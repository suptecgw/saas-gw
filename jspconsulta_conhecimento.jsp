<%@page import="conhecimento.BeanCadConhecimento"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDIBO"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDI"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.BeanConsultaConhecimento,
         nucleo.Apoio,
         nucleo.BeanConfiguracao,
         nucleo.impressora.BeanConsultaImpressora,
         usuario.BeanUsuario,
         java.text.SimpleDateFormat,
         java.util.Vector "%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    boolean userConnected = false;
    BeanUsuario user = Apoio.getUsuario(request);
    userConnected = (user != null);
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelMontagem = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("montagemcarga") : 0);
    int nivelUserManifesto = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadmanifesto") : 0);
    int nivelUserCartaFrete = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lancartafrete") : 0);
    int nivelUserViagem = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanviagem") : 0);
    int nivelUserToFilial = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelCte = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("altnfefilial") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
    boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
    boolean emiteAqueviario = Apoio.getUsuario(request).isEmiteAquaviario();
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    Collection<LayoutEDI> listaLayoutCONEMB = LayoutEDIBO.mostrarLayoutEDI("c", Apoio.getUsuario(request));
    Collection<LayoutEDI> listaLayoutOCOREN = LayoutEDIBO.mostrarLayoutEDI("o", Apoio.getUsuario(request));

// Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String agencia = "";
    String filial = "";
    String filialentrega = "";
    String impressos = "";
    String meusCts = "";
    String idRemetente = "";
    String idRedespachante = "";
    String redespachante = "";
    String remetente = "";
    String idDestinatario = "";
    String destinatario = "";
    String tipoTransporte = "";
    String idConsignatario = "";
    String consignatario = "";
    String idMotorista = "";
    String motorista = "";
    String serie = "";
    String cancelados = "";
    String operadorConsulta = "";
    String tipoFrete = "";
    String limiteResultados = "";
    String ordenacao = "";
    String tipoOrdenacao = "";
    String valorConsulta2 = "";
    String serieNF = "";
    String represColeta = "";
    String idRepresColeta = "";
    String represEntrega = "";
    String idRepresEntrega = "";
    String tipoCTE = "";
    //Cookie
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaCtrc")) {
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
            consulta = new Cookie("consultaCtrc", "");
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
        String dt1 = (consulta.getValue().isEmpty() || splitConsulta.length < 3 ? fmt.format(new Date()) : splitConsulta[2]);
        String dt2 = (consulta.getValue().isEmpty() || splitConsulta.length < 4 ? fmt.format(new Date()) : splitConsulta[3]);
        String ag = (consulta.getValue().isEmpty() || splitConsulta.length < 5 ? "false" : splitConsulta[4]);
        String fl = (consulta.getValue().isEmpty() || splitConsulta.length < 6 ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : splitConsulta[5]);
        String imp = (consulta.getValue().isEmpty() || splitConsulta.length < 7 ? "false" : splitConsulta[6]);
        String ser = (consulta.getValue().isEmpty() || splitConsulta.length < 8 ? "" : splitConsulta[7]);
        String rem = (consulta.getValue().isEmpty() || splitConsulta.length < 9 ? "Todos os remetentes" : splitConsulta[8]);
        String idRem = (consulta.getValue().isEmpty() || splitConsulta.length < 10 ? "0" : splitConsulta[9]);
        String des = (consulta.getValue().isEmpty() || splitConsulta.length < 11 ? "Todos os destinatarios" : splitConsulta[10]);
        String idDes = (consulta.getValue().isEmpty() || splitConsulta.length < 12 ? "0" : splitConsulta[11]);
        String con = (consulta.getValue().isEmpty() || splitConsulta.length < 13 ? "Todos os consignatarios" : splitConsulta[12]);
        String idCon = (consulta.getValue().isEmpty() || splitConsulta.length < 14 ? "0" : splitConsulta[13]);
        String red = (consulta.getValue().isEmpty() || splitConsulta.length < 15 ? "Todos os redespachantes" : splitConsulta[14]);
        String idRed = (consulta.getValue().isEmpty() || splitConsulta.length < 16 ? "0" : splitConsulta[15]);
        String tpTrans = (consulta.getValue().isEmpty() || splitConsulta.length < 17 ? (emiteRodoviario ? "r" : (emiteAereo ? "a" : (emiteAqueviario ? "q" : ""))) : splitConsulta[16]);
        String idMot = (consulta.getValue().isEmpty() || splitConsulta.length < 18 ? "0" : splitConsulta[17]);
        String mot = (consulta.getValue().isEmpty() || splitConsulta.length < 19 ? "Todos os motoristas" : splitConsulta[18]);
        String meu = (consulta.getValue().isEmpty() || splitConsulta.length < 20 ? "false" : splitConsulta[19]);
        String can = (consulta.getValue().isEmpty() || splitConsulta.length < 21 ? "false" : splitConsulta[20]);
        String tipoFre = (consulta.getValue().isEmpty() || splitConsulta.length < 22 ? "false" : splitConsulta[21]);
        String ord = (consulta.getValue().isEmpty() || splitConsulta.length < 24 ? "nfiscal" : splitConsulta[22]);
        String tipoOrd = (consulta.getValue().isEmpty() || splitConsulta.length < 24 ? "" : splitConsulta[23]);
        String vl2 = (consulta.getValue().isEmpty() || splitConsulta.length < 25 ? "" : splitConsulta[24]);
        String serNF = (consulta.getValue().isEmpty() || splitConsulta.length < 26 ? "" : splitConsulta[25]);
        String repColeta = (consulta.getValue().isEmpty() || splitConsulta.length < 27 ? "Todos os representantes das Coletas" : splitConsulta[26]);
        String idRepColeta = (consulta.getValue().isEmpty() || splitConsulta.length < 28 ? "0" : splitConsulta[27]);
        String repEntrega = (consulta.getValue().isEmpty() || splitConsulta.length < 29 ? "Todos os representantes das Entregas" : splitConsulta[28]);
        String idRepEntrega = (consulta.getValue().isEmpty() || splitConsulta.length < 30 ? "0" : splitConsulta[29]);
        String tipoCte = (consulta.getValue().isEmpty() || splitConsulta.length < 31 ? "" : splitConsulta[30]);
        String flEntre = (consulta.getValue().isEmpty() || splitConsulta.length < 32 ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : splitConsulta[31]);

        valorConsulta = (request.getParameter("valor_consulta") != null ? request.getParameter("valor_consulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        agencia = (request.getParameter("minhaagencia") != null ? request.getParameter("minhaagencia") : (ag));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        impressos = (request.getParameter("isNotImpresso") != null ? request.getParameter("isNotImpresso") : (imp));
        idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : (idRem));
        remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : (rem));
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : (idMot));
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : (mot));
        idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : (idDes));
        destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : (des));
        tipoTransporte = (request.getParameter("tipoTransporte") != null ? request.getParameter("tipoTransporte") : (tpTrans));
        idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : (idCon));
        consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : (con));
        idRedespachante = (request.getParameter("idredespachante") != null ? request.getParameter("idredespachante") : (idRed));
        redespachante = (request.getParameter("redspt_rzs") != null ? request.getParameter("redspt_rzs") : (red));
        serie = (request.getParameter("serie") != null ? request.getParameter("serie") : (ser));
        serieNF = (request.getParameter("serie_nf") != null ? request.getParameter("serie_nf") : (serNF));
        meusCts = (request.getParameter("isMeusCts") != null ? request.getParameter("isMeusCts") : (meu));
        cancelados = (request.getParameter("cancelado") != null ? request.getParameter("cancelado") : (can));
        tipoFrete = (request.getParameter("tipoFrete") != null ? request.getParameter("tipoFrete") : (tipoFre));
        ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : (ord));
        tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : (tipoOrd));
        valorConsulta2 = (request.getParameter("valor_consulta2") != null ? request.getParameter("valor_consulta2") : (vl2));
        //11/09/2015
        represColeta = (request.getParameter("representanteColeta") != null ? request.getParameter("representanteColeta") : (repColeta));
        idRepresColeta = (request.getParameter("idRepresentanteColeta") != null ? request.getParameter("idRepresentanteColeta") : (idRepColeta));
        represEntrega = (request.getParameter("representanteEntrega") != null ? request.getParameter("representanteEntrega") : (repEntrega));
        idRepresEntrega = (request.getParameter("idRepresentanteEntrega") != null ? request.getParameter("idRepresentanteEntrega") : (idRepEntrega));
        tipoCTE = (request.getParameter("tipoCTE") != null ? request.getParameter("tipoCTE") : (tipoCte));
        filialentrega = (request.getParameter("filialIdEntrega") != null ? request.getParameter("filialIdEntrega") : (flEntre));
        
        campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                ? request.getParameter("campo")
                : (campo.equals("") ? "emissao_em" : campo));
        operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                ? request.getParameter("ope")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                ? request.getParameter("limite")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        consulta.setValue(URLEncoder.encode(valorConsulta + "!!"
                + campoConsulta + "!!"
                + dataInicial + "!!"
                + dataFinal + "!!"
                + agencia + "!!"
                + filial + "!!"
                + impressos + "!!"
                + serie + "!!"
                + remetente + "!!"
                + idRemetente + "!!"
                + destinatario + "!!"
                + idDestinatario + "!!"
                + consignatario + "!!"
                + idConsignatario + "!!"
                + redespachante + "!!"
                + idRedespachante + "!!"
                + tipoTransporte + "!!"
                + idMotorista + "!!"
                + motorista + "!!"
                + meusCts + "!!"
                + cancelados + "!!"
                + tipoFrete + "!!"
                + ordenacao + "!!"
                + tipoOrdenacao + "!!"
                + valorConsulta2 + "!!"
                + serieNF + "!!"
                + represColeta + "!!"
                + idRepresColeta + "!!"
                + represEntrega + "!!"
                + idRepresEntrega + "!!"
                + tipoCTE + "!!"
                + filialentrega + "!!", "ISO-8859-1"));

        //esse if é para não ocorrer o seguinte erro:
        //a tela setar o operador maior que, por exemplo, e em OUTRA TELA
        //filtrar por nome, razaosocial ou qualquer outra STRING, poderia ficar
        //na SQL o seguinte: varchar >= integer, o que dá erro.
        if (operadorConsulta.equals("1") || operadorConsulta.equals("2") || operadorConsulta.equals("3") || operadorConsulta.equals("4")) {
            operador.setValue(operadorConsulta);
        }
        
            limite.setValue(limiteResultados);
            response.addCookie(consulta);
            response.addCookie(operador);
            response.addCookie(limite);
    } else {
        campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                ? request.getParameter("campo") : "emissao_em");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        agencia = (request.getParameter("minhaagencia") != null ? request.getParameter("minhaagencia") : "false");
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        impressos = (request.getParameter("isNotImpresso") != null ? request.getParameter("isNotImpresso") : "false");
        idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0");
        remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "Todos os remetentes");
        idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0");
        destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "Todos os destinatários");
        idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0");
        consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "Todos os consignatários");
        idRedespachante = (request.getParameter("idredespachante") != null ? request.getParameter("idredespachante") : "0");
        redespachante = (request.getParameter("redspt_rzs") != null ? request.getParameter("redspt_rzs") : "Todos os redespachante");
        tipoTransporte = (request.getParameter("tipoTransporte") != null ? request.getParameter("tipoTransporte") : "false");
        serie = (request.getParameter("serie") != null ? request.getParameter("serie") : "");
        serieNF = (request.getParameter("serie_nf") != null ? request.getParameter("serie_nf") : "");
        meusCts = (request.getParameter("isMeusCts") != null ? request.getParameter("isMeusCts") : "false");
        cancelados = (request.getParameter("cancelado") != null ? request.getParameter("cancelado") : "false");
        tipoFrete = (request.getParameter("tipoFrete") != null ? request.getParameter("tipoFrete") : "false");
        filialentrega = (request.getParameter("filialIdEntrega") != null ? request.getParameter("filialIdEntrega") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : "nfiscal");
        tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : "nfiscal");
        valorConsulta2 = (request.getParameter("valor_consulta2") != null ? request.getParameter("valor_consulta2") : "");
        valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("")        
                ? request.getParameter("valorDaConsulta") : "");
        represColeta = (request.getParameter("representanteColeta") != null ? request.getParameter("representanteColeta") : "");
        idRepresColeta = (request.getParameter("idRepresentanteColeta") != null ? request.getParameter("idRepresentanteColeta") : "0");
        represEntrega = (request.getParameter("representanteEntrega") != null ? request.getParameter("representanteEntrega") : "");
        idRepresEntrega = (request.getParameter("idRepresentanteEntrega") != null ? request.getParameter("idRepresentanteEntrega") : "0");
        tipoCTE = (request.getParameter("tipoCTE") != null ? request.getParameter("tipoCTE") : "");
        operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                ? request.getParameter("ope") : "1");
        limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                ? request.getParameter("limite") : "10");
    }
//   Finalizando Cookie

%>

<%

    BeanConsultaConhecimento beanconh = null;
    String acao = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
//Carregando as configurações
    cfg.CarregaConfig();
    int pag = Apoio.parseInt((request.getParameter("pag") != null ? request.getParameter("pag") : "1"));

    if (acao.equals("iniciar")) {
        acao = "consultar";
        pag = 1;
    }

    if (acao.equals("consultar") || acao.equals("proxima")) {
        beanconh = new BeanConsultaConhecimento();
        beanconh.setConexao(Apoio.getUsuario(request).getConexao());
        beanconh.setExecutor(Apoio.getUsuario(request));
        beanconh.setCampoDeConsulta(campoConsulta);
        beanconh.setValorDaConsulta2(valorConsulta2);
        beanconh.setOperador(Apoio.parseInt(operadorConsulta));
        beanconh.setValorDaConsulta(valorConsulta);
        beanconh.setLimiteResultados(Apoio.parseInt(limiteResultados));
        beanconh.setIsNotImpresso(Boolean.parseBoolean(impressos));
        beanconh.setMeusCts(Boolean.parseBoolean(meusCts));
        beanconh.setApenasCancelados(Boolean.parseBoolean(cancelados));
        beanconh.setTipoFrete(tipoFrete);
        beanconh.setOrdenacaoConsulta(ordenacao + " " + tipoOrdenacao);

        BeanUsuario usu = Apoio.getUsuario(request);
        //Se o usuario tiver permissao para lancar conh para outras filiais entao
        //ele pode visualizar os conh. das outras(quando for 0 vai mostrar todas)
        beanconh.setIdFilialConhecimento(Apoio.parseInt(filial));
        beanconh.setAgency((Boolean.parseBoolean(agencia) ? Apoio.getUsuario(request).getAgencia().getId() : -1));
        beanconh.setDtEmissao1(Apoio.paraDate(dataInicial));
        beanconh.setDtEmissao2(Apoio.paraDate(dataFinal));
        beanconh.setPaginaResultados(pag);
        beanconh.setIdRemetente(Apoio.parseInt(idRemetente));
        beanconh.setIdDestinatario(Apoio.parseInt(idDestinatario));
        beanconh.setIdConsignatario(Apoio.parseInt(idConsignatario));
        beanconh.setIdMotorista(Apoio.parseInt(idMotorista.trim()));
        beanconh.setSerie(serie);
        beanconh.setSerieNF(serieNF);
        beanconh.setTipoTransporte(tipoTransporte);
        beanconh.setIdRedespachante(Apoio.parseInt(idRedespachante));        
        beanconh.setIdRepresentanteColeta(Apoio.parseInt(idRepresColeta));
        beanconh.setIdRepresentanteEntrega(Apoio.parseInt(idRepresEntrega));
        beanconh.setTipoCTE(tipoCTE);
        beanconh.setIdFilialEntrega(Apoio.parseInt(filialentrega));
        // a chamada do método Consultar() está lá em mbaixo
    }
    //se o usuario tiver permissao de excluir
    //Obs.: O teste de permissao para outras filiais esta na instrucao sql.
    if (nivelUser == 4 && acao.equals("excluir")) {
        conhecimento.BeanCadConhecimento cadconh = new conhecimento.BeanCadConhecimento();
        cadconh.setConexao(Apoio.getUsuario(request).getConexao());
        cadconh.setExecutor(Apoio.getUsuario(request));
        cadconh.getConhecimento().setId(Apoio.parseInt(request.getParameter("id")));
%><script language="javascript"><%
    if (!cadconh.Deleta()) {
       if(cadconh.getErros().contains("ainda é referenciada pela tabela sales")){
           if(!cadconh.getNumeroConhecimento().equals("")){
    %>
       alert("Este CT-e não pode ser excluído pois está atrelado a outro CT-e complementar, reentrega ou de devolução! Para localizar esse CT-e você pode filtrar escolhendo o campo de consulta 'NF do Cliente' e digitar o número da NF.");
    <%}}else if(cadconh.getErros().contains("ctrc_recibo_cte_ctrc_id_fkey")){%>
        alert("Atenção!!! Conhecimento não pode ser excluído pois já foi enviado para a SEFAZ e possui status diferente de Negado!");
    <%} else if (cadconh.getErros().contains("recibo_xml_envio_ctrcs_fk")) {%>
        alert('Atenção!!! O Conhecimento não pode ser excluído pois já foi enviado para a SEFAZ.');
    <%} else if (cadconh.getErros().contains("manifesto_conhecimento") || cadconh.getErros().contains("romaneio_ctrc")) {%>
        alert('Atenção!!! O Conhecimento não pode ser excluído pois já está atrelado a um Manifesto/Romaneio.');
    <%}else{%>
    alert("Erro ao tentar excluir!\r\nMensagem: <%=cadconh.getErros()%>");<%
           }}
    %>location.replace("./consultaconhecimento?acao=iniciar");
</script><%

    }

    if (acao.equals("enviarEmail")) {
        //Enviando e-mail para os clientes
        EnviaEmail m = new EnviaEmail();
        m.setCon(Apoio.getUsuario(request).getConexao());
        m.carregaCfg();
        BeanConsultaConhecimento ct = new BeanConsultaConhecimento();
        ct.setConexao(Apoio.getUsuario(request).getConexao());
        ct.setExecutor(Apoio.getUsuario(request));
        ct.consultarCtrcEmail(request.getParameter("idCtrc"), 0, "");
        ResultSet rsCt = ct.getResultado();
        String msg = "";
        String msgErro = "";
        boolean deuCerto = true;
        while (rsCt.next()) {
            String texto = cfg.getMensagemCtrc();
            texto = texto.replaceAll("@@nome_cliente", rsCt.getString("cliente"));
            texto = texto.replaceAll("@@cnpj_cliente", rsCt.getString("cnpj_cliente"));
            texto = texto.replaceAll("@@nota_fiscal", rsCt.getString("notas"));
            texto = texto.replaceAll("@@emissao_ctrc", fmt.format(rsCt.getDate("emissao_em")));
            texto = texto.replaceAll("@@previsao_entrega", (rsCt.getDate("previsao_entrega_em") == null ? "" : fmt.format(rsCt.getDate("previsao_entrega_em"))));
            texto = texto.replaceAll("@@nome_transportadora", Apoio.getUsuario(request).getFilial().getRazaosocial());
            texto = texto.replaceAll("@@ctrc", rsCt.getString("ctrc"));
            texto = texto.replaceAll("@@remetente", rsCt.getString("remetente"));
            texto = texto.replaceAll("@@destinatario", rsCt.getString("destinatario"));
            //Novos a partir 24/09
            texto = texto.replaceAll("@@volume", rsCt.getString("tot_volume"));
            texto = texto.replaceAll("@@peso", rsCt.getString("tot_peso"));
            texto = texto.replaceAll("@@valor_mercadoria", rsCt.getString("tot_valor"));
            //NOVO CAMPO a partir de 28/01/2009
            texto = texto.replaceAll("@@valor_frete", rsCt.getString("valor_frete"));
            texto = texto.replaceAll("@@cidade_destino", rsCt.getString("cidade_destinatario"));

            msg = texto;
            m.setAssunto("CT-e Emitido - Mensagem automática da " + Apoio.getUsuario(request).getFilial().getRazaosocial());
            m.setMensagem(msg);
            m.setPara(rsCt.getString("email"));
            deuCerto = m.EnviarEmail();
            if (!deuCerto) {
                msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\r\n"
                        + "Cliente: " + rsCt.getString("cliente") + "\r\n"
                        + "CT-e: " + rsCt.getString("ctrc") + "\r\n";
            }
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

    if (acao.equals("exportar")) {
        
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        String idCtrc = request.getParameter("idCtrc");
        String modelo = request.getParameter("modelo") != null ? request.getParameter("modelo") : "1";
        //Verificando qual campo filtrar

        //Exportando
        java.util.Map param = new java.util.HashMap(5);
        
        param.put("USUARIO", Apoio.getUsuario(request).getNome());

        if (modelo.indexOf("personalizado") > -1) {
            String relatorio = "doc_ctrc_" + modelo;
            param.put("ID_MOVIMENTACAO", idCtrc);
            param.put("USUARIO",Apoio.getUsuario(request).getNome());     
            param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
            request.setAttribute("map", param);
            request.setAttribute("rel",relatorio);
        }else if(modelo.equals("3")){
            param.put("ID_MOVIMENTACAO", idCtrc);
            param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
            param.put("DIR_HOME",(Apoio.getHomePath()));
            request.setAttribute("map", param);
            request.setAttribute("rel", "dacte_minuta_mod" + modelo);
        }else{
            param.put("ID_MOVIMENTACAO", idCtrc);
            param.put("USUARIO",Apoio.getUsuario(request).getNome());     
            param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
            request.setAttribute("map", param);
            request.setAttribute("rel", "documento_ctrc_mod" + modelo);
        }
        
        conhecimento.BeanCadConhecimento cadconh = new conhecimento.BeanCadConhecimento();
        cadconh.setConexao(Apoio.getUsuario(request).getConexao());
        cadconh.setExecutor(Apoio.getUsuario(request));
        Boolean foi = cadconh.ctrcImpresso(idCtrc);
        
        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=1");
        dispacher.forward(request, response);

    }


%>

<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="java.util.Date"%>
<%@page import="nucleo.EnviaEmail"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>
<html>
    <head>
        <script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
        <script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" >
    shortcut.add("enter",function() {consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value, valor_consulta2.value)});    
    
        jQuery.noConflict();
            var dataAtualSistema = '<%=new SimpleDateFormat("dd/MM/yyyy").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
            function seleciona_campos(){
            <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
                if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null)) {%>
                        $("valor_consulta").focus();
                        document.getElementById("valor_consulta").value = "<%=valorConsulta%>";
                        document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
                        document.getElementById("valor_consulta2").value = "<%=valorConsulta2%>";
                        document.getElementById("operador_consulta").value = "<%=operadorConsulta%>";
                        document.getElementById("limite").value = "<%=limiteResultados%>";
                        $('ordenacao').value = "<%=ordenacao%>";
                        $('tipo_ordenacao').value = "<%=tipoOrdenacao%>";
                        $('filialIdEntrega').value = "<%=Apoio.parseInt(filialentrega)%>";
                        if (getObj("driverImpressora") != null)
                            getObj("driverImpressora").value = "<%=Apoio.getUsuario(request).getFilial().getDriverPadraoImpressora()%>";
            <%}%>
                    if ($("operador_consulta").value == "11" && $('campo_consulta').value != "emissao_em" && $("campo_consulta").value!="baixa_em" && $("campo_consulta").value!="ocorrencia_em" && $("campo_consulta").value!="dtmanifesto"){
                        document.getElementById("divIntervalo").style.display = "";
                        document.getElementById("valor_consulta2").style.display = "";
                        document.getElementById("valor_consulta").size = "8";
                    }
                }
            
                function localizamotorista(){
                    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>','motorista',
                    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
                }

                function consulta(campo, operador, valor, limite, valorConsulta2, filial){
                    try {
                        var data1 = document.getElementById("dtemissao1").value.trim();
                        var data2 = document.getElementById("dtemissao2").value.trim();
                        if (campo == "emissao_em" && !(validaData(document.getElementById("dtemissao1")) && validaData(document.getElementById("dtemissao2")) ))
                        {
                            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
                            return null;
                        }else if(campo == "numero_fatura"){
                            if (valor.split("/").length < 2) {
                                alert("Coloque uma barra \"/\" para informar o ano!");
                                return null;
                            }else if(valor.split("/")[0].trim() == ""){
                                alert("Informe o número da fatura!");
                                return null;
                            }else if(valor.split("/")[1].trim() == ""){
                                alert("Informe o ano da fatura!");
                                return null;
                            }
                        }
                        
                        $("formConsultar").action = "./consultaconhecimento?campo="+campo+"&ope="+operador+
                            "&tipoTransporte="+$('tipoTransporte').value+"&idredespachante="+$('idredespachante').value+
                            "&redspt_rzs="+$('redspt_rzs').value+"&"+
                            concatFieldValue('idremetente,rem_rzs,iddestinatario,dest_rzs,idconsignatario,con_rzs,serie,serie_nf,ordenacao,tipo_ordenacao')+
                            (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&limite="+limite+"&pag=1&acao=consultar&isNotImpresso="+
                            $('impresso').checked+"&isMeusCts="+$('meuscts').checked+"&minhaagencia="+$('minhaagencia').checked+"&idmotorista= "+$("idmotorista").value+
                            "&cancelado="+$('cancelado').checked+
                            "&motor_nome="+$("motor_nome").value + "&tipoFrete="+$("tipoFrete").value + "&representanteColeta=" + $("representanteColeta").value + 
                            "&idRepresentanteColeta=" + $("idRepresentanteColeta").value + "&idRepresentanteEntrega=" + $("idRepresentanteEntrega").value + "&tipoCTE=" + $("tipoCTE").value
                            + "&representanteEntrega=" + $("representanteEntrega").value+ "&filialId="+$("filialId").value +"&filialIdEntrega="+$("filialIdEntrega").value;
                    
                            $("formConsultar").submit();
                    
                    
                    } catch (e) { 
                        alert(e);
                    }
                }

                function editarconhecimento(idmovimento, podeexcluir){
                    location.href = "./frameset_conhecimento?acao=editar&id="+idmovimento+(podeexcluir != null ? "&ex="+podeexcluir : "");
                }

                function proxima(campo, operador, valor, limite, valorConsulta2, filial)
                {
                    var data1 = document.getElementById("dtemissao1").value.trim();
                    var data2 = document.getElementById("dtemissao2").value.trim();
            <%//Somando a pag atual + 1 para a proxima pagina %>
                    location.replace('./consultaconhecimento?campo='+campo+'&valorConsulta2='+valorConsulta2+'&ope='+operador+'&valor='+valor+
                            '&'+concatFieldValue('idremetente,rem_rzs,iddestinatario,dest_rzs,idconsignatario,con_rzs,serie,serie_nf,ordenacao,tipo_ordenacao') +
                            (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&limite="+limite+"&pag=<%=(pag + 1)%>&acao=proxima&isNotImpresso=" +
                            $('impresso').checked+"&isMeusCts="+$('meuscts').checked+"&minhaagencia="+$('minhaagencia').checked+"&idmotorista= "+$("idmotorista").value +
                            "&cancelado="+$('cancelado').checked+
                            "&motor_nome="+$("motor_nome").value + "&tipoFrete="+$("tipoFrete").value + "&representanteColeta=" + $("representanteColeta").value + 
                            "&idRepresentanteColeta=" + $("idRepresentanteColeta").value + "&idRepresentanteEntrega=" + $("idRepresentanteEntrega").value + "&tipoCTE=" + $("tipoCTE").value +
                            "&representanteEntrega=" + $("representanteEntrega").value+ "&filialId="+filial+"&filialIdEntrega="+$("filialIdEntrega").value);
                }

                function anterior(campo, operador, valor, limite, valorConsulta2, filial)
                {
                    var data1 = document.getElementById("dtemissao1").value.trim();
                    var data2 = document.getElementById("dtemissao2").value.trim();
            <%//Somando a pag atual + 1 para a proxima pagina %>
                    location.replace('./consultaconhecimento?campo='+campo+'&valorConsulta2='+valorConsulta2+'&ope='+operador+'&valor='+valor+
                        '&'+concatFieldValue('idremetente,rem_rzs,iddestinatario,dest_rzs,idconsignatario,con_rzs,serie,serie_nf,ordenacao,tipo_ordenacao')+
                        (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&limite="+limite+"&pag=<%=(pag - 1)%>&acao=proxima&isNotImpresso="+
                        $('impresso').checked+"&isMeusCts="+$('meuscts').checked+"&minhaagencia="+$('minhaagencia').checked+"&idmotorista= "+$("idmotorista").value +
                        "&cancelado="+$('cancelado').checked+
                        "&motor_nome="+$("motor_nome").value + "&tipoFrete="+$("tipoFrete").value + "&representanteColeta=" + $("representanteColeta").value + 
                        "&idRepresentanteColeta=" + $("idRepresentanteColeta").value + "&idRepresentanteEntrega=" + $("idRepresentanteEntrega").value + "&tipoCTE=" + $("tipoCTE").value +
                        "&representanteEntrega=" + $("representanteEntrega").value+ "&filialId="+filial+"&filialIdEntrega="+$("filialIdEntrega").value);
                }

                function excluirconhecimento(idmovimento)
                {
                    if (confirm("Deseja mesmo excluir este Conhecimento de transporte?"))
                    {
                        location.replace("./consultaconhecimento?acao=excluir&id="+idmovimento);
                    }
                }

                function habilitaConsultaDePeriodo(opcao)
                {
                    document.getElementById("valor_consulta2").style.display = "none";
                    document.getElementById("divIntervalo").style.display = "none";
                    document.getElementById("valor_consulta").size = "27";
                    document.getElementById("valor_consulta").style.display = (opcao ? "none" : "");
                    document.getElementById("operador_consulta").style.display = (opcao ? "none" : "");
                    document.getElementById("div1").style.display = (opcao ? "" : "none");
                    document.getElementById("div2").style.display = (opcao ? "" : "none");
                    if ($("operador_consulta").value == "11" && $('campo_consulta').value != "emissao_em" && $("campo_consulta").value!="baixa_em" && $("campo_consulta").value!="ocorrencia_em" && $("campo_consulta").value!="dtmanifesto"){
                        document.getElementById("divIntervalo").style.display = "";
                        document.getElementById("valor_consulta2").style.display = "";
                        document.getElementById("valor_consulta").size = "8";
                    }
                    if ($('campo_consulta').value == "numero" || $('campo_consulta').value == "pedido"){
                        $('divLbSerieNF').style.display = ''; 
                        $('divSerieNF').style.display = ''; 
                    }else{
                        $('divLbSerieNF').style.display = 'none'; 
                        $('divSerieNF').style.display = 'none'; 
                    }
                }
                
                function aoCarregar(){                    
                    seleciona_campos();
                    var idConsignatario = $("idconsignatario").value;
                    if (idConsignatario != "0") {
                        carregarLayoutsCliente(idConsignatario);
                    }else{
                        mostrarTodosLayouts();                        
                    }
                    carregarFiliais($("filialId"), "emissao");
                    carregarFiliais($("filialIdEntrega"), "entrega");
                    
            <%if ((acao.equals("consultar") || acao.equals("proxima")) && (campoConsulta.equals("emissao_em") || campoConsulta.equals("baixa_em") || campoConsulta.equals("ocorrencia_em") || campoConsulta.equals("dtmanifesto"))) {%>
                    habilitaConsultaDePeriodo(true);
            <%}%>
                }

                function getCheckedCtrcs(isImprimir){
                    var ids = "";
                    var ctrc = "";
                    var ctrcsImpressos = "";
                    for (i = 0; getObj("ck" + i) != null; ++i){
                        if (getObj("ck" + i).checked){
                            ids += ',' + getObj("ck" + i).value;
                            ctrc = getObj("ck" + i).value;
                            if (getObj("impresso" + ctrc).value == 'true'){
                                ctrcsImpressos += (ctrcsImpressos == '' ? '' : ',') + getObj("numeroctrc" + ctrc).value;
                            }
                        }
                    }
                    if (isImprimir && ctrcsImpressos != '' && !confirm("O(s) CTRC(s) " + ctrcsImpressos + " já foi(ram) impresso(s), deseja imprimir novamente?")){
                        return "";
                    }
                    return ids.substr(1);
                }

                function printMatricideCtrc() {
                    var ctrcs = getCheckedCtrcs(true);
                    function e(transport){
                        var textoresposta = transport.responseText;
                        //se deu algum erro na requisicao...
                        if (textoresposta == "load=0"){
                            return false;
                        }else{
//                            alert(textoresposta); (este alert estava em branco)
                        }
                    }//funcao e()

                    if (ctrcs == "") {
                        alert("Selecione pelo menos um CT-e!");
                        return null;
                    }
                    var url =  "./matricidectrc.ctrc?idmovs="+ctrcs+"&"+concatFieldValue("driverImpressora,caminho_impressora");
                    tryRequestToServer(function(){document.location.href = url;});

                    new Ajax.Request("./consultaconhecimento?acao=enviarEmail&idCtrc="+ctrcs,{method:'post', onSuccess: e, onError: e});

                }

                var dataAtual = '<%=new SimpleDateFormat("yyyyMMdd").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
                var dataAtualRicardo = '<%=new SimpleDateFormat("ddMM").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
                var dataAtualMercador = '<%=new SimpleDateFormat("ddMMyyyyHHmm").format(new Date())%>';
                var dataAtualRoca = '<%=new SimpleDateFormat("yyMM").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
                function exportar(){
                    try {
                        var ctrcs = getCheckedCtrcs(false);
                        var mod = $('cbexportar').value;
                        if (ctrcs == "") {
                            alert("Selecione pelo menos um CT-e!");
                            return null;
                        }

                        console.log("mod: "+mod);
                        if (mod == 'FRONTDIG'){
                            document.location.href = './manifesto.txt2?idctrc='+ctrcs + '&modelo=ctrc';
                        }else if(mod == 'ATM'){
                            document.location.href = './averbacao.txt4?ids='+ctrcs + '&modelo=CTRC';
                        }else if(mod == 'APISUL'){
                            document.location.href = './averbacao.txt5?ids='+ctrcs + '&modelo=CTRC';
                        }else if(mod == 'PORTOSEGURO'){
                            document.location.href = './averbacao.txt8?ids='+ctrcs +'&modelo=CTRC';
                        }else if(mod == 'ITAUSEGUROS'){
                            document.location.href = './averbacao.txt11?ids='+ctrcs +'&modelo=CTRC&acao=itauSeguros';
                        }else
                            if ($("idconsignatario").value == '0'){
                                return alert('Informe o cliente antes de gerar o arquivo.');
                            }else{
                            if(mod=='roca-doccob'){
                                document.location.href = './COBRANCA_000000.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if(mod=='pro3.0a-doccob' || mod=='pro3.0a-doccob-dhl' || mod=='santher3.0a-doccob' || mod=='pro3.0a-doccob-tramontina'){
                                document.location.href = './DOCCOB'+dataAtual+'.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if(mod=='mercador'){
                                document.location.href = './' + $('con_rzs').value + 'CTRC'+dataAtualMercador+'001.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value +
                                    '&filial=0';
                            }else if(mod=='gerdau' || mod=='pro3.0a' || mod=='pro3.1' || mod=='pro3.1gko' || mod == 'nestle'
                                || mod=='pro3.1kimberly' || mod=='santher3.1-conemb' || mod=='pro3.0aTramontina' || mod=='pro3.1betta'
                                || mod=='docile-conemb' || mod == 'bpcs-cremer' || mod == 'tivit3.1-conemb' || mod == 'usiminas' || mod == 'terphane'
                                || mod == 'pro5.0' || mod == 'pro4.0' || mod == 'neogrid_conemb'){
                                document.location.href = './CONEMB'+dataAtual+'.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if (mod == 'ricardo-conemb'){
                                document.location.href = './CTO'+dataAtualRicardo+'.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if (mod == 'roca-ocoren'){
                                document.location.href = './CE'+dataAtualRoca+'.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if (mod == 'electrolux' || mod == 'pro3.0a-ocoren' || mod=='pro3.0a-ocoren-hyper' || mod=='pro3.0a-ocoren-alianca' || mod=='neogrid_ocoren' || mod == 'pro3.1-ocoren' || mod == 'pro3.1-ocoren-betta' || mod == "santher3.1-ocoren" || mod == "docile-ocoren" || mod == "bpcs-cremer-ocoren"  || mod == 'pro5.0-ocoren' || mod == 'tivit3.0a-ocoren'){
                                document.location.href = './OCOREN'+dataAtual+'.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if (mod == 'ricardo-ocoren'){
                                document.location.href = './OCO'+dataAtualRicardo+'0.txt3?modelo='+mod+
                                    '&ctrcs='+ctrcs+'&cliente='+$('con_rzs').value+'&idconsignatario='+$('idconsignatario').value+
                                    "&sped=false";
                            }else if(mod.indexOf("webserviceAvon") > -1){
                                var acao = "consultarCTesAvon";
                                var docum = window.open('about:blank', 'pop', 'width=510, height=200');
                                docum.location.href = "NDDAvonControlador?acao="+acao+"&ids="+ctrcs+"&idfilial="+$("filialId").value+"&"+concatFieldValue("idconsignatario");
                            }else if(mod.indexOf("webserviceClaro") > -1){
                                var acao = "exportarClaroXML";
                                var docum = window.open('about:blank', 'pop', 'width=510, height=200');
                                docum.location.href = "ExportacaoClaroControlador?acao="+acao+"&ids="+ctrcs+"&idfilial="+$("filialId").value+"&"+concatFieldValue("idconsignatario");
                            }else if(mod.indexOf("funcEdi") > -1){
                                var layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_c);
                                if (layout == null) {
                                    layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_o);
                                }
                                var numeroCTE = "";
                                var dataEmissaoCTE = "";
                                var idPrimeiroCTE=  "";

                                
                                if(ctrcs.split(',').length > 1){
                                   idPrimeiroCTE = ctrcs.split(',')[0];
                                }else{
                                   idPrimeiroCTE = ctrcs; 
                                }
                                numeroCTE = $("numeroCTE"+idPrimeiroCTE).value;
                                dataEmissaoCTE = $("emissaoCTE"+idPrimeiroCTE).value;

                                if (layout != null && layout.descricao === "Magazine Luiza (Web Service)") {
                                    var acao = "exportarMagazineLuiza";
                                    var docum = window.open('about:blank', 'pop', 'width=510, height=200');

                                    docum.location.href = "ExportacaoMagazineLuizaControlador?acao=" + acao + "&ids=" + ctrcs + "&idfilial=" + $("filialId").value + "&" + concatFieldValue("idconsignatario");
                                } else if (layout != null) {
                                    var nomeArquivo = layout.nomeArquivo;
                                    horaAtualSistema = new Date();                                    
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
                                            document.location.href = "./"+nomeArquivo+".txt3?modelo=funcEDI&ids="+ctrcs+"&layoutID="+layout.id+"&"+concatFieldValue("idconsignatario");
                                            break;
                                        case "env":
                                            enviarHidroall(layout.id,nomeArquivo);
//                                            document.location.href = "./"+nomeArquivo+".zip?acao=hidroal&ids="+ctrcs+"&layoutID="+layout.id+"&"+concatFieldValue("idconsignatario,dtemissao1,dtemissao2");
                                            break;
                                        case "csv":
                                            document.location.href = "./"+nomeArquivo+".csv?modelo=funcEDI&ids="+ctrcs+"&layoutID="+layout.id+"&"+concatFieldValue("idconsignatario");
                                            break;
                                    }
                                }else{
                                    alert("Não foi possivel gerar arquivo!");
                                }
                            } else if (mod.indexOf('sap-webservice') != -1) {
                                var acao = "exportarSAP";
                                var docum = window.open('about:blank', 'pop', 'width=510, height=200');

                                docum.location.href = "ExportacaoSAPControlador?acao=" + acao + "&ids=" + ctrcs + "&idfilial=" + $("filialId").value + "&" + concatFieldValue("idconsignatario");
                            }
                        }
                    } catch (e) { 
                        alert(e);
                    }
                }

                function enviarHidroall(layout,nomeArquivo){

                    jQuery.ajax({
                        url: './'+nomeArquivo+'.zip',
                        dataType: "text",
                        method: "post",
                        data: {
                            dtinicialedi : $("dtemissao1").value,
                            dtfinaledi : $("dtemissao2").value,
                            idconsignatario : $("idconsignatario").value,
                            layoutID : layout,
                            acao : "hidroal"
                        },
                        success: function(data) {
                            var retorno = JSON.parse(data);
                            alert(retorno.retornoHidroall);
                        }
                    });
                 }

                function viewDups(idMov){
                    if ($("tr_"+idMov).style.display == ''){
                        $('tr_'+idMov).style.display = 'none';
                        $('plus_'+idMov).style.display = '';
                        $('minus_'+idMov).style.display = 'none';
                    }else{
                        $('plus_'+idMov).style.display = 'none';
                        $('minus_'+idMov).style.display = '';
                        $('tr_'+idMov).style.display = '';
                    }
                }

                function mostrarDetalhes(ctrc){
                    var filtros = "tipoFiltro=ctrc&idremetente=0&iddestinatario=0&rem_rzs=&" +
                        "notafiscal=&ctrc="+ctrc+"&dest_rzs=&limite=10&rem_cnpj=&dest_cnpj="+
                        "&chkNaoEntregue=false&chkTrazerColeta=false&dtinicial="+$("dtemissao1").value+
                        "&dtfinal="+$("dtemissao2").value;

                    //Apenas se os filtros estiverem corretos
                    window.open("./consulta_entrega_ctrc.jsp?acao=consultar&"+filtros,
                    "Detalhes" , 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }

                function checkTodos(){
                    //seleciona todos
                    var i = 0 , check = false;

                    if ($("ckTodos").checked){
                        check = true;
                    }

                    while ($("ck"+i) != null){
                        $("ck"+i).checked = check;
                        i++
                    }
                }

                function popitup(url) {
                    if (navigator.userAgent.indexOf('Chrome/') > 0) {
                        if (window.CTe) {
                            window.CTe.close();
                            window.CTe = null;
                        }
                    }
                    window.CTe =window.open(url,'CTe','height=600,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1');
                    if (window.focus) {window.CTe.focus()}
                    return false;
                }

                function abrirCTe(){
            <%if (nivelCte == 0) {%>
                    return alert("Você não tem privelégios suficientes para executar esta ação!");
            <%} else {%>
                    //window.open("./enviar_cte.jsp?acao=consultar&statusCte=P", "CTe", "height=500,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1");

                    popitup("./CTeControlador?acao=listar")
                    //CTe = window.open("./CTeControlador?acao=listar&statusCte=P", "CTe", "height=600,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1");

                    //window.open('', 'CTe', 'top=10,left=0,,,status=1,scrollbars=1');
            <%}%>
                }

                function abrirImportarConhecimentoLote(){
                    location.href ="ConhecimentoControlador?acao=iniciarImportarConhecimentoLote";
                }
                
                function aoClicarNoLocaliza(idjanela){
                //Usado nos filtros Representante Coleta e representante Entrega.
                if(idjanela == "representante_coleta"){
                    $("representanteColeta").value = $("redspt_rzs").value;
                    $("idRepresentanteColeta").value = $("idredespachante").value;
                }
                if(idjanela == "representante_entrega"){
                    $("idRepresentanteEntrega").value = $("idredespachante").value;
                    $("representanteEntrega").value = $("redspt_rzs").value;
                }
                   
                    if (idjanela == "Consignatario_") {
                        carregarLayoutsCliente($("idconsignatario").value);
                    }
                }                

                function popCTRC(id){
                    var modelo = $("modelo") != null ? $("modelo").value : "1"; 
                    
                    if (id == null)
                        return null;
                    launchPDF('./jspconsulta_conhecimento.jsp?acao=exportar&impressao=1&modelo='+modelo+'&idCtrc='+id);
                   

                }
                
                
                
                
                function getCheckeds(){
                   

                    var ids = "0";
                    var ctrc = "";
                    var ctrcsImpressos = "";
                    for (i = 0; getObj("ck" + i) != null; ++i){
                        if (getObj("ck" + i).checked){
                            ids += ',' + getObj("ck" + i).value;
                            ctrc = getObj("ck" + i).value;
                            if (getObj("impresso" + ctrc).value == 'true'){
                                ctrcsImpressos += (ctrcsImpressos == '' ? '' : ',') + getObj("numeroctrc" + ctrc).value;
                            }
                        }
                    }
                    
                    
                    return ids/*.substr()*/;
                }

                function printCtrcs() {
                    
                 
                    
                    var ctrcs = getCheckeds();
                    if(ctrcs == "0") {
                        alert("Selecione pelo menos um CT-e!");
                        return null;
                    }
                       
                    
                    
                    popCTRC(ctrcs);
                }
                
                              
                //*************************   EDI DINAMICO  ********************* INICIO
                var layoutsFunctionAll_c = new Array();
                var layoutsFunctionAll_f = new Array();
                var layoutsFunctionAll_o = new Array();
                var idxAll_c = 0;
                var idxAll_f = 0;
                var idxAll_o = 0;
                
                var idxLayTela = 0;
                var listLayoutEDITela = new Array();
                var idxLay_c = 0;
                var listLayoutEDI_c = new Array();
                var idxLay_o = 0;
                var listLayoutEDI_o = new Array();
            
                var layoutsCliente_c = new Array();
                var layoutsCliente_o = new Array();
                var idxO = 0;
                var idxC = 0;
            
                listLayoutEDITela[idxLayTela++] = new Option("FRONTDIG", "Fronteira Digital PE");
                listLayoutEDITela[idxLayTela++] = new Option("APISUL","Averba&ccedil;&atilde;o (APISUL)");
                listLayoutEDITela[idxLayTela++] = new Option("ATM","Averba&ccedil;&atilde;o (AT&amp;M)");
                listLayoutEDITela[idxLayTela++] = new Option("PORTOSEGURO","Averba&ccedil;&atilde;o (PORTO SEGURO)");
                listLayoutEDITela[idxLayTela++] = new Option("ITAUSEGUROS","Averba&ccedil;&atilde;o (ITAU SEGUROS)");
            
                listLayoutEDI_c[idxLay_c++] = new Option("---","--------------------------------------------------------------");
                listLayoutEDI_c[idxLay_c++] = new Option("bpcs-cremer","EDI-CONEMB(BPCS - Cremer S/A)");
                listLayoutEDI_c[idxLay_c++] = new Option("docile-conemb","EDI-CONEMB(EMS Datasul/Totvs - Docile Ltda)");
                listLayoutEDI_c[idxLay_c++] = new Option("gerdau","EDI-CONEMB(Gerdau)");
                listLayoutEDI_c[idxLay_c++] = new Option("mercador","EDI-CONEMB(Mercador)");
                listLayoutEDI_c[idxLay_c++] = new Option("neogrid_conemb","EDI-CONEMB(NeoGrid)");
                listLayoutEDI_c[idxLay_c++] = new Option("nestle","EDI-CONEMB(Nestle)");
                listLayoutEDI_c[idxLay_c++] = new Option("pro3.0a","EDI-CONEMB(Proceda 3.0a)");
                listLayoutEDI_c[idxLay_c++] = new Option("pro3.0aTramontina","EDI-CONEMB(Proceda 3.0a-Tramontina)");
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
                listLayoutEDI_c[idxLay_c++] = new Option("webserviceAvon_con","EDI-CONEMB(Avon (Web Service Consulta))");
                listLayoutEDI_c[idxLay_c++] = new Option("webserviceClaro", "Claro S/A (XML CTE - Web Service)");
            <%for (LayoutEDI layout : listaLayoutCONEMB) {%>
                listLayoutEDI_c[idxLay_c++] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
                layoutsFunctionAll_c[idxAll_c++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
            <%}%>
            
                listLayoutEDI_o[idxLay_o++] = new Option("---","--------------------------------------------------------------");
                listLayoutEDI_o[idxLay_o++] = new Option("docile-ocoren","EDI-OCOREN(EMS Datasul/Totvs - Docile Ltda)");
                listLayoutEDI_o[idxLay_o++] = new Option("electrolux","EDI-OCOREN(Electrolux)");
                listLayoutEDI_o[idxLay_o++] = new Option("neogrid_ocoren","EDI-OCOREN(NeoGrid)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro3.0a-ocoren","EDI-OCOREN(Proceda 3.0a)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro3.0a-ocoren-alianca","EDI-OCOREN (Proceda 3.0a - Alian&ccedil;a)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro3.0a-ocoren-alianca","EDI-OCOREN (Proceda 3.0a - Alian&ccedil;a)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro3.0a-ocoren-hyper","EDI-OCOREN (Proceda 3.0a - Hypermarcas)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro3.1-ocoren" ,"EDI-OCOREN(Proceda 3.1)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro3.1-ocoren-betta","EDI-OCOREN(Proceda 3.1 - Bettanin)");
                listLayoutEDI_o[idxLay_o++] = new Option("pro5.0-ocoren","EDI-OCOREN(Proceda 5.0)");
                listLayoutEDI_o[idxLay_o++] = new Option("ricardo-ocoren","EDI-OCOREN(Ricardo Eletro)");
                listLayoutEDI_o[idxLay_o++] = new Option("roca-ocoren","EDI-OCOREN(Roca Brasil)");
                listLayoutEDI_o[idxLay_o++] = new Option("santher3.1-ocoren","EDI-OCOREN(Santher 3.1)");
                listLayoutEDI_o[idxLay_o++] = new Option("tivit3.0a-ocoren","EDI-OCOREN(Tivit 3.0a)");
                listLayoutEDI_o[idxLay_o++] = new Option("sap-webservice", "SAP (Web Service)");
            <%for (LayoutEDI layout : listaLayoutOCOREN) {%>
                listLayoutEDI_o[idxLay_o++] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
                layoutsFunctionAll_o[idxAll_o++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
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
                
                 
                 function carregarFiliais(elemento, tipoFilialSelect){
                    var filialUsada = (tipoFilialSelect == "entrega" ? $("idfilialEntreusada").value : $("idfilialusada").value );
                    jQuery.ajax({
                        url: '<c:url value="/FilialControlador" />',
                        dataType: "text",
                        method: "post",
                        contentType: "application/json; charset=utf-8",
                        data: {
                            tipoFilialSelect: tipoFilialSelect,
                            acao : "listarFilialFranquia",
                            idFilial: $("filialId").value
                        },
                        success: function(data) {
                            var filiais = jQuery.parseJSON(data);
                            if (filiais != null) {
                                var selectbox = jQuery("#"+elemento.name);
                                selectbox.find('option').remove();
                                var maxFilial = (filiais != undefined && filiais.list[0].filialFranquia.length != undefined ? filiais.list[0].filialFranquia.length : 1);
                                for (var i = 0; i < maxFilial; i++) {
                                    if (maxFilial > 1) {
                                        if (i == 0) {
                                            jQuery('<option>').val(0).text("TODAS AS FILIAIS").appendTo(selectbox);
                                        }
                                        jQuery('<option>').val(filiais.list[0].filialFranquia[i].id).text("APENAS A " + filiais.list[0].filialFranquia[i].abreviatura).appendTo(selectbox);
                                    } else {
                                        jQuery('<option>').val(0).text("APENAS A " + filiais.list[0].filialFranquia.abreviatura).appendTo(selectbox);
                                    }
                                }
                                jQuery(jQuery("#"+elemento.name)).val(filialUsada);
                            }
                        },error: function(){
                            alert("Erro ao carregar a lista de filiais!");
                        }
                    });
                }
            
                function carregarLayoutsCliente(clienteId){
                    try {
                        function e(transport){
                            var textoresposta = transport.responseText;
                            var lista = jQuery.parseJSON(textoresposta).list[0];
                            if (lista != "") {
                                var listaEDI = lista.listaClienteLayoutsEDI;
                                var length = (listaEDI != undefined && listaEDI.length != undefined ? listaEDI.length : 1);
                                for(var i = 0; i < length; i++){
                                    if(length > 1){
                                        switch(listaEDI[i].tipo){
                                            case "c":
                                                layoutsCliente_c[idxC++] = (listaEDI[i]);
                                                break;
                                            case "o":
                                                layoutsCliente_o[idxO++] = (listaEDI[i]);
                                                break;
                                        }
                                    }else{
                                        switch(listaEDI.tipo){
                                            case "c":
                                                layoutsCliente_c[idxC++] = (listaEDI);
                                                break;
                                            case "o":
                                                layoutsCliente_o[idxO++] = (listaEDI);
                                                break;
                                        }
                                    
                                    }
                                }
                                removeOptionSelected("cbexportar");
                                removerEDI($("cbexportar"), layoutsCliente_c, listLayoutEDI_c, "c");
                                removerEDI($("cbexportar"), layoutsCliente_o, listLayoutEDI_o, "o");
                            }else{
                                mostrarTodosLayouts();
                            }
                        
                        }//funcao e()
                        tryRequestToServer(function(){
                            new Ajax.Request("LayoutEDIControlador?acao=ajaxCarregarClienteLayoutEDI&cliente_id="+clienteId,{method:'post', onSuccess: e, onError: e});
                        });
                    } catch (e) { 
                        alert("Erro ao carregar a lista de layouts para EDI do cliente!"+e)
                    }
                
                }
            
                function getFuncLayoutEDI(valor, layoutsCliente){
                    var retorno = null;
                    for (i = 0; i < layoutsCliente.size(); i++) {
                        if (layoutsCliente[i].layoutEDI.id == valor) {
                            retorno =  layoutsCliente[i].layoutEDI;
                            break;
                        }
                    }
                    return retorno;
                }
            
                function povoarSelect(elemento, lista, isDivisao, tipo){
                    try {
                        if (isDivisao && tipo == "o") {
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
                    removeOptionSelected("cbexportar");
                    povoarSelect($("cbexportar"), listLayoutEDITela, false, "");
                    povoarSelect($("cbexportar"), listLayoutEDI_c, false, "");
                    povoarSelect($("cbexportar"), listLayoutEDI_o, false, "");
                }
                //*************************   EDI DINAMICO  ********************* FIM
    function localizarRepresColeta(){
        launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>', 'representante_coleta');
    }
    function limparRepresentanteColeta(){
        $("idRepresentanteColeta").value = "0";
        $("representanteColeta").value = "Todos os representantes das Coletas";
    }
    function localizarRepresEntrega(){
        launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>', 'representante_entrega');
    }
    function  limparRepresentanteEntraga(){
        $("representanteEntrega").value = "Todos os representantes das Entregas";
        $("idRepresentanteEntrega").value = "0";
    }
    
    function desativarCTeGWi(idCTe, numeroCTe){            
            
        if (confirm("Deseja desativar o CT-e " + numeroCTe + " do GW-i?")) { 
            window.open("./ConhecimentoControlador?acao=desativarCTeGWi&idCTe="+idCTe, "pop", "width=210, height=100");
        }
            
    }
    
    function alteraTipoFilial(){
        carregarFiliais($("filialIdEntrega"), "entrega");
    }

            function abrirPopAuditoria() {
                tryRequestToServer(function () {
                    var url = "ConhecimentoControlador?acao=auditoriacte&isExclusao=true";

                    window.open(url, 'auditoriaCteExclusao', 'toolbar=no,left=0,top=0,location=no,status=no,menubar=no,scrollbars=yes,resizable=no');
                });
            }

        </script>


        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Consulta de CT-e(s)</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style8 {font-size: 11px}
            -->
        </style>
    </head>

    <body onLoad="javascript:aoCarregar();applyFormatter();">
    <form method="post" id="formConsultar">
        <img src="img/banner.gif"  alt=""><br>
        <input type="hidden" name="idremetente" id="idremetente" value="<%=idRemetente%>">
        <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=idDestinatario%>">
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=idConsignatario%>">
        <input type="hidden" name="idredespachante" id="idredespachante" value="<%=idRedespachante%>">
        <input type="hidden" name="redspt_rzs" id="redspt_rzs" value="<%=redespachante%>">
        <input type="hidden" name="idmotorista" id="idmotorista" value="<%=idMotorista%>">       
        <input type="hidden" name="idfilialusada" id="idfilialusada" value="<%=(request.getParameter("filialId") != null ? request.getParameter("filialId") : "0")%>">
        <input type="hidden" name="idfilialEntreusada" id="idfilialEntreusada" value="<%=(request.getParameter("filialIdEntrega") != null ? request.getParameter("filialIdEntrega") : "0")%>">
        <label style="display: none" id="usuarioLogado"><%=(userConnected ? user.getLogin() : "")%></label>
        <table width="99%" align="center" class="bordaFina" >
            <tr>
                <td width="40%">
                    <div align="left">
                        <b>Consulta de CT-e(s)</b>
                    </div>
                </td>
                <td width="15%" align="center">
                    <input type="button" class="botoes" value="Visualizar Auditoria" id="bt_auditoria" name="bt_auditoria" onClick="abrirPopAuditoria();">
                </td>
                <td width="15%" align="center">
                    <input type="button" onClick="javascript:tryRequestToServer(function(){abrirCTe();});" value="Visualizar CT-e(s)" class="inputBotao">
                </td>
                <td width="15%" align="center">
                    <input name="butImportarConhecimento" type="button" class="botoes" id="butImportarConhecimento" onClick="javascript:tryRequestToServer(function(){abrirImportarConhecimentoLote();});" value="Incluir Conhecimentos em Lote">
                </td>

                <% if (nivelUser >= 3) {%>
                <%if (nivelMontagem > 3) {%>
                <td width="15%" align="center">
                    <input name="novamontagem" type="button" class="botoes" id="novamontagem" onClick="javascript:tryRequestToServer(function(){location.href = './montar_carga.jsp?acao=iniciar';});" value="Montar uma nova carga">
                </td>
                <%}%>
                <td width="15%" align="center">
                    <input name="novoconhecimento" type="button" class="botoes" id="novoconhecimento" onClick="javascript:tryRequestToServer(function(){location.href = './frameset_conhecimento?acao=iniciar';});" value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="12%"  height="5">
                    <select class="inputTexto" name="campo_consulta" id="campo_consulta" style="width: 120px;" onChange="javascript:habilitaConsultaDePeriodo(this.value=='emissao_em' || this.value=='baixa_em' || this.value=='ocorrencia_em' || this.value=='dtmanifesto');">
                        <option value="emissao_em">Data de emiss&atilde;o</option>
                        <option value="baixa_em">Data de entrega</option>
                        <option value="ocorrencia_em">Data da ocorr&ecirc;ncia</option>
                        <option value="nfiscal" selected>Número do CT-e</option>
                        <option value="chave_acesso_cte">Chave do CT-e</option>
                        <option value="numero">NF do cliente</option>
                        <option value="pedido">Pedido/Carga da NF do cliente</option>
                        <option value="pedido_cliente">Pedido do cliente</option>
                        <option value="numero_carga">Número da carga</option>
                        <option value="ct.numero_container">Número Container</option>
                        <option value="ct.house_awb">House AWB</option>
                        <option value="ct.master_awb">Master AWB</option>
                        <option value="dtmanifesto">Data do Manifesto</option>
                        <option value="m.nmanifesto">Número do Manifesto</option>
                        <option value="numero_fatura">Número da Fatura/Ano</option>
                        <option value="token">Código Localizador</option>
                    </select>
                </td>
                <td width="20%">
                    <select name="operador_consulta" id="operador_consulta" class="inputTexto" style="width: 190px;" onChange="javascript:habilitaConsultaDePeriodo($('campo_consulta').value=='emissao_em' || $('campo_consulta').value=='baixa_em' || $('campo_consulta').value=='ocorrencia_em' || this.value=='dtmanifesto');">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (V&aacute;rios separados por vírgula)</option>
                        <option value="11">Igual &agrave; palavra/frase (Intervalo entre)</option>
                        <option value="5" selected>Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">
                        De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" value="<%=dataInicial%>"
                               class="fieldDate" onBlur="alertInvalidDate(this)">
                    </div>      
                </td>
                <td width="12%">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">
                        Até:
                        <input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" value="<%=dataFinal%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <input name="valor_consulta" type="text" id="valor_consulta" size="27" class="inputtexto">	  
                    <label name="divIntervalo" id="divIntervalo" style="display:none"> e </label>
                    <input name="valor_consulta2" type="text" id="valor_consulta2" size="8" class="inputtexto" style="display:none">	  
                </td>
                <td width="15%">
                    <label>Emissão:</label>
                    <select name="filialId" id="filialId" style="font-size:8pt;" class="inputTexto" onchange="alteraTipoFilial();"></select>
                    <br/>
                    <label>Entrega:</label>
                    <select name="filialIdEntrega" id="filialIdEntrega" style="font-size:8pt;" class="inputTexto"></select>
                </td>
                <td colspan="4">
                    <div align="left">
                        <input name="minhaagencia" type="checkbox" id="minhaagencia" <%=(Boolean.parseBoolean(agencia) ? "checked" : "")%> style="display:<%=(nivelUserToFilial > 0 ? "" : "none")%>;" >
                        <span class="style8"><%=(nivelUserToFilial > 0 ? "Mostrar apenas CT-e(s) da minha agência." : "")%></span>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td  height="6" colspan="2">
                    <div align="center">
                        Rem.:
                        <input name="rem_rzs" type="text" id="rem_rzs" value="<%=remetente%>" size="30" readonly="true" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');;">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os remetentes';">
                    </div>
                </td>
                <td colspan="2">
                    <div align="center">
                        Con.:
                        <input name="con_rzs" type="text" id="con_rzs" value="<%=consignatario%>" size="30" readonly="true" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Consignatario_');">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idconsignatario').value = '0';getObj('con_rzs').value = 'Todos os consignatarios';">
                    </div>
                </td>                
                <td colspan="4">
                    <div align="left">
                        <input name="impresso" type="checkbox" id="impresso" <%=(impressos.equals("true") ? "checked" : "")%>>
                        <span class="style8">Mostrar apenas CT-e(s) n&atilde;o impressos.</span>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td  height="13" colspan="2">
                    <div align="center">
                        Des.:
                        <input name="dest_rzs" type="text" id="dest_rzs" value="<%=destinatario%>" size="30" readonly="true" class="inputReadOnly8pt">
                        <strong>
                            <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                        </strong>
                    </div>
                </td>
                <td>
                    <div align="right">Apenas a s&eacute;rie do CT:</div>
                    <div align="right" id="divLbSerieNF" name="divLbSerieNF" style='display:<%=campoConsulta.equals("numero") || campoConsulta.equals("pedido") ? "" : "none" %>'>Apenas a s&eacute;rie da NF do cliente:</div>
                </td>
                <td width="19%">
                    <div align="left">
                        <input name="serie" type="text" id="serie" size="3" value="<%=serie%>" class="inputtexto">
                        <div id="divSerieNF" name="divSerieNF" style='display:<%=campoConsulta.equals("numero") || campoConsulta.equals("pedido") ? "" : "none" %>'>
                            <input name="serie_nf" type="text" id="serie_nf" size="3" value="<%=serieNF%>" class="inputtexto">
                        </div>
                    </div>
                </td>
                <td width="34%" colspan="4">
                    <div align="left">
                        <input name="meuscts" type="checkbox" id="meuscts" <%=(meusCts.equals("true") ? "checked" : "")%>>
                        <span class="style8">Mostrar CT-e(s) Criados Por Mim</span>
                    </div>
                </td>
            </tr>
            <tr class="celula">               
                <td class="celula">
                    <div align="right">Tipo do Transporte:</div>
                        <td>
                            <div align="left">
                                <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:160px;"   class="fieldMin">
                                    <%= emiteRodoviario && emiteAereo && emiteAqueviario? "<option value='false'" + (tipoTransporte != null && tipoTransporte.equals("false") ? "selected" : "") + ">Todos</option>" : ""%>
                                    <%= emiteRodoviario ? "<option value='r'" + (tipoTransporte != null && tipoTransporte.equals("r") ? "selected" : "") + ">CTR - Transp. Rodoviário</option>" : ""%>
                                    <%= emiteAereo ? "<option value='a'" + (tipoTransporte != null && tipoTransporte.equals("a") ? "selected" : "") + " >CTA - Transp. A&eacute;reo</option>" : ""%>
                                    <%= emiteAqueviario ? "<option value='q'" + (tipoTransporte != null && tipoTransporte.equals("q") ? "selected" : "") + ">CTQ - Transp. Aquavi&aacute;rio</option>" : ""%>
                                </select>
                            </div>
                        </td>                   
                </td>
                <td colspan="2">
                    <div align="center">
                        Motorista:
                        <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" value="<%=motorista%>" size="30" readonly="true">
                        <strong>
                            <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:localizamotorista();">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';getObj('motor_nome').value = 'Todos os motoristas';">
                        </strong>
                    </div>
                </td>
                <td colspan="4">
                    <div align="left">
                        <input name="cancelado" type="checkbox" id="cancelado" <%=(cancelados.equals("true") ? "checked" : "")%>>
                        <span class="style8">Mostrar Apenas CT-e(s) Cancelados</span>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td colspan="2">
                    <div align="center">Repr. Entrega:
                        <input id="representanteEntrega" type="text" class="inputReadOnly8pt" value="<%=represEntrega%>" size="30" readonly="true" name="representanteEntrega"/>
                        <input id="idRepresentanteEntrega" type="hidden" value="<%=idRepresEntrega%>" name="idRepresentanteEntrega"/>
                        <strong>
                            <input type="button" class="botoes" value="..." onclick="localizarRepresEntrega();"/>
                            <img src="img/borracha.gif" class="imagemLink" onclick="limparRepresentanteEntraga();"/>
                        </strong>
                    </div>                    
                </td>
                <td colspan="2">                    
                    <div align="center">Repr. Coleta:
                        <input id="representanteColeta" type="text" class="inputReadOnly8pt" value="<%=represColeta%>" size="30" readonly="true" name="representanteColeta"/>
                         <input id="idRepresentanteColeta" type="hidden" value="<%=idRepresColeta%>" name="idRepresentanteColeta"/>
                        <strong>
                            <input type="button" class="botoes" value="..." onclick="localizarRepresColeta();"/>
                            <img src="img/borracha.gif" class="imagemLink" onclick="limparRepresentanteColeta();"/>
                        </strong>
                    </div>                    
                </td>
                <td colspan="4"></td>
            </tr>
            <tr class="celula">
                <td class="celula">                
                    <div align="right">Tipo de Frete:</div>
                        <td>
                            <div align="left">
                                <select name="tipoFrete" id="tipoFrete" class="inputTexto">
                                    <option value="false" <%=(tipoTransporte.equals("false") ? "selected" : "")%>>Todos</option>
                                    <option value="CIF" <%=(tipoFrete.equals("CIF") ? "selected" : "")%>>CIF</option>
                                    <option value="FOB" <%=(tipoFrete.equals("FOB") ? "selected" : "")%>>FOB</option>
                                    <option value="RED" <%=(tipoFrete.equals("RED") ? "selected" : "")%>>RED</option>
                                    <option value="CON" <%=(tipoFrete.equals("CON") ? "selected" : "")%>>CON</option>
                                </select>
                            </div>
                        </td> 
                </td>
                <td class="celula">                
                    <div align="right">Tipo de CT-E:</div>
                        <td>
                            <div align="left">
                                <select name="tipoCTE" id="tipoCTE" class="inputTexto">
                                    <option value="" <%=(tipoCTE.equals("") ? "selected" : "")%> selected="">Todos</option>
                                    <option value="n" <%=(tipoCTE.equals("n") ? "selected" : "")%>>Normal</option>
                                    <option value="l" <%=(tipoCTE.equals("l") ? "selected" : "")%>>Entrega Local (Cobrança)</option>
                                    <option value="i" <%=(tipoCTE.equals("i") ? "selected" : "")%>>Diárias</option>
                                    <option value="p" <%=(tipoCTE.equals("p") ? "selected" : "")%>>Pallets</option>
                                    <option value="c" <%=(tipoCTE.equals("c") ? "selected" : "")%>>Complementar</option>
                                    <option value="r" <%=(tipoCTE.equals("r") ? "selected" : "")%>>Reentrega</option>
                                    <option value="d" <%=(tipoCTE.equals("d") ? "selected" : "")%>>Devolução</option>
                                    <option value="b" <%=(tipoCTE.equals("b") ? "selected" : "")%>>Cortesia</option>
                                    <option value="s" <%=(tipoCTE.equals("s") ? "selected" : "")%>>Substituição</option>
                                    <option value="a" <%=(tipoCTE.equals("a") ? "selected" : "")%>>Anulação</option>
                                </select>
                            </div>
                        </td> 
                </td>
                <td>
                    <div align="right">Ordenação:</div>
                    <td>
                        <div align="left">
                            <select class="inputTexto" name="ordenacao" id="ordenacao" style="width: 120px;">
                                <option value="emissao_em">Data de emiss&atilde;o</option>
                                <option value="nfiscal" selected>Número do CT-e</option>
                                <option value="pedido_cliente">Pedido do cliente</option>
                                <option value="numero_carga">Número da carga</option>
                                <option value="ct.numero_container">Número Container</option>
                            </select>      
                            <select class="inputTexto" name="tipo_ordenacao" id="tipo_ordenacao">
                                <option value="" selected>Crescente</option>
                                <option value="desc">Decrescente</option>
                            </select>
                        </div>
                    </td>
                </td>
                <td>
                    <div align="center">
                        <input name=" pesquisar " type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value, valor_consulta2.value, filialId.value);});">
                    </div>
                </td>
                <td class="celula">
                    <div align="center">Por p&aacute;g.:
                        <select name="limite" id="limite" class="inputTexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                            <option value="100">100 resultados</option>
                            <option value="200">200 resultados</option>
                            <option value="1000">1000 resultados</option>
                            <option value="2000">2000 resultados</option>
                        </select>
                    </div>
                </td>
                
            </tr>
        </table>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="2%">
                    <input name="ckTodos" type="checkbox" value="1" id="ckTodos" onClick="checkTodos()">
                </td>
                <td width="2%"></td>
                <td width="2%"></td>
                <td width="2%"><img src="img/pdf.gif" border="0" align="right" class="imagemLink" onClick="javascript:tryRequestToServer(function(){printCtrcs()});"></td>
                <td width="6%">CT-e</td>
                <td width="4%" align="left">S&eacute;rie</td>
                <td width="7%" align="left">Tipo do CT-E</td>
                <td width="4%" align="left">Frete</td>
                <td width="8%">Dt.Emiss&atilde;o</td>
                <td width="10%">Filial/Ag.</td>
                <td width="24%">Remetente</td>
                <td width="24%">Destinat&aacute;rio</td>
                <td align="right" width="8%">Total</td>
                <td width="2%"></td>
            </tr>
            <% //variaveis da paginacao
                int linhatotal = 0;
                int linha = 0;
                int qtde_pag = 0;
                String cor = "";

                // se conseguiu consultar
                if ((acao.equals("consultar") || acao.equals("proxima")) && (beanconh.Consultar())) {
                    ResultSet rs = beanconh.getResultado();
                    while (rs.next()) {
                        cor = (rs.getBoolean("is_cancelado") ? "#CC0000" : "");
                        //pega o resto da divisao e testa se é par ou impar
            %> 
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td width="20">
                    <input name="ck<%=linha%>" type="checkbox" value="<%=rs.getInt("id")%>" id="ck<%=linha%>">
                    <input name="impresso<%=rs.getInt("id")%>" type="hidden" value="<%=rs.getBoolean("is_impresso")%>" id="impresso<%=rs.getInt("id")%>">
                    <input name="numeroctrc<%=rs.getInt("id")%>" type="hidden" value="<%=rs.getString("numero")%>" id="numeroctrc<%=rs.getInt("id")%>">
                    <input type="hidden" name="numeroCTE<%=rs.getString("id")%>" id="numeroCTE<%=rs.getString("id")%>" value="<%=rs.getString("numero")%>">
                    <input type="hidden" name="emissaoCTE<%=rs.getString("id")%>" id="emissaoCTE<%=rs.getString("id")%>" value="<%=new SimpleDateFormat("ddMMyyyy").format(rs.getDate("emissao_em"))%>">
                    <input type="hidden" name="emissaoCTE2<%=rs.getString("id")%>" id="emissaoCTE2<%=rs.getString("id")%>" value="<%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("emissao_em"))%>">
                </td>
                <td>
                    <img src="img/lupa.gif" id="lupa_<%=rs.getString("id")%>" name="lupa_<%=rs.getInt("id")%>" title="Mostrar todos os detalhes" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function(){mostrarDetalhes('<%=rs.getString("numero")%>');});">
                </td>
                <td>
                    <% if ( rs.getInt("created_by") == 8888 ) { %>
                        <% if (rs.getBoolean("is_desativado_gwi")) {%>
                            <img src="img/gwi-desativado.png" width="30" height="30" style="margin-right: 4px;margin-left: 4px;" title="CT-e desativado do GW-i"/>
                        <% } else { %>
                            <img class="imagemLink" src="img/gwi-ativo.png" width="30" height="30" style="margin-right: 4px;margin-left: 4px;" title="Desativar CT-e do GW-i" onclick="javascript:tryRequestToServer(function(){desativarCTeGWi('<%=rs.getString("id")%>','<%=rs.getString("numero")%>');});"/>
                        <% } %>
                    <% } %>
                </td>
                <td>
                    <div align="center">
                        <img src="img/pdf.gif" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popCTRC('<%=rs.getString("id")%>');});">
                    </div>
                </td>
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarconhecimento(<%=rs.getString("id") + ",null"%>);});">
                        <%=rs.getString("numero")%>
                    </div>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("serie") + "/" + rs.getString("especie")%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=(rs.getString("tipo_do_conhecimento"))%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=(rs.getString("tipo"))%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("emissao_em"))%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("fi_abreviatura") + (rs.getString("agencia") == null ? "" : "<br>" + rs.getString("agencia"))%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("rem_rzs")%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("des_rzs")%>
                    </font>
                </td>
                <td align="right">
                    <font color=<%=cor%>>
                    <%=rs.getString("ct_total")%>
                    </font>
                </td>
                <td>
                    <% if ((nivelUser == 4)
                                && //se o ctrc pertencer a outra filial, verificar nivel de acesso para filiais...
                                !((rs.getInt("filial_id") != user.getFilial().getIdfilial()) && (nivelUserToFilial < 4))) {%>
                                <img src="img/lixo.png" title="Excluir este registro" style="display:<%=rs.getBoolean("is_cancelado") && "P".equals(rs.getString("st_utilizacao")) ? "none" : ""%>"
                         onclick="javascript:tryRequestToServer(function(){excluirconhecimento(<%=rs.getString("id")%>);});">
                    <%}%>
                </td>
            </tr>
            <% if (rs.isLast()) {
                            //Quantidade geral de resultados da consulta
                            linhatotal = rs.getInt("qtd_resultados");
                        }
                        linha++;
                    }//while
                    //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
                      qtde_pag = ((linhatotal % Apoio.parseInt(limiteResultados)) == 0
                          ? (linhatotal / Apoio.parseInt(limiteResultados))
                          : (linhatotal / Apoio.parseInt(limiteResultados)) + 1);
                }//if
                //pag = ( qtde_pag == 0 ? 0 : pag );
            %>
        </table>
        <br>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr>
                <td width="26%">
                    <table width="100%" align="center" cellspacing="1">
                        <tr class="celula" height="25px">
                            <td width="50%">
                                <center>
                                    Ocorr&ecirc;ncias: 
                                    <b> <%= linha %> / <%= linhatotal %></b>
                                </center>
                            </td>
                            <td width="50%">
                                <div align="center">
                                    P&aacute;gina Atual: 
                                    <b><%=pag%> / <%= qtde_pag %></b>
                                </div>
                            </td>
                        </tr>    
                        <tr class="celula" height="25px">
                            <td>
                                <div align="center">
                                    <input name="avancar" type="button" class="botoes" id="avancar" value="Página Anterior" onClick="javascript:tryRequestToServer(function(){anterior('<%=campoConsulta%>','<%=operadorConsulta%>','<%=valorConsulta%>','<%=limiteResultados%>','<%=valorConsulta2%>','<%=filial%>');});" <%= pag == 1 ? "disabled" : "" %> >
                                </div>
                            </td>
                            <td>
                                <div align="center">
                                    <input name="avancar" type="button" class="botoes" id="avancar" value="Próxima Página" onClick="javascript:tryRequestToServer(function(){proxima('<%=campoConsulta%>','<%=operadorConsulta%>','<%=valorConsulta%>','<%=limiteResultados%>','<%=valorConsulta2%>','<%=filial%>');});" <%= qtde_pag == pag ? "disabled" : "" %>>
                                </div>
                            </td>
                        </tr>
                    </table>    
                </td>
                <td width="74%">
                    <table width="100%" align="center" cellspacing="1">
                        <tr class="celula" height="25px">
                            <td width="13%">Modelo PDF:</td>
                            <td width="16%">
                                <select name="modelo" id="modelo" class="inputTexto">
                                    <option value="1" <%=cfg.getRelDefaultConhecimento().equals("1") ? "selected" : ""%>>Modelo 1 (Minuta)</option>
                                    <option value="2" <%=cfg.getRelDefaultConhecimento().equals("2") ? "selected" : ""%>>Modelo 2 (Etiqueta)</option>
                                    <option value="3" <%=cfg.getRelDefaultConhecimento().equals("3") ? "selected" : ""%>>Modelo 3 (Minuta)</option>
                                    <option value="4" <%=cfg.getRelDefaultConhecimento().equals("4") ? "selected" : ""%>>Modelo 4 (Minuta)</option>
                                   
                                    <%for (String rel : Apoio.listDocCtrc(request)){%>
                                        <option value="personalizado_<%=rel%>" <%=(cfg.getRelDefaultConhecimento().startsWith("personalizado_"+rel) ? "selected" : "")%> >Modelo <%=rel.toUpperCase() %></option>
                                    <%}%>
                                </select>
                            </td>
                            <td width="21%">Impressora Matricial:</td>
                            <td width="18%">
                                <select name="caminho_impressora" id="caminho_impressora" class="inputTexto" style="width:120px;">
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
                            </td>
                            <td width="32%">Driver:
                                <select name="driverImpressora" id="driverImpressora" class="inputTexto" style="width: 120px;">
                                    <option value="">&nbsp;</option>
                                    <%Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "ctrc.txt");
                                    for (int i = 0; i < drivers.size(); ++i) {
                                        String driv = (String) drivers.get(i);
                                        driv = driv.substring(0, driv.lastIndexOf("."));
                                    %>
                                    <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                                    <%}
                                    //agora as etiquetas
                                    drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "etq.txt");
                                    for (int i = 0; i < drivers.size(); ++i) {
                                        String driv = (String) drivers.get(i);
                                        driv = driv.substring(0, driv.lastIndexOf("."));
                                    %>
                                    <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                                    <%}
                                    //agora as etiquetas
                                    drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "prn.txt");
                                    for (int i = 0; i < drivers.size(); ++i) {
                                        String driv = (String) drivers.get(i);
                                        driv = driv.substring(0, driv.lastIndexOf("."));
                                    %>
                                    <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                                    <%}%>
                                </select>
                                <img src="img/ctrc.gif" class="imagemLink" title="Imprimir CT-e(s) selecionados" onClick="tryRequestToServer(function(){printMatricideCtrc()});">
                            </td>
                        </tr>
                        <tr class="celula" height="25px">
                            <td>Exportar EDI:</td>
                            <td colspan="3">
                                <select name="cbexportar" id="cbexportar" class="inputTexto" style="width:280px;">
                                </select>
                                <input name="btexportar" type="button" class="botoes" id="btexportar" value="OK"  onClick="javascript:tryRequestToServer(function(){exportar();});">
                            </td>
                            <td>
                                <img src="img/cte.jpg" height="25" class="imagemLink" title="Visualizar CT-e(s)." onClick="tryRequestToServer(function(){abrirCTe()});">
                                <input type="button" onClick="javascript:tryRequestToServer(function(){abrirCTe();});" value="Visualizar CT-e(s)" class="inputBotao">
                            </td>
                        </tr>
                    </table>    
                </td>
            </tr>
        </table>
        <br>
    </form>
</body>
</html>
