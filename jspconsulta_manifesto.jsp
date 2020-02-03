<%@page import="java.lang.Double"%>
<%@page import="br.com.gwsistemas.configuracao.email.caixaSaida.CaixaSaida"%>
<%@page import="br.com.gwsistemas.configuracao.email.caixaSaida.CaixaSaidaBO"%>
<%@page import="nucleo.Conexao"%>
<%@page import="java.sql.Connection"%>
<%@page import="net.sf.jasperreports.engine.JasperRunManager"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.OutputStream"%>
<%@page import="conhecimento.BeanCadConhecimento"%>
<%@page import="conhecimento.manifesto.conferencia.ConferenciaBO"%>
<%@page import="java.text.DateFormat"%>
<%@page import="conhecimento.manifesto.conferencia.Conferencia"%>
<%@page import="java.io.File"%>
<%@page import="java.util.Collection"%>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
     import="java.sql.ResultSet,conhecimento.manifesto.*,nucleo.Apoio,nucleo.BeanConfiguracao,usuario.BeanUsuario,nucleo.BeanLocaliza,java.text.SimpleDateFormat,java.util.Date,java.util.Vector,nucleo.impressora.*" %>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    BeanUsuario autenticado = Apoio.getUsuario(request);
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadmanifesto") : 0);
    int nivelUserCf = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lancartafrete") : 0);
    int nivelUserToFilial = (nivelUser > 0 ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg = (BeanConfiguracao) request.getSession().getServletContext().getAttribute("configuracao");
    
    boolean isCiot = false;
    
    char roteirizador = Apoio.getUsuario(request).getFilial().getStUtilizacaoBuonnyRoteirizador();
    
//Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String filial = "";
    String motorista = "";
    String idMotorista = "0";
    String veiculo = "";
    String idVeiculo = "0";
    String carreta = "";
    String idCarreta = "0";
    String ordenacao = "";
    String tipoOrdenacao = "";
    StringBuilder condicaoConsulta = new StringBuilder();   
    String tipoTransporte = "(";

    String operadorConsulta = "";
    String limiteResultados = "";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;
    
    //18/12/2014
    String companhiaAerea = "";
    String idCompanhiaAerea = "0";
    String aeroportoOrigem = "";
    String idAeroportoOrigem = "0";
    String aeroportoDestino = "";
    String idAeroportoDestino = "0";
    String representanteDestino = "";
    String idRepresentanteDestino = "0";
    
    //22/01/2015
    String chkManifestoCriados = "false";
    String idManifestoCriados = "0";
    
    boolean chkAereo = false;
    boolean chkAquaviario = false;
    boolean chkRodoviario = false;
    
    String preManifesto = "a";
    
    //22/03/2016
    String rotaId = "0";
    String rotaDesc = "";
    
    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaManifesto")) {
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
            consulta = new Cookie("consultaManifesto", "");
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
        

        String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
        String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
        String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
        String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
        String fl = (consulta.getValue().equals("") ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : consulta.getValue().split("!!")[4]);
        String mot = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 6 ? "" : consulta.getValue().split("!!")[5]);
        String idMot = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 7 ? "0" : consulta.getValue().split("!!")[6]);
        String vei = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 8 ? "" : consulta.getValue().split("!!")[7]);
        String idVei = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 9 ? "0" : consulta.getValue().split("!!")[8]);
        String car = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 10 ? "" : consulta.getValue().split("!!")[9]);
        String idCar = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 11 ? "0" : consulta.getValue().split("!!")[10]);
        String ord = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 12 ? "nmanifesto" : consulta.getValue().split("!!")[11]);
        String tipoOrd = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 13 ? "" : consulta.getValue().split("!!")[12]);
        //o index 13 é tipo transporte.
        String companhiaAer = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 15 ? "" : consulta.getValue().split("!!")[14]);
        String idCompanhiaAer = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 16 ? "0" : consulta.getValue().split("!!")[15]);
        String aeroportoOrige = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 17 ? "" : consulta.getValue().split("!!")[16]);
        String idAeroportoOrige = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 18 ? "0" : consulta.getValue().split("!!")[17]);
        String aeroportoDest = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 19 ? "" : consulta.getValue().split("!!")[18]);
        String idAeroportoDest = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 20 ? "0" : consulta.getValue().split("!!")[19]);
        String representanteDest = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 21 ? "" : consulta.getValue().split("!!")[20]);
        String idRepresentanteDest = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 22 ? "0" : consulta.getValue().split("!!")[21]); 
        String chkCriadosPorMim =  (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 24 ? "false" : consulta.getValue().split("!!")[23]); 
        String slcPreManifesto =  (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 25 ? "a" : consulta.getValue().split("!!")[24]); 
        String rotasid = (consulta.getValue() == null || consulta.getValue().equals("") || consulta.getValue().split("!!").length < 26 ? "0" : consulta.getValue().split("!!")[25]); 
        String rotasdesc = (consulta.getValue() == null || consulta.getValue().equals("") || consulta.getValue().split("!!").length < 27 ? "" : consulta.getValue().split("!!")[26]); 
        
        
        valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
        dataInicial = (request.getParameter("dtsaida1") != null ? request.getParameter("dtsaida1") : (dt1));
        dataFinal = (request.getParameter("dtsaida2") != null ? request.getParameter("dtsaida2") : (dt2));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : (mot));
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : (idMot));
        veiculo = (request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : (vei));
        idVeiculo = (request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : (idVei));
        carreta = (request.getParameter("car_placa") != null ? request.getParameter("car_placa") : (car));
        idCarreta = (request.getParameter("idcarreta") != null ? request.getParameter("idcarreta") : (idCar));
        ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : (ord));
        tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : (tipoOrd));
        companhiaAerea = (request.getParameter("companhia_aerea") != null ? request.getParameter("companhia_aerea") : (companhiaAer));       
        idCompanhiaAerea = (request.getParameter("idcompanhia") != null ? request.getParameter("idcompanhia") : (idCompanhiaAer));
        aeroportoOrigem = (request.getParameter("aeroporto_origem") != null ? request.getParameter("aeroporto_origem") : (aeroportoOrige));
        idAeroportoOrigem = (request.getParameter("aeroporto_origem_id") != null ? request.getParameter("aeroporto_origem_id") : (idAeroportoOrige));
        aeroportoDestino = (request.getParameter("aeroporto_destino") != null ? request.getParameter("aeroporto_destino") : (aeroportoDest));
        idAeroportoDestino = (request.getParameter("aeroporto_destino_id") != null ? request.getParameter("aeroporto_destino_id") : (idAeroportoDest));
        representanteDestino = (request.getParameter("redspt_rzs") != null ? request.getParameter("redspt_rzs") : (representanteDest));
        idRepresentanteDestino = (request.getParameter("idredespachante") != null ? request.getParameter("idredespachante") : (idRepresentanteDest));
        rotaId = (request.getParameter("rota_id") != null ? request.getParameter("rota_id") : (rotasid));
        rotaDesc = (request.getParameter("rota_desc") != null ? request.getParameter("rota_desc") : (rotasdesc));
        
         
        
        
        chkAereo = Apoio.parseBoolean(request.getParameter("chkAereo"));
        chkAquaviario = Apoio.parseBoolean(request.getParameter("chkAquaviario"));
        chkRodoviario = Apoio.parseBoolean(request.getParameter("chkRodoviario"));
        
        //16/01/2015
        chkManifestoCriados = (request.getParameter("chkManifestoCriados") != null ? request.getParameter("chkManifestoCriados") : (chkCriadosPorMim));        
        
        preManifesto = (request.getParameter("slcPreManifesto") != null ? request.getParameter("slcPreManifesto") : (slcPreManifesto));
        
        
        
        if(chkAereo){
        tipoTransporte += ",'a'";
    
        }
        if(chkAquaviario){
            tipoTransporte += ",'f'";    
        }
        if(chkRodoviario){
            tipoTransporte += ",'m'";
        }   
        if(!tipoTransporte.equals("")){            
            tipoTransporte = tipoTransporte.replaceFirst(",", "");
            tipoTransporte += ")";            
        }
       
        
        campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                ? request.getParameter("campo")
                : (campo.equals("") ? "dtsaida" : campo));
        operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                ? request.getParameter("ope")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                ? request.getParameter("limite")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" 
                + filial + "!!" + motorista + "!!" + idMotorista + "!!" + veiculo + "!!" + idVeiculo + "!!" 
                + carreta + "!!" + idCarreta + "!!" + ordenacao + "!!" + tipoOrdenacao + "!!" + tipoTransporte + "!!" 
                + companhiaAerea + "!!" + idCompanhiaAerea + "!!" + aeroportoOrigem + "!!" + idAeroportoOrigem + "!!" 
                + aeroportoDestino + "!!" + idAeroportoDestino + "!!" + representanteDestino + "!!" + idRepresentanteDestino + "!!"
                + idManifestoCriados + "!!"+ chkManifestoCriados+ "!!" + preManifesto + "!!");  //fazer alteração no beanConsultaManifesto     
        
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
    } else {
        campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                ? request.getParameter("campo") : "dtsaida");
        dataInicial = (request.getParameter("dtsaida1") != null ? request.getParameter("dtsaida1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtsaida2") != null ? request.getParameter("dtsaida2") : fmt.format(new Date()));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "");
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0");
        veiculo = (request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "");
        idVeiculo = (request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : "0");
        carreta = (request.getParameter("car_placa") != null ? request.getParameter("car_placa") : "");
        idCarreta = (request.getParameter("idcarreta") != null ? request.getParameter("idcarreta") : "0");
        ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : "nmanifesto");
        tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : "");
        valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("")
                ? request.getParameter("valor") : "");
        operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                ? request.getParameter("ope") : "1");
        limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                ? request.getParameter("limite") : "10"); 
        companhiaAerea = (request.getParameter("companhia_aerea") != null ? request.getParameter("companhia_aerea") : "");
        idCompanhiaAerea = (request.getParameter("idcompanhia") != null ? request.getParameter("idcompanhia") : "0");
        aeroportoOrigem = (request.getParameter("aeroporto_origem") != null ? request.getParameter("aeroporto_origem") : "");
        idAeroportoOrigem = (request.getParameter("aeroporto_origem_id") != null ? request.getParameter("aeroporto_origem_id") : "0");
        aeroportoDestino = (request.getParameter("aeroporto_destino") != null ? request.getParameter("aeroporto_destino") : "");
        idAeroportoDestino = (request.getParameter("aeroporto_destino_id") != null ? request.getParameter("aeroporto_destino_id") : "0"); 
        representanteDestino = (request.getParameter("redspt_rzs") != null ? request.getParameter("redspt_rzs") : "");
        idRepresentanteDestino = (request.getParameter("idredespachante") != null ? request.getParameter("idredespachante") : "0");
        chkManifestoCriados = (request.getParameter("chkManifestoCriados") != null ? request.getParameter("chkManifestoCriados") : "false");
        preManifesto = (request.getParameter("slcPreManifesto") != null ? request.getParameter("slcPreManifesto") : "a");
        rotaId = (request.getParameter("rota_id") != null ? request.getParameter("rota_id") : "0");
        rotaDesc = (request.getParameter("rota_desc") != null ? request.getParameter("rota_desc") : "");
        
    }
