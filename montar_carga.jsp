 <%@page import="nucleo.SituacaoTributavelICMS"%>
<%@page import="nucleo.SituacaoTributavel"%>
<%@page import="conhecimento.coleta.tipoContainer.ConsultaTipoContainer"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         java.text.*,
         mov_banco.*,
         mov_banco.conta.*,
         cliente.*,
         conhecimento.orcamento.Cubagem,
         cliente.tipoProduto.*,
         conhecimento.*,
         despesa.BeanDespesa,
         despesa.apropriacao.BeanApropDespesa,
         despesa.duplicata.*,
         despesa.apropriacao.*,
		 viagem.BeanViagem,
         conhecimento.duplicata.*,
         conhecimento.apropriacao.*,
		 conhecimento.manifesto.*,
		 conhecimento.cartafrete.*,
         nucleo.BeanLocaliza,
         com.sagat.bean.NotaFiscal,
         tipo_veiculos.*,
         nucleo.BeanConfiguracao,
         fpag.*,
         java.util.*,
         filial.*,
         org.json.simple.JSONObject,
         nucleo.Apoio"
         %>
<%@page import="conhecimento.coleta.BeanConsultaColeta"%>
<%@page import="org.json.simple.* "%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="conhecimento.orcamento.Cubagem"%>
<%
            int nivelUser = Apoio.getUsuario(request).getAcesso("cadconhecimento");
            int nivelUserFl = Apoio.getUsuario(request).getAcesso("lanconhfl");
            int nivelUserAlteraCidade = Apoio.getUsuario(request).getAcesso("alterarcidadetabela");
            int nivelAlteraCtrc = Apoio.getUsuario(request).getAcesso("altnumctrc");
            int nivelComissao = Apoio.getUsuario(request).getAcesso("vercomissao");
			int nivelAlterarFrete = Apoio.getUsuario(request).getAcesso("alttabprecolanccontrfrete");
			int nivelUserAdiantamento = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("alterapercadiant") : 0);
            boolean allowChangeTablePrice = (Apoio.getUsuario(request).getAcesso("cadtabelacliente") >= 2);
            boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
            int idUsuario = Apoio.getUsuario(request).getIdusuario();
            
            //-- criado em 31/03/2016 utilizado na nova trava de valor maximo
            String valoresMaximosFiliais = "";
            String idsFiliais = "";
            String isAtivaValorMaximo = "";
            //---------------------------------------------------------------
            Collection<SituacaoTributavel> listaStIcms = SituacaoTributavelICMS.mostrarTodos(Apoio.getUsuario(request).getConexao());
//testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
			String fpagCartaFrete = "";

            BeanConfiguracao cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            cfg.CarregaConfig();

            if (acao.equals("localizaClienteCodigo")){
                String filialId = (request.getParameter("filialId"));
                String resultado = "";
				String ufDestinatario = (request.getParameter("dest_uf") == null ? "" : request.getParameter("dest_uf"));
				String cidadeDestinoId = (request.getParameter("idcidadedestino") == null || request.getParameter("idcidadedestino").equals("0") ? "" : request.getParameter("idcidadedestino"));
                BeanCadCliente cli = new BeanCadCliente();
                cli.setConexao(Apoio.getUsuario(request).getConexao());
                ResultSet rs = cli.getLocalizaClienteCodigo((request.getParameter("idcliente").equals("") ? "0" : request.getParameter("idcliente")), Integer.parseInt(request.getParameter("idfilial")), "idcliente", "", ufDestinatario, "", cidadeDestinoId, 0,filialId);
                if (rs == null){
                    resultado = "null";
                } else {
                    if (rs.next()) {
                        resultado = rs.getString("idcliente") + "!=!" + rs.getString("razao") + "!=!" + rs.getString("cidade") + "!=!" +
                                rs.getString("uf") + "!=!" + rs.getString("cnpj") + "!=!" + rs.getString("pgt") + "!=!" + rs.getString("tipotaxa") + "!=!" +
                                rs.getString("idvendedor") + "!=!" + rs.getString("vendedor") + "!=!" + rs.getString("idcidade") + "!=!" +
                                rs.getString("vlvendedor") + "!=!" + rs.getString("tipofpag");
                        if (request.getParameter("idfilial").equals("0")) {
                            resultado += "!=!0!=!"+rs.getString("obs_cli");
                        } else {
                            resultado += "!=!" + rs.getString("aliquota") + "!=!" + rs.getString("obs");
                        }
                                resultado += "!=!" + rs.getString("st_mg") + "!=!" + rs.getString("unificada_modal_vendedor") + "!=!" + 
                                rs.getString("comissao_rodoviario_fracionado_vendedor") + "!=!" + rs.getString("comissao_rodoviario_lotacao_vendedor")+"!=!"+
                                rs.getString("tipo_documento_padrao")+"!=!"+rs.getBoolean("is_utilizar_tipo_frete_tabela")+"!=!"+rs.getString("st_icms")+"!=!"+rs.getString("tipo_arredondamento_peso")
                                +"!=!"+rs.getString("tipo_tributacao");
                    }
                }
                response.getWriter().append(resultado);
                response.getWriter().close();
            }

            if (acao.equals("carregar_taxascli")){
                BeanCadTabelaCliente cadTabCli = new BeanCadTabelaCliente();
                cadTabCli.setConexao(Apoio.getUsuario(request).getConexao());
                cadTabCli.setExecutor(Apoio.getUsuario(request));
                SimpleDateFormat formatDate = new SimpleDateFormat("dd/MM/yyyy");
                Date DataEmissao = Apoio.paraDate(request.getParameter("dtemissao"));
                JSONObject jo = new JSONObject();
                int remetente_id = Integer.parseInt(Apoio.coalesce(request.getParameter("idCliente"), "0"));
                int tipo_veiculo_id = Integer.parseInt(Apoio.coalesce(request.getParameter("tipoveiculo"), "0"));
                int product_type_id = Integer.parseInt(Apoio.coalesce(request.getParameter("tipoproduto"), "0"));
                int cidade_origem_id = Integer.parseInt(Apoio.coalesce(request.getParameter("idcidadeorigem"), "0"));
                int cidade_destino_id = Integer.parseInt(Apoio.coalesce(request.getParameter("idcidadedestino"), "0"));
                float peso = Float.parseFloat(Apoio.coalesce(request.getParameter("peso"), "0"));
                int km = Integer.parseInt(Apoio.coalesce(request.getParameter("total_km"), "0"));

                //obtendo a tabela de taxas do cliente informado...
                ResultSet tabela = null;
                if (request.getParameter("idTaxa").equals("5")) {
                              tabela = cadTabCli.loadTableByKm(remetente_id,
					 tipo_veiculo_id, 
					 product_type_id, 
					 km);
                } else {
                    tabela = cadTabCli.loadTableByCity(remetente_id,
                            cidade_origem_id,
                            cidade_destino_id,
                            tipo_veiculo_id,
                            product_type_id,
                            peso,
                            "r",0,"n");
                }
                if (tabela != null && tabela.next()) {
                    for (int i = 1; i <= tabela.getMetaData().getColumnCount(); ++i) {
                        if (tabela.getString(i) != null) {
                            //se eh um tipo boolean(valor f ou t e inicia com "is")
                            if ((tabela.getString(i).equals("f") || tabela.getString(i).equals("t")) && tabela.getMetaData().getColumnName(i).startsWith("is")) {
                                jo.put(tabela.getMetaData().getColumnName(i), tabela.getBoolean(i) + "");
                            } else {
                                jo.put(tabela.getMetaData().getColumnName(i), tabela.getString(i));
                            }
                        }
                    }
                    
                    String previsaoEntrega = "";
                    int prazoEntrega = tabela.getInt("prazo_entrega");
                    String tipoPrazoEntrega = tabela.getString("tipo_dias_entrega");
                    if (prazoEntrega == 0) {
                        previsaoEntrega = "";
                    } else if (tipoPrazoEntrega.equals("c")) {
                        previsaoEntrega = formatDate.format(Apoio.incData(DataEmissao, prazoEntrega));
                   } else if (tipoPrazoEntrega.equals("u")) {
                        previsaoEntrega = formatDate.format(Apoio.incDataUteis(DataEmissao, prazoEntrega));
                    } else if (tipoPrazoEntrega.equals("e")) {
                        previsaoEntrega = formatDate.format(Apoio.incDataEntregaUtil(DataEmissao, prazoEntrega));
                    } else {
                        previsaoEntrega = "";
                    }
                    jo.put("previsao_entrega_calculada", previsaoEntrega);
                    
                    tabela.close();

                    response.getWriter().append(jo.toString().replace("\"false\"", "false").replace("\"true\"", "true"));
                    if (tabela.getArray("ids_desativar") != null) {
                        BeanCadConhecimento cadCt = new BeanCadConhecimento();
                        cadCt.desativarTabela(tabela.getArray("ids_desativar"));
                    }
                } else {
                    response.getWriter().append("load=0");
                }
                response.getWriter().close();
            }else if (acao.equals("salvar")) {
                int qtdCtrc = Integer.parseInt(request.getParameter("qtdCtrc"));
                String tipoMontagem = request.getParameter("tipoMontagem");
                int idCfopComercioDentro = cfg.getCfopDefault().getIdcfop();
					int idPlanoCfopComercioDentro = cfg.getCfopDefault().getPlanoCusto().getIdconta();
                int idCfopComercioFora = cfg.getCfopDefault2().getIdcfop();
					int idPlanoCfopComercioFora = cfg.getCfopDefault2().getPlanoCusto().getIdconta();
                int idCfopIndustriaDentro = cfg.getCfopIndustriaDentro().getIdcfop();
					int idPlanoCfopIndustriaDentro = cfg.getCfopIndustriaDentro().getPlanoCusto().getIdconta();
                int idCfopIndustriaFora = cfg.getCfopIndustriaFora().getIdcfop();
					int idPlanoCfopIndustriaFora = cfg.getCfopIndustriaFora().getPlanoCusto().getIdconta();
                int idCfopPFDentro = cfg.getCfopPessoaFisicaDentro().getIdcfop();
					int idPlanoCfopPFDentro = cfg.getCfopPessoaFisicaDentro().getPlanoCusto().getIdconta();
                int idCfopPFFora = cfg.getCfopPessoaFisicaFora().getIdcfop();
					int idPlanoCfopPFFora = cfg.getCfopPessoaFisicaFora().getPlanoCusto().getIdconta();
                int idCfopOutroEstado = cfg.getCfopOutroEstado().getIdcfop();
					int idPlanoCfopOutroEstado = cfg.getCfopOutroEstado().getPlanoCusto().getIdconta();
                int idCfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getIdcfop();
					int idPlanoCfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getPlanoCusto().getIdconta();
                int idCfopTransporteDentro = cfg.getCfopTransporteDentro().getIdcfop();
					int idPlanoCfopTransporteDentro = cfg.getCfopTransporteDentro().getPlanoCusto().getIdconta();
                int idCfopTransporteFora = cfg.getCfopTransporteFora().getIdcfop();
					int idPlanoCfopTransporteFora = cfg.getCfopTransporteFora().getPlanoCusto().getIdconta();
                int idCfopServicoDentro = cfg.getCfopPrestadorServicoDentro().getIdcfop();
					int idPlanoCfopServicoDentro = cfg.getCfopPrestadorServicoDentro().getPlanoCusto().getIdconta();
                int idCfopServicoFora = cfg.getCfopPrestadorServicoFora().getIdcfop();
					int idPlanoCfopServicoFora = cfg.getCfopPrestadorServicoFora().getPlanoCusto().getIdconta();
                int idCfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getIdcfop();
					int idPlanoCfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getPlanoCusto().getIdconta();
                int idCfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getIdcfop();
					int idPlanoCfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getPlanoCusto().getIdconta();
                int idCfopExteriorDentro = cfg.getCfopExteriorDentro().getIdcfop();
					int idPlanoCfopExteriorDentro = cfg.getCfopExteriorDentro().getPlanoCusto().getIdconta();
                int idCfopExteriorFora = cfg.getCfopExteriorFora().getIdcfop();
					int idPlanoCfopExteriorFora = cfg.getCfopExteriorFora().getPlanoCusto().getIdconta();
                int idCfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getIdcfop();
                                        int idPlanoCfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getPlanoCusto().getIdconta();
                int idCfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getIdcfop();
                                        int idPlanoCfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getPlanoCusto().getIdconta();
                String tipoServico = request.getParameter("tipoServico");
                String tipoCfop = "c";
                String cnpjTipoCfop = "";
                String ufFilial = Apoio.getUsuario(request).getFilial().getCidade().getUf();
                String ufDestinatario = "";
                String ufRemetente = "";
                BeanCadConhecimento cadCt = new BeanCadConhecimento();
                cadCt.setConexao(Apoio.getUsuario(request).getConexao());
                cadCt.setExecutor(Apoio.getUsuario(request));
                BeanConhecimento ctrc;
                BeanConhecimento arCtrcs[] = new BeanConhecimento[qtdCtrc];
                String sufix = "";
                Cubagem cubnf;
                String ieConsig = "";
                int idFilialAll = 0;
                if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 0) {
                    idFilialAll = Apoio.parseInt(request.getParameter("filialId"));                    
                }else{
                    idFilialAll = Apoio.getUsuario(request).getFilial().getIdfilial();
                }
                BeanFilial fi = null;
                BeanCadFilial beanCadFilial = new BeanCadFilial();
                beanCadFilial.setExecutor(Apoio.getUsuario(request));
                beanCadFilial.setConexao(Apoio.getUsuario(request).getConexao());
                beanCadFilial.getFilial().setIdfilial(idFilialAll);
                beanCadFilial.LoadAllPropertys();
                fi = beanCadFilial.getFilial();
                String chaveCte = "";                
                
                for (int x = 0; x <= qtdCtrc; x++) {
                    if (request.getParameter("idDest_" + x) != null) {
                        ctrc = new BeanConhecimento();
                        ctrc.setEspecie(request.getParameter("especie"));
                        ctrc.setSerie(request.getParameter("serie"));
                        ctrc.setNumero("");
                        ctrc.setNumeroCarga(request.getParameter("numeroCarga"));
                        ctrc.setPedidoCliente(request.getParameter("numeroPedido"));
                        ctrc.setEmissaoEm(request.getParameter("dtemissao"));
                        ctrc.setPrevisaoEntrega(request.getParameter("dataEntrega_"+x));
                        ctrc.setCategoria("ct");
                        ctrc.setCreatedBy(Apoio.getUsuario(request));
                        ctrc.setCreatedAt(Apoio.paraDate(Apoio.getDataAtual()));
                        //ctrc.setHistorico("Frete");
                        //se o usuario pode lancar conhecimentos para outras filiais...
//                        if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 0) {
//                            ctrc.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
//                        } else {
//                            ctrc.getFilial().setIdfilial(Apoio.getUsuario(request).getFilial().getIdfilial());
//                        }
                        ctrc.getFilial().setIdfilial(idFilialAll);
                        
                        ctrc.getFilial().getCidade().setUf(request.getParameter("uf_fl_"+ctrc.getFilial().getIdfilial()));
                        
                        if (tipoMontagem.equals("r")){
                            ctrc.getRemetente().setIdcliente(Integer.parseInt(request.getParameter("idCliente")));
                            ufRemetente = request.getParameter("ufRemetente");
                            ctrc.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("idDest_" + x)));
                            ctrc.getCliente().setIdcliente(Integer.parseInt(request.getParameter("tipo_frete").equals("fob") ? request.getParameter("idDest_" + x) : request.getParameter("idCliente")));
                            ufDestinatario = request.getParameter("ufCfopDest_" + x);
			    if (request.getParameter("tipo_frete").equals("cif")){
            		        ctrc.getCliente().getCidade().setUf(request.getParameter("ufRemetente"));
                                tipoCfop = request.getParameter("rem_tipo_cfop");
                                cnpjTipoCfop = request.getParameter("cnpjRemetente");
                                ieConsig = request.getParameter("rem_insc_est");
			    }else{
                                tipoCfop = request.getParameter("tipoCfopDest_" + x);
                                cnpjTipoCfop = request.getParameter("cnpjCfopDest_" + x);
                                ieConsig = request.getParameter("ieDest_" + x);
                            }
                        }else if (tipoMontagem.equals("d")){
                            ctrc.getRemetente().setIdcliente(Integer.parseInt(request.getParameter("idDest_" + x)));
                            ufRemetente = request.getParameter("ufCfopDest_" + x);
                            ctrc.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("idCliente")));
                            ufDestinatario = request.getParameter("ufRemetente");
			    if (request.getParameter("tipo_frete").equals("cif")){
                                tipoCfop = request.getParameter("tipoCfopDest_" + x);
                                cnpjTipoCfop = request.getParameter("cnpjCfopDest_" + x);
                                ieConsig = request.getParameter("ieRem_" + x);
                            }else{
                                tipoCfop = request.getParameter("des_tipo_cfop");
                                cnpjTipoCfop = request.getParameter("cnpjRemetente");
                                ieConsig = request.getParameter("dest_insc_est");
                            }
                            ctrc.getCliente().setIdcliente(Integer.parseInt(request.getParameter("tipo_frete").equals("fob") ? request.getParameter("idCliente") : request.getParameter("idDest_" + x)));
                        }else if (tipoMontagem.equals("v")){
                            ctrc.getRemetente().setIdcliente(Integer.parseInt(request.getParameter("idRem_" + x)));
                            ufRemetente = request.getParameter("ufRem_" + x);
                            ctrc.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("idDest_" + x)));
                            tipoCfop = request.getParameter("tipoCfopDest_" + x);
                            cnpjTipoCfop = request.getParameter("cnpjCfopDest_" + x);
                            ufDestinatario = request.getParameter("ufCfopDest_" + x);
                            ctrc.getCliente().setIdcliente(Integer.parseInt(request.getParameter("tipo_frete").equals("fob") ? request.getParameter("idDest_" + x) : request.getParameter("idRem_" + x)));
                            ieConsig = (request.getParameter("tipo_frete").equals("fob") ? request.getParameter("ieDest_" + x) : request.getParameter("ieRem_" + x));
                        }
                        //Verificando CFOP
                        if(tipoServico.equals("s")){//Fretes com destinatario para fora do pais
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopSubContratacaoDentro : idCfopSubContratacaoFora);
                            ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopSubContratacaoDentro : idPlanoCfopSubContratacaoFora);
                        }else if (ufDestinatario.equals("EX")){ 
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufRemetente) ? idCfopExteriorDentro : idCfopExteriorFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufRemetente) ? idPlanoCfopExteriorDentro : idPlanoCfopExteriorFora);
                        }else if (!ufFilial.equals(ufRemetente)){
                            ctrc.getCfop().setIdcfop(ufRemetente.equals(ufDestinatario) ? idCfopOutroEstado : idCfopOutroEstadoFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufRemetente.equals(ufDestinatario) ? idPlanoCfopOutroEstado : idPlanoCfopOutroEstadoFora);
                        }else if (cnpjTipoCfop.length() == 14 && ieConsig.equals("ISENTO")){
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopPFDentro : idCfopPFFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopPFDentro : idPlanoCfopPFFora);
                        }else if (tipoCfop.equals("c")){
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopComercioDentro : idCfopComercioFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopComercioDentro : idPlanoCfopComercioFora);
                        }else if (tipoCfop.equals("i")){
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopIndustriaDentro : idCfopIndustriaFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopIndustriaDentro : idPlanoCfopIndustriaFora);
                        }else if (tipoCfop.equals("t")){
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopTransporteDentro : idCfopTransporteFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopTransporteDentro : idPlanoCfopTransporteFora);
                        }else if (tipoCfop.equals("p")){
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopServicoDentro : idCfopServicoFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopServicoDentro : idPlanoCfopServicoFora);
                        }else if (tipoCfop.equals("r")){
                            ctrc.getCfop().setIdcfop(ufFilial.equals(ufDestinatario) ? idCfopProdutorRuralDentro : idCfopProdutorRuralFora);
			    ctrc.getCfop().getPlanoCusto().setIdconta(ufFilial.equals(ufDestinatario) ? idPlanoCfopProdutorRuralDentro : idPlanoCfopProdutorRuralFora);
                        } 

                        ctrc.setPago(request.getParameter("tipo_frete").equals("cif"));
                        ctrc.setCalculadoAte(request.getParameter("cid_destino") + "/" + request.getParameter("uf_destino"));
                        ctrc.getRedespacho().setIdcliente(Integer.parseInt(request.getParameter("idClienteRedespacho_" + x)));
                        ctrc.setRedespachoPago(!request.getParameter("idClienteRedespacho_" + x).equals("0"));
                        ctrc.setRedespachoCtrc(request.getParameter("ctrcRedespacho_" + x));
                        ctrc.setRedespachoValor(Float.parseFloat(request.getParameter("valorCtrcRedespacho_" + x)));
                        ctrc.setValorTaxaFixa(Float.parseFloat(request.getParameter("vlTaxa_" + x)));
                        ctrc.setValorITR(0);
                        ctrc.setValorPeso(Float.parseFloat(request.getParameter("vlFretePeso_" + x)));
                        ctrc.setValorFrete(Float.parseFloat(request.getParameter("vlFreteValor_" + x)));
                        ctrc.setValorDespacho(0);
                        ctrc.setValorAdeme(0);
                        ctrc.setValorOutros(Float.parseFloat(request.getParameter("vlOutros_" + x)));
                        ctrc.setValor_pedagio(Float.parseFloat(request.getParameter("vlPedagio_" + x)));
                        ctrc.setValor_desconto(0);
                        ctrc.setValor_sec_cat(Float.parseFloat(request.getParameter("vlSecCat_" + x)));
                        ctrc.setValor_gris(Float.parseFloat(request.getParameter("vlGris_" + x)));
                        ctrc.setBaseCalculo(Float.parseFloat(request.getParameter("vlTotal_" + x)));
                        ctrc.setAliquota(Float.parseFloat(request.getParameter("vlAliqIcms_" + x)));
                        ctrc.setEntrega(request.getParameter("cid_destino") + "-" + request.getParameter("uf_destino"));
                        ctrc.setLocalColeta(request.getParameter("cid_origem") + "-" + request.getParameter("uf_origem"));
                        ctrc.setDistanciaOrigemDestino(Integer.parseInt(request.getParameter("total_km")));
                        String obs = request.getParameter("obsLinha1_" + x) + "<br>" + request.getParameter("obsLinha2_" + x) + "<br>" + request.getParameter("obsLinha3_" + x) + "<br>" + request.getParameter("obsLinha4_" + x) + "<br>" + request.getParameter("obsLinha5_" + x);
                        ctrc.setObservacao(obs.split("<br>"));
                        ctrc.setTipoTaxa(Integer.parseInt(request.getParameter("tipotaxa")));
                        ctrc.getTipoveiculo().setId(Integer.parseInt(request.getParameter("tipoveiculo")));
                        ctrc.getTipoProduto().setId(Integer.parseInt(request.getParameter("tipoproduto")));
                        ctrc.setCubagem_altura(Float.parseFloat(request.getParameter("altura_" + x)));
                        ctrc.setCubagem_largura(Float.parseFloat(request.getParameter("largura_" + x)));
                        ctrc.setCubagem_comprimento(Float.parseFloat(request.getParameter("comprimento_" + x)));
                        ctrc.setCubagemBase(Float.parseFloat(request.getParameter("base_" + x)));
                        ctrc.setCubagemMetro(Float.parseFloat(request.getParameter("metro_" + x)));
                        ctrc.setAddedIcms(request.getParameter("chk_incluir_icms") != null);
                        ctrc.setIcmsBarreira(0);
                        ctrc.getColeta().setId(Integer.parseInt(request.getParameter("idcoleta")));
                        ctrc.setRedespachanteTipoTaxa(Integer.parseInt(request.getParameter("tabelaRed_" + x)));
                        ctrc.getRedespachante().setIdfornecedor(Integer.parseInt(request.getParameter("idRedespacho_" + x)));
                        ctrc.setRedespachanteValor(Float.parseFloat(request.getParameter("valorRed_" + x)));
                        ctrc.setCancelado(false);
                        ctrc.getVendedor().setIdfornecedor(Integer.parseInt(request.getParameter("idvendedor")));
                        ctrc.setComissaoVendedor(Double.parseDouble(request.getParameter("comissaoVendedor")));
                        ctrc.setQtde_entregas(1);
                        ctrc.getAgencia().setId(0);
                        ctrc.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
                        ctrc.getVeiculo().setIdveiculo(Integer.parseInt(request.getParameter("idveiculo")));
                        ctrc.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("idcarreta")));
                        ctrc.getBiTrem().setIdveiculo(Integer.parseInt(request.getParameter("idbitrem")));
                        ctrc.getTabelaCliente().setId(Integer.parseInt(request.getParameter("idtabela")));
						ctrc.getRota().setId(Integer.parseInt(request.getParameter("id_rota_viagem_real")));
                        ctrc.getCidadeOrigem().setIdcidade(Integer.parseInt(request.getParameter("idCidadeRemetente")));
                        ctrc.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("idCidadeDest_" + x)));
                        ctrc.getCidadeDestino().setUf(request.getParameter("uf_destino"));
                        ctrc.setTipoTransporte("r");
                        ctrc.setTipo(request.getParameter("tipoConhecimento"));
                        ctrc.setTipoFpag("p");
                        ctrc.getFilialRecebedora().setIdfilial(0);

			ctrc.setNumeroContainer(request.getParameter("numero_container"));
			ctrc.getTipoContainer().setId(Integer.parseInt(request.getParameter("tipo_container")));
			ctrc.setNumeroGenset(request.getParameter("genset"));
			ctrc.setNumeroLacre(request.getParameter("lacre_container"));
			ctrc.setNumeroBooking(request.getParameter("booking"));
			ctrc.getNavio().setId(Integer.parseInt(request.getParameter("idnavio")));
			ctrc.setNumeroViagemNavio(request.getParameter("viagem_container"));
			ctrc.getArmador().setIdcliente(Integer.parseInt(request.getParameter("idarmador").equals("")?"0":request.getParameter("idarmador")));
			ctrc.getTerminal().setId(Integer.parseInt(request.getParameter("idterminal")));
			ctrc.setPesoContainer(Float.parseFloat(request.getParameter("peso_container")));
			ctrc.setValorContainer(Float.parseFloat(request.getParameter("valor_container")));
                        ctrc.getStIcms().setId(Apoio.parseInt(request.getParameter("stIcms_" + x)));
                        ctrc.setModalCte(Apoio.getUsuario(request).getFilial().getModalCTE());
                        
                        ctrc.getColeta().setCategoria(request.getParameter("gerar_" + x));
                        ctrc.setTipoServico(request.getParameter("tipoServico"));

                        //Adicionando as duplicatas
                        int diasPagto = 0;
                        BeanDuplicata[] bean_dups = new BeanDuplicata[1];
                        BeanDuplicata du = new BeanDuplicata();
                        du.setId(0);
                        du.setDuplicata(1);
                        if (tipoMontagem.equals("r")){
                            if (request.getParameter("tipo_frete").equals("cif")){
                                diasPagto = Integer.parseInt(request.getParameter("rem_pgt"));
                            }else{
                                diasPagto = Integer.parseInt(request.getParameter("pagtoDest_" + x));
                            }
                        }else if (tipoMontagem.equals("d")){
                            if (request.getParameter("tipo_frete").equals("cif")){
                                diasPagto = Integer.parseInt(request.getParameter("pagtoDest_" + x));
                            }else{
                                diasPagto = Integer.parseInt(request.getParameter("dest_pgt"));
                            }
                        }else if (tipoMontagem.equals("v")){
                            if (request.getParameter("tipo_frete").equals("cif")){
                                diasPagto = Integer.parseInt(request.getParameter("pagtoRem_" + x));
                            }else{
                                diasPagto = Integer.parseInt(request.getParameter("pagtoDest_" + x));
                            }
                        }
                        du.setDtvenc(Apoio.incData(Apoio.paraDate(request.getParameter("dtemissao")),diasPagto));
                        du.setVlduplicata(ctrc.getStIcms().getId() != 9 ? Double.parseDouble(request.getParameter("vlTotal_" + x)) : Double.parseDouble(request.getParameter("vlTotal_" + x)) - Apoio.toFixed(ctrc.getVlIcms(), 2));
                        ctrc.getDuplicatas().add(0, du);
                        //Adicionando a apropriação
                        BeanApropriacao[] bean_aprops = new BeanApropriacao[1];
                        BeanApropriacao ap = new BeanApropriacao();
                        if (ctrc.getCfop().getPlanoCusto().getIdconta()!=0){
                            ap.getPlanocusto().setIdconta(ctrc.getCfop().getPlanoCusto().getIdconta());
                        }else{
                            ap.getPlanocusto().setIdconta((request.getParameter("idAprop_" + x).equals("0")?cfg.getPlanoDefault().getIdconta():Integer.parseInt(request.getParameter("idAprop_" + x))));
                        }
                        ap.setValor(Double.parseDouble(request.getParameter("vlTotal_" + x)));
                        ap.getUnidadeCusto().setId(Integer.parseInt(request.getParameter("idUnd_" + x)));
                        ctrc.getApropriacoes().add(0, ap);
                        
                        int qtdNotas = Integer.parseInt(request.getParameter("qtdNotas"));
                        //Adicionando as notas fiscais
                        NotaFiscal arNf[] = new NotaFiscal[qtdNotas + 1];
                        NotaFiscal nf;
                        
                        for (int y = 0; y <= qtdNotas; y++) {
                            if (request.getParameter("nf_valor" + y + "_id" + x) != null) {
                                //Dados da coleta
                                nf = new NotaFiscal();
                                nf.setIdnotafiscal(Integer.parseInt(request.getParameter("nf_idnota_fiscal" + y + "_id" + x)));
                                nf.setNumero(request.getParameter("nf_numero" + y + "_id" + x));
                                nf.setSerie(request.getParameter("nf_serie" + y + "_id" + x));
                                nf.setEmissao(Apoio.paraDate(request.getParameter("nf_emissao" + y + "_id" + x)));
                                nf.setValor(Double.parseDouble(request.getParameter("nf_valor" + y + "_id" + x)));
                                nf.setVl_base_icms(Float.parseFloat(request.getParameter("nf_base_icms" + y + "_id" + x)));
                                nf.setVl_icms(Float.parseFloat(request.getParameter("nf_icms" + y + "_id" + x)));
                                nf.setVl_icms_frete(Float.parseFloat(request.getParameter("nf_icms_frete" + y + "_id" + x)));
                                nf.setVl_icms_st(Float.parseFloat(request.getParameter("nf_icms_st" + y + "_id" + x)));
                                nf.setPeso(Float.parseFloat(request.getParameter("nf_peso" + y + "_id" + x)));
                                nf.setVolume(Float.parseFloat(request.getParameter("nf_volume" + y + "_id" + x)));
                                nf.setEmbalagem(request.getParameter("nf_embalagem" + y + "_id" + x));
                                nf.setConteudo(request.getParameter("nf_conteudo" + y + "_id" + x));
                                nf.setPedido(request.getParameter("nf_pedido" + y + "_id" + x));
                                nf.setTipoDocumento(request.getParameter("nf_tipoDocumento" + y + "_id" + x));

                                //campos corrigidos apartir 27/05
                                nf.setLargura(Float.parseFloat(request.getParameter("nf_largura" + y + "_id" + x).replaceAll(",", ".")));
                                nf.setAltura(Float.parseFloat(request.getParameter("nf_altura" + y + "_id" + x).replaceAll(",", ".")));
                                nf.setComprimento(Float.parseFloat(request.getParameter("nf_comprimento" + y + "_id" + x).replaceAll(",", ".")));
                                nf.setMetroCubico(Float.parseFloat(request.getParameter("nf_metroCubico" + y + "_id" + x).replaceAll(",", ".")));
                                String idMarcaVeiculo = request.getParameter("nf_id_marca_veiculo" + y + "_id" + x);
                                nf.getMarcaVeiculo().setIdmarca(Integer.parseInt(idMarcaVeiculo.equals("")?"0":idMarcaVeiculo));
                                nf.setModeloVeiculo(request.getParameter("nf_modelo_veiculo" + y + "_id" + x));
                                nf.setAnoVeiculo(request.getParameter("nf_ano_veiculo" + y + "_id" + x));
                                nf.setCorVeiculo(Integer.parseInt(request.getParameter("nf_cor_veiculo" + y + "_id" + x)));
                                nf.setChassiVeiculo(request.getParameter("nf_chassi_veiculo" + y + "_id" + x));
                                //Veiculos Novos
                                nf.setPlacaVeiculo(request.getParameter("nf_placa_veiculo" + y + "_id" + x));
                                nf.setVeiculoNovo(Apoio.parseBoolean(request.getParameter("nf_veiculo_novo" + y + "_id" + x)));
                                nf.setCorFabVeiculo(request.getParameter("nf_cor_fab" + y + "_id" + x));
                                nf.setMarcaModeloVeiculo(request.getParameter("nf_marcamodelo_veiculo" + y + "_id" + x));

                                String idCfopNota = request.getParameter("nf_cfopId" + y + "_id" + x);
                                nf.getCfop().setIdcfop(Integer.parseInt(idCfopNota.equals("")?"0":idCfopNota));
                                nf.setChaveNFe(request.getParameter("nf_chave_nf" + y + "_id" + x));

                                nf.setAgendado(new Boolean(request.getParameter("nf_is_agendado" + y + "_id" + x)));
                                nf.setDataAgenda(Apoio.paraDate(request.getParameter("nf_data_agenda" + y + "_id" + x)));
                                nf.setHoraAgenda(request.getParameter("nf_hora_agenda" + y + "_id" + x));
                                nf.setObservacaoAgenda(request.getParameter("nf_obs_agenda" + y + "_id" + x));

                                nf.setPrevisaoEm(Apoio.paraDate(request.getParameter("nf_previsao_entrega" + y + "_id" + x)));
                                nf.setPrevisaoAs(request.getParameter("nf_previsao_as" + y + "_id" + x));
                                nf.getDestinatario().setIdcliente(Integer.parseInt((request.getParameter("nf_id_destinatario" + y + "_id" + x))));

                                sufix = y + "_id" + x;
                                int qtdItensMetro = Integer.parseInt(request.getParameter("maxItensMetro" + sufix));

                                Cubagem arCub[] = new Cubagem[qtdItensMetro + 1];
                                int it = 0;
                                

                                for (int s = 0; s <= qtdItensMetro; s++) {
                                    if (request.getParameter("nf_metroId_" + sufix + s) != null) {
                                        cubnf = new Cubagem();
                                        cubnf.setId(Integer.parseInt(request.getParameter("nf_metroId_" + sufix + s)));
                                        cubnf.setAltura(Double.parseDouble(request.getParameter("nf_itemAltura_" + sufix + s)));
                                        cubnf.setComprimento(Double.parseDouble(request.getParameter("nf_metroComprimento_" + sufix + s)));
                                        cubnf.setLargura(Double.parseDouble(request.getParameter("nf_metroLargura_" + sufix + s)));
                                        cubnf.setMetroCubico(Double.parseDouble(request.getParameter("nf_metroCubico_" + sufix + s)));
                                        cubnf.setVolume(Double.parseDouble(request.getParameter("nf_metroVolume_" + sufix + s)));
                                        arCub[it] = cubnf;
                                        it++;
                                    }
                                }
                                nf.setCubagens(arCub);
                                
                                arNf[y] = nf;
                            }
                        }
                        ctrc.setNotaFiscal(arNf);
                        
                        
                        //if (!Apoio.isApenasNumeros(ctrc.getSerie())) {
                             //chaveCte = ctrc.getChave104Minuta(fi.getCidade().getCod_ibge(), fi.getStUtilizacaoCte(), fi.getCnpj()).getString();
                             //ctrc.setChaveAcessoCte(chaveCte);
                        //}
                        
                        arCtrcs[x] = ctrc;

                    }
                }

                cadCt.setArrayBCtrc(arCtrcs);
				boolean isGeraCarta = request.getParameter("chk_carta_automatica") != null;
                
				BeanManifesto man = null;
				BeanCartaFrete cFrete = null;
				if (isGeraCarta && cfg.isCartaFreteAutomatica()){
					man = new BeanManifesto();
					man.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
					man.getCavalo().setIdveiculo(Integer.parseInt(request.getParameter("idveiculo")));
					man.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("idcarreta")));
					man.getCidadeorigem().setIdcidade(Integer.parseInt(request.getParameter("idcidadeorigem")));
					man.getCidadedestino().setIdcidade(Integer.parseInt(request.getParameter("idcidadedestino")));
					man.setDtsaida(Apoio.paraDate(request.getParameter("dtemissao")));
					man.setHrsaida(new SimpleDateFormat("HH:mm").format(new Date()));
					man.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
					man.getFilialdestino().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
					man.getSeguradora().setIdfornecedor(Integer.parseInt(request.getParameter("seguradora_id")));
					man.getAgenteCarga().setIdfornecedor(Integer.parseInt(request.getParameter("idagente_carga")));
					man.setLibmotorista(request.getParameter("motor_liberacao"));
					man.setSerieMdfe(Apoio.getUsuario(request).getFilial().getSerieMdfe());
                                        
					cFrete = new BeanCartaFrete();
					
					cFrete.setData(Apoio.paraDate(request.getParameter("dtemissao")));
					cFrete.setVldependentes(0);
					cFrete.setVlbaseir(Float.parseFloat(request.getParameter("baseIR")));
					cFrete.setAliqir(Float.parseFloat(request.getParameter("aliqIR")));
					cFrete.setVlir(Float.parseFloat(request.getParameter("valorIR")));
					cFrete.setVlJaRetido(Float.parseFloat(request.getParameter("inss_prop_retido")));
					cFrete.setVlOutrasEmpresas(0);
					cFrete.setVlbaseinss(Float.parseFloat(request.getParameter("baseINSS")));
					cFrete.setAliqinss(Float.parseFloat(request.getParameter("aliqINSS")));
					cFrete.setVlinss(Float.parseFloat(request.getParameter("valorINSS")));
					cFrete.setBaseSestSenat(Float.parseFloat(request.getParameter("baseINSS")));
					cFrete.setAliqsestsenat(Float.parseFloat(request.getParameter("aliqSEST")));
					cFrete.setVlsestsenat(Float.parseFloat(request.getParameter("valorSEST")));
					cFrete.setVlAvaria(0);
					cFrete.setVlFreteMotorista(Float.parseFloat(request.getParameter("cartaValorFrete")));
					cFrete.setOutrosdescontos(Float.parseFloat(request.getParameter("cartaOutros")));
					cFrete.setObsoutrosdescontos("");
                                        cFrete.setReterImpostos(request.getParameter("chk_reter_impostos") != null ? true : false );
					cFrete.setVlImpostos(Float.parseFloat(request.getParameter("cartaImpostos")));
					cFrete.setValorPedagio(Double.parseDouble(request.getParameter("cartaPedagio")));
					cFrete.setVlLiquido(Float.parseFloat(request.getParameter("cartaLiquido")));
					cFrete.setVlOutrasDeducoes(Float.parseFloat(request.getParameter("cartaRetencoes")));
					cFrete.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId"))); 
					cFrete.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
					cFrete.getMotorista().setNome(request.getParameter("motor_nome"));
					cFrete.getVeiculo().setIdveiculo(Integer.parseInt(request.getParameter("idveiculo")));
					cFrete.getContratado().setIdfornecedor(Integer.parseInt(request.getParameter("idproprietarioveiculo")));
					cFrete.getContratado().getPlanoCustoPadrao().setIdconta(Integer.parseInt(request.getParameter("plano_proprietario")));
					cFrete.getContratado().getUnidadeCusto().setId(Integer.parseInt(request.getParameter("und_proprietario")));
					cFrete.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("idcarreta")));
					cFrete.getRota().setId(Integer.parseInt(request.getParameter("id_rota_viagem_real")));
					cFrete.setObservacao(request.getParameter("obs_carta_frete"));
					
					//Carregando os dados do pagamento da contrato de frete:
					int qtdPagtoCarta = (Double.parseDouble(request.getParameter("cartaValorCC")) > 0 ? 3 : 2);
					BeanPagamentoCartaFrete[] arrayPagtoCarta = new BeanPagamentoCartaFrete[qtdPagtoCarta];
					//Dados do adiantamento
					BeanPagamentoCartaFrete pgCarta = new BeanPagamentoCartaFrete();
					pgCarta.setId(0);
					pgCarta.setTipoPagamento("a");
					pgCarta.setValor(Float.parseFloat(request.getParameter("cartaValorAdiantamento")));
					pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataAdiantamento")));
					pgCarta.getFpag().setIdFPag(Integer.parseInt(request.getParameter("cartaFPagAdiantamento")));
					pgCarta.setDocumento(request.getParameter(cfg.isControlarTalonario()?"cartaDocAdiantamento_cb":"cartaDocAdiantamento"));
					pgCarta.getAgente().setIdfornecedor(Integer.parseInt(request.getParameter("idagente")));
					pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(Integer.parseInt(request.getParameter("plano_agente")));
					pgCarta.getAgente().getUnidadeCusto().setId(Integer.parseInt(request.getParameter("und_agente")));
					pgCarta.setPercAbastecimento(0);
					pgCarta.getDespesa().setIdmovimento(0);
					pgCarta.setBaixado(false);
					if (request.getParameter("contaAdt") != null && !request.getParameter("contaAdt").equals("")){
						pgCarta.getConta().setIdConta(Integer.parseInt(request.getParameter("contaAdt")));
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
					pgCarta.setValor(Float.parseFloat(request.getParameter("cartaValorSaldo")));
					pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataSaldo")));
					pgCarta.getFpag().setIdFPag(Integer.parseInt(request.getParameter("cartaFPagSaldo")));
					pgCarta.setDocumento(request.getParameter("cartaDocSaldo"));
					pgCarta.getAgente().setIdfornecedor(Integer.parseInt(request.getParameter("idagentesaldo")));
					pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(Integer.parseInt(request.getParameter("plano_agente_saldo")));
					pgCarta.getAgente().getUnidadeCusto().setId(Integer.parseInt(request.getParameter("und_agente_saldo")));
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

					if (qtdPagtoCarta == 3){
						//Dados do saldo
						pgCarta = new BeanPagamentoCartaFrete();
						pgCarta.setId(0);
						pgCarta.setTipoPagamento("a");
						pgCarta.setValor(Float.parseFloat(request.getParameter("cartaValorCC")));
						pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataCC")));
						pgCarta.getFpag().setIdFPag(Integer.parseInt(request.getParameter("cartaFPagCC")));
						pgCarta.setDocumento("");
						pgCarta.getAgente().setIdfornecedor(0);
						pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(0);
						pgCarta.getAgente().getUnidadeCusto().setId(0);
						pgCarta.setPercAbastecimento(0);
						pgCarta.getDespesa().setIdmovimento(0);
						pgCarta.setBaixado(false);
						if (request.getParameter("contaCC") != null && !request.getParameter("contaCC").equals("")){
							pgCarta.getConta().setIdConta(Integer.parseInt(request.getParameter("contaCC")));
						}    
						pgCarta.setSaldoAutorizado(false);
						pgCarta.setTipoFavorecido("m");
						pgCarta.setContaBancaria("");
						pgCarta.setAgenciaBancaria("");
						pgCarta.setFavorecido("");
						pgCarta.getBanco().setIdBanco(1);
	
						arrayPagtoCarta[2] = pgCarta;
					}	
	    	  
					cFrete.setPagamento(arrayPagtoCarta);

					int countDespesaCarta = Integer.parseInt(request.getParameter("countDespesaCarta"));
					BeanDespesa[] dpArray = new BeanDespesa[countDespesaCarta];
					for (int kk = 0; kk <= countDespesaCarta; ++kk){
						if (request.getParameter("vlDespCarta_"+kk) != null){
							BeanDespesa dp = new BeanDespesa(); 
							dp.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
							dp.setAVista(request.getParameter("DespPago_"+kk) != null);
							dp.setSerie("");
							dp.setNfiscal("");
							dp.setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao")));
							dp.setDtEntrada(Apoio.paraDate(request.getParameter("dtemissao")));
							dp.setCompetencia(request.getParameter("dtemissao").substring(3,10));
							dp.getFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idFornDespCarta_"+kk)));
							dp.getHistorico().setIdHistorico(0);
							dp.setDescHistorico("Pagamento de " + request.getParameter("planoDespCarta_"+kk));
							dp.setValor(Float.parseFloat(request.getParameter("vlDespCarta_"+kk)));

							//atribuindo as parcelas
							BeanDuplDespesa[] du = new BeanDuplDespesa[1];
							du[0] = new BeanDuplDespesa();
							du[0].setDtvenc(Apoio.paraDate(request.getParameter("vlDespVencimento_"+kk)));
							du[0].setVlduplicata(Float.parseFloat(request.getParameter("vlDespCarta_"+kk)));
							if (dp.isAVista()){
								du[0].setBaixado(true);
								du[0].setNumeroBoleto("");
								du[0].setValorPis(0);
								du[0].setValorCofins(0);
								du[0].setValorCssl(0);
								du[0].getFpag().setIdFPag( request.getParameter("chqDespCarta_"+kk) == null ? 1 : 3 );
								du[0].setVlacrescimo(0);
								du[0].setVlpago(Float.parseFloat(request.getParameter("vlDespCarta_"+kk)));
								du[0].setCriaPcs(false);
								du[0].setVldesconto(0);
								du[0].setDtpago(Apoio.paraDate(request.getParameter("dtemissao")));
								//Movimentacao bancária
								du[0].getMovBanco().getConta().setIdConta(Integer.parseInt(request.getParameter("contaDespCarta_"+kk)));
								du[0].getMovBanco().setValor(Float.parseFloat(request.getParameter("vlDespCarta_"+kk)));
								du[0].getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dtemissao")));
								du[0].getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao")));
								du[0].getMovBanco().setConciliado(false);
								du[0].getMovBanco().setHistorico(dp.getDescHistorico());
								if (cfg.isControlarTalonario() && du[0].getFpag().getIdFPag() == 3){
									du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_cb_"+kk));
								}else{
									du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_"+kk));
								}
								du[0].getMovBanco().setNominal("");
								du[0].getMovBanco().getHistorico_id().setIdHistorico(0);
								du[0].getMovBanco().setCheque(du[0].getFpag().getIdFPag()==3);
							}
							dp.setDuplicatas(du);

							//atribuindo as apropriacoes
							BeanApropDespesa[] ap = new BeanApropDespesa[1];
							ap[0] = new BeanApropDespesa();
							ap[0].getPlanocusto().setIdconta(Integer.parseInt(request.getParameter("idPlanoDespCarta_"+kk)));
							ap[0].getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
							ap[0].getVeiculo().setIdveiculo(0);
							ap[0].getUndCusto().setId(0);
							ap[0].setValor(Float.parseFloat(request.getParameter("vlDespCarta_"+kk)));
							dp.setApropriacoes(ap);
						
							dpArray[kk] = dp;
						}
					}
			
					cFrete.setDespesa(dpArray);
					
				}
				
				boolean isGeraADV = request.getParameter("chk_adv_automatica") != null;
				
				BeanViagem viag = null;
				if (isGeraADV && cfg.isCartaFreteAutomatica()){
					//setando os dados do ADV
					viag = new BeanViagem();
					viag.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
					viag.setNumViagem("");
					viag.setSaidaEm(Apoio.paraDate(request.getParameter("dtemissao")));
					viag.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
					viag.getVeiculo().setIdveiculo(Integer.parseInt(request.getParameter("idveiculo")));
					viag.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("idcarreta")));
					viag.setOrigem(request.getParameter("rem_cidade") + "-" + request.getParameter("rem_uf"));
					viag.setDestino(request.getParameter("cid_destino") + "-" + request.getParameter("uf_destino"));
					viag.setObservacao("");
                                        viag.setValorPrevistoViagem(Apoio.parseDouble(request.getParameter("valorPrevistoViagem")));
					viag.setBaixada(false);
			  
					//Preenchendo o array dos adiantamentos
					int qtdAdiant = Integer.parseInt(request.getParameter("countADV"));
					int xy = 0;
					//Preenchendo o array dos mov_banco
					BeanMovBanco[] arBanco = new BeanMovBanco[(qtdAdiant == 0 ? 2 : qtdAdiant * 2)];

					for (int x = 0; x < qtdAdiant; ++x){
						if(request.getParameter("contaADV_"+x)!=null){
							//Preechendo os dados do débito
							BeanMovBanco mb = new BeanMovBanco();
							mb.setCheque(request.getParameter("chqADV_"+x)!=null? true : false);
							mb.getConta().setIdConta(Integer.parseInt(request.getParameter("contaADV_"+x)));
							mb.setValor(Float.parseFloat(request.getParameter("vlADV_"+x))*-1);
							mb.setDtEntrada(Apoio.paraDate(request.getParameter("dtemissao")));
							mb.setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao")));
							mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
							mb.setHistorico("ADIANT. VIAGEM MOT: "+ request.getParameter("motor_nome"));
							mb.getHistorico_id().setIdHistorico(0);
							if(cfg.isControlarTalonario() && mb.isCheque()){
								mb.setDocum(request.getParameter("docADV_cb_"+x));
							}else{
								mb.setDocum(request.getParameter("docADV_"+x));
							}
							mb.setTipo("t");
							arBanco[xy] = mb;
							xy++;
							//Preechendo os dados do crédito
							mb = new BeanMovBanco();
							mb.setCheque(request.getParameter("chqADV_"+x)!=null? true : false);
							mb.getConta().setIdConta(cfg.getConta_adiantamento_viagem_id().getIdConta());
							mb.setValor(Float.parseFloat(request.getParameter("vlADV_"+x)));
							mb.setDtEntrada(Apoio.paraDate(request.getParameter("dtemissao")));
							mb.setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao")));
							mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
							mb.setHistorico(request.getParameter("histAdiant"+x));
							mb.setHistorico("ADIANT. VIAGEM MOT: "+ request.getParameter("motor_nome"));
							mb.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
							if(cfg.isControlarTalonario() && mb.isCheque()){
								mb.setDocum(request.getParameter("docADV_cb_"+x));
							}else{
								mb.setDocum(request.getParameter("docADV_"+x));
							}
							mb.setTipo("t");
							arBanco[xy] = mb;
							xy++;
						}   
					}
					viag.setMovBanco(arBanco);
			  
					int qtdDespADV = Integer.parseInt(request.getParameter("countDespesaADV"));
					BeanDespesa[] dp = new BeanDespesa[qtdDespADV];
					for (int x = 0; x < qtdDespADV; ++x){
						if (request.getParameter("vlDespADV_"+x) != null){
							dp[x] = new BeanDespesa();
							dp[x].getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
							dp[x].setAVista(false);
							dp[x].setSerie("");
							dp[x].setNfiscal("");
							dp[x].setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao")));
							dp[x].setDtEntrada(Apoio.paraDate(request.getParameter("dtemissao")));
							dp[x].setCompetencia(request.getParameter("dtemissao").substring(3,10));
							dp[x].getFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idFornDespADV_"+x)));
							dp[x].getHistorico().setIdHistorico(0);
							dp[x].setDescHistorico("REF.: " + request.getParameter("planoDespADV_"+x));
							dp[x].setValor(Float.parseFloat(request.getParameter("vlDespADV_"+x)));
							//atribuindo as parcelas
							BeanDuplDespesa[] du = new BeanDuplDespesa[1];
							du[0] = new BeanDuplDespesa();
							du[0].setDtvenc(Apoio.paraDate(request.getParameter("dtemissao")));
							du[0].setVlduplicata(Float.parseFloat(request.getParameter("vlDespADV_"+x)));
							//Caso o lançamento seja a vista
							dp[x].setDuplicatas(du);
							//atribuindo as apropriacoes
							BeanApropDespesa[] ap = new BeanApropDespesa[1];
							if (request.getParameter("idPlanoDespADV_"+x) != null){
								ap[0] = new BeanApropDespesa();
								ap[0].getPlanocusto().setIdconta(Integer.parseInt(request.getParameter("idPlanoDespADV_"+x)));
								ap[0].getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
								ap[0].getVeiculo().setIdveiculo(Integer.parseInt(request.getParameter("idveiculo")));
								ap[0].getUndCusto().setId(0);
								ap[0].setValor(Float.parseFloat(request.getParameter("vlDespADV_"+x)));
							}
							dp[x].setApropriacoes(ap);
						}
					}
					viag.setDespesa(dp);
			  
					cadCt.setViagem(viag);
				}
						
				
				
				boolean salvou = false;
                salvou = cadCt.IncluiVarios(man, cFrete, isGeraCarta && cfg.isCartaFreteAutomatica(), isGeraADV && cfg.isCartaFreteAutomatica());

				

                String scr = "";
                    if (!salvou && !cadCt.getErros().equals("Um resultado foi retornado quando nenhum era esperado.")) {
                        
                        if(cadCt.getErros().indexOf("sale_services_tax_id_fkey") > -1){
                            scr = "<script>";
                            scr += "alert('" + "ATENÇÃO: Para gerar uma montagem com a opção de Coleta/OS, precisa primeiro habilitar "
                                    + "em configurações a opção de Serviço padrão p/ Lançamentos de Coleta/OS na Montagem de Carga. " + "');";
                            scr += " window.opener.document.getElementById('baixar').disabled = false; " +//Deixa o botão Salvar HABILITADO
                                    " window.opener.document.getElementById('baixar').value = 'Salvar'; "; //Deixa o nome Salvar no botão
                                if(Apoio.getUsuario(request).getAcesso("alteratipofretecte") < 4){
                                    scr += " window.opener.document.getElementById('tipotaxa').disabled = true; " ;//Deixa o Select Desabilitado SE não tiver permissão de alterar
                                }
                            scr += "window.close();" +
                            "</script>";

                        }else{
                            scr = "<script>";
                            scr += "alert('" + cadCt.getErros() + "');";
                            scr += " window.opener.document.getElementById('baixar').disabled = false; " +//Deixa o botão Salvar HABILITADO
                                    " window.opener.document.getElementById('baixar').value = 'Salvar'; "; //Deixa o nome Salvar no botão
                                if(Apoio.getUsuario(request).getAcesso("alteratipofretecte") < 4){
                                    scr += " window.opener.document.getElementById('tipotaxa').disabled = true; " ;//Deixa o Select Desabilitado SE não tiver permissão de alterar
                                }
                            scr += "window.close();" +
                                "</script>";
                        }
                        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                    } else {
                        scr = "<script>" +
                                "window.opener.document.location ='./consultaconhecimento?acao=iniciar';" +
                                "window.close();" +
                                "</script>";
                    }

                    response.getWriter().append(scr);
                    response.getWriter().close();
            } else if (acao.equals("obter_cubagens")) {
                //String resultado = "";
                BeanConsultaColeta con_col1 = new BeanConsultaColeta();
                
                con_col1.setConexao(Apoio.getConnectionFromUser(request));
                Collection lista = con_col1.consultarCubagensNota(request);
                if (lista != null) {
                    XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
                    xstream.setMode(XStream.NO_REFERENCES);
                    xstream.alias("cubagem", Cubagem.class);
                    String json = xstream.toXML(lista);
                    response.getWriter().append(json);
                } else {
                    response.getWriter().append("load=0");
                }
                response.getWriter().close();        
            }

