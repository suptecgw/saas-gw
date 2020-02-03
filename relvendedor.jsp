
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.filial.usuario.UsuarioVendedor"%>
<%@page import="java.util.ArrayList"%>
<%@page import="br.com.gwsistemas.filial.usuario.Usuario"%>
<%@page import="br.com.gwsistemas.filial.usuario.Usuario"%>
<%@page import="br.com.gwsistemas.filial.usuario.UsuarioDAO"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="br.com.gwsistemas.filial.usuario.UsuarioBO"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.text.*,
                  java.util.Date,
                  nucleo.*" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relvendedor") > 0);
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  if (acao.equals("exportar")){
    String tipoVendedor = request.getParameter("tipovendedor");
    String orderBy = "";
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
    Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
    String modelo = request.getParameter("modelo");
    boolean semVendedor = Apoio.parseBoolean(request.getParameter("semVendedor"));
    String idVendedor = request.getParameter("idvendedor");
    String nomeVendedor = request.getParameter("vendedor");
    String cidadeDestino = request.getParameter("cidadeDestino");
    String select = "";
    String tipoFiltroVendedor = request.getParameter("tipofiltrovendedor");
    String idredespachante = request.getParameter("idredespachante");
    String idVendedor2 = "";
    
    String representante = "";
    String vendedor = "";
    String impostosFederais = "";
    String pagarComissaoJuros = "'rj'";
    String pagarComissaoDesconto = "'rd'";
    String deduzirValorCFPagtComissao = "";
    String condicaoCalcularComissao = "";
    String condicaoTipoVendedor = "";
    boolean isIcms = Apoio.parseBoolean(request.getParameter("isIcms"));
    boolean isPis = Apoio.parseBoolean(request.getParameter("isPis"));
    boolean isCofins = Apoio.parseBoolean(request.getParameter("isCofins"));
    boolean isCssl = Apoio.parseBoolean(request.getParameter("isCssl"));
    boolean isIr = Apoio.parseBoolean(request.getParameter("isIr"));
    boolean isInss = Apoio.parseBoolean(request.getParameter("isInss"));
//    boolean isDeduzirValorCFPagtComissao = Apoio.parseBoolean(request.getParameter("isDeduzirValorCFPagtComissao"));
    boolean isRetirarContratoFreteBaseCalculo = Apoio.parseBoolean(request.getParameter("isRetirarContratoFreteBaseCalculo"));
    String valorJuros = request.getParameter("valorJuros");
    String valorDesconto = request.getParameter("valorDesconto");
    String tipoDataPagamentoComissao = request.getParameter("tipoData");
    String utilizaCriterioPagamentoComissao = "";
    String calcularComissao = "'" + request.getParameter("tipocomissao").toLowerCase() + "'";
    String supervisorVendedor = "";
    String sqlUFDestino = "";
    String sqlCidadeDestino = "";
    String sqlFaturaCobranca = "";
    String tipoAgrupamento = "";
    String sqlTipoPagamento = "";
    String tipoData = "";
    String tipoPagamento = "";
    BeanUsuario autenticado = Apoio.getUsuario(request);    
    String condicao = "";
    String ids = "";
    String tipoVendedorSupervisor ="";
    String nomeRepresentante = request.getParameter("redespachante");
    StringBuilder filtroUtilizados = new StringBuilder();
    
    if (modelo.equals("2")){
        if (tipoVendedor.equals("C")){
            if (tipoFiltroVendedor.equals("S")){
//                select = " idsupervisor_cliente AS idven, supervisor_cliente AS vendedor_rel, comissao_pelo_valor_pago_bruto_supervisor::float AS comissao_bruto, comissao_pelo_valor_pago_liquido_supervisor::float AS comissao_liquido, ";
                select = " supervisor_cliente_id AS idven, supervisor_cliente AS vendedor_rel, comissao_pelo_valor_pago_bruto_supervisor::float AS comissao_bruto, comissao_pelo_valor_pago_liquido_supervisor::float AS comissao_liquido, ";
                select +=" CASE WHEN tipo_base_comissao = 't' THEN roundabnt(((valor_parcela * vlcomissao_vendedor2 / 100)::numeric(10,4))::numeric,4) else roundabnt(comissao_pelo_valor_pago_liquido_supervisor::numeric,4) end as comissao_percentual,";
                idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and supervisor_cliente_id="+idVendedor);
//                orderBy = "idsupervisor_cliente";
                orderBy = "supervisor_cliente_id";
            }else{
//                select = " idvendedor_cliente AS idven, vendedor_cliente AS vendedor_rel, comissao_pelo_valor_pago_bruto_cliente::float AS comissao_bruto, comissao_pelo_valor_pago_liquido_cliente::float AS comissao_liquido, ";
                select = " vendedor_cliente_id AS idven, vendedor_cliente AS vendedor_rel, comissao_pelo_valor_pago_bruto_cliente::float AS comissao_bruto, comissao_pelo_valor_pago_liquido_cliente::float AS comissao_liquido, ";
                select +=" CASE WHEN tipo_base_comissao = 't' THEN roundabnt(((valor_parcela * vlcomissao_vendedor / 100)::numeric(10,4))::numeric,4) else roundabnt(comissao_pelo_valor_pago_liquido_cliente::numeric,4) end as comissao_percentual,";
                idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and vendedor_cliente_id="+idVendedor);
//                idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and idvendedor_cliente="+idVendedor);
//                orderBy = "idvendedor_cliente";
                orderBy = "vendedor_cliente_id";
            }
        }else{
            select = " vendedor_id AS idven, vendedor AS vendedor_rel,comissao_pelo_valor_pago_bruto::float AS comissao_bruto, comissao_pelo_valor_pago_liquido::float AS comissao_liquido, ";
            select +=" CASE WHEN tipo_base_comissao = 't' THEN roundabnt(((valor_parcela * comissao_vendedor / 100)::numeric(10,4))::numeric,4) else roundabnt(comissao_pelo_valor_pago_liquido::numeric,4) end as comissao_percentual,";
            idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and vendedor_id="+idVendedor);
            orderBy = "vendedor_id";
        }
    }else{
        if (tipoVendedor.equals("C")){
            if (tipoFiltroVendedor.equals("S")){
                select = " supervisor_cliente_id AS idven, supervisor_cliente AS vendedor_rel, comissao_devida_bruto_supervisor::float AS comissao_bruto, comissao_devida_liquido_supervisor::float AS comissao_liquido, comissao_supervisor as percentual_comissao,  ";
                idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and supervisor_cliente_id="+idVendedor);
                orderBy = "supervisor_cliente_id";
            }else{
                select = " vendedor_cliente_id AS idven, vendedor_cliente AS vendedor_rel, comissao_devida_bruto_cliente::float AS comissao_bruto, comissao_devida_liquido_cliente::float AS comissao_liquido, comissao_vendedor_cadastro as percentual_comissao, ";
                idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and vendedor_cliente_id="+idVendedor);
                orderBy = "vendedor_cliente_id";
            }
        }else{
            select = " vendedor_id AS idven, vendedor AS vendedor_rel,comissao_devida_bruto::float AS comissao_bruto, comissao_devida_liquido::float AS comissao_liquido, comissao_vendedor as percentual_comissao, ";
            idVendedor = (idVendedor.equals("0") && !semVendedor ?"":" and vendedor_id="+idVendedor);
            orderBy = "vendedor_id";
        }
    }
    if (modelo.equals("3")){
        vendedor = "";
        if (!request.getParameter("idvendedor").equals("0")){
            vendedor = " AND f.idfornecedor = " + request.getParameter("idvendedor");
        }
        representante = "";
        if (!request.getParameter("idredespachante").equals("0")){
            representante = (vendedor.equals("") ? " AND " : " OR ") + " f.idfornecedor = " + request.getParameter("idredespachante");
        }
    }
    
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
            condicao = "";
        }else{
            if (tipoVendedor.equals("C")){
                condicao = " AND vendedor_cliente_id IN ('" + ids + "') ";
            }else{
                condicao = " AND vendedor_id IN ('" + ids + "') ";
            }
        }
    }else{
        condicao = " ";
    }
    
    if (modelo.equals("1") || modelo.equals("4")){
        sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino IN ('" + request.getParameter("apenas_uf_destino").toUpperCase().replaceAll(",","','") + "') ");
        sqlCidadeDestino = (request.getParameter("idcidadedestino").trim().equals("0") ? "" : " AND idcidade_destino = " + request.getParameter("idcidadedestino"));
        if (modelo.equals("1")) {
            tipoAgrupamento = request.getParameter("agrupamentoMod1");
        } else {
            tipoAgrupamento = request.getParameter("agrupamentoMod4");
        }
        if (tipoAgrupamento.equals("uf_destino")){
            orderBy = "uf_destino,"+orderBy;
        }else if(tipoAgrupamento.equals("cliente")){
            if (modelo.equals("1")) {
                orderBy = "razaosocial," + orderBy;
            } else if (modelo.equals("4")) {
                // Resolve o problema de ambiguidade com vrelvendedor e cliente
                orderBy = "vrelvendedor.razaosocial, " + orderBy;
            }
        }
        sqlFaturaCobranca = "";
        tipoData = (request.getParameter("tipoData").equals("p") ? "data_pagamento" : "dtemissao");
        tipoPagamento = (request.getParameter("tipoData").equals("p") ? "'pagamento'" : "'dtemissao'");
        tipoVendedorSupervisor = (tipoVendedor.equals("C") ? "'C'" : "'L'");
        if(tipoData.equals("data_pagamento")){
            pagarComissaoJuros = (Apoio.parseBoolean(request.getParameter("valorRecebidoJuros")) ? "'rj'" : "'oj'");       
            pagarComissaoDesconto = (Apoio.parseBoolean(request.getParameter("valorRecebidoDesconto")) ? "'rd'" : "'od'");
        }
    }else if (modelo.equals("2")){
        sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND uf_destino IN ('" + request.getParameter("apenas_uf_destino").toUpperCase().replaceAll(",","','") + "') ");
        sqlCidadeDestino = (request.getParameter("idcidadedestino").trim().equals("0") ? "" : " AND idcidade_destino = " + request.getParameter("idcidadedestino"));
        tipoAgrupamento = "";
//        sqlFaturaCobranca = (Apoio.parseBoolean(request.getParameter("faturaCobranca"))? "" : " AND (situacao_fatura <> 'DE' OR situacao_fatura is null) ");
        sqlFaturaCobranca = (Apoio.parseBoolean(request.getParameter("faturaCobranca"))? "" : " AND (situacao <> 'DE' OR situacao is null) ");
//        tipoPagamento = (request.getParameter("tipoData").equals("p") ? "'data_pagamento'" : "'dtemissao'");
        tipoPagamento = "'pagamento'";
        tipoVendedorSupervisor = (tipoVendedor.equals("C") ? "'C'" : "'L'");
        pagarComissaoJuros = (Apoio.parseBoolean(request.getParameter("valorRecebidoJuros")) ? "'rj'" : "'oj'");       
        pagarComissaoDesconto = (Apoio.parseBoolean(request.getParameter("valorRecebidoDesconto")) ? "'rd'" : "'od'");       
    }else if (modelo.equals("3")){
        sqlUFDestino = (request.getParameter("apenas_uf_destino").trim().equals("") ? "" : " AND cid_dest.uf IN ('" + request.getParameter("apenas_uf_destino").toUpperCase().replaceAll(",","','") + "') ");
        sqlCidadeDestino = (request.getParameter("idcidadedestino").trim().equals("0") ? "" : " AND cid_dest.idcidade = " + request.getParameter("idcidadedestino"));
        tipoAgrupamento = "";
        sqlFaturaCobranca = "";
        sqlTipoPagamento = " AND pc.tipo_comissao = " + Apoio.SqlFix(request.getParameter("tipoPagamento"));
    }
    