//Finalizando Cookie

%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaManifesto beanManif = null;
    String acao = request.getParameter("acao");
    String id = request.getParameter("campo");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    int pag = Apoio.parseInt((request.getParameter("pag") != null ? request.getParameter("pag") : "1"));
    //Parametro para mostrar somente manifestoss da 
    //filial do usuario logado(se false e usuario poder lancar conh p/ outras filiais 
    //entao mostra todos os manifestos de todas as filiais)
    boolean esta_filial = (request.getParameter("esta_filial") != null ? request.getParameter("esta_filial").equals("true") : true);
    boolean lanca_conh_fl = Apoio.getUsuario(request).getAcesso("lanconhfl") > 0;

    if (acao.equals("iniciar")) {
        acao = "consultar";
        pag = 1;
    }

    if ((acao.equals("consultar")) || (acao.equals("proxima"))) {   //instanciando o bean
        beanManif = new BeanConsultaManifesto();
        beanManif.setConexao(Apoio.getUsuario(request).getConexao());
        beanManif.setCampoDeConsulta(campoConsulta);
        beanManif.setOperador(Apoio.parseInt(operadorConsulta));
        beanManif.setValorDaConsulta(valorConsulta);
        beanManif.setLimiteResultados(Apoio.parseInt(limiteResultados));
        BeanUsuario usu = Apoio.getUsuario(request);
        beanManif.setExecutor(usu);
        //Se o usuario tiver permissao para lancar conh para outras filiais entao 
        //ele pode visualizar os conh. das outras(quando for 0 vai mostrar todas)
        beanManif.setIdFilialManifesto(Apoio.parseInt(filial));
        beanManif.setDtSaida1(Apoio.paraDate(dataInicial));
        beanManif.setDtsaida2(Apoio.paraDate(dataFinal));
        beanManif.getMotorista().setIdmotorista(Apoio.parseInt(idMotorista));
        beanManif.getVeiculo().setIdveiculo(Apoio.parseInt(idVeiculo));
        beanManif.getCarreta().setIdveiculo(Apoio.parseInt(idCarreta));
        beanManif.setOrdenacao(ordenacao + " " + tipoOrdenacao);
        beanManif.setTipo(tipoTransporte);
        beanManif.setPaginaResultados(pag);
        beanManif.getComponhiaAereaManifesto().setIdfornecedor(Apoio.parseInt(idCompanhiaAerea));
        beanManif.getAeroportoOrigemManifesto().setId(Apoio.parseInt(idAeroportoOrigem));
        beanManif.getAeroportoDestinoManifesto().setId(Apoio.parseInt(idAeroportoDestino));
        beanManif.getRepresentanteDestinoManifesto().setIdfornecedor(Apoio.parseInt(idRepresentanteDestino));
        beanManif.setManifestoCriadosPorMim(Apoio.parseBoolean(chkManifestoCriados));
        beanManif.setPreManifesto(preManifesto);
        beanManif.getRota().setId(Apoio.parseInt(rotaId));
        beanManif.getRota().setDescricao(rotaDesc);
        // a chamada do método Consultar() está lá em mbaixo
    }
    if(acao.equals("importar") && !id.equals("")){
        String url = "importar_conferencia.jsp";
        response.sendRedirect(url);
    }
        

    //se o usuario tiver permissao de excluir  
    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null)) {
        BeanCadManifesto cadManif = new BeanCadManifesto();
        cadManif.setConexao(Apoio.getUsuario(request).getConexao());
        cadManif.setExecutor(Apoio.getUsuario(request));
        cadManif.getManifesto().setIdmanifesto(Apoio.parseInt(request.getParameter("id")));
%><script language="javascript"><% 
            if (!cadManif.Deleta()) {
    %>alert("Erro ao tentar excluir!");<%                }
    %>location.replace("./consultamanifesto?acao=iniciar");
</script><%

            }

            //exportacao do manifesto para arquivo .pdf
            if (acao.equals("exportar") && request.getParameter("id") != null) {
                java.util.Map param = new java.util.HashMap(20);          
                
                String idManifesto = request.getParameter("id");
                
                param.put("IDMANIFESTO", idManifesto);
                String model = request.getParameter("modelo");
                String modeloMinuta = request.getParameter("modeloMinuta");
                if (model.indexOf("personalizado") > -1) {
                   String relatorio = model;
                   request.setAttribute("map", param);
                   request.setAttribute("rel",relatorio);                     
                }else{
                   request.setAttribute("map", param);
                   if(model.equals("16")) {
                       request.setAttribute("rel", "manifestomod16_" + modeloMinuta);
                   } else {
                       request.setAttribute("rel", "manifestomod" + model);
                   }
                }
                
                param.put("USUARIO", Apoio.getUsuario(request).getNome());
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                
                RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
                dispatcher.forward(request, response);
                
            }

            if (acao.equals("exportarSeparacao") && request.getParameter("id") != null) {
                java.util.Map param = new java.util.HashMap(1);
                param.put("IDMANIFESTO", request.getParameter("id"));
                request.setAttribute("map", param);
                request.setAttribute("rel", "guia_separacao_mod" + request.getParameter("modelo"));

                RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
                dispatcher.forward(request, response);
            }

            if (acao.equals("enviarEmail")) {
                    //Enviando e-mail para os clientes
                    EnviaEmail m = new EnviaEmail();

                    m.setCon(Apoio.getUsuario(request).getConexao());
                    m.carregaCfg();
                    BeanConsultaConhecimento ct = new BeanConsultaConhecimento();
                    ct.setConexao(Apoio.getUsuario(request).getConexao());
                    ct.setExecutor(Apoio.getUsuario(request));
                    ct.consultarCtrcEmail(request.getParameter("idManif"), 1, "");
                    ResultSet rsCt = ct.getResultado();
                    String msg = "";
                    String msgErro = "";
                    boolean deuCerto = true;

                    BeanCadConhecimento cadconh = new BeanCadConhecimento();
                    cadconh.setExecutor(Apoio.getUsuario(request));
                    cadconh.setConexao(Apoio.getUsuario(request).getConexao());
                    while (rsCt.next()) {
                        String texto = cfg.getMensagemManifesto();
                        texto = texto.replaceAll("@@nome_cliente", rsCt.getString("cliente"));
                        texto = texto.replaceAll("@@cnpj_cliente", rsCt.getString("cnpj_cliente"));
                        texto = texto.replaceAll("@@nota_fiscal", rsCt.getString("notas"));
                        texto = texto.replaceAll("@@emissao_ctrc", fmt.format(rsCt.getDate("emissao_em")));
                        texto = texto.replaceAll("@@previsao_entrega", (rsCt.getDate("previsao_entrega_em") == null ? "" : fmt.format(rsCt.getDate("previsao_entrega_em"))));
                        texto = texto.replaceAll("@@nome_transportadora", Apoio.getUsuario(request).getFilial().getRazaosocial());
                        texto = texto.replaceAll("@@ctrc", rsCt.getString("ctrc"));
                        texto = texto.replaceAll("@@remetente", rsCt.getString("remetente"));
                        texto = texto.replaceAll("@@destinatario", rsCt.getString("destinatario"));
                        //Novos a partir 24/09/2009
                        texto = texto.replaceAll("@@volume", rsCt.getString("tot_volume"));
                        texto = texto.replaceAll("@@peso", rsCt.getString("tot_peso"));
                        texto = texto.replaceAll("@@valor_mercadoria", rsCt.getString("tot_valor"));
                        //novo campo a partir 28/01/2010
                        texto = texto.replaceAll("@@valor_frete", rsCt.getString("valor_frete"));
                        texto = texto.replaceAll("@@cidade_destino", rsCt.getString("cidade_destinatario"));
                        msg = texto;
                        m.setAssunto("CTRC Manifestado - Mensagem automática da " + Apoio.getUsuario(request).getFilial().getRazaosocial());
                        m.setMensagem(msg);
                        m.setPara(rsCt.getString("email"));
//                      String extensao = file.toString().substring((file.toString().lastIndexOf(".")) + 1);
                        CaixaSaida caixaSaida = new CaixaSaida();
                        CaixaSaidaBO caixaSaidaBO = new CaixaSaidaBO();
                        String mensagemEnvio = "";
                        //condição para verificar se vai ser enviado os emails pela caixa de saída, caso seja true.
                        if (!cfg.getIsEnviarEntreHorario() && cfg.getPreferenciaEnvioEmail().equals("a")) {
                            deuCerto = m.EnviarEmail();
                            if (!deuCerto) {
                                // nao possui anexo
                                mensagemEnvio = "r";
                                msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\r\n"
                                        + "Cliente: " + rsCt.getString("cliente") + "\r\n"
                                        + "CTRC: " + rsCt.getString("ctrc") + "\r\n";
                            } else {
                                cadconh.atualizarEnviarEmail(String.valueOf(rsCt.getInt("ctrc_id")), 1);
                                mensagemEnvio = "e";
                            }
                        } else {
                            mensagemEnvio = "p";
                        }
                        
                        caixaSaida = caixaSaida.converterEnvioEmailParaCaixaSaida(m, Apoio.getUsuario(request), m.getCfg().getEmailEntrega().getId(), mensagemEnvio);
                        caixaSaidaBO.salvarEmailCaixaSaida(caixaSaida, Apoio.getUsuario(request));

                    }
                    rsCt.close();
                    //Fim enviando e-mail

                    if (!msgErro.equals("")) {
                        response.getWriter().append(msgErro);
                    } else {
                        response.getWriter().append("load=0");
                    }
                    response.getWriter().close();
                }
    
            if (acao.equals("enviarEmailManifestoRepresentante")) {

                    java.util.Map param = new java.util.HashMap(1);
                    param.put("IDMANIFESTO", request.getParameter("idManif"));
                    param.put("USUARIO", Apoio.getUsuario(request).getNome());

                    File relfile = null;
                    
                    if (request.getParameter("modelo").indexOf("doc_manifesto_personalizado") > -1) {
                        relfile = new File(nucleo.Apoio.getDirHome() + "/WEB-INF/jreport" + File.separator + request.getParameter("modelo") + ".jasper");
                    }else{
                        relfile = new File(nucleo.Apoio.getDirHome() + "/WEB-INF/jreport" + File.separator + "manifestomod" + request.getParameter("modelo") + ".jasper");
                    }
                    

                    byte[] b = null;
                    Connection con = Conexao.getConnection();
                    try {
                        b = JasperRunManager.runReportToPdf(relfile.getAbsolutePath(), param, con);
                    } finally {
                        if (con != null && !con.isClosed()) {
                            con.close();
                        }
                    }
                    OutputStream output = null;

                    File file = new File(nucleo.Apoio.getDirHome() + "/WEB-INF/jreport" + File.separator + "manifestomod" + request.getParameter("modelo") + ".pdf");
                    output = new FileOutputStream(file);
                    output.write(b);
                    output.flush();
                    output.close();

                    EnviaEmail m = new EnviaEmail();

                    m.setCon(Apoio.getUsuario(request).getConexao());
                    m.carregaCfg();
                    BeanConsultaManifesto bcm = new BeanConsultaManifesto();
                    bcm.setConexao(Apoio.getUsuario(request).getConexao());
                    bcm.setExecutor(Apoio.getUsuario(request));
                    bcm.consultarEmailManifestoRepresentante(Apoio.parseInt(request.getParameter("idManif")));
                    ResultSet rsBcm = bcm.getResultado();

                    String msg = "";
                    String msgErro = "";
                    String msgSucesso = "";
                    boolean deuCerto = true;

                    BeanCadManifesto cadMani = new BeanCadManifesto();
                    cadMani.setConexao(Apoio.getUsuario(request).getConexao());
                    cadMani.setExecutor(Apoio.getUsuario(request));

                    while (rsBcm.next()) {
                        String texto = cfg.getMensagemManifestoRepresentante();
                        texto = texto.replaceAll("@@transportadora", rsBcm.getString("transportadora") != null ? rsBcm.getString("transportadora") : "");
                        texto = texto.replaceAll("@@representante", rsBcm.getString("repre_destino") != null ? rsBcm.getString("repre_destino") : "");
                        texto = texto.replaceAll("@@origem", rsBcm.getString("cidade_origem") != null ? rsBcm.getString("cidade_origem") : "");
                        texto = texto.replaceAll("@@destino", rsBcm.getString("cidade_destino") != null ? rsBcm.getString("cidade_destino") : "");
                        texto = texto.replaceAll("@@peso", rsBcm.getString("peso_total") != null ? rsBcm.getString("peso_total") : "");
                        texto = texto.replaceAll("@@volumes", rsBcm.getString("volume_total") != null ? rsBcm.getString("volume_total") : "");
                        texto = texto.replaceAll("@@valor_mercadoria", rsBcm.getString("valor_mercadoria") != null ? rsBcm.getString("valor_mercadoria") : "");
                        texto = texto.replaceAll("@@emissao", rsBcm.getString("emissao") != null ? fmt.format(rsBcm.getDate("emissao")) : "");
                        texto = texto.replaceAll("@@chegada", rsBcm.getString("previsao_chegada") != null ? fmt.format(rsBcm.getDate("previsao_chegada")) : "");
                        texto = texto.replaceAll("@@voo", rsBcm.getString("numero_voo") != null ? rsBcm.getString("numero_voo") : "");
                        texto = texto.replaceAll("@@cia_aerea", rsBcm.getString("campanhia_aerea") != null ? rsBcm.getString("campanhia_aerea") : "");

                        msg = texto;

                        m.setAssunto("Pré-Alerta p/ Representante - Mensagem automática da " + Apoio.getUsuario(request).getFilial().getRazaosocial());
                        m.setMensagem(msg);
                        if (rsBcm.getString("tipo_destino").equals("rd")) {
                            m.setPara(rsBcm.getString("email"));
                        } else if (rsBcm.getString("tipo_destino").equals("fl")) {
                            m.setPara(rsBcm.getString("email_pre_alerta"));
                        }
                        m.setAnexo(file);
                        String extensao = file.toString().substring((file.toString().lastIndexOf(".")) + 1);
                        CaixaSaida caixaSaida = new CaixaSaida();
                        CaixaSaidaBO caixaSaidaBO = new CaixaSaidaBO();
                        String mensagemEnvio = "";
                        //condição para verificar se vai ser enviado os emails pela caixa de saída, caso seja true.
                        if (!cfg.getIsEnviarEntreHorario() && cfg.getPreferenciaEnvioEmail().equals("a")) {
                            deuCerto = m.EnviarEmail();
                            if (!deuCerto) {
                                mensagemEnvio = "r";
                                msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\r\n"
                                        + "Representante: " + rsBcm.getString("repre_destino") + "\r\n"
                                        + "Manifesto: " + rsBcm.getString("numero_manifesto") + "\r\n";
                            } else {
                                mensagemEnvio = "e";
                                cadMani.atualizarEmailMenifesto(Apoio.parseInt(rsBcm.getString("idmanifesto")));
                            }
                        } else {
                              mensagemEnvio = "p";                              
                        }
                        
                        caixaSaida = caixaSaida.converterEnvioEmailParaCaixaSaida(m, Apoio.getUsuario(request), m.getCfg().getEmailEntrega().getId(), mensagemEnvio);
                        caixaSaidaBO.salvarEmailCaixaSaida(caixaSaida, Apoio.getUsuario(request));

                    }
                    rsBcm.close();
                    if (!msgErro.equals("")) {
                        response.getWriter().append(msgErro);
                    } else {
                        nucleo.Apoio.redirecionaPop(response.getWriter(), "ConsultaControlador?codTela=28");
                        //response.getWriter().append("load=0");                   
                    }
                    response.getWriter().close();
                }
    
    
    
    
    

