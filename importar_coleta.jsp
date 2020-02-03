<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="br.com.gwsistemas.exception.ExcecaoConsultaSituacao"%>
<%@page import="java.io.File"%>
<%@page import="br.com.gwsistemas.consultarSituacao.imagem.InfoImagem"%>
<%@page import="br.com.gwsistemas.consultarSituacao.imagem.RetornoConsultaImagem"%>
<%@page import="br.com.gwsistemas.consultarSituacao.EnvioConsultaSituacao"%>
<%@page import="br.com.gwsistemas.consultarSituacao.nfe.ConsultaSituacaoNfe"%>
<%@page import="conhecimento.orcamento.Cubagem"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.coleta.*,
         java.text.*,
         com.sagat.bean.*,
         java.util.*,
         filial.*,
         nucleo.Apoio"
         %>
<%
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);


    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser <= 2)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }


    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    ConsultaSituacaoNfe comNFe;
    EnvioConsultaSituacao envio;
    String diretorio = "img/captcha/";
    String rotina = "importarColeta";
    String usuario = "Usu" + Apoio.getUsuario(request).getLogin();
    
    BeanConfiguracao cfg = (BeanConfiguracao) request.getSession().getServletContext().getAttribute("configuracao");

    if (acao.equals("iniciarConsultarNFe")) {
        String nomeImagem = "captchaConsultaNFe_" + rotina + "_" + usuario + "_" + Apoio.getFormatData(new Date(), "yyyy_MM_dd_HH_mm_ss") + ".png";
        String repositorioImg = diretorio + nomeImagem;
//        BeanConfiguracao cfg = (BeanConfiguracao) request.getSession().getServletContext().getAttribute("configuracao");
        comNFe = new ConsultaSituacaoNfe();
        RetornoConsultaImagem retImg;
        InfoImagem infImg;
        File img;
        String json = "";

        try {
            String path = ((String) request.getSession().getAttribute("dir_home"));
            File dir = new File(path.replace("/", File.separator) + diretorio.replace("/", File.separator));
            if (dir.isDirectory() && !dir.exists()) {
                dir.mkdir();
            }else if(dir.isDirectory()){
                for(File f : dir.listFiles()){
                    if (f.getName().indexOf(rotina) > -1 && f.getName().indexOf(usuario) > -1) {
                        f.delete();
                    }
                }
            }
            envio = new EnvioConsultaSituacao(path + repositorioImg.replace("/", File.separator));
//            retImg = (RetornoConsultaImagem) comNFe.createCaptcha(envio);
            retImg = null;
            infImg = (InfoImagem) retImg.getInfRet();
            img = infImg.getFile();

            request.setAttribute("comNFe", comNFe);
            request.setAttribute("envioComNFe", envio);

            json = repositorioImg;
        } catch (Exception ex) {
            json = "ERRO:Não foi possivel gerar a imagem.";
            ex.printStackTrace();
        } finally {
            if (response.getWriter() != null) {
                response.getWriter().append(json);
                response.getWriter().flush();
                response.getWriter().close();
            }
        }
    }

    if (acao.equals("importar")) {
        int qtdColetas = Apoio.parseInt(request.getParameter("qtdColetas"));
        int qtdNotas = Apoio.parseInt(request.getParameter("qtdNotas"));
        BeanCadColeta cadCol = new BeanCadColeta();
        cadCol.setConexao(Apoio.getUsuario(request).getConexao());
        cadCol.setExecutor(Apoio.getUsuario(request));
        BeanColeta col;
        BeanColeta arCols[] = new BeanColeta[qtdColetas + 1];
        String layout = request.getParameter("layout");
            col = new BeanColeta();
          if(request.getParameter("layoutImp").equals("cargasnet")){
                for (int x = 1; x <= qtdColetas; x++) {
                    col = new BeanColeta();
                    col.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("filialId")));
                    
                    col.setSolicitadaEm(Apoio.paraDate(request.getParameter("solicitadaEm_"+x)));
                    col.setColetaEm(Apoio.paraDate(request.getParameter("solicitadaEm_"+x)));
                    col.setPrevisaoEm(Apoio.paraDate(request.getParameter("solicitadaEm_"+x)));
                    col.setCategoria("co");
                    col.getCidadeDestino().setIdcidade((request.getParameter("cidadeDestino_" + x) == null ? 0 : Apoio.parseInt(request.getParameter("cidadeDestino_" + x).replace("  ", ""))));                  
                    col.setObs((request.getParameter("obs_" + x) == null ? "" : request.getParameter("obs_" + x).replace("  ", "")));
                    col.getCliente().setIdcliente(0);
                    col.getCliente().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("cidadeOrigem_" + x)));
                    col.getCliente().setEndereco("");
                    col.setValorCombinado((request.getParameter("valorFrete_" + x) == null ? 0 : Float.parseFloat(request.getParameter("valorFrete_" + x))));
                    col.setLocalColeta("");
                    
                    col.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo_"+x)));
                    col.getMotorista().setIdmotorista(Apoio.parseInt(request.getParameter("idMotorista_"+x)));
                    col.getDestinatario().setIdcliente(0);
                    col.getDestinatario().setInscest("ISENTO");
                    col.getDestinatario().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("cidadeDestino_" + x)));
                    col.getCliente().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("cidadeOrigem_" + x)));
                    arCols[x] = col;
             
                }
                cadCol.setArrayColetas(arCols);
                
            
        }else if(layout==null || layout.equals("")){   
            for (int x = 0; x <= qtdColetas; x++) {
                
                if (request.getParameter("idRemetente_" + x) != null && !request.getParameter("idCidadeDestinatario_" + x).equals("0") && !request.getParameter("idCidadeDestinatario_" + x).equals("")) {
                    if (request.getParameter("nfExiste_" + x) == null || request.getParameter("nfExiste_" + x).equals("NAO")) {
                        col = new BeanColeta();
                        //Dados da coleta
                        col.setId(0);
                        col.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
                        col.setSolicitadaEm(new Date());
                        //foi comentado pois esta lançando a coleta para poder ser realizada, não pode colocar a data da coleta realizada, pois ainda não foi feita - Cassimiro
//                        col.setColetaEm(new Date());
                        col.setPrevisaoEm(new Date());
                        col.setNumero("");
                        col.setPedidoCliente("");
                        col.setCategoria("co");

                        col.setObs((request.getParameter("observacaoColeta_" + x) == null ? "" : request.getParameter("observacaoColeta_" + x).replace("  ", "")));
                        col.setLocalColeta((request.getParameter("localDestino_" + x) == null ? "" : request.getParameter("localDestino_" + x)));
                        col.setEnderecoEntrega((request.getParameter("localEntrega_" + x) == null ? "" : request.getParameter("localEntrega_" + x)));
                        col.setBairroEntrega((request.getParameter("bairroDestino_" + x) == null ? "" : request.getParameter("bairroDestino_" + x).replace("  ", "")));
                        col.getCidadeDestino().setIdcidade((request.getParameter("idCidadeDestino_" + x) == null ? 0 : Apoio.parseInt(request.getParameter("idCidadeDestino_" + x).replace("  ", ""))));
                        
                        //Dados do CONSIGNATARIO
                        if (request.getParameter("idConsignatario_" + x) != null) {
                            col.setClientePagador("c");
                            col.getConsignatario().setIdcliente(Apoio.parseInt(request.getParameter("idConsignatario_" + x)));
                            col.getConsignatario().setRazaosocial(request.getParameter("nomeConsignatario_" + x).trim());
                            col.getConsignatario().setNomefantasia(request.getParameter("nomeConsignatario_" + x).trim());
                            col.getConsignatario().setCnpj(request.getParameter("cgcConsignatario_" + x));
                            col.getTransportador().setIdcliente(Apoio.parseInt(request.getParameter("idTransportadora_" + x)));
                            col.getTerminal().setId(Apoio.parseInt(request.getParameter("idTerminal_" + x)));
    //                        col.getConsignatario().setEndereco(request.getParameter("enderecoConsignatario_" + x).trim());
    //                        col.getConsignatario().setBairro(request.getParameter("bairroConsignatario_" + x).trim());
    //                        col.getConsignatario().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeConsignatario_" + x)));
    //                        col.getConsignatario().setInscest(request.getParameter("ieConsignatario_" + x).trim());
                        }
                        //Dados do cliente
                        
                        col.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idRemetente_" + x)));
                        col.getCliente().setRazaosocial(request.getParameter("nomeRemetente_" + x).trim());
                        col.getCliente().setNomefantasia(request.getParameter("nomeRemetente_" + x).trim());
                        col.getCliente().setEndereco(request.getParameter("enderecoRemetente_" + x).trim());
                        col.getCliente().setBairro(request.getParameter("bairroRemetente_" + x).trim());
                        col.getCliente().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeRemetente_" + x)));
                        col.getCliente().setCnpj(request.getParameter("cgcRemetente_" + x));
                        col.getCliente().setInscest(request.getParameter("ieRemetente_" + x).trim());
                        //Dados do destinatário
                        col.setDestinatario(null);
                        if (request.getParameter("idDestinatario_" + x) != null && !request.getParameter("idDestinatario_" + x).equals("0")) {
                            col.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("idDestinatario_" + x)));
                            col.getDestinatario().setRazaosocial(request.getParameter("nomeDestinatario_" + x).trim());
                            col.getDestinatario().setNomefantasia(request.getParameter("nomeDestinatario_" + x).trim());
                            col.getDestinatario().setEndereco(request.getParameter("enderecoDestinatario_" + x).trim());
                            col.getDestinatario().setNumeroLogradouro((request.getParameter("numeroEnderecoDestinatario_" + x) == null ? "" : request.getParameter("numeroEnderecoDestinatario_" + x).trim()));
                            col.getDestinatario().setCep((request.getParameter("cepDestinatario_" + x) == null ? "" : request.getParameter("cepDestinatario_" + x).trim()));
                            col.getDestinatario().setBairro(request.getParameter("bairroDestinatario_" + x).trim());
                            col.getDestinatario().setFone(request.getParameter("foneDestinatario_" + x) == null ? "" : request.getParameter("foneDestinatario_" + x).replace(" ", ""));
                            col.getDestinatario().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeDestinatario_" + x)));
                            col.getDestinatario().setTipocgc(request.getParameter("tipoDestinatario_" + x));
                            //            col.getDestinatario().setCep(request.getParameter("cepDestinatario_"+x));
                            col.getDestinatario().setCnpj(request.getParameter("cgcDestinatario_" + x).trim());
                            col.getDestinatario().setInscest(request.getParameter("ieDestinatario_" + x).trim());
                        }
                        col.setValorCombinado((request.getParameter("valorFrete_" + x) == null ? 0 : Float.parseFloat(request.getParameter("valorFrete_" + x))));
                        if(request.getParameter("qtdNotasColeta_"+x) != null){
                            qtdNotas = Apoio.parseInt(request.getParameter("qtdNotasColeta_"+x));
                        }
                        NotaFiscal arNf[] = new NotaFiscal[qtdNotas];
                        NotaFiscal nf;
                        for (int y = 0; y <= qtdNotas; y++) {
                            if (request.getParameter("container_" + x + "_" + y) != null){
                                col.setPedidoCliente(request.getParameter("pedido_" + x + "_" + y));
                                col.setNumeroContainer(request.getParameter("container_" + x + "_" + y));
                                col.setValorContainer(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                                col.setPesoContainer(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                                col.setNumeroLacre((request.getParameter("numeroLacre_" + x + "_" + y)));
                                col.getNavio().setId(Apoio.parseInt(request.getParameter("navio_" + x + "_" + y)));                           
                                col.setNumeroBooking((request.getParameter("numeroBooking_" + x + "_" + y)));
                                col.getTipoContainer().setId(Apoio.parseInt(request.getParameter("idContainer_" + x + "_" + y)));
                            }
                            if (request.getParameter("nf_" + x + "_" + y) != null && !request.getParameter("nf_" + x + "_" + y).equals("")) {
                                //Dados da coleta
                                col.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("destino_" + x + "_" + y)));
                                col.setClientePagador((request.getParameter("frete_" + x + "_" + y).equals("CIF") ? "r" : "d"));
                                nf = new NotaFiscal();
                                nf.setIdnotafiscal(0);
                                nf.setNumero(request.getParameter("nf_" + x + "_" + y));
                                nf.setTipoDocumento("NF");
                                if (request.getParameter("chave_nf_" + x + "_" + y) != null && !request.getParameter("chave_nf_" + x + "_" + y).trim().equals("")){
                                    nf.setChaveNFe(request.getParameter("chave_nf_" + x + "_" + y));
                                    nf.setTipoDocumento("NE");

                                }
                                nf.setSerie(request.getParameter("serie_" + x + "_" + y));
                                nf.setEmissao(Apoio.paraDate(request.getParameter("emissao_" + x + "_" + y)));
                                nf.setValor(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                                nf.setVl_base_icms(0);
                                nf.setVl_icms(0);
                                nf.setVl_icms_frete(0);
                                nf.setVl_icms_st(0);
                                if (request.getParameter("cfopNF_" + x + "_" + y) != null) {
                                    nf.getCfop().setIdcfop(Integer.parseInt(request.getParameter("cfopNF_" + x + "_" + y)));
                                }
                                if (request.getParameter("chaveNFe_" + x + "_" + y) != null) {
                                    nf.setChaveNFe(request.getParameter("chaveNFe_" + x + "_" + y));
                                }

                                nf.setPeso(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                                nf.setVolume(Float.parseFloat(request.getParameter("volume_" + x + "_" + y)));

                                if (request.getParameter("qtdCubagens_" + x + "_" + y) != null) {
                                    nf.setComprimento(0);
                                    nf.setLargura(0);
                                    nf.setAltura(0);
                                    int qtdCubagens = Integer.parseInt(request.getParameter("qtdCubagens_" + x + "_" + y));
                                    float metroCubicoTotal = 0;
                                    nf.setCubagens(new Cubagem[qtdCubagens]);
                                    for (int t = 1; t <= qtdCubagens; t++) {
                                        double volume = 1;
                                        double comprimento = Double.parseDouble(request.getParameter("comprimentoNF_" + x + "_" + y + "_" + t));
                                        double largura = Double.parseDouble(request.getParameter("larguraNF_" + x + "_" + y + "_" + t));
                                        double altura = Double.parseDouble(request.getParameter("alturaNF_" + x + "_" + y + "_" + t));
                                        double metroCubico = (Apoio.toFixedMed(volume * comprimento * largura * altura, 3));
                                        nf.getCubagens()[t - 1] = new Cubagem();
                                        nf.getCubagens()[t - 1].setVolume(volume);
                                        nf.getCubagens()[t - 1].setComprimento(comprimento);
                                        nf.getCubagens()[t - 1].setLargura(largura);
                                        nf.getCubagens()[t - 1].setAltura(altura);
                                        nf.getCubagens()[t - 1].setMetroCubico(metroCubico);
                                        metroCubicoTotal += metroCubico;
                                    }
                                    nf.setMetroCubico(metroCubicoTotal);
                                }
                                nf.setEmbalagem("");
                                nf.setConteudo("");
                                nf.setPedido(request.getParameter("pedido_" + x + "_" + y));
                                nf.setDataAgenda(null);
                                nf.setPrevisaoEm(null);
                                nf.setImportadaEdi(true);

                                arNf[y] = nf;
                            }
                            col.setNotaFiscal(arNf);
                        }
                        arCols[x] = col;
                    }
                }
                if (request.getParameter("layoutSocen") != null && request.getParameter("layoutSocen").equals("socen")) {
                
                 if ((request.getParameter("tipo_" + x) != null && request.getParameter("tipo_" + x).equals("C")) 
                         && request.getParameter("idRemetente_" + x) != null 
                         || request.getParameter("tipo_" + x) != null && request.getParameter("tipo_" + x).equals("E") 
                         && request.getParameter("idRemetente_" + x) != null 
                         && !request.getParameter("idCidadeDestinatario_" + x).equals("0") 
                         && !request.getParameter("idCidadeDestinatario_" + x).equals("")) {
                         
                    if (request.getParameter("nfExiste_" + x) == null || request.getParameter("nfExiste_" + x).equals("NAO")) {
                        col = new BeanColeta();
                        //Dados da coleta
                        col.setId(0);
                        col.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
                        col.setSolicitadaEm(new Date());
                        //foi comentado pois esta lançando a coleta para poder ser realizada, não pode colocar a data da coleta realizada, pois ainda não foi feita - Cassimiro
//                        col.setColetaEm(new Date());
                        col.setPrevisaoEm(new Date());
                        col.setNumero("");
                        col.setPedidoCliente("");
                        col.setCategoria("co");

                        col.setObs((request.getParameter("observacaoColeta_" + x) == null ? "" : request.getParameter("observacaoColeta_" + x).replace("  ", "")));
                        col.setLocalColeta((request.getParameter("localDestino_" + x) == null ? "" : request.getParameter("localDestino_" + x)));
                        col.setEnderecoEntrega((request.getParameter("localEntrega_" + x) == null ? "" : request.getParameter("localEntrega_" + x)));
                        col.setBairroEntrega((request.getParameter("bairroDestino_" + x) == null ? "" : request.getParameter("bairroDestino_" + x).replace("  ", "")));
                        col.getCidadeDestino().setIdcidade((request.getParameter("idCidadeDestino_" + x) == null ? 0 : Apoio.parseInt(request.getParameter("idCidadeDestino_" + x).replace("  ", ""))));
                        
                        //Dados do CONSIGNATARIO
                        //Nesse layout não se faz necessário o consignatario, validei se ele vem zero também, por que pra esse layout 
                        //se vinher zero ele passa pelo if abaixo e dar erro no cadastrarVarios no BeanCadColeta, informa que precisa ser cadastrado um consignatário.
                        if (request.getParameter("idConsignatario_" + x) != null && !request.getParameter("idConsignatario_" + x).equals("0")) {
                            col.setClientePagador("c");
                            col.getConsignatario().setIdcliente(Apoio.parseInt(request.getParameter("idConsignatario_" + x)));
                            col.getConsignatario().setRazaosocial(request.getParameter("nomeConsignatario_" + x).trim());
                            col.getConsignatario().setNomefantasia(request.getParameter("nomeConsignatario_" + x).trim());
                            col.getConsignatario().setCnpj(request.getParameter("cgcConsignatario_" + x));
                            col.getTransportador().setIdcliente(Apoio.parseInt(request.getParameter("idTransportadora_" + x)));
                            col.getTerminal().setId(Apoio.parseInt(request.getParameter("idTerminal_" + x)));
    //                        col.getConsignatario().setEndereco(request.getParameter("enderecoConsignatario_" + x).trim());
    //                        col.getConsignatario().setBairro(request.getParameter("bairroConsignatario_" + x).trim());
    //                        col.getConsignatario().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeConsignatario_" + x)));
    //                        col.getConsignatario().setInscest(request.getParameter("ieConsignatario_" + x).trim());
                        }
                        //Dados do cliente
                        
                        col.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idRemetente_" + x)));
                        col.getCliente().setRazaosocial(request.getParameter("nomeRemetente_" + x).trim());
                        col.getCliente().setNomefantasia(request.getParameter("nomeRemetente_" + x).trim());
                        col.getCliente().setEndereco(request.getParameter("enderecoRemetente_" + x).trim());
                        col.getCliente().setBairro(request.getParameter("bairroRemetente_" + x).trim());
                        col.getCliente().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeRemetente_" + x)));
                        col.getCliente().setCnpj(request.getParameter("cgcRemetente_" + x));
                        col.getCliente().setInscest(request.getParameter("ieRemetente_" + x).trim());
                        //Dados do destinatário
                        col.setDestinatario(null);
                        if (request.getParameter("idDestinatario_" + x) != null && !request.getParameter("idDestinatario_" + x).equals("0")) {
                            col.getDestinatario().setIdcliente(Apoio.parseInt(request.getParameter("idDestinatario_" + x)));
                            col.getDestinatario().setRazaosocial(request.getParameter("nomeDestinatario_" + x).trim());
                            col.getDestinatario().setNomefantasia(request.getParameter("nomeDestinatario_" + x).trim());
                            col.getDestinatario().setEndereco(request.getParameter("enderecoDestinatario_" + x).trim());
                            col.getDestinatario().setNumeroLogradouro((request.getParameter("numeroEnderecoDestinatario_" + x) == null ? "" : request.getParameter("numeroEnderecoDestinatario_" + x).trim()));
                            col.getDestinatario().setCep((request.getParameter("cepDestinatario_" + x) == null ? "" : request.getParameter("cepDestinatario_" + x).trim()));
                            col.getDestinatario().setBairro(request.getParameter("bairroDestinatario_" + x).trim());
                            col.getDestinatario().setFone(request.getParameter("foneDestinatario_" + x) == null ? "" : request.getParameter("foneDestinatario_" + x).replace(" ", ""));
                            col.getDestinatario().getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeDestinatario_" + x)));
                            col.getDestinatario().setTipocgc(request.getParameter("tipoDestinatario_" + x));
                            //            col.getDestinatario().setCep(request.getParameter("cepDestinatario_"+x));
                            col.getDestinatario().setCnpj(request.getParameter("cgcDestinatario_" + x).trim());
                            col.getDestinatario().setInscest(request.getParameter("ieDestinatario_" + x).trim());
                        }
                        col.setValorCombinado((request.getParameter("valorFrete_" + x) == null ? 0 : Float.parseFloat(request.getParameter("valorFrete_" + x))));
                        if(request.getParameter("qtdNotasColeta_"+x) != null){
                            qtdNotas = Apoio.parseInt(request.getParameter("qtdNotasColeta_"+x));
                        }
                        NotaFiscal arNf[] = new NotaFiscal[qtdNotas];
                        NotaFiscal nf;
                        for (int y = 0; y <= qtdNotas; y++) {
                            if (request.getParameter("container_" + x + "_" + y) != null){
                                col.setPedidoCliente(request.getParameter("pedido_" + x + "_" + y));
                                col.setNumeroContainer(request.getParameter("container_" + x + "_" + y));
                                col.setValorContainer(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                                col.setPesoContainer(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                                col.setNumeroLacre((request.getParameter("numeroLacre_" + x + "_" + y)));
                                col.getNavio().setId(Apoio.parseInt(request.getParameter("navio_" + x + "_" + y)));                           
                                col.setNumeroBooking((request.getParameter("numeroBooking_" + x + "_" + y)));
                                col.getTipoContainer().setId(Apoio.parseInt(request.getParameter("idContainer_" + x + "_" + y)));
                            }
                            if (request.getParameter("nf_" + x + "_" + y) != null && !request.getParameter("nf_" + x + "_" + y).equals("")) {
                                //Dados da coleta
                                col.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("destino_" + x + "_" + y)));
                                col.setClientePagador((request.getParameter("frete_" + x + "_" + y).equals("CIF") ? "r" : "d"));
                                nf = new NotaFiscal();
                                nf.setIdnotafiscal(0);
                                nf.setNumero(request.getParameter("nf_" + x + "_" + y));
                                nf.setTipoDocumento("NF");
                                if (request.getParameter("chave_nf_" + x + "_" + y) != null && !request.getParameter("chave_nf_" + x + "_" + y).trim().equals("")){
                                    nf.setChaveNFe(request.getParameter("chave_nf_" + x + "_" + y));
                                    nf.setTipoDocumento("NE");

                                }
                                nf.setSerie(request.getParameter("serie_" + x + "_" + y));
                                nf.setEmissao(Apoio.paraDate(request.getParameter("emissao_" + x + "_" + y)));
                                nf.setValor(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                                nf.setVl_base_icms(0);
                                nf.setVl_icms(0);
                                nf.setVl_icms_frete(0);
                                nf.setVl_icms_st(0);
                                if (request.getParameter("cfopNF_" + x + "_" + y) != null) {
                                    nf.getCfop().setIdcfop(Integer.parseInt(request.getParameter("cfopNF_" + x + "_" + y)));
                                }
                                if (request.getParameter("chaveNFe_" + x + "_" + y) != null) {
                                    nf.setChaveNFe(request.getParameter("chaveNFe_" + x + "_" + y));
                                }

                                nf.setPeso(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                                nf.setVolume(Float.parseFloat(request.getParameter("volume_" + x + "_" + y)));

                                if (request.getParameter("qtdCubagens_" + x + "_" + y) != null) {
                                    nf.setComprimento(0);
                                    nf.setLargura(0);
                                    nf.setAltura(0);
                                    int qtdCubagens = Integer.parseInt(request.getParameter("qtdCubagens_" + x + "_" + y));
                                    float metroCubicoTotal = 0;
                                    nf.setCubagens(new Cubagem[qtdCubagens]);
                                    for (int t = 1; t <= qtdCubagens; t++) {
                                        double volume = 1;
                                        double comprimento = Double.parseDouble(request.getParameter("comprimentoNF_" + x + "_" + y + "_" + t));
                                        double largura = Double.parseDouble(request.getParameter("larguraNF_" + x + "_" + y + "_" + t));
                                        double altura = Double.parseDouble(request.getParameter("alturaNF_" + x + "_" + y + "_" + t));
                                        double metroCubico = (Apoio.toFixedMed(volume * comprimento * largura * altura, 3));
                                        nf.getCubagens()[t - 1] = new Cubagem();
                                        nf.getCubagens()[t - 1].setVolume(volume);
                                        nf.getCubagens()[t - 1].setComprimento(comprimento);
                                        nf.getCubagens()[t - 1].setLargura(largura);
                                        nf.getCubagens()[t - 1].setAltura(altura);
                                        nf.getCubagens()[t - 1].setMetroCubico(metroCubico);
                                        metroCubicoTotal += metroCubico;
                                    }
                                    nf.setMetroCubico(metroCubicoTotal);
                                }
                                nf.setEmbalagem("");
                                nf.setConteudo("");
                                nf.setPedido(request.getParameter("pedido_" + x + "_" + y));
                                nf.setDataAgenda(null);
                                nf.setPrevisaoEm(null);
                                nf.setImportadaEdi(true);

                                arNf[y] = nf;
                            }
                            col.setNotaFiscal(arNf);
                        }
                        arCols[x] = col;
                    }
                  }
                }
                cadCol.setArrayColetas(arCols);
            }
        }

        boolean salvou = false;
        salvou = cadCol.incluirVarias(Apoio.getConfiguracao(request));
        if (!salvou) {
            String erro = "";
            if(cadCol.getErros().contains("nota_fiscal_remcliente")){
                erro = "Atenção! Remetente da coleta ainda não foi cadastrado!";
            }else if(cadCol.getErros().contains("un_nota_fiscal")){
                erro = "Atenção! Nota fiscal da coleta já cadastrada!";
            }else{
                erro = cadCol.getErros();
            }
            response.getWriter().append("<script>alert('" + erro + "');window.close();</script>");
        } else {
            String scr = "";
            scr = "<script>";
            scr += "window.opener.document.location.replace('ConsultaControlador?codTela=24');"
                    + "window.close();"
                    + "</script>";
            response.getWriter().append(scr);
        }
        response.getWriter().close();
    } else if (acao.equals("importar_notas")) {
        
        int qtdColetas = Integer.parseInt(request.getParameter("qtdColetas"));
        int qtdNotas = Integer.parseInt(request.getParameter("qtdNotas"));
        String nomeDestinatario = null;
        CadNotaFiscal cadNota = new CadNotaFiscal();
        cadNota.setConexao(Apoio.getUsuario(request).getConexao());
        cadNota.setExecutor(Apoio.getUsuario(request));
        NotaFiscal nf;
        
        NotaFiscal arNFs[] = new NotaFiscal[qtdNotas + 1];
        for (int x = 0; x <= qtdColetas; x++) {
            for (int y = 0; y <= qtdNotas; y++) {
                if (request.getParameter("importar_" + x + "_" + y) != null) {
                    nomeDestinatario = request.getParameter("nomeDestinatario_" + x).replace("  ", "");
                    nf = new NotaFiscal();
                    nf.setIdnotafiscal(0);
                    nf.setNumero(request.getParameter("nf_" + x + "_" + y));
                    nf.getRemetente().setIdcliente(Integer.parseInt(request.getParameter("idRemetente_" + x)));
                    nf.setSerie(request.getParameter("serie_" + x + "_" + y));
                    nf.setEmissao(Apoio.paraDate(request.getParameter("emissao_" + x + "_" + y)));
                    nf.setValor(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                    nf.setVl_base_icms(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                    nf.setVl_icms(0);
                    nf.setVl_icms_frete(0);
                    nf.setVl_icms_st(0);
                    nf.getCfop().setIdcfop(Integer.parseInt(request.getParameter("cfopNF_" + x + "_" + y)));
                    nf.setPeso(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                    nf.setVolume(Float.parseFloat(request.getParameter("volume_" + x + "_" + y)));
                    nf.setEmbalagem(request.getParameter("embalagem_" + x + "_" + y));
                    nf.setConteudo(request.getParameter("natureza_" + x + "_" + y));
                    nf.setPedido(request.getParameter("pedido_" + x + "_" + y));
                    nf.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("idDestinatario_" + x)));
                    nf.getDestinatario().setRazaosocial(nomeDestinatario.substring(0, (nomeDestinatario.length() > 49 ? 50 : (nomeDestinatario.length() - 1))));
                    nf.getDestinatario().setNomefantasia(request.getParameter("nomeDestinatario_" + x).replace("  ", ""));
                    nf.getDestinatario().setEndereco(request.getParameter("enderecoDestinatario_" + x).replace("  ", ""));
                    nf.getDestinatario().setNumeroLogradouro((request.getParameter("numeroEnderecoDestinatario_" + x) == null ? "" : request.getParameter("numeroEnderecoDestinatario_" + x).replace("  ", "")));
                    nf.getDestinatario().setCep((request.getParameter("cepDestinatario_" + x) == null ? "" : request.getParameter("cepDestinatario_" + x).replace("  ", "")));
                    nf.getDestinatario().setBairro(request.getParameter("bairroDestinatario_" + x).replace("  ", ""));
                    nf.getDestinatario().setFone(request.getParameter("foneDestinatario_" + x).replace(" ", ""));
                    nf.getDestinatario().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeDestinatario_" + x)));
                    nf.getDestinatario().setTipocgc(request.getParameter("tipoDestinatario_" + x));
                    nf.getDestinatario().setCnpj(request.getParameter("cgcDestinatario_" + x).replace("  ", ""));
                    nf.getDestinatario().setInscest(request.getParameter("ieDestinatario_" + x).replace("  ", ""));
                    nf.setImportadaEdi(true);
                    nf.setTipoDocumento("NF");
                    if (request.getParameter("chave_nf_" + x + "_" + y) != null && !request.getParameter("chave_nf_" + x + "_" + y).trim().equals("")){
                        nf.setChaveNFe(request.getParameter("chave_nf_" + x + "_" + y));
                        nf.setTipoDocumento("NE");
                    }
                    arNFs[y] = nf;
                }
                cadNota.setArrayNotas(arNFs);
            }
        }

        boolean salvou = false;
        salvou = cadNota.incluirVarias();
        if (!salvou) {
            response.getWriter().append("<script>alert('" + cadNota.getErros() + "');window.close();</script>");
        } else {
            String scr = "";
            scr = "<script>";
            scr += "window.opener.document.location.replace('ConsultaControlador?codTela=24');"
                    + "window.close();"
                    + "</script>";
            response.getWriter().append(scr);
        }
        response.getWriter().close();
    } else if (acao.equals("importar_roca")) {
        
        
        int qtdColetas = Integer.parseInt(request.getParameter("qtdColetas"));
        int qtdNotas = Integer.parseInt(request.getParameter("qtdNotas"));
        BeanCadColeta cadCol = new BeanCadColeta();
        cadCol.setConexao(Apoio.getUsuario(request).getConexao());
        cadCol.setExecutor(Apoio.getUsuario(request));
        BeanColeta col;
        BeanColeta arCols[] = new BeanColeta[qtdColetas + 1];
        for (int x = 0; x <= qtdColetas; x++) {
            if (request.getParameter("idRemetente_" + x) != null) {
                //Verificando se o destinatario já está am alguma coleta
                boolean isAchouColeta = false;
                int posicaoD = 0;
                col = new BeanColeta();
                for (int d = 0; d <= x; d++) {
                    if (arCols[d] != null) {
                        if (arCols[d].getDestinatario().getCnpj().equals(request.getParameter("cgcDestinatario_" + x).trim())) {
                            col = arCols[d];
                            isAchouColeta = true;
                            posicaoD = d;
                        }
                    }

                }
                if (!isAchouColeta) {
                    //Dados da coleta
                    col.setId(0);
                    col.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
                    col.setSolicitadaEm(new Date());
                    col.setPrevisaoEm(new Date());
                    col.setNumero("");
                    col.setPedidoCliente("");
                    col.setCategoria("co");

                    col.setObs((request.getParameter("observacaoColeta_" + x) == null ? "" : request.getParameter("observacaoColeta_" + x).replace("  ", "")));
                    //Dados do cliente
                    col.getCliente().setIdcliente(Integer.parseInt(request.getParameter("idRemetente_" + x)));
                    col.getCliente().setRazaosocial(request.getParameter("nomeRemetente_" + x).replace("  ", ""));
                    col.getCliente().setNomefantasia(request.getParameter("nomeRemetente_" + x).replace("  ", ""));
                    col.getCliente().setEndereco(request.getParameter("enderecoRemetente_" + x).replace("  ", ""));
                    col.getCliente().setBairro(request.getParameter("bairroRemetente_" + x).replace("  ", ""));
                    col.getCliente().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeRemetente_" + x)));
                    col.getCliente().setCnpj(request.getParameter("cgcRemetente_" + x));
                    col.getCliente().setInscest(request.getParameter("ieRemetente_" + x).replace("  ", ""));

                    //Dados do destinatário
                    col.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("idDestinatario_" + x)));
                    col.getDestinatario().setRazaosocial(request.getParameter("nomeDestinatario_" + x).replace("  ", ""));
                    col.getDestinatario().setNomefantasia(request.getParameter("nomeDestinatario_" + x).replace("  ", ""));
                    col.getDestinatario().setEndereco(request.getParameter("enderecoDestinatario_" + x).replace("  ", ""));
                    col.getDestinatario().setNumeroLogradouro((request.getParameter("numeroEnderecoDestinatario_" + x) == null ? "" : request.getParameter("numeroEnderecoDestinatario_" + x).replace("  ", "")));
                    col.getDestinatario().setCep((request.getParameter("cepDestinatario_" + x) == null ? "" : request.getParameter("cepDestinatario_" + x).replace("  ", "")));
                    col.getDestinatario().setBairro(request.getParameter("bairroDestinatario_" + x).replace("  ", ""));
                    col.getDestinatario().setFone(request.getParameter("foneDestinatario_" + x).replace(" ", ""));
                    col.getDestinatario().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeDestinatario_" + x)));
                    col.getDestinatario().setTipocgc(request.getParameter("tipoDestinatario_" + x));
                    col.getDestinatario().setCnpj(request.getParameter("cgcDestinatario_" + x).replace("  ", ""));
                    col.getDestinatario().setInscest(request.getParameter("ieDestinatario_" + x).replace("  ", ""));
                    col.setValorCombinado((request.getParameter("valorFrete_" + x) == null ? 0 : Float.parseFloat(request.getParameter("valorFrete_" + x))));
                }
                NotaFiscal arNf[] = new NotaFiscal[qtdNotas];
                //  if (isAchouColeta){
                //    arNf[] = col.getNotaFiscal();
                //}
                NotaFiscal nf;

                for (int y = 0; y <= qtdNotas; y++) {
                    if (request.getParameter("pedido_" + x + "_" + y) != null) {
                        //Dados da coleta
                        col.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("destino_" + x + "_" + y)));
                        col.setClientePagador((request.getParameter("frete_" + x + "_" + y).equals("CIF") ? "r" : "d"));
                        nf = new NotaFiscal();
                        nf.setIdnotafiscal(0);
                        nf.setNumero(request.getParameter("nf_" + x + "_" + y));
                        nf.setSerie(request.getParameter("serie_" + x + "_" + y));
                        nf.setEmissao(Apoio.paraDate(request.getParameter("emissao_" + x + "_" + y)));
                        nf.setValor(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                        nf.setVl_base_icms(0);
                        nf.setVl_icms(0);
                        nf.setVl_icms_frete(0);
                        nf.setVl_icms_st(0);
                        nf.setPeso(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                        nf.setVolume(Float.parseFloat(request.getParameter("volume_" + x + "_" + y)));
                        nf.setEmbalagem("");
                        nf.setConteudo("");
                        nf.setPedido(request.getParameter("pedido_" + x + "_" + y));
                        nf.setImportadaEdi(true);
                        if (isAchouColeta) {
                            col.getNotaFiscal()[y] = nf;
                        } else {
                            arNf[y] = nf;
                        }

                    }
                    if (!isAchouColeta) {
                        col.setNotaFiscal(arNf);
                    }
                }
                if (isAchouColeta) {
                    arCols[posicaoD] = col;
                } else {
                    arCols[x] = col;
                }
            }
            cadCol.setArrayColetas(arCols);
        }

        boolean salvou = false;
        salvou = cadCol.incluirVarias(Apoio.getConfiguracao(request));
        if (!salvou) {
            response.getWriter().append("<script>alert('" + cadCol.getErros() + "');window.close();</script>");
        } else {
            String scr = "";
            scr = "<script>";
            scr += "window.opener.document.location.replace('ConsultaControlador?codTela=24');"
                    + "window.close();"
                    + "</script>";
            response.getWriter().append(scr);
        }
        response.getWriter().close();
    } else if (acao.equals("importarNFe")) {
        int qtdColetas = Apoio.parseInt(request.getParameter("qtdColetas"));
        int qtdNotas = Apoio.parseInt(request.getParameter("qtdNotas"));
        BeanCadColeta cadCol = new BeanCadColeta();
        cadCol.setConexao(Apoio.getUsuario(request).getConexao());
        cadCol.setExecutor(Apoio.getUsuario(request));
        BeanColeta col, colAnt = null;
        BeanColeta arCols[] = new BeanColeta[qtdColetas + 1];
        for (int x = 0; x <= qtdColetas; x++) {
            if (request.getParameter("idRemetente_" + x) != null && !request.getParameter("idCidadeDestinatario_" + x).equals("0") && !request.getParameter("idCidadeDestinatario_" + x).equals("")) {
                if (request.getParameter("nfExiste_" + x) == null || request.getParameter("nfExiste_" + x).equals("NAO")) {
                    col = new BeanColeta();
                    //Dados da coleta
                    col.setId(0);
                    col.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filialId")));
                    col.setSolicitadaEm(new Date());
                    col.setColetaEm(new Date());
                    col.setPrevisaoEm(new Date());
                    col.setNumero("");
                    col.setPedidoCliente("");
                    col.setCategoria("co");
                    col.setObs((request.getParameter("observacaoColeta_" + x) == null ? "" : request.getParameter("observacaoColeta_" + x).replace("  ", "")));
                    
                    
                    col.setEnderecoEntrega((request.getParameter("localDestino_" + x) == null ? "" : request.getParameter("localDestino_" + x)));
                    col.setBairroEntrega((request.getParameter("bairroDestino_" + x) == null ? "" : request.getParameter("bairroDestino_" + x)));
                    col.getCidadeDestino().setIdcidade((request.getParameter("idCidadeDestino_" + x) == null ? 0 : Apoio.parseInt(request.getParameter("idCidadeDestino_" + x))));
                    
                    //Dados do cliente
                    col.getCliente().setIdcliente(Integer.parseInt(request.getParameter("idRemetente_" + x)));
                    col.getCliente().setRazaosocial(request.getParameter("nomeRemetente_" + x).trim());
                    col.getCliente().setNomefantasia(request.getParameter("nomeRemetente_" + x).trim());
                    col.getCliente().setEndereco(request.getParameter("enderecoRemetente_" + x).trim());
                    col.getCliente().setBairro(request.getParameter("bairroRemetente_" + x).trim());
                    col.getCliente().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeRemetente_" + x)));
                    col.getCliente().setCnpj(request.getParameter("cgcRemetente_" + x));
                    col.getCliente().setInscest(request.getParameter("ieRemetente_" + x).trim());
                    //Dados do destinatário
                    col.getDestinatario().setIdcliente(Integer.parseInt(request.getParameter("idDestinatario_" + x)));
                    col.getDestinatario().setRazaosocial(request.getParameter("nomeDestinatario_" + x).trim());
                    col.getDestinatario().setNomefantasia(request.getParameter("nomeDestinatario_" + x).trim());
                    col.getDestinatario().setEndereco(request.getParameter("enderecoDestinatario_" + x).trim());
                    col.getDestinatario().setNumeroLogradouro((request.getParameter("numeroEnderecoDestinatario_" + x) == null ? "" : request.getParameter("numeroEnderecoDestinatario_" + x).trim()));
                    col.getDestinatario().setCep((request.getParameter("cepDestinatario_" + x) == null ? "" : request.getParameter("cepDestinatario_" + x).trim()));
                    col.getDestinatario().setBairro(request.getParameter("bairroDestinatario_" + x).trim());
                    col.getDestinatario().setFone(request.getParameter("foneDestinatario_" + x).replace(" ", ""));
                    col.getDestinatario().setComplemento(request.getParameter("compDestinatario_" + x).replace(" ", ""));
                    col.getDestinatario().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadeDestinatario_" + x)));
                    col.getDestinatario().setTipocgc(request.getParameter("tipoDestinatario_" + x));
                    //            col.getDestinatario().setCep(request.getParameter("cepDestinatario_"+x));
                    col.getDestinatario().setCnpj(request.getParameter("cgcDestinatario_" + x).trim());
                    col.getDestinatario().setInscest(request.getParameter("ieDestinatario_" + x).trim());
                    col.setValorCombinado((request.getParameter("valorFrete_" + x) == null ? 0 : Float.parseFloat(request.getParameter("valorFrete_" + x))));

                    NotaFiscal arNf[] = new NotaFiscal[qtdNotas];
                    NotaFiscal nf;
                    for (int y = 0; y <= qtdNotas; y++) {
                        if (request.getParameter("pedido_" + x + "_" + y) != null) {
                            //Dados da coleta
                            col.setClientePagador((request.getParameter("frete_" + x + "_" + y).equals("CIF") ? "r" : "d"));
                            nf = new NotaFiscal();
                            nf.setIdnotafiscal(0);
                            nf.setNumero(request.getParameter("nf_" + x + "_" + y));
                            if (request.getParameter("chave_nf_" + x + "_" + y) != null){
                                nf.setChaveNFe(request.getParameter("chave_nf_" + x + "_" + y));
                            }
                            nf.setSerie(request.getParameter("serie_" + x + "_" + y));
                            nf.setEmissao(Apoio.paraDate(request.getParameter("emissao_" + x + "_" + y)));
                            nf.setValor(Float.parseFloat(request.getParameter("valorNF_" + x + "_" + y)));
                            nf.setVl_base_icms(0);
                            nf.setVl_icms(0);
                            nf.setVl_icms_frete(0);
                            nf.setVl_icms_st(0);
                            if (request.getParameter("cfopNF_" + x + "_" + y) != null) {
                                nf.getCfop().setIdcfop(Integer.parseInt(request.getParameter("cfopNF_" + x + "_" + y)));
                            }
                            if (request.getParameter("chaveNFe_" + x + "_" + y) != null) {
                                nf.setChaveNFe(request.getParameter("chaveNFe_" + x + "_" + y));
                            }

                            nf.setPeso(Float.parseFloat(request.getParameter("peso_" + x + "_" + y)));
                            nf.setVolume(Float.parseFloat(request.getParameter("volume_" + x + "_" + y)));

                            if (request.getParameter("qtdCubagens_" + x + "_" + y) != null) {
                                nf.setComprimento(0);
                                nf.setLargura(0);
                                nf.setAltura(0);
                                int qtdCubagens = Integer.parseInt(request.getParameter("qtdCubagens_" + x + "_" + y));
                                float metroCubicoTotal = 0;
                                nf.setCubagens(new Cubagem[qtdCubagens]);
                                for (int t = 1; t <= qtdCubagens; t++) {
                                    double volume = 1;
                                    double comprimento = Double.parseDouble(request.getParameter("comprimentoNF_" + x + "_" + y + "_" + t));
                                    double largura = Double.parseDouble(request.getParameter("larguraNF_" + x + "_" + y + "_" + t));
                                    double altura = Double.parseDouble(request.getParameter("alturaNF_" + x + "_" + y + "_" + t));
                                    double metroCubico = (Apoio.toFixedMed(volume * comprimento * largura * altura, 3));
                                    nf.getCubagens()[t - 1] = new Cubagem();
                                    nf.getCubagens()[t - 1].setVolume(volume);
                                    nf.getCubagens()[t - 1].setComprimento(comprimento);
                                    nf.getCubagens()[t - 1].setLargura(largura);
                                    nf.getCubagens()[t - 1].setAltura(altura);
                                    nf.getCubagens()[t - 1].setMetroCubico(metroCubico);
                                    metroCubicoTotal += metroCubico;
                                }
                                nf.setMetroCubico(metroCubicoTotal);
                            }
                            nf.setEmbalagem("");
                            nf.setConteudo("");
                            nf.setPedido(request.getParameter("pedido_" + x + "_" + y));
                            nf.setDataAgenda(null);
                            nf.setPrevisaoEm(null);
                            nf.setImportadaEdi(true);

                            arNf[y] = nf;
                        }
                        col.setNotaFiscal(arNf);
                    }
                    if (colAnt == null) {
                        arCols[x] = col;
                    }else if (colAnt != null && col.getDestinatario().getId() != colAnt.getDestinatario().getId()) {
                        arCols[x] = col;
                    }else if(col.getDestinatario().getId() != colAnt.getDestinatario().getId()){
                        colAnt.getNotasfiscais().addAll(col.getNotasfiscais());
                    }
                    colAnt = col;
                }
            }
            cadCol.setArrayColetas(arCols);
        }

        boolean salvou = false;
        salvou = cadCol.incluirVarias(Apoio.getConfiguracao(request));
        if (!salvou) {
            response.getWriter().append("<script>alert('" + cadCol.getErros() + "');window.close();</script>");
        } else {
            String scr = "";
            scr = "<script>";
            scr += "window.opener.document.location.replace('ConsultaControlador?codTela=24');"
                    + "window.close();"
                    + "</script>";
            response.getWriter().append(scr);
        }
        response.getWriter().close();
    }