//    if(modelo.equals("1") || modelo.equals("2")){
//        if(tipoFiltroVendedor.equals("V")){
//            if(isIcms){
//                impostosFederais += " and is_icms_vendedor";
//            }
//            if (isPis){
//                impostosFederais += " and is_pis_vendedor";
//            }
//            if (isCofins){
//                impostosFederais += " and is_cofins_vendedor";
//            }
//            if (isCssl){
//                impostosFederais += " and is_cssl_vendedor";
//            }
//            if (isIr){
//                impostosFederais += " and is_ir_vendedor";
//            }
//            if (isInss){
//                impostosFederais += " and is_inss_vendedor";
//            }
//            if (isDeduzirValorCFPagtComissao) {
//                deduzirValorCFPagtComissao = " and is_deduzir_valor_cf_pagamento_comissao_vendedor";
//            }
//            if(tipoDataPagamentoComissao.equals("p")){                
//                pagarComissaoJuros = " and pagamento_comissao_juros_vendedor = '" + valorJuros + "'";
//                pagarComissaoDesconto = " and pagamento_comissao_desconto_vendedor = '" + valorDesconto + "'";
//            }
//            utilizaCriterioPagamentoComissao = " and is_utiliza_criterio_pagamento_comissao_vendedor";
//            condicaoCalcularComissao = " and calcular_comissao_vendedor = '" + calcularComissao + "'";
//            condicaoTipoVendedor = " and tipo_vendedor_criterio_pagamento_comissao_vendedor = '" + tipoVendedor + "'";
//            
//        }else if(tipoFiltroVendedor.equals("S")){
//            if(isIcms){
//                impostosFederais += " and is_icms_supervisor";
//            }
//            if(isPis){
//                impostosFederais += " and is_pis_supervisor";
//            }
//            if(isCofins){
//                impostosFederais += " and is_cofins_supervisor";
//            }
//            if(isCssl){
//                impostosFederais += " and is_cssl_supervisor";
//            }
//            if(isIr){
//                impostosFederais += " and is_ir_supervisor";
//            }
//            if(isInss){
//                impostosFederais += " and is_inss_supervisor";
//            }
//            if(isDeduzirValorCFPagtComissao) {
//                deduzirValorCFPagtComissao = " and is_deduzir_valor_cf_pagamento_comissao_supervisor";
//            }
//            if(tipoDataPagamentoComissao.equals("p")){                
//                pagarComissaoJuros = " and pagamento_comissao_juros_supervisor = '" + valorJuros + "'";                
//                pagarComissaoDesconto = " and pagamento_comissao_desconto_supervisor = '" + valorDesconto + "'";                
//            }            
//            utilizaCriterioPagamentoComissao = " and is_utiliza_criterio_pagamento_comissao_supervisor";
//            condicaoCalcularComissao = " and calcular_comissao_supervisor = '" + calcularComissao + "'";
//            condicaoTipoVendedor = " and tipo_vendedor_criterio_pagamento_comissao_supervisor = '" + tipoVendedor + "'";
//        }
//    }    

    if (tipoFiltroVendedor.equals("V")) {
        supervisorVendedor = "'vendedor'";
    }else if (tipoFiltroVendedor.equals("S")) {
        supervisorVendedor = "'supervisor'";            
    }    
    
    filtroUtilizados.append("Período selecionado: "+new SimpleDateFormat("dd/MM/yyyy").format(dtinicial)+" até "+new SimpleDateFormat("dd/MM/yyyy").format(dtfinal));
    
    if (modelo.equals("1") || modelo.equals("4")) {
        if(tipoData.equals("dtemissao")){
            filtroUtilizados.append(", tipo data: ").append("emissão");
        }else{
            filtroUtilizados.append(", tipo data: ").append("pagamento");            
        }
    }else if(modelo.equals("2")){
        filtroUtilizados.append(", tipo data: ").append("pagamento");
    }else if(modelo.equals("3")){
        filtroUtilizados.append(", tipo data: ").append("emissão");        
    }
    
    //Filtros Utilizados
    if (modelo.equals("1") || modelo.equals("2") || modelo.equals("4")) {
       if (tipoVendedor.equals("C")) {
            filtroUtilizados.append(", utilizar vínculo do vendedor no cadastro de clientes");               
       }else{
            filtroUtilizados.append(", utilizar vínculo do vendedor nos lançamentos de CTs/NFS");           
       }       
       if(!idVendedor.equals("0") && !idVendedor.equals("")){
           if(tipoFiltroVendedor.equals("S")){
                filtroUtilizados.append(", supervisor: ").append(nomeVendedor);            
           }else if(tipoFiltroVendedor.equals("V")){            
                filtroUtilizados.append(", vendedor: ").append(nomeVendedor);            
           }
       }
       if (semVendedor && modelo.equals("1") || modelo.equals("4")) {
          filtroUtilizados.append(", mostrar apenas CTs/NFs sem vendedor");
       }
       if(Apoio.parseBoolean(request.getParameter("faturaCobranca")) && modelo.equals("2")){
          filtroUtilizados.append(", mostrar faturas recebidas pela empresa de cobrança (FATURAS DO TIPO DEVEDORA)");           
       }
       if (calcularComissao.equals("'l'")) {
          filtroUtilizados.append(", calcular comissão: valor líquido");               
       }else if(calcularComissao.equals("'b'")){
          filtroUtilizados.append(", calcular comissão: valor bruto");
       }
       if (!request.getParameter("idcidadedestino").trim().equals("0")) {
          filtroUtilizados.append(", apenas a cidade de destino: ").append(cidadeDestino);
       }
       if (!sqlUFDestino.equals("")) {
          filtroUtilizados.append(", apenas a(s) UF(s) de destino: ").append(request.getParameter("apenas_uf_destino"));
       }
       if(isIcms || isPis || isCofins || isCssl || isIr || isInss){
          filtroUtilizados.append(", impostos federais: ");
          filtroUtilizados.append(isIcms ? "ICMS" : "").append(isPis ? isIcms ? ",PIS" : "PIS" : "");
          filtroUtilizados.append(isCofins ? isIcms || isPis ? ",COFINS" : "COFINS" : "");
          filtroUtilizados.append(isCssl ? isIcms || isPis || isCofins ? ",CSSL" : "CSSL" : "");
          filtroUtilizados.append(isIr ? isIcms || isPis || isCofins || isCssl ? ",IR" : "IR" : "");
          filtroUtilizados.append(isInss ? isIcms || isPis || isCofins || isCssl || isIr ? ",INSS" : "INSS" : "");
       }
       if(isRetirarContratoFreteBaseCalculo){
           filtroUtilizados.append(", retirar contrato frete da base de cálculo");
       }
       if(pagarComissaoJuros.equals("'rj'")){
           filtroUtilizados.append(", pagar comissão (Juros): ").append("Valor Recebido");
       }else if(pagarComissaoJuros.equals("'oj'")){
           filtroUtilizados.append(", pagar comissão (Desconto): ").append("Valor Original");           
       }
       if(pagarComissaoDesconto.equals("'rd'")){
           filtroUtilizados.append(", pagar comissão (Desconto): ").append("Valor Recebido");
       }else if(pagarComissaoDesconto.equals("'od'")){
           filtroUtilizados.append(", pagar comissão (Desconto): ").append("Valor Original");           
       }
    }else if(modelo.equals("3")){
        if(!idVendedor.equals("0") && !idVendedor.equals("")){
           if(tipoFiltroVendedor.equals("S")){
                filtroUtilizados.append(", supervisor: ").append(nomeVendedor);            
           }else if(tipoFiltroVendedor.equals("V")){            
                filtroUtilizados.append(", vendedor: ").append(nomeVendedor);            
           }
       }
        
       if(!representante.equals("")){
           filtroUtilizados.append(", apenas o representante: ").append(nomeRepresentante);
       } 
        
       if(Apoio.parseBoolean(request.getParameter("faturaCobranca"))){
          filtroUtilizados.append(", mostrar faturas recebidas pela empresa de cobrança (FATURAS DO TIPO DEVEDORA)");           
       }
       if (!request.getParameter("idcidadedestino").trim().equals("0")) {
          filtroUtilizados.append(", apenas a cidade de destino: ").append(cidadeDestino);
       }
       if (!sqlUFDestino.equals("")) {
          filtroUtilizados.append(", apenas a(s) UF(s) de destino: ").append(request.getParameter("apenas_uf_destino"));
       }
    }
    
    
    java.util.Map param = new java.util.HashMap(13);
    param.put("TIPO_DATA", tipoData);
    param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
    param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
    param.put("IDVENDEDOR", idVendedor);