%>


<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var primeiroManifesto = "";
    function seleciona_campos(){
    <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
       if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null)) {%>
               $("valor_consulta").focus();
               document.getElementById("valor_consulta").value = "<%=valorConsulta%>";
               document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
               document.getElementById("operador_consulta").value = "<%=operadorConsulta%>";
               document.getElementById("limite").value = "<%=limiteResultados%>";
               document.getElementById("ordenacao").value = "<%=ordenacao%>";
               document.getElementById("tipo_ordenacao").value = "<%=tipoOrdenacao%>";
               document.getElementById("slcPreManifesto").value = "<%=preManifesto%>";
    <%}%>
        }
        shortcut.add("enter",function() {consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value)});
        function consulta(campo, operador, valor, limite){
            var data1 = document.getElementById("dtsaida1").value.trim();
            var data2 = document.getElementById("dtsaida2").value.trim();
            if (campo == "dtsaida" && !(validaData(data1) && validaData(data2) )) 
            {
                alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
                return null;
            }
            
            location.replace("./consultamanifesto?campo="+campo+"&ope="+operador+"&valor="+valor+"&filialId="+$('filialId').value+"&idmotorista="+$('idmotorista').value+
                "&motor_nome="+$('motor_nome').value
                +"&vei_placa="+$('vei_placa').value
                +"&idveiculo="+$('idveiculo').value
                +"&car_placa="+$('car_placa').value
                +"&idcarreta="+$('idcarreta').value
                +"&chkAereo="+$('chkAereo').checked+"&chkAquaviario="+$('chkAquaviario').checked+"&chkRodoviario="+$('chkRodoviario').checked
                +"&ordenacao="+$('ordenacao').value+"&tipo_ordenacao="+$('tipo_ordenacao').value
                +"&companhia_aerea="+$('companhia_aerea').value
                +"&idcompanhia="+$('idcompanhia').value
                +"&aeroporto_origem="+$('aeroporto_origem').value
                +"&aeroporto_origem_id="+$('aeroporto_origem_id').value
                +"&aeroporto_destino="+$('aeroporto_destino').value
                +"&aeroporto_destino_id="+$('aeroporto_destino_id').value
                +"&redspt_rzs="+$('redspt_rzs').value
                +"&idredespachante="+$('idredespachante').value
                +"&chkManifestoCriados="+$('chkManifestoCriados').checked 
                +"&slcPreManifesto="+$('slcPreManifesto').value 
                +"&rota_id="+$('rota_id').value 
                +"&rota_desc="+$('rota_desc').value 
                +(data1 == "" ? "" : "&dtsaida1="+data1+"&dtsaida2="+data2)+"&limite="+limite+"&pag=1&acao=consultar");
        }

        function editarmanifesto(idmanifesto, podeexcluir){
            location.replace("./cadmanifesto?acao=editar&id="+idmanifesto+(podeexcluir != null ? "&ex="+podeexcluir : ""));
        }
        
        function abrirImportacao(id,tipo){
          launchPopupLocate("./ConferenciaControlador?acao=importarArquivo&id="+id+"&tipo_operacao="+tipo+"&layout=t", "Manifesto");
        }
        
        function editarcartafrete(idcartafrete, podeexcluir, isCiot){
            if (!isCiot){
                window.open("./cadcartafrete?acao=editar&id="+idcartafrete+"&ex="+podeexcluir, "CONTRATO" , "top=0,resizable=yes");
            }else{
                window.open("./ContratoFreteControlador?acao=iniciarEditar&id="+idcartafrete+"&ex="+podeexcluir, "CONTRATO" , "top=0,resizable=yes");
            }    
        }
  
        function proxima(ultimo_titulo)
        {
            var data1 = document.getElementById("dtsaida1").value.trim();
            var data2 = document.getElementById("dtsaida2").value.trim();
            //Somando a pag atual + 1 para a proxima pagina
            location.replace("./consultamanifesto?pag="+<%=(pag + 1)%>
            +"&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>&idmotorista="+$('idmotorista').value
            +"&ordenacao="+$('ordenacao').value+"&tipo_ordenacao="+$('tipo_ordenacao').value
            +"&motor_nome="+$('motor_nome').value+"&chkAereo="+$('chkAereo').checked+"&chkAquaviario="+$('chkAquaviario').checked
            +"&chkRodoviario="+$('chkRodoviario').checked
            +"&slcPreManifesto="+$('slcPreManifesto').value
            +"&rota_id="+$('rota_id').value
            +"&rota_desc="+$('rota_desc').value+
                (data1 == "" ? "" : "&dtsaida1="+data1+"&dtsaida2="+data2)+"&ope=<%=operadorConsulta%>&acao=proxima"
            +"&chkManifestoCriados="+$('chkManifestoCriados').checked);
        }

        function anterior(ultimo_titulo)
        {
            var data1 = document.getElementById("dtsaida1").value.trim();
            var data2 = document.getElementById("dtsaida2").value.trim();
    <%                                               //Somando a pag atual + 1 para a proxima pagina %>
            location.replace("./consultamanifesto?pag="+<%=(pag - 1)%>
            +"&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>&idmotorista="+$('idmotorista').value
            +"&motor_nome="+$('motor_nome').value+"&chkAereo="+$('chkAereo').checked+"&chkAquaviario="+$('chkAquaviario').checked
            +"&chkRodoviario="+$('chkRodoviario').checked+"&ordenacao="+$('ordenacao').value+"&tipo_ordenacao="+$('tipo_ordenacao').value
            +"&chkManifestoCriados="+$('chkManifestoCriados').checked
            +"&slcPreManifesto="+$('slcPreManifesto').value
            +"&rota_id="+$('rota_id').value 
            +"&rota_desc="+$('rota_desc').value 
            +(data1 == "" ? "" : "&dtsaida1="+data1+"&dtsaida2="+data2)+"&ope=<%=operadorConsulta%>&acao=proxima");
        }

        function excluirmanifesto(idmanifesto){
            if (confirm("Deseja mesmo excluir este Manifesto?"))
            {
                location.replace("./consultamanifesto?acao=excluir&id="+idmanifesto);
            }
        }
  
        function cadmanifesto(){ 
            location.replace("./cadmanifesto?acao=iniciar");
        }
  
        function habilitaConsultaDePeriodo(opcao)
        {
            document.getElementById("valor_consulta").style.display = (opcao ? "none" : "");
            document.getElementById("operador_consulta").style.display = (opcao ? "none" : "");
            document.getElementById("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");	  
        }
  
        function aoCarregar(){
            seleciona_campos();
            
    <%if ((acao.equals("consultar") || acao.equals("proxima")) && (campoConsulta.equals("dtsaida"))) {%>
            habilitaConsultaDePeriodo(true);
    <%}%>
        }
        
        function popManifesto(id){
            function e(transport){
                var textoresposta = transport.responseText;
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0"){
                    return false;
                }
//                else{
//                    alert(textoresposta);
//                }
            }//funcao e()

            if (id == null)
                return null;
            launchPDF('./consultamanifesto?acao=exportar&modelo='+document.getElementById("cbmodelo").value+'&id='+id, 
            'manifesto'+id);
            new Ajax.Request("./consultamanifesto?acao=enviarEmail&idManif="+id,{method:'post', onSuccess: e, onError: e});
        }

        function exportarModelo(modelo){
            var manif = getCheckedManif();
            if (manif == "") {
                alert("Selecione pelo menos um Manifesto!");
                return null;
            }

            if (modelo=='-'){
                alert('Escolha um layout de exportação corretamente!');
                return false;
            }else if (modelo=='FRONTDIG'){
                document.location.href = './manifesto'+primeiroManifesto+'.txt2?idmanifesto='+manif + '&modelo=manif';
            }else if(modelo=='ATM'){
                document.location.href = './averbacao.txt4?ids='+manif + '&modelo=MANIF';
            }else if(modelo=='ATM-M'){
                document.location.href = './averbacao.txt4?ids='+manif + '&modelo=MANIF-M';
            }else if(modelo=='APISUL'){
                document.location.href = './averbacao.txt5?ids='+manif + '&modelo=MANIF';
            }else if(modelo=='FRONTRAP'){
                document.location.href = './FR<%=Apoio.getUsuario(request).getFilial().getCnpj()%>'+primeiroManifesto+'.txt6?ids='+manif + '&modelo=manif';
            }else if(modelo=='FRONTRAPRN'){
                document.location.href = './ROMANEIO_'+primeiroManifesto+'.txt6?ids='+manif + '&modelo=manifrn';
            }else if(modelo=='PAMCARY'){
                document.location.href = './TIDN<%=new SimpleDateFormat("MMDDHmm").format(new Date())%>.txt7?ids='+manif;
            }else if(modelo=='PORTOSEGURO'){
                document.location.href = './averbacao.txt8?ids='+ manif +'&modelo=MANIF';
            }else if(modelo=='ITAUSEGUROS'){
                document.location.href = './averbacao.txt11?ids='+ manif +'&modelo=MANIF&acao=itauSeguros';
            }else if(modelo=='SUFRAMA'){
                launchPopupLocate('./Suframa.SIN?ids='+ manif +'&modelo=MANIF&acao=suframa', "Arquivo_SUFRAMA");
            }else if(modelo=='CITNET'){
                document.location.href = './averbacao.txt10?ids='+ manif +'&modelo=MANIF';
            }else if(modelo == 'BUONNY'){
                var x = 0;
                for(x = 0; getObj("ck"+x) != null; x++){
                    if(getObj("ck"+x).checked){
                        var idManifesto = getObj("ck"+x).value;
                    }
                }
                var roteirizadorBuonny = '<%=roteirizador%>';                
                if(idManifesto != undefined){            
                    window.open("ManifestoBuonnyControlador?acao=enviarManifestoBuonny&idManifesto="+idManifesto+"&roteirizadorBuonny="+roteirizadorBuonny, "pop", "width=210, height=100");
                }else{
                    alert("Selecione um manifesto!");
                    return false;
                }
            }
        }

        function popSeparacao(){
            var manif = getCheckedManif();
            if (manif == "") {
                alert("Selecione pelo menos um Manifesto!");
                return null;
            }

            launchPDF('./consultamanifesto?acao=exportarSeparacao&modelo='+document.getElementById("cbmodeloseparacao").value+'&id='+manif, 
            'manifesto'+manif);
        }

        function getCheckedManif(){
            var ids = "";
            for (i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked){
                    if (ids == ''){
                        primeiroManifesto = getObj("manif" + i).value;
                    }
                ids += ',' + getObj("ck" + i).value;
            }
            return ids.substr(1);
        }

        function printMatricideManifesto() {
            function e(transport){
                var textoresposta = transport.responseText;
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0"){
                    return false;
                }else{
                    alert(textoresposta);
                }
            }//funcao e()

            var manif = getCheckedManif();
            if (manif == "") {
                alert("Selecione pelo menos um Manifesto!");
                return null;
            }
            var url =  "./matricidemanifesto.ctrc?ids="+manif+"&"+concatFieldValue("driverImpressora,caminho_impressora");
            tryRequestToServer(function(){document.location.href = url;});
            new Ajax.Request("./consultamanifesto?acao=enviarEmail&idManif="+manif,{method:'post', onSuccess: e, onError: e});
        }
        
        

        function marcaTodos(){
            var i = 0;
            while ($("ck"+i) != null){
                $("ck"+i).checked = $("chkTodos").checked;
                i++;
            }
        }

        function limpaVeiculo(){
            $("idveiculo").value = 0;
            $("vei_placa").value = "";
        }

        function limpaCarreta(){
            $("idcarreta").value = 0;
            $("car_placa").value = "";
        }
        
        function limpaCompnhiaAerea(){
            $("idcompanhia").value = 0;
            $("companhia_aerea").value = "";
        }
        function limpaAeroportoOrigem(){
            $("aeroporto_origem_id").value = 0;
            $("aeroporto_origem").value = "";
        }
        function limpaAeroportoDestino(){
            $("aeroporto_destino_id").value = 0;
            $("aeroporto_destino").value = "";
        }
        function limpaRepresentanteDestino(){
            $("idredespachante").value = 0;
            $("redspt_rzs").value = "";
        }
        function limpaRota(){
            $("rota_id").value = "";
            $("rota_desc").value = "";
        }
        
        function enviarCLe(){
            var manif = getCheckedManif();    
            if(manif.split(",").length > 1){
                alert("Selecione apenas um manifesto!");
                return false;
            }
            window.open("CLeControlador?manifestoId=" + manif,
            "pop", "width=210, height=100");  
    
    
        }
        
        function enviarMDFe(){
            window.open("MDFeControlador?acao=listarMDFe",'MDFe','height=600,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1');
        }
        
        function enviarEmailManifestoRepresentante(idmanifesto){
            if (idmanifesto == null){
                return null;
            }            
            window.open("./consultamanifesto?acao=enviarEmailManifestoRepresentante&idManif="+idmanifesto+"&modelo="+$("cbmodelo").value, "pop", "width=210, height=100");
        }
        
        //Manifesto Buonny
        function enviarManifestoGwBuonny(){
            var x = 0;
            for(x = 0; getObj("ck"+x) != null; x++){
                if(getObj("ck"+x).checked){
                    var idManifesto = getObj("ck"+x).value;
                }
            }
            if(idManifesto != undefined){            
                window.open("ManifestoBuonnyControlador?acao=enviarManifestoBuonny&idManifesto="+idManifesto, "pop", "width=210, height=100");
            }else{
                alert("Selecione um manifesto!");
                return false;
            }
        }
