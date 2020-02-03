<%@page import="java.sql.SQLException"%>
<%@page import="cidade.BeanCidade"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@page import="rota.percurso.cidade.PercursoCidade"%>
<%@page import="rota.percurso.Percurso"%>
<%@page import="java.util.Iterator"%>
<%@page import="rota.tipoVeiculo.TipoVeiculoRota"%>
<%@page import="tipo_veiculos.Tipo_veiculos"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html" language="java"
         import="rota.*,
   	       java.sql.ResultSet,
	       cliente.tipoProduto.TipoProduto,
               nucleo.Apoio" errorPage="" %>

<!--<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>-->
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/Rota.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/validarSessao.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script src="${homePath}/script/funcoesTelaRota.js?v=${random.nextInt()}"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
            // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
            BeanUsuario usu = Apoio.getUsuario(request);
            int nivelUser = usu.getAcesso("cadrota");
            
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
%>

<%
            String acao = (request.getParameter("acao") == null ? "iniciar" : request.getParameter("acao"));
            boolean carregarota = false;
            CadRota cadRt = null;
            Percurso percurso = null;
            PercursoCidade percCidade = null;
            Rota rota = null;
            ResultSet rs = null;
            TipoVeiculoRota tpVeiRota= null;
            Tipo_veiculos tpVei = new Tipo_veiculos();
            Iterator iTpVeiRota = null;
            rs = tpVei.all(Apoio.getUsuario(request).getConexao());
            
            if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {
                //instanciando o bean de cadastro
                rota = new Rota();
                cadRt = new CadRota();
                cadRt.setConexao(Apoio.getUsuario(request).getConexao());
                cadRt.setExecutor(Apoio.getUsuario(request));
            }

            //executando a acao desejada
            if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
                int id = Integer.parseInt(request.getParameter("id"));
                rota.setId(id); 
                cadRt.setRota(rota);
                //carregando completo
                cadRt.LoadAllPropertys();
                rota = cadRt.getRota();
                iTpVeiRota = rota.getListaTipoVeiculo().iterator();
            } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
                //populando o JavaBean
                boolean erro = false;
                int max = Integer.parseInt(request.getParameter("maxRota"));
                int maxTpVei;
                int maxPercurso;
                int maxPercursoCidade;

                for(int i = 1;i <=max; i++){
                    if(request.getParameter("id_"+i) != null){
                        rota = new Rota();
                        rota.setId(Integer.parseInt(request.getParameter("id_"+i)));
                        rota.setDescricao(request.getParameter("descricao_"+i));
                        rota.getOrigem().setIdcidade(Integer.parseInt(request.getParameter("cidadeOrigemId_"+i)));
                        rota.getDestino().setIdcidade(Integer.parseInt(request.getParameter("cidadeDestinoId_"+i)));
                        rota.setDistancia(Integer.parseInt(request.getParameter("distancia_"+i)));
                        rota.setPrazoEntrega(Integer.parseInt(request.getParameter("previsaoEntrega_"+i)));
                        rota.setTipoPrevisao(request.getParameter("tipoPrevisaoEntrega_"+i));
                        rota.getCriadoPor().setIdusuario(usu.getIdusuario());
                        rota.getAtualizadoPor().setIdusuario(usu.getIdusuario());
                        rota.setVlDiariaMotorista(Apoio.parseDouble(request.getParameter("diariaMotorista_" + i)));
                        rota.setVlPernoiteMotorista(Apoio.parseDouble(request.getParameter("pernoiteMotorista_" + i)));
                        rota.setVlAlimentacaoMotorista(Apoio.parseDouble(request.getParameter("alimentacaoMotorista_" + i)));
                        rota.setTipoDestino(request.getParameter("tipoRota_" + i));
                        rota.getAreaDestino().setId(Apoio.parseInt(request.getParameter("areaDestinoId_" + i)));
                        rota.setRotaColeta(request.getParameter("chkColeta_" + i) != null);
                        rota.setRotaTransferencia(request.getParameter("chkTransferencia_" + i) != null);
                        rota.setRotaEntrega(request.getParameter("chkEntrega_" + i) != null);
                        rota.setRotaAtiva(request.getParameter("chkAtiva_" + i) != null);
                        rota.setCodigoIntegracaoPedagio(request.getParameter("codigoIntegracaoPedagio_"+i));
                        rota.setCodigoSolicitacaoMonitoramento(Apoio.parseInt(request.getParameter("codigoSolicitacaoMonitoramento_" + i)));
                        rota.setPrazoEntregaHora(Apoio.parseInt(request.getParameter("prazoEntregaHora_" + i)));
                        
                        rota.setIdsExcluirTabelaPreco(request.getParameter("idsTabelaPrecoExcluir"));

                        maxTpVei = Integer.parseInt(request.getParameter("maxTpVei_"+i));
                        for (int j = 1; j <= maxTpVei; j++) {
                                if (request.getParameter("idRotaTpVei_" + i + "_" + j) != null) {
                                    tpVeiRota = new TipoVeiculoRota();
                                    tpVeiRota.setId(Apoio.parseInt(request.getParameter("idRotaTpVei_" + i + "_" + j)));
                                    tpVeiRota.getTipoVeiculo().setId(Apoio.parseInt(request.getParameter("tipoVeiculoId_" + i + "_" + j)));
                                    tpVeiRota.setTipoValor(request.getParameter("tipoValor_" + i + "_" + j));
                                    tpVeiRota.setConsiderarCampoCte(request.getParameter("considerarCampoCte_" + i + "_" + j));

                                    if (!tpVeiRota.getTipoValor().equals("f") && !tpVeiRota.getTipoValor().equals("k")) {
                                        tpVeiRota.setValor(Apoio.parseDouble(request.getParameter("valor1_" + i + "_" + j)));
                                    } else {
                                        tpVeiRota.setValor(Apoio.parseDouble(request.getParameter("valor2_" + i + "_" + j)));
                                        tpVeiRota.setValorMaximo(Apoio.parseDouble(request.getParameter("valorMaximo_" + i + "_" + j)));
                                    }
                                    tpVeiRota.setValorViagem2(Apoio.parseDouble(request.getParameter("valorViagem2_" + i + "_" + j)));
                                    tpVeiRota.setValorPedagio(Apoio.parseDouble(request.getParameter("valorPedagio_" + i + "_" + j)));
                                    tpVeiRota.setValorEntrega(Apoio.parseDouble(request.getParameter("valorEntrega_" + i + "_" + j)));
                                    tpVeiRota.setValorDiaria(Apoio.parseDouble(request.getParameter("valorDiaria_" + i + "_" + j)));
                                    tpVeiRota.setValorPesoExcedente(Apoio.parseDouble(request.getParameter("valorExcedente_" + i + "_" + j)));
                                    tpVeiRota.setQuantidadeEntregas(Apoio.parseInt(request.getParameter("qtdEntrega_" + i + "_" + j)));
                                    tpVeiRota.getTipoProduto().setId(Apoio.parseInt(request.getParameter("tipoProduto_" + i + "_" + j)));
                                    tpVeiRota.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("clienteTabelaId_" + i + "_" + j)));
                                    tpVeiRota.setDeduzirPedagio(Apoio.parseBoolean(request.getParameter("chkDeduzir_" + i + "_" + j)));
                                    tpVeiRota.setCarregarPedagio(Apoio.parseBoolean(request.getParameter("chkCarregarV_" + i + "_" + j)));
                                    tpVeiRota.setValorTaxaFixa(Apoio.parseDouble(request.getParameter("taxaFixa_" + i + "_" + j)));
                                    tpVeiRota.setValorMinimo(Apoio.parseDouble(request.getParameter("valorMinimo_" + i + "_" + j)));
                                    tpVeiRota.setCalcularPercentualNFePorEntrega(Apoio.parseBoolean(request.getParameter("chkNFePorEntrega_" + i + "_" + j)));

                                    rota.getListaTipoVeiculo().add(tpVeiRota);
                                }
                            }

                        maxPercurso = Integer.parseInt(request.getParameter("maxPercurso_"+i));
                        for(int j = 1; j <= maxPercurso; j++){
                            if(request.getParameter("idPercursoRota_"+i+"_"+j) != null){
                                percurso = new Percurso();
                                percurso.setId(Integer.parseInt(request.getParameter("idPercursoRota_"+i+"_"+j)));
                                percurso.setDescricao(request.getParameter("descricaoPercurso_"+i+"_"+j));
                                
                                maxPercursoCidade = Integer.parseInt(request.getParameter("maxPercursoCidade_"+i+"_"+j));
                                for(int p = 1; p <= maxPercursoCidade; p++){
                                    if(request.getParameter("idPercursoCidadeRota_"+i+"_"+j+"_"+p) != null){
                                        percCidade = new PercursoCidade();

                                        percCidade.setId(Integer.parseInt(request.getParameter("idPercursoCidadeRota_"+i+"_"+j+"_"+p)));
                                        percCidade.setOrdem(Integer.parseInt(request.getParameter("ordemPercurso_"+i+"_"+j+"_"+p)));
                                        percCidade.getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidadePercurso_"+i+"_"+j+"_"+p)));
                                        percCidade.setCodigoSolicitacaoMonitoramento(Apoio.parseInt(request.getParameter("codigoSolicitacaoMonitoramento_" + i + "_" + j + "_" + p)));
                                        
                                        percurso.getCidades().add(percCidade);
                                    }
                                }
                            }
                            rota.getPercursos().add(percurso);
                        }

                        cadRt.setRota(rota);
                        erro = !((acao.equals("incluir") && nivelUser >= 3)? cadRt.Inclui() : cadRt.Atualiza());
                    }
                    
                }

                
