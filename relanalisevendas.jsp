<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="nucleo.BeanConfiguracao,
                  java.text.*,
                  java.util.Date,
                  nucleo.Apoio" errorPage="" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="org.apache.commons.lang3.StringUtils"%>
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


<% boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("relanalisevenda") > 0);
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
   BeanUsuario user = Apoio.getUsuario(request);
   

   request.setAttribute("nivelFilial", user.getAcesso("reloutrasfiliais"));
   request.setAttribute("filialUser", user.getFilial());
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );    
    int nivelFilialFranquia = Apoio.getUsuario(request).getAcesso("verctefiliais");
    int nivelUserToFilial = Apoio.getUsuario(request).getAcesso("reloutrasfiliais");
    String tipoFilialConfig = cfg.getMatrizFilialFranquia();

  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("exportar"))
  {
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    String cliente = "";
    StringBuilder filial = new StringBuilder();
    String filtros = "";
    String tipoData = "";
    String modelo = request.getParameter("modelo");
    String sqlDistribuicao = "";
    String sqlGrupos = "";
    String sqlFretes= "";
    String sqlSerie = "";
    String sqlRepresentante = "";
    String sqlTipoLancamento = "";
    String sqlModal = "";
    boolean isTipoRelAnalitico = false;
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    
    String consig = request.getParameter("con_rzs");
    List<String> consignatarioIds = new ArrayList<>();
    
    if (StringUtils.isNotBlank(consig)) {
        String[] splitConsignatarios = consig.split("!@!");
        
        for (String splitConsignatario : splitConsignatarios) {
            String[] splitConsignatarioId = splitConsignatario.split("#@#");
            
            if (splitConsignatarioId.length >= 2) {
                consignatarioIds.add(String.valueOf(Apoio.parseInt(splitConsignatarioId[1])));
            }
        }
    }
    
    String remet = request.getParameter("remet");
    List<String> remetenteIds = new ArrayList<>();
    
    if (StringUtils.isNotBlank(remet)) {
        String[] splitRemetentes = remet.split("!@!");
        
        for (String splitRemetente : splitRemetentes) {
            String[] splitRemetenteId = splitRemetente.split("#@#");
            
            if (splitRemetenteId.length >= 2) {
                remetenteIds.add(String.valueOf(Apoio.parseInt(splitRemetenteId[1])));
            }
        }
    }
    
    String dest = request.getParameter("dest");
    List<String> destinatarioIds = new ArrayList<>();
    
    if (StringUtils.isNotBlank(dest)) {
        String[] splitDestinatarios = dest.split("!@!");
        
        for (String splitDestinatario : splitDestinatarios ) {
            String[] splitDestinatarioId = splitDestinatario.split("#@#");
            
            if (splitDestinatarioId.length >= 2) {
                destinatarioIds.add(String.valueOf(Apoio.parseInt(splitDestinatarioId[1])));
            }
        }
    }
    
    //filtros
    filtros = "Usuário: "+user.getLogin();
    filtros +=", Período selecionado: " + request.getParameter("dtinicial") + " até " +request.getParameter("dtfinal");
    //Verificando o critério de datas
    if(modelo.equals("1")){
        tipoData = "emissao_em";
    }else if(modelo.equals("4")){
        tipoData = request.getParameter("tipodata").equals("dtemissao")?"s.emissao_em":"s.emissao_em";
    }else{
        tipoData = request.getParameter("tipodata").equals("dtemissao")?"s.emissao_em":"f.emissao_em";
    }

    //Verificando se vai filtrar apenas um consignatário
    if (!modelo.equals("1")){
        cliente = (consignatarioIds.isEmpty() ? "" : "and consignatario_id IN (" + String.join(",", consignatarioIds) + ")");
    }
    else{
        cliente = (consignatarioIds.isEmpty() ? "" : "and idcliente IN (" + String.join(",", consignatarioIds) + ")");
    }
    
    String agrupamento = "";
    String descAgrupamento = "";
    String ser = request.getParameter("serie");
    String repres = request.getParameter("idredespachante");
    String sqlDiariaParada = "";
    String filialId = request.getParameter("idfilial");
    String tipoRateio = "peso";
    boolean isClienteCteEmitido = false;
    Date dtinicialClienteCteEmitido = formatador.parse(request.getParameter("dtinicialClienteCteEmitido"));;
    Date dtfinalClienteCteEmitido = formatador.parse(request.getParameter("dtfinalClienteCteEmitido"));;
    String sqlClienteCteEmitido = "";
    
    if (Apoio.parseBoolean(request.getParameter("tipoRateioValorCte"))){
        tipoRateio = "valor_cte";
    }
    if (request.getParameter("excetoGrupo").equals("IN")) {
        sqlGrupos = (request.getParameter("grupos").equals("") ? "" : " and grupo_id IN (" + request.getParameter("grupos") + ")");
    }else{
        sqlGrupos = (request.getParameter("grupos").equals("") ? "" : " and (grupo_id NOT IN (" + request.getParameter("grupos") + ") OR grupo_id is null )");
    }
    if (request.getParameter("idfilial") != null && !"0".equals(request.getParameter("idfilial")) && !"".equals(request.getParameter("idfilial"))) {
        if("1".contains(modelo)){
            filial.append(" and idfilial = ").append(request.getParameter("idfilial"));
        }else if("9,8,7,4,6".contains(modelo)){
            filial.append(" and s.filial_id = ").append(request.getParameter("idfilial"));
        }else {
            filial.append(" and filial_id = ").append(request.getParameter("idfilial"));
        }
    }
    if (request.getParameter("idfilialentrega") != null && !"0".equals(request.getParameter("idfilialentrega")) && !"".equals(request.getParameter("idfilialentrega"))){
        if("6".contains(modelo)){
            filial.append(" and fca.filial_id = ").append(request.getParameter("idfilialentrega"));
        }else{
            filial.append(" and id_filial_entrega = ").append(request.getParameter("idfilialentrega"));
        }
    }

    if (modelo.equals("1")){
        sqlDistribuicao = "";
        isClienteCteEmitido = Apoio.parseBoolean(request.getParameter("chk_apenasClienteCteEmitido"));

        if(isClienteCteEmitido){
            sqlClienteCteEmitido = " AND (ts.data_ultima_venda between '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicialClienteCteEmitido) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinalClienteCteEmitido) +"') ";
        }
    } else if (modelo.equals("2")){
        sqlDistribuicao = (tipoData.equals("f.emissao_em") ? "" : (request.getParameter("slDistribuicao").equals("nf")?" AND ((s.categoria = 'ns') OR (s.categoria = 'ct' and ct.sale_distribuicao_id is null)) ":" AND ((s.categoria = 'ns' and s.tipo <> 'l') OR (s.categoria = 'ct')) ")) ;
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
    } else if (modelo.equals("3")){
        sqlDistribuicao = (tipoData.equals("f.emissao_em") ? "" : (request.getParameter("slDistribuicao").equals("nf")?" AND ((s.categoria = 'ns') OR (s.categoria = 'ct' and ct.sale_distribuicao_id is null)) ":" AND ((s.categoria = 'ns' and s.tipo <> 'l') OR (s.categoria = 'ct')) ")) ;
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
    } else if (modelo.equals("4")){
        sqlDistribuicao = "" ;
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
    } else if (modelo.equals("5")){
        sqlDistribuicao = (tipoData.equals("f.emissao_em") ? "" : (request.getParameter("slDistribuicao").equals("nf")?" AND ((s.categoria = 'ns') OR (s.categoria = 'ct' and ct.sale_distribuicao_id is null)) ":" AND ((s.categoria = 'ns' and s.tipo <> 'l') OR (s.categoria = 'ct')) ")) ;
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
    } else if (modelo.equals("6")){
        sqlDistribuicao = (tipoData.equals("f.emissao_em") ? "" : (request.getParameter("slDistribuicao").equals("nf")?" AND ((s.categoria = 'ns') OR (s.categoria = 'ct' and ct.sale_distribuicao_id is null)) ":" AND ((s.categoria = 'ns' and s.tipo <> 'l') OR (s.categoria = 'ct')) ")) ;
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
    } else if (modelo.equals("7")){
        sqlDistribuicao = "";
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
        tipoData = request.getParameter("tipodata").equals("dtemissao")?"s.emissao_em":"f.emissao_em";
    } else if (modelo.equals("8")){
        if (request.getParameter("excetoGrupo").equals("IN")) {
            sqlGrupos = (request.getParameter("grupos").equals("") ? "" : " and cli.grupo_id IN (" + request.getParameter("grupos") + ")");
        }else{
            sqlGrupos = (request.getParameter("grupos").equals("") ? "" : " and (cli.grupo_id NOT IN (" + request.getParameter("grupos") + ") OR cli.grupo_id is null )");
        }
        sqlDistribuicao = "" ;
        agrupamento = request.getParameter("slAgrupModelo8");
        tipoData = request.getParameter("tipodata").equals("dtemissao")?"s.emissao_em":"s.emissao_em";
        if (agrupamento.equals("abreviatura")){
            descAgrupamento = "FILIAL";
        }else if (agrupamento.equals("cliente_rzs")){
            descAgrupamento = "CLIENTE";
        }else if (agrupamento.equals("rem_rzs")){
            descAgrupamento = "REMETENTE";
        }else if (agrupamento.equals("dest_rzs")){
            descAgrupamento = "DESTINATARIO";
        }else if (agrupamento.equals("dest_cnpj")){
            descAgrupamento = "CNPJ (DESTINATARIO)";
        }else if (agrupamento.equals("nmanifesto")){
            descAgrupamento = "MANIFESTO";
        }else if (agrupamento.equals("red_rzs")){
            descAgrupamento = "REPRESENTANTE ENTREGA";
        }else if (agrupamento.equals("rep_entr_rzs")){
            descAgrupamento = "REPRESENTANTE ENTREGA2";
        }else if (agrupamento.equals("red2_rzs")){
            descAgrupamento = "REPRESENTANTE COLETA";
        }else if (agrupamento.equals("rep_col_rzs")){
            descAgrupamento = "REPRESENTANTE COLETA2";
        }else if (agrupamento.equals("dtemissao")){
            descAgrupamento = "EMISSÃO CT-E";
        }else if (agrupamento.equals("cidade_destino")){
            descAgrupamento = "CIDADE DE DESTINO";
        }else if (agrupamento.equals("uf_destino")){
            descAgrupamento = "UF DE DESTINO";
        }else if (agrupamento.equals("modal")){
            descAgrupamento = "MODAL";
        }
        isTipoRelAnalitico = Apoio.parseBoolean(request.getParameter("tipoAnalitico"));
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
        sqlRepresentante = (repres.trim().equals("0") ? "" : " AND (ct.redespachante_id = " + repres + " OR ct.representante_entrega2_id="+repres+") ");
        String tpMod = "";
        //Modal
        if (Apoio.parseBoolean(request.getParameter("isModalRodoviario"))){
            tpMod = "'r'";
        }
        if (Apoio.parseBoolean(request.getParameter("isModalAereo"))){
            tpMod += (tpMod.equals("")?"":",") + "'a'";
        }
        if (Apoio.parseBoolean(request.getParameter("isModalAquaviario"))){
            tpMod += (tpMod.equals("")?"":",") + "'q'";
        }
        sqlModal = " AND ct.tipo_transporte IN (" + tpMod + ") ";
    } else if (modelo.equals("9")){
        if (request.getParameter("excetoGrupo").equals("IN")) {
            sqlGrupos = (request.getParameter("grupos").equals("") ? "" : " and cli.grupo_id IN (" + request.getParameter("grupos") + ")");
        }else{
            sqlGrupos = (request.getParameter("grupos").equals("") ? "" : " and (cli.grupo_id NOT IN (" + request.getParameter("grupos") + ") OR cli.grupo_id is null )");
        }
        sqlDistribuicao = (request.getParameter("slDistribuicao").equals("nf") ? " AND s.categoria = 'ct' and ct.sale_distribuicao_id is null AND s.tipo <> 'b' ":" and s.tipo <> 'l' ");
        agrupamento = request.getParameter("slAgrupModelo9");
        tipoData = request.getParameter("tipodata").equals("dtemissao")?"s.emissao_em":"s.emissao_em";
        if (agrupamento.equals("abreviatura")){
            descAgrupamento = "FILIAL";
            sqlDiariaParada = " COALESCE((SELECT sum(cf2.valor_diaria) FROM carta_frete cf2 WHERE cf2.data between '"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"' AND '"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"' AND cf2.is_diaria_parada AND NOT cf2.is_cancelada " + (!filialId.equals("0")?" AND cf2.idfilial="+filialId:"")+" AND cf2.idfilial = s.filial_id),0)::float AS diaria_parado, ";
        }else if (agrupamento.equals("cliente_rzs")){
            descAgrupamento = "CLIENTE";
            sqlDiariaParada = " COALESCE((SELECT sum(cf2.valor_diaria) FROM carta_frete cf2 WHERE cf2.data between '"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"' AND '"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"' AND cf2.is_diaria_parada AND NOT cf2.is_cancelada " + (!filialId.equals("0")?" AND cf2.idfilial="+filialId:"")+" AND cf2.cliente_diaria_parada_id = s.consignatario_id),0)::float AS diaria_parado, ";
        }else if (agrupamento.equals("rem_rzs")){
            descAgrupamento = "REMETENTE";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("dest_rzs")){
            descAgrupamento = "DESTINATARIO";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("nmanifesto")){
            descAgrupamento = "MANIFESTO";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("red_rzs")){
            descAgrupamento = "REPRESENTANTE ENTREGA";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("rep_entr_rzs")){
            descAgrupamento = "REPRESENTANTE ENTREGA2";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("red2_rzs")){
            descAgrupamento = "REPRESENTANTE COLETA";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("rep_col_rzs")){
            descAgrupamento = "REPRESENTANTE COLETA2";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("dtemissao")){
            descAgrupamento = "EMISSÃO CT-E";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("cidade_destino")){
            descAgrupamento = "CIDADE DE DESTINO";
            sqlDiariaParada = " 0::float AS diaria_parado, ";
        }else if (agrupamento.equals("motorista")){
            descAgrupamento = "MOTORISTA";
            sqlDiariaParada = " COALESCE((SELECT sum(cf2.valor_diaria) FROM carta_frete cf2 WHERE cf2.data between '"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"' AND '"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"' AND cf2.is_diaria_parada AND NOT cf2.is_cancelada " + (!filialId.equals("0")?" AND cf2.idfilial="+filialId:"")+" AND cf2.motorista_id = ct.motorista_id),0)::float AS diaria_parado, ";
        }else if (agrupamento.equals("veiculo")){
            descAgrupamento = "VEICULO";
            sqlDiariaParada = " COALESCE((SELECT sum(cf2.valor_diaria) FROM carta_frete cf2 WHERE cf2.data between '"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"' AND '"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"' AND cf2.is_diaria_parada AND NOT cf2.is_cancelada " + (!filialId.equals("0")?" AND cf2.idfilial="+filialId:"")+" AND cf2.veiculo_id = ct.veiculo_id),0)::float AS diaria_parado, ";
        }else if (agrupamento.equals("tipo_frota_veiculo")){
            descAgrupamento = "TIPO FROTA";
            sqlDiariaParada = " COALESCE((SELECT sum(cf2.valor_diaria) FROM carta_frete cf2 JOIN veiculo v2 ON (cf2.veiculo_id = v2.idveiculo) WHERE cf2.data between '"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"' AND '"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"' AND cf2.is_diaria_parada AND NOT cf2.is_cancelada AND v2.tipofrota = vei.tipofrota " + (!filialId.equals("0")?" AND cf2.idfilial="+filialId:"")+"),0)::float AS diaria_parado, ";
        }
        isTipoRelAnalitico = Apoio.parseBoolean(request.getParameter("tipoAnalitico"));
        sqlSerie = (ser.trim().equals("") ? "" : " AND s.serie IN ('"+ser.replace(",", "','")+"')");
        sqlRepresentante = (repres.trim().equals("0") ? "" : " AND ct.redespachante_id = " + repres + " OR ct.representante_entrega2_id="+repres+" ");
        String tpLan = "";
        //Tipo de Lançamento
        if (Apoio.parseBoolean(request.getParameter("isCategoriaSalesCTE"))){
            tpLan = "'ct'";
        }
        if (Apoio.parseBoolean(request.getParameter("isCategoriaSalesNFS"))){
            tpLan += (tpLan.equals("")?"":",") + "'ns'";
        }

        sqlTipoLancamento = " AND s.categoria IN (" + tpLan + ") ";
    }

    java.util.Map param = new java.util.HashMap(12);
    param.put("TIPO_DATA", tipoData);
    param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
    param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
    param.put("CLIENTE", cliente);
    param.put("FILIAL", filial.toString());
    param.put("DISTRIBUICAO_TOTAL", sqlDistribuicao);
    param.put("OPCOES", filtros);
    param.put("GRUPOS", sqlGrupos);
    param.put("CAMPO_CLIENTE", (Apoio.parseBoolean(request.getParameter("isGrupoClientes"))?" COALESCE(gr.descricao,cl.razaosocial)": " cl.razaosocial " ));
    param.put("AGRUPAMENTO", agrupamento);
    param.put("DESCRICAO_AGRUPAMENTO", descAgrupamento);
    param.put("IS_ANALITICO",isTipoRelAnalitico);
    param.put("SERIE",sqlSerie);
    param.put("REPRESENTANTE",sqlRepresentante);
    param.put("TIPO_LANCAMENTO",sqlTipoLancamento);
    param.put("MODAL",sqlModal);
    param.put("DIARIA_PARADA",sqlDiariaParada);
    param.put("FRETES",request.getParameter("fretes"));

    //INICIO DA NOVA REGRA DE PARAMETROS
    
    param.put("REGRA_CLIENTE", "<>".equals(request.getParameter("slRegraCliente")) ? " NOT " : "");
    param.put("ID_CLIENTE", consignatarioIds.isEmpty() ? "" : " IN (" + String.join(",", consignatarioIds) + ")");
    param.put("REGRA_REMETENTE", "<>".equals(request.getParameter("slRegraRemente")) ? " NOT " : "");
    param.put("ID_REMETENTE", remetenteIds.isEmpty() ? "" : " IN (" + String.join(",", remetenteIds) + ")");
    param.put("ID_DESTINATARIO", destinatarioIds.isEmpty() ? "" :  ("<>".equals(request.getParameter("slRegraDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", destinatarioIds) + ")");
    
    param.put("FORMA_RATEIO", tipoRateio);
    param.put("CLIENTE_CTE_EMITIDO", sqlClienteCteEmitido);
    
    param.put("USUARIO",Apoio.getUsuario(request).getNome());
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENSA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));     
    //FIM DA NOVA REGRA DE PARAMETROS 
    request.setAttribute("map", param);
    request.setAttribute("rel", "analisereceitasmod"+modelo);
    
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }
    else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_ANALISE_RECEITA_RELATORIO.ordinal());
    }    
  