function rotasNoMaps(origem, destinos){
    if (origem == null || destinos == null)
	    return null;
    var url = "http://maps.google.com/maps?saddr="+origem + "&daddr="+destinos;
    window.open(url,"googMaps","toolbar=no,location=no,scrollbars=no,resizable=no");
     
}
function incluirPreManifesto(){
        tryRequestToServer(function(){document.location.replace("./SeparacaoControlador?acao=novoCadastro");});
    }
function aoClicarNoLocaliza(idJanela){
    
        if(idJanela == "Aeroporto_Origem"){
                $("aeroporto_origem_id").value = $("aeroporto_id_orig").value;
                $('aeroporto_origem').value = $('aeroporto_orig').value;
        }
        if(idJanela == "Aeroporto_Destino"){
                $("aeroporto_destino_id").value = $("aeroporto_id_dest").value;
                $("aeroporto_destino").value = $("aeroporto_dest").value;
        }
}

function getMarcaTodos(){
    
    var idManifesto = "0";    
    var manifesto = "";
    
    
    for(i = 0; getObj("ck" + i) != null; ++i){
        if(getObj("ck" + i).checked){
            idManifesto = idManifesto + ',' + getObj("ck" + i).value;
//            manifesto = getObj("ck" + i).value;
            
//            if(getObj("impressoManif" + manifesto).value == 'true'){
//                manifestoImpressos = manifestoImpressos + (manifestoImpressos == '' ? '' : ',') + getObj("numeroManifesto" + manifesto).value;
//            }
        }
    }
    
    return idManifesto;
}