//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type="text/javascript"><%
      if (erro) {
          acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadRt.getErros())%>');
    <%} else {%>
      window.opener.document.location.replace("ConsultaControlador?codTela=47");
    <%}%>
        
        window.close();
        
</script>

<%
}else if(acao.equalsIgnoreCase("AjaxRemoverPercurso")){    
    Auditoria auditoria = new Auditoria();
    auditoria.setIp(request.getRemoteHost());
    auditoria.setAcao("Remover Percuso");
    auditoria.setRotina("Alterar Rota");
    auditoria.setUsuario(Apoio.getUsuario(request));
    auditoria.setModulo("WebTrans Rotas");    
    
    Percurso per = new Percurso();
    per.setId(Apoio.parseInt(request.getParameter("percursoId")));
    String retorno = "";
    try {
        
        CadRota.removerPercurso(per, usu.getConexao(), auditoria);
        
        } catch (SQLException ex) {
            retorno = ex.getMessage();
        } catch (nucleo.excecao.ExcecaoConexao ex) {
            retorno = ex.getMessage();
        }finally{
            response.getWriter().append(retorno);
            response.getWriter().close();
        }
    
}else if(acao.equalsIgnoreCase("AjaxRemoverPercursoCidade")){
    Auditoria auditoriaCidade = new Auditoria();
    auditoriaCidade.setIp(request.getRemoteHost());
    auditoriaCidade.setAcao("Remover Percuso Cidade");
    auditoriaCidade.setRotina("Alterar Rota");
    auditoriaCidade.setUsuario(Apoio.getUsuario(request));
    auditoriaCidade.setModulo("WebTrans Rotas");    
    
    PercursoCidade per = new PercursoCidade();
    per.setId(Apoio.parseInt(request.getParameter("percursoCidadeId")));
    CadRota.removerPercursoCidade(per, usu.getConexao(), auditoriaCidade);
}else if(acao.equalsIgnoreCase("carregarRotaPercursoAjax")){
    BeanUsuario usuario = Apoio.getUsuario(request);
    CadRota cadRota = new CadRota(usuario.getConexao());
    cadRota.getRota().setId(Apoio.parseInt(request.getParameter("rota")));
    cadRota.setExecutor(usuario);

    cadRota.LoadAllPropertys();

    XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
    xstream.setMode(XStream.NO_REFERENCES);
    xstream.alias("rota", Rota.class);
    xstream.alias("percurso", Percurso.class);
    String json = xstream.toXML(cadRota.getRotaPercurso());

    response.getWriter().append(json);
    response.getWriter().close();
}else if(acao.equalsIgnoreCase("carregarRotaOrigemDestinoAjax")){
    BeanCidade origem = new BeanCidade();
    BeanCidade destino = new BeanCidade();
    BeanUsuario usuario = Apoio.getUsuario(request);
    CadRota cadRota = new CadRota(usuario.getConexao());

    origem.setIdcidade(Apoio.parseInt(request.getParameter("origem_id")));
    destino.setIdcidade(Apoio.parseInt(request.getParameter("destino_id")));
    cadRota.setExecutor(usuario);
    cadRota.setRota(cadRota.getRotaOrigemDestino(origem, destino));

    cadRota.LoadAllPropertys();

    XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
    xstream.setMode(XStream.NO_REFERENCES);
    xstream.alias("rota", Rota.class);
    String json = xstream.toXML(cadRota);

    response.getWriter().append(json);
    response.getWriter().close();
 }

            //variavel usada para saber se o usuario esta editando
            carregarota = (cadRt != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">
    
    //-------------  Tipo Veiculo Km ------------ Inicio
    jQuery.noConflict();
     var countRota = 0;
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria','divAuditoria');   
    
    var countTpVeiKm = 0;
    
    var listaConsiderarValor = new Array();
    var countConsiderarValor = 0;
    
    listaConsiderarValor[++countConsiderarValor] = new Option('tp','Pelo total da prestação');
    listaConsiderarValor[++countConsiderarValor] = new Option('fp','Pelo frete peso');
    listaConsiderarValor[++countConsiderarValor] = new Option('fv','Pelo frete valor');
    
    function TipoVeiculoRota(id, tipoVeiculoId, tipoVeiculo, valor, valorMaximo, tipoValor, valor_viagem_2, valor_pedagio, valor_entrega, qtd_entregas, 
    tiposProdutos, tipoProdutoId, clienteTabela, clienteTabelaId, valorDiaria, valorPesoExcedente, considerarCampoCte,is_deduzir_pedagio,is_carregar_pedagio_ctes, taxaFixa, valorMinimo,
                             calcularPercentualNFePorEntrega) {
    //validação
    this.id=(id==null || id==undefined?"0":id);
    this.tipoVeiculoId=(tipoVeiculoId==null || tipoVeiculoId==undefined?"0":tipoVeiculoId);
    this.tipoVeiculo=(tipoVeiculo==null || tipoVeiculo==undefined?"":tipoVeiculo);
    this.valor=(valor==null || valor==undefined?"0":valor);
    this.valorMaximo =(valorMaximo==null || valorMaximo==undefined?"0":valorMaximo);
    this.tipoValor =(tipoValor==null || tipoValor==undefined?"p":tipoValor);
    this.valor_viagem_2 =(valor_viagem_2==null || valor_viagem_2==undefined?"0":valor_viagem_2);
    this.valor_pedagio =(valor_pedagio==null || valor_pedagio==undefined?"0":valor_pedagio);
    
    this.valor_entrega =(valor_entrega==null || valor_entrega==undefined?"0":valor_entrega);
    this.qtd_entrega =(qtd_entregas==null || qtd_entregas==undefined?"0":qtd_entregas);
    this.tipoProdutoId =(tipoProdutoId==null || tipoProdutoId==undefined?"0":tipoProdutoId);
    if (tiposProdutos==null || tiposProdutos==undefined){
       this.tiposProdutos = new Array();
       var qtdTpProd = 0;
       this.tiposProdutos[qtdTpProd] = new SelectProdutos('0', 'Não informado', true);
       <%ResultSet product_types = TipoProduto.all(Apoio.getConnectionFromUser(request),0,false,0);
       while (product_types.next()) {%>
          qtdTpProd++;
          this.tiposProdutos[qtdTpProd] = new SelectProdutos('<%=product_types.getInt("id")%>', '<%=product_types.getString("descricao")%>', false);
       <%}%>
    }
    this.clienteTabelaId =(clienteTabelaId==null || clienteTabelaId==undefined?"0":clienteTabelaId);
    this.clienteTabela =(clienteTabela==null || clienteTabela==undefined?"":clienteTabela);
    this.valorDiaria =(valorDiaria==null || valorDiaria==undefined?"0":valorDiaria);
    this.valorPesoExcedente =(valorPesoExcedente==null || valorPesoExcedente==undefined?"0":valorPesoExcedente);
    this.considerarCampoCte =(considerarCampoCte==null || considerarCampoCte==undefined ? "" : considerarCampoCte);
    this.is_deduzir_pedagio = (is_deduzir_pedagio==null || is_deduzir_pedagio==undefined?false:is_deduzir_pedagio);
    this.is_carregar_pedagio_ctes = (is_carregar_pedagio_ctes==null || is_carregar_pedagio_ctes==undefined?false:is_carregar_pedagio_ctes);
    this.taxaFixa = (taxaFixa==null || taxaFixa==undefined?"0":taxaFixa);
    this.valorMinimo = (valorMinimo == null || valorMinimo == undefined ? "0" : valorMinimo);
    this.calcularPercentualNFePorEntrega = (calcularPercentualNFePorEntrega == null || calcularPercentualNFePorEntrega == undefined ? false : calcularPercentualNFePorEntrega);
}

    
    
    //-------------  Tipo Veiculo Km ------------ Fim
    // @@@@@@@@@ ROTA  @@@@@@@@@@@ INICIO
   
    function addRota(rota, iscarrega){
        countRota++;
        countTpVeiKm = 0;
        var tpVei ;
        if(rota == null || rota == undefined){
            rota = new Rota();
        }

        if(countRota != 1 && !iscarrega && $("cidadeOrigem_"+(countRota-1)) != null){
            rota.origem = $("cidadeOrigem_"+(countRota-1)).value;
            rota.origemId = $("cidadeOrigemId_"+(countRota-1)).value;
            rota.ufOrigem = $("ufOrigem_"+(countRota-1)).value;
        }


        iscarrega =(iscarrega==null || iscarrega==undefined?true:iscarrega);
        //campos
        var hid1_ = Builder.node("INPUT",{type:"hidden",id:"id_"+countRota, name:"id_"+countRota, value: rota.id});
        var hid4_ = Builder.node("INPUT",{type:"hidden",id:"maxPercurso_"+countRota, name:"maxPercurso_"+countRota, value: 0});
        var hid2_ = Builder.node("INPUT",{type:"hidden",id:"cidadeDestinoId_"+countRota, name:"cidadeDestinoId_"+countRota, value: rota.destinoId});
        var hid3_ = Builder.node("INPUT",{type:"hidden",id:"cidadeOrigemId_"+countRota, name:"cidadeOrigemId_"+countRota, value: rota.origemId});
        var hidAreaId_ = Builder.node("INPUT",{type:"hidden",id:"areaDestinoId_"+countRota, name:"areaDestinoId_"+countRota, value: rota.areaDestinoId});
        var inp1_ = Builder.node("INPUT",{type:"text",id:"descricao_"+countRota, name:"descricao_"+countRota, size:"25", maxLength:"22", value: rota.descricao, className:"fieldMin"});
        var inp2_ = Builder.node("INPUT",{type:"text",id:"distancia_"+countRota, name:"distancia_"+countRota, size:"8", maxLength:"8", value: rota.distancia, className:"fieldMin", onchange: "seNaoIntReset($('distancia_"+countRota+"'), 0);validarValorNegativo($('distancia_"+countRota+"'),"+countRota+");"});
        var inp3_ = Builder.node("INPUT",{type:"text",id:"previsaoEntrega_"+countRota, name:"previsaoEntrega_"+countRota,size:"2", maxLength:"5", value: rota.prazoEntrega, className:"fieldMin", onChange: "seNaoIntReset($('previsaoEntrega_"+countRota+"'), 0);"});
        var lab1_ = Builder.node("LABEL"," Dias: ");
        var slc1_ = Builder.node("SELECT",{id:"tipoPrevisaoEntrega_"+countRota, name:"tipoPrevisaoEntrega_"+countRota, className:"fieldMin"},[
            Builder.node('OPTION', {value:'U'}, 'Úteis'),
            Builder.node('OPTION', {value:'C'}, 'Corridos')
        ]);
        var slcTipoRota_ = Builder.node("SELECT",{id:"tipoRota_"+countRota, name:"tipoRota_"+countRota, className:"fieldMin", onchange:"selecionaTipoRota ("+countRota+");"},[
            Builder.node('OPTION', {value:'c'}, 'Por Cidade'),
            Builder.node('OPTION', {value:'a'}, 'Por Área')
        ]);

        var inp4_ = Builder.node("INPUT",{type:"text",id:"cidadeOrigem_"+countRota, name:"cidadeOrigem_"+countRota, size:"17", maxLength:"30", value: rota.origem, className:"inputReadOnly8pt", readOnly:true});
        var inp5_ = Builder.node("INPUT",{type:"text",id:"cidadeDestino_"+countRota, name:"cidadeDestino_"+countRota, size:"17", maxLength:"30", value: rota.destino, className:"inputReadOnly8pt", readOnly:true});
        var brMdfe_ = Builder.node("BR",{id:"brMdfe_"+countRota, name:"brMdfe_"+countRota});
        var lbMdfe_ = Builder.node("LABEL",{id:"lbMdfe_"+countRota, name:"lbMdfe_"+countRota},"Base MDF-e:");
        var inp6_ = Builder.node("INPUT",{type:"text",id:"ufOrigem_"+countRota, name:"ufOrigem_"+countRota, size:"1", maxLength:"2", value: rota.ufOrigem, className:"inputReadOnly8pt", readOnly:true});
        var inp7_ = Builder.node("INPUT",{type:"text",id:"ufDestino_"+countRota, name:"ufDestino_"+countRota, size:"1", maxLength:"2", value: rota.ufDestino, className:"inputReadOnly8pt", readOnly:true});
        var inpArea_ = Builder.node("INPUT",{type:"text",id:"areaDestino_"+countRota, name:"areaDestino_"+countRota, size:"21", maxLength:"30", value: rota.areaDestino, className:"inputReadOnly8pt", readOnly:true});
        var inp8_ = Builder.node("INPUT",{type:"text",id:"diariaMotorista_"+countRota, name:"diariaMotorista_"+countRota, size:"6", maxLengh:"10", value: colocarVirgula(rota.vlDiariaMotorista), onkeypress:"mascara(this, reais)", className:"fieldMin styleValor", onchange:"seNaoFloatReset(this,'0.00');getVlLiquido();getPlcustoPadrao();", onblur:"tirarLinha();"});
        var inp9_ = Builder.node("INPUT",{type:"text",id:"pernoiteMotorista_"+countRota, name:"pernoiteMotorista_"+countRota, size:"6", maxLengh:"10", value: colocarVirgula(rota.vlPernoiteMotorista), onkeypress:"mascara(this, reais)", className:"fieldMin styleValor", onchange:"seNaoFloatReset(this,'0.00');getVlLiquido();getPlcustoPadrao();", onblur:"tirarLinha();"});
        var inp10_ = Builder.node("INPUT",{type:"text",id:"alimentacaoMotorista_"+countRota, name:"alimentacaoMotorista_"+countRota, size:"6", maxLengh:"10", value: colocarVirgula(rota.vlAlimentacaoMotorista), onkeypress:"mascara(this, reais)", className:"fieldMin styleValor", onchange:"seNaoFloatReset(this,'0.00');getVlLiquido();getPlcustoPadrao();", onblur:"tirarLinha();"});
        var bot1_ = Builder.node("INPUT",{className:"inputBotaoMin", id:"localizaCidadeOrigem_"+countRota, name:"localizaCidadeOrigem_"+countRota, type:"button", value:"...",onClick:"localizarCidadeOrigem(this);"});
        var bot2_ = Builder.node("INPUT",{className:"inputBotaoMin", id:"localizaCidadeDestino_"+countRota, name:"localizaCidadeDestino_"+countRota, type:"button", value:"...",onClick:"localizarCidadeDestino(this);"});
        var botArea_ = Builder.node("INPUT",{className:"inputBotaoMin", id:"localizaAreaDestino_"+countRota, name:"localizaAreaDestino_"+countRota, type:"button", value:"...",onClick:"localizarAreaDestino(this);"});
        var _img3 = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerRota("+countRota+");"});
        var _img4 = Builder.node("IMG",{src:"img/plus.jpg", id:"img_"+countRota, onClick:"chkTipoVeiculo(this);"});
        var _img6 = Builder.node("IMG",{src:"img/add.gif", id:"imgAddPerc_"+countRota, onClick:"addPercurso("+null+","+countRota+");", title:"Adicionar um percurso."});
        var _imgVei = Builder.node("IMG",{src:"img/add.gif", id:"imgAddVei_"+countRota, onClick:"addNewTipoVeiculo(this);", title:"Adicionar um tipo de veículo."});
        var chkCol_ = Builder.node("INPUT",{type:"checkbox",id:"chkColeta_"+countRota, name:"chkColeta_"+countRota});
        var chkTra_ = Builder.node("INPUT",{type:"checkbox",id:"chkTransferencia_"+countRota, name:"chkTransferencia_"+countRota});
        var chkEnt_ = Builder.node("INPUT",{type:"checkbox",id:"chkEntrega_"+countRota, name:"chkEntrega_"+countRota});
        var chkAtiva_ = Builder.node("INPUT",{type:"checkbox",id:"chkAtiva_"+countRota, name:"chkAtiva_"+countRota});
        
        var inp11_ = Builder.node("INPUT",{type:"text",id:"codigoIntegracaoPedagio_"+countRota, name:"codigoIntegracaoPedagio_"+countRota, size:"5", maxLength:"20", value: rota.codigoIntegracaoPedagio, className:"fieldMin"});
        var lab2_ = Builder.node("LABEL","Código Integração Pedágio:");
        var brLab = Builder.node("BR");
        //tds
        
        var tdImgMais = Builder.node("TD",{align:"center"});
        var tdExcluiRota_ = Builder.node("TD",{align:"center"});
        var tdDescRota = Builder.node("TD",{});
        var tdOrigem = Builder.node("TD",{});
        var tdDestino = Builder.node("TD",{});
        var tdDistancia = Builder.node("TD",{align:"left"});
        var tdPrevisaoEntrega = Builder.node("TD",{align:"left"});
        var tdColeta = Builder.node("TD",{align:"center"});
        var tdDiaria = Builder.node("TD",{align:"left"});
        var tdPernoite = Builder.node("TD",{align:"left"});
        var tdEntrega = Builder.node("TD",{align:"center"});
        var tdAlim = Builder.node("TD",{align:"left"});
        var tdTransf = Builder.node("TD",{align:"center"});
        var tdAtiva = Builder.node("TD",{align:"center"});
        //inserindo os campos nas tds
        if(iscarrega){
            tdExcluiRota_.appendChild(_img3);
        }
        tdImgMais.appendChild(_img4);
        tdDescRota.appendChild(hid1_);
        tdDescRota.appendChild(hid4_);
        tdDescRota.appendChild(hid2_);
        tdDescRota.appendChild(hid3_);
        tdDescRota.appendChild(hidAreaId_);
        tdDescRota.appendChild(inp1_);
        tdDescRota.appendChild(brLab);
        tdDescRota.appendChild(lab2_);
        tdDescRota.appendChild(inp11_);
        tdOrigem.appendChild(inp4_);
        tdOrigem.appendChild(inp6_);
        tdOrigem.appendChild(bot1_);
        tdDestino.appendChild(slcTipoRota_);
        tdDestino.appendChild(inpArea_);
        tdDestino.appendChild(botArea_);
        tdDestino.appendChild(brMdfe_);
        tdDestino.appendChild(lbMdfe_);
        tdDestino.appendChild(inp5_);
        tdDestino.appendChild(inp7_);
        tdDestino.appendChild(bot2_);
        tdDistancia.appendChild(inp2_);
        tdPrevisaoEntrega.appendChild(inp3_);
        tdPrevisaoEntrega.appendChild(lab1_);
        tdPrevisaoEntrega.appendChild(slc1_);
        tdColeta.appendChild(chkCol_);
        tdTransf.appendChild(chkTra_);
        tdEntrega.appendChild(chkEnt_);
        tdDiaria.appendChild(inp8_);
        tdPernoite.appendChild(inp9_);
        tdAlim.appendChild(inp10_);
        tdAtiva.appendChild(chkAtiva_);

        //trs
        var classe = ((countRota % 2) != 0 ? 'CelulaZebra2' : 'CelulaZebra1');
        var trRota_ = Builder.node("TR",{className:classe, id:"trRota_"+countRota});
        //inserindo as tds nas determinadas trs
        trRota_.appendChild(tdImgMais);
        trRota_.appendChild(tdExcluiRota_);
        trRota_.appendChild(tdDescRota);
        trRota_.appendChild(tdOrigem);
        trRota_.appendChild(tdDestino);
        trRota_.appendChild(tdDistancia);
        trRota_.appendChild(tdPrevisaoEntrega);
        trRota_.appendChild(tdColeta);
        trRota_.appendChild(tdTransf);
        trRota_.appendChild(tdEntrega);
        trRota_.appendChild(tdDiaria);
        trRota_.appendChild(tdPernoite);
        trRota_.appendChild(tdAlim);
        trRota_.appendChild(tdAtiva);

        //Montando a segunda TR com os dados do tipo de veiculo e Percurso
        var trSecundaria_ = Builder.node("TR",{id:"trSecundaria_"+countRota, style:"display:none;"});
        var tdSec1_ = Builder.node("TD",{colSpan:"8", style:"vertical-align:top;"});
        var tdSec2_ = Builder.node("TD",{colSpan:"6", style:"vertical-align:top;"});

        //Criando a parte dos tipos de veiculos
        var tblVei = Builder.node("TABLE",{width: "100%"});
        var tbdVei = Builder.node("TBODY",{id:"tbTipoVeiculo_"+countRota, name:"tbTipoVeiculo_"+countRota});
        var trCabVei = Builder.node("TR", {className:""});
        var tdCabAdd = Builder.node("TD",{className:"tabela", colSpan:"9"},'Tabela de preço por tipo de veículo');
        
        trCabVei.appendChild(tdCabAdd);
        tbdVei.appendChild(trCabVei);
        
        
        var trTit = Builder.node("TR", {className:""});
        var tdTitTipo = Builder.node("TD",{width:"11%", className: "tabela"});
        var lbTipoVei = Builder.node("LABEL",{},'Tipo Veículo');
        var inpMaxTpVei = Builder.node("input",{type:"hidden", id:"maxTpVei_"+countRota, name:"maxTpVei_"+countRota, value:0});
        var tdTitCli = Builder.node("TD",{width:"18%", className: "tabela"},'Cliente');
        var tdTitProd = Builder.node("TD",{width:"13%", className: "tabela"},'Produto/Oper.');
        var tdTitTabe = Builder.node("TD",{width:"9%", className: "tabela"},'Tabela');
        var tdTitValor = Builder.node("TD",{width:"14%", className: "tabela"},'Valor');
        var tdTitViag = Builder.node("TD",{width:"10%", className: "tabela"},'2ª Viagem');
        var img2Viag = Builder.node("img",{src:"img/ajuda.png", border:"0", title:"Clique aqui pra saber a utilidade desse campo.", align:"absbottom", className:"imagemLink", onClick:"javascript:getAjudaViagem2();"});
        var tdTaxaFixa = Builder.node("TD",{width:"7%", className: "tabela"},'Taxa Fixa');
        var tdTitTaxa = Builder.node("TD",{width:"14%", className: "tabela"},'Taxa de Entrega');
        var tdTitDiaria = Builder.node("TD",{width:"6%", className: "tabela"},'Diária');

        tdTitTipo.appendChild(_imgVei);
        tdTitTipo.appendChild(inpMaxTpVei);
        tdTitTipo.appendChild(lbTipoVei);
        tdTitViag.appendChild(img2Viag);
        
        trTit.appendChild(tdTitTipo);
        trTit.appendChild(tdTitCli);
        trTit.appendChild(tdTitProd);
        trTit.appendChild(tdTitTabe);
        trTit.appendChild(tdTitValor);
        trTit.appendChild(tdTitViag);
        trTit.appendChild(tdTaxaFixa);
       // trTit.appendChild(tdTitPeda);
        trTit.appendChild(tdTitTaxa);
        trTit.appendChild(tdTitDiaria);
        tbdVei.appendChild(trTit);
        tblVei.appendChild(tbdVei);
        tdSec1_.appendChild(tblVei);
        
        //Criando a parte dos percursos
        var tblPer = Builder.node("TABLE",{width: "100%"});
        var tbdPer = Builder.node("TBODY",{id:"tbPercurso_"+countRota, name:"tbPercurso_"+countRota});
        var trCabPer = Builder.node("TR", {className:""});
        var tdCabAddPer = Builder.node("TD",{width:"7%", className:"tabela"});
        var tdCabPer = Builder.node("TD",{width:"93%", className:"tabela"},'Percursos');
        
        tdCabAddPer.appendChild(_img6);
        trCabPer.appendChild(tdCabAddPer);
        trCabPer.appendChild(tdCabPer);
        tbdPer.appendChild(trCabPer);
        tblPer.appendChild(tbdPer);

        tdSec2_.appendChild(tblPer);
        
        
        
        trSecundaria_.appendChild(tdSec1_);
        trSecundaria_.appendChild(tdSec2_);
        
        var tr2_ = Builder.node("TR",{id:"trTipoVeiculos_"+countRota});
        var tr3_ = Builder.node("TR",{id:"trPercurso_"+countRota});
        
        // TR de Gerenciamento de Risco
        var trPGR_ = Builder.node("TR",{className:"tabela"});
        var tdPGR_ = Builder.node("TD",{colspan:"15"});
        var boldDescricaoPGR_ = Builder.node("B");
        var lbDescricaoPGR_ = Builder.node("DIV",{align:"center"},'Gerenciador de Risco');
        
        var trPGR1_ = Builder.node("TR");
        var trPGR2_ = Builder.node("TR",{id:"trPGR_"+countRota});
        // id:"maxTpVei_"+countRota, name:"maxTpVei_"+countRota,
        var tdCodigoPGR_ = Builder.node("TD",{className:"CelulaZebra1", colspan:"3"});
        var lbCodigoPGR_ = Builder.node("DIV",{},'Código da rota');
        var tdPrazoPGR_ = Builder.node("TD",{className:"CelulaZebra1", colspan:"1"});
        var lbPrazoPGR_ = Builder.node("DIV",{},'Prazo p/ Entrega em horas');
        var tdCodigoPGR2_ = Builder.node("TD",{className:"CelulaZebra2", colspan:"3"});
        var tdPrazoPGR2_ = Builder.node("TD",{className:"CelulaZebra2", colspan:"1"});
        var tdFillerPGR_ = Builder.node("TD",{className:"CelulaZebra1", colspan:"10"});
        var tdFillerPGR2_ = Builder.node("TD",{className:"CelulaZebra2", colspan:"10"});
        var campoCodigoPGR_ = Builder.node("INPUT", {
            type: "text",
            id: "codigoSolicitacaoMonitoramento_" + countRota,
            name: "codigoSolicitacaoMonitoramento_" + countRota,
            size:"15",
            maxLengh: "10",
            className: "fieldMin styleValor",
            value: rota.codigoSolicitacaoMonitoramento,
            onchange: "seNaoIntReset($('codigoSolicitacaoMonitoramento_" + countRota + "'), 0);"
        });
        var campoPrazoPGR_ = Builder.node("INPUT", {
            type: "text",
            id: "prazoEntregaHora_" + countRota,
            name: "prazoEntregaHora_" + countRota,
            size:"15",
            maxLengh: "10",
            className: "fieldMin styleValor",
            value: rota.prazoEntregaHora,
            onchange: "seNaoIntReset($('prazoEntregaHora_" + countRota + "'), 0);"
        });
        
        boldDescricaoPGR_.appendChild(lbDescricaoPGR_);
        tdPGR_.appendChild(boldDescricaoPGR_);
        trPGR_.appendChild(tdPGR_);
        
        tdCodigoPGR_.appendChild(lbCodigoPGR_);
        trPGR1_.appendChild(tdCodigoPGR_);
        
        tdPrazoPGR_.appendChild(lbPrazoPGR_);
        trPGR1_.appendChild(tdPrazoPGR_);
        
        trPGR1_.appendChild(tdFillerPGR_);
        
        tdCodigoPGR2_.appendChild(campoCodigoPGR_);
        tdPrazoPGR2_.appendChild(campoPrazoPGR_);
        
        trPGR2_.appendChild(tdCodigoPGR2_);
        trPGR2_.appendChild(tdPrazoPGR2_);
        trPGR2_.appendChild(tdFillerPGR2_);
        //inserindo outra tabela que possuirá a tabela com os tipos de veiculos

        $("tabRota").appendChild(trRota_);
        $("tabRota").appendChild(trPGR_);
        $("tabRota").appendChild(trPGR1_);
        $("tabRota").appendChild(trPGR2_);
        $("tabRota").appendChild(trSecundaria_);
        $("tabRota").appendChild(tr3_);

        tr2_.style.display = "none";
        slc1_.value= rota.tipoPrazoEntrega;
        slcTipoRota_.value = rota.tipoRota;

        $('chkColeta_'+countRota).checked = rota.isRotaColeta;
        $('chkTransferencia_'+countRota).checked = rota.isRotaTransferencia;
        $('chkEntrega_'+countRota).checked = rota.isRotaEntrega;
        $('chkAtiva_'+countRota).checked = rota.isRotaAtiva;
        
        selecionaTipoRota(countRota);

        if(iscarrega){
            <%while(rs.next()){%>
                tpVei = new TipoVeiculoRota(0, '<%=rs.getInt("id")%>', '<%=rs.getString("descricao")%>', "0.00");
                addTipoVeiculo(tpVei);
            <%}%>
        }
        $("maxRota").value = countRota;
        
    }

    function setDefault(){
        var rota = new Rota();
        var tpVeiRota;
        var percurso;
        var percursoCidade;
        var linhaPercurso = 0;
        
        <%if(acao.equals("editar")){%>
            $("trNovo").style.display="none";

            rota.id = '<%=rota.getId()%>';
            rota.descricao = '<%=rota.getDescricao()%>';
            rota.distancia = '<%=rota.getDistancia()%>';
            rota.prazoEntrega  = '<%=rota.getPrazoEntrega()%>';
            rota.tipoPrazoEntrega  = '<%=rota.getTipoPrevisao()%>';
            rota.origem  = '<%=rota.getOrigem().getDescricaoCidade()%>';
            rota.origemId  = '<%=rota.getOrigem().getIdcidade()%>';
            rota.ufOrigem = '<%=rota.getOrigem().getUf()%>';
            rota.ufDestino = '<%=rota.getDestino().getUf()%>';
            rota.destino  = '<%=rota.getDestino().getDescricaoCidade()%>';
            rota.destinoId  = '<%=rota.getDestino().getIdcidade()%>';
            rota.vlDiariaMotorista = '<%=rota.getVlDiariaMotorista()%>';
            rota.vlPernoiteMotorista = '<%=rota.getVlPernoiteMotorista()%>';
            rota.vlAlimentacaoMotorista = '<%=rota.getVlAlimentacaoMotorista()%>';
            rota.tipoRota = '<%=rota.getTipoDestino()%>';
            rota.areaDestinoId = '<%=rota.getAreaDestino().getId()%>';
            rota.areaDestino = '<%=rota.getAreaDestino().getSigla()%>';
            rota.isRotaColeta = <%=rota.isRotaColeta()%>;
            rota.isRotaTransferencia = <%=rota.isRotaTransferencia()%>;
            rota.isRotaEntrega = <%=rota.isRotaEntrega()%>;
            rota.isRotaAtiva = <%=rota.isRotaAtiva()%>;
            rota.codigoIntegracaoPedagio = "<%=rota.getCodigoIntegracaoPedagio()%>";
            rota.codigoSolicitacaoMonitoramento = "<%= rota.getCodigoSolicitacaoMonitoramento()%>";
            rota.prazoEntregaHora = "<%= rota.getPrazoEntregaHora()%>";
            addRota(rota, false);
            
            <%while(iTpVeiRota.hasNext()){
                tpVeiRota = (TipoVeiculoRota) iTpVeiRota.next(); %>
                tpVeiRota = new TipoVeiculoRota();
                tpVeiRota.id = <%=tpVeiRota.getId()%>;
                tpVeiRota.tipoVeiculo = '<%=tpVeiRota.getTipoVeiculo().getDescricao()%>';
                tpVeiRota.tipoVeiculoId = <%=tpVeiRota.getTipoVeiculo().getId()%>;
                tpVeiRota.valor = <%=tpVeiRota.getValor()%>;
                tpVeiRota.valorMaximo = <%=tpVeiRota.getValorMaximo()%>;
                tpVeiRota.tipoValor = '<%=tpVeiRota.getTipoValor()%>';                
                tpVeiRota.valor_viagem_2 = '<%=tpVeiRota.getValorViagem2()%>';
                tpVeiRota.valor_pedagio = '<%=tpVeiRota.getValorPedagio()%>';
                tpVeiRota.valor_entrega = '<%=tpVeiRota.getValorEntrega()%>';
                tpVeiRota.qtd_entrega = '<%=tpVeiRota.getQuantidadeEntregas()%>';
                tpVeiRota.tipoProdutoId = '<%=tpVeiRota.getTipoProduto().getId()%>';
                tpVeiRota.clienteTabelaId = '<%=tpVeiRota.getCliente().getIdcliente()%>';
                tpVeiRota.clienteTabela = '<%=tpVeiRota.getCliente().getRazaosocial()%>';
                tpVeiRota.valorDiaria = '<%=tpVeiRota.getValorDiaria()%>';
                tpVeiRota.valorPesoExcedente = '<%=tpVeiRota.getValorPesoExcedente()%>';
                tpVeiRota.considerarCampoCte = '<%=tpVeiRota.getConsiderarCampoCte()%>';
                tpVeiRota.is_deduzir_pedagio = <%=tpVeiRota.isDeduzirPedagio()%>;
                tpVeiRota.is_carregar_pedagio_ctes = <%=tpVeiRota.isCarregarPedagio()%>;
                tpVeiRota.taxaFixa = <%=tpVeiRota.getValorTaxaFixa()%>;
                tpVeiRota.valorMinimo = <%=tpVeiRota.getValorMinimo()%>;
                tpVeiRota.calcularPercentualNFePorEntrega = <%=tpVeiRota.isCalcularPercentualNFePorEntrega()%>;
                addTipoVeiculo(tpVeiRota);
                slcTipoValor(countRota, countTpVeiKm);
            <%}%>

             <%for (Percurso perc : rota.getPercursos()) {%>
                 ++linhaPercurso;
                 percurso = new Percurso();
                 percurso.id = '<%=perc.getId()%>';
                 percurso.descricao = '<%=perc.getDescricao()%>';
                 
                 addPercurso(percurso);

                 <%for (PercursoCidade perCid : perc.getCidades()) {%>
                     percursoCidade = new PercursoCidade();
                     percursoCidade.id = '<%=perCid.getId()%>';
                     percursoCidade.ordem = '<%=perCid.getOrdem()%>';
                     percursoCidade.idCidade = '<%=perCid.getCidade().getIdcidade()%>';
                     percursoCidade.cidade = '<%=perCid.getCidade().getDescricaoCidade()%>';
                     percursoCidade.uf = '<%=perCid.getCidade().getUf()%>';
                     percursoCidade.codigoSolicitacaoMonitoramento = '<%= perCid.getCodigoSolicitacaoMonitoramento()%>';

                     addPercursoCidade(percursoCidade, null, linhaPercurso);
                 <%}%>
             <%}%>

            
        <%}else{%>
            addRota();
        <%}%>
    }

    var carregarota = '<%= carregarota %>';
    var data = "<%=Apoio.getDataAtual()%>";
</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro Rotas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
            
            input[id^="valor1_"],
            input[id^="valor2_"] {
                display: block;
            }
        </style>
    </head>

    <body onLoad="setDefault();setDataAuditoria();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
        <form method="post"  id="formulario" target="pop">
            <img src="img/banner.gif" >
            <input type="hidden" name="tipo_veiculo_id" id="tipo_veiculo_id" value="0">
            <input type="hidden" name="tipo_veiculo_descricao" id="tipo_veiculo_descricao" value="">
            <input type="hidden" name="linhaRota" id="linhaRota" value="0">
            <input type="hidden" name="linhaPercurso" id="linhaPercurso" value="0">
            <input type="hidden" name="linhaPercursoCidade" id="linhaPercursoCidade" value="0">
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
            <input type="hidden" name="cid_origem" id="cid_origem" value="">
            <input type="hidden" name="uf_origem" id="uf_origem" value="">
            <input type="hidden" name="cid_destino" id="cid_destino" value="">
            <input type="hidden" name="uf_destino" id="uf_destino" value="">
            <input type="hidden" name="area_id" id="area_id" value="0">
            <input type="hidden" name="sigla_area" id="sigla_area" value="">
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="con_rzs" id="con_rzs" value="">
            <input type="hidden" name="con_cnpj" id="con_cnpj" value="">
           
        <br>
        <table width="98%" align="center" class="bordaFina" >
            <tr >
                <td width="100%"><div align="left"><b>Cadastro de Rotas</b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="15%"><input name="exclui" type="button" class="botoes" id="exclui" value="Excluir" onclick="tryRequestToServer(function(){excluir(<%=cadRt.getRota().getId()%>);});"></td>
                 <input type="hidden" name="idRota" id="idRota" value="<%=cadRt.getRota().getId()%>">
                 <input type="hidden" name="idsTabelaPrecoExcluir" id="idsTabelaPrecoExcluir" value="">
                    <%}%>
                <td width="15%" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:tryRequestToServer(function(){voltar();});"></td>
            </tr>
        </table>
        <br>
        <table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="4" align="center">Dados principais</td>
            </tr>
            <tr>
                <td>
                    <table width="100%" class="bordaFina">
                        <tbody id="tabRota">
                            <tr>
                                <td class="CelulaZebra1" colspan="8"></td>
                                <td class="CelulaZebra1" colspan="3"><b><div align="center">Utilizar rota para</div></b></td>
                                <td class="CelulaZebra1" colspan="3"><b><div align="center">Valores para ADV</div></b></td>
                            </tr>
                            <tr>
                                <td class="CelulaZebra1" width="2%" ><input type="hidden" id="maxRota"name="maxRota" value="0"></td>
                                <td class="CelulaZebra1" width="2%" >
                                    <img src="img/add.gif" id="trNovo" border="0" class="imagemLink " title="Adicionar uma nova rota" onClick="addRota();">
                                </td>
                                <td class="CelulaZebra1" width="15%" >Nome da Rota</td>
                                <td class="CelulaZebra1" width="14%" >Origem</td>
                                <td class="CelulaZebra1" width="21%" >Destino</td>
                                <td class="CelulaZebra1" width="7%" >Dist&acirc;ncia(Km)</td>
                                <td class="CelulaZebra1" width="11%" >Prazo p/ Entrega</td>
                                <td class="CelulaZebra1" width="4%" >Coleta</td>
                                <td class="CelulaZebra1" width="4%" >Manifesto</td>
                                <td class="CelulaZebra1" width="4%" >Romaneio</td>
                                <td class="CelulaZebra1" width="4%" >Diária</td>
                                <td class="CelulaZebra1" width="4%" >Pernoite</td>
                                <td class="CelulaZebra1" width="4%" >Refeição</td>
                                <td class="CelulaZebra1" width="3%" >Ativa</td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>
       
            <table width="98%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                   
                                   <td style='display: <%=carregarota && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                  
                               </tr>
                            </table>
                        </td> 
                    </tr>
               
                                         
                </table>              
                
                    <div id="divAuditoria" >
                         
                        <table width="98%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregarota && nivelUser == 4 ? "" : "none"%>'>
                                 <%@include file="/gwTrans/template_auditoria.jsp" %>

                        </table>
                    </div>
                      
                   <br>
                                <% if (nivelUser >= 2){%>
                             <table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                                <tr class="CelulaZebra2">
                                    <td height="24" colspan="4">
                                      <center>
                                        
                                        <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
                                        <%}%>
                                      </center>
                                    </td>
                                </tr>
                            </table>    
    </form>
    </body>
</html>
