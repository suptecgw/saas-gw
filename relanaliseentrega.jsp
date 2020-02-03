<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="usuario.BeanCadUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>

<script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>

<link href="estilo.css" rel="stylesheet" type="text/css">
<link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
<link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">



<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relanaliseentrega") > 0); // a permissao e´a mesma de analise venda
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
    boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
    boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    
    int nivelFilialFranquia = Apoio.getUsuario(request).getAcesso("verctefiliais");
    int nivelUserToFilial = Apoio.getUsuario(request).getAcesso("reloutrasfiliais");
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    String tipoFilialConfig = cfg.getMatrizFilialFranquia();

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


    //pegar id destinatario

    List<String> idsDestinatario = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("dest_rzs"))) {
            String[] splitDestinatarios = request.getParameter("dest_rzs").split("!@!");
            for (String splitDestinatario: splitDestinatarios) {
                String[] splitDestinatarioID = splitDestinatario.split("#@#");
                if (splitDestinatarioID.length >= 2) {
                    idsDestinatario.add(String.valueOf(Apoio.parseInt(splitDestinatarioID[1])));
                }
            }
        }

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        String modelo = request.getParameter("modelo");
        String tipoModelo3 = request.getParameter("tipo_rel");
        String tipoModelo7 = request.getParameter("tipo_rel");
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        String cliente = "";
        StringBuilder filial = null;
        String cidadeDestino = "";
        String condicaoEntregue = "";
        String entregues = request.getParameter("entregues");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String tipoTransporte = "";
        String remetente = "0";
        String destinatario = "0";
        /* Campo adicionados na data 10/1/2012 */
        String idMotorista = "";
        String CTRC = "";
        String manifesto = "";
        String anoManifesto = "";
        String ocorrencia = "";
        String isResolvido = "";
        //Mostrar CT's (var tc = variavel aux )
        String tc = "";
        String filtroUF = "";
        String tipoFpag = request.getParameter("tipoFpag");
        // 16-12-2013 - Paulo - novos campos
        String idredespachante = (request.getParameter("idredespachante") == null ? "0" : request.getParameter("idredespachante"));
        String representante = "";
        //14/09/2015 Marcus Leal
        String idDestinatario = (request.getParameter("iddestinatario") == null ? "0" : request.getParameter("iddestinatario"));
        String serie = "";
        String performEntregas = request.getParameter("performance");
        String condicaoPerformance = "";

        //Apenas os CTs Normais
        tc = (Boolean.parseBoolean(request.getParameter("ctNormal")) ? "'n'" : "");
        //Apenas os CTs Locais
        tc += (Boolean.parseBoolean(request.getParameter("ctLocal")) ? (tc.equals("") ? "'l'" : ",'l'") : "");
        //Apenas os CTs Diarias
        tc += (Boolean.parseBoolean(request.getParameter("ctDiaria")) ? (tc.equals("") ? "'i'" : ",'i'") : "");
        //Apenas os CTs Paletização
        tc += (Boolean.parseBoolean(request.getParameter("ctPaletizacao")) ? (tc.equals("") ? "'p'" : ",'p'") : "");
        //Apenas os CTs Complementares
        tc += (Boolean.parseBoolean(request.getParameter("ctComplementar")) ? (tc.equals("") ? "'c'" : ",'c'") : "");
        //Apenas os CTs Reentrega
        tc += (Boolean.parseBoolean(request.getParameter("ctReentrega")) ? (tc.equals("") ? "'r'" : ",'r'") : "");
        //Apenas os CTs Devolução
        tc += (Boolean.parseBoolean(request.getParameter("ctDevolucao")) ? (tc.equals("") ? "'d'" : ",'d'") : "");
        //Apenas os CTs Cortesia
        tc += (Boolean.parseBoolean(request.getParameter("ctCortesia")) ? (tc.equals("") ? "'b'" : ",'b'") : "");
        //Apenas os CTs Substituição
        tc += (Boolean.parseBoolean(request.getParameter("ctSubstituicao")) ? (tc.equals("") ? "'s'" : ",'s'") : "");
        //Apenas os CTs Anulacao
        tc += (Boolean.parseBoolean(request.getParameter("ctAnulacao")) ? (tc.equals("") ? "'a'" : ",'a'") : "");

        String tipoConhecimento = "";
        if (modelo.equals("1") || modelo.equals("4") || modelo.equals("9")) {
            tipoConhecimento = (tc.equals("") ? "" : " AND vf.tipo_conhecimento IN (" + tc + ")");
        } else {
            tipoConhecimento = (tc.equals("") ? "" : " AND tipo_conhecimento IN (" + tc + ")");
        }
        
        cliente = (idsConsignatario.isEmpty() ? "" : " and idconsignatario " + ("NotIn".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
        //cliente = (idsConsignatario.isEmpty() ? "" : " and sl.consignatario_id " + ("<>".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");

        remetente = (!idsRemetente.isEmpty() ? " and idremetente " + ("NotIn".equals(request.getParameter("excetoRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")" : "");
        

        destinatario = (!idsDestinatario.isEmpty() ? " and iddestinatario " + ("NotIn".equals(request.getParameter("excetoDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatario) + ")" : "");
        

        if (modelo.equals("1") || modelo.equals("4") || modelo.equals("9")) {
            ocorrencia = (!request.getParameter("ocorrenciaId").equals("0") ? " AND " + request.getParameter("ocorrenciaId") + " IN (SELECT oco.ocorrencia_ctrc_id FROM ocorrencias oco WHERE oco.sale_id = vf.id )" : "");
            isResolvido = (Boolean.parseBoolean(request.getParameter("isResolvido")) ? " AND  (COALESCE((SELECT COUNT(*) FROM ocorrencias oco LEFT JOIN ocorrencia_ctrcs occ ON oco.ocorrencia_ctrc_id = occ.id"
                    + " WHERE oco.sale_id = vf.id AND occ.is_obriga_resolucao AND NOT oco.is_resolvido),0))>0" : "");
        } else {
            if (modelo.equals("5")) {
                ocorrencia = (!request.getParameter("ocorrenciaId").equals("0") ? " AND " + request.getParameter("ocorrenciaId") + " IN (SELECT oco.ocorrencia_ctrc_id FROM ocorrencias oco WHERE oco.sale_id = v.id )" : "");
                isResolvido = (Boolean.parseBoolean(request.getParameter("isResolvido")) ? " AND (COALESCE((SELECT COUNT(*) FROM ocorrencias oco LEFT JOIN ocorrencia_ctrcs occ ON oco.ocorrencia_ctrc_id = occ.id"
                        + " WHERE oco.sale_id = v.id AND occ.is_obriga_resolucao AND NOT oco.is_resolvido),0))>0 " : "");
            } else {
                ocorrencia = (!request.getParameter("ocorrenciaId").equals("0") ? " AND " + request.getParameter("ocorrenciaId") + " IN (SELECT oco.ocorrencia_ctrc_id FROM ocorrencias oco WHERE oco.sale_id = vf.id )" : "");
                isResolvido = (Boolean.parseBoolean(request.getParameter("isResolvido")) ? " AND  (COALESCE((SELECT COUNT(*) FROM ocorrencias oco LEFT JOIN ocorrencia_ctrcs occ ON oco.ocorrencia_ctrc_id = occ.id"
                        + " WHERE oco.sale_id = vf.id AND occ.is_obriga_resolucao AND NOT oco.is_resolvido),0))>0" : "");
            }
        }
        filial =  new StringBuilder();
        if (modelo.equals("3")) {
            if (tipoModelo3.equals("1")) {
                if (request.getParameter("idfilial") != null && !"0".equals(request.getParameter("idfilial")) && !"".equals(request.getParameter("idfilial"))) {
                    filial.append(" and filial_ctrc_id =").append(request.getParameter("idfilial"));
                }
            } else {
                if (request.getParameter("idfilialentrega") != null && !"0".equals(request.getParameter("idfilialentrega")) && !"".equals(request.getParameter("idfilialentrega"))){
                    filial.append("and chegada_em is not null and id_filial_entrega =").append(request.getParameter("idfilialentrega"));
                }else{
                    filial.append("and chegada_em is not null ");
                }
            }
        } else {
            if (request.getParameter("idfilial") != null && !"0".equals(request.getParameter("idfilial")) && !"".equals(request.getParameter("idfilial"))) {
                filial.append(" and filial_ctrc_id =").append(request.getParameter("idfilial"));
            }
            if (request.getParameter("idfilialentrega") != null && !"0".equals(request.getParameter("idfilialentrega")) && !"".equals(request.getParameter("idfilialentrega"))){
                 filial.append(" and id_filial_entrega =").append(request.getParameter("idfilialentrega"));
            }
        }
        cidadeDestino = (!request.getParameter("idCidadeDestino").equals("0") ? " and cidade_destinatario_id=" + request.getParameter("idCidadeDestino") : "");
        //condição da entrega
        condicaoEntregue = (entregues == null || entregues.equals("a") ? "" : " AND emaberto = " + entregues.equals("n"));
        if (entregues.equals("esc")) {
            condicaoEntregue += " and baixado_no_dia is null ";
        } else if (entregues.equals("n2")) {
            if (modelo.equals("1")){
                condicaoEntregue = " and emaberto and vf.id NOT IN (SELECT idctrc FROM romaneio_ctrc WHERE idctrc is not null) ";
            }else if (modelo.equals("4") || modelo.equals("9")){
                condicaoEntregue = " and emaberto and vf.id NOT IN (SELECT idctrc FROM romaneio_ctrc WHERE idctrc is not null) ";
            }else if (modelo.equals("5")){
                condicaoEntregue = " and emaberto and v.id NOT IN (SELECT idctrc FROM romaneio_ctrc WHERE idctrc is not null) ";
            }else if (modelo.equals("6")){
                condicaoEntregue = " and emaberto and vf.id NOT IN (SELECT idctrc FROM romaneio_ctrc WHERE idctrc is not null) ";
            }else{
                condicaoEntregue = " and emaberto and vf.id NOT IN (SELECT idctrc FROM romaneio_ctrc WHERE idctrc is not null) ";
            }
        } else if (entregues.equals("at")) {
            if (modelo.equals("1")){
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }else if (modelo.equals("2")){
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }else if (modelo.equals("3")){
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }else if (modelo.equals("4") || modelo.equals("9")){
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }else if (modelo.equals("5")){
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }else if (modelo.equals("6")){
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }else{
                condicaoEntregue = " and baixa_em is null AND current_date > previsao_entrega_em ";
            }
        }
        tipoTransporte = (!request.getParameter("tipoTransporte").equals("false") ? " AND tipo_transporte='" + request.getParameter("tipoTransporte") + "'" : "");

        //Verificando o critério de datas
        String tipoData = request.getParameter("tipodata");
        idMotorista = (request.getParameter("idMotorista") != null && !request.getParameter("idMotorista").equals("0")  ? " AND motorista_id=" + request.getParameter("idMotorista") + " " : "");
        if (modelo.equals("5")) {
            if (tipoData.equals("romaneio")) {
                //tipoData = " (SELECT dtromaneio FROM romaneio r JOIN romaneio_ctrc rc ON (r.idromaneio = rc.idromaneio) WHERE rc.idctrc = v.id ORDER BY r.numromaneio desc LIMIT 1) ";
                tipoData = " rom.dtromaneio ";
            }
            idMotorista = (request.getParameter("idMotorista") != null && !request.getParameter("idMotorista").equals("0")? " AND v.motorista_id = " + request.getParameter("idMotorista") + " " : "");
        }

        CTRC = (!request.getParameter("numCtrc").equals("") && request.getParameter("numCtrc") != null ? " AND numero='" + request.getParameter("numCtrc") + "' " : "");
        List<String> series = new ArrayList<>();
        if (request.getParameter("serie") != null) {
            for (String s : request.getParameter("serie").split(",")) {
                series.add(Apoio.SqlFix(s));
            }
        }
        serie = (!"".equals(request.getParameter("serie")) ? " and serie " + ("NotIn".equals(request.getParameter("excetoSerie")) ? " NOT " : "") + " IN (" + String.join(",", series) + ")" : "");
        manifesto = (!request.getParameter("numeroManifesto").equals("") && request.getParameter("numeroManifesto") != null ? " AND nmanifesto='" + request.getParameter("numeroManifesto") + "' " : "");
        anoManifesto = (!request.getParameter("anoManifesto").equals("") && request.getParameter("anoManifesto") != null ? " AND ano='" + request.getParameter("anoManifesto") + "' " : "");

        //Filtro UF 
        if (request.getParameter("uf") != null && !request.getParameter("uf").equals("")){
            filtroUF = " AND uf_destinatario " + request.getParameter("apenasUF") + " ('" + request.getParameter("uf").replaceAll(",", "','") + "') ";
        }
        //Filtro representante - 16-12-2013 - Paulo
        representante = "";
        if(modelo.equals("1") || modelo.equals("4") || modelo.equals("6") || modelo.equals("8") || modelo.equals("9")){
            if(!request.getParameter("idredespachante").equals("0")){
                representante = " AND (vf.redespachante_id = " + idredespachante+" or vf.representante_entrega2_id = " +idredespachante + ")";
            }
        }else if(modelo.equals("7")){
            if(!request.getParameter("idredespachante").equals("0")){
                representante = " AND (vf.redespachante_id = " + idredespachante+" or vf.representante_entrega2_id = " +idredespachante + " ) ";
            }
        }else if(modelo.equals("5")){
            if(!request.getParameter("idredespachante").equals("0")){
                representante = " AND v.redespachante_id = " + idredespachante+" or v.representante_entrega2_id = " +idredespachante;
            }
        }else if(modelo.equals("2") || modelo.equals("3")){
            if(!request.getParameter("idredespachante").equals("0")){
                representante = " AND redespachante_id = " + idredespachante+" or representante_entrega2_id = " +idredespachante;
            }
        }
        
        String pendenciaFaturamento = "";
        
        boolean isPendenciaFaturamento = Apoio.parseBoolean(request.getParameter("isPendenciaFaturamento"));
            if (isPendenciaFaturamento) {
               // if(modelo.equals("3") || modelo.equals("4") || modelo.equals("5") || modelo.equals("6")){
                
                    pendenciaFaturamento = " and case when oco_ct.is_devolucao and not is_resolvido_devolucao or oco_ct.is_reentrega and not is_resolvido_reentrega or oco_ct.is_complementar and not is_resolvido_complementar then  true end";
              //  }else{
                    pendenciaFaturamento = " and case when  (is_diaria and not is_resolvido_diaria) or (is_pallet and not is_resolvido_pallet) or (is_devolucao and not is_resolvido_devolucao) or (is_reentrega and not is_resolvido_reentrega) or (is_complementar and not is_resolvido_complementar) then true else false end ";
              //  }
            } 
        
        int qtdDias = Apoio.parseInt(request.getParameter("qtdDAtraso"));
        
        String sqlAtraso = "";
        String sqlProtocolo = "";
        String sqlAgrupamento = "";
        String sqlOrdenacao = "";
        String sqlGrupo = "";

        //Regra do grupo
        if (request.getParameter("excetoGrupo").equals("IN")) {
            sqlGrupo = (request.getParameter("grupos").equals("") ? "" : " and grupo_id IN (" + request.getParameter("grupos") + ")");
        }else{
            sqlGrupo = (request.getParameter("grupos").equals("") ? "" : " and (grupo_id NOT IN (" + request.getParameter("grupos") + ") OR grupo_id is null )");
        }
        
        if (modelo.equals("1")){
            sqlAtraso = (qtdDias > 0 ? " AND dias_atraso_entrega >= " +qtdDias + " " : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }else if (modelo.equals("2")){
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }else if (modelo.equals("3")){
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }else if (modelo.equals("4")){
            sqlAtraso = (qtdDias > 0 ? " AND ( (baixa_em - previsao_entrega_em) > 0 and (baixa_em - previsao_entrega_em) >= " +qtdDias+")" : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }else if (modelo.equals("5")){
            sqlAtraso = (qtdDias > 0 ? " AND dias_atraso_entrega >= " +qtdDias + " " : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND v.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = v.id) " : " AND v.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = v.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }else if (modelo.equals("6")){
            sqlAtraso = (qtdDias > 0 ? " AND dias_atraso_entrega >= " +qtdDias + " " : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }else if (modelo.equals("7")){
            sqlAtraso = (qtdDias > 0 ? " AND dias_atraso_entrega >= " +qtdDias + " " : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlAgrupamento = tipoModelo7;
            if (tipoModelo7.equals("1")){
                sqlOrdenacao = request.getParameter("ordenacao");
            }else{
                sqlOrdenacao = "responsavel_acompanhamento_entrega_id,"+request.getParameter("ordenacao");
            }
        }else if (modelo.equals("8")){
            sqlAtraso = (qtdDias > 0 ? " AND dias_atraso_entrega >= " +qtdDias + " " : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
            condicaoPerformance = (performEntregas.equals("a") ? "" : (performEntregas.equals("p") ? " and var_horas_canhoto <=0 " : " and var_horas_canhoto > 0" ));
        }else if (modelo.equals("9")){
            sqlAtraso = (qtdDias > 0 ? " AND ( (baixa_em - previsao_entrega_em) > 0 and (baixa_em - previsao_entrega_em) >= " +qtdDias+")" : "" );
            sqlProtocolo = (request.getParameter("protocolo").equals("a") ? "" : (request.getParameter("protocolo").equals("c") ? " AND vf.id IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " : " AND vf.id NOT IN (SELECT pc5.ctrc_id FROM protocolo_ctrc pc5 WHERE pc5.ctrc_id = vf.id) " ));
            sqlOrdenacao = request.getParameter("ordenacao");
        }

        //Apenas o focal point
        String sqlFocalPoint = "";
        sqlFocalPoint = (Apoio.parseInt(request.getParameter("usuario_id")) == 0 ? "" : " and responsavel_acompanhamento_entrega_id = " + request.getParameter("usuario_id"));        
        
        java.util.Map param = new java.util.HashMap(37);
        param.put("TIPO_DATA", tipoData);
        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");//1
        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");//2
        param.put("IDCLIENTE", cliente);//3
        param.put("ORDENACAO", sqlOrdenacao);//4
        param.put("TIPO_REL", (tipoModelo3.equals("1") ? "E" : "S"));//5
        param.put("AGRUPAMENTO", sqlAgrupamento);//6
        param.put("CIDADE_DESTINO", cidadeDestino);//7
        param.put("FILIAL", filial.toString());//8
        param.put("UF", filtroUF);//9
        param.put("IS_OCORRENCIA", request.getParameter("isOcorrencia"));//10
        param.put("IS_PENDENCIA_FINANCEIRA", (Boolean.parseBoolean(request.getParameter("isPendenciaFinan")) ? " AND COALESCE((SELECT true FROM sales sl JOIN ctrcs ct ON (sl.id = ct.sale_id) JOIN parcels p ON (sl.id = p.sale_id) WHERE sl.consignatario_id = vf.idconsignatario AND NOT sl.is_cancelado AND sl.tipo <> 'b' AND ct.sale_distribuicao_id IS NULL AND NOT p.is_baixado AND getproximodiautil(p.vence_em) < current_date LIMIT 1),false) " : ""));//11
        param.put("ENTREGUES", condicaoEntregue);//12
        param.put("GRUPOS", sqlGrupo);//13
        param.put("OPCOES", "Período selecionado: " + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") + (request.getParameter("fi_abreviatura").equals("") ? "" : ". Filial: " + request.getParameter("fi_abreviatura"))
                + (request.getParameter("idconsignatario").equals("0") ? "" : ". Apenas o remetente: " + request.getParameter("con_rzs")));//14
        param.put("TIPO_TRANSPORTE", tipoTransporte);//15
        param.put("ID_MOTORISTA", idMotorista);//16
        param.put("CTRC", CTRC);//17
        param.put("MANIFESTO", manifesto);//18
        param.put("OCORRENCIA", ocorrencia);//19
        param.put("IS_RESOLVIDO", isResolvido);//20
        param.put("TIPO_CONHECIMENTO", tipoConhecimento);//21
        param.put("TIPO_FPAG", tipoFpag.equals("") ? "" : " AND tipo_fpag = '" + tipoFpag + "' ");//22
        param.put("IDREMETENTE", remetente);//23
        param.put("IDDESTINATARIO", destinatario);
        param.put("REPRESENTANTE", representante);//24
        param.put("PENDENCIA_FATURAMENTO", pendenciaFaturamento);//25
        param.put("QTD_DIAS_ATRASO", sqlAtraso);//26
        param.put("FOCAL_POINT", sqlFocalPoint);//27
        param.put("PROTOCOLO", sqlProtocolo);//28
        param.put("AREA_DESTINO", request.getParameter("area_id"));//29
        switch(modelo){
            case "2":
            case "3":
            case "4":
            case "6":
            case "7":
            case "8":
            case "9":
                param.put("CONDICAO_DESTINATARIO", destinatario);
                break;
        }

        if (modelo.equals("1")) {
            if (tipoModelo3.equals("1")) {
                param.put("AGRUPAMENTO", "abreviatura");//30
            } else if (tipoModelo3.equals("2")) {
                param.put("AGRUPAMENTO", "area_destinatario");//31
            }
        } else if (modelo.equals("5")) {
            if (tipoModelo3.equals("1")) {
                param.put("AGRUPAMENTO", "remetente");//32
            } else if (tipoModelo3.equals("2")) {
                param.put("AGRUPAMENTO", "destinatario");//33
            } else if (tipoModelo3.equals("3")) {
                param.put("AGRUPAMENTO", "consignatario");//34
            }
        }
        
        //INICIO Nova forma de parametrização dos relatórios
        param.put("IS_CONSIDERAR_PE_COMO_DP",Apoio.parseBoolean(request.getParameter("chk_pe_dp")));//35

        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));//36
        param.put("ID_DESTINATARIO", idDestinatario);//37
        param.put("ANO_MANIFESTO", anoManifesto);//38
        param.put("SERIE", serie);
        param.put("PERFORMANCE", condicaoPerformance);
        //FIM Nova forma de parametrização dos relatórios
        request.setAttribute("map", param);
        request.setAttribute("rel", "analiseentregamod" + modelo);


        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispacher.forward(request, response);
        
        }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_ANALISE_ENTREGA_RELATORIO.ordinal());
    }
%>

<script language="javascript" type="text/javascript">
    var homePath = '${homePath}';

    function abrirLocalizarCliente(input) {
        jQuery('#localizarCliente').attr('input', input);
        controlador.acao('abrirLocalizar', 'localizarCliente');
    }

    function voltar(){
        location.replace("./menu");
    }

    function modelos(modelo){
        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("modelo5").checked = false;
        $("modelo6").checked = false;
        $("modelo7").checked = false;
        $("modelo8").checked = false;
        $("modelo9").checked = false;

        $("modelo"+modelo).checked = true;

        $("trGrupo").style.display = "none";
        $("trFinan").style.display = "none";
        $("trTipoFpag").style.display = "none";
        $("trAtraso").style.display = "none";
        $("performEntregas").style.display = "none";

        if(modelo == '1'){
            $("trGrupo").style.display = "";
            $("trAtraso").style.display = "";
        }else if(modelo == '2'){
            $("trGrupo").style.display = "";
        }else if(modelo == '3'){
            $("trGrupo").style.display = "";
        }else if (modelo == '4'){
            $("trFinan").style.display = "";
            $("trTipoFpag").style.display = "";
            $("trGrupo").style.display = "";
            $("trAtraso").style.display = "";
        }else if(modelo == '5' || modelo == '6' || modelo == '7'){
            $("trGrupo").style.display = "";
            $("trAtraso").style.display = "";
        } else if (modelo == '9'){
            $("trFinan").style.display = "";
            $("trTipoFpag").style.display = "";
            $("trGrupo").style.display = "";
            $("trAtraso").style.display = "";
        }else  if(modelo == '8') {
            $("trGrupo").style.display = "";
            $("trAtraso").style.display = "";
            $("performEntregas").style.display = "";
        }

        alteraTipoData();
    }

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function limparRemetente(){
        $("rem_rzs").value = "";
        $("idremetente").value = "0";
       
    }

    function limparclifor(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }
    
    function mudarTipoData(tipo){
        if(tipo == 'n' || tipo == 'n2'){
            $("tipodata").value = "emissao_em";
        }else{
            $("tipodata").value = "baixa_em";
        }
    }
    
    
    function popRel(){
        var modelo;
        var grupos = getGrupos();
        var tipo_rel = '';
         
        if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value)){
            alert ("Informe o intervalo de datas corretamente.");
        }else{
            if ($("modelo1").checked){
                modelo = '1';
                if($("radmod1_1").checked){
                    tipo_rel = '1';
                }
                if($("radmod1_2").checked){
                    tipo_rel = '2';
                }
            }else if ($("modelo2").checked){
                modelo = '2';
            }else if ($("modelo3").checked){
                modelo = '3';
                if($("radmod3_1").checked){
                    tipo_rel = '1';
                }
                if($("radmod3_2").checked){
                    tipo_rel = '2';
                }
            }else if ($("modelo4").checked){
                modelo = '4';
            }else if ($("modelo5").checked){
                modelo = '5';
                if($("radmod5_1").checked){
                    tipo_rel = '1';
                }
                if($("radmod5_2").checked){
                    tipo_rel = '2';
                }
                if($("radmod5_3").checked){
                    tipo_rel = '3';
                }
            }else if($("modelo6").checked){
                modelo= '6';
            }else if($("modelo7").checked){
                modelo= '7';
                if($("radmod7_1").checked){
                    tipo_rel = '1';
                }
                if($("radmod7_2").checked){
                    tipo_rel = '2';
                }
            }else if($("modelo8").checked){
                modelo= '8';
            }else if($("modelo9").checked){
                modelo= '9';
            }

            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";


            let url = ('./relanaliseentrega.jsp?acao=exportar&modelo='+modelo+
                '&impressao='+impressao+'&idconsignatario='+$("idconsignatario").value+
                '&idfilial='+$("idfilialemissao").value+
                '&idfilialentrega='+$("idfilialentrega").value+
                '&tipodata='+$("tipodata").value+
                '&dtinicial='+$("dtinicial").value+'&dtfinal='+$("dtfinal").value+
                '&entregues='+$('cbEntregues').value+
                '&protocolo='+$('cbProtocolo').value+
                '&apenasUF='+$('apenasUF').value+
                '&uf='+$('uf').value+
                '&tipoTransporte=' + $("tipoTransporte").value +
                '&idCidadeDestino='+$('idcidadedestino').value+
                '&ordenacao='+$('ordenacao').value+
                '&isPendenciaFinan='+$('isPendenciaFinan').checked+
                '&isPendenciaFaturamento='+$('isPendenciaFaturamento').checked+
                '&tipo_rel='+tipo_rel+
                '&excetoGrupo='+$("excetoGrupo").value+'&grupos='+grupos
                +'&fi_abreviatura='+$("fi_abreviatura").value
                +"&chk_pe_dp="+$("chk_pe_dp").checked
                +"&isOcorrencia="+$("isOcorrencia").checked
                +"&idMotorista="+ $("idmotorista").value
                +"&tipoFpag="+ $("tipoFpag").value
                +"&numCtrc="+ $("numCtrc").value
                +"&numeroManifesto=" + $("numeroManifesto").value
                +"&anoManifesto=" + $("anoManifesto").value
                +"&ocorrenciaId=" + $("ocorrencia_id").value
                +"&isResolvido="  + $("isResolvido").checked
                +'&excetoCliente='+$("excetoCliente").value
                +'&excetoRemetente='+$("excetoRemetente").value
                +'&excetoDestinatario='+$("excetoDestinatario").value
            // Mostrar CTs
                +"&ctNormal=" + $("ct_normal").checked
                +"&ctLocal=" + $("ct_local").checked
                +"&ctDiaria=" + $("ct_diaria").checked
                +"&ctPaletizacao=" + $("ct_paletizacao").checked
                +"&ctComplementar=" + $("ct_complementar").checked
                +"&ctReentrega=" + $("ct_reentrega").checked
                +"&ctDevolucao=" + $("ct_devolucao").checked
                +"&ctCortesia=" + $("ct_cortesia").checked
                +"&ctAnulacao=" + $("ct_anulacao").checked
                +"&ctSubstituicao=" + $("ct_substituicao").checked
                +"&idremetente="+$("idremetente").value
                +"&qtdDAtraso="+$("qtdDAtraso").value
                +"&usuario_nome="+$("usuario_nome").value
                +"&usuario_id="+$("usuario_id").value
                +"&idredespachante="+ $("idredespachante").value
                +"&area_id="+ $("area_id").value
                +"&iddestinatario=" + $("iddestinatario").value
                +"&excetoSerie="+$("excetoSerie").value
                +"&serie="+$("serie").value
                +"&performance="+$("performEntregas").value
                );

                window.open('blank','pop_rel', 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1');
                $("form_con_rzs").value = $("con_rzs").value;
                $("form_rem_rzs").value = $("rem_rzs").value;
                $("form_dest_rzs").value = $("dest_rzs").value;
                $("gamb").action = url;
                $("gamb").submit();

        }
    }

    function aoClicarNoLocaliza(idjanela){
        if (idjanela == "Grupo"){
            addGrupo($('grupo_id').value,'node_grupos', getObj('grupo').value)
        }else if (idjanela == "Filial_Emissao"){
            $('idfilialemissao').value = getObj('idfilial').value;
            $('filial_emissora').value = getObj('fi_abreviatura').value;
            if (<%=!tipoFilialConfig.equals("p")%>) {
                alteraCondicaoFilial();
            }
        }else if (idjanela == "Filial_Entrega"){
            $('idfilialentrega').value = getObj('idfilial').value;
            $('filial_entrega').value = getObj('fi_abreviatura').value;
        }
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=12','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function alteraTipoData(){
        if (!$('modelo5').checked && $('tipodata').value == 'romaneio'){
            alert('Data de romaneio só poderá ser utilizada no modelo 5!');
            $('tipodata').value = 'emissao_em';
        }
    }
    function localizamotorista(){
        post_cad = window.open('./localiza?acao=consultar&idlista=10','Motorista',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    function localizarDestinatario(){
        launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');
    }
    function limparDestinatario(){
        $("dest_rzs").value = "";
        $("iddestinatario").value = "0";
    }
    
    function alteraCondicaoFilial(){
        if (<%=tipoFilialConfig.equals("p")%>) {
                if (<%=nivelUserToFilial == 0%>) {
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
            if (<%=nivelUserToFilial > 0%> || ($("idFilialUsuario").value == $("idfilialemissao").value)) {
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
    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
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

        <title>Webtrans - Relatórios de análises de entregas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);alteraCondicaoFilial();">
        <div align="center"><img src="img/banner.gif" alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="0">
            <input type="hidden" name="fi_abreviatura" id="fi_abreviatura" value="0">
            <input type="hidden" name="idfilialemissao" id="idfilialemissao" value="">
            <input type="hidden" name="idfilialentrega" id="idfilialentrega" value="">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idFilialUsuario" id="idFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="descFilialUsuario" id="descFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getAbreviatura())%>">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relatórios de análises de entregas</b></td>
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
                <td width="25%" class="TextoCampos"> <div align="left">
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="50%" class="CelulaZebra2"> Relat&oacute;rio de entregas agrupadas por:</td>
                <td width="25%" class="CelulaZebra2">
                    <input type="radio" name="radmod1" id="radmod1_1" value="1" checked>Filial
                    <br>
                    <input type="radio" name="radmod1" id="radmod1_2" value="2" >Área Destino
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td colspan="2" class="CelulaZebra2"> Relação dos CT-e(s) entregues </td>
            </tr>
            <tr>

                <td class="TextoCampos"> <div align="left">
                        <input name="modelo3" id="modelo3" type="radio" value="2" onClick="javascript:modelos(3);">
                        Modelo 3<br>
                        <input name="isOcorrencia" type="checkbox"  id="isOcorrencia" class="inputReadOnly" >Mostrar Ocorrência(s)
                    </div></td>
                <td class="CelulaZebra2" >
                    CT-e(s) com Tempo de Permanência na Filial<br>
                </td>

                <td class="CelulaZebra2" width="15%" >
                    <input type="radio" name="radmod3" id="radmod3_1" value="1" checked>De Origem
                    <br>
                    <input type="radio" name="radmod3" id="radmod3_2" value="2" >De Destino
                </td>

            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4</div></td>
                <td colspan="2" class="CelulaZebra2"> Relat&oacute;rio de Acompanhamento de Entregas </td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5</div></td>
                <td class="CelulaZebra2"> Relat&oacute;rio de Acompanhamento de Entregas Agrupado por:</td>
                <td class="CelulaZebra2">
                    <input type="radio" name="radmod5" id="radmod5_1" value="1" checked>Remetente
                    <br>
                    <input type="radio" name="radmod5" id="radmod5_2" value="2" >Destinatário
                    <br>
                    <input type="radio" name="radmod5" id="radmod5_3" value="3" >Consignatário
                </td>
            </tr>

            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo6" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                        Modelo 6</div></td>
                <td colspan="2" class="CelulaZebra2"> Relat&oacute;rio dos dados de entrega </td>
            </tr>

            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo7" id="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                        Modelo 7</div></td>
                <td class="CelulaZebra2"> 
                    Relat&oacute;rio de entregas com os dados do AWB<BR>
                    <input name="chk_pe_dp" type="checkbox" id="chk_pe_dp">Considerar Status PE como DP
                </td>
                <td class="CelulaZebra2">
                    <input type="radio" name="radmod7" id="radmod7_1" value="1" checked>Sem agrupamento
                    <br>
                    <input type="radio" name="radmod7" id="radmod7_2" value="2" >Agrupado por Focal Point
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo8" id="modelo8" type="radio" value="8" onClick="javascript:modelos(8);">
                        Modelo 8</div></td>
                <td colspan="2" class="CelulaZebra2"> Relat&oacute;rio de performance de baixa do canhoto por representante.</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input name="modelo9" id="modelo9" type="radio" value="9" onClick="javascript:modelos(9);">
                        Modelo 9</div></td>
                <td colspan="2" class="CelulaZebra2"> Relat&oacute;rio de acompanhamento de entregas com prazo de transferência e entrega</td>
            </tr>

            <tr class="tabela"> 
                <td colspan="4"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr>
                <td class="TextoCampos">Por data de:</td>
                <td colspan="3" class="CelulaZebra2">
                    <select id="tipodata" name="tipodata" class="inputtexto" onchange="alteraTipoData()">
                        <option value="baixa_em" selected>Entrega</option>
                        <option value="emissao_em" >Emissão</option>
                        <option value="romaneio" >Romaneio</option>
                        <option value="previsao_entrega_em">Previs&atilde;o de entrega</option>
                    </select>
                    entre<strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="4" > <div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td colspan="7">
                    <table width="100%" border="0" >
                        <tr>
                            <td width="20%" class="TextoCampos" rowSpan="2"><label id="lbMotrarCT" name="lbMotrarCT">Mostrar CT-e(s):</label></td>
                            <td width="80%" class="CelulaZebra2">
                                <input name="ct_normal" type="checkbox" id="ct_normal" checked >Normais
                                <input name="ct_local" type="checkbox" id="ct_local" checked >Distrib. locais
                                <input name="ct_diaria" type="checkbox" id="ct_diaria"  >Diárias
                                <input name="ct_paletizacao" type="checkbox" id="ct_paletizacao" checked >Pallets
                                <input name="ct_complementar" type="checkbox" id="ct_complementar"  >Complementares
                                <input name="ct_reentrega" type="checkbox" id="ct_reentrega" >Reentregas
                                <input name="ct_devolucao" type="checkbox" id="ct_devolucao" >Devoluções
                                <br>
                                <input name="ct_cortesia" type="checkbox" id="ct_cortesia" >Cortesias
                                <input name="ct_substituicao" type="checkbox" id="ct_substituicao" >Substituição
                                <input name="ct_anulacao" type="checkbox" id="ct_anulacao" >Anulação
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="4"> <table width="100%" class="bordaFina" >
                        <tr>
                            <td width="40%" class="TextoCampos" colspan="2"><div align="right">Apenas o representante:</div></td>
                            <td width="60%" class="TextoCampos">
                            <div align="left">
                                    <strong>
                                        <input type="hidden" id="idredespachante" value="0" name="idredespachante"/>
                                        <input name="redspt_rzs" type="text" id="redspt_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                           onClick="launchPopupLocate('./localiza?acao=consultar&idlista=23', 'Vendedor')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                         onClick="javascript:getObj('idredespachante').value = '0';javascript:getObj('redspt_rzs').value = '';"> 
                                     </strong>
                            </div>
                        </td>                      
                        </tr>
                        <tr>
                            <td height="24"  class="TextoCampos" colspan="2">
                                <div align="right">
                                    <select name="excetoRemetente" id="excetoRemetente" class="inputtexto">
                                        <option value="In" selected>Apenas o remetente:</option>
                                        <option value="NotIn">Exceto o remetente:</option>
                                    </select>
                                </div>
                            </td>
                        <td  class="TextoCampos">
                                <div align="left">
                                        <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="idremetente" type="hidden" id="idremetente" value ="0">
                                        <input name="localiza_remetente" type="button" class="botoes" id="localiza_remetente" value="..." onClick="abrirLocalizarCliente('rem_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar remetente" onClick="removerValorInput('rem_rzs');">
                                </div>
                        </td>
                        
                        
                        </tr>
                        <tr>
                            <td class="TextoCampos" colspan="2">
                                <div align="right">
                                    <select name="excetoDestinatario" id="excetoDestinatario" class="inputtexto">
                                        <option value="In" selected>Apenas o Destinatário</option>
                                        <option value="NotIn">Exceto o Destinatário</option>
                                    </select>
                                </div>
                            </td>
                            <td class="CelulaZebra2">
                                <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true"/>
                                <input id="iddestinatario" type="hidden" name="iddestinatario" value="0"/>
                                <input class="botoes" type="button" value="..." onclick="abrirLocalizarCliente('dest_rzs');"/>
                                <img id="" src="img/borracha.gif" class="imagemLink" onclick="removerValorInput('dest_rzs');" title="Limpar Destinatário"/>
                            </td>
                        </tr>
                        <tr>
                              <td height="24"  class="TextoCampos" colspan="2">
                                  <div align="right">
                                      <select name="excetoCliente" id="excetoCliente" class="inputtexto">
                                          <option value="In" selected>Apenas o cliente:</option>
                                          <option value="NotIn">Exceto o cliente:</option>
                                      </select>
                                  </div>
                              </td>
                            <td  class="TextoCampos">
                                <div align="left">
                                        <input name="con_rzs" type="text" id="con_rzs" class="" value="" size="15" maxlength="10" readonly="">
                                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor" value="..." onClick="abrirLocalizarCliente('con_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="removerValorInput('con_rzs');">
                                </div>
                            </td>
                        </tr>

                        <tr>
                            <td height="24"  class="TextoCampos" colspan="2"><div align="right">Apenas o Focal Point (Responsável pelo Acompanhamento):</div></td>
                            <td  class="CelulaZebra2">
                                <input name="usuario_nome" type="text" id="usuario_nome" size="35" readonly class="inputReadOnly" value="">
                                <input name="localiza_usuario" type="button" class="botoes" id="localiza_usuario" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=84', 'Usuario')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="$('usuario_nome').value='';$('usuario_id').value = '0';">
                                <input name="usuario_id" type="hidden" id="usuario_id" value="0">
                            </td>
                        </tr>

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
                            <td height="24" class="TextoCampos" colspan="2">Apenas o destino:</td>
                            <td class="CelulaZebra2">
                                <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
                                <input name="cid_destino" type="text"  id="cid_destino" class="inputReadOnly" value="" size="25" readonly="true">
                                <input name="uf_destino" type="text" id="uf_destino" class="inputReadOnly" size="2" readonly="true">
                                <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();" >
                                <img src="img/borracha.gif" name="apaga_cid_destino" border="0" align="absbottom" class="imagemLink" id="apaga_cid_destino" title="Limpar Motorista" onClick="javascript:getObj('idcidadedestino').value = 0;javascript:getObj('cid_destino').value = '';getObj('uf_destino').value = '';" ></td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" colspan="2">Apenas o motorista:</td>
                            <td class="CelulaZebra2">
                                <input type="hidden" name="idmotorista" id="idmotorista" value="0">
                                <input name="motor_nome" type="text"  id="motor_nome" class="inputReadOnly" value="" size="25" readonly="true">
                                <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:localizamotorista();">
                                <img src="img/borracha.gif" name="apaga_motorista" border="0" align="absbottom" class="imagemLink" id="apaga_cid_destino" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';" ></td>
                        </tr>                        
                        <tr name="trAtraso" id="trAtraso">
                            <td height="24" class="TextoCampos" colspan="2">Mostrar CT-e(s) com atraso igual ou superior a:</td>
                            <td class="CelulaZebra2"> 
                                <input type="text" class="inputTexto" id="qtdDAtraso" name="qtdDAtraso" value="0" size="6" onchange="javascript:seNaoIntReset(this,'0')">
                                dia(s)
                            </td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" colspan="2">Apenas o CT-e:</td>
                            <td class="CelulaZebra2">
                                <input type="text" class="inputTexto" id="numCtrc" name="numCtrc" value="" size="6" >
                        </tr>
                        <tr>
                            <td height="24"  class="TextoCampos" colspan="2">
                                <div align="right">
                                    <select name="excetoSerie" id="excetoSerie" class="inputtexto">
                                        <option value="In" selected>Apenas as séries:</option>
                                        <option value="NotIn">Exceto os séries:</option>
                                    </select>
                                </div>
                            </td>
                            <td class="CelulaZebra2">
                                <input type="text" name="serie" id="serie" value="" class="inputTexto" size="15" maxlength="80">
                            </td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" colspan="2">Apenas o manifesto:</td>
                            <td class="CelulaZebra2">
                                <input name="numeroManifesto" type="text"  id="numeroManifesto" class="inputTexto" value="" size="6" >
                                Ano:
                                <input name="anoManifesto" type="text"  id="anoManifesto" class="inputTexto" value="" size="6" >
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" colspan="2">Mostrar:</td>
                            <td class="CelulaZebra2"><label>
                                    <select name="cbEntregues" id="cbEntregues" class="inputtexto" onchange="mudarTipoData(this.value)">
                                        <option value="a" selected>Ambos</option>
                                        <option value="e">CT-e(s) Entregues</option>
                                        <option value="esc">CT-e(s) Entregues (Sem Comprovante)</option>
                                        <option value="n">CT-e(s) N&atilde;o entregues</option>
                                        <option value="n2">CT-e(s) N&atilde;o entregues (Sem Romaneio)</option>
                                        <option value="at">CT-e(s) Em aberto com entrega atrasada</option>
                                    </select>
                                    <select name="cbProtocolo" id="cbProtocolo" class="inputtexto">
                                        <option value="a" selected>Ambos</option>
                                        <option value="c">Com Protocolo</option>
                                        <option value="s">Sem Protocolo</option>
                                    </select>
                                    <select style="display: none" name="performEntregas" id="performEntregas" class="inputtexto">
                                        <option value="a" selected>Ambas</option>
                                        <option value="p">Positiva</option>
                                        <option value="n">Negativa</option>
                                    </select>
                                </label>
                            </td>
                        </tr>
                        <tr id="trTipoTrans">
                            <td class="TextoCampos" colspan="2">Tipo de Transporte:</td>
                            <td  class="CelulaZebra2"><div align="left">
                                    <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:'160px';"   class="fieldMin">
                                        <%= emiteRodoviario && emiteAereo && emiteAquaviario ? "<option value='false' >Todos</option>" : ""%>
                                        <%= emiteRodoviario ? "<option value='r' >CTR - Transp. Rodoviário</option>" : ""%>
                                        <%= emiteAereo ? "<option value='a' >CTA - Transp. A&eacute;reo</option>" : ""%>
                                        <%= emiteAquaviario ? "<option value='q' >CTQ - Transp. Aquavi&aacute;rio</option>" : ""%>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr id="trTipoFpag" style="display:none;">
                            <td class="TextoCampos" colspan="2">Apenas a forma de pagto:</td>
                            <td  class="CelulaZebra2"><div align="left">
                                    <select name="tipoFpag" id="tipoFpag" style="font-size:8pt;width:'160px';"   class="fieldMin">
                                        <option value="">Ambas</option>
                                        <option value="v">À vista</option>
                                        <option value="p">À prazo</option>
                                        <option value="c">Conta Corrente</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" colspan="2"><div align="right">Apenas a ocorr&ecirc;ncia:</div></td>
                            <td class="TextoCampos">
                                <div align="left">
                                    <strong>
                                        <input name="ocorrencia_id" type="hidden" id="ocorrencia_id" value="0">
                                        <input name="descricao_ocorrencia" type="text" id="descricao_ocorrencia" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <input name="" type="button" class="botoes" id="" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=40','Ocorrencia','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ocorrencia" onClick="javascript:$('ocorrencia_id').value = 0; $('descricao_ocorrencia').value = '';">                                    </strong>                                </div>                            </td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" colspan="2"><div align="right">Apenas Area de Destino:</div></td>
                            <td class="TextoCampos">
                                <div align="left">
                                    <strong>
                                        <input name="area_id" type="hidden" id="area_id" value="0">
                                        <input name="area" type="text" id="area" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <input name="" type="button" class="botoes" id="" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=34','Area_Destino','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Area de Destino" onClick="javascript:$('area_id').value = 0; $('area').value = '';">                                    </strong>                                </div>                            </td>
                        </tr>
                        <tr>
                            <td colspan="3" class="TextoCampos">
                                <div align="center">
                                    <input name="isResolvido" type="checkbox"  id="isResolvido" class="inputReadOnly" >Mostrar apenas CT-e(s) com ocorr&ecirc;ncias n&atilde;o resolvidas
                                </div>
                            </td>
                            <td class="TextoCampos"></td>
                        </tr>
                        <tr id="trFinan" style="display:none">
                            <td colspan="3" class="TextoCampos">
                                <div align="center">
                                    <input name="isPendenciaFinan" type="checkbox"  id="isPendenciaFinan" class="inputReadOnly" >Mostrar apenas clientes com pendências financeiras.
                                </div>
                            </td>
                            <td class="TextoCampos"></td>
                        </tr>
                        <tr>
                            <td colspan="3" class="TextoCampos">
                                <div align="center">
                                    <input name="isPendenciaFaturamento" type="checkbox"  id="isPendenciaFaturamento" class="inputReadOnly" >Mostrar CT-e(s) com pendências de faturamento.
                                </div>
                            </td>
                            <td class="TextoCampos"></td>
                        </tr>
                        <tr id="trUFs">
                            <td class="TextoCampos" colspan="2">
                                <select name="apenasUF" id="apenasUF" class="inputtexto">
                                    <option value="IN" selected>Apenas as UFs destino</option>
                                    <option value="NOT IN">Exceto as UFs destino</option>
                                </select>                            
                            </td>
                            <td class="CelulaZebra2">
                                <input name="uf" type="text" id="uf" size="20" maxlength="60" onChange="javascript:$('uf').value = $('uf').value.toUpperCase();" class="inputtexto">
                                <label id="descUF" name="descUF" >Separe as UFs com v&iacute;rgulas </label>                            
                            </td>
                        </tr>
                        <tr id="trGrupo" style="">
                            <td colspan="3">
                                <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                                    <tr class="cellNotes">
                                        <td width="16%" class="CelulaZebra2"><div align="center"><img src="img/add.gif" border="0"
                                                                                                      title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">          </div></td>
                                        <td width="84%" class="CelulaZebra2" ><div align="center">
                                                <select name="excetoGrupo" id="excetoGrupo" class="inputtexto">
                                                    <option value="IN" selected>Apenas os grupos</option>
                                                    <option value="NOT IN">Exceto os grupos</option>
                                                </select>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="4"><div align="center">Ordena&ccedil;&atilde;o</div></td>
            </tr>
            <tr>
                <td colspan="4" class="TextoCampos"><div align="center">
                        <select name="ordenacao" id="ordenacao" class="inputtexto">
                            <option value="emissao_em" selected>Data de Emiss&atilde;o</option>
                            <option value="baixa_em">Data de Entrega</option>
                            <option value="numero">N&uacute;mero do CT-e</option>
                        </select>
                    </div>
                </td>
            </tr>
        </tr>


        <tr>
            <td colspan="4" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
        </tr>
        <tr>
            <td colspan="4" class="TextoCampos"><div align="center">
                    <input type="radio" name="impressao" id="pdf" value="1" checked/>
                    <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                    <input type="radio" name="impressao" id="excel" value="2" />
                    <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                    <input type="radio" name="impressao" id="word" value="3" />
                    <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                </div></td>
        </tr>
        <tr>
            <td colspan="4" class="TextoCampos"> <div align="center">
                    <% if (temacesso) {%>
                    <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
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
    <form id="gamb" target="pop_rel" method="post" >
        <input type="hidden" id="form_con_rzs" name="con_rzs"/>
        <input type="hidden" id="form_rem_rzs" name="rem_rzs"/>
        <input type="hidden" id="form_dest_rzs" name="dest_rzs"/>
    </form>
</body>
</html>

<script>

    class filtro {
        constructor(tipoLocalizar) {
            this.tipoLocalizar = tipoLocalizar;
        }

        getTipo() {
            return this.tipoLocalizar;
        }

        setTipo(tipoLocalizar) {
            this.tipoLocalizar = tipoLocalizar;
        }

    }

    var tipo = new filtro('veiculo');

    jQuery(document).ready(function() {
        jQuery('#rem_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#con_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#dest_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
    });

</script>