function printManifesto(){
    var manifesto =  getMarcaTodos();
    var idManifesto = "0";
    idManifesto = manifesto.replace("0,", "");
        if(manifesto == "0"){
            alert("Selecione pelo menos um Nº Manifesto!");
            return null;
  
    }
        confirmRelManif(idManifesto);
    
}

    function roteirizarEntrega(){
        window.open("RoteirizacaoControlador?acao=listar",'MDFe','height=800,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1');
    }
    
    
    function enviarGerenciadorRisco(){
        if(confirm("Deseja enviar para Golden Service? ")){
                
                var manifesto = getCheckedManifesto();
                console.log("manfiesto: "+manifesto);
                var formu = $("formulario");
                formu.action = 'GoldenServiceControlador?acao=enviar&idManifesto=' + manifesto;
                var pop = window.open(formu, 'pop', 'width=400, height=200');
                formu.submit();
            }
    }
    
    function getCheckedManifesto(){
                var ids = "";
                for (var i = 0; getObj("ck" + i) != null; ++i)
                   
                if (getObj("ck" + i).checked)
                    ids = getObj("ck" + i).value;
                return ids;
    }
    
    function compareDate(dataInicio,dataFim){
        
        var nova_dataIncio = parseInt(dataInicio.split("/")[2].toString() + dataInicio.split("/")[1].toString() + dataInicio.split("/")[0].toString());
        var nova_dataFim = parseInt(dataFim.split("/")[2].toString() + dataFim.split("/")[1].toString() + dataFim.split("/")[0].toString());
 
         if (nova_dataFim > nova_dataIncio)
          return false;
         else if (nova_dataIncio == nova_dataFim)
          return true;
         else
          return true;
    }
    
    function confirmRelManif(idManifesto){
        var isUsaGenRisco = "";
        var tipoBloqMonitoramento = "";
        var isConfirmadoGen = "";
        var nmanifesto = "";
        var dataUsoGoldenService = "";
        var dataDoManifesto = "";
        var ids = idManifesto;
        var idsliberados = "";
        var idsbloqueados = "";
        var idsTipoA = 0;
          
                for(var i = 0; i < ids.split(",").length ; ++i){ 
                        //essa validação estava quebrando na hora de imprimir relatorios aleatoriamente
//                        if((document.getElementById("ck"+i).value) == ids.split(",")[i]){

                        isUsaGenRisco = document.getElementById("tipoUsoGenRisco_"+i).value;
                        tipoBloqMonitoramento = document.getElementById("tipoBloq_"+i).value;
                            if(tipoBloqMonitoramento == "1"){
                                idsTipoA++;
                            }
                        nmanifesto = document.getElementById("manif"+i).value;
                        dataUsoGoldenService = document.getElementById("dataUsoGoldenService_"+i).value;
                        dataDoManifesto = document.getElementById("dtManif_"+i).value;
                        isConfirmadoGen = (document.getElementById("protocolo_"+i).value == null ? "" : document.getElementById("protocolo_"+i).value);

                       if (isUsaGenRisco != "0") {
                                //alert("Entrou IF risco")
                            if (compareDate(dataDoManifesto, dataUsoGoldenService)) {
                              // alert("Entrou IF data")
                                if (tipoBloqMonitoramento == "2") {
                             //   alert("Entrou IF Tipo")
                                        if(isConfirmadoGen !=""){
                                             if(idsliberados==""){
                                                         idsliberados+=ids.split(",")[i];
                                                     }else{
                                                         idsliberados+=","+ids.split(",")[i];
                                                     } 
                                            }else{ 
                                                    if(idsbloqueados==""){
                                                         idsbloqueados += nmanifesto;
                                                          
                                                     }else{
                                                         idsbloqueados +=","+nmanifesto;
                                                             
                                                     }   
                                                    }        

                                }else{
                                    
                                     if(idsliberados==""){
                                                         idsliberados += ids.split(",")[i];
                                                          
                                                     }else{
                                                         idsliberados +=","+ids.split(",")[i];
                                                             
                                                     }
                                                }

                            }else{
                                    if(idsliberados==""){
                                         idsliberados+=ids.split(",")[i];
                                     }else{
                                         idsliberados+=","+ids.split(",")[i];
                                     } 
                                }

                        }else{
                                    if(idsliberados==""){
                                         idsliberados+=ids.split(",")[i];
                                     }else{
                                         idsliberados+=","+ids.split(",")[i];
                                     } 
                                }
//                  }
      }
                     if(idsbloqueados != 0){
                      alert(" O(s) manifesto(s): "+idsbloqueados+" não "+(idsbloqueados.split().length > 1 ? "possui" : "possuem") +" protocolo de confirmação na Gerenciadora de Risco");
                     }  
                    
                 if (idsliberados != 0) {
                    if(idsTipoA != 0){
                          if(confirm("Deseja imprimir os relatórios? "))
                            popManifesto(idsliberados);
                     }else{
                        popManifesto(idsliberados);
                    }
 }                   
    
}
    function confirmUnicoRel(idManifesto){
            var isUsaGenRisco = "";
            var tipoBloqMonitoramento = "";
            var isConfirmadoGen = "";            
            var dataUsoGoldenService = "";
            var dataDoManifesto = "";
             var idsTipoA = 0;
             var nmanifesto = "";
            
                for(var i = 0; i < getObj("limite").value ; i++){ 
               
                    if((document.getElementById("ck"+i).value) == idManifesto){
               
                          isUsaGenRisco = document.getElementById("tipoUsoGenRisco_"+i).value;
                        tipoBloqMonitoramento = document.getElementById("tipoBloq_"+i).value;
                            if(tipoBloqMonitoramento == "1"){
                                idsTipoA++;
                            }
                        nmanifesto = document.getElementById("manif"+i).value;
                        dataUsoGoldenService = document.getElementById("dataUsoGoldenService_"+i).value;
                        dataDoManifesto = document.getElementById("dtManif_"+i).value;
                        isConfirmadoGen = (document.getElementById("protocolo_"+i).value == null ? "" : document.getElementById("protocolo_"+i).value);

                if(isUsaGenRisco != '0'){
                    if(compareDate(dataDoManifesto,dataUsoGoldenService)){
                         if(tipoBloqMonitoramento == '1'){
                            if(confim("Deseja imprimir Relatório ? "))
                                    popManifesto(idManifesto);
                                            break;
                                        } else if (isConfirmadoGen == "") {
                                            alert("Este manifesto: "+nmanifesto+" não possui protocolo de confirmação na Gerenciadora de Risco");
                                            break;
                                               } else {
                                            popManifesto(idManifesto);
                                            break;
                                               }
                                           } else {
                                        popManifesto(idManifesto);
                                        break;
                                           }
                                       } else {
                                    popManifesto(idManifesto);
                                    break;
                                           }
                                       }
                                       }
                                   }
                                   
                                   
        function sincronizarGwMobile(id, actionImport){
            window.open("./MobileControlador?acao=sincronizarGWMobileManifesto&idManifesto=" + id + "&actionImport="+actionImport, "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
        }

</script>

<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.EnviaEmail"%>
<%@page import="conhecimento.BeanConsultaConhecimento"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Consulta de Manifestos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                      font-size: 13px;
            }
            -->
        </style>
    </head>
        
    <body onLoad="javascript:aoCarregar();applyFormatter()">
    <form id="formulario" name="formulario" target="pop" method="post">
        <input type="hidden" id="idAwb" name="idAwb" value="">
        <input type="hidden" id="aeroporto_orig" name="aeroporto_orig" value="">
        <input type="hidden" id="aeroporto_id_orig" name="aeroporto_id_orig" value="0">
        <input type="hidden" id="aeroporto_dest" name="aeroporto_dest" value="">
        <input type="hidden" id="aeroporto_id_dest" name="aeroporto_id_dest" value="0">
        <img src="img/banner.gif"  alt=""><br>
        <table width="98%" align="center" class="bordaFina" >
            <tr >
                <td width="525"><div align="left"><b>Consulta de Manifestos</b></div></td>
                <%if (Apoio.getUsuario(request).getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().getId() == 2
                            && Apoio.getUsuario(request).getFilial().getFilialGerenciadorRisco().getStUtilizacao() != 0) {%>
                <td align="right" width="10%">
                        <input type="button" class="botoes" value=" Enviar Golden Service " onclick="javascript:tryRequestToServer(function(){enviarGerenciadorRisco();});"/>                    
                </td>
                <%}%>
                <%if (Apoio.getUsuario(request).getAcesso("roteirizadorentrega") ==4) {%>
                    <td align="right" width="10%">
                        <input type="button" class="botoes" value=" Roteirizador de Entregas " onclick="javascript:tryRequestToServer(function(){roteirizarEntrega();});"/>                    
                    </td>
                <%}%>
                <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoMDFe() != 'N' && Apoio.getUsuario(request).getAcesso("enviomdfe")==4) {%>
                    <td align="right" width="10%">
                        <input type="button" class="botoes" value=" MDF-e " onclick="enviarMDFe($('cbexportar').value)"/>                    
                    </td>
                <%}%>
                <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoCle() != 'N') {%>
                    <td align="right" width="15%">   
                        <input type="button" class="botoes" value=" TRANSMITIR CL-e PARA SEFAZ " onclick="enviarCLe($('cbexportar').value)"/>                    
                    </td>
                <%}%>
                <% if (nivelUser >= 3) {%>
                <td width="55" >
                    <input id="preManifesto" name="preManifesto" type="button" class="botoes" value="Incluir Pré-Manifesto" alt="Incluir Pré-Manifesto" onClick="javascript:incluirPreManifesto();">
                </td>
                <%}%>
                <% if (nivelUser >= 3) {%>
                <td align="right" width="10%">
                    <input name="novomanifesto" type="button" class="botoes" id="novomanifesto"  value="Novo cadastro" onClick="javascript:cadmanifesto();">
                </td>
                
                <%}%>
            </tr>
            
        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">

            <tr class="celula">
                <td width="140"  height="26">
                    <select name="campo_consulta" id="campo_consulta" onChange="javascript:habilitaConsultaDePeriodo(this.value=='dtsaida');" class="inputtexto">
                        <option value="nmanifesto">Nº Manifesto</option>
                        <option value="numeros_cte">Nº CT-e</option>
                        <option value="numero_awb">Nº AWB (Cia Aérea)</option>
                        <option value="numero_carga">Nº Carga</option>
                        <option value="numeros_nf">Nº NF do CT-e</option>
                        <option value="dtsaida" selected>Data</option>
                        <option value="origem">Cidade de origem</option>
                        <option value="destino">Cidade de destino</option>
                        <option value="placa">Cavalo</option>
                        <option value="placa_carreta">Carreta</option>
                        <option value="nome">Motorista</option>
                        <option value="libmotorista">Nº Liberação</option>
                    </select>
                </td>
                <td width="158">
                    <select name="operador_consulta" id="operador_consulta" class="inputtexto" style="width: 190px;">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (Vários separados por vírgula)</option>
                        <option value="5" selected>Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De:<input name="dtsaida1" type="text" id="dtsaida1" size="10" maxlength="10" value="<%=dataInicial%>"
                                                                   class="fieldDate" onBlur="alertInvalidDate(this)"></div>
                </td>
                <td>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">Para:<input name="dtsaida2" type="text" id="dtsaida2" size="10" maxlength="10" value="<%=dataFinal%>"
                                                                     class="fieldDate" onBlur="alertInvalidDate(this)" ></div>
                    <input name="valor_consulta" type="text" id="valor_consulta" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
                </td>
                <td width="148"><select name="filialId" id="filialId" class="inputtexto">
                        <%BeanFilial fl = new BeanFilial();
            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                        <%if (nivelUserToFilial > 0) {%>
                        <option value="0">TODAS AS FILIAIS</option>
                        <%}
            while (rsFl.next()) {
                if (nivelUserToFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                        <option value="<%=rsFl.getString("idfilial")%>" 
                                <%=(filial.equals(rsFl.getString("idfilial")) ? "selected" : "")%>>APENAS A <%=rsFl.getString("abreviatura")%></option>
                        <%}%>
                        <%}%>
                    </select></td>
                <td width="86">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
                <td width="74"><div align="right">
                        Por p&aacute;g.:

                    </div></td>
                <td width="117"><select name="limite" id="limite" class="inputtexto">
                        <option value="10" selected>10 resultados</option>
                        <option value="20">20 resultados</option>
                        <option value="30">30 resultados</option>
                        <option value="40">40 resultados</option>
                        <option value="50">50 resultados</option>
                    </select></td>
            </tr>
            <tr>
                  <td colspan="7">
                    <table width="100%">
                        <tr class="celula">                           

                            <td width="14%" align="right">Motorista:</td>
                            <td width="24%" align="left">

                                <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" size="20" readonly="true" value="<%=motorista%>">
                                <input name="localiza_rem3" type="button" class="botoes" id="localiza_rem3" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista');
                                        ;">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';
                                        getObj('motor_nome').value = '';">
                                <input type="hidden" name="idmotorista" id="idmotorista" value="<%=idMotorista%>">
                            </td>                           

                            <td width="14%" align="right">Veículo:</td>
                            <td width="24%" align="left">

                                <input type="hidden" name="idveiculo"   id="idveiculo" value="<%=idVeiculo%>">
                                <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" size="10" readonly="true" value="<%=veiculo%>">
                                <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=7', 'Veiculo', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaVeiculo();"/>
                            </td>
                            <td width="6%" align="right">Carreta:</td>
                            <td  width="10%" align="left">
                                <input type="hidden" name="idcarreta" id="idcarreta" value="<%=idCarreta%>">
                                <input name="car_placa" type="text" id="car_placa" class="inputReadOnly8pt" size="10" readonly="true" value="<%=carreta%>">
                                <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=9', 'Veiculo', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaCarreta();"/>
                            </td>
                            
                        </tr>
                        <tr class="celula" >
                            <td align="right">Apenas a companhia aerea:</td>
                            <td align="left">
                                <input type="hidden" name="idcompanhia" id="idcompanhia" value="<%=idCompanhiaAerea%>">
                                <input name="companhia_aerea" type="text" id="companhia_aerea" class="inputReadOnly" size="20" readonly="true" value="<%=companhiaAerea%>">
                                <input name="localiza_companhia" type="button" class="botoes" id="localiza_companhia" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COMPANHIA_AEREA%>', 'companhia', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaCompnhiaAerea()">
                            </td>
                            <td  colspan="1" align="right">Apenas o repres. de destino:</td>
                            <td  colspan="1" align="left">
                                <input type="hidden" name="idredespachante" id="idredespachante" value="<%=idRepresentanteDestino%>">
                                <input name="redspt_rzs" type="text" id="redspt_rzs" class="inputReadOnly" size="20" readonly="true" value="<%=representanteDestino%>">
                                <input name="localiza_representante_dest" type="button" class="botoes" id="localiza_representante_dest" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE2%>', 'Representante_Entrega', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaRepresentanteDestino()">
                            </td>
                            <td align="right">Mostrar:</td>
                            <td >
                                <div align="left">
                                    <input type="checkbox" id="chkAquaviario" name="chkAquaviario" value="" <%=(chkAquaviario==true)? "checked": ""%>>
                                    <label for="lbAquaviario">Aquaviário </label><br>
                                    <input type="checkbox" id="chkRodoviario" name="chkRodoviario" value=""  <%=(chkRodoviario==true)? "checked": ""%>>
                                    <label for="lbRodoviario">Rodoviário </label><br>
                                    <input type="checkbox" id="chkAereo" name="chkAereo" value="" <%=(chkAereo==true)? "checked": ""%>>
                                    <label for="lbAereo">Aéreo </label>
                                </div>

                            </td>

                        <tr class="celula">
                            <td  colspan ="1" align="right">Apenas o aeroporto de origem:</td>
                            <td align="left">
                                <input type="hidden" name="aeroporto_origem_id" id="aeroporto_origem_id" value="<%=idAeroportoOrigem%>">
                                <input name="aeroporto_origem" type="text" id="aeroporto_origem" class="inputReadOnly" size="20" readonly="true" value="<%=aeroportoOrigem%>">
                                <input name="btAero" type="button" class="botoes" id="btAero" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AEROPORTO%>', 'Aeroporto_Origem', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoOrigem()">
                            </td> 
                            <td  colspan ="1" align="right">Apenas o aeroporto de destino:</td>
                            <td align="left">
                                <input type="hidden" name="aeroporto_destino_id" id="aeroporto_destino_id" value="<%=idAeroportoDestino%>">
                                <input name="aeroporto_destino" type="text" id="aeroporto_destino" class="inputReadOnly" size="20" readonly="true" value="<%=aeroportoDestino%>">
                                <input name="btAero" type="button" class="botoes" id="btAero" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AEROPORTO2%>', 'Aeroporto_Destino', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoDestino()">
                            </td> 
                            <td width="6%" align="right">Ordenar:</td>

                            <td width="10%" align="left">
                                <select name="ordenacao" id="ordenacao" class="inputtexto" style="width: 80px;">
                                    <option value="nmanifesto" selected>Nº Manifesto</option>
                                    <option value="dtsaida">Data</option>
                                    <option value="origem">Cidade de origem</option>
                                    <option value="destino">Cidade de destino</option>
                                    <option value="placa">Cavalo</option>
                                    <option value="placa_carreta">Carreta</option>
                                    <option value="nome">Motorista</option>
                                </select>
                                <select name="tipo_ordenacao" id="tipo_ordenacao" class="inputtexto" style="width: 80px;">
                                    <option value="" selected>Crescente</option>
                                    <option value="desc">Decrescente</option>
                                </select>
                            </td>          
                            
                        </tr>
                        
                        <tr class="celula">
                            <td></td>
                            <td width="10%" align="center">
                                <label>
                                    <input type="checkbox" id="chkManifestoCriados" name="chkManifestoCriados" value="checkbox" <%=(chkManifestoCriados.equals("true") ? "checked": "")%>/>
                                    Mostrar manifestos criados por mim
                                </label>
                            </td>
                            <td  colspan ="1" align="right">Apenas a rota: </td>
                            <td align="left">
                                <input type="text" class="inputReadOnly8pt" id="rota_desc" name="rota_desc" value="<%= rotaDesc%>"/>
                                <input type="hidden" id="rota_id" name="rota_id" value="<%= rotaId %>" />
                                <input name="localiza_rota" type="button" class="botoes" id="localiza_rota" value="..." 
                                       onclick="javascript:tryRequestToServer(function(){window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.ROTA%>', 'Rota', 'top=80,left=150,height=600,width=800,resizable=yes,status=1,scrollbars=1');});" />
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaRota()">
                            </td>
                            <td align="right">
                                <!--<label>-->
                                    <!--<input type="checkbox" id="chkPreManifesto" name="chkPreManifesto" value="checkbox" < %=(isPreManifesto.equals("true") ? "checked": "")%>/>-->
                                    Pré-Manifesto:
                                <!--</label>-->
                            </td>
                            <td align="left" colspan="2">
                                <select id="slcPreManifesto" name="slcPreManifesto" class="inputtexto">
                                    <option value="a" selected="">Ambos</option>
                                    <option value="s">Sim</option>
                                    <option value="n">Não</option>
                                </select>
                            </td>
                        </tr>
                        
                    </table>
                </td>
            </tr>
        </table>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr>
                <td width="1%" class="tabela"><input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcaTodos();"></td>
                <td width="2%" class="tabela">
                    <img src="img/pdf.jpg" width="19" height="19" border="0" class="imagemLink" title="Formato PDF(usado para mostrar todas impressões)"
                         onClick="javascript:tryRequestToServer(function (){printManifesto()});">
                </td>
                <td width="2%" class="tabela"></td>
                <td width="2%" class="tabela"></td>
                <td width="2%" class="tabela"></td>
                <td width="2%" class="tabela"></td>
                <td width="2%" class="tabela"></td>
                <td width="7%" class="tabela">
                    <div align="center">Nº Manifesto</div>
                </td>
                <td width="3%" class="tabela">
                    <div align="center">Série MDF-e</div>
                </td>
                <td width="6%" class="tabela">
                    <div align="center">Filial</div>
                </td>
                <td width="2%" class="tabela">
                    <div align="center">
                        Tipo
                    </div>
                </td>
                <td width="1%" class="tabela">Data</td>
                <td width="2%" class="tabela">Vol(s)</td>
                <td width="2%" class="tabela">R$ NF(s)</td>
                <td width="9%" class="tabela">Origem</td>
                <td width="9%" class="tabela">Destino</td>
                <td width="6%" class="tabela">Veículo</td>
                <td width="22%" class="tabela">Motorista</td>
                <td width="7%" class="tabela">Lib.</td>
                <td width="6%" class="tabela"><div align="center">C. F.</div></td>
                <td width="4%" class="tabela">Pré M.</td>
             
                <td width="1%" class="tabela"></td>
            </tr>
            <% //variaveis da paginacao
                int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;
                String ultima_linha = "";

                // se conseguiu consultar
                
                if ((acao.equals("consultar") || acao.equals("proxima")) && (beanManif.Consultar())) {
                    ResultSet rs = beanManif.getResultado();
                    while (rs.next()) {
                        //pega o resto da divisao e testa se é par ou impar
%>  
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td>
                    <input name="ck<%=linha%>" type="checkbox" value="<%=rs.getInt("idmanifesto")%>" id="ck<%=linha%>">
                </td>
                <td>
                    <img src="img/pdf.jpg" width="19" height="19" border="0" class="imagemLink" title="Formato PDF(usado para a impressão)"
                         onClick="javascript:tryRequestToServer(function(){confirmUnicoRel('<%=rs.getString("idmanifesto")%>');});">
                </td>                
                <td>
                    <%-- <%if(rs.getString("tipo_destino").equals("rd")){%> --%>
                        <%if(!rs.getBoolean("is_enviado_email_representante")){%>
                            <img src="img/out.png" title="Manifesto enviar e-mail para o representante" onclick="javascript:enviarEmailManifestoRepresentante('<%=rs.getString("idmanifesto")%>');"/>
                        <%} else {%>
                            <img src="img/outc.png" title="Manifesto e-mail enviado para o representante" onclick="javascript:enviarEmailManifestoRepresentante('<%=rs.getString("idmanifesto")%>');"/>
                        <%}%>
                  <%--  <%}%>   --%>
                </td>
                <td>
                    <a href="#">
                         <img src="img/gmaps.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Visualizar Rotas no Google Maps" onClick="javascript:tryRequestToServer(function(){rotasNoMaps('<%=rs.getString("origem_mapa")%>','<%=rs.getString("destinos_mapa")%>');});"> 
                    </a>
                </td>
                <td>
                    <div align="center">        
                        <%if(!autenticado.getFilial().getTipoUtilizacaoGWMobile().equals("N")){

                        if(rs.getBoolean("is_sincronizado_mobile")){%>
                            <%if (rs.getBoolean("pode_reenviar")){ %>
                                <!-- 
                            esse icone abaixo não está bom. é como se o TODO o romaneio não foi enviado, mas a regra é que
                                se houver ao menos um ctrc ou coleta ele poderá enviar novamente.
                                    Mas Deivid disse para deixar assim (22/12/16) 
                        -->
                        <img src="img/smartphone.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Romaneios para o GwMobile" 
                             onClick="javascript:tryRequestToServer(function () {
                                          sincronizarGwMobile('<%=rs.getString("idmanifesto")%>', 'a');
                                      });">
                            <%} else{%>
                                <img src="img/smart3.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Romaneios para o GwMobile" 
                             onClick="javascript:tryRequestToServer(function () {
                                          alert('Romaneio já sincronizado com o gwMobile.')
                                      });">
                            <%} %>
                        <%} else{ %>

                        <img src="img/smartphone.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Manifesto para o GwMobile"
                             onClick="javascript:tryRequestToServer(function () {
                                          sincronizarGwMobile('<%=rs.getString("idmanifesto")%>', 'i');
                                      });">

                        <%}}%>
                    </div>
                </td>
                <td>
                    <a href="#"><img src="img/seta-azul.png" width="19" height="19" border="0" onclick="javascript:tryRequestToServer(function(){abrirImportacao(<%=rs.getString("idmanifesto")%>, 1, <%=rs.getString("nmanifesto")%>);});"></a>
                </td>
                <td>
                    <a href="#"><img src="img/seta-verde.png" width="19" height="19" border="0" onclick="javascript:tryRequestToServer(function(){abrirImportacao(<%=rs.getString("idmanifesto")%>, 0,<%=rs.getString("nmanifesto")%>);});"></a>
                </td>
                <td>
                    <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){editarmanifesto(<%=rs.getString("idmanifesto") + "," + rs.getBoolean("podeexcluir")%>);});">
                        <% if (rs.getString("st_utilizacao_mdfe").equals("N")) {%>
                            <%=rs.getString("nmanifesto") + (cfg.isSubCodigoManifesto() ? "-" + rs.getString("sub_codigo") : "") + "/" + rs.getString("ano")%>
                        <%} else {%>
                            <%=rs.getString("nmanifesto") + (cfg.isSubCodigoManifesto() ? "-" + rs.getString("sub_codigo") : "")%>
                        <%}%>
                    </div>
                    <input name="manif<%=linha%>" type="hidden" value="<%=rs.getString("nmanifesto")%>" id="manif<%=linha%>">
                </td>
                <td>
                    <div align="center">
                        <%=rs.getString("serie_mdfe") == null ? "" : rs.getString("serie_mdfe")%>                        
                    </div>
                </td>
                <td>
                    <div align="center">
                        <%=rs.getString("abreviatura")%>
                        <input type="hidden" id="tipoUsoGenRisco_<%=linha%>" name="tipoUsoGenRisco_<%=linha%>" value="<%=rs.getString("fgr_st_utilizacao")%>">
                        <input type="hidden" id="tipoBloq_<%=linha%>" name="tipoBloq_<%=linha%>" value="<%=rs.getString("fgr_tipo_bloqueio_rastreamento")%>">
                        <input type="hidden" id="protocolo_<%=linha%>" name="protocolo_<%=linha%>" value="<%=rs.getString("protocolo")%>" />
                        <input type="hidden" id="dataUsoGoldenService_<%=linha%>" name="dataUsoGoldenService_<%=linha%>" value="<%= rs.getDate("fgr_data_inicio_uso") == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("fgr_data_inicio_uso"))%>">
                    </div>
                </td>
                <td>
                    <div align="center">
                        <% if (rs.getString("tipo").equals("a")) {%>                           
                        <label title="Aéreo"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">A</font></label>
                        <%} else if (rs.getString("tipo").equals("m")) {%>                            
                        <label title="Rodoviário"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">R</font></label>
                        <%} else if (rs.getString("tipo").equals("f")) {%>                           
                        <label title="Aquaviário"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Q</font></label>
                        <%}%> 
                            
                    </div>
                </td>
                <td id="idDtSaida"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtsaida"))%></font>
                    <input type="hidden" id="dtManif_<%=linha%>" name="dtManif_<%=linha%>" value="<%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtsaida"))%>">
                </td>
                <td>
                    <div align="left">
                        <%
                        String qtdTotal = Apoio.to_curr2(rs.getDouble("qtdtotal")).split(",")[0].replace(".", "");
                        %>
                        <%=qtdTotal%>
                    </div>
                </td>
                <td>
                    <div align="left">
                        <%String nftotal = Apoio.to_curr2(rs.getDouble("nftotal"));%>
                        <%=nftotal%>
                    </div>
                </td>
                <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("origem")%></font></td>
                <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("destino")%></font></td>
                <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("placa")%></font></td>
                <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("nome")%></font></td>
                <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("libmotorista") != null ? rs.getString("libmotorista") : "" %></font></td>
                <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">
                    <%isCiot = !rs.getString("st_utilizacao_cfe").equals("N");%>
                    <div align="center"  <%=(nivelUserCf == 0 ? "" : "class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarcartafrete(" + rs.getString("idcartafrete") + "," + (nivelUserCf == 4 ? true : false) + ","+isCiot+");});'")%>>
                        <%=(rs.getString("idcartafrete") == null ? "" : rs.getString("idcartafrete"))%>
                    </div>
                    </font>
                </td>
                <td><%
                    if(rs.getBoolean("is_pre_manifesto")){%>
                        Sim
                    <%}else{%>
                        Não
                    <%}%>
                </td>
               
                    <%-- se o usuario tem permissao para excluir.... --%>
                <td width="21">
                    <% if ((nivelUser == 4) && (rs.getBoolean("podeexcluir"))) {%>
                    <img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                         onclick="javascript:tryRequestToServer(function(){excluirmanifesto(<%=rs.getString("idmanifesto")%>);});">
                    <%}%></td>
            </tr>
            <%if (rs.getString("tipo").equals("a")){%>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                    <td colspan="7" align="right"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Nº AWB:</font></td>
                    <td align="left"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("numero_awb")%></font></td>
                    <td colspan="2" align="right"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Nº CT-e(AWB):</font></td>
                    <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("numero_cte_awb")%></font></td>
                    <td align="right"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Cia Aérea:</font></td>
                    <td colspan="2"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("cia_aerea")%></font></td>
                    <td align="right"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Nº Vôo:</font></td>
                    <td colspan="4"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>"><%=rs.getString("numero_voo")%></font></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            <%}%>
            <%if ((rs.getString("protocolo_buonny") != null && !rs.getString("protocolo_buonny").equals("")) || (rs.getString("descricao_status_mdfe") != null && !rs.getString("descricao_status_mdfe").equals(""))){%>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                    <td colspan="7" align="right"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Status MDF-e:</font></td>
                    <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">
                        <%=rs.getString("descricao_status_mdfe")%>
                    </font></td>
                    <td align="right" colspan="2"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Chave de Acesso:</font></td>
                    <td colspan="4"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">
                        <%=rs.getString("chave_acesso_mdfe")%>
                    </font></td>
                    <td align="right"><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">Cód. Buonny:</font></td>
                    <td><font color="<%=rs.getString("status_mdfe") != null && rs.getString("status_mdfe").equalsIgnoreCase("L") ? "red" : ""%>">
                        <%if(roteirizador != 'N' && rs.getString("protocolo_buonny") != null){%>
                            <%=rs.getString("protocolo_buonny")%>
                        <%}%>
                    </font></td>
                    <%if (Apoio.getUsuario(request).getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().getId() == 2
                            && Apoio.getUsuario(request).getFilial().getFilialGerenciadorRisco().getStUtilizacao() != 0) {%>
                        <td align="right">Protocolo:</td>
                        <td><%=rs.getString("protocolo")%>
                        </td>
                        <td colspan="4"></td>
                    <%}%>
                    <td align="right" colspan="1">Monitora:</td>
                    <td><%= rs.getString("status_monitora") %></td>
                    <td colspan="4"></td>
                </tr>
            <%}%>

            <% //se for a ultima linha...
                        if (rs.isLast()) {
                            ultima_linha = rs.getString("idmanifesto");
                            //Quantidade geral de resultados da consulta
                            linhatotal = rs.getInt("qtde_linhas");
                        }
                        linha++;
                    }//while
                    //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
                    qtde_pag = ((linhatotal % Apoio.parseInt(limiteResultados)) == 0
                            ? (linhatotal / Apoio.parseInt(limiteResultados))
                            : (linhatotal / Apoio.parseInt(limiteResultados)) + 1);
                }//if
                pag = (qtde_pag == 0 ? 0 : pag);


            %>
        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula"> 
                <td width="15%"> <center>
                Ocorrências: <b><%=linha%> / <%=linhatotal%></b> </center></td>
        <td width="9%" rowspan="4" align="center">
            <input name="avancar" type="button" class="botoes" id="avancar3"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=ultima_linha%>');});">
            <%
        if (pag < qtde_pag) {%>
            <br><input name="avancar" type="button" class="botoes" id="avancar3"
                       value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});"></td>
            <%}
        //se tiver mais pags entao mostre o botao 'proxima'
