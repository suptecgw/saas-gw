<%@page import="java.util.Date"%>
<%@page import="fpag.BeanFPag"%>
<%@page import="java.util.Collection"%>
<%@page import="fpag.BeanConsultaFPag"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="org.codehaus.jettison.json.JSONObject"%>
<%@page import="conhecimento.awb.BeanAWB"%>
<%@page import="despesa.rateio.Rateio"%>
<%@ page contentType="text/html" 
         language="java"
         import="nucleo.*,
         despesa.*,
         fornecedor.BeanCadFornecedor,
         despesa.duplicata.*,
         despesa.apropriacao.*,
         java.text.DecimalFormat,
         java.text.SimpleDateFormat,
         java.util.Vector" %> 


<script language="javascript" src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery-1.6.2.min.js" type="text/javascript"></script>
<script language="JavaScript" src="script/beans/AWB.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("caddespesa") : 0);
    int nivelUserFl = (nivelUser == 0 ? 0 : Apoio.getUsuario(request).getAcesso("landespfl"));
    int nivelUserApropParcelaQuitada = (nivelUser == 0 ? 0 : Apoio.getUsuario(request).getAcesso("alteraDespesaParcelaQuitada"));
    boolean temParcelaQuitada = false;
    
    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    int idFilialUser = (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getIdfilial() : 0);
    boolean limitarUsuarioVisualizarContas = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    //Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();
    
    //Permissão para o usuario poder alterar a despesa mesmo quando for gerada pela comissão.
    int nivelUsuerLiberarAcesso = Apoio.getUsuario(request).getAcesso("liberaralterardespesacomissao");
%>
<jsp:useBean id="caddesp" class="despesa.BeanCadDespesa" />
<jsp:useBean id="desp" class="despesa.BeanDespesa" />
<%
    
    String acao = (request.getParameter("acao") == null || nivelUser == 0 ? "" : request.getParameter("acao"));
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    boolean carregadesp = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar") || acao.equals("excluir"));
    Collection<BeanFPag> fmtPags = BeanConsultaFPag.mostrarTudo(Apoio.getUsuario(request).getConexao());
    caddesp = new BeanCadDespesa();
    caddesp.setConexao(Apoio.getUsuario(request).getConexao());
    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir")) {
        if (acao.equals("editar")) {
            caddesp.getDespesa().setIdmovimento(Integer.parseInt(request.getParameter("id")));
            carregadesp = caddesp.LoadAllPropertys();
            desp = (carregadesp ? caddesp.getDespesa() : null);
            
            //varre todas as duplicatas para verificar a existencia de pelo menos umas baixada.
            for (BeanDuplDespesa duplicata : desp.getDuplicatas()) {
                //se a duplicata for baixada
                if (duplicata.isBaixado() || duplicata.getUsuarioLib().getIdusuario() != 0) {
                    //ERRO - não tem permissão e existe duplicata baixada.
                    temParcelaQuitada = true;
                    break;
                }
            }
            
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir"))) {
            boolean executou = false;
            caddesp.setExecutor(Apoio.getUsuario(request));
%><jsp:setProperty name="desp" property="*" /><%
    //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
    if (acao.equals("atualizar") || acao.equals("incluir")) {
        desp.getEspecie_().setId(Apoio.parseInt(request.getParameter("especie")));
        desp.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
        desp.getFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor")));
        desp.setDtEmissao(Apoio.paraDate(request.getParameter("dtemissao")));
        desp.setDtEntrada(Apoio.paraDate(request.getParameter("dtentrada")));
        desp.setIsJaContabilizado(Boolean.parseBoolean(request.getParameter("isjacontabilizado")));
        desp.getHistorico().setIdHistorico(Integer.parseInt(request.getParameter("idhist")));
        desp.getHistorico().setDescHistorico(request.getParameter("idhist"));
        desp.setDescHistorico(request.getParameter("descricao_historico"));
        desp.setValorIrrf(Double.parseDouble(request.getParameter("valor_irrf")));
        desp.setValorInss(Double.parseDouble(request.getParameter("valor_inss")));
        desp.setValorIss(Double.parseDouble(request.getParameter("valor_iss")));
        desp.setValorSest(Double.parseDouble(request.getParameter("valor_sest")));
        desp.setIntegraFiscal(Boolean.parseBoolean(request.getParameter("isintegrafiscal")));
        desp.setValorContabil(Double.parseDouble(request.getParameter("valor_contabil")));
        desp.setBaseIcms(Float.parseFloat(request.getParameter("base_icms")));
        desp.setPercIcms(Float.parseFloat(request.getParameter("aliq_icms")));
        desp.getCfop().setIdcfop(Integer.parseInt(request.getParameter("idcfop")));
        desp.setProvisao(Boolean.parseBoolean(request.getParameter("isProvisao")));
        desp.setQtdProvisao(Integer.parseInt(request.getParameter("qtdProvisao")));
        //adicionando as duplicatas
        String[] strDups = request.getParameter("dups").split("!!");
        BeanDuplDespesa dups[] = new BeanDuplDespesa[strDups.length];
        desp.getProprietarioMovBanco().setIdfornecedor(Integer.parseInt(request.getParameter("idproprietario")));
        //NOVOS CAMPOS 02/06/2016 - 
        desp.setMotivoAcrescimoAWB(request.getParameter("motivoAcrescimo"));
        desp.setMotivoDescontoAWB(request.getParameter("motivoDesconto"));
        desp.setValorAcrescimoAWB(Apoio.parseDouble(request.getParameter("valorAcrescimo").replace(".", "").replace(",", ".")));
        desp.setValorDescontoAWB(Apoio.parseDouble(request.getParameter("valorDesconto").replace(".", "").replace(",", ".")));
        
        
         for (int i = 0; i < strDups.length; ++i) {
            BeanDuplDespesa du = new BeanDuplDespesa();
            du.setDtvenc(Apoio.paraDate(strDups[i].split("!-")[0]));
            du.setVlduplicata(Double.parseDouble(strDups[i].split("!-")[1]));
            du.setBaixado(strDups[i].split("!-")[2].equals("true"));
            du.setNumeroBoleto(strDups[i].split("!-")[3]);
            du.setValorPis(Double.parseDouble(strDups[i].split("!-")[5]));
            du.setValorCofins(Double.parseDouble(strDups[i].split("!-")[6]));
            du.setValorCssl(Double.parseDouble(strDups[i].split("!-")[7]));
            du.getFpag().setIdFPag(Apoio.parseInt(strDups[i].split("!-")[8]));
//                     du.getFpag().setIdFPag(2);
            du.setVlacrescimo(Double.parseDouble(strDups[i].split("!-")[4]));
            du.setIsParcelaCancelada(Boolean.parseBoolean(strDups[i].split("!-")[10]));
            du.setMotivoCancelamento(((!du.isIsParcelaCancelada())? "" :strDups[i].split("!-")[9]));
            du.setPrevisaoPagamento(Apoio.paraDate(strDups[i].split("!-")[11]));            
            du.setDataCancelamento(Apoio.paraDate(Apoio.getDataAtual()));
            
         
            du.setCnabCodigoReceitaTributo(strDups[i].split("!-")[12]);
            du.setCnabNomeContribuinte(strDups[i].split("!-")[13]);
            du.setCnabTipoIdentificacaoContribuinte(Apoio.parseInt(strDups[i].split("!-")[14]));
            du.setCnabIdentificacaoContrinuinte(strDups[i].split("!-")[15]);
            du.setValorReceitaBruta(Apoio.parseDouble(strDups[i].split("!-")[16]));
            du.setPercentualReceitaBruta(Apoio.parseDouble(strDups[i].split("!-")[17]));
            
            du.setPossuiRemessa(Apoio.parseBoolean(strDups[i].split("!-")[18]));
            
               
            if (acao.equals("incluir")) {
                desp.setAVista(Boolean.parseBoolean(request.getParameter("avista")));
                du.getMovBanco().getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
                du.getMovBanco().setValor(Float.parseFloat(String.valueOf(du.getVlduplicata() - du.getValorPis() - du.getValorCofins() - du.getValorCssl() + du.getVlacrescimo())));
                du.getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dtpagto")));
                du.getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dtpagto")));
                du.getMovBanco().setConciliado(false);
                du.getMovBanco().setHistorico(request.getParameter("descricao_historico"));
                du.getMovBanco().setDocum(request.getParameter("dupFmtPgto1").equals("3") ? request.getParameter("slct-docum") : request.getParameter("docum") );                
                du.getMovBanco().setNominal("");
                du.getMovBanco().getHistorico_id().setIdHistorico((request.getParameter("idhist").equals("") ? 0 : Integer.parseInt(request.getParameter("idhist"))));

                du.setVlpago(du.getVlduplicata() - du.getValorPis() - du.getValorCofins() - du.getValorCssl());
                du.setCriaPcs(false);
                du.setVldesconto(0);
                du.setDtpago(Apoio.paraDate(request.getParameter("dtpagto")));
                if (request.getParameter("isDespesaProprietario") != null) { //cria mov bancária para proprietário
                    du.getMovBancoFornecedor().setConta(cfg.getContaAdiantamentoFornecedor());
                    du.getMovBancoFornecedor().setTipo("n");
                    du.getMovBancoFornecedor().setDocum("");
                    du.getMovBancoFornecedor().setNominal("");
                    du.getMovBancoFornecedor().setDtEmissao(du.getDtvenc());
                    du.getMovBancoFornecedor().setDtEntrada(du.getDtvenc());
                    du.getMovBancoFornecedor().getHistorico_id().setDescHistorico(request.getParameter("descricao_historico"));
                    du.getMovBancoFornecedor().getHistorico_id().setIdHistorico(desp.getHistorico().getIdhistorico());
                    du.getMovBancoFornecedor().setHistorico(request.getParameter("descricao_historico"));
                    du.getMovBancoFornecedor().setValor(du.getMovBanco().getValor());
                    du.getMovBancoFornecedor().setUsuario(Apoio.getUsuario(request));
                    du.getMovBancoFornecedor().setConciliado(false);
                    du.getMovBancoFornecedor().setCheque(false);

                    du.getMovBancoFornecedor().getAdiantamentoFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idproprietario")));

                    du.getMovBancoFornecedor().getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo_prop")));
                } else {
                    du.getMovBancoFornecedor().getAdiantamentoFornecedor().setIdfornecedor(0);
                }
            }
                    dups[i] = du;
        }
                    desp.setDuplicatas(dups);
        //adicionando as apropriacoes
        if (!request.getParameter("aprops").equals("")) {
            String[] strAprops = request.getParameter("aprops").split("!!");
            String descricaoApropriacao="";
            BeanApropDespesa aprops[] = new BeanApropDespesa[strAprops.length];
            for (int i = 0; i < strAprops.length; ++i) {
                BeanApropDespesa ap = new BeanApropDespesa();
                ap.getPlanocusto().setIdconta(Integer.parseInt(strAprops[i].split("!-")[0]));
                ap.setValor(Double.parseDouble(strAprops[i].split("!-")[1]));
                if (!strAprops[i].split("!-")[2].equals("")) {
                    ap.getVeiculo().setIdveiculo(Integer.parseInt(strAprops[i].split("!-")[2]));
                }
                ap.getFilial().setIdfilial(Integer.parseInt(strAprops[i].split("!-")[3]));
                if (!strAprops[i].split("!-")[4].equals("0")) {
                    ap.getUndCusto().setId(Integer.parseInt(strAprops[i].split("!-")[4]));
                }                
                descricaoApropriacao = strAprops[i].split("!-")[5] != null ? strAprops[i].split("!-")[5] : "";
                ap.setDescricaoApropriacao(descricaoApropriacao);
                aprops[i] = ap;
            }
            desp.setApropriacoes(aprops);
        }


        //adicionando os awb's
        int qtdAWB = Integer.parseInt(request.getParameter("qtdAWB"));
        String[] strAWBs = request.getParameter("AWBs").split("!!");
        BeanAWB awb = null;
        if (!strAWBs.equals("")) {
            for (int i = 1; i < strAWBs.length; i++) {
                awb = new BeanAWB();
                awb.setId(strAWBs[i]);

                desp.getListaAWB().add(awb);
            }
        }

        caddesp.setDespesa(desp);
        if (acao.equals("atualizar")) {
            executou = caddesp.Atualiza();
        } else if (acao.equals("incluir") && nivelUser >= 3) {
            executou = caddesp.Inclui();
        }

%><script language="javascript" type="text/javascript"><%
    if (!executou) {%>
        window.opener.document.getElementById("salvar").disabled = false;
        window.opener.document.getElementById("salvar").value = "Salvar";
        alert('<%=(caddesp.getErros())%>');<%
                             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                         } else {%>
                             if (window.opener != null)
                                 window.opener.document.getElementById("bt_consultar").onclick();
    <%}%> 
        self.close();
</script>
<%} else if (acao.equals("excluir") && nivelUser >= 4) {
    caddesp.setDespesa(desp);
    executou = caddesp.Deleta();
    BeanCadDespesa desp1 = caddesp;
     
//função não estava funcionando foi comentado pois ja levanta o erro na tarefa abaixo
   // if(!executou){
         // response.getWriter().append(caddesp.getErros());

       // response.getWriter().close();
//    }else{
//      response.getWriter().append("Despesa excluida com sucesso!");

//            response.getWriter().close();
//        }
        
        
        
%><script language="javascript" type="text/javascript"><%
    if (!executou) {
            if((caddesp.getErros().contains("despesa_arquivo_despesa_id_fkey"))){
                caddesp.setErros("Para excluir a despesa é preciso primeiro excluir o(s) documento(s) em anexo(s)!");
                    response.getWriter().append(caddesp.getErros());
                    response.getWriter().close();
            }else if((caddesp.getErros().contains("despesa_produtos_despesa_id_fkey"))){
                caddesp.setErros("Essa despesa esta vinculada em uma compra no modulo Frota. Só é possivel excluir a despesa excluindo a compra!");
                    response.getWriter().append(caddesp.getErros());
                    response.getWriter().close();
            }else{
                    response.getWriter().append(caddesp.getErros());
                    response.getWriter().close();
            }
            %>
            window.close();
        <%} else {%>
            window.opener.location.reload();
            window.close();
        <%}%> 
        
</script>
<%}
        }
    } else if (acao.equals("localizaFornecedor")) {
        String resultado = "";
        String campo = request.getParameter("campo");
        String valor = request.getParameter("valor");
        BeanCadFornecedor fo = new BeanCadFornecedor();
        fo.setConexao(Apoio.getUsuario(request).getConexao());
        ResultSet rs = fo.getLocalizaCodigo(valor, campo);

        if (rs == null) {
            resultado = "null";
        } else {
            if (rs.next()) {
                resultado = rs.getString("idfornecedor") + "!=!"
                        + rs.getString("razaosocial") + "!=!"
                        + rs.getString("cpf_cnpj") + "!=!"
                        + rs.getString("descricao_historico") + "!=!"
                        + rs.getString("idplcustopadrao") + "!=!"
                        + rs.getString("contaplcusto") + "!=!"
                        + rs.getString("descricaoplcusto") + "!=!"
                        + rs.getString("id_und_forn") + "!=!"
                        + rs.getString("sigla_und_forn") + "!=!";
            }
        }
        response.getWriter().append(resultado);
        response.getWriter().close();
    } else if (acao.equals("buscarRateio")) {
        int idRateio = Apoio.parseInt(request.getParameter("idRateio"));
        Rateio rateio = caddesp.buscarRateio(idRateio);

        //criando o objeto json
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("itemRateio", Rateio.ItemRateio.class);

        /*if(rateio.getItens().size() > 0){
         jo.put("itens",rateio.getItens());
         response.getWriter().append(jo.toString().replace("\"false\"", "false").replace("\"true\"", "true"));
         }else{
         response.getWriter().append("load=0");
         }
         response.getWriter().close();*/
        String json = xstream.toXML(rateio.getItens());

        response.getWriter().append(json);

        response.getWriter().close();
    }else if(acao.equals("removerAWB")){
        
        BeanAWB beanAWB = new BeanAWB();
        int idAWB = Apoio.parseInt(request.getParameter("idAWB"));
        beanAWB.setId(idAWB);
       
        BeanCadDespesa beanCadDespesa = new BeanCadDespesa();
        beanCadDespesa.getDespesa().getListaAWB().add(beanAWB);
        beanCadDespesa.setConexao(Apoio.getUsuario(request).getConexao());
	beanCadDespesa.setExecutor(Apoio.getUsuario(request));
        beanCadDespesa.getDespesa().setIdmovimento(Apoio.parseInt(request.getParameter("idmovimento")));
        beanCadDespesa.removerAWB();
    }

%>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();

var arAbasDS = new Array();
    arAbasDS[0] = new setAba('tdPrincipal','divDados');
    arAbasDS[1] = new setAba('tdAbaAuditoria','divAuditoria');


