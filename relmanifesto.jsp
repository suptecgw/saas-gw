<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="tipo_veiculos.ConsultaTipo_veiculos"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.BeanLocaliza,
         nucleo.Apoio" errorPage="" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.stream.Collectors" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("relmanifesto") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
    boolean temacessofiliaisFranquia = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("verctefiliais") > 0);
    BeanConfiguracao cfg = new BeanConfiguracao(); cfg.setConexao(Apoio.getUsuario(request).getConexao()); cfg.CarregaConfig();
    boolean modeloFilialFranquia = (Apoio.getUsuario(request) != null
            && cfg.getMatrizFilialFranquia().equals("f"));
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String idVeiculo = request.getParameter("idveiculo");
        String isChegada = request.getParameter("isChegada");
        String idSeguradora = request.getParameter("seguradora_id");
        String idFilial = request.getParameter("idfilial");
        String idFilial2 = request.getParameter("idfilial2");
        String opcoes = "";
        String modelo = request.getParameter("modelo");
        String sqlUFDestino = "";
        String apenasCliente = "";
        String sqlCiaAerea = "";
        String manifesto = request.getParameter("nummanifesto");
        String tipoFrota = request.getParameter("tipofrota");
        String tipoVeiculo = (request.getParameter("tipveiculo").equals("0") ? "" : request.getParameter("tipveiculo"));
        String paramTipoVeiculo = "";
           String agregado =(   request.getParameter("is_Agregado").equals("true")?"ag":"");
             String frotaP =(     request.getParameter("is_FrotaP").equals("true")?"fp":"");
        String carreteiro = (request.getParameter("is_Carreteiros").equals("true")?"ca":"");
        String sqlAeroportoOrigem = "";
        String sqlAeroportoDestino = "";

        String tiposFrota = "";
        tiposFrota = (request.getParameter("is_Agregado").equals("true")? "'ag'" : "");
        tiposFrota += (request.getParameter("is_FrotaP").equals("true")? (tiposFrota.equals("")? "'pr'" : ",'pr'"):"");
        tiposFrota += (request.getParameter("is_Carreteiros").equals("true")? (tiposFrota.equals("")? "'ca'" : ",'ca'"):"");
        String tiposFrotaDesmarcados = "";
        tiposFrotaDesmarcados = (request.getParameter("is_Agregado").equals("false")? "'ag'" : "");
        tiposFrotaDesmarcados += (request.getParameter("is_FrotaP").equals("false")? (tiposFrotaDesmarcados.equals("")? "'pr'" : ",'pr'"):"");
        tiposFrotaDesmarcados += (request.getParameter("is_Carreteiros").equals("false")? (tiposFrotaDesmarcados.equals("")? "'ca'" : ",'ca'"):"");
        
        opcoes = (request.getParameter("tipodata").equals("dtsaida") ? "Emitidos entre:" : "Chegada prevista entre:")
                + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal");
        opcoes += (idFilial.equals("0") ? "" : ",Apenas a filial de origem:" + request.getParameter("fi_abreviatura"));
        opcoes += (idFilial2.equals("0") ? "" : ",Apenas a filial de destino:" + request.getParameter("fi_abreviatura2"));
        opcoes += (idSeguradora.equals("0") ? ",Todas seguradoras" : ",Apenas a seguradora:" + request.getParameter("nome_seguradora"));
        opcoes += (request.getParameter("idcidadedestino").equals("0") ? ",Todas as cidades de destino" : ",Apenas o destino:" + request.getParameter("cid_destino") + "-" + request.getParameter("uf_destino"));
        opcoes += (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : ",Apenas a UF:" + request.getParameter("apenas_uf_destino"));
        opcoes += (modelo.equals("7") && !request.getParameter("tipoFrete").equals("") ? ",Apenas os fretes " + request.getParameter("tipoFrete") : "");
        opcoes += (request.getParameter("idconsignatario").equals("0") ? "" : ",Apenas o cliente:" + request.getParameter("cid_destino") + "-" + request.getParameter("con_rzs"));

        java.util.Map param = new java.util.HashMap(21);
        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        param.put("VEICULO", idVeiculo.equals("0") ? "" : " and m.idcavalo =" + idVeiculo);
        param.put("TIPO_GRUPO", request.getParameter("agrupamento"));
        param.put("TIPO_DATA", request.getParameter("tipodata"));
        param.put("CIDADE_DESTINO", (request.getParameter("idcidadedestino").equals("0") ? "" : " AND idcidadedestino = " + request.getParameter("idcidadedestino")));
        param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND idmotorista= " + request.getParameter("idmotorista"));
        param.put("MANIFESTO", (manifesto.equals("") ? "" : "and nmanifesto = '" + manifesto + "'"));
        
        sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
        String sqlComChegada = "";
        String sqlTipoCargaCte = "";
        String tipoCargaCte = request.getParameter("tipoModalCte");
        if (modelo.equals("1")) {
            param.put("CLIENTE", (request.getParameter("idconsignatario").equals("0") ? "" : " AND vrelmanifesto.idmanifesto IN (select idmanifesto from manifesto_conhecimento mc4 join sales sl4 ON mc4.idconhecimento = sl4.id WHERE sl4.consignatario_id = " + request.getParameter("idconsignatario") + ") "));
            param.put("FILIAL", (!idFilial.equals("0") ? " and idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
        }else if (modelo.equals("2")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            opcoes += (isChegada.equals("") ? "" : (isChegada.equals("true") ? ",Com data de chegada" : ",Sem data de chegada"));
            param.put("FILIAL", (!idFilial.equals("0") ? " and idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = (" + Apoio.SqlFix(request.getParameter("apenas_uf_destino").toUpperCase()) + ") ");
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and chegada_em is not null " : " and chegada_em is null "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("3")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            opcoes += (request.getParameter("agrupamento").equals("dtsaida") ? ",Agrupado por data de saída" : ",Agrupado por motorista");
            param.put("FILIAL", (!idFilial.equals("0") ? " and idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            param.put("TIPO_FROTA", (" AND tipo_frota in (" + (tiposFrota.equals("")? "''" : tiposFrota) +") and tipo_frota not in ("+ (tiposFrotaDesmarcados.equals("")?"''":tiposFrotaDesmarcados) +") "));
            param.put("CLIENTE", (request.getParameter("idconsignatario").equals("0") ? "" : " AND m.idmanifesto IN (select idmanifesto from manifesto_conhecimento mc4 join sales sl4 ON mc4.idconhecimento = sl4.id WHERE sl4.consignatario_id = " + request.getParameter("idconsignatario") + ") "));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and chegada_em is not null " : " and chegada_em is null "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("4")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND mot.idmotorista= " + request.getParameter("idmotorista"));
            opcoes += (idVeiculo.equals("0") ? "" : ",Apenas o veículo:" + request.getParameter("vei_placa"));
            param.put("FILIAL", (!idFilial.equals("0") ? " and m.idfilial=" + idFilial : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND m.seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND des.uf = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            param.put("TIPO_FROTA", (" AND vei.tipofrota in (" + (tiposFrota.equals("")? "''" : tiposFrota) +") and vei.tipofrota not in ("+ (tiposFrotaDesmarcados.equals("")?"''":tiposFrotaDesmarcados) +") "));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("5")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("FILIAL", (!idFilial.equals("0") ? " and id_filial_origem=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and id_filial_destino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("6")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND mo.idmotorista= " + request.getParameter("idmotorista"));
            param.put("FILIAL", (!idFilial.equals("0") ? " and idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND des.uf = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("7")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("FILIAL", (!idFilial.equals("0") ? " and id_filial_origem=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and id_filial_destino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("8")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND d.idmotorista= " + request.getParameter("idmotorista"));
            param.put("FILIAL", (!idFilial.equals("0") ? " and id_filial_origem=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and id_filial_destino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            param.put("CLIENTE", (request.getParameter("idconsignatario").equals("0") ? "" : " and consignatario_id = " + request.getParameter("idconsignatario")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("9")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("FILIAL", (!idFilial.equals("0") ? " and idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and chegada_em is not null " : " and chegada_em is null "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("10")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("FILIAL", (!idFilial.equals("0") ? " and id_filial_origem=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and id_filial_destino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            param.put("MANIFESTO", (manifesto.equals("") ? "" : "and nmanifesto = '" + manifesto + "'"));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        }else if(modelo.equals("11")){
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and cavalo.tipo_veiculo_id = " + tipoVeiculo);
            param.put("FILIAL", (!idFilial.equals("0") ? " and ma.idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and fl2.idfilial=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND ma.seguradora_id = " + idSeguradora));
            param.put("MANIFESTO", (manifesto.equals("") ? "" : "and nmanifesto = '" + manifesto + "'"));
            param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND moto.idmotorista= " + request.getParameter("idmotorista"));
            param.put("CIDADE_DESTINO", (request.getParameter("idcidadedestino").equals("0") ? "" : " AND des.idcidade = " + request.getParameter("idcidadedestino")));
             String sqlChegadaEm = "(select chegada_em from ctrcs co2 join manifesto_conhecimento maco2 "
                     + "on (co2.sale_id = maco2.idconhecimento) where maco2.idmanifesto = ma.idmanifesto order by chegada_em limit 1)";
            param.put("IS_CHEGADA", (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and " + sqlChegadaEm + " is not null " : " and "+  sqlChegadaEm +" is null ")));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND des.uf = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and ma.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = ma.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and ma.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = ma.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and ma.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = ma.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("12")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND d.idmotorista= " + request.getParameter("idmotorista"));
            param.put("FILIAL", (!idFilial.equals("0") ? " and id_filial_origem=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and id_filial_destino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            param.put("CLIENTE", (request.getParameter("idconsignatario").equals("0") ? "" : " and consignatario_id = " + request.getParameter("idconsignatario")));
            param.put("CIA_AEREA", (request.getParameter("idcompanhia").equals("0") ? "" : " and id_cia_aerea = " + request.getParameter("idcompanhia")));
            sqlAeroportoOrigem = (request.getParameter("aeroportoColetaId").equals("0") ? "" : " AND id_aeroporto_origem= " + request.getParameter("aeroportoColetaId"));
            opcoes += (request.getParameter("aeroportoColetaId").equals("0") ? "" : ",Apenas o aeroporto origem:" + request.getParameter("aeroportoColeta"));
            sqlAeroportoDestino = (request.getParameter("aeroportoEntregaId").equals("0") ? "" : " AND id_aeroporto_destino= " + request.getParameter("aeroportoEntregaId"));
            opcoes += (request.getParameter("aeroportoEntregaId").equals("0") ? "" : ",Apenas o aeroporto destino:" + request.getParameter("aeroportoEntrega"));
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is not null LIMIT 1) " : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.chegada_em is null LIMIT 1) "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and d.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = d.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else if (modelo.equals("13")) {
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            opcoes += (request.getParameter("agrupamento").equals("dtsaida") ? ",Agrupado por data de saída" : ",Agrupado por motorista");
            param.put("FILIAL", (!idFilial.equals("0") ? " and m.idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND m.seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND cid.uf = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
            param.put("TIPO_FROTA", (" AND tipo_frota in (" + (tiposFrota.equals("")? "''" : tiposFrota) +") and tipo_frota not in ("+ (tiposFrotaDesmarcados.equals("")?"''":tiposFrotaDesmarcados) +") "));
            param.put("CLIENTE", (request.getParameter("idconsignatario").equals("0") ? "" : " AND m.idmanifesto IN (select idmanifesto from manifesto_conhecimento mc4 join sales sl4 ON mc4.idconhecimento = sl4.id WHERE sl4.consignatario_id = " + request.getParameter("idconsignatario") + ") "));
            param.put("ID_MOTORISTA", request.getParameter("idmotorista").equals("0") ? "" : "AND m.idmotorista= " + request.getParameter("idmotorista"));
            
            boolean tipoCif = (request.getParameter("apenasTiposFreteC") != null ? Apoio.parseBoolean(request.getParameter("apenasTiposFreteC")) : false);
            boolean tipoFob = (request.getParameter("apenasTiposFreteF") != null ? Apoio.parseBoolean(request.getParameter("apenasTiposFreteF")) : false);
            boolean tipoTer = (request.getParameter("apenasTiposFreteT") != null ? Apoio.parseBoolean(request.getParameter("apenasTiposFreteT")) : false);
            String tiposFrete = " and tipo_frete in (''" + (tipoCif ? ",'CIF'": "") + (tipoFob ? ",'FOB'" : "") + (tipoTer ? ",'CON', 'RED'" : "") + ") ";
            param.put("TIPOS_FRETE", tiposFrete);
            sqlComChegada = (isChegada.equals("") ? "" : (isChegada.equals("true") ? " and mc.chegada_em is not null " : " and mc.chegada_em is null "));
            sqlTipoCargaCte = (tipoCargaCte.equals("") ? "" : " and m.idmanifesto IN (SELECT mc2.idmanifesto FROM manifesto_conhecimento mc2 JOIN ctrcs ct2 ON (mc2.idconhecimento = ct2.sale_id) WHERE mc2.idmanifesto = m.idmanifesto AND ct2.modal_rodoviario_cte = '"+tipoCargaCte+"' LIMIT 1) ");
        } else {//não há if para os modelo 1 e 9, então eles entram nesse else.
            paramTipoVeiculo = (tipoVeiculo.equals("") ? "" : " and tipo_veiculo_id = " + tipoVeiculo);
            param.put("FILIAL", (!idFilial.equals("0") ? " and idfilial=" + idFilial : ""));
            param.put("FILIAL_DESTINO", (!idFilial2.equals("0") ? " and idfilialdestino=" + idFilial2 : ""));
            param.put("SEGURADORA", (idSeguradora.equals("0") ? "" : " AND seguradora_id = " + idSeguradora));
            sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino = " + Apoio.SqlFix(request.getParameter("apenas_uf_destino")));
        }

        //nmanifesto
        param.put("TIPO_FRETE", (request.getParameter("tipoFrete").equals("") ? "" : " AND tipo_frete = " + Apoio.SqlFix(request.getParameter("tipoFrete"))));
        param.put("UF_DESTINO", sqlUFDestino);
        param.put("AEROPORTO_ORIGEM", sqlAeroportoOrigem);
        param.put("AEROPORTO_DESTINO", sqlAeroportoDestino);
        param.put("IS_CHEGADA", sqlComChegada);
        param.put("TIPO_CARGA_CTE", sqlTipoCargaCte);

        param.put("OPCOES", opcoes);
        param.put("TIPOVEICULO", paramTipoVeiculo);
                
        if (modelo.startsWith("personalizado_")) {//Verificando se o nome começa por "personalizado_".
            request.setAttribute("rel", modelo);
        }
        
        //INICIO DA NOVA FORMA DE SETARMOS OS PARAMETROS
        param.put("IS_MOSTRA_CTRC", Apoio.parseBoolean(request.getParameter("is_mostra_ctrc")));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        //FIM DA NOVA FORMA DE SETARMOS OS PARAMETROS
        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        // Tipo de manifestos
        List<String> tiposModalManifesto = new ArrayList<>();
        
        if (Apoio.parseBoolean(request.getParameter("tipoManifestoRodoviario"))) {
            tiposModalManifesto.add("m");
        }

        if (Apoio.parseBoolean(request.getParameter("tipoManifestoAereo"))) {
            tiposModalManifesto.add("a");
        }

        if (Apoio.parseBoolean(request.getParameter("tipoManifestoAquaviario"))) {
            tiposModalManifesto.add("f");
        }
        
        switch (request.getParameter("modelo")) {
            case "4":
            case "6":
            case "13":
                param.put("FILTRO_TIPOS_MODAL_MANIFESTO", " AND m.tipo IN (".concat(tiposModalManifesto.stream().collect(Collectors.joining("','", "'", "'"))).concat(")"));
                break;
            case "11":
                param.put("FILTRO_TIPOS_MODAL_MANIFESTO", " AND ma.tipo IN (".concat(tiposModalManifesto.stream().collect(Collectors.joining("','", "'", "'"))).concat(")"));
                break;
            default:
                param.put("FILTRO_TIPOS_MODAL_MANIFESTO", " AND letra_modal_manifesto IN (".concat(tiposModalManifesto.stream().collect(Collectors.joining("','", "'", "'"))).concat(")"));
                break;
        }
        tiposModalManifesto.clear();
        request.setAttribute("map", param);
        request.setAttribute("rel", "relmanifestomod" + request.getParameter("modelo"));
        
        dispacher.forward(request, response);
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_MANIFESTO_RELATORIO.ordinal());
    }
%>

<script language="javascript" type="text/javascript">

    function modelos(modelo){
        getObj("modelo1").checked = false;
        getObj("modelo2").checked = false;
        getObj("modelo3").checked = false;
        getObj("modelo4").checked = false;
        getObj("modelo5").checked = false;
        getObj("modelo6").checked = false;
        getObj("modelo7").checked = false;
        getObj("modelo8").checked = false;
        getObj("modelo9").checked = false;
        getObj("modelo10").checked = false;
        getObj("modelo11").checked = false;
        getObj("modelo12").checked = false;
        getObj("modelo13").checked = false;
        getObj("modelo14").checked = false;

        getObj("modelo"+modelo).checked = true;

        $("filialDestinoTR").style.display = "";
        $("trVeiculo").style.display = "none";
        $("trTipoVeiculo").style.display = "none";
        $("trIsChegada").style.display = "none";
        $("trSeguradora").style.display = "";
        $("trTipoFrete").style.display = "none";
        $("trCliente").style.display = "none";
        $("trNumManifesto").style.display = "none";
        $("trCiaAerea").style.display = "none";
        $("trAeroportoOri").style.display = "none";
        $("trAeroportoDes").style.display = "none";
        $("TRApenasTiposFrete").style.display = "none";
        $("trTipoManifesto").style.display = "none";

        if (modelo == "1"){
            $("trCliente").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "2"){
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "3"){
            $("trIsChegada").style.display = "";
            $("trVeiculo").style.display = "";
            $("trTipoVeiculo").style.display = "";
            $("trCliente").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "4"){
            $("filialDestinoTR").style.display = "";
            $("trVeiculo").style.display = "";
            $("trTipoVeiculo").style.display = "";
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "5"){
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "6"){
            $("trSeguradora").style.display = "none";
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "7"){
            $("trTipoFrete").style.display = "";
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "8"){
            $("trCliente").style.display = "";
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "9"){
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "10"){
            $("trNumManifesto").style.display = "";
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "11"){
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "12"){
            $("trCliente").style.display = "";
            $("trCiaAerea").style.display = "";
            $("trAeroportoOri").style.display = "";
            $("trAeroportoDes").style.display = "";
            $("trIsChegada").style.display = "";
            $("trTipoManifesto").style.display = "none";
        }
        if (modelo == "13"){
            $("trIsChegada").style.display = "";
            $("trVeiculo").style.display = "";
            $("trTipoVeiculo").style.display = "";
            $("trCliente").style.display = "";
            $("TRApenasTiposFrete").style.display = "";
            $("trTipoManifesto").style.display = "";
        }
        if (modelo == "14"){
            $("trCliente").style.display = "";
            $("trTipoManifesto").style.display = "";
        }

    }
    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizafilialdest(){
        post_cad = window.open('./localiza?acao=consultar&idlista=17','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizafilialdest(){
        post_cad = window.open('./localiza?acao=consultar&idlista=17','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaSeguradora(){
        post_cad = window.open('./localiza?acao=consultar&idlista=57','Seguradora',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=7','Veiculo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    function localizaMotorista(){ 
        post_cad = window.open('./localiza?acao=consultar&idlista=10','motorista',
        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
        
    }

    function limparveiculo(){
        $("idveiculo").value = 0;
        $("vei_placa").value = "";
    }
    
    function limparmotorista(){
        $("idmotorista").value = 0;
        $("motor_nome").value = "";
    }

    function popRel(){
        var modelo; 
        var agrupamento = "dtsaida";
        if (! validaData(getObj("dtinicial").value) || ! validaData(getObj("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else{
            if (getObj("modelo1").checked){
                modelo = '1';
            }else if (getObj("modelo2").checked){
                modelo = '2';
            }else if (getObj("modelo3").checked){
                modelo = '3';
                if ($("agrupamentoMod3_2").checked){
                    agrupamento = "motorista";
                }else if ($("agrupamentoMod3_3").checked){
                    agrupamento = "veiculo";
                }else if ($("agrupamentoMod3_4").checked){
                    agrupamento = "mes_saida";
                }else if ($("agrupamentoMod3_5").checked){
                    agrupamento = "cidade_destino";
                }else if ($("agrupamentoMod3_6").checked){
                    agrupamento = "area_destino";
                }
            }else if (getObj("modelo4").checked){
                modelo = '4';
            }else if (getObj("modelo5").checked){
                modelo = '5';
            }else if (getObj("modelo6").checked){
                modelo = '6';
            }else if (getObj("modelo7").checked){
                modelo = '7';
            }else if (getObj("modelo8").checked){
                modelo = '8';
            }else if (getObj("modelo9").checked){
                modelo = '9';
            }else if (getObj("modelo10").checked){
                modelo = '10';
            }else if (getObj("modelo11").checked){
                modelo = '11';
            }else if (getObj("modelo12").checked){
                modelo = '12';
            }else if (getObj("modelo13").checked){
                modelo = '13';
            }else if (getObj("modelo14").checked) {
                modelo = '14';
            }

            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";


            launchPDF('./relmanifesto?acao=exportar&modelo='+modelo+'&tipveiculo='+$("tipveiculo").value+'&agrupamento='+agrupamento+'&isChegada='+$("isChegada").value+'&impressao='+impressao
                    +'&is_mostra_ctrc='+$("is_mostra_ctrc").checked
                    +'&is_Agregado='+$("is_Agregado").checked
                    +'&is_Carreteiros='+$("is_Carreteiros").checked 
                    +'&is_FrotaP='+$("is_FrotaP").checked+'&'
                    +'&apenasTiposFreteC='+$("apenasTiposFreteC").checked+'&'
                    +'&apenasTiposFreteF='+$("apenasTiposFreteF").checked+'&'
                    +'&apenasTiposFreteT='+$("apenasTiposFreteT").checked+'&'
                    +concatFieldValue("tipoModalCte,idcompanhia,dtinicial,dtfinal,tipodata,idfilial,fi_abreviatura,idfilial2,fi_abreviatura2,idveiculo,vei_placa,seguradora_id,nome_seguradora,idcidadedestino,cid_destino,uf_destino,tipoFrete,apenas_uf_destino, nummanifesto,con_rzs,idconsignatario,tipofrota, idmotorista,motor_nome,aeroportoColetaId,aeroportoColeta,aeroportoEntregaId,aeroportoEntrega")
                    +'&tipoManifestoRodoviario=' + $('tipoManifestoRodoviario').checked
                    +'&tipoManifestoAereo=' + $('tipoManifestoAereo').checked
                    +'&tipoManifestoAquaviario=' + $('tipoManifestoAquaviario').checked);
        }
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=12','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparclifor(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }

function localizaCompanhiaAerea(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COMPANHIA_AEREA%>','companhia',
    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
}

    function limpaAeroportoEntrega(){
        $("aeroportoEntrega").value = "";
        $("aeroportoEntregaId").value = "0";
    }

    function limpaAeroportoColeta(){
        $("aeroportoColeta").value = "";
        $("aeroportoColetaId").value = "0";
    }

    function aoClicarNoLocaliza(idjanela){
        if(idjanela == "Aeroporto_Coleta"){
            $("aeroportoColeta").value = $("aeroporto").value;
            $("aeroportoColetaId").value = $("aeroporto_id").value;
        }
        
        if(idjanela == "Aeroporto_Entrega"){
            $("aeroportoEntrega").value = $("aeroporto").value;
            $("aeroportoEntregaId").value = $("aeroporto_id").value;
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

        <title>Webtrans - Relatório de Manifestos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="idfilial2" id="idfilial2" value="<%=(((!modeloFilialFranquia && temacessofiliais) || (modeloFilialFranquia && temacessofiliaisFranquia)) ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="idveiculo" id="idveiculo" value="0">
            <input type="hidden" name="idveiculo" id="idveiculo" value="0">
            <input type="hidden" name="idmotorista" id="idmotorista" value="0">  
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Manifestos</b></td>
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
                <td width="50%" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos(1);">
                        <label for="modelo1">Modelo 1</label></div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de manifestos
                    com os valores dos seguros</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos(2);">
                        <label for="modelo2">Modelo 2</label></div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de manifestos
                    embarcados</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos(3);">
                        <label for="modelo3">Modelo 3</label></div></td>
                <td class="CelulaZebra2">
                    Relação de manifestos com valores de frete.<br> 
                    <input type="checkbox" checked name="is_mostra_ctrc" id="is_mostra_ctrc"><label for="is_mostra_ctrc">Mostrar os CT-e(s)</label>
                </td>
                <td width="210" class="CelulaZebra2">
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_1" value="dtsaida" checked >
                    <label for="agrupamentoMod3_1">Agrupar por data de saída</label><br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_2" value="motorista" >
                    <label for="agrupamentoMod3_2">Agrupar por motorista</label><br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_3" value="veiculo" >
                    <label for="agrupamentoMod3_3">Agrupar por Veículo</label><br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_4" value="mes_saida" >
                    <label for="agrupamentoMod3_4">Agrupar por Mês/Ano</label><br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_5" value="cidade_destino" >
                    <label for="agrupamentoMod3_5">Agrupar por Cidade de destino</label><br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_6" value="area_destino" >
                    <label for="agrupamentoMod3_6">Agrupar por Área de destino</label>
                </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos(4);">
                        <label for="modelo4">Modelo 4</label></div></td>
                <td width="378" colspan="2" class="CelulaZebra2">Relação de manifestos por cidade de destino
                </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo5" id="modelo5" value="5" onClick="javascript:modelos(5);">
                        <label for="modelo5">Modelo 5</label></div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Relação de manifestos com CT-e(s)</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo6" id="modelo6" value="6" onClick="javascript:modelos(6);">
                        <label for="modelo6">Modelo 6</label></div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Quantidade de manifestos por agente de carga</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo7" id="modelo7" value="7" onClick="javascript:modelos(7);">
                        <label for="modelo7">Modelo 7</label></div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Relação dos CT-e(s) Agrupados por filial de destino</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo8" id="modelo8" value="5" onClick="javascript:modelos(8);">
                        <label for="modelo8">Modelo 8</label></div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Relação de manifestos com CT-e(s) e ocorrências</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo9" id="modelo9" value="9" onClick="javascript:modelos(9);">
                        <label for="modelo9">Modelo 9</label></div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de manifestos
                    Embarcados por Tipo de Veículo</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo10" id="modelo10" value="10" onClick="javascript:modelos(10);">
                        <label for="modelo10">Modelo 10</label></div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de manifestos
                    Ordenados por Cidade de Destino</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo11" id="modelo11" value="11" onClick="javascript:modelos(11);">
                        <label for="modelo11">Modelo 11</label></div></td>
                <td colspan="2" class="CelulaZebra2">Relação de manifestos com taxa de ocupação</td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo12" id="modelo12" value="12" onClick="javascript:modelos(12);">
                        <label for="modelo12">Modelo 12</label></div></td>
                <td colspan="2" class="CelulaZebra2">Relação de manifestos Aéreos com dados do AWB Agrupado por Cia Aérea</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo13" id="modelo13" value="13" onClick="javascript:modelos(13);">
                        <label for="modelo13">Modelo 13</label>
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Relação de Manifestos por filial de destino com lucratividade</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo14" id="modelo14" value="14" onClick="javascript:modelos(14);">
                        <label for="modelo14">Modelo 14</label>
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Relatório de conferência de manifesto</td>
            </tr>
            <tr class="tabela">
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="dtsaida" selected>Saídas entre</option>
                        <option value="dtprevista">Previstos entre</option>
                    </select>    </td>
                <td colspan="2" class="CelulaZebra2"> <strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="3"> <div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td colspan="3">
                    <table width="100%" border="0" >
                        <tr>
                            <td width="50%" class="TextoCampos">Apenas a filial origem:</td>
                            <td width="60%" class="CelulaZebra2"><strong>
                                    <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="35" maxlength="80" readonly="true">
                                    <% if (temacessofiliais) {%>
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial').value = '0';javascript:getObj('fi_abreviatura').value = '';">
                                    <%}%>
                                </strong></td>
                        </tr>
                        <tr id="filialDestinoTR">
                            <td class="TextoCampos"><div align="right">Apenas a filial destino:</div></td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="fi_abreviatura2" type="text" id="fi_abreviatura2" class="inputReadOnly" value="<%=(((!modeloFilialFranquia && temacessofiliais) || (modeloFilialFranquia && temacessofiliaisFranquia)) ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="35" maxlength="60" readonly="true">
                                        <% if (((!modeloFilialFranquia && temacessofiliais) || (modeloFilialFranquia && temacessofiliaisFranquia))) {%>
                                        <input name="localiza_filial2" type="button" class="botoes" id="localiza_filial2" value="..." onClick="javascript:localizafilialdest();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial2').value = '0';javascript:getObj('fi_abreviatura2').value = '';">
                                        <%}%>
                                    </strong></div></td>
                        </tr>
                        <tr id="trSeguradora">
                            <td class="TextoCampos"><div align="right">Apenas a seguradora:</div></td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="seguradora_id" type="hidden" id="seguradora_id" value="0">
                                        <input name="nome_seguradora" type="text" id="nome_seguradora" class="inputReadOnly" size="35" maxlength="60" readonly="true">
                                        <input name="localiza_seguradora" type="button" class="botoes" id="localiza_seguradora" value="..." onClick="javascript:localizaSeguradora();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Seguradora" onClick="javascript:getObj('seguradora_id').value = '0';javascript:getObj('nome_seguradora').value = '';">
                                    </strong></div></td>
                        </tr>
                        <tr id="trVeiculo" style="display:none">
                            <td class="TextoCampos">Apenas o ve&iacute;culo:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly" size="10" maxlength="80" readonly="true">
                                    <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..." onClick="javascript:localizaveiculo();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparveiculo();">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trMotorista" >
                            <td class="TextoCampos">Apenas o motorista:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                    <input name="localiza_mot" type="button" class="botoes" id="localiza_mot" value="..." onClick="javascript:localizaMotorista();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar motorista" onClick="javascript:limparmotorista();">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trTipoVeiculo" style="display:none">
                            <td class="TextoCampos">Apenas os ve&iacute;culos:</td>
                            <td class="CelulaZebra2">
                                <select name="tipofrota" id="tipofrota" style="display: none">
                                    <option value="" selected>Todos</option>
                                    <option value="ag">Agregados</option>
                                    <option value="pr">Da frota pr&oacute;pria</option>
                                    <option value="ca">De Carreteiros</option>
                                    <option value="te">Terceiros(Agegados e Carreteiros)</option>
                                </select>  
                               <label > <input type="checkbox" checked name="is_Agregado" id="is_Agregado"> Agregados<br></label >
                               <label > <input type="checkbox" checked name="is_FrotaP" id="is_FrotaP"> Da frota pr&oacute;pria<br></label >
                               <label > <input type="checkbox" checked name="is_Carreteiros" id="is_Carreteiros"> De Carreteiros<br></label >
                            </td>
                        </tr>
                        <tr id="trCidadeDestino">
                            <td class="TextoCampos">Apenas a cidade de destino:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
                                    <input name="cid_destino" type="text" class="inputReadOnly8pt" id="cid_destino"  value="" size="20" readonly="true">
                                    <input name="uf_destino" type="text" id="uf_destino"  class="inputReadOnly8pt" size="2" readonly="true">
                                    <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();">
                                    <img src="img/borracha.gif" name="apaga_cid_destino" border="0" align="absbottom" class="imagemLink" id="apaga_cid_destino" title="Limpar Cidade de Destino" onClick="javascript:getObj('idcidadedestino').value = 0;javascript:getObj('cid_destino').value = '';getObj('uf_destino').value = '';">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trUFDestino">
                            <td class="TextoCampos">Apenas a UF de destino:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="apenas_uf_destino" type="text" id="apenas_uf_destino"  class="fieldMin" onChange="javascript:$('apenas_uf_destino').value = $('apenas_uf_destino').value.toUpperCase();" size="2" maxlength="2">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trIsChegada" name="trIsChegada" style="display: none">
                            <td class="TextoCampos">Mostrar Manifesto:</td>
                            <td class="TextoCampos"><div align="left">
                                    <select id="isChegada" name="isChegada" class="inputtexto">
                                        <option value="" selected>Todos</option>
                                        <option value="true">Com data de chegada</option>
                                        <option value="false">Sem data de chegada</option>
                                    </select>
                                    <select id="tipoModalCte" name="tipoModalCte" class="inputtexto">
                                        <option value="" selected>Todos</option>
                                        <option value="f">Com CT-e(s) tipo Fracionado</option>
                                        <option value="l">Com CT-e(s) tipo Lotação</option>
                                    </select></div>
                            </td>
                        </tr>
                        <tr id="trCliente" name="trCliente">
                            <td class="TextoCampos">Apenas o cliente:</td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                    <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizacliente();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();"></strong>
                                <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                            </td>
                        </tr>
                        <tr id="trTipoFrete" name="trTipoFrete" style="display: none">
                            <td class="TextoCampos">Mostrar CT-e(s):</td>
                            <td class="TextoCampos"><div align="left">
                                    <select id="tipoFrete" name="tipoFrete" class="inputtexto">
                                        <option value="" selected>Todos</option>
                                        <option value="CIF">CIF</option>
                                        <option value="FOB">FOB</option>
                                        <option value="CON">CON</option>
                                        <option value="RED">RED</option>
                                    </select></div>
                            </td>
                        </tr>
                        <tr id="trNumManifesto" style="display: none">
                            <td class="TextoCampos">N° do Manifesto:</td>
                            <td class="CelulaZebra2">
                                <input name="nummanifesto" type="text" id="nummanifesto"  class="fieldMin" size="15">
                            </td>
                        </tr>
                        <tr>
                        <td class="textoCampos">Apenas o Tipo de Veiculo: 
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
                        <tr id="trTipoManifesto">
                            <td class="textoCampos"><label for="tipoManifesto">Tipo de Manifesto:</label></td>
                            <td class="CelulaZebra2" id="tipoManifesto">
                                <input type="checkbox" id="tipoManifestoRodoviario" name="tipoManifestoRodoviario" checked><label for="tipoManifestoRodoviario">Rodoviário</label>
                                <input type="checkbox" id="tipoManifestoAereo" name="tipoManifestoAereo" checked><label for="tipoManifestoAereo">Aéreo</label>
                                <input type="checkbox" id="tipoManifestoAquaviario" name="tipoManifestoAquaviario" checked><label for="tipoManifestoAquaviario">Aquaviário</label>
                            </td>
                        </tr>
                        <tr id="trCiaAerea" name="trCiaAerea" style="display: none;">
                            <td class="TextoCampos">Apenas a Companhia Aérea:</td>
                            <td class="CelulaZebra2">
                                <input name="idcompanhia" type="hidden" id="idcompanhia" value="0">
                                <input name="companhia_aerea" type="text" id="companhia_aerea" class="inputReadOnly" value="" size="35" readonly="true">
                                <input name="localiza_companhia" type="button" class="botoes" id="localiza_companhia" value="..." onClick="javascript:localizaCompanhiaAerea();">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cia Aérea" onClick="javascript:$('idcompanhia').value='0';$('companhia_aerea').value = '';">
                            </td>
                        </tr>
                        <tr id="trAeroportoOri" name="trAeroportoOri" style="display: none;">
                            <td class="TextoCampos">Apenas o Aeroporto de Origem:</td>
                            <td class="CelulaZebra2">
                                <input name="aeroportoColeta" id="aeroportoColeta" class="inputReadOnly" value="" size="20" readonly/>
                                <input name="btAero" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=73', 'Aeroporto_Coleta')" style="text-align: center"/>
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoColeta();">
                                <input name="aeroportoColetaId" id="aeroportoColetaId" type="hidden" value="0"/>
                                <input type="hidden" id="aeroporto" name="aeroporto" value="">
                                <input type="hidden" id="aeroporto_id" name="aeroporto_id" value="">
                            </td>
                        </tr>
                        <tr id="trAeroportoDes" name="trAeroportoDes" style="display: none;">
                            <td class="TextoCampos">Apenas o Aeroporto de Destino:</td>
                            <td class="CelulaZebra2">
                                <input name="aeroportoEntrega" id="aeroportoEntrega" class="inputReadOnly" value="" size="20" readonly/>
                                <input name="btAero" id="btAero" class="inputBotaoMin" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=73', 'Aeroporto_Entrega')" style="text-align: center"/>
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaAeroportoEntrega()">
                                <input name="aeroportoEntregaId" id="aeroportoEntregaId" type="hidden" value="0"/>
                            </td>
                        </tr>
                        <tr id="TRApenasTiposFrete" style="display: none;">
                            <td class="TextoCampos">Apenas os tipos de Frete:</td>
                            <td class="CelulaZebra2">
                               <label><input type="checkbox" value="CIF" name="apenasTiposFreteC" id="apenasTiposFreteC" checked>CIF</label>
                               <label><input type="checkbox" value="FOB" name="apenasTiposFreteF" id="apenasTiposFreteF" checked>FOB</label>
                               <label><input type="checkbox" value="TER" name="apenasTiposFreteT" id="apenasTiposFreteT" checked>Terceiro</label>
                            </td>
                        </tr>
                    </table>
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
                    </div>
                </td>
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
