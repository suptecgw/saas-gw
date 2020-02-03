<%@page import="br.com.gwsistemas.eutil.NivelAcessoUsuario"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDIBO"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDI"%>
<%@page import="java.util.Collection"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="nucleo.Apoio,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         mov_banco.conta.BeanConsultaConta,
         conhecimento.duplicata.fatura.BeanConsultaFatura,
         conhecimento.duplicata.fatura.BeanCadFatura,
         java.util.Date" %>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanfatura") : 0);
    String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    int nivelCtrc = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelCtrcFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelNf = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    int nivelCobranca = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("emailcobranca") : 0);
    boolean limitarVisualizarUsuarioConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    Collection<LayoutEDI> listaLayoutCONEMB = LayoutEDIBO.mostrarLayoutEDI("c", Apoio.getUsuario(request));
    Collection<LayoutEDI> listaLayoutDOCCOB = LayoutEDIBO.mostrarLayoutEDI("f", Apoio.getUsuario(request));

    BeanConfiguracao configuracao = new BeanConfiguracao();
    configuracao.setConexao(Apoio.getUsuario(request).getConexao());
    configuracao.setExecutor(Apoio.getUsuario(request));
    boolean carregaConf = configuracao.CarregaConfig();

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    //Iniciando Cookie
    String filial = "";
    String campoConsulta = "";
    String valorConsulta = "";
    String anoFatura = "";
    String dataInicial = "";
    String dataFinal = "";
    String finalizada = "";
    String consignatario = "Todos";
    String idConsignatario = "0";
    String operadorConsulta = "";
    String limiteResultados = "";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;
    String valor1 = "";
    String valor2 = "";
    String enviadoEmail = "";
    String exportadaBanco = "";
    String faturaImpressa = "";
    String conta = "";
    String tipoOrdenacao = "";
    String situacaoFiltro = "";
    String criadoPorMim = "";
    
    //Carregando todas as contas cadastradas
    BeanConsultaConta contaSelc = new BeanConsultaConta();
    contaSelc.setConexao(Apoio.getUsuario(request).getConexao());
    contaSelc.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarVisualizarUsuarioConta, idUsuario);
    ResultSet rsconta = contaSelc.getResultado();

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaFatura")) {
                consulta = cookies[i];
            } else if (cookies[i].getName().equals("operadorConsulta")) {
                operador = cookies[i];
            } else if (cookies[i].getName().equals("limiteConsulta")) {
                limite = cookies[i];
            }
            if (consulta != null && operador != null && limite != null) { //se já encontrou os cookies então saia
                break;
            }
        }
        if (consulta == null) {//se não achou o cookieu então inclua
            consulta = new Cookie("consultaFatura", "");
        }
        if (operador == null) {//se não achou o cookieu então inclua
            operador = new Cookie("operadorConsulta", "");
        }
        if (limite == null) {//se não achou o cookieu então inclua
            limite = new Cookie("limiteConsulta", "");
        }
        consulta.setMaxAge(60 * 60 * 24 * 90);
        operador.setMaxAge(60 * 60 * 24 * 90);
        limite.setMaxAge(60 * 60 * 24 * 90);

        String[] splitConsulta = URLDecoder.decode(consulta.getValue(), "ISO-8859-1").split("!!");

        String valor = (consulta.getValue().isEmpty() || splitConsulta.length < 1 ? "" : splitConsulta[0]);
        String campo = (consulta.getValue().isEmpty() || splitConsulta.length < 2 ? "" : splitConsulta[1]);
        String ano = (consulta.getValue().isEmpty() || splitConsulta.length < 3 ? "" : splitConsulta[2]);
        String dt1 = (consulta.getValue().isEmpty() || splitConsulta.length < 4 ? fmt.format(new Date()) : splitConsulta[3]);
        String dt2 = (consulta.getValue().isEmpty() || splitConsulta.length < 5 ? fmt.format(new Date()) : splitConsulta[4]);
        String fin = (consulta.getValue().isEmpty() || splitConsulta.length < 6 ? "false" : splitConsulta[5]);
        String con = (consulta.getValue().isEmpty() || splitConsulta.length < 7 ? "Todos" : splitConsulta[6]);
        String idCon = (consulta.getValue().isEmpty() || splitConsulta.length < 8 ? "0" : splitConsulta[7]);
        String fl = (consulta.getValue().isEmpty() || splitConsulta.length < 9 ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : splitConsulta[8]);
        String vlr1 = (consulta.getValue().isEmpty() || splitConsulta.length < 10 ? "0.00" : splitConsulta[9]);
        String vlr2 = (consulta.getValue().isEmpty() || splitConsulta.length < 11 ? "0.00" : splitConsulta[10]);
        String envEmail = (consulta.getValue().isEmpty() || splitConsulta.length < 12 ? "false" : splitConsulta[11]);
        String expBanco = (consulta.getValue().isEmpty() || splitConsulta.length < 13 ? "false" : splitConsulta[12]);
        String cont = (consulta.getValue().isEmpty() || splitConsulta.length < 14 ? "0" : splitConsulta[13]);
        String ordenacao = (consulta.getValue().isEmpty() || splitConsulta.length < 15 ? "f" : splitConsulta[14]);
        String fatImp = (consulta.getValue().isEmpty() || splitConsulta.length < 16 ? "false" : splitConsulta[15]);
        String situ = (consulta.getValue().isEmpty() || splitConsulta.length < 17 ? "" : splitConsulta[16]);
        String criPorMim = (consulta.getValue().isEmpty() || splitConsulta.length < 18 ? "false" : splitConsulta[17]);
        
        valor1 = (request.getParameter("valor1") != null ? request.getParameter("valor1") : vlr1);
        valor2 = (request.getParameter("valor2") != null ? request.getParameter("valor2") : vlr2);
        enviadoEmail = (request.getParameter("enviadoEmail") != null ? request.getParameter("enviadoEmail") : envEmail);
        exportadaBanco = (request.getParameter("exportadaBanco") != null ? request.getParameter("exportadaBanco") : expBanco);
        faturaImpressa = (request.getParameter("faturaImpressa") != null ? request.getParameter("faturaImpressa") : fatImp);
        conta = (request.getParameter("conta") != null ? request.getParameter("conta") : cont);
        tipoOrdenacao = (request.getParameter("tipoOrdenacao") != null ? request.getParameter("tipoOrdenacao") : ordenacao);
        
        situacaoFiltro = (request.getParameter("situacaoFiltro") != null ? request.getParameter("situacaoFiltro") : situ );
        
        criadoPorMim = (request.getParameter("criadoPorMim") != null ? request.getParameter("criadoPorMim") : criPorMim);
        
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        anoFatura = (request.getParameter("anoFatura") != null ? request.getParameter("anoFatura") : (ano));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : (fin));
        consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : (con));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : (idCon));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "vencimento_fatura" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));


        consulta.setValue(URLEncoder.encode(valorConsulta + "!!" + campoConsulta + "!!" + anoFatura + "!!" + dataInicial + "!!" + dataFinal + "!!" + finalizada + "!!"
                + consignatario + "!!" + idConsignatario + "!!" + filial + "!!"
                + valor1 + "!!" + valor2 + "!!" + enviadoEmail + "!!" + exportadaBanco + "!!" + conta + "!!" + tipoOrdenacao + "!!" + faturaImpressa + "!!" 
                + situacaoFiltro + "!!" + criadoPorMim, "ISO-8859-1"));

        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
    } else {
        exportadaBanco = (request.getParameter("exportadaBanco") != null ? request.getParameter("exportadaBanco") : "false");
        faturaImpressa = (request.getParameter("faturaImpressa") != null ? request.getParameter("faturaImpressa") : "false");
        criadoPorMim = (request.getParameter("criadoPorMim") != null ? request.getParameter("criadoPorMim") : "false");
        enviadoEmail = (request.getParameter("enviadoEmail") != null ? request.getParameter("enviadoEmail") : "false");
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta") : "vencimento_fatura");
        anoFatura = (request.getParameter("anoFatura") != null && !request.getParameter("anoFatura").trim().equals("")
                ? request.getParameter("anoFatura") : "");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : "false");
        consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "Todos");
        idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0");
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador") : "1");
        operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados") : "10");
    }
