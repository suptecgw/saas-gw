<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="br.com.gwsistemas.filial.usuario.UsuarioVendedor"%>
<%@page import="java.util.Collection"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.sql.ResultSet,
         java.util.Date,
         mov_banco.conta.BeanConsultaConta,
         nucleo.Apoio" errorPage="" %>
<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
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
<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("relcontasreceber") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
    int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
    
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    
    String tipoFilialConfig = cfg.getMatrizFilialFranquia();
    int nivelUserToFilial = Apoio.getUsuario(request).getAcesso("lanconhfl");

    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    
    boolean limitarUsuarioVisualizarContas = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    
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
        
    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        String vendedor ="";
        String conta = "";
        String cliente = "";
        StringBuilder filial =  null;
        String fatura = "";
        String anofatura = "";
        String data = "";
        String tipoData = "";
        String situacao = "";
        String planoCusto = "";
        String sqlEmpresaCobranca = "";
        String empresaCobrancaId = request.getParameter("idfornecedor");
        String sqlTipoCobranca = "";
        String tipoCobranca = request.getParameter("tipoCobranca");
        String modelo = request.getParameter("modelo");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String formasPag = request.getParameter("formasPagamento");
        String iddestinatario = request.getParameter("iddestinatario");
        StringBuilder condicaoFormaPag = new StringBuilder();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
        String tipoFretes = "";
        //Verificando se vai filtrar apenas um consignatário
        String isBaixados = "";
        String mostraBaixadosApos = "";
        String baixados = "";
        String condicaoPagamento = "";
        String grupos = "";
        String excetoGrupo = request.getParameter("excetoGrupo");
        String idCidade = "0";
        
        if(modelo.equals("6")){
            tipoData = request.getParameter("tipodata");
            isBaixados = request.getParameter("chkabertodia");
        }else if(modelo.equals("8")){
            isBaixados = request.getParameter("chkabertodia");
        }
         
        //Colocando os parametros do select do cliente.
        
        cliente = "";
        if (request.getParameter("modelo").equals("3")) {            
            //cliente = (!request.getParameter("idconsignatario").equals("0") ? " AND sl.consignatario_id" + request.getParameter("excetoCliente") + request.getParameter("idconsignatario") : "");
            cliente = (idsConsignatario.isEmpty() ? "" : " and sl.consignatario_id " + ("<>".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
        } else if (request.getParameter("modelo").equals("5")) {
            cliente = (idsConsignatario.isEmpty() ? "" : " and consignatario_id " + ("<>".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
            //cliente = (!request.getParameter("idconsignatario").equals("0") ? " AND consignatario_id" + request.getParameter("excetoCliente") + request.getParameter("idconsignatario") : "");
        
        }else {
            cliente = (idsConsignatario.isEmpty() ? "" : " AND idconsignatario " + ("<>".equals(request.getParameter("excetoCliente")) ? " NOT " : "") + " IN (" + String.join(",", idsConsignatario) + ")");
            //cliente = (!request.getParameter("idconsignatario").equals("0") ? " AND idconsignatario" + request.getParameter("excetoCliente") + request.getParameter("idconsignatario") : "");
        }
        conta = (!request.getParameter("conta").equals("0") ? " and conta_id= " + request.getParameter("conta") : "");

        //Verificando se vai filtrar apenas uma filial
        if (modelo.equals("6") && request.getParameter("idconsignatario").equals("0") && isBaixados.equals("true")){
            filial =  new StringBuilder();
            if (request.getParameter("idfilial") != null && !request.getParameter("idfilial").equals("0")) {
                filial.append(" and idfilial =").append(request.getParameter("idfilial"));
            }
            if (request.getParameter("idfilialentrega") != null && !request.getParameter("idfilialentrega").equals("0")){
                 filial.append(" and id_filial_entrega =").append(request.getParameter("idfilialentrega"));
            }
            if (request.getParameter("modelo").equals("6") && isBaixados.equals("false") && !request.getParameter("idfilialcobranca").equals("0")){
                filial.append(" and filial_cobranca_id =").append(request.getParameter("idfilialcobranca"));
            }
        }else{
            filial =  new StringBuilder();
            if (request.getParameter("idfilial") != null && !request.getParameter("idfilial").equals("0")) {
                if(request.getParameter("modelo").equals("3")){
                    filial.append(" and fl.idfilial =").append(request.getParameter("idfilial"));
                } else if(request.getParameter("modelo").equals("5")){
                   filial.append(" and filial_id =").append(request.getParameter("idfilial"));
                }else{
                   filial.append(" and idfilial =").append(request.getParameter("idfilial"));
                }
            }
            if (request.getParameter("idfilialentrega") != null && !request.getParameter("idfilialentrega").equals("0")){
                 filial.append(" and id_filial_entrega =").append(request.getParameter("idfilialentrega"));
            }
            if (request.getParameter("idfilialcobranca") != null && !request.getParameter("idfilialcobranca").equals("0")) {
                filial.append(" AND filial_cobranca_id =").append(request.getParameter("idfilialcobranca"));
            }
        }
        //Verificando se vai filtrar apenas uma fatura
        fatura = (!request.getParameter("fatura").equals("") ? "and fatura='" + request.getParameter("fatura") + "'" : "");
        //Verificando se vai filtrar apenas um ano fatura
        anofatura = (!request.getParameter("anofatura").equals("") ? "and ano_fatura='" + request.getParameter("anofatura") + "'" : "");
        //Verificando o critério de datas
        tipoData = request.getParameter("tipodata");
        if (request.getParameter("modelo").equals("2") || request.getParameter("modelo").equals("9")) {
            tipoData = (tipoData.equals("dtemissao") ? "emissao_fatura" : tipoData);
            tipoData = (tipoData.equals("dtvenc") ? "vencimento_fatura" : tipoData);
        } else if (request.getParameter("modelo").equals("3")) {
            tipoData = (tipoData.equals("dtemissao") ? "sl.emissao_em" : "p.vence_em");
        } else if (request.getParameter("modelo").equals("5")) {
            tipoData = (tipoData.equals("dtemissao") ? "emissao_em" : "vence_em");
        }
        data = " and " + tipoData + " BETWEEN '" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "' and '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'";

        condicaoFormaPag.append(" and  (tipo_fpag in (").append(formasPag).append(") or tipo_fpag is null) ");

        if (modelo.equals("1") || modelo.equals("2") || modelo.equals("6") || modelo.equals("8") || modelo.equals("9") || modelo.equals("4") || modelo.equals("7") || modelo.equals("12")) {
            planoCusto = (request.getParameter("idPlano").equals("0")) ? "" : " AND " + request.getParameter("idPlano") + " IN (SELECT planocusto_id FROM appropriations app WHERE d.sale_id = app.sale_id)";
        } else if (modelo.equals("5")) {
            planoCusto = (request.getParameter("idPlano").equals("0")) ? "" : " AND " + request.getParameter("idPlano") + " IN (SELECT planocusto_id FROM appropriations app WHERE bx.sale_id = app.sale_id)";
        } else if (modelo.equals("3")) {
            planoCusto = (request.getParameter("idPlano").equals("0")) ? "" : " AND " + request.getParameter("idPlano") + " IN (SELECT planocusto_id FROM appropriations app WHERE p.sale_id = app.sale_id)";
        }

        String sqlOrdenacao = request.getParameter("ordenacao");
        
        if (modelo.equals("1")){
            sqlTipoCobranca = "";
            sqlEmpresaCobranca = "";
            if (!Apoio.parseBoolean(request.getParameter("totalVencimento"))) {
                sqlOrdenacao = (Apoio.parseBoolean(request.getParameter("chkTotalFatura")) ? "ano_fatura,fatura," + sqlOrdenacao : sqlOrdenacao);
            }
        }else if (modelo.equals("2")){
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
            if (sqlOrdenacao.equals("dtvenc")) {
                sqlOrdenacao = "vencimento_fatura";
            } else if (sqlOrdenacao.equals("dtemissao")) {
                sqlOrdenacao = "dtemissao";
            } else if (sqlOrdenacao.equals("cliente")) {
                sqlOrdenacao = "cliente";
            } else if (sqlOrdenacao.equals("cidade_consignatario")) {
                sqlOrdenacao = "cidade_consignatario";
            } else {
                sqlOrdenacao = "fatura";
            }
        }else if (modelo.equals("3")){
            sqlTipoCobranca = "";
            sqlEmpresaCobranca = "";
            if (sqlOrdenacao.equals("cidade_consignatario")) {
                sqlOrdenacao = "cliente";
            }    
        }else if (modelo.equals("4")){
            sqlTipoCobranca = "";
            sqlEmpresaCobranca = "";
        }else if (modelo.equals("5")){
            sqlTipoCobranca = "";
            sqlEmpresaCobranca = "";
        }else if (modelo.equals("6")){
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
        }else if (modelo.equals("7")){
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
        }else if (modelo.equals("8")){
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
        }else if (modelo.equals("9")){
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
        }
        // 10-10-2013 Paulo
        BeanUsuario user = Apoio.getUsuario(request);
        int idVendedor = Apoio.parseInt(request.getParameter("idvendedor"));
        Collection<UsuarioVendedor> usuario = user.getItens();
        
        
        if(modelo.equals("3")){
           grupos =  (request.getParameter("grupos").equals("") ? "" : " and (cli.grupo_id " + 
                   excetoGrupo + " (" + request.getParameter("grupos") + ")" + (excetoGrupo.contains("NOT") ? " OR cli.grupo_id IS NULL " : "")+ ")");
        }else if(modelo.equals("5")){
           grupos =  (request.getParameter("grupos").equals("") ? "" : " and (bx.grupo_id " + 
                   excetoGrupo + " (" + request.getParameter("grupos") + ")" + (excetoGrupo.contains("NOT") ? " OR bx.grupo_id IS NULL " : "")+ ")");
        }else{
            grupos =  (request.getParameter("grupos").equals("") ? "" : " and (d.grupo_id " + 
                   excetoGrupo + " (" + request.getParameter("grupos") + ")" + (excetoGrupo.contains("NOT") ? " OR d.grupo_id IS NULL " : "")+ ")");
        }
        
//        if(modelo.equals("5")){
//         grupos = (request.getParameter("grupos").equals("") ? "" : " and (grupo_id " + 
//                excetoGrupo + " (" + request.getParameter("grupos") + ")" + (excetoGrupo.contains("NOT") ? " OR grupo_id IS NULL " : "")+ ")");
//        }else{
//         grupos = (request.getParameter("grupos").equals("") ? "" : " and (d.grupo_id " + 
//                excetoGrupo + " (" + request.getParameter("grupos") + ")" + (excetoGrupo.contains("NOT") ? " OR d.grupo_id IS NULL " : "")+ ")");
//        }
//        
        //param.put("VENDEDOR", (!request.getParameter("idvendedor").equals("0") ? " and vendedor_id =" + request.getParameter("idvendedor") : ""));
        /*
        vendedor = (usuario.isEmpty() && idVendedor == 0 ? " " : // Imprime tudo
                    !usuario.isEmpty() && idVendedor == 0 ? " and uv.usuario_id=" + user.getId() : // Imprime apenas os vendedores que estiverem na lista de usuarios
                    usuario.isEmpty() && idVendedor != 0 ? " and d.vendedor_id=" + idVendedor : // Imprime apenas o vendedor selecionado no filtro, quando a lista vazia
                    !usuario.isEmpty() && idVendedor != 0 ? " and (uv.usuario_id=" + user.getId() + " and d.vendedor_id=" + idVendedor + ")" : " "); // Imprime apenas o vendedor da lista, mesmo se for passado algum vendedor no filtro
            // o modelo 3 utiliza sales e o modelo 5 utiliza vbx_receber        
            if (modelo.equals("3")) {
                vendedor = (usuario.isEmpty() && idVendedor == 0 ? " " : // Imprime Tudo
                        !usuario.isEmpty() && idVendedor == 0 ? " and uv.usuario_id=" + user.getId() : // Imprime apenas os vendedores que estiverem na lista de usuarios
                        usuario.isEmpty() && idVendedor != 0 ? " and sl.vendedor_id=" + idVendedor : // Imprime apenas o vendedor selecionado no filtro, quando a lista vazia
                        !usuario.isEmpty() && idVendedor != 0 ? " and (uv.usuario_id=" + user.getId() + " and sl.vendedor_id=" + idVendedor + ")" : " "); // Imprime apenas o vendedor da lista, mesmo se for passado algum vendedor no filtro
            } else if (modelo.equals("5")) {
                vendedor = (usuario.isEmpty() && idVendedor == 0 ? " " : // Imprime Tudo
                        !usuario.isEmpty() && idVendedor == 0 ? " and uv.usuario_id=" + user.getId() : // Imprime apenas os vendedores que estiverem na lista de usuarios
                        usuario.isEmpty() && idVendedor != 0 ? " and bx.vendedor_id=" + idVendedor : // Imprime apenas o vendedor selecionado no filtro, quando a lista vazia
                        !usuario.isEmpty() && idVendedor != 0 ? " and (uv.usuario_id=" + user.getId() + " and bx.vendedor_id=" + idVendedor + ")" : " "); // Imprime apenas o vendedor da lista, caso esteja na lista
            }
         */
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
//                    vendedor = " AND vendedor_id IN ('" + -9 + "') ";
                    vendedor = "";
                }else{
                    vendedor = " AND vendedor_id IN ('" + ids + "') ";
                }
                vendedor += (!request.getParameter("idvendedor").equals("0") ? " and vendedor_id =" + request.getParameter("idvendedor") : "");
            }else{
                vendedor = (!request.getParameter("idvendedor").equals("0") ? " and vendedor_id =" + request.getParameter("idvendedor") : "");
            }
            
        java.util.Map param = new java.util.HashMap(20);
        param.put("VENDEDOR", vendedor);
        param.put("PLANO_CUSTO", planoCusto);//Verifica se vai separar por data

        param.put("MOSTRA_TOTAL_VENCIMENTO", new Boolean(request.getParameter("totalVencimento")));
        if (request.getParameter("modelo").equals("2") || request.getParameter("modelo").equals("9") || request.getParameter("modelo").equals("12")) {
            param.put("TIPO_DATA", tipoData);
            param.put("FILIAL_RECEBEDORA", (!request.getParameter("idfilialrecebedora").equals("0") ? "and filial_cobranca_id=" + request.getParameter("idfilialrecebedora") : ""));
            param.put("CONTA", conta);
            param.put("TIPO_RELATORIO", request.getParameter("tipoRelatorio"));
        } else if (request.getParameter("modelo").equals("3")) {
            param.put("TIPO_DATA", tipoData);
            param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
            param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
            param.put("TIPO_FPAG", (request.getParameter("modalidade").equals("a") ? "" : " AND ct.tipo_fpag='" + request.getParameter("modalidade") + "'"));
            //Verificando se vai filtrar apenas uma filial
            param.put("FILIAL_RECEBEDORA", (!request.getParameter("idfilialrecebedora").equals("0") ? "and filial_recebedora_id=" + request.getParameter("idfilialrecebedora") : ""));
        } else if (request.getParameter("modelo").equals("5")) {
            param.put("TIPO_DATA", tipoData);
            param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
            param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
            param.put("TIPO_FPAG", (request.getParameter("modalidade").equals("a") ? ""
                    : (request.getParameter("modalidade").equals("v") ? " AND ct.tipo_fpag='" + request.getParameter("modalidade") + "'"
                    : (request.getParameter("modalidade").equals("p") ? " AND ct.tipo_fpag='" + request.getParameter("modalidade") + "' AND fatura_id is null "
                    : " AND ct.tipo_fpag='p' AND fatura_id is not null "))));
            //Verificando se vai filtrar apenas uma filial
            
        }else if(modelo.equals("6")){
            param.put("TIPO_DATA", tipoData);
            param.put("IS_BAIXADO", isBaixados);
            param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
            param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        }else if (modelo.equals("8")) {
            
            param.put("TIPO_DATA", tipoData);
            param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
            param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
            param.put("IS_BAIXADO", isBaixados);
        }
        else {
            param.put("TIPO_DATA", tipoData);
            param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
            param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        }

        
        param.put("CLIENTE", cliente);
        param.put("FILIAL", filial.toString());
        param.put("FATURA", fatura);
        param.put("ANO_FATURA", anofatura);
        param.put("DATA", data);
        situacao = request.getParameter("situacao");
        param.put("SITUACAO", (situacao.equals("") ? "" : " AND situacao in (" + situacao + ") "));
        param.put("ORDENACAO", sqlOrdenacao);
        param.put("SERIE", (request.getParameter("serie").equals("") ? "" : " and serie='" + request.getParameter("serie") + "'"));
     
        
        param.put("FORMA_PAGAMENTO", condicaoFormaPag.toString());
        param.put("BAIXADOS_POSTERIOR", mostraBaixadosApos);
        if (request.getParameter("modelo").equals("1") || request.getParameter("modelo").equals("11")) {
            param.put("MOSTRAR_TOTAL_FATURA", new Boolean(request.getParameter("chkTotalFatura")));
        }
         
        param.put("TIPO_COBRANCA", sqlTipoCobranca);
        param.put("EMPRESA_COBRANCA", sqlEmpresaCobranca);
//        chkCte chkNfs chkReceita
        String mostrar = request.getParameter("mostrar");
        String sqlMostrar = " AND categoria in ("+mostrar.substring(0,mostrar.length()-1) + ")";
        param.put("MOSTRAR",sqlMostrar);
        
        
        tipoFretes = request.getParameter("tipo_frete");
        int con = Integer.parseInt(request.getParameter("count"));
        int outros = Integer.parseInt(request.getParameter("novoCount"));        
        if(modelo.equals("3")){
            if(con == 0 && outros >= 1){
                param.put("TIPOFRETES", (tipoFretes.equals("") ? "" : " AND sl.consignatario_id IN (" + tipoFretes + ")" ));
            }else if(con == 1 && outros == 0 ){
                param.put("TIPOFRETES", (tipoFretes.equals("") ? "" : " AND sl.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,coalesce(ct.redespacho_id,0)) " ));
            }else if(con == 1 && outros >= 1){
                param.put("TIPOFRETES", (tipoFretes.equals("") ? "" : " AND (sl.consignatario_id IN (" + tipoFretes + ") OR sl.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,coalesce(ct.redespacho_id,0)) )" ));
            }            
        }else{
            param.put("TIPOFRETES", (tipoFretes.equals("") ? "" : " AND tipo_frete IN (" + tipoFretes + ") "));
        }
        String condicaoFaturamento = "";        
        String faturamento = "";
        String tipoOpções = "";
        
        if(modelo.equals("10")){
            String anoSelecionado = request.getParameter("selectAno");
            String mesSelecionado = request.getParameter("selectMes");
            boolean anual = Apoio.parseBoolean(request.getParameter("anual"));
            boolean decendio = Apoio.parseBoolean(request.getParameter("decendio"));
            boolean mensal = Apoio.parseBoolean(request.getParameter("mensal"));
            
            if(anual){
                condicaoFaturamento = "";                
                faturamento = "anual";
                anoSelecionado = "";
                tipoOpções = "Faturamento Anual";
            }
            if(decendio){
                condicaoFaturamento = "and extract(year from dtemissao)="+anoSelecionado+" and extract(month from dtemissao)="+mesSelecionado+"";
                faturamento = "decendio";
                tipoOpções = "Faturamento Decendio - Ano: " + anoSelecionado + " Mês: " + mesSelecionado;
            }
            if(mensal){
                condicaoFaturamento = "and extract(year from dtemissao)="+anoSelecionado+"";
                faturamento = "mensal";
                tipoOpções = "Faturamento Mensal - Ano: " + anoSelecionado;
            }
            param.put("CONDICAO_FATURAMENTO", condicaoFaturamento);
            param.put("ANO", anoSelecionado);
            param.put("FATURAMENTO", faturamento);            
        }else{
            tipoOpções = request.getParameter("tipodata").equals("dtemissao") ? "Emissao entre: " : "Vencimento entre: ";
            tipoOpções += (request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal"));
        }
        
        
        param.put("OPCOES", tipoOpções);
        param.put("GRUPOS", grupos);
        param.put("REMETENTE_ID", request.getParameter("idremetente"));
        param.put("DESTINATARIO_ID", iddestinatario);
        param.put("TIPO_DATA_BAIXADO", request.getParameter("tipodataBaixado"));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        //param.put("CONDICAO_REMETENTE", idsRemetente.isEmpty() ? "" : " and remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
        if (modelo.equals("5")) {
            param.put("CONDICAO_REMETENTE", idsRemetente.isEmpty() ? "" : " and ct.remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("CONDICAO_DESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and ct.destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        } else if (modelo.equals("11")) {
            param.put("REMETENTE_CONDICAO", idsRemetente.isEmpty() ? "" : " and remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("DESTINATARIO_CONDICAO", idsDestinatarios.isEmpty() ? "" : " and destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
        } else {
            param.put("CONDICAO_REMETENTE", idsRemetente.isEmpty() ? "" : " and remetente_id " + ("<>".equals(request.getParameter("apenasRemetente")) ? " NOT " : "") + " IN (" + String.join(",", idsRemetente) + ")");
            param.put("CONDICAO_DESTINATARIO", idsDestinatarios.isEmpty() ? "" : " and destinatario_id " + ("<>".equals(request.getParameter("apenasDestinatario")) ? " NOT " : "") + " IN (" + String.join(",", idsDestinatarios) + ")");
       
        }
        if(modelo.equals("11")){
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            condicaoFormaPag.append(" and  (tipo_fpag in (").append(formasPag).append(") or tipo_fpag is null) ");
            situacao = request.getParameter("situacao");
            
            //comentando a linha abaixo pois foi dito que não é para ter essa ordenação modelo 11
//            param.put("ORDENACAO", sqlOrdenacao);
            param.put("CLIENTE_ID", Apoio.parseInt(request.getParameter("idconsignatario")));
            param.put("APENAS_CLIENTE", request.getParameter("excetoCliente"));
            param.put("PLANO_CUSTO", Apoio.parseInt(request.getParameter("idPlano")));
            param.put("VENDEDOR", Apoio.parseInt(request.getParameter("idvendedor")));
            param.put("TIPOFRETES", tipoFretes);
            param.put("FILIAL", filial.toString());
            
            param.put("SITUACAO", (situacao.equals("") ? "" : " AND situacao in (" + situacao + ") "));
            param.put("FORMA_PAGAMENTO", condicaoFormaPag.toString());
            param.put("EMPRESA_COBRANCA", sqlEmpresaCobranca);
            param.put("TIPO_COBRANCA", sqlTipoCobranca);
        }
        
        if (modelo.equals("12")){
            sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
            sqlEmpresaCobranca = (empresaCobrancaId.equals("0") ? "" : " AND empresa_cobranca_id = " + empresaCobrancaId);
            if (sqlOrdenacao.equals("dtvenc")) {
                sqlOrdenacao = "vencimento_fatura";
            } else if (sqlOrdenacao.equals("dtemissao")) {
                sqlOrdenacao = "dtemissao";
            } else if (sqlOrdenacao.equals("cliente")) {
                sqlOrdenacao = "cliente";
            } else if (sqlOrdenacao.equals("cidade_consignatario")) {
                sqlOrdenacao = "cidade_consignatario";
            } else {
                sqlOrdenacao = "fatura";
            }
        }
        

        idCidade = (request.getParameter("idCidade") == null || request.getParameter("idCidade").equals("") ? "0" : request.getParameter("idCidade"));
        
        param.put("ID_CIDADE", idCidade);
        
        request.setAttribute("map", param);
        request.setAttribute("rel", "contasrecebermod" + request.getParameter("modelo"));

        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispacher.forward(request, response);
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CONTAS_RECEBER_E_RECEBIDAS_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">
    
    var homePath = '${homePath}';
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
        $("modelo10").checked = false;
        $("modelo11").checked = false;
        $("modelo12").checked = false;

        $("trfilial_recebedora").style.display = "none";
        $("modalidade").style.display = "none";
        $("divSituacao").style.display = "none";
        $("divFormaPagamento").style.display = "none";
        $("trConta").style.display = "none";
        $("trMostrarQuitadas").style.display = "none";
    
        $("modelo"+modelo).checked = true;
    
        if(modelo=='1'){
            $("trTotalVencimento").style.display = "";
            $("divSituacao").style.display = "";
            $("divFormaPagamento").style.display = "";
            $("trMostrarQuitadas").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("spfatura").style.display = "";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
            
        }else if (modelo == '6' || modelo == '7' || modelo == '8'){
            $("trTotalVencimento").style.display = "";
            $("divSituacao").style.display = "";
            $("divFormaPagamento").style.display = "";
            $("trMostrarQuitadas").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("spfatura").style.display = "";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if (modelo == '2'){
            $("trfilial_recebedora").style.display = "";
            $("trTotalVencimento").style.display = "";
            $("divSituacao").style.display = "";
            $("divFormaPagamento").style.display = "";
            $("trConta").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("spfatura").style.display = "none";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if (modelo == '3'){
            $("trfilial_recebedora").style.display = "";
            $("modalidade").style.display = "";
            $("trTotalVencimento").style.display = "none";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if (modelo == '4' || modelo == '6'){
            $("divFormaPagamento").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if(modelo == '5'){
            $("modalidade").style.display = "";
            $("trTotalVencimento").style.display = "none";
            $("divFormaPagamento").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if (modelo == '9'){
            $("trfilial_recebedora").style.display = "";
            $("trTotalVencimento").style.display = "";
            $("divSituacao").style.display = "";
            $("divFormaPagamento").style.display = "";
            $("trConta").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("spfatura").style.display = "";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if(modelo == '10'){
            $("faturamento").style.display = "";
            $("camposFaturamento").style.display = "";
            $("selecttipodata").style.display = "none";
            $("lbtipodata").style.display = "none";
            $("trTotalVencimento").style.display = "none";
            $("trTotalFatura").style.display = "none";
            $("lbplanoCusto").style.display = "none";
            $("planoCusto").style.display = "none";
            $("lbApenasFatura").style.display = "none";
            $("apenasFatura").style.display = "none";
            $("lbApenasSerie").style.display = "none";
            $("apenasSerie").style.display = "none";
            $("tdModalidade").style.display = "none";
            $("lbApenasFrete").style.display = "none";
            $("apenasFrete").style.display = "none";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";            
            if(!$("anual").checked && !$("decendio").checked && !$("mensal").checked){
                $("anual").checked = true;                
            }
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }else if(modelo == '11'){
            $("trTotalFatura").style.display = "none";
            $("trTotalVencimento").style.display = "none";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("trOrdenacaoLabel").style.display = "none";
            $("trOrdenacao").style.display = "none";
            //-------------------------------
            $("divSituacao").style.display = "";
            $("divFormaPagamento").style.display = "";
            $("trMostrarQuitadas").style.display = "";
        }else if (modelo == '12'){
            $("trfilial_recebedora").style.display = "";
            $("trTotalVencimento").style.display = "";
            $("divSituacao").style.display = "";
            $("divFormaPagamento").style.display = "";
            $("trConta").style.display = "";
            $("faturamento").style.display = "none";
            $("selecttipodata").style.display = "";
            $("lbtipodata").style.display = "";
            $("faturamento").style.display = "none";
            $("camposFaturamento").style.display = "none";
            $("lbplanoCusto").style.display = "";
            $("planoCusto").style.display = "";
            $("lbApenasFatura").style.display = "";
            $("apenasFatura").style.display = "";
            $("lbApenasSerie").style.display = "";
            $("apenasSerie").style.display = "";
            $("tdModalidade").style.display = "";
            $("lbApenasFrete").style.display = "";
            $("apenasFrete").style.display = "";
            $("imgGrupo").style.display = "";
            $("selectGrupo").style.display = "";
            $("spfatura").style.display = "none";
            $("trTotalFatura").style.display = "none";
            $("trOrdenacaoLabel").style.display = "";
            $("trOrdenacao").style.display = "";
        }

    }
    

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizaremetente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Remetente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizadestinatario(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=4','Destinatario',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizavendedor(){
        post_cat = window.open('./localiza?acao=consultar&idlista=27&paramaux=1','Vendedor','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparcliente(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }
    
    function limparremetente(){
        $("idremetente").value = "0";
        $("rem_rzs").value = "";
    }

    function limpardestinatario(){
        $("iddestinatario").value = "0";
        $("dest_rzs").value = "";
    }
    
    function limparvendedor(){
        $('idvendedorselecionado').value = "0";
        $('vend_rzs').value = "";
    }
    
    function changeValue(){
        if($("chkTotalFatura").checked == true){
            alert("alterando para true")
            $("chkTotalFatura").value = true;
        }else{
            alert("alterando para false")
            $("chkTotalFatura").value = false;
        }
    }

    function popRel(){
        var modelo; 
        var grupos = getGrupos();
        var tipoRelatorio = "";
        if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value)){
            alert ("Informe o intervalo de datas corretamente.");
        }else{
            
            if($("chkCte").checked == false && $("chkNfs").checked == false && $("chkReceita").checked == false && $("chkVendaVeiculo").checked == false){
                alert("É necessário selecionar uma das opções: CT-e(s)/Minutas , NFS-e , Receita Financeira ou Venda de Veículo ");
                return false;
            }
            if ($("modelo1").checked){
                modelo = '1';
            }else if ($("modelo2").checked){
                modelo = '2';
            }else if ($("modelo3").checked){
                modelo = '3';
            }else if ($("modelo4").checked){
                modelo = '4'; 
            }else if ($("modelo5").checked){
                modelo = '5'; 
            }else if ($("modelo6").checked){
                modelo = '6'; 
            }else if ($("modelo7").checked){
                modelo = '7';
            }else if ($("modelo8").checked){
                modelo = '8';
            }else if ($("modelo9").checked){
                modelo = '9';
                if($('analiticoMod9').checked){
                    tipoRelatorio = $('analiticoMod9').value;
                }else if($('sinteticoMod9').checked){
                    tipoRelatorio = $('sinteticoMod9').value;
                }
            }
            else if ($("modelo10").checked)
                modelo = '10';
            else if ($("modelo11").checked)
                modelo = '11';
            else if ($("modelo12").checked)
                modelo = '12';
                
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";

            var situacao = "";
            //Verificando as situações
            if ($('chksem').checked){
                situacao = "''";
            }
            if ($('chknomais').checked){
                situacao += (situacao == "" ? "" : ",") + "'NM'";
            }
            if ($('chkcartorio').checked){
                situacao += (situacao == "" ? "" : ",") + "'TC'";
            }
            if ($('chkdescontadas').checked){
                situacao += (situacao == "" ? "" : ",") + "'DT'";
            }
            if ($('chkdevedoras').checked){
                situacao += (situacao == "" ? "" : ",") + "'DE'";
            }

            //verificando as formas de pagamento
            var formPag = "";
            formPag = "''";
            if ($('isAvista').checked){
                formPag  += (formPag  == "" ? "" : ",") + "'v'";
            }
            if ($('isAPrazo').checked){
                formPag  += (formPag  == "" ? "" : ",") + "'p'";
            }
            if ($('isConta').checked){
                formPag += (formPag == "" ? "" : ",") + "'c'";
            }
                    
            var tipoCobranca;
            if ($('tipoCobranca1').checked){
                tipoCobranca = '';
            }else if ($('tipoCobranca2').checked){
                tipoCobranca = 'c';
            }else{
                tipoCobranca = 'b';
            }                
            //apenas os fretes
            var tipoFretes = "";
            // variavéis criadas para o tipo CON que utiliza uma condição diferente - "AND sl.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,ct.redespacho_id)";
            var count;
            var novoCount; 
            if(modelo == '3'){
                tipoFretes = "";
                count = 0;
                novoCount = 0;
                if($('chkcif').checked){
                    novoCount++;
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "ct.remetente_id";    
                }                              
                if($('chkfob').checked){
                    novoCount++;
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "ct.destinatario_id";                        
                }
                if($('chkred').checked){
                    novoCount++;
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "ct.redespacho_id";                        
                } 
                if($('chkcon').checked){                    
                    count++;
                    if(count == 1 && novoCount == 0){
                        tipoFretes += (tipoFretes == "" ? "" : " ") + "AND sl.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,ct.redespacho_id)";
                    }                    
                }
                     
            }else{
                tipoFretes = "''";
                count = 0;
                novoCount = 0;
                if($('chkcif').checked){
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "'CIF'";
                }
                if($('chkcon').checked){
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "'CON'";
                }
                if($('chkfob').checked){
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "'FOB'";                
                }
                if($('chkred').checked){
                    tipoFretes += (tipoFretes == "" ? "" : ",") + "'RED'";
                }     
            }
            
            var mostrar = "";
            if($("chkCte").checked == true){mostrar += "'ct',";}
            if($("chkNfs").checked == true){mostrar += "'ns',";}
            if($("chkReceita").checked == true){mostrar += "'fn',";}
            if($("chkVendaVeiculo").checked == true){mostrar += "'vv',";}
            launchPDF('./relcontasreceber?acao=exportar&modelo='+modelo+'&impressao='+impressao+
                '&idconsignatario='+$("idconsignatario").value+'&idfilial='+$("idfilialemissao").value+
                '&idfilialentrega='+$("idfilialentrega").value+
                '&idfilialcobranca='+$("idfilialcobranca").value+
                '&fatura='+$("fatura").value+'&anofatura='+$("anofatura").value+
                '&tipodata='+$("tipodata").value+
                '&tipodataBaixado='+$("tipodataBaixado").value+
                '&dtinicial='+$("dtinicial").value+'&dtfinal='+$("dtfinal").value+
                '&excetoCliente='+$("excetoCliente").value+'&excetoGrupo='+$("excetoGrupo").value+
                '&serie='+$("serie").value+'&modalidade='+$("modalidade").value+
                '&idfornecedor='+$("idfornecedor").value+
                '&idremetente='+$("idremetente").value+
                '&iddestinatario='+$("iddestinatario").value+
                '&ordenacao='+$("ordenacao").value+'&idfilialrecebedora='+$("idfilialrecebedora").value+
                '&grupos='+grupos+'&totalVencimento='+$("totalVencimento").checked+'&chkabertodia='+$("chkabertodia").checked+
                '&situacao='+situacao+'&idvendedor='+$("idvendedorselecionado").value+'&conta='+$("conta").value+"&formasPagamento="+formPag+"&idPlano="+$("idplanocusto").value+
                '&chkTotalFatura='+$("chkTotalFatura").checked+
                '&tipoCobranca='+tipoCobranca+'&tipo_frete='+tipoFretes+'&count='+count+'&novoCount='+novoCount+'&anual='+$('anual').checked+
                '&decendio='+$('decendio').checked+'&mensal='+$('mensal').checked+'&selectAno='+$("selectAno").value+
                '&selectMes='+$('selectMes').value+'&tipoRelatorio='+tipoRelatorio+
                '&mostrar='+mostrar+"&idCidade="+$("idCidade").value+'&con_rzs='+encodeURIComponent($("con_rzs").value)+'&apenasRemetente='+$("apenasRemetente").value+'&rem_rzs='+encodeURIComponent($("rem_rzs").value)+'&apenasDestinatario='+$("apenasDestinatario").value+'&dest_rzs='+encodeURIComponent($("dest_rzs").value));
        }
    }

    function aoClicarNoLocaliza(idjanela){
        
        if (idjanela == "Grupo"){
            addGrupo($('grupo_id').value,'node_grupos', getObj('grupo').value);
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
        }else if (idjanela == "Filial_recebedora"){
            $('idfilialrecebedora').value = getObj('idfilial').value;
            $('filial_recebedora').value = getObj('fi_abreviatura').value;
        }else if(idjanela == "Cidade_Destino"){
            $("cidade").value = $("cid_destino").value;
            $("idCidade").value = $("idcidadedestino").value;
            $("ufCidade").value = $("uf_destino").value;
        }
        
        if (idjanela == "Vendedor"){
            $('vend_rzs').value = getObj('ven_rzs').value;
            $('idvendedorselecionado').value = getObj('idvendedor').value;
        }
    }
  
    function localizaPlanoCusto(){
        post_cad = window.open('./localiza?acao=consultar&idlista=13','Plano_de_Custo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
  
    function limparPlanoCusto(){
        document.getElementById("idplanocusto").value = 0;
        document.getElementById("plcusto_conta").value = "";
        document.getElementById("plcusto_descricao").value = "";
    }

    function localizaforn(){
     	post_cad = window.open('./localiza?acao=consultar&idlista=21','Fornecedor',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparforn(){
        document.getElementById("idfornecedor").value = "0";
        document.getElementById("fornecedor").value = "Todas";
    }
    
    function selecionarTipoFaturamento(tipo){
            $("anual").checked = false;
            $("decendio").checked = false;
            $("mensal").checked = false;                  
            $(tipo).checked = true;
            if($("anual").checked){
                $("camposAnual").style.display = "none";
                $("camposDecendio").style.display = "none";
                $("selectMes").style.display = "none";
            }
            if($("decendio").checked){
                $("camposAnual").style.display = "";
                $("camposDecendio").style.display = "";
                $("selectMes").style.display = "";
            }
            if($("mensal").checked){
                $("camposAnual").style.display = "";
                $("camposDecendio").style.display = "none";
                $("selectMes").style.display = "none";
            }
    }
    
    function localizarCidade(){
        post_cad = window.open('./localiza?&acao=consultar&idlista=12','Cidade_Destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function limparCidade(){
        $("cidade").value = "";
        $("ufCidade").value = "";
        $("idCidade").value = "0";
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

        <title>Webtrans - Relatório de contas a receber</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
        <link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
    </head>

    <body onLoad="applyFormatter();modelos(1);AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');
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
            <input type="hidden" name="idfilialrecebedora" id="idfilialrecebedora" value="0">
            <input type="hidden" name="idvendedorselecionado" id="idvendedorselecionado" value="0">
            <input type="hidden" name="idvendedor" id="idvendedor" value="0">
            <input type="hidden" name="ven_rzs" id="ven_rzs" value="">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
            <input type="hidden" name="cid_destino" id="cid_destino" value="">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
            <input type="hidden" name="uf_destino" id="uf_destino" value="">
            <input type="hidden" name="idFilialUsuario" id="idFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="descFilialUsuario" id="descFilialUsuario" value="<%=(Apoio.getUsuario(request).getFilial().getAbreviatura())%>">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de contas a receber</b></td>
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
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    duplicatas em aberto com o número e tipo da fatura</td>
            </tr>
            <tr> 
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    faturas em aberto</td>
            </tr>
            <tr> 
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o dos CT-e(s)  por filial recebedora </td>
            </tr>
            <tr> 
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das duplicatas em aberto por contrato de frete emitida</td>
            </tr>
            <tr> 
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das duplicatas em aberto por tipo de pagamento</td>
            </tr>
            <tr> 
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo5" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                        Modelo 6 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das
                    duplicatas em aberto, com dados do CT-e</td>
            </tr>
            <tr>
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo5" id="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                        Modelo 7 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    duplicatas em aberto por cliente</td>
            </tr>
            <tr>
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo8" id="modelo8" type="radio" value="8" onClick="javascript:modelos(8);">
                        Modelo 8 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    duplicatas em aberto</td>
            </tr>
            <tr>
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo9" id="modelo9" type="radio" value="9" onClick="javascript:modelos(9);">
                        Modelo 9 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das faturas em aberto agrupadas por cliente
                    <input type="radio" name="tipoRelatorio" id="analiticoMod9" value="a" checked="true"/>Analítico
                    <input type="radio" name="tipoRelatorio" id="sinteticoMod9" value="s"/>Sintético
                </td>
            </tr>
            <tr>
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo10" id="modelo10" type="radio" value="10" onClick="javascript:modelos(10);">
                        Modelo 10 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2">Resumo de contas a receber</td>
            </tr>
            <tr>
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo11" id="modelo11" type="radio" value="11" onClick="javascript:modelos(11);">
                        Modelo 11 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2">Relação de contas a receber por cliente (Sintético).</td>
            </tr>
            <tr>
                <td width="20%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo12" id="modelo12" type="radio" value="12" onClick="javascript:modelos(12);">
                        Modelo 12 </div></td>
                <td width="80%" colspan="2" class="CelulaZebra2">Relação das faturas em aberto com relacionamentos.</td>
            </tr>
            <tr class="tabela"> 
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos" style="display: " id="lbtipodata">Por data de:</td>
                <td colspan="2" class="CelulaZebra2" style="display: " id="selecttipodata"> 
                    <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="dtemissao">Emissão</option>
                        <option value="dtvenc" selected>Vencimento</option>
                    </select>
                    entre<strong> 
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong> 
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                               onblur="alertInvalidDate(this);$('lbDataFinal').innerHTML = this.value;" class="fieldDate" />
                    </strong></td>
            </tr>
            <tr>
                <td class="CelulaZebra2" id="faturamento" style="display: none" >
                    <input type="radio" id="anual" name="anual" class="inputtexto" value="" onclick="javascript:selecionarTipoFaturamento('anual');" /><label class="TextoCampos">Anual</label>
                    <input type="radio" id="decendio" name="decendio" class="inputtexto" value="" onclick="javascript:selecionarTipoFaturamento('decendio');" /><label class="TextoCampos">Decêndio</label>
                    <input type="radio" id="mensal" name="mensal" class="inputtexto" value="" onclick="javascript:selecionarTipoFaturamento('mensal');" /><label class="TextoCampos">Mensal</label>
                </td>
                <td class="CelulaZebra2" id="camposFaturamento" name="camposFaturamento" colspan="2" style="display: none">
                    <div id="camposDecendio" style="display: none; float: left">
                        <select class="inputtexto" id="selectMes">
                            <option value="1" selected>Janeiro</option>
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
                        </select>
                    </div>                    
                    <div id="camposAnual" style="display: none">
                        <select class="inputtexto" id="selectAno">
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
                            <option value="2013">2013</option>
                            <option value="2014" selected>2014</option>
                            <option value="2015">2015</option>
                            <option value="2016">2016</option>
                            <option value="2017">2017</option>
                            <option value="2018">2018</option>
                            <option value="2019">2019</option>
                            <option value="2020">2020</option>
                            <option value="2020">2021</option>
                            <option value="2020">2022</option>
                            <option value="2020">2023</option>
                            <option value="2020">2024</option>
                            <option value="2020">2025</option>
                            <option value="2020">2026</option>
                            <option value="2020">2027</option>
                            <option value="2020">2028</option>
                            <option value="2020">2029</option>
                            <option value="2020">2030</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr >
                <td height="24" colspan="3"   width="50%" class="TextoCampos" name="trTotalVencimento" id="trTotalVencimento">
                    <div align="center">
                        <input name="totalVencimento" type="checkbox" id="totalVencimento" value="checkbox" checked>
                        Totalizar por data de vencimento
                    </div></td>

            </tr>
            <tr>
                <td colspan="3" class="TextoCampos" name="trTotalFatura" id="trTotalFatura" width="50%"><div align="center" >
                        <input type="checkbox" name="chkTotalFatura" id="chkTotalFatura"  value="check">     
                        Totalizar pelo número da fatura
                    </div>
                </td>
            </tr>
            <tr class="tabela"> 
                <td height="18" colspan="3"> <div align="center">Filtros</div></td>
            </tr>
            <tr> 
                <td colspan="3"> <table width="100%" height="81" border="0" >
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
                        <tr id="trfilial_recebedora" name="filial_recebedora" style="display:none;">
                            <td class="TextoCampos">Apenas a filial recebedora: </td>
                            <td colspan="2" class="CelulaZebra2"><strong>
                                    <input name="filial_recebedora" type="text" id="filial_recebedora" class="inputReadOnly" size="20" maxlength="60" readonly="true">
                                    <% if (temacessofiliais) {%>
                                    <input name="localiza_filial" type="button" class="inputBotaoMin" id="localiza_filial" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=8','Filial_recebedora','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilialrecebedora').value = 0; $('filial_recebedora').value = '';">
                                    <%}%>
                                </strong></td>
                        </tr>
                        <tr> 
                            <td width="35%"  class="TextoCampos"><div align="right">
                                    <select name="excetoCliente" id="excetoCliente" class="inputtexto">
                                        <option value="=" selected>Apenas o cliente</option>
                                        <option value="<>">Exceto o cliente</option>                                        
                                    </select>
                                    :</div></td>
                            <td colspan="2"  class="TextoCampos"><div align="left"><strong> 
                                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_cliente" type="button" class="inputBotaoMin" id="localiza_cliente" value="..." onClick="abrirLocalizarCliente('con_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="removerValorInput('con_rzs');">
                                    </strong></div></td>
                        </tr>
                        <tr> 
                            <td width="35%"  class="TextoCampos"><div align="right">
                                    <select name="apenasRemetente" id="apenasRemetente" class="inputtexto">
                                        <option value="=" selected>Apenas o Remetente</option>
                                        <option value="<>">Exceto o Remetente</option>
                                    </select>
                                </div></td>
                            <td colspan="2"  class="TextoCampos"><div align="left"><strong> 
                                        <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_remetente" type="button" class="inputBotaoMin" id="localiza_remetente" value="..." onClick="abrirLocalizarCliente('rem_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar remetente" onClick="removerValorInput('rem_rzs');">
                                    </strong></div></td>
                        </tr>
                        <tr> 
                            <td width="35%"  class="TextoCampos"><div align="right">
                                    <select name="apenasDestinatario" id="apenasDestinatario" class="inputtexto">
                                        <option value="=" selected> Apenas o Destinatario </option>
                                        <option value="<>"> Exceto o Destinatario </option>
                                </div></td>
                            <td colspan="2"  class="TextoCampos"><div align="left"><strong> 
                                        <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_destinatario" type="button" class="inputBotaoMin" id="localiza_destinatario" value="..." onClick="abrirLocalizarCliente('dest_rzs');">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar destinatario" onClick="removerValorInput('dest_rzs');">
                                    </strong></div></td>
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
                            <td class="TextoCampos" id="lbplanoCusto" style="display: "><div align="right">Apenas um Plano de Custo:</div></td>
                            <td class="TextoCampos" colspan="2" id="planoCusto" style="display: none">
                                <div align="left">
                                    <strong>
                                        <input name="plcusto_conta" type="text" id="plcusto_conta" value="" class="inputReadOnly" size="8" maxlength="60" readonly="true">
                                        <input name="plcusto_descricao" type="text" id="plcusto_descricao" value="" class="inputReadOnly" size="23" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_planoCusto" type="button" class="inputBotaoMin" id="planoCusto" value="..." onClick="javascript:localizaPlanoCusto();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Plano de Custo" onClick="javascript:limparPlanoCusto();"> 
                                        <%}%>
                                    </strong>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas a cidade do Cliente:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="text" id="cidade" name="cidade" value="" class="inputReadOnly" size="20" maxlength="20" readonly="true"/>
                                <input type="text" id="ufCidade" name="ufCidade" value="" class="inputReadOnly" size="3" maxlength="10" readonly="true" />                                
                                <input type="hidden" id="idCidade" name="idCidade" value="0" />                                
                                <input name="localiza_cidadeDestino" type="button" class="inputBotaoMin" id="localiza_cidadeDestino" value="..." onclick="javascript:tryRequestToServer(function(){localizarCidade();});" />
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onclick="javascript:limparCidade();"> 
                            </td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos" id="lbApenasFatura" style="display: ">Apenas a fatura:</td>
                            <td colspan="2" class="TextoCampos" id="apenasFatura" style="display: ">
                                <div align="left">
                                    <strong> 
                                        <input name="fatura" type="text" id="fatura" size="10" maxlength="8" class="inputtexto">
                                        <font size="3">/</font> 
                                        <input name="anofatura" type="text" id="anofatura" size="8" maxlength="4" class="inputtexto">
                                    </strong>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" id="lbApenasSerie" style="display: ">Apenas a s&eacute;rie: </td>
                            <td width="17%" class="CelulaZebra2" id="apenasSerie" style="display: ">
                                <strong>
                                    <input name="serie" type="text" id="serie" size="2" maxlength="3" class="inputtexto">
                                </strong>
                            </td>
                            <td width="48%" class="CelulaZebra2" id="tdModalidade" style="display: ">
                                <select name="modalidade" id="modalidade" style="display:none " class="inputTexto">
                                    <option value="a">Ambos</option>
                                    <option value="v" selected>Apenas &agrave; vista</option>
                                    <option value="p">Apenas &agrave; prazo (Não Faturados)</option>
                                    <option value="pf">Apenas &agrave; prazo (Faturados)</option>
                                </select>
                            </td>
                        </tr>
                        <tr id="trConta" style="display:none">
                            <td class="TextoCampos"><div id="divConta" >Apenas a conta: </div></td>
                            <td class="CelulaZebra2" colspan="2">
                                <select id="conta" name="conta" class="inputtexto">
                                    <option value="0" selected> Todas </option>
                                    <%BeanConsultaConta contas = new BeanConsultaConta();
                                        contas.setConexao(Apoio.getUsuario(request).getConexao());
                                        contas.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarContas, idUsuario);
                                        ResultSet rsconta = contas.getResultado();
                                        while (rsconta.next()) {%>
                                    <option value="<%=rsconta.getString("idconta")%>" ><%=rsconta.getString("numero")%> - <%=rsconta.getString("banco")%></option>
                                    <%}%>
                                </select>
                            </td>
                        </tr>
                        <tr id="divSituacao" name="divSituacao">
                            <td class="TextoCampos">Apenas as faturas:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <span id="spfatura" name="smfatura">
                                    <input type="checkbox" name="chksem" id="chksem" value="SEM" checked>CTs/NFS sem fatura gerada<br>
                                </span>
                                <input type="checkbox" name="chknomais" id="chknomais" value="NM" checked>Normais<br>
                                <input type="checkbox" name="chkcartorio" id="chkcartorio" value="TC" checked>Cartório<br>
                                <input type="checkbox" name="chkdescontadas" id="chkdescontadas" value="DT" checked>Descontadas<br>
                                <input type="checkbox" name="chkdevedoorderas" id="chkdevedoras" value="DE" checked>Devedoras
                                <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
                                &nbsp; Empresa de Cobrança:
                                <input name="fornecedor" type="text" id="fornecedor" size="15" maxlength="80" readonly="true" class="inputReadOnly" value="Todas">
                                <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" value="..." onClick="javascript:localizaforn();">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparforn();"> 
                                <br>
                                <input name="tipoCobranca" id="tipoCobranca1" type="radio" value="a" checked="">Todos os tipos
                                <input name="tipoCobranca" id="tipoCobranca2" type="radio" value="c">Cobrança em Carteira
                                <input name="tipoCobranca" id="tipoCobranca3" type="radio" value="b">Cobrança em Banco
                            </td>
                        </tr>
                        <tr id="divFormaPagamento">
                            <td class="TextoCampos">Apenas as Formas de Pagto:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="checkbox" name="isAvista" id="isAvista" value="v" checked>A vista
                                <input type="checkbox" name="isAPrazo" id="isAPrazo" value="p" checked>A prazo
                                <input type="checkbox" name="isConta" id="isConta" value="c" checked>Conta corrente
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" id="lbApenasFrete" style="display: ">Apenas os Fretes: </td>
                            <td class="CelulaZebra2" colspan="2" id="apenasFrete" style="display: ">
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
                        <tr name="trMostrarQuitadas" id="trMostrarQuitadas">
                            <td colspan="3" class="TextoCampos"><div align="center" >
                                    <input type="checkbox" name="chkabertodia" id="chkabertodia" value="check">
                                    Mostrar duplicatas quitadas mas que estavam em aberto at&eacute; o dia
                                    <label name="lbDataFinal" id="lbDataFinal"><%=Apoio.getDataAtual()%></label>. Considerar a 
                                    <select id="tipodataBaixado" name="tipodataBaixado" class="inputtexto">
                                        <option value="pago_em" selected>Data de Pagamento</option>
                                        <option value="baixado_em">Data que o usuário efetuou a baixa</option>
                                    </select>
                                </div></td>
                        </tr>
                    </table>
                </td>
            </tr>

            <tr> 
                <td colspan="9">
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tr class="cellNotes"> 
                            <td width="24%" class="CelulaZebra2" id="imgGrupo" style="display: ">
                                <div align="center">
                                    <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">
                                </div>
                            </td>
                            <td width="76%" class="CelulaZebra2" id="selectGrupo" style="display: ">
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
            <tr class="tabela" id="trOrdenacaoLabel"> 
                <td colspan="3"><div align="center">Ordena&ccedil;&atilde;o</div></td>
            </tr>
            <tr id="trOrdenacao"> 
                <td colspan="3" class="TextoCampos"><div align="center">
                        <select id="ordenacao" name="ordenacao" class="inputtexto">
                            <option value="dtemissao">Data de Emiss&atilde;o</option>
                            <option value="dtvenc" selected>Data de Vencimento</option>
                            <option value="nfiscal">Número do CT-e</option>
                            <option value="cliente">Cliente (Tomador do serviço)</option>
                            <option value="cidade_consignatario">Cidade do Cliente</option>
                        </select>
                    </div></td>
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
                        <input type="radio" name="impressao" id="word" value="3" /><script>
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
        
            <div id="tabDinamico">

            </div>
            <div class="localiza">
                <iframe id="localizarCliente" input="con_rzs" name="localizarCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
            </div>
            <div class="cobre-tudo"></div>
    </body>
</html>
