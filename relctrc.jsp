<%@page import="java.util.stream.Collectors"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="veiculo.BeanCadVeiculo"%>
<%@page import="tipo_veiculos.ConsultaTipo_veiculos"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date, 
         java.sql.ResultSet,
         venda.BeanConsultaAgencia,
         nucleo.Apoio" errorPage="" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/produto-util.js" type=""></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script type="text/javascript" src="${homePath}/assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relctrc") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
//fim da MSA
    }
    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
    boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
    boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
    boolean carregaveiculo = false;
    BeanCadVeiculo cadveiculo = null;
    int nivelUserToFilial = Apoio.getUsuario(request).getAcesso("reloutrasfiliais");
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    String tipoFilialConfig = cfg.getMatrizFilialFranquia();
//exportacao da Cartafrete para arquivo .pdf
String modelo = "";
    if (acao.equals("exportar")) {
            
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String extra = "";
        modelo = request.getParameter("modelo");
        String ordenacao = request.getParameter("ordenacao");
        String tc = "";
        String cancelado = request.getParameter("ct_cancelados");;
        String naoCancelado = request.getParameter("ct_nao_cancelados");
        String canceladoModelo = "";
        String opcoes = "";
        String tipoTransporte = request.getParameter("tipoTransporte");
        String tpTrans = "";
        String tipoFrete = "";
        StringBuilder filial = new StringBuilder();
        boolean chkNfseNormal = Apoio.parseBoolean(request.getParameter("chkNfseNormal"));
        
        boolean is_status_confirmado = Apoio.parseBoolean(request.getParameter("ct_confirmados"));
        boolean is_status_pendente = Apoio.parseBoolean(request.getParameter("ct_pendentes"));
        boolean is_status_enviado = Apoio.parseBoolean(request.getParameter("ct_enviados"));
        boolean is_status_negado = Apoio.parseBoolean(request.getParameter("ct_negados"));
        
        //Apenas os CTs Normais
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_normal")) ? ", Apenas os CTs: Normais" : "");
        tc = (Boolean.parseBoolean(request.getParameter("ct_normal")) ? "'n'" : "");
        //Apenas os CTs Locais
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_local")) ? (tc.equals("") ? ", Apenas os CTs: Distribuições Locais" : "-Distribuições Locais") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_local")) ? (tc.equals("") ? "'l'" : ",'l'") : "");
        //Apenas os CTs Diarias
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_diaria")) ? (tc.equals("") ? ", Apenas os CTs: Diárias" : "-Diárias") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_diaria")) ? (tc.equals("") ? "'i'" : ",'i'") : "");
        //Apenas os CTs Paletização
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_paletizacao")) ? (tc.equals("") ? ", Apenas os CTs: Pallets" : "-Pallets") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_paletizacao")) ? (tc.equals("") ? "'p'" : ",'p'") : "");
        //Apenas os CTs Complementares
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_complementar")) ? (tc.equals("") ? ", Apenas os CTs: Complementares" : "-Complementares") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_complementar")) ? (tc.equals("") ? "'c'" : ",'c'") : "");
        //Apenas os CTs Reentrega
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_reentrega")) ? (tc.equals("") ? ", Apenas os CTs: Reentregas" : "-Reentregas") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_reentrega")) ? (tc.equals("") ? "'r'" : ",'r'") : "");
        //Apenas os CTs Devolução
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_devolucao")) ? (tc.equals("") ? ", Apenas os CTs: Devoluções" : "-Devoluções") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_devolucao")) ? (tc.equals("") ? "'d'" : ",'d'") : "");
        //Apenas os CTs Cortesia
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_cortesia")) ? (tc.equals("") ? ", Apenas os CTs: Costesias" : "-Cortesias") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_cortesia")) ? (tc.equals("") ? "'b'" : ",'b'") : "");
        //Apenas os CTs Substitutos
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_substituicao")) ? (tc.equals("") ? ", Apenas os CTs: Substituições" : "-Substituições") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_substituicao")) ? (tc.equals("") ? "'s'" : ",'s'") : "");
        //Apenas os CTs Substituidos
        opcoes += (Boolean.parseBoolean(request.getParameter("ct_substituido")) ? (tc.equals("") ? ", Apenas os CTs: Substituidos" : "-Substituidos") : "");
        tc += (Boolean.parseBoolean(request.getParameter("ct_substituido")) ? (tc.equals("") ? "'t'" : ",'t'") : "");
        
        canceladoModelo = (cancelado.equals("") ? "":" AND cancelado=" + cancelado);

        String veiculos = request.getParameter("vei_placa");

        List<String> placas = new ArrayList<>();
        List<String> veiculoIds = new ArrayList<>();

        if (StringUtils.isNotBlank(veiculos)) {
            String[] splitVeiculos = veiculos.split("!@!");

            for (String splitVeiculo : splitVeiculos) {
                String[] splitPlacaId = splitVeiculo.split("#@#");

                if (splitPlacaId.length >= 2) {
                    placas.add(splitPlacaId[0]);
                    veiculoIds.add(String.valueOf(Apoio.parseInt(splitPlacaId[1])));
                }
            }

            if (placas.size() > 0) {
                opcoes += (" Apenas o(s) veículo(s): ".concat(String.join(", ", placas))).concat(". ");
            }
        }
        // Pegar os IDs do remetentes
         List<String> idsRemetente = new ArrayList<>();

        if (StringUtils.isNotBlank(request.getParameter("remet"))) {
            String[] splitRemetentes = request.getParameter("remet").split("!@!");
            for (String splitRemetente : splitRemetentes) {
                    String[] splitRemetenteId = splitRemetente.split("#@#");

                    if (splitRemetenteId.length >= 2) {
                            idsRemetente.add(String.valueOf(Apoio.parseInt(splitRemetenteId[1])));
                    }
            }
        }
        // Pegar id dos destinatários.

        List<String> idsDestinatarios = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("dest"))) {
            String[] splitDestinatarios = request.getParameter("dest").split("!@!");
            for (String splitDestinatario: splitDestinatarios) {
                String[] splitDestinatarioID = splitDestinatario.split("#@#");

                if (splitDestinatarioID.length >= 2) {
                    idsDestinatarios.add(String.valueOf(Apoio.parseInt(splitDestinatarioID[1])));
                }
            }
        }
        //Pegar id dos consignatários

        List<String> idsConsignatario = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("consig"))) {
            String[] splitConsignatarios = request.getParameter("consig").split("!@!");
            for (String splitConsignatario: splitConsignatarios) {
                String[] splitConsignatarioID = splitConsignatario.split("#@#");

                if (splitConsignatarioID.length >= 2) {
                    idsConsignatario.add(String.valueOf(Apoio.parseInt(splitConsignatarioID[1])));
                }
            }
        }

        //Pegar id dos Representantes
        List<String> idsRedespachante = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("redspt_rzs"))) {
            String[] splitRedespachantes = request.getParameter("redspt_rzs").split("!@!");
            for (String splitRedespachante: splitRedespachantes) {
                String[] splitRedespachantesID = splitRedespachante.split("#@#");

                if (splitRedespachantesID.length >=2) {
                    idsRedespachante.add(String.valueOf(Apoio.parseInt(splitRedespachantesID[1])));
                }
            }
        }
        
        
        //Pegar id dos Redespachos
        List<String> idsRedespacho = new ArrayList<>();
        if (StringUtils.isNotBlank(request.getParameter("red_rzs"))) {
            String[] splitRedespachos = request.getParameter("red_rzs").split("!@!");
            for (String splitRedespacho: splitRedespachos) {
                String[] splitRedespachosID = splitRedespacho.split("#@#");

                if (splitRedespachosID.length >=2) {
                    idsRedespacho.add(String.valueOf(Apoio.parseInt(splitRedespachosID[1])));
                }
            }
        }

        if (modelo.equals("P")){
            
            String pedidoNota = request.getParameter("pedidoNota");            
            String serieFiltro="";
            String filtroSerie=request.getParameter("serie");
           // pedidoNota = pedidoNota.replace("'", "");
            String pedidos = "";
            for (int x = 0; x <= pedidoNota.split(",").length - 1; x++) {
                pedidos += (pedidos.equals("") ? "" : ",") + "'" + pedidoNota.split(",")[x].trim() + "'";
            }
                   
            canceladoModelo = (cancelado.equals("") ? "":" AND sl.is_cancelado=" + cancelado);
            serieFiltro = (filtroSerie.equals("")?"": " AND sl.serie='" + filtroSerie+"'");
            java.util.Map param = new java.util.HashMap(30);
            //PARAMETROS
            String grupos = (request.getParameter("grupos").equals("") 
                                ? "" 
                                : " and (con.grupo_id " + request.getParameter("excetoGrupo") + "(" + request.getParameter("grupos") + ") " 
                                    + (request.getParameter("excetoGrupo").equals("NOT IN") 
                                        ? " OR con.grupo_id is null " 
                                        : "") + ")");
            param.put("GRUPOS", grupos);
            param.put("TIPODATA", request.getParameter("dtemissao"));
            param.put("DATA_INI", ("'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'"));
            param.put("DATA_FIM", ("'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'"));
            param.put("IDCONSIGNATARIO", request.getParameter("idconsig"));
            param.put("OPERADOR_CONSIGNATARIO", request.getParameter("apenasConsignatario"));
            param.put("IDREMETENTE", request.getParameter("idremetente"));
            param.put("OPERADOR_REMETENTE", request.getParameter("apenasRemetente"));
            param.put("IDDESTINATARIO", request.getParameter("iddestinatario"));
            param.put("OPERADOR_REDESPACHO", request.getParameter("apenasRedespacho"));
            param.put("OPERADOR_DESTINATARIO", request.getParameter("apenasDestinatario"));
            param.put("OPERADOR_REDESPACHANTE", request.getParameter("apenasRedespachante"));
            param.put("IDMOTORISTA", request.getParameter("idmotorista"));
            param.put("IDFILIAL", request.getParameter("idFilialFiltro"));
            param.put("OPERADOR_FILIAL", request.getParameter("apenasFilial"));
            param.put("SERIE", serieFiltro);
            param.put("TIPO_TRANSPORTE", tipoTransporte);
            param.put("IDREDESPACHANTE", request.getParameter("idredespachante"));
            param.put("IDREDESPACHO", request.getParameter("idredespacho"));
            param.put("IS_CONFIRMADO",is_status_confirmado);     
            param.put("IS_PENDENTE",is_status_pendente);     
            param.put("IS_ENVIADO",is_status_enviado);     
            param.put("IS_NEGADO",is_status_negado);
            param.put("IS_CANCELADO",Boolean.parseBoolean(cancelado));
            param.put("IS_NAO_CANCELADO",Boolean.parseBoolean(naoCancelado));
            param.put("TIPO_DO_FRETE", request.getParameter("tipoFrete"));
            param.put("PEDIDO_NOTA", pedidos);
            param.put("IDVEICULO", veiculoIds.size() > 0 ? String.join(",", veiculoIds) : "0");
            param.put("VEICULO_ID_UNICO", request.getParameter("idveiculo"));
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (sl.tipo IN (" + tc + ")) "));
            param.put("CANCELADO", canceladoModelo);
            
            request.setAttribute("map", param);
            request.setAttribute("rel", request.getParameter("personalizado"));
            
        }else{
        tipoFrete = (!request.getParameter("tipoFrete").equals("") ? "AND tipo_frete =" + request.getParameter("tipoFrete") : "");
        if ((modelo.equals("16") || modelo.equals("26") || modelo.equals("32") || modelo.equals("29") || modelo.equals("27") || modelo.equals("35") || modelo.equals("36")) && !request.getParameter("ctrc1").trim().equals("") && !request.getParameter("ctrc1").trim().equals("")) {
            opcoes = "CTRCs entre: " + request.getParameter("ctrc1") + " até " + request.getParameter("ctrc2") + ". ";
        } else {
            opcoes = "Período selecionado: " + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") + ". ";
        }
        //tipo de transporte
        if (tipoTransporte.equals("r")) {
            tpTrans = "Rodoviário";
        } else if (tipoTransporte.equals("a")) {
            tpTrans = "Aéreo";
        } else if (tipoTransporte.equals("q")) {
            tpTrans = "Aquaviário";
        }

        String cfop = "";
        if (modelo.equals("1")) {
            cfop = (request.getParameter("idcfop").equals("0") ? "" : " AND s.cfop_id = " + request.getParameter("idcfop"));
            opcoes += (request.getParameter("idcfop").equals("0") ? "" : ". Apenas o CFOP " + request.getParameter("cfop"));
        }
            
            if (request.getParameter("idfilialemissao") != null && !"0".equals(request.getParameter("idfilialemissao")) && !"".equals(request.getParameter("idfilialemissao"))) {
                if("5".contains(modelo)){
                    filial.append(" and filial_ctrc_id ").append(request.getParameter("apenasFilial")).append(request.getParameter("idfilialemissao"));
                }else if("15".equals(modelo)){
                    filial.append(" and sl.filial_id ").append(request.getParameter("apenasFilial")).append(request.getParameter("idfilialemissao"));
                }else if("31".equals(modelo)){
                    filial.append(" and s.filial_id ").append(request.getParameter("apenasFilial")).append(request.getParameter("idfilialemissao"));
                }else{
                    filial.append(" and filial ").append(request.getParameter("apenasFilial")).append(request.getParameter("idfilialemissao"));
                }
            }
            if (request.getParameter("idfilialentrega") != null && !"0".equals(request.getParameter("idfilialentrega")) && !"".equals(request.getParameter("idfilialentrega"))){
                if(!"16".contains("modelo")){
                    filial.append(" and COALESCE(id_filial_entrega,0) ").append(request.getParameter("apenasFilialEntrega")).append(request.getParameter("idfilialentrega"));
                 }
            }

        //Verificando se vai mostrar os cancelados ou não 
        //Caso os 2 checkboxes estejam marcados ou desmarcados ao mesmo tempo
        if ((Boolean.parseBoolean(cancelado) && Boolean.parseBoolean(naoCancelado)) || (!Boolean.parseBoolean(cancelado) && !Boolean.parseBoolean(naoCancelado))) {
            cancelado = "";
            opcoes += ", Mostrar Cancelados e Não Cancelados ";
        
        } else if (!Boolean.parseBoolean(cancelado) && Boolean.parseBoolean(naoCancelado)){// Somente "Não Cancelados" marcado
            cancelado = "false";
            opcoes += ", Mostrar Não Cancelados ";
        }else if  (Boolean.parseBoolean(cancelado) && !Boolean.parseBoolean(naoCancelado)){// Somente "Cancelados" marcado
            cancelado = "true";
            opcoes += ", Mostrar Cancelados ";            
        }    
            
        opcoes += (request.getParameter("serie").equals("") ? "" : "Apenas a série: " + request.getParameter("serie") + ". ");
        opcoes += (request.getParameter("idfilialemissao").equals("0") ? "" : (request.getParameter("apenasFilial").equals("=") ? "Apenas" : "Exceto") + " a filial: " + request.getParameter("filial_emissora") + ". ");
        opcoes += (request.getParameter("idfilialentrega").equals("0") ? "" : (request.getParameter("apenasFilialEntrega").equals("=") ? "Apenas" : "Exceto") + " a filial de entrega: " + request.getParameter("filial_entrega") + ". ");
        opcoes += (request.getParameter("idremetente").equals("0") ? "" : (request.getParameter("apenasRemetente").equals("=") ? "Apenas" : "Exceto") + " o remetente: " + request.getParameter("remet") + ". ");
        opcoes += (request.getParameter("iddestinatario").equals("0") ? "" : (request.getParameter("apenasDestinatario").equals("=") ? "Apenas" : "Exceto") + " o destinatário: " + request.getParameter("dest") + ". ");
        opcoes += (request.getParameter("idconsig").equals("0") ? "" : (request.getParameter("apenasConsignatario").equals("=") ? "Apenas" : "Exceto") + " o consignatário: " + request.getParameter("consig") + ". ");
        opcoes += (request.getParameter("idredespacho").equals("0") ? "" : (request.getParameter("apenasRedespacho").equals("=") ? "Apenas" : "Exceto") + " o redespacho: " + request.getParameter("red_rzs") + ". ");
        opcoes += (request.getParameter("idredespachante").equals("0") ? "" : (request.getParameter("apenasRedespachante").equals("=") ? "Apenas" : "Exceto") + " o redespacho: " + request.getParameter("redspt_rzs") + ". ");

        if (!veiculoIds.isEmpty()) {
            opcoes += (" Apenas o(s) veículo(s): ".concat(String.join(", ", placas))).concat(". ");
        }
        
        opcoes += (request.getParameter("tipoTransporte").equals("false") ? "" : "Apenas o Tipo de Transporte: " + tpTrans + ". ");
        opcoes += (request.getParameter("idmotorista").equals("0") ? "" : "Apenas o motorista: " + request.getParameter("motor_nome") + ". ");
        opcoes += (request.getParameter("numerocarga").equals("") ? "" : "Apenas o nº de carga: " + request.getParameter("numerocarga") + ". ");
        opcoes +=  request.getParameter("tipveiculo");
        
        String isAgregado = request.getParameter("is_Agregado");
        String isFrota = request.getParameter("is_FrotaP");
        String isCarreteiro = request.getParameter("is_Carreteiros");
        String tiposFrota = "";
        tiposFrota  = (isAgregado.equals("true")? "'ag'" : "");
        tiposFrota += (isFrota.equals("true")? (tiposFrota.equals("")? "'pr'" : ",'pr'"):"");
        tiposFrota += (isCarreteiro.equals("true")? (tiposFrota.equals("")? "'ca'" : ",'ca'"):"");
        
        if(!tiposFrota.equals("")){
             opcoes += "Apenas veículos: ";
             if (isAgregado.equals("true")) {    
                 opcoes += "Agregados, ";
             }
             if (isFrota.equals("true")) {
                opcoes += "Frota Própria, ";
             }
             if(isCarreteiro.equals("true")){
                opcoes += "Carreteiros. ";
             }
            if(isCarreteiro.equals("false") && 
               isFrota.equals("false") &&
               isAgregado.equals("false")){
                opcoes += " ";
            }
        }
        
        

        //Apenas modelo 5 ou 15
        if (modelo.equals("5") || modelo.equals("15") || modelo.equals("31")) {
            if (request.getParameter("ordenacao").equals("dtemissao")) {
                ordenacao = "emissao_em";
            } else {
                ordenacao = "numero";
            }
            //Parametro Extra para o modelo 5
            if (!request.getParameter("finalizado").equals("both")) {
                if (Boolean.parseBoolean(request.getParameter("finalizado"))) {
                    extra = " and baixa_em is not null"; //Apenas CTRCs Entregues, ou seja data da baixa diferente de null
                } else {
                    extra = " and baixa_em is null"; //Apenas CTRCs Não Entregues, ou seja data da baixa = null
                }
            }
            if (modelo.equals("15")) {
                canceladoModelo = (cancelado.equals("") ? "" : " AND is_cancelado=" + cancelado);
            }
        } else if (modelo.equals("7") && request.getParameter("ordenacao").equals("nfiscal")) {
            //apenas modelo 7
            ordenacao = "ctrc";
            //Parametro Extra para o modelo 7
        }

        if (modelo.equals("4")) {
            extra = "";
            if (!request.getParameter("finalizado").equals("both")) {
                if (Boolean.parseBoolean(request.getParameter("finalizado"))) {
                    extra = " and dtfechamento is not null"; //Apenas CTRCs Entregues, ou seja data da baixa diferente de null
                } else {
                    extra = " and dtfechamento is null"; //Apenas CTRCs Não Entregues, ou seja data da baixa = null
                }
            }
        } else if (modelo.equals("7")) {
            if (!request.getParameter("finalizado").equals("both")) {
                if (Boolean.parseBoolean(request.getParameter("finalizado"))) {
                    extra = " and baixa_em is not null"; //Apenas CTRCs Entregues, ou seja data da baixa diferente de null
                } else {
                    extra = " and baixa_em is null"; //Apenas CTRCs Não Entregues, ou seja data da baixa = null
                }
            }
        }


        java.util.Map param = new java.util.HashMap(56);

        if (modelo.equals("15")) {
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (sl.tipo IN (" + tc + ")) "));
        } else if (modelo.equals("1")) {
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (s.tipo_conhecimento IN (" + tc + ")) "));
        } else if (modelo.equals("16")) {
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (nf.tipo IN (" + tc + ")) "));            
        } else if (modelo.equals("2")){
            //coloquei de uma forma que libere a ASA DE PRATA
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (tipo_conhecimento IN (" + tc + ")) ")); //+ (cancelado.equals("") ? " or not cancelado " : (cancelado.equals("true") ? " or cancelado " : " and not cancelado ") )+ ")"));
        } else {
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (tipo_conhecimento IN (" + tc + ")) "));
        }
        //modelo 10 nessecita que mande outro cancelado
        param.put("TIPO_CONHECIMENTO_2", (tc.equals("") ? "" : ""));
        if (modelo.equals("10")) {
            param.put("IDFILIAL2", (request.getParameter("idfilialemissao") != null && !"0".equals(request.getParameter("idfilialemissao")) && !"".equals(request.getParameter("idfilialemissao")) ? " and s.filial_id" + request.getParameter("apenasFilial") + request.getParameter("idfilialemissao") : ""));
            StringBuilder filial2 = new StringBuilder();
            if (request.getParameter("idfilialemissao") != null && !"0".equals(request.getParameter("idfilialemissao")) && !"".equals(request.getParameter("idfilialemissao"))) {
                    filial2.append(" and s.filial_id ").append(request.getParameter("apenasFilial")).append(request.getParameter("idfilialemissao"));
            }
            if (request.getParameter("idfilialentrega") != null && !"0".equals(request.getParameter("idfilialentrega")) && !"".equals(request.getParameter("idfilialentrega"))){
                filial2.append(" and COALESCE(fca.id_filial_entrega,0) ").append(request.getParameter("apenasFilialEntrega")).append(request.getParameter("idfilialentrega"));
            }
            param.put("IDFILIAL3", filial2.toString());
        } else if (modelo.equals("7")) {
            param.put("TIPO_CONHECIMENTO", (tc.equals("") ? "" : " and (tipo_conhecimento IN (" + tc + ")) "));
            param.put("MODALIDADE", (request.getParameter("apenasModalidade").equals("a") ? "" : " and tipo_fpag='" + request.getParameter("apenasModalidade") + "'"));
            param.put("IDCIDADEDESTINO", (!request.getParameter("idcidadedestino").equals("0") ? " and idcidadedestino=" + request.getParameter("idcidadedestino") : ""));
            String ufs = "";
            for (int x = 0; x <= request.getParameter("uf").split(",").length - 1; x++) {
                ufs += (ufs.equals("") ? "" : ",") + "'" + request.getParameter("uf").split(",")[x] + "'";
            }
            param.put("UF", (request.getParameter("uf").equals("") ? "" : " and uf_destino " + request.getParameter("apenasUF") + "(" + ufs + ")"));
        
        } else //Jonas
        if (modelo.equals("2")) {
            param.put("DESCONTO", Double.parseDouble(request.getParameter("descontoIcms")));
                        //jonas
        } else if (modelo.equals("17")) {
            param.put("AGRUPADO_CARRETA", Boolean.parseBoolean(request.getParameter("agrupadoCarreta")));
        } else if (modelo.equals("21")) {
            String ufs = "";
            for (int x = 0; x <= request.getParameter("uf").split(",").length - 1; x++) {
                ufs += (ufs.equals("") ? "" : ",") + "'" + request.getParameter("uf").split(",")[x] + "'";
            }
            param.put("UF", (request.getParameter("uf").equals("") ? "" : " and cid.uf " + request.getParameter("apenasUF") + "(" + ufs + ")"));
        } else if (modelo.equals("26") || modelo.equals("32") || modelo.equals("29") || modelo.equals("27") || modelo.equals("35")) {
            param.put("IDCIDADEDESTINO", (!request.getParameter("idcidadedestino").equals("0") ? " and id_cidade_destino" + request.getParameter("apenasDestino") + request.getParameter("idcidadedestino") : ""));
            param.put("NUMERO_CARGA", (!request.getParameter("numerocarga").equals("") ? " and numero_carga ='" + request.getParameter("numerocarga")+"'": ""));
            opcoes += (request.getParameter("idcidadedestino").equals("0") ? "" : (request.getParameter("apenasDestino").equals("=") ? "Apenas" : "Exceto") + " o destino: " + request.getParameter("cid_destino") + " - " + request.getParameter("uf_destino") + ". ");
        }

        if (modelo.equals("4")) {
            param.put("IDCIDADEDESTINO", (!request.getParameter("idcidadedestino").equals("0") ? " and id_cidade_destino" + request.getParameter("apenasDestino") + request.getParameter("idcidadedestino") : ""));
            param.put("AREA_DESTINO", (!request.getParameter("area_id").equals("0") ? " and area_destino_id = " + request.getParameter("area_id") : ""));
        } else if (modelo.equals("10")) {
            param.put("AREA_DESTINO", (!request.getParameter("area_id").equals("0") ? " and v.cidade_destino_id IN (select cidade_id from area_cidade ac where area_id = "+request.getParameter("area_id")+")" : ""));
        } else if (modelo.equals("27") || modelo.equals("35")) {
            param.put("AREA_DESTINO", (!request.getParameter("area_id").equals("0") ? " and area_destino_id = " + request.getParameter("area_id") : ""));
        }

        //remetente, Destinatario, Redespacho e Redespachante
        param.put("IDCONSIGNATARIO", idsConsignatario.isEmpty() ? "" : " and idconsignatario " + ("<>".equals(request.getParameter("apenasConsignatario")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
        //param.put("IDCONSIGNATARIO", (!request.getParameter("idconsig").equals("0") ? " and idconsignatario" + request.getParameter("apenasConsignatario") + request.getParameter("idconsig") : ""));
        param.put("IDREDESPACHO", idsRedespacho.isEmpty() ? "" : " and redespacho_id " + ("<>".equals(request.getParameter("apenasRedespacho")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespacho) + ")");
        //param.put("IDREDESPACHO", (!request.getParameter("idredespacho").equals("0") ? " and redespacho_id" + request.getParameter("apenasRedespacho") + request.getParameter("idredespacho") : ""
        if (modelo.equals("31")) {
            param.put("IDCONSIGNATARIO", idsConsignatario.isEmpty() ? "" : " and s.consignatario_id " + ("<>".equals(request.getParameter("apenasConsignatario")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
            param.put("IDREDESPACHO", idsRedespacho.isEmpty() ? "" : " and ct.redespacho_id " + ("<>".equals(request.getParameter("apenasRedespacho")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespacho) + ")");
            param.put("IDREDESPACHANTE", idsRedespachante.isEmpty() ? "" : " and COALESCE(ct.redespachante_id,0) " + ("<>".equals(request.getParameter("apenasRedespachante")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespachante) + ")");

            //param.put("IDREDESPACHO", (!request.getParameter("idredespacho").equals("0") ? " and ct.redespacho_id" + request.getParameter("apenasRedespacho") + request.getParameter("idredespacho") : ""));
        } else if (modelo.equals("1") || modelo.equals("8") || modelo.equals("11") || modelo.equals("15") || modelo.equals("21") || modelo.equals("24") || modelo.equals("26") || modelo.equals("27") || modelo.equals("29") || modelo.equals("30") || modelo.equals("4") || modelo.equals("32") || modelo.equals("35") || modelo.equals("36")){
            param.put("IDREDESPACHANTE", idsRedespachante.isEmpty() ? "" : " and COALESCE(co.redespachante_id,0) " + ("<>".equals(request.getParameter("apenasRedespachante")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespachante) + ")");
            
        } else if (modelo.equals("2") || modelo.equals("9")) {
            param.put("IDREDESPACHANTE", idsRedespachante.isEmpty() ? "" : " and COALESCE(s.redespachante_id,0) " + ("<>".equals(request.getParameter("apenasRedespachante")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespachante) + ")");
        } else if (modelo.equals("3") || modelo.equals("5") || modelo.equals("6") || modelo.equals("7") || modelo.equals("8") || modelo.equals("10") || modelo.equals("12") || modelo.equals("13") || modelo.equals("14") || modelo.equals("17") || modelo.equals("18") || modelo.equals("19") || modelo.equals("20") || modelo.equals("22") || modelo.equals("23") || modelo.equals("25") || modelo.equals("28") || modelo.equals("33") || modelo.equals("34")) {
            param.put("IDREDESPACHANTE", idsRedespachante.isEmpty() ? "" : " and COALESCE(redespachante_id,0) " + ("<>".equals(request.getParameter("apenasRedespachante")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespachante) + ")");
        } else {
            param.put("ID_REPRESENTANTE_ENTREGA2", (!request.getParameter("idredespachante").equals("0") ? " and representante_entrega2_id = " + request.getParameter("idredespachante") : ""));
            param.put("ID_REPRESENTANTE_COLETA2", (!request.getParameter("idredespachante").equals("0") ? " and representante_coleta2_id = " + request.getParameter("idredespachante") : ""));
            param.put("IDREDESPACHANTE_2", (!request.getParameter("idredespachante").equals("0") ? " and representante2_id = " + request.getParameter("idredespachante") : ""));
            param.put("IDREDESPACHANTE", (!request.getParameter("idredespachante").equals("0") ? " and redespachante_id = " + request.getParameter("idredespachante") : ""));
        }
        if (modelo.equals("1")) {
            param.put("IDREMETENTE", idsRemetente.isEmpty() ? "" : " and s.idremetente " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("IDDESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and iddestinatario " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
            //param.put("IDREDESPACHO", (!request.getParameter("idredespacho").equals("0") ? " and co.redespacho_id" + request.getParameter("apenasRedespacho") + request.getParameter("idredespacho") : ""));
        } else if (modelo.equals("5")) {
            param.put("IDREMETENTE", idsRemetente.isEmpty() ? "" : " and remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("IDDESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
            param.put("IDREDESPACHO", idsRedespacho.isEmpty() ? "" : "and co.redespacho_id" + ("<>".equals(request.getParameter("apenasRedespacho")) ? " NOT " : "") + " IN (" + String.join(",", idsRedespacho) + ")");
            String ufs = "";
            for (int x = 0; x <= request.getParameter("uf").split(",").length - 1; x++) {
                ufs += (ufs.equals("") ? "" : ",") + "'" + request.getParameter("uf").split(",")[x] + "'";
            }
            param.put("UF", (request.getParameter("uf").equals("") ? "" : " and uf_destinatario " + request.getParameter("apenasUF") + "(" + ufs + ")"));
        } else if (modelo.equals("31")) {
            param.put("IDREMETENTE", idsRemetente.isEmpty() ? "" : " and ct.remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("IDDESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and ct.destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        } else {
            param.put("IDREMETENTE", idsRemetente.isEmpty() ? "" : " and idremetente " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("IDDESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and iddestinatario " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        }

        if (modelo.equals("1") || modelo.equals("4") || modelo.equals("26") || modelo.equals("27") || modelo.equals("32") || modelo.equals("35") || modelo.equals("36") || modelo.equals("14")) {
            String ufMod = request.getParameter("uf").replaceAll(" ", "");
            ufMod = ufMod.replace("'", "");
            String ufs = "";
            for (int x = 0; x <= ufMod.split(",").length - 1; x++) {
                ufs += (ufs.equals("") ? "" : ",") + "'" + ufMod.split(",")[x] + "'";
            }
            param.put("UF", (request.getParameter("uf").equals("") || (request.getParameter("uf").equals(",")) ? "" : " and uf_destino " + request.getParameter("apenasUF") + "(" + ufs + ")"));
        }
        
//        String filial;
//        
//        if (modelo.equals("31")) {
//            //filial = (!request.getParameter("idfilial").equals("0") ? " and s.filial_id= " + request.getParameter("idfilial") : "");//           
//        }// else {
//           // filial = (!request.getParameter("idfilial").equals("0") ? " and filial= " + request.getParameter("idfilial") : "");
//        //}
//        
        String tipoData = (modelo.equals("16") || modelo.equals("26") || modelo.equals("32") || modelo.equals("27") || modelo.equals("29") || modelo.equals("35") || modelo.equals("36")) ? (!request.getParameter("ctrc1").trim().equals("") && !request.getParameter("ctrc2").trim().equals("") ? "nfiscal" : "dtemissao") : request.getParameter("tipodata");
        if (modelo.equals("9")){
            if (tipoData.equals("baixa_em")){
                tipoData = "dtfechamento";
            }else{
                tipoData = "dtemissao";
            }
        }
        param.put("TIPODATA", tipoData);

        param.put("DATA_INI", (modelo.equals("16") || modelo.equals("26") || modelo.equals("32") || modelo.equals("27") || modelo.equals("29") || modelo.equals("35")|| modelo.equals("36")) && !request.getParameter("ctrc1").trim().equals("") && !request.getParameter("ctrc2").trim().equals("") ? " '" + request.getParameter("ctrc1") + "' " : "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FIM", (modelo.equals("16") || modelo.equals("26") || modelo.equals("32") || modelo.equals("27") || modelo.equals("29") || modelo.equals("35")|| modelo.equals("36")) && !request.getParameter("ctrc1").trim().equals("") && !request.getParameter("ctrc2").trim().equals("") ? " '" + request.getParameter("ctrc2") + "' " : "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        param.put("IDFILIAL", filial.toString());

//        param.put("CANCELADO", canceladoModelo);
        param.put("CANCELADO", !cancelado.equals("") ? canceladoModelo : "");
        //modelo 10 necessita que mande outro cancelado
        param.put("CANCELADO_2", (cancelado.equals("") ? "" : " AND s.is_cancelado=" + cancelado));
        
        if (modelo.equals("30")) {
            param.put("CANCELADO", !cancelado.equals("") ? canceladoModelo : "");
        }
        if (modelo.equals("26")) {
            param.put("MANIFESTO", (!request.getParameter("numeroManifesto").equals("") ? " AND COALESCE((SELECT m2.nmanifesto FROM manifesto m2 JOIN manifesto_conhecimento mc2 ON (m2.idmanifesto = mc2.idmanifesto) WHERE mc2.idconhecimento = co.idmovimento ORDER BY dtsaida desc LIMIT 1),'') = '" + request.getParameter("numeroManifesto") + "'" : ""));
            opcoes += (request.getParameter("numeroManifesto").equals("") ? "" : ". Apenas o manifesto:" + request.getParameter("numeroManifesto"));
        }
        if (modelo.equals("15")) {
            param.put("MANIFESTO", (!request.getParameter("numeroManifesto").equals("") ? " AND numero_manifesto = '" + request.getParameter("numeroManifesto").trim() + "'" : ""));
            opcoes += (request.getParameter("numeroManifesto").equals("") ? "" : ". Número do manifesto:" + request.getParameter("numeroManifesto"));
            param.put("SERIE_MANIF", (!request.getParameter("serieManifesto").equals("") ? " AND serie_manifesto = '" + request.getParameter("serieManifesto").trim().toUpperCase() + "'" : ""));
            opcoes += (request.getParameter("serieManifesto").equals("") ? "" : ". Série do manifesto:" + request.getParameter("serieManifesto"));
        }
        if(modelo.equals("15")){
            param.put("GRUPOS", (request.getParameter("grupos").equals("") ? "" : " and (con.grupo_id " + request.getParameter("excetoGrupo") + "(" + request.getParameter("grupos") + ") " + (request.getParameter("excetoGrupo").equals("NOT IN") ? " OR con.grupo_id is null " : "") + ")"));
        }else{
            param.put("GRUPOS", (request.getParameter("grupos").equals("") ? "" : " and (grupo_id " + request.getParameter("excetoGrupo") + "(" + request.getParameter("grupos") + ") " + (request.getParameter("excetoGrupo").equals("NOT IN") ? " OR grupo_id is null " : "") + ")"));
        }    
        
        param.put("ORDENACAO", ordenacao); 
        param.put("EXTRA", extra);
        param.put("MOSTRA_FILIAL", new Boolean(request.getParameter("mostrarAgencia")));
        param.put("IS_SEGURO_PROPRIO", request.getParameter("seguroProprio").equals("true") ? " and averba_carga_consiguinatario=" + request.getParameter("seguroProprio") : "");
        param.put("AGENCIA", !request.getParameter("agenciaId").equals("0") ? " and c.agency_id = " + request.getParameter("agenciaId") : " ");
        param.put("ANALITICO", request.getParameter("agrupMod16"));
        param.put("TIPO_FRETE", tipoFrete);
        param.put("MOSTRAR_GRAFICO", new Boolean(request.getParameter("mostrarGrafico")));
        
        if(modelo.equals("15")){
            param.put("PRODUTOS", (request.getParameter("produtos").equals("") ? "" : " and (pt.id " + request.getParameter("excetoProduto") + "(" + request.getParameter("produtos") + ") " + (request.getParameter("excetoProduto").equals("NOT IN") ? " OR pt.id is null " : "") + ")"));        
            param.put("IDREMETENTE", idsRemetente.isEmpty() ? "" : " and co.remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("IDDESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and co.destinatario_id" + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        }else if(modelo.equals("19")){
            param.put("PRODUTOS", (request.getParameter("produtos").equals("") ? "" : " and (ct.tipo_produto_id " + request.getParameter("excetoProduto") + "(" + request.getParameter("produtos") + ") " + (request.getParameter("excetoProduto").equals("NOT IN") ? " OR ct.tipo_produto_id is null " : "") + ")"));        
        }else if(modelo.equals("31")){
            param.put("PRODUTOS", (request.getParameter("produtos").equals("") ? "" : " and (pt.id " + request.getParameter("excetoProduto") + "(" + request.getParameter("produtos") + ") " + (request.getParameter("excetoProduto").equals("NOT IN") ? " OR pt.id is null " : "") + ")"));
        }else{
            param.put("PRODUTOS", (request.getParameter("produtos").equals("") ? "" : " and (tipo_produto_id " + request.getParameter("excetoProduto") + "(" + request.getParameter("produtos") + ") " + (request.getParameter("excetoProduto").equals("NOT IN") ? " OR tipo_produto_id is null " : "") + ")"));        
            param.put("PRODUTOS_RECEITA", (request.getParameter("produtos").equals("") ? "" : " and (ct.product_type_id " + request.getParameter("excetoProduto") + "(" + request.getParameter("produtos") + ") " + (request.getParameter("excetoProduto").equals("NOT IN") ? " OR ct.product_type_id is null " : "") + ")"));        
        }

        if (modelo.equals("3")) {
            param.put("DISTRIBUICAO_SALES", (request.getParameter("slDistribuicao").equals("nf") ? "" : " AND (tipo_conhecimento <> 'l' OR (select count(ct4.sale_id) from ctrcs ct4 WHERE ct4.sale_distribuicao_id = idmovimento) = 0) "));
            param.put("DISTRIBUICAO_CTRC", (request.getParameter("slDistribuicao").equals("ct") ? " AND idmovimento NOT IN (SELECT sale_distribuicao_id FROM ctrcs WHERE ctrcs.sale_distribuicao_id = vrelvendas.idmovimento) " : " AND sale_distribuicao_id is null "));
            param.put("DISTRIBUICAO_TOTAL", (request.getParameter("slDistribuicao").equals("nf") ? " AND ((categoria = 'ns') OR (categoria = 'ct' and sale_distribuicao_id is null)) " : " AND idmovimento NOT IN (SELECT sale_distribuicao_id FROM ctrcs WHERE ctrcs.sale_distribuicao_id = idmovimento) "));
            //param.put("DISTRIBUICAO_TOTAL2", (request.getParameter("slDistribuicao").equals("nf") ? " AND ((categoria = 'ns') OR (categoria = 'ct' and sale_distribuicao_id is null)) " : " AND idmovimento NOT IN (SELECT sale_distribuicao_id FROM ctrcs WHERE ctrcs.sale_distribuicao_id = vr.idmovimento) "));
            opcoes += (request.getParameter("slDistribuicao").equals("nf") ? " Em caso de distribuição local mostrar dados da Nota de Serviço. " : " Em caso de distribuição local mostrar dados do CTRC. ");
        } else if (modelo.equals("10")) {
            //sqlDistribuicao = (request.getParameter("slDistribuicao").equals("nf") ? " AND s.categoria = 'ct' and ct.sale_distribuicao_id is null AND s.tipo <> 'b' ":" and s.tipo <> 'l' ");
            param.put("DISTRIBUICAO_SALES", (request.getParameter("slDistribuicao").equals("nf") ? "" : " AND (s.tipo <> 'l' OR (select count(ct4.sale_id) from ctrcs ct4 WHERE ct4.sale_distribuicao_id = s.id) = 0)"));
//            param.put("DISTRIBUICAO_TOTAL", (request.getParameter("slDistribuicao").equals("nf") ? " AND ((categoria = 'ns') OR (categoria = 'ct' and sale_distribuicao_id is null)) " : " AND ((categoria = 'ns' and tipo_conhecimento <> 'l') OR (categoria = 'ct')) "));
            param.put("DISTRIBUICAO_TOTAL", (request.getParameter("slDistribuicao").equals("nf") ? " AND categoria = 'ct' and sale_distribuicao_id is null AND tipo_conhecimento <> 'b' " : " and (tipo_conhecimento <> 'l' OR (select count(ct4.sale_id) from ctrcs ct4 WHERE ct4.sale_distribuicao_id = v.idmovimento) = 0) "));
            //param.put("DISTRIBUICAO_TOTAL_2", (request.getParameter("slDistribuicao").equals("nf") ? " AND ((categoria = 'ns') OR (categoria = 'ct' and ct.sale_distribuicao_id is null)) " : " AND ((categoria = 'ns' and s.tipo <> 'l') OR (categoria = 'ct')) "));
            param.put("DISTRIBUICAO_TOTAL_2", (request.getParameter("slDistribuicao").equals("nf") ? " AND categoria = 'ct' and ct.sale_distribuicao_id is null AND s.tipo <> 'b' " : " and s.tipo <> 'l' "));
            opcoes += (request.getParameter("slDistribuicao").equals("nf") ? " Em caso de distribuição local mostrar dados da Nota de Serviço. " : " Em caso de distribuição local mostrar dados do CTRC. ");
        }
        param.put("CFOP", cfop);

        //if (modelo.equals("15") || modelo.equals("31")) {
        //    param.put("TIPO_PRODUTO", request.getParameter("tipo_produto_id").equals("0") ? "" : "  and pt.id = " + request.getParameter("tipo_produto_id"));
        //}else{
        //     param.put("TIPO_PRODUTO", request.getParameter("tipo_produto_id").equals("0") ? "" : " and tipo_produto_id =" + request.getParameter("tipo_produto_id"));
        //}
        
        if(modelo.equals("33")){
            param.put("TP_VEICULO",request.getParameter("tipveiculo").equals("0") ? "" : "and id_tipoveiculo="+request.getParameter("tipveiculo"));     
        }
        
        if(modelo.equals("6")){
            String ufMod = request.getParameter("uf").replaceAll(" ", "");
            ufMod = ufMod.replace("'", "");
            String ufs = "";
            for (int x = 0; x <= ufMod.split(",").length - 1; x++) {
                ufs += (ufs.equals("") ? "" : ",") + "'" + ufMod.split(",")[x] + "'";
            }
            param.put("UF", (request.getParameter("uf").equals("") || (request.getParameter("uf").equals(","))  ? "" : " and ufdestino " + request.getParameter("apenasUF") + "(" + ufs + ")"));
        }
        
        if(modelo.equals("6") || modelo.equals("14")){
            //Tentando tirar a virgula e setar espaço em branco para não dar erro !!!!
            param.put("IDCIDADEDESTINO", (!request.getParameter("idcidadedestino").equals("0")  ? " and id_cidade_destino" + request.getParameter("apenasDestino") + request.getParameter("idcidadedestino")  : ""));
        }

        
        //I N I C I O   D A S    O R G A N I Z A C O E S    D O S    P A R A M E T R O S
        //1) Parametro para mostrar os CT(s) Manifestados ou não.
        String ct_manifestado = request.getParameter("manifestado");
        String sqlCtManifestado = "";
        //2) Parametro para filtrar apenas uma Série 
        String serie = request.getParameter("serie");
        String sqlSerie = "";
        //3) Parametro para filtrar apenas um motorista
        String sqlMotorista = "";
        //4) Parametro para filtrar apenas um veiculo
        String sqlVeiculo = "";
        //5) Parametro para filtrar apenas um tipo de veiculo
        String sqlTipoVeiculo = "";
        //6) Parametro para filtrar apenas um serivço - 24-10-2013 Paulo
        String apenasServico = "";   
        //7) Parametro para filtrar o tipo de transporte (Modal)
        String sqlModal = "";
        //8) Tipo de agrupamento
        String sqlTipoAgrupamento = "";

        String veiculoIdsString = String.join(", ", veiculoIds);

        if (modelo.equals("1")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND s.serie LIKE ('%%') " : " AND s.serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and s.motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and s.veiculo_cavalo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and s.tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("2")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("3")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' OR categoria = 'ns' ) " : "");
        }else if (modelo.equals("4")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and co.tipo_transporte='" + tipoTransporte + "'" : "");
            sqlTipoAgrupamento = request.getParameter("agrupMod4");
            String sqlContagemDias = " ('now'::text::date - dtemissao) ";
            if (Apoio.parseBoolean(request.getParameter("chk_dias_uteis"))){
                sqlContagemDias = " (get_qtd_dias_uteis(dtemissao, 'now'::text::date, id_cidade_destino, uf_destino)) ";
                opcoes += " Considerar dias úteis na contagem de dias;";
            }
            param.put("CONTAGEM_DIAS", sqlContagemDias);
        }else if (modelo.equals("5")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? "" : "and serie ='"+serie+"'");
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            //deixei pois pode ser util..
            //sqlTipoVeiculo = (!request.getParameter("tipofrota").equals("td") ? " and veiculo_cavalo_tipo_frota" + request.getParameter("apenasTipoVeiculo") + "'" + request.getParameter("tipofrota") + "'" : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("6")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            if (chkNfseNormal) {
                sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' OR tipo_transporte is null) " : "");
            }else{
                sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
            }
            sqlTipoAgrupamento = request.getParameter("agrupMod6");
        }else if (modelo.equals("7")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' or tipo_transporte is null )" : "");
        }else if (modelo.equals("8")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("9")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("10")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_tipo_frota in (" + (tiposFrota) +") ");
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("11")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("12")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("13")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and ct.tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("14")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("15")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            param.put("IDCONSIGNATARIO", idsConsignatario.isEmpty() ? "" : " and sl.consignatario_id " + ("<>".equals(request.getParameter("apenasConsignatario")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("16")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            apenasServico = (!request.getParameter("type_service").equals("0") ? " and nf.id_type_servico="+request.getParameter("type_service") : "");
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("17")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and (veiculo_cavalo_id IN (".concat(veiculoIdsString).concat(") OR veiculo_carreta_id IN (").concat(veiculoIdsString).concat("))") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("18")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and ct.motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_cavalo_id IN (".concat(veiculoIdsString).concat(")") : "");
            //sqlTipoVeiculo = (!request.getParameter("tipofrota").equals("td") ? " and veiculo_cavalo_tipo_frota" + request.getParameter("apenasTipoVeiculo") + "'" + request.getParameter("tipofrota") + "'" : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("19")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and ct.motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and ct.veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("20")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            if (chkNfseNormal) {
                sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' OR tipo_transporte is null) " : "");
            }else{
                sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
            }
        }else if (modelo.equals("21")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            sqlModal = (!tipoTransporte.equals("false") ? " and co.tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("22")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("23")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("24")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and co.tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("25")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            if (chkNfseNormal) {
                sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' OR tipo_transporte is null) " : "");
            }else{
                sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
            }
            sqlTipoAgrupamento = request.getParameter("agrupMod25");
        }else if (modelo.equals("26")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            
            sqlVeiculo = (!veiculoIds.isEmpty() ? " AND (veiculo_cavalo_id IN (".concat(veiculoIdsString).concat(") OR veiculo_carreta_id IN (").concat(veiculoIdsString).concat(") OR veiculo_bitrem_id IN (").concat(veiculoIdsString).concat("))") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("27")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("28")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            if (chkNfseNormal) {
                sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' OR tipo_transporte is null) " : "");
            }else{
                sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
            }
        }else if (modelo.equals("29")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("30")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("31")){
            sqlCtManifestado = "";
            sqlSerie = (!serie.equals("") ? "AND s.serie LIKE ('" + serie + "') " : "");
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and ct.motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and v.idveiculo IN (".concat(veiculoIdsString).concat(")") : " ");
            //sqlTipoVeiculo = (!request.getParameter("tipofrota").equals("td") ? " and v.tipofrota" + request.getParameter("apenasTipoVeiculo") + "'" + request.getParameter("tipofrota") + "'" : "");
            sqlTipoVeiculo = ("" + (tiposFrota.equals("")? "" : "AND v.tipofrota in ("+tiposFrota+")"));
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("32")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("33")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? "" : "and serie ='"+serie+"'");
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            //sqlTipoVeiculo = (!request.getParameter("tipofrota").equals("td") ? " and veiculo_cavalo_tipo_frota" + request.getParameter("apenasTipoVeiculo") + "'" + request.getParameter("tipofrota") + "'" : "");
            sqlTipoVeiculo = (tiposFrota.equals("") ? "" : " AND veiculo_cavalo_tipo_frota in (" + (tiposFrota) +") ");
            if (chkNfseNormal) {
                sqlModal = (!tipoTransporte.equals("false") ? " and (tipo_transporte='" + tipoTransporte + "' OR tipo_transporte is null) " : "");
            }else{
                sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
            }
        }else if (modelo.equals("34")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and ct.motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and ct.veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("35")){
            sqlCtManifestado = (ct_manifestado.equals("both")?"":(ct_manifestado.equals("true")?" AND idmovimento IN (SELECT idconhecimento FROM manifesto_conhecimento WHERE idconhecimento = idmovimento) ":" AND idmovimento NOT IN (SELECT idconhecimento FROM manifesto_conhecimento WHERE idconhecimento = idmovimento) "));
            sqlSerie = (serie.equals("") ? " AND serie LIKE ('%%') " : " AND serie = "+Apoio.SqlFix(serie));
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }else if (modelo.equals("36")){
            sqlCtManifestado = "";
            sqlSerie = (serie.equals("") ? "" : "and serie ='"+serie+"'");
            sqlMotorista = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id =" + request.getParameter("idmotorista") : "");
            sqlVeiculo = (!veiculoIds.isEmpty() ? " and veiculo_id IN (".concat(veiculoIdsString).concat(")") : "");
            sqlTipoVeiculo = "";
            sqlModal = (!tipoTransporte.equals("false") ? " and tipo_transporte='" + tipoTransporte + "'" : "");
        }
        
        //PARAMETROS
        param.put("MANIFESTADO",sqlCtManifestado);     
        param.put("SERIE", sqlSerie);
        param.put("IDMOTORISTA", sqlMotorista);
        param.put("IDVEICULO", sqlVeiculo);
        param.put("TIPO_VEICULO", sqlTipoVeiculo);
        param.put("TIPO_TRANSPORTE", sqlModal); 
        param.put("TIPO_AGRUPAMENTO", sqlTipoAgrupamento);
        param.put("IS_MOSTRAR_NFSE_NORMAL", (!chkNfseNormal &&(
                modelo.equals("6") || modelo.equals("20") 
                || modelo.equals("25") || modelo.equals("28") 
                || modelo.equals("33") )? " AND (categoria = 'ct' OR (categoria = 'ns' AND tipo_conhecimento = 'l')) " : ""));
        
        if(modelo.equals("16")){            
            if(!apenasServico.equals("")){
                param.put("TYPE_SERVICO", apenasServico);
            }else{
                apenasServico = " and nf.id_type_servico is not null";
                param.put("TYPE_SERVICO", apenasServico);
            }
        }
        
        //INICIO DA NOVA ESTRUTURA DE PARAMETROS NOS RELATORIOS 
        //INICIO Campos de Status da SEFAZ
        String statusSEFAZ = "";
        statusSEFAZ = (is_status_confirmado ? ";Status SEFAZ:Confirmado" : "");
        statusSEFAZ += (is_status_pendente ? (statusSEFAZ.equals("") ? ";Status SEFAZ:" : ",") + "Pendente" : "");
        statusSEFAZ += (is_status_enviado ? (statusSEFAZ.equals("") ? ";Status SEFAZ:" : ",") + "Enviado" : "");
        statusSEFAZ += (is_status_negado ? (statusSEFAZ.equals("") ? ";Status SEFAZ:" : ",") + "Negado" : "");
        opcoes += statusSEFAZ;
        
        param.put("IS_CONFIRMADO",is_status_confirmado);     
        param.put("IS_PENDENTE",is_status_pendente);     
        param.put("IS_ENVIADO",is_status_enviado);     
        param.put("IS_NEGADO",is_status_negado);     
        //FIM Campos de Status da SEFAZ
        
        param.put("OPCOES", opcoes);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        if(modelo.equals("2")){
            param.put("ALIQUOTA_FRETE", request.getParameter("apenasAliqFrete"));
        }
        //FIM DA NOVA ESTRUTURA DE PARAMETROS NOS RELATORIOS 
        request.setAttribute("map", param);
        request.setAttribute("rel", "ctrcmod" + request.getParameter("modelo"));
        }
        RequestDispatcher dispatcher = null;
        dispatcher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispatcher.forward(request, response);
        
    }else if(acao.equals("iniciar")){
        
//        ReportBuilderBO bo = new ReportBuilderBO();
//        Consulta filtro = new Consulta();
//        filtro.setCampoConsulta("nome_relatorio");
//        filtro.setFiltrosAdicionais(new StringBuilder(" and rotina_relatorio = ").append(SistemaTipoRelatorio.WEBTRANS_CTE_RELATIORIO.ordinal()));
//        filtro.setLimiteResultados(100);
//        Collection lista = bo.listarRelatorios(filtro);
//        
//        request.setAttribute("listaRelatorioPersonalizado", lista);
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CTE_RELATIORIO.ordinal());
    }
        
    request.setAttribute("user", Apoio.getUsuario(request));
%>

<script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
<jsp:include page="/importAlerts.jsp">
    <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
    <jsp:param name="nomeUsuario" value="${user.nome}"/>
</jsp:include>
<style>
    .modal-dialog {
        text-align: left !important;
    }
</style>
<script language="javascript" type="text/javascript">
    var homePath = '${homePath}';

    jQuery.noConflict();
    function voltar(){
        location.replace("./menu");
    }

    function localizaremet(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Remetente_',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizaredespacho(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=6','Redespacho',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
   
    function localizaRedespachante(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=23','Redespachante',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizaRedespachoCodigo(campo, valor){
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if (resp == 'INA'){
                $('idredespacho').value = '0';
                $('red_codigo').value = '';
                $('red_rzs').value = '';
                $('red_cidade').value = '';
                $('red_uf').value = '';
                $('red_cnpj').value = '';
                $('red_pgt').value = '0';
                $('red_tipotaxa').value = '-1';
                $('idvenredespacho').value = '0';
                $('venredespacho').value = '';
                $('vlvenredespacho').value = '0';
                $('redtipofpag').value = 'v';
                $('redtipoorigem').value = 'r';
                $('redtabelaproduto').value = 'f';
                $('red_analise_credito').value = 'f';
                $('red_valor_credito').value = '0';
                $('red_is_bloqueado').value = 'f';
                $('red_tabela_remetente').value = 'f';
                alert('Cliente inativo.');
                return false;
            }else if(resp == ''){
                $('idredespacho').value = '0';
                $('red_codigo').value = '';
                $('red_rzs').value = '';
                $('red_cidade').value = '';
                $('red_uf').value = '';
                $('red_cnpj').value = '';
                $('red_pgt').value = '0';
                $('red_tipotaxa').value = '-1';
                $('idvenredespacho').value = '0';
                $('venredespacho').value = '';
                $('vlvenredespacho').value = '0';
                $('redtipofpag').value = 'v';
                $('redtipoorigem').value = 'r';
                $('redtabelaproduto').value = 'f';
                $('red_analise_credito').value = 'f';
                $('red_valor_credito').value = '0';
                $('red_is_bloqueado').value = 'f';
                $('red_tabela_remetente').value = 'f';
                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                $('idredespacho').value = resp.split('!=!')[0];
                $('red_codigo').value = resp.split('!=!')[0];
                $('red_rzs').value = resp.split('!=!')[1];
                $('red_cidade').value = resp.split('!=!')[2];
                $('red_uf').value = resp.split('!=!')[3];
                $('red_cnpj').value = resp.split('!=!')[4];
                $('red_pgt').value = resp.split('!=!')[5];
                $('red_tipotaxa').value = resp.split('!=!')[6];
                $('idvenredespacho').value = resp.split('!=!')[7];
                $('venredespacho').value = resp.split('!=!')[8];
                $('vlvenredespacho').value = resp.split('!=!')[10];
                $('redtipofpag').value = resp.split('!=!')[11];
                $('redtipoorigem').value = resp.split('!=!')[16];
                $('redtabelaproduto').value = resp.split('!=!')[18];
                $('red_analise_credito').value = resp.split('!=!')[19];
                $('red_valor_credito').value = resp.split('!=!')[20];
                $('red_is_bloqueado').value = resp.split('!=!')[21];
                $('red_tabela_remetente').value = resp.split('!=!')[22];
                aoClicarNoLocaliza('Redespacho');
            }
        }//funcao e()

        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./jspcadconhecimento.jsp?acao=localizaClienteCodigo&valor="+valor+"&idFilialFiltro=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
    }
    
     function modeloP(){
        if($("modeloP").checked){
            $("trPedido").style.display = "";
        }else{
            $("trPedido").style.display = "none";
        }
    }
    
    function modelos(modelo){
        modeloP();
        $("trTipoTrans").style.display = "";
        $("trRedes").style.display = "";
        $("veiculo").style.display = "none";
        $("vei_placa").style.display = "none";
        $("prod_tipo").style.display = "";
        $("localiza_vei").style.display = "none";
        $("limpavei").style.display = "none";
        $("tipodata").value = "emissao_em";
        $("tipodata").disabled = true;
        $("apenasTipoVeiculo").style.display = "none";
        $("apenasVeiculos").style.display = "none";
        $("tipofrota").style.display = "none";
        $("apenasUF").style.display = "none";
        $("uf").style.display = "none";
        $("descUF").style.display = "none";
        $("lbModalidade").style.display = "none";
        $("apenasModalidade").style.display = "none";
        $("lbcidade_destino").style.display = "none";
        $("cid_destino").style.display = "none";
        $("uf_destino").style.display = "none";
        $("localiza_cid_destino").style.display = "none";
        $("apaga_cid_destino").style.display = "none";
        $("descontoIcms").style.display = "none";
        $("lbDescontoIcms").style.display = "none";
//        $("blTipoProduto").style.display = "";
//        $("tipoProduto").style.display = "";
        $("divSeguroProprio").style.display = "none";
        $("apenasDestino").style.display = "none";
        $("numerocarga").style.display = "none";
        $("ctrc1").style.display = "none";
        $("ctrc2").style.display = "none";
        $("lbnumerocarga").style.display = "none";
        $("lbctrc").style.display = "none";
        $("lbAgencia").style.display = "none";
        $("agenciaId").style.display = "none";
        $("lbMotrarCT").innerHTML = "Mostrar CT-e(s):";
        $("divDistribuicao").style.display = "none";
        $("lbArea").style.display = "none";
        $("area").style.display = "none";
        $("localizaArea").style.display = "none";
        $("limpaArea").style.display = "none";
        $("lbCfop").style.display = "none";
        $("idcfop").style.display = "none";
        $("cfop").style.display = "none";
        $("botCfop").style.display = "none";
        $("borrachaCfop").style.display = "none";
        $("numeroManifesto").style.display = "none";
        $("serieManifesto").style.display = "none";
        $("lbManifesto").style.display = "none";
        $("lbManifesto2").style.display = "none";
        $("lbtipo").style.display = "none";
        $("tipveiculo").style.display = "none";
        $("lbManifestado").style.display = "none";
        $("manifestado").style.display = "none";
        $("lbtype_servico").style.display = "none";
        $("type_service_descricao").style.display = "none";
        $("localiza_typeservico").style.display = "none";
        $("borrachaTypeServico").style.display = "none";
        //Status SEFAZ
        $("ct_confirmados").style.display = "";
        $("ct_pendentes").style.display = "";
        $("ct_enviados").style.display = "";
        $("ct_negados").style.display = "";
        $("lb_confirmados").style.display = "";
        $("lb_pendentes").style.display = "";
        $("lb_enviados").style.display = "";
        $("lb_negados").style.display = "";
        $("trChkNfseNormal").style.display = "none";
        $("trFilialEntrega").style.display = "";
        $("ct_cancelados").disabled = false;
        
        if ($("modeloP").checked) {                        
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = ""; 
            $("prod_tipo").style.display = "";
        }
        
        var qtdRel = 36; // quantidade de modelos de relatorio
        //desmarcando todos os modelos
        $("modeloP").checked = false;
         
        for (var i = 1; i<= qtdRel; i++){
            $("modelo"+i).checked = false;
        }

        $("finalizado").disabled = true;
        //marcando apenas o modelo selecionado
        $("modelo"+modelo).checked = true;

        if (modelo == 1){
            $("veiculo").style.display = "";    
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divSeguroProprio").style.display = "";
            $("lbCfop").style.display = "";
            $("idcfop").style.display = "";
            $("cfop").style.display = "";
            $("botCfop").style.display = "";
            $("borrachaCfop").style.display = "";
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("trPedido").style.display = "none";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("trChkNfseNormal").style.display = "none";
             
        } else if (modelo == 2){
            $("descontoIcms").style.display = "";
            $("lbDescontoIcms").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "";
            $("divInpApenasAliqFrete").style.display = "";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 3){
            $("divDistribuicao").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 4){
            $("finalizado").disabled = false;
            $("finalizado").value = "false";
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("lbArea").style.display = "";
            $("area").style.display = "";
            $("localizaArea").style.display = "";
            $("limpaArea").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
            $("tipodata").disabled = false;
             $("trPedido").style.display = "none";
            selectChegada(modelo);
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 5){
            $("finalizado").disabled = false;
            $("tipodata").disabled = false;
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            selectChegada(modelo);
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 6){
            $("lbAgencia").style.display = "";
            $("agenciaId").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            // novo filtro apenas ufs - 16-12-2013 - Paulo
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            // novo filtro apenas cidade destino - 16-12-2013 - Paulo
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "";
        } else if (modelo == 7){
            $("finalizado").disabled = false;
            $("lbModalidade").style.display = "";
            $("apenasModalidade").style.display = "";
            $("lbcidade_destino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("ct_confirmados").checked = false;
            $("ct_confirmados").style.display = "none";
            $("ct_pendentes").style.display = "none";
            $("ct_enviados").style.display = "none";
            $("ct_negados").style.display = "none";
            $("lb_confirmados").style.display = "none";
            $("lb_pendentes").style.display = "none";
            $("lb_enviados").style.display = "none";
            $("lb_negados").style.display = "none";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
            $("ct_cancelados").disabled = "true";
        // 15/07/13 - adição do modelo 8 
        } else if (modelo == 8){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("ct_confirmados").checked = true;
            $("ct_pendentes").style.display = "none";
            $("ct_enviados").style.display = "none";
            $("ct_negados").style.display = "none";
            $("lb_pendentes").style.display = "none";
            $("lb_enviados").style.display = "none";
            $("lb_negados").style.display = "none";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
            $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 9){
            $("tipodata").disabled = false;
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";  
             $("trPedido").style.display = "none";
            selectChegada(modelo);
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 10){
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
            $("divDistribuicao").style.display = "";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("lbArea").style.display = "";
            $("area").style.display = "";
            $("localizaArea").style.display = "";
            $("tipofrota").style.display = "";
            $("apenasVeiculos").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        }else if(modelo == 11){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 12){
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 13){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        // 15/07/13 - Adição do modelo 14
        } else if (modelo == 14){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
                 // novo filtro apenas ufs - 16-12-2013 - Paulo
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            // novo filtro apenas cidade destino - 16-12-2013 - Paulo
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";modelo
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        }else if(modelo == 15){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("ct_confirmados").checked = true;
            $("ct_pendentes").style.display = "none";
            $("ct_enviados").style.display = "none";
            $("ct_negados").style.display = "none";
            $("lb_pendentes").style.display = "none";
            $("lb_enviados").style.display = "none";
            $("lb_negados").style.display = "none";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
            $("numeroManifesto").style.display = "";
            $("serieManifesto").style.display = "";
            $("lbManifesto").style.display = "none";
            $("lbManifesto2").style.display = "";
        } else if (modelo == 16){
            $("lbctrc").style.display = "";
            $("ctrc1").style.display = "";
            $("trTipoTrans").style.display = "none";
            $("trRedes").style.display = "none";
            $("lbMotrarCT").innerHTML = "Mostrar NFS-e(s):";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
            $("lbtype_servico").style.display = "";
            $("type_service_descricao").style.display = "";
            $("localiza_typeservico").style.display = "";
            $("borrachaTypeServico").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("ct_confirmados").style.display = "none";
            $("ct_pendentes").style.display = "none";
            $("ct_enviados").style.display = "none";
            $("ct_negados").style.display = "none";
            $("lb_confirmados").style.display = "none";
            $("lb_pendentes").style.display = "none";
            $("lb_enviados").style.display = "none";
            $("lb_negados").style.display = "none";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
            $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
            $("trFilialEntrega").style.display = "none";
        } else if (modelo == 17){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 18){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        // 15/07/13 - Adição do modelo 19
        } else if (modelo == 19){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 20){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "";
        } else if (modelo == 21){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("apenasUF").style.display = "none";
            $("uf").style.display = "none";
            $("descUF").style.display = "none";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 22){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 23 ){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 24){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 25){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "";
        } else if (modelo == 26){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("numerocarga").style.display = "";
            $("ctrc1").style.display = "";
            $("ctrc2").style.display = "";
            $("lbnumerocarga").style.display = "";
            $("lbctrc").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("numeroManifesto").style.display = "";
            $("lbManifesto").style.display = "";
            $("lbManifesto2").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAA modelo 26 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 27){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("numerocarga").style.display = "";
            $("ctrc1").style.display = "";
            $("ctrc2").style.display = "";
            $("lbnumerocarga").style.display = "";
            $("lbctrc").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("lbArea").style.display = "";
            $("area").style.display = "";
            $("localizaArea").style.display = "";
            $("limpaArea").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 28){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "";
        }else if (modelo == 29){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("numerocarga").style.display = "";
            $("ctrc1").style.display = "";
            $("ctrc2").style.display = "";
            $("lbnumerocarga").style.display = "";
            $("lbctrc").style.display = "";
//                $("blTipoProduto").style.display = "";
//                $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        //15/07/13 - Adição do modelo 30
        } else if (modelo == 30){
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 31){
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        } else if (modelo == 32){
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("numerocarga").style.display = "";
            $("ctrc1").style.display = "";
            $("ctrc2").style.display = "";
            $("lbnumerocarga").style.display = "";
            $("lbctrc").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        }else if (modelo == 33){
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("apenasTipoVeiculo").style.display = "none";
            $("apenasVeiculos").style.display = "";
            $("tipofrota").style.display = "";
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("lbtipo").style.display = "";
            $("tipveiculo").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "";
        //15/07/13 - Adição do modelo 34
        }else if (modelo == 34){
            $("tipoFrete").style.display = "none";
            $("lbTipoFrete").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        }else if (modelo == 35){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("numerocarga").style.display = "";
            $("ctrc1").style.display = "";
            $("ctrc2").style.display = "";
            $("lbnumerocarga").style.display = "";
            $("lbctrc").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("lbArea").style.display = "";
            $("area").style.display = "";
            $("localizaArea").style.display = "";
            $("limpaArea").style.display = "";
//                $("blTipoProduto").style.display = "";
//                $("tipoProduto").style.display = "";
            $("lbManifestado").style.display = "";
            $("manifestado").style.display = "";
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";     
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        }else if(modelo == 36){
            $("tipoFrete").style.display = "";
            $("lbTipoFrete").style.display = "";
            $("apenasDestino").style.display = "";
            $("cid_destino").style.display = "";
            $("uf_destino").style.display = "";
            $("localiza_cid_destino").style.display = "";
            $("apaga_cid_destino").style.display = "";
            $("numerocarga").style.display = "";
            $("ctrc1").style.display = "";
            $("ctrc2").style.display = "";
            $("lbnumerocarga").style.display = "";
            $("lbctrc").style.display = "";
            $("apenasUF").style.display = "";
            $("uf").style.display = "";
            $("descUF").style.display = "";
            $("numeroManifesto").style.display = "";
            $("lbManifesto").style.display = "";
            $("lbManifesto2").style.display = "none";
//            $("blTipoProduto").style.display = "";
//            $("tipoProduto").style.display = "";  
            $("veiculo").style.display = "";
            $("vei_placa").style.display = "";
            $("localiza_vei").style.display = "";
            $("limpavei").style.display = "";
            $("divLbApenasAliqFrete").style.display = "none";
            $("divInpApenasAliqFrete").style.display = "none";
             $("trPedido").style.display = "none";
            $("trChkNfseNormal").style.display = "none";
        }
        
    }
  
    function localizades(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Destinatario_',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizaconsig(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Consignatario_',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela)
    {          
        if (idjanela == "Remetente_"){
            $("remet").value = $("con_rzs").value;
            $("idremetente").value = $("idconsignatario").value;
        }else  if (idjanela == "Destinatario_"){
            $("dest").value = $("con_rzs").value;
            $("iddestinatario").value = $("idconsignatario").value;
        }else  if (idjanela == "Consignatario_"){
            $("consig").value = $("con_rzs").value;
            $("idconsig").value = $("idconsignatario").value;
        }else if (idjanela == "Grupo"){
            addGrupo($('grupo_id').value,'node_grupos', $('grupo').value)
        }else if(idjanela == "Produto"){
            addProduto($('tipo_produto_id').value,'node_produtos', $('tipo_produto').value);
        }else if(idjanela == "Motorista"){
            removerValorInput('vei_placa')
        }else if (idjanela == "Filial_Emissao"){
            $('idfilialemissao').value = $('idfilial').value;
            $('filial_emissora').value = $('fi_abreviatura').value;
            if(<%=!tipoFilialConfig.equals("p")%>){
                alteraCondicaoFilial();
            }
        }else if (idjanela == "Filial_Entrega"){
            $('idfilialentrega').value = $('idfilial').value;
            $('filial_entrega').value = $('fi_abreviatura').value;
        }
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
    
    function localizafilialDestino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial_Destino',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function popRel(){
        var produtos = "";
        var prod = document.getElementById("prod_tipo").value;
        if(prod){
            prod.split('!@!').forEach(function (elemento) {
                var split = elemento.split('#@#');
                if(split[1]){
                    produtos += ","+split[1];
                }
            });
            produtos = produtos.split(',').slice(1);
        }
        var modelo;
        var grupos = getGrupos();
        if (! validaData($("dtinicial").value) || ! validaData($("dtfinal").value))
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
            else if ($("modelo13").checked)
                modelo = '13';
            else if ($("modelo14").checked)
                modelo = '14';
            else if ($("modelo15").checked)
                modelo = '15';
            else if ($("modelo16").checked)
                modelo = '16';
            else if ($("modelo17").checked)
                modelo = '17';
            else if ($("modelo18").checked)
                modelo = '18';
            else if ($("modelo19").checked)
                modelo = '19';
            else if ($("modelo20").checked)
                modelo = '20';
            else if ($("modelo21").checked)
                modelo = '21';
            else if ($("modelo22").checked)
                modelo = '22';
            else if ($("modelo23").checked)
                modelo = '23';
            else if ($("modelo24").checked)
                modelo = '24';
            else if ($("modelo25").checked)
                modelo = '25';
            else if ($("modelo26").checked)
                modelo = '26';
            else if ($("modelo27").checked)
                modelo = '27';
            else if ($("modelo28").checked)
                modelo = '28';
            else if ($("modelo29").checked)
                modelo = '29';
            else if ($("modelo30").checked)
                modelo = '30';
            else if ($("modelo31").checked)
                modelo = '31';
            else if ($("modelo32").checked)
                modelo = '32';
            else if ($("modelo33").checked)
                modelo = '33';
            else if ($("modelo34").checked)
                modelo = '34';
            else if ($("modelo35").checked)
                modelo = '35';
            else if ($("modelo36").checked)
                modelo = '36';
            else if ($("modeloP").checked)
                modelo = 'P';
    
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";

            var agrupMod4 = ""
            if($("agrupMod4_1").checked == true){
                agrupMod4 = "abreviatura";
            }else if($("agrupMod4_2").checked == true){
                agrupMod4 = "cidade_destino";
            }else if($("agrupMod4_3").checked == true){
                agrupMod4 = "area_destino,destinatario";
            }else if($("agrupMod4_4").checked == true){
                agrupMod4 = "consignatario";
            }else if($("agrupMod4_5").checked == true){
                agrupMod4 = "cat_carga_id";
            }else if($("agrupMod4_6").checked == true) {
                agrupMod4 = "id_filial_entrega";
            }else{            
                agrupMod4 = "abreviatura";
            }
    
            //agrupMod6
            var agrupMod6 = ""
            if($("agrupMod6_1").checked == true){
                agrupMod6 = "abreviatura";
            }else if($("agrupMod6_2").checked == true){
                agrupMod6 = "idmanifesto";
            }

            var agrupMod16 = "false";
            if ($('agrupMod16_1').checked){
                agrupMod16 = "true";
            }

            //agrupMod25
            var agrupMod25 = ""
            if($("agrupadoFilial25").checked == true){
                agrupMod25 = "abreviatura";
            }else if($("agrupadoVeiculo25").checked == true){
                agrupMod25 = "veiculo_placa";
            }
            
            $("formPedidosNota").action = './relctrc?acao=exportar&modelo='+modelo+
                '&impressao='+impressao+
                '&finalizado='+$("finalizado").value+
                '&agrupadoCarreta='+$("agrupadoCarreta").checked+
                '&mostrarAgencia=' + $("mostrarAgencia").checked +
                '&mostrarGrafico=' + $("mostrarGrafico").checked +
                '&tipoTransporte=' + $("tipoTransporte").value +
                '&idredespachante=' + $("idredespachante").value +
                '&seguroProprio=' + $("seguroProprio").checked +
                '&chk_dias_uteis=' + $("chk_dias_uteis").checked +
                '&ct_normal=' + $("ct_normal").checked +
                '&ct_local=' + $("ct_local").checked +
                '&ct_diaria=' + $("ct_diaria").checked +
                '&ct_paletizacao=' + $("ct_paletizacao").checked +
                '&ct_complementar=' + $("ct_complementar").checked +
                '&ct_reentrega=' + $("ct_reentrega").checked +
                '&ct_devolucao=' + $("ct_devolucao").checked +
                '&ct_cortesia=' + $("ct_cortesia").checked +
                '&ct_substituicao=' + $("ct_substituicao").checked +
                '&ct_substituido=' + $("ct_substituido").checked +
                '&ct_nao_cancelados=' + $("ct_nao_cancelados").checked +
                '&ct_cancelados=' + $("ct_cancelados").checked +
                '&ct_confirmados=' + $("ct_confirmados").checked +
                '&ct_pendentes=' + $("ct_pendentes").checked +
                '&ct_enviados=' + $("ct_enviados").checked +
                '&ct_negados=' + $("ct_negados").checked +
                '&agrupMod4=' + agrupMod4 +
                '&agrupMod6=' + agrupMod6 +
                '&agrupMod16=' + agrupMod16 +
                '&agrupMod25=' + agrupMod25 +
                '&tipveiculo='+$("tipveiculo").value+
                '&is_Agregado='+$("is_Agregado").checked+
                '&is_Carreteiros='+$("is_Carreteiros").checked+
                '&is_FrotaP='+$("is_FrotaP").checked+
//                '&pedidoNota='+$("pedidoNota").value+
                '&'+
                concatFieldValue("personalizado,dtinicial,dtfinal,idremetente,iddestinatario,"+
                "idconsig,idfilialemissao,idfilialentrega,serie,idmotorista,consig,redspt_rzs,"+
                "tipodata,ordenacao,tipofrota,apenasDestinatario,apenasRemetente,apenasFilial,apenasFilialEntrega,"+
                "apenasConsignatario,apenasTipoVeiculo,apenasUF,remet,dest,"+
                "uf,apenasModalidade,idcidadedestino,excetoGrupo,excetoProduto,descontoIcms,idcfop,cfop,"+
//              "tipo_produto_id,tipo_produto,tipoFrete ,fi_abreviatura,motor_nome,apenasDestino,slDistribuicao,"+
                "tipoFrete ,filial_entrega,filial_emissora,motor_nome,apenasDestino,slDistribuicao,"+
                "uf_destino,cid_destino,numerocarga,ctrc1,ctrc2,agenciaId,idredespacho,apenasRedespacho,area_id,area,numeroManifesto,tipveiculo,manifestado,apenasAliqFrete,serieManifesto," +
                "vei_placa, red_rzs")+
                '&grupos='+grupos+'&type_service='+$("type_service_id").value+'&produtos='+produtos
                +'&chkNfseNormal='+$('chkNfseNormal').checked;
        
                var janela = window.open('about:blank', 'pop1', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
                $("formPedidosNota").target = "pop1";
        
                $("formPedidosNota").submit();
        }
    }
    
    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=41','Veiculo',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizatipoproduto(){
        post_cad = window.open('./localiza?acao=consultar&idlista=37','Produto',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=12','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    // Borracha - Limpar Type Serviço - 24-10-2013
    function limparTypeServico(){           
        $("type_service_id").value = "0";
        $("type_service_descricao").value = "";
    }
    
    function consultarTodasAliq(){        
        if ($("chkAliqFrete").checked) {
            $("apenasAliqFrete").value = "";
            $("apenasAliqFrete").disabled = true;    
        }else{
            $("apenasAliqFrete").value = "0.00";
            $("apenasAliqFrete").disabled = false;
        }
    }
    //Está função serve para habilitar e desabilitar as option: Data de Entrega, Data de Chegada e  
    function selectChegada(modelo){
     var slcTipoData = $("tipodata");
        if (modelo == 4) {        
            slcTipoData.disabled = false;
            
            $("emissaoEm").style.display = "";
            $("emissaoEm").disabled = false;
            $("baixaEm").style.display = "none";
            $("baixaEm").disabled = true;
            $("chegadaEm").style.display = "";
            $("chegadaEm").disabled = false;
            
            
            
        }else if(modelo == 5 || modelo == 9){
            
            $("emissaoEm").style.display = "";
            $("emissaoEm").disabled = false;
            $("baixaEm").style.display = "";
            $("baixaEm").disabled = false;
            $("chegadaEm").style.display = "none";
            $("chegadaEm").disabled = true;
        }
    }
    function abrirLocalizarCliente(input) {
        if(input != null) {
            jQuery('#localizarCliente').attr('input', input);
            controlador.acao('abrirLocalizar', 'localizarCliente');
        }
    }
    function abrirLocalizarFornecedor(input) {
        if(input != null) {
            jQuery('#localizarRepresentante').attr('input', input);
            controlador.acao('abrirLocalizar', 'localizarRepresentante');
        }
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

        <title>Webtrans - Relatório de CTRCs / Notas de Serviços</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
        <link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
    </head>

    <body onLoad="applyFormatter();modelos('1');consultarTodasAliq();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');alteraCondicaoFilial();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="idredespacho" id="idredespacho" value="0">
            <input type="hidden" name="idredespachante" id="idredespachante" value="0">
            <input type="hidden" name="tipo_produto_id" id="tipo_produto_id" value="0">
            <input type="hidden" name="tipo_produto" id="tipo_produto" value="0">
            <input type="hidden" name="con_rzs" id="con_rzs" value="">
            <input type="hidden" name="idremetente" id="idremetente" value="0">
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
            <input type="hidden" name="idmotorista" id="idmotorista" value="0">
            <input type="hidden" name="idconsig" id="idconsig" value="0">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="0">
            <input type="hidden" name="fi_abreviatura" id="fi_abreviatura" value="0">
            <input type="hidden" name="idfilialemissao" id="idfilialemissao" value="">
            <input type="hidden" name="idfilialentrega" id="idfilialentrega" value="">
            <input type="hidden" name="idFilialUsuario" id="idFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="descFilialUsuario" id="descFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getAbreviatura())%>">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de CTRCs / Notas de Servi&ccedil;os</b></td>
            </tr>
        </table>

        <br>

        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
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
            <form id="formPedidosNota" name="formPedidosNota" method="post">
            <tr class="tabela"> 
                <td colspan="7"><div align="center">Modelos</div></td>
            </tr>
            <tr>
                <td width="13%" class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1 
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o dos CTRCs emitidos 
                    por filial
                </td>
                <td width="13%" height="24" class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos(2);">
                        Modelo 2
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de ICMS por CTRC emitido
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos(3);">
                        Modelo 3
                    </div>
                </td>
                <td class="CelulaZebra2">Faturamento por Filial (CTRCs/Serviços)</td>
                <td class="CelulaZebra2">
                    <input name="mostrarAgencia" type="checkbox" id="mostrarAgencia" >
                    Mostrar agência                    
                    <br>
                    <input name="mostrarGrafico" type="checkbox" id="mostrarGrafico" >
                    Mostrar gráfico              
                </td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos(4);">
                        Modelo 4
                    </div>
                </td>
                <td width="18%" class="CelulaZebra2">CTRCs não manifestados/romaneados </td>
                <td width="19%" class="CelulaZebra2">
                    <input type="radio" name="agrupMod4" id="agrupMod4_1" value="abreviatura" checked>
                    Por filial
                    <br>
                    <input type="radio" name="agrupMod4" id="agrupMod4_6" value="id_filial_entrega">
                    Por filial de entrega
                    <br>
                    <input type="radio" name="agrupMod4" id="agrupMod4_2" value="cidade_destino" >
                    Por cidade
                    <br>
                    <input type="radio" name="agrupMod4" id="agrupMod4_3" value="area_destino" >
                    Por área de destino
                    <br>
                    <input type="radio" name="agrupMod4" id="agrupMod4_4" value="consignatario"/>
                    Por consignatário
                    <br>
                    <input type="radio" name="agrupMod4" id="agrupMod4_5" value="categoria_carga"/>
                    Por categoria de carga
                    <br>
                    <input name="chk_dias_uteis" type="checkbox" id="chk_dias_uteis">
                    Ao contar dias considerar dias úteis
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo5" id="modelo5" value="5" onClick="javascript:modelos(5);">
                        Modelo 5
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Acompanhamento dos CTRCs(Manifesto,Chegada e Entrega)</td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo6" id="modelo6" value="6" onClick="javascript:modelos(6);">
                        Modelo 6
                    </div>
                </td>
                <td class="CelulaZebra2">Análise de CTRC</td>
                <td class="CelulaZebra2"><input type="radio" name="agrupMod6" id="agrupMod6_1" value="abreviatura" checked >Por filial<br/><input type="radio" value="idmovimento" name="agrupMod6" id="agrupMod6_2">Por Manifesto</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo7" id="modelo7" value="7" onClick="javascript:modelos(7);">
                        Modelo 7
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">CTRCs/Servi&ccedil;os em aberto sem faturas geradas(Agrupados por filial) </td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo8" id="modelo8" value="8" onClick="javascript:modelos(8);">
                        Modelo 8
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">CTRCs não entregues(Agrupados por filial destino) </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left"> 
                        <input type="radio" name="modelo9" id="modelo9" value="9" onClick="javascript:modelos(9);">
                        Modelo 9                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de CTRCs por cliente (consignatário)</td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo10" id="modelo10" value="10" onClick="javascript:modelos(10);">
                        Modelo 10                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de ranking de vendas(CTRCs/Serviços) por cliente (consignatário)</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo11" id="modelo11" value="11" onClick="javascript:modelos(11);">
                        Modelo 11                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de faturamento(CTRCs) por tipo de veículo</td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo12" id="modelo12" value="12" onClick="javascript:modelos(12);">
                        Modelo 12                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de faturamento(CTRCs) por trecho</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo13" id="modelo13" value="13" onClick="javascript:modelos(13);">
                        Modelo 13                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de CTRCs por cliente (remetente)</td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo14" id="modelo14" value="14" onClick="javascript:modelos(14);">
                        Modelo 14                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de faturamento(CTRCs) por cidade/UF destino</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo15" id="modelo15" value="15" onClick="javascript:modelos(15);">
                        Modelo 15                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de CTRCs por representante</td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo16" id="modelo16" value="16" onClick="javascript:modelos(16);">
                        Modelo 16                    
                    </div>                
                </td>
                <td class="CelulaZebra2">Relatório de notas fiscais de serviço por filial</td>
                <td class="CelulaZebra2">
                    <input type="radio" name="agrupMod16" id="agrupMod16_1" value="true" checked>
                    Analítico
                    <br>
                    <input type="radio" name="agrupMod16" id="agrupMod16_2" value="false" >
                    Sintético
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo17" id="modelo17" value="17" onClick="javascript:modelos(17);">
                        Modelo 17                    
                    </div>                
                </td>
                <td width="17%" class="CelulaZebra2">Relatório de CTRCs por veículo</td>
                <td width="20%" class="CelulaZebra2">
                    <input name="agrupadoVeiculo" id="agrupadoVeiculo" type="radio" value="radiobutton" onClick="javascript:$('agrupadoCarreta').checked = false;this.checked=true;">
                    Agrupado por ve&iacute;culo
                    <br>
                    <input name="agrupadoCarreta" id="agrupadoCarreta" type="radio" value="radiobutton" checked onClick="javascript:$('agrupadoVeiculo').checked = false;this.checked=true;">
                    Agrupado por carreta                
                </td>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo18" id="modelo18" value="18" onClick="javascript:modelos(18);">
                        Modelo 18                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relat&oacute;rio de CTRCs por cliente (Consignat&aacute;rio) e valor das parcelas</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo19" id="modelo19" value="19" onClick="javascript:modelos(19);">
                        Modelo 19                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de CT(s) emitidos por filial com valor do frete carreteiro</td>
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo20" id="modelo20" value="20" onClick="javascript:modelos(20);">
                        Modelo 20                    
                    </div>                
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de CTRCs por veículo informando valor líquido do frete</td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo21" id="modelo21" value="21" onClick="javascript:modelos(21);">
                        Modelo 21
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Resumo de CTRCs manifestados por ve&iacute;culo </td>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo22" id="modelo22" value="22" onClick="javascript:modelos(22);">
                        Modelo 22
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">Rela&ccedil;&atilde;o dos CTRCs emitidos por ag&ecirc;ncia</td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo23" id="modelo23" value="23" onClick="javascript:modelos(23);">
                        Modelo 23
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o dos CTRCs emitidos por filial com modalidade frete</td>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo24" id="modelo24" value="24" onClick="javascript:modelos(24);">
                        Modelo 24
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">
                    Rela&ccedil;&atilde;o dos CTRCs emitidos 
                    por destinatário
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo25" id="modelo25" value="25" onClick="javascript:modelos(25);">
                        Modelo 25
                    </div>
                </td>
                <td class="CelulaZebra2">Análise de CTRC com valores dos impostos</td>
                <td class="CelulaZebra2">
                    <input name="agrupadoFilial25" id="agrupadoFilial25" type="radio" value="radiobutton" checked onClick="javascript:$('agrupadoVeiculo25').checked = false;this.checked=true;">
                    Agrupado por filial      
                    <br>
                    <input name="agrupadoVeiculo25" id="agrupadoVeiculo25" type="radio" value="radiobutton" onClick="javascript:$('agrupadoFilial25').checked = false;this.checked=true;">
                    Agrupado por ve&iacute;culo
                </td>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo26" id="modelo26" value="26" onClick="javascript:modelos(26);">
                        Modelo 26
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">
                    Rela&ccedil;&atilde;o dos CTRCs emitidos por cidade de destino
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo27" id="modelo27" value="27" onClick="javascript:modelos(27);">
                        Modelo 27
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o dos CTRCs emitidos por cidade de destino</td>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo28" id="modelo28" value="28" onClick="javascript:modelos(28);">
                        Modelo 28                    
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">
                    Relatório de CTRCs por motorista
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo29" id="modelo29" value="29" onClick="javascript:modelos(29);">
                        Modelo 29
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o dos CTRCs emitidos por área de destino</td>
                <td class="textoCampos">
                    <div align="left">
                        <input type="radio" name="modelo30" id="modelo30" value="30" onClick="javascript:modelos(30);">
                        Modelo 30
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">
                    Relat&oacute;rio de CT's com AWB
                </td>
            </tr>
            <tr>    
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo31" id="modelo31" value="31" onclick="javascript:modelos(31);">
                        Modelo 31
                    </div>   
                </td>
                <td colspan="2" class="CelulaZebra2">
                    Relat&oacute;rio de Faturamento Di&aacute;rio por Veiculo
                </td>
                <td class="textoCampos">
                    <div align="left">
                        <input type="radio" name="modelo32" id="modelo32" value="32" onClick="javascript:modelos(32);">
                        Modelo 32
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">
                    Relat&oacute;rio de CT's Agrupados por Local Coleta e Local Entrega
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo33" id="modelo33" value="33" onclick="javascript:modelos(33);">
                        Modelo 33
                    </div>   
                </td>
                <td colspan="2" class="CelulaZebra2">
                    Relat&oacute;rio de Comiss&atilde;o de Motorista Por CT.                   
                </td>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo34" id="modelo34" value="34" onclick="javascript:modelos(34);">
                        Modelo 34
                    </div>   
                </td>
                <td colspan="2" class="CelulaZebra2">
                    Relat&oacute;rio de CT(s) com número do pedido.                   
                </td>
            </tr>
            <tr>    
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo35" id="modelo35" value="35" onclick="javascript:modelos(35);">
                        Modelo 35
                    </div>   
                </td>
                <td colspan="2" class="CelulaZebra2">
                    Relat&oacute;rio de Ct(s) agrupados por número da carga
                </td>
                <td class="textoCampos">
                    <div align="left">
                        <input type="radio" name="modelo36" id="modelo36" value="36" onclick="javascript:modelos(36);">
                        Modelo 36
                    </div>
                </td>
                <td colspan="2"  class="CelulaZebra2">
                    Relação de CTRCs com todas as taxas e generalidades.
                </td>
                
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modeloP" id="modeloP" value="P"  onClick="javascript:modelos('P');">
                        Personalizado
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">
                        <select name="personalizado" id="personalizado" class="inputtexto">
                            <option value="">Escolha o modelo personalizado</option>
                            <%for (String rel : Apoio.listRelatorioCtrc(request)) {%>
                                <option value="relatorio_ctrc_personalizado_<%=rel%>"><%=rel.toUpperCase()%></option>
                            <%}%>
                        </select>
                </td>
                <td class="textoCampos">
                </td>
                <td colspan="2"  class="CelulaZebra2">
                </td>
            </tr>
            <tr id="trPedido" style="display: none">
                <td class="TextoCampos" colspan="2"><div align="center">Número do Pedido da Nota Fiscal (Separado por vírgulas):</div></td>
                <td colspan="4" class="CelulaZebra2">
                    <span class="CelulaZebra2">
                        <strong>
                           
                                <input name="pedidoNota" type="text" id="pedidoNota" size="100"  class="inputtexto">                                
                            
                        </strong>                                
                    </span>               
                </td>
                </tr>
            <tr>
                <td colspan="6">
                    <table width="100%" border="0">
                        <tr>
                            <td colspan="2" class="tabela">
                                <div align="center">Crit&eacute;rio de datas </div>
                            </td>
                            <td colspan="2" class="tabela">
                                <div align="center">Ordena&ccedil;&atilde;o</div>
                            </td>
                        </tr>
                        <tr>
                            <td width="25%" class="TextoCampos">
                                <span class="TextoCampos">
                                    <select name="tipodata" id="tipodata" disabled class="inputtexto">
                                        <option value="emissao_em" id="emissaoEm" style="display: none">Data de Emiss&atilde;o</option>                                    
                                   
                                        <option value="baixa_em" id="baixaEm" style="display: none">Data de Entrega</option>
                                    
                                        <option value="chegada_em" id="chegadaEm" style="display: ">Data de Chegada</option>                                    
                                       
                                    </select>
                                   
                                    entre:                                
                                </span>                            
                            </td>
                            <td width="25%" class="CelulaZebra2">
                                <strong>
                                    <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                                </strong>e
                                <strong>
                                    <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                                </strong>                            
                            </td>
                            <td width="18%" class="TextoCampos">Ordenar por:</td>
                            <td width="32%" class="CelulaZebra2">
                                <select id="ordenacao" name="ordenacao" class="inputtexto">
                                    <option value="dtemissao" selected>Data de emiss&atilde;o</option>
                                    <option value="nfiscal">CTRC / NF Servi&ccedil;o</option>
                                    <option value="numero_carga">Nº da Carga</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" colspan="2">
                                <div align="center" id="divDistribuicao" name="divDistribuicao" style="display:none;">
                                    Em caso de entregas locais, mostrar dados
                                    <select id="slDistribuicao" name="slDistribuicao" class="fieldMin">
                                        <option value="nf">da NFS-e/CT-e de Cobrança</option>
                                        <option value="ct" selected>do CT-e/Minuta de Entrega</option>
                                    </select>
                                </div>
                            </td>
                            <td class="TextoCampos"></td>
                            <td class="TextoCampos"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr class="tabela"> 
                <td height="18" colspan="7"> 
                    <div align="center">Filtros</div>
                </td>
            </tr>
            <tr>
                <td colspan="7">
                    <table width="100%" border="0" >
                        <tr>
                            <td width="9%" class="TextoCampos" rowSpan="3">
                                <label id="lbMotrarCT" name="lbMotrarCT">Mostrar CT-e(s):</label>
                            </td>
                            <td width="8%" class="TextoCampos">
                                Tipo:
                            </td>
                            <td width="83%" class="CelulaZebra2">
                                <input name="ct_normal" type="checkbox" id="ct_normal" checked >Normais
                                <input name="ct_local" type="checkbox" id="ct_local" checked >Distrib. locais
                                <input name="ct_diaria" type="checkbox" id="ct_diaria" checked >Diárias
                                <input name="ct_paletizacao" type="checkbox" id="ct_paletizacao" checked >Pallets
                                <input name="ct_complementar" type="checkbox" id="ct_complementar" checked >Complementares
                                <input name="ct_reentrega" type="checkbox" id="ct_reentrega" checked >Reentregas
                                <input name="ct_devolucao" type="checkbox" id="ct_devolucao" checked >Devolu&ccedil;&otilde;es
                                <input name="ct_cortesia" type="checkbox" id="ct_cortesia" >Cortesias
                                <input name="ct_substituicao" type="checkbox" id="ct_substituicao" checked>Substituições
                                <input name="ct_substituido" type="checkbox" id="ct_substituido" >Substituídos
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                Situação:
                            </td>
                            <td class="CelulaZebra2">
                                <input name="ct_nao_cancelados" type="checkbox" id="ct_nao_cancelados" checked>N&atilde;o Cancelados
                                <input name="ct_cancelados" type="checkbox" id="ct_cancelados" >Cancelados
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                Status SEFAZ:
                            </td>
                            <td class="CelulaZebra2">
                                <input name="ct_confirmados" type="checkbox" id="ct_confirmados" checked><label name="lb_confirmados" id="lb_confirmados">Confirmados</label>
                                <input name="ct_pendentes" type="checkbox" id="ct_pendentes" ><label name="lb_pendentes" id="lb_pendentes">Pendentes</label>
                                <input name="ct_enviados" type="checkbox" id="ct_enviados" ><label name="lb_enviados" id="lb_enviados">Enviados (Aguardando confirmação)</label>
                                <input name="ct_negados" type="checkbox" id="ct_negados" ><label name="lb_negados" id="lb_negados">Negados</label>
                            </td>
                        </tr>
                        <tr id="trChkNfseNormal" name="trChkNfseNormal">
                            <td class="celulaZebra2" >
                            </td>
                            <td class="celulaZebra2" colspan="3">
                                <input type="checkbox" id="chkNfseNormal" name="chkNfseNormal"> Mostrar, também, NFS-e do tipo normal/cortesia.
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr> 
                <td colspan="7">
                    <table width="100%" border="0" >
                        <tr>
                            <td class="TextoCampos" width="10%">
                                <label id="lbCfop" name="lbCfop">Apenas o CFOP:</label>
                                <label id="lbManifestado" name="lbCfop">Apenas CT(s):</label>
                                <label id="lbtype_servico" name="lbtype_servico" style="display:none;">Apenas o Serviço: </label>
                            </td>
                            <td class="CelulaZebra2">
                                <input type="hidden" id="idcfop" name="idcfop"  value="0" />
                                <input class="inputReadOnly" type="text" size="7" id="cfop" name="cfop" readonly  value="" />
                                <input type="button" id="botCfop" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CFOP%>','Cfop')" value="..." />
                                <img src="img/borracha.gif" id="borrachaCfop" border="0" align="absbottom" class="imagemLink" title="Limpar CFOP" onClick="javascript:$('idcfop').value = 0;javascript:$('cfop').value = '';">
                                <select name="manifestado" id="manifestado" class="inputtexto">
                                    <option value="both" selected>Ambos</option>
                                    <option value="true">Manifestados</option>
                                    <option value="false">N&atilde;o Manifestados</option>
                                </select>
                                    <input id="type_service_id" type="hidden" value="0" name="type_service_id" style="">
                                    <input id="type_service_descricao" class="inputReadOnly" type="text" value="" readonly="" name="type_service_descricao" size="15" style="display: none">                                
                                    <input id="localiza_typeservico" class="botoes" type="button" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=36','Servico')" value="..." name="localiza_typeservico3" style="display:none;">
                                    <img src="img/borracha.gif" title="Limpar Serviço" alt="" name="borrachaTypeServico" class="imagemLink" id="borrachaTypeServico" onclick="limparTypeServico()" style="display:none;" />
                            </td>
                            <td class="TextoCampos">Mostrar apenas:</td>
                            <td width="120" class="CelulaZebra2">
                                <select name="finalizado" id="finalizado" disabled class="inputtexto">
                                    <option value="both" selected>Ambos</option>
                                    <option value="true">CT(s) Entregues</option>
                                    <option value="false">CT(s) N&atilde;o entregues</option>
                                </select>
                            </td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos">Apenas a s&eacute;rie:</td>
                            <td width="120" class="CelulaZebra2">
                                <span class="CelulaZebra2">
                                    <strong>
                                        <input name="serie" type="text" id="serie" size="5" maxlength="3" class="inputtexto">
                                    </strong>                                
                                </span>               
                            </td>
                            <td width="100" class="TextoCampos">
                                <select name="apenasFilial" id="apenasFilial" class="inputtexto">
                                    <option value="=" selected>Apenas a Filial de Emissão</option>
                                    <option value="<>">Exceto a Filial de Emissão</option>
                                </select>
                            </td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong> 
                                        <input name="filial_emissora" type="text" id="filial_emissora" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <input name="localiza_filial_emissao" type="button" class="inputBotaoMin" id="localiza_filial_emissao" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Emissao','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img name="btnLimparFilialEmissao" id="btnLimparFilialEmissao" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialemissao').value = 0; $('filial_emissora').value = ''; alteraCondicaoFilial();">
                                    </strong></div></td>
                        </tr>
                        <tr id="trFilialEntrega">
                            <td width="100" Colspan="2" class="TextoCampos"></td><!-- Apenas usado para alinhamento -->
                            <td width="100" class="TextoCampos">
                                <select name="apenasFilialEntrega" id="apenasFilialEntrega" class="inputtexto">
                                    <option value="=" selected>Apenas a Filial de Entrega</option>
                                    <option value="<>">Exceto a Filial de Entrega</option>
                                </select>
                            </td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong> 
                                        <input name="filial_entrega" type="text" id="filial_entrega" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                        <input name="localiza_filial_entrega" type="button" class="inputBotaoMin" id="localiza_filial_entrega" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Entrega','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                        <img name="btnLimparFilialEntrega" id="btnLimparFilialEntrega" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialentrega').value = 0; $('filial_entrega').value = '';">
                                    </strong></div></td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos">
                                <select name="apenasRemetente" id="apenasRemetente" class="inputtexto">
                                    <option value="=" selected>Apenas o Remetente</option>
                                    <option value="<>">Exceto o Remetente</option>
                                </select>                            
                            </td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="remet" type="text" id="remet" class="inputReadOnly8pt" size="28" maxlength="80" readonly="true">
                                    <input name="localiza_clifor" type="button" class="botoes" id="localiza_rem" value="..." onClick="abrirLocalizarCliente('remet');">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="removerValorInput('remet');">
                                </strong>                            
                            </td>
                            <td class="TextoCampos">
                                <select name="apenasDestinatario" id="apenasDestinatario" class="inputtexto">
                                    <option value="=" selected>Apenas o Destinatário</option>
                                    <option value="<>">Exceto o Destinatário</option>
                                </select>
                            </td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="dest" type="text" id="dest" class="inputReadOnly8pt" size="28" maxlength="80" readonly="true">
                                    <input name="localiza_clifor2" type="button" class="botoes" id="localiza_clifor" value="..." onClick="abrirLocalizarCliente('dest');">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Destinat&aacute;rio" onClick="removerValorInput('dest');">
                                </strong>                            
                            </td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos">
                                <select name="apenasConsignatario" id="apenasConsignatario" class="inputtexto">
                                    <option value="=" selected>Apenas o Consign.</option>
                                    <option value="<>">Exceto o Consign.</option>
                                </select>                            
                            </td>
                            <td class="CelulaZebra2">
                                <span class="CelulaZebra2">
                                    <strong>
                                        <input name="consig" type="text" id="consig" class="inputReadOnly8pt" size="28" maxlength="80" readonly="true">
                                        <input name="localiza_clifor3" type="button" class="botoes" id="localiza_clifor2" value="..." onClick="abrirLocalizarCliente('consig');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Consignat&aacute;rio" onClick="removerValorInput('consig');">
                                    </strong>                                
                                </span>                            
                            </td>
                            <td class="TextoCampos">Motorista:</td>
                            <td class="CelulaZebra2">
                                <input name="motor_nome" type="text"  class="inputReadOnly8pt" id="motor_nome" size="28" value="" readonly="true">
                                <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                                <strong>
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">                                
                                </strong>                            
                            </td>
                        </tr>
                        <tr id="trRedes">
                            <td class="TextoCampos" >
                                <select name="apenasRedespacho" id="apenasRedespacho" class="inputtexto">
                                    <option value="=" selected>Apenas o Redespacho</option>
                                    <option value="&lt;&gt;">Exceto o Redespacho</option>
                                </select>                            
                            </td>
                            <td class="CelulaZebra2" >
                                <strong>
                                    <input name="red_rzs" type="text" id="red_rzs" size="28" class="inputReadOnly8pt"  value="" readonly  onFocus="this.select();">
                                    <input name="localiza_red" type="button" class="botoes" id="localiza_red" value="..." onClick="abrirLocalizarCliente('red_rzs');">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Redespacho" onClick="removerValorInput('red_rzs');">
                                </strong>
                            </td>

<!--                            <td class="TextoCampos">Representante:</td>
                            <td class="TextoCampos">
                                <div align="left">
                                    <strong>
                                        <input name="redspt_rzs" type="text" id="redspt_rzs" size="28" class="inputReadOnly8pt"  value="" readonly onKeyUp="javascript:if (event.keyCode==13) localizaRedespachoCodigo('c.razaosocial', this.value)" onFocus="this.select();">
                                        <input name="localiza_redspt" type="button" class="botoes" id="localiza_redspt" value="..." onClick="javascript:localizaRedespachante();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Redespachante" onClick="javascript:$('idredespachante').value = 0;javascript:$('redspt_rzs').value = '';">
                                    </strong>
                                </div>
                            </td>-->

                            <td class="TextoCampos" >
                                <select name="apenasRedespachante" id="apenasRedespachante" class="inputtexto">
                                    <option value="=" selected>Apenas o Representante</option>
                                    <option value="<>">Exceto o Representante</option>
                                </select>                            
                            </td>
                            <td class="CelulaZebra2" >
                                <strong>
                                    <input name="redspt_rzs" type="text" id="redspt_rzs" size="28" class="inputReadOnly8pt"  value="" readonly  onFocus="this.select();">
                                    <input name="localiza_redspt" type="button" class="botoes" id="localiza_redspt" value="..." onClick="abrirLocalizarFornecedor('redspt_rzs');">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Redespachante" onClick="removerValorInput('redspt_rzs');">
                                </strong>
                            </td>

                        </tr>
                        <tr id="trTipoTrans">
                            <td class="TextoCampos">Tipo de Transporte:</td>
                            <td  class="CelulaZebra2"><div align="left">
                                    <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:'160px';"   class="fieldMin">
                                        <%= emiteRodoviario && emiteAereo && emiteAquaviario ? "<option value='false' >Todos</option>" : ""%>
                                        <%= emiteRodoviario ? "<option value='r' >CTR - Transp. Rodoviário</option>" : ""%>
                                        <%= emiteAereo ? "<option value='a' >CTA - Transp. A&eacute;reo</option>" : ""%>
                                        <%= emiteAquaviario ? "<option value='q' >CTQ - Transp. Aquavi&aacute;rio</option>" : ""%>
                                    </select>
                                </div>
                            </td>
                            <td class="TextoCampos">
                                <label id="lbArea" name="lbArea" style="display:none;">Apenas a área:</label>
                                <label id="lbManifesto" name="lbManifesto" style="display:none;">Apenas o manifesto:</label>
                                <label id="lbManifesto2" name="lbManifesto2" style="display:none;">Número e Série do Manifesto:</label>
                            </td>
                            <td class="CelulaZebra2">
                                <input name="area" type="text" id="area" class="inputReadOnly" value="" size="25" maxlength="80" readonly="true" style="display:none;">
                                <input name="localizaArea" id="localizaArea" type="button" class="botoes" value="..." style="display:none;" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34', 'Area')">
                                <img src="img/borracha.gif" id="limpaArea" border="0" align="absbottom" class="imagemLink" style="display:none;" title="Limpar àrea" onClick="javascript:$('area_id').value = '0';javascript:$('area').value = '';">
                                <input type="hidden" name="area_id" id="area_id" value="0">
                                <input name="numeroManifesto" type="text" id="numeroManifesto" size="7" style="display:none;" class="inputtexto">
                                <input name="serieManifesto" type="text" id="serieManifesto" size="3" style="display:none;" class="inputtexto">
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                <label id="veiculo" name="veiculo">Apenas o ve&iacute;culo: </label><br />
                                <label id="lbctrc" name="lbctrc" style="display:none;">CTRCs entre: </label><br>
                                <label id="lbAgencia" name="lbAgencia" style="display:none;">Apenas a Agência: </label>                            </td>
                            <td class="CelulaZebra2">
                                <div>
                                    <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" value="" size="15" maxlength="10" readonly>
                                    <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..." onClick="controlador.acao('abrirLocalizar','localizarVeiculoGeral');">
                                    <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink" id="limpavei" title="Limpar Veículo" onClick="removerValorInput('vei_placa')">
                                </div>
                                <div>
                                    <input name="ctrc1" type="text" id="ctrc1" size="7" style="display:none;" class="inputtexto">
                                    <input name="ctrc2" type="text" id="ctrc2" size="7" style="display:none;" class="inputtexto">
                                </div>
                                <select name="agenciaId" id="agenciaId" style="display:none;font-size:8pt;" class="fieldMin">
                                    <%
                                        BeanConsultaAgencia ag = new BeanConsultaAgencia();
                                        ag.setConexao(Apoio.getUsuario(request).getConexao());
                                        ag.MostrarAgencias(temacessofiliais ? "" : "" + Apoio.getUsuario(request).getFilial().getIdfilial());

                                        if (temacessofiliais) {%>
                                    <option value="0">TODAS AS AGÊNCIAS</option>
                                    <%}
                                        while (ag.getResultado().next()) {%>
                                    <option value="<%=ag.getResultado().getString("id")%>" ><%=ag.getResultado().getString("abreviatura")%></option>
                                    <%}%>
                                </select>

                                              
                            </td>

                            <td class="TextoCampos">

                                <label name="lbcidade_destino" id="lbcidade_destino" style="display:none;">Apenas o destino:</label>
                                <select name="apenasDestino" id="apenasDestino" style="display:none;" class="inputtexto">
                                    <option value="=" selected>Apenas o Destino</option>
                                    <option value="&lt;&gt;">Exceto o Destino</option>
                                </select>
            
                                <select name="apenasTipoVeiculo" id="apenasTipoVeiculo" style="display:none;" class="inputtexto">
                                    <option value="=" selected>Apenas os ve&iacute;culos</option>
                                    <option value="&lt;&gt;">Exceto os ve&iacute;culos</option>
                                </select>      
                                <div id="apenasVeiculos">
                                    Apenas o Tipo de Veiculo
                                </div>
                            </td>
                            <td class="CelulaZebra2">
                                <div id="divSeguroProprio">
                                    <input name="seguroProprio" type="checkbox" id="seguroProprio" >
                                    Mostrar CTRCS com seguro pr&oacute;prio.
                                </div>
                                <strong>
                                    <input name="cid_destino" type="text" class="inputReadOnly8pt" id="cid_destino"  value="" size="20" readonly="true">
                                    <input name="uf_destino" type="text" id="uf_destino"  class="inputReadOnly8pt" size="2" readonly="true">
                                    <strong>
                                        <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();" style="display:none;">
                                        <strong>
                                            <img src="img/borracha.gif" name="apaga_cid_destino" border="0" align="absbottom" class="imagemLink" id="apaga_cid_destino" title="Limpar Cidade de Destino" onClick="javascript:getObj('idcidadedestino').value = 0;javascript:getObj('cid_destino').value = '';getObj('uf_destino').value = '';" style="display:none;">                                        
                                        </strong>                                    
                                    </strong>                                
                                </strong>
                                <div id="tipofrota" style="font-size:8pt;display:none;">
                                <!--<select name="tipofrota" id="tipofrota" style="font-size:8pt;display:none;">
                                    <option value="td" selected>Todos</option>
                                    <option value="ag">Agregados</option>
                                    <option value="pr">Da frota pr&oacute;pria</option>
                                    <option value="ca">De Carreteiros</option>
                                </select>       
                                <br>
                                comentado para caso precise...-->
                                <label ><input type="checkbox" name="is_Agregado" id="is_Agregado"> Agregados<br></label>
                                <label><input type="checkbox" name="is_FrotaP" id="is_FrotaP"> Da frota pr&oacute;pria<br></label>
                                <label><input type="checkbox" name="is_Carreteiros" id="is_Carreteiros"> De Carreteiros<br></label>
                                
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                <select name="apenasUF" id="apenasUF" style="display:none; " class="inputtexto">
                                    <option value="IN" selected>Apenas as UFs destino</option>
                                    <option value="NOT IN">Exceto as UFs destino</option>
                                </select>                            
                            </td>
                            <td class="CelulaZebra2">
                                <input name="uf" type="text" id="uf" size="9" maxlength="60" onChange="javascript:$('uf').value = $('uf').value.toUpperCase();" style="display:none; " class="inputtexto">
                                <label id="descUF" name="descUF" style="display:none; " >Separe as UFs com v&iacute;rgulas </label>
                            </td>
                            <td class="TextoCampos">
                                <label id="lbModalidade" name="lbModalidade" style="display:none;">Apenas a modalidade:</label>                            
                                <label id="lbnumerocarga" name="lbnumerocarga" style="display:none;">Apenas o nº de carga: </label>
                            </td>
                            <td class="CelulaZebra2">
                                <input name="numerocarga" type="text" id="numerocarga" size="7" style="display:none;" class="inputtexto"><br>
                                <select name="apenasModalidade" id="apenasModalidade" style="display:none;" class="inputtexto">
                                    <option value="a" selected>Ambas</option>
                                    <option value="v">Apenas fretes &agrave; vista</option>
                                    <option value="p">Apenas fretes &agrave; prazo</option>
                                </select>                            
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                <label id="lbDescontoIcms" name="lbDescontoIcms" style="display:none;">
                                    % desconto de ICMS:                            
                                </label>                            
                            </td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="descontoIcms" type="text" value="0.00" id="descontoIcms" size="8" maxlength="6" onChange="seNaoFloatReset(this,'0.00');" style="display:none;" class="inputtexto">
                                </strong>                            
                            </td>
                            <td class="TextoCampos">                                
                                <!--<div id="blTipoProduto" style="display:none">Apenas o tipo de produto:</div>-->                       
                                <div id="divLbApenasAliqFrete" style="display: none">
                                    Apenas a Aliquota:                                    
                                </div>
                            </td>
                            <td class="CelulaZebra2">
                            <!--<span class="CelulaZebra2">
                                    <div id="tipoProduto" style="display:none">
                                        <input name="tipo_produto" type="text" class="inputReadOnly8pt" id="tipo_produto" size="28" value="" readonly="true">
                                        <input name="button2" type="button" class="botoes" onClick="javascript:localizatipoproduto();" value="...">
                                        <strong> 
                                            <img src="img/borracha.gif" alt="" border="0" align="absbottom" class="imagemLink" title="Limpar tipo produto" onClick="javascript:getObj('tipo_produto_id').value = 0;javascript:getObj('tipo_produto').value = '';">
                                        </strong> 
                                    </div>
                                </span>-->
                            <div id="divInpApenasAliqFrete" style="display: none">
                                <input type="text" id="apenasAliqFrete" name="apenasAliqFrete" onChange="seNaoFloatReset(this,'0.00');" value="0.00" size="8" maxlength="10" class="inputtexto" />                                
                                <label class="TextoCampos">
                                    <input type="checkbox" id="chkAliqFrete" name="chkAliqFrete" value="true" onclick="javascript:consultarTodasAliq()" checked/>
                                    Todas as alíquotas
                                </label>
                            </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><label id="lbTipoFrete">Apenas Fretes:</label></td>
                            <td class="CelulaZebra2">
                                <select class="inputtexto" id="tipoFrete" name="tipoFrete">
                                    <option value="">Ambos</option>
                                    <option value="'CIF'">CIF</option>
                                    <option value="'FOB'">FOB</option>
                                    <option value="'CON'">CON</option>
                                    <option value="'RED'">RED</option>
                                </select>
                            </td>
                            <td class="TextoCampos">
                                <label class="TextoCampos" id="lbtipo" name="lbtipo">Apenas o Tipo de Veículos:</label>
                            </td> 
                            <td class="CelulaZebra2">
                                
                                <select name="tipveiculo" id="tipveiculo" style="font-size:8pt;" class="inputtexto">
                                    <option value="0" style="background-color:#FFFFFF" selected>Todos</option>
                                    <%ConsultaTipo_veiculos tipo = new ConsultaTipo_veiculos();
                                        tipo.setConexao(Apoio.getUsuario(request).getConexao());
                                        //alteracao referente a historia 3231
                                        tipo.mostraTipos(false, Apoio.parseInt("0"));
                                        ResultSet rs = tipo.getResultado();
                                        while (rs.next()) {%>
                                       <option value="<%=rs.getString("id")%>" style="background-color:#FFFFFF"><%=rs.getString("descricao")%></option>
                                    <%}%>
                               </select> 
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr> 
                <td colspan="13"> 
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tr class="cellNotes"> 
                            <td width="24%" class="CelulaZebra2">
                                <div align="center">
                                    <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">                                
                                </div>                            
                            </td>
                            <td width="76%" class="CelulaZebra2" >
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
            
             <tr>
                <td class="TextoCampos">
                    <div align="center">
                        <select name="excetoProduto" id="excetoProduto" class="inputtexto">
                            <option value="IN" selected>Apenas os tipos de produtos</option>
                            <option value="NOT IN">Exceto os tipos de produtos</option>
                        </select>
                    </div>
                </td>
               
                <td class="CelulaZebra2" colspan="5">
                    <div>
                        <input name="prod_tipo" type="text" id="prod_tipo" class="inputReadOnly8pt" value="" size="50" maxlength="10" readonly>
                        <input name="localiza_prod" type="button" class="botoes" id="localiza_prod" value="..." onClick="controlador.acao('abrirLocalizar','localizarTipoProduto');">
                        <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink" id="limpavei" title="Limpar Veículo" onClick="removerValorInput('prod_tipo')">
                    </div>
                </td>
            </tr>
            
            <tr>
                <td colspan="13" class="tabela">
                    <div align="center">Formato do relat&oacute;rio </div>
                </td>
            </tr>
            <tr>
                <td colspan="13" class="TextoCampos">
                    <div align="center">
                        <input type="radio" name="impressao" id="pdf" value="1" checked/>
                        <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                        <input type="radio" name="impressao" id="excel" value="2" />
                        <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                        <input type="radio" name="impressao" id="word" value="3" />
                        <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                    </div>
                </td>
            </tr>
            <tr> 
                <td colspan="7" class="TextoCampos"> 
                    <div align="center"> 
                        <%if (temacesso) {%>
                        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                        <%}%>
                    </div>
                </td>
            </tr>
            </form>
        </table>
    </div>
        <div id="tabDinamico">
            
          
        </div>
        <div class="localiza">
            <iframe id="localizarCliente" input="remet" name="localizarCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarRepresentante" input="redspt_rzs" name="localizarRedespachante" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarRepresentante" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarVeiculoGeral" input="vei_placa" name="localizarVeiculoGeral" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarVeiculoGeral" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarTipoProduto" input="prod_tipo" name="localizarTipoProduto" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarTipoProduto" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="cobre-tudo"></div>
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
        jQuery('#vei_placa').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#prod_tipo').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#remet').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#dest').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#consig').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#red_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        jQuery('#redspt_rzs').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
    });

</script>