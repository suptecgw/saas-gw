<%@page import="java.io.File"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Date"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         mov_banco.conta.*, 
         despesa.duplicata.*,
         mov_banco.talaocheque.ConsultaTalaoCheque,
         mov_banco.talaocheque.TalaoCheque,
         java.text.*,
         nucleo.Apoio,
         nucleo.BeanConfiguracao,
         mov_banco.BeanCadMovBanco,
         fpag.BeanConsultaFPag,
         nucleo.impressora.*,
         filial.BeanFilial,
         java.util.Vector "%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>

<%
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("bxpagar") : 0);
    int nivelUserBxViagem = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("bxpagarviagem") : 0);
    int nivelUserConciliacao = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("conbancaria") : 0);
    int nivelUserDespesa = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("caddespesa") : 0);
    int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
    int nivelCopiaCheque = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("impcopiacheque") : 0);
    int nivelApagaContas = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("apagacontasdia") : 0);
    int nivelLiberaSaldo = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("liberasaldocarta") : 0);
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0 && nivelUserBxViagem == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    //permissao para confirmar pagamento do saldo na NDD
   int nivelConfirmarPgtoNDD = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("confirmarPagamentoNDD") : 0);
   boolean filialConfirmarPgtoNDD = Apoio.getUsuario(request).getFilial().isConfirmarPagamentoNDD();
   char stUtilizacaoCFe = Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe();
   boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
   
    //int aux = (nivelApagaContas == 4 && idUsuario = rs.getInt("idusuariobaixa") && 
    //fim da MSA
    Date hoje = new Date();
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    String dataHoje = formatador.format(hoje);
    Locale localFmtValor = new Locale("pt", "BR");
    DecimalFormat fmtValor = new DecimalFormat("#,##0.00", new DecimalFormatSymbols(localFmtValor));

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    BeanConsultaDup dupls = null;
    BeanDuplDespesa duplicata = null;
    BeanAlteraDup altDupls = null;
    BeanConfiguracao cfg = null;
    Collection<String> documentos = new ArrayList<String>();
    cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();

    String chq = "0";     
    
            String dataPago = request.getParameter("dtpago");
            String dataCheque = request.getParameter("dtchq");
            String formaPag = request.getParameter("fpag");
            String contaF = request.getParameter("conta");
                
                if (dataPago == null) {
                    dataPago = Apoio.getDataAtual();
                }
                
                if (dataCheque == null) {
                    dataCheque = Apoio.getDataAtual();
                }
                
                
                request.setAttribute("dataCheque", dataCheque);
                request.setAttribute("formaPag", formaPag);
                request.setAttribute("dataPago", dataPago);
                request.setAttribute("contaPag", contaF);
                
    if (!acao.equals("iniciar")) {
        dupls = new BeanConsultaDup();
        dupls.setConexao(Apoio.getUsuario(request).getConexao());
        dupls.setApenasViagem(Apoio.getUsuario(request).getAcesso("bxpagarviagem") > 0 && Apoio.getUsuario(request).getAcesso("bxpagar") == 0);
        duplicata = new BeanDuplDespesa();
        altDupls = new BeanAlteraDup();
        altDupls.setConexao(Apoio.getUsuario(request).getConexao());
        altDupls.setExecutor(Apoio.getUsuario(request));
    }
    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("consultar")) {
        dupls.setMostraSaldoCarta((nivelUserBxViagem > 0 && nivelUser == 0));
        dupls.setValorDaConsulta(request.getParameter("idfornecedor"));
        dupls.setBaixado(request.getParameter("baixado"));
        dupls.setDataVenc1(request.getParameter("dtinicial"));
        dupls.setDataVenc2(request.getParameter("dtfinal"));
        dupls.setFilial(request.getParameter("idfilial"));
        dupls.setTipoData(request.getParameter("tipoData"));
        dupls.setNfiscal(request.getParameter("nf"));
        dupls.setValor1(Float.parseFloat(request.getParameter("valor1")));
        dupls.setValor2(Float.parseFloat(request.getParameter("valor2")));
        dupls.setMostraSaldoCarta(Boolean.parseBoolean(request.getParameter("mostrarSaldo")));
        dupls.setContaId(request.getParameter("filtroConta") == null ? 0 : Integer.parseInt(request.getParameter("filtroConta")));
        dupls.setOrdenacao(request.getParameter("ordenacao") == null ? "razaosocial" : request.getParameter("ordenacao").equals("nfiscal") ? "nfiscal::numeric" : request.getParameter("ordenacao"));// foi deixado o nfiscal::numeric pois a base do cliente estava com lixo
        dupls.setNumeroBoleto(request.getParameter("codBarras"));
        dupls.setIdPlanoCusto(Apoio.parseInt(request.getParameter("idPlano")));
        dupls.setCodRepom(request.getParameter("codRepom"));
        //11/05/2015
        dupls.setMostrarDuplicatas(request.getParameter("hidMostrarDuplicatas") != null && request.getParameter("hidMostrarDuplicatas").equals("am")? "" : request.getParameter("hidMostrarDuplicatas"));
        dupls.setMostrarDespesas(request.getParameter("hidMostrarDespesa") != null && request.getParameter("hidMostrarDespesa").equals("a")? "" : request.getParameter("hidMostrarDespesa"));        
        dupls.setUsuario(Apoio.getUsuario(request));
        
    } else if (acao.equals("baixar")) {
        //Quando for alterar algum campo ou informação ne treixo de código, no objeto BeanDuplDespesa, verificar também no NddControlador, 
        //existe um doBeanDuplDespesa desse mesmo objeto, provavalmente vai precisar alterar lá também. - Qualquer dúvida falar com Vladson ou Paulo
        
        //Preenchendo o array dos conhecimentos
        String valor = request.getParameter("ids");
        //recebendo valor do primeiro cheque
        chq = (request.getParameter("doc").equals("") ? "1" : request.getParameter("doc"));
        int qtdDupls = valor.split("_").length;
        BeanDuplDespesa[] arDupls = new BeanDuplDespesa[qtdDupls];        
        for (int k = 0; k < qtdDupls; ++k) {
            BeanDuplDespesa dp = new BeanDuplDespesa();
            dp.setId(Integer.parseInt(valor.split("_")[k]));
            dp.setIdmovimento(Apoio.parseInt(request.getParameter("idmovimento_" + valor.split("_")[k])));
            dp.setVlduplicata(Double.parseDouble(request.getParameter("vldupl_" + valor.split("_")[k]).replace(".", "").replace(",", ".")));
            dp.setValorPis(Double.parseDouble(request.getParameter("vlpis_" + valor.split("_")[k])));
            dp.setValorCofins(Double.parseDouble(request.getParameter("vlcofins_" + valor.split("_")[k])));
            dp.setValorCssl(Double.parseDouble(request.getParameter("vlcssl_" + valor.split("_")[k])));
            dp.setVlpago(Double.parseDouble(request.getParameter("vlpago_" + valor.split("_")[k])));
            dp.setDtpago(formatador.parse(request.getParameter("dtpago")));
            dp.setDtbaixa(formatador.parse(Apoio.getDataAtual()));
            dp.setCriaPcs(Boolean.parseBoolean(request.getParameter("criapcs_" + (valor.split("_")[k]))));
            dp.setDtNovaPcs(formatador.parse(request.getParameter("dtnovapcs_" + valor.split("_")[k])));
            dp.getFpag().setIdFPag(Integer.parseInt(request.getParameter("fpag")));
            dp.getMovBanco().getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
            dp.getMovBanco().setDocum(String.valueOf(chq));
            dp.getMovBanco().setNominal(request.getParameter("nominal"));
            dp.getMovBanco().setDtEmissao(!request.getParameter("fpag").equals("2") ? formatador.parse(request.getParameter("dtchq")) : formatador.parse(request.getParameter("dtpago")));
            dp.getMovBanco().setDtEntrada(!request.getParameter("fpag").equals("2") ? formatador.parse(request.getParameter("dtchq")) : formatador.parse(request.getParameter("dtpago")));
            dp.getMovBanco().setHistorico(request.getParameter("hist_" + valor.split("_")[k]));
            dp.getMovBanco().getHistorico_id().setIdHistorico(Integer.parseInt(request.getParameter("idhist_" + valor.split("_")[k])));
            dp.getMovBanco().setValor(Double.parseDouble(request.getParameter("vlpago_" + valor.split("_")[k])));
            dp.getMovBanco().getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
            dp.getMovBanco().setConciliado(Boolean.parseBoolean(request.getParameter("conciliar")));
            dp.getMovBanco().getAdiantamentoFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idFornecedor_" + valor.split("_")[k])));
            arDupls[k] = dp;
        }
        altDupls.setArrayBDupls(arDupls);

        boolean erroBaixar = !altDupls.Atualiza(altDupls.BAIXAR_DUPLICATA);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroBaixar) {
            response.getWriter().append("<script>alert('" + altDupls.getErros() + "');</script>");
            response.getWriter().append("<script>window.opener.habilitaSalvar(true);window.close();</script>");
        } else {
            String scr = "";
            String caminhoImpressora = URLDecoder.decode(request.getParameter("caminho_impressora"), "UTF-8").replace('\\', File.separatorChar);
            scr = "<script>";
            if (Boolean.parseBoolean(request.getParameter("imprimirchq"))) {
                scr += "window.open('./matricidecheque.ctrc?&idmovs=" + request.getParameter("doc") + "&driverImpressora=" + request.getParameter("driverImpressora")
                        + "&conta=" + request.getParameter("conta") + "&caminho_impressora=" + caminhoImpressora + "','drive');";
            }
            if (Boolean.parseBoolean(request.getParameter("imprimirRecibo"))) {
                scr += "window.open('./bxcontaspagar?acao=exportar&modelo=" + request.getParameter("modeloRecibo") + "&ids=" + request.getParameter("recibo") + "','recibo" + request.getParameter("recibo") + "','recibo');";
            }
            if (Boolean.parseBoolean(request.getParameter("imprimirCopia"))) {
                if (Boolean.parseBoolean(request.getParameter("imprimirRecibo"))) {
                    scr += "alert('Clique em OK para visualizar a cópia de cheque.');";
                }
                scr += "window.open('./bxcontaspagar?acao=exportarcopiacheque&modelo=" + request.getParameter("modeloCheque") + "&conta=" + request.getParameter("conta") + "&docum=" + request.getParameter("doc") + "&dtentrada=" + request.getParameter("dtchq") + "','copiacheque');";
            }            
            scr += "window.opener.document.getElementById('visualizar').onclick();"                   
                    +" window.close();"
                    +"</script>";
            response.getWriter().append(scr);
            
        }
        response.getWriter().close();
    } else if (acao.equals("excluir")) {
        //Preenchendo o array dos conhecimentos
        duplicata.setIdmovimento(Integer.parseInt(request.getParameter("id")));
        duplicata.setDuplicata(Integer.parseInt(request.getParameter("duplicata")));
        duplicata.getMovBanco().setIdLancamento(Integer.parseInt(request.getParameter("idlancamento")));
        altDupls.setBDupls(duplicata);

        boolean erroExcluir = !altDupls.Atualiza(altDupls.EXCLUIR_BAIXA);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroExcluir) {
            if (altDupls.getErros().contains("mov_banco_fornecedor_mov_banco_id_fkey")) {
                response.getWriter().append("err<=> Atenção: Esse lançamento foi feito para a conta corrente do fornecedor, a exclusão deverá ser feita pela tela de conciliação bancária.");
            }else{
                response.getWriter().append("err<=>" + altDupls.getErros());
                //response.getWriter().append("<script>window.close();</script>");
            }
        } else {
            response.getWriter().append("err<=>");
        }
        response.getWriter().close();
    } else if (acao.equals("estornar")) {
        //Preenchendo o array dos conhecimentos
        duplicata.setIdmovimento(Integer.parseInt(request.getParameter("id")));
        duplicata.setDuplicata(Integer.parseInt(request.getParameter("duplicata")));
        duplicata.getMovBanco().setIdLancamento(Integer.parseInt(request.getParameter("idlancamento")));
        altDupls.setBDupls(duplicata);

        boolean erroExcluir = !altDupls.Atualiza(4);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroExcluir) {
            response.getWriter().append("err<=>" + altDupls.getErros());
        } else {
            response.getWriter().append("err<=>");
        }
        response.getWriter().close();
    }

    //Imprimindo recibo
    if (acao.equals("exportar")) {
        //Preenchendo o array dos conhecimentos
        String recibos = request.getParameter("ids");
        String condicao = "";
        //recebendo valor do primeiro cheque
        int qtdRecibos = recibos.split("_").length;
        for (int k = 0; k < qtdRecibos; ++k) {
            if (k == 0) //só entra na primeira vez
            {
                condicao = " where id IN (";
            }

            condicao += recibos.split("_")[k] + (k < qtdRecibos - 1 ? ", " : "");
        }
        condicao += ") ";

        java.util.Map param = new java.util.HashMap(1);
        param.put("CONDICAO", condicao);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", "recibopagarmod" + request.getParameter("modelo"));

        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
        dispacher.forward(request, response);
    }

    //Imprimindo cópia de cheque
    if (acao.equals("exportarcopiacheque")) {
        //recebendo valor do primeiro cheque
        java.util.Map param = new java.util.HashMap(3);
        param.put("IDCONTA", request.getParameter("conta"));
        param.put("CHEQUE", request.getParameter("docum"));
        param.put("DTENTRADA", "'" + new SimpleDateFormat("MM-dd-yyyy").format(Apoio.paraDate(request.getParameter("dtentrada"))) + "'");
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", "copiachequemod" + request.getParameter("modelo"));

        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
        dispacher.forward(request, response);
    }
    if (acao.equals("proxCheque")) {

        //não esta sendo usando

        String setor = request.getParameter("setor") == null ? "" : request.getParameter("setor");;
        setor = (setor.trim().length() == 0 ? "" : ",") + (nivelUser == 4 && nivelUserBxViagem == 4 ? "f,o" : (nivelUser == 4 ? "f" : nivelUserBxViagem == 4 ? "o" : ""));
        if (cfg.isControlarTalonario()) {
//                    ConsultaTalaoCheque tc = new ConsultaTalaoCheque();
//                    //ResultSet rsCT = tc.ConsultarDoc(Apoio.getUsuario(request).getConexao(),request.getParameter("conta"));
//                    tc.setConexao(Apoio.getUsuario(request).getConexao());
//                    int idConta = request.getParameter("idConta") != null ? Integer.parseInt(request.getParameter("idConta")): cfg.getConta_padrao_id().getIdConta();
//          
//                    Collection<TalaoCheque> lista = new ArrayList<TalaoCheque>();
//                    tc.consultarDoc(idConta,Apoio.getUsuario(request).getFilial().getIdfilial(),setor,Apoio.getUsuario(request));
//                        ResultSet rsCT1 = tc.getResultado();
//                        
//                        TalaoCheque talaoCheque = null;
//                        while (rsCT1.next()){
//                            
//                            
//                            talaoCheque = new TalaoCheque();
//                            talaoCheque.setNumeroInicial(rsCT1.getString("docum"));
//                            lista.add(talaoCheque);
//                            
//                        }                    
//                    
//                    XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
//                    xstream.setMode(XStream.NO_REFERENCES);
//                    xstream.alias("talaoCheque", TalaoCheque.class);
//                    String json = xstream.toXML(lista);
//                    response.getWriter().append(json);
        } else {
            BeanCadMovBanco movBanco = new BeanCadMovBanco();
            movBanco.setConexao(Apoio.getUsuario(request).getConexao());
            String resultado = movBanco.getProxCheque(Integer.parseInt(request.getParameter("idConta")));
            response.getWriter().append(resultado);
        }
        response.getWriter().close();
    }