//    param.put("OPCOES", "Período selecionado: "+new SimpleDateFormat("dd/MM/yyyy").format(dtinicial)+" até "+new SimpleDateFormat("dd/MM/yyyy").format(dtfinal));
    param.put("OPCOES", filtroUtilizados.toString());
    param.put("TIPOVALOR", request.getParameter("tipocomissao"));
    param.put("TIPOVENDEDOR", tipoVendedor);
    param.put("TIPOAGRUPAMENTO", tipoAgrupamento);
    param.put("FATURA_COBRANCA", sqlFaturaCobranca);
    param.put("ORDENACAO", orderBy);
    param.put("SELECT", select);
    param.put("VENDEDOR", vendedor);
    param.put("TIPOVENDEDORSUPERVISOR", tipoFiltroVendedor);
    param.put("REPRESENTANTE", representante);
    param.put("CONDICAO", condicao);
    param.put("UF_DESTINO", sqlUFDestino);
    param.put("CIDADE_DESTINO", sqlCidadeDestino);
    param.put("TIPO_PAGAMENTO", sqlTipoPagamento);
    param.put("IMPOSTOS_FEDERAIS", impostosFederais);    
    param.put("DEDUZIR_VALOR_CF_PAGT_COMISSAO", deduzirValorCFPagtComissao);    
    param.put("UTILIZA_CRITERIO_PAGT_COMISSAO", utilizaCriterioPagamentoComissao);    
    param.put("PAGAR_COMISSAO_JUROS", pagarComissaoJuros);    
    param.put("PAGAR_COMISSAO_DESCONTO", pagarComissaoDesconto);    
    param.put("CALCULAR_COMISSAO", calcularComissao);    
    param.put("TIPO_VENDEDOR_CRITERIO_PAGT", condicaoTipoVendedor);
    param.put("IS_ICMS", isIcms);
    param.put("IS_PIS", isPis);
    param.put("IS_COFINS", isCofins);
    param.put("IS_CSSL", isCssl);
    param.put("IS_IR", isIr);
    param.put("IS_INSS", isInss);