//Finalizando Cookie

    BeanConsultaFatura conFat = new BeanConsultaFatura();
    conFat.setConta(conta);
    conFat.setExportadaBanco(exportadaBanco);
    conFat.setEnviadoEmail(enviadoEmail);
    conFat.setFaturaImpressa(faturaImpressa);
    conFat.setCampoDeConsulta(campoConsulta);
    conFat.setFilial(filial);
    conFat.setBaixado(finalizada);
    conFat.setLimiteResultados(Apoio.parseInt(limiteResultados));
    conFat.setOperador(Apoio.parseInt(operadorConsulta));
    conFat.setValorDaConsulta(valorConsulta);
    conFat.setDataVenc1(dataInicial);
    conFat.setDataVenc2(dataFinal);
    conFat.setAnoFatura(anoFatura);
    conFat.setValor1(Apoio.parseDouble(valor1));
    conFat.setValor2(Apoio.parseDouble(valor2));
    conFat.setIdConsignatario(Apoio.parseInt(idConsignatario));
    conFat.setPaginaResultados(request.getParameter("paginaResultados") == null ? 1 : Apoio.parseInt(request.getParameter("paginaResultados")));
    conFat.setOrdenacao(tipoOrdenacao);
    conFat.setSituacao(situacaoFiltro);
    conFat.setCriadoPorMim(criadoPorMim);
    conFat.setExecutor(Apoio.getUsuario(request));

    if (acao.equals("obter_ctrcs")) {

        conFat.setConexao(Apoio.getUsuario(request).getConexao());
        conFat.setCodFatura(request.getParameter("id"));
        if (conFat.consultaConhecimentos(0)){
            ResultSet ct = conFat.getResultado();
            int row = 0;
            boolean finalizado = false;
            String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'" + request.getParameter("idcarta") + ">"
                    + "<tr class='tabela'>"
                    + "<td width='8%'>Tipo</td>"
                    + "<td width='9%'>Nº doc.</td>"
                    + "<td width='2%'>PC</td>"
                    + "<td width='8%'>Emissao</td>"
                    + "<td width='12%'>Filial</td>"
                    + "<td width='27%'>Remetente</td>"
                    + "<td width='27%'>Destinatário</td>"
                    + "<td width='7%'><div align='right'>Valor</div></td>"
                    + "</tr>";
            while (ct.next()) {
                resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";
                resultado += "<td>" + (ct.getString("categoria").equals("ns") ? "NF Serviço" : (ct.getString("categoria").equals("fn") ? "Receita financeira" : "CTRC")) + "</td>";
                if (ct.getString("categoria").equals("ns") && nivelNf > 0) {
                    resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + ct.getString("sale_id") + ",0);});'>";
                } else if (ct.getString("categoria").equals("ct") && nivelCtrc > 0) {
                    if (ct.getInt("filial_id") == Apoio.getUsuario(request).getFilial().getIdfilial()) {
                        resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + ct.getString("sale_id") + ",1);});'>";
                    } else if (ct.getInt("filial_id") != Apoio.getUsuario(request).getFilial().getIdfilial() && nivelCtrcFilial > 0) {
                        resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + ct.getString("sale_id") + ",1);});'>";
                    } else {
                        resultado += "<td>";
                    }
                } else {
                    resultado += "<td>";
                }
                resultado += ct.getString("doc") + "-" + ct.getString("serie") + "</div></td>";
                resultado += "<td>" + ct.getString("parcela") + "</td>";
                resultado += "<td>" + (ct.getDate("emissao_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(ct.getDate("emissao_em")) : "") + "</td>";
                resultado += "<td>" + ct.getString("filial") + "</td>";
                resultado += "<td>" + ct.getString("remetente") + "</td>";
                resultado += "<td>" + ct.getString("destinatario") + "</td>";
                resultado += "<td><div align='right'>" + new DecimalFormat("#,##0.00").format(ct.getFloat("valor_parcela")) + "</div></td>";

                resultado += "</tr>";
                row++;
            }
            resultado += "</table>";
            response.getWriter().append(resultado);
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    }

//se a acao eh exportar fatura para arquivo .pdf
    if (acao.equals("exportar")) {
        String codFatura = request.getParameter("codFatura");
        Map param = new java.util.HashMap(2);

        param.put("ID_FATURA", String.valueOf(codFatura));
        param.put("IDFILIAL_EMISSAO", String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        String model = request.getParameter("modelo");
         if (model.indexOf("personalizado") > -1) {
            String relatorio = model;
            request.setAttribute("rel",relatorio);
            RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
            dispacher.forward(request, response);

        } else {
            request.setAttribute("rel", "faturamod" + request.getParameter("modelo"));
            RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
            dispacher.forward(request, response);
        }
        BeanCadFatura cadFat = new BeanCadFatura();
        cadFat.setExecutor(Apoio.getUsuario(request));
        cadFat.setConexao(Apoio.getUsuario(request).getConexao());
        cadFat.faturaImpressa(codFatura);
    }

    if (acao.equals("exportarBoleto")) {
        String codFatura = request.getParameter("codFatura");
        response.sendRedirect("./BoletoServlet?acao=gerar&codFatura=" + codFatura+"&gerarBoleto=true");
        BeanCadFatura cadFat = new BeanCadFatura();
        cadFat.setExecutor(Apoio.getUsuario(request));
        cadFat.setConexao(Apoio.getUsuario(request).getConexao());
        cadFat.faturaImpressa(codFatura);
        
    }
    if (acao.equals("exportarBoletoJasper")) {
        String codFatura = request.getParameter("codFatura");
        String modelo = request.getParameter("modelo");
        response.sendRedirect("./BoletoServlet?acao=gerarJasper&codFatura=" + codFatura + "&modelo=" + modelo+"&gerarBoleto=true");
        BeanCadFatura cadFat = new BeanCadFatura();
        cadFat.setExecutor(Apoio.getUsuario(request));
        cadFat.setConexao(Apoio.getUsuario(request).getConexao());
        cadFat.faturaImpressa(codFatura);
    }
        
    
    /*
     if (acao.equals("enviarEmail")) {
     conFat.setConexao(Apoio.getUsuario(request).getConexao());
     String codFatura = request.getParameter("fatura");
     */
    /*
     Map param = new java.util.HashMap(2);

     param.put("ID_FATURA", String.valueOf(codFatura));
     param.put("IDFILIAL_EMISSAO", String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
     request.getSession(false).setAttribute("map", param);
     request.getSession(false).setAttribute("rel", "faturamod" + request.getParameter("modelo"));

     conFat.enviaEmailRelatorio(request, response, this.getServletContext());
     acao = "consultar";
     */
    /*
     String acaoBoleto = "";
     String modelo = request.getParameter("modelo");
     if(modelo.equals("1")){
     acaoBoleto = "exportarBoleto";
     }else{
     acaoBoleto = "exportarBoletoJasper";
     }
     response.sendRedirect("./BoletoServlet?acao="+acaoBoleto+"&codFatura=" + codFatura + "&modelo=" + modelo);
     }
     */
%>

<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    jQuery.noConflict();


    function abrirPopAuditoria() {
        tryRequestToServer(function () {
            var url = "FaturaControlador?acao=auditoriaFatura&isExclusao=true&isFatura=true";

            window.open(url, 'auditoriaFaturaExclusao', 'toolbar=no,left=0,top=0,location=no,status=no,menubar=no,scrollbars=yes,resizable=no');
        });
    }
    
    function consultar(acao){
        //        if (getObj("campoDeConsulta").value == "vencimento_fatura" && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
        //            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
        //            return null;
        //        }

        //alert($('exportadaBanco').checked + "  "+ $('enviadoEmail').checked);

        document.location.replace("./consultafatura?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=conFat.getPaginaResultados() + 1%> : (acao=='anterior'?<%=conFat.getPaginaResultados() - 1%>:1))+
            "&exportadaBanco="+$('exportadaBanco').checked+"&enviadoEmail="+$('enviadoEmail').checked
            +"&faturaImpressa="+$('faturaImpressa').checked+"&criadoPorMim="+$("criadoPorMim").checked
            +"&"+
            concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,finalizada,anoFatura,con_rzs,idconsignatario,filialId,valor1,valor2,conta, tipoOrdenacao, situacaoFiltro"));
        
      
    }

    function excluir(id){
        function ev(resp, st){
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
            else
                document.location.replace("./consultafatura?acao=iniciar");
            else
                alert("Status "+st+"\n\nNão Conseguiu Realizar o Acesso ao Servidor!");
        }

        if (!confirm("Deseja Mesmo Excluir esta Fatura?"))
            return null;

        requisitaAjax("./fatura_cliente?acao=excluir&id="+id, ev);
    }

    function aoCarregar(){
        getObj("campoDeConsulta").value = "<%=campoConsulta%>";
        getObj("finalizada").value = "<%=finalizada%>";
        getObj("operador").value = "<%=operadorConsulta%>";
        getObj("limiteResultados").value = "<%=limiteResultados%>";
        getObj("valorDaConsulta").value = "<%=valorConsulta%>";
        getObj("anoFatura").value = "<%=anoFatura%>";
        getObj("filialId").value = "<%=filial%>";
        //        getObj("valor1").value = "<%=conFat.getValor1()%>";
        //        getObj("valor2").value = "<%=conFat.getValor2()%>";
        getObj("tipoOrdenacao").value = "<%=tipoOrdenacao%>";

    <%
        if (conFat.getCampoDeConsulta().equals("") || conFat.getCampoDeConsulta().equals("vencimento_fatura") || conFat.getCampoDeConsulta().equals("emissao_fatura")) {
    %>
            habilitaConsultaDePeriodo(true);
    <%   } else {%>
            habilitaConsultaDePeriodo(false);
    <%}%>
            if ($("idconsignatario").value != "0") {
                carregarLayoutsCliente($("idconsignatario").value);
            }else{
                mostrarTodosLayouts();
            }
        }
        
        function editar(id){
            location.replace("./fatura_cliente?acao=editar&id="+id);
        }

        function editarSale(id,categ){
            if (categ == 1){
                window.open('./frameset_conhecimento?acao=editar&id='+id+'&ex=false', 'CTRC' , 'top=0,resizable=yes');
            }else{
                window.open('./cadvenda.jsp?acao=editar&id='+id+'&ex=false', 'NF_Servico' , 'top=0,resizable=yes');
            }
        }

        function habilitaConsultaDePeriodo(opcao) {

            getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
            getObj("anoFatura").style.display = (opcao ? "none" : "");
            getObj("operador").style.display = (opcao ? "none" : "");
            getObj("div1").style.display = (opcao ? "" : "none");

            if ($("campoDeConsulta").value == "lote_automatico" || $("campoDeConsulta").value == "ct_nfs"){
                getObj("anoFatura").style.display = "none" ;
            }else if($("campoDeConsulta").value == "numromaneio"){
                getObj("operador").style.display = "none";
            }else if($("campoDeConsulta").value == "numero_bordero"){
                getObj("operador").style.display = "none";
                getObj("anoFatura").style.display = "none";
            }
        }

        function viewCtrcs(idFat){
            function e(transport){
                var textoresposta = transport.responseText;
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0") {
                    return false;
                }else{
                    Element.show("trfat_"+idFat);
                    $("trfat_"+idFat).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
                }
            }//funcao e()
            if (Element.visible("trfat_"+idFat)){
                Element.toggle("trfat_"+idFat);
                $('plus_'+idFat).style.display = '';
                $('minus_'+idFat).style.display = 'none';
            }else{
                $('plus_'+idFat).style.display = 'none';
                $('minus_'+idFat).style.display = '';
                new Ajax.Request("./consultafatura?acao=obter_ctrcs&id="+idFat,{method:'post', onSuccess: e, onError: e});
            }
        }

        function popFatura(tipoImpressao){
            var codFat = getCheckedFaturas();

            //return alert("" + codFat);

            if (codFat == ''){
                alert('Favor Informar a(s) Fatura(s) que Deseja Imprimir.');
            }else{
                pdf = window.open('./consultafatura?acao=exportar&modelo='+$("cbmodelo").value+'&codFatura='+codFat+"&impressao="+tipoImpressao,'fatura',
                'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
            }
        }

        function popBoleto(){
            var codFat = getCheckedFaturas();
            var modelo = $("modeloBoleto").value;
            var acao = "";
                
                    for (i = 0; getObj("ck" + i) != null; ++i){
                        if (getObj("ck" + i).checked && $("isBaixado_"+i).value == 'true'){
                           alert("Boleto " + $("nomeFatura_"+i).value +" ! já esta quitado total ou parcial, impressão do boleto não permitido ");
                           return false;
                        }
                    }
               
//            if(modelo == "1"){
//                acao = "exportarBoleto";
//            }else{
                acao = "exportarBoletoJasper";
//            }

            if (codFat == ''){
                alert('Favor Informar o(s) Boletos(s) que Deseja Imprimir.');
            }else{
                pdf = window.open('./consultafatura?acao='+acao+'&codFatura='+codFat + '&modelo=' + modelo,'fatura',
                'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
            }
        }

        function enviarEmail(codFat,idCliente,cliente,clienteCgc,emails,numFatura,vencimento, gerarBoleto, isBaixado) {
            if(emails == ""){
                return alert("Para Enviar o Boleto por E-mail, \n "+
                    "O Cliente Deve Ter no Mínimo um Contato (Com Perfil de Cobrança).");
            }
            if (isBaixado) {
                return alert("Fatura " + numFatura + " baixada, não é possível enviar o e-mail!");
            }

            var acaoBoleto = "";
            var modelo = "";
            
            if (gerarBoleto) {
                modelo = $("modeloBoleto").value;
            }else{
                modelo = $("cbmodelo").value;
            }

            if(modelo == "1"){
                acaoBoleto = "gerar";
            }else{
                acaoBoleto = "gerarJasper";
            }
            window.open("./BoletoServlet?acao="+acaoBoleto+"&codFatura=" + codFat +
                "&modelo=" + modelo+"&emailCliente="+emails+"&idCliente="+idCliente+"&cliente="+cliente+"&clienteCgc="+clienteCgc+
                "&numFatura=" + numFatura + "&vencimento=" + vencimento +"&gerarBoleto=" + gerarBoleto +
                "&enviaEmail=true&detNomeArquivoEmail="+idCliente+"_"+numFatura.replace("/",""),
                "pop", "width=210, height=100");     
                       
        }
        
        
        function enviarCTE(idCte){
            var isCanc = false;
            if (idCte == null)
                return null;
            window.open("./CTeControlador?acao=enviarEmail&idCte=" + idCte+"&isCanc=" + isCanc , idCte, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
        }        

        function enviarFaturasEmails(acao){
            var faturas = getCheckedFaturas();
            var faturasSituacao = getCheckedFaturasEsituacao();
            var modelo = $("modeloBoleto").value;
            var numeroFaturaBaixada = "";
            
            for (var i = 0; i < faturasSituacao.split(",").length; i++) {
                if (faturasSituacao.split(",")[i].split("@")[1] == "true") {
                    if (numeroFaturaBaixada == "") {
                        numeroFaturaBaixada = faturasSituacao.split(",")[i].split("@")[0];                        
                    }else{
                        numeroFaturaBaixada += "," + faturasSituacao.split(",")[i].split("@")[0];
                    }
                }
            }
            
            if (numeroFaturaBaixada != "") {
                 alert("Fatura(s) " + numeroFaturaBaixada + " baixada(s), não é possível enviar o e-mail!");
                 return false
            }
            
            if(faturas == ""){
                alert("Escolha Pelo Menos uma Fatura !");
                return false;
            }
            window.open("./BoletoServlet?acao=enviarFaturasEmail" + "&faturas=" + faturas
                +"&modelo=" + modelo + "&enviaEmail=true&modeloFatura="+$("cbmodelo").value,
                 "pop", "width=210, height=100");
        }
        function enviarFaturasEmailCobranca(acao){
            var faturas = getCheckedFaturas();
            var faturasSituacao = getCheckedFaturasEsituacao();
            var modelo = $("modeloBoleto").value;
            var numeroFaturaBaixada = "";
            
            for (var i = 0; i < faturasSituacao.split(",").length; i++) {
                if (faturasSituacao.split(",")[i].split("@")[1] == "true") {
                    if (numeroFaturaBaixada == "") {
                        numeroFaturaBaixada = faturasSituacao.split(",")[i].split("@")[0];                        
                    }else{
                        numeroFaturaBaixada += "," + faturasSituacao.split(",")[i].split("@")[0];
                    }
                }
            }
            
            if (numeroFaturaBaixada != "") {
                 alert("Fatura(s) " + numeroFaturaBaixada + " baixada(s), não é possível enviar o e-mail!");
                 return false
            }
            
            if(faturas == ""){
                alert("Escolha Pelo Menos uma Fatura !");
                return false;
            }
            
            window.open("./BoletoServlet?acao=enviarFaturasEmailCobranca" + "&faturas=" + faturas
                +"&modelo=" + modelo + "&enviaEmail=true&modeloFatura="+$("cbmodelo").value,
                 "pop", "width=210, height=100");
                return false;
        }

        function getCheckedFaturasEsituacao(){
            var ids = "";
            for (i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked)
                    ids += ',' + getObj("nomeFatura_" + i).value + "@" + getObj("isBaixado_" + i).value;

            return ids.substr(1);
        }

        function getCheckedFaturas(){
            var ids = "";
            for (i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked)
                    ids += ',' + getObj("ck" + i).value;

            return ids.substr(1);
        }

        function exportarTextoMatricial() {
            var codFat = getCheckedFaturas();
            if (codFat == ''){
                alert('Favor Informar a(s) Fatura(s) que Deseja Imprimir.');
            }else{
                location.href = './servletMatricideFatura.ctrc?fatura='+codFat+"&driverImpressora="+$('driverImpressora').value+
                    "&caminho_impressora="+$('caminho_impressora').value;
            }
        }

        function marcaTodos(){
            var i = 0;
            while ($("ck"+i) != null){
                $("ck"+i).checked = $("chkTodos").checked;
                i++;
            }
        }
        var dataAtualSistema = '<%=new SimpleDateFormat("dd/MM/yyyy").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
        var dataAtual = '<%=new SimpleDateFormat("yyyyMMdd").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
        var dataAtualRicardo = '<%=new SimpleDateFormat("ddMM").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
        var dataAtualMercador = '<%=new SimpleDateFormat("ddMMyyyyHHmm").format(new Date())%>';       
    
        function exportarEDI(){
            try {
                var codFat = getCheckedFaturas();
                if (codFat == "") {
                    return alert("Selecione Pelo Menos uma Fatura!");
                }
                
                var mod = $('versaoDOCCOB').value;
                if ($("idconsignatario").value == '0'){
                    return alert('Informe o Cliente Antes de Gerar o Arquivo.');
                }else{
                    if(mod=='roca-doccob'){
                        document.location.href = './COBRANCA_000000.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                            "&sped="+$('chkSped').checked;
                    }else if(mod=='intral'){
                        document.location.href = './conhec_fatur.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value;
                    }else if(mod=='pro3.0a-doccob' || mod=='pro3.0a-doccob-dhl' || mod=='pro3.0a-doccob-betta' || mod=='neogrid_doccob'
                        || mod=='santher3.0a-doccob' || mod=='pro3.0a-doccob-tramontina' || mod=='pro3.0a-doccob-alianca'
                        || mod=='pro3.0a-doccob-paulus' || mod=='tivit3.0a-doccob' 
                        || mod == 'pro5.0-doccob' || mod == 'pro4.0'){
                        document.location.href = './DOCCOB'+dataAtual+'.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                            "&sped="+$('chkSped').checked;
                    }else if(mod=='ricardo-doccob'){
                        document.location.href = './COB'+dataAtualRicardo+'0.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                            "&sped="+$('chkSped').checked;
                    }else if(mod=='mercador'){
                        document.location.href = './' + $('con_fantasia').value + 'CTRC'+dataAtualMercador+'001.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value +
                            '&filial=0';
                    }else if(mod=='gerdau' || mod=='pro3.0a' || mod=='pro3.1' || mod == 'nestle'
                        || mod=='pro3.1gko' || mod=='pro3.1betta' || mod=='pro3.1kimberly' || mod=='santher3.1-conemb' || mod=='terphane'
                        || mod=='pro3.0aTramontina' || mod=='docile-conemb' || mod=='bpcs-cremer' || mod=='neogrid_conemb'
                        || mod=='tivit3.1-conemb' || mod == 'pro5.0' || mod == 'usiminas'){
                        document.location.href = './CONEMB'+dataAtual+'.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                            "&sped="+$('chkSped').checked;
                    }else if (mod == 'ricardo-conemb'){
                        document.location.href = './CTO'+dataAtualRicardo+'.txt3?modelo='+mod+
                            '&codFat='+codFat+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                            "&sped="+$('chkSped').checked;
                    }else if(mod.indexOf("webserviceAvon") > -1){
                        var acao = "";
                        if (mod.indexOf("_con") > -1) {
                            acao = "consultarFaturasAvon";
                        }else{
                            acao = "enviarFaturasAvon";
                        }
                        var docum = window.open('about:blank', 'pop', 'width=510, height=200');
                        docum.location.href = "NDDAvonControlador?acao="+acao+"&ids="+codFat+"&idfilial="+$("filialId").value+"&"+concatFieldValue("idconsignatario");
                    }else if(mod.indexOf("funcEdi") > -1){
                        layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_f);
                        
                        if (layout == null) {
                            var layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_c);
                        }
                        
                        var numeroCTE = "";
                        var dataEmissaoCTE = "";
                        var idPrimeiraFatura = "";
                        
                        if(codFat.split(',').length > 1){
                           idPrimeiraFatura = codFat.split(',')[0];
                        }else{
                           idPrimeiraFatura = codFat; 
                        }
                        numeroCTE = $("numeroCTE_"+idPrimeiraFatura).value;
                        dataEmissaoCTE = $("dataEmissaoCTE_"+idPrimeiraFatura).value;
                        dataEmissaoCTE = dataEmissaoCTE.split('-')[2]+dataEmissaoCTE.split('-')[1]+dataEmissaoCTE.split('-')[0];
                        
                        if (layout != null) {
                            var nomeArquivo = layout.nomeArquivo;
                            var horaAtualSistema = new Date();
                            nomeArquivo = replaceAll(nomeArquivo, "@@dia", dataAtualSistema.split("/")[0]);
                            nomeArquivo = replaceAll(nomeArquivo, "@@mes", dataAtualSistema.split("/")[1]);
                            nomeArquivo = replaceAll(nomeArquivo, "@@ano", dataAtualSistema.split("/")[2]);
                            nomeArquivo = replaceAll(nomeArquivo, "@@hora", horaAtualSistema.getHours());
                            nomeArquivo = replaceAll(nomeArquivo, "@@minuto", horaAtualSistema.getMinutes());
                            nomeArquivo = replaceAll(nomeArquivo, "@@segundo", horaAtualSistema.getSeconds());
                            nomeArquivo = replaceAll(nomeArquivo, "@@numero_CTE", numeroCTE);
                            nomeArquivo = replaceAll(nomeArquivo, "@@data_Emissao_CTE", dataEmissaoCTE);
                            switch(layout.extencaoArquivo){
                                case "txt":
                                    document.location.href = "./"+nomeArquivo+".txt3?modelo=funcEDI&ids="+codFat+"&layoutID="+layout.id+"&"+concatFieldValue("idconsignatario");
                                    break;
                                case "csv":
                                    document.location.href = "./"+nomeArquivo+".csv?modelo=funcEDI&ids="+codFat+"&layoutID="+layout.id+"&"+concatFieldValue("idconsignatario");
                                    break;
                            }
                        }else{
                            alert("Não Foi Possivel Gerar Arquivo!");
                        }
                    }
                }
            } catch (e) { 
                alert(e);
            }
        }

        function aoClicarNoLocaliza(idjanela){
            function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
            if (idjanela == "Consignatario_Fatura"){
                $('pesquisar').click();
            }
        }


        //*************************   EDI DINAMICO  ********************* INICIO
        var layoutsFunctionAll_c = new Array();
        var layoutsFunctionAll_f = new Array();
        var idxAll_c = 0;
        var idxAll_f = 0;

        var idxLayTela = 0;
        var listLayoutEDITela = new Array();
        var idxLay_c = 0;
        var listLayoutEDI_c = new Array();
        var idxLay_f = 0;
        var listLayoutEDI_f = new Array();

        var layoutsCliente_c = new Array();
        var layoutsCliente_f = new Array();
        var idxF = 0;
        var idxC = 0;
    
        listLayoutEDI_c[idxLay_c++] = new Option("---","--------------------------------------------------------------");
        listLayoutEDI_c[idxLay_c++] = new Option("bpcs-cremer","EDI-CONEMB(BPCS - Cremer S/A)");
        listLayoutEDI_c[idxLay_c++] = new Option("docile-conemb","EDI-CONEMB(EMS Datasul/Totvs - Docile Ltda)");
        listLayoutEDI_c[idxLay_c++] = new Option("gerdau","EDI-CONEMB(Gerdau)");
        listLayoutEDI_c[idxLay_c++] = new Option("mercador","EDI-CONEMB(Mercador)");
        listLayoutEDI_c[idxLay_c++] = new Option("neogrid_conemb","EDI-CONEMB(NeoGrid)");
        listLayoutEDI_c[idxLay_c++] = new Option("nestle","EDI-CONEMB(Nestle)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro3.0a","EDI-CONEMB(Proceda 3.0a)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro3.0aTramontina","EDI-CONEMB(Proceda 3.0a-Tramontina)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro3.1","EDI-CONEMB(Proceda 3.1)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro3.1betta","EDI-CONEMB(Proceda 3.1-Bettanin)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro3.1gko","EDI-CONEMB(Proceda 3.1-GKO)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro3.1kimberly","EDI-CONEMB(Proceda 3.1-Kimberly)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro4.0","EDI-CONEMB(Proceda 4.0-Aliança)");
        listLayoutEDI_c[idxLay_c++] = new Option("pro5.0","EDI-CONEMB(Proceda 5.0)");
        listLayoutEDI_c[idxLay_c++] = new Option("ricardo-conemb","EDI-CONEMB(Ricardo Eletro)");
        listLayoutEDI_c[idxLay_c++] = new Option("santher3.1-conemb","EDI-CONEMB(Santher 3.1)");
        listLayoutEDI_c[idxLay_c++] = new Option("terphane","EDI-CONEMB(Terphane)");
        listLayoutEDI_c[idxLay_c++] = new Option("tivit3.1-conemb","EDI-CONEMB(Tivit 3.0-GDC)");
        listLayoutEDI_c[idxLay_c++] = new Option("usiminas","EDI-CONEMB(Soluções Usiminas)");
    <%for (LayoutEDI layout : listaLayoutCONEMB) {%>
        listLayoutEDI_c[idxLay_c++] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
        layoutsFunctionAll_c[idxAll_c++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
    <%}%>

        listLayoutEDI_f[idxLay_f++] = new Option("intral","EDI-DOCCOB(EMS Datasul/Totvs (Intral S/A))");
        listLayoutEDI_f[idxLay_f++] = new Option("neogrid_doccob","EDI-DOCCOB(NeoGrid)");
        listLayoutEDI_f[idxLay_f++] = new Option("pro3.0a-doccob","EDI-DOCCOB(Proceda 3.0a)");
        listLayoutEDI_f[idxLay_f++] = new Option("pro3.0a-doccob-alianca","EDI-DOCCOB(Proceda 3.0a (Aliança))");
        listLayoutEDI_f[idxLay_f++] = new Option("pro3.0a-doccob-betta","EDI-DOCCOB(Proceda 3.0a (Bettanin))");
        listLayoutEDI_f[idxLay_f++] = new Option("pro3.0a-doccob-tramontina","EDI-DOCCOB(Proceda 3.0a-Tramontina)");
        listLayoutEDI_f[idxLay_f++] = new Option("pro3.0a-doccob-dhl","EDI-DOCCOB(Proceda 3.0a (DHL))");
        listLayoutEDI_f[idxLay_f++] = new Option("pro3.0a-doccob-paulus","EDI-DOCCOB(Proceda 3.0a (Paulus))");
        listLayoutEDI_f[idxLay_f++] = new Option("ricardo-doccob","EDI-DOCCOB(Ricardo Eletro)");
        listLayoutEDI_f[idxLay_f++] = new Option("roca-doccob","EDI-DOCCOB(Roca Brasil)");
        listLayoutEDI_f[idxLay_f++] = new Option("santher3.0a-doccob","EDI-DOCCOB(Santher 3.0a)");
        listLayoutEDI_f[idxLay_f++] = new Option("tivit3.0a-doccob","EDI-DOCCOB(Tivit 3.0a)");
        listLayoutEDI_f[idxLay_f++] = new Option("pro5.0-doccob","EDI-DOCCOB(Proceda 5.0)");
        listLayoutEDI_f[idxLay_f++] = new Option("webserviceAvon_env","EDI-DOCCOB(Avon (Web Service Envio))");
        listLayoutEDI_f[idxLay_f++] = new Option("webserviceAvon_con","EDI-DOCCOB(Avon (Web Service Consulta))");
    <%for (LayoutEDI layout : listaLayoutDOCCOB) {%>
        listLayoutEDI_f[idxLay_f++] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
        layoutsFunctionAll_f[idxAll_f++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
    <%}%>

        function removerEDI(elemento, layoutsCliente, listaContainer, tipo){
            var listaInclusao = new Array();
            var i = 0;

            try {
                for (i; i < layoutsCliente.size(); i++) {
                    if (layoutsCliente[i].layoutEDI.id != 0) {
                        listaInclusao[i] = new Option( layoutsCliente[i].layoutEDI.id , layoutsCliente[i].layoutEDI.descricao);
                        listaInclusao[i].valor += "!!funcEdi";
                    }else{
                        for (j = 0; j < listaContainer.size(); j++) {
                            if (layoutsCliente[i].layoutFormatoAntigo == listaContainer[j].valor && listaContainer[j].valor != "") {
                                listaInclusao[i] = listaContainer[j];
                            }
                        }
                    }
                }
                povoarSelect(elemento, listaInclusao, true, tipo);
                elemento.selectedIndex = 0;
            } catch (e) { 
                alert(e);
            }
        }

        function carregarLayoutsCliente(clienteId){
            try {
                function e(transport){
                    var textoresposta = transport.responseText;
                    var lista = jQuery.parseJSON(textoresposta).list[0];

                    //Verificando se existe alguma lista de EDI no cadastro do cliente
                    if (lista != "") {
                        var listaEDI = lista.listaClienteLayoutsEDI;
                        //Definindo o tamanho da lista
                        var length = (listaEDI != undefined && listaEDI.length != undefined ? listaEDI.length : 1);
                        for(var i = 0; i < length; i++){
                            //Lendo os layouts que estão no cadastro do cliente e colocando eles dentro  da lista que será colocada dentro do <select>
                            if(length > 1){
                                switch(listaEDI[i].tipo){
                                    case "c"://Caso o tipo seja conemb
                                        layoutsCliente_c[idxC++] = (listaEDI[i]);
                                        break;
                                    case "f"://Caso o tipo seja doccob
                                        layoutsCliente_f[idxF++] = (listaEDI[i]);
                                        break;
                                }
                            }else{
                                switch(listaEDI.tipo){
                                    case "c"://Caso o tipo seja conemb
                                        layoutsCliente_c[idxC++] = (listaEDI);
                                        break;
                                    case "f"://Caso o tipo seja doccob
                                        layoutsCliente_f[idxF++] = (listaEDI);
                                        break;
                                }

                            }
                        }
                        removeOptionSelected("versaoDOCCOB");
                        removerEDI($("versaoDOCCOB"), layoutsCliente_f, listLayoutEDI_f, "f");
                        removerEDI($("versaoDOCCOB"), layoutsCliente_c, listLayoutEDI_c, "c");
                    }else{
                        mostrarTodosLayouts();
                    }

                }//funcao e()
                tryRequestToServer(function(){
                    new Ajax.Request("LayoutEDIControlador?acao=ajaxCarregarClienteLayoutEDI&cliente_id="+clienteId,{method:'post', onSuccess: e, onError: e});
                });
            } catch (e) { 
                alert("Erro ao Carregar a Lista de Layouts Para EDI do Cliente!"+e)
            }

        }

        function getFuncLayoutEDI(valor, layoutsCliente){
            try {
                var retorno = null;
                for (i = 0; i < layoutsCliente.size(); i++) {
                    if (layoutsCliente[i].layoutEDI.id == valor) {
                        retorno =  layoutsCliente[i].layoutEDI;
                        break;
                    }
                }
            } catch (e) { 
                alert(e);
            }
            return retorno;
        }

        function povoarSelect(elemento, lista, isDivisao, tipo){
            try {
                if (isDivisao && tipo == "c") {
                    optLayout = Builder.node("option", {value: "---"});
                    Element.update(optLayout, "--------------------------------------------------------------");
                    elemento.appendChild(optLayout);
                }

                var optLayout = null;
                if (lista != null) {
                    for(var i = 0; i < lista.length; i++){
                        if (lista[i] != null && lista[i] != undefined) {
                            optLayout = Builder.node("option", {value: lista[i].valor});
                            Element.update(optLayout, lista[i].descricao);
                            elemento.appendChild(optLayout);
                        }
                    }
                    elemento.selectedIndex = 0;
                }
            } catch (e) { 
                alert(e);
            }
        }

        function mostrarTodosLayouts(){
            removeOptionSelected("versaoDOCCOB");
            povoarSelect($("versaoDOCCOB"), listLayoutEDI_f, false, "");
            povoarSelect($("versaoDOCCOB"), listLayoutEDI_c, false, "");
        }
        //*************************   EDI DINAMICO  ********************* FIM


function setIcone(valor){
        var img = "";
        switch (valor){
            case "1":
                img = "imprimirPDF";
                break;
            case "2":
                img = "imprimirEXCEL";
                break;
            case "3":
                img = "imprimirWORD";
                break;
        }
        
        document.getElementById("imprimirPDF").style.display = "none";
        document.getElementById("imprimirEXCEL").style.display = "none";
        document.getElementById("imprimirWORD").style.display = "none";
        
        document.getElementById(img).style.display = "";

    }
    
    function verificarSituacao(situacao){        
        console.log("aaaaaaaa situacao ::: " + situacao);
        if (situacao == 'CA') {
            $("trPrincipal").style.color = "red";
        }
    }

</script>
<%@page import="conhecimento.duplicata.fatura.BeanConsultaFatura"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="filial.BeanFilial"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="nucleo.impressora.BeanConsultaImpressora"%>
<%@page import="java.util.Vector"%>
<%@page import="java.util.Map"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Faturas / Boletos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style8 {font-size: 11px}
            -->
        </style>
    </head>

    <body onLoad="aoCarregar();applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=idConsignatario%>">
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <%
                    if (nivelUser >= 2) {
                %>
                        <td width="44%" align="left"><b>Consulta de Faturas / Boletos</b></td>
                <%  }

                    if (nivelUser >= 3) {
                %>
                        <td width="56%">
                            <input name="auditoria_fatura" type="button" class="botoes" id="auditoria_fatura"
                                   onClick="javascript:abrirPopAuditoria();"
                                   value="Visualizar Auditoria">
                            <input name="imp_fatura" type="button" class="botoes" id="imp_fatura"
                                onClick="javascript:tryRequestToServer(function(){document.location.replace('./importar_fatura.jsp?acao=iniciar');});"
                                value="Importar Faturas">
                            <input name="novoFaturaLote" type="button" class="botoes" id="novoFaturaLote"
                                onClick="javascript:tryRequestToServer(function(){
                                    document.location.replace('./cadfatura_lote.jsp?acao=consultar&idconsignatario=0&con_rzs=&marcados=&acaoDoPai=cad');});"
                                value="Faturar CT-e(s)/NFs em lote">
                            <input name="novo" type="button" class="botoes" id="novo"
                                onClick="javascript:tryRequestToServer(function(){document.location.replace('./fatura_cliente?acao=iniciar');});"
                                value="Novo cadastro">
                        </td>
                <%  }
                %>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="12%"  height="8">
                    <select name="campoDeConsulta" class="fieldMin" id="campoDeConsulta" onChange="javascript:habilitaConsultaDePeriodo(this.value=='vencimento_fatura'||this.value=='emissao_fatura');">
                        <option value="numromaneio">Nº Fatura / Ano</option>
                        <option value="vencimento_fatura" selected>Vencimento</option>
                        <option value="emissao_fatura" selected>Data de Emiss&atilde;o</option>
                        <option value="lote_automatico" >Nº Lote</option>
                        <option value="boleto_nosso_numero" >Nosso N&uacute;mero</option>
                        <option value="numero_pre_fatura" >Número Pré Fatura</option>
                        <option value="numero_cte" >CT-e/NFS</option>
                        <option value="numero_bordero" >Numero do borderô</option>
                    </select> 
                </td>
                <td width="27%">
                    <select name="operador" id="operador" class="fieldMin">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">
                        De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10"
                               value="<%=dataInicial%>"
                               onblur="alertInvalidDate(this)" class="fieldDate" >
                        At&eacute;:
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10"
                               value="<%=dataFinal%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" class="fieldMin" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" value="" size="20">
                    <input name="anoFatura" type="text" id="anoFatura" class="fieldMin" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" value="" size="4">
                </td>
                <td width="8%"><div align="right">Filial:</div></td>
                <td width="10%">
                    <select name="filialId" id="filialId" class="fieldMin">
                        <option value="0" selected="selected">TODAS</option>
                        <%BeanFilial fl = new BeanFilial();
                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                            while (rsFl.next()) {
                        %>
                        <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                        <%}%>
                    </select>
                </td>
                <td width="12%"><div align="right">Mostrar:</div></td>
                <td width="10%" height="20">
                    <div align="left">
                        <select name="finalizada" id="finalizada" class="fieldMin">
                            <option value="todas">Todas</option>
                            <option value="false">Em aberto</option>
                            <option value="true" selected>Baixadas</option>
                        </select>
                    </div>
                </td>
                <td width="21%" >
                    <div align="center">Por P&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="fieldMin">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                            <option value="100">100 resultados</option>
                            <option value="200">200 resultados</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td><div align="right">Cliente:</div></td>
                <td>
                    <div align="left">
                        <input name="con_fantasia" type="hidden" id="con_fantasia" value="">
                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly8pt" value="<%=consignatario%>" size="27" readonly="true">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Consignatario_Fatura');;">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idconsignatario').value = '0';getObj('con_rzs').value = 'Todos';">    
                    </div>
                </td>
                <td colspan="2" align="right">Filtrar Valores: </td>
                <td colspan="2">
                    <div align="left">
                        Entre 
                        <input name="valor1" id="valor1" value="<%=(request.getParameter("valor1") != null ? request.getParameter("valor1") : valor1)%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="5" class="fieldMin" maxlength="12" align="Right">
                        e
                        <input name="valor2" id="valor2" value="<%=(request.getParameter("valor2") != null ? request.getParameter("valor2") : valor2)%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="5" class="fieldMin" maxlength="12" align="Right">
                    </div>
                </td>
                <td>
                    <div align="center" >
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td>Mostrar Apenas:</td>
                <td align="left">
                    <label>
                        <input name="enviadoEmail" type="checkbox" id="enviadoEmail" <%=(Apoio.parseBoolean(enviadoEmail) ? "checked" : "")%>>
                        N&atilde;o Enviados Por E-mail.                    
                    </label>
                    <br>    
                    <label>
                        <input name="exportadaBanco" type="checkbox" id="exportadaBanco" <%=(Apoio.parseBoolean(exportadaBanco) ? "checked" : "")%>>
                        N&atilde;o Exportadas Para o Banco.                    
                    </label>
                    <br>
                    <label>
                        <input name="faturaImpressa" type="checkbox" id="faturaImpressa" <%=(Apoio.parseBoolean(faturaImpressa) ? "checked" : "")%>>
                        N&atilde;o Impressas.                    
                    </label>
                    <br/>
                    <label>
                        <input name="criadoPorMim" type="checkbox" id="criadoPorMim" <%=(Apoio.parseBoolean(criadoPorMim) ? "checked" : "")%> >
                        Criados Por Mim.                    
                    </label>
                </td>
                <td colspan="4">
                    Apenas a Conta:
                    <select name="conta" id="conta" style="width: 200 px" class="fieldMin" onChange="consultar('consultar')">
                        <option value="0" <%=(conta.equals("0") ? "selected" : "")%>>Todas</option>
                        <%while (rsconta.next()) {%>
                        <option value="<%=rsconta.getString("idconta")%>" <%=(conta.equals(rsconta.getString("idconta")) ? "selected" : "")%>>
                            <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%>
                        </option>
                        <%}%>
                    </select>
                    <br />
                    Apenas a situação:
                    <select name="situacaoFiltro" id="situacaoFiltro" style="width: 200 px" class="fieldMin"> 
                        <option value="" <%= situacaoFiltro.equals("") ? "selected" : ""%>>Todas</option>
                        <option value="NM" <%= situacaoFiltro.equals("NM")  ? "selected" : ""%>>Normal</option>
                        <option value="CA" <%= situacaoFiltro.equals("CA")  ? "selected" : ""%>>Cancelada</option>
                        <option value="CO" <%= situacaoFiltro.equals("CO")  ? "selected" : ""%>>Cortesia</option>
                        <option value="TC" <%= situacaoFiltro.equals("TC")  ? "selected" : ""%>>Cart&oacute;rio</option>
                        <option value="DT" <%= situacaoFiltro.equals("DT")  ? "selected" : ""%>>Descontada (Factoring)</option>
                        <option value="DE" <%= situacaoFiltro.equals("DE")  ? "selected" : ""%>>Devedora (Em Cobran&ccedil;a)</option>
                    </select>
                    
                </td>
                <td align="center">
                    Ordenação:
                    <select name="tipoOrdenacao" id="tipoOrdenacao" class="inputtexto">
                        <option value="">Padrão</option>
                        <option value="f">N° Fatura </option>
                        <option value="v">Vencimento </option>
                        <option value="e">Emissão </option>
                    </select> 
                </td>
            </tr>
        </table>
        <table width="95%" border="0" align="center" class="bordaFina">
            <tr class="tabela">
                <td width="2%"><input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcaTodos();"></td>
                <td width="1%"></td>
                <td width="10%">Fatura</td>
                <td width="8%">Emiss&atilde;o</td>
                <td width="26%">Cliente</td>
                <td width="9%">Vencimento</td>
                <td width="7%"><div align="right">Valor</div></td>
                <td width="7%"><div align="right">Acréscimo</div></td>
                <td width="7%"><div align="right">Desconto</div></td>
                <td width="7%"><div align="right">L&iacute;quido</div></td>
                <td width="8%">Status</td>
                <td width="3%">Sit.</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">Rem.</td>
                <td width="3%">&nbsp;</td>
            </tr>
            <%int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;
                double totalFatura = 0;
                double totalFaturaLiq = 0;

                if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                    conFat.setConexao(Apoio.getConnectionFromUser(request));
                    if (conFat.Consultar()) {
                        ResultSet r = conFat.getResultado();
                        while (r.next()) {
                            totalFatura += r.getDouble("valor");
                            totalFaturaLiq += (r.getDouble("valor_fatura") - r.getDouble("desconto_fatura"));
            %>           <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" style="<%=(r.getString("situacao").equals("CA") ? "color:red" : "")%>">
                                <td width="20">
                                    <input name="ck<%=linha%>" type="checkbox" value="<%=r.getInt("fatura_id")%>" id="ck<%=linha%>">
                                </td>
                                <td>
                                    <input type="hidden" id="numeroCTE_<%= r.getString("fatura_id") %>" name="numeroCTE_<%= r.getString("fatura_id") %>" value="<%= r.getString("numero_cte") %>">
                                    <input type="hidden" id="dataEmissaoCTE_<%= r.getString("fatura_id") %>" name="dataEmissaoCTE_<%= r.getString("fatura_id") %>" value="<%= r.getString("emissao_cte") %>">
                                    <input type="hidden" name="email_<%=r.getString("fatura_id")%>" id="email_<%=r.getString("fatura_id")%>" value="<%=r.getString("email")%>">
                                    <input type="hidden" name="idCliente_<%=r.getString("fatura_id")%>" id="idCliente_<%=r.getString("fatura_id")%>" value="<%=r.getString("idconsignatario")%>">
                                    <img src="img/plus.jpg" id="plus_<%=r.getString("fatura_id")%>" name="plus_<%=r.getString("fatura_id")%>" title="Mostrar duplicatas" class="imagemLink" align="right"
                                        onclick="javascript:viewCtrcs('<%=r.getString("fatura_id")%>');">
                                    <img src="img/minus.jpg" id="minus_<%=r.getString("fatura_id")%>" name="minus_<%=r.getString("fatura_id")%>" title="Mostrar duplicatas" class="imagemLink" align="right" style="display:none; "
                                        onclick="javascript:viewCtrcs('<%=r.getString("fatura_id")%>');">
                                </td>
                                <td>
                                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("fatura_id")%>);});">
                                        <%=r.getString("numero_fatura") + "/" + r.getString("ano_fatura")%>
                                        <input type="hidden" id="nomeFatura_<%=linha%>" name="nomeFatura_<%=linha%>" value="<%=r.getString("numero_fatura") + "/" + r.getString("ano_fatura")%>">
                                    </div>
                                    <%=r.getInt("lote_automatico") != 0 ? "Lote: " + r.getInt("lote_automatico") : ""%>
                                </td>
                                <td><%=fmt.format(r.getDate("emissao_fatura"))%></td>
                                <td><%=(r.getString("consignatario") == null ? "" : r.getString("consignatario"))%></td>
                                <td><%=(r.getDate("vencimento_fatura") != null ? fmt.format(r.getDate("vencimento_fatura")) : "C/ Apres.")%></td>
                                <td><div align="right"><%=new DecimalFormat("#,##0.00").format(r.getDouble("valor"))%></div></td>
                                <td><div align="right"><%=new DecimalFormat("#,##0.00").format(r.getDouble("acrescimo"))%></div></td>
                                <td><div align="right"><%=new DecimalFormat("#,##0.00").format(r.getDouble("desconto_fatura"))%></div></td>
                                <td><div align="right"><%=new DecimalFormat("#,##0.00").format(r.getDouble("valor_fatura") - r.getDouble("desconto_fatura"))%></div></td>
                                <td><label><%=(r.getBoolean("baixado") ? "Baixado" : r.getString("situacao").equals("CA") ? "Cancelado" : "Em Aberto")%></label>
                                    <input type="hidden" id="isBaixado_<%=linha%>" name="isBaixado_<%=linha%>" value="<%=r.getBoolean("baixado")%>">
                                </td>
                                
                                <td><%=r.getString("situacao")%></td>
                                <td align="center">
                                    <img src="img/out.png" id="naoEnviado_<%=r.getInt("fatura_id")%>" class="imagemLink"  title="Envia por e-mail a fatura selecionada" onClick="tryRequestToServer(function(){enviarEmail(<%=r.getInt("fatura_id")%>,<%=r.getInt("idconsignatario")%>,'<%=r.getString("consignatario")%>','<%=r.getString("consignatario_cgc")%>','<%=r.getString("email")%>','<%=r.getString("numero_fatura") + "/" + r.getString("ano_fatura")%>','<%=(r.getDate("vencimento_fatura") != null ? fmt.format(r.getDate("vencimento_fatura")) : "C/ Apres.")%>',<%=r.getBoolean("is_gera_boleto")%>,<%=r.getBoolean("baixado")%>);});" style="display:<%=(!r.getBoolean("is_boleto_enviado") ? "" : "none")%>">
                                    <img src="img/outc.png"  id="jaEnviado_<%=r.getInt("fatura_id")%>" class="imagemLink"  title="Reenvia por e-mail a fatura selecionada" onClick="tryRequestToServer(function(){enviarEmail(<%=r.getInt("fatura_id")%>,<%=r.getInt("idconsignatario")%>,'<%=r.getString("consignatario")%>','<%=r.getString("consignatario_cgc")%>','<%=r.getString("email")%>','<%=r.getString("numero_fatura") + "/" + r.getString("ano_fatura")%>','<%=(r.getDate("vencimento_fatura") != null ? fmt.format(r.getDate("vencimento_fatura")) : "C/ Apres.")%>', <%=r.getBoolean("is_gera_boleto")%>,<%=r.getBoolean("baixado")%>);});" style="display:<%=(r.getBoolean("is_boleto_enviado") ? "" : "none")%>">
                                </td>
                                <td align="center">
                                    <img width="20px" height="20px" src="img/bnb.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("004") ? "" : "none")%>">
                                    <img src="img/real.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("356") ? "" : "none")%>">
                                    <img src="img/bb.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("001") ? "" : "none")%>">
                                    <img src="img/caixa.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("104") ? "" : "none")%>">
                                    <img src="img/bradesco.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("237") ? "" : "none")%>">
                                    <img src="img/unibanco.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("409") ? "" : "none")%>">
                                    <img src="img/itau.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("341") ? "" : "none")%>">
                                    <img src="img/santander.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("033") ? "" : "none")%>">
                                    <img src="img/hsbc.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("399") ? "" : "none")%>">
                                    <img src="img/daycoval.png" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("707") ? "" : "none")%>">
                                    <img src="img/sicoob.png" width="30" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("756") ? "" : "none")%>">
                                </td>
                                <td align="center" >
                                    <%=(r.getBoolean("is_gera_boleto") ? (r.getInt("sequencial_remessa") != 0 ? "Sim" : "Não") : "")%>
                                </td>
                                <td align="center">
                                    <% if ((nivelUser == 4) && (r.getBoolean("pode_excluir"))) {
                                    %>    <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                                               onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("fatura_id")%>);});">
                                    <% }
                                    %> 
                                </td>
                            </tr>
                            <tr style="display:none" id="trfat_<%=r.getString("fatura_id")%>" name="trfat_<%=r.getString("fatura_id")%>">
                                <td rowspan="1" class='CelulaZebra1'></td>
                                <td rowspan="1" colspan="15">--</td>
                            </tr>

            <%
                            if (r.isLast()) {
                                linhatotal = r.getInt("qtde_linhas");
                            }
                          linha++;
                        }

                        int limit = conFat.getLimiteResultados();
                        qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                    }
                }
            %>
            <tr class="tabela">
                <td colspan="4" align="center">
                    <%if(nivelCobranca == NivelAcessoUsuario.CONTROLE_TOTAL.getNivel()){%>
                        <label>Enviar Cobrança</label>
                        <img src="img/out.png" id="" class="imagemLink"  title="Enviar e-mail de cobrança" 
                             onClick="javascript:tryRequestToServer(function(){enviarFaturasEmailCobranca()();});">
                    <%}%>
                </td>
                <td colspan="1" align="right">
                    Total:
                </td>
                <td colspan="2" align="right">                    
                    <%=new DecimalFormat("#,##0.00").format(totalFatura)%>                    
                </td>
                <td colspan="3" align="right">
                    <%=new DecimalFormat("#,##0.00").format(totalFaturaLiq)%>
                </td>
                <td colspan="2">
                    <div align="right">Enviar em lote:</div>
                </td>
                <td colspan="1">
                    <div align="center">
                        <img src="img/out.png" id="" class="imagemLink"  title="Envia e-mail todas os boletos selecionados" onClick="javascript:tryRequestToServer(function(){enviarFaturasEmails();});">
                    </div>
                </td>
                <td colspan="3">
                    <div align="right"></div>
                </td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td class="CelulaZebra1" colspan="">
                </td>
                <td class="CelulaZebra1" colspan="3">
                    <div align="center" >
                        Formato da Impress&atilde;o:
                        <input type="radio" name="impressao" id="impressao_1" onClick="setIcone(this.value)" border="0" value="1" checked/>
                        <img src="img/pdf.gif" style="vertical-align: middle" >
                        <input type="radio" name="impressao" id="impressao_2" onClick="setIcone(this.value)" border="0" value="2" />
                        <img src="img/excel.gif"  style="vertical-align: middle">
                        <!--<input type="radio" name="impressao" id="impressao_3" onClick="setIcone(this.value)" border="0" value="3" />-->
                        <!--<img src="img/ie.gif"  style="vertical-align: middle">-->
                        <input type="radio" name="impressao" id="impressao_3" onClick="setIcone(this.value)" border="0" value="3" />
                        <img src="img/word.gif"  style="vertical-align: middle">
                    </div>
                </td>
                
                <td colspan="2"  align="center">
                    <div align="right">Modelo de impress&atilde;o em PDF:
                        <select name="cbmodelo" id="cbmodelo" class="fieldMin" style="width: 80px;">
                            <option value="1" <%=configuracao.getRelDefaultFatura().equals("1") ? "selected" : ""%>>Modelo 1</option>
                            <option value="2" <%=configuracao.getRelDefaultFatura().equals("2") ? "selected" : ""%>>Modelo 2</option>
                            <option value="3" <%=configuracao.getRelDefaultFatura().equals("3") ? "selected" : ""%>>Modelo 3</option>
                            <option value="4" <%=configuracao.getRelDefaultFatura().equals("4") ? "selected" : ""%>>Modelo 4</option>
                            <option value="5" <%=configuracao.getRelDefaultFatura().equals("5") ? "selected" : ""%>>Modelo 5</option>
                            <option value="6" <%=configuracao.getRelDefaultFatura().equals("6") ? "selected" : ""%>>Modelo 6</option>
                            <option value="7" <%=configuracao.getRelDefaultFatura().equals("7") ? "selected" : ""%>>Modelo 7</option>
                            <option value="8" <%=configuracao.getRelDefaultFatura().equals("8") ? "selected" : ""%>>Modelo 8</option>
                            <option value="9" <%=configuracao.getRelDefaultFatura().equals("9") ? "selected" : ""%>>Modelo 9</option>
                            <option value="10" <%=configuracao.getRelDefaultFatura().equals("10") ? "selected" : ""%>>Modelo 10</option>
                            <option value="11" <%=configuracao.getRelDefaultFatura().equals("11") ? "selected" : ""%>>Modelo 11 (Container)</option>
                            <option value="12" <%=configuracao.getRelDefaultFatura().equals("12") ? "selected" : ""%>>Modelo 12</option>
                            <option value="13" <%=configuracao.getRelDefaultFatura().equals("13") ? "selected" : ""%>>Modelo 13 (Apenas NFS)</option>
                            <%for (String rel : Apoio.listFaturas(request)) {%>
                                <option value="doc_fatura_personalizado_<%=rel%>" <%=configuracao.getRelDefaultFatura().startsWith("doc_fatura_personalizado_"+rel) ? "selected" : ""%> >Modelo <%=rel.toUpperCase() %></option>
                            <%}%>
                        </select>
                    </div>
                </td>
                <td>
                    <div align="center">
                        <img src="img/pdf.jpg" width="25" id="imprimirPDF" height="25" border="0" class="imagemLink" title="Formato PDF(usado para a impress&atilde;o)"
                             onClick="javascript:tryRequestToServer(function(){popFatura('1');});">
                        <img src="img/excel.gif" width="25" id="imprimirEXCEL" height="25" border="0" class="imagemLink" title="Formato EXCEL"
                             onClick="javascript:tryRequestToServer(function(){popFatura('2');});" style="display : none">
                        <img src="img/word.gif" width="25" id="imprimirWORD" height="25" border="0" class="imagemLink" title="Formato EXCEL"
                             onClick="javascript:tryRequestToServer(function(){popFatura('3');});" style="display : none">
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td height="21"><div align="center">Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b></div></td>
                <td width="10%" rowspan="2" align="center">
                    <input name="avancar" type="button" class="botoes" id="avancar"
                           value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
                    <br>
                    <%if (conFat.getPaginaResultados() < qtde_pag) {%>
                    <input name="avancar" type="button" class="botoes" id="avancar"
                           value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
                    <%}%>
                </td>
                <td align="center" colspan="2">
                </td>
                <td align="center" colspan="3">
                    <input type="button" class="botoes" value="Imprimir Boletos" onClick="javascript:tryRequestToServer(function(){popBoleto('');});" >
                    <select name="modeloBoleto" id="modeloBoleto" class="fieldMin">
                        <option value="1" <%=configuracao.getRelDefaultBoleto().equals("1") ? "selected" : ""%>>Modelo 1</option>
                        <option value="2" <%=configuracao.getRelDefaultBoleto().equals("2") ? "selected" : ""%>>Modelo 2</option>
                        <option value="3" <%=configuracao.getRelDefaultBoleto().equals("3") ? "selected" : ""%>>Modelo 3</option>
                        <option value="4" <%=configuracao.getRelDefaultBoleto().equals("4") ? "selected" : ""%>>Modelo 4</option>
                        <option value="5" <%=configuracao.getRelDefaultBoleto().equals("5") ? "selected" : ""%>>Modelo 5</option>
                        <option value="6" <%=configuracao.getRelDefaultBoleto().equals("6") ? "selected" : ""%>>Modelo 6</option>
                        <option value="7" <%=configuracao.getRelDefaultBoleto().equals("7") ? "selected" : ""%>>Modelo 7</option>
                        <option value="8" <%=configuracao.getRelDefaultBoleto().equals("8") ? "selected" : ""%>>Modelo 8</option>
                        <option value="9" <%=configuracao.getRelDefaultBoleto().equals("9") ? "selected" : ""%>>Modelo 9</option>
                        <option value="10" <%=configuracao.getRelDefaultBoleto().equals("10") ? "selected" : ""%>>Modelo 10</option>
                        <option value="11" <%=configuracao.getRelDefaultBoleto().equals("11") ? "selected" : ""%>>Modelo 11</option>
                        
                        <% for (String rel: Apoio.listBoleto(request)){%>
                        
                        <option value="personalizado_<%=rel%>" <%=configuracao.getRelDefaultBoleto().startsWith("boleto_personalizado_") ? "selected" : ""%> > Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                    
                        <%}%>
                    </select>
                </td>
            </tr>
            <tr class="celula">
                <td width="20%" height="22">
                    <center>
                        P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : conFat.getPaginaResultados())%> / <%=qtde_pag%></b>        
                    </center>
                </td>
                <td width="16%" align="center"><div align="right">Impressora:</div></td>
                <td width="14%" align="center">
                    <span class="CelulaZebra2">
                        <select name="caminho_impressora" id="caminho_impressora" class="fieldMin">
                            <option value="">&nbsp;&nbsp;</option>
                            <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                                impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                                if (impressoras.Consultar()) {
                                    ResultSet rs = impressoras.getResultado();
                                    while (rs.next()) {%>
                            <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora()) ? "selected" : "")%>><%=rs.getString("descricao")%></option>
                            <%}%>
                            <%}%>
                        </select>
                    </span>
                </td>
                <td width="9%" align="center"><div align="right">Driver:</div></td>
                <td width="27%" align="center">
                    <div align="left">
                        <select name="driverImpressora" id="driverImpressora" class="fieldMin">
                            <% Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "fat.txt");
                                for (int i = 0; i < drivers.size(); ++i) {
                                    String driv = (String) drivers.get(i);
                                    driv = driv.substring(0, driv.lastIndexOf("."));
                            %>
                            <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                            <%}%>
                        </select>
                    </div>
                </td>
                <td width="4%" align="right">
                    <div align="center">
                        <img src="img/ctrc.gif" class="imagemLink" title="Imprimir Faturas selecionados" onClick="tryRequestToServer(function(){exportarTextoMatricial();});"> 
                    </div>
                </td>
            </tr>
            <tr class="celula" >
                <td  height="22" colspan="3">
                    <div align="center">
                        <input name="chkSped" type="checkbox" id="chkSped" value="checkbox">
                        Gerar o Campo Nota Fiscal Com 9 D&iacute;gitos (SPED). 
                    </div>
                </td>
                <td  align="right">Exportar Para:</td>
                <td  align="left" colspan="2">
                    <select name="versaoDOCCOB" id="versaoDOCCOB" class="fieldMin" style="width:'250px';"></select>
                    <input name="exportar" type="button" class="botoes" id="exportar"
                        value="OK"  onClick="javascript:tryRequestToServer(function(){exportarEDI();});">
                </td>
                <td  align="right">
                    <div align="center"></div>
                </td>
            </tr>
        </table>
    </body>
</html>