%>
        <td width="11%" align="center"><div align="right">Exportar:

            </div></td>
        <td height="26" colspan="2" align="center"><div align="left">
                <select name="cbexportar" id="cbexportar" class="inputtexto">
                    <option value="FRONTDIG" selected>SEFAZ - Fronteira Digital (PE)</option>
                    <option value="FRONTRAP">SEFAZ - Fronteira R&aacute;pida (PI)</option>
                    <option value="FRONTRAPRN">SEFAZ - Fronteira R&aacute;pida (RN)</option>
                    <option value="SUFRAMA">SEFAZ - Arquivo (SUFRAMA/PIN)</option>
                    <option value="-">- - - - - - - - - - - - - - - - - - - - - -</option>
                    <option value="APISUL">Averba&ccedil;&atilde;o (APISUL)</option>
                    <option value="ATM">Averba&ccedil;&atilde;o (AT&amp;M) Dados do CT-e</option>
                    <option value="ATM-M">Averba&ccedil;&atilde;o (AT&amp;M) Dados do Manifesto</option>
                    <option value="PAMCARY">Averba&ccedil;&atilde;o (PAMCARY)</option>
                    <option value="PORTOSEGURO">Averba&ccedil;&atilde;o (PORTO SEGURO)</option>
                    <option value="ITAUSEGUROS">Averba&ccedil;&atilde;o (ITAU SEGUROS)</option>
                    <option value="CITNET">Averba&ccedil;&atilde;o (CITNET)</option>
                    <option value="-">- - - - - - - - - - - - - - - - - - - - - -</option>
                    <%if(roteirizador != 'N'){%>
                    <option value="BUONNY">Roteirizador (BUONNY WEBSERVICE)</option>
                    <%}%>
                </select>
                <input name="exportar" type="button" class="botoes" id="exportar"
                       value="OK"  onClick="javascript:tryRequestToServer(function(){exportarModelo($('cbexportar').value);});">
            </div></td>
        
        <td colspan="3"><div align="right">Modelo em PDF: 
                <select name="cbmodelo" id="cbmodelo" class="inputtexto">
                    <option value="1" <%=cfg.getRelDefaultManifesto().equals("1") ? "selected" : ""%>>Modelo 1 (Rodoviário)</option>
                    <option value="2" <%=cfg.getRelDefaultManifesto().equals("2") ? "selected" : ""%>>Modelo 2 (Rodoviário)</option>
                    <option value="3" <%=cfg.getRelDefaultManifesto().equals("3") ? "selected" : ""%>>Modelo 3 (Rodoviário)</option>
                    <option value="4" <%=cfg.getRelDefaultManifesto().equals("4") ? "selected" : ""%>>Modelo 4 (Rodoviário)</option>
                    <option value="5" <%=cfg.getRelDefaultManifesto().equals("5") ? "selected" : ""%>>Modelo 5 (Rodoviário)</option>
                    <option value="6" <%=cfg.getRelDefaultManifesto().equals("6") ? "selected" : ""%>>Modelo 6 (Rodoviário)</option>
                    <option value="7" <%=cfg.getRelDefaultManifesto().equals("7") ? "selected" : ""%>>Modelo 7 (Marítimo)</option>
                    <option value="8" <%=cfg.getRelDefaultManifesto().equals("8") ? "selected" : ""%>>Modelo 8 (Rodoviário)</option>
                    <option value="9" <%=cfg.getRelDefaultManifesto().equals("9") ? "selected" : ""%>>Modelo 9 (Rodoviário)</option>
                    <option value="10" <%=cfg.getRelDefaultManifesto().equals("10") ? "selected" : ""%>>Modelo 10 (Rodoviário)</option>
                    <option value="11" <%=cfg.getRelDefaultManifesto().equals("11") ? "selected" : ""%>>Modelo 11 (Rodoviário)</option>
                    <option value="12" <%=cfg.getRelDefaultManifesto().equals("12") ? "selected" : ""%>>Modelo 12 (Rodoviário)</option>
                    <%-- <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCle() == 'H' || Apoio.getUsuario(request).getFilial().getStUtilizacaoCle() == 'P'){%> --%>
                    <option value="13" <%=cfg.getRelDefaultManifesto().equals("13") ? "selected" : ""%>>Modelo 13 (Capa de Lote)</option>
                    <%-- <%}%> --%>
                    <option value="14" <%=cfg.getRelDefaultManifesto().equals("14") ? "selected" : ""%>>Modelo 14 (Aereo - Pré-Alerta)</option>
                    <option value="15" <%=cfg.getRelDefaultManifesto().equals("15") ? "selected" : ""%>>Modelo 15 (Rodoviário/Aéreo)</option>
                    <%for (String rel : Apoio.listManifesto(request)) {%> 
                        <option value="doc_manifesto_personalizado_<%=rel%>" <%=cfg.getRelDefaultManifesto().equals("doc_manifesto_personalizado_"+rel) ? "selected" : ""%>>Modelo <%=rel.toUpperCase() %></option>
                    <%}%>

                </select>
            </div></td>
    </tr>
    <tr class="celula">
        <td width="15%"><div align="center">P&aacute;ginas: <b><%=pag%> / <%=qtde_pag%></b></div></td>
        <td height="26" align="center"><div align="right">Impressora: </div></td>
        <td colspan="2">
            <div align="left"><span class="CelulaZebra2">
                    <select name="caminho_impressora" id="caminho_impressora" class="inputtexto">
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
                    </select>
                </span></div></td>
        <td width="8%"><div align="right">Driver:</div></td>
        <td width="10%">
            <div align="left"><!--DIV PARA LISTAR TODOS OS DRIVERS QUE SÃO REFERENTES AO MANIFESTO -->
                <select name="driverImpressora" id="driverImpressora" class="inputtexto">
                    <%Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "man.txt");
                        for (int i = 0; i < drivers.size(); ++i) {
                            String driv = (String) drivers.get(i);
                            driv = driv.substring(0, driv.lastIndexOf("."));
                    %>
                    <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                    <%}%>
                    <% drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "prn.txt");
                        for (int i = 0; i < drivers.size(); ++i) {
                            String driv = (String) drivers.get(i);
                            driv = driv.substring(0, driv.lastIndexOf("."));
                    %>
                    <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                    <%}%>
                </select>
            </div>
        </td>
        <td width="14%"><img src="img/ctrc.gif" class="imagemLink" title="Imprimir manifestos selecionados" onClick="printMatricideManifesto()"></td>
    </tr>
    <%if (cfg.isGeraGSMManifesto()) {%>
    <tr class="celula">
        <td>&nbsp;</td>
        <td height="26" align="center">&nbsp;</td>
        <td width="8%">&nbsp;</td>
        <td colspan="2"><div align="right">Guia de separa&ccedil;&atilde;o: </div></td>
        <td><select name="cbmodeloseparacao" id="cbmodeloseparacao" class="inputtexto">
                <option value="1" selected>Modelo 1</option>
            </select></td>
        <td><img src="img/pdf.jpg" width="25" height="25" border="0" class="imagemLink" title="Formato PDF(usado para a impress&atilde;o)"
                 onClick="javascript:tryRequestToServer(function(){popSeparacao();});"></td>
    </tr>
    <%}%>  
</table>

</form>
</body>
</html>