%>


<script language="javascript" type="text/javascript">
    var homePath = "${homePath}";
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
    
    $("divDistribuicao").style.display = "none";
    $("trGrupo").style.display = "none";
    $("trTipo").style.display = "none";
    $("fretesdiv").style.display = "";
    $("trTipoRateio").style.display = "none";
    $("trRepresentante").style.display = "none";
    $("trSerie").style.display = "none";
    $("trCategoria").style.display = "none";
    $("trModal").style.display = "none";
    $("trRemetente").style.display = "none";
    $("trDestinatario").style.display = "none";
    $("divRegraCliente").style.display = "none";
    $("slRegraCliente").style.display = "none";
    
    if (modelo == '1'){
        if ($('tipodata').value == 'emissao_fatura'){
            $('tipodata').value = 'dtemissao';
        }
        $("divRegraCliente").style.display = "";
        $("trGrupo").style.display = "";
        $("fretesdiv").style.display = "none";

    }else if (modelo == '2'){
        $("divDistribuicao").style.display = "";
        alteraTipoData();
        //Para evitar erro do grupo_id
        $("trGrupo").style.display = "";
        $("trSerie").style.display = "";
        $("divRegraCliente").style.display = "";
    }else if (modelo == '3'){
        $("divDistribuicao").style.display = "";
        alteraTipoData();
        //Para evitar erro do grupo_id
        $("trGrupo").style.display = "";
        $("trSerie").style.display = "";
        $("divRegraCliente").style.display = "";
    }else if (modelo == '4'){
        $("divDistribuicao").style.display = "none";
        if ($('tipodata').value == 'emissao_fatura'){
            $('tipodata').value = 'dtemissao';
        }
        $("trGrupo").style.display = "";
        $("trSerie").style.display = "";
        $("divRegraCliente").style.display = "";
    }else if (modelo == '5'){
        $("divDistribuicao").style.display = "";
        alteraTipoData();
        $("trSerie").style.display = "";
        $("divRegraCliente").style.display = "";
        $("trGrupo").style.display = "";
    }else if (modelo == '6'){
        $("divDistribuicao").style.display = "";
        if ($('tipodata').value == 'emissao_fatura'){
            $('tipodata').value = 'dtemissao';
        }
        $("trSerie").style.display = "";
        $("divRegraCliente").style.display = "";
        $("trGrupo").style.display = "";
    }else if (modelo == '7'){
        if($('tipodata').value == 'emissao_fatura'){
            $('tipodata').value = 's.emissao_em';
        }
        $("trSerie").style.display = "";
        $("divRegraCliente").style.display = "";
        $("trGrupo").style.display = "";
    }else if (modelo == '8'){
        $("divDistribuicao").style.display = "none";
        if ($('tipodata').value == 'emissao_fatura'){
            $('tipodata').value = 'dtemissao';
        }
        $("trGrupo").style.display = "";
        $("trTipo").style.display = "";
        $("trTipoRateio").style.display = "";
        $("trRepresentante").style.display = "";
        $("trSerie").style.display = "";
        $("trModal").style.display = "";
        $("trRemetente").style.display = "";
        $("trDestinatario").style.display = "";
        $("slRegraCliente").style.display = "";
    }else if (modelo == '9'){
        $("divDistribuicao").style.display = "";
        if ($('tipodata').value == 'emissao_fatura'){
            $('tipodata').value = 'dtemissao';
        }
        $("trGrupo").style.display = "";
        $("trTipo").style.display = "";
        $("trTipoRateio").style.display = "";
        $("trRepresentante").style.display = "";
        $("trSerie").style.display = "";
        $("trCategoria").style.display = "";
        $("trRemetente").style.display = "";
        $("trDestinatario").style.display = "";
        $("slRegraCliente").style.display = "";
    }
  }

  function alteraTipoData(){
      if ($('tipodata').value == 'emissao_fatura'){
        if ($("modelo1").checked || $("modelo4").checked || $("modelo6").checked){
            alert('Esse critério de data não é válido para os modelo 1, 4 e 6!')
            $('tipodata').value = 'dtemissao';
        }else{
            $("divDistribuicao").style.display = "none";
        }
      }else{
        $("divDistribuicao").style.display = "";
      }
  }

  function localizacliente(){
     	post_cad = window.open("./localiza?categoria=loc_cliente&acao=consultar&idlista=59","Cliente",
                        "top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1");
  }
  
  function localizaFilial(){
     	post_cad = window.open("./localiza?acao=consultar&idlista=8","Filial",
                        "top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1");
  }

  function limparclifor(){
    $("idconsignatario").value = "0";
    $("con_rzs").value = "";
  }

  function popRel(){
    var idconsignatario = "";
    var consig = $("con_rzs").value;
    if(consig){
        consig.split('!@!').forEach(e => {
            var split = e.split('#@#');
            if(split[1]){
                idconsignatario += ","+split[1];
            }
        });
        idconsignatario = idconsignatario.split(',').slice(1);
    }
    var modelo; 
    var grupos = getGrupos();

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
        if ($("isModalRodoviario").checked == false && $("isModalAereo").checked == false && $("isModalAquaviario").checked == false){
            alert('Informe pelo menos um modal!');
            return false;
        }
      else if ($("modelo9").checked){
        modelo = '9';
        if ($("isCategoriaSalesCTE").checked == false && $("isCategoriaSalesNFS").checked == false){
            alert('Informe pelo menos um tipo de lançamento!');
            return false;
        }
      }
    
      var impressao;
      if ($("pdf").checked)
        impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";
        
      launchPDF('./relanalisevendas.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+
      '&idfilial='+$("idfilialemissao").value+
      '&idfilialentrega='+$("idfilialentrega").value+
      '&tipodata='+$("tipodata").value+'&dtinicial='+$("dtinicial").value+'&dtfinal='+$("dtfinal").value+'&isGrupoClientes='+$("isGrupoClientes").checked+
      '&slRegraCliente='+$('slRegraCliente').value +
      '&idredespachante='+$('idredespachante').value +
      '&serie='+$('serie').value +
      '&slAgrupModelo8='+$('slAgrupModelo8').value +
      '&slAgrupModelo9='+$('slAgrupModelo9').value +
      '&tipoAnalitico='+$("tipoAnalitico").checked+
      '&tipoSintetico='+$("tipoSintetico").checked+
      '&tipoRateioValorCte='+$("tipoRateioValorCte").checked+
      '&isCategoriaSalesCTE='+$("isCategoriaSalesCTE").checked+
      '&isCategoriaSalesNFS='+$("isCategoriaSalesNFS").checked+
      '&isModalRodoviario='+$("isModalRodoviario").checked+
      '&isModalAereo='+$("isModalAereo").checked+
      '&isModalAquaviario='+$("isModalAquaviario").checked+
      '&excetoGrupo='+$("excetoGrupo").value+
      '&slDistribuicao='+$('slDistribuicao').value+'&grupos='+grupos+
      '&chk_apenasClienteCteEmitido='+$('chk_apenasClienteCteEmitido').checked+
      '&dtinicialClienteCteEmitido='+$('dtinicialClienteCteEmitido').value+
      '&dtfinalClienteCteEmitido='+$('dtfinalClienteCteEmitido').value+
      '&con_rzs=' + encodeURIComponent($('con_rzs').value)+
      '&slRegraRemetente='+$('slRegraRemetente').value +
      '&remet=' + encodeURIComponent($('remet').value) +
      '&slRegraDestinatario='+$('slRegraDestinatario').value +
      '&fretes='+$('fretes').value +
      '&dest=' + encodeURIComponent($('dest').value)

      );
    }
  }

  function aoClicarNoLocaliza(idjanela){ 
    if (idjanela == "Grupo"){
        addGrupo($('grupo_id').value,'node_grupos', getObj('grupo').value);
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
  
  function localizaRedespachante(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=23','Redespachante',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }
  
  function localizaremet(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Remetente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  function localizades(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=4','Destinatario',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
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
    function abrirLocalizador(input) {
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

<title>Webtrans - Relat&oacute;rio de an&aacute;lise de receitas</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
<link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
</head>
<body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);alteraCondicaoFilial();">
    <div align="center">
        <img src="img/banner.gif"  alt="banner"><br>
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
    <table width="90%" align="center" class="bordaFina" >
        <tr>
            <td>
                <b>Relat&oacute;rio de an&aacute;lise de receitas</b>
            </td>
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
            <td colspan="3">
                <div align="center">Modelos</div>
            </td>
        </tr>
        <tr> 
            <td width="23%" height="24" class="TextoCampos"> 
                <div align="left"> 
                    <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                    Modelo 1
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2"> Relat&oacute;rio de clientes sem vendas no per&iacute;odo </td>
        </tr>
        <tr> 
            <td width="23%" height="24" class="TextoCampos"> 
                <div align="left"> 
                    <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                    Modelo 2
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2">Relat&oacute;rio de faturamento, por m&ecirc;s</td>
        </tr>
        <tr> 
            <td width="23%" height="24" class="TextoCampos"> 
                <div align="left"> 
                    <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                    Modelo 3
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2">Relat&oacute;rio de faturamento de filial, por m&ecirc;s</td>
        </tr>
        <tr>
            <td width="23%" height="24" class="TextoCampos"> 
                <div align="left">
                    <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                    Modelo 4
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2">Relat&oacute;rio de lucratividade (A&eacute;reo)</td>
        </tr>
        <tr>
            <td width="23%" height="24" class="TextoCampos"> 
                <div align="left">
                    <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                    Modelo 5
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2">Relat&oacute;rio de An&aacute;lise Financeira&nbsp;&nbsp;&nbsp;
                <input name="isGrupoClientes" type="checkbox"  id="isGrupoClientes" >Considerar o Grupo de clientes
            </td>
        </tr>
        <tr>
            <td width="23%" class="TextoCampos"> 
                <div align="left">
                    <input name="modelo6" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                    Modelo 6
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2">Relat&oacute;rio de An&aacute;lise de servi&ccedil;os prestados</td>
        </tr>
        <tr>
            <td width="23%" class="TextoCampos"> 
                <div align="left">
                    <input name="modelo7" id="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                    Modelo 7
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2">Relat&oacute;rio de Faturamento Di&aacute;rio por Filial </td>
        </tr>
        <tr>
            <td class="TextoCampos"> 
                <div align="left">
                    <input name="modelo8" id="modelo8" type="radio" value="8" onClick="javascript:modelos(8);">
                    Modelo 8
                </div>
            </td>
            <td colspan="2" class="CelulaZebra2">Relat&oacute;rio de Margens de Lucratividade (Todos os modais) 
                    Agrupado por: <select id="slAgrupModelo8" name="slAgrupModelo8" class="fieldMin">
                        <option value="abreviatura" selected>Filial</option>
                        <option value="cliente_rzs">Cliente (Tomador do Serviço)</option>
                        <option value="rem_rzs">Remetente</option>
                        <option value="dest_rzs">Destinatário</option>
                        <option value="dest_cnpj">Destinatário (Raiz CNPJ)</option>
                        <option value="dtemissao">Emissão CT-e</option>
                        <option value="cidade_destino">Cidade Destino</option>
                        <option value="uf_destino">UF Destino</option>
                        <option value="nmanifesto">Manifesto/AWB</option>
                        <option value="modal">Modal do Transporte</option>
                        <option value="red2_rzs">Representante Coleta</option>
                        <option value="rep_col_rzs">Representante Coleta2</option>
                        <option value="red_rzs">Representante Entrega</option>
                        <option value="rep_entr_rzs">Representante Entrega2</option>
                    </select>
            </td>
        </tr>
        <tr>
            <td class="TextoCampos"> 
                <div align="left">
                    <input name="modelo8" id="modelo9" type="radio" value="9" onClick="javascript:modelos(9);">
                    Modelo 9
                </div>
            </td>
            <td colspan="2" class="CelulaZebra2">Relat&oacute;rio de Margens de Lucratividade (Rodoviário)
                    Agrupado por: <select id="slAgrupModelo9" name="slAgrupModelo9" class="fieldMin">
                        <option value="abreviatura" selected>Filial</option>
                        <option value="cliente_rzs">Cliente (Tomador do Serviço)</option>
                        <option value="rem_rzs">Remetente</option>
                        <option value="dest_rzs">Destinatário</option>
                        <option value="dtemissao">Emissão CT-e</option>
                        <option value="cidade_destino">Cidade Destino</option>
                        <option value="nmanifesto">Manifesto</option>
                        <option value="red2_rzs">Representante Coleta</option>
                        <option value="rep_col_rzs">Representante Coleta2</option>
                        <option value="red_rzs">Representante Entrega</option>
                        <option value="rep_entr_rzs">Representante Entrega2</option>
                        <option value="motorista">Motorista</option>
                        <option value="veiculo">Placa do Veículo/Cavalo</option>
                        <option value="tipo_frota_veiculo">Tipo da Frota</option>
                    </select>
            </td>
        </tr>
        <tr class="tabela"> 
            <td colspan="3">
                <div align="center">Crit&eacute;rio de datas</div>
            </td>
        </tr>
        <tr> 
            <td class="TextoCampos">Por data de:</td>
            <td colspan="2" class="CelulaZebra2"> 
                <select id="tipodata" name="tipodata" class="inputtexto" onChange="alteraTipoData();">
                    <option value="dtemissao" selected>Emissão CT/NFS</option>
                    <option value="emissao_fatura">Emiss&atilde;o Fatura</option>
                </select>
                entre
                <strong>
                    <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                           onblur="alertInvalidDate(this)" class="fieldDate" />
                </strong>
                e
                <strong> 
                    <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                           onblur="alertInvalidDate(this)" class="fieldDate" />
                </strong>
            </td>
        </tr>
        <tr>
            <td class="TextoCampos" colspan="2">
                <label><input type="checkbox" name="chk_apenasClienteCteEmitido" id="chk_apenasClienteCteEmitido" > Considerar apenas os clientes que tiveram CT-e(s)/NFS-e(s) emitidos no período:</label>
            </td>
            <td class="CelulaZebra2"> 
                <strong>
                    <input name="dtinicialClienteCteEmitido" type="text" id="dtinicialClienteCteEmitido" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                           onblur="alertInvalidDate(this)" class="fieldDate" />
                </strong>
                e
                <strong> 
                    <input name="dtfinalClienteCteEmitido" type="text" id="dtfinalClienteCteEmitido" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                           onblur="alertInvalidDate(this)" class="fieldDate" />
                </strong>
            </td>
        </tr>
        <tr>
            <td class="TextoCampos" colspan="3">
                <div align="center" id="divDistribuicao" name="divDistribuicao" style="display:none;">
                    Em caso de entregas locais, utilizar valores
                    <select id="slDistribuicao" name="slDistribuicao" class="fieldMin">
                        <option value="nf">da NFS-e/CT-e de Cobrança</option>
                        <option value="ct" selected>do CT-e/Minuta de Entrega</option>
                    </select>
                </div>
            </td>
        </tr>
        <tr class="tabela"> 
            <td height="18" colspan="6">
                <div align="center">Filtros</div>
            </td>
        </tr>
        <tr> 
            <td colspan="12">
                <table width="100%" border="0" >
                    <tr name="trTipo" id="trTipo" style="display: none;">
                        <td class="TextoCampos" colspan="2">Tipo de Relatório:</td>
                        <td class="CelulaZebra2">
                            <input name="tipoAnalitico" id="tipoAnalitico" type="radio" value="radiobutton" checked onClick="javascript:$('tipoSintetico').checked=false;this.checked=true;">
                            Analítico
                            <input name="tipoSintetico" id="tipoSintetico" type="radio" value="radiobutton" onClick="javascript:$('tipoAnalitico').checked = false;this.checked=true;">
                            Sintético
                        </td>
                    </tr>
                    <tr name="trTipoRateio" id="trTipoRateio" style="display: none;">
                        <td class="TextoCampos" colspan="2">Tipo de Rateio:</td>
                        <td class="CelulaZebra2">
                            <input name="tipoRateioPeso" id="tipoRateioPeso" type="radio" value="radiobutton" checked onClick="javascript:$('tipoRateioValorCte').checked=false;this.checked=true;">
                            Pelo Peso
                            <input name="tipoRateioValorCte" id="tipoRateioValorCte" type="radio" value="radiobutton" onClick="javascript:$('tipoRateioPeso').checked = false;this.checked=true;">
                            Pelo Valor do CT-e
                        </td>
                    </tr>
                    <tr name="trModal" id="trModal" style="display: none;">
                        <td class="TextoCampos" colspan="2">Modal:</td>
                        <td class="CelulaZebra2">
                             <input name="isModalRodoviario" type="checkbox"  id="isModalRodoviario" checked>
                            Rodoviário
                            <input name="isModalAereo" type="checkbox"  id="isModalAereo" checked>
                            Aéreo
                            <input name="isModalAquaviario" type="checkbox"  id="isModalAquaviario" checked>
                            Aquaviário
                        </td>
                    </tr>
                    <tr name="trCategoria" id="trCategoria" style="display: none;">
                        <td class="TextoCampos" colspan="2">Tipo de Lançamento:</td>
                        <td class="CelulaZebra2">
                             <input name="isCategoriaSalesCTE" type="checkbox"  id="isCategoriaSalesCTE" checked>
                            CT-e
                            <input name="isCategoriaSalesNFS" type="checkbox"  id="isCategoriaSalesNFS">
                            NFS-e
                        </td>
                    </tr>
                    <tr id="trSerie" style="display:none;"> 
                        <td class="TextoCampos" colspan="2">
                            Apenas a(s) Série(s):
                        </td>
                        <td class="CelulaZebra2">
                            <input name="serie" type="text" id="serie" class="inputTexto" size="5">&nbsp;&nbsp;Exemplo: 1,A,2
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Filial de Emissão: </td>
                        <td colspan="1" class="TextoCampos"><div align="left"><strong>
                                <input name="filial_emissora" type="text" id="filial_emissora" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                <input name="localiza_filial_emissao" type="button" class="inputBotaoMin" id="localiza_filial_emissao" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Emissao','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img name="btnLimparFilialEmissao" id="btnLimparFilialEmissao" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialemissao').value = 0; $('filial_emissora').value = ''; alteraCondicaoFilial();">
                            </strong></div></td>
                        <td class="TextoCampos" colspan="1">
                            <div id="fretesdiv" align="left" style="display: none;">Apenas Fretes:
                                <select name="fretes" id="fretes" class="inputtexto">
                                   <option value="todos" selected>Todos</option>
                                   <option value="cif">CIF</option>
                                   <option value="fob">FOB</option>
                                   <option value="con">CON</option>
                                   <option value="red">RED</option>

                               </select>
                             </div>
                        </td>  
                    </tr>
                        
                        <tr>
                            <td colspan="1" class="TextoCampos">Filial de Entrega: </td>
                            <td colspan="2" class="TextoCampos"><div align="left"><strong>
                                <input name="filial_entrega" type="text" id="filial_entrega" value="" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                <input name="localiza_filial_entrega" type="button" class="inputBotaoMin" id="localiza_filial_entrega" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_Entrega','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img name="btnLimparFilialEntrega" id="btnLimparFilialEntrega" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialentrega').value = 0; $('filial_entrega').value = '';">
                                </strong></div></td>
                        </tr>
                    <tr>
                        <td  class="TextoCampos" colspan='1'>
                            <select id="slRegraCliente" name="slRegraCliente" class="fieldMin" style="display: none;">
                                <option value="=" selected>Apenas o cliente (Tomador do serviço):</option>
                                <option value="<>">Exceto o cliente (Tomador do serviço):</option>
                            </select>
                            <div align="right" id="divRegraCliente">Apenas o cliente (Tomador do serviço):</div>
                        </td>
                        <td  class="TextoCampos" colspan='2'>
                            <div align="left">
                                <strong>
                                    <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="28" maxlength="80" readonly="true">
                                    <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor" value="..." onClick="abrirLocalizador('con_rzs')">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="removerValorInput('con_rzs')">
                                </strong>
                            </div>
                        </td>
                    </tr>
                    <tr style="display:none;" id="trRemetente" name="trRemetente"> 
                        <td class="TextoCampos" colspan="2">
                            <select id="slRegraRemetente" name="slRegraRemetente" class="fieldMin">
                                <option value="=" selected>Apenas o remetente:</option>
                                <option value="<>">Exceto o remetente:</option>
                            </select>
                        </td>
                        <td class="TextoCampos">
                            <div align="left">
                                <strong>
                                    <input type="hidden" name="idremetente" id="idremetente" value="0">
                                    <input name="remet" type="text" id="remet" class="inputReadOnly8pt" size="28" maxlength="80" readonly="true">
                                    <input name="localiza_clifor" type="button" class="botoes" id="localiza_rem" value="..." onClick="abrirLocalizador('remet')">
                                    
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="removerValorInput('remet')">                                
                                </strong>
<!--                                <input name="isRaizRemetente" type="checkbox"  id="isRaizRemetente">Filtrar apenas a raiz do CNPJ-->
                            </div>
                        </td>
                        
                    </tr>
                    <tr style="display:none;" id="trDestinatario" name="trDestinatario"> 
                        <td class="TextoCampos" colspan="2">
                            <select id="slRegraDestinatario" name="slRegraDestinatario" class="fieldMin">
                                <option value="=" selected>Apenas o destinatário:</option>
                                <option value="<>">Exceto o destinatário:</option>
                            </select>
                        </td>
                        <td class="TextoCampos">
                            <div align="left">
                                <strong>
                                    <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
                                    <input name="dest" type="text" id="dest" class="inputReadOnly8pt" size="28" maxlength="80" readonly="true">
                                    <input name="localiza_clifor2" type="button" class="botoes" id="localiza_clifor" value="..." onClick="abrirLocalizador('dest')">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Destinat&aacute;rio" onClick="removerValorInput('dest')">                                
                                </strong>
<!--                                <input name="isRaizDestinatario" type="checkbox"  id="isRaizDestinatario">Filtrar apenas a raiz do CNPJ-->
                            </div>
                        </td>
                    </tr>
                    <tr id="trRepresentante" style="display:none;">
                        <td height="24" class="TextoCampos" colspan="2">
                            Apenas o representante de entrega:
                        </td>
                        <td class="CelulaZebra2">
                            <input name="redspt_rzs" type="text" id="redspt_rzs" size="28" class="inputReadOnly"  value="" readonly onKeyUp="javascript:if (event.keyCode==13) localizaRedespachoCodigo('c.razaosocial', this.value)" onFocus="this.select();">
                            <input name="localiza_redspt" type="button" class="botoes" id="localiza_redspt" value="..." onClick="javascript:localizaRedespachante();">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Redespachante" onClick="javascript:$('idredespachante').value = 0;javascript:$('redspt_rzs').value = '';">
                            <input type="hidden" name="idredespachante" id="idredespachante" value="0">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr name="trGrupo" id="trGrupo" >
            <td colspan="3">
                <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                    <tr class="cellNotes"> 
                        <td width="24%" class="CelulaZebra2">
                            <div align="center">
                                <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">          
                            </div>
                        </td>
                        <td width="76%" class="CelulaZebra2" >
                            <!--<div align="center">Apenas os grupos</div>-->
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
            <td colspan="3" class="tabela">
                <div align="center">Formato do relat&oacute;rio </div>
            </td>
        </tr>
        <tr>
            <td colspan="3" class="TextoCampos">
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
            <td colspan="3" class="TextoCampos">
                <div align="center">
                    <% if (temacesso){%>
                          <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                    <%}%>
                </div>
            </td>
        </tr>
    </table>
        </div>
                <div id="tabDinamico">
                                                    
                        
                </div>  
                <div class="localiza">
                    <iframe id="localizarCliente" input="con_rzs" name="localizarCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
                </div>
                <div class="cobre-tudo"></div>
  </body>
</html>
<script>
    jQuery(document).ready(function() {
        jQuery('#con_rzs').inputMultiploGw({
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
    });                           
</script>