function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

   function AlterneAba(menu, conteudo) {
    try {
        if (arAbasDS != null) {
            for (i = 0; i < arAbasDS.length; i++) {
                if (arAbasDS[i] != null && arAbasDS[i] != undefined) {
                    m = document.getElementById(arAbasDS[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasDS[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasDS[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasDS[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasDS[i].conteudo.split(",")[j].replace("div", "tr")), false);
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
    } catch (e) {
        alert(e);
    }
}
 
    /*--- Variaveis globais ---*/ 
    //indexacao da apropriacao
    var indexAprop = new Array(); 
    var idxDespesa = 0;

    function baixar(venc, baixado){
        window.open("./bxcontaspagar?acao=consultar&"+
            "idfornecedor="+$('idfornecedor').value+"&fornecedor="+$('fornecedor').value+"&"+
            "dtinicial="+venc+"&dtfinal="+venc+"&baixado="+baixado+"&idfilial="+$('idfilial').value+"&"+
            "fi_abreviatura="+$('fi_abreviatura').value+"&nf=&valor1=0.00&valor2=0.00&tipoData=dtvenc&mostrarSaldo=true", "Despesa" , "top=8,resizable=yes,status=1,scrollbars=1");
    }
    
    function validaDataVenc(dtVenc){
        var dataE = new Date($('dtemissao').value.substring(6,10),$('dtemissao').value.substring(3,5)-1,$('dtemissao').value.substring(0,2));
        var dataV = new Date(dtVenc.value.substring(6,10),dtVenc.value.substring(3,5)-1,dtVenc.value.substring(0,2));
        if (dataV.getTime() < dataE.getTime()){
            alert('A data de vencimento não pode ser inferior a data de emissão.');
            dtVenc.focus();
        }
    }

    function concatDups() {
        var dupCount = idxDespesa;
        var dups = "";
        for (i = 1; i <= dupCount; ++i) {
            dups += $("dupVenc" + i).value + "!-" + $("dupVlParc" + i).value + "!-" + $("dupBaixada" + i).value +
                "!-" + $("dupBoleto" + i).value + "!-" + $("dupTaxas" + i).value + "!-" + $("dupPis" + i).value +
                "!-" + $("dupCofins" + i).value + "!-" + $("dupCssl" + i).value + "!-" + $("dupFmtPgto" + i).value + 
                "!-" +($("MotivoCancelamento"+i).value.trim() == "" ? " " : $("MotivoCancelamento"+i).value )+
                "!-" + $("isCancelado" +i).checked + "!-" + ($("previsaoPagamento" +i).value.trim() == "" ? " " : $("previsaoPagamento" +i).value) + 
                "!-" + ($("codigoReceita" + i)!=null? $("codigoReceita" + i).value: " ") + 
                "!-" + ($("nomeContribuinte" + i)!= null ?$("nomeContribuinte" + i).value: " ") + 
                "!-" + ($("idTipoContribuinte" + i)!=null? $("idTipoContribuinte" + i).value: " ") + 
                "!-" +($("tipoContribuinte"+i)!=null? ($("tipoContribuinte"+i).value.trim() == "" ? " " : $("tipoContribuinte"+i).value):" " )+
                "!-" +($("valorReceitaBruta"+i)!=null ? ($("valorReceitaBruta"+i).value.trim() == "" ? " " : $("valorReceitaBruta"+i).value):" " )+
                "!-" +($("percentualReceitaBruta"+i)!=null? ($("percentualReceitaBruta"+i).value.trim() == "" ? " " : $("percentualReceitaBruta"+i).value):" " )+
                "!-" +($("possuiRemessa"+i).value)+            
           
                (i == dupCount? "" : "!!"); //<--- Finalizador do array bidimensional
        }
        return dups;
    }

    function addParcell(dias, dtVenc, vlParc, dtPago, vlPago, dupBaixada, conta, //7
    docum, dupLiberada, usuario, boleto, valorAdicional, pis, cofins, cssl, isCartaFrete, //9
    fmtPagto,isCancelado,motivoCancelamento,dataCancelamento,previsaoPagamento,idUsuarioLib, nomeUsuarioLib//7
            ,cnabCodigoReceitaTributo, cnabNomeContribuinte, cnabTipoIdentificacaoContribuinte, cnabIdentificacaoContrinuinte, valorReceitaBruta, percentualReceitaBruta, possuiRemessa ){   //7
        function blockField(ob, bx){
            ob.readOnly  = (ob.readOnly || bx);
            ob.className = (ob.readOnly || bx? "inputReadOnly" : "inputtexto");	
        }
        possuiRemessa = possuiRemessa == undefined? "false": possuiRemessa;
      
       
        
        idxDespesa++;
        var indice = idxDespesa;
        var CelulaZebra = "CelulaZebra"+((indice % 2) == 0 ? 1 : 2);
        var trLine = makeElement("TR", "class=" + CelulaZebra + "&id=trDup" + indice);
        var strInput = "type=TEXT&maxLength=10&size=9&class=inputtexto";

     
        var tdOcult = makeElement("TD","");
        var imgPlus = makeElement("IMG","class=imagemLink&src=./img/plus.jpg&id=plus"+indice+
            "&title=Visualizar Dados adicionais&onclick=viewDadosAdicionais(true,"+indice+");");
        var imgMinus = makeElement("IMG","class=imagemLink&src=./img/minus.jpg&id=minus"+indice+
            "&title=Ocultar Dados adicionais&onclick=viewDadosAdicionais(false,"+indice+");");
        tdOcult.appendChild(imgPlus);
        tdOcult.appendChild(imgMinus);
        trLine.appendChild(tdOcult);

        trLine.appendChild(makeElement("TD","innerHTML="+$("notafiscal").value + "/" + indice));

        //string usada para bloquear um objeto se a duplicata foi baixada
  
        var strBlock = ((dupBaixada || isCancelado || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa=='true')) ? "&class=inputReadOnly&readOnly=true" : "&class=inputtexto");
        //input de com dias apartir do vencimento
        var onchangeDias = "$('dupVenc"+indice+"').setAttribute('value', incData($('dtemissao').value, $('dias"+indice+"').value));";
        var onchangeData = "$('dias"+indice+"').setAttribute('value', incDias($('dtemissao').value, $('dupvenc"+indice+"').value));";
        trLine.appendChild(makeWithTD("INPUT", "type=TEXT&maxLength=4&size=1&onchange="+ onchangeDias +"&value="+ dias +"&id=dias"+indice + strBlock));
        var str_fmt_date = "fmtDate($('dupVenc"+indice+"'),event);";
        trLine.appendChild(makeWithTD("INPUT", strInput+"&id=dupVenc"+indice+"&size=9&onChange=alertInvalidDate($('dupVenc"+indice+"'));validaDataVenc($('dupVenc"+indice+"'));mudarProvisionamento("+indice+")&onkeypress="+str_fmt_date+"&onkeyup="+str_fmt_date+"&onkeydown="+str_fmt_date+"&value="+dtVenc + strBlock));
        trLine.appendChild(makeWithTD("INPUT", strInput + "&id=dupVlParc" + indice + "&value=" + formatoMoeda(vlParc) +
            "&size=6&onchange=seNaoFloatReset($('dupVlParc"+indice+"'),'0.00');getValorLiquidoParcela("+indice+");" + strBlock));
        trLine.appendChild(makeWithTD("INPUT", strInput + "&id=dupTaxas" + indice + "&value=" + formatoMoeda(valorAdicional) +
            "&size=6&onchange=seNaoFloatReset($('dupTaxas"+indice+"'),'0.00');getValorLiquidoParcela("+indice+");" + strBlock));
        trLine.appendChild(makeWithTD("INPUT", strInput + "&id=dupRetencoes" + indice + "&value=" + formatoMoeda(0) +
            "&size=6&onchange=seNaoFloatReset($('dupRetencoes"+indice+"'),'0.00');&class=inputReadOnly&readOnly=true"));
        trLine.appendChild(makeWithTD("INPUT", strInput + "&id=dupLiquido" + indice + "&value=" + formatoMoeda(0) +
            "&size=6&onchange=seNaoFloatReset($('dupLiquido"+indice+"'),'0.00');&class=inputReadOnly&readOnly=true"));
                                                            
        trLine.appendChild(makeWithTD("INPUT", strInput+"&id=dupBoleto"+indice+"&size=16&maxLength=60&value="+boleto+ strBlock));
        trLine.appendChild(makeElement("TD","innerHTML="+dtPago));
        trLine.appendChild(makeElement("TD","innerHTML="+vlPago));
        var inPossuiRemessa = makeElement("INPUT", "type=hidden&id=possuiRemessa"+indice+"&value="+possuiRemessa);
        trLine.appendChild(inPossuiRemessa);
       
        /*
             Acrescentando um campo <select> como não faço ideia de como fazer isso usando a forma acima, 
             criarei diferente
         */
        var tdFmt = Builder.node("td");
        var sltFmt = Builder.node("select",{
            id: "dupFmtPgto" + indice,
            name: "dupFmtPgto" + indice,
            className: (possuiRemessa=='true'? "inputReadOnly" : "inputtexto") ,
            onChange: 'verFpag()'
        });
        
        if(possuiRemessa=='true'){
            sltFmt.disabled = true;
        }else{
            sltFmt.disabled = false;
            
        }
            
        var opt = Builder.node("option",{
            value:"" 
        },"-- Não informado --");
            
        sltFmt.appendChild(opt);
            
    <%for (BeanFPag fomPag : fmtPags) {%>
            opt = Builder.node("option",{
                value:"<%=fomPag.getIdFPag()%>" 
            },"<%=fomPag.getDescFPag()%>");
                
            sltFmt.appendChild(opt);
    <%}%>
            //            
            sltFmt.style.width = "40px";
            tdFmt.appendChild(sltFmt);
            trLine.appendChild(tdFmt);
            
            if (fmtPagto == null || fmtPagto == undefined || fmtPagto == 0) {
                sltFmt.value = 1;// Não especificada
            }else{
                sltFmt.value = fmtPagto;
            }
            
    <%  if (acao.equals("editar")) {%>
            trLine.appendChild(makeWithTD("IMG","class=imagemLink&src=./img/"+(dupBaixada && !isCancelado? "del_baixa":(isCancelado == true ? "del" : "baixar"))+".gif&"+
                "title="+(dupBaixada? "Excluir baixa&" : "Baixar esta duplicata&")+
                "onclick=baixar('"+dtVenc+"',"+dupBaixada+")&class=imagemLink"));
    <%  } else {%>
            trLine.appendChild(makeElement("TD",""));
    <%  }%>	

            trLine.appendChild(makeWithTD("INPUT", strInput+"&id=dupBaixada"+indice+"&name=dupBaixada"+indice+"&value="+dupBaixada));
            trLine.appendChild(makeWithTD("INPUT", strInput+"&id=dupCancelada"+indice+"&name=dupCancelada"+indice+"&value="+isCancelado));

            //adicionando a linha na lista
            $("corpoDups").appendChild(trLine);

            //Montando a segunda tr
            var trLine2 = makeElement("TR", "id=trDup2" + indice); // nova TR
            var tdLine2 = makeElement("TD", "colSpan=13"); // nova TD
            var tableLine2 = makeElement("TABLE", "width=100%"); // nova table
            var tBodyLine2 = makeElement("TBODY", "width=100%"); // novo TBODY
            var trTableLine2 = makeElement("TR", ""); // NOVA TR DO TBODY

            // TD COM LABEL Impostos Retidos
            var tdTableLine1 = makeElement("TD","class="+ CelulaZebra + "&width=14%&innerHTML=Impostos Retidos"); 
            
            
            // TD COM LABEL PIS        
            var tdTableLine2 = makeElement("TD","class="+ CelulaZebra + "&width=4%&innerHTML=PIS:"); 

            // TD PARA O CAMPO PIS
            var tdTableLine3 = makeElement("TD","class="+ CelulaZebra + "&width=8%"); 
            // CAMPO PIS
            var inTd3 = makeElement("INPUT", strInput + "&id=dupPis" + indice + "&value=" + formatoMoeda(pis) +
                "&size=6&onchange=seNaoFloatReset($('dupPis"+indice+"'),'0.00');getValorLiquidoParcela("+indice+");" + strBlock);
            //inserir o campo pis na TD DE PIS
            tdTableLine3.appendChild(inTd3);
            
            // TD COM LABEL COFINS
            var tdTableLine4 = makeElement("TD","class="+ CelulaZebra + "&width=7%&innerHTML=COFINS:");
            
            // TD PARA O CAMPO COFINS
            var tdTableLine5 = makeElement("TD","class="+ CelulaZebra + "&width=8%");
            // CAMPO COFINS
            var inTd5 = makeElement("INPUT", strInput + "&id=dupCofins" + indice + "&value=" + formatoMoeda(cofins) +
                "&size=6&onchange=seNaoFloatReset($('dupCofins"+indice+"'),'0.00');getValorLiquidoParcela("+indice+");" + strBlock);
            // inserir o campo cofins na TD de cofins
            tdTableLine5.appendChild(inTd5);
            
            // TD COM LABEL CSSL
            var tdTableLine6 = makeElement("TD","class="+ CelulaZebra + "&width=5%&innerHTML=CSSL:");
            
            // TD PARA CAMPO CSSL
            var tdTableLine7 = makeElement("TD","class="+ CelulaZebra + "&width=8%");
            
            // CAMPO CSSL
            var inTd7 = makeElement("INPUT", strInput + "&id=dupCssl" + indice + "&value=" + formatoMoeda(cssl) +
                "&size=6&onchange=seNaoFloatReset($('dupCssl"+indice+"'),'0.00');getValorLiquidoParcela("+indice+");" + strBlock);
            //inserir o campo cssl na TD de cssl
            tdTableLine7.appendChild(inTd7);
            
            // TD que aparece o numero da conta, o documento e o usuario que baixou CASO A PARCELA SEJA BAIXADA
            var tdTableLine8 = makeElement("TD","class="+ CelulaZebra + 
                "&width=46&colspan=1&innerHTML="+(dupBaixada && !isCancelado ?"Pago na conta:"+conta+ ", Cheque/Doc Nº:" +docum+ ", Pelo usuário:" +usuario : ""));
            
            
            // toda a linha a seguir, deverá ser hidden, caso a parcela seja baixada.
            // nova TR
            var trTableLine2_1 = makeElement("TR", "id=trMotivo_"+indice);
            
            // nova TD COM LABEL Parcela Cancelada.
            var tdTableLine2_1 = makeElement("TD", "class="+ CelulaZebra + "&width=14%&colspan=2&innerHTML=Parcela Cancelada : ");
            
            // TD PARA CAMPO DE CHECK IS CANCELADO
            var tdTableLine2_2 = makeElement("TD", "class="+ CelulaZebra + "&width=14");
            // CAMPO CHECK IS CANCELADO
            var inTd2_2 = makeElement("INPUT", "type=checkbox"+(isCancelado? "&checked" : "") + "&id=isCancelado"+indice+"&onclick=cancelar("+indice+")");
            
            
            var tdLabelPrevPagamento = makeElement("TD", "class="+ CelulaZebra + "NoAlign&width=14&innerHTML=Previsão de pagamento : &align=right");
            
            var tdPrevPagamento = makeElement("TD", "class="+ CelulaZebra + "&width=10");
            var inputPrevPagamento = makeElement("INPUT", "type=TEXT&maxLength=10&size=9&class=inputtexto&id=previsaoPagamento" + indice+ 
                    "&onkeydown=fmtDate(this,event)&onblur=alertInvalidDate(this,true)&value="+previsaoPagamento);
            tdPrevPagamento.appendChild(inputPrevPagamento);
            if(isCancelado || dupBaixada || (possuiRemessa =='true')){
                inputPrevPagamento.readOnly='true';
                inputPrevPagamento.className = "inputReadOnly";
            }
            
            var tdLiberacaoPagamento = makeElement("TD","class="+ CelulaZebra + "&width=14%&innerHTML=Autorizado por:"); 
            
            //a partir daqui e a parte onde mostra o motivo do cancelamento da parcela
            var tdTableLine2_3 = makeElement("TD", "class="+ CelulaZebra + "&width=14&colspan=2&innerHTML=Motivo cancelamento: ");
            var tdTableLine2_4 = makeElement("TD", "class="+ CelulaZebra + "&width=14&colspan=5");
            var inTd2_4 = makeElement("INPUT", "type=TEXT&maxLength=50&size=50&class=inputtexto&id=MotivoCancelamento" + indice+"&value="+(motivoCancelamento == "null" || motivoCancelamento == undefined? "" : motivoCancelamento));
            //type=TEXT&maxLength=10&size=9&class=inputtexto
            
            //aqui antes era dataCancelamento, mas como nao era para ser mostrado ficou uma TD vazia para complementar.
            var tdTableLine2_5 = makeElement("TD", "class="+ CelulaZebra + "&width=14&colspan=3");
            var tdTableLine2_6 = makeElement("TD", "class="+ CelulaZebra + "&width=14");
            var inTd2_6 = makeElement("INPUT", "type=TEXT&maxLength=10&size=9&class=inputtexto&id=dataCancelamento" + indice+ 
                    "&onkeydown=fmtDate(this,event)&onblur=alertInvalidDate(this,true)&value="+(dataCancelamento == "null" || dataCancelamento == undefined ? "" : dataCancelamento));
            
            var trTableLine10 = makeElement("TR", "id=trTipoPagamentoCnab" + indice  + "&name=trTipoPagamentoCnab" + indice  ); // NOVA TR DO TBODY
            var tdTableLine10_1 = makeElement("TD","class="+ CelulaZebra + "&colspan=1&innerHTML=Código da Receita do Tributo:"); 
            var tdTableLine10_2 = makeElement("TD","class="+ CelulaZebra + "&colspan=1"); 
            var tdTableLine10_3 = makeElement("TD","class="+ CelulaZebra + "&colspan=1&innerHTML=Nome Contribuinte:"); 
            var tdTableLine10_4 = makeElement("TD","class="+ CelulaZebra + "&colspan=1"); 
            var tdTableLine10_5 = makeElement("TD","class="+ CelulaZebra + "&width=14%&innerHTML=Tipo Identificação do Contribuinte:"); 
            var tdTableLine10_6 = makeElement("TD","class="+ CelulaZebra + "&colspan=1"); 
            var tdTableLine10_7 = makeElement("TD","class="+ CelulaZebra + "&colspan=1"); 
            var tdTableLine10_8 = makeElement("TD","class="+ CelulaZebra + "&colspan=1%&innerHTML=Valor Bruto Receita:"); 
            var tdTableLine10_9 = makeElement("TD","class="+ CelulaZebra + "&colspan=1"); 
            var tdTableLine10_10 = makeElement("TD","class="+ CelulaZebra + "&colspan=1%&innerHTML=Percentual Bruto Receita:"); 
            var tdTableLine10_11 = makeElement("TD","class="+ CelulaZebra + "&colspan=1"); 
            var tdTableLine10_12 = makeElement("TD","class="+ CelulaZebra + "&colspan=4"); 
            var inTd10_1 = makeElement("INPUT", strInput + "&id=codigoReceita" + indice  + "&name=codigoReceita" + indice + "&size=15&maxLength=15&align=center"+strBlock+"&value="+(cnabCodigoReceitaTributo == "null" || cnabCodigoReceitaTributo == undefined ? "" : cnabCodigoReceitaTributo ));
            tdTableLine10_2.appendChild(inTd10_1);
            var inTd10_2 = makeElement("INPUT", strInput + "&id=nomeContribuinte" + indice  + "&name=nomeContribuinte" + indice + "&size=20&maxLength=60"+strBlock+"&value="+(cnabNomeContribuinte == "null" || cnabNomeContribuinte == undefined ? "" : cnabNomeContribuinte));
            tdTableLine10_4.appendChild(inTd10_2);
            var inTd10_3 = makeElement("INPUT", strInput + "&id=tipoContribuinte" + indice  + "&name=tipoContribuinte" + indice + "&size=10&maxLength=25"+strBlock+"&value="+(cnabIdentificacaoContrinuinte == "null" || cnabTipoIdentificacaoContribuinte == undefined ? "" : cnabIdentificacaoContrinuinte));
            tdTableLine10_7.appendChild(inTd10_3);
            var inTd10_4 = makeElement("INPUT", strInput + "&id=valorReceitaBruta" + indice  + "&name=valorReceitaBruta" + indice + "&size=5&maxLength=25"+strBlock+"&value=0&onkeypress=mascara(this, reais);&onkeyup=mascara(this, reais);&onkeydown=mascara(this, reais);&value="+(valorReceitaBruta == "null" || valorReceitaBruta == undefined ? "" : valorReceitaBruta));
            tdTableLine10_9.appendChild(inTd10_4);
            var inTd10_5 = makeElement("INPUT", strInput + "&id=percentualReceitaBruta" + indice  + "&name=percentualReceitaBruta" + indice + "&size=5&maxLength=25"+strBlock+"&value=0&onkeypress=mascara(this, reais);&onkeyup=mascara(this, reais);&onkeydown=mascara(this, reais);&value="+(percentualReceitaBruta == "null" || percentualReceitaBruta == undefined ? "" : percentualReceitaBruta));
            tdTableLine10_11.appendChild(inTd10_5);
            
            var sltTipo = Builder.node("select",{
                id: "idTipoContribuinte" + indice,
                name: "idTipoContribuinte" + indice,
                className: possuiRemessa=='true'? "inputReadOnly" : "inputtexto",
                disabled: (possuiRemessa=='true'? "true" : "false") 
            });
            
            if(possuiRemessa=='true'){
                sltTipo.disabled = true;
            }else{
                sltTipo.disabled = false;

            }

            var opt0 = Builder.node("option",{value:"0"},"Não informado");
            var opt1 = Builder.node("option",{value:"1"},"CPF");
            var opt2 = Builder.node("option",{value:"2"},"CNPJ");
            var opt3 = Builder.node("option",{value:"3"},"NIT / PIS / PASEP");
            var opt4 = Builder.node("option",{value:"4"},"CEI");
            var opt5 = Builder.node("option",{value:"5"},"NB");
            var opt6 = Builder.node("option",{value:"6"},"Número do Título");
            var opt7 = Builder.node("option",{value:"7"},"DEBCAD");
            var opt8 = Builder.node("option",{value:"8"},"REFERÊNCIA");

            sltTipo.appendChild(opt0);
            sltTipo.appendChild(opt1);
            sltTipo.appendChild(opt2);
            sltTipo.appendChild(opt3);
            sltTipo.appendChild(opt4);
            sltTipo.appendChild(opt5);
            sltTipo.appendChild(opt6);
            sltTipo.appendChild(opt7);
            sltTipo.appendChild(opt8);
         
            sltTipo.style.width = "120px";
            if(cnabTipoIdentificacaoContribuinte =="null" || cnabTipoIdentificacaoContribuinte=='undefined'){
                sltTipo.selectedIndex =0;
            }else{
                sltTipo.value=cnabTipoIdentificacaoContribuinte;
            }
            tdTableLine10_6.appendChild(sltTipo);
            
            trTableLine10.appendChild(tdTableLine10_1);
            trTableLine10.appendChild(tdTableLine10_2);
            trTableLine10.appendChild(tdTableLine10_3);
            trTableLine10.appendChild(tdTableLine10_4);
            trTableLine10.appendChild(tdTableLine10_5);
            trTableLine10.appendChild(tdTableLine10_6);
            trTableLine10.appendChild(tdTableLine10_7);
            trTableLine10.appendChild(tdTableLine10_8);
            trTableLine10.appendChild(tdTableLine10_9);
            trTableLine10.appendChild(tdTableLine10_10);
            trTableLine10.appendChild(tdTableLine10_11);       
            if($("tipoPagamentoCNAB").value != "null" && $("tipoPagamentoCNAB").value != "s"){
                tdTableLine10_8.style.display="none";
                tdTableLine10_9.style.display="none";
                tdTableLine10_10.style.display="none";
                tdTableLine10_11.style.display="none";
                trTableLine10.appendChild(tdTableLine10_12);                
            }  
                                    
            var trTableLine11 = makeElement("TR", "id=trJaPossuiRemessa" + indice  + "&name=trJaPossuiRemessa" + indice); // NOVA TR DO TBODY
            var tdTableLine11_1 = makeElement("TD","class="+ CelulaZebra + "&colspan=2&innerHTML=Pagamento Gerado para esta Duplicata. Liberar alteração:"); 
            var tdTableLine11_2 = makeElement("TD","class="+ CelulaZebra + "&colspan=9"); 
            var inTd11_1 = makeElement("INPUT", "type=checkbox&id=liberarDupl" + indice  + "&name=liberarDupl" + indice+"&onclick=habilitarCamposDupl("+indice+");");
            tdTableLine11_2.appendChild(inTd11_1);
            trTableLine11.appendChild(tdTableLine11_1);
            trTableLine11.appendChild(tdTableLine11_2);

            
            //tdTableLine2_2.appendChild(inTd2_2);
            tdTableLine2_4.appendChild(inTd2_4);
            tdTableLine2_6.appendChild(inTd2_6);
            
//            trTableLine2_1.appendChild(tdTableLine2_1);
//            trTableLine2_1.appendChild(tdTableLine2_2);
            trTableLine2_1.appendChild(tdTableLine2_3);
            trTableLine2_1.appendChild(tdTableLine2_4);
            trTableLine2_1.appendChild(tdTableLine2_5);
        
            if(dupBaixada && !isCancelado ){trTableLine2_1.style.display = "none";}




            trTableLine2.appendChild(tdTableLine1);
            trTableLine2.appendChild(tdTableLine2);
            trTableLine2.appendChild(tdTableLine3);
            trTableLine2.appendChild(tdTableLine4);
            trTableLine2.appendChild(tdTableLine5);
            trTableLine2.appendChild(tdTableLine6);
            trTableLine2.appendChild(tdTableLine7);
                var labelCancelado = Builder.node("label","Parcela cancelada");
                labelCancelado.style.display = "none";
                inTd2_2.style.display = "none";
            if(!(dupBaixada && !isCancelado)){
                labelCancelado.style.display = "";
                inTd2_2.style.display = "";
            }
            
            trTableLine2.appendChild(tdLabelPrevPagamento);
            trTableLine2.appendChild(tdPrevPagamento);            
            tdLiberacaoPagamento.innerHTML += (idUsuarioLib != undefined && idUsuarioLib != 0 ? nomeUsuarioLib : "");
            trTableLine2.appendChild(tdLiberacaoPagamento);
            
                tdTableLine8.appendChild(inTd2_2);
                tdTableLine8.appendChild(labelCancelado);
            trTableLine2.appendChild(tdTableLine8);

            tBodyLine2.appendChild(trTableLine2);
            tBodyLine2.appendChild(trTableLine2_1);
           
            if($("tipoPagamentoCNAB").value != "null" && $("tipoPagamentoCNAB").value != "n"){
                 tBodyLine2.appendChild(trTableLine10);
            }
            
            if(possuiRemessa =='true' && !dupBaixada){
                tBodyLine2.appendChild(trTableLine11);
            }
            if(isCancelado){
                trTableLine2_1.style.display = "";
            }else{
                trTableLine2_1.style.display = "none";
            }
            tableLine2.appendChild(tBodyLine2);
            tdLine2.appendChild(tableLine2);
            trLine2.appendChild(tdLine2);
            $("corpoDups").appendChild(trLine2);

            //Escondendo campos ocultos.
            $('dupBaixada'+indice).style.display = "none";
            $('dupCancelada'+indice).style.display = "none";
            
            
            //travando o valor da despesa se a dup estiver baixada OU CANCELADA            
            blockField($("valor"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("valor_irrf"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("valor_inss"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("valor_iss"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("valor_sest"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("qtdParcelas"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("valorParcelas"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("tipoDuplicata"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            blockField($("qtdDiasParcelas"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            //Regra para liberar o acesso ao usuario alterar os campos, notafiscal, serie, especie, quando a despesa for gerada pela comissão.
            <%if(!(carregadesp && desp.isComissaoVendedor())){%>
                blockField($("notafiscal"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0)|| (possuiRemessa =='true'));
                blockField($("serie"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0)|| (possuiRemessa =='true'));
                $("especie").disabled = $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true');
            <%}%>
                
            blockField($("dtemissao"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0) || (possuiRemessa =='true'));
            //esse metodo blockField recebe um objeto como primeiro parametro e um 'boolean' como segundo.
            
            //blockField($("dtentrada"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete);
            blockField($("competencia"), $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0)|| (possuiRemessa =='true'));
            $("criarDups").disabled = $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0)|| (possuiRemessa =='true');
            if (<%=nivelUserFl >= 1%> && $("localiza_filial") != null){
                $("localiza_filial").disabled = $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0)|| (possuiRemessa =='true');
            }
            $("localiza_fornecedor").disabled = $("criarDups").disabled || dupBaixada || isCancelado || isCartaFrete || (idUsuarioLib != undefined && idUsuarioLib != 0)|| (possuiRemessa =='true');

            //Ocultando dados adicionais
            $("minus"+indice).style.display = "none";
            $("trDup2"+indice).style.display = "none";

            getValorLiquidoParcela(indice);
        }//addParcell()
        
        function mudarProvisionamento(index){
            if($("dupVenc"+index) && validaData($("dupVenc"+index).value)){
                $("previsaoPagamento"+index).value = $("dupVenc"+index).value;
            }
        }
           
        function habilitarCamposDupl(index){
            //class=inputReadOnly&readOnly=true
            var habilitar = $("liberarDupl"+index).checked;
          
            if(!habilitar){
                
                jQuery("#dias" + index).removeClass("inputtexto");
                jQuery("#dias" + index).addClass("inputReadOnly");
                jQuery("#dias" + index).prop('readonly', true);
              
                jQuery("#dupVenc" + index).removeClass("inputtexto");
                jQuery("#dupVenc" + index).addClass("inputReadOnly");
                jQuery("#dupVenc" + index).prop('readonly', true);
                
                jQuery("#dupVlParc" + index).removeClass("inputtexto");
                jQuery("#dupVlParc" + index).addClass("inputReadOnly");
                jQuery("#dupVlParc" + index).prop('readonly', true);
                
                jQuery("#dupTaxas" + index).removeClass("inputtexto");
                jQuery("#dupTaxas" + index).addClass("inputReadOnly");
                jQuery("#dupTaxas" + index).prop('readonly', true);
                
                jQuery("#dupBoleto" + index).removeClass("inputtexto");
                jQuery("#dupBoleto" + index).addClass("inputReadOnly");
                jQuery("#dupBoleto" + index).prop('readonly', true);
                
                jQuery("#dupFmtPgto" + index).removeClass("inputtexto");
                jQuery("#dupFmtPgto" + index).addClass("inputReadOnly");
                jQuery("#dupFmtPgto" + index).prop('readonly', true);
                jQuery("#dupFmtPgto" + index).prop('disabled', true);
                
                jQuery("#dupPis" + index).removeClass("inputtexto");
                jQuery("#dupPis" + index).addClass("inputReadOnly");
                jQuery("#dupPis" + index).prop('readonly', true);
                
                jQuery("#dupCofins" + index).removeClass("inputtexto");
                jQuery("#dupCofins" + index).addClass("inputReadOnly");
                jQuery("#dupCofins" + index).prop('readonly', true);
                
                jQuery("#dupCssl" + index).removeClass("inputtexto");
                jQuery("#dupCssl" + index).addClass("inputReadOnly");
                jQuery("#dupCssl" + index).prop('readonly', true);
                
                jQuery("#previsaoPagamento" + index).removeClass("inputtexto");
                jQuery("#previsaoPagamento" + index).addClass("inputReadOnly");
                jQuery("#previsaoPagamento" + index).prop('readonly', true);
                
                jQuery("#codigoReceita" + index).removeClass("inputtexto");
                jQuery("#codigoReceita" + index).addClass("inputReadOnly");
                jQuery("#codigoReceita" + index).prop('readonly', true);
                
                jQuery("#nomeContribuinte" + index).removeClass("inputtexto");
                jQuery("#nomeContribuinte" + index).addClass("inputReadOnly");
                jQuery("#nomeContribuinte" + index).prop('readonly', true);
                
                jQuery("#idTipoContribuinte" + index).removeClass("inputtexto");
                jQuery("#idTipoContribuinte" + index).addClass("inputReadOnly");
                jQuery("#idTipoContribuinte" + index).prop('readonly', true);
                jQuery("#idTipoContribuinte" + index).prop('disabled', true);
                
                jQuery("#tipoContribuinte" + index).removeClass("inputtexto");
                jQuery("#tipoContribuinte" + index).addClass("inputReadOnly");
                jQuery("#tipoContribuinte" + index).prop('readonly', true);
                
                jQuery("#isCancelado" + index).removeClass("inputtexto");
                jQuery("#isCancelado" + index).addClass("inputReadOnly");
                jQuery("#isCancelado" + index).prop('readonly', true);
                
            }else{
                
                jQuery("#dias" + index).removeClass("inputReadOnly");
                jQuery("#dias" + index).addClass("inputtexto");
                jQuery("#dias" + index).prop('readonly', false);
              
                jQuery("#dupVenc" + index).removeClass("inputReadOnly");
                jQuery("#dupVenc" + index).addClass("inputtexto");
                jQuery("#dupVenc" + index).prop('readonly', false);
                
                jQuery("#dupVlParc" + index).removeClass("inputReadOnly");
                jQuery("#dupVlParc" + index).addClass("inputtexto");
                jQuery("#dupVlParc" + index).prop('readonly', false);
                
                jQuery("#dupTaxas" + index).removeClass("inputReadOnly");
                jQuery("#dupTaxas" + index).addClass("inputtexto");
                jQuery("#dupTaxas" + index).prop('readonly', false);
                
                jQuery("#dupBoleto" + index).removeClass("inputReadOnly");
                jQuery("#dupBoleto" + index).addClass("inputtexto");
                jQuery("#dupBoleto" + index).prop('readonly', false);
                
                jQuery("#dupFmtPgto" + index).removeClass("inputReadOnly");
                jQuery("#dupFmtPgto" + index).addClass("inputtexto");
                jQuery("#dupFmtPgto" + index).prop('readonly', false);
                 jQuery("#dupFmtPgto" + index).prop('disabled', false);
            
                jQuery("#dupPis" + index).removeClass("inputReadOnly");
                jQuery("#dupPis" + index).addClass("inputtexto");
                jQuery("#dupPis" + index).prop('readonly', false);
                
                jQuery("#dupCofins" + index).removeClass("inputReadOnly");
                jQuery("#dupCofins" + index).addClass("inputtexto");
                jQuery("#dupCofins" + index).prop('readonly', false);
                
                jQuery("#dupCssl" + index).removeClass("inputReadOnly");
                jQuery("#dupCssl" + index).addClass("inputtexto");
                jQuery("#dupCssl" + index).prop('readonly', false);
                
                jQuery("#previsaoPagamento" + index).removeClass("inputReadOnly");
                jQuery("#previsaoPagamento" + index).addClass("inputtexto");
                jQuery("#previsaoPagamento" + index).prop('readonly', false);
                
                jQuery("#codigoReceita" + index).removeClass("inputReadOnly");
                jQuery("#codigoReceita" + index).addClass("inputtexto");
                jQuery("#codigoReceita" + index).prop('readonly', false);
                
                jQuery("#nomeContribuinte" + index).removeClass("inputReadOnly");
                jQuery("#nomeContribuinte" + index).addClass("inputtexto");
                jQuery("#nomeContribuinte" + index).prop('readonly', false);
                
                jQuery("#idTipoContribuinte" + index).removeClass("inputReadOnly");
                jQuery("#idTipoContribuinte" + index).addClass("inputtexto");
                jQuery("#idTipoContribuinte" + index).prop('readonly', false);
                jQuery("#idTipoContribuinte" + index).prop('disabled', false);
                
                jQuery("#tipoContribuinte" + index).removeClass("inputReadOnly");
                jQuery("#tipoContribuinte" + index).addClass("inputtexto");
                jQuery("#tipoContribuinte" + index).prop('readonly', false);
            
                jQuery("#isCancelado" + index).removeClass("inputReadOnly");
                jQuery("#isCancelado" + index).addClass("inputtexto");
                jQuery("#isCancelado" + index).prop('readonly', false);
            
                
            }
            
        }

        function colocarTotal(){
            if ($("valorParcelas").value != "0.00" && $("valorParcelas").value != "0"){
                var total = (parseFloat($("qtdParcelas").value)  * parseFloat($("valorParcelas").value) ); 
                $("valor").value = formatoMoeda(total);
                getVlLiquido();
            }
        }

        function tirarLinha(){
            if($("valor").value == "0.00" || $("valor").value == "0"){
                $("lbValor1").innerHTML = 'No valor de ';
                $("valorParcelas").style.display = '';
                $("lbValor2").innerHTML = 'cada.';
            }else{
                $("lbValor1").innerHTML = '';
                $("valorParcelas").style.display = 'none';
                $("valorParcelas").value = "0.00";
                $("lbValor2").innerHTML = '';
            }

        }    

        function validaTipo(){
            if( $("tipoDuplicata").value =="com"){
                $("lblDias").style.display = '';
                $("lblaPartirDe").style.display = 'none';
                $("mes").style.display = 'none';
            } else {
                if( $("tipoDuplicata").value =="todoDia")
                    $("lblDias").style.display = 'none';
                $("lblaPartirDe").style.display = '';
                $("mes").style.display = '';
            }     
        }
        
        //funcao para quando clicar no check CANCELAR aparecer ou nao o campo MOTIVO.
        function cancelar(index){
            if($("isCancelado"+index).checked){
                $("trMotivo_"+index).style.display = ""
            }else{
                $("trMotivo_"+index).style.display = "none"
            }   
        }
        

        /* Cria as parcelas dividindo o valor da despesa pela quantidade especificada de duplicatas*/
        function doParcells(dias) {
            colocarTotal(); 
            var mesR; 
            var emissao = $("dtemissao").value;
            var diaE = emissao.split("/")[0];
            var mesE = emissao.split("/")[1];
            var anoE = emissao.split("/")[2];
            /* Data atual */
            var data = new Date(anoE, mesE  - 1, diaE );

            /* Ano */ 
            var anoRAux = data.getFullYear();

            if($("tipoDuplicata").value == "com"){

                idxDespesa = 0;
                var qtDup = parseFloat($("qtdParcelas").value);
                //se existir alguma dup baixada entao exclua apartir da ultima baixada 
                removeElementsByPrefix("trDup", 1);   
                removeElementsByPrefix("trDup2", 1);
                //adicionando as parcelas na lista
                for (i = 1; i <= qtDup; ++i) {
                    var vlDespesa = parseFloat($("valor_liquido").value);    
                    var vlDup = formatoMoeda(parseFloat(vlDespesa / qtDup)); 
                    //Se a divisao n for exata, entao some na ultima duplicata para balancear o valor.
                    if (i == qtDup){
                        var diffVlDup = formatoMoeda((vlDup * qtDup) - vlDespesa);
                        vlDup = formatoMoeda(vlDup - parseFloat(diffVlDup));
                    }
                    addParcell(i * dias,incData($("dtemissao").value, i * dias), vlDup, "<center>-</center>", "<center>-</center>", false, "<center>-</center>", "<center>-</center>", false, //9
                    "<center>-</center>",'',0,0,0,0,false, 0,false,'','',incData($("dtemissao").value, i * dias));//9
                    
                }
            } else {


                idxDespesa = 0;
                var qtDup = parseFloat($("qtdParcelas").value);
                //se existir alguma dup baixada entao exclua apartir da ultima baixada 
                removeElementsByPrefix("trDup", 1);   
                removeElementsByPrefix("trDup2", 1);
                //adicionando as parcelas na lista
                for (i = 1; i <= qtDup; ++i) {
                    var vlDespesa = parseFloat($("valor_liquido").value);    
                    var vlDup = formatoMoeda(parseFloat(vlDespesa / qtDup)); 
                    //Se a divisao n for exata, entao some na ultima duplicata para balancear o valor.
                    if (i == qtDup){
                        var diffVlDup = formatoMoeda((vlDup * qtDup) - vlDespesa);
                        vlDup = formatoMoeda(vlDup - parseFloat(diffVlDup));
                    }
                    var diaParcela = parseInt($("qtdDiasParcelas").value, 10); 
                    if(diaParcela>31 || diaParcela<diaE){
                        if(diaParcela>31 || diaParcela<=0){
                            alert("Dia Inválido !");
                            $("qtdDiasParcelas").focus();
                            return false;
                        }else{
                            if(diaParcela<diaE && $("mes").value == "mesAtual"){
                                alert("A 1ª parcela não pode ficar menor que a data de emissão!");
                                $("qtdDiasParcelas").focus();
                                return false;   
                            }
                        }
                    }
                    /* Dia */
                    var diaR = diaParcela ;
                    /* Mês */

                    if($("mes").value == "mesAtual" && i==1){
                        mesR = parseFloat(mesE);
                    }else{
                        if($("mes").value == "proximoMes" && i==1){
                            mesR = parseFloat(mesE)+1;
                        }
                    }
                    if(mesR==13){
                        mesR = 1;
                        anoRAux = parseFloat(anoRAux) + 1;
                    }
                    /* Formatação do mês  */
                    if(mesR != 10 && mesR != 11 && mesR != 12 && mesR<13){
                        mesR = "0" + mesR ;   
                    }
                    if (parseFloat(diaR) > 0 && parseFloat(diaR) <10){
                        diaR = "0" + diaR;
                    }
                    
                    var novaData = (isNaN(diaR) ? '01' : diaR) +"/"+mesR+"/"+anoRAux;
                    while(!eDate.isValid({'dd/mm/yyyy':novaData})){
                        diaR = diaR - 1;
                        novaData = diaR +"/"+mesR+"/"+anoRAux;
                    }
                    //while(!this.validaData2(novaData)){
                    // diaR = diaR - 1;
                    //novaData = diaR +"/"+mesR+"/"+anoRAux;
                    // }
                    mesR = parseFloat(mesR) + 1;
                    addParcell(i * dias,novaData, vlDup, "<center>-</center>", "<center>-</center>", false, "<center>-</center>", "<center>-</center>", false, "<center>-</center>",//9
                    '',0,0,0,0,false, 0,false,'','',novaData);//8
                }  


            }
        }

        function validaData2(data){
            barras = data.split("/");
            if (barras.length == 3){
                var dia = barras[0];
                var mes = barras[1];
                var ano = barras[2];
                var anoAnt = ano;
                if (ano.length == 2){
                    if (ano >= 50 && ano <= 99)
                        ano = "19" + ano;
                    else
                        ano = "20" + ano;
                }


                //Verificando se o dia e o mï¿½s ï¿½ vï¿½lido
                if ((mes < 1 || mes > 12) || (dia < 1 || dia > 31))
                    return false;
                //Verificando se o dia estï¿½ correto para os meses com 30 dias
                else if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia == 31)
                    return false;
                //Verificando se o dia foi digitado corretamente para o mï¿½s 02
                else if (mes == 2 && dia > 29)
                    return false;
                //Verificando a qtd de dï¿½gitos do ano
                else if ( ano.length != 4)
                    return false;
                else{
                    data.value = dia + "/" + mes + "/"+ ano;
                    return true;

                }

            }else{
                return false;
            }
        }

        function viewDadosAdicionais(view, idx){
            $("plus"+idx).style.display = (view?"none":"");
            $("minus"+idx).style.display = (view?"":"none");
            $("trDup2"+idx).style.display = (view?"":"none");
        }

        function getValorLiquidoParcela(idx){

            $("dupRetencoes"+idx).value = formatoMoeda(parseFloat($("dupPis"+idx).value)+
                parseFloat($("dupCofins"+idx).value) +
                parseFloat($("dupCssl"+idx).value));

            $("dupLiquido"+idx).value = formatoMoeda(parseFloat($("dupVlParc"+idx).value)+
                parseFloat($("dupTaxas"+idx).value) -
                parseFloat($("dupRetencoes"+idx).value));
        }

        function getVlTotalAprop(){
            var tot = 0;
            if ($("trAprop1") != null)
                for (i = 1; i <= indexAprop.length; ++i)
                    if (indexAprop[i - 1] == true) 
                        tot = tot + parseFloat($("apropVl" + i).value);
            return tot;
        }
        
        
        /**
         *Função que conta quantas Apropriações tem a filial diferente da que está sendo lançada.
         *A função requer um contador de apropriações para fazer o loop.
         * @return Retorna a quantidade de Apropropriações que tem a filial diferente.
         */
        function getContFiliaisDiferentes(){
            var quantidadeFiliais = 0;
            var filial = $("idfilial").value;
            for(var i= 1;i <= indexAprop.length;i++){
                if($("idFil"+i) != null){
                    var idFilialApp = $("idFil"+i).value;
                    if(filial != idFilialApp){
                        quantidadeFiliais++;
                    }
                }
            }
            return quantidadeFiliais    
        }
        

        function addAppropriation(idPlcusto, descPlcusto, valorAprop, idVeiculo, placaVeiculo, idFilial, filialAbrev, idUnd, undSigla, descAprop) {            
            var indice = 1;
            if ($("trAprop1") != null)
                //alterou as posições do substring para poder usar 3 casas decimais
                indice = parseFloat($("corpoAprops").lastChild.id.substring(7,10)) + 1;

            var trLine = makeElement("TR", "class=CelulaZebra"+((indice % 2) == 0 ? 1 : 2)+"&id=trAprop"+indice);
            //criando planocusto
            var inIdPlCusto = makeElement("INPUT", "type=hidden&id=idPl"+indice+"&value="+idPlcusto);
            var tdPlCusto = makeElement("TD", "id=tdApropPl" + indice + "&innerHTML="+descPlcusto);
            var btPlCusto = makeElement("INPUT", "id=botaoPlanoCusto_"+indice+"&type=button&value=...&class=botoes&onclick=popLocate("+indice+",<%=BeanLocaliza.PLANO_CUSTO_DESPESA%>,'Plano_Custo',0)");
            trLine.appendChild(inIdPlCusto);
            trLine.appendChild(appendObj(makeElement("TD",""), btPlCusto));
            trLine.appendChild(tdPlCusto);
            //criando campo valor
            var inApropVl = makeElement("INPUT", "id=apropVl" + indice + "&type=TEXT&onchange=seNaoFloatReset($('apropVl"+indice+"'),'0.00')&"+
                "maxLength=10&size=7&class=inputtexto&value="+formatoMoeda(valorAprop));
            trLine.appendChild(appendObj(makeElement("TD",""), inApropVl));
            //criando campos do veiculo
            var idVeic = makeElement("INPUT", "type=hidden&id=idVei"+indice+"&value="+idVeiculo);
            var btVeic = makeElement("INPUT", "id=botaoAddVeiculo_"+ indice +"&type=button&onclick=popLocate("+indice+",'<%=BeanLocaliza.CAVALO_E_CARRETA%>','Veiculo',1)&class=botoes&value=...");
            var tdVei = makeElement("TD", "");
            trLine.appendChild(idVeic);
            trLine.appendChild(appendObj(tdVei, btVeic));
            trLine.appendChild(appendObj(tdVei, makeElement("IMG","id=botaoBorracharVeiculo_"+indice+"&src=img/borracha.gif&align='absbottom'&title=Apagar Veiculo&class=imagemLink&onclick=limparVeiculo("+indice+");")));
            trLine.appendChild(appendObj(tdVei, makeElement("LABEL", "id=lbPlacaVei"+indice+"&innerHTML="+placaVeiculo)));
            //criando campos da filial
            var idFil = makeElement("INPUT", "type=hidden&id=idFil"+indice+"&value="+idFilial);
            var btFil = makeElement("INPUT", "id=botaoAddFilial_"+ indice +"&type=button&onclick=popLocate("+indice+",'<%=BeanLocaliza.FILIAL_DESTINO%>','Filial',0)&class=botoes&value=...");
            var tdFil = makeElement("TD", "");
            trLine.appendChild(idFil);
    <%=(nivelUserFl > 1 ? "trLine.appendChild(appendObj(tdFil, btFil));" : "")%>
            // não utilize string com & nos campos de makeElement pois vai quebrar igual a abreviatura quebrou a tela.
            trLine.appendChild(appendObj(tdFil, makeElement("LABEL", "id=lbAbrevFil"+indice )));

            //criando campos da unidade de custo
            var idUnd = makeElement("INPUT", "type=hidden&id=idUnd"+indice+"&value="+idUnd);
            var btUnd = makeElement("INPUT", "id=botaoAddUnidadeCusto_"+ indice +"&type=button&onclick=popLocate("+indice+",'<%=BeanLocaliza.UNIDADE_CUSTO%>','Unidade_de_Custo',1)&class=botoes&value=...");
            var tdUnd = makeElement("TD", "");
            trLine.appendChild(idUnd);
            trLine.appendChild(appendObj(tdUnd, btUnd));
            trLine.appendChild(appendObj(tdUnd, makeElement("IMG","id=botaoBorrachaUnidadeCusto_"+ indice +"&src=img/borracha.gif&align='absbottom'&title=Apagar unidade de custo&class=imagemLink&onclick=limparUnd("+indice+");")));
            trLine.appendChild(appendObj(tdUnd, makeElement("LABEL", "id=lbUnd"+indice+"&innerHTML="+undSigla)));
            //criando campo de observação
            var idDescAprp = makeElement("INPUT","type=text&id=descAprop_"+indice+"&class=inputtexto&size=30&maxlength=30&value="+(descAprop == null || descAprop == "null" || descAprop == undefined ? "" : descAprop));
            var tdDescAprp = makeElement("TD","");
            trLine.appendChild(idDescAprp);
            
            //incluindo na lista o botao de excluir Apropriacao
            trLine.appendChild(appendObj(makeElement("TD",""), 
            makeElement("IMG","id=botaoLixoPlanoCusto_"+indice+"&src=img/lixo.png&title=Excluir&class=imagemLink&onclick=delAppropriation('"+indice+"')")));
            $("corpoAprops").appendChild(trLine);   
            $("lbAbrevFil"+indice).innerHTML = filialAbrev;
            // se estiver carregando e nivel menor que quatro e tem parcela quitada.
            if (<%= (carregadesp ? (nivelUserApropParcelaQuitada < 4 && temParcelaQuitada) : false) %>) {
                
                //plano
                $("botaoPlanoCusto_" + indice).style.display = "none";//botão ADD
                
                //valor
                $("apropVl" + indice).readOnly = "true";//input VALOR
                jQuery("#apropVl" + indice).toggleClass("inputReadOnly")//input VALOR
                
                //veiculo
                $("botaoAddVeiculo_" + indice).style.display = "none";//botão ADD
                $("botaoBorracharVeiculo_"+indice).style.display = "none";//borracha
                
                //filial
                $("botaoAddFilial_"+ indice ).style.display = "none";//botão ADD
                
                //unidade de custo
                $("botaoAddUnidadeCusto_"+ indice).style.display = "none";//botão ADD
                $("botaoBorrachaUnidadeCusto_"+ indice).style.display = "none";//borracha
                
                //apagar plano custo
                $("botaoLixoPlanoCusto_"+indice).style.display = "none";//borracha
            }
            //adicionando o indice no array(como o array começa em 0, subtraimos 1)
            indexAprop[indice - 1] = true;
        }

        function limparVeiculo(indice){ clean("idVei"+indice); $("lbPlacaVei"+indice).innerHTML = ''; }

        function limparUnd(indice){ clean("idUnd"+indice); $("lbUnd"+indice).innerHTML = ''; }

        function delAppropriation(indiceAprop) {
            if (confirm("Deseja mesmo excluir esta apropriação?"))
                $("trAprop" + indiceAprop).parentNode.removeChild($("trAprop" + indiceAprop));
            //removendo o indice no array(como o array começa em 0 subtraimos 1)
            indexAprop[indiceAprop - 1] = false;
        }

        function aoClicarNoLocaliza(idjanela){    
            function indiceJanela(initPos, finalPos) { 
                return idjanela.substring(initPos, finalPos); 
            }
            //localizando planocusto
            if (idjanela.indexOf("Plano_Custo") > -1) 
                if (indiceJanela(11,13) == "")
                    addAppropriation($("idplanocusto_despesa").value,
            $("plcusto_conta_despesa").value+" - "+$("plcusto_descricao_despesa").value, 
            ($("valor").value - ($("trAprop1") == null? 0:getVlTotalAprop())),
            "", "", $("idfilial").value, $("fi_abreviatura").value, "", "", $("descricao_apropriacao").value);
            else {
                $("idPl" + indiceJanela(11,13)).value = $("idplanocusto_despesa").value;
                $("tdApropPl" + indiceJanela(11,13)).innerHTML = $("plcusto_conta_despesa").value + " - " + $("plcusto_descricao_despesa").value;
            }     
            //ao localizar veiculo
            if (idjanela.indexOf("Veiculo") > -1) {
                if (idjanela.indexOf("Veiculo_Prop") > -1) {
                    $("idveiculo_prop").value = $("idveiculo").value;
                    $("vei_placa_prop").value = $("vei_placa").value;
                } else {
                    $("idVei" + indiceJanela(7, 10)).value = $("idveiculo").value;
                    $("lbPlacaVei" + indiceJanela(7, 10)).innerHTML = "&nbsp;" + $("vei_placa").value;
                }
            } 
            //ao localizar filial[para rateio, nao para lancamento]
            if (idjanela.indexOf("Filial") > -1 && indiceJanela(6,8) != "") {
                $("idFil" + indiceJanela(6,9)).value = $("idfilial2").value;
                $("lbAbrevFil" + indiceJanela(6,9)).innerHTML = "&nbsp;"+$("fi_abreviatura2").value;
            }          
            //ao localizar unidade de custo
            if (idjanela.indexOf("Unidade_de_Custo") > -1) {
                //alterou a posicao do parametros do indicejanela para poder pegar 3 casas decimais
                $("idUnd" + indiceJanela(16,19)).value = $("id_und").value;
                $("lbUnd" + indiceJanela(16,19)).innerHTML = "&nbsp;"+$("sigla_und").value;
            }          
            //ao localizar unidade de custo
            if (idjanela.indexOf("Fornecedor") > -1) {
                if($('idplcustopadrao').value != 0){
                    getPlcustoPadrao();
                    }
                
                var isCompAerea = ($("is_companhia_aerea").value=="t" ? true : false);
                $("is_companhia_aerea").value = isCompAerea;
                    
                    if(isCompAerea){
                        visivel($("trAWB"));
                    }else{
                        invisivel($("trAWB"));
                        removerAllAWB();
                    }

            }
            
            if(idjanela.indexOf("Rateio")>-1){
                buscarRateio(parseInt($("idrateio").value));                
            }

            // Ao localizar proprietário
            if (idjanela.indexOf('Proprietario') > -1) {
                if ($('tipo_controle_conta_corrente').value == 's') {
                    jQuery('.td_veiculo_prop').show();
                } else {
                    jQuery('.td_veiculo_prop').hide();
                }
            }
        }
        
        function buscarRateio(idRateio){
            function e(transport){
                var textoresposta = transport.responseText;

                var lista = jQuery.parseJSON(textoresposta);
                var itensRateio = lista.list[0].itemRateio;
                //                var listContratoFrete = lista.list[0].contratoFrete;
                var totalValor = 0;//essa é a soma dos valores para não dar errado no ultimo rateio;
                var valorParcial = 0;//essa é a variavel que será os valores a serem adicionados;
                        
                var length = (itensRateio != undefined && itensRateio.length != undefined ? itensRateio.length : 1);

               

                if (length == 1) {
                   
                    addAppropriation(itensRateio.planocusto.idconta,
                        itensRateio.planocusto.conta+"-"+itensRateio.planocusto.descricao,
                        (parseFloat(itensRateio.percentual) * parseFloat($("valor").value)/100), 
                        itensRateio.veiculo.idveiculo,
                        (itensRateio.veiculo.placa != undefined?itensRateio.veiculo.placa:""),
                        itensRateio.filial.idfilial,    
                        itensRateio.filial.abreviatura,    
                        itensRateio.unidadeCusto.id,    
                        (itensRateio.unidadeCusto.sigla != undefined?itensRateio.unidadeCusto.sigla:""));
                           
                }else{
                
                    for(var i = 0; i < length;i++){
                        if ((i+1) == length) { // i + 1 para saber se é igual, já que a condição será FALSE;
                            //se for o ultimo ele soma todos os valores já impressos e subtrai do TOTAL da despesa.
                            valorParcial = formatoMoeda(parseFloat($("valor").value - parseFloat(totalValor)));
                        }else {
                            //se não for o ultimo ele fará o rateio com as porcentagens
                            valorParcial = (parseFloat(itensRateio[i].percentual) * parseFloat($("valor").value)/100);
                        }
                        
                        addAppropriation(itensRateio[i].planocusto.idconta,
                        itensRateio[i].planocusto.conta+"-"+itensRateio[i].planocusto.descricao,
                        valorParcial, 
                        itensRateio[i].veiculo.idveiculo,
                        (itensRateio[i].veiculo.placa != undefined?itensRateio[i].veiculo.placa:""),
                        itensRateio[i].filial.idfilial,    
                        itensRateio[i].filial.abreviatura,    
                        itensRateio[i].unidadeCusto.id,    
                        (itensRateio[i].unidadeCusto.sigla != undefined?itensRateio[i].unidadeCusto.sigla:""));
                        
                        totalValor = formatoMoeda(parseFloat(totalValor) + parseFloat(valorParcial));
                    }
                }
            }
            
            tryRequestToServer(function(){
                new Ajax.Request("./caddespesa.jsp?acao=buscarRateio&idRateio="+idRateio,{method:'post',onSuccess: e});                    
            });
  
        }
        

        function popLocate(indice, idlista, nomeJanela){
            launchPopupLocate("./localiza?acao=consultar&idlista="+idlista, nomeJanela + indice); 
        }

        //exibe uma msg e para a instrucao
        function alertMsg(msgText){ alert(msgText); return false; }

        function checkDups() {
            if ($("trDup1") == null) return alertMsg("Deve existir pelo menos uma duplicata!");
            var totalVlDup = 0;
            for (i = 1; i <= idxDespesa; ++i){
                totalVlDup = (parseFloat($("dupVlParc"+i).value) + totalVlDup);
                if (parseFloat($("dupVlParc"+i).value) <= 0) 
                    return alertMsg("O valor de uma duplicata não pode ser inferior ou igual a zero!");
                if (!validaData($("dupVenc"+i).value))
                    return alertMsg("A duplicata "+i+" está com a data inválida!"); 
            }
            if (formatoMoeda(totalVlDup) != parseFloat($("valor_liquido").value))
                return alertMsg("O valor total das duplicatas não pode ser diferente do valor da despesa!");

            return true;
        }

        function checkAprops() {
            var totalVlAprop = 0;
            var existeAprop = false;
            for (i = 1; i <= indexAprop.length; ++i)
                if (indexAprop[i - 1] == true) {
                    totalVlAprop = (parseFloat($("apropVl"+i).value) + totalVlAprop);
                    existeAprop = true;
                    if (parseFloat($("apropVl"+i).value) <= 0)  
                        return alertMsg("O valor de uma apropriação não pode ser inferior ou igual a zero!");
                }
            if (formatoMoeda(totalVlAprop) != parseFloat($("valor").value) && existeAprop)
                return alertMsg("O valor total das apropriações não pode ser diferente do valor da despesa!");


            if (<%=cfg.isUnidadeCustoObrigatoria()%> && !getUnidadeCusto()){
                return alertMsg("Informe a unidade de custo corretamente nas apropriações!");
            }         

            //else (Deveria ser um else) a aprop nao eh obrigatoria
            if ($("trAprop1") == null && !confirm("Não foi informado a apropriação, deseja salvar mesmo assim?")){
                return false;
            }

            return true;
        }

        function concatAprops() {
            var aprops = "";
            for (i = 1; i <= indexAprop.length; ++i) {
                if (indexAprop[i - 1] == true){                    
                    aprops += $("idPl"+i).value+"!-"+$("apropVl"+i).value+"!-" 
                            + $("idVei"+i).value+"!-"+$("idFil"+i).value + "!-" 
                            + ($("idUnd"+i).value == "" ? "0" : $("idUnd"+i).value)+ "!-" 
                            + ($("descAprop_"+i).value==""?"null":$("descAprop_"+i).value) + (i == indexAprop.length? "" : "!!");
                }                
                
            }
            console.log(aprops);
            return aprops;
        }

        function habilitaSalvar(opcao){
            $("salvar").disabled = !opcao;
            $("salvar").value = (opcao ? "Salvar" : "Enviando...");
        }

        function salva(acao){
            //checando competencia
            var comp = $("competencia").value;
            var idProp = "0";
            var isDespesaProp = false;
            idProp = $("idproprietario").value;
            isDespesaProp = $("isDespesaProprietario").checked;

    <%if (!carregadesp && cfg.getContaAdiantamentoFornecedor().getIdConta() != 0) {%>
            if ($("isDespesaProprietario").checked && $("idproprietario").value == "0")
                return alert("Informe o nome do proprietário corretamente!");

    <%}%>

            if ((comp.split("/").length != 2) || (parseFloat(comp.split("/")[0]) < 1  && parseFloat(comp.split("/")[1]) < 1))
                return alertMsg("O campo \"Competência\" esta preenchido incorretamente(formato mm/aaaa).");

            //checando dtemissao
            if (!validaData($("dtemissao").value) || $("dtemissao").value.length != 10)
                return alertMsg("A data de emissão é inválida!\nO formato correto é: dd/mm/aaaa");

            if (acao == 'incluir' && $("chkavista").checked && $('conta').value == 0)
                return alertMsg("Informe a conta para baixa corretamente.");

            if (wasNull("idfornecedor,dtemissao,descricao_historico,competencia"))
                return alertMsg("Preencha os campos corretamente!");
                
            var qtdFiliaisDiferentes = getContFiliaisDiferentes();
            if(qtdFiliaisDiferentes > 0){
                if(!confirm("Existe(m) "+ qtdFiliaisDiferentes +" apropriação(s) que tem a filial diferente do lançamento!\n"
                    +"Deseja salvar a despesa mesmo assim?")){
                    return false;
                }
            }
            
            if ($('chkprovisao').checked && $('notafiscal').value != ''){
                return alertMsg("ATENÇÃO! Para lançamentos de provisão o campo NF/DOCUM deverá ficar em branco.");
            }
            
            
            if($("qtdAWB").value > 0){
                var vl_acre = $("valorAcrescimo").value.replace(/[0,.]/g, "");
                var vl_desc = $("valorDesconto").value.replace(/[0,.]/g, "");
                if(vl_acre != ""){
                    if($("motivoAcrescimo").value.trim() == ""){
                        return alertMsg("Informe um motivo do acréscimo da AWB");
                    }
                }
                if(vl_desc != ""){
                    if($("motivoDesconto").value.trim() == ""){
                        return alertMsg("Informe um motivo de desconto da AWB");
                    }
                }
            }
            
            if (checkDups() && checkAprops()) {
                if (acao == "atualizar")
                    acao += "&idmovimento=<%=(carregadesp ? caddesp.getDespesa().getIdmovimento() : 0)%>";
                    
                var dups = concatDups();
                
                $('dups').value = dups;

                var inputvalues = "acao="+acao+"&qtdDups="+idxDespesa + "&qtdAWB=" + countAWB + "&AWBs="+concatAWB() +
                    "&aprops="+concatAprops()+
                    "&"+concatFieldValue("idfornecedor,serie,dtemissao,idfilial,valor,competencia,dtentrada,idhist,valor_irrf,valor_inss,valor_iss,valor_sest,qtdProvisao"+
                    ",valor_contabil,base_icms,aliq_icms,idcfop")+"&especie="+$("especie").value.split("@")[0]+
                    "&descHistorico="+$("descricao_historico").value+"&nfiscal="+$("notafiscal").value+"&isjacontabilizado="+$("isjacontabilizado").checked +
                    "&isProvisao="+$("chkprovisao").checked + "&isintegrafiscal="+$("isintegrafiscal").checked + 
                    "&isDespesaProprietario="+ isDespesaProp+ 
                    "&idproprietario="+ idProp + "&idveiculoProp="+ $("idveiculo_prop").value +
                    (acao == 'incluir' ? "&" + concatFieldValue("dtpagto,docum,conta") + "&avista=" + $('chkavista').checked : "");

                habilitaSalvar(false);
                
                window.open('about:blank', 'pop', 'width=210, height=100');
                
                $("formulario").action = "./caddespesa?" + inputvalues;
                $("formulario").submit();
                //requisitaPost(inputvalues, "./caddespesa");         
                
            }
        }

        function voltar(){
            document.location.replace('./consultadespesa?acao=iniciar');
        }

        function aoCarregar(){
            var awb;
            var podeExcluirAWB= true;
    <%  if (carregadesp) {%>
            idxDespesa = 0;
    <%
        boolean isReadOnly = desp.isDespesaCartaFrete();
        if (desp.getProprietarioMovBanco().getIdfornecedor() != 0) {
            isReadOnly = true;
        }
        //adicionando as duplicatas da despesa
        for (int n = 0; n < desp.getDuplicatas().length; ++n) {
            BeanDuplDespesa dup = desp.getDuplicatas()[n];
    %>
//    Removendo essa função para não calcular toda vez que carregar a tela.                
//    alteraEspecie();
    var dias = incDias('<%=desp.getDtEmissao() != null ? fmt.format(desp.getDtEmissao()) : "" %>','<%=dup.getDtvenc() != null ? fmt.format(dup.getDtvenc()) : ""%>');
    addParcell(dias,"<%=dup.getDtvenc() != null ? fmt.format(dup.getDtvenc()) : ""%>", "<%=dup.getVlduplicata()%>",//3
            "<%=dup.getDtpago() == null ? "" : fmt.format(dup.getDtpago())%>", "<%=new DecimalFormat("#,##0.00").format(dup.getVlpago())%>", <%=dup.isBaixado()%>,"<%=dup.getMovBanco().getConta().getNumero()%>", //4
            "<%=dup.getMovBanco().getDocum()%>", <%=dup.getUsuarioLib().getIdusuario() != 0%>,"<%=dup.getUsuarioBaixa().getLogin()%>",//3
            "<%=dup.getNumeroBoleto()%>",<%=dup.getVlacrescimo()%>,<%=dup.getValorPis()%>,<%=dup.getValorCofins()%>,<%=dup.getValorCssl()%>,<%=isReadOnly%>, <%=dup.getFpag().getIdFPag()%>,//7
             <%= dup.isIsParcelaCancelada() %>,'<%= dup.getMotivoCancelamento() %>','<%= dup.getDataCancelamentoStr()%>',"<%= dup.getPrevisaoPagamentoStr() %>",//4
             "<%=dup.getUsuarioLib().getIdusuario()%>","<%=dup.getUsuarioLib().getNome()%>"//2
             ,"<%=dup.getCnabCodigoReceitaTributo()%>","<%=dup.getCnabNomeContribuinte()%>","<%=dup.getCnabTipoIdentificacaoContribuinte()%>","<%=dup.getCnabIdentificacaoContrinuinte()%>"//4
             ,"<%=dup.getValorReceitaBruta()%>","<%=dup.getPercentualReceitaBruta()%>" ,"<%=dup.isPossuiRemessa()%>" );//2

    <%if (dup.isBaixado()) {%>
            podeExcluirAWB = false;
    <%}%>
    <%       }
        //adicioonando as apropriacoes
        for (int u = 0; u < desp.getApropriacoes().length; ++u) {
            BeanApropDespesa apr = desp.getApropriacoes()[u];
    %>           addAppropriation("<%=apr.getPlanocusto().getIdconta()%>", 
            "<%=apr.getPlanocusto().getConta()%> - <%=apr.getPlanocusto().getDescricao()%>", 
            "<%=apr.getValor()%>", 
            "<%=apr.getVeiculo().getIdveiculo()%>",
            "<%=(apr.getVeiculo().getPlaca() != null ? apr.getVeiculo().getPlaca() : "")%>",
            "<%=apr.getFilial().getIdfilial()%>",
            "<%=apr.getFilial().getAbreviatura()%>",
            "<%=apr.getUndCusto().getId()%>",
            "<%=apr.getUndCusto().getSigla()%>",
            "<%=apr.getDescricaoApropriacao() == null ? "" : apr.getDescricaoApropriacao() %>");
    <%       }%><%=desp.getApropriacoes().length%><%

        //adicionando os awb's
        if (desp.getFornecedor().isCompanhiaAerea()) {
            for (BeanAWB awb : desp.getListaAWB()) {%>
                    awb = new AWB();
                    awb.id = '<%=awb.getId()%>';
                    awb.movimento = '<%=awb.getNumero()%>';
                    awb.numeroAWB = '<%=awb.getNumeroAWB()%>';
                    awb.numeroVoo = '<%=awb.getNumeroVoo()%>';
                    awb.valor = formatoMoeda('<%=awb.getValorFrete()%>');
                    awb.dataEmissao = '<%=fmt.format(awb.getEmissaoEm())%>';
                    awb.cidadeOrigem = '<%=awb.getCidadeOrigem().getDescricaoCidade()%>';
                    awb.cidadeDestino = '<%=awb.getCidadeDestino().getDescricaoCidade()%>';

                    addAWB(awb, podeExcluirAWB);
    <%}

        }

        //Mostrando os dados fiscais
        if (desp.isIntegraFiscal()) {%>
                mostraFiscal();
    <%}
        }
    %> 
            if(podeExcluirAWB){
                visivel($("selecionarAWB"));
            }else{
                invisivel($("selecionarAWB"));

            }
                        
            if($("motivoAcrescimo") != null){
                $("motivoAcrescimo").value = '<%=(desp.getMotivoAcrescimoAWB() != null ? desp.getMotivoAcrescimoAWB() : "" )%>';
            }
            if($("motivoDesconto") != null){
                $("motivoDesconto").value = '<%=(desp.getMotivoDescontoAWB() != null ? desp.getMotivoDescontoAWB() : "" )%>';
            }
            if($("valorAcrescimo") != null){
                $("valorAcrescimo").value = colocarVirgula('<%=(desp.getValorAcrescimoAWB() != 0 ? desp.getValorAcrescimoAWB() : "0,00" )%>');
                mascara($("valorAcrescimo"),reais);
            }
            if($("valorDesconto") != null){
                $("valorDesconto").value = colocarVirgula('<%=(desp.getValorDescontoAWB() != 0 ? desp.getValorDescontoAWB() : "0,00" )%>');
                mascara($("valorDesconto"),reais);
            }
                        
        }
    
       
        
        function excluirDespesa(i){
         
            function e(transport){
                var textoresposta = transport.responseText;
                
                
                if (textoresposta.indexOf("ERROR") > -1) {
                    alert(textoresposta);
                }else{
                    alert(textoresposta);
                    voltar();
                }
                
                    
            }

            if(confirm("Deseja mesmo remover a despesa " + i +" ?")){             
                if (i != 0) {
                    new Ajax.Request("./caddespesa.jsp?acao=excluir&idmovimento="+i,{
                        method:'post',
                        onSuccess: e,
                        onFailure: e
                    });     
                }                                
            }
        }

        function getVlLiquido(){
            $("valor_liquido").value = formatoMoeda(parseFloat($("valor").value)-parseFloat($("valor_irrf").value)-parseFloat($("valor_inss").value)-parseFloat($("valor_iss").value)-parseFloat($("valor_sest").value));
        }

        function getPlcustoPadrao(){
            if ($('idplcustopadrao').value != '0' && $("trAprop1") == null){
                addAppropriation($('idplcustopadrao').value, $('contaplcusto').value + ' - ' + $('descricaoplcusto').value, 
                $('valor').value, 0, '', $('idfilial').value, $('fi_abreviatura').value, $('id_und_forn').value, $('sigla_und_forn').value), '';
            }else{
                
                // Foi criado a validação abaixo pois ao adicionar um AWB, caso a trAprop ainda não existir,
                // estava quebrando a tela e deixando o pop-up aberto. Em caso de futuro erro fazer nova validação.
                if (($("trAprop" + 1) != null && $("trAprop" + 1) != undefined ) && ($('idplcustopadrao').value != '0')) {
                    
                    $("trAprop" + 1).parentNode.removeChild($("trAprop" + 1) );
                    addAppropriation($('idplcustopadrao').value, $('contaplcusto').value + ' - ' + $('descricaoplcusto').value, 
                                     $('valor').value, 0, '', $('idfilial').value, $('fi_abreviatura').value, $('id_und_forn').value, $('sigla_und_forn').value), '';
                }
            }
        }

        function aVista(){
            $('qtdParcelas').value = '1';
            $('qtdParcelas').readOnly = $('chkavista').checked;
            //    addParcell(0,$("dtemissao").value, $('valor_liquido').value, "<center>-</center>", "<center>-</center>", false, "<center>-</center>", "<center>-</center>", false, "<center>-</center>",'',0,0,0,0);
            doParcells(0);
            $('fixo').style.display = ($('chkavista').checked ? "" : "none");
            
            if ($('dupFmtPgto1').value == '3') {
                invisivel($('docum'));
                visivel($('slct-docum'));
            } else {
                invisivel($('slct-docum'));
                visivel($('docum'));
            }
        }

        function calculaIcms(){
            $("valor_icms").value = formatoMoeda(parseFloat($("base_icms").value) * parseFloat($("aliq_icms").value) / 100);
        }

        function mostraFiscal(){
            $("dadosFiscais").style.display = ($('isintegrafiscal').checked ? "" : "none");
        }

        function alteraEspecie(){
            if ($('especie').value != ''){
                $('isjacontabilizado').checked = ($('especie').value.split('@')[1] == 't' ? false : true);
                $('isintegrafiscal').checked = ($('especie').value.split('@')[2] == 't' ? true : false);
            
                $("tipoPagamentoCNAB").value = ($('especie').value.split('@')[3]);
    <%if (cfg.getIsFiscal()) {%>
                mostraFiscal();
    <%}%>
            }
        }
        
        function habilitaCamposCNAB(){
               
            for(i=1; i<=idxDespesa; i++){
                if($("trTipoPagamentoCnab"+i)!=null){
                    if($("tipoPagamentoCNAB").value == 'null' ||$("tipoPagamentoCNAB").value == 'n'){
                        $("trTipoPagamentoCnab"+i).style.display='none';
                    } else{
                        $("trTipoPagamentoCnab"+i).style.display='';
                    }                    
                }  
            }
        }
        

        function localizacfop(){
            post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CFOP%>','Cfop',
            'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
        }

        function getUnidadeCusto(){
                for (i = 1; i <= indexAprop.length; ++i){
                    if ($("trAprop" + i) != null){
                        if (indexAprop[i - 1] == true){
                            if ($("idUnd" + i).value == '0' || $("idUnd" + i).value == ''){
                                return false;
                            }
                        }
                    }
                }
            return true;
        }

        //@@@@@@@@@@@@@@@@@@@@@@  AWB @@@@@@@@@@@@@@@@@@@@  INICIO
        var countAWB = 0;
        function removerAllAWB(){
            for(var i = 1; i<=countAWB;i++){
                Element.remove('trAWB_'+i);
            }
            countAWB = 0;
            calcularTotalAWB();
            mostrarTrAWB();
        }
        
       
         function removerAWB(i){
           var idAWB = $("idAWB_"+i).value;
           var idmovimento = $("idmovimento").value;
            if(confirm("Deseja mesmo remover o AWB desta despesa?")){
                var vlAwb =  $('labValor_'+i).innerHTML;
                var vlTotal = $("valor").value;   
                var vlTotalRes = parseFloat(vlTotal) - parseFloat(vlAwb);
                if(vlTotalRes<0){
                    $("valor").value=0;
                }else{
                    $("valor").value= vlTotalRes;
                }
                Element.remove('trAWB_'+i);
                if (idAWB != 0) {
                    new Ajax.Request("./caddespesa.jsp?acao=removerAWB&idAWB="+idAWB+"&idmovimento="+idmovimento,     {
                        method:'get',
                        onSuccess: function(){ alert('AWB removido com sucesso!') },
                        onFailure: function(){ alert('Something went wrong...') }
                    });     
                }                                
            }
            calcularTotalAWB();
            mostrarTrAWB();
        }
        
        function adicionarTotalAWB(  ){
            var valorTotal = 0;
            for (var i = 1; i <= countAWB; i++){
                if($("labValor_"+i) != null){
                    valorTotal = parseFloat(valorTotal) + parseFloat($("labValor_"+i).innerHTML);
                }
            }
            $("valor").value = formatoMoeda(valorTotal);
            getVlLiquido();
            getPlcustoPadrao();
        }
        
        function removerValorAWB(){
            var valorTotal = 0;
            for (var i = 1; i <= countAWB; i++){
                if($("labValor_"+i) != null){
                    valorTotal = parseFloat(valorTotal) + parseFloat($("labValor_"+i).innerHTML);
                }
            }
            $("valor").value = formatoMoeda(parseFloat($("valor").value) - parseFloat(valorTotal));
            getVlLiquido();
            getPlcustoPadrao();
        }
        
        function addAWB(awb, podeexcluir){
            if($("is_companhia_aerea").value == "false"){
                post_cad.close();
                alert("ERRO");
            }
            
            else{
                countAWB++;
                if(awb == null || awb == undefined){
                    awb = new AWB();
                }
                podeexcluir = (podeexcluir== null || podeexcluir==undefined? true : podeexcluir);

                var _hid1 = Builder.node("INPUT",{type:"hidden",id:"idAWB_"+countAWB, name:"idAWB_"+countAWB, value: awb.id});
                var _lab1 = Builder.node("LABEL",awb.numeroAWB);
                var _lab2 = Builder.node("LABEL",awb.numeroVoo);
                var _lab3 = Builder.node("LABEL",awb.dataEmissao);
                var _lab4 = Builder.node("LABEL",awb.cidadeOrigem);
                var _lab5 = Builder.node("LABEL",awb.cidadeDestino);
                var _lab6 = Builder.node("LABEL",{id:"labValor_"+countAWB},awb.valor);
                var _img = Builder.node("IMG",{src:"img/lixo.png", title:"Excluir o AWB da Despesa.", onclick: "removerAWB("+countAWB+")" });

                var _td1 = Builder.node("TD",{width:"13%", align:"center"});
                var _td2 = Builder.node("TD",{width:"13%", align:"center"});
                var _td3 = Builder.node("TD",{width:"15%", align:"center"});
                var _td4 = Builder.node("TD",{width:"22%", align:"left"});
                var _td5 = Builder.node("TD",{width:"22%", align:"left"});
                var _td6 = Builder.node("TD",{width:"11%", align:"right"});
                var _td7 = Builder.node("TD",{width:"4%", align:"center"});

                _td1.appendChild(_hid1);
                _td1.appendChild(_lab1);
                _td2.appendChild(_lab2);
                _td3.appendChild(_lab3);
                _td4.appendChild(_lab4);
                _td5.appendChild(_lab5);
                _td6.appendChild(_lab6);
                if(podeexcluir){
                    _td7.appendChild(_img);
                }

                var classe = ((countAWB % 2) != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign');

                var _tr = Builder.node("TR", {className: classe, id:"trAWB_"+countAWB});

                _tr.appendChild(_td1)
                _tr.appendChild(_td2)
                _tr.appendChild(_td3)
                _tr.appendChild(_td4)
                _tr.appendChild(_td5)
                _tr.appendChild(_td6)
                _tr.appendChild(_td7)

                $("tbodyAWB").appendChild(_tr);
                $("qtdAWB").value = countAWB;
                mostrarTrAWB();
            }
        }
        
        function isCompAereo(){

            if($("is_companhia_aerea").value=="true"){
                visivel($("trAWB"));
            }else{
                invisivel($("trAWB"));
            }
        }
        
        function getAWB(){
            //retorna os IDs dos conhecimentos deste manifestoids
            var idsAwb="0";
            for(var i = 0; i<=countAWB;i++){
                if($("idAWB_"+i)!=null){
                    idsAwb +=(idsAwb==""?"":",")+ $("idAWB_"+i).value;
                }
            }
            return idsAwb;
        }

        function concatAWB() {

            var listAWB = "";
            for (i = 1; i <= countAWB; ++i) {
                if($("idAWB_" + i)!= null){
                    listAWB +=  "!!"+$("idAWB_" + i).value; //<--- Finalizador do array bidimensional
                }
            }
            return listAWB;
        }

        function selecionar_awb(qtdLinhas,acao){
            var idsAwb=getAWB();

            // chama a tela que inclue conhecimentos neste manifesto
            post_cad = window.open('./pops/seleciona_awb_despesa.jsp?acao=iniciar&idsAwb='+idsAwb+'&acaoDoPai='+acao+'&mostratudo=true&idfornecedor='+$("idfornecedor").value
                +'&dtinicial=<%=Apoio.getDataAtual()%>&dtfinal=<%=Apoio.getDataAtual()%>','Selecionar_AWB',
            'top=50,left=0,height=700,width=1150,resizable=yes,status=1,scrollbars=1');
        }

        //@@@@@@@@@@@@@@@@@@@@@@  AWB @@@@@@@@@@@@@@@@@@@@  FIM

        //Consulta fonecedor
        function localizaFornecedorCgc(campo, valor){
            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport){
                var resp = transport.responseText;
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (resp == 'null'){
                    alert('Erro ao localizar fornecedor.');
                    return false;
                }else if(resp == ''){
                    $('idfornecedor').value = '0';
                    $('fornecedor').value = '';
                    $('cpf_cnpj').value = '';
                    $('descricao_historico').value = '';
                    $('idplcustopadrao').value = '';
                    $('contaplcusto').value = '';
                    $('descricaoplcusto').value = '';

                    if (confirm("Fornecedor não encontrado, deseja cadastrá-lo agora?")){
                        window.open('./cadfornecedor?acao=iniciar','Fornecedor','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                    }
                    return false;
                }else{
                    $('idfornecedor').value = resp.split('!=!')[0];
                    $('fornecedor').value = resp.split('!=!')[1];
                    $('cpf_cnpj').value = resp.split('!=!')[2];
                    $('descricao_historico').value = resp.split('!=!')[3];
                    $('idplcustopadrao').value = resp.split('!=!')[4];
                    $('contaplcusto').value = resp.split('!=!')[5];
                    $('descricaoplcusto').value = resp.split('!=!')[6];
                    $('id_und_forn').value = resp.split('!=!')[7];
                    $('sigla_und_forn').value = resp.split('!=!')[8];
                }
            }//funcao e()
            if (valor != ''){
                espereEnviar("",true);
                tryRequestToServer(function(){
                    new Ajax.Request("./caddespesa.jsp?acao=localizaFornecedor&valor="+valor+"&campo="+campo,{method:'post', onSuccess: e, onError: e});
                });
            }
        }

        function localizaproprietario(){

            var windowProp = window.open('localiza?acao=consultar&idlista=<%=BeanLocaliza.PROPRIETARIO%>','Proprietario',
            'top=80,left=70,height=500,width=700,resizable=yes,status=1,scrollbars=1');
        }

        function chqDespesaProp(possuiDespesa){
            if(possuiDespesa){
                $("botaoProprietario").style.display="";

                if ($('tipo_controle_conta_corrente').value == 's' && $('idproprietario').value != '0') {
                    jQuery('.td_veiculo_prop').show();
                }
            }else{
                $("botaoProprietario").style.display="none";

                if ($('tipo_controle_conta_corrente').value == 's') {
                    jQuery('.td_veiculo_prop').hide();
                }
            }
        }
        
        function abrirLocalizarRateio(){
            if($('valor').value > 0){
                launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.RATEIO%>','Rateio');
            }else{
                alert('Informe o valor da Nota Fiscal!');
            }  
        }
        
        function abrirLocalizarPlanoCusto(){
        if( $("idfornecedor").value == ""){
                alert('Favor selecionar um fornecedor');
            }else{
              launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CUSTO_DESPESA%>','Plano_Custo');
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
    var rotina = "despesa";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=carregadesp ? caddesp.getDespesa().getIdmovimento() : 0 %>;
    consultarLog(rotina, id, dataDe, dataAte);
}

function setAuditoria() {
    if ($("dataDeAuditoria") != null && $("dataDeAuditoria") != undefined) {
        $("dataDeAuditoria").value = "<%=carregadesp ? Apoio.getDataAtual() : ""%>";
    }
       
    if ($("dataAteAuditoria") != null && $("dataAteAuditoria") != undefined) {
        $("dataAteAuditoria").value = "<%=carregadesp ? Apoio.getDataAtual() : ""%>";
    }
}


function mostrarTrAWB(){
    if('<%=temParcelaQuitada%>' == 'true'){
        $("valorAcrescimo").className = "inputReadOnly";
        $("valorAcrescimo").readOnly = true;
        $("valorDesconto").className = "inputReadOnly";
        $("valorDesconto").readOnly = true;
        $("motivoAcrescimo").className = "inputReadOnly";
        $("motivoAcrescimo").readOnly = true;
        $("motivoDesconto").className = "inputReadOnly";
        $("motivoDesconto").readOnly = true;
        
    }
    if($("trAWB_1") != null ){
        $("trMotivoAcrescimo").style.display = "";
        $("trMotivoDesconto").style.display = "";
        $("trTotalAWB").style.display = "";
        $("valor").className = "inputReadOnly";
        $("valor").readOnly = true;
        $("valorParcelas").readOnly = true;
        $("valorParcelas").className = "inputReadOnly";
        calcularTotalAWB();
    }else{
        $("trMotivoAcrescimo").style.display = "none";
        $("trMotivoDesconto").style.display = "none";
        $("valorAcrescimo").value = "0,00";
        $("valorDesconto").value = "0,00";
        $("motivoAcrescimo").value = "";
        $("motivoDesconto").value = "";
        $("trTotalAWB").style.display = "none";
        $("valor").className = "inputtexto";
        $("valor").readOnly = false;
        $("valorParcelas").readOnly = false;
        $("valorParcelas").className = "inputtexto";
        calcularTotalAWB();
    }
}

function calcularTotalAWB(){
    if($("qtdAWB").value > 0){
        var i = 1;

        var valorTotalAWB = 0;


        for(var i = 0; i<=countAWB;i++){
            if($("labValor_"+i)!=null){
                valorTotalAWB = parseFloat(colocarPonto(colocarVirgula(valorTotalAWB))) + parseFloat(colocarPonto(colocarVirgula($("labValor_"+i).innerHTML)));
            }
        }

        if(valorTotalAWB == 0){
            valorTotalAWB = colocarPonto(colocarVirgula(valorTotalAWB));
        }

        var vl_acre = colocarPonto($("valorAcrescimo").value);
        var vl_desc = colocarPonto($("valorDesconto").value);

        var vl_total = parseFloat(colocarPonto(colocarVirgula(valorTotalAWB)))+
                parseFloat(colocarPonto(colocarVirgula(vl_acre)) - 
                parseFloat(colocarPonto(colocarVirgula(vl_desc))));
        if(vl_total < 0){
            alert("Valor do desconto não pode ser maior que o valor do acréscimo");
            $("valorAcrescimo").value = "0,00";
            $("valorDesconto").value = "0,00";
            calcularTotalAWB();
        }else{
            $("valor").value = colocarPonto(colocarVirgula((vl_total)));
            getVlLiquido();getPlcustoPadrao();
            $("totalAWB").value = colocarVirgula(vl_total);
            mascara($("totalAWB"),reais);
        }
    }
}

function seNaoValorReset(obj){
    if(obj != null && obj.value == "" || obj.value == "0"){
        obj.value = "0,00";
    }
}

function abrirLocalizarVeiculoProp() {
    launchPopupLocate('./localiza?acao=consultar&paramaux4=' + $("idproprietario").value + '&idlista=<%=BeanLocaliza.TODOS_VEICULOS%>', 'Veiculo_Prop');
}

function limparVeiculoProp() {
    $('vei_placa_prop').value = '';
    $('idveiculo_prop').value = '';
}

function addSlctDocum(valor) {
    let opt = new Element("option", {
        value: (valor == ' ---- ' ? '' : valor)
    });
    opt.text = valor;
    $('slct-docum').appendChild(opt);
}

function verFpag() {

    let slct = $('slct-docum');
    let docum = $('docum');
    while (slct.length > 0) {
        slct.remove(slct.length-1);
    }
    
    addSlctDocum(' ---- ');
    
    function e(transport){
        let textoresposta = transport.responseText;
        espereEnviar("",false); 
        if ($('is_controla_talonario').value == 't' || $('is_controla_talonario').value == 'true') {
            let lista = jQuery.parseJSON(textoresposta);
            let listCheque = lista.list[0].documento;
            listCheque.forEach(
                    function (e) {
                        addSlctDocum(e);
                    }
                );
        } else {
            addSlctDocum(textoresposta);
        }
    }
        
    // so se o tipo de pagamento for cheque
    if ($('dupFmtPgto1').value == '3' && $('conta').value !== '0') {
        visivel(slct);
        invisivel(docum);
        espereEnviar("",true);
        tryRequestToServer(function(){
                new Ajax.Request("TalaoChequeControlador?acao=proxCheque&idConta="+$('conta').value,{method:'post', onSuccess: e, onError: e});
        });
    } else {
        invisivel(slct);
        visivel(docum);
    }
}
        
</script>
<%@page import="despesa.especie.Especie"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>Lan. Despesa - Webtrans</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style2 {font-family: Verdana, Arial, Helvetica, sans-serif}
            -->
        </style>
    </head>

    <body onLoad="aoCarregar();applyFormatter(); isCompAereo();AlterneAba('tdPrincipal', 'divDados');setAuditoria();mostrarTrAWB();calcularTotalAWB();">
        <form method="post" action="./caddespesa" id="formulario" target="pop">
            <!-- Campos ocultos -->
            <input type="hidden" name="idcfop" id="idcfop" value="<%=(carregadesp ? String.valueOf(desp.getCfop().getIdcfop()) : "0")%>">
            <!-- id do fornecedor -->
            <input type="hidden" id="idfornecedor" value="<%=(carregadesp ? String.valueOf(desp.getFornecedor().getIdfornecedor()) : "")%>">
            <input type="hidden" id="idhist" value="<%=(carregadesp ? desp.getHistorico().getIdhistorico() : 0)%>">
            <input type="hidden" id="is_companhia_aerea" value="<%=(carregadesp ? desp.getFornecedor().isCompanhiaAerea() : false)%>">
            <!-- Filial do lancamento -->
                   <input type="hidden" id="idfilial" value="<%=(carregadesp ? desp.getFilial().getIdfilial()
                           : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getIdfilial() : 0))%>">
            <input type="hidden" id="idplcustopadrao" value="0">
            <input type="hidden" id="contaplcusto" value="">
            <input type="hidden" id="descricaoplcusto" value="">
            <!-- receber apropriacao selecionada -->
            <input type="hidden" id="idplanocusto_despesa">
            <input type="hidden" id="plcusto_conta_despesa">
            <input type="hidden" id="plcusto_descricao_despesa">
            <input type="hidden" id="id_und_forn" value="0">
            <input type="hidden" id="sigla_und_forn" value="">
            <input type="hidden" id="plcusto_conta_despesa">
            <!-- receber filial[da apropriacao] selecionada -->
            <input type="hidden" id="idfilial2">
            <input type="hidden" id="fi_abreviatura2">
            <!-- receber veiculo[da apropriacao] selecionado -->
            <input type="hidden" id="idveiculo">
            <input type="hidden" id="vei_placa">
            <input type="hidden" id="id_und">
            <input type="hidden" id="sigla_und">
            
            <input type="hidden" id="dups" name="dups" value="">
            <input type="hidden" id="idmovimento" name="idmovimento" value="<%=(carregadesp ? desp.getIdmovimento() : 0)%>">
            <input type="hidden" id="descricao_apropriacao" name="descricao_apropriacao" value="">
            
            <input type="hidden" id="tipoPagamentoCNAB" name="tipoPagamentoCNAB" value="">
            <input type="hidden" id="tipo_controle_conta_corrente" name="tipo_controle_conta_corrente" value="">
            <input type="hidden" id="is_controla_talonario" name="is_controla_talonario" value="<%=cfg.isControlarTalonario()%>">
            <!-- Fim -->

            <img src="img/banner.gif" >
            <br>
            <table width="90%" align="center" class="bordaFina" >
                <tr>
                    <td width="613" align="left">
                        <b>Lan&ccedil;amento de Despesa</b>
                    </td>
                    <%   if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("podeExcluir")))) {
                    %>
                    <td width="15">
                        <input name="excluir" type="button" class="botoes" value="Excluir"
                               onClick="javascript:tryRequestToServer(function(){excluirDespesa('<%=(carregadesp ? desp.getIdmovimento() : 0)%>');});">
                    </td>
                    <%   }
                    %>    
                    <td width="56" >
                        <input  name="bt_consultar" type="button" class="botoes" id="bt_consultar" onClick="voltar()" value="Consulta">
                    </td>
                </tr>
            </table>
            <br>
            <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr> 
                    <td colspan="7"  class="tabela">
                        <div align="center">Dados Principais</div>
                    </td>
                </tr>
                <tr> 
                    <td width="76" class="TextoCampos">Movimento:</td>
                    <td width="70" class="CelulaZebra2">
                        <b><%=(acao.equals("editar") ? String.valueOf(desp.getIdmovimento()) : caddesp.getProximoMovimento())%></b>
                    </td>
                    <td width="192" class="TextoCampos style2">Filial:</td>
                    <td colspan="4" class="CelulaZebra2">
                        <input name="fi_abreviatura" type="text" class="inputReadOnly" id="fi_abreviatura" size="16" maxlength="12" readonly
                               value="<%=(carregadesp ? desp.getFilial().getAbreviatura() : (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getAbreviatura() : ""))%>">
                        <% if (nivelUserFl > 1) {
                        %>
                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial')" value="...">
                        <% }%>
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td class="TextoCampos">Esp&eacute;cie:</td>
                    <td colspan="2">
                        <%Especie es = new Especie();
                            ResultSet rs = es.all(Apoio.getUsuario(request).getConexao());%> 
                        <select name="especie" id="especie" onBlur="javascript:alteraEspecie();habilitaCamposCNAB();" onChange="javascript:alteraEspecie();habilitaCamposCNAB();" class="inputtexto">
                            <option value="">Nenhuma</option>
                            <%while (rs.next()) {%>
                            <option value="<%=rs.getString("id") + "@" + rs.getString("is_contabilidade") + "@" + rs.getString("is_fiscal") +"@"+ rs.getString("tipo_pagamento")%>" <%=(desp.getEspecie_().getEspecie().equals(rs.getString("especie")) ? "selected" : "")%> ><%=rs.getString("especie") + " - " + rs.getString("descricao")%></option>
                            <%}%>   
                        </select>
                    </td>
                    <td width="48" class="TextoCampos">
                        <span class="TextoCampos">S&eacute;rie:</span>
                    </td>
                    <td width="37" class="CelulaZebra2">
                        <input name="serie" type="text" id="serie" size="3" maxlength="3" value="<%=(carregadesp ? desp.getSerie() : "")%>" class="inputtexto">
                    </td>
                    <td width="96" class="TextoCampos">NF / Docum. :</td>
                    <td width="132" class="CelulaZebra2">
                        <input name="notafiscal" type="text" id="notafiscal" size="16" maxlength="15" onChange="seNaoIntReset(this,'')" value="<%=(carregadesp ? desp.getNfiscal() : "")%>" class="inputtexto">
                    </td>
                </tr>
                <tr class="CelulaZebra2"> 
                    <td class="TextoCampos">Emiss&atilde;o:</td>
                    <td class="CelulaZebra2">
                        <input name="dtemissao" type="text" id="dtemissao" size="10" maxlength="10" 
                               value="<%=carregadesp ? fmt.format(desp.getDtEmissao()) : Apoio.getDataAtual()%>" 
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </td>
                    <td class="TextoCampos">Entrada:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="dtentrada" type="text" id="dtentrada" size="10" maxlength="10" 
                               value="<%=carregadesp ? fmt.format(desp.getDtEntrada()) : Apoio.getDataAtual()%>" 
                               onblur="alertInvalidDate(this)" class="fieldDate" >
                    </td>
                    <td  class="TextoCampos">Compet&ecirc;ncia:</td>
                    <td class="CelulaZebra2">
                        <input name="competencia" type="text" id="competencia" value="<%=(carregadesp ? desp.getCompetencia() : Apoio.getDataAtual().split("/")[1] + "/" + Apoio.getDataAtual().split("/")[2])%>" size="7" maxlength="7" class="inputtexto">
                    </td>
                </tr>
                <tr class="CelulaZebra2"> 
                    <td height="26" class="TextoCampos">Fornecedor:</td>
                    <td colspan="6">
                        <input name="cpf_cnpj" type="text" class="inputReadOnly" id="cpf_cnpj" size="17" value="<%=(carregadesp ? desp.getFornecedor().getCpfCnpj() : "")%>" onKeyPress="javascript:if (event.keyCode==13) localizaFornecedorCgc('f.cpf_cnpj', this.value)">
                        <input name="fornecedor_old" type="text" class="inputReadOnly" id="fornecedor" size="50" value="<%=(carregadesp ? desp.getFornecedor().getRazaosocial() : "")%>" readonly>
                        <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>','Fornecedor')" value="...">
                    </td>
                </tr>
            </table>
                <table width="90%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdPrincipal" class="menu-sel" onclick="AlterneAba('tdPrincipal', 'divDados')"> Dados Principais </td>
                                  <td style='display: <%=carregadesp && nivelUser ==4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlterneAba('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                            
                               </tr>
                            </table>
                        </td> 
                    </tr>
               </table>
             <div id="divDados" name="divDados">                     
              <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <!--ATENÇÂO: o campo abaixo foi solicitado para ser alinhado a esquerda PELA ANALISE. -->
                    <td class="CelulaZebra2NoAlign" align="left">Hist&oacute;rico:</td>
                    <!--ATENÇÂO: o campo acima foi solicitado para ser alinhado a esquerda PELA ANALISE. -->
                    <td colspan="6" class="CelulaZebra2">
                        <input name="codigo_historico" type="text" id="codigo_historico" value="<%=(carregadesp && desp.getHistorico().getCodigo_historico() != null ? desp.getHistorico().getCodigo_historico() : "")%>" onBlur="javascript:seNaoIntReset(this,'0');" size="2" maxlength="3" class="inputtexto">
                        <input type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.HISTORICO_DE_LANCAMENTO%>','Historico')" value="...">
                        <textarea cols="80" rows="2" wrap="VIRTUAL" name="descricao_historico" id="descricao_historico" class="inputtexto"><%=(carregadesp ? desp.getDescHistorico() : "")%></textarea>
                    </td>
                </tr>
                <tr style=<%=(cfg.getIsContabil() || cfg.getIsFiscal() ? "display:" : "display:none")%>>
                    <td height="17" colspan="3" class="TextoCampos">
                        <p align="center">
                            <input name="isjacontabilizado" type="checkbox" style="<%=(cfg.getIsContabil() ? "display:" : "display:none")%>" id = "isjacontabilizado" value="checkbox" <%=(carregadesp && desp.getIsJaContabilizado() ? "checked" : "")%>>
                            <%if (cfg.getIsContabil()) {%>
                            Lan&ccedil;amento j&aacute; contabilizado
                            <%}%>
                        </p>
                    </td>
                    <td height="17" colspan="4" class="TextoCampos">
                        <div align="center">
                            <input name="isintegrafiscal" type="checkbox" onClick="javascript:mostraFiscal();" style="<%=(cfg.getIsFiscal() ? "display:" : "display:none")%>" id="isintegrafiscal" value="checkbox" <%=(carregadesp && desp.isIntegraFiscal() ? "checked" : "")%>>
                            <%if (cfg.getIsFiscal()) {%>
                            Integrar com o fiscal 
                            <%}%>
                        </div>
                    </td>
                </tr>
                <tr id="trAWB" style="display: none" >
                    <td colspan="7">
                        <table width="100%" class="bordaFina">
                                <tr>
                                    <td>
                                        <table width="100%" class="bordaFina" id="tableAWB">
                                            <tbody id="tbodyAWB">
                                                <tr class="CelulaZebra1NoAlign">
                                                    <td class="CelulaZebra1NoAlign" align="center" width="13%">Número AWB</td>
                                                    <td class="CelulaZebra1NoAlign" align="center" width="13%">Número do Voo</td>
                                                    <td class="CelulaZebra1NoAlign" align="center" width="15%">Data de Emissão</td>
                                                    <td class="CelulaZebra1NoAlign" align="left" width="22%">Cidade Origem</td>
                                                    <td class="CelulaZebra1NoAlign" align="left" width="22%">Cidade Destino</td>
                                                    <td class="CelulaZebra1NoAlign" align="right" width="11%">Valor</td>
                                                    <td class="CelulaZebra1NoAlign" align="right" width="4%"></td>
                                                </tr>
                                            </tbody>
                                            <tfoot>
                                                <tr id="trMotivoAcrescimo">
                                                    <td class="TextoCampos" colspan="2"> 
                                                        Motivo Acréscimo:
                                                    </td>
                                                    <td class="CelulaZebra2" colspan="2"> 
                                                        <input name="motivoAcrescimo" id="motivoAcrescimo" type="text" class="inputTexto" size="50">
                                                    </td>
                                                    <td class="TextoCampos"> 
                                                        Valor Acréscimo:
                                                    </td>
                                                    <td class="CelulaZebra2NoAlign" align="right">  
                                                        <input name="valorAcrescimo" id="valorAcrescimo" type="text" maxlength="12" class="inputtexto" size="7" value="0,00" onblur="calcularTotalAWB();" onchange="calcularTotalAWB();seNaoValorReset(this);" onkeypress="mascara(this, reais);" onkeyup="mascara(this, reais);" onkeydown="mascara(this, reais);">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        
                                                    </td>
                                                </tr>
                                                <tr id="trMotivoDesconto">
                                                    <td class="TextoCampos" colspan="2">
                                                        Motivo Desconto:
                                                    </td>
                                                    <td class="CelulaZebra2" colspan="2">
                                                        <input name="motivoDesconto" id="motivoDesconto" type="text" class="inputTexto" size="50">
                                                    </td>
                                                    <td class="TextoCampos">
                                                        Valor Desconto:
                                                    </td>
                                                    <td class="CelulaZebra2NoAlign" align="right">
                                                        <input name="valorDesconto" id="valorDesconto" type="text" maxlength="10" class="inputtexto" size="7" value="0,00" onblur="calcularTotalAWB();" onchange="calcularTotalAWB();seNaoValorReset(this);" onkeypress="mascara(this, reais);" onkeyup="mascara(this, reais);" onkeydown="mascara(this, reais);">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        
                                                    </td>
                                                </tr>
                                                <tr id="trTotalAWB">
                                                    <td class="TextoCampos" colspan="4">
                                                    </td>
                                                    <td class="TextoCampos">
                                                        Total:
                                                    </td>
                                                    <td class="CelulaZebra2NoAlign" align="right">
                                                        <input name="totalAWB" id="totalAWB" type="text" class="inputReadOnly" readonly="true" size="7" value="0.00">
                                                    </td>
                                                    <td class="CelulaZebra2"></td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2">
                                        <input name="selecionarAWB" type="button" class="botoes" id="selecionarAWB" value="Selecione AWB's" onClick="selecionar_awb();">
                                        <input name="qtdAWB" type="hidden" class="botoes" id="qtdAWB" value="0" >
                                    </td>
                                </tr>
                                </table>
                            </td>
                        </tr>
                <tr name="dadosFiscais" id="dadosFiscais" style="display:none; ">
                    <td colspan="7">
                        <table width="100%"  border="0">
                            <tr class="celula">
                                <td colspan="10">
                                    <div align="center">
                                        <strong>Dados fiscais</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td width="9%" class="TextoCampos">CFOP :</td>
                                <td width="18%" class="CelulaZebra2">
                                    <input name="cfop_old" type="text" id="cfop" size="5" maxlength="5" readonly value="<%=(carregadesp ? desp.getCfop().getCfop() : "")%>" class="inputReadOnly">
                                    <input name="localiza_cfop" type="button" class="botoes" id="localiza_cfop" value="..." onClick="javascript:localizacfop();">
                                    <img src="img/borracha.gif" border="0" class="imagemLink" onClick="javascript:$('idcfop').value='0';$('cfop').value='';">
                                </td>
                                <td width="16%" class="TextoCampos">Valor cont&aacute;bil :</td>
                                <td width="7%" class="CelulaZebra2">
                                    <input name="valor_contabil" class="inputtexto" type="text" id="valor_contabil" onChange="seNaoFloatReset(this,'0.00');getVlLiquido();getPlcustoPadrao();" 
                                           size="7" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getValor()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%> >
                                </td>
                                <td width="13%" class="TextoCampos">Base ICMS : </td>
                                <td width="5%" class="CelulaZebra2">
                                    <input name="base_icms" class="inputtexto" type="text" id="base_icms" onChange="seNaoFloatReset(this,'0.00');calculaIcms();" 
                                           size="7" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getBaseIcms()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%>>
                                </td>
                                <td width="11%" class="TextoCampos">% ICMS :</td>
                                <td width="4%" class="CelulaZebra2">
                                    <input name="aliq_icms" type="text" class="inputtexto" id="aliq_icms" onChange="seNaoFloatReset(this,'0.00');calculaIcms();" 
                                           size="5" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getPercIcms()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%>>
                                </td>
                                <td width="13%" class="TextoCampos">Valor ICMS :</td>
                                <td width="4%" class="CelulaZebra2">
                                    <input name="valor_icms" type="text" class="inputReadOnly" id="valor_icms" onChange="seNaoFloatReset(this,'0.00');" 
                                           value="<%=(carregadesp ? Apoio.to_curr(desp.getValorIcms()) : "0.00")%>" size="5" maxlength="10" readonly="true">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="7" class="TextoCampos">
                        <table width="100%" border="1" cellspacing="0">
                            <tr>
                                <td colspan="2">&nbsp;</td>
                                <td colspan="8" class="celula">
                                    <div align="center">
                                        <strong>Impostos retidos </strong>
                                    </div>
                                </td>
                                <td colspan="2">&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="8%" class="TextoCampos">Valor NF: </td>
                                <td width="8%" class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="valor" onblur="tirarLinha();" type="text" id="valor" onChange="seNaoFloatReset(this,'0.00');getVlLiquido();getPlcustoPadrao();" 
                                               size="7" maxlength="10" class="inputtexto" value="<%=(carregadesp ? Apoio.to_curr(desp.getValor()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%>>
                                    </span>
                                </td>
                                <td width="8%" class="TextoCampos">IRRF:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="valor_irrf" type="text" id="valor_irrf" class="inputtexto" onChange="seNaoFloatReset(this,'0.00');getVlLiquido();" 
                                               size="5" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getValorIrrf()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%> >
                                    </span>
                                </td>
                                <td width="8%" class="TextoCampos">INSS:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="valor_inss" type="text" id="valor_inss" class="inputtexto" onChange="seNaoFloatReset(this,'0.00');getVlLiquido();" 
                                               size="5" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getValorInss()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%> >
                                    </span>
                                </td>
                                <td width="8%" class="TextoCampos">ISS:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="valor_iss" type="text" id="valor_iss" class="inputtexto" onChange="seNaoFloatReset(this,'0.00');getVlLiquido();" 
                                               size="5" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getValorIss()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%> >
                                    </span>
                                </td>
                                <td width="12%" class="TextoCampos">SEST/SENAT:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <input name="valor_sest" class="inputtexto" type="text" id="valor_sest" onChange="seNaoFloatReset(this,'0.00');getVlLiquido();" 
                                           size="5" maxlength="10" value="<%=(carregadesp ? Apoio.to_curr(desp.getValorSest()) : "0.00")%>" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%> >
                                </td>
                                <td width="8%" class="TextoCampos">L&iacute;quido:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <span class="CelulaZebra2">
                                        <input name="valor_liquido" type="text" class="inputReadOnly" id="valor_liquido" onChange="seNaoFloatReset(this,'0.00')" value="<%=(carregadesp ? Apoio.to_curr(desp.getValor() - desp.getValorIrrf() - desp.getValorInss() - desp.getValorIss() - desp.getValorSest()) : "0.00")%>"
                                               size="7" maxlength="10" readonly="true">
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="7">
                        <table width="100%" border="0">
                            <tr>
                                <td width="100%" class="CelulaZebra2">Qtd parcelas:
                                    <input name="qtdParcelas" type="text" id="qtdParcelas" class="inputtexto" onChange="seNaoIntReset(this,1)" value="<%=(carregadesp ? desp.getDuplicatas().length : 1)%>" size="2" maxlength="3" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%>>
                                    <label id="lbValor1" > no valor de </label>
                                    <input name="valorParcelas" type="text" id="valorParcelas" class="inputtexto" onChange="seNaoFloatReset(this,'0.00');" size="7" maxlength="10"  value="0.00" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%>>
                                    <label id="lbValor2" > cada.</label>
                                    Vencimento:
                                    <select id="tipoDuplicata" name="tipoDuplicata" class="inputtexto" onchange="validaTipo();" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "disabled" : "") : "") : "")%>>
                                        <option value="com" selected>A cada</option>
                                        <option value="todoDia">Todo dia</option>
                                    </select>
                                    <input name="qtdDiasParcelas" type="text" id="qtdDiasParcelas" class="inputtexto" onChange="seNaoIntReset(this,1)" value="01" size="2" maxlength="3" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "readonly" : "") : "") : "")%>>
                                    <label id="lblDias" name="lblDias">Dias</label>
                                    <label id="lblaPartirDe" name="lblaPartirDe" style="display: none">A partir do mês:</label>
                                    <select id="mes" name="mes" class="inputtexto" style="display: none">
                                        <option value="mesAtual">Atual</option>
                                        <option value="proximoMes">Seguinte</option>
                                    </select>
                                    <br>
                                    <div align="center">
                                        <input name="criarDups" type="button" class="botoes" id="criarDups" value="Criar Duplicatas" onClick="javascript:if($('chkprovisao').checked) $('qtdParcelas').value = '1';doParcells(($('qtdDiasParcelas').value == '' ? 30 : $('qtdDiasParcelas').value ));getPlcustoPadrao();" <%=(carregadesp ? (desp.isComissaoVendedor() ? (nivelUsuerLiberarAcesso == 0 ? "disabled" : "") : "") : "")%>>
                                        <%=(desp.isDespesaCartaFrete() ? "<font color=red>ATENÇÃO: Despesa lançada pela rotina de contrato de frete</font>" : "")%>
                                        <%=(desp.getProprietarioMovBanco().getIdfornecedor() != 0 ? "<font color=red>ATENÇÃO: Despesa lançada na conta Corrente do proprietário: " + desp.getProprietarioMovBanco().getRazaosocial() + "</font>" : "")%>
                                        <%=(desp.isComissaoVendedor() ? "<font color=red>ATENÇÃO: Despesa lançada pela rotina de comissão</font>" : "")%>
                                        <%if (!carregadesp) {%>
                                        <br><input name="chkavista" type="checkbox" id="chkavista" value="checkbox" onClick="javascript:aVista();">Lan&ccedil;amento &agrave; vista (Ao marcar a despesa será baixada automaticamente) <%}%>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td height="24" colspan="12" class="TextoCampos" style="display:<%=(!carregadesp && cfg.isProvisaoDespesa() ? "" : "none")%>">
                                    <div align="center">
                                        <input name="chkprovisao" type="checkbox" id="chkprovisao" value="checkbox" 
                                               onclick="javascript:$('qtdParcelas').value = '1';doParcells(30);">
                                        Gerar provisão desse lançamento. Quantidade de lan&ccedil;amentos 
                                        <span class="CelulaZebra2">
                                            <input name="qtdProvisao" type="text" id="qtdProvisao" onChange="seNaoIntReset(this,1)" 
                                                   value="1" size="2" maxlength="3" class="inputtexto">
                                        </span>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="tabela"> 
                    <td colspan="7" align="center">Duplicatas a pagar </td>
                </tr>
                <tr> 
                    <td colspan="7"> 
                        <!-- Duplicatas -->
                        <table width="100%" height="100%" border="0" cellpadding="0">
                            <form method="post" id="formDesp">
                                <tbody id="corpoDups">
                                    <tr class="tabela"> 
                                        <td width="2%"></td>
                                        <td width="12%">Parcela</td>
                                        <td width="3%">Dias</td> 
                                        <td width="10%">Vencimento</td>
                                        <td width="8%">Valor(+)</td>
                                        <td width="8%">Taxas(+)</td>
                                        <td width="12%">Retenções(-)</td>
                                        <td width="9%">Líquido(=)</td>
                                        <td width="16%">Nº Boleto</td>
                                        <td width="9%">Dt.Pago</td>
                                        <td width="8%">Vl.Pago</td>
                                        <td width="4%">FPAG</td>
                                        <td width="2%"></td>
                                        <td width="0%"></td>
                                    </tr>
                                </tbody>
                            </form>
                        </table>
                        <!-- FIM Duplicatas -->
                    </td>
                </tr>
                <%if (!carregadesp) {%>
                <tr id="fixo" name="fixo" style="display:none">
                    <td colspan="8">
                        <table width="100%" border="0">
                            <tr>
                                <td width="49" class="TextoCampos">Conta:</td>
                                <td colspan="2" class="CelulaZebra2">
                                    <select name="conta" id="conta" style="font-size:8pt;" class="fieldMin" onChange="verFpag()">
                                        <option value="0">Escolha a conta para baixa.</option>
                                        <%      //Carregando todas as contas cadastradas
                                            BeanConsultaConta conta = new BeanConsultaConta();
                                            conta.setConexao(Apoio.getUsuario(request).getConexao());
                                            conta.mostraContas((nivelUserFl > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarContas, idUsuario);
                                            ResultSet rsconta = conta.getResultado();
                                            while (rsconta.next()) {%>
                                        <option value="<%=rsconta.getString("idconta")%>"> <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%></option>
                                        <%}
                                            rs.close();%>
                                    </select>
                                </td>
                                <td width="102" class="TextoCampos">Data Pagam.: </td>
                                <td width="67" class="CelulaZebra2">
                                    <input name="dtpagto" type="text" id="dtpagto" size="10" maxlength="10" 
                                           value="<%=Apoio.getDataAtual()%>" 
                                           onblur="alertInvalidDate(this)" class="fieldDate" >
                                </td>
                                <td width="95" class="TextoCampos">Docum.:</td>
                                <td width="64" colspan="2" class="CelulaZebra2">
                                    <input name="docum" type="text" id="docum" size="6" maxlength="6" onChange="seNaoIntReset(this,'')" value="<%=(carregadesp ? desp.getNfiscal() : "")%>" class="inputtexto">
                                    <select name="slct-docum" id="slct-docum" class="inputtexto">
                                        <option value=""> ---- </option>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%}%>  

                <tr <%=(carregadesp || (cfg.getContaAdiantamentoFornecedor().getIdConta() == 0) ? "style='display:none'" : "")%>>
                    <td  colspan="3" class="TextoCampos">
                        <input type="checkbox" name="isDespesaProprietario" id="isDespesaProprietario" onclick="chqDespesaProp(this.checked);" value="true" <%=(carregadesp && desp.getProprietarioMovBanco().getIdfornecedor() != 0 ? "checked" : "")%>>
                        Acrescentar parcelas na conta corrente do proprietário:
                    </td>
                    <td  colspan="2" class="CelulaZebra2">
                        <input name="nome" id="nome" type="text" class="inputReadOnly" size="35" readonly/>
                        <input type="button" class="inputbotao" name="botaoProprietario" id="botaoProprietario"  onClick="tryRequestToServer(function(){localizaproprietario()});" value="..." style="display: none"/>
                        <input type="hidden" name="idproprietario" id="idproprietario" value="<%=desp.getProprietarioMovBanco().getIdfornecedor()%>"/>
                    </td>
                    <td colspan="1" class="TextoCampos td_veiculo_prop" style="display: none;">Veículo:</td>
                    <td colspan="1" class="CelulaZebra2 td_veiculo_prop" style="display: none;">
                        <input name="vei_placa_prop" id="vei_placa_prop" type="text" class="inputReadOnly8pt" size="13" readonly/>
                        <input type="hidden" name="idveiculo_prop" id="idveiculo_prop" value="0">
                        <input type="button" class="inputbotao" value="..." onClick="abrirLocalizarVeiculoProp();"/>
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onclick="limparVeiculoProp();">
                    </td>
                </tr>

                <tr class="tabela"> 
                    <td colspan="7" align="center">Apropria&ccedil;&atilde;o gerencial </td>
                </tr>
                <tr> 
                    <td colspan="7" class="CelulaZebra2">
                        <% if ( !(carregadesp ? (nivelUserApropParcelaQuitada < 4 && temParcelaQuitada) : false) ) {%>
                        <input id="btAddPl" type="button" class="botoes" value="Adicionar apropria&ccedil;&atilde;o"
                               onClick="abrirLocalizarPlanoCusto()">
                                
                            <%}%>
                        <input id="btAddRateio" type="button" class="botoes" value="Adicionar rateio"
                               onClick="abrirLocalizarRateio();">
                        <input type="hidden" id="idrateio" name="idrateio" value="0">
                    </td>
                </tr>
                <tr> 
                    <td colspan="7"> 
                        <table width="100%" height="100%" border="0" cellpadding="0">
                            <tbody id="corpoAprops">
                                <tr class="tabela"> 
                                    <td width="2%">&nbsp;</td>
                                    <td width="25%">Plano centro de custo</td>
                                    <td width="11%">Valor</td>
                                    <td width="15%">Ve&iacute;culo</td>
                                    <td width="20%">Filial</td>
                                    <td width="10%">Und. Custo</td>
                                    <td width="14%">Observação</td>
                                    <td width="0%"></td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
              </table>
             </div>
            <div id="divAuditoria" name="divAuditoria">           
              <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">           
             
                <tr> 
                    <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                </tr>
                <tr> 
                    <td colspan="7" >
                        <table width="100%" border="0">
                            <tr> 
                                <td width="10%" class="TextoCampos">Incluso:</td>
                                <td width="40%" class="CelulaZebra2">Em:<%=(carregadesp ? (fmt.format(desp.getDtLancamento())) : "")%><br>
                                    Por: <%=(carregadesp ? (desp.getUsuarioLancamento().getNome()) : "")%> </td>
                                <td width="10%" class="TextoCampos">Alterado:</td>
                                <td width="40%" class="CelulaZebra2">Em:<%=(carregadesp && desp.getDtAlteracao() != null ? fmt.format(desp.getDtAlteracao()) : "")%><br>
                                    Por:<%=(carregadesp ? (desp.getUsuarioAlteracao().getNome())  : "" )%> </td>
                            </tr>
                        </table>
                    </td>
                </tr>
              </table>
            </div>               
                            <br>
            <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">               
                <%
                    if (nivelUser >= 2 && !(carregadesp && nivelUserFl < 2
                            && desp.getFilial().getIdfilial() != idFilialUser)) {
                %>
                <tr class="CelulaZebra2">
                    <td colspan="7" align="center"> 
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar"
                               onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                    </td>
                </tr>
                <%        }%>
            </table>
            <br>
        </form>
    </body>
</html>
