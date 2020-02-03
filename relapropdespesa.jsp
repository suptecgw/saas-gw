<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="mov_banco.conta.BeanConta"%>
<%@page import="java.util.Collection"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="nucleo.ModeloRelatorio"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.Calendar"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript" src="script/TalaoCheque.js" type="text/javascript"></script>
<script language="JavaScript" src="script/Despesa.js" type="text/javascript"></script>
<script language="JavaScript" src="script/contrato_frete_documento.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("reldespesas") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
    boolean despMovBancOutrosUsuarios = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("landespfl") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)){
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String modelo = request.getParameter("modelo");
    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    
    //Carrega a informações da conta
    BeanConsultaConta consultaConta = new BeanConsultaConta();
    int idFilial = (despMovBancOutrosUsuarios == true ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial());
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();  
    Collection<BeanConta> listaContas = consultaConta.mostraContas(idFilial, false, Apoio.getUsuario(request).getConexao(), limitarUsuarioVisualizarConta, idUsuario);
    request.setAttribute("listaContas", listaContas);
    
    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        
        java.util.Map param = new java.util.HashMap(13);
        String tipoData = request.getParameter("tipodata");
        String tipoDataRel = "";
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat fmtPost = new SimpleDateFormat("MM/dd/yyyy");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        Date dtinicial2 = formatador.parse(request.getParameter("dtinicial2"));
        Date dtfinal2 = formatador.parse(request.getParameter("dtfinal2"));
        Date dtinicial4 = formatador.parse(request.getParameter("dataInicial4"));
        Date dtfinal4 = formatador.parse(request.getParameter("dataFinal4"));
        Date dtCompetencia = formatador.parse("01/" + request.getParameter("competencia"));
        GregorianCalendar calendar = new GregorianCalendar();
        calendar.setTime(dtfinal2);
        dtfinal2.setDate(calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
        StringBuilder filtros = new StringBuilder();
        
        if (modelo.equals("P")) {
            param.put("TIPO_DATA", tipoData);
            param.put("DATA_INI", "'" + fmtPost.format(dtinicial) + "'");
            param.put("DATA_FIM", "'" + fmtPost.format(dtfinal) + "'");
            param.put("IDFILIAL", request.getParameter("idfilial"));
            //param.put("IDMOTORISTA", request.getParameter("idmotorista"));
            //param.put("IDAJUDANTE", request.getParameter("idajudante"));
            param.put("IDVEICULO", request.getParameter("idveiculo"));
            //param.put("IDREMETENTE", request.getParameter("idremetente"));
            //param.put("OPERADOR_REMETENTE", request.getParameter("apenasRemetente"));
            //param.put("IDDESTINATARIO", request.getParameter("iddestinatario"));
            //param.put("OPERADOR_DESTINATARIO", request.getParameter("apenasDestinatario"));
            //param.put("IDCONSIGNATARIO", request.getParameter("idconsignatario"));
            //param.put("OPERADOR_CONSIGNATARIO", request.getParameter("apenasConsignatario"));
            //param.put("CTRC", request.getParameter("situacao"));
            //param.put("BAIXADA", request.getParameter("baixado"));
            //param.put("CANCELADA", request.getParameter("cancelada"));
            //param.put("PROGRAMADA", request.getParameter("programada"));
            //param.put("BAIRRO", request.getParameter("bairroOrigem"));
            //param.put("BOOKING", request.getParameter("booking"));
            //param.put("GRUPOS", request.getParameter("grupos"));
            
            //Carregando as opções selecionadas
            filtros.append("Período Selecionado:").append(request.getParameter("dtinicial")).append(" a ").append(request.getParameter("dtfinal"));
            
            param.put("OPCOES", filtros.toString());

            request.setAttribute("map", param);
            request.setAttribute("rel", request.getParameter("personalizado"));
        } else {
            String veiculo = "";
            String competencia = request.getParameter("competencia");
            StringBuilder condicaoData = new StringBuilder();
            StringBuilder condicaoData2 = new StringBuilder();
            //exclusivamente para o modelo 9
            String dataInicial = "";
            String dataFinal = "";
            String idFornecedor = request.getParameter("idfornecedor");
            String idCliente = request.getParameter("idconsignatario");
//            String idConta = request.getParameter("idconta");
            String idsConta = request.getParameter("idsConta");
            String conta = null;
            String condicaoContabilizado = "";
            String idsGrupo = request.getParameter("grupoIds");

            /* 
             Geração de Relatório p/ mais de 1(um) Plano de Custo 
             Data : 8/12/2011
             */
            //Antes : String idsPlanoCusto = request.getParameter("idsPlanoCusto");
            String contasPlanoCusto = request.getParameter("contasPlanoCusto");
            // Antes : param.put("PLANOCUSTO", (!idsPlanoCusto.equals("0") ?" and idconta IN (" + idsPlanoCusto + ")":""));
            String sql = "";

            if ("exceto".equals(request.getParameter("tipoFiltroPlanoCusto"))) {
                sql = " AND NOT ( ";
            } else {
                sql = " AND ( ";
            }

            int max = contasPlanoCusto.split(",").length;
            for (int i = 1; i <= max - 1; i++) {
                if (i == max - 1) {
                    sql += "(conta LIKE '" + contasPlanoCusto.split(",")[i] + "%%')";
                } else {
                    sql += "(conta LIKE '" + contasPlanoCusto.split(",")[i] + "%%') OR ";
                }

            }
            sql += ")";

            param.put("PLANOCUSTO", (contasPlanoCusto.equals("0") ? "" : sql));
            // param.put("PLANOCUSTO", (!request.getParameter("idplanocusto").equals("0")?" and conta like '"+request.getParameter("plcusto_conta")+"%'":""));
            param.put("APENAS_SINTETICAS", (Boolean.parseBoolean(request.getParameter("apenasSinteticas")) ? "s" : "n"));
            if (modelo.equals("5")) {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and (fl_sale=" + request.getParameter("idfilial") + " or fl_despesa=" + request.getParameter("idfilial") + ")" : ""));
                param.put("IDFILIAL_COMP", request.getParameter("idfilial"));
                param.put("QUITADAS", (request.getParameter("mostrar").equals("ambas") ? "" : request.getParameter("mostrar").equals("quitadas") ? " and (des_baixado or sale_baixado)" : " and (not des_baixado or not sale_baixado)"));
                param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0") ? " and (vei_receita=" + request.getParameter("idveiculo") + " or vei_despesa=" + request.getParameter("idveiculo") + ") " : ""));
                param.put("IDVEICULO_COMP", request.getParameter("idveiculo"));
                param.put("IDUND_COMP", request.getParameter("id_und"));
                param.put("REMENTENTE", (!request.getParameter("idRemetente").equals("0") ? " and (remetente_id = " + request.getParameter("idRemetente") + ") " : ""));
                param.put("DESTINATARIO", (!request.getParameter("idDestinatario").equals("0") ? " and (destinatario_id = " + request.getParameter("idDestinatario") + ") " : ""));
            } else if (modelo.equals("4")) {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and (lancamento_filial_id=" + request.getParameter("idfilial") + ") " : ""));
                param.put("QUITADAS", (request.getParameter("mostrar").equals("ambas") ? "" : request.getParameter("mostrar").equals("quitadas") ? " and (lancamento_is_baixado)" : " and (not lancamento_is_baixado)"));
                param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0") ? " and (lancamento_veiculo_id=" + request.getParameter("idveiculo") + ") " : ""));
                param.put("REMENTENTE", (!request.getParameter("idRemetente").equals("0") ? " and (remetente_id = " + request.getParameter("idRemetente") + ") " : ""));
                param.put("DESTINATARIO", (!request.getParameter("idDestinatario").equals("0") ? " and (destinatario_id = " + request.getParameter("idDestinatario") + ") " : ""));
            } else if (modelo.equals("6")) {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and v2.idfilial=" + request.getParameter("idfilial") : ""));
                param.put("IDFILIALREC", (!request.getParameter("idfilial").equals("0") ? " and sl.filial_id=" + request.getParameter("idfilial") : ""));
                param.put("QUITADAS", (request.getParameter("mostrar").equals("ambas") ? "" : request.getParameter("mostrar").equals("quitadas") ? " and baixado" : " and not baixado"));
                param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0") ? " and idveiculo=" + request.getParameter("idveiculo") : ""));
                param.put("REMENTENTE", (!request.getParameter("idRemetente").equals("0") ? " and (co.remetente_id = " + request.getParameter("idRemetente") + ") " : ""));
                param.put("DESTINATARIO", (!request.getParameter("idDestinatario").equals("0") ? " and (co.destinatario_id = " + request.getParameter("idDestinatario") + ") " : ""));
            } else if (modelo.equals("9") || modelo.equals("12")) {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and (va.filial_id=" + request.getParameter("idfilial") + " OR vl_rateio = 0)" : ""));
                param.put("IDFILIALREC", (!request.getParameter("idfilial").equals("0") ? " and s.filial_id=" + request.getParameter("idfilial") : ""));
                //param.put("QUITADAS", (request.getParameter("mostrar").equals("ambas")?"":request.getParameter("mostrar").equals("quitadas")?" and baixado":" and not baixado"));
                //param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0")?" and idveiculo="+request.getParameter("idveiculo"):""));
            } else if (modelo.equals("10")) {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and (lancamento_filial_id=" + request.getParameter("idfilial") + ") " : ""));
                param.put("QUITADAS", (request.getParameter("mostrar").equals("ambas") ? "" : request.getParameter("mostrar").equals("quitadas") ? " and (lancamento_is_baixado)" : " and (not lancamento_is_baixado)"));
                param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0") ? " and (lancamento_veiculo_id=" + request.getParameter("idveiculo") + ") " : ""));
                param.put("REMENTENTE", (!request.getParameter("idRemetente").equals("0") ? " and (remetente_id = " + request.getParameter("idRemetente") + ") " : ""));
                param.put("DESTINATARIO", (!request.getParameter("idDestinatario").equals("0") ? " and (destinatario_id = " + request.getParameter("idDestinatario") + ") " : ""));
            } else if (modelo.equals("11")) {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and v.lancamento_filial_id= " + request.getParameter("idfilial") : ""));
            } else {
                param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and idfilial=" + request.getParameter("idfilial") : ""));
                param.put("QUITADAS", (request.getParameter("mostrar").equals("ambas") ? "" : request.getParameter("mostrar").equals("quitadas") ? " and baixado" : " and not baixado"));
                param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0") ? " and idveiculo=" + request.getParameter("idveiculo") : ""));
            }

            dataInicial = fmtPost.format(dtinicial);
            dataFinal = fmtPost.format(dtfinal);            

            if (modelo.equals("9") || modelo.equals("12")) {
                tipoData = "'" + request.getParameter("tipodata3") + "'";
                if (tipoData.equals("'dtemissao'")) {
                    filtros.append("Tipo de Data: Emissão");
                } else if (tipoData.equals("'vencimento'")) {
                    filtros.append("Tipo de Data: Vencimento");
                } else if (tipoData.equals("'pagamento'")) {
                    filtros.append("Tipo de Data: Pagamento");
                }
                filtros.append(",Período selecionado: " + Apoio.getFormatData(dtinicial2)).append(" até ").append(Apoio.getFormatData(dtfinal2));
            } else if(modelo.equals("11")){
                tipoData = "'" + request.getParameter("tipodata4") + "'";
                if (tipoData.equals("'dtemissao'")) {
                    filtros.append("Tipo de Data: Emissão");
                } else if (tipoData.equals("'vencimento'")) {
                    filtros.append("Tipo de Data: Vencimento");
                } else if (tipoData.equals("'pagamento'")) {
                    filtros.append("Tipo de Data: Pagamento");
                }
                filtros.append(",Período selecionado: " + Apoio.getFormatData(dtinicial4)).append(" até ").append(Apoio.getFormatData(dtfinal4));
            } else {
                if (tipoData.equals("dtemissao")) {
                    filtros.append("Tipo de Data: Emissão");
                } else if (tipoData.equals("dtentrada")) {
                    filtros.append("Tipo de Data: Entrada");
                } else if (tipoData.equals("vencimento")) {
                    filtros.append("Tipo de Data: Vencimento");
                } else if (tipoData.equals("dtpago")) {
                    filtros.append("Tipo de Data: Pagamento");
                } else if (tipoData.equals("competencia")) {
                    filtros.append("Tipo de Data: Competência");
                } else if (tipoData.equals("emissao_conciliacao")) {
                    filtros.append("Tipo de Data: Emissão (Conciliação)");
                } else if (tipoData.equals("entrada_conciliacao")) {
                    filtros.append("Tipo de Data: Entrada (Conciliação)");
                }
                filtros.append(",Período selecionado: " + request.getParameter("dtinicial")).append(" até " + request.getParameter("dtfinal"));
            }

            //Regra de Data
            if (tipoData.equals("competencia")) {
                filtros = new StringBuilder();
                filtros.append("Competência selecionada: " + competencia);
                condicaoData.append(" competencia ='").append(competencia).append("' ");
                if (modelo.equals("6")) {
                    condicaoData2.append(" sl.emissao_em between '").append(fmtPost.format(dtCompetencia)).append("' and '");
                    calendar.setTime(dtCompetencia);
                    dtCompetencia.setDate(calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
                    condicaoData2.append(fmtPost.format(dtCompetencia)).append("' ");
                }else if(modelo.equals("4")){    
                    condicaoData2.append(" lancamento_competencia ='").append(competencia).append("' ");
                    tipoData = "lancamento_competencia";
                }else if(modelo.equals("10")){    
                    condicaoData2.append(" lancamento_competencia ='").append(competencia).append("' ");
                    tipoData = "lancamento_competencia";
                }else{
                    condicaoData2.append(" competencia ='").append(competencia).append("' ");
                    param.put("COMPETENCIA", "'"+competencia+"'");
                }
            } else if (modelo.equals("1") || modelo.equals("2") || modelo.equals("3") || modelo.equals("7") || modelo.equals("8")) {
                condicaoData.append(" (").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("')");
                condicaoData2.append(" ").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("'");
            } else if (modelo.equals("4")) {
                if (tipoData.equals("emissao_conciliacao") || tipoData.equals("entrada_conciliacao")){
                    //condicaoData.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    condicaoData2.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                }else if (tipoData.equals("dtpago")){
                    tipoData = " lancamento_pagamento ";
                    condicaoData2.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                }else{
                    //condicaoData.append(" lancamento_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    condicaoData2.append(" lancamento_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    tipoData = " lancamento_" + tipoData;
                }
            } else if (modelo.equals("5")) {
                if (tipoData.equals("emissao_conciliacao") || tipoData.equals("entrada_conciliacao")){
                    condicaoData.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    condicaoData2.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("'");
                }else{
                    condicaoData.append(" (des_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    condicaoData.append(" or sale_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("')");
                    condicaoData2.append(" (des_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("'");
                    condicaoData2.append(" or sale_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("') ");
                    tipoData = " des_" + tipoData + ",sale_" + tipoData;
                }
            } else if (modelo.equals("10")) {
                if (tipoData.equals("emissao_conciliacao") || tipoData.equals("entrada_conciliacao")){
                    //condicaoData.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    condicaoData2.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                }else if (tipoData.equals("dtpago")){
                    tipoData = " lancamento_pagamento ";
                    condicaoData2.append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                }else{
                    //condicaoData.append(" lancamento_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    condicaoData2.append(" lancamento_").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                    tipoData = " lancamento_" + tipoData;
                }
            } else if (modelo.equals("6")) {
                condicaoData.append(" ").append(tipoData).append(" between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
                condicaoData2.append(" ").append(" sl.emissao_em between '").append(fmtPost.format(dtinicial)).append("' and '").append(fmtPost.format(dtfinal)).append("' ");
            } else if (modelo.equals("9") || modelo.equals("12")) {
                dataInicial = "'" + fmtPost.format(dtinicial2) + "'";
                dataFinal = "'" + fmtPost.format(dtfinal2) + "'";
            } else if (modelo.equals("10")) {
                veiculo = (!request.getParameter("idVeiculo").equals("0") ? " and (id_veiculo_receita=" + request.getParameter("idVeiculo") + " OR id_veiculo_despesa=" + request.getParameter("idVeiculo") + ")" : "");
                param.put("IDVEICULO", veiculo);
            }
            
            if (Boolean.parseBoolean(request.getParameter("ctbil_sim"))){
                condicaoContabilizado = " AND NOT isjacontabilizado ";
                filtros.append(",Apenas contabilizadas pelo Webtrans");
            }else if (Boolean.parseBoolean(request.getParameter("ctbil_nao"))){
                condicaoContabilizado = " AND isjacontabilizado ";
                filtros.append(",Apenas contabilizadas manualmente");
            }else{
                condicaoContabilizado = "";
            }

            if (request.getParameter("mostrar").equals("ambas")) {
                filtros.append(",Mostrar: Ambas");
            } else if (request.getParameter("mostrar").equals("quitadas")) {
                filtros.append(",Mostrar: Quitadas");
            } else if (request.getParameter("mostrar").equals("aberto")) {
                filtros.append(",Mostrar: Em aberto");
            }

            filtros.append((request.getParameter("fi_abreviatura").equals("") ? "" : ",Filial: " + request.getParameter("fi_abreviatura")));
            filtros.append((request.getParameter("idveiculo").equals("0") ? "" : ",Apenas o veículo " + request.getParameter("vei_placa")));
            filtros.append((request.getParameter("id_und").equals("0") ? "" : ",Apenas a unidade de custo " + request.getParameter("sigla_und")));

            String sqlConciliado = "";
            String sqlUndCusto = "";
            String sqlFornecedor = "";
            String sqlCliente = "";

            if (modelo.equals("1")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
//                    conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and coust_type_id=" + request.getParameter("id_und")  : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("2")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
//                    conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und") + " or unidade_custo_id = "+ request.getParameter("id_und") +")" : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("3")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
//                    conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und") + " or unidade_custo_id = "+ request.getParameter("id_und") +")" : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("4")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado"));
                if (idsConta!=(null)) {
//                    conta = (!idsConta.equals("0") ? " and (conta_baixa_id=" + idsConta +" ) " : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (lancamento_und_custo_id=" + request.getParameter("id_und") + ") " : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND (tipo = 'd' AND cliente_fornecedor_id = " + idFornecedor + " ) ");
                sqlCliente = (idCliente.equals("0") ? "" : " AND (tipo = 'r' AND cliente_fornecedor_id = " + idCliente + ") ");
            }else if (modelo.equals("5")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
//                    conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und") + ")" : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("6")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
//                    conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und") + " or unidade_custo_id = "+ request.getParameter("id_und") +")" : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("7")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
                    //conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und") + " or unidade_custo_id = "+ request.getParameter("id_und") +")" : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("8")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
                    //conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und") + " or unidade_custo_id = "+ request.getParameter("id_und") +")" : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("9") || modelo.equals("12")){
                sqlConciliado = "";
                tipoDataRel = "'" + request.getParameter("tipodata3") + "'";
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (coust_type_id=" + request.getParameter("id_und")+")" : "");
                if(request.getParameter("tipodata3").equals("dtemissao")){
                    tipoData = "dtemissao";
                }else if(request.getParameter("tipodata3").equals("pagamento")){
                    tipoData = "dtpago";
                }else if(request.getParameter("tipodata3").equals("vencimento")){
                    tipoData = "dtvenc";
                }
            }else if (modelo.equals("10")){
                sqlConciliado = (request.getParameter("mostrarConciliado").equals("ambas") ? "" : " AND conciliado = " + request.getParameter("mostrarConciliado") );
                if (idsConta!=(null)) {
                    //conta = (!idsConta.equals("0") ? " and conta_baixa_id=" + idsConta : "");
                    conta = (!idsConta.equals("0") ? " and conta_baixa_id IN (" + idsConta + ")" : "");
                } else {
                    conta = "";
                }
                sqlUndCusto = (!request.getParameter("id_und").equals("0") ? " and (lancamento_und_custo_id=" + request.getParameter("id_und") + ") " : "");
                sqlFornecedor = (idFornecedor.equals("0") ? "" : " AND idfornecedor = " + idFornecedor);
                sqlCliente = (idCliente.equals("0") ? "" : " AND idcliente = " + idCliente);
            }else if (modelo.equals("11")){
                param.put("PLANO_ZERADO", request.getParameter("chkMostrarZerados") + "");
                
                Date dtInicial4 = formatador.parse(request.getParameter("dataInicial4"));
                Date dtFinal4 = formatador.parse(request.getParameter("dataFinal4"));
                dataInicial = fmtPost.format(dtInicial4);
                dataFinal = fmtPost.format(dtFinal4);
                sqlConciliado = "";
                if(request.getParameter("tipodata4").equals("dtemissao")){
                    tipoData = "lancamento_dtemissao";
                }else if(request.getParameter("tipodata4").equals("pagamento")){
                    tipoData = "lancamento_pagamento";
                }else if(request.getParameter("tipodata4").equals("vencimento")){
                    tipoData = "lancamento_vencimento";
                }
                
                filtros.append((request.getParameter("fi_abreviatura").equals("") ? "" : ",Filial: " + request.getParameter("fi_abreviatura")));
                
            }
            
            //Validação para caso o usuario não tem permissão para visualizar nenhuma conta.
            if (request.getParameter("mostrar").equals("quitadas") && idsConta.equals("0") && limitarUsuarioVisualizarConta) {
                conta = " and conta_baixa_id = -1 ";
            }
            param.put("CONCILIADO", sqlConciliado);
            param.put("CONDICAO_DATA", condicaoData.toString());
            param.put("CONDICAO_DATA2", condicaoData2.toString());
            param.put("CONTABILIZADA", condicaoContabilizado);
            param.put("DATA_INI", dataInicial);
            param.put("DATA_FIM", dataFinal);
            param.put("TIPODATA", tipoData);
            param.put("LIQUIDO", request.getParameter("impostoliquido"));
            param.put("FORNECEDOR", sqlFornecedor);
            param.put("CLIENTE", sqlCliente);
            param.put("CONTA", conta);
            param.put("OPCOES", filtros.toString());
            param.put("IDUND", sqlUndCusto);
            param.put("TIPODATAREL", tipoDataRel);
            param.put("USUARIO",Apoio.getUsuario(request).getNome());  
            param.put("ID_GRUPO", idsGrupo.toString());
            param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
            
            
            request.setAttribute("map", param);
            request.setAttribute("rel", "apropdespmod" + modelo);
        }
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    
    } else if (acao.equals("iniciar")){
                request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_APROPRIACAO_PLANO_DE_CUSTO.ordinal());
        }
%>


<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    function voltar(){
        location.replace("./menu");
    }
    
    function modelos(modelo){
        //$("undCusto").style.display = "none";
        $("sintetica").style.display = "none";
        $("trCriteio1").style.display = "";
        $("trCriteio2").style.display = "none";
        $("trCriterio3").style.display = "none";
        $("trCriterio4").style.display = "none";
        $("trVeiculo").style.display = "";
        $("undCusto").style.display = "";
        $("trFornecedor").style.display = "none";
        $("trCliente").style.display = "none";
        $("trRemetente").style.display = "none";
        $("trDestinatario").style.display = "none";
        $("trQuitadas").style.display = "";
        $('trConta').style.display = "none";
        $("trImpostoliquido").style.display = "";
        $("trCtbil").style.display = "";
        $("tipodata").disabled = false;
        $("trPlNaoZerado").style.display = "none";
        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("modelo5").checked = false;
        $("modelo6").checked = false;
        $("modelo7").checked = false;
        $("modelo8").checked = false;
        $("modelo9").checked = false;
        $("modelo10").checked = false;
        $("modelo11").checked = false;
        $("modelo12").checked = false;
        $("modeloP").checked = false;
    
        if (modelo == '1'){
            //$("undCusto").style.display = "";
            $("sintetica").style.display = "";
            $('trConta').style.display = "";
            $("trCriterio3").style.display = "none";
            $("trGrupoFornecedor").style.display = "none";
            setModelo(1);
        }

        if (modelo == '2'){
            $('trConta').style.display = "";
            $("trGrupoFornecedor").style.display = "none";
        }

        if (modelo == '3'){
            $('trConta').style.display = "";
            $("trGrupoFornecedor").style.display = "none";
        }

        if (modelo == '4'){
            $("trFornecedor").style.display = "";
            $("trCliente").style.display = "";
            $("trRemetente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trCriterio3").style.display = "none";
            $('trConta').style.display = "";
            $("trGrupoFornecedor").style.display = "";
            setModelo(4);
        }

        if (modelo == '5'){
            $('trConta').style.display = "";
            $("trRemetente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trGrupoFornecedor").style.display = "none";
        }
        
        if (modelo == '6'){
            $('trConta').style.display = "";
            $("trRemetente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trGrupoFornecedor").style.display = "none";
        }

        if (modelo == '7'){
            $('trConta').style.display = "";
            $("trGrupoFornecedor").style.display = "none";
        }
        
        if (modelo == '8'){
            $("undCusto").style.display = "";
            $('trConta').style.display = "";
            $("trCriterio3").style.display = "none";
            $("trGrupoFornecedor").style.display = "none";
            setModelo(8);
        }
        if (modelo == '9'){
            $("trQuitadas").style.display = "none";
            $("trCriteio1").style.display = "none";
            $("trCriteio2").style.display = "none";
            $("trCriterio3").style.display = "";
            $("trVeiculo").style.display = "none";
            $("undCusto").style.display = "";       
            $("trGrupoFornecedor").style.display = "none";
            setModelo(9);
        }
        if(modelo == '10'){
            $('trConta').style.display = "";
            $("trRemetente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trGrupoFornecedor").style.display = "none";
        }
        if(modelo == '11'){
            $("trQuitadas").style.display = "none";
            $("trCriteio1").style.display = "none";
            $("trCriteio2").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("undCusto").style.display = "none";
            $("trImpostoliquido").style.display = "none";
            $("trCtbil").style.display = "none";
            $("trPlNaoZerado").style.display = "";
            $("trCriterio4").style.display = "";
            $("trGrupoFornecedor").style.display = "none";
            setModelo(11);
        }
        if (modelo == '12'){
            $("trQuitadas").style.display = "none";
            $("trCriteio1").style.display = "none";
            $("trCriteio2").style.display = "none";
            $("trCriterio3").style.display = "";
            $("trVeiculo").style.display = "none";
            $("undCusto").style.display = "";   
            $("trGrupoFornecedor").style.display = "none";
            setModelo(12);
        }
        $("modelo"+modelo).checked = true;
        validaModelo();
        
    }
  
    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaund(){
        post_cad = window.open('./localiza?acao=consultar&idlista=39','Unidade_de_custo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=24','Veiculo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    
    function localizaGrupoFornecedor(){
        var grupoFornecedor = this.getIdsGrupo();
        var paramaux = (grupoFornecedor != null && grupoFornecedor != "" ? " and id not in ("+grupoFornecedor+") " : "");
        post_cad = window.open('./localiza?acao=consultar&idlista=33&fecharJanela=false&paramaux4='+paramaux,'Grupo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
  
    function limparfilial(){
        $("idfilial").value = 0;
        $("fi_abreviatura").value = "";
    }

    function limparund(){
        $("id_und").value = 0;
        $("sigla_und").value = "";
    }

    function limparveiculo(){
        $("idveiculo").value = 0;
        $("vei_placa").value = "";
    }
    
    function validaModelo(){           
        if($('mostrar').value == "quitadas" && !$("modelo9").checked && !$("modelo11").checked && !$("modelo12").checked){               
            $('trConta').style.display = "";            
        }else{
            $('trConta').style.display = "none";   
        }       
    }
    
    var modelo;
    function getModelo(){
        
        return modelo;
    }
    
    function setModelo(id){
        modelo = id;
    }

    function popRel(){
        var modelo; 
        if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else{
            if ($("modelo1").checked)
                modelo = '1';
            else if ($("modelo2").checked)
                modelo = '2';
            else if ($("modelo3").checked)
                modelo = '3';
            else if ($("modelo4").checked)
                modelo = '4';
            else if ($("modelo5").checked)
                modelo = '5';
            else if ($("modelo6").checked)
                modelo = '6';
            else if ($("modelo7").checked)
                modelo = '7';
            else if ($("modelo8").checked)
                modelo = '8';
            else if ($("modelo9").checked)
                modelo = '9';
            else if ($("modelo10").checked)
                modelo = '10';
            else if ($("modelo11").checked)
                modelo = '11';
            else if ($("modelo12").checked)
                modelo = '12';
            else if($("modeloP").checked)
                modelo = "P";

            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";
            if($("modeloP").checked && $("personalizado").value == ""){
                return alert("Escolha um relátorio personalizado!")
            }
    
    
            var idsPlanoCusto = this.getIdsPlanoCusto();            
            var contasPlanoCusto = this.getContasPlanoCusto();
            var idsGrupoFornecedor = this.getIdsGrupo();
            var idsConta = 0;            
            if($("mostrar").value == "quitadas"){
                idsConta = getIdsConta();                
            }
            launchPDF('./relapropdespesa?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("idveiculo,vei_placa,idfilial,idplanocusto,impostoliquido,dtinicial,dtfinal,fi_abreviatura,tipodata,mostrar,id_und,sigla_und,idfornecedor,fornecedor,con_rzs,idconsignatario,mostrarConciliado,tipodata3,tipodata4,dataInicial4,dataFinal4,grupo_id")+
                '&apenasSinteticas='+$('chkSinteticas').checked
                +'&ctbil_ambas='+$('ctbil_ambas').checked
                +'&ctbil_sim='+$('ctbil_sim').checked
                +'&ctbil_nao='+$('ctbil_nao').checked
                +"&competencia="+$("competencia1").value
                +"&dtinicial2=01/"+$("competenciaInicial").value
                +"&dtfinal2=01/"+$("competenciaFinal").value
                +"&idsPlanoCusto="+idsPlanoCusto
                +"&grupoIds="+idsGrupoFornecedor
                +"&contasPlanoCusto="+contasPlanoCusto
                +"&personalizado="+$("personalizado").value
                +"&idRemetente="+$("idremetente").value
                +"&idDestinatario="+$("iddestinatario").value
//                +"&idconta="+$("idconta").value
                +"&idsConta="+idsConta
                +"&chkMostrarZerados="+$("chkMostrarZerados").checked
                +"&tipoFiltroPlanoCusto=" + $('tipoFiltroPlanoCusto').value);
           
           
        }
    }

    function verificarTipoData(valor){
        if(valor=="competencia"){
            visivel($("divCompetencia"));
            invisivel($("divData"));
            invisivel($("lbEntre"));
        }else{
            invisivel($("divCompetencia"));
            visivel($("divData"));
            visivel($("lbEntre"));
        }
    }
    // Retorna ids dos Planos de Custo Autor: Wagner Cunha
    function getIdsPlanoCusto(){
        var idsPlanoCusto = "0";	 
        var maxPlanoCusto = $("max").value ;  
        for (e = 1; e <= maxPlanoCusto; ++e)
        {
            if (getObj("planoCusto_"+e) != null) 
            {
                if (idsPlanoCusto == "")
                    idsPlanoCusto += getObj("planoCustoId_"+e).value;
                else  
                    idsPlanoCusto += ","+getObj("planoCustoId_"+e).value;
            }
        }    
        return idsPlanoCusto;
      
    }
    // Autor: Wagner Cunha
    function getContasPlanoCusto(){
        var contasPlanoCusto = "0";	 
        var maxPlanoCusto = $("max").value ;  
        for (e = 1; e <= maxPlanoCusto; ++e)
        {
            if (getObj("planoCusto_"+e) != null) 
            {
                if (contasPlanoCusto == "")
                    contasPlanoCusto += getObj("plCustoConta_"+e).value;
                else  
                    contasPlanoCusto += ","+getObj("plCustoConta_"+e).value;
            }
        }    
        return contasPlanoCusto;
      
    }
    // Autor: Wagner Cunha
    function aoClicarNoLocaliza(idjanela){
        var planoCusto ;
        var grupo;
        if(idjanela == 'Plano'){
            planoCusto = new PlanoCusto();
          
            planoCusto.idPlanoCusto = $("idplanocusto").value;
            planoCusto.descricaoPlanoCusto = $("plcusto_descricao").value;
            planoCusto.plCustoConta = $("plcusto_conta").value;
            addPlanoCusto(planoCusto);
        } else if (idjanela == 'Grupo') {
            grupo = new GrupoClienteFornecedor();
            grupo.idGrupo = $("grupo_id").value;
            grupo.descricaoGrupo = $("grupo").value;
            addGrupoFornecedor(grupo);
        }
    }
    
    function getIdsGrupo(){
        var idsGrupo = "";	 
        var maxGrupo = $("maxGrupo").value ;  
        for (i = 1; i <= maxGrupo; ++i) {
            if ($("grupoId_"+i) != null) {
                if (idsGrupo == '') {
                    idsGrupo += $("grupoId_"+i).value;
                } else {
                    idsGrupo += "," + $("grupoId_"+i).value;
                }
            }    
        }
        return idsGrupo;
    }
    
    function PlanoCusto(idPlanoCusto,descricaoPlanoCusto,plCustoConta){
        this.idPlanoCusto = (idPlanoCusto== null || idPlanoCusto == undefined ? 0 : idPlanoCusto);
        this.descricaoPlanoCusto = (descricaoPlanoCusto == null || descricaoPlanoCusto == undefined? 0 : descricaoPlanoCusto);
        this.plCustoConta = (plCustoConta == null || plCustoConta == undefined? 0 : plCustoConta);
    }

    // DOM para escolha dos Plano de Custo Autor: Wagner Cunha
    var countPlanoCusto = 0;
    function addPlanoCusto(planoCusto){
        if(planoCusto == null || planoCusto == undefined){
            planoCusto = new PlanoCusto();
        }
        countPlanoCusto++;
        var tabelaBase = $("bodyPlanoCusto");
        
        var tr0 = new Element ("tr" ,{
            id : "trPlanoCusto_"+countPlanoCusto ,
            className : "CelulaZebra2"
        });
        
        var td0 = new Element("td", {
            align : "center"
        });
        
        var img0 = Builder.node("img",{
            src: "img/lixo.png", 
            title:"Excluir Plano de Custo", 
            className:"imagemLink" ,
            onClick: "callExcluirPagto("+countPlanoCusto+")"

        });
        td0.appendChild(img0);
        tr0.appendChild(td0);
        var td1 = new Element ("td" , {
            align : "center" 
        }); 
        // Id Plano Custo
        var inp1 = new Element ("input" , {
            type  : "hidden" ,
            id    : "planoCustoId_" + countPlanoCusto , 
            value : planoCusto.idPlanoCusto
        });
        // Descrição Plano Custo
        var text0 = Builder.node ("input", {
            id : "plCustoConta_" + countPlanoCusto ,
            name : "plCustoConta" + countPlanoCusto ,
            className:"inputReadOnly8pt" ,
            readonly : true ,
            type  : "text" ,
            size  : "15" ,
            value : planoCusto.plCustoConta
        });   
        var text1 = Builder.node ("input", {
            id : "planoCusto_" + countPlanoCusto ,
            name : "planoCusto_" + countPlanoCusto ,
            className:"inputReadOnly8pt" ,
            readonly : true ,
            type  : "text" ,
            size  : "30" ,
            value : planoCusto.descricaoPlanoCusto
            
        });
        td1.appendChild(inp1);
        td1.appendChild(text0);
        td1.appendChild(text1);
        
        tr0.appendChild(td1);
        tabelaBase.appendChild(tr0);
        
        $("max").value = countPlanoCusto;
    }
    function callExcluirPagto(id){
        if (confirm("Tem certeza que deseja remover o plano de custo " + $('planoCusto_'+id).value+ " da lista abaixo?")){
            Element.remove($('trPlanoCusto_' + id));
            countPlanoCusto = countPlanoCusto -1;
        }
    }
    
    function GrupoClienteFornecedor(idGrupo, descricaoGrupo){
        this.idGrupo = (idGrupo== null || idGrupo == undefined ? 0 : idGrupo);
        this.descricaoGrupo = (descricaoGrupo == null || descricaoGrupo == undefined? 0 : descricaoGrupo);
    }
    
     // DOM para escolha dos Plano de Custo Autor: Wagner Cunha
    var countGrupo = 0;
    function addGrupoFornecedor(grupo){
        if(grupo == null || grupo == undefined){
            grupo = new GrupoClienteFornecedor();
        }
        countGrupo++;
        var tabelaBase = $("bodyGrupo");
        
        var tr0 = new Element ("tr" ,{
            id : "trGrupo_"+countGrupo ,
            className : "CelulaZebra2"
        });
        
        var td0 = new Element("td", {
            align : "center"
        });
        
        var img0 = Builder.node("img",{
            src: "img/lixo.png", 
            title:"Excluir Grupo", 
            className:"imagemLink" ,
            onClick: "callExcluirGrupo("+countGrupo+")"

        });
        td0.appendChild(img0);
        tr0.appendChild(td0);
        var td1 = new Element ("td" , {
            align : "center" 
        }); 
        // Id Plano Custo
        var inp1 = new Element ("input" , {
            type  : "hidden" ,
            id    : "grupoId_" + countGrupo , 
            value : grupo.idGrupo
        });
        // Descrição Plano Custo
        var text0 = Builder.node ("input", {
            id : "descricaoGrupo_" + countGrupo ,
            name : "descricaoGrupo_" + countGrupo ,
            className:"inputReadOnly8pt" ,
            readonly : true ,
            type  : "text" ,
            size  : "15" ,
            value : grupo.descricaoGrupo
        });   

        td1.appendChild(inp1);
        td1.appendChild(text0);
        
        tr0.appendChild(td1);
        tabelaBase.appendChild(tr0);
        
        $("maxGrupo").value = countGrupo;
    }

    function callExcluirGrupo(index){
        if (confirm("Tem certeza que deseja remover o grupo de cliente/fornecedor " + $("descricaoGrupo_"+index).value+ " da lista abaixo?")){
            Element.remove($("trGrupo_" + index));
            countGrupo = countGrupo -1;
        }
    }
    
    function localizaforn(){
        post_cad = window.open('./localiza?acao=consultar&idlista=21&paramaux=1','Fornecedor',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparforn(){
        document.getElementById("idfornecedor").value = "0";
        document.getElementById("fornecedor").value = "";
    }

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Consignatario_Fatura',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizaRemetente(){
        post_cad = window.open('./localiza?acao=consultar&idlista=3','remetente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizaDestinatario(){
        post_cad = window.open('./localiza?acao=consultar&idlista=4','destinatario',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizaconta(){
        post_cad = window.open('./localiza?acao=consultar&idlista=31&paramaux=and true','Conta',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparclifor(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }
    
    function limparRemetente(){
        $("idremetente").value = "0";
        $("rem_rzs").value = "";
    }
    
    function limparDestinatario(){
        $("iddestinatario").value = "0";
        $("dest_rzs").value = "";
    }
    
    function limparconta(){
        document.getElementById("idconta").value = 0;
        document.getElementById("conta").value = "";
    }
    
    function marcarDesmarcarTodas(){
        var maxConta = ($("maxConta") != null ? $("maxConta").value : 0);
        var marcarDesmarcarTodos = $("marcarDesmacar").checked;
        for (var qtdConta = 1; qtdConta <= maxConta; qtdConta++) {
            $("conta_"+qtdConta).checked = marcarDesmarcarTodos;
        }
    }
    
    function getIdsConta(){
        var idsConta = "0";	 
        var idsContaNaoMarcados = "0";	 
        var maxConta = ($("maxConta") != null ? $("maxConta").value : 0);
        var countNaoMarcados = 0;
        
        for (var qtdConta = 1; qtdConta <= maxConta; ++qtdConta){
            if ($("conta_"+qtdConta) != null && $("conta_"+qtdConta).checked){
                idsConta += ","+$("conta_"+qtdConta).value;
            }            
            if ($("conta_"+qtdConta) != null && $("conta_"+qtdConta).checked == false) {
                countNaoMarcados++;
                idsContaNaoMarcados += ","+$("conta_"+qtdConta).value;
            }
        }
        //Caso o usuario desmarque vou pegar todas as contas que esteja falso, caso seja todas ele coloca no idsConta.
        if(countNaoMarcados == maxConta){
            idsConta = idsContaNaoMarcados;
        }
        
        return idsConta;
      
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

        <title>Webtrans - Relatório de despesas por plano de custo</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value='${rotinaRelatorio}'/>);">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="id_und" id="id_und" value="0">
            <input type="hidden" name="idveiculo" id="idveiculo" value="0">
            <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
            <input type="hidden" name="plcusto_conta" id="plcusto_conta" value="">
            <input type="hidden" name="idconta" id="idconta" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de despesas por plano de custo</b></td>
            </tr>
        </table>

        <br>
        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"><center>Relatórios Principais</center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');">Relatórios Personalizados</td>
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
                <td width="24%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                    <label for="modelo1">Modelo 1</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das 
                    despesas por P. Custo (Sint&eacute;tico)</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                    <label for="modelo2">Modelo 2</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das 
                    despesas (Agrupadas por ve&iacute;culo)</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                    <label for="modelo3">Modelo 3</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das 
                    despesas (Agrupadas por filial)</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                    <label for="modelo4">Modelo 4</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Relatório de 
                    razão de P. Custo (Analítico)</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                    <label for="modelo5">Modelo 5</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das 
                    despesas X receitas (Sintético)</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo6" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                    <label for="modelo6">Modelo 6</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Relatório das despesas X receitas por veículo</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo7" id="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                    <label for="modelo7">Modelo 7</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Relatório dos veículos por P. custo</td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo8" id="modelo8" type="radio" value="8" onClick="javascript:modelos(8);">
                    <label for="modelo8">Modelo 8</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das 
                    despesas (Agrupadas por Unidade de Custo)</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo9" id="modelo9" type="radio" value="9" onClick="javascript:modelos(9);">
                    <label for="modelo9">Modelo 9</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    despesas por P. Custo (Agrupadas por Mês)</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo10" id="modelo10" type="radio" value="10" onClick="javascript:modelos(10);">
                    <label for="modelo10">Modelo 10</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Relatório de
                    razão de P. Custo agrupado por veículo (Analítico)</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo11" id="modelo11" type="radio" value="11" onClick="javascript:modelos(11);">
                    <label for="modelo11">Modelo 11</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Relatório de
                    Análise da semana por plano de custo</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo12" id="modelo12" type="radio" value="12" onClick="javascript:modelos(12);">
                    <label for="modelo12">Modelo 12</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Relatório de apropriação agrupado por unidade custo</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modeloP" id="modeloP" value="P"  onClick="javascript:modelos('P');">
                        <label for="modeloP">Personalizado</label>
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">
                        <select name="personalizado" id="personalizado" class="inputtexto">
                            <option value="">Escolha o modelo personalizado</option>
                            <%for (ModeloRelatorio rel : ModeloRelatorio.stringToModelo(Apoio.listRelatorioApropriacao(request))) {%>
                                <option value="relatorio_apropriacao_personalizado_<%=rel.getPrefixo()%>"><%=rel.getDescricao()%></option>
                            <%}%>
                        </select>
                </td>
            </tr>
            <tr class="tabela"> 
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr id="trCriteio1">
                <td height="24" class="TextoCampos">Por data de :</td>
                <td class="CelulaZebra2" colspan="2">
                    <select id="tipodata" name="tipodata" class="inputtexto" onchange="verificarTipoData(this.value);">
                        <option value="dtemissao" selected>Emiss&atilde;o (Lançamento)</option>
                        <option value="dtentrada">Entrada/Saída (Lançamento)</option>
                        <option value="vencimento">Vencimento</option>
                        <option value="dtpago">Pagamento</option>
                        <option value="competencia">Competência</option>
                        <option value="emissao_conciliacao">Emiss&atilde;o (Conciliação)</option>
                        <option value="entrada_conciliacao">Entrada (Conciliação)</option>
                    </select>
                    <label id="lbEntre"> entre </label>
                    <span id="divData">
                        <strong> <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"  onblur="alertInvalidDate(this)" class="fieldDate" />
                        </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"onblur="alertInvalidDate(this)" class="fieldDate" /></strong>
                    </span>
                    <span id="divCompetencia" style="display: none">
                        <input name="competencia1" type="text" id="competencia1" value="<%=Apoio.getDataAtual().substring(3)%>" size="10" maxlength="10" onkeypress="mascaraCompetencia(this)" class="inputTexto" />
                    </span>
                </td>
            </tr>
            <tr id="trCriteio2" style="display: none">
<!--                <td height="24" class="TextoCampos">Por data de :</td>
                <td width="" class="CelulaZebra2" colspan="2">
                    Emissão entre:<input name="competenciaInicial" type="text" id="competenciaInicial" value="<%=Apoio.getDataAtual().substring(3)%>" size="10" maxlength="10" onkeypress="mascaraCompetencia(this)" class="inputTexto" />
                    e
                    <input name="competenciaFinal" type="text" id="competenciaFinal" value="<%=Apoio.getDataAtual().substring(3)%>" size="10" maxlength="10" onkeypress="mascaraCompetencia(this)" class="inputTexto" />
                </td>-->
            </tr>
            <tr id="trCriterio3" style="display: none">
                <td height="24" class="TextoCampos">Por data de :</td>
                <td colspan="2" class="CelulaZebra2">
                    <select id="tipodata3" name="tipodata3" class="inputtexto" onchange="verificarTipoData(this.value);">
                        <option value="dtemissao" selected>Emiss&atilde;o (Despesa)</option>
                        <option value="vencimento">Vencimento</option>
                        <option value="pagamento">Pagamento</option>
                    </select>
                    <label id="lbEntre3"> entre </label>
                    <span id="divData3">
                        <strong> <input name="competenciaInicial" type="text" id="competenciaInicial" value="<%=Apoio.getDataAtual().substring(3)%>" size="10" maxlength="10" onkeypress="mascaraCompetencia(this)" class="inputTexto" />
                        </strong>e<strong>
                        <input name="competenciaFinal" type="text" id="competenciaFinal" value="<%=Apoio.getDataAtual().substring(3)%>" size="10" maxlength="10" onkeypress="mascaraCompetencia(this)" class="inputTexto" /></strong>
                    </span>
                </td>
            </tr>
            <tr id="trCriterio4" style="display: none">
                <td height="24" class="TextoCampos">Por data de :</td>
                <td colspan="2" class="CelulaZebra2">
                    <select id="tipodata4" name="tipodata4" class="inputtexto" onchange="verificarTipoData(this.value);">
                        <option value="dtemissao" selected>Emiss&atilde;o</option>
                        <option value="vencimento">Vencimento</option>
                        <option value="pagamento">Pagamento</option>
                    </select>
                    <label id="lbEntre4"> entre </label>
                    <span id="divData4">
                        <strong> <input name="dataInicial4" type="text" id="dataInicial4" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate" />
                        </strong>e<strong>
                        <input name="dataFinal4" type="text" id="dataFinal4" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate" /></strong>
                    </span>
                </td>
            </tr>
            <tr class="tabela"> 
                <td height="18" colspan="3"> 
                    <div align="center">Filtros</div></td>
            </tr>
            <tr> 
                <td colspan="3"> <table width="100%" class="bordaFina">
                        <tr name="trQuitadas" id="trQuitadas">
                            <td width="24%" class="TextoCampos">Mostrar apenas: </td>
                            <td width="76%" class="CelulaZebra2">
                                <select id="mostrar" name="mostrar" class="inputtexto" onchange="validaModelo();">
                                    <option value="ambas">Ambas</option>
                                    <option value="quitadas">Quitadas</option>
                                    <option value="aberto">Em aberto</option>
                                </select>
                                <select id="mostrarConciliado" name="mostrarConciliado" class="inputtexto" onchange="validaModelo();">
                                    <option value="ambas">Ambas</option>
                                    <option value="true">Conciliados</option>
                                    <option value="false">Não Conciliados</option>
                                </select>
                            </td>
                        </tr>
                        <tr id="trConta" style="display: none">

<!--                            <td class="TextoCampos">Apenas a conta: </td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="conta" type="text" id="conta" class="inputReadOnly" size="15" maxlength="80" readonly="true">
                                    <input name="localiza_conta" type="button" class="inputBotaoMin" id="localiza_clifor" value="..." onClick="javascript:localizaconta();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:limparconta();"></strong></td>-->                                
                            <td colspan="9" class="CelulaZebra2NoAlign">                                
                                <fieldset>
                                    <legend align="left">Apenas a(s) conta(s)</legend>
                                    <table width="100%" class="tabelaZerada">
                                        <tbody>
                                            <tr class="CelulaZebra2NoAlign">
                                                <td colspan="4">
                                                    <label>
                                                        <input type="checkbox" id="marcarDesmacar" name="marcarDesmarcar" checked="" onclick="marcarDesmarcarTodas();"/>
                                                        <b>Marcar/Desmarcar Todas</b>
                                                    </label>
                                                </td>
                                            </tr>                                        
                                            <c:forEach var="conta" varStatus="status" items="${listaContas}">
                                                <c:if test="${status.count % 4 == 1}">
                                                    <tr class="CelulaZebra2NoAlign">
                                                </c:if>     
                                                    <!--Lógica do colspan, caso seja a ultima conta, verifico se é impar ou par ai adiciono 4, caso contrario 0-->
                                                    <td colspan="${status.last && (status.count % 2 == 1 || status.count % 2 == 0) ? '4' : '0'}">
                                                        <label>
                                                            <input type="checkbox" id="conta_${status.count}" name="conta_${status.count}" value="${conta.idConta}" />                                                    
                                                            ${conta.numero} - ${conta.descricao}                                                                
                                                        </label>
                                                    </td>
                                                <c:if test="${status.count % 4 == 0}">
                                                    </tr>
                                                </c:if>
                                                <c:if test="${status.last}">                                                    
                                                    <input type="hidden" id="maxConta" name="maxConta" value="${status.count}"/>                                                    
                                                </c:if>
                                            </c:forEach>
                                        </tbody>
                                    </table>                                    
                                </fieldset>
                            </td>
                        </tr>
                        <tr id="trImpostoliquido">
                            <td class="TextoCampos">Reten&ccedil;&atilde;o de impostos:</td>
                            <td class="CelulaZebra2"><select id="impostoliquido" name="impostoliquido" class="inputtexto">
                                    <option value="S" selected>Considerar o valor líquido do lançamento</option>
                                    <option value="N">Considerar o valor bruto do lançamento</option>
                                </select></td>
                        </tr>
                        <tr id="trVeiculo">  
                            <td class="TextoCampos">Apenas um ve&iacute;culo:</td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly" size="25" maxlength="80" readonly="true">
                                    <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..." onClick="javascript:localizaveiculo();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparveiculo();"></strong></td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos"><div align="right">Apenas uma filial:</div></td>
                            <td class="TextoCampos"><div align="left"><strong> 
                                        <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="25" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:limparfilial();"> 
                                        <%}%>
                                    </strong></div></td>
                        </tr>
                        <tr name="undCusto" id="undCusto"> 
                            <td class="TextoCampos"><div align="right">Apenas uma und. custo:</div></td>
                            <td class="TextoCampos"><div align="left"><strong> 
                                        <input name="sigla_und" type="text" id="sigla_und" value="" class="inputReadOnly" size="15" maxlength="60" readonly="true">
                                        <input name="localiza_und" type="button" class="botoes" id="localiza_und" value="..." onClick="javascript:localizaund();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:limparund();"> 
                                    </strong></div></td>
                        </tr>
                        <tr name="trFornecedor" id="trFornecedor" style="display: none;">
                            <td class="TextoCampos">Apenas o fornecedor:</td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="fornecedor" type="text" id="fornecedor" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" value="..." onClick="javascript:localizaforn();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparforn();">
                                        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
                                    </strong></div>
                            </td>
                        </tr>
                        <tr name="trCliente" id="trCliente" style="display: none;">
                            <td class="TextoCampos"><div align="right">Apenas o cliente:</td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizacliente();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();">
                                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                                    </strong></div>
                            </td>
                        </tr>
                        <tr name="trRemetente" id="trRemetente" style="display: none;">
                            <td class="TextoCampos"><div align="right">Apenas o Remetente</td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizaRemetente();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparRemetente();">
                                        <input type="hidden" name="idremetente" id="idremetente" value="0">
                                    </strong></div>
                            </td>
                        </tr>
                        <tr name="trDestinatario" id="trDestinatario" style="display: none;">
                            <td class="TextoCampos"><div align="right">Apenas o Destinatario:</td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizaDestinatario();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparDestinatario();">
                                        <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
                                    </strong></div>
                            </td>
                        </tr>
                        <tr id="trCtbil">
                            <td class="TextoCampos">Mostrar Lançamentos:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="radio" name="ctbil_ambas" id="ctbil_ambas" value="radiobutton" onclick="javascript:$('ctbil_sim').checked = false;$('ctbil_nao').checked = false;this.checked = true;" checked>Ambos
                                <input type="radio" name="ctbil_nao" id="ctbil_nao" value="radiobutton" onclick="javascript:$('ctbil_ambas').checked = false;$('ctbil_sim').checked = false;this.checked = true">Contabilizados Manualmente
                                <input type="radio" name="ctbil_sim" id="ctbil_sim" value="radiobutton" onclick="javascript:$('ctbil_nao').checked = false;$('ctbil_ambas').checked = false;this.checked = true">Contabilizados Webtrans
                            </td>    
                        </tr>
                        <tr id="trPlano"> 
                            <td colspan="9"> 
                                <table id="node_grupos" border="0" class="bordaFina" width="100%">
                                    <tbody id="bodyPlanoCusto" name="bodyPlanoCusto" > 
                                        <tr class="cellNotes"> 
                                            <td width="3%" class="CelulaZebra2">
                                                <div align="center">
                                                    <img src="img/add.gif" border="0" title="Adiciona um novo Plano de Custo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=32&fecharJanela=false&paramaux=1','Plano')">          
                                                </div>
                                            </td>
                                            <td width="97%" class="CelulaZebra2" >
                                                <input type="hidden" name="plcusto_descricao" id="plcusto_descricao" value="0"/>
                                                <input type="hidden" name="max" id="max" value="0" />
                                                <div align="center">
                                                    <select name="tipoFiltroPlanoCusto" id="tipoFiltroPlanoCusto" class="inputtexto">
                                                        <option value="apenas" selected>Apenas</option>
                                                        <option value="exceto">Exceto</option>
                                                    </select>
                                                    <label for="tipoFiltroPlanoCusto"><strong>o(s) plano(s) de custo(s) abaixo</strong></label>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <tr id="trGrupoFornecedor" style="display:none;"> 
                            <td colspan="9"> 
                                <table id="node_gruposfornecedor" border="0" class="bordaFina" width="100%">
                                    <tbody id="bodyGrupo" name="bodyGrupo" > 
                                        <tr class="cellNotes"> 
                                            <td width="3%" class="CelulaZebra2">
                                                <div align="center">
                                                    <!--<img src="img/add.gif" border="0" title="Adiciona um novo Grupo de Fonecedor/Cliente" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33&fecharJanela=false&paramaux=1','Grupo')">-->          
                                                    <img src="img/add.gif" border="0" title="Adiciona um novo Grupo de Fonecedor/Cliente" class="imagemLink" onClick="javascript:localizaGrupoFornecedor();">         
                                                </div>
                                            </td>
                                            <td width="97%" class="CelulaZebra2" >
                                                <input type="hidden" name="maxGrupo" id="maxGrupo" value="0" />
                                                <div align="center">
                                                    <b>
                                                        Apenas o(s) grupo(s) de clientes/fornecedores
                                                    </b>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <tr name="sintetica" id="sintetica">
                            <td colspan="2" class="TextoCampos"><div align="center">
                                    <input name="chkSinteticas" type="checkbox" id="chkSinteticas">
                                    Mostrar apenas contas sintéticas
                                </div></td>
                        </tr>
                        <tr name="trPlNaoZerado" id="trPlNaoZerado" style="display: none;">
                            <td colspan="2" class="TextoCampos">
                                <div align="center">
                                    <input name="chkMostrarZerados" type="checkbox" id="chkMostrarZerados">
                                    Mostrar Planos com total zero
                                </div>
                            </td>
                        </tr>
                    </table></td>
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
                        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                        <%}%>
                    </div></td>
            </tr>
        </table>
        </div>
        <div id="tabDinamico"></div>
    </body>
</html>