%>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<!--<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>-->
<script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript" type="text/javascript">
    jQuery.noConflict();
    
    // executar quando a pagina terminar de carregar.
    jQuery(document).ready(function(){
        
        // se APERTAR o ENTER não deve fazer NADA!
        jQuery("#chaveAcessoNFe").on('keydown', function(ev){
            if (ev.keyCode == 13) {
                ev.preventDefault();
            }
        });
        
        // quando levantar uma tecla
        jQuery("#chaveAcessoNFe").on('keyup', function(ev){
            // se a tecla for 13
            if (ev.keyCode == 13) {
                //cancelar o que deveria ser feito
                ev.preventDefault();
                //chamar a função do botão.
                getFile();
            }
        });
    });

    function voltar(){
        tryRequestToServer(function(){document.location.replace('ConsultaControlador?codTela=24');});
    }

    function getFile(){
        if ($('file').value == '' && $("layout").value != "chaveAcesso"){
            alert('Informe o arquivo corretamente!');
        }else if($("layout").value == "chaveAcesso"){
            $("formColeta").enctype = "";
            try{
                   

                tryRequestToServer(function(){
                    var nfe = $("chaveAcessoNFe").value;
                    var popChave = window.open('http://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&nfe=' + nfe, '', 'width=1000, height=700,scrollbars=1');
                    jQuery('.block-tela').show();
                    var interval = setInterval(function () {
                        localStorage.setItem("nfe",nfe);
                        if (localStorage.getItem(nfe)) {
                            clearInterval(interval);
                            try{
                                jQuery.ajax({
                                    'url':'ServletUpload',
                                    'data':{
                                        layout: $('layout').value,
                                        sped: $('sped').checked,
                                        chaveAcessoNFe: nfe,
                                        html: localStorage.getItem(nfe)
                                    },
                                    method:'POST',
                                    complete: function (jqXHR, textStatus ) {
                                        if (jqXHR != null && jqXHR != "") {
                                            var textoresposta = jqXHR.responseText;
                                            if (textoresposta != null && textoresposta != "") {
                                                var lista = jQuery.parseJSON(textoresposta);
                                                var dest = lista.itensProdutos.dest;
                                                var emit = lista.itensProdutos.emit;
                                                var ide = lista.itensProdutos.ide;
                                                var volume = lista.itensProdutos.volume;
                                                var peso = lista.itensProdutos.peso;
                                                var valorNota = lista.itensProdutos.valorNota;
                                                var idDest = lista.itensProdutos.idDest;
                                                var idEmit = lista.itensProdutos.idEmit;
                                                var tipoDest = lista.itensProdutos.tipoDestinatario;
                                                var chaveAcesso = lista.itensProdutos.nfeProc.protNFe.infProt.chNFe;
                           
                                                var indexColeta = $("qtdColetas").value;
                                                if(idDest==0){
                                                    if (confirm("Destinatário é do exterior e não é possível realizar o cadastro do mesmo. Deseja realizar o cadastro agora?")){
                                                        window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                                    }
                                                }
                                                $("isAgrupar").disabled = true;
                                                if($("isAgrupar").checked){
                                                    var criarColeta = false;
                                                    if(indexColeta < 1){addColetaChave(emit,idEmit,dest,idDest,tipoDest);}
                                                        for(var contColetas =0; contColetas < indexColeta; contColetas++ ){
                                                            if((idEmit == $("idRemetente_"+contColetas).value)){
                                                                criarColeta = false;
                                                                indexColeta = contColetas;
                                                                break;
                                                            }else{
                                                                criarColeta=true;
                                                            }
                                                        }
                                                    if(criarColeta){
                                                        addColetaChave(emit,idEmit,dest,idDest,tipoDest);
                                                    }
                                                    addNotas(indexColeta,ide,dest,volume,peso,valorNota,chaveAcesso);
                                                }else{
                                                    addColetaChave(emit,idEmit,dest,idDest,tipoDest);
                                                    addNotas(indexColeta,ide,dest,volume,peso,valorNota,chaveAcesso);
                                                }
                                                $("chaveAcessoNFe").value = "";
                                                if (transport.indexOf("ERRO") > -1) {
                                                    alert(transport);
                                                    espereEnviar("Aguarde...", false);
                                                    return false;
                                                }
                                            }else{
                                                alert(" Erro ao Consultar NF-e. Verifique a chave de acesso, o caracter digitado e tente novamente. Caso persista o erro consulte a chave de acesso no site da sefaz.");
                                            }
                                        } 

                                    }
                                });
                            }catch(err){
                                console.error(err);
                            }finally{
                                localStorage.clear();
                                popChave.close();
                                jQuery('.block-tela').hide();
                            }
                        }
                    },500);
                }); 
            }catch(ex){
                console.log(ex);
                localStorage.clear();
            }
       
        }else{
                
           
            $("isAgrupar").disabled = false;
            document.getElementById('formColeta').action="ServletUpload?layout="+$('layout').value+"&sped="+$('sped').checked+
                "&chaveAcessoNFe="+$("chaveAcessoNFe").value+"&isAgrupar="+$("isAgrupar").checked;
            tryRequestToServer(function(){document.getElementById("formColeta").submit();});
            
        }
    }
    
    
    function apagarColeta(index){
         if(confirm("Deseja excluir a coleta ?")){
                if(confirm("Tem certeza?")){
                    Element.remove("trColetas_"+index);
                }
         }
    }
    
    function addColetaChave(rem,idRem,dest,idDest,tipoDestinatario){
            /*if (coleta == null || coleta==undefined){
                coleta = new Coletas();
            } */
            //countItensCompra++;

            var tabelaBase = $("tabelaBaseColetasChave");
            var qtdColetas = $("qtdColetas").value ;
            var complemento = qtdColetas;
            
            var trBase = Builder.node('tr',{});            
            var tdBase = Builder.node('td',{
                colSpan:'9'
            });
            var trColeta = Builder.node("tr",{
                id:"trColetas_"+complemento,
                name:"trColetas_"+complemento
            });
            var tdColeta = Builder.node("td",{
                id:"tdColetas_"+complemento,
                name:"tdColetas_"+complemento
            });
            var tableColeta = Builder.node("table",{
                id:"tableColetas_"+complemento,
                name:"tableColetas_"+complemento,
                className:"bordaFina",
                width:"100%"
            });
            var subTable = Builder.node('table',{
                id:"tabelaColeta",
                width:'100%',
                className:'bordaFina'
            });
            var subTr = Builder.node('tr',{
                className:'tabela'
            });
            
            var tdExcluir = Builder.node("td",{
                className:'tabela'
            });
            
            var labelRemetente = Builder.node('label','Remetente')
            var tdLabelRemetente = Builder.node('td',{
                width:'35%'
            });
            tdLabelRemetente.appendChild(labelRemetente);
            
            var labelCGCRem = Builder.node('label','CNPJ')
            var tdLabelCGCRem = Builder.node('td',{
                 width:'15%'
            });
            tdLabelCGCRem.appendChild(labelCGCRem);
            
            var labelDestinatario = Builder.node('label','Destinatario')
            var tdLabelDestinatario = Builder.node('td',{
                width:'35%'
            });
            tdLabelDestinatario.appendChild(labelDestinatario);
            
            var labelCGCDest = Builder.node('label','CNPJ')
            var tdLabelCGCDest = Builder.node('td',{
                width:'15%'
            });
            tdLabelCGCDest.appendChild(labelCGCDest);
            //_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ //

            var trHiddens = Builder.node('tr',{
                className:"CelulaZebra1"
            });
            
            var tdExcluirColeta = Builder.node("td");
            var imgExcluir = Builder.node("img",{
                src:"img/lixo.png", 
                onClick:"apagarColeta("+qtdColetas+")"
            });
            
            var labelEmitNome = Builder.node('label',rem.xNome);
            var tdEmitNome = Builder.node('td');
            tdEmitNome.appendChild(labelEmitNome);
            
            var labelEmitCPF = Builder.node('label',rem.cnpj);
            var tdEmitCPF = Builder.node('td');
            tdEmitCPF.appendChild(labelEmitCPF);
            
            //_ _ _ _ inicio dados Remetente _ _ _ _ 
            var hiddenIdRemetente = Builder.node("input",{
                type:"hidden",
                id:"idRemetente_"+complemento,
                name:"idRemetente_"+complemento,
                value:idRem
            });
            var hiddenNomeRemetente = Builder.node("input",{
                type:"hidden",
                id:"nomeRemetente_"+complemento,
                name:"nomeRemetente_"+complemento,
                value:rem.xNome
            });
            var hiddenEnderecoRemetente = Builder.node("input",{
                type:"hidden",
                id:"enderecoRemetente_"+complemento,
                name:"enderecoRemetente_"+complemento,
                value:rem.enderEmit.xLgr
            });
            var hiddenBairroRemetente = Builder.node("input",{
                type:"hidden",
                id:"bairroRemetente_"+complemento,
                name:"bairroRemetente_"+complemento,
                value:rem.enderEmit.xMun
            });
            var hiddenIdCidadeRemetente = Builder.node("input",{
                type:"hidden",
                id:"idCidadeRemetente_"+complemento,
                name:"idCidadeRemetente_"+complemento,
                value:rem.enderEmit.cMun
            });
            var hiddenCGCRemetente = Builder.node("input",{
                type:"hidden",
                id:"cgcRemetente_"+complemento,
                name:"cgcRemetente_"+complemento,
                value:rem.cnpj
            });
            var hiddenIERemetente = Builder.node("input",{
                type:"hidden",
                id:"ieRemetente_"+complemento,
                name:"ieRemetente_"+complemento,
                value:rem.ie
            });
            //_ _ _ _ fim dados remetente_ _ _ 
            
            var labelDestNome = Builder.node('label',dest.xNome);
            var tdDestNome = Builder.node('td');
            tdDestNome.appendChild(labelDestNome);
            
            //_ _ _ _ inicio dados Destinatario _ _ _ _ _ 
            var hiddenIdDestinatario = Builder.node("input",{
                type:"hidden",
                id:"idDestinatario_"+complemento,
                name:"idDestinatario_"+complemento,
                value:idDest
            });
            var hiddenNomeDestinatario = Builder.node("input",{
                type:"hidden",
                id:"nomeDestinatario_"+complemento,
                name:"nomeDestinatario_"+complemento,
                value:dest.xNome
            });
            var hiddenEnderecoDestinatario = Builder.node("input",{
                type:"hidden",
                id:"enderecoDestinatario_"+complemento,
                name:"enderecoDestinatario_"+complemento,
                value:dest.enderDest.xLgr
            });
            var hiddenNumeroDestinatario = Builder.node("input",{
                type:"hidden",
                id:"numeroEnderecoDestinatario_"+complemento,
                name:"numeroEnderecoDestinatario_"+complemento,
                value:dest.enderDest.nro
            });
            var hiddenBairroDestinatario = Builder.node("input",{
                type:"hidden",
                id:"bairroDestinatario_"+complemento,
                name:"bairroDestinatario_"+complemento,
                value:dest.enderDest.xBairro
            });
            var hiddenTipoDestinatario = Builder.node("input",{
                type:"hidden",
                id:"tipoDestinatario_"+complemento,
                name:"tipoDestinatario_"+complemento,
                value: tipoDestinatario
            });
            var hiddenIdCidadeDestinatario = Builder.node("input",{
                type:"hidden",
                id:"idCidadeDestinatario_"+complemento,
                name:"idCidadeDestinatario_"+complemento,
                value:dest.enderDest.cMun
            });
            var hiddenCGCDestinatario = Builder.node("input",{
                type:"hidden",
                id:"cgcDestinatario_"+complemento,
                name:"cgcDestinatario_"+complemento,
                value:(dest.cnpj == null || dest.cnpj == undefined ? (dest.cpf == null || dest.cpf == undefined ? dest.cpf : "") :dest.cnpj)
            });
            var hiddenIEDestinatario = Builder.node("input",{
                type:"hidden",
                id:"ieDestinatario_"+complemento,
                name:"ieDestinatario_"+complemento,
                value:dest.ie
            });
            
            var hiddenCEPDestinatario = Builder.node("input",{
                type:"hidden",
                id:"cepDestinatario_"+complemento,
                name:"cepDestinatario_"+complemento,
                value:dest.enderDest.cep
            });
            
            var hiddenFoneDestinatario = Builder.node("input",{
                type:"hidden",
                id:"foneDestinatario_"+complemento,
                name:"foneDestinatario_"+complemento,
                value:dest.enderDest.fone
            });
            //_ _ _ _ fim dados Destinatario _ _ _ _ 
            
            
            var labelDestCPF = Builder.node('label',dest.cnpj);
            var tdDestCPF = Builder.node('td');
            tdDestCPF.appendChild(labelDestCPF);


            //_ _ para controle das notas: _ _ 
            var qtdNotas = Builder.node("input",{
                type:"hidden",
                id:"qtdNotasColeta_"+complemento,
                name:"qtdNotasColeta_"+complemento,
                value:0
            });
            

            
//                  _ _ _ _ _ _ abaixo é DOM de notas:_ _ _ _ _ _ _ _ _ _ 
        var trNota = Builder.node("tr",{className:"tabela"});
        
        var labelPedido = Builder.node('label','Pedido');
        var tdLabelPedido = Builder.node("td");
        tdLabelPedido.appendChild(labelPedido);
        
        var labelNF = Builder.node('label','NF');
        var tdLabelNF = Builder.node("td");
        tdLabelNF.appendChild(labelNF);
        
        var labelSerie = Builder.node('label','Série');
        var tdLabelSerie = Builder.node("td");
        tdLabelSerie.appendChild(labelSerie);
        
        var labelEmissao = Builder.node('label','Emissão');
        var tdLabelEmissao = Builder.node("td");
        tdLabelEmissao.appendChild(labelEmissao);
        
        var labelFrete = Builder.node('label','Frete');
        var tdLabelFrete = Builder.node("td");
        tdLabelFrete.appendChild(labelFrete);
        
        var labelDestino = Builder.node('label','Destino');
        var tdLabelDestino = Builder.node("td");
        tdLabelDestino.appendChild(labelDestino);
        
        var labelVolumes = Builder.node('label','Volumes');
        var tdLabelVolumes = Builder.node("td");
        tdLabelVolumes.appendChild(labelVolumes);
        
        var labelPeso = Builder.node('label','Peso');
        var tdLabelPeso = Builder.node("td");
        tdLabelPeso.appendChild(labelPeso);
        
        var labelValor = Builder.node('label','Valor');
        var tdLabelValor = Builder.node("td");
        tdLabelValor.appendChild(labelValor);
        
        trNota.appendChild(tdLabelPedido);
        trNota.appendChild(tdLabelNF);
        trNota.appendChild(tdLabelSerie);
        trNota.appendChild(tdLabelEmissao);
        trNota.appendChild(tdLabelFrete);
        trNota.appendChild(tdLabelDestino);
        trNota.appendChild(tdLabelVolumes);
        trNota.appendChild(tdLabelPeso);
        trNota.appendChild(tdLabelValor);
        //_ _ _ _ _  fim inicio DOM notas _ _ _ _ _ 
        
        //controle das notas:
        tdEmitNome.appendChild(qtdNotas);
        //fim controle notas.
        //_ _ _ _ _ _dados remetente _ _ _ _ _ _
        tdEmitNome.appendChild(hiddenIdRemetente);
        tdEmitNome.appendChild(hiddenNomeRemetente);
        tdEmitNome.appendChild(hiddenEnderecoRemetente);
        tdEmitNome.appendChild(hiddenBairroRemetente);
        tdEmitNome.appendChild(hiddenIdCidadeRemetente);
        tdEmitNome.appendChild(hiddenCGCRemetente);
        tdEmitNome.appendChild(hiddenIERemetente);
        //_ _ _ _ _ _ fim dados remetente _ _ _ _
        
        
        //_ _ _ _ _ _dados Destinatario _ _ _ _ _ _
        tdDestNome.appendChild(hiddenIdDestinatario);
        tdDestNome.appendChild(hiddenNomeDestinatario);
        tdDestNome.appendChild(hiddenEnderecoDestinatario);
        tdDestNome.appendChild(hiddenNumeroDestinatario);
        tdDestNome.appendChild(hiddenBairroDestinatario);
        tdDestNome.appendChild(hiddenTipoDestinatario);
        tdDestNome.appendChild(hiddenIdCidadeDestinatario);
        tdDestNome.appendChild(hiddenCGCDestinatario);
        tdDestNome.appendChild(hiddenIEDestinatario);
        tdDestNome.appendChild(hiddenCEPDestinatario);
        tdDestNome.appendChild(hiddenFoneDestinatario);
        //_ _ _ _ _ _ fim dados Destinatario _ _ _ _
        
        subTr.appendChild(tdExcluir);
        subTr.appendChild(tdLabelRemetente);
        subTr.appendChild(tdLabelCGCRem);
        subTr.appendChild(tdLabelDestinatario);
        subTr.appendChild(tdLabelCGCDest);
        subTable.appendChild(subTr);
        tdBase.appendChild(subTable);
        trBase.appendChild(tdBase);     
        
        tdExcluirColeta.appendChild(imgExcluir);
        
        trHiddens.appendChild(tdExcluirColeta);
        trHiddens.appendChild(tdEmitNome);
        trHiddens.appendChild(tdEmitCPF);
        trHiddens.appendChild(tdDestNome);
        trHiddens.appendChild(tdDestCPF);
        subTable.appendChild(trHiddens);
        
        tableColeta.appendChild(trBase);
        tableColeta.appendChild(trNota);
        tdColeta.appendChild(tableColeta);
        trColeta.appendChild(tdColeta);
        
        tabelaBase.appendChild(trColeta);
        $("qtdColetas").value = parseInt($("qtdColetas").value) + 1;
    }
    
    
    function addNotas(indexColeta,ide,dest,volume,peso,valor,chaveAcesso){

        var tabelaBase = $("tableColetas_"+indexColeta);
        var qtdNotas = $("qtdNotasColeta_"+indexColeta).value;
        var complemento = indexColeta+"_"+qtdNotas;
        var trNotaValores = Builder.node("tr",{className:"CelulaZebra1"});

        //TD PEDIDO
        var tdPedido = Builder.node("td",{});
        var hiddenPedido = Builder.node("input",{
            type:"hidden",
            id:"pedido_"+complemento,
            name:"pedido_"+complemento,
            value:""

        });
        var hiddenDataSaida = Builder.node("input",{
            type:"hidden",
            id:"dataSaida_"+complemento,
            name:"dataSaida_"+complemento
        });            

        var hiddenChaveNFE = Builder.node("input",{
            type:"hidden",
            id:"chaveNFe_"+complemento,
            name:"chaveNFe_"+complemento,
            value:(chaveAcesso == undefined ? "" : chaveAcesso) 
        });
        //fim TD PEDIDO

        //TD NF
        var tdNF = Builder.node("td",{});
        var hiddenNF = Builder.node("input",{
            type:"hidden",
            id:"nf_"+complemento,
            name:"nf_"+complemento,
            value:ide.nnf
        });
            
        var labelNF = Builder.node("label",""+ide.nnf);
        tdNF.appendChild(labelNF);
        //fim TD NF
            
        //TD SERIE
        var tdSerie = Builder.node("td",{});
        var hiddenSerie = Builder.node("input",{
            type:"hidden",
            id:"serie_"+complemento,
            name:"serie_"+complemento,
            value:ide.serie
        });
        var labelSerie = Builder.node("label",ide.serie);
        tdSerie.appendChild(labelSerie);
        //FIM TD SERIE
        
        //TD EMISSAO
        var tdEmissao = Builder.node("td",{});
        var hiddenEmissao = Builder.node("input",{
            type:"hidden",
            id:"emissao_"+complemento,
            name:"emissao_"+complemento,
            value:ide.dEmi
        });
        var labelEmissao = Builder.node("label",ide.dEmi);
        tdEmissao.appendChild(labelEmissao);
        //FIM TD EMISSAO
        
        //TD FRETE
        var tdFrete = Builder.node("td",{});
        var hiddenFrete = Builder.node("input",{
            type:"hidden",
            id:"frete_"+complemento,
            name:"frete_"+complemento,
            value:(ide.mod == 0 ? "CIF" : "FOB")
        });
        var labelFrete = Builder.node("label",(ide.mod == 0 ? "CIF" : "FOB"));
        tdFrete.appendChild(labelFrete);
        //FIM TD FRETE
        
        //TD DESTINO
        var tdDestino = Builder.node("td",{});
        var hiddenDestino = Builder.node("input",{
            type:"hidden",
            id:"destino_"+complemento,
            name:"destino_"+complemento,
            value:dest.enderDest.cMun
        });
        var labelDestino = Builder.node("label",dest.enderDest.xMun);
        tdDestino.appendChild(labelDestino);
        //FIM TD DESTINO
        
        //TD VOLUME
        var tdVolume = Builder.node("td",{});
        var hiddenVolume = Builder.node("input",{
            type:"hidden",
            id:"volume_"+complemento,
            name:"volume_"+complemento,
            value:volume
        });
        var labelVolume = Builder.node("label",volume);
        tdVolume.appendChild(labelVolume);
        //FIM TD VOLUME
        
        //TD PESO
        var tdPeso = Builder.node("td",{});
        var hiddenPeso = Builder.node("input",{
            type:"hidden",
            id:"peso_"+complemento,
            name:"peso_"+complemento,
            value:peso
        });
        var labelPeso = Builder.node("label",peso);
        tdPeso.appendChild(labelPeso);
        //FIM TD PESO
        
        //TD VALOR
        var tdValor = Builder.node("td",{});
        var hiddenValor = Builder.node("input",{
            type:"hidden",
            id:"valorNF_"+complemento,
            name:"valorNF_"+complemento,
            value:valor
        });
        var labelValor = Builder.node("label",valor);
        tdValor.appendChild(labelValor);
        //FIM TD VALOR
        
        
        //montando appendChild's
        tdPedido.appendChild(hiddenPedido);
        tdPedido.appendChild(hiddenDataSaida);
        tdPedido.appendChild(hiddenChaveNFE);        
        
        tdNF.appendChild(hiddenNF);
        tdSerie.appendChild(hiddenSerie);
        tdEmissao.appendChild(hiddenEmissao);
        tdFrete.appendChild(hiddenFrete);
        tdDestino.appendChild(hiddenDestino);
        tdVolume.appendChild(hiddenVolume);
        tdPeso.appendChild(hiddenPeso);
        tdValor.appendChild(hiddenValor);
        
        trNotaValores.appendChild(tdPedido);
        trNotaValores.appendChild(tdNF);
        trNotaValores.appendChild(tdSerie);
        trNotaValores.appendChild(tdEmissao);
        trNotaValores.appendChild(tdFrete);
        trNotaValores.appendChild(tdDestino);
        trNotaValores.appendChild(tdVolume);
        trNotaValores.appendChild(tdPeso);
        trNotaValores.appendChild(tdValor);
        
        tabelaBase.appendChild(trNotaValores);
        $("qtdNotasColeta_"+indexColeta).value = parseInt($("qtdNotasColeta_"+indexColeta).value) + parseInt("1");
    }
    
    
    function alterarLayout(layout){
        switch(layout){
            case "chaveAcesso":
                visivel($("chaveAcessoNFe"));
                visivel($("trAgrupar"));
                invisivel($("file"));
//                ajaxCarregarCaptcha();
                break;
            case "nfe":
                invisivel($("chaveAcessoNFe"));
                invisivel($("trAgrupar"));
                visivel($("file"));
                visivel($("trAgrupar"));
            break;
            default:
                invisivel($("chaveAcessoNFe"));
                invisivel($("trAgrupar"));
                visivel($("file"));
                break;
        }
    }
  
    function importar(){
        if ($('layout_tramontina_0') != null){
            $('formImportar').action = './importar_coleta.jsp?acao=importar_notas';
        }else if ($('layout_roca_1') != null){
            $('formImportar').action = './importar_coleta.jsp?acao=importar_roca';
        }else if ($('layout_nfe_0') != null){
            $('formImportar').action = './importar_coleta.jsp?acao=importarNFe';
        }
        if ($('layoutRicardo') != null){
            var notas = '';
            for (var r = 0; r <= $('qtdColetas').value; r++) {
                if ($("idRemetente_" + r) != null){
                    if ($("nfExiste_" + r) == null || $("nfExiste_" + r).value == 'NAO'){
                        for (var y = 0; y <= $('qtdNotas').value; y++) {
                            if ($("pedido_" + r + "_" + y) != null) {
                                if (parseFloat($("qtdCubagens_" + r + "_" + y).value)== 0){
                                    notas += (notas == '' ? '' : ',') + $('nf_'+ r + "_" + y).value;
                                }else{
                                    for (var t = 1; t <= $("qtdCubagens_" + r + "_" + y).value; t++) {
                                        if($("metroNF_" + r + "_" + y+ "_" + t) != null && (parseFloat($("metroNF_" + r + "_" + y+ "_" + t).value)== 0)){
                                            notas += (notas == '' ? '' : ',') + $('nf_'+ r + "_" + y).value;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (notas != ''){
                if (!confirm('As nota(s):' + notas + ' estão com a cubagem zerada, deseja continuar a importação?')){
                    return null;
                }
            }
        }
        if ($('layoutSeara0') != null){
            var notas = "";
            for (var r = 0; r <= $('qtdColetas').value; r++) {
                for (var y = 0; y <= $('qtdNotas').value; y++) {
                    if ($("destino_" + r + "_" + y) != null && $("destino_" + r + "_" + y) == "0") {
                        notas += (notas == '' ? '' : ',') + $('nf_'+ r + "_" + y).value;                                           
                    }
                }
            }
            if (notas != ''){
                if (!confirm('As nota(s):' + notas + ' não serão salvas, pois o CEP encontrasse invalido.')){
                    return null;
                }
            }
        }
        tryRequestToServer(function(){submitPopupForm($('formImportar'));});
    }
    
    function carregar(){
        if ('<%=cfg.getLayoutImportacaoXmlDanfe()%>' == 'c') {
            $("layout").value = "chaveAcesso";
            alterarLayout("chaveAcesso");
        }else if('<%=cfg.getLayoutImportacaoXmlDanfe()%>' == 'x'){
            $("layout").value = "nfe";
            alterarLayout("nfe");
        }
        
    }
      
</script>

<html>
    <head>
        <script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/notaFiscal-util.js" type="text/javascript"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Importar coletas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {color: #FF0000}
            .style2 {color: #0000FF}
            -->
        </style>
    </head>

    <body onLoad="carregar();">
        <div align="center"><img src="img/banner.gif" alt="banner"><br>
        </div>
        <table width="85%" height="28" align="center" class="bordaFina">
            <tr>
                <td width="86%" height="22"><b>Importa&ccedil;&atilde;o de  coletas (EDI) </b></td>
                <td width="14%"><b> <input name="Button" type="button"
                                           class="botoes" value="Voltar para Consulta" onClick="voltar()"> </b></td>
            </tr>
        </table>

        <br>
        <table width="85%" border="0" class="bordaFina" align="center">
            <form id="formColeta" name="formColeta" method="post" action="ServletUpload" enctype="multipart/form-data">
                <tr class="tabela">
                    <td height="18" colspan="5">
                        <div align="center">Filtros</div>
                        <div align="center"></div>
                    </td>
                </tr>
                <tr>
                    <td width="102" class="TextoCampos">Informe o layout:</td>
                    <td width="98"  colspan="1" class="TextoCampos">
                        <div align="left">
                          <strong>
                                <select name="layout" id="layout" class="fieldMin" onchange="alterarLayout(this.value)" >
                                    <option value="cargasnet" >Cargas NET</option>
                                    <option value="datasul" selected>EMS Datasul/Totvs (Intral S/A,Docile Ltda)</option>
                                    <option value="el">Electrolux</option>
                                    <option value="proceda-3.1">Proceda 3.1</option>
                                    <option value="proceda-3.1-alianca">Proceda 3.1 (Aliança)</option>
                                    <option value="proceda-3.1-hermes">Proceda 3.1 (Hermes)</option>
                                    <option value="proceda-3.1-masterfoods">Proceda 3.1 (Masterfoods)</option>
                                    <option value="proceda-5.0">Proceda 5.0</option>
                                    <option value="ricardo">Ricardo Eletro</option>
                                    <option value="roca">Roca Brasil</option>
                                    <option value="roca_sanitario">Roca Sanitários Ltda</option>
                                    <option value="santher-3.1">Santher 3.1</option>
                                    <option value="socen">SOCEN 5.0</option>
                                    <option value="tramontina">Tramontina</option>
                                    <option value="seara">Seara</option>
                                    <option value="nfe">NF-e (XML)</option>
                                    <option value="chaveAcesso">Chave de Acesso(NF-e)</option>
                                    <option value="whirlpool">Whirlpool</option>
                                    <option value="ge">GE Healthcare</option>
                                </select>
                            </strong></div>
                    </td>
                    <td width="216" class="TextoCampos"><div align="left">
                            <input name="sped" type="checkbox" id="sped" value="checkbox">
                            Nota fiscal com 9 d&iacute;gitos(SPED) </div></td>
                    <td width="120" class="TextoCampos">Selecione o arquivo: </td>
                    <td width="270" class="CelulaZebra2">
                        <input name="file" type="file" id="file" style="font-size:8pt;" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" size="30" class="fieldMin" multiple="true">
                        <input name="chaveAcessoNFe" id="chaveAcessoNFe" type="text" class="inputTexto" size="60"  />
                        <div align="center">
                        </div></td>
                </tr>
                <tr id="trAgrupar">
                    <td class="TextoCampos" colspan="2">
                        <input type="checkbox" id="isAgrupar" <%=request.getAttribute("importEdi") == null ? " " : "disabled='true'" %> 
                               <%= (request.getAttribute("importEdi") == null ? 
                                       " " : 
(Apoio.parseInt((request.getSession().getAttribute("qtdNotas") == null ? "0" : request.getSession().getAttribute("qtdNotas").toString())) > Apoio.parseInt((request.getSession().getAttribute("qtdColetas") == null ? "0" : request.getSession().getAttribute("qtdColetas").toString())) ? "checked" : " " )) %> 
name="isAgrupar"> Agrupar Notas com mesmo remetente
                    </td>
                    <td class="TextoCampos" colspan="3"></td>
                </tr>
            </form>
            <tr>
                <td colspan="5" class="TextoCampos"><div align="center">
                        <input name="visualizar" type="button"
                               class="botoes" id="visualizar" value="Visualizar"
                               onclick="javascript:tryRequestToServer(function(){getFile();});">
                    </div></td>
            </tr>
        </table>
        <form method="post" id="formImportar" name="formImportar" action="./importar_coleta.jsp?acao=importar">
            <table width="85%" border="0" class="bordaFina" align="center">
                <tbody id="tbColeta" name="tbColeta">
                <INPUT TYPE="hidden" ID="qtdColetas" NAME="qtdColetas" VALUE="<%=request.getAttribute("qtdColetas")==null ? "0" : request.getAttribute("qtdColetas")%>">
                <INPUT TYPE="hidden" ID="qtdNotas" NAME="qtdNotas" VALUE="<%=request.getAttribute("qtdNotas")%>">
                <INPUT TYPE="hidden" ID="tipoLayout" NAME="tipoLayout" VALUE="">
                 <INPUT TYPE="hidden" ID="layoutImp" NAME="layoutImp" VALUE="<%=request.getAttribute("layout")%>">
                <tr>
                    <td class="TextoCampos">Informe a filial das coletas:</td>
                    <td class="CelulaZebra2">
                        <select name="filialId" id="filialId" style="font-size:8pt;" class="fieldMin">
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                                while (rsFl.next()) {%>
                            <option value="<%=rsFl.getString("idfilial")%>"
                                    <%=(Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                        </select>
                    </td>
                </tr>
                <tr id="trColeta" name="trColeta">
                    <td id="tdColeta" name="tdColeta" colspan="2">
                        
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table id="tabelaBaseColetasChave" width='100%'></table>
                    </td>
                </tr>
                <%if (acao.equals("carregar")) {%>
                <script>
                    <%if(request.getAttribute("ERRO") != null){%>
                        alert("<%=request.getAttribute("ERRO")%>");
                    <%}%>           
                    <%if(request.getSession().getAttribute("MENSAGEMGE") != null){%>
                        alert("<%=request.getSession().getAttribute("MENSAGEMGE")%>");
                    <%}%>           
                    $("trColeta").childNodes[(isIE()? 0 : 1)].innerHTML = "<%=request.getAttribute("importEdi") == null ? "" :request.getAttribute("importEdi")%>";
                </script>
                <%}
                    request.removeAttribute("importEdi");
                    request.removeAttribute("qtdColetas");
                    request.removeAttribute("qtdNotas");
                %>
            </table>
        </form>
        <table width="85%" border="0" class="bordaFina" align="center">
            <tr>
                <td width="100%" class="TextoCampos">
                    <div align="center">
                        <% if (nivelUser >= 2) {%>
                        <input name="baixar" type="button"
                               class="botoes" id="baixar" value="Importar"
                               onclick="javascript:tryRequestToServer(function(){importar();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
        <br>
        <style>
                .block-tela{
                    position: absolute;
                    width: 100%;
                    height: 100%;
                    background: rgba(0,0,0,0.5);
                    top: 0;
                    left: 0;
                    z-index: 99999;
                    display: none;
                }
        </style>
        <div class="block-tela"></div>
    </body>
</html>
