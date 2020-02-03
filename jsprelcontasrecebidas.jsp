<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="nucleo.BeanConexao"%>
<%@page import="fpag.BeanFPag"%>
<%@page import="fpag.CadFPag"%>
<%@page import="fpag.BeanConsultaFPag"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="venda.BeanCadVenda"%>
<%@page import="venda.BeanVenda"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="br.com.gwsistemas.filial.usuario.UsuarioVendedor"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relcontasreceber") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    //29/06/2015    
    CadFPag formaPagamento = new CadFPag();
    BeanConexao con = Apoio.getUsuario(request).getConexao();    
    Collection<BeanFPag> listarPagamento = formaPagamento.listaFPag(con);
    request.setAttribute("listarPagamento", listarPagamento);

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    
    String tipoFilialConfig = cfg.getMatrizFilialFranquia();
    int nivelUserToFilial = Apoio.getUsuario(request).getAcesso("lanconhfl");    

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        String vendedor ="";
        String cliente = "";
        StringBuilder filial = null;
        String fatura = "";
        String anofatura = "";
        String data = "";
        String modalidade = "";
        String sqlModalidade = "";
        String planoCusto = "";
        String situacao = "";
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String ordem = request.getParameter("ordem");
        String sqlTipoCobranca = "";
        String tipoCobranca = request.getParameter("tipoCobranca");
        String modelo = request.getParameter("modelo");
        String tipoFretes = request.getParameter("tipo_frete");
        String excetoGrupo = request.getParameter("excetoGrupo");
        String grupos = "";
        String valorOpcoesPagamento = (request.getParameter("valoresOpcoesPagamento").equals("") ? "" : request.getParameter("valoresOpcoesPagamento")); 
        String maxValuePagamento = request.getParameter("maxValuePagamento");
        String dataFinal = "";
        //pegar id cliente
    List<String> idsConsignatario = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("con_rzs"))) {
            String[] splitConsignatarios = request.getParameter("con_rzs").split("!@!");
            for (String splitConsignatario: splitConsignatarios) {
                String[] splitConsignatarioID = splitConsignatario.split("#@#");

                if (splitConsignatarioID.length >= 2) {
                    idsConsignatario.add(String.valueOf(Apoio.parseInt(splitConsignatarioID[1])));
                }
            }
        }
    //pegar id remetente
    List<String> idsRemetente = new ArrayList<>();
    if (StringUtils.isNotBlank(request.getParameter("rem_rzs"))) {
        String[] splitRemetentes = request.getParameter("rem_rzs").split("!@!");
        for (String splitRemetente: splitRemetentes) {
            String[] splitRemetenteID = splitRemetente.split("#@#");
            
            if (splitRemetenteID.length >= 2) {
                idsRemetente.add(String.valueOf(Apoio.parseInt(splitRemetenteID[1])));
            }
        }
    }
    //pegar id destinatário
     List<String> idsDestinatarios = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("dest_rzs"))) {
            String[] splitDestinatarios = request.getParameter("dest_rzs").split("!@!");
            for (String splitDestinatario: splitDestinatarios) {
                String[] splitDestinatarioID = splitDestinatario.split("#@#");

                if (splitDestinatarioID.length >= 2) {
                    idsDestinatarios.add(String.valueOf(Apoio.parseInt(splitDestinatarioID[1])));
                }
            }
        }
        if (request.getParameter("modelo").equals("1") && request.getParameter("totalizar").equals("S")) {
            ordem = "pago_em," + ordem;
        }

            //Verificando se vai filtrar apenas um consignatário
            cliente = (idsConsignatario.isEmpty() ? "" : " and consignatario_id " + ("<>".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
        


        //Verificando se vai filtrar apenas uma filial
            filial =  new StringBuilder();
            if (request.getParameter("idfilial") != null && !request.getParameter("idfilial").equals("0")) {
                filial.append(" and filial_id =").append(request.getParameter("idfilial"));
            }
            if (request.getParameter("idfilialentrega") != null && !request.getParameter("idfilialentrega").equals("0")){
                 filial.append(" and id_filial_entrega =").append(request.getParameter("idfilialentrega"));
            }
            if (request.getParameter("idfilialcobranca") != null && !request.getParameter("idfilialcobranca").equals("0")) {
                if(request.getParameter("modelo").equals("5")){
                   filial.append(" AND bx.filial_cobranca_id =").append(request.getParameter("idfilialcobranca"));
                }else{
                   filial.append(" AND filial_cobranca_id =").append(request.getParameter("idfilialcobranca"));
                }
                
            }
        //Verificando o critério de datas
        String tipoData = request.getParameter("tipodata");

        data = " and bx." + tipoData + " BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
        
        //Tratando a modalidade do frete
        modalidade = request.getParameter("tipoModalidade");
        if (modalidade.equals("c")) {
            sqlModalidade = " AND ct.tipo_fpag = 'p' ";
        } else if (modalidade.equals("v")) {
            sqlModalidade = " AND ct.tipo_fpag = 'v' AND is_pago ";
        } else if (modalidade.equals("p")) {
            sqlModalidade = " AND ct.tipo_fpag = 'v' AND not is_pago ";
        }
        if(modelo.equals("10")){
            planoCusto = (request.getParameter("idPlano").equals("0")) ? "" : " AND " + request.getParameter("idPlano") + " IN (SELECT planocusto_id FROM appropriations app WHERE vr.sale_id = app.sale_id)";
        }else{
            planoCusto = (request.getParameter("idPlano").equals("0")) ? "" : " AND " + request.getParameter("idPlano") + " IN (SELECT planocusto_id FROM appropriations app WHERE bx.sale_id = app.sale_id)";
        }
        situacao = request.getParameter("situacao");

        String sqlDataFinal = "";
        
        if (modelo.equals("1")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("2")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("3")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("4")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("5")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("6")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("7")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
        } else if (modelo.equals("8")) {
        } else if (modelo.equals("9")) {
        } else if (modelo.equals("10")) {
        } else if (modelo.equals("11")) {
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND (NOT is_gera_boleto OR is_gera_boleto is null) "));
            sqlDataFinal = "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
        }
        
        
        /*02/09/13 Modelo 8 utiliza colunas diferentes já que, para sua construção, foi tomado como base o modelo 2 de contas a receber, 
         * modelo este que se utiliza da view vrelduplicata e não de vbx_receber como os demais de contas recebidas.
         * Na condição abaixo são alterados todos os itens que são diferenciados no modelo 8.
         */
        if(modelo.equals("8")){
            
            //alterando a ordenacao da consulta
            if(ordem.equals("numero")){
                ordem =  "fatura";  
            }else if(ordem.equals("emissao_em")){
                ordem =  "emissao_fatura";  
            }else if(ordem.equals("pago_em")){
                ordem =  "d.pago_em";
            }
            
            //alterando o tipo de consulta por data
            if (tipoData.equals("emissao_em")) {
                data = " and emissao_fatura BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
            } else if (tipoData.equals("vence_em")) {
                data = " and vencimento_fatura BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
            } else if (tipoData.equals("emissao_conciliacao")) {
                data = " and emissao_conciliacao BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
            } else if (tipoData.equals("entrada_conciliacao")) {
                data = " and entrada_conciliacao BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
            } else {
                data = " and d.pago_em BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";
            }

            // plano de custo e cliente são diferentes no modelo 8
            planoCusto = (request.getParameter("idPlano").equals("0")) ? "" : " AND " + request.getParameter("idPlano") + " IN (SELECT planocusto_id FROM appropriations app WHERE d.sale_id = app.sale_id)";
            cliente = (idsConsignatario.isEmpty() ? "" : " and idconsignatario " + ("<>".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
        
        }
        
        /*BeanUsuario user = Apoio.getUsuario(request);
        int idVendedor = Apoio.parseInt(request.getParameter("idvendedor"));
        Collection<UsuarioVendedor> usuario = user.getItens();
        
        
        vendedor = (usuario.isEmpty() && idVendedor == 0 ? " " : // Imprime Tudo
                   (!usuario.isEmpty()) && idVendedor == 0 ? " and uv.usuario_id=" + user.getId() : // Imprime apenas os vendedores que estiverem na lista de usuarios
                    usuario.isEmpty() && idVendedor != 0 ? " and bx.vendedor_id=" + idVendedor : // Imprime apenas o vendedor selecionado no filtro, quando a lista vazia
                   !usuario.isEmpty() && idVendedor != 0 ? " and (uv.usuario_id=" + user.getId() + " and bx.vendedor_id=" + idVendedor + ")" : " "); // Imprime apenas o vendedor da lista, caso esteja na lista
        
        
        LOG.debug("AAAAAAA VALIDACOES : " + !usuario.isEmpty() +" - " + (idVendedor == 0) );
        
        
        if(modelo != "8"){
        vendedor = (idVendedor == 0 ? "" : 
                (" and bx.vendedor_id=" + idVendedor));
        }else vendedor = (idVendedor == 0 ? "" : 
                (" and d.vendedor_id=" + idVendedor));*/
        
        
        
        BeanUsuario autenticado = Apoio.getUsuario(request);
            String ids = "";
            
            if(autenticado.isIsVendedor()){
                Collection<UsuarioVendedor> usuarios = autenticado.getItens();

                for(UsuarioVendedor str : usuarios) {
                    if (ids.length() == 0){ 
                        ids += String.valueOf(str.getVendedor().getIdfornecedor()); 
                    }else{
                        ids += "','" + String.valueOf(str.getVendedor().getIdfornecedor());
                    }
                }
        
                if (ids.trim().equals("")){
                    //Para não mostrar nada
                    vendedor = "  ";
                }else{
                    if(!(modelo.equals("8"))){
                    vendedor = " AND vendedor_id IN ('" + ids + "') ";
                    }else{
                    vendedor = " AND d.vendedor_id IN ('" + ids + "') ";
                    }
                }
                vendedor += (!request.getParameter("idvendedor").equals("0") ? " and vendedor_id =" + request.getParameter("idvendedor") : "");
            }else{
                vendedor = (!request.getParameter("idvendedor").equals("0") ? " and vendedor_id =" + request.getParameter("idvendedor") : "");
            }
            if(modelo.equals("10")){
                vendedor = (!request.getParameter("idvendedor").equals("0") ? " and vr.vendedor_id =" + request.getParameter("idvendedor") : "");
            }
        
            grupos =  (request.getParameter("grupos").equals("") ? "" : " and (grupo_id " + 
                   excetoGrupo + " (" + request.getParameter("grupos") + ")" + (excetoGrupo.contains("NOT") ? " OR grupo_id IS NULL " : "")+ ")");            
            //01/07/2015            
            String formaPagamentoSQL = "";
            if (!valorOpcoesPagamento.equals("") && maxValuePagamento != "") {
                    formaPagamentoSQL = " AND fpag_id IN(" + valorOpcoesPagamento + ")";
                    if (modelo.equals("8")) {
                        formaPagamentoSQL = " AND d.fpag_id IN(" + valorOpcoesPagamento + ")";
                    }
                }
            
        java.util.Map param = new java.util.HashMap(21);
        
        String mostrar = request.getParameter("mostrar");
        String sqlMostrar = " AND categoria in ("+mostrar.substring(0,mostrar.length()-1) + ")";
        param.put("MOSTRAR",sqlMostrar);
        
        param.put("CLIENTE", cliente);
        param.put("PLANO_CUSTO", planoCusto);
        param.put("FILIAL", filial.toString());
        param.put("DATA", data);
        param.put("VENDEDOR", vendedor);
        param.put("TOTAL_DIARIO", (Boolean.parseBoolean(request.getParameter("totalizar")) ? "S" : "N"));
        param.put("SERIE", (request.getParameter("serie").equals("") ? "" : " and serie='" + request.getParameter("serie") + "'"));
        param.put("OPCOES", "Período selecionado: " + new SimpleDateFormat("dd/MM/yyyy").format(dtinicial) + " até " + new SimpleDateFormat("dd/MM/yyyy").format(dtfinal));
        param.put("GRUPOS", grupos);
        param.put("AVISTA", sqlModalidade);
        param.put("TIPO_COBRANCA", sqlTipoCobranca);
        param.put("ORDENACAO", ordem);
        
        //09/08/13 - Parâmetros diferenciados para novo modelo (8)
        if (modelo.equals("8")) {
            param.put("CONTA", (!request.getParameter("idconta").equals("0") ? " and conta_id=" + request.getParameter("idconta") : ""));
            param.put("SITUACAO", (situacao.equals("") ? "" : " AND situacao in (" + situacao + ") "));
        } else {
            param.put("CONTA", (!request.getParameter("idconta").equals("0") ? " and idconta=" + request.getParameter("idconta") : ""));
            param.put("SITUACAO", (situacao.equals("") ? "" : " AND situacao_fatura in (" + situacao + ") "));
        }
            String tipoData2 = request.getParameter("tipodata2");
            String tipoDt = "";
            if (modelo.equals("10")) {
                    BeanVenda fi = null;
                    BeanCadVenda beanCadVenda = new BeanCadVenda();
                    beanCadVenda.setExecutor(Apoio.getUsuario(request));
                    beanCadVenda.setConexao(Apoio.getUsuario(request).getConexao());
                    
                    beanCadVenda.getDiasDoMes(Apoio.parseInt(request.getParameter("mes")));
                    param.put("DATA", request.getParameter("ano")+(request.getParameter("mes").equals("10") || request.getParameter("mes").equals("11") || request.getParameter("mes").equals("12") ? "-" : "-0")+request.getParameter("mes")+"-"+"01");
                    if (request.getParameter("mes").equals("1") || request.getParameter("mes").equals("3") || request.getParameter("mes").equals("5") || request.getParameter("mes").equals("7") || request.getParameter("mes").equals("8") || request.getParameter("mes").equals("10") || request.getParameter("mes").equals("12")) {
                        dataFinal = (request.getParameter("ano")+(request.getParameter("mes").equals("10") || request.getParameter("mes").equals("11") || request.getParameter("mes").equals("12") ? "-" : "-0")+request.getParameter("mes")+"-"+"31");
                    }else if (request.getParameter("mes").equals("2")){
                        dataFinal = (request.getParameter("ano")+"-0"+request.getParameter("mes")+"-"+"28");
                    }else{
                        dataFinal = (request.getParameter("ano")+(request.getParameter("mes").equals("10") || request.getParameter("mes").equals("11") || request.getParameter("mes").equals("12") ? "-" : "-0")+request.getParameter("mes")+"-"+"30");
                    }

                    param.put("ANO", request.getParameter("ano"));
                    param.put("MES", request.getParameter("mes"));
                    param.put("DATA_FINAL_PESQUISA", dataFinal);
                    // RelatorioBO relatorioBO = new RelatorioBO();
                    //  relatorioBO.getDiasDoMes(Apoio.parseInt(request.getParameter("mes")));
                        
                    param.put("TIPO_DATA", "vence_em");
                }
        param.put("DESTINATARIO_ID", request.getParameter("iddestinatario"));
        param.put("REMETENTE_ID", request.getParameter("idremetente"));
        param.put("TIPOFRETES", (tipoFretes.equals("") ? "" : "AND tipo_frete IN (" + tipoFretes + ")"));
        param.put("DATA_FINAL", sqlDataFinal);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        param.put("OPCOES_PAGAMENTO", formaPagamentoSQL);
        
        
        if (modelo.equals("5")) {
           param.put("CONDICAO_REMETENTE", idsRemetente.isEmpty() ? "" : " and bx.remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
           param.put("CONDICAO_DESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and bx.destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        } else {
            param.put("CONDICAO_REMETENTE", idsRemetente.isEmpty() ? "" : " and remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("CONDICAO_DESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        }
        
        request.setAttribute("map", param);
        request.setAttribute("rel", "contasrecebidasmod" + request.getParameter("modelo"));

        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispacher.forward(request, response);
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CONTAS_RECEBER_E_RECEBIDAS_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">
    var homePath = '${homePath}';
    function voltar() {
        location.replace("./menu");
    }

    function localizacliente() {
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5', 'Cliente',
                'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizaremetente() {
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=3', 'Remetente',
                'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    
    }
    function localizadestinatario() {
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=4', 'Destinatário',
                'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizavendedor() {
        post_cad = window.open('./localiza?acao=consultar&idlista=27&paramaux=1','Vendedor','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaconta() {
        //Não teve outra alternativa, tive que fazer essa gambi.        
        var limitarUsuarioVisualizarConta = '<%=limitarUsuarioVisualizarConta%>';
        var idUsuario = '<%=idUsuario%>';
        var paramaux4 = "";
        var paramaux = "and true";
        if (limitarUsuarioVisualizarConta == 'true') {
            paramaux4 = "LEFT JOIN usuario_conta uc ON (c.idconta = uc.conta_id) ";
            paramaux = " and uc.usuario_id = " + idUsuario + "";
        }
        post_cad = window.open('./localiza?acao=consultar&idlista=31&paramaux4='+paramaux4+'&paramaux='+paramaux, 'Conta',
                'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
    }

    function modelos(modelo) {
   
        getObj("modelo1").checked = false;
        getObj("modelo2").checked = false;
        getObj("modelo3").checked = false;
        getObj("modelo4").checked = false;
        getObj("modelo5").checked = false;
        getObj("modelo6").checked = false;
        getObj("modelo7").checked = false;
        getObj("modelo8").checked = false;
        getObj("modelo9").checked = false; // 23-10-2013 - Paulo
        getObj("modelo10").checked = false;
        getObj("modelo11").checked = false;
        getObj("tipoModalidade").style.display = "none";
        getObj("trTotalPagamento").style.display = "none";
        getObj("lbConta").style.display = "none";
        getObj("divConta").style.display = "none";
        getObj("trMesAno").style.display = "none";
        getObj("modelo" + modelo).checked = true;

        if (modelo == 1) {
            getObj("trData").style.display = "";
            getObj("trTotalPagamento").style.display = "";
            getObj("lbConta").style.display = "";
            getObj("divConta").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }

        if (modelo == 2) {
            getObj("trData").style.display = "";
            $("orden1").style.display = "none";
            $("orden2").style.display = "none";
            $("ordem").style.display = "none";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }


        if (modelo == 3) {
            getObj("trData").style.display = "";
            $("orden1").style.display = "none";
            $("orden2").style.display = "none";
            $("ordem").style.display = "none";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }

        if (modelo == 4) {
            getObj("trData").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }

        if (modelo == 5) {
            getObj("trData").style.display = "";
            getObj("tipoModalidade").style.display = "";
            $("orden1").style.display = "none";
            $("orden2").style.display = "none";
            $("ordem").style.display = "none";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }

        if (modelo == 6) {
            getObj("trData").style.display = "";
            getObj("trTotalPagamento").style.display = "none";
            getObj("lbConta").style.display = "";
            getObj("divConta").style.display = "";
            $("orden1").style.display = "none";
            $("orden2").style.display = "none";
            $("ordem").style.display = "none";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }

        if (modelo == 7) {
            getObj("trData").style.display = "";
            getObj("trTotalPagamento").style.display = "";
            getObj("lbConta").style.display = "";
            getObj("divConta").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }
        if (modelo == 8) {
            getObj("trData").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }
        if (modelo == 9) {
            getObj("trData").style.display = "";
            getObj("trTotalPagamento").style.display = "";
            getObj("lbConta").style.display = "";
            getObj("divConta").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }
        if (modelo == 10) {         
            getObj("trData").style.display = "none";
            getObj("trMesAno").style.display = "";
            getObj("trTotalPagamento").style.display = "none";
            getObj("lbConta").style.display = "";
            getObj("divConta").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
            slipData();
        }
        if (modelo == 11) {
            getObj("trData").style.display = "";
            getObj("trTotalPagamento").style.display = "";
            getObj("lbConta").style.display = "";
            getObj("divConta").style.display = "";
            $("orden1").style.display = "";
            $("orden2").style.display = "";
            $("ordem").style.display = "";
            $("imgGrupo").style.display = "";
            $("selecExcetoGrupo").style.display = "";
        }
    }

    function limparcliente() {
        $('idconsignatario').value = "0";
        $('con_rzs').value = "";
    }
    
    function limparremetente() {
        $('idremetente').value = "0";
        $('rem_rzs').value = "";
    }
    
    function limpardestinatario() {
        $('iddestinatario').value = "0";
        $('dest_rzs').value = "";
    }
   
    function limparvendedor() {
        $('idvendedorselecionado').value = 0; 
        $('vend_rzs').value = '';
    }

    function localizafilial() {
        post_cad = window.open('./localiza?acao=consultar&idlista=8', 'Filial',
                'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparfilial() {
        document.getElementById("idfilial").value = 0;
        document.getElementById("fi_abreviatura").value = "";
    }

    function limparconta() {
        document.getElementById("idconta").value = 0;
        document.getElementById("conta").value = "";
    }
    var countPopRel = 0;
    function popRel() {
        countPopRel++;
        var modelo;
        var grupos = getGrupos();
        if (!validaData(document.getElementById("dtinicial").value) || !validaData(document.getElementById("dtfinal").value))
            alert("Informe o intervalo de datas corretamente.");
        else {
            
            if($("chkCte").checked == false && $("chkNfs").checked == false && $("chkReceita").checked == false && $("chkVendaVeiculo").checked == false){
                alert("É necessário selecionar uma das opções: CT-e(s)/Minutas , NFS-e , Receita Financeira ou Venda de veículo ");            
                return false;
            }
            
            if (getObj("modelo1").checked)
                modelo = '1';
            else if (getObj("modelo2").checked)
                modelo = '2';
            else if (getObj("modelo3").checked)
                modelo = '3';
            else if (getObj("modelo4").checked)
                modelo = '4';
            else if (getObj("modelo5").checked)
                modelo = '5';
            else if (getObj("modelo6").checked)
                modelo = '6';
            else if (getObj("modelo7").checked)
                modelo = '7';
            else if (getObj("modelo8").checked)
                modelo = '8';
            else if(getObj("modelo9").checked)
                modelo = '9'; // 23-10-2013 Paulo
            else if (getObj("modelo10").checked)
                modelo = '10';
            else if (getObj("modelo11").checked)
                modelo = '11';
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";

            var situacao = "";
            //Verificando as situações
            if ($('chksem').checked) {
                situacao = "''";
            }
            if ($('chknomais').checked) {
                situacao += (situacao == "" ? "" : ",") + "'NM'";
            }
            if ($('chkcartorio').checked) {
                situacao += (situacao == "" ? "" : ",") + "'TC'";
            }
            if ($('chkdescontadas').checked) {
                situacao += (situacao == "" ? "" : ",") + "'DT'";
            }
            if ($('chkdevedoras').checked) {
                situacao += (situacao == "" ? "" : ",") + "'DE'";
            }

            var tipoCobranca;
            if ($('tipoCobranca1').checked) {
                tipoCobranca = '';
            } else if ($('tipoCobranca2').checked) {
                tipoCobranca = 'c';
            } else {
                tipoCobranca = 'b';
            }
            
            var mes ;
            var ano;
            var tipodata2;
            if($('mes').value==null){
                mes=0;
            }else{
                mes=$('mes').value;
            }
            
            if($('ano').value==null){
                ano=0;
            }else{
                ano=$('ano').value;
            }
            
            // apenas os fretes
            var tipofretes;
            tipofretes = "''";
            if($('chkcif').checked){
                tipofretes += (tipofretes == "" ? "" : ",") + "'CIF'";
            }
            if($('chkcon').checked){
                tipofretes += (tipofretes == "" ? "" : ",") + "'CON'";
            }
            if($('chkfob').checked){
                tipofretes += (tipofretes == "" ? "" : ",") + "'FOB'";
            }
            if($('chkred').checked){
                tipofretes += (tipofretes == "" ? "" : ",") + "'RED'";
            }            
            //Opcões de pagamento
        var maxValuePagamento = $('maxValuePagamento').value ;   
        var opcoesPagamento = "";
        var valoresOpcoesPagamento = ""; 
        var countPagamento = 0;
        for(var i = 1; i <= maxValuePagamento; i++){            
            if($('opcoesFormPagaId_' + i).checked == true){ 
                    ++countPagamento;
                    opcoesPagamento += ", " + $('opcoesFormPagaId_' + i).value;                   
                    valoresOpcoesPagamento = opcoesPagamento.substring(1);//                    
                }                
        }
            if(countPagamento == maxValuePagamento){
                    maxValuePagamento = "";
                }        
                
                
        var mostrar = "";
        if($("chkCte").checked == true){mostrar += "'ct',";}
        if($("chkNfs").checked == true){mostrar += "'ns',";}
        if($("chkReceita").checked == true){mostrar += "'fn',";}
        if($("chkReceita").checked == true){mostrar += "'vv',";}
            
        //.replace()//falta fazer que quando vim um numero não vir virgula
            launchPDF('./relcontasrecebidas?acao=exportar&modelo=' + modelo +
                    '&impressao=' + impressao + '&idconsignatario=' + document.getElementById("idconsignatario").value +
                    '&idfilial='+$("idfilialemissao").value+
                    '&idfilialentrega='+$("idfilialentrega").value+
                    '&idfilialcobranca='+$("idfilialcobranca").value+
                    '&excetoCliente=' + document.getElementById("excetoCliente").value +'&excetoGrupo=' + $("excetoGrupo").value +
                    '&serie=' + document.getElementById("serie").value + '&tipodata=' + document.getElementById("tipodata").value +
                    '&dtinicial=' + document.getElementById("dtinicial").value + '&dtfinal=' + document.getElementById("dtfinal").value +
                    '&grupos=' + grupos + '&tipoModalidade=' + $('tipoModalidade').value +
                    '&idremetente=' + $("idremetente").value + '&iddestinatario=' + $("iddestinatario").value +
                    '&situacao=' + situacao +
                    '&idPlano=' + $("idplanocusto").value +
                    '&totalizar=' + $('totalPagamento').checked + '&idconta=' + $('idconta').value + '&ordem=' + $('ordem').value +
                    '&tipoCobranca=' + tipoCobranca + '&idvendedor=' + $('idvendedorselecionado').value
                    + '&mes=' + mes+ '&ano=' + ano+'&tipo_frete='+tipofretes +
                    '&valoresOpcoesPagamento=' + valoresOpcoesPagamento + 
                    '&maxValuePagamento=' + maxValuePagamento + 
                    '&mostrar='+mostrar+'&con_rzs='+encodeURIComponent($("con_rzs").value)+'&apenasDestinatario='+ document.getElementById("apenasDestinatario").value+'&dest_rzs='+encodeURIComponent($("dest_rzs").value)+'&apenasRemetente='+ document.getElementById("apenasRemetente").value+'&rem_rzs='+encodeURIComponent($("rem_rzs").value));
                    

        }


    }

    function aoClicarNoLocaliza(idjanela)
    {
        if (idjanela == "Grupo") {
            addGrupo(getObj('grupo_id').value, 'node_grupos', getObj('grupo').value)
        }else if (idjanela == "Filial_Emissao"){
            $('idfilialemissao').value = getObj('idfilial').value;
            $('filial_emissora').value = getObj('fi_abreviatura').value;
            if(<%=!tipoFilialConfig.equals("p")%>){
                alteraCondicaoFilial();
            }
        }else if (idjanela == "Filial_Entrega"){
            $('idfilialentrega').value = getObj('idfilial').value;
            $('filial_entrega').value = getObj('fi_abreviatura').value;
        }else if (idjanela == "Filial_Cobranca"){
            $('idfilialcobranca').value = getObj('idfilial').value;
            $('filial_cobranca').value = getObj('fi_abreviatura').value;
        }
        
        if(idjanela == "Vendedor"){
            $('idvendedorselecionado').value = $('idvendedor').value;
            $('vend_rzs').value = $('ven_rzs').value;
        }
    }

    function localizaPlanoCusto() {
        post_cad = window.open('./localiza?acao=consultar&idlista=13', 'Filial',
                'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparPlanoCusto() {
        document.getElementById("idplanocusto").value = 0;
        document.getElementById("plcusto_conta").value = "";
        document.getElementById("plcusto_descricao").value = "";
    }
    
    
    function slipData(){
        
        var dtAtual =$("dtinicial").value;
        var mes = dtAtual.substring(3,5);
        var mestemp = dtAtual.substring(3,4);
        var mestemp2 = dtAtual.substring(4,5);
        var ano = dtAtual.substring(6,10);
        var mesfinal;
        var temp=0;
      
        if(mestemp=='0'){
            mesfinal = mestemp2;
        }else{
            mesfinal = mes;
        } 
        $("mes").value = mesfinal;
        $("ano").value = ano;
       
    }
    
    function alteraCondicaoFilial(){
        if (<%=tipoFilialConfig.equals("p")%>) {
                if (<%=!temacessofiliais %>) {
                    $("filial_emissora").value = $("descFilialUsuario").value;
                    $("idfilialemissao").value = $("idFilialUsuario").value;
                    $("localiza_filial_emissao").style.display = "none";
                    $("btnLimparFilialEmissao").style.display = "none";
                } else {
                    $("filial_emissora").value = "";
                    $("idfilialemissao").value = "0";
                    $("localiza_filial").style.display = "";
                    $("btnLimparFilial").style.display = "";
                }
                $("filial_entrega").value = "";
                $("idfilialentrega").value = "0";
                $("localiza_filial_entrega").style.display = "";
                $("btnLimparFilialEntrega").style.display = "";
            
        }else {
            if (<%=temacessofiliais%> || ($("idFilialUsuario").value == $("idfilialemissao").value)) {
                $("filial_entrega").value = "";
                $("idfilialentrega").value = "0";
                $("localiza_filial_entrega").style.display = "";
                $("btnLimparFilialEntrega").style.display = "";
            } else {
                $("filial_entrega").value = $("descFilialUsuario").value;
                $("idfilialentrega").value = $("idFilialUsuario").value;
                $("localiza_filial_entrega").style.display = "none";
                $("btnLimparFilialEntrega").style.display = "none";
            }
        }
    }
    function abrirLocalizarCliente(input) {
        jQuery('#localizarCliente').attr('input', input);
        controlador.acao('abrirLocalizar', 'localizarCliente');
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

        <title>Webtrans - Relatório de contas recebidas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
        <link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');
        aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');alteraCondicaoFilial();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="idremetente" id="idremetente" value="0">
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="0">
            <input type="hidden" name="fi_abreviatura" id="fi_abreviatura" value="0">
            <input type="hidden" name="idfilialemissao" id="idfilialemissao" value="">
            <input type="hidden" name="idfilialentrega" id="idfilialentrega" value="">
            <input type="hidden" name="idfilialcobranca" id="idfilialcobranca" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idconta" id="idconta" value="0">
            <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
            <input type="hidden" name="idvendedor" id="idvendedor" value="0">
            <input type="hidden" name="idvendedorselecionado" id="idvendedorselecionado" value="0">
            <input type="hidden" name="ven_rzs" id="ven_rzs" value="">
            <input type="hidden" name="idFilialUsuario" id="idFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="descFilialUsuario" id="descFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getAbreviatura())%>">
        </div>
        <table width="90%" border="0" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de contas recebidas</b></td>
            </tr>
        </table>

        <br>
        
        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <div id="tabPrincipal">
            
            <table width="90%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td colspan="3"><div align="center">Modelos</div></td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    duplicatas recebidas </td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Total recebido por forma de pagamento (Analítico)</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Total recebido por forma de pagamento (Sintético)</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    duplicatas recebidas (Com histórico)</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de CTRCs por tipo de pagamento</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                        Modelo 6</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das duplicatas recebidas por fatura</td>
            </tr>

            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                        Modelo 7</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das duplicatas recebidas com impostos retidos</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo8" type="radio" value="8" onClick="javascript:modelos(8);">
                        Modelo 8</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Relação das Faturas Recebidas</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo9" type="radio" value="9" onClick="javascript:modelos(9);">
                        Modelo 9</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de contas recebidas com dados do motorista e veiculo</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo10" type="radio" value="10" onClick="javascript:modelos(10);">
                        Modelo 10</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de inadimplência mensal</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo11" type="radio" value="11" onClick="javascript:modelos(11);">
                        Modelo 11</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de performance de recebimentos por cliente</td>
            </tr>
            
            <tr class="tabela">
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr id="trData" style="display: ">
                <td height="24" class="TextoCampos">Por data de:</td>
                <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="emissao_em">Emissão</option>
                        <option value="vence_em">Vencimento</option>
                        <option value="pago_em" selected>Pagamento</option>
                        <option value="emissao_conciliacao">Emissão (Conciliação)</option>
                        <option value="entrada_conciliacao">Entrada (Conciliação)</option>
                    </select>
                    entre<strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong></td>
            </tr>
             <tr id="trMesAno" name="trMesAno" style="display: none">
                     <td height="24" class="TextoCampos">
                       Vencimento:
                    </td>
                    <td class="CelulaZebra2" colspan="3" width="71%" >
                        <select name="mes" id="mes" class="inputtexto">
                            <option value="1">Janeiro</option>
                            <option value="2">Fevereiro</option>
                            <option value="3">Março</option>
                            <option value="4">Abril</option>
                            <option value="5">Maio</option>
                            <option value="6">Junho</option>
                            <option value="7">Julho</option>
                            <option value="8">Agosto</option>
                            <option value="9">Setembro</option>
                            <option value="10">Outubro</option>
                            <option value="11">Novembro</option>
                            <option value="12">Dezembro</option>
                        </select> /
                        <select name="ano" id="ano" class="inputtexto">
                            <option value="2000">2000</option>
                            <option value="2001">2001</option>
                            <option value="2002">2002</option>
                            <option value="2003">2003</option>
                            <option value="2004">2004</option>
                            <option value="2005">2005</option>
                            <option value="2006">2006</option>
                            <option value="2007">2007</option>
                            <option value="2008">2008</option>
                            <option value="2009">2009</option>
                            <option value="2010">2010</option>
                            <option value="2011">2011</option>
                            <option value="2012">2012</option>
                            <option value="2013"selected>2013</option>
                            <option value="2014">2014</option>
                            <option value="2015">2015</option>
                            <option value="2016">2016</option>
                            <option value="2017">2017</option>
                            <option value="2018">2018</option>
                            <option value="2019">2019</option>
                            <option value="2020">2020</option>
                        </select>
                    </td>
                </tr>
            <tr name="trTotalPagamento" id="trTotalPagamento">
                <td colspan="2" class="TextoCampos">
                    <div align="center">
                        <input name="totalPagamento" type="checkbox" id="totalPagamento" value="checkbox" checked>
                        Totalizar por data de pagamento
                    </div></td>
                <td width="50%" height="24" class="TextoCampos">&nbsp;</td>
            </tr>
            <tr class="tabela">
                <td colspan="3">
                    <div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td colspan="3"><table width="100%" border="0" >
                        <tr>
                            <td class="TextoCampos">Filial de Emissão: </td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong> 
                                        <input name="filial_emissora" type="text" id="filial_emissora" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <input name="localiza_filial_emissao" type="button" class="inputBotaoMin" id="localiza_filial_emissao" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Emissao','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img name="btnLimparFilialEmissao" id="btnLimparFilialEmissao" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialemissao').value = 0; $('filial_emissora').value = ''; alteraCondicaoFilial();">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Filial de Entrega: </td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong> 
                                        <input name="filial_entrega" type="text" id="filial_entrega" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <input name="localiza_filial_entrega" type="button" class="inputBotaoMin" id="localiza_filial_entrega" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Entrega','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img name="btnLimparFilialEntrega" id="btnLimparFilialEntrega" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialentrega').value = 0; $('filial_entrega').value = '';">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Filial de Cobrança: </td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong> 
                                        <input name="filial_cobranca" type="text" id="filial_cobranca" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_filial" type="button" class="inputBotaoMin" id="localiza_filial" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Cobranca','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img name="btnLimparFilial" id="btnLimparFilial" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialcobranca').value = 0; $('filial_cobranca').value = '';">
                                        <%}%>
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td width="40%" class="TextoCampos"><div align="right">
                                    <select name="excetoCliente" id="excetoCliente" class="inputtexto">
                                        <option value="=" selected>Apenas o cliente </option>
                                        
                                        <option value="<>">Exceto o cliente</option>                                
                                    </select>
                                    :</div></td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong>
                                        <input name="con_rzs" type="text" id="con_rzs"  size="25" maxlength="80" readonly="true" class="inputReadOnly">
                                        <input name="localiza_cliente" type="button" class="inputBotaoMin" id="localiza_cliente" value="..." onClick="abrirLocalizarCliente('con_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="removerValorInput('con_rzs')">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td width="40%" class="TextoCampos"><div align="right">
                                    <select name="apenasRemetente" id="apenasRemetente" class="inputtexto">
                                        <option value="=" selected> Apenas Remetente </option>
                                        <option value="<>"> Exceto Remetente </option>
                                    </select>  
                                </div></td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong>
                                        <input name="rem_rzs" type="text" id="rem_rzs"  size="25" maxlength="80" readonly="true" class="inputReadOnly">
                                        <input name="localiza_remetente" type="button" class="inputBotaoMin" id="localiza_remetente" value="..." onClick="abrirLocalizarCliente('rem_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="removerValorInput('rem_rzs');">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td width="40%" class="TextoCampos"><div align="right">
                                <select name="apenasDestinatario" id="apenasDestinatario" class="inputtexto">  
                                    <option value="=" selected> Apenas Destinatario </option>
                                    <option value="<>"> Exceto Destinatario </option>
                                </select>
                                </div></td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong>
                                        <input name="dest_rzs" type="text" id="dest_rzs"  size="25" maxlength="80" readonly="true" class="inputReadOnly">
                                        <input name="localiza_destinatario" type="button" class="inputBotaoMin" id="localiza_destinatario" value="..." onClick="abrirLocalizarCliente('dest_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="removerValorInput('dest_rzs');">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td width="40%" class="TextoCampos">Apenas a s&eacute;rie: </td>
                            <td width="10%" class="CelulaZebra2"><strong>
                                    <input name="serie" type="text" id="serie" size="2" maxlength="3" class="inputtexto">
                                </strong></td>
                            <td width="50%" class="CelulaZebra2"><div align="center">
                                    <select id="tipoModalidade" name="tipoModalidade" style="display:none;" class="inputtexto">
                                        <option value="v">Apenas fretes á vista (pago na origem)</option>
                                        <option value="p" selected>Apenas fretes á vista (pago no destino)</option>
                                        <option value="c">Apenas fretes faturados (conta corrente)</option>
                                    </select>                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><div id="lbConta">Apenas a conta: </div></td>
                            <td class="CelulaZebra2" colspan="2">
                                <div id="divConta">

                                    <strong>
                                        <input name="conta" type="text" id="conta" class="inputReadOnly" size="15" maxlength="80" readonly="true">
                                        <input name="localiza_conta" type="button" class="inputBotaoMin" id="localiza_clifor" value="..." onClick="javascript:localizaconta();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:limparconta();">                                    </strong>                                </div>                            </td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos"><div align="right">Apenas um Plano de Custo:</div></td>
                            <td class="TextoCampos" colspan="2"><div align="left"><strong>
                                        <input name="plcusto_conta" type="text" id="plcusto_conta" value="" class="inputReadOnly" size="8" maxlength="60" readonly="true">
                                        <input name="plcusto_descricao" type="text" id="plcusto_descricao" value="" class="inputReadOnly" size="17" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_planoCusto" type="button" class="inputBotaoMin" id="planoCusto" value="..." onClick="javascript:localizaPlanoCusto();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Plano de Custo" onClick="javascript:limparPlanoCusto();"> 
                                        <%}%>
                                    </strong>
                                </div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas o vendedor: </td>
                            <td colspan="2" class="CelulaZebra2">
                                <strong>
                                    <input name="vend_rzs" type="text" id="vend_rzs" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                    <input name="localiza_vendedor" type="button" class="inputBotaoMin" id="localiza_vendedor" value="..." onClick="javascript:localizavendedor();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar vendedor" onClick="javascript:limparvendedor();">
                                </strong>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas as faturas:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="checkbox" name="chksem" id="chksem" value="SEM" checked>CTs/NFS sem fatura gerada<br>
                                <input type="checkbox" name="chknomais" id="chknomais" value="NM" checked>Normais<br>
                                <input type="checkbox" name="chkcartorio" id="chkcartorio" value="TC" checked>Cartório<br>
                                <input type="checkbox" name="chkdescontadas" id="chkdescontadas" value="DT" checked>Descontadas<br>
                                <input type="checkbox" name="chkdevedoras" id="chkdevedoras" value="DE" checked>Devedoras (Em Cobrança)<br>
                                <input name="tipoCobranca" id="tipoCobranca1" type="radio" value="a" checked="">Todos os tipos
                                <input name="tipoCobranca" id="tipoCobranca2" type="radio" value="c">Cobrança em Carteira
                                <input name="tipoCobranca" id="tipoCobranca3" type="radio" value="b">Cobrança em Banco
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas os Fretes: </td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="checkbox" name="chkcif" id="chkcif" value="CIF" checked>CIF
                                <input type="checkbox" name="chkfob" id="chkfob" value="FOB" checked>FOB
                                <input type="checkbox" name="chkcon" id="chkcon" value="CON" checked>CON
                                <input type="checkbox" name="chkred" id="chkred" value="RED" checked>RED                                                                
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" id="lbMostrar" style="display: ">Mostrar: </td>
                            <td class="CelulaZebra2" colspan="2" id="mostrar" style="display: ">
                                <input type="checkbox" name="chkCte" id="chkCte" value="ct" checked>CT-e(s)/Minutas
                                <input type="checkbox" name="chkNfs" id="chkNfs" value="ns" checked>NFS-e
                                <input type="checkbox" name="chkReceita" id="chkReceita" value="fn" checked>Receita Financeira
                                <input type="checkbox" name="chkVendaVeiculo" id="chkVendaVeiculo" value="vv" checked>Venda de Veículo
                            </td>
                        </tr>
                        <tr>
                            <th class="TextoCampos" colspan="3" >
                                <div align="center">
                                    Opções de Forma de Pagamento
                                </div>
                            </th>                            
                        </tr>
                        <c:forEach var="opcoesPagamento" varStatus="status" items="${listarPagamento}"> 
                            <c:if test="${status.count% 3 == 1}">
                                <tr class="CelulaZebra2">
                            </c:if>
                                <td width="33%">
                                ${status.count} - ${status.count% 3}
                                    <label>
                                        <input id="opcoesFormPagaId_${status.count}" type="checkbox" value="${opcoesPagamento.idFPag}" name="opcoesFormPagaId_${status.count}" checked/>
                                        ${opcoesPagamento.descFPag}                                        
                                    </label>
                                </td>
                            <c:if test="${status.count % 3 == 0}">
                               </tr>
                            </c:if>
                            <c:if test="${status.last}">
                                <input id="maxValuePagamento" type="hidden" value="${status.count}" name="maxValuePagamento"/>                                
                            </c:if>   
                            <c:if test="${status.count %3 != 0 && status.last}">
                                <td colspan="${3 - (status.count%3)}"></td>
                            </c:if>
                        </c:forEach>                       
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tr class="cellNotes">
                            <td width="24%" class="CelulaZebra2" id="imgGrupo" style="display: ">
                                <div align="center">
                                    <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33', 'Grupo')">
                                </div>
                            </td>
                        <td width="76%" class="CelulaZebra2" id="selecExcetoGrupo" style="display: ">
                            <div align="center">
                        <select name="excetoGrupo" id="excetoGrupo" class="inputtexto">
                             <option value="IN" selected>Apenas os grupos</option>
                             <option value="NOT IN">Exceto os grupos</option>
                        </select>
                   </div>
                </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <tr class="tabela" id="orden1" name ="orden1">
                <td colspan="3" align="center" class="tabela" >Ordenação</td>
            </tr>
            <tr class="CelulaZebra2" id="orden2" name ="orden2">
                <td colspan="3" align="center">
                    <select id="ordem" name="ordem" class="inputtexto">
                        <option value="numero">Número</option>
                        <option value="emissao_em" selected>Data de Emissão</option>
                        <option value="pago_em" >Data de Pagamento</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
            </tr>
            <tr>
                <td colspan="3" class="TextoCampos"><div align="center">
                        <input type="radio" name="impressao" id="pdf" value="1" checked/>
                        <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                        <input type="radio" name="impressao" id="excel" value="2" />
                        <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                        <input type="radio" name="impressao" id="word" value="3" />
                        <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                    </div></td>
            </tr>
            <tr>
                <td colspan="3" class="TextoCampos"> <div align="center">
                        <% if (temacesso) {%>
                        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function() {
            popRel();
        });">
                        <%}%>
                    </div></td>
            </tr>
        </table>
            
        </div>
        
        <div id="tabDinamico"></div>
        <div class="localiza">
                <iframe id="localizarCliente" input="con_rzs" name="localizarCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
            </div>
            <div class="cobre-tudo"></div>
        
        
    </body>
</html>
<script>
    jQuery(document).ready(function() {
        jQuery('#rem_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#dest_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#con_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
    });
</script>