//    param.put("IS_DEDUZIR_VALOR", isDeduzirValorCFPagtComissao);
    param.put("IS_RETIRAR_CONTRATO_FRETE_BASE_CALCULO", isRetirarContratoFreteBaseCalculo);
    param.put("SUPERVISOR_VENDEDOR", supervisorVendedor);
    param.put("TIPO_PAGAMENTO", tipoPagamento);
    param.put("TIPO_VENDEDOR_SUPERVISOR", tipoVendedorSupervisor);
    
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    request.setAttribute("map", param);
    request.setAttribute("rel", "relvendedormod"+modelo);
         
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_COMISSAO_RELATORIO.ordinal());
    }
  
%>


<script language="javascript" type="text/javascript">

  function modelos(modelo){
    getObj("modelo1").checked = false;
    getObj("modelo2").checked = false;
    getObj("modelo3").checked = false;
    getObj("modelo4").checked = false;
    getObj("modelo"+modelo).checked = true;

    if (getObj("modelo1").checked || getObj("modelo4").checked){
        $("trTipoVendedor").style.display = "";
        $("tipo_data").innerHTML = "";
        $("tipoData").style.display = "";
        $("trSemVendedor").style.display = "";
        $("trFaturaCobranca").style.display = "none";
        $("trTipoComissao").style.display = "";
        $("trRepresentante").style.display = "none";
        $("trCriterioPagamentoComissao").style.display = "";
        criterioPagamentoComissao($("tipoData").value);
    }else if (getObj("modelo2").checked){
        $("tipo_data").innerHTML = "Emitidos entre:";
        $("trTipoVendedor").style.display = "";
        $("tipo_data").innerHTML = "Pagos entre:";
        $("tipoData").style.display = "none";
        $("trSemVendedor").style.display = "none";
        $("trFaturaCobranca").style.display = "";
        $("trTipoComissao").style.display = "";
        $("trRepresentante").style.display = "none";
        $("trCriterioPagamentoComissao").style.display = "";
        $("trPagarComissaoJuros").style.display = "";
        $("trPagarComissaoDesconto").style.display = "";
    }else if (getObj("modelo3").checked){
        $("tipo_data").innerHTML = "Emitidos entre:";  
        $("tipoData").style.display = "none";
        $("trTipoVendedor").style.display = "none";
        $("trSemVendedor").style.display = "none";
        $("trFaturaCobranca").style.display = "";
        $("trTipoComissao").style.display = "none";
        $("trRepresentante").style.display = "";
        $("trCriterioPagamentoComissao").style.display = "none";
        $("trPagarComissaoJuros").style.display = "none";
        $("trPagarComissaoDesconto").style.display = "none";
    }
  }

  function popRel(){
    var modelo; 
    var agrupamentoMod1;
    var agrupamentoMod4;
    if (! validaData(getObj("dtinicial").value) || ! validaData(getObj("dtfinal").value))
      alert ("Informe o Intervalo de Datas Corretamente!");
    else{
      if (getObj("modelo1").checked)
        modelo = '1';
      else if (getObj("modelo2").checked)
        modelo = '2';
      else if (getObj("modelo3").checked)
        modelo = '3';
      else if (getObj("modelo4").checked)
          modelo = '4';
      var impressao;
      if ($("pdf").checked)
        impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";
    
      if ($('agrupModelo1_1').checked){
          agrupamentoMod1 = "vendedor";
      }else if($('agrupModelo1_2').checked){
          agrupamentoMod1 = "uf_destino";
      }else{
          agrupamentoMod1 = "cliente";
      }

        if ($('agrupModelo4_1').checked) {
            agrupamentoMod4 = "vendedor";
        } else if ($('agrupModelo4_2').checked) {
            agrupamentoMod4 = "uf_destino";
        } else {
            agrupamentoMod4 = "cliente";
        }
      
      var valorJuros = "";
      if($("valorJuros") != null){
          valorJuros = $("valorJuros").value;           
      }
      var valorDesconto = "";
      if($("valorDesconto") != null){
          valorDesconto = $("valorDesconto").value;           
      }
              
      launchPDF('./relvendedor?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'
                + concatFieldValue("tipoPagamento,dtinicial,dtfinal,idvendedor,tipocomissao,tipovendedor,tipofiltrovendedor,apenas_uf_destino,idcidadedestino,tipoData")
                +"&semVendedor="+$('semVendedor').checked+"&faturaCobranca="+$('faturaCobranca').checked+"&idredespachante="+ $("idredespachante").value+"&agrupamentoMod1="+agrupamentoMod1
//                + "&isDeduzirValorCFPagtComissao="+$("deduzirValorCFPagtComissao").checked+"&isIcms="+$("icms").checked+"&isPis="+$("pis").checked+"&isCofins="+$("cofins").checked
                + "&isRetirarContratoFreteBaseCalculo="+$("retirarContratoFreteBaseCalculo").checked+"&isIcms="+$("icms").checked+"&isPis="+$("pis").checked+"&isCofins="+$("cofins").checked
                + "&isCssl="+$("cssl").checked+"&isIr="+$("ir").checked+"&isInss="+$("inss").checked+"&valorJuros="+valorJuros+"&valorDesconto="+valorDesconto
                +"&valorRecebidoJuros="+$("valorRecebidoJuros").checked+"&valorRecebidoDesconto="+$("valorRecebidoDesconto").checked
                +"&vendedor="+$("ven_rzs").value+"&cidadeDestino="+$("cid_destino").value+"&redespachante="+$("redspt_rzs").value+"&agrupamentoMod4="+agrupamentoMod4);
    }
  }
  
    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=12','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
    function marcarTodosImpostos(){
        $("icms").checked = $("impostoFederais").checked;
        $("pis").checked = $("impostoFederais").checked;
        $("cofins").checked = $("impostoFederais").checked;
        $("cssl").checked = $("impostoFederais").checked;
        $("ir").checked = $("impostoFederais").checked;
        $("inss").checked = $("impostoFederais").checked;
    }
    
    function criterioPagamentoComissao(tipoPagamento){
        if(tipoPagamento == "p"){
            $("trPagarComissaoJuros").style.display = "";
            $("trPagarComissaoDesconto").style.display = "";
        }else if(tipoPagamento == "e"){
            $("trPagarComissaoJuros").style.display = "none";
            $("trPagarComissaoDesconto").style.display = "none";            
        }
    }
    
    function desabilitarImposto(calcularComissao){
        if(calcularComissao == "B"){
            $("impostoFederais").disabled = true;
            $("icms").disabled = true;
            $("pis").disabled = true;
            $("cofins").disabled = true;
            $("cssl").disabled = true;
            $("ir").disabled = true;
            $("inss").disabled = true;
        }else if(calcularComissao == "L"){
            $("impostoFederais").disabled = false;            
            $("icms").disabled = false;            
            $("pis").disabled = false;            
            $("cofins").disabled = false;            
            $("cssl").disabled = false;            
            $("ir").disabled = false;            
            $("inss").disabled = false;            
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

        <title>Webtrans - Relat&oacute;rio de Comiss&atilde;o</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center">
            <img src="img/banner.gif"  alt="banner"> 
            <br>
            <input type="hidden" name="idvendedor" id="idvendedor" value="0">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td><b>Relat&oacute;rio de Comiss&atilde;o</b></td>
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
                <td width="17%" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos('1');">
                        Modelo 1 
                    </div>
                </td>
                <td width="53%" class="CelulaZebra2">
                    Rela&ccedil;&atilde;o de Comiss&atilde;o por ctrc Emitido
                </td>
                <td width="30%" class="CelulaZebra2">
                        <input type="radio" name="agrupModelo1" id="agrupModelo1_1" value="vendedor" checked>Agrupado por Vendedor 
                        <br>
                        <input type="radio" name="agrupModelo1" id="agrupModelo1_2" value="uf">Agrupado por UF 
                        <br />
                        <input type="radio" name="agrupModelo1" id="agrupModelo1_3" value="cliente">Agrupado por Cliente 
                </td>
            </tr>
            <tr> 
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos('2');">
                        Modelo 2 
                    </div>
                </td>
                <td class="CelulaZebra2" colspan="2">
                    Rela&ccedil;&atilde;o de Comiss&atilde;o por Fatura Quitada
                </td>
            </tr>
            <tr> 
                <td class="TextoCampos"> 
                    <div align="left"> 
                        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos('3');">
                        Modelo 3 
                    </div>
                </td>
                <td class="CelulaZebra2" colspan="2">
                    Rela&ccedil;&atilde;o de Comiss&atilde;o (Com Lan&ccedil;amento do Pagamento)
                    <select name="tipoPagamento" class="inputtexto" id="tipoPagamento" >
                        <option value="v" selected>Agrupado por Vendedor</option>
                        <option value="r">Agrupado por Representante</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <div align="left">
                        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="modelos('4');">
                        Modelo 4
                    </div>
                </td>
                <td class="CelulaZebra2">
                    Relação de comissão por CTRC emitido (Dados da Fatura)
                </td>
                <td width="30%" class="CelulaZebra2">
                    <input type="radio" name="agrupModelo4" id="agrupModelo4_1" value="vendedor" checked>Agrupado por Vendedor
                    <br>
                    <input type="radio" name="agrupModelo4" id="agrupModelo4_2" value="uf">Agrupado por UF
                    <br>
                    <input type="radio" name="agrupModelo4" id="agrupModelo4_3" value="cliente">Agrupado por Cliente
                </td>
            </tr>
            <tr class="tabela"> 
                <td colspan="3">
                    <div align="center">Crit&eacute;rio de datas</div>
                </td>
            </tr>
            <tr> 
                <td class="TextoCampos">
                    <label id="tipo_data" name="tipo_data">
                    </label>
                    <select name="tipoData" class="inputtexto" id="tipoData" onclick="criterioPagamentoComissao(this.value);">
                        <option value="e" selected>Emissão:</option>
                        <option value="p">Pagamento:</option>
                    </select>
                </td>
                <td class="CelulaZebra2" colspan="2"> 
                    <strong> 
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
                    e
                    <strong> 
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
                </td>
            </tr>
            <tr class="tabela"> 
                <td height="18" colspan="3">
                    <div align="center">Filtros</div>
                </td>
            </tr>
            <tr> 
                <td colspan="3"> 
                    <table width="100%" border="0" >
                        <tr name="trTipoVendedor" id="trTipoVendedor">
                            <td colspan="2" class="TextoCampos">
                                <div align="center">
                                    <select name="tipovendedor" id="tipovendedor" onBlur="javascript:if(this.value == 'L') $('tipofiltrovendedor').value = 'V';" class="inputtexto">
                                        <option value="L" selected>Utilizar V&iacute;nculo do Vendedor nos Lan&ccedil;amentos de CTs/NFS</option>
                                        <option value="C">Utilizar V&iacute;nculo do Vendedor no Cadastro de Clientes</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos" width="50%">
                                <select name="tipofiltrovendedor" class="inputtexto" id="tipofiltrovendedor" onBlur="javascript:if(this.value == 'S') $('tipovendedor').value = 'C';">
                                    <option value="V" selected>Apenas o Vendedor:</option>
                                    <option value="S">Apenas o Supervisor:</option>
                                </select>
                            </td>
                            <td class="CelulaZebra2" width="50%">
                                <strong> 
                                    <input name="ven_rzs" type="text" id="ven_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                           onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>&paramaux=1', 'Vendedor')">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                         onClick="javascript:getObj('idvendedor').value = '0';javascript:getObj('ven_rzs').value = '';"> 
                                </strong>
                            </td>
                        </tr>
                        <tr id="trRepresentante" name="trRepresentante" style="display:none;">
                            <td class="TextoCampos">
                                <div align="right">Apenas o Representante:</div>
                            </td>
                            <td class="CelulaZebra2">
                                <strong> 
                                    <input type="hidden" id="idredespachante" value="0" name="idredespachante"/>
                                    <input name="redspt_rzs" type="text" id="redspt_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                           onClick="launchPopupLocate('./localiza?acao=consultar&idlista=23', 'Vendedor')">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                         onClick="javascript:getObj('idredespachante').value = '0';javascript:getObj('redspt_rzs').value = '';"> 
                                </strong>
                            </td>
                        </tr>
                        <tr name="trFaturaCobranca" id="trFaturaCobranca" style="display: none;">
                            <td colspan="2" class="TextoCampos">
                                <div align="center">
                                    <label>
                                        <input type="checkbox" name="faturaCobranca" id="faturaCobranca">
                                        Mostrar faturas recebidas pela empresa de cobrança (FATURAS DO TIPO DEVEDORA).
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr name="trSemVendedor" id="trSemVendedor">
                            <td colspan="2" class="TextoCampos">
                                <div align="center">
                                    <label>
                                        <input type="checkbox" name="semVendedor" id="semVendedor">
                                        Mostrar Apenas CTs/NFs Sem Vendedor
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr id="trTipoComissao" name="trTipoComissao">
                            <td class="TextoCampos">Calcular Comiss&atilde;o: </td>
                            <td class="CelulaZebra2">
                                <label>
                                    <select name="tipocomissao" id="tipocomissao" class="inputtexto" onclick="desabilitarImposto(this.value)">
                                        <option value="L" selected>Valor L&iacute;quido</option>
                                        <option value="B">Valor Bruto</option>
                                    </select>
                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas a cidade de destino:</td>
                            <td class="CelulaZebra2">
                                    <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
                                    <input name="cid_destino" type="text" class="inputReadOnly8pt" id="cid_destino"  value="" size="20" readonly="true">
                                    <input name="uf_destino" type="text" id="uf_destino"  class="inputReadOnly8pt" size="2" readonly="true">
                                    <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();">
                                    <img src="img/borracha.gif" name="apaga_cid_destino" border="0" align="absbottom" class="imagemLink" id="apaga_cid_destino" title="Limpar Cidade de Destino" onClick="javascript:getObj('idcidadedestino').value = 0;javascript:getObj('cid_destino').value = '';getObj('uf_destino').value = '';">
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas a(s) UF(s) de destino:</td>
                            <td class="CelulaZebra2">
                                    <input name="apenas_uf_destino" type="text" id="apenas_uf_destino"  class="fieldMin" size="15">Exemplo: PE,PB,CE
                            </td>
                        </tr>
                        <tr id="trCriterioPagamentoComissao" style="display: ">
                            <td class="CelulaZebra2">
                                <div align="center">
                                    <label><input type="checkbox" id="impostoFederais" name="impostoFederais" value="false" onclick="marcarTodosImpostos('Vendedor')"/>Impostos federais</label>
                                    <label><input type="checkbox" id="icms" name="icms" value="checkbox" checked/>ICMS</label>
                                    <label><input type="checkbox" id="pis" name="pis" value="checkbox"/>PIS</label>
                                    <label><input type="checkbox" id="cofins" name="cofins" value="checkbox"/>COFINS</label>
                                    <label><input type="checkbox" id="cssl" name="cssl" value="checkbox"/>CSSL</label>
                                    <label><input type="checkbox" id="ir" name="ir" value="checkbox"/>IR</label>
                                    <label><input type="checkbox" id="inss" name="inss" value="checkbox"/>INSS</label>                                    
                                </div>
                            </td>
                            <td class="TextoCamposNoAlign">
                                <div align="center">
                                    <label>
                                        <!--<input type="checkbox" id="deduzirValorCFPagtComissao" name="deduzirValorCFPagtComissao" value="checkbox"/>-->
                                        <input type="checkbox" id="retirarContratoFreteBaseCalculo" name="retirarContratoFreteBaseCalculo" value="checkbox"/>
                                        Retirar contrato frete da base de cálculo
                                    </label>                                    
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" id="trPagarComissaoJuros" style="display: none">
                            <td class="TextoCampos"><label>Em caso de recebimentos com juros, pagar comissão sobre:</label></td>
                            <td class="TextoCamposNoAlign">
                                <label>
                                    <input type="radio" name="valorJuros" id="valorRecebidoJuros" value="rj" checked />
                                    Valor Recebido
                                </label>
                                <label>
                                    <input type="radio" name="valorJuros" id="valorOriginalJuros" value="oj" />
                                    Valor Original
                                </label>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" id="trPagarComissaoDesconto" style="display: none">
                            <td class="TextoCampos"><label>Em caso de recebimentos com desconto, pagar comissão sobre:</label></td>
                            <td class="TextoCamposNoAlign">
                                <label>
                                    <input type="radio" name="valorDesconto" id="valorRecebidoDesconto" value="rd" checked />
                                    Valor Recebido
                                </label>
                                <label>
                                    <input type="radio" name="valorDesconto" id="valorOriginalDesconto" value="od" />
                                    Valor Original
                                </label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="tabela">
                    <div align="center">Formato do Relat&oacute;rio </div>
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
                <td colspan="3"class="TextoCampos"> 
                    <div align="center">
                        <% if (temacesso){%>
                            <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
            
        </div>
                    
        <div id="tabDinamico"></div>
        
        
    </body>
</html>