%>
        <script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
        <script language="javascript" src="script/tabelaFrete.js"></script>
	<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="javascript" src="script/fabtabulous.js" type="text/javascript"></script>
        <script language="javascript" src="script/builder.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/notaFiscal-util.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
		<script language="JavaScript" src="script/impostos.js" type="text/javascript"></script>
		<script language="JavaScript" src="script/aliquotaIcmsCtrc.js" type="text/javascript"></script>
		
<script language="JavaScript" type="text/javascript">
    jQuery.noConflict();
    
    function localizaCubagens(idNotaFiscal,prefix){
        
    
    function e(transport){
        var textoresposta = transport.responseText;
        
        
        if (textoresposta == "load=0") {
            return alert("Erro ao carregar as notas do conhecimento ");
        }else{
            var lista = jQuery.parseJSON(textoresposta);
            
            var cubagens = lista.list[0].cubagem;
            
            if (cubagens != undefined){
        
                var cubagem;
                var length = (cubagens.length == undefined ? 0 : cubagens.length);
        
                //var prefix = getLastIndexFromTableRoot('0','tableNotes');
        
                $('maxItensMetro'+prefix).value = length+"";
                
                for(var j = 0; j < length; j++){
                    
                    if(length > 1){
                        cubagem = cubagens[j];
                    }else{
                        cubagem = cubagens;                    
                    }
                    
                    addUpdateNotaFiscal3('trNote'+prefix,
                                            idNotaFiscal,
                                            cubagem.id,
                                            prefix,
                                            formatoMoeda(cubagem.metroCubico),
                                            formatoMoeda(cubagem.altura),
                                            formatoMoeda(cubagem.largura),
                                            formatoMoeda(cubagem.comprimento),
                                            formatoMoeda(cubagem.volume),
                                            cubagem.etiqueta,
                                            j
                                        );
                }
            }
        }
    }
    
    new Ajax.Request("./montar_carga.jsp?acao=obter_cubagens&idNotaFiscal="+idNotaFiscal,{method:'post', onSuccess: e, onError: e});
}

    
    var tarifas = {};
    var totalGeralMercadoria = 0;
  
    function voltar(){
        document.location.replace("./consultaconhecimento?acao=iniciar");
    }
  
    function applyEventInNote(idCtrc) {


        var lastIndex = (getNextIndexFromTableRoot(idCtrc, 'tableNotes'+idCtrc) - 1);

        //aplicando o evento ao ultimo nf_valor adicionado
        var lastVlNote = $("nf_valor"+lastIndex+"_id"+idCtrc);


        lastVlNote.onchange = function(){ 
            seNaoFloatReset(lastVlNote,"0.00");
            $("totalValor_"+idCtrc).value = sumValorNotes(idCtrc);
            totalGeralNota();
        };

        
        //aplicando o evento ao ultimo nf_peso adicionado
        var lastVlPeso = getObj("nf_peso"+lastIndex+"_id"+idCtrc);
        lastVlPeso.onchange = function(){
            seNaoFloatReset(lastVlPeso,"0.00");
            $("totalPeso_"+idCtrc).value = sumPesoNotes(idCtrc);
            totalGeralNota();
        };
        //aplicando o evento ao ultimo nf_volume adicionado
        var lastVlVolume = $("nf_volume"+lastIndex+"_id"+idCtrc);
        lastVlVolume.onchange = function(){ 
            seNaoFloatReset(lastVlVolume,"0.00");
            $("totalVol_"+idCtrc).value = sumVolumeNotes(idCtrc);
            totalCubadoCtrc(idCtrc);
            totalGeralNota();
        };                      
    }
  
    var windowRemetente = null;
    function localizaremetente(){
        var filialId = $("filialId").value;
        if (getTipoMontagem()=='r' || getTipoMontagem()=='v'){
            windowRemetente = window.open('./localiza?acao=consultar&paramaux3='+$('idcidadedestino').value+'&paramaux4='+filialId+'&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>','Remetente',
            'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
        }else{
            //aqui existia uma validacao : ($('uf_origem').value == ''), que foi removida pois o setor de analise disse que estava incorreta a forma de adicionar o Destinatario. 
                windowDestinatario = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>&paramaux='+$("filialId").value+'&paramaux2='+$("uf_origem").value+'&paramaux3='+$('idcidadeorigem').value+'&paramaux4='+filialId,'Destinatario',
                'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1'); 
        }
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
    
    function localizaRemetenteCodigo(){
        var filialId = $("filialId").value;
        console.log("localizaRemetenteCodigo: "+filialId);
        console.log("codigoRemetente "+$('codigoRemetente').value);
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        if($('codigoRemetente').value!=""){
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);	 
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if(resp == ''){
                alert('Cliente não encontrado');
                $('idremetente').value = '0';
                $('rem_codigo').value = '';
                $('rem_rzs').value = '';
                $('rem_obs').value = '';
                $('rem_cidade').value = '';
                $('rem_uf').value = '';
                $('rem_cnpj').value = '';
                $('rem_pgt').value = '0';
                $('rem_tipotaxa').value = '-1';
                $('idvenremetente').value = '0';
                $('venremetente').value = '';
                $('idcidadeorigem').value = '0';
                $('vlvenremetente').value = '0';
                $('remTipoFpag').value = 'v';
                $('rem_unificada_modal_vendedor').value = "";
                $('rem_comissao_rodoviario_fracionado_vendedor').value = "";
                $('rem_comissao_rodoviario_lotacao_vendedor').value = "";
                return false;
            }else{
                var obs = resp.split('!=!')[13];
                
                obs = replaceAll(obs,/<br>/gi,'<BR>');
                obs = replaceAll(obs,'<br>','<BR>');
                obs = replaceAll(obs,'<br/>','<BR>');
                obs = replaceAll(obs,'\r\n', '<BR>');
                $('idremetente').value = resp.split('!=!')[0];
                $('codigoRemetente').value = resp.split('!=!')[0];
                $('rem_rzs').value = resp.split('!=!')[1];
                $('rem_cidade').value = resp.split('!=!')[2];
                $('rem_uf').value = resp.split('!=!')[3];
                $('rem_cnpj').value = resp.split('!=!')[4];
                $('rem_pgt').value = resp.split('!=!')[5];
                $('rem_tipotaxa').value = resp.split('!=!')[6];
                $('idvenremetente').value = resp.split('!=!')[7];
                $('venremetente').value = resp.split('!=!')[8];
                $('idcidadeorigem').value = resp.split('!=!')[9];
                $('vlvenremetente').value = resp.split('!=!')[10];
                $('remTipoFpag').value = resp.split('!=!')[11];
                $('rem_st_mg').value = resp.split('!=!')[14];
                $('rem_obs').value = obs;
                $('rem_unificada_modal_vendedor').value = resp.split('!=!')[16];
                $('rem_comissao_rodoviario_fracionado_vendedor').value = resp.split('!=!')[17];
                $('rem_comissao_rodoviario_lotacao_vendedor').value = resp.split('!=!')[18];
                $('tipo_documento_padrao').value = resp.split('!=!')[19];      
                $("is_utilizar_tipo_frete_tabela").value = resp.split('!=!')[19];
                $("st_icms").value = resp.split('!=!')[20];
                $("tipo_arredondamento_peso_rem").value = resp.split('!=!')[21];
                $("rem_tipo_tributacao").value = resp.split('!=!')[22];
                aoClicarNoLocaliza('Remetente');
            }
        }//funcao e()

        espereEnviar("",true);
        
            tryRequestToServer(function(){new Ajax.Request("./montar_carga.jsp?acao=localizaClienteCodigo&idcliente="+$('codigoRemetente').value+"&idfilial=0&destUF="+$('dest_uf').value+"&idcidadedestino="+$('idcidadedestino').value+'&filialId='+filialId,{method:'post', onSuccess: e, onError: e});});
        }
    }
  
    var windowDestinatario = null;
    function localizadestinatario(){
        var filialId = $("filialId").value;
        if (getTipoMontagem()=='r' || getTipoMontagem()=='v'){
            if ($('uf_origem').value == ''){
                alert('Informe o remetente ou cidade de origem corretamente.');
                return null;
            }else{
                windowDestinatario = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>&paramaux='+$("filialId").value+'&paramaux2='+$("uf_origem").value+'&paramaux3='+$('idcidadeorigem').value+'&paramaux4='+filialId,'Destinatario',
                'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
            }
        }else{// +'&paramaux4=and csif.filial_id='+filialId+' or csif.filial_id is null'
            windowRemetente = window.open('./localiza?acao=consultar&paramaux3='+$('idcidadedestino').value+'&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>'+'&paramaux4='+filialId,'Remetente',
            'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
        }
    }

    function getValorComissaoVendedor(tipo, modal, isFracionado, vlUnificado, vlAereo, vlRodFracionado, vlRodLotacao){
        var retorno  = 0;

        if (tipo == "1") {
            retorno = vlUnificado;
        } else {
            switch (modal){
                case "r":
                    retorno = (isFracionado ? vlRodFracionado : vlRodLotacao);
                    break;
                case "a":
                    retorno = vlAereo;
                    break;
                case "q":
                    retorno = vlUnificado;
                    break;
            }
        }
        return retorno;
    }

    function addNota(countDest, tablenotes){
        if ($('idcoleta').value=='0'){
            addNewNoteMotagem(countDest, tablenotes, 'false','<%=cfg.isBaixaEntregaNota()%>',$("tipoPadraoDocumento"));
        }else{
            windowDestinatario = window.open('./localiza?acao=consultar&fecharJanela=false&idlista=<%=BeanLocaliza.NOTA_FISCAL%>&paramaux='+$("idcoleta").value+'&paramaux2='+concatIdNota(),'Nota_Fiscal_'+countDest,
            'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
        }
    }
    
    function alterarTipoPagamento(tipo){
        try {
            var qtdCtrc = countDest;
            var obsDestObj = null;
            var obsRemObj = $("rem_obs");
            var obsConsig = "";
            var stIcmsConsignaratio = "";
            for (var i = 0; i <= qtdCtrc; i++) {
                obsDestObj = $("dest_obs_"+i);
                if (obsDestObj != null && obsDestObj != undefined) {
                    if (tipo == "cif") {
                        obsConsig = obsRemObj.value;
                        if (getTipoMontagem()=='r' || getTipoMontagem()=='v') {
                            stIcmsConsignaratio = $("stIcmsRem").value;
                        }else{
                            stIcmsConsignaratio = $("stIcmsDest_"+i).value;
                        }
                    } else {
                        obsConsig = obsDestObj.value;
                        if (getTipoMontagem()=='r' || getTipoMontagem()=='v') {
                            stIcmsConsignaratio = $("stIcmsDest_"+i).value;
                        }else{
                            stIcmsConsignaratio = $("stIcmsRem").value;
                        }
                    }
                    if (parseInt(stIcmsConsignaratio, 10) == 0) {
                        $("stIcms_"+i).value = $("stIcmsConfig_"+i).value;
                    } else {
                        $("stIcms_"+i).value = stIcmsConsignaratio;
                    }
                    if (obsConsig == "") {
                        getDadosIcms(i);
                    }else{
                        obsConsig = replaceAll(obsConsig,/<br>/gi,'<BR>');
                        obsConsig = replaceAll(obsConsig,'<br>','<BR>');
                        obsConsig = replaceAll(obsConsig,'<br/>','<BR>');
                        obsConsig = replaceAll(obsConsig,'\r\n', '<BR>');
                        
                        $("obsLinha1_"+i).value = (obsConsig.split("<BR>").size() < 1) ? "" : obsConsig.split("<BR>")[0];
                        $("obsLinha2_"+i).value = (obsConsig.split("<BR>").size() < 2) ? "" : obsConsig.split("<BR>")[1];
                        $("obsLinha3_"+i).value = (obsConsig.split("<BR>").size() < 3) ? "" : obsConsig.split("<BR>")[2];
                        $("obsLinha4_"+i).value = (obsConsig.split("<BR>").size() < 4) ? "" : obsConsig.split("<BR>")[3];
                        $("obsLinha5_"+i).value = (obsConsig.split("<BR>").size() < 5) ? "" : obsConsig.split("<BR>")[4];
                    }
                }
            }
        } catch (e) {

        }

    }

	function removeDestinatario(idxDest){
            console.log("removeDestinatario countDest: "+countDest);
		if (confirm("Deseja mesmo excluir este remetente e/ou destinatário da lista?")){
			Element.remove('trDest_'+ idxDest);
			Element.remove('trDestRem_'+ idxDest);
			Element.remove('trNFDest_'+ idxDest);
			Element.remove('trVLDest_'+ idxDest);
                        
                        Element.remove('trCab_'+idxDest);
                        
			Element.remove('trCubDest_'+ idxDest);
			Element.remove('trDet_' + idxDest);
			Element.remove('trClienteRed_' + idxDest);
			Element.remove('trObs_' + idxDest);
			Element.remove('trAprop_' + idxDest);
			totalGeralNota();
			alteraTipoTaxa();
                        $("maxCte").value = ($("maxCte").value)-1;
                        travaFilial();
			//Diminiundo a qtd de entregas
			var qtdEntregas = parseInt($('total_entregas').value);
			qtdEntregas = qtdEntregas - 1;
			$('total_entregas').value = qtdEntregas;
		}
	}
	
    var countDest = 0;
    var countNotas = 0; 
    var listaStICMS = new Array();
    var indice = 0;
    <%for(SituacaoTributavel st: listaStIcms){%>
        listaStICMS[indice++] = new Option('<%=st.getId()%>', '<%=st.getCodigo()+"-"+st.getDescricao()%>');
    <%}%>
    //dom de Serviço Preventivo
    function addDestinatario(idDest, nome, cidade, uf, cnpj, aliquota, valor_tarifa, valor_outros, idCfop, obs, tipoCfopDest, diasPagtoDest, cidadeIdDest, ieDest,
                             temPermissao_alteraprecocte, temPermissao_alterainffiscal, obsDest, stIcmsDest, tipoArredondamento, ieRem, destTipoTrib){
        if (countDest != 0){
            var _trCab = Builder.node("tr", {name: "trCab_" + countDest, id: "trCab_" + countDest, className:"tabela"});
            var _tdCab1 = Builder.node("td");
            var _tdCab2 = Builder.node("td", (getTipoMontagem() == 'd' ? "Remetente" : (getTipoMontagem() == 'r' ? "Destinatário" : "Remetente/Destinatário")));
            var _tdCab3 = Builder.node("td", "Cidade/UF");
            var _tdCab4 = Builder.node("td", "CNPJ / CPF");
            var _tdCab5 = Builder.node("td", "Valor NF");
            var _tdCab6 = Builder.node("td", "Peso");
            var _tdCab7 = Builder.node("td", "Volumes");
            var _tdCab8 = Builder.node("td", "Gerar");
            var _tdCab9 = Builder.node("td");
        
            _trCab.appendChild(_tdCab1);
            _trCab.appendChild(_tdCab2);
            _trCab.appendChild(_tdCab3);
            _trCab.appendChild(_tdCab4);
            _trCab.appendChild(_tdCab5);
            _trCab.appendChild(_tdCab6);
            _trCab.appendChild(_tdCab7);
            _trCab.appendChild(_tdCab8);
            _trCab.appendChild(_tdCab9);

            $('tDestinatario').appendChild(_trCab);

        }
		
		//Acrescentando a qtd de entregas
		var qtdEntregas = parseInt($('total_entregas').value);
		qtdEntregas++;
		$('total_entregas').value = qtdEntregas;
                
        //Incluindo a tr
        var _trRem = Builder.node("tr", {name: "trDestRem_" + countDest, id: "trDestRem_" + countDest, className:"CelulaZebra2"});
        var _tr = Builder.node("tr", {name: "trDest_" + countDest, id: "trDest_" + countDest, className:"CelulaZebra2"});

        //primeiro Campo excluir
        var _td1 = Builder.node("td");
        var _td1Rem = Builder.node("td");
        var _img = Builder.node("img", {src: "img/cancelar.png" ,  onclick:"removeDestinatario("+ countDest + ");"});
        _td1.appendChild(_img);

        //Destinatário
        var _td2Rem = Builder.node("td");
        var _ip2_nomeRem = Builder.node("label", {name: "nomeRem_" + countDest, id: "nomeRem_" + countDest});
        var _ip2_idRem = Builder.node("input", {name: "idRem_" + countDest, id: "idRem_" + countDest, type: "hidden", value: $('idCliente').value});
        var _ip2_pagtoRem = Builder.node("input", {type: "hidden", name: "pagtoRem_" + countDest, id: "pagtoRem_" + countDest, value: $('rem_pgt').value});
        var _ip2_ufRem = Builder.node("input", {name: "ufRem_" + countDest, id: "ufRem_" + countDest, type: "hidden", value: $('ufRemetente').value});
        var _ip2_ieRem = Builder.node("input", {name: "ieRem_" + countDest, id: "ieRem_" + countDest, type: "hidden", value: ieRem});
        _td2Rem.appendChild(_ip2_nomeRem); // Atualiza
        _td2Rem.appendChild(_ip2_idRem); // Atualiza
        _td2Rem.appendChild(_ip2_pagtoRem); // Atualiza
        _td2Rem.appendChild(_ip2_ufRem); // Atualiza
        _td2Rem.appendChild(_ip2_ieRem); // Atualiza

        var _td2 = Builder.node("td");
        var _ip2_id = Builder.node("input", {name: "idDest_" + countDest, id: "idDest_" + countDest, type: "hidden", value: idDest});
        var _ipObsDest = Builder.node("input", {name: "dest_obs_" + countDest, id: "dest_obs_" + countDest, type: "hidden", value: (obsDest == undefined || obsDest == null ? "" : obsDest)});//caso a obsDest viesse undefined dava erro e nao era inserido.
        var _ip2_pagtoDest = Builder.node("input", {type: "hidden", name: "pagtoDest_" + countDest, id: "pagtoDest_" + countDest, value: diasPagtoDest});
        var _ip2_cfop = Builder.node("input", {name: "idCfop_" + countDest, id: "idCfop_" + countDest, type: "hidden", value: idCfop});
        var _ip2_tipoCfop = Builder.node("input", {name: "tipoCfopDest_" + countDest, id: "tipoCfopDest_" + countDest, type: "hidden", value: tipoCfopDest});
        var _ip2_cnpjCfop = Builder.node("input", {name: "cnpjCfopDest_" + countDest, id: "cnpjCfopDest_" + countDest, type: "hidden", value: cnpj});
        var _ip2_ufCfopDest = Builder.node("input", {name: "ufCfopDest_" + countDest, id: "ufCfopDest_" + countDest, type: "hidden", value: uf});
        var _ip2_idCidadeDest = Builder.node("input", {name: "idCidadeDest_" + countDest, id: "idCidadeDest_" + countDest, type: "hidden", value: cidadeIdDest});
        var _ip2_stIcmsConfig = Builder.node("input", {name: "stIcmsConfig_" + countDest, id: "stIcmsConfig_" + countDest, type: "hidden", value: ""});
        var _ip2_ieDest = Builder.node("input", {name: "ieDest_" + countDest, id: "ieDest_" + countDest, type: "hidden", value: ieDest});
        var _ip2_nomeDest = Builder.node("label", {name: "nomeDest_" + countDest, id: "nomeDest_" + countDest});
        var _ip2_stIcms = Builder.node("input", {name: "stIcmsDest_" + countDest, id: "stIcmsDest_" + countDest, type: "hidden", value: stIcmsDest});
        var _ip2_tipoArredondamento = Builder.node("input", {name: "tipoArredondamento_" + countDest, id: "tipoArredondamento_" + countDest, type: "hidden", value: tipoArredondamento == undefined || tipoArredondamento == null || tipoArredondamento == '' ? "n" : tipoArredondamento});
        _td2.appendChild(_ip2_id); // Atualiza
        _td2.appendChild(_ipObsDest); // Atualiza
        _td2.appendChild(_ip2_pagtoDest); // Atualiza
        _td2.appendChild(_ip2_cfop); // Atualiza
        _td2.appendChild(_ip2_tipoCfop); // Atualiza
        _td2.appendChild(_ip2_cnpjCfop); // Atualiza
        _td2.appendChild(_ip2_ufCfopDest); // Atualiza
        _td2.appendChild(_ip2_idCidadeDest); // Atualiza
        _td2.appendChild(_ip2_stIcmsConfig); // Atualiza
        _td2.appendChild(_ip2_ieDest); // Atualiza
        _td2.appendChild(_ip2_nomeDest); // Atualiza
        _td2.appendChild(_ip2_stIcms); // Atualiza
        _td2.appendChild(_ip2_tipoArredondamento); // Atualiza

        var _td3 = Builder.node("td");
        var _td3Rem = Builder.node("td");
        var _ip3_cidadeRem = Builder.node("label", {name: "cidadeRem_" + countDest, id: "cidadeRem_" + countDest});
        var _ip3_cidadeDest = Builder.node("label", {name: "cidadeDest_" + countDest, id: "cidadeDest_" + countDest});
        _td3Rem.appendChild(_ip3_cidadeRem); // Atualiza
        _td3.appendChild(_ip3_cidadeDest); // Atualiza

        var _td4 = Builder.node("td");
        var _td4Rem = Builder.node("td");
        var _ip4_cnpjRem = Builder.node("label", {name: "cnpjRem_" + countDest, id: "cnpjRem_" + countDest});
        var _ip4_cnpjDest = Builder.node("label", {name: "cnpjDest_" + countDest, id: "cnpjDest_" + countDest});
        _td4Rem.appendChild(_ip4_cnpjRem); // Atualiza
        _td4.appendChild(_ip4_cnpjDest); // Atualiza
        
        var _td5 = Builder.node("td");
        var _td5Rem = Builder.node("td");
        var _ipTotalVL = Builder.node("input", {name: "totalValor_" + countDest, size:"8", className: "inputReadOnly", readOnly:true, id: "totalValor_" + countDest, type: "text", value: "0.00"});
        var _bt5Rem = Builder.node("input", {name: "btRemetente_" + countDest, id: "btRemetente_" + countDest, type: "button", value: "...", className: "botoes", onClick: "javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'clienteremetente_"+countDest+"');"});
        _td5.appendChild(_ipTotalVL); // Atualiza
        _td5Rem.appendChild(_bt5Rem); // Atualiza

        var _td6 = Builder.node("td");
        var _td6Rem = Builder.node("td");
        var _ipTotalPeso = Builder.node("input", {name: "totalPeso_" + countDest, size:"8", className: "inputReadOnly", readOnly:true, id: "totalPeso_" + countDest, type: "text", value: "0.00"});
        _td6.appendChild(_ipTotalPeso); // Atualiza

        var _td7 = Builder.node("td");
        var _td7Rem = Builder.node("td");
        var _ipTotalVol = Builder.node("input", {name: "totalVol_" + countDest, size:"8", className: "inputReadOnly", readOnly:true, id: "totalVol_" + countDest, type: "text", value: "0.00"});
        _td7.appendChild(_ipTotalVol); // Atualiza

        var _td8 = Builder.node("td");
        var _td8Rem = Builder.node("td");
        var _selGerar = Builder.node("select", {name: "gerar_" + countDest, readOnly:true, id: "gerar_" + countDest, className:"inputReadOnly" });
        var _opCtrc = Builder.node("option", {value: 'ct'},'CTRC');
        var _opColeta = Builder.node("option", {value: 'os'},'Coleta/OS');

        _selGerar.appendChild(_opCtrc); // Atualizadest_obs_
        _selGerar.appendChild(_opColeta); // Atualiza
        _td8.appendChild(_selGerar); // Atualiza

        var _td9 = Builder.node("td");
        var _td9Rem = Builder.node("td");
        var _lb9 = Builder.node("div", {name: "detalhes_" + countDest, id: "detalhes_" + countDest, className: "linkEditar", align: "center", onClick: "mostrarDetalhes("+countDest+");"},"mais...");
                  //resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale("+ct.getString("sale_id")+",0);});'>";

        _td9.appendChild(_lb9); // Atualiza

        _trRem.appendChild(_td1Rem);
        _trRem.appendChild(_td2Rem);
        _trRem.appendChild(_td3Rem);
        _trRem.appendChild(_td4Rem);
        _trRem.appendChild(_td5Rem);
        _trRem.appendChild(_td6Rem);
        _trRem.appendChild(_td7Rem);
        _trRem.appendChild(_td8Rem);
        _trRem.appendChild(_td9Rem);

        _tr.appendChild(_td1);
        _tr.appendChild(_td2);
        _tr.appendChild(_td3);
        _tr.appendChild(_td4);
        _tr.appendChild(_td5);
        _tr.appendChild(_td6);
        _tr.appendChild(_td7);
        _tr.appendChild(_td8);
        _tr.appendChild(_td9);

        $('tDestinatario').appendChild(_trRem);
        $('tDestinatario').appendChild(_tr);

        //Atribuindo valores as Labels
        if (getTipoMontagem()=='v'){
            $('nomeRem_'+countDest).innerHTML = 'REM:'+$('remetenteNome').value + '<br>'; // Buscava um campo chamado 'remetente' porém o mesmo não existe
            $('nomeDest_'+countDest).innerHTML = 'DES:'+nome;
            $('cidadeRem_'+countDest).innerHTML = $('cidadeRemetente').value + " - " + $('ufRemetente').value + '<br>';
            $('cidadeDest_'+countDest).innerHTML = cidade + " - " + uf;
            $('cnpjRem_'+countDest).innerHTML = $('cnpjRemetente').value + '<br>';
            $('cnpjDest_'+countDest).innerHTML = cnpj;
        }else{
            $('trDestRem_' + countDest).style.display = "none";
            $('nomeDest_'+countDest).innerHTML = nome;
            $('cidadeDest_'+countDest).innerHTML = cidade + " - " + uf;
            $('cnpjDest_'+countDest).innerHTML = cnpj;
        }
        $('totalValor_'+ countDest).style.fontSize = "8pt";
        $('totalPeso_'+ countDest).style.fontSize = "8pt";
        $('totalVol_'+ countDest).style.fontSize = "8pt";

        //Verificando se vai gerar um CTRC ou uma coleta
        if ($('cidade_destino_id').value == $('idcidadeorigem').value){
            $('gerar_'+countDest).value = 'os'; 
        }else{
            $('gerar_'+countDest).value = 'ct'; 
        }

        //Acrescentando a TR da cubagem
        var _trCub = Builder.node("tr",{name: "trCubDest_" + countDest, id: "trCubDest_" + countDest});
        var _tdCub = Builder.node("td",{colSpan: "9"});

        var _tableCub = Builder.node("table", {name: "tableCubagem" + countDest, id: "tableCubagem" + countDest, width:"100%" });
        var _tbodyCub = Builder.node("tbody");
        var _trCubDesc = Builder.node("tr");

        var _tdCub1 = Builder.node("td", {className:"TextoCampos", width:"15%"});
        var _lbCub1 = Builder.node("label", {name: "tituloCub_" + countDest, id: "tituloCub_" + countDest},"Dados da cubagem");
        _tdCub1.appendChild(_lbCub1);

        var _tdCub2 = Builder.node("td", {className:"TextoCampos", width:"5%"});
        var _lbCub2 = Builder.node("label","Altura:");
        _tdCub2.appendChild(_lbCub2);

        var _tdCub3 = Builder.node("td", {className:"CelulaZebra2", width:"7%"});
        var _ipCub3 = Builder.node("input", {name: "altura_" + countDest, className:"fieldMin", size:"5", id: "altura_" + countDest, type: "text", value: "0.00", onBlur: "javascript:seNaoFloatReset(this,'0.00');totalCubadoCtrc("+countDest+");"});
        _tdCub3.appendChild(_ipCub3);

        var _tdCub4 = Builder.node("td", {className:"TextoCampos", width:"5%"});
        var _lbCub4 = Builder.node("label","Largura:");
        _tdCub4.appendChild(_lbCub4);

        var _tdCub5 = Builder.node("td", {className:"CelulaZebra2", width:"7%"});
        var _ipCub5 = Builder.node("input", {name: "largura_" + countDest, className:"fieldMin", size:"5", id: "largura_" + countDest, type: "text", value: "0.00", onBlur: "javascript:seNaoFloatReset(this,'0.00');totalCubadoCtrc("+countDest+");"});
        _tdCub5.appendChild(_ipCub5);

        var _tdCub6 = Builder.node("td", {className:"TextoCampos", width:"10%"});
        var _lbCub6 = Builder.node("label","Comprimento:");
        _tdCub6.appendChild(_lbCub6);

        var _tdCub7 = Builder.node("td", {className:"CelulaZebra2", width:"7%"});
        var _ipCub7 = Builder.node("input", {name: "comprimento_" + countDest, className:"fieldMin", size:"5", id: "comprimento_" + countDest, type: "text", value: "0.00", onBlur: "javascript:seNaoFloatReset(this,'0.00');totalCubadoCtrc("+countDest+");"});
        _tdCub7.appendChild(_ipCub7);

        var _tdCub8 = Builder.node("td", {className:"TextoCampos", width:"5%"});
        var _lbCub8 = Builder.node("label","M³:");
        _tdCub8.appendChild(_lbCub8);

        var _tdCub9 = Builder.node("td", {className:"CelulaZebra2", width:"7%"});
        var _ipCub9 = Builder.node("input", {name: "metro_" + countDest, className:"fieldMin", size:"5", id: "metro_" + countDest, type: "text", value: "0.00", onBlur: "javascript:seNaoFloatReset(this,'0.00');pesoCubadoCtrc("+countDest+");totalGeralNota();"});
        _tdCub9.appendChild(_ipCub9);

        var _tdCub10 = Builder.node("td", {className:"TextoCampos", width:"5%"});
        var _lbCub10 = Builder.node("label","Base:");
        _tdCub10.appendChild(_lbCub10);

        var _tdCub11 = Builder.node("td", {className:"CelulaZebra2", width:"8%"});
        var _ipCub11 = Builder.node("input", {name: "base_" + countDest, className:"fieldMin", size:"5", id: "base_" + countDest, type: "text", value: "0.00", onBlur: "javascript:seNaoFloatReset(this,'0.00');pesoCubadoCtrc("+countDest+");"});
        _tdCub11.appendChild(_ipCub11);

        var _tdCub12 = Builder.node("td", {className:"TextoCampos", width:"10%"});
        var _lbCub12 = Builder.node("label","Peso cubado:");
        _tdCub12.appendChild(_lbCub12);

        var _tdCub13 = Builder.node("td", {className:"CelulaZebra2", width:"9%"});
        var _ipCub13 = Builder.node("input", {name: "pesoCubado_" + countDest, size:"7", id: "pesoCubado_" + countDest, type: "text", value: "0.00", onBlur: "javascript:seNaoFloatReset(this,'0.00');", className: "inputReadOnly", readOnly:true});
        _tdCub13.appendChild(_ipCub13);

        _trCubDesc.appendChild(_tdCub1);
        _trCubDesc.appendChild(_tdCub2);
        _trCubDesc.appendChild(_tdCub3);
        _trCubDesc.appendChild(_tdCub4);
        _trCubDesc.appendChild(_tdCub5);
        _trCubDesc.appendChild(_tdCub6);
        _trCubDesc.appendChild(_tdCub7);
        _trCubDesc.appendChild(_tdCub8);
        _trCubDesc.appendChild(_tdCub9);
        _trCubDesc.appendChild(_tdCub10);
        _trCubDesc.appendChild(_tdCub11);
        _trCubDesc.appendChild(_tdCub12);
        _trCubDesc.appendChild(_tdCub13);

        _tbodyCub.appendChild(_trCubDesc);
        _tableCub.appendChild(_tbodyCub);

        _tdCub.appendChild(_tableCub);
        _trCub.appendChild(_tdCub);

        $('tDestinatario').appendChild(_trCub);

        //Atribuindo propriedades aos objetos
        $('altura_'+ countDest).style.fontSize = "8pt";
        $('largura_'+ countDest).style.fontSize = "8pt";
        $('comprimento_'+ countDest).style.fontSize = "8pt";
        $('base_'+ countDest).style.fontSize = "8pt";
        $('base_'+ countDest).value = (tarifas.base_cubagem == undefined ? "0" : tarifas.base_cubagem);
        $('metro_'+ countDest).style.fontSize = "8pt";
        $('pesoCubado_'+ countDest).style.fontSize = "8pt";

        //Acrescentando agora a tr das notas fiscais
        var _trNF = Builder.node("tr",{name: "trNFDest_" + countDest, id: "trNFDest_" + countDest});
        var _tdNF = Builder.node("td",{colSpan: "9"});
        
        var _table = Builder.node("table", {name: "tableNotes" + countDest, id: "tableNotes" + countDest, width:"100%"});
        var _tbody = Builder.node("tbody");
        var _trNFTitulo = Builder.node("tr", {className:"colorClear"});
        
        var _td1NF = Builder.node("td","");
        var _imgNF = Builder.node("img", {src: "img/add.gif" ,  onclick:"countNotas++;addNota('"+countDest+"', 'tableNotes"+countDest+"');", title: "Adicionar uma nova Nota fiscal", className:"imagemLink"});
        _td1NF.appendChild(_imgNF);

        var _td2NF = Builder.node("td",{colSpan:"2"});
        var _td3NF = Builder.node("td","Número");
        var _td4NF = Builder.node("td","Série");
        var _td5NF = Builder.node("td","Emissão");
        var _td6NF = Builder.node("td","Valor");
        var _td7NF = Builder.node("td","Peso");
        var _td8NF = Builder.node("td","Volume");
        var _td9NF = Builder.node("td","Embalagem");
        var _td10NF = Builder.node("td","Conteúdo");
        var _td11NF = Builder.node("td","Base Icms");
        var _td12NF = Builder.node("td","Vl. Icms");
        var _td13NF = Builder.node("td","Icms ST");
        //var _td14NF = Builder.node("td","Pedido");
        

        _trNFTitulo.appendChild(_td1NF);
        _trNFTitulo.appendChild(_td2NF);
        _trNFTitulo.appendChild(_td3NF);
        _trNFTitulo.appendChild(_td4NF);
        _trNFTitulo.appendChild(_td5NF);
        _trNFTitulo.appendChild(_td6NF);
        _trNFTitulo.appendChild(_td7NF);
        _trNFTitulo.appendChild(_td8NF);
        _trNFTitulo.appendChild(_td9NF);
        _trNFTitulo.appendChild(_td10NF);
        _trNFTitulo.appendChild(_td11NF);
        _trNFTitulo.appendChild(_td12NF);
        _trNFTitulo.appendChild(_td13NF);
        //_trNFTitulo.appendChild(_td14NF);
        
        _tbody.appendChild(_trNFTitulo);
        
        _table.appendChild(_tbody);
        
        _tdNF.appendChild(_table);

        _trNF.appendChild(_tdNF);
        
        $('tDestinatario').appendChild(_trNF);
        
        //acrescentando a tr dos valores
        var _trVL = Builder.node("tr",{name: "trVLDest_" + countDest, id: "trVLDest_" + countDest, width:"100%"});
        var _tdVL = Builder.node("td",{colSpan: "9"});
        var _tableVL = Builder.node("table",{width: "100%"});
        var _tbodyVL = Builder.node("tbody");
        var _trVLTitulo = Builder.node("tr",{className:"celula"});
        
        var _tdTaxa = Builder.node("td",{width: "6%", align:"left"},"Taxa");
        var _tdPedagio = Builder.node("td",{width: "7%", align:"left"},"Pedágio");
        var _tdOutros = Builder.node("td",{width: "7%", align:"left"},"Outros");
        var _tdSecCat = Builder.node("td",{width: "7%", align:"left"},"SEC/CAT");
        var _tdGris = Builder.node("td",{width: "6%", align:"left"},"GRIS");
        var _tdFretePeso = Builder.node("td",{width: "9%", align:"left"},"Frete peso");
        var _tdFreteValor = Builder.node("td",{width: "9%", align:"left"},"Frete valor");
        var _tdTotal = Builder.node("td",{width: "13%", align:"left"},"Total Prestação");
        var _tdIcms = Builder.node("td",{width: "9%", align:"left"},"ICMS");
        var _tdStICMS = Builder.node("td",{width: "9%", align:"left"},"ST ICMS");
        var _tdVazia = Builder.node("td",{width: "14%", align:"left"},"Previsão de Entrega");
        
        _trVLTitulo.appendChild(_tdTaxa);
        _trVLTitulo.appendChild(_tdPedagio);
        _trVLTitulo.appendChild(_tdOutros);
        _trVLTitulo.appendChild(_tdSecCat);
        _trVLTitulo.appendChild(_tdGris);
        _trVLTitulo.appendChild(_tdFretePeso);
        _trVLTitulo.appendChild(_tdFreteValor);
        _trVLTitulo.appendChild(_tdTotal);
        _trVLTitulo.appendChild(_tdIcms);
        _trVLTitulo.appendChild(_tdStICMS);
        _trVLTitulo.appendChild(_tdVazia);
		
		//TR dos valores
        var _trVLValor = Builder.node("tr");
        
		var valorTarifaDom = formatoMoeda(0);
		if (tarifas.taxa_apartir_entrega != undefined){
			if (parseInt($('total_entregas').value) >= parseInt(tarifas.taxa_apartir_entrega)){
				valorTarifaDom = formatoMoeda(valor_tarifa);
			}
		}
		
		var _tdVLTaxa = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLTaxa = Builder.node("input", {name: "vlTaxa_" + countDest, className:"fieldMin", size:"5", id: "vlTaxa_" + countDest, type: "text", value: valorTarifaDom, align:"center", maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLTaxa.appendChild(_ipVLTaxa);

		var _tdVLPedagio = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLPedagio = Builder.node("input", {name: "vlPedagio_" + countDest, className:"fieldMin", size:"7", id: "vlPedagio_" + countDest, type: "text", value:"0.00", align:"center",maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLPedagio.appendChild(_ipVLPedagio);

        var _tdVLOutros = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLOutros = Builder.node("input", {name: "vlOutros_" + countDest, className:"fieldMin", size:"5", id: "vlOutros_" + countDest, type: "text", value: valor_outros,maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLOutros.appendChild(_ipVLOutros);

        var _tdVLSecCat = Builder.node("td",{className:"CelulaZebra2", width: "5%"});
        var _ipVLSecCat = Builder.node("input", {name: "vlSecCat_" + countDest, className:"fieldMin", size:"5", id: "vlSecCat_" + countDest, type: "text", value: "0.00",maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLSecCat.appendChild(_ipVLSecCat);

        var _tdVLGris = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLGris = Builder.node("input", {name: "vlGris_" + countDest, className:"fieldMin", size:"5", id: "vlGris_" + countDest, type: "text", value: "0.00",maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLGris.appendChild(_ipVLGris);

        var _tdVLFretePeso = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLFretePeso = Builder.node("input", {name: "vlFretePeso_" + countDest, className:"fieldMin", size:"9", id: "vlFretePeso_" + countDest, type: "text", value: "0.00",maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLFretePeso.appendChild(_ipVLFretePeso);

        var _tdVLFreteValor = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLFreteValor = Builder.node("input", {name: "vlFreteValor_" + countDest, className:"fieldMin", size:"9", id: "vlFreteValor_" + countDest, type: "text", value: "0.00",maxlenght: "12", onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        _tdVLFreteValor.appendChild(_ipVLFreteValor);

        var _tdVLTotal = Builder.node("td",{className:"CelulaZebra2", width: "6%"});
        var _ipVLTotal = Builder.node("input", {name: "vlTotal_" + countDest, size:"9", className: "inputReadOnly", readOnly:true, id: "vlTotal_" + countDest, type: "text", value: "0.00"});
        _tdVLTotal.appendChild(_ipVLTotal);
        var inpTipoTrib = Builder.node("input", {name: "dest_tipo_tributacao_" + countDest,readOnly:true, id: "dest_tipo_tributacao_" + countDest, type: "hidden", value: destTipoTrib});
        _tdVLTotal.appendChild(inpTipoTrib);

        //esses campos so serao disabled caso o usuario nao tenha permissao.
        if(temPermissao_alteraprecocte == "false"){//alteraprecocte
            _ipVLTaxa.disabled = true;
            _ipVLPedagio.disabled = true;
            _ipVLOutros.disabled = true;
            _ipVLSecCat.disabled = true;
            _ipVLGris.disabled = true;
            _ipVLFretePeso.disabled = true;
            _ipVLFreteValor.disabled = true;
        }

        var _tdVLICMS = Builder.node("td",{className:"CelulaZebra2", width: "11%"});
        var _ipVLAliqICMS = Builder.node("input", {name: "vlAliqIcms_" + countDest, className:"fieldMin", size:"1", id: "vlAliqIcms_" + countDest, type: "text", value: aliquota, onBlur: "javascript:seNaoFloatReset(this,'0.00');calculaTotalCtrc("+countDest+");"});
        var _lbPercIcms = Builder.node("label","%");
        var _ipVLICMS = Builder.node("input", {name: "vlIcms_" + countDest, size:"5", className: "inputReadOnly", readOnly:true, id: "vlIcms_" + countDest, type: "text", maxlenght: "12", value: "0.00"});
        _tdVLICMS.appendChild(_ipVLAliqICMS);
        _tdVLICMS.appendChild(_lbPercIcms);
        _tdVLICMS.appendChild(_ipVLICMS);

        var _tdVlSlICMS = Builder.node("td",{className:"CelulaZebra2"});
        var _ipStICMS = Builder.node("select", {name: "stIcms_" + countDest, className: "inputReadOnly", id: "stIcms_" + countDest});
        _ipStICMS.style.width = "60px";
        povoarSelect(_ipStICMS, listaStICMS);
        _tdVlSlICMS.appendChild(_ipStICMS);
        
        //esses campos so serao disabled caso o usuario nao tenha permissao.
        if (temPermissao_alterainffiscal == "false"){//alterainffiscal
            _ipStICMS.disabled = true;
            _ipVLAliqICMS.disabled = true;
        }
        
        var _tdVLVazia = Builder.node("td",{className:"CelulaZebra2", width: "42%"});
        var _ipDataEntrega = Builder.node("input", {name: "dataEntrega_" + countDest, className:"fieldDate", size:"10", id: "dataEntrega_" + countDest, type: "text", value: "", maxlenght: "12", onChange:"javascript:(alertInvalidDate(this,true));"});
        _tdVLFreteValor.appendChild(_ipVLFreteValor);
        _tdVLVazia.appendChild(_ipDataEntrega);
        
        _trVLValor.appendChild(_tdVLTaxa);
        _trVLValor.appendChild(_tdVLPedagio);
        _trVLValor.appendChild(_tdVLOutros);
        _trVLValor.appendChild(_tdVLSecCat);
        _trVLValor.appendChild(_tdVLGris);
        _trVLValor.appendChild(_tdVLFretePeso);
        _trVLValor.appendChild(_tdVLFreteValor);
        _trVLValor.appendChild(_tdVLTotal);
        _trVLValor.appendChild(_tdVLICMS);
        _trVLValor.appendChild(_tdVlSlICMS);
        _trVLValor.appendChild(_tdVLVazia);
		
        _tbodyVL.appendChild(_trVLTitulo);
        _tbodyVL.appendChild(_trVLValor);

        _tableVL.appendChild(_tbodyVL);

        _tdVL.appendChild(_tableVL);

        _trVL.appendChild(_tdVL);

        $('tDestinatario').appendChild(_trVL);
        
        //Atribuindo propriedades aos objetos
        $('vlTaxa_'+ countDest).style.fontSize = "8pt";
        $('vlOutros_'+ countDest).style.fontSize = "8pt";
        $('vlSecCat_'+ countDest).style.fontSize = "8pt";
        $('vlGris_'+ countDest).style.fontSize = "8pt";
        $('vlFretePeso_'+ countDest).style.fontSize = "8pt";
        $('vlFreteValor_'+ countDest).style.fontSize = "8pt";
        $('vlAliqIcms_'+ countDest).style.fontSize = "8pt";
        $('vlIcms_'+ countDest).style.fontSize = "8pt";
        $('vlTotal_'+ countDest).style.fontSize = "8pt";

        //Acrescetnando a TR dos detalhes do CTRC:
        var _trClienteRed = Builder.node("tr",{name: "trClienteRed_" + countDest, id: "trClienteRed_" + countDest, width:"100%"});
        var _tdClienteRed = Builder.node("td",{colSpan: "9"});
        var _tableClienteRed = Builder.node("table",{width:"100%"});
        var _tbodyClienteRed = Builder.node("tbody");
        var _trClienteRedTitulo = Builder.node("tr");

        var _tdLbClienteRed = Builder.node("td",{className:"TextoCampos", width: "15%"},"Redespacho:");
        var _tdClienteRedespacho = Builder.node("td",{className:"CelulaZebra2", width: "40%"});
        var _ipIdClienteRedespacho = Builder.node("input", {name: "idClienteRedespacho_" + countDest, id: "idClienteRedespacho_" + countDest, type: "hidden", value: "0"});
        var _ipClienteRedespacho = Builder.node("input", {name: "clienteRedespacho_" + countDest, size:"40", className: "inputReadOnly", readOnly:true, id: "clienteRedespacho_" + countDest, type: "text", value: ""});
        var _btClienteRedespacho = Builder.node("input", {name: "btClienteRedespacho_" + countDest, id: "btClienteRedespacho_" + countDest, type: "button", value: "...", className: "botoes", onClick: "javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHO_DE_CONHECIMENTO%>', 'Redespacho_"+countDest+"');"});
        var _imgClienteRedespacho = Builder.node("img", {src: "img/borracha.gif", border: "0", align: "absbottom", className: "imagemLink", title: "Limpar Cliente Redespacho", onClick:"getObj('idClienteRedespacho_"+countDest+"').value = 0;getObj('clienteRedespacho_"+countDest+"').value = '';"});
        _tdClienteRedespacho.appendChild(_ipIdClienteRedespacho);
        _tdClienteRedespacho.appendChild(_ipClienteRedespacho);
        _tdClienteRedespacho.appendChild(_btClienteRedespacho);
        _tdClienteRedespacho.appendChild(_imgClienteRedespacho);

        var _tdLbCtrcRedespacho = Builder.node("td",{className:"TextoCampos", width: "10%"},"N. CTRC:");
        var _tdCtrcRedespacho = Builder.node("td",{className:"CelulaZebra2", width: "10%"});
        var _ipCtrcRedespacho = Builder.node("input", {name: "ctrcRedespacho_" + countDest, className:"fieldMin", size:"6", id: "ctrcRedespacho_" + countDest, type: "text", value: "", maxLenght: "6"});
        _tdCtrcRedespacho.appendChild(_ipCtrcRedespacho);

        var _tdLbValorCtrcRedespacho = Builder.node("td",{className:"TextoCampos", width: "10%"},"Valor CTRC:");
        var _tdValorCtrcRedespacho = Builder.node("td",{className:"CelulaZebra2", width: "15%"});
        var _ipValorCtrcRedespacho = Builder.node("input", {name: "valorCtrcRedespacho_" + countDest, className:"fieldMin", size:"8", id: "valorCtrcRedespacho_" + countDest, type: "text", value: "0.00"});
        _tdValorCtrcRedespacho.appendChild(_ipValorCtrcRedespacho);

        _trClienteRedTitulo.appendChild(_tdLbClienteRed);
        _trClienteRedTitulo.appendChild(_tdClienteRedespacho);
        _trClienteRedTitulo.appendChild(_tdLbCtrcRedespacho);
        _trClienteRedTitulo.appendChild(_tdCtrcRedespacho);
        _trClienteRedTitulo.appendChild(_tdLbValorCtrcRedespacho);
        _trClienteRedTitulo.appendChild(_tdValorCtrcRedespacho);

        _tbodyClienteRed.appendChild(_trClienteRedTitulo);
        _tableClienteRed.appendChild(_tbodyClienteRed);
        _tdClienteRed.appendChild(_tableClienteRed);
        _trClienteRed.appendChild(_tdClienteRed);

        $('tDestinatario').appendChild(_trClienteRed);

        $('clienteRedespacho_'+ countDest).style.fontSize = "8pt";
        $('valorCtrcRedespacho_'+ countDest).style.fontSize = "8pt";
        $('ctrcRedespacho_'+ countDest).style.fontSize = "8pt";
        $('trClienteRed_' + countDest).style.display = "none";

        var _trDet = Builder.node("tr",{name: "trDet_" + countDest, id: "trDet_" + countDest, width:"100%"});
        var _tdDet = Builder.node("td",{colSpan: "9"});
        var _tableDet = Builder.node("table", {width: "100%"});
        var _tbodyDet = Builder.node("tbody");
        var _trDetTitulo = Builder.node("tr");

        var _tdLbRed = Builder.node("td",{className:"TextoCampos", width: "15%"},"Representante:");
        var _tdRedespacho = Builder.node("td",{className:"CelulaZebra2", width: "40%"});
        var _ipIdRedespacho = Builder.node("input", {name: "idRedespacho_" + countDest, id: "idRedespacho_" + countDest, type: "hidden", value: "0"});
        var _ipRedespacho = Builder.node("input", {name: "redespacho_" + countDest, size:"40", className: "inputReadOnly", readOnly:true, id: "redespacho_" + countDest, type: "text", value: ""});
        var _btRedespacho = Builder.node("input", {name: "btRedespacho_" + countDest, id: "btRedespacho_" + countDest, type: "button", value: "...", className: "botoes", onClick: "javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>', 'Redespachante_"+countDest+"');"});
        var _imgRedespacho = Builder.node("img", {src: "img/borracha.gif", border: "0", align: "absbottom", className: "imagemLink", title: "Limpar Remetente", onClick:"getObj('idRedespacho_"+countDest+"').value = 0;getObj('redespacho_"+countDest+"').value = '';"});
        _tdRedespacho.appendChild(_ipIdRedespacho);
        _tdRedespacho.appendChild(_ipRedespacho);
        _tdRedespacho.appendChild(_btRedespacho);
        _tdRedespacho.appendChild(_imgRedespacho);

        var _tdLbTabelaRed = Builder.node("td",{className:"TextoCampos", width: "15%"},"Tabela de preço:");
        var _tdTabelaRed = Builder.node("td",{className:"CelulaZebra2", width: "10%"});
        var _selTabelaRed = Builder.node("select", {name: "tabelaRed_" + countDest, id: "tabelaRed_" + countDest, className:"inputtexto", onBlur: "calculaRedesp("+countDest+");"});
        var _opPercentual = Builder.node("option", {value: '0'},'% sobre frete');
        var _opPeso = Builder.node("option", {value: '1'},'Sobre peso');
        _selTabelaRed.appendChild(_opPercentual);
        _selTabelaRed.appendChild(_opPeso);
        _tdTabelaRed.appendChild(_selTabelaRed);

        var _tdLbValorRed = Builder.node("td",{className:"TextoCampos", width: "10%"},"Valor:");
        var _tdValorRed = Builder.node("td",{className:"CelulaZebra2", width: "20%"});
        var _tdValorRedBlank = Builder.node("td",{className:"CelulaZebra2", width: "10%"},"");
            
        var _ipValorRed = Builder.node("input", {name: "valorRed_" + countDest, size:"8", id: "valorRed_" + countDest, type: "text", className:"inputtexto", value: "0.00"});
        var _ipMinimoRed = Builder.node("input", {name: "valorMinimoRed_" + countDest, className:"fieldMin", size:"8", id: "valorMinimoRed_" + countDest, type: "hidden", value: "0.00"});
        var _ipPesoRed = Builder.node("input", {name: "valorPesoRed_" + countDest, className:"fieldMin", size:"8", id: "valorPesoRed_" + countDest, type: "hidden", value: "0.00"});
        var _ipPercentualRed = Builder.node("input", {name: "valorPercRed_" + countDest, className:"fieldMin", size:"8", id: "valorPercRed_" + countDest, type: "hidden", value: "0.00"});
        _tdValorRed.appendChild(_ipValorRed);       
        _tdValorRed.appendChild(_ipMinimoRed);
        _tdValorRed.appendChild(_ipPesoRed);
        _tdValorRed.appendChild(_ipPercentualRed);

        _trDetTitulo.appendChild(_tdLbRed);
        _trDetTitulo.appendChild(_tdRedespacho);
        _trDetTitulo.appendChild(_tdLbTabelaRed);
        _trDetTitulo.appendChild(_tdTabelaRed);
        _trDetTitulo.appendChild(_tdLbValorRed);
        _trDetTitulo.appendChild(_tdValorRed);
        
        _tbodyDet.appendChild(_trDetTitulo);
        _tableDet.appendChild(_tbodyDet);
        _tdDet.appendChild(_tableDet);
        _trDet.appendChild(_tdDet);

        $('tDestinatario').appendChild(_trDet);

        $('redespacho_'+ countDest).style.fontSize = "8pt";
        $('valorRed_'+ countDest).style.fontSize = "8pt";
        $('trDet_' + countDest).style.display = "none";

        //Acrescetnando a TR das Observaçoes:
        obs = replaceAll(obs,/<br>/gi,'<BR>');
        obs = replaceAll(obs,'<br>','<BR>');
        obs = replaceAll(obs,'<br/>','<BR>');
        obs = replaceAll(obs,'\r\n', '<BR>');

        
        var _trObs = Builder.node("tr",{name: "trObs_" + countDest, id: "trObs_" + countDest, width:"100%"});
        var _tdObs = Builder.node("td",{colSpan: "9"});
        var _tableObs = Builder.node("table");
        var _tbodyObs = Builder.node("tbody");
        var _trObsTitulo = Builder.node("tr");
        var _tdLbObs = Builder.node("td",{className:"TextoCampos", width: "7%"},"Observação:");
        var _tdObs1 = Builder.node("td",{className:"CelulaZebra2", width: "31%"},"1:");
        var _ipObs1 = Builder.node("input", {name: "obsLinha1_" + countDest, size:"47", maxLength: "59", id: "obsLinha1_" + countDest, type: "text", className:"inputtexto", 
                            value: ((obs.split("<BR>").size() < 1)  ? "" : obs.split("<BR>")[0])});
        var _tdObs2 = Builder.node("td",{className:"CelulaZebra2", width: "31%"},"2:");
        var _ipObs2 = Builder.node("input", {name: "obsLinha2_" + countDest, size:"47", maxLength: "59", id: "obsLinha2_" + countDest, type: "text", className:"inputtexto",
                            value: ((obs.split("<BR>").size() < 2) ? "" : obs.split("<BR>")[1])});
        var _tdObs3 = Builder.node("td",{className:"CelulaZebra2", width: "31%"},"3:");
        var _ipObs3 = Builder.node("input", {name: "obsLinha3_" + countDest, size:"47", maxLength: "59", id: "obsLinha3_" + countDest, type: "text", className:"inputtexto",
                                value: ((obs.split("<BR>").size() < 3) ? "" : obs.split("<BR>")[2])});

        _tdObs1.appendChild(_ipObs1);
        _tdObs2.appendChild(_ipObs2);
        _tdObs3.appendChild(_ipObs3);

        _trObsTitulo.appendChild(_tdLbObs);
        _trObsTitulo.appendChild(_tdObs1);
        _trObsTitulo.appendChild(_tdObs2);
        _trObsTitulo.appendChild(_tdObs3);

        var _trObsTitulo2 = Builder.node("tr");

        var _tdLbObs2 = Builder.node("td",{className:"TextoCampos"});
        var _btObs = Builder.node("input", {name: "btObs_" + countDest, id: "btObs_" + countDest, type: "button", value: "...", className: "botoes", onClick: "javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.OBSERVACAO%>', 'Observacao_"+countDest+"');"});
        _tdLbObs2.appendChild(_btObs);

        var _tdObs4 = Builder.node("td",{className:"CelulaZebra2"},"4:");
        var _ipObs4 = Builder.node("input", {name: "obsLinha4_" + countDest, size:"47", maxLength: "59", id: "obsLinha4_" + countDest, type: "text", className:"inputtexto", value: ((obs.split("<BR>").size() < 4) ? "" : obs.split("<BR>")[3])});
        var _tdObs5 = Builder.node("td",{className:"CelulaZebra2"},"5:");
        var _ipObs5 = Builder.node("input", {name: "obsLinha5_" + countDest, size:"47", maxLength: "59", id: "obsLinha5_" + countDest, type: "text", className:"inputtexto", value: ((obs.split("<BR>").size() < 5) ? "" : obs.split("<BR>")[4])});
        var _tdObs6 = Builder.node("td",{className:"CelulaZebra2"});

        _tdObs4.appendChild(_ipObs4);
        _tdObs5.appendChild(_ipObs5);

        _trObsTitulo2.appendChild(_tdLbObs2);
        _trObsTitulo2.appendChild(_tdObs4);
        _trObsTitulo2.appendChild(_tdObs5);
        _trObsTitulo2.appendChild(_tdObs6);

        _tbodyObs.appendChild(_trObsTitulo);
        _tbodyObs.appendChild(_trObsTitulo2);
        _tableObs.appendChild(_tbodyObs);
        _tdObs.appendChild(_tableObs);
        _trObs.appendChild(_tdObs);

        $('tDestinatario').appendChild(_trObs);

        $('obsLinha1_'+ countDest).style.fontSize = "8pt";
        $('obsLinha2_'+ countDest).style.fontSize = "8pt";
        $('obsLinha3_'+ countDest).style.fontSize = "8pt";
        $('obsLinha4_'+ countDest).style.fontSize = "8pt";
        $('obsLinha5_'+ countDest).style.fontSize = "8pt";
        $('trObs_' + countDest).style.display = "none";

        //Acrescetnando a TR da apropriação:
        var _trAprop = Builder.node("tr",{name: "trAprop_" + countDest, id: "trAprop_" + countDest, width:"100%"});
        var _tdAprop = Builder.node("td",{colSpan: "9"});
        var _tableAprop = Builder.node("table", {width: "100%"});
        var _tbodyAprop = Builder.node("tbody");
        var _trApropTitulo = Builder.node("tr");

        var _tdLbAprop = Builder.node("td",{className:"TextoCampos", width: "10%"},"Apropriação:");
        var _tdApropriacao = Builder.node("td",{className:"CelulaZebra2", width: "60%"});
        var _ipIdAprop = Builder.node("input", {name: "idAprop_" + countDest, id: "idAprop_" + countDest, type: "hidden", value: "0"});
        var _ipContaAprop = Builder.node("input", {name: "contaAprop_" + countDest, size:"15", className: "inputReadOnly", readOnly:true, id: "contaAprop_" + countDest, type: "text", value: ""});
        var _ipAprop = Builder.node("input", {name: "aprop_" + countDest, size:"45", className: "inputReadOnly", readOnly:true, id: "aprop_" + countDest, type: "text", value: ""});
        var _btAprop = Builder.node("input", {name: "btAprop_" + countDest, id: "btAprop_" + countDest, type: "button", value: "...", className: "botoes", onClick: "javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CUSTO_RECEITA%>', 'Apropriacao_"+countDest+"');"});
        _tdApropriacao.appendChild(_ipIdAprop);
        _tdApropriacao.appendChild(_ipContaAprop);
        _tdApropriacao.appendChild(_ipAprop);
        _tdApropriacao.appendChild(_btAprop);

        var _tdLbUnd = Builder.node("td",{className:"TextoCampos", width: "15%"},"Und. custo:");
        var _tdUnd = Builder.node("td",{className:"CelulaZebra2", width: "15%"});
        var _tdUndBlank = Builder.node("td",{className:"CelulaZebra2", width: "15%"});
        var lbUndBlank = Builder.node("input",{id:"lbUndBlank_"+countDest, name:"lbUndBlank_"+countDest});
        var _ipIdUnd = Builder.node("input", {name: "idUnd_" + countDest, id: "idUnd_" + countDest, type: "hidden", value: "0"});
        var _ipUnd = Builder.node("input", {name: "und_" + countDest, size:"15", className: "inputReadOnly", readOnly:true, id: "und_" + countDest, type: "text", value: ""});
        var _btUnd = Builder.node("input", {name: "btUnd_" + countDest, id: "btUnd_" + countDest, type: "button", value: "...", className: "botoes", onClick: "javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.UNIDADE_CUSTO%>', 'Unidade_Custo_"+countDest+"');"});
        _tdUnd.appendChild(_ipIdUnd);
        _tdUnd.appendChild(_ipUnd);
        _tdUnd.appendChild(_btUnd);
        
       

        _trApropTitulo.appendChild(_tdLbAprop);
        _trApropTitulo.appendChild(_tdApropriacao);
        _trApropTitulo.appendChild(_tdLbUnd);
        _trApropTitulo.appendChild(_tdUnd);
     

        _tbodyAprop.appendChild(_trApropTitulo);
        _tableAprop.appendChild(_tbodyAprop);
        _tdAprop.appendChild(_tableAprop);
        _trAprop.appendChild(_tdAprop);

        $('tDestinatario').appendChild(_trAprop);

        $('contaAprop_'+ countDest).style.fontSize = "8pt";
        $('aprop_'+ countDest).style.fontSize = "8pt";
        $('und_'+ countDest).style.fontSize = "8pt";
        $('trAprop_' + countDest).style.display = "none";

        calculaTotalCtrc(countDest);
        
	getDadosIcms(countDest);

        applyFormatter(document, $("dataEntrega_"+countDest));	
        
	
        countDest++;
        $("maxCte").value = countDest;
        travaFilial();
        
    }
    
    function travaFilial(){
        if($("maxCte").value!=0){
            $("filialId").disabled = true;
        }else{
            $("filialId").disabled = false;
        }
        
    }
    
    function getObsCliente(){
        return getObsClienteGenerico($('dest_obs'));
    }
    function getObsClienteGenerico(obDest){
        var retorno = "";
        if ($("tipo_frete_cif").checked && $("rem_obs").value != "") {
            retorno = $("rem_obs").value;
        }else if($("tipo_frete_fob").checked && (obDest != null && obDest.value != "")){
            retorno = obDest.value;
        }
        return retorno;
    }
    

    function aoClicarNoLocaliza(idjanela){ 
        if (idjanela == "marca"){
            $('inIdMarcaVeiculo').value = $('idmarca').value;
            $('inMarcaVeiculo').value = $('descricao').value;
        }else if (idjanela == "Cfop_Nota_fiscal"){
            $('inCfopId').value = $('idcfop').value;
            $('inCfop').value = $('cfop').value;
        }else if (idjanela.split("__")[0] == "Cfop_Nota_fiscal_nfe"){
            var idxCfopNfe = idjanela.split("__")[1];
            $('nf_cfop'+idxCfopNfe).value = $('cfop').value;
            $('nf_cfopId'+idxCfopNfe).value = $('idcfop').value;
        }else if(idjanela.split("__")[0] == "Produto_ctrcs_nf"){
            var idxProdNF = idjanela.split("__")[1];            
            $('nf_conteudo'+idxProdNF).value = $('desc_prod').value;
            
            
        }else if (idjanela == "Destinatario"){
            if (getTipoMontagem()=='r' || getTipoMontagem()=='v'){
                    if ($('idcidadedestino').value == '0'){
                            $("idcidadedestino").value = $("cidade_destino_id").value;
                            $("cid_destino").value = $("dest_cidade").value;
                            $("uf_destino").value = $("dest_uf").value;
                            alteraTipoTaxa();
                    }
                    if ($('id_rota_viagem_real').value == '0'){
                            $('id_rota_viagem_real').value = $('id_rota_viagem').value;
                            $('rota_viagem_real').value = $('rota_viagem').value;
                    }

                var obs = "";
                
                if (getObsCliente() != "") {
                    obs = getObsCliente() + '<BR>';
                }else{
                    obs = $('obs_desc').value + '<BR>';
                }
                
                addDestinatario($('iddestinatario').value, $('dest_rzs').value, $('dest_cidade').value, $('dest_uf').value, $('dest_cnpj').value, $('aliquota').value,
                $('valor_taxa_fixa').value, $('valor_outros').value,$('idcfop').value, obs ,$('des_tipo_cfop').value, $('dest_pgt').value, $("cidade_destino_id").value, $('dest_insc_est').value,$("temPermissao_alteraprecocte").value,
                $("temPermissao_alterainffiscal").value, $('dest_obs').value, $("st_icms").value, $("tipo_arredondamento_peso_dest").value,"", $("dest_tipo_tributacao").value);
            }else{
                $("idCliente").value = $("iddestinatario").value;
                $("codigoRemetente").value = $("des_codigo").value;
                $("remetenteNome").value = $("dest_rzs").value;
                $("cidadeRemetente").value = $("dest_cidade").value;
                $("ufRemetente").value = $("dest_uf").value;
                
                $("cnpjRemetente").value = $("dest_cnpj").value;
                $("idcidadedestino").value = $("cidade_destino_id").value;
				$("cid_destino").value = $("dest_cidade").value;
				$("uf_destino").value = $("dest_uf").value;
                $('tipotaxa').value = $('dest_tipotaxa').value;
                $('idvendedor').value = $('idvendestinatario').value;
                $('ven_rzs').value = $('vendestinatario').value;
                $('comissaoVendedor').value = getValorComissaoVendedor($("des_unificada_modal_vendedor").value, "r", 
                                ("<%=Apoio.getUsuario(request).getFilial().getModalCTE()%>" == "f"), $('vlvendestinatario').value, $('vlvendestinatario').value, 
                                $("des_comissao_rodoviario_fracionado_vendedor").value, $("des_comissao_rodoviario_lotacao_vendedor").value);
                        $("stIcmsRem").value = $("st_icms").value;
                $("tipo_arredondamento_peso").value = $("tipo_arredondamento_peso_dest").value;
            }
            if($("tipo_frete_cif").checked){
                alterarTipoPagamento("cif");
            }else if($("tipo_frete_fob").checked){
                alterarTipoPagamento("fob");
            }         
        }else 
        


        if (idjanela == "Remetente"){
            if (getTipoMontagem()=='r' || getTipoMontagem()=='v'){
                $("idCliente").value = $("idremetente").value;
                $("codigoRemetente").value = $("rem_codigo").value;
                $("remetenteNome").value = $("rem_rzs").value;
                $("cidadeRemetente").value = $("rem_cidade").value;
                $("ufRemetente").value = $("rem_uf").value;
                $("cnpjRemetente").value = $("rem_cnpj").value;
                $("idCidadeRemetente").value = $("idcidadeorigem").value;
                $("cid_origem").value = $("rem_cidade").value;
                $("uf_origem").value = $("rem_uf").value;
                $('tipotaxa').value = $('rem_tipotaxa').value;
                $('idvendedor').value = $('idvenremetente').value;
                $('ven_rzs').value = $('venremetente').value;
                $('comissaoVendedor').value = getValorComissaoVendedor($("rem_unificada_modal_vendedor").value, "r", 
                                ("<%=Apoio.getUsuario(request).getFilial().getModalCTE()%>" == "f"), $('vlvenremetente').value, $('vlvenremetente').value, 
                                $("rem_comissao_rodoviario_fracionado_vendedor").value, $("rem_comissao_rodoviario_lotacao_vendedor").value, $("rem_tipo_tributacao").value);
                        $("tipoPadraoDocumento").value = $("tipo_documento_padrao").value;
                $("utilizaTipoFreteTabelaRem").value = $("is_utilizar_tipo_frete_tabela").value;
                $("stIcmsRem").value = $("st_icms").value;
                $("tipo_arredondamento_peso").value = $("tipo_arredondamento_peso_rem").value;
                $('rem_insc_est').value = $('rem_insc_est').value;
            }else{
                    if ($('idCidadeRemetente').value == '0'){
                        $("idCidadeRemetente").value = $("idcidadeorigem").value;
                        $("cid_origem").value = $("rem_cidade").value;
                        $("uf_origem").value = $("rem_uf").value;
                        alteraTipoTaxa();
                    }
                    if ($('id_rota_viagem_real').value == '0'){
                        $('id_rota_viagem_real').value = $('id_rota_viagem').value;
                        $('rota_viagem_real').value = $('rota_viagem').value;
                    }
//                    $("stIcmsRem").value = $("st_icms").value;
                    addDestinatario($('idremetente').value, $('rem_rzs').value, $('rem_cidade').value,
                    $('rem_uf').value, $('rem_cnpj').value, $('aliquota').value,
                    $('valor_taxa_fixa').value, $('valor_outros').value, $('idcfop').value,$('obs_desc').value + '<BR>',$('rem_tipo_cfop').value,$('rem_pgt').value,0,'',$("temPermissao_alteraprecocte").value,
                    $("temPermissao_alterainffiscal").value, $("rem_obs").value, $("st_icms").value,'',$("rem_insc_est").value);
                    
                }
               
                if($("tipo_frete_cif").checked){
                    alterarTipoPagamento("cif");
                }else if($("tipo_frete_fob").checked){
                    alterarTipoPagamento("fob");
                }
                
        }else if (idjanela == "Cidade"){
			$('id_rota_viagem_real').value = $('id_rota_viagem').value;
			$('rota_viagem_real').value = $('rota_viagem').value;
            alteraTipoTaxa();
        }else if (idjanela == "Cidade_Destino"){
			$('id_rota_viagem_real').value = $('id_rota_viagem').value;
			$('rota_viagem_real').value = $('rota_viagem').value;
            alteraTipoTaxa();
        }else if (idjanela.split('_')[0] == 'clienteremetente'){
            var idx = idjanela.split("_")[1];
            $('idRem_'+idx).value = $('idremetente').value;
            $('nomeRem_'+idx).innerHTML = $('rem_rzs').value;
            $('cidadeRem_'+idx).innerHTML = $('rem_cidade').value + ' - ' + $('rem_uf').value;
            $('ufRem_'+idx).value = $('rem_uf').value;
            $('cnpjRem_'+idx).innerHTML = $('rem_cnpj').value;
            $('pagtoRem_'+idx).value = $('rem_pgt').value;
			getDadosIcms(idx);
        }else if (idjanela.split('_')[0] == 'Redespachante'){
            var idx = idjanela.split("_")[1];
            $('redespacho_'+idx).value = $('redspt_rzs').value;
            $('idRedespacho_'+idx).value = $('idredespachante').value;
            $('valorMinimoRed_'+idx).value = $('redspt_vlfreteminimo').value;
            $('valorPesoRed_'+idx).value = $('redspt_vlsobpeso').value;
            $('valorPercRed_'+idx).value = $('redspt_vlsobfrete').value;
            calculaRedesp(idx);
        }else if (idjanela.split('_')[0] == "Observacao"){
            var idx = idjanela.split("_")[1];
            var obs = $('obs_desc').value;

            $('obsLinha1_'+idx).value = (obs.split('<BR>')[0] == undefined ? '' : obs.split('<BR>')[0]);
            $('obsLinha2_'+idx).value = (obs.split('<BR>')[1] == undefined ? '' : obs.split('<BR>')[1]);
            $('obsLinha3_'+idx).value = (obs.split('<BR>')[2] == undefined ? '' : obs.split('<BR>')[2]);
            $('obsLinha4_'+idx).value = (obs.split('<BR>')[3] == undefined ? '' : obs.split('<BR>')[3]);
            $('obsLinha5_'+idx).value = (obs.split('<BR>')[4] == undefined ? '' : obs.split('<BR>')[4]);
        }else if (idjanela.split('_')[0] == "Nota"){
            var idx = idjanela.split("_")[2];
            
            $('emissao_nota').value = $('emissao').value;
            
            var sufix = addNote(idx, 'tableNotes'+idx,$('idnota_fiscal').value,
                    $('numero_nf').value,$('serie_nota').value,$('emissao_nota').value, 
                    $('valor_nota').value,$('vl_base_icms').value,$('vl_icms_nota').value,
                    $('vl_icms_st').value,$('vl_icms_frete').value,$('peso_nota').value,
                    $('volume_nota').value,$('embalagem_nota').value,$('conteudo_nota').value,
                    0,$('pedido_nota').value,false,
                    $('largura_nota').value,$('altura_nota').value,$('comprimento_nota').value, 
                    $('metro_cubico_nota').value,$('marca_veiculo_id').value,$('marca_nf').value,
                    $('modelo_veiculo').value,$('ano_veiculo').value,$('cor_veiculo').value,
                    $('chassi_veiculo').value,'0','false',
                    $('cfop_id').value,$('cfop_nf').value,$('chave_acesso').value,
                    $('is_agendado').value,$('data_agenda').value,$('hora_agenda').value,
                    $('obs_agenda').value,'<%=cfg.isBaixaEntregaNota()%>',
                    $('nf_previsao_entrega').value,$('nf_previsao_entrega_as').value,
                    $('nf_iddestinatario').value,$('nf_destinatario').value,
                    $('is_importada_edi').value,$('max_itens_metro').value);

            $("totalValor_"+idx).value = sumValorNotes(idx);
            $("totalPeso_"+idx).value = sumPesoNotes(idx);
            $("totalVol_"+idx).value = sumVolumeNotes(idx);
            totalGeralNota();
            countNotas++;
            
            localizaCubagens($('idnota_fiscal').value,sufix);
            
        }else if (idjanela.split('_')[0] == "Apropriacao"){
            var idx = idjanela.split("_")[1];
            $('idAprop_'+idx).value = $('idplanocusto').value;
            $('contaAprop_'+idx).value = $('plcusto_conta').value;
            $('aprop_'+idx).value = $('plcusto_descricao').value;
        }else if (idjanela.split('_')[0] == "Unidade"){
            var idx = idjanela.split("_")[2];
            $('idUnd_'+idx).value = $('id_und').value;
            $('und_'+idx).value = $('sigla_und').value;
        }else if (idjanela.split('_')[0] == 'Redespacho'){
            var idx = idjanela.split("_")[1];
            $('idClienteRedespacho_'+idx).value = $('idredespacho').value;
            $('clienteRedespacho_'+idx).value = $('red_rzs').value;
        }else if (idjanela == 'Motorista' || idjanela == 'Veiculo' || idjanela == 'Carreta'){
            if  ($('tipo').value == 'f'){
                $('chk_adv_automatica').checked = true;
                $('chk_carta_automatica').checked = false;
			    if ($('percentual_ctrc_contrato_frete').value > 0){
					$('chk_carta_automatica').checked = true;
				}
				if (countADV == 0){
					incluiADV();
				}
            }else{
                //Só pode marcar esse flag se no cadastro do cliente tirar pra marcar frete automatico. 
                if (<%=cfg.isCartaFreteAutomatica()%>) {
                    $('chk_carta_automatica').checked = true;
                }
                $('chk_adv_automatica').checked = false;
            }
			if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
				$('chk_reter_impostos').checked = true;
			}else{
				$('chk_reter_impostos').checked = false;
			}
			calcularFreteCarreteiroRota();			
			calcularFreteCarreteiro();
		}else if (idjanela.substring(0,25) == 'Fornecedor_Contrato_Frete'){
			var idxForn = idjanela.split('_')[3];
			$('idFornDespCarta_'+idxForn).value = $('idfornecedor').value;
			$('fornDespCarta_'+idxForn).value = $('fornecedor').value;
			$('idPlanoDespCarta_'+idxForn).value = $('idplcustopadrao').value;
			$('planoDespCarta_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
		}else if (idjanela.substring(0,14) == 'Fornecedor_ADV'){
			var idxForn = idjanela.split('_')[2];
			$('idFornDespADV_'+idxForn).value = $('idfornecedor').value;
			$('fornDespADV_'+idxForn).value = $('fornecedor').value;
			$('idPlanoDespADV_'+idxForn).value = $('idplcustopadrao').value;
			$('planoDespADV_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
		}else if (idjanela.substring(0,9) == 'Plano_ADV'){
			var idxPlano = idjanela.split('_')[2];
			$('idPlanoDespADV_'+idxPlano).value = $('idplanocusto_despesa').value;
			$('planoDespADV_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
		}else if (idjanela.substring(0,20) == 'Plano_Contrato_Frete'){
			var idxPlano = idjanela.split('_')[3];
			$('idPlanoDespCarta_'+idxPlano).value = $('idplanocusto_despesa').value;
			$('planoDespCarta_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
		}
    }

    function calculaTotalCtrc(idx){
        //inicio cálculo frete mínimo
        var totalX = parseFloat($('vlTaxa_'+ idx).value) +
            parseFloat($('vlOutros_'+ idx).value) +
            parseFloat($('vlPedagio_'+ idx).value) +
            parseFloat($('vlSecCat_'+ idx).value) +
            parseFloat($('vlGris_'+ idx).value) +
            parseFloat($('vlFretePeso_'+ idx).value) +
            parseFloat($('vlFreteValor_'+ idx).value);

        var zeraTaxa = true;
        if (tarifas.is_desconsidera_taxa_minimo != undefined && (tarifas.is_desconsidera_taxa_minimo == true || tarifas.is_desconsidera_taxa_minimo == 't' || tarifas.is_desconsidera_taxa_minimo == 'true')){
          totalX = parseFloat(totalX) - parseFloat($('vlTaxa_'+ idx).value);
          zeraTaxa = false;
        }
        var zeraPedagio = true;
        if (tarifas.is_desconsidera_pedagio_minimo != undefined && (tarifas.is_desconsidera_pedagio_minimo == true || tarifas.is_desconsidera_pedagio_minimo == 't' || tarifas.is_desconsidera_pedagio_minimo == 'true')){
          totalX = parseFloat(totalX) - parseFloat($('vlPedagio_'+ idx).value);
          zeraPedagio = false;
        }
        var zeraOutros = true;
        if (tarifas.is_desconsidera_outros_minimo != undefined && (tarifas.is_desconsidera_outros_minimo == true || tarifas.is_desconsidera_outros_minimo == 't' || tarifas.is_desconsidera_outros_minimo == 'true')){
          totalX = parseFloat(totalX) - parseFloat($('vlOutros_'+ idx).value);
          zeraOutros = false;
        }
        var zeraSecCat = true;
        if (tarifas.is_desconsidera_seccat_minimo != undefined && (tarifas.is_desconsidera_seccat_minimo == true || tarifas.is_desconsidera_seccat_minimo == 't' || tarifas.is_desconsidera_seccat_minimo == 'true')){
          totalX = parseFloat(totalX) - parseFloat($('vlSecCat_'+ idx).value);
          zeraSecCat = false;
        }
        var zeraGris = true;
        if (tarifas.is_desconsidera_gris_minimo != undefined && (tarifas.is_desconsidera_gris_minimo == true || tarifas.is_desconsidera_gris_minimo == 't' || tarifas.is_desconsidera_gris_minimo == 'true')){
          totalX = parseFloat(totalX) - parseFloat($('vlGris_'+ idx).value);
          zeraGris = false;
        }
        var zeraSeguro = true;
        var seguroX = 0;
        if (tarifas.is_desconsidera_seguro_minimo != undefined && (tarifas.is_desconsidera_seguro_minimo == true || tarifas.is_desconsidera_seguro_minimo == 't' || tarifas.is_desconsidera_seguro_minimo == 'true')){
          seguroX = getFreteValor($('totalValor_'+idx).value,tarifas.percentual_advalorem,
                                                    tarifas.percentual_nf,tarifas.base_nf_percentual,tarifas.valor_percentual_nf,
                                                    $("tipotaxa").value,'p',tarifas.formula_seguro, tarifas.formula_percentual,
                                                    $('totalPeso_'+idx).value, $('totalVol_'+idx).value, '0', $('total_km').value, $('tipoveiculo').value,
													tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('metro_'+idx).value,false,0,1,'r','t',0, true, $("tipo_arredondamento_peso").value);
          totalX = parseFloat(totalX) - parseFloat(seguroX);
          zeraSeguro = false;
        }

        var isIcmsMinimo = true;
        var vlMinimo = (tarifas.valor_frete_minimo == undefined ? 0 : getFreteMinimo(tarifas.valor_frete_minimo, tarifas.formula_minimo, $('tipotaxa').value, $('totalPeso_'+idx).value, $('totalValor_'+idx).value, $('totalVol_'+idx).value, '0', $('total_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,0,false,0,1,'r',true,'t',0, $("tipo_arredondamento_peso").value));
        if (tarifas.valor_frete_minimo != undefined && parseFloat(vlMinimo) > parseFloat(totalX)){
            if (tarifas.is_desconsidera_icms_minimo != undefined && (tarifas.is_desconsidera_icms_minimo == true || tarifas.is_desconsidera_icms_minimo == 't' || tarifas.is_desconsidera_icms_minimo == 'true')){
                isIcmsMinimo = false;
            }
            if (zeraTaxa){
                $('vlTaxa_'+ idx).value = '0.00';
            }
            if (zeraPedagio){
                $('vlPedagio_'+ idx).value = '0.00';
            }
            if (zeraOutros){
                $('vlOutros_'+ idx).value = '0.00';
            }
            if (zeraSecCat){
                $('vlSecCat_'+ idx).value = '0.00';
            }
            if (zeraGris){
                $('vlGris_'+ idx).value = 0;
            }
            if (zeraSeguro){
              $('vlFreteValor_'+ idx).value = formatoMoeda(parseFloat(vlMinimo));
            }else{
              $('vlFreteValor_'+ idx).value = formatoMoeda(parseFloat(vlMinimo) + parseFloat(seguroX));
            }
            $('vlFretePeso_'+ idx).value = '0.00';
        }
        //Final cálculo do frete minímo
        
        $('vlTotal_'+ idx).value = formatoMoeda(parseFloat($('vlTaxa_'+ idx).value) +
            parseFloat($('vlOutros_'+ idx).value) +
            parseFloat($('vlPedagio_'+ idx).value) +
            parseFloat($('vlSecCat_'+ idx).value) +
            parseFloat($('vlGris_'+ idx).value) +
            parseFloat($('vlFretePeso_'+ idx).value) +
            parseFloat($('vlFreteValor_'+ idx).value));

        if ($('chk_incluir_icms').checked && isIcmsMinimo){
		    var isCalculaNormal = true; 
			if (getTipoMontagem() == 'r' && $('tipo_frete_cif').checked){
				if ($("uf_destino").value != "MG" && $('uf_fl_'+$('filialId').value).value == 'MG' && $('ufRemetente').value == 'MG'
				    && ($('rem_st_mg').value == 't' || $('rem_st_mg').value == 'true')){
					$('vlTotal_'+ idx).value = formatoMoeda(parseFloat($('vlTotal_'+ idx).value / 0.856));
					var isCalculaNormal = false; 
				}
			}
			if (isCalculaNormal){
				var totalComICMS = parseFloat($('vlTotal_'+ idx).value) / ((100 - parseFloat($('vlAliqIcms_'+idx).value))/100);
				totalComICMS = totalComICMS.toFixed(3);
				$('vlTotal_'+ idx).value = formatoMoeda(totalComICMS);
			}
        }
        
        $('vlIcms_'+ idx).value = formatoMoeda(parseFloat($('vlTotal_'+ idx).value) * parseFloat($('vlAliqIcms_'+ idx).value) / 100);
        
        calculaRedesp(idx);
    }

    function calcularTotal(){
        $('total_prestacao').value = formatoMoeda(parseFloat($('valor_taxa_fixa').value) +
            parseFloat($('valor_outros').value) +
            parseFloat($('valor_pedagio').value) +
            parseFloat($('valor_sec_cat').value) +
            parseFloat($('valor_frete_peso').value) +
            parseFloat($('valor_frete_valor').value));

    }

    var windowCidade = null;
    function localizaCidadeOrigem(){
        windowCidade = window.open('./localiza?acao=consultar&paramaux='+$('idcidadedestino').value+'&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
    }

    function localizaCidadeDestino(){
        windowCidade = window.open('./localiza?acao=consultar&paramaux='+$('idcidadeorigem').value+'&idlista=<%=BeanLocaliza.CIDADE_DESTINO%>','Cidade_Destino',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
    }
    function totalGeralNota(){
        var totalPeso = 0;  
        var totalVol = 0;  
        var totalCubagem = 0;
        var totalMercadoria = 0;
    
        for (i = 0; i <= countDest - 1; ++i){
            if ($('trDest_' + i) != null){
                totalCubagem += parseFloat($('metro_'+ i).value);
                totalPeso += parseFloat($('totalPeso_'+ i).value);
                totalMercadoria += parseFloat($('totalValor_'+ i).value);
                totalVol += parseFloat($('totalVol_'+ i).value);
            }
        }
        $('total_cubagem').value = roundABNT(totalCubagem, 4);
        $('total_peso').value = roundABNT(totalPeso, 3);
        $('total_volume').value = roundABNT(totalVol, 4);
        $('total_mercadoria').value = formatoMoeda(totalMercadoria);
        totalGeralMercadoria = totalMercadoria;
        if (tarifas.tipo_frete_peso == 'f' && ($('tipotaxa').value == '0' || $('tipotaxa').value == '1' )) {
            alteraTipoTaxa();
        }else{
            ratear();
        }
    }

    function getQtdCtrcs(){
        var qtdCtrcs = 0;
        for (i = 0; i <= countDest - 1; ++i){
            if ($('trDest_' + i) != null){
                qtdCtrcs++;
            }
        }
        return qtdCtrcs;
    }    
    
    function ratear(){
		var countEntrega = 0; 
        if ($('chk_ratearFrete').checked){
            calculaFrete(-1);
            var qtdCtrcs = getQtdCtrcs();
            var valorQuilo = parseFloat($('valor_frete_peso').value) / parseFloat($('total_peso').value);
            var valorMercadoria = parseFloat($('valor_frete_peso').value) / parseFloat($('total_mercadoria').value);
            var valorVolume = parseFloat($('valor_frete_peso').value) / parseFloat($('total_volume').value);
            var valorCubagem = parseFloat($('valor_frete_peso').value) / parseFloat($('total_cubagem').value);
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
					countEntrega++;
					if (countEntrega >= parseInt(tarifas.taxa_apartir_entrega)){
						$('vlTaxa_'+ i).value = $('valor_taxa_fixa').value;
					}else{
						$('vlTaxa_'+ i).value = '0.00';
					}		
                    $('vlSecCat_'+ i).value = $('valor_sec_cat').value;
                    $('vlFreteValor_'+i).value = getFreteValor($('totalValor_'+i).value,tarifas.percentual_advalorem,
                                                    tarifas.percentual_nf,tarifas.base_nf_percentual,tarifas.valor_percentual_nf,
                                                    $("tipotaxa").value,tarifas.tipo_impressao_percentual,tarifas.formula_seguro, tarifas.formula_percentual,
                                                    $('totalPeso_'+i).value, $('totalVol_'+i).value, '0', $('total_km').value, $('tipoveiculo').value,
                                                    tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('metro_'+i).value,false,0,1,'r','t',0, true, $("tipo_arredondamento_peso").value);
                    $('vlGris_'+i).value = getGris(tarifas.percentual_gris,$('totalValor_'+i).value, tarifas.valor_minimo_gris, tarifas.formula_gris, $('tipotaxa').value, $('totalPeso_'+i).value, $('totalVol_'+i).value, '0', $('total_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('metro_'+i).value,1,'r','t',0, $("tipo_arredondamento_peso").value);
                    //escondendo a tr da cubagem
                    $('trCubDest_'+i).style.display = "none";
                    //Ratear por peso
                    if (document.getElementById("peso").checked){
                        if ($('tipotaxa').value == '0' || $('tipotaxa').value == '3' || $('tipotaxa').value == '5'){
                            $('vlFretePeso_'+ i).value = formatoMoeda(parseFloat($('totalPeso_'+ i).value) * valorQuilo);
                        }else{
                            $('vlFretePeso_'+ i).value = formatoMoeda(parseFloat($('pesoCubado_'+ i).value) * valorQuilo);
                        }
					}else if (document.getElementById("mercadoria").checked){
                        $('vlFretePeso_'+ i).value = formatoMoeda(parseFloat($('totalValor_'+ i).value) * valorMercadoria);
                    }else if (document.getElementById("volume").checked){
                        $('vlFretePeso_'+ i).value = formatoMoeda(parseFloat($('totalVol_'+ i).value) * valorVolume);
                    }else{
                        $('trCubDest_'+i).style.display = "";
                        $('vlFretePeso_'+ i).value = formatoMoeda(parseFloat($('metro_'+ i).value) * valorCubagem);
                    }
                    
                    
                    
                    
                    calculaTotalCtrc(i);
                    
                    //Verificando a previsao de entrega
                    if(tarifas.previsao_entrega_calculada == undefined){
                        $('dataEntrega_'+i).value = '';
                    }else{
                        $('dataEntrega_'+i).value = tarifas.previsao_entrega_calculada;
                    }
                    
                }
            }
        }else{
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    calculaFrete(i);
					countEntrega++;
					if (countEntrega >= parseInt(tarifas.taxa_apartir_entrega)){
						$('vlTaxa_'+ i).value = $('valor_taxa_fixa').value;
					}else{
						$('vlTaxa_'+ i).value = '0.00';
					}		
                    $('vlSecCat_'+ i).value = $('valor_sec_cat').value;
                    $('vlFreteValor_'+i).value = formatoMoeda($('totalValor_'+i).value * tarifas.percentual_advalorem / 100);
                    var gris = parseFloat($('totalValor_'+i).value) * parseFloat(tarifas.percentual_gris) / 100
                    $('vlGris_'+i).value = getGris(tarifas.percentual_gris,$('totalValor_'+i).value, tarifas.valor_minimo_gris, tarifas.formula_gris, $('tipotaxa').value, $('totalPeso_'+i).value, $('totalVol_'+i).value, '0', $('total_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('metro_'+i).value,1,'r','t',0, $("tipo_arredondamento_peso").value);
                    calculaTotalCtrc(i);
                    //Verificando a previsao de entrega
                    
                    if(tarifas.previsao_entrega_calculada == undefined){
                         $('dataEntrega_'+i).value = '';
                    }else{                       
                        $('dataEntrega_'+i).value = tarifas.previsao_entrega_calculada;
                    }
                }
            }
        }
        if ($('chk_ratearOutros').checked){
            var valorOutrosQuilo = parseFloat($('valor_outros').value) / parseFloat($('total_peso').value);
            var valorOutrosVolume = parseFloat($('valor_outros').value) / parseFloat($('total_volume').value);
            var valorOutrosMercadoria = parseFloat($('valor_outros').value) / parseFloat($('total_mercadoria').value);
            var valorOutrosCubagem = parseFloat($('valor_outros').value) / parseFloat($('total_cubagem').value);
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    //Ratear por peso
                    if (document.getElementById("peso").checked){
                        $('vlOutros_'+ i).value = formatoMoeda(parseFloat($('totalPeso_'+ i).value) * valorOutrosQuilo);
                    }else if (document.getElementById("mercadoria").checked){
                        $('vlOutros_'+ i).value = formatoMoeda(parseFloat($('totalValor_'+ i).value) * valorOutrosMercadoria);
                    }else if (document.getElementById("volume").checked){
                        $('vlOutros_'+ i).value = formatoMoeda(parseFloat($('totalVol_'+ i).value) * valorOutrosVolume);
                    }else{
                        $('trCubDest_'+i).style.display = "";
                        $('vlOutros_'+ i).value = formatoMoeda(parseFloat($('metro_'+ i).value) * valorOutrosCubagem);
                    }
                    calculaTotalCtrc(i);
                }
            }
        }else{
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    $('vlOutros_'+ i).value = $('valor_outros').value;
                    calculaTotalCtrc(i);
                }
            }
        }
        if ($('chk_ratearSec').checked){
            var valorSecQuilo = parseFloat($('valor_sec_cat').value) / parseFloat($('total_peso').value);
            var valorSecMercadoria = parseFloat($('valor_sec_cat').value) / parseFloat($('total_mercadoria').value);
            var valorSecVolume = parseFloat($('valor_sec_cat').value) / parseFloat($('total_volume').value);
            var valorSecCubagem = parseFloat($('valor_sec_cat').value) / parseFloat($('total_cubagem').value);
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    //Ratear por peso
                    if (document.getElementById("peso").checked){
                        $('vlSecCat_'+ i).value = formatoMoeda(parseFloat($('totalPeso_'+ i).value) * valorSecQuilo);
                    }else if (document.getElementById("mercadoria").checked){
                        $('vlSecCat_'+ i).value = formatoMoeda(parseFloat($('totalValor_'+ i).value) * valorSecMercadoria);
                    }else if (document.getElementById("volume").checked){
                        $('vlSecCat_'+ i).value = formatoMoeda(parseFloat($('totalVol_'+ i).value) * valorSecVolume);
                    }else{
                        $('trCubDest_'+i).style.display = "";
                        $('vlSecCat_'+ i).value = formatoMoeda(parseFloat($('metro_'+ i).value) * valorSecCubagem);
                    }
                    calculaTotalCtrc(i);
                }
            }
        }else{
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    $('vlSecCat_'+ i).value = $('valor_sec_cat').value;
                    calculaTotalCtrc(i);
                }
            }
        }
        if ($('chk_ratearPedagio').checked){
            var valorPedagioQuilo = parseFloat($('valor_pedagio').value) / parseFloat($('total_peso').value);
            var valorPedagioMercadoria = parseFloat($('valor_pedagio').value) / parseFloat($('total_mercadoria').value);
            var valorPedagioVolume = parseFloat($('valor_pedagio').value) / parseFloat($('total_volume').value);
            var valorPedagioCubagem = parseFloat($('valor_pedagio').value) / parseFloat($('total_cubagem').value);
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    //Ratear por peso
                    if (document.getElementById("peso").checked){
                        $('vlPedagio_'+ i).value = formatoMoeda(parseFloat($('totalPeso_'+ i).value) * valorPedagioQuilo);
                    }else if (document.getElementById("mercadoria").checked){
                        $('vlPedagio_'+ i).value = formatoMoeda(parseFloat($('totalValor_'+ i).value) * valorPedagioMercadoria);
                    }else if (document.getElementById("volume").checked){
                        $('vlPedagio_'+ i).value = formatoMoeda(parseFloat($('totalVol_'+ i).value) * valorPedagioVolume);
                    }else{
                        $('trCubDest_'+i).style.display = "";
                        $('vlPedagio_'+ i).value = formatoMoeda(parseFloat($('metro_'+ i).value) * valorPedagioCubagem);
                    }
                    calculaTotalCtrc(i); 
                }
            }
        }else{
            for (i = 0; i <= countDest - 1; ++i){
                if ($('trDest_' + i) != null){
                    $('vlPedagio_'+ i).value = getPedagio($('totalPeso_'+i).value,tarifas.valor_pedagio,tarifas.qtd_quilo_pedagio,$('tipotaxa').value,'0',tarifas.formula_pedagio,totalGeralMercadoria,$('totalVol_'+i).value,'0',$('total_km').value,$('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('total_cubagem').value,1,'r','t',0, $("tipo_arredondamento_peso").value);
                    calculaTotalCtrc(i);
                }
            }
        }
    }

    function alteraTipoTaxa(){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var textoresposta = transport.responseText;
            espereEnviar("",false);	  		
            //se deu algum erro na requisicao...
            if (textoresposta == "load=0") {
                //          buscouTaxas = "0";
                //               fechaClientesWindow();
                if ($("tipotaxa").value != 3 && $("tipotaxa").value != 5){
                    alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino.");   		          
                    $("tipotaxa").value = $("rem_tipotaxa").value;
                }   
                return false;
            }

            //obtendo o objeto JSON com a tabela de preço
            tarifas = eval('('+textoresposta+')');
            $('idtabela').value = tarifas.id;
            $('lbIdTabel').innerHTML = "Tabela:"+tarifas.id;
            $('lbIdTabel').style.display = '';

            //faz o calculo da taxa escolhida e atribui aos respectivos campos

            ratear();
        }//funcao e()

        $('lbTotalPeso').innerHTML = "Total Peso:";
        if ($('tipotaxa').value == '1'){
            $('lbTotalPeso').innerHTML = "Peso Cubado:";
        }

        if ($('idCliente').value == '0'){
            if (getTipoMontagem()=='r' || getTipoMontagem()=='v'){
                alert('Informe o remetente corretamente!');
                $('tipotaxa').value = $('rem_tipotaxa').value;
            }else{
                alert('Informe o destinatário corretamente!');
                $('tipotaxa').value = $('dest_tipotaxa').value;
            }
        }else if ($('idcidadeorigem').value == '0'){
            alert('Informe a cidade de origem corretamente!');
            $('tipotaxa').value = (getTipoMontagem()=='r' || getTipoMontagem()=='v' ? $('rem_tipotaxa').value : $('dest_tipotaxa').value);
        }else if ($('idcidadedestino').value == '0'){
            alert('Informe a cidade de destino corretamente!');
            $('tipotaxa').value = (getTipoMontagem()=='r' || getTipoMontagem()=='v' ? $('rem_tipotaxa').value : $('dest_tipotaxa').value);
        }else{
            var peso_para_calculo = $('total_peso').value;
            //Buscando a tabela de preço 
            tryRequestToServer(function(){new Ajax.Request("./ConhecimentoControlador?acao=carregar_taxascli"+
//                    concatFieldValue("idCliente,idcidadeorigem,idcidadedestino,tipoveiculo,tipoproduto,total_km,dtemissao")+
                    "&idconsignatario="+$("idCliente").value+
                    "&idcidadeorigem="+$("idcidadeorigem").value+
                    "&idcidadedestino="+$("idcidadedestino").value+
                    "&tipoveiculo="+$("tipoveiculo").value+
                    "&tipoproduto="+$("tipoproduto").value+
                    "&distancia_km="+$("total_km").value+
                    "&dtemissao="+$("dtemissao").value+
                    "&peso="+peso_para_calculo+
                    "&idTaxa="+$('tipotaxa').value+
                    "&tipoTransporte=r",//na chamada antiga era informado r como padrao.
                {method:'post', 
                    onSuccess: e});
            });		 				 
            espereEnviar("",true);
        }
    }

    function limpaCampos(idx){
        if ($('vlFretePeso_'+idx) != null){
            $('vlFretePeso_'+idx).value = "0.00";
            $('vlFreteValor_'+idx).value = "0.00";
            $('vlTaxa_'+ idx).value = "0.00";
            $('vlOutros_'+ idx).value = "0.00";
        }    
        $('valor_taxa_fixa').value = "0.00";
        $('valor_outros').value = "0.00";
        $('valor_frete_peso').value = "0.00";
        $('valor_frete_valor').value = "0.00";
    }
    
   
   // function removeNote(nameObj, nameObj2) {
    //    if (confirm("Deseja mesmo excluir esta Nota Fiscal ?")){
            //nf_idnota_fiscal
       //     Element.remove(nameObj);
      //  }
    //}
    
    
    
	function checkContratoFrete(){
            
		function alertMsg(msgText){ alert(msgText); habilitaSalvar(true); return false; }
        if (<%=cfg.isCartaFreteAutomatica()%> && $('chk_carta_automatica').checked){
            if (($('idmotorista').value=='0' || $('idveiculo').value=='0')){
				return alertMsg("Informe o motorista e/ou veículo corretamente para que a geração do contrato de frete automática funcione.");
            }
			if ( <%=cfg.isObrigaAgenteCargaCTRC()%> && parseInt(getObj("idagente_carga").value)==0 && $('tipo').value == 'c')
				return  alertMsg("O Campo Agente de carga é de preenchimento Obrigatório.");
            if ((parseFloat($('cartaLiquido').value) !=  parseFloat(parseFloat($('cartaValorAdiantamento').value) + parseFloat($('cartaValorSaldo').value) + parseFloat($('cartaValorCC').value)).toFixed(2)) || parseFloat($('cartaLiquido').value) <= 0){
				return alertMsg("Informe o valor do frete carreteiro corretamente.");
            }
			if (<%=cfg.isControlarTalonario()%>){
				if (parseFloat($('cartaValorAdiantamento').value) != 0 && $('cartaFPagAdiantamento').value == '3' && $('cartaDocAdiantamento_cb').value == ''){
					return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
				}
			}else{
				if (parseFloat($('cartaValorAdiantamento').value) != 0 && $('cartaFPagAdiantamento').value == '3' && $('cartaDocAdiantamento').value == ''){
					return alertMsg("Informe o número do cheque corretamente para o adiantamento.");
				}
			}
			if ($('motor_liberacao').value == ''){
					return alertMsg("Informe a liberação do motorista corretamente.");
			}
			//Verificando se o percentual de adiantamento está dentro do permitido no cadastro do motorista.
			if (<%=nivelUserAdiantamento == 0%>){
				var percPermitido = $('perc_adiant').value;
				var totalAdtmo = $('cartaValorAdiantamento').value;
				var xTotalLiquido = $('cartaLiquido').value;
				var percAdtmo = parseFloat(totalAdtmo) * 100 / parseFloat(xTotalLiquido);
				if (parseFloat(percAdtmo) > parseFloat(percPermitido)){
					return alertMsg('Para esse motorista só é permitido ' + percPermitido + '% de adiantamento!');
				}
			}
			//Validação das despesas
			for(var dd = 0; dd <= parseInt(countDespesaCarta); dd++){
				if ($('trDespCarta_'+dd) != null){
					if (parseFloat($('vlDespCarta_'+dd).value) <= 0 || $('idFornDespCarta_'+dd).value == '0' || $('idPlanoDespCarta_'+dd).value == '0'){
						return alertMsg("Para gerar a despesa de viagem do contrato de frete é necessário informar o 'Valor', 'Fornecedor' e o 'Plano de Custo'.");
					}
					if ($('DespPago_'+dd).checked && $('chqDespCarta_'+dd).checked){
						if (<%=cfg.isControlarTalonario()%>){
							if($('docDespCarta_cb_'+dd).value == ''){
								return alertMsg("Informe o número do cheque corretamente para a despesa de viagem.");
							}
						}else{
							if($('docDespCarta_'+dd).value == ''){
								return alertMsg("Informe o número do cheque corretamente para a despesa de viagem.");
							}
						}	
					}
				}
			}
        }
        if (<%=cfg.isCartaFreteAutomatica()%> && $('chk_adv_automatica').checked){
			//Validação dos adiantamentos
			for(var di = 0; di <= parseInt(countADV); di++){
				if ($('trADV_'+di) != null){
					if (parseFloat($('vlADV_'+di).value) <= 0){
						return alertMsg("Informe o valor do adiantamento de viagem corretamente.");
					}
					if (parseFloat($('contaADV_'+di).value) == ''){
						return alertMsg("Informe a conta do adiantamento de viagem corretamente.");
					}
					if ($('chqADV_'+di).checked){
						if (<%=cfg.isControlarTalonario()%>){
							if($('docADV_cb_'+di).value == ''){
								return alertMsg("Informe o número do cheque corretamente para o adiantamento de viagem.");
							}
						}else{
							if($('docADV_'+di).value == ''){
								return alertMsg("Informe o número do cheque corretamente para o adiantamento de viagem.");
							}
						}	
					}
				}
			}
			//Validação das despesas
			for(var dd = 0; dd <= parseInt(countDespesaADV); dd++){
				if ($('trDespADV_'+dd) != null){
					if (parseFloat($('vlDespADV_'+dd).value) <= 0 || $('idFornDespADV_'+dd).value == '0' || $('idPlanoDespADV_'+dd).value == '0'){
						return alertMsg("Para gerar a despesa de viagem do adiantamento é necessário informar o 'Valor', 'Fornecedor' e o 'Plano de Custo'.");
					}
				}
			}
			
			if(<%=cfg.isImpedeViagemMotorista()%> && $('impedir_viagem_motorista').value == 't'){
				return alertMsg("O motorista informado possui alguma viagem em aberto, finalize a viagem anterior antes de criar uma nova.");
			}
		}
		//se chegou aqui entao esta td ok
		return true;   	
	}
        
    var valorMaximo;    
    function ativarDesativarValorMaximo(){
        var idFilialSelecionada = $("filialId").value;
        var idFiliais = $("idsFiliais").value;
        var ativarValorMaximo = $("ativarValorMaximoFiliais").value;
        var valoresMaxFiliais = $("valoresMaxFiliais").value;
        var passou = false;
        for(var i = 0;i < idFiliais.split("!!").length; i++){
            if(idFiliais.split("!!")[i] == idFilialSelecionada){
                if($("chk_carta_automatica").checked == true && (ativarValorMaximo.split("!!")[i] == "t" || ativarValorMaximo.split("!!")[i] == "true")){
                    valorMaximo = valoresMaxFiliais.split("!!")[i];
                    passou = true;
                }
            }
        }
        return passou;
    }
        
    function salvar(){
        var validarValorMaximoCte = ativarDesativarValorMaximo();
        if ($('idCliente').value == '0'){
            alert('Informe o cliente remetente corretamente!');
            return false;
        }else if($('idcidadedestino').value == '0'){
            alert('Informe a cidade de destino corretamente!');
            return false;
        }else if(countDest == 0){
            alert('Informe, no mínimo, 1 destinatário!');
            return false;
		}else if ( <%=cfg.isObrigaRotaCTRC()%> && parseInt(getObj("id_rota_viagem_real").value)==0){
			return  alertMsg("O Campo Rota é de preenchimento Obrigatório.");
		}else if ( <%=cfg.isObrigaColetaCTRC()%> && parseInt(getObj("idcoleta").value)==0){
			return  alertMsg("O Campo Coleta é de preenchimento Obrigatório.");
		}else if ( <%=cfg.isObrigaMotoristaCTRC()%> && parseInt(getObj("idmotorista").value)==0){
			return  alertMsg("O Campo Motorista é de preenchimento Obrigatório.");
		}else if ( <%=cfg.isObrigaVeiculoCTRC()%> && parseInt(getObj("idveiculo").value)==0){
			return  alertMsg("O Campo Veículo é de preenchimento Obrigatório.");
		}else if (getObj("is_obriga_carreta").value =='t' && parseInt(getObj("idcarreta").value)==0){
			return  alertMsg("O Campo Carreta é de preenchimento Obrigatório.");
		}else if (!checkContratoFrete()){	
        }else{
            var notes = "";
            for (var i = 0; i <= countDest; i++){
                if (getNotes(i) == null){
                    return null;
                }
                if ($('idDest_'+i) != null){
                    notes += (notes == "" ? "" : "&")+getNotes(i);
                }
            }
            //Validação para não deixar salvar uma Coleta/OS e um contrato de frete.
            //Só pode adicionar um contrato de frete com CT-e.
            var maxCte = $("maxCte").value;
            for (var qtdCte = 0; qtdCte < maxCte; qtdCte++) {
                if(validarValorMaximoCte){
                    if(valorMaximo != null && valorMaximo != undefined){
                        if($("totalValor_"+qtdCte).value > valorMaximo){
                            alert("Atenção : o valor do(s) total(is) da(s) NF(s) é maior que o valor limite da filial de origem.");
                            return false;
                        }
                    }
                }
                
                if ($("gerar_"+qtdCte) != null) {                    
                    if ($("gerar_"+qtdCte).value == "os" && $("chk_carta_automatica").checked) {
                        alert("Atenção: Ao gerar uma Coleta/Os, não pode adicionar um contrato de frete!");
                        return false;
                    }
                    
                }
            }
            if(colocarPonto($("cartaValorFrete").value) == 0 && $("chk_carta_automatica").checked == true){
                alert("Atenção: Valor do Contrato de frete não pode ser 0!");
                return false;
            }
                
            $("tipotaxa").disabled = false;
            habilitar($("filialId"));
            document.getElementById('formCtrc').action = "./montar_carga.jsp?acao=salvar&qtdCtrc=" + countDest +
                                                         "&qtdNotas=" + countNotas + "&tipoMontagem="+getTipoMontagem()+
														 "&countADV="+countADV+
														 "&countDespesaADV="+countDespesaADV+
														 "&countDespesaCarta="+countDespesaCarta;
            window.open('about:blank', 'pop', 'width=210, height=100');
            $("formCtrc").submit();
            return true;
        }
    }
    
    function calculaFrete(idx){
        //idx = -1 quer dizer que não haverá rateio
        var valorFretePeso = (idx == -1 ? "valor_frete_peso" : "vlFretePeso_"+idx);
        var totalPeso = (idx == -1 ? "total_peso" : ($('tipotaxa').value == '0' ? "totalPeso_"+idx : "pesoCubado_"+idx));
        var totalVolume = (idx == -1 ? "total_volume" : "totalVol_"+idx);
    
        limpaCampos(idx);
        
        $('chk_incluir_icms').checked = tarifas.isinclui_icms; 
        
        $("tipoFreteTabela").value = tarifas.tipo_taxa;
        console.log("tarifas.tipo_taxa: "+tarifas.tipo_taxa);
        console.log("tipoTaxa: "+$("tipotaxa").value);
        console.log("utilizaTipoFreteTabelaRem "+$("utilizaTipoFreteTabelaRem").value);
        var utiliza = ($("utilizaTipoFreteTabelaRem").value == 't') || ($("utilizaTipoFreteTabelaRem").value == 'true');
        <%boolean alteraTipoFrete = (Apoio.getUsuario(request).getAcesso("alteratipofretecte") == 4);%>
        var tp = $("tipoFreteTabela").value;
        if(($("tipoFreteTabela").value!= null && $("tipoFreteTabela").value!='undefined' && (tp!='-1') && utiliza)){
            if(($("tipotaxa").value=='0' || $("tipotaxa").value=='1') && ($("tipoFreteTabela").value== '1' || $("tipoFreteTabela").value=='0') && tarifas.is_considerar_maior_peso){
            } else if(($("tipotaxa").value=='0' || $("tipotaxa").value=='1'|| $("tipotaxa").value=='2') 
                    && ($("tipoFreteTabela").value== '1' || $("tipoFreteTabela").value=='0' || $("tipoFreteTabela").value=='2') && tarifas.is_considerar_valor_maior_peso_nota){
            }else{
                if($("utilizaTipoFreteTabelaRem").value == 't' || $("utilizaTipoFreteTabelaRem").value == 'true'){
                    $("tipotaxa").value= $("tipoFreteTabela").value;                     
                }                
            }
            $("tipotaxa").disabled = 'true';
            }else if (tarifas.cliente_id == undefined && (tp!='-1') && utiliza){
                $("tipotaxa").value= $("tipoTaxaTabela").value;
            }else{
            if(<%=alteraTipoFrete%>){
                $("tipotaxa").disabled = false;
            }else{
                $("tipotaxa").disabled = 'true';
            }
        }
        switch ($('tipotaxa').value){
            //Peso/Kg
            case "0" :
                //valor por peso usando faixas peso 
                $(valorFretePeso).value = getFretePeso($(totalPeso).value,$("total_volume").value,$("tipotaxa").value,
                                           tarifas.valor_peso,tarifas.valor_volume,0,
                                           0,tarifas.valor_veiculo,tarifas.valor_por_faixa,
                                           'r',tarifas.valor_excedente_aereo ,tarifas.valor_excedente,
                                           tarifas.maximo_peso_final,tarifas.ispreco_tonelada,tarifas.tipo_frete_peso,
                                           tarifas.valor_maximo_peso_final,tarifas.valor_km,tarifas.is_considerar_maior_peso,
                                           tarifas.tipo_impressao_percentual,$("total_mercadoria").value,tarifas.base_nf_percentual,
                                           tarifas.valor_percentual_nf,tarifas.percentual_nf,0,
                                           $("total_km").value,tarifas.formula_volumes, $('tipoveiculo').value,
                                           tarifas.formula_percentual,tarifas.valor_pallet,tarifas.formula_pallet,
                                           false,'0.00',0,
                                           tarifas.formula_frete_peso,tarifas.tipo_inclusao_icms, 0, false,$("tipo_arredondamento_peso").value
                                          );

                /*if (tarifas.tipo_frete_peso == "f") {
                    $(valorFretePeso).value = formatoMoeda((tarifas.valor_por_faixa <= 0 ? 
                        (parseFloat(tarifas.valor_maximo_peso_final) + ((parseFloat($(totalPeso).value) - parseFloat(tarifas.maximo_peso_final)) * parseFloat(tarifas.valor_excedente))) 
                    : tarifas.valor_por_faixa)); 
                }else{//valor por peso normal
                    if (tarifas.ispreco_tonelada) {
                        $(valorFretePeso).value = formatoMoeda(tarifas.valor_peso * ($(totalPeso).value/1000));
                    }else{
                        $(valorFretePeso).value = formatoMoeda(tarifas.valor_peso * $(totalPeso).value);	
                    }
                }*/
                break;
            
            //Peso/Cubagem
            case "1" :

                //valor por peso usando faixas peso
                if (tarifas.tipo_frete_peso == "f") {
                    $(valorFretePeso).value = formatoMoeda((tarifas.valor_por_faixa <= 0 ?
                        (parseFloat(tarifas.valor_maximo_peso_final) + ((parseFloat($(totalPeso).value) - parseFloat(tarifas.maximo_peso_final)) * parseFloat(tarifas.valor_excedente)))
                    : tarifas.valor_por_faixa));

                }else{//valor por peso normal
                    if (tarifas.ispreco_tonelada) {
                        $(valorFretePeso).value = formatoMoeda(tarifas.valor_peso * ($(totalPeso).value/1000));
                    }else{
                        $(valorFretePeso).value = formatoMoeda(tarifas.valor_peso * $(totalPeso).value);
                    }
                }

                break;

            //Percentual sobre nota fiscal
            case "2":

                var valor_mercadoria = ($('totalValor_'+idx) == null ? 0 : $('totalValor_'+idx).value);
                          
                var x = 0;
                //x receberá por padrão o valor_percentual_frete
                x = tarifas.valor_percentual_nf;
                //Se o valor da mercadoria for maior que a base então calcule pelo percentual
                if (parseFloat(valor_mercadoria) > parseFloat(tarifas.base_nf_percentual))
                x = (valor_mercadoria * tarifas.percentual_nf)/100;

                var y = valor_mercadoria * (tarifas.percentual_advalorem / 100);

                $('vlFretePeso_'+idx).value = "0.00";
                $('vlFreteValor_'+idx).value = formatoMoeda(x + y);
                                
                break;
                   
            //frete combinado
            case "3":
                $(valorFretePeso).value = formatoMoeda(tarifas.valor_veiculo);

                break;
                   
            //frete por volume
            case "4":              
                $(valorFretePeso).value = formatoMoeda($(totalVolume).value * tarifas.valor_volume);
                break;

            //frete por km 
            case "5":
                $("valor_frete_peso").value = formatoMoeda(tarifas.valor_km);
                break;
        }
        $('valor_sec_cat').value = getValorSecCat(tarifas.valor_sec_cat, tarifas.formula_sec_cat, $('tipotaxa').value, $('total_peso').value, totalGeralMercadoria, $('total_volume').value, '0', $('total_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('total_cubagem').value,1,'r',0,0,'t',0, $("tipo_arredondamento_peso").value);
        $("valor_pedagio").value = getPedagio($('total_peso').value,tarifas.valor_pedagio,tarifas.qtd_quilo_pedagio,$('tipotaxa').value,'0',tarifas.formula_pedagio,totalGeralMercadoria,$('total_volume').value,'0',$('total_km').value,$('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('total_cubagem').value,1,'r','t',0, $("tipo_arredondamento_peso").value);
        $('valor_taxa_fixa').value = getTaxaFixa(tarifas.valor_taxa_fixa, tarifas.formula_taxa_fixa, $('tipotaxa').value, $('total_peso').value, totalGeralMercadoria, $('total_volume').value, '0', $('total_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('total_cubagem').value,1,'r',0,0,'t',0, $("tipo_arredondamento_peso").value);
        $('valor_outros').value = getOutros(tarifas.valor_outros, tarifas.formula_outros, $('tipotaxa').value, $('total_peso').value, totalGeralMercadoria, $('total_volume').value, '0', $('total_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,tarifas.base_cubagem,$('total_cubagem').value,1,'r','t',0, $("tipo_arredondamento_peso").value);
        
        if (tarifas.is_considerar_valor_maior_peso_nota && ($('tipotaxa').value == "0" || $('tipotaxa').value == "1" || $('tipotaxa').value == "2")) {
                var mTpFrete = getTipoPreferencialPesoPercentualNotaFiscal($(totalPeso).value,$("total_volume").value,$("tipotaxa").value,
                                           tarifas.valor_peso,tarifas.valor_volume,0,
                                           0,tarifas.valor_veiculo,tarifas.valor_por_faixa,
                                           'r',tarifas.valor_excedente_aereo ,tarifas.valor_excedente,
                                           tarifas.maximo_peso_final,tarifas.ispreco_tonelada,tarifas.tipo_frete_peso,
                                           tarifas.valor_maximo_peso_final,tarifas.valor_km,tarifas.is_considerar_maior_peso,
                                           tarifas.tipo_impressao_percentual,$("total_mercadoria").value,tarifas.base_nf_percentual,
                                           tarifas.valor_percentual_nf,tarifas.percentual_nf,0,
                                           $("total_km").value,tarifas.formula_volumes, $('tipoveiculo').value,
                                           tarifas.formula_percentual,tarifas.valor_pallet,tarifas.formula_pallet,
                                           false,'0.00',0,
                                           tarifas.formula_frete_peso,tarifas.tipo_inclusao_icms, 0, false, $("tipo_arredondamento_peso").value
                                          );
                                    
                if (mTpFrete != $('tipotaxa').value) {
                    $('tipotaxa').value = mTpFrete;
                    alteraTipoTaxa($('tipotaxa').value);
                    return null;
                }
            }
}

function totalCubadoCtrc(idx){
    //Calculando o total de metro
    $('metro_'+idx).value = formatoMoeda(parseFloat($('altura_'+idx).value) *
    parseFloat($('largura_'+idx).value) * parseFloat($('comprimento_'+idx).value) *
    parseFloat($('totalVol_'+idx).value));
    pesoCubadoCtrc(idx);
}

function pesoCubadoCtrc(idx){
    //Calculando o total de metro
    $('pesoCubado_'+idx).value = formatoMoeda(parseFloat($('metro_'+idx).value) *
    parseFloat($('base_'+idx).value));
}

function mostrarDetalhes(idx){
    if ($('detalhes_'+idx).innerHTML == 'mais...'){
        $('detalhes_'+idx).innerHTML = 'ocultar...';
        $('trDet_' + idx).style.display = "";
        $('trClienteRed_' + idx).style.display = "";
        $('trObs_' + idx).style.display = "";
        $('trAprop_' + idx).style.display = "";
    }else{
        $('detalhes_'+idx).innerHTML = 'mais...';
        $('trDet_' + idx).style.display = "none";
        $('trClienteRed_' + idx).style.display = "none";
        $('trObs_' + idx).style.display = "none";
        $('trAprop_' + idx).style.display = "none";
    }
}

function calculaRedesp(idx){
    var minimo = $('valorMinimoRed_'+idx).value;
    var totalRed = 0;
    if ($('tabelaRed_'+idx).value == '0'){
        var valorPerc = $('valorPercRed_'+idx).value;
        totalRed = (parseFloat(valorPerc) * parseFloat($('vlTotal_'+idx).value) / 100);
    }else if ($('tabelaRed_'+idx).value == '1'){
        var valorPeso = $('valorPesoRed_'+idx).value;
        totalRed = (parseFloat(valorPeso) * parseFloat($('totalPeso_'+idx).value));
    }
    $('valorRed_'+idx).value = formatoMoeda((parseFloat(totalRed) < parseFloat(minimo) ? minimo : totalRed));
}

function getTipoMontagem(){

	$('codigoRemetente').style.display = '';
    if ($('tipoMontagemRem').checked){
       return 'r';
    }else if ($('tipoMontagemDest').checked){
		$('codigoRemetente').style.display = 'none';
       return 'd';
    }else if ($('tipoMontagemVarios').checked){
       return 'v';
    }else{
       return 'r';
    }

}

function alteraTipoMontagem(){
    if (getTipoMontagem() == 'r'){
        $('lbRemetente').innerHTML = "Remetente:";
        $('lbDest').innerHTML = "Destinatário";
    }else if (getTipoMontagem() == 'd'){
        $('lbRemetente').innerHTML = "Destinatário:";
        $('lbDest').innerHTML = "Remetente";
    }else if (getTipoMontagem() == 'v'){
        $('lbRemetente').innerHTML = "Remetente:";
        $('lbDest').innerHTML = "Remetente/Destinatário";
    }
    if($("tipo_frete_cif").checked){
        alterarTipoPagamento("cif");
    }else if($("tipo_frete_fob").checked){
        alterarTipoPagamento("fob");
    }    
}

function concatIdNota(){
    var ids = "0";
    for (var ii = 0; ii <= countDest; ii++){
        if ($('idDest_' + ii) != null){
            for (var i2 = 0; i2 <= countNotas; i2++){
                if ($('nf_idnota_fiscal' + i2 + "_id" + ii) != null){
                    ids += ","+$('nf_idnota_fiscal' + i2 + "_id" + ii).value;
                }
            }
        }
    }
    return ids;
}

function calcularFreteCarreteiroRota(){
	//Calculando valor da ROTA
	var totalPrestacao = 0;
	if ($('chk_viagem_2').checked){
		totalPrestacao = $('valor_rota_viagem_2').value;
	}else{
		if ($('tipo_valor_rota').value == 'f'){
			totalPrestacao = $('valor_rota').value;
		}else if ($('tipo_valor_rota').value == 'p'){
			totalPrestacao = parseFloat(parseFloat($('valor_rota').value) * (parseFloat($('total_peso').value) / 1000)).toFixed(2);
			$('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
		}else if ($('tipo_valor_rota').value == 'c'){
			for(var ft = 0; ft <= parseInt(countDest); ft++){
				if ($('vlTotal_'+ft) != null){
					totalPrestacao += parseFloat($('vlTotal_'+ft).value) - parseFloat($('vlIcms_'+ft).value);
				}
			}
			totalPrestacao = parseFloat(parseFloat(totalPrestacao) * (parseFloat($('valor_rota').value) / 100)).toFixed(2);
			$('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
		}
	}
	$('cartaPedagio').value = $('valor_pedagio_rota').value;
	var qtdEntregasRota = parseFloat($('qtd_entregas_rota').value);
	var qtdEntregasMontagem = parseFloat($('total_entregas').value);
	if (qtdEntregasMontagem >= qtdEntregasRota){
		$('cartaOutros').value = formatoMoeda(parseFloat($('valor_entrega_rota').value) * (parseFloat(qtdEntregasMontagem - qtdEntregasRota + 1)));
	}else{
		$('cartaOutros').value = '0.00';
	}
	$('cartaValorFrete').value = formatoMoeda(totalPrestacao);
	
}	

function validarFreteCarreteiro(){
    var freteCarreteiroX = parseFloat($('cartaValorFrete').value);
    var freteMaximoCarreteiroX = parseFloat($('valor_maximo_rota').value);
    if (<%=nivelAlterarFrete < 4%>){
		if (parseFloat(freteCarreteiroX) > parseFloat(freteMaximoCarreteiroX)){
			alert('Você não tem privilégio suficiente para aumentar o valor do frete');
			$('cartaValorFrete').value = formatoMoeda(freteMaximoCarreteiroX);
		}
	}
}


	function calcularFreteCarreteiro(){
		var PercFreteCadastroProp = parseFloat($('percentual_ctrc_contrato_frete').value);
		if (PercFreteCadastroProp > 0){
			var totalSeguroProp = 0;
	//		if ($('is_urbano2').checked){
	//		   totalSeguroProp = parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('taxa_roubo_urbano').value) + parseFloat($('taxa_tombamento_urbano').value)) / 100); 	 
	//		}else{
	//		   totalSeguroProp = parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('taxa_roubo').value) + parseFloat($('taxa_tombamento').value)) / 100); 	 
	//		}
			//Somando o total de despesas de viagens
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
			var freteTotal = 0;
			var icmsTotal = 0;
			for(var ft = 0; ft <= parseInt(countDest); ft++){
				if ($('vlTotal_'+ft) != null){
					freteTotal += parseFloat($('vlTotal_'+ft).value);
					icmsTotal += parseFloat($('vlIcms_'+ft).value);
				}
			}
			var totalLiquidoProp = parseFloat(freteTotal) - parseFloat(icmsTotal) - parseFloat(totalSeguroProp) - parseFloat(totalDespViagemProp);
			var totalFreteCadastroProp = parseFloat(totalLiquidoProp * parseFloat(PercFreteCadastroProp) / 100);
			$('cartaValorFrete').value = formatoMoeda(totalFreteCadastroProp);
			$('valor_maximo_rota').value = formatoMoeda(totalFreteCadastroProp);
		}
		
		var freteCarreteiro = parseFloat($('cartaValorFrete').value);
		var freteOutros = parseFloat($('cartaOutros').value);
		var fretePedagio = parseFloat($('cartaPedagio').value);
		var valorTotalImpostos = 0;
		calculaImpostos();
		var valorTotalImpostos = $('cartaImpostos').value;

		// Calcular valor outras retenções
		var vlOutrosConfig = parseFloat(<%=cfg.getVlConMotor()%>);
		var tipoOutrosConfig = '<%=cfg.getTipoVlConMotor()%>';
		var vlOutrosMotorista = parseFloat($('mot_outros_descontos_carta').value);
		var valorOutrasRetencoes = 0;
		if (parseFloat(vlOutrosConfig) == 0 && parseFloat(vlOutrosMotorista) == 0){
			valorOutrasRetencoes = parseFloat($('cartaRetencoes').value);
		}else{
			if (tipoOutrosConfig == 'f'){
				valorOutrasRetencoes = parseFloat(vlOutrosConfig);
			}else{
				valorOutrasRetencoes = parseFloat(freteCarreteiro * vlOutrosConfig / 100);
			}
			valorOutrasRetencoes += parseFloat(freteCarreteiro * vlOutrosMotorista / 100);
		}
		
		var freteLiquido = parseFloat(freteCarreteiro + freteOutros + fretePedagio - valorTotalImpostos - valorOutrasRetencoes);
		
		$('cartaRetencoes').value = formatoMoeda(valorOutrasRetencoes);
		$('cartaLiquido').value = formatoMoeda(freteLiquido);
		
		//Dividindo os valores dos pagamentos
		$('cartaValorAdiantamento').value = formatoMoeda(parseFloat(freteLiquido) * parseFloat($('perc_adiant').value) / 100);
		var sld = parseFloat(freteLiquido) - parseFloat($('cartaValorAdiantamento').value);
		sld = parseFloat(sld) < 0 ? 0 : sld;
		
		//Verificando se vai descontar do conta corrente
		if (parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0 ){
			$('trCartaCC').style.display = '';
			var percentual_desconto = parseFloat($('percentual_desconto_prop').value);
			var vlCC = (sld == 0 ? 0 : parseFloat(parseFloat(percentual_desconto) * parseFloat(sld) / 100 ));
			if (parseFloat(vlCC) > parseFloat($('debito_prop').value)){
				vlCC = $('debito_prop').value;
			}
			sld = parseFloat(parseFloat(formatoMoeda(sld)) - parseFloat(formatoMoeda(vlCC)));
			$('cartaValorCC').value = formatoMoeda(vlCC);
		}else{
			$('trCartaCC').style.display = 'none';
			$('cartaValorCC').value = '0.00';
		}
	 
		$('cartaValorSaldo').value = formatoMoeda(parseFloat(sld));
		alteraFpag('s');
		
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
						var textoresposta = transport.responseText;
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
	
    function calculaImpostos(){
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
	
    function calculaInss(){
	
		var valorFrete= parseFloat($("cartaValorFrete").value);
        var percentualBase = parseFloat(<%=cfg.getInssAliqBaseCalculo()%>);
        var valorJaRetido = parseFloat($("inss_prop_retido").value);
        var teto = parseFloat(<%=cfg.getTetoInss()%>);

        var faixas = new Array();

        faixas[0] = new Faixa(0, <%=cfg.getInssAte()%>, <%=cfg.getInssAliqAte()%>);
        faixas[1] = new Faixa(<%=cfg.getInssDe1()%>, <%=cfg.getInssAte1()%>, <%=cfg.getInssAliq1()%>);
        faixas[2] = new Faixa(<%=cfg.getInssDe2()%>, <%=cfg.getInssAte2()%>, <%=cfg.getInssAliq2()%>);
        faixas[3] = new Faixa(<%=cfg.getInssDe3()%>, <%=cfg.getInssAte3()%>, <%=cfg.getInssAliq3()%>);
		var baseINSSJaRetida = $('base_inss_prop_retido').value;

        var inss = new Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseINSSJaRetida);

        $("baseINSS").value = formatoMoeda(inss.baseCalculo);
        $("aliqINSS").value = formatoMoeda(inss.aliquota);
        $("valorINSS").value = formatoMoeda(inss.valorFinal);

        return inss;
    }
	
    function calculaSest(baseCalculo){
		var aliquota = parseFloat(<%=cfg.getSestSenatAliq()%>);
        var sest = new Sest(baseCalculo, aliquota);
        $("baseSEST").value = formatoMoeda(sest.baseCalculo);
        $("aliqSEST").value = formatoMoeda(sest.aliquota);
        $("valorSEST").value = formatoMoeda(sest.valorFinal);

        return sest;
    }
	
    function calculaIR(inss){
        var percentualBase = parseFloat(<%=cfg.getIrAliqBaseCalculo()%>);
        var isDeduzirInssIr = '<%=cfg.isDeduzirINSSIR()%>';
        var faixas = new Array();
        faixas[0] = new Faixa(0, parseFloat(<%=cfg.getIrDe1()%>), 0, 0);
        faixas[1] = new Faixa(parseFloat(<%=cfg.getIrDe1()%>), parseFloat(<%=cfg.getIrAte1()%>), parseFloat(<%=cfg.getIrAliq1()%>), parseFloat(<%=cfg.getIrdeduzir1()%>));
        faixas[2] = new Faixa(parseFloat(<%=cfg.getIrDe2()%>), parseFloat(<%=cfg.getIrAte2()%>), parseFloat(<%=cfg.getIrAliq2()%>), parseFloat(<%=cfg.getIrDeduzir2()%>));
        faixas[3] = new Faixa(parseFloat(<%=cfg.getIrDe3()%>), parseFloat(<%=cfg.getIrAte3()%>), parseFloat(<%=cfg.getIrAliq3()%>), parseFloat(<%=cfg.getIrDeduzir3()%>));
        faixas[4] = new Faixa(parseFloat(<%=cfg.getIrAte3()%>), 99999999, parseFloat(<%=cfg.getIrAliqAcima()%>), parseFloat(<%=cfg.getIrdeduzirAcima()%>));
		var baseIRJaRetida = $('base_ir_prop_retido').value;
		var valorIRJaRetido = $('ir_prop_retido').value;
		
      	var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, 0, 0, false, isDeduzirInssIr);
        $("valorIR").value = formatoMoeda(ir.valorFinal);
        $("baseIR").value = formatoMoeda(ir.baseCalculo);
        $("aliqIR").value = formatoMoeda(ir.aliquota);
    }
	
var countDespesaCarta = 0;
function incluiDespesaCarta(){
    $("trDespesaCarta").style.display = "";
	var descricaoClassName = ((countDespesaCarta % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
	
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
    var fornDespCarta = Builder.node("INPUT",{type:"text",id:"fornDespCarta_"+countDespesaCarta, name:"fornDespCarta_"+countDespesaCarta, size:"27", maxLength:"60", value: "Fornecedor", className:"inputReadOnly8pt", readOnly:true});
    var btFornDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaFornecedorDesp_"+countDespesaCarta, name:"localizaFornecedorDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespForn.appendChild(idFornDespCarta);
    tdDespForn.appendChild(fornDespCarta);
    tdDespForn.appendChild(btFornDespCarta);
	
	//TD Plano
    var tdDespPlano = Builder.node("TD",{width:"45%"});
    var idPlanoDespCarta = Builder.node("INPUT",{type:"hidden",id:"idPlanoDespCarta_"+countDespesaCarta, name:"idPlanoDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
    var planoDespCarta = Builder.node("INPUT",{type:"text",id:"planoDespCarta_"+countDespesaCarta, name:"planoDespCarta_"+countDespesaCarta, size:"27", maxLength:"60", value: "Plano Custo", className:"inputReadOnly8pt", readOnly:true});
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
	<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
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

	countDespesaCarta++;
		
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
	
var countADV = 0;
function incluiADV(){
	var descricaoClassNameADV = ((countADV % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
	
    var trADV = Builder.node("TR",{name:"trADV_"+countADV, id:"trADV_"+countADV, className:descricaoClassNameADV});
	//TD Lixo
    var tdADVLixo = Builder.node("TD");
	var imgADVLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerADV("+countADV+");"});
    tdADVLixo.appendChild(imgADVLixo);
	
	//TD Valor
	var tdADVValor = Builder.node("TD");
    var vlADV = Builder.node("INPUT",{type:"text",id:"vlADV_"+countADV, name:"vlADV_"+countADV, size:"10", maxLength:"12", value: "0.00", className:"fieldmin", onchange: "seNaoFloatReset($('vlADV_"+countADV+"'), 0.00);calcularFreteCarreteiro();"});
    tdADVValor.appendChild(vlADV);
	
	//TD Conta
	var tdADVConta = Builder.node("TD");
    var contaADV = Builder.node("SELECT",{id:"contaADV_"+countADV, name:"contaADV_"+countADV, className:"fieldMin", style:"width:120px;", onChange:"getFpagADV("+countADV+");"});
	<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
		BeanConsultaConta contaAd = new BeanConsultaConta();
		contaAd.setConexao(Apoio.getUsuario(request).getConexao());
		contaAd.mostraContasViagem(0, limitarUsuarioVisualizarConta, idUsuario);
		ResultSet rsCADV = contaAd.getResultado();
		while (rsCADV.next()){
            if (rsCADV.getInt("idconta") != cfg.getConta_adiantamento_viagem_id().getIdConta()) {%>
				var optionContaADV = Builder.node("OPTION",{value:"<%=rsCADV.getString("idconta")%>"},"<%=rsCADV.getString("numero") +"-"+ rsCADV.getString("digito_conta") +" / "+ rsCADV.getString("banco")%>");
				contaADV.appendChild(optionContaADV);
		  <%}
		}rsCADV.close();
	}%>
    tdADVConta.appendChild(contaADV);
	
	//TD CHQ
	var tdADVChq = Builder.node("TD");
	var chqADV = Builder.node("INPUT",{type:"checkbox", id:"chqADV_"+countADV, name:"chqADV_"+countADV, onClick:"getFpagADV("+countADV+");"});
    var lbChqADV = Builder.node("LABEL",{id:"lbChqADV_"+countADV, name:"lbChqADV_"+countADV});
    tdADVChq.appendChild(chqADV);
    tdADVChq.appendChild(lbChqADV);
	
	//TD DOC
	var tdADVDoc = Builder.node("TD");
    var docADV = Builder.node("INPUT",{type:"text",id:"docADV_"+countADV, name:"docADV_"+countADV, size:"8", maxLength:"12", value: "", className:"fieldmin"});
    var docADV_cb = Builder.node("SELECT",{id:"docADV_cb_"+countADV, name:"docADV_cb_"+countADV, className:"fieldMin",style:"display:none;"});
    tdADVDoc.appendChild(docADV);
    tdADVDoc.appendChild(docADV_cb);
 	
    trADV.appendChild(tdADVLixo);
    trADV.appendChild(tdADVValor);
    trADV.appendChild(tdADVConta);
    trADV.appendChild(tdADVChq);
    trADV.appendChild(tdADVDoc);
    tbADV.appendChild(trADV);

	$('lbChqADV_'+countADV).innerHTML = 'Em Cheque';	
	
	countADV++;
}

function getFpagADV(idxADV){
	var isCheque = $('chqADV_'+idxADV).checked;
	$('docADV_'+idxADV).style.display = 'none';
	$('docADV_cb_'+idxADV).style.display = 'none';
	if (isCheque){
		if (<%=cfg.isControlarTalonario()%>){
			$('docADV_cb_'+idxADV).style.display = '';
			function e(transport){

				var textoresposta = transport.responseText;
                                carregarAjaxTalaoCheque(textoresposta, $('docADV_cb_'+idxADV));			
                            }//funcao e()

			tryRequestToServer(
				function(){
					new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaADV_'+idxADV).value,{method:'post', onSuccess: e, onError: e});
				}
			);
		}else{
			$('docADV_'+idxADV).style.display = '';
		}
	}else{
		$('docADV_'+idxADV).style.display = '';
	}
}

var countDespesaADV = 0;
function incluiDespesaADV(){
	var descricaoClassName = ((countDespesaADV % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
	
    var trDespADV = Builder.node("TR",{name:"trDespADV_"+countDespesaADV, id:"trDespADV_"+countDespesaADV, className:descricaoClassName});
	//TD Lixo
    var tdDespADVLixo = Builder.node("TD",{width:"2%"});
	var imgDespADVLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerDespCarta("+countDespesaADV+",false);"});
    tdDespADVLixo.appendChild(imgDespADVLixo);
	
	//TD Valor	
    var tdDespADVValor = Builder.node("TD",{width:"8%"});
    var vlDespADV = Builder.node("INPUT",{type:"text",id:"vlDespADV_"+countDespesaADV, name:"vlDespADV_"+countDespesaADV, size:"5", maxLength:"12", value: "0.00", className:"fieldmin", onchange: "seNaoFloatReset($('vlDespADV_"+countDespesaADV+"'), 0.00);calcularFreteCarreteiro();"});
    tdDespADVValor.appendChild(vlDespADV);
	
	//TD Fornecedor
    var tdDespFornADV = Builder.node("TD",{width:"45%"});
    var idFornDespADV = Builder.node("INPUT",{type:"hidden",id:"idFornDespADV_"+countDespesaADV, name:"idFornDespADV_"+countDespesaADV, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
    var fornDespADV = Builder.node("INPUT",{type:"text",id:"fornDespADV_"+countDespesaADV, name:"fornDespADV_"+countDespesaADV, size:"24", maxLength:"60", value: "Fornecedor", className:"inputReadOnly8pt", readOnly:true});
    var btFornDespADV = Builder.node("INPUT",{className:"botoes", id:"localizaFornecedorDespADV_"+countDespesaADV, name:"localizaFornecedorDespADV_"+countDespesaADV, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_ADV_"+countDespesaADV+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespFornADV.appendChild(idFornDespADV);
    tdDespFornADV.appendChild(fornDespADV);
    tdDespFornADV.appendChild(btFornDespADV);
	
	//TD Plano
    var tdDespPlanoADV = Builder.node("TD",{width:"45%"});
    var idPlanoDespADV = Builder.node("INPUT",{type:"hidden",id:"idPlanoDespADV_"+countDespesaADV, name:"idPlanoDespADV_"+countDespesaADV, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
    var planoDespADV = Builder.node("INPUT",{type:"text",id:"planoDespADV_"+countDespesaADV, name:"planoDespADV_"+countDespesaADV, size:"24", maxLength:"60", value: "Plano Custo", className:"inputReadOnly8pt", readOnly:true});
    var btPlanoDespADV = Builder.node("INPUT",{className:"botoes", id:"localizaPlanoDespADV_"+countDespesaADV, name:"localizaPlanoDespADV_"+countDespesaADV, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=20','Plano_ADV_"+countDespesaADV+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespPlanoADV.appendChild(idPlanoDespADV);
    tdDespPlanoADV.appendChild(planoDespADV);
    tdDespPlanoADV.appendChild(btPlanoDespADV);

    trDespADV.appendChild(tdDespADVLixo);
    trDespADV.appendChild(tdDespADVValor);
    trDespADV.appendChild(tdDespFornADV);
    trDespADV.appendChild(tdDespPlanoADV);
	
	$("tbDespesaADV").appendChild(trDespADV);
	
	countDespesaADV++;
		
}

function removerDespCarta(idxCarta, isCarta){ 
    if (isCarta){
		if (confirm("Deseja mesmo excluir esta despesa do contrato de frete?")){
			Element.remove('trDespCarta_'+idxCarta);
			Element.remove('trDespCarta2_'+idxCarta);
			calcularFreteCarreteiro();
		}	
	}else{
		if (confirm("Deseja mesmo excluir esta despesa do adiantamento de viagem?")){
			Element.remove('trDespADV_'+idxCarta);
			calcularFreteCarreteiro();
		}
	}
}

function removerADV(idxADV){
    if (confirm("Deseja mesmo excluir este adiantamento de viagem?")){
		Element.remove('trADV_'+idxADV);
		calcularFreteCarreteiro();
	}	
}

function iniciando(){
    getAliquotasIcmsAjax($('filialId').value);
    
    $("temPermissao_alterainffiscal").value = <%= Apoio.getUsuario(request).getAcesso("alterainffiscal") == 4 %>;
    $("temPermissao_alteraprecocte").value  = <%= Apoio.getUsuario(request).getAcesso("alteraprecocte") == 4 %>;
}


function localizarColeta(){
    if ($("idremetente").value != "" && $("idremetente").value != "0") {
        windowRemetente = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COLETA%>&paramaux='+$('idremetente').value, 'Coleta',
           'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
    }else{
        alert("ATENÇÃO: É preciso escolher um remetente antes de escolher uma coleta");
        return false;
    }
}


function getDadosIcms(idxIcms){
	var ufOrigemIcms = '';
	var ufDestinoIcms = '';
	var idCidadeDestinoCtrc = '';
	var inscEstDest = '';
        var tipoTributacao = "NI";
    if (getTipoMontagem()=='r'){
		ufOrigemIcms = $('uf_origem').value;
		ufDestinoIcms = $('ufCfopDest_'+idxIcms).value;
		idCidadeDestinoCtrc = $('idCidadeDest_'+idxIcms).value;
		inscEstDest = $('ieDest_'+idxIcms).value.trim();
                tipoTributacao = (($("tipo_frete_cif").checked) ? $("rem_tipo_tributacao").value : $("dest_tipo_tributacao_"+idxIcms).value);
	}else if (getTipoMontagem()=='d'){
		ufOrigemIcms = $('ufCfopDest_'+idxIcms).value;
		ufDestinoIcms = $('uf_destino').value;
		idCidadeDestinoCtrc = $('idcidadedestino').value;
		inscEstDest = $('dest_insc_est').value.trim();
                tipoTributacao = (($("tipo_frete_cif").checked) ? $("rem_tipo_tributacao_"+idxIcms).value : $("dest_tipo_tributacao").value);
	}else if (getTipoMontagem()=='v'){
		ufOrigemIcms = $('ufRem_'+idxIcms).value;
		ufDestinoIcms = $('ufCfopDest_'+idxIcms).value;
		idCidadeDestinoCtrc = $('idCidadeDest_'+idxIcms).value;
		inscEstDest = $('ieDest_'+idxIcms).value.trim();
	}
	var	isDestinatarioIsento = (inscEstDest == '' || inscEstDest == 'ISENTO' || inscEstDest == 'ISENTA');
	var tpTransporteIcms = 'r';
	var aliquotaIcmsJs = null;
        var tipoMontagem = getTipoMontagem();
        var ativarICMSGoias = ($("is_IN_GSF_1298_16_GO_"+$("filialId").value).value == "true" || $("is_IN_GSF_1298_16_GO_"+$("filialId").value).value == "t");
        var remetenteUf = (tipoMontagem == "r" ? $("ufRemetente").value : $('ufRem_'+idxIcms).value);
        var filialUf = $("uf_fl_"+$("filialId").value).value;
        var isCif = ($("tipo_frete_cif").checked);
	if (ufOrigemIcms != '' && ufDestinoIcms != ''){
            //(aliquotaIcmsJs.aliquotaAereoCpf == null || aliquotaIcmsJs.aliquotaAereoCpf == undefined ? aliquotaIcmsJs.aliquotaAereoPessoaFisica : aliquotaIcmsJs.aliquotaAereoCpf)
            //(aliquotaIcmsJs.aliqCpf == null || aliquotaIcmsJs.aliqCpf == undefined ? aliquotaIcmsJs.aliquotaPessoaFisica : aliquotaIcmsJs.aliqCpf)
            //(aliquotaIcmsJs.aliq == null || aliquotaIcmsJs.aliq == undefined ? aliquotaIcmsJs.aliquota : aliquotaIcmsJs.aliq)
		aliquotaIcmsJs = getUfAliquotaIcmsCtrc(ufOrigemIcms, ufDestinoIcms, idCidadeDestinoCtrc, undefined, tipoTributacao);
		//Verificando se o destinatário é ISENTO de IE
		if (aliquotaIcmsJs != null){
			if (tpTransporteIcms == 'a'){
				if (isDestinatarioIsento){
					$('vlAliqIcms_'+idxIcms).value = (aliquotaIcmsJs.aliquotaAereoCpf == null || aliquotaIcmsJs.aliquotaAereoCpf == undefined ? aliquotaIcmsJs.aliquotaAereoPessoaFisica : aliquotaIcmsJs.aliquotaAereoCpf);
				}else{
					$('vlAliqIcms_'+idxIcms).value = aliquotaIcmsJs.aliquotaAereo;
				}
			}else{
				if (isDestinatarioIsento){
					$('vlAliqIcms_'+idxIcms).value = (aliquotaIcmsJs.aliqCpf == null || aliquotaIcmsJs.aliqCpf == undefined ? aliquotaIcmsJs.aliquotaPessoaFisica : aliquotaIcmsJs.aliqCpf);
				}else{
					$('vlAliqIcms_'+idxIcms).value = (aliquotaIcmsJs.aliq == null || aliquotaIcmsJs.aliq == undefined ? aliquotaIcmsJs.aliquota : aliquotaIcmsJs.aliq);
				}

                                if(getObsClienteGenerico($("dest_obs_"+ idxIcms)) == ""){
                                    $('obs_desc').value = (aliquotaIcmsJs.obs.descricao == undefined ? '' : aliquotaIcmsJs.obs.descricao);
                                    $('obsLinha1_'+idxIcms).value = $('obs_desc').value.split("\n")[0] == undefined ? '' : $('obs_desc').value.split("\n")[0];
                                    $('obsLinha2_'+idxIcms).value = $('obs_desc').value.split("\n")[1] == undefined ? '' : $('obs_desc').value.split("\n")[1];
                                    $('obsLinha3_'+idxIcms).value = $('obs_desc').value.split("\n")[2] == undefined ? '' : $('obs_desc').value.split("\n")[2];
                                    $('obsLinha4_'+idxIcms).value = $('obs_desc').value.split("\n")[3] == undefined ? '' : $('obs_desc').value.split("\n")[3];
                                    $('obsLinha5_'+idxIcms).value = $('obs_desc').value.split("\n")[4] == undefined ? '' : $('obs_desc').value.split("\n")[4];
                                }
			}
                         $("stIcmsConfig_"+idxIcms).value = aliquotaIcmsJs.situacaoTributavel.id;
		}else{
			$('vlAliqIcms_'+idxIcms).value = '-1.00';
		}	
	}
        
        if (filialUf.toUpperCase() == "GO" && !ativarICMSGoias && remetenteUf.toUpperCase() == "GO"  && isCif) {
            $('vlAliqIcms_'+idxIcms).value = '0.00';
        }
	
}
function alterTipoTransporte(idFilial){
    $("serie").value = $("serie_padrao_cte_rodoviario_"+idFilial).value;
}
	
</script>

<html>
    <head>
        
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        
        <title>Webtrans - Montagem de carga</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">
		<style type="text/css">
			<!--
			.style1 {color: #990000}
			-->
		</style>
    </head>
    
    <body onLoad="javascript:iniciando();">
        <div align="center"><img src="img/banner.gif" alt="banner"><br>
			<table width="90%" height="28" align="center" class="bordaFina">
				<tr>
					<td width="86%" height="22"><b>Montagem de carga</b></td>
					<td width="14%"><b> 
						<input name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="voltar()"> </b>
					</td>
				</tr>
			</table>
            <input name="idmarca" id="idmarca" type="hidden" value="0">
            <input name="descricao" id="descricao" type="hidden" value="">

            <input name="idcfop" id="idcfop" type="hidden" value="0">
            <input name="cfop" id="cfop" type="hidden" value="">

		<input type="hidden" name="temPermissao_alteraprecocte" id="temPermissao_alteraprecocte" value="false">
		<input type="hidden" name="temPermissao_alterainffiscal" id="temPermissao_alterainffiscal" value="false">
                
		<input type="hidden" name="idnota_fiscal" id="idnota_fiscal" value="0">                
		<input type="hidden" name="numero_nf" id="numero_nf" value="">
		<input type="hidden" name="idcoleta_nota" id="idcoleta_nota" value="0">
		<input type="hidden" name="emissao_nota" id="emissao_nota" value="">
		<input type="hidden" name="emissao" id="emissao" value="">
		<input type="hidden" name="valor_nota" id="valor_nota" value="0">
		<input type="hidden" name="vl_base_icms" id="vl_base_icms" value="0">
		<input type="hidden" name="vl_icms_nota" id="vl_icms_nota" value="0">
		<input type="hidden" name="vl_icms_st" id="vl_icms_st" value="0">
		<input type="hidden" name="vl_icms_frete" id="vl_icms_frete" value="0">
		<input type="hidden" name="peso_nota" id="peso_nota" value="0">
		<input type="hidden" name="volume_nota" id="volume_nota" value="0">
		<input type="hidden" name="embalagem_nota" id="embalagem_nota" value="">
		<input type="hidden" name="conteudo_nota" id="conteudo_nota" value="">
		<input type="hidden" name="serie_nota" id="serie_nota" value="1">
		<input type="hidden" name="pedido_nota" id="pedido_nota" value="">
		<input type="hidden" name="altura_nota" id="altura_nota" value="0">
		<input type="hidden" name="largura_nota" id="largura_nota" value="0">
		<input type="hidden" name="comprimento_nota" id="comprimento_nota" value="0">
		<input type="hidden" name="metro_cubico_nota" id="metro_cubico_nota" value="0">
		<input type="hidden" name="marca_veiculo_id" id="marca_veiculo_id" value="0">
		<input type="hidden" name="marca_nf" id="marca_nf" value="">
		<input type="hidden" name="modelo_veiculo" id="modelo_veiculo" value="">
		<input type="hidden" name="ano_veiculo" id="ano_veiculo" value="">
		<input type="hidden" name="cor_veiculo" id="cor_veiculo" value="0">
		<input type="hidden" name="chassi_veiculo" id="chassi_veiculo" value="">
		<input type="hidden" name="cfop_id" id="cfop_id" value="">
		<input type="hidden" name="cfop_nf" id="cfop_nf" value="">
		<input type="hidden" name="chave_acesso" id="chave_acesso" value="">
		<input type="hidden" name="is_agendado" id="is_agendado" value="false">
		<input type="hidden" name="data_agenda" id="data_agenda" value="">
		<input type="hidden" name="hora_agenda" id="hora_agenda" value="">
		<input type="hidden" name="obs_agenda" id="obs_agenda" value="">
		<input type="hidden" name="nf_previsao_entrega" id="nf_previsao_entrega" value="">
		<input type="hidden" name="nf_previsao_entrega_as" id="nf_previsao_entrega_as" value="">
		<input type="hidden" name="nf_iddestinatario" id="nf_iddestinatario" value="">
		<input type="hidden" name="nf_destinatario" id="nf_destinatario" value="">
		<input type="hidden" name="is_importada_edi" id="is_importada_edi" value="false">
		<input type="hidden" name="max_itens_metro" id="max_itens_metro" value="0">
        
		<input type="hidden" name="id_und" id="id_und" value="0">
		<input type="hidden" name="sigla_und" id="sigla_und" value="">
		<input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
		<input type="hidden" name="plcusto_conta" id="plcusto_conta" value="">
		<input type="hidden" name="plcusto_descricao" id="plcusto_descricao" value="">
        
		<input type="hidden" name="idvenremetente" id="idvenremetente" value="0">
		<input type="hidden" name="venremetente" id="venremetente" value="">
		<input type="hidden" name="vlvenremetente" id="vlvenremetente" value="0">
                <input type="hidden" id="rem_unificada_modal_vendedor" value="">
		<input type="hidden" id="rem_comissao_rodoviario_fracionado_vendedor" value="">
		<input type="hidden" id="rem_comissao_rodoviario_lotacao_vendedor" value="">
		<input type="hidden" name="idvendestinatario" id="idvendestinatario" value="0">
		<input type="hidden" name="vendestinatario" id="vendestinatario" value="">
		<input type="hidden" name="vlvendestinatario" id="vlvendestinatario" value="0">
		<input type="hidden" id="des_unificada_modal_vendedor" value="">
		<input type="hidden" id="des_comissao_rodoviario_fracionado_vendedor" value="">
		<input type="hidden" id="des_comissao_rodoviario_lotacao_vendedor" value="">
                <input type="hidden" name="redspt_rzs" id="redspt_rzs" value="">
                <input type="hidden" name="idredespachante" id="idredespachante" value="0">
                <input type="hidden" name="redspt_vlsobpeso" id="redspt_vlsobpeso" value="0">
                <input type="hidden" name="redspt_vlfreteminimo" id="redspt_vlfreteminimo" value="0">
                <input type="hidden" name="redspt_vlsobfrete" id="redspt_vlsobfrete" value="0">               

<input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
        <input type="hidden"id="tipo_documento_padrao" value="">
	<input type="hidden" id="cidade_destino_id" name="cidade_destino_id" value="0">
        <input name="des_codigo" type="hidden" id="des_codigo" value="">
        <input name="dest_rzs" type="hidden" id="dest_rzs" value="">
        <input name="dest_cidade" type="hidden" id="dest_cidade" value="">
        <input name="dest_uf" type="hidden" id="dest_uf" value="">
        <input name="dest_cnpj" type="hidden" id="dest_cnpj" value="">
        <input name="aliquota" type="hidden" id="aliquota" value="0">
        <input name="obs_desc" type="hidden" id="obs_desc" value="">
        <input name="dest_obs" type="hidden" id="dest_obs" value="">
        <!-- Conteudo -->
        <input type="hidden" id="desc_prod" name="desc_prod" value="">
        
        <input type="hidden" name="tipoFreteTabela" id="tipoFreteTabela" value="">
        <input type="hidden" name="utilizaTipoFreteTabelaRem" id="utilizaTipoFreteTabelaRem" value="">
        <input type="hidden" name="utilizaTipoFreteTabelaDest" id="utilizaTipoFreteTabelaDest" value="">
        <input type="hidden" name="is_utilizar_tipo_frete_tabela" id="is_utilizar_tipo_frete_tabela" value="">
        
        <input type="hidden" name="st_icms" id="st_icms" value="0">
        <input type="hidden" name="stIcmsConfig" id="stIcmsConfig" value="0">
        <input type="hidden" name="stIcmsRem" id="stIcmsRem" value="0">
        <input type="hidden" name="stIcmsConsig" id="stIcmsConsig" value="0">
        <input type="hidden" name="maxCte" id="maxCte" value="1">
        <input type="hidden" name="tipo_arredondamento_peso_rem" id="tipo_arredondamento_peso_rem" value="">
        <input type="hidden" name="tipo_arredondamento_peso_dest" id="tipo_arredondamento_peso_dest" value="">
        <input type="hidden" name="tipo_arredondamento_peso" id="tipo_arredondamento_peso" value="">
        
        <input type="hidden" name="dest_tipo_tributacao" id="dest_tipo_tributacao" value="NI" >
        <input type="hidden" name="rem_tipo_tributacao" id="rem_tipo_tributacao" value="NI" >
        <input type="hidden" name="con_tipo_tributacao" id="con_tipo_tributacao" value="NI" > 
        
        <form id="formCtrc" name="formCtrc" method="post" action="./montar_carga.jsp?acao=salvar" target="pop">
        <input name="des_tipo_cfop" id="des_tipo_cfop" type="hidden" value="c">
        <input name="rem_tipo_cfop" id="rem_tipo_cfop" type="hidden" value="c">
       <!--coloquei as inscrições estaduais dentro do formctrc por conta da validação na ação de salvar onde faz o submit neste formulario e precisa destes valores - Daniel Cassimiro-->
        <input name="dest_insc_est" type="hidden" id="dest_insc_est" size="20" class="inputReadOnly8pt" value="">
        <input name="rem_insc_est" type="hidden" id="rem_insc_est" size="20" class="inputReadOnly8pt" value="">
            <table width="90%" border="1" cellspacing="0" cellpadding="0" class="bordaFina" align="center">
                <tr class="tabela">
                    <td height="18" colspan="7">
                        <div align="center">Dados da carga</div>
                        <div align="center"></div>                    </td>
                </tr>
                <tr>
                  <td colspan="6"><table width="100%" border="1" cellspacing="0" cellpadding="0">
                    <tr>
                      <td width="33%" class="TextoCampos"><div align="center">
                        <input name="tipoMontagem" type="radio" id="tipoMontagemRem" value="r" checked onClick="alteraTipoMontagem()">
                        <b>1 remetente para v&aacute;rios destinat&aacute;rios</b></div></td>
                      <td width="32%" class="TextoCampos"><div align="center">
                        <input type="radio" name="tipoMontagem" id="tipoMontagemDest" value="d" onClick="alteraTipoMontagem()">
                      <b>1 destinat&aacute;rio para v&aacute;rios remetentes</b></div></td>
                      <td width="35%" class="TextoCampos"><div align="center">
                        <input type="radio" name="tipoMontagem" id="tipoMontagemVarios" value="v" onClick="alteraTipoMontagem()">
                      <b>V&aacute;rios remetentes para v&aacute;rios destinat&aacute;rios</b></div></td>
                    </tr>
                  </table></td>
                </tr>
                <tr>
                    <td width="13%" class="TextoCampos">N&uacute;mero da carga:</td>
                    <td width="37%"  class="CelulaZebra2">
                        <input name="numeroCarga" type="text" class="fieldMin" id="numeroCarga" size="20" maxlength="20">
                        <input type="hidden" name="idtabela" id="idtabela" value="0">
                        <label class="TextoCampos">Tipo:</label>
                        <select name="tipoConhecimento" id="tipoConhecimento" style="font-size:8pt;width:50px;" class="fieldMin">
                            <option value="n" selected>Normal</option>
                            <option value="l">Distribuição Local</option>
                            <option value="c">Complementar</option>
                            <option value="r">Reentrega</option>
                            <option value="d">Devolução</option>
                            <option value="b">Cortesia</option>
                        </select>
                        <label class="TextoCampos">Tipo Serviço:</label>
                        <select name="tipoServico" id="tipoServico" style="font-size:8pt;width:60px;" class="fieldMin">
                            <option value="n" selected>Normal</option>
                            <option value="s">SubContratação</option>
                            <option value="r">Redespacho</option>
                            <option value="i">Redespacho Intermediário</option>
                            <option value="m">Multimodal</option>
                        </select>
                        <label class="TextoCampos">Filial:</label>
                                                <select name="filialId" id="filialId" class="fieldMin" style="width:60px;" onchange="getAliquotasIcmsAjax(this.value);alterTipoTransporte(this.value);localizaRemetenteCodigo();">
                            <%BeanFilial fl = new BeanFilial();
                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                            while (rsFl.next()) {
                            valoresMaximosFiliais += String.valueOf(rsFl.getDouble("valor_maximo_controle_manifesto")) + "!!";
                            idsFiliais += String.valueOf(rsFl.getInt("idfilial")) + "!!";
                            isAtivaValorMaximo += String.valueOf(rsFl.getBoolean("is_ativar_controle_valor_manifesto")) + "!!";
                            %>
                            <%if (nivelUserFl >= 3) {%>
                            <option value="<%=rsFl.getString("idfilial")%>"  
                                    <%=(Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%>                                    </option>
                            <%} else if (Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                            <option value="<%=rsFl.getString("idfilial")%>"  
                                    <%=(Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%>                                    </option>
                            <%}%>
                            <%}
                            rsFl.close();%>
                        </select>               
                        <input type="hidden" name="valoresMaxFiliais" id="valoresMaxFiliais" value="<%=valoresMaximosFiliais%>">
                        <input type="hidden" name="idsFiliais" id="idsFiliais" value="<%=idsFiliais%>">
                        <input type="hidden" name="ativarValorMaximoFiliais" id="ativarValorMaximoFiliais" value="<%=isAtivaValorMaximo%>">
                    </td>
                    <td width="8%" class="TextoCampos">Espécie:</td>
                    <td width="23%" class="CelulaZebra2">
                        <input name="especie" type="text" class="fieldMin" id="especie" style="font-size:8pt;" 
						value="<%=String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("H") || String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("P") ? "CTE" : "CTR"%>" size="2" maxlength="10">
                        Série:
                        <input name="serie" type="text" class="fieldMin" id="serie" style="font-size:8pt;" 
                               value="<%=String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("H") || String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("P") ? Apoio.getUsuario(request).getFilial().getSeriePadraoCTeRodoviario() : cfg.getSeriePadraoCtrc()%>" size="2" maxlength="10">
                        <%ResultSet rsFl2 = fl.all(Apoio.getUsuario(request).getConexao());
                        while (rsFl2.next()) {%>
                                <input type="hidden" name="uf_fl_<%=rsFl2.getString("idfilial")%>" id="uf_fl_<%=rsFl2.getString("idfilial")%>" value="<%=rsFl2.getString("uf_filial")%>">
                                <input type="hidden" name="is_IN_GSF_1298_16_GO_<%=rsFl2.getString("idfilial")%>" id="is_IN_GSF_1298_16_GO_<%=rsFl2.getString("idfilial")%>" value="<%=rsFl2.getString("is_IN_GSF_1298_16_GO")%>">
                                <input type="hidden" name="serie_padrao_cte_rodoviario_<%=rsFl2.getString("idfilial")%>" id="serie_padrao_cte_rodoviario_<%=rsFl2.getString("idfilial")%>" value="<%=rsFl2.getString("serie_padrao_cte_rodoviario")%>">
                        <%}rsFl2.close();%>
                        Nº Pedido:
                        <input name="numeroPedido" type="text" class="fieldMin" id="numeroPedido" size="10" maxlength="20">
                    </td>
                    <td width="5%" class="TextoCampos">Data:</td>
                    <td width="14%" class="CelulaZebra2"><input name="dtemissao" type="text" 
                                                                class="fieldDate" id="dtemissao" style="font-size:8pt;" onChange="javascript:if (alertInvalidDate(this)) parent.frameAbaixo.refazerDtsVenc();" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" <%=(nivelAlteraCtrc == 0 ? "readonly" : "")%>></td>
                </tr>
                <tr>
                    <td class="TextoCampos"><label id="lbRemetente" name="lbRemetente">Remetente:</label></td>
                    <td class="CelulaZebra2">
                        <input name="rem_codigo" type="hidden" id="rem_codigo" size="4" style="font-size:8pt">
                        <input type="hidden" id="rem_pgt" name="rem_pgt" value="0">
                        <input type="hidden" id="dest_pgt" name="dest_pgt" value="0">
                        <input name="des_codigo" type="hidden" id="des_codigo" size="4" style="font-size:8pt">
                        <input name="codigoRemetente" type="text" id="codigoRemetente" size="4" class="fieldMin" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo()" >
                        <input name="rem_rzs" type="hidden" id="rem_rzs" size="40" class="inputReadOnly8pt" readonly="true">
                        <input name="remetenteNome" type="text" id="remetenteNome" size="38" class="inputReadOnly8pt" readonly="true">
                        <input name="rem_obs" type="hidden" id="rem_obs" size="38" value="" />
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaremetente();">
                        <input type="hidden" id="tipoPadraoDocumento" value="">
                        <input type="hidden" name="idremetente" id="idremetente" value="0">
                        <input type="hidden" name="idredespacho" id="idredespacho" value="0">
                        <input name="red_rzs" type="hidden" id="red_rzs" size="40" value="">
                        <input type="hidden" name="idCliente" id="idCliente" value="0">
                        <input type="hidden" name="remTipoFpag" id="remTipoFpag" value="v">
					<input type="hidden" name="rem_st_mg" id="rem_st_mg" value="f">
                  <input type="hidden" name="rem_tipotaxa" id="rem_tipotaxa" value="">                    
                  <input type="hidden" name="dest_tipotaxa" id="dest_tipotaxa" value="">                  </td>
                    <td class="TextoCampos">Cidade/UF:</td>
                    <td class="CelulaZebra2">
                        <input name="rem_cidade" type="hidden" id="rem_cidade" size="25" style="font-size:8pt;background-color:#FFFFF1" readonly="true">
                        <input name="cidadeRemetente" type="text" id="cidadeRemetente" size="25" class="inputReadOnly8pt" readonly="true">
		<input name="ufRemetente" type="text" id="ufRemetente" size="1" class="inputReadOnly8pt" readonly>                                       <input name="rem_uf" type="hidden" id="rem_uf" size="2" class="inputReadOnly8pt" readonly>                    </td>
                    <td class="TextoCampos">CNPJ:</td>
                    <td class="CelulaZebra2">
                        <input name="rem_cnpj" type="hidden" id="rem_cnpj" size="18" style="font-size:8pt;background-color:#FFFFF1" readonly="true">        <input name="cnpjRemetente" type="text" id="cnpjRemetente" size="18" class="inputReadOnly8pt" readonly="true">            </td>
                </tr>
                <tr>
                   <td class="TextoCampos">Origem do frete: </td>
                    <td class="CelulaZebra2"><input name="cid_origem" type="text" id="cid_origem" size="25" class="inputReadOnly8pt" readonly="true">
                        <input name="uf_origem" type="text" id="uf_origem" size="1" class="inputReadOnly8pt" readonly="true">
                        <%if (nivelUserAlteraCidade == 4){%>
                            <input name="btn_origem"  type="button" class="botoes" id="btn_origem" onClick="localizaCidadeOrigem();" value="...">
                      <%}%>
                        <input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="0">                  
                        <input type="hidden" id="idCidadeRemetente" name="idCidadeRemetente" value="0">                    </td>
                    <td class="TextoCampos">Destino:</td>
                    <td class="CelulaZebra2">
						<input name="cid_destino" type="text" id="cid_destino" size="25" class="inputReadOnly8pt" readonly="true">
                        <input name="uf_destino" type="text" id="uf_destino" size="1" class="inputReadOnly8pt" readonly="true">
                        <%if (nivelUserAlteraCidade == 4){%>
                            <input name="btn_destino"  type="button" class="botoes" id="btn_destino" onClick="localizaCidadeDestino();" value="...">
                        <%}%>
						<input type="hidden" id="idcidadedestino" name="idcidadedestino" value="0">
					</td>
					<td class="TextoCampos">Rota:</td>
					<td class="CelulaZebra2"> 
						<input name="rota_viagem_real" type="text" id="rota_viagem_real" size="18" class="inputReadOnly8pt" readonly="true" value="">
						<input name="id_rota_viagem_real" type="hidden" id="id_rota_viagem_real" size="10" class="inputReadOnly8pt" readonly="true" value="0">
						<input name="rota_viagem" type="hidden" id="rota_viagem" size="18" class="inputReadOnly8pt" readonly="true" value="">
						<input name="id_rota_viagem" type="hidden" id="id_rota_viagem" size="10" class="inputReadOnly8pt" readonly="true" value="0">
					</td>
                </tr>
                <tr>
                  <td class="TextoCampos">Vendedor:</td>
                  <td class="CelulaZebra2"><input name="ven_rzs" class="inputReadOnly8pt" type="text" id="ven_rzs" size="40" readonly >
                    <strong>
                    <input name="localiza_vendedor" type="button" class="botoes" id="localiza_vendedor" value="..." 
		         onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Vendedor')">
                    <img src="img/borracha.gif" border="0" class="imagemLink" onClick="$('idvendedor').value = '0';$('ven_rzs').value = '';" align="absbottom"></strong>
                    		<input type="hidden" id="idvendedor" name="idvendedor" value="0"></td>
                  <td class="TextoCampos"><label style="display:<%=(nivelComissao == 0 ? "none" : "")%>;">Comiss&atilde;o:</label></td>
                  <td class="CelulaZebra2"><input name="comissaoVendedor" type="text" id="comissaoVendedor" class="fieldMin" style="display:<%=(nivelComissao == 0 ? "none" : "")%>;" onChange="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="6" 
		         maxlength="12">
                  %</td>
                  <td class="TextoCampos">Coleta:</td>
                  <td class="CelulaZebra2"><input name="numcoleta" type="text" id="numcoleta" size="6" readonly class="inputReadOnly8pt">
                    <strong>
                    <input name="localiza_coleta" type="button" class="botoes" id="localiza_coleta" value="..." 
		         onClick="localizarColeta();">
                    <img src="img/borracha.gif" border="0" class="imagemLink" onClick="$('idcoleta').value = '0';$('numcoleta').value = '';" align="absbottom">
                    <input type="hidden" id="idcoleta" name="idcoleta" value="0">
                  </strong></td>
                </tr>
                <tr>
                    <td colspan="6"><table width="100%"  border="1" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="13%" class="CelulaZebra2">
                                    <div align="center">
                                        <input name="tipo_frete" id="tipo_frete_cif" type="radio" value="cif" onClick="alterarTipoPagamento(this.value)" checked>
                                        CIF
                                        <input id="tipo_frete_fob" name="tipo_frete" type="radio" value="fob" onClick="alterarTipoPagamento(this.value)">
                                        FOB
                                    </div>
                                </td>
                                <td width="12%" class="TextoCampos">Tipo de produto: </td>
                                <td width="7%" class="CelulaZebra2"><span class="CelulaZebra2">
                                        <select name="tipoproduto" onChange="alteraTipoTaxa();"
                                                id="tipoproduto" class="fieldMin" style="width:80px;">
                                            <option value="0" selected>Nenhum</option>
                                            <%TipoProduto prod = new TipoProduto();
            ResultSet product_types = prod.all(Apoio.getConnectionFromUser(request),0,false,0);
            while (product_types.next()) {%>
                                            <option value="<%=product_types.getString("id")%>" style="background-color:#FFFFFF"> 
                                            <%=product_types.getString("descricao")%></option>
                                            <%}
            product_types.close();%>
                                        </select>
                                </span></td>
                                <td width="8%" class="TextoCampos">Tipo frete: </td>
                                <td width="12%" class="CelulaZebra2"><span class="CelulaZebra2">
  <select name="tipotaxa" id="tipotaxa" <%=!allowChangeTablePrice || Apoio.getUsuario(request).getAcesso("alteratipofretecte") < 4? "disabled='disabled'" : ""%>
                                                onChange="alteraTipoTaxa();" class="fieldMin">
                                            <option value="-1">--Selecione--</option>
                                            <option value="0">Peso/Kg</option>
                                            <option value="1">Peso/Cubagem</option>
                                            <option value="2">% Nota Fiscal</option>
                                            <option value="3">Combinado</option>
                                            <option value="4">Por Volume</option>
                                            <option value="5">Por Km</option>
                                        </select>
                                </span>
                                <label id='lbIdTabel' name='lbIdTabel' style="display:none;"></label></td>
                              <td width="10%" class="TextoCampos">Tipo ve&iacute;culo: </td>
      <td width="10%" class="CelulaZebra2"><select name="tipoveiculo" <%=!allowChangeTablePrice ? "disabled='disabled'" : ""%> id="tipoveiculo" class="fieldMin" onChange="alteraTipoTaxa();" style="width:80px;">
                                        <option value="-1">Nenhum</option>
                                        <%ConsultaTipo_veiculos tipo = new ConsultaTipo_veiculos();
            tipo.setConexao(Apoio.getUsuario(request).getConexao());
            tipo.mostraTipos(true, Apoio.parseInt("0")); //passando o id = 0 para no select funcionar da forma antiga, trazendo apenas os tipos tabelados - Historia 3231
            ResultSet rs = tipo.getResultado();
            while (rs.next()) {%>
                                        <option value="<%=rs.getString("id")%>" style="background-color:#FFFFFF"><%=rs.getString("descricao")%></option>
                <%}%>
                                </select></td>
                              <td width="12%" class="CelulaZebra2"><div align="center">
                                <input name="chk_incluir_icms" type="checkbox" id="chk_incluir_icms" value="checkbox" checked <%= (Apoio.getUsuario(request).getAcesso("alteraprecocte")  < 4 ? "disabled" : "") %> >
                                Incluir Icms </div></td>
                              <td width="8%" class="CelulaZebra2"><div align="right">Total KM:</div></td>
                              <td width="8%" class="CelulaZebra2"><input name="total_km" type="text" id="total_km" class="fieldMin" onBlur="javascript:seNaoIntReset(this,'0');alteraTipoTaxa();" value="0" size="7"
                                                                            maxlength="12"></td>
                      </tr>
                  </table></td>
                </tr>
                <tr>
                    <td colspan="6" class=""><table width="100%"  border="1" cellspacing="0" cellpadding="0">
                            <tr>
                                <td class="TextoCampos"  width="5%">Tarifa:</td>
                                <td class="CelulaZebra2" width="7%"><input name="valor_taxa_fixa" readonly type="text" id="valor_taxa_fixa" value="0.00" class="inputReadOnly8pt" size="7" 
                                                                            maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularTotal();"></td>
                                <td class="TextoCampos"  width="7%">Pedágio:</td>
                                <td class="CelulaZebra2" width="7%"><input name="valor_pedagio" readonly type="text" id="valor_pedagio" value="0.00" class="inputReadOnly8pt" size="7" 
                                                                            maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularTotal();"></td>
                                <td class="TextoCampos" width="7%">Outros:</td>
                              <td class="CelulaZebra2" width="7%"><input name="valor_outros" readonly type="text" id="valor_outros" value="0.00" class="inputReadOnly8pt" size="7" 
                                                                            maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularTotal();"></td>
                                <td width="7%" class="TextoCampos">SEC CAT: </td>
                                <td width="7%" class="CelulaZebra2"><input name="valor_sec_cat" readonly type="text" id="valor_sec_cat" value="0.00" class="inputReadOnly8pt" size="7" 
                                                                            maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularTotal();"></td>
                              <td class="TextoCampos" width="9%">Frete Peso: </td>
                                <td class="CelulaZebra2" width="7%"><input name="valor_frete_peso" readonly type="text" id="valor_frete_peso" value="0.00" class="inputReadOnly8pt" size="7" 
                                                                            maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularTotal();"></td>
                              <td class="TextoCampos" width="9%">Frete Valor:</td>
                                <td class="CelulaZebra2" width="7%"><input name="valor_frete_valor" readonly type="text" id="valor_frete_valor" value="0.00" class="inputReadOnly8pt" size="7" 
                                                                            maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularTotal();"></td>
                              <td width="5%" class="TextoCampos">Total:</td>
                                <td width="9%" class="CelulaZebra2"><input name="total_prestacao" type="text" id="total_prestacao" value="0.00" size="8" style="font-size:8pt;" class="inputReadOnly8pt" readonly></td>
                      </tr>
                  </table></td>
                </tr>
                <tr>
                    <td colspan="6">
						<table width="100%" border="1" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="10%" class="TextoCampos"><label id="lbTotalPeso" name="lbTotalPeso">Total Peso:</label></td>
                                <td width="10%" class="CelulaZebra2"><input name="total_peso" type="text" class="inputReadOnly8pt" id="total_peso" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="9"
                                                               maxlength="12" readonly></td>
                                <td width="10%" class="TextoCampos"><label id="lbTotalMerc" name="lbTotalMerc">Total Notas:</label></td>
                                <td width="10%" class="CelulaZebra2"><input name="total_mercadoria" type="text" class="inputReadOnly8pt" id="total_mercadoria" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="9"
                                                              maxlength="12" readonly></td>
                                <td width="10%" class="TextoCampos">Total Volumes: </td>
                                <td width="10%" class="CelulaZebra2"><input name="total_volume" type="text" class="inputReadOnly" id="total_volume" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="7"
                                                                maxlength="12" readonly></td>
                                <td width="10%" class="TextoCampos">Total M&sup3;: </td>
                                <td width="10%" class="CelulaZebra2"><input name="total_cubagem" type="text" class="inputReadOnly" id="total_cubagem" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00" size="7"
                                                                maxlength="12" readonly></td>
                                <td width="10%" class="TextoCampos">Total Entregas: </td>
                                <td width="10%" class="CelulaZebra2"><input name="total_entregas" type="text" class="inputReadOnly" id="total_entregas" style="font-size:8pt;" value="0" size="7"
                                                                maxlength="12" readonly></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="6">
                        <table width="100%" border="1" cellspacing="0" cellpadding="0">
                            <tr>
								<td width="10%" class="TextoCampos">Ratear:</td>
								<td width="40%" class="TextoCampos"><div align="left">
									<input name="chk_ratearFrete2" type="checkbox" id="chk_ratearFrete" value="checkbox" checked>Frete Peso
									<input name="chk_ratearOutros" type="checkbox" id="chk_ratearOutros" value="checkbox" checked>Valor Outros
									<input name="chk_ratearSec" type="checkbox" id="chk_ratearSec" value="checkbox" checked>SEC CAT
									<input name="chk_ratearPedagio" type="checkbox" id="chk_ratearPedagio" value="checkbox" checked>Pedágio</div></td>
								<td width="15%" class="TextoCampos">Ao ratear considerar:</td>
								<td width="35%" class="TextoCampos"><div align="left">
									<input name="tipo_rateio" id="peso" type="radio" value="peso" onClick="" checked>Peso
									<input name="tipo_rateio" id="mercadoria" type="radio" value="mercadoria" onClick="">Valor da nota
									<input id="volume" name="tipo_rateio" type="radio" value="volume" onClick="">Volumes
									<input id="cubagem" name="tipo_rateio" type="radio" value="cubagem" onClick="">M³
								</div></td>
                            </tr>
                        </table>
                    </td>
                </tr>
			</table>
				<br>
				<div id="container" style="width:90%" align="center">
					<div align="center">
						<ul id="tabs">
							<li>
								<a href="#tab1" ><strong>Dados dos CTRCs</strong></a>
							</li>
							<li>
								<a href="#tab2" ><strong>Dados Container</strong></a>
							</li>
							<li>
								<a href="#tab3" ><strong>Dados da entrega<%=(cfg.isCartaFreteAutomatica()?"/Contrato de frete":"")%></strong></a>
							</li>
						</ul>
					</div>
					<div class="panel" id="tab1">
						<fieldset>
							<table width="100%" border="1" cellspacing="0" cellpadding="0" class="bordaFina" align="center">
								<tbody id="tDestinatario" name="tDestinatario">
                                                                        <tr class="tabela">
                                                                            <td width="2%" id="btlocalizadest" name="btlocalizadest"><img src="img/add.gif" border="0" title="Adicionar um destinatário" class="imagemLink" onClick="javascript:localizadestinatario();"></td>
                                                                            <td colspan="8"></td>
                                                                        </tr>
									<tr class="tabela" name="trCab_0" id="trCab_0">
                                                                                <td width="2%" id="btlocalizadest" name="btlocalizadest"></td>
										<td width="25%" id="tddest" name="tddest_0"><label id="lbDest" name="lbDest">Destinat&aacute;rio</label></td>
										<td width="18%" id="tdcid" name="tdcid_0">Cidade/UF</td>
										<td width="16%" id="tdcnpj" name="tdcnpj_0">CNPJ / CPF </td>
										<td width="7%" id="tdvalor" name="tdvalor_0">Valor NF</td>
										<td width="7%" id="tdpeso" name="tdpeso_0">Peso</td>
										<td width="7%" id="tdvol" name="tdvol_0">Volumes</td>
										<td width="10%" id="tdgerar" name="tdgerar_0">Gerar</td>
										<td width="8%" id="tdblank" name="tdblank_0">&nbsp;</td>
									</tr>
								</tbody>
							</table>
						</fieldset>
					</div>	
					<div class="panel" id="tab2">
						<fieldset>
							<table width="100%" border="1" cellspacing="0" cellpadding="0" class="bordaFina" align="center">
								<tr>
									<td width="8%" class="TextoCampos">Container:</td>
									<td width="12%" class="CelulaZebra2"><input name="numero_container" type="text" id="numero_container" value="" size="12" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
									<td width="7%" class="TextoCampos">Tipo:</td>
									<td width="9%" class="CelulaZebra2">
                                        <select name="tipo_container" id="tipo_container" style="font-size:8pt;width:'80px';" class="fieldMin">
                                            <option value="0" selected>Selecione</option>
                                            <%ConsultaTipoContainer tpContainer = new ConsultaTipoContainer();
                                            tpContainer.setConexao(Apoio.getUsuario(request).getConexao());
                                            tpContainer.MostrarTudo();
                                            ResultSet rsTp = tpContainer.getResultado();
                                            while (rsTp.next()) {%>
                                                <option value="<%=rsTp.getString("id")%>" style="background-color:#FFFFFF"><%=rsTp.getString("descricao")%></option>
											<%}rsTp.close();%>
                                        </select>
									</td>
									<td width="9%" class="TextoCampos">GENSET:</td>
									<td width="12%" class="CelulaZebra2"><input name="genset" type="text" id="genset" value="" size="12" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
									<td width="9%" class="TextoCampos">Lacre:</td>
									<td width="11%" class="CelulaZebra2"><input name="lacre_container" type="text" id="lacre_container" value="" size="10" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
									<td width="9%" class="TextoCampos">Booking:</td>
									<td width="14%" class="CelulaZebra2"><input name="booking" type="text" id="booking" value="" size="13" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
								</tr>
								<tr>
									<td class="TextoCampos">Navio:</td>
									<td colspan="3" class="CelulaZebra2"><input name="navio" type="text" class="inputReadOnly" id="navio" size="20" value="" style="font-size:8pt;">
										<input name="idnavio" type="hidden" class="inputReadOnly" id="idnavio" value="0">
										<input name="button5" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=53','Navio')" value="...">
										<strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Navio" onClick="javascript:getObj('idnavio').value = '0';javascript:getObj('navio').value = '';"></strong>
									</td>
									<td class="TextoCampos">N&ordm; Viagem:</td>
									<td class="CelulaZebra2"><input name="viagem_container" type="text" id="viagem_container" value="" size="7" maxlength="10" style="font-size:8pt;" class="fieldMin"></td>
									<td class="TextoCampos">Terminal:</td>
									<td colspan="3" class="CelulaZebra2"><input name="terminal" type="text" class="inputReadOnly" id="terminal" size="20" value="" style="font-size:8pt;">
										<input name="idterminal" type="hidden" class="inputReadOnly" id="idterminal" value="0">
										<input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=54','Terminal')" value="...">
										<strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Armador" onClick="javascript:getObj('idterminal').value = '0';javascript:getObj('terminal').value = '';"></strong>
									</td>
								</tr>
								<tr>
									<td class="TextoCampos">Armador:</td>
									<td colspan="4" class="CelulaZebra2"><input name="armador" type="text" class="inputReadOnly" id="armador" size="35" value="" style="font-size:8pt;">
										<input name="idarmador" type="hidden" class="inputReadOnly" id="idarmador" value="0">
										<input name="button2" type="button" class="botoes" onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=52','Armador')" value="...">
										<strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Armador" onClick="javascript:getObj('idarmador').value = '0';javascript:getObj('armador').value = '';"></strong>
									</td>
									<td class="CelulaZebra2">&nbsp;</td>
									<td class="TextoCampos">Peso:</td>
									<td class="CelulaZebra2">
										<input name="peso_container" type="text" id="peso_container" style="font-size:8pt;" value="0.000" size="8" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.000');" class="fieldMin" >
									</td>
									<td class="TextoCampos">Valor:</td>
									<td class="CelulaZebra2">
										<input name="valor_container" type="text" id="valor_container" style="font-size:8pt;" value="0.00" size="8" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');" class="fieldMin" >
									</td> 
								</tr>
							</table>
						</fieldset>
					</div>	
					<div class="panel" id="tab3">
						<fieldset>
							<table width="100%" border="1" cellspacing="0" cellpadding="0" class="bordaFina" align="center">
								<tr class="tabela">
									<td><div align="center">Dados da entrega</div></td>
								</tr>
								<tr>
									<td class="CelulaZebra2" style="display:<%=cfg.isCartaFreteAutomatica() ? "" : "none" %>">
										<input name="chk_viagem_2" type="checkbox" id="chk_viagem_2" onClick="calcularFreteCarreteiroRota();calcularFreteCarreteiro();" value="checkbox">2ª viagem do dia
									</td>
								</tr>
								<tr>
									<td>
										<table width="100%" border="1" cellspacing="0" cellpadding="0">
											<tr>
												<td width="8%" class="TextoCampos">Motorista:</td>
												<td width="29%" class="CelulaZebra2">
													<input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" value="" size="33"  readonly="true">
													<input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&paramaux=carta&paramaux2='+($('tipoproduto').value == 0 ? ' is null ' : ' = ' + $('tipoproduto').value )+'&paramaux3='+$('id_rota_viagem_real').value+'&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista');" style="font-size:8pt;">
													<img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';"></td>
													<input type="hidden" name="idmotorista" id="idmotorista" value="0">
													<input type="hidden" name="tipo" id="tipo" value="">
													<input type="hidden" id="impedir_viagem_motorista" name="impedir_viagem_motorista" value="f">
													<input type="hidden" name="idproprietarioveiculo" id="idproprietarioveiculo" value="0">
													<input type="hidden" name="perc_adiant" id="perc_adiant" value="0">
													<input type="hidden" name="is_tac" id="is_tac" value="f">
												<td width="6%" class="TextoCampos">Ve&iacute;culo:</td>
												<td width="15%" class="CelulaZebra2">
													<input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" value="" size="10" readonly="true">
													<input name="localiza_cavalo" type="button" class="botoes" id="localiza_cavalo" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&paramaux2='+($('tipoproduto').value == 0 ? ' is null ' : ' = ' + $('tipoproduto').value )+'&paramaux3='+$('id_rota_viagem_real').value+'&idlista=<%=BeanLocaliza.VEICULO%>', 'Veiculo');" style="font-size:8pt;">
													<input type="hidden" name="idveiculo" id="idveiculo" value="0">
													<input type="hidden" name="is_obriga_carreta" id="is_obriga_carreta" value="f">
													<strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';"></strong>
												</td>
												<td width="6%" class="TextoCampos">Carreta:</td>
												<td width="15%" class="CelulaZebra2"><strong>
													<input name="car_placa" type="text" id="car_placa" class="inputReadOnly8pt" value="" size="10" readonly="true">
													<input type="hidden" name="idcarreta" id="idcarreta" value="0">
													<input name="localiza_carreta" type="button" class="botoes" id="localiza_carreta" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&paramaux2='+($('tipoproduto').value == 0 ? ' is null ' : ' = ' + $('tipoproduto').value )+'&paramaux3='+$('id_rota_viagem_real').value+'&idlista=<%=BeanLocaliza.CARRETA%>', 'Carreta');" style="font-size:8pt;">
													<img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="javascript:getObj('idcarreta').value = 0;javascript:getObj('car_placa').value = '';">
												</td>
												<td width="6%" class="TextoCampos">Bi-trem:</td>
												<td width="15%" class="CelulaZebra2">
													<input name="bi_placa" type="text" id="bi_placa" class="inputReadOnly8pt" value="" size="9" readonly="true">
													<input type="hidden" name="idbitrem" id="idbitrem" value="0">
													<input name="localiza_bitrem" type="button" class="botoes" id="localiza_bitrem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.BITREM%>', 'BiTrem');" style="font-size:8pt;">
													<img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="javascript:getObj('idbitrem').value = 0;javascript:getObj('bi_placa').value = '';">
												</td>
											</tr>
										</table>
										<table width="100%" border="1" cellspacing="0" cellpadding="0">
											<tr>
												<td>
													<table width="100%" border="0" cellpadding="0" cellspacing="1">
														<tr style="display:<%=cfg.isCartaFreteAutomatica() ? "" : "none" %>">
															<td width="100%" colspan="6" >
																<table width="100%"  border="0" cellspacing="1" cellpadding="2">
																	<tr>
																		<td colspan="2" class="tabela">
																			<div align="center">
																				<input name="chk_carta_automatica" type="checkbox" id="chk_carta_automatica" value="checkbox"> Gerar Contrato de Frete com o Proprietário
																			</div>
																		</td>
																		<td colspan="2" class="tabela">
																			<div align="center">
																				<input name="chk_adv_automatica" type="checkbox" id="chk_adv_automatica" value="checkbox"> Gerar Adiantamento de viagem para o motorista da casa
																			</div>
																		</td>
																	</tr>
																	<tr>
																		<td width="10%" class="TextoCampos">Proprietário:</td>
																		<td width="40%" class="CelulaZebra2">
																			<input name="vei_prop" type="text" id="vei_prop" class="inputReadOnly8pt" size="40" readonly="true" value="">
																			<input name="vei_prop_cgc" type="text" id="vei_prop_cgc" class="inputReadOnly8pt" size="20" readonly="true" value="">
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
																			<input name="inss_prop_retido" type="hidden" id="inss_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
																		</td>
																		<td width="50%" colspan="2" rowspan="5" style="vertical-align:top;">
																			<table width="100%" border="0" cellspacing="1" cellpadding="2">
																				<tbody id="tbADV">
																					<tr class="celula">
																						<td width="3%" ><img src="img/add.gif" border="0" onClick="incluiADV();" title="Adicionar um adiantamento para o motorista" class="imagemLink"></td>
																						<td width="19%" ><div align="center">Valor</div></td>
																						<td width="35%" ><div align="center">Conta</div></td>
																						<td width="23%" ></td>
																						<td width="20%" ><div align="center">Doc</div></td>
																					</tr>
																				</tbody>
                                                                                                                                                                <tr>
                                                                                                                                                                    <td colspan="4" class="TextoCampos">
                                                                                                                                                                        Valor Previsto para as Despesas de Viagem: 
                                                                                                                                                                    </td>
                                                                                                                                                                    <td class="CelulaZebra2">
                                                                                                                                                                        <input name="valorPrevistoViagem" type="text" class="fieldmin" id="valorPrevistoViagem" value="0.00" size="8" maxlength="12" onchange="seNaoFloatReset(this, '0.00');">
                                                                                                                                                                    </td>
                                                                                                                                                                </tr>
																				<tr class="celula">
																					<td ><img src="img/add.gif" border="0" onClick="incluiDespesaADV();" title="Adicionar despesa a prazo para o adiantamento de viagem" class="imagemLink"></td>
																					<td colspan="4">Despesas de viagem</td>
																				</tr>
																				<tr>
																					<td colspan="5">
																						<table width="100%" border="0" cellspacing="1" cellpadding="2">
																							<tbody id="tbDespesaADV">
																							</tbody>
																						</table>
																					</td>
																				</tr>		
																			</table>
																		</td>
																	</tr>
																	<tr>
																		<td class="TextoCampos">Seguradora:</td>
																		<td class="CelulaZebra2">
																			<input name="nome_seguradora" type="text" id="nome_seguradora" class="inputReadOnly8pt" size="27" readonly="true" value="">
																			<input name="localiza_seguradora" type="button" class="botoes" id="localiza_seguradora" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=57','Seguradora','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
																			Liberação:<input name="motor_liberacao" type="text" id="motor_liberacao" class="fieldMin" size="15" value="">
																			<input name="seguradora_id" type="hidden" id="seguradora_id" class="inputReadOnly8pt" size="20" readonly="true" value="0">
																		</td>
																	</tr>
																	<tr>
																		<td colSpan="2">
																			<table width="100%" border="0" cellspacing="1" cellpadding="2">
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
																			</table>
																		</td>
																	</tr>	
																	<tr>
																		<td colspan="2">
																			<table width="100%" border="0" cellspacing="1" cellpadding="2">
																				<tr class="Celula">
																					<td width="16%" >Frete</td>
																					<td width="16%" >Outros</td>
																					<td width="16%" >Pedágio</td>
																					<td width="21%" class="style1"><input name="chk_reter_impostos" type="checkbox" id="chk_reter_impostos" value="checkbox" onClick="calcularFreteCarreteiro();"> Impostos</td>
																					<td width="16%" class="style1" >Desconto</td>
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
																						<input name="cartaRetencoes" type="text" id="cartaRetencoes" value="0.00" size="8" maxlength="12" class="fieldMin style1" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">
																						<input name="mot_outros_descontos_carta" type="hidden" id="mot_outros_descontos_carta" value="0.00" size="8" maxlength="12">
																					</td>
																					<td class="CelulaZebra2"><input name="cartaLiquido" type="text" id="cartaLiquido" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt" readonly onBlur="javascript:seNaoFloatReset(this,'0.00');"></td>
																				</tr>
																				<tr id="trImpostosCarta" name="trImpostosCarta" style="display:none;">
																					<td class="TextoCampos">INSS:</td>
																					<td class="CelulaZebra2">
																						<input name="valorINSS" type="text" id="valorINSS" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
																						<input name="baseINSS" type="hidden" id="baseINSS" value="0.00" size="8" maxlength="12">
																						<input name="aliqINSS" type="hidden" id="aliqINSS" value="0.00" size="8" maxlength="12">
																					</td>
																					<td class="TextoCampos">SEST:</td>
																					<td class="CelulaZebra2">
																						<input name="valorSEST" type="text" id="valorSEST" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
																						<input name="baseSEST" type="hidden" id="baseSEST" value="0.00" size="8" maxlength="12">
																						<input name="aliqSEST" type="hidden" id="aliqSEST" value="0.00" size="8" maxlength="12">
																					</td>
																					<td class="TextoCampos">IR:</td>
																					<td class="CelulaZebra2">
																						<input name="valorIR" type="text" id="valorIR" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
																						<input name="baseIR" type="hidden" id="baseIR" value="0.00" size="8" maxlength="12">
																						<input name="aliqIR" type="hidden" id="aliqIR" value="0.00" size="8" maxlength="12">
																					</td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																	<tr>
																		<td colspan="2">
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
																					<td class="TextoCampos"><input name="cartaValorAdiantamento" type="text" id="cartaValorAdiantamento" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('a');"></td>
																					<td class="TextoCampos"><input name="cartaDataAdiantamento" type="text" id="cartaDataAdiantamento" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onChange="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
																					<td class="TextoCampos">
																						<select name="cartaFPagAdiantamento" id="cartaFPagAdiantamento" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('a');">
																							<%if (acao.equals("iniciar")){
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
																							<%if (acao.equals("iniciar")){
																								BeanConsultaConta contaAd = new BeanConsultaConta();
																								contaAd.setConexao(Apoio.getUsuario(request).getConexao());
																								contaAd.mostraContas(0, true, limitarUsuarioVisualizarConta, idUsuario);
																								ResultSet rsC = contaAd.getResultado();
																								while (rsC.next()){%>
																									<option value="<%=rsC.getString("idconta")%>"><%=rsC.getString("numero") +"-"+ rsC.getString("digito_conta") +" / "+ rsC.getString("banco")%></option>
																								<%}rsC.close();
																							}%>
																						</select>
																						<input name="agente" type="text" id="agente" class="inputReadOnly8pt" size="15" readonly="true" value="" style="display:none;">
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
																							<%if (acao.equals("iniciar")){%>
																								<%=fpagCartaFrete%>
																							<%}%>
																						</select>
																					</td>
																					<td class="TextoCampos">
																						<input name="agentesaldo" type="text" id="agentesaldo" class="inputReadOnly8pt" size="15" readonly="true" value="" style="display:none;">
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
																	<tr>
																		<td colspan="2">
																			<table width="100%" border="0" cellspacing="1" cellpadding="2">
																				<tr class="celula">
																					<td width="5%">
																						<img src="img/add.gif" border="0" onClick="incluiDespesaCarta();" title="Adicionar uma despesa" class="imagemLink">
																					</td>
																					<td colspan="5" width="95%">Despesas de viagem</td>
																				</tr>
																				<tr id="trDespesaCarta" name="trDespesaCarta" style="display:none;" >
																					<td colspan="6">
																						<input name="fornecedor" type="hidden" id="fornecedor" class="inputReadOnly8pt" size="15" readonly="true" value="Fornecedor">
																						<input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
																						<input name="idplanocusto_despesa" type="hidden" id="idplanocusto_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="0">
																						<input name="plcusto_descricao_despesa" type="hidden" id="plcusto_descricao_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
																						<input name="plcusto_conta_despesa" type="hidden" id="plcusto_conta_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
																						<input name="idplcustopadrao" type="hidden" id="idplcustopadrao" class="inputReadOnly8pt" size="25" readonly="true" value="0">
																						<input name="descricaoplcusto" type="hidden" id="descricaoplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
																						<input name="contaplcusto" type="hidden" id="contaplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
																						<table width="100%">
																							<tbody id="tbDespesaCarta">
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
													</table></td>
												</tr>
											<tr> 
										</table>
									</td>
								</tr>
							</table>
						</fieldset>
					</div>
				</div>

	</form>    
        <% if (nivelUser >= 2) {%> 
        <table width="90%" border="0" class="bordaFina" align="center">
            <tr>
                <td width="100%" class="TextoCampos">
                    <div align="center">
                        <input name="baixar" type="button"
                               class="botoes" id="baixar" value="Salvar"
                               onclick="javascript:tryRequestToServer(function(){salvar();});">
                    </div>
                </td>
            </tr>
        </table>
        <%}%>
        </div>
        <br>
        
    </body>
</html>