%>


<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    var vlSelecionado = 0;

    function habilitaSalvar(opcao){
        $("baixar").disabled = !opcao;
        $("baixar").value = (opcao ? "Baixar" : "Enviando...");
    }

    function baixar(linhas){
        var id = "";
        var deuCerto = true;
        var ids = "";
        var recibo = "";
        var totalCheque = 0;   
	    
        for (i = 0; i <= linhas - 1; ++i){
            id = $("chk_"+i).value
            //Verificando se o check está marcado
            if ($("chk_"+i).checked){
                //verificando se a data de pagamento está válida
                if (! validaData($("dtpago").value)){
                    deuCerto = false;
                    $("dtpago").style.background ="#FFE8E8";
                    //verificando se a data do cheque está válida
                }else if (! validaData($("dtchq").value)){
                    deuCerto = false;
                    $("dtchq").style.background ="#FFE8E8";
                    //verificando se a data do novo vencimento está válida
                } else if ($("fpag").value == '3' && eDate.compare($("dtchq").value, $("dtpago").value) < 0) {
                    deuCerto = false;
                    $("dtchq").style.background ="#FFE8E8";
                    alert('A data informada não pode ser menor que a data de pagamento!');
                } else if (! validaData($("dtnovapcs_"+id).value) && $("criapcs_"+id).value=="sim"){
                    deuCerto = false;
                    $("dtnovapcs_"+id).style.background ="#FFE8E8";
                }
                else if (wasNull('hist_'+id)){
                    deuCerto = false;
                }else if ($('chkimpcheque').checked && (/*$('nominal').value.trim() == "" ||*/ $('driverImpressora').value.trim() == "" || 
                    ((<%=!cfg.isControlarTalonario()%> && $('doc').value.trim() == "") || (<%=cfg.isControlarTalonario()%> && $('doc1').value.trim() == "")))){
                    alert("Para impressão de cheque informe o número do cheque e o driver da impressora!");
                    deuCerto = false;
                }else {
                    //Começando a concatenação
                    if (ids != ""){
                        ids += "_";
                        recibo += "_";
                    }
                    recibo += id;
                    ids += id;
          
                    /*Somando os valores de notas marcadas*/
                    totalCheque = parseFloat(totalCheque) + parseFloat($("vlpago_"+id).value);
                }
            }            
        }
        
        if($("conta").value == ""){
              alert("ATENÇÃO: Escolha uma conta para baixar");
              return false;
        }
        if($("doc").value.length > 10){//caso o numero do documento tenha mais de 10 digitos retorna um alert e cancelar a atualizacao.
            alert("O numero do documento não pode ter mais de 10 digitos.");
            return false;
        }
        
        if (!deuCerto)
            alert('Informe todos os dados da baixa corretamente');
        else if(ids == "")
            alert('Escolha uma duplicata corretamente');
        else{
            var doc = $("doc").value;
            if ($('fpag').value == '3'){  
    <%if (cfg.isControlarTalonario()) {%>
                    doc = $("doc1").value;
                    if(doc == ""){
                        return alert('Informe a numeração do cheque corretamente.');
                    }
    <%}%>
                }
                habilitaSalvar(false);

                $('formBx').action = "./bxcontaspagar?acao=baixar&conta="+$("conta").value.split('@')[0]+"&doc="+doc+
                    "&nominal="+$("nominal").value+"&ids="+ids+"&conciliar="+$("chkconciliado").checked+"&fpag="+$('fpag').value+
                    "&dtpago="+$("dtpago").value+"&dtchq="+$("dtchq").value+"&driverImpressora="+$('driverImpressora').value+"&caminho_impressora="+ encodeURI($('caminho_impressora').value)+
                    "&imprimirchq="+$('chkimpcheque').checked+"&imprimirRecibo=" + $('chkrecibo').checked + "&recibo="+recibo +
                    "&mostrarSaldo=" + $('mostrar_saldos').checked + "&imprimirCopia=" + $('chkimpcopiacheque').checked + "&modeloRecibo=" + $('cbmodelo').value + 
                    "&modeloCheque="+$("modeloCheque").value + "&codBarras="+$("codBarras").value+"&visualizar="+$("visualizar"+"&codRepom="+$("codRepom").value);

//                submitPopupForm($('formBx'));
                $('formBx').target = "pop";
                window.open('about:blank', 'pop', 'width=210, height=100');
                $('formBx').submit();
            }
             
        }

        function gerarArquivoRemessa(linhas, isSantanderItau){
            try {
            var id = "";
            var vlPago = "";
            var deuCerto = true;
            var ids = "";
            var recibo = "";
            var totalCheque = 0;
	    
            for (i = 0; i <= linhas - 1; ++i){
                if ($("chk_"+i) != null && $("chk_"+i) != undefined) {
                    
                    //Verificando se o check está marcado
                    if ($("chk_"+i).checked){
                        id = $("chk_"+i).value;
                    vlPago = $("vlpago_"+id).value
                        //verificando se a data de pagamento está válida
                        //Começando a concatenação
                        if (ids != ""){
                            ids += "_";
                            recibo += "_";
                        }
                        recibo += id;
                        ids += id+"!!"+vlPago;
                    }
                }
            }
            var acaoArquivoRemessa;
            if(isSantanderItau==true){
                acaoArquivoRemessa = $("acaoArquivoRemessa").value;
            }
            if(ids == ""){
                alert('Escolha uma duplicata corretamente');
            }else{
                //var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                //pop.setTimeout("window.close();", 10000)
                //pop.location.href = "RemessaContasPagar.txt?acao=gerarArquivoRemessaContasPagar&conta="+$("conta").value.split('@')[0]+"&ids="+ids+"&acaoArquivoRemessa="+acaoArquivoRemessa;
                
                pdf = window.open("RemessaContasPagar.txt?acao=gerarArquivoRemessaContasPagar&conta="+$("conta").value.split('@')[0]+"&ids="+ids+"&acaoArquivoRemessa="+acaoArquivoRemessa, 'fatura',
                    'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
                
                
            }
            } catch (e) { 
                alert(e);
                throw e;
            }
        }

        function excluir(id,duplicata,idMovBanco,conciliado){

            function ev(resp, codstatus) {
                // habilitaSalvar(true);
                if (codstatus==200 && resp=="err<=>")
                    location.replace("./bxcontaspagar?acao=consultar&mostrarSaldo="+$('mostrar_saldos').checked+"&"+concatFieldValue("idfornecedor,fornecedor,dtinicial,dtfinal,baixado,idfilial,tipoData,nf,valor1,valor2,codBarras,codRepom"));
                else
                    alert(resp.split("<=>")[1]);
            }

            if (conciliado && <%=(nivelUserConciliacao < 4)%>){
                alert('Esse pagamento já foi conciliado, exclusão cancelada.');
                return null;
            }

            if (confirm("Deseja mesmo excluir a baixa dessa duplicata?")){
                requisitaAjax("./bxcontaspagar?acao=excluir&id="+id+"&duplicata="+duplicata+"&idlancamento="+idMovBanco,ev);
            }
        }

        function estornar(id,duplicata,idMovBanco){

            function ev(resp, codstatus) {
                // habilitaSalvar(true);
                if (codstatus==200 && resp=="err<=>")
                    location.replace("./bxcontaspagar?acao=consultar&mostrarSaldo="+$('mostrar_saldos').checked+"&"+concatFieldValue("idfornecedor,fornecedor,dtinicial,dtfinal,baixado,idfilial,tipoData,nf,valor1,valor2, codBarras,codRepom"));
                else
                    alert(resp.split("<=>")[1]);
            }

            if (confirm("ATENÇÃO: Ao estornar a baixa o valor referente a esse estorno continuará aparecendo na conciliação bancária. Deseja mesmo estornar a baixa dessa duplicata?")){
                requisitaAjax("./bxcontaspagar?acao=estornar&id="+id+"&duplicata="+duplicata+"&idlancamento="+idMovBanco,ev);
            }
        }

        function recibo(id)
        {
            launchPDF('./bxcontaspagar?acao=exportar&modelo='+$('cbmodelo').value+'&ids='+id+'_',
            'recibo'+id);
        }
  
        function visualizar(){
          //dando erro ao Visualizar
            limparCampos();            
            var filtros = "";
            if (! validaData(getObj("dtinicial").value) || !validaData(getObj("dtfinal").value))
                alert ("Informe o intervalo de datas corretamente."); 
            else
                filtros = concatFieldValue("idfornecedor,fornecedor,dtinicial,dtfinal,baixado,idfilial,"+
                "tipoData,nf,valor1,valor2,conta,filtroConta, codBarras, hidMostrarDespesa, hidMostrarDuplicatas, idPlano, plano, planoNome, codRepom");
                
            //Apenas se os filtros estiverem corretos
            if (filtros.trim()!=''){
                location.replace("./bxcontaspagar?acao=consultar&"+filtros+
                            "&mostrarSaldo=" + $('mostrar_saldos').checked + "&ordenacao="+$("ordenacao").value + "&dtpago="+$("dtpago").value + "&dtchq="+$("dtchq").value+"&fpag="+$("fpag").value+"&conta="+$("conta").value.split('@')[0]);
            }                     
        }


        function limparCampos(){
            if($("tipoData").value == "nfDoc"){
                $('codBarras').value = "";
                $('codRepom').value = ""; 
            }else if ($("tipoData").value == "codigoBarra"){
                $('nf').value = ""; 
                $('codRepom').value = ""; 
            }else if ($("tipoData").value == "cont_repom"){
                $('nf').value = ""; 
                $('codBarras').value = "";
            }else{
                $('codBarras').value = "";
                $('nf').value = ""; 
                $('codRepom').value = ""; 
            }                
        }
        

        function verDesp(id){
            window.open("./caddespesa?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes,status=1,scrollbars=1");
        }
        
        

        function mostraCombos(){
            $("baixado").value = '<%=(request.getParameter("baixado") == null ? "false" : request.getParameter("baixado"))%>';
            $("tipoData").value = '<%=(request.getParameter("tipoData") == null ? "dtvenc" : request.getParameter("tipoData"))%>';
            $("conta").value = '<%=(request.getParameter("conta") == null ? cfg.getConta_padrao_id().getIdConta() : request.getParameter("conta"))%>';
            alterarSelect();
        }
  
        function aoClicarNoLocaliza(idjanela){
            if ((idjanela == "Historico")){
                var campo = "hist_"+$("id_historico").value;
                $(campo).value = $("descricao_historico").value
                $("idhist_"+$("id_historico").value).value = $("idhist").value
                $("codhist_"+$("id_historico").value).value = $("codigo_historico").value
            }else if (idjanela == "Plano"){
                $("plano").value = $("plcusto_conta_despesa").value;
                $("planoNome").value = $("plcusto_descricao_despesa").value;
                $("idPlano").value =  $("idplanocusto_despesa").value;
            }
        }

        function localizahist(obj){
            document.getElementById("id_historico").value = obj.name;
            post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
        }

        function limparclifor(){
            $("idfornecedor").value = "0";
            $("fornecedor").value = "";
        }

        function getTotalDup(linha, alterou) {
            console.log("getTotalDup");
            var id = $("idContas_"+linha).value;
            var vlPago = $("vlpago_"+id).value;
            if (alterou){
                var vlPagoAux = $('vlpagoaux_'+$('chk_'+linha).value).value;
                if ($('chk_'+linha).checked){
                    vlSelecionado = vlSelecionado - parseFloat(vlPagoAux) + parseFloat(vlPago);
                }
                $('vlpagoaux_'+$('chk_'+linha).value).value = vlPago;
            }else{
                if ($('chk_'+linha).checked){
                    vlSelecionado = vlSelecionado + parseFloat(vlPago);
                }else{
                    vlSelecionado = vlSelecionado - parseFloat(vlPago);
                }
            }
            $("totaldup").value = formatoMoeda(vlSelecionado);
        }

        function getNominal(linha) {
            $("nominal").value = $("razaosocial_"+$("chk_"+linha).value).value;
        }

        function marcaTodos(){
            var index = $("linha").value;
            var i = 0;
            vlSelecionado = 0;
            if($("chkTodos").checked) {
                while ($("chk_"+i) != null){
                    if($("idContas_"+i) != null){
                    $("chk_"+i).checked = $("chkTodos").checked;
                        getTotalDup(i, false);
                    }
                    if ($("chk_"+i).checked && $("tipoPagamento_"+i).value == 's') {
                        avisoPagamentoSaldoNdd(i);    
                    }
                    i++;
                }                
            }else {
                i = 0;
                while($("chk_" +i) != null){
                    $("chk_"+i).checked = false;
                    i++;  
                }
                $("totaldup").value = "0,00";
            }
        }

        function verFpag(is_carregar){
            $("fpag").value = is_carregar ? '${formaPag}' : $("fpag").value;
            $("conta").value.split('@')[0] = is_carregar ? '${contaPag}' : $("conta").value.split('@')[0];
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
              
                    var docum;
                    var isPrimeiro = true;
                    
                    var slct = $("doc1");

                    var opt = null;

                    Element.update(slct);
                    opt = new Element("option", {
                        value: ""
                    })
                               

                    Element.update(opt, " ---- ");
                    slct.appendChild(opt);
                    
                    var length = (listCheque != undefined && listCheque.length != undefined ? listCheque.length : 1);

                    for(var i = 0; i < length; i++){
                        
                        if(length > 1){
                            docum = listCheque[i];
                        }else{
                            docum = listCheque;
                        }
                    
                        if(docum != null && docum != undefined){
                            
                            if(isPrimeiro){
                                opt = new Element("option", {
                                    value: docum,
                                    selected: isPrimeiro+""
                                })
                            }else{
                                opt = new Element("option", {
                                    value: docum
                                })
                            }

                            Element.update(opt, docum);
                            slct.appendChild(opt);
                            isPrimeiro = false;
                        }
                    }

                <%} else {%>
                    $('doc').value = textoresposta;
                <%}%>
                }
            }//funcao e()

            if ($('fpag').value == '3'){
            
    <%if (cfg.isControlarTalonario()) {%>
                $('doc').style.display = 'none';
                $('doc1').style.display = '';
    <%} else {%>
                $('doc').style.display = '';
    <%}%>             
                 
                $('lbDoc').innerHTML = "N&ordm; Cheque:";
                $('lbBomPara').innerHTML = "Bom para:";
                $('dtchq').style.display = "";
                espereEnviar("",true);
            
             tryRequestToServer(function(){
                    new Ajax.Request("TalaoChequeControlador?acao=proxCheque&idConta="+$('conta').value,{method:'post', onSuccess: e, onError: e});
                });
            }else if ($('fpag').value == '2'){
    <%if (cfg.isControlarTalonario()) {%>
                $('doc1').style.display = 'none';
    <%}%>
                $('doc').style.display = '';
                $('doc').value = '';
                $('lbDoc').innerHTML = "N&ordm; DOC:";
                $('lbBomPara').innerHTML = "";
                $('dtchq').style.display = "none";
            }else{
    <%if (cfg.isControlarTalonario()) {%>
                $('doc1').style.display = 'none';
    <%}%>
                $('doc').style.display = '';                
                $('doc').value = '';
                $('lbDoc').innerHTML = "N&ordm; DOC:";
                $('lbBomPara').innerHTML = "Data conciliação:";
                $('dtchq').style.display = "";
            }
            
            if($("conta").value.split('@')[1] =="true" && ($("conta").value.split('@')[2] == "033" || $("conta").value.split('@')[2] == "341") ){            
                $("gerarArquivoRemessaSantander").style.display = "";
                $("divAcaoArquivoRemessa").style.display = "";
                $("acaoArquivoRemessa").style.display = "";
                $("gerarArquivoRemessa").style.display = "none";           
                
                if($("conta").value.split('@')[2] == "341"){
                    $("opAlteracao").style.display = "none";
                }else{
                    $("opAlteracao").style.display = "";
                }
                
            }else{
                $("gerarArquivoRemessaSantander").style.display = "none";
                $("divAcaoArquivoRemessa").style.display = "none";
                $("acaoArquivoRemessa").style.display = "none";
                $("gerarArquivoRemessa").style.display = "";          
            }
        }

        function reterImpostos(idx){
            if ($('chkRet_'+idx).checked){
                $('tr_ret'+idx).style.display = '';
            }else{
                $('tr_ret'+idx).style.display = 'none';
            }
        }

        function getTotalRetido(idx){
            $('vltotalretido_'+idx).value = formatoMoeda(parseFloat($('vlpis_'+idx).value)+
                parseFloat($('vlcofins_'+idx).value)+
                parseFloat($('vlcssl_'+idx).value));
            $('vldupl_'+idx).value = formatoMoeda(parseFloat($('vloriginal_'+idx).value) - parseFloat($('vltotalretido_'+idx).value));
            $('vlpago_'+idx).value = formatoMoeda(parseFloat($('vldupl_'+idx).value) + parseFloat($('vladicional_'+idx).value));
            $('vldupl_'+idx).value = $('vldupl_'+idx).value.replace('.',',');
        }
    
        function alterarSelect(){
            if(($('tipoData').value == 'nfDoc')) {
                $('notaDoc').style.display = "";   
                $('data').style.display = "none"; 
                $('tdCodBarras').style.display = "none";   
                $('tdCodRepom').style.display = "none";   
            }else if (($('tipoData').value == 'codigoBarra')){
                $('tdCodBarras').style.display = "";   
                $('data').style.display = "none";  
                $('notaDoc').style.display = "none";   
                $('tdCodRepom').style.display = "none";   
            }else if (($('tipoData').value == 'cont_repom')){
                $('tdCodRepom').style.display = "";   
                $('notaDoc').style.display = "none";   
                $('data').style.display = "none"; 
                $('tdCodBarras').style.display = "none";   
            }else{
                $('notaDoc').style.display = "none";   
                $('data').style.display = "";   
                $('tdCodBarras').style.display = "none";   
                $('tdCodRepom').style.display = "none";   
            }
        }
    
        function avisoPagamentoSaldoNdd(index){
            var chkInp = $("chk_"+index).checked;
            var tipoPagamento = $("tipoPagamento_"+index).value;
            var stUtilizacaoCFe = '<%=stUtilizacaoCFe%>';
            if (stUtilizacaoCFe == 'D') {
                if (chkInp == true && (<%=nivelConfirmarPgtoNDD == 0%> || <%=filialConfirmarPgtoNDD == true%>) && tipoPagamento == 's') {    
                    var mensagem = "A baixa do 'SALDO' não será sincronizado com a NDD!";
                    mensagem += "\n \t \t \t \t \t \t # Para Sincronizar #";
                    mensagem += "\n 1 - Terá que habilitar a permissão ('Confirmar pagamento de saldo ndd');";
                    mensagem += "\n 2 - Terá que habilitar a opção em Integrações ('Confirmar pagamento de saldo pela Ndd);";
                    mensagem += "\n 3 - Realizar a baixa pela tela, Consulta saldo contrato de frete.";
                    alert("Atenção: " + mensagem);
                }
            }
        }
    
    //função para alternar os valores do type="radio"
    function alternarValues(){       
        if($("mostrarAmbas").checked){
            $("hidMostrarDespesa").value = $("mostrarAmbas").value;           
        }else if($("mostrarEnviadas").checked){
            $("hidMostrarDespesa").value = $("mostrarEnviadas").value;            
        }else if($("mostrarNaoEnviadas").checked){
            $("hidMostrarDespesa").value = $("mostrarNaoEnviadas").value;                        
        }        
    }
    
    //peguei essa função de jspbxcontasreceber.jsp
    function criaNovaPcs(ids,tipo){
        var isValidando = (parseFloat(colocarPonto($("vldupl_"+ids).value)) > parseFloat(($("vlpago_"+ids).value)));
        
    //        if(parseFloat($("vldupl_"+ids).value.replace('.','')) > parseFloat($("vlpago_"+ids).value)){ //Se valor pago for menor que o previsto
    //      Comentei essa linha acima por que não estava comparando valores quebrados EX: 19.09 > 19.00
            if(isValidando){ //Se valor pago for menor que o previsto
                if (tipo == "F") {

                }else
                if (confirm("O valor pago é menor que o previsto, deseja criar uma nova parcela?")){
                    if (prompt("Informe o vencimento da nova parcela.", getObj("dtpago").value)) {
                        getObj("dtnovapcs_"+ids).value = prompt("Informe o vencimento da nova parcela.", getObj("dtpago").value);
                        getObj("criapcs_"+ids).value = "true";
                        getObj("dtnovapcs_"+ids).style.display = "";
                    }
                }else{
                    getObj("criapcs_"+ids).value = "false";
                    getObj("dtnovapcs_"+ids).style.display = "none";
                }
            }
    }
    

    function mostrarDuplicatas(){
        if(document.getElementById("hidMostrarDuplicatas").value == null || document.getElementById("hidMostrarDuplicatas").value == ""){
            document.getElementById("hidMostrarDuplicatas").value = "am";
        }
        
        if(document.getElementById("liberadas").checked){
            document.getElementById("hidMostrarDuplicatas").value = document.getElementById("liberadas").value;
        }else if(document.getElementById("naoLiberadas").checked){
            document.getElementById("hidMostrarDuplicatas").value = document.getElementById("naoLiberadas").value;
        }else if(document.getElementById("ambas").checked){
            document.getElementById("hidMostrarDuplicatas").value = document.getElementById("ambas").value;
        }else if(document.getElementById("hidMostrarDuplicatas").value = "am"){
            document.getElementById("ambas").checked = true;
        }
        
    }
    
    function localizaPlanoCusto(){
        launchPopupLocate('./localiza?acao=consultar&idlista=20&fecharJanela=true','Plano');
    }
    
    function limparPlanoCusto(){
        $("plano").value = "";
        $("planoNome").value = "";
        $("idPlano").value = 0;
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

        <title>Webtrans - Baixas de contas a pagar</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="javascript:mostraCombos();verFpag(true);mostrarDuplicatas();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idfornecedor" id="idfornecedor" value="<%=(request.getParameter("idfornecedor") != null ? request.getParameter("idfornecedor") : "0")%>">
            <input type="hidden" name="idfilial1" id="idfilial1" value="<%=(request.getParameter("idfilial") != null ? request.getParameter("idfilial") : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="descricao_historico" id="descricao_historico" value="0">
            <input type="hidden" name="codigo_historico" id="codigo_historico" value="0">
            <input type="hidden" name="idhist" id="idhist" value="0">
            <input type="hidden" name="id_historico" id="id_historico" value="0">
            <input type="hidden" name="plcusto_conta_despesa" id="plcusto_conta_despesa" value="">
            <input type="hidden" name="plcusto_descricao_despesa" id="plcusto_descricao_despesa" value="">
            <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="<%=(request.getParameter("idPlano") != null ? request.getParameter("idPlano") : "0")%>">
        </div>
        <table width="100%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22" width="100%" ><b>Baixa de contas a pagar</b></td>

            </tr>
        </table>
        <br>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td colspan="6"><div align="center">Filtros </div>
                    <div align="center"></div></td>
            </tr>
            <tr>
                <td width="14%" height="24" class="TextoCampos"><span class="CelulaZebra2">
                        <select name="tipoData" id="tipoData" class="inputtexto" onchange="alterarSelect();">
                            <option value="dtvenc">Vencimento</option>
                            <option value="emissaolanc">Emiss&atilde;o</option>
                            <option value="dtpago" selected>Pagamento</option>
                            <option value="nfDoc" selected>NF/Doc</option>
                            <option value="codigoBarra" selected>Cód. Barras do Boleto</option>
                            <option value="previsao_pagamento" >Previsão de Pagamento</option>
                            <option value="cont_repom">Nº Contrato REPOM</option>
                        </select>
                    </span> </td>
                <td id="data" display="" width="35%" class="CelulaZebra2">Entre:<strong>
                        <input name="dtinicial" type="text" id="dtinicial" style="font-size:8pt;" class="fieldDate" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>"
                               size="9" maxlength="10" onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" class="fieldDate" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                               onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </strong>
                </td>
                <td  style="display:none" id="notaDoc" class="CelulaZebra2"><input name="nf" id="nf" type="text" value="<%=(request.getParameter("nf") != null ? request.getParameter("nf") : "")%>" size="45" class="fieldMin" maxlength="40" onBlur="">          
                </td>
                <td  style="display:none" id="tdCodBarras" class="CelulaZebra2"><input name="codBarras" id="codBarras" type="text" value="<%=(request.getParameter("codBarras") != null ? request.getParameter("codBarras") : "")%>" size="50" class="fieldMin" maxlength="100" onBlur="">          
                </td>
                <td  style="display:none" id="tdCodRepom" class="CelulaZebra2"><input name="codRepom" id="codRepom" type="text" value="<%=(request.getParameter("codRepom") != null ? request.getParameter("codRepom") : "")%>" size="50" class="fieldMin" maxlength="100" onBlur="">          
                </td>
                <td width="13%" class="TextoCampos">Apenas o fornecedor:</td>
                <td width="23%" class="TextoCampos"><div align="left"><strong>
                            <input name="fornecedor" type="text" id="fornecedor" class="inputReadOnly8pt" value="<%=(request.getParameter("fornecedor") != null ? request.getParameter("fornecedor") : "")%>" size="27" maxlength="80" readonly="true">
                            <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=21','Fornecedor')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:limparclifor();">
                        </strong></div></td>
                <td width="5%" class="TextoCampos">Mostrar:</td>
                <td width="10%" class="CelulaZebra2" style="font-size:8pt;"><select name="baixado" id="baixado" class="inputtexto">
                        <option value="todas">Todas</option>
                        <option value="false" selected>Em aberto</option>
                        <option value="true">Quitadas</option>
                    </select></td>
            </tr>
            <tr>
                <td height="22" colspan="6">
                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                        <tr>
                            <td width="4%" class="TextoCampos">Filial:</td>
                            <td width="10%" class="CelulaZebra2"><select name="idfilial" id="idfilial" class="inputtexto">
                                    <%BeanFilial fl = new BeanFilial();
                                        ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                                    <%if (nivelUserDespesaFilial > 0) {%>
                                    <option value="0">TODAS</option>
                                    <%}

                                        int filial = (request.getParameter("idfilial") != null ? Integer.parseInt(request.getParameter("idfilial"))
                                                : Apoio.getUsuario(request).getFilial().getIdfilial());

                                        while (rsFl.next()) {
                                            if (nivelUserDespesaFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                                    <option value="<%=rsFl.getString("idfilial")%>"
                                            <%=(filial == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%></option>
                                    <%}%>
                                    <%}%>
                                </select></td>
                            <td width="10%" class="TextoCampos">Valores entre:</td>
                            <td width="13%" class="CelulaZebra2">
                                <input name="valor1" id="valor1" value="<%=(request.getParameter("valor1") != null ? request.getParameter("valor1") : "0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="6" class="fieldMin" maxlength="12" align="Right">
                                e 
                                <input name="valor2" id="valor2" value="<%=(request.getParameter("valor2") != null ? request.getParameter("valor2") : "0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="6" class="fieldMin" maxlength="12" align="Right">
                            </td>
                            <td width="13%" class="TextoCampos">Baixados na Conta:</td>
                            <td width="14%" class="TextoCampos">
                                <select name="filtroConta" id="filtroConta" class="fieldMin" style="font-size:8pt;width: 130px;" >
                                    <div align="left">
                                        <option value="0" selected>Todas as contas</option>
                                        <%      //Carregando todas as contas cadastradas
                                            BeanConsultaConta filtroConta = new BeanConsultaConta();
                                            filtroConta.setConexao(Apoio.getUsuario(request).getConexao());
                                            filtroConta.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                            ResultSet rsContaFiltro = filtroConta.getResultado();
                                            while (rsContaFiltro.next()) {%>
                                        <option value="<%=rsContaFiltro.getString("idconta")%>" <%=(request.getParameter("filtroConta") != null && request.getParameter("filtroConta").equals(rsContaFiltro.getString("idconta")) ? "selected" : "")%>> <%=rsContaFiltro.getString("numero") + "-" + rsContaFiltro.getString("digito_conta") + " / " + rsContaFiltro.getString("banco")%></option>
                                        <%}
                                            rsContaFiltro.close();%>
                                    </div>
                                </select>
                            </td>
                            <td width="36%" class="CelulaZebra2"><label>
                                    <div align="center">
                                        <input type="checkbox" name="mostrar_saldos" id="mostrar_saldos" <%=(request.getParameter("mostrarSaldo") == null || Boolean.parseBoolean(request.getParameter("mostrarSaldo")) ? "checked" : "")%> >
                                        Mostrar saldos de contratos de fretes n&atilde;o autorizados</div>
                                </label></td>
                        </tr>                        
                    </table>
                                
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <table width="100%" cellspacing="1" cellpadding="2">
                        
                            <td class="TextoCampos">
                                <div align="right" width="6%">Ordenação:</div>
                            </td>
                            <td class="CelulaZebra2" width="8%">
                                <select name="ordenacao" class="inputtexto"  id="ordenacao" >
                                    <option value="razaosocial" <%=(request.getParameter("ordenacao") == null || request.getParameter("ordenacao").equals("razaosocial") ? "Selected" : "")%>>Fornecedor</option>
                                    <option  value="emissaolanc"<%=(request.getParameter("ordenacao") != null && request.getParameter("ordenacao").equals("emissaolanc") ? "Selected" : "")%>>Emissão</option>
                                    <option value="dtvenc"  <%=(request.getParameter("ordenacao") != null && request.getParameter("ordenacao").equals("dtvenc") ? "Selected" : "")%>>Vencimento</option>
                                    <option value="nfiscal"  <%=(request.getParameter("ordenacao") != null && request.getParameter("ordenacao").equals("nfiscal") ? "Selected" : "")%>>Nota Fiscal</option>
                                </select>
                            </td>                           
                        
                         <td class="TextoCampos" width="38%">
                                <div align="right">Mostrar apenas despesas enviadas para o banco (Arquivo de remessa):</div>
                            </td>
                            <td class="CelulaZebra2" width="48%" colspan="4">
                                <div align="left">
                                    <input id="mostrarAmbas" type="radio" value="a" name="mostrarDespesa" onclick="alternarValues();" <%=(request.getParameter("hidMostrarDespesa") == null || request.getParameter("hidMostrarDespesa").equals("a") ? "checked" : "")%>/> Ambas
                                    <input id="hidMostrarDespesa" type="hidden" value="a" name="hidMostrarDespesa" /> 
                                    <input id="mostrarEnviadas" type="radio" value="e" name="mostrarDespesa" onclick="alternarValues();"  <%=(request.getParameter("hidMostrarDespesa") == null || request.getParameter("hidMostrarDespesa").equals("e") ? "checked" : "")%>/> Enviadas
                                    <input id="mostrarNaoEnviadas" type="radio" value="n" name="mostrarDespesa" onclick="alternarValues();" <%=(request.getParameter("hidMostrarDespesa") == null || request.getParameter("hidMostrarDespesa").equals("n") ? "checked" : "")%>/> Não enviadas
                                </div>
                            </td>
                            
                            
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <table table width="100%" cellspacing="1" cellpadding="2">
                        <td class="TextoCampos" width="11%">
                            <div align="right">Apenas o plano de custo:</div>
                        </td>
                        <td class="CelulaZebra2" width="30%" colspan="4">
                            <div align="left">
                                <input name="plano" type="text" class="inputReadOnly" id="plano" size="10" readonly value="<%=(request.getParameter("plano") != null ? request.getParameter("plano") : "")%>" />
                                <input name="planoNome" type="text" class="inputReadOnly" id="planoNome" size="28" readonly value="<%=(request.getParameter("planoNome") != null ? request.getParameter("planoNome") : "")%>"/>
                                <input type="button" class="inputbotao" name="botaoPlanoCusto" id="botaoPlanoCusto"  onclick="localizaPlanoCusto();" value="..."/>                                                
                                <input type="hidden" name="idPlano" id="idPlano" value="<%=(request.getParameter("idPlano") != null ? request.getParameter("idPlano") : "0")%>"/>
                                <img alt="" src="${homePath}/img/borracha.gif" id="borracha" onclick="limparPlanoCusto();" class="imagemLink"/>
                            </div>
                        </td>
                        <td class="TextoCampos" width="32%">
                            Mostrar duplicatas :
                        </td>
                        <td class="CelulaZebra2" width="30%" colspan="4">
                            <div align="left">
                                <input id="hidMostrarDuplicatas" type="hidden" name="hidMostrarDuplicatas" />
                                <input id="liberadas" type="radio" value="l" name="mostrarliberadas" onclick="mostrarDuplicatas();" <%=(request.getParameter("hidMostrarDuplicatas") == null || request.getParameter("hidMostrarDuplicatas").equals("l") ? "checked" : "")%>/> Liberadas
                                <input id="naoLiberadas" type="radio" value="nl" name="mostrarliberadas" onclick="mostrarDuplicatas();" <%=(request.getParameter("hidMostrarDuplicatas") == null || request.getParameter("hidMostrarDuplicatas").equals("nl") ? "checked" : "")%>/> Não liberadas
                                <input id="ambas" type="radio" value="am" name="mostrarliberadas" onclick="mostrarDuplicatas();" <%=(request.getParameter("hidMostrarDuplicatas") == null || request.getParameter("hidMostrarDuplicatas").equals("am") ? "checked" : "")%>/> Ambas
                            </div>
                        </td>
                    </table>
                </td>
            </tr>
            <tr
                >
                <td colspan="6" class="TextoCampos"> <div align="center">
                        <% if (nivelUser >= 1 || nivelUserBxViagem >= 1) {%>
                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
                        <%}%>
                    </div></td>
            </tr>
        </table>
        <form method="post" id="formBx">
            <table width="100%" border="0" class="bordaFina" id="lista">
                <tr class="tabela">
                    <td width="2%"><input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcaTodos();"></td>
                    <td width="7%">Docum.</td>
                    <td width="4%">PC</td>
                    <td width="20%"><strong>Fornecedor</strong></td>
                    <td width="8%"><strong>Vencim.</strong></td>
                    <td width="6%"><div align="right"><strong>Valor</strong></div></td>
                    <td width="6%"><div align="right"><strong>Vl Pago</strong></div></td>
                    <td width="14%"></td>
                    <td width="27%"><strong>Histórico</strong></td>
                    <td width="2%">&nbsp;</td>
                    <td width="2%">&nbsp;</td>
                    <td width="2%">&nbsp;</td>
                </tr>
                <% //variaveis da paginacao
                    int linha = 0;
                    // se conseguiu consultar
                    if ((acao.equals("consultar")) && (dupls.consultaBxPagar())) {
                        //Apenas as duplicatadas agora
                        ResultSet rs = dupls.getResultado();
                        while (rs.next()) {
                            boolean isRetencao = (rs.getFloat("valor_pis_retido") == 0 && rs.getFloat("valor_cofins_retido") == 0 && rs.getFloat("valor_cssl_retido") == 0);
                            //pega o resto da divisao e testa se é par ou impar
                %><tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                    <td>
                        <div class="linkEditar" onClick="">
                            <input name="chk_<%=linha%>" id="chk_<%=linha%>" type="checkbox" <%=(rs.getBoolean("baixado") || ((nivelUser < 4 && nivelUserBxViagem < 4) && !rs.getBoolean("pagtlib") && cfg.getTetoLiberacao() <= rs.getFloat("vlduplicata")) || (nivelLiberaSaldo < 4 && !rs.getBoolean("saldo_carta_autorizado")) ? "disabled=true" : "")%> value="<%=rs.getString("id")%>" onClick="javascript:getTotalDup('<%=linha%>',false);getNominal('<%=linha%>');avisoPagamentoSaldoNdd('<%=linha%>');">
                            <input name="tipoPagamento_<%=linha%>" id="tipoPagamento_<%=linha%>" type="hidden" value="<%=rs.getString("tipo_pagamento")%>">
                            <input name="idmovimento_<%=rs.getString("id")%>" id="idmovimento_<%=rs.getString("id")%>" type="hidden" value="<%=rs.getString("idmovimento")%>">
                            <input name="despesaCartaFrete_<%=rs.getString("id")%>" id="despesaCartaFrete_<%=rs.getString("id")%>" type="hidden" value="<%=rs.getString("is_despesa_carta_frete")%>">
                        </div>
                    </td>
                    <td><font size="1">
                        <%if (nivelUserDespesa >= 1) {%>
                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verDesp('<%=rs.getString("idmovimento")%>');});">
                            <font size="1"><%=rs.getString("nfiscal")%></font>
                        </div>
                        <%} else {%>
                        <font size="1"><%=rs.getString("nfiscal")%></font>
                        <%}%>
                        </font></td>
                    <td>
                        <font size="1"><%=rs.getString("parcela")%></font>
                    </td>

                    <td><font size="1">
                        <%=rs.getString("razaosocial")%>
                        <input name="idFornecedor_<%=rs.getString("id")%>" id="idFornecedor_<%=rs.getString("id")%>" value="<%=rs.getString("idfornecedor")%>" type="hidden" />
                        <input type="hidden" name="razaosocial_<%=rs.getString("id")%>"
                               id="razaosocial_<%=rs.getString("id")%>"  value="<%=rs.getString("razaosocial")%>">
                        </font></td>
                    <td><font size="1"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtvenc"))%></font></td>
                    <td><div align="right">
                            <input name="vldupl_<%=rs.getString("id")%>" id="vldupl_<%=rs.getString("id")%>" value="<%=fmtValor.format(rs.getDouble("valor_liquido"))%>" type="text" size="7" class="inputReadOnly8pt" readonly="true" maxlength="12" align="Right">
                        </div></td>
                        <%if (rs.getBoolean("baixado")) {%>
                    <td><div align="right"><font size="1"><%=fmtValor.format(rs.getDouble("vlpago"))%></font></div></td>
                    <td>
                        Pago em:<font size="1"><%=formatador.format(rs.getDate("dtpago"))%></font><br>
                        Conta:<font size="1"><%=rs.getString("conta")%></font>
                    </td>
                    <td><div align="left"><font size="1"><%=rs.getString("historico")%></font></div></td>
                    <td>
                        <%
                            boolean isPermissaoExcluir = false;
                            String auxData = formatador.format(rs.getDate("dtbaixa"));
                            if (nivelApagaContas >= 4 && idUsuario == rs.getInt("idusuariobaixa") && dataHoje.equals(auxData)) {
                                isPermissaoExcluir = true;
                            }
                            if (nivelUser == 4 || isPermissaoExcluir) {%>
                        <img src="img/lixo.png" alt="Excluir essa baixa" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:excluir('<%=rs.getString("idmovimento")%>','<%=rs.getString("duplicata")%>','<%=rs.getString("idlancamento")%>',<%=rs.getBoolean("conciliado")%>)});">
                        <%}%>
                    </td>
                    <td>
                        <%if (nivelUser == 4 && nivelUserConciliacao == 4) {%>
                        <img src="img/undo.gif" alt="Estornar essa baixa" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:estornar('<%=rs.getString("idmovimento")%>','<%=rs.getString("duplicata")%>','<%=rs.getString("idlancamento")%>')});" width="19" height="20" border="0" align="right">&nbsp;
                        <%}%>   
                    </td>
                    <td>
                        <img src="img/pdf.jpg" alt="Imprimir recibo" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:recibo('<%=rs.getString("id")%>')});"
                             width="19" height="20" border="0" align="right">
                    </td>
                    <%} else if ((nivelUser < 4 && nivelUserBxViagem < 4 && !rs.getBoolean("pagtlib") && cfg.getTetoLiberacao() <= rs.getDouble("valor_liquido"))) {%>
                    <td colspan="3"><div align="center"><font size="2">Pagamento Não Liberado</font></div></td>
                    <td><div align="left"><font size="1"><%=rs.getString("deschistorico")%></font></div></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <%} else if (nivelLiberaSaldo < 4 && !rs.getBoolean("saldo_carta_autorizado")) {%>
                    <td colspan="3"><div align="center"><font size="2">Pagamento do contrato de frete não autorizado</font></div></td>
                    <td><div align="left"><font size="1"><%=rs.getString("deschistorico")%></font></div></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <%} else {%>
                    <td><div align="right"><font size="1">
                            <input name="vlpago_<%=rs.getString("id")%>" id="vlpago_<%=rs.getString("id")%>"
                                   value="<%=Apoio.to_curr(rs.getDouble("valor_liquido") + rs.getFloat("vlacrescimo"))%>" 
                                   onBlur="javascript:seNaoFloatReset(this,'0.00');getTotalDup('<%=linha%>',true);criaNovaPcs('<%=rs.getString("id")%>', <%=rs.getBoolean("is_despesa_carta_frete") ? "'F'" : "''"%>);" 
                                   type="text" size="7" 
                                   class="fieldMin" maxlength="12" align="Right">
                            <input name="vladicional_<%=rs.getString("id")%>" id="vladicional_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getDouble("vlacrescimo"))%>" type="hidden" size="7" style="font-size:8pt;" maxlength="12" align="Right">
                            <input name="vlpagoaux_<%=rs.getString("id")%>" type="hidden" id="vlpagoaux_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getDouble("vlduplicata"))%>">
                            <input name="criapcs_<%=rs.getString("id")%>" type="hidden" id="criapcs_<%=rs.getString("id")%>" value="false">
                            <input name="dtnovapcs_<%=rs.getString("id")%>" id="dtnovapcs_<%=rs.getString("id")%>" value="<%=Apoio.getDataAtual()%>" type="text" size="8" class="fieldDateMin" style="display:none" maxlength="12">
                            <input name="idContas_<%=linha%>" id="idContas_<%=linha%>" value='<%=rs.getString("id")%>' type="hidden">
                            </font></div>
                    </td>

                    <td>
                        <input name="chkRet_<%=linha%>" id="chkRet_<%=linha%>" type="checkbox" <%=(rs.getBoolean("baixado") ? "disabled=true" : "")%> value="<%=rs.getString("id")%>" onClick="javascript:reterImpostos(<%=linha%>);" <%=(isRetencao ? "" : "checked")%>>
                        Reter impostos </td>

                    <td> <font size="1">
                        <input name="idhist_<%=rs.getString("id")%>" id="idhist_<%=rs.getString("id")%>" value="<%=rs.getString("historico_id")%>" type="hidden" size="1" style="font-size:8pt;" maxlength="3">
                        <input name="codhist_<%=rs.getString("id")%>" id="codhist_<%=rs.getString("id")%>" value="<%=rs.getString("codigo_historico")%>" type="text" size="1" class="fieldMin" maxlength="3">
                        <input name="<%=rs.getString("id")%>" type="button" class="botoes" id="<%=rs.getString("id")%>" value="..." onClick="javascript:localizahist(this);">
                        <input name="hist_<%=rs.getString("id")%>" id="hist_<%=rs.getString("id")%>" value="<%=rs.getString("deschistorico")%>" type="text" size="34" class="fieldMin" maxlength="120" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');">
                        <strong>
                        </strong> </font>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <%}%>
                </tr>
                <tr id="tr_ret<%=linha%>" name="tr_ret<%=linha%>" style="display:<%=(isRetencao ? "none" : "")%>">
                    <td colspan="12">
                        <table width="100%">
                            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                <td width="15%" ><div align="right"><font size="1">Impostos Retidos</font></div></td>
                                <td width="10%" ><div align="right"><font size="1">Valor original:</font></div></td>
                                <td width="6%" ><input name="vloriginal_<%=rs.getString("id")%>" id="vloriginal_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getFloat("vlduplicata"))%>" onBlur="javascript:seNaoFloatReset(this,'0.00');getTotalRetido(<%=rs.getString("id")%>);" type="text" size="7" class="inputReadOnly8pt" readonly="true" maxlength="12"></td>
                                <td width="3%" ><div align="right"><font size="1">PIS:</font></div></td>
                                <td width="6%" ><input name="vlpis_<%=rs.getString("id")%>" id="vlpis_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getFloat("valor_pis_retido"))%>" onBlur="javascript:seNaoFloatReset(this,'0.00');getTotalRetido(<%=rs.getString("id")%>);" type="text" size="7" class="fieldMin" maxlength="12"></td>
                                <td width="5%" ><div align="right"><font size="1">COFINS:</font></div></td>
                                <td width="6%" ><input name="vlcofins_<%=rs.getString("id")%>" id="vlcofins_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getFloat("valor_cofins_retido"))%>" onBlur="javascript:seNaoFloatReset(this,'0.00');getTotalRetido(<%=rs.getString("id")%>);" type="text" size="7" class="fieldMin" maxlength="12"></td>
                                <td width="4%" ><div align="right"><font size="1">CSSL:</font></div></td>
                                <td width="6%" ><input name="vlcssl_<%=rs.getString("id")%>" id="vlcssl_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getFloat("valor_cssl_retido"))%>" onBlur="javascript:seNaoFloatReset(this,'0.00');getTotalRetido(<%=rs.getString("id")%>);" type="text" size="7" class="fieldMin"" maxlength="12"></td>
                                <td width="5%" ><div align="right"><font size="1">Total:</font></div></td>
                                <td width="10%" ><input name="vltotalretido_<%=rs.getString("id")%>" id="vltotalretido_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getFloat("valor_pis_retido") + rs.getFloat("valor_cofins_retido") + rs.getFloat("valor_cssl_retido"))%>" onBlur="" type="text" size="7" class="inputReadOnly8pt" readonly="true" maxlength="12"></td>
                                <td width="33%" ></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%
                            linha++;
                        }%>
                        <input type="hidden" id="linha" name="linha" value="<%=linha%>"/>
                    <%}%>
            </table>
        </form>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr>
                <td width="10%" class="TextoCampos">Conta baixa:</td>
                <td width="22%" class="CelulaZebra2"><span class="CelulaZebra2"><font size="1">
                        <select name="conta" id="conta" class="fieldMin" style="font-size:8pt;" onChange="verFpag(false);">
                            <option value="">Selecione</option>
                            <%      //Carregando todas as contas cadastradas
                                BeanConsultaConta conta = new BeanConsultaConta();
                                conta.setConexao(Apoio.getUsuario(request).getConexao());
                                conta.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                ResultSet rsconta = conta.getResultado();
                                while (rsconta.next()) {%>
                            <option value="<%=rsconta.getString("idconta")+"@"+rsconta.getBoolean("is_ativar_envio_remessa_pagamentos")+"@"+rsconta.getString("cod_banco") %>"  
                                    <%=(request.getParameter("conta") != null && request.getParameter("conta").equals(rsconta.getString("idconta")) ? "selected" : 
                                    (rsconta.getInt("idconta") == cfg.getConta_padrao_id().getIdConta() &&  request.getParameter("conta") == null ? "selected" : ""))%>> 
                                <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%></option>
                            <%}
                                rsconta.close();%>
                        </select>
                        </font></span></td>
                <td width="22%" class="TextoCampos">Total selecionado: <font size="1">&nbsp;
                    </font> </td>
                <td width="16%" class="CelulaZebra2"><input name="totaldup" id="totaldup" value="0,00" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="12" class="inputReadOnly8pt" readonly="true" maxlength="12" align="Right"></td>
                <td colspan="2" class="CelulaZebra2"><div align="center">
                        <input name="chkimpcheque" type="checkbox" id="chkimpcheque">
                        Ao baixar, imprimir cheque.  </div></td>
            </tr>
            <tr>
                <td class="TextoCampos">Forma  pagam.:</td>
                <td class="CelulaZebra2"><select name="fpag" id="fpag" onChange="verFpag(false);" class="fieldMin">
                        <%BeanConsultaFPag fpag = new BeanConsultaFPag();
                            fpag.setConexao(Apoio.getUsuario(request).getConexao());
                            fpag.MostrarTudo();
                            ResultSet rsFpag = fpag.getResultado();
                            while (rsFpag.next()) {%>
                        <option value="<%=rsFpag.getString("idfpag")%>" style="background-color:#FFFFFF" <%=(rsFpag.getString("descfpag").equals("Cheque") ? "Selected" : "")%>><%=rsFpag.getString("descfpag") %></option>
                        <%}
                            rsFpag.close();%>
                    </select></td>
                <td colspan="2" class="CelulaZebra2">      <div align="left">
                        <input name="chkconciliado" type="checkbox" id="chkconciliado">
                        Ao baixar, conciliar o movimento banc&aacute;rio. </div></td>
                <td class="TextoCampos" width="10%">Driver:</td>
                <td class="CelulaZebra2" width="20%"><select name="driverImpressora" id="driverImpressora" class="fieldMin">
                        <option value="">&nbsp;</option>
                        <%                Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "chq.txt");
                            for (int i = 0; i < drivers.size(); ++i) {
                                String driv = (String) drivers.get(i);
                                driv = driv.substring(0, driv.lastIndexOf("."));
                        %>
                        <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                        <%}%>
                    </select></td>
            </tr>
            <tr>
                <td class="TextoCampos"><label id="lbDoc" name="lbDoc">N&ordm;  do cheque:</label></td>
                <td class="CelulaZebra2">

                    <%if (cfg.isControlarTalonario()) {%>
                    <select name="doc1" id="doc1" class="fieldMin">
                        <option value="" > ---- </option>          
                    </select>
                    <%}%>                    
                    <input name="doc" id="doc" value="" type="text" size="6" style="font-size:8pt;" maxlength="10" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');" class="fieldMin">

                    <label id="lbBomPara" name="lbBomPara">bom para:</label>
                    <input name="dtchq" id="dtchq" value="${dataCheque}" class="fieldDate" type="text" size="9" style="font-size:8pt;" maxlength="12" onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" >
                </td>
                <td class="TextoCampos"><div align="left"><span class="CelulaZebra2">
                            <input name="chkrecibo" type="checkbox" id="chkrecibo">
                            Imprimir recibo.</span></div></td>
                <td class="CelulaZebra2"><select name="cbmodelo" id="cbmodelo" class="fieldMin">
                        <option value="1" selected>Modelo 1</option>
                        <option value="2">Modelo 2</option>
                        <option value="3">Modelo 3</option>
                    </select></td>
                <td class="TextoCampos"><span class="TextoCampos">Impressora:</span></td>
                <td class="CelulaZebra2"><select name="caminho_impressora" id="caminho_impressora" class="fieldMin">
                        <option value="">&nbsp;&nbsp;</option>
                        <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                            impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                            impressoras.setLimiteResultados(50);
                            if (impressoras.Consultar()) {
                                ResultSet rs = impressoras.getResultado();
                                while (rs.next()) {%>
                        <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora()) ? "selected" : "")%>><%=rs.getString("descricao")%></option>
                        <%}%>
                        <%}%>
                    </select></td>
            </tr>
            <tr>
               
                <td class="TextoCampos">Data pagam.:</td>
                <td class="CelulaZebra2">
                    <font size="1">                    
                    
                    
                    <input name="dtpago" id="dtpago" value="${dataPago}" type="text" size="9" style="font-size:8pt;" maxlength="12" onBlur="alertInvalidDate(this);if ($('fpag').value == '2'){$('dtchq').value = this.value;}" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldDate">                       
                    </font>
                </td>
                <td class="TextoCampos">
                    <div align="left"><span class="CelulaZebra2">
                            <input name="chkimpcopiacheque" type="checkbox" id="chkimpcopiacheque" style="display:<%=(nivelCopiaCheque > 0 ? "" : "none")%>;">
                            <label name="imprimeCopia" id="imprimeCopia" style="display:<%=(nivelCopiaCheque > 0 ? "" : "none")%>;"> Imprimir c&oacute;pia de cheque. </label>

                        </span>
                    </div>

                </td>
                <td class="CelulaZebra2">

                    <select name="modeloCheque" id="modeloCheque" class="fieldMin">
                        <option value="1" selected>Modelo 1 (1 via)</option>
                        <option value="2">Modelo 2 (2 vias)</option>
                        <option value="3">Modelo 3</option>
                    </select>


                </td>
                <td class="TextoCampos"><span class="TextoCampos">Nominal &agrave;:</span></td>
                <td class="CelulaZebra2"><input name="nominal" id="nominal" value="" type="text" size="35" class="fieldMin" maxlength="50" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');"></td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    
                </td>
                <td class="CelulaZebra2">
                    <font size="1">
                    </font>
                </td>
                <td class="TextoCampos">
                </td>
                <td class="CelulaZebra2">
                </td>
                <td class="CelulaZebra2NoAlign" align="center" colspan="2" id="tdGerarArquivoRemessa">
                    <input type="button" id="gerarArquivoRemessa" name="gerarArquivoRemessa" class="botoes" value="Gerar arquivo de remessa" 
                           title="Gerar arquivo de remessa com as contas a pagar, que serão enviados ao banco." 
                           onClick="javascript:tryRequestToServer(function(){gerarArquivoRemessa(<%=linha%>, false);});"/>
                    
                </td>
            </tr>
        </table>
        <br/>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr>
                <td colspan="10" class="TextoCampos"> 
                    <div align="center" style="width: 50%;float:left;">
                        <% if (nivelUser >= 2 || nivelUserBxViagem >= 2) {%>
                        <input name="baixar" type="button" class="botoes" id="baixar" style="float: right;" value="Baixar" onClick="javascript:tryRequestToServer(function(){baixar(<%=linha%>);});">
                        <%}%>
                    </div>
                        <div align="center" id="divAcaoArquivoRemessa" style="width: 50%;float:left;"> 
                            <input type="button" id="gerarArquivoRemessaSantander" name="gerarArquivoRemessaSantander" class="botoes" value="Gerar arquivo de remessa" style="display: none"
                           title="Gerar arquivo de remessa com as contas a pagar, que serão enviados ao banco." 
                           onClick="javascript:tryRequestToServer(function(){gerarArquivoRemessa(<%=linha%>, true);});"/>
                                 Ação do Arquivo:
                        <select id="acaoArquivoRemessa" name="acaoArquivoRemessa" class="fieldMin">
                            <option value="i">INCLUSÃO</option>
                            <option id="opAlteracao" name="opAlteracao" value="a">ALTERAÇÃO</option>
                            <option value="e">EXCLUSÃO</option>
                        </select>
                     </div>
                </td>
            </tr>
        </table>
    </body>
</html>
