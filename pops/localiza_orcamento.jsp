<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.orcamento.BeanConsultaOrcamento,
         conhecimento.orcamento.BeanCadOrcamento,
         nucleo.Apoio,
         java.text.SimpleDateFormat,
         java.text.DecimalFormat"%>
<%
            SimpleDateFormat formatDate = new SimpleDateFormat("dd/MM/yyyy");
            if (Apoio.getUsuario(request) == null) {
                response.sendError(response.SC_FORBIDDEN);
            }

            int idConsignatario = Apoio.parseInt(request.getParameter("idconsignatario"));
            int idDestinatario = Apoio.parseInt(request.getParameter("iddestinatario"));
            String consignatario = request.getParameter("con_rzs");
            int idFilial = Apoio.parseInt(request.getParameter("idfilial"));
            //09/04/2015
            int idCidadeDestino = Apoio.parseInt(request.getParameter("idcidadedestino"));
            int idColeta = Apoio.parseInt(request.getParameter("idColeta"));
            int idOrcamento = Apoio.parseInt(request.getParameter("orcamento_id"));
            String numeroColeta = request.getParameter("numeroColeta");
            boolean mostrarTodos = Apoio.parseBoolean(request.getParameter("mostrarTodos"));
            
            BeanConsultaOrcamento beanorc = null;

            beanorc = new BeanConsultaOrcamento();
            beanorc.setConexao(Apoio.getUsuario(request).getConexao());
%>
<html>
    <head>
        <script language="JavaScript"  src="../script/funcoes.js" type="text/javascript"></script>
        <script language="JavaScript"  src="../script/prototype.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" >
            function getPesoCubado(id){
                var pesoCubado = 0;
                if ($("tipo_transporte_"+id).value == 'a'){
                    pesoCubado =  parseFloat($("cubagem_metro_"+id).value) * parseFloat(1000000) / parseFloat($("base_"+id).value);
                }else{
                    pesoCubado = parseFloat($("base_"+id).value) * parseFloat($("cubagem_metro_"+id).value);
                }
                return pesoCubado;
            }
            
            function retornapai(id){
                var pai = window.opener.document;
                
                if ($("destinatario_id_"+ id).value != "0" && pai.getElementById("iddestinatario").value != "0" && pai.getElementById("iddestinatario").value != ""
                        && $("destinatario_id_"+ id).value != pai.getElementById("iddestinatario").value) {
                    if (!confirm("Atenção. O destinatario do CT-e é diferente do destinatario do Orçamento. Tem certeza que deseja utlizar este Orçamento.")) {
                        return false;
                    }
                }

                pai.getElementById("numero_orcamento").value = $("numero_"+id).value;
                pai.getElementById("orcamento_id").value = id;
                pai.getElementById("tipoproduto").value = $("tipo_produto_id_"+id).value;
                pai.getElementById("qtde_entregas").value = $("quantidade_entregas_"+id).value;

                //cidade origem
                pai.getElementById("idcidadeorigem").value = $("cidade_origem_id_"+id).value;
                pai.getElementById("cid_origem").value = $("cidade_origem_"+id).value;
                pai.getElementById("uf_origem").value = $("uf_origem_"+id).value;

                //cidade destino
                pai.getElementById("idcidadedestino").value = $("cidade_destino_id_"+id).value;
                pai.getElementById("cid_destino").value = $("cidade_destino_"+id).value;
                pai.getElementById("uf_destino").value = $("uf_destino_"+id).value;
                pai.getElementById("mensagem_usuario_cte_con_orc").value = $("mensagem_usuario_cte_con_orc_"+id).value;
                pai.getElementById("tipo_arredondamento_peso_con").value = $("tipo_arredondamento_peso_con_orc_"+id).value;
                pai.getElementById("tipo_prazo_rota").value = $("tipo_prazo_rota_"+id).value;
                pai.getElementById("prazo_rota").value = $("prazo_rota_"+id).value;
                pai.getElementById("distancia_km").value = $("distancia_km_"+id).value;
                pai.getElementById("rota_viagem").value = $("rota_viagem_"+id).value == "null" ? "" : $("rota_viagem_"+id).value;
                pai.getElementById("id_rota_viagem").value = $("id_rota_viagem_"+id).value;
                pai.getElementById("is_frete_dirigido").value = $("rem_is_frete_dirigido_"+id).value;
                //TDE
                pai.getElementById("cobrarTde").checked = ($("is_tde_"+id).value == "t" || $("is_tde_"+id).value == "true" ? true : false);
                pai.getElementById("valor_tde_orcamento").value = ($("valor_tde_"+id).value ? $("valor_tde_"+id).value : "0.00");
                pai.getElementById("valor_tde").value = ($("valor_tde_"+id).value ? $("valor_tde_"+id).value : "0.00");
                
                //destinatário
                if ($("destinatario_id_"+id).value != "0"){
                    var utilizarDestinatarioOrcamento = true;
                    if ($("destinatario_id_"+ id).value != "0" && pai.getElementById("iddestinatario").value != "0" && pai.getElementById("iddestinatario").value != ""
                        && $("destinatario_id_"+ id).value != pai.getElementById("iddestinatario").value) {
                        if (!confirm("Atenção. Confirme se vai utilizar o Destinatario do Orçamento.")) {
                            utilizarDestinatarioOrcamento= false;
                        }
                    }
                    if (utilizarDestinatarioOrcamento) {
                        pai.getElementById("des_codigo").value = $("destinatario_id_"+id).value;
                        pai.getElementById("iddestinatario").value = $("destinatario_id_"+id).value;
                        pai.getElementById("dest_rzs").value = $("razao_social_des_"+id).value;

                        pai.getElementById("dest_cidade").value = $("cidade_dest_"+id).value;
                        pai.getElementById("dest_uf").value = $("uf_dest_"+id).value;

                        pai.getElementById("dest_cnpj").value = $("cnpj_des_"+id).value;                    
                        pai.getElementById("dest_tipotaxa").value = $("dest_tipotaxa_"+id).value;
                        pai.getElementById("desttipofpag").value = $("desttipofpag_"+id).value;

                        pai.getElementById("desttabelaproduto").value = $("desttabelaproduto_"+id).value;
                        pai.getElementById("dest_endereco").value = $("dest_endereco_"+id).value;
                        pai.getElementById("des_analise_credito").value = $("des_analise_credito_"+id).value;
                        pai.getElementById("des_valor_credito").value = $("des_valor_credito_"+id).value;
                        pai.getElementById("des_is_bloqueado").value = $("des_is_bloqueado_"+id).value;
                        pai.getElementById("des_tabela_remetente").value = $("des_tabela_remetente_"+id).value;
                        pai.getElementById("is_utilizar_tipo_frete_tabela").value = $("des_is_utilizar_tipo_frete_tabela_"+id).value;
                        pai.getElementById("utilizatipofretetabeladest").value = $("des_is_utilizar_tipo_frete_tabela_"+id).value;
                    }
                }

                //consiguinatário
                var idconsignatario = "0";
                var con_codigo = "";
                var con_rzs = "";
                var con_cidade = "";
                var con_uf = "";
                var con_cnpj = "";
                var contipofpag = "";
                var contipoorigem = "";
                var contabelaproduto = "";
                var con_analise_credito = "";
                var con_valor_credito = "";
                var con_is_bloqueado = "";
                var con_tabela_remetente = "";
                var tipotaxa = "";
                
              /*  if ($("clientepagador_"+id).value == "r"){
                    pai.getElementById("fretepago_sim").checked = true;
                    pai.getElementById("fretepago_nao").checked = false;                    
                    idconsignatario = $("idremetente_"+id).value;
                    con_codigo = $("idremetente_"+id).value;
                    con_rzs = $("razao_social_cli_"+id).value;
                    con_cidade = $("cidade_rem_"+id).value;
                    con_uf = $("uf_rem_"+id).value;
                    con_cnpj = $("cnpj_rem_"+id).value;  
                    contipofpag = $("rem_tipo_f_pag_"+id).value;
                    contipoorigem = $("rem_tipo_origem_"+id).value;
                    contabelaproduto = $("remtabelaproduto_"+id).value;
                    con_analise_credito = $("rem_analise_credito_"+id).value;
                    con_valor_credito = $("rem_valor_credito_"+id).value;
                    con_is_bloqueado = $("rem_is_bloqueado_"+id).value;                    
                    con_tabela_remetente =$("rem_tabela_remetente_"+id).value;
                    tipotaxa =$("rem_tipotaxa_"+id).value;
                    
                }else if ($("clientepagador_"+id).value == "d"){
                    pai.getElementById("fretepago_sim").checked = false;
                    pai.getElementById("fretepago_nao").checked = true;                    
                    idconsignatario = $("destinatario_id_"+id).value;
                    con_codigo = $("destinatario_id_"+id).value;
                    con_rzs = $("razao_social_des_"+id).value;
                    con_cidade = $("cidade_dest_"+id).value;
                    con_uf = $("uf_dest_"+id).value;
                    con_cnpj = $("cnpj_des_"+id).value;  
                    contipofpag = $("desttipofpag_"+id).value;
                    contabelaproduto = $("desttabelaproduto_"+id).value;
                    con_analise_credito = $("des_analise_credito_"+id).value;
                    con_valor_credito = $("des_valor_credito_"+id).value;                    
                    con_tabela_remetente = $("des_tabela_remetente_"+id).value;
                    tipotaxa = $("dest_tipotaxa_"+id).value;
                }else */
        
                if ($("clientepagador_"+id).value == "c"){
                    pai.getElementById("fretepago_sim").checked = false;
                    pai.getElementById("fretepago_nao").checked = true; 
                    
                    pai.getElementById("idconsignatario").value = $("consignatario_id_"+id).value;
                    pai.getElementById("con_codigo").value = $("consignatario_id_"+id).value;
                    pai.getElementById("con_rzs").value = $("consignatario_razao_"+id).value;
                    pai.getElementById("con_cnpj").value = $("consignatario_cnpj_"+id).value; 
                    pai.getElementById("con_cidade").value = $("consignatario_cidade_"+id).value;
                    pai.getElementById("con_uf").value = $("consignatario_uf_"+id).value;
                    pai.getElementById("tipofpag").value = $("consignatario_fpagamento_" + id).value;
                    pai.getElementById("con_tabela_remetente").value = $("consignatario_tabela_remetente_"+id).value;
                    pai.getElementById("is_utilizar_tipo_frete_tabela").value = $("consignatario_is_utilizar_tipo_frete_tabela_"+id).value;
                    pai.getElementById("utilizatipofretetabelaconsig").value = $("consignatario_is_utilizar_tipo_frete_tabela_"+id).value;
                    
                    contipofpag = $("desttipofpag_"+id).value;
                    contabelaproduto = $("desttabelaproduto_"+id).value;
                    con_analise_credito = $("des_analise_credito_"+id).value;
                    con_valor_credito = $("des_valor_credito_"+id).value;                    
                    con_tabela_remetente = $("des_tabela_remetente_"+id).value;
                }
                tipotaxa = $("tipo_taxa_"+id).value;
                pai.getElementById("tipotaxa").value = $("tipo_taxa_"+id).value;

                if($("vendedor_id_"+id).value != "0"){
                    pai.getElementById("idvendedor").value = $("vendedor_id_"+id).value;
                    pai.getElementById("ven_rzs").value = $("ven_rzs_"+id).value;
                }
                
                var obs = "Orçamento: ";
                var valorFrete = parseFloat($("valor_frete_valor_"+id).value);
                
                pai.getElementById("valor_frete").value = formatoMoeda(valorFrete);
                
                pai.getElementById("obs_orcamento_hidden").value = obs + $("numero_"+id).value;
                pai.getElementById("cub_metro").value = $("cubagem_metro_"+id).value;
                pai.getElementById("cub_base").value = $("base_"+id).value;
                pai.getElementById("cub_peso").value = formatoMoeda(getPesoCubado(id));

//              Comentada pos não deve ser recarregado a tabela 
//              de preço quando o conhecimento for gerado atravez de um orçamento
//              Número revisão SVN : 13908
//                window.opener.alteraTipoTaxa(tipotaxa);
                
                var valorNota = $("valor_mercadoria_"+id).value;
                
                var pesoCTe = pai.getElementById("peso").value;
                var volumeCTe = pai.getElementById("volume").value;
                var vlMercadoriaCTe = pai.getElementById("vlmercadoria").value;
                var addNotaOrcamento = true;
                var chamarRecalcular = false;
                
                if (pesoCTe != "0.00" && volumeCTe != "0.00" && vlMercadoriaCTe != "0.00") {
                    addNotaOrcamento = false;
                }
                if (addNotaOrcamento) {
                    window.opener.addNoteLocalizarConhecimento("0","","1",pai.getElementById("dtemissao").value,
                           formatoMoeda(valorNota),
                           "0.00","0.00","0.00","0.00",
                           $("peso_solicitado_"+id).value,
                           $("volume_solicitado_"+id).value,
                           "","",
                           "0",
                           "",
                           "0.00","0.00","0.00",$("cubagem_metro_"+id).value,
                           "0","","","","0","",
                           "0","","",
                           "false","","","",
                           "","","0","","false","0");

                }
                window.opener.pagtoAvista();

                pai.getElementById("peso_orcamento").value = $("peso_solicitado_"+id).value;
                pai.getElementById("volume_orcamento").value = $("volume_solicitado_"+id).value;
                pai.getElementById("mercadoria_orcamento").value = formatoMoeda(valorNota);
                pai.getElementById("cubagem_orcamento").value = $("cubagem_metro_"+id).value;
        
                pai.getElementById("client_tariff_id").value = $("tabela_id_"+id).value;
                pai.getElementById("valor_taxa_fixa").value = formatoMoeda($("valor_taxa_fixa_"+id).value);
                
                
                pai.getElementById("valor_itr").value = formatoMoeda($("valor_itr_"+id).value);
                pai.getElementById("valor_despacho").value = formatoMoeda($("valor_despacho_"+id).value);
                pai.getElementById("valor_ademe").value = formatoMoeda($("valor_ademe_"+id).value);
                if (parseFloat($("percentualDesc_"+id).value) > 0){
                    if ($("isDescFreteNacional_"+id).value == 't' || $("isDescFreteNacional_"+id).value == 'true' || $("isDescFreteNacional_"+id).value == true){
                        var valorFretePesoComDesconto = parseFloat($("valor_frete_peso_"+id).value) - (parseFloat($("valor_frete_peso_"+id).value) * parseFloat($("percentualDesc_"+id).value) / 100);
                        pai.getElementById("valor_peso").value = formatoMoeda(valorFretePesoComDesconto);
                        pai.getElementById("valor_desconto").value = '0.00';
                    }else{
                        pai.getElementById("valor_peso").value = formatoMoeda($("valor_frete_peso_"+id).value);
                    }
                    if ($("isDescAdvalorem_"+id).value == 't' || $("isDescAdvalorem_"+id).value == 'true' || $("isDescAdvalorem_"+id).value == true){
                        var valorFreteValorComDesconto = parseFloat($("valor_frete_valor_"+id).value) - (parseFloat($("valor_frete_valor_"+id).value) * parseFloat($("percentualDesc_"+id).value) / 100);
                        pai.getElementById("valor_frete").value = formatoMoeda(valorFreteValorComDesconto);
                        pai.getElementById("valor_desconto").value = '0.00';
                    }else{
                        pai.getElementById("valor_frete").value =  formatoMoeda($("valor_frete_valor_"+id).value);         
                    }
                }else{
                    pai.getElementById("valor_peso").value = formatoMoeda($("valor_frete_peso_"+id).value);
                    pai.getElementById("valor_frete").value =  formatoMoeda($("valor_frete_valor_"+id).value);         
                    pai.getElementById("valor_desconto").value = formatoMoeda($("valor_desconto_"+id).value);
                }
                //pai.getElementById("percentual_desconto").value =  formatoMoeda($("percentualDesc_"+id).value);         
                //pai.getElementById("isDescAdvalorem").value = ($("isDescAdvalorem_"+id).value);         
                //pai.getElementById("isDescFreteNacional").value = ($("isDescFreteNacional_"+id).value);         
                pai.getElementById("valor_sec_cat").value = formatoMoeda($("valor_sec_cat_"+id).value);
                pai.getElementById("valor_outros").value = formatoMoeda($("valor_outros_"+id).value);
                pai.getElementById("valor_gris").value = formatoMoeda($("valor_gris_"+id).value);
                pai.getElementById("valor_pedagio").value = formatoMoeda($("valor_pedagio_"+id).value);
                pai.getElementById("base_calculo").value = formatoMoeda($("base_calculo_icms_"+id).value);
                pai.getElementById("aliquota").value = formatoMoeda($("aliquota_icms_"+id).value);
                pai.getElementById("icms").value =  "0.00";
                pai.getElementById("total").value = formatoMoeda($("valor_frete_valor_"+id).value);

                if ($("incluir_icms_"+id).value == "t" ||$("incluir_icms_"+id).value == "true"){
                    pai.getElementById("incluirIcms").checked = true;
                    pai.getElementById("addicms").value = pai.getElementById("incluirIcms").checked;
                }
                if ($("incluirFederais_"+id).value == "t" ||$("incluirFederais_"+id).value == "true"){
                    pai.getElementById("incluirFederais").checked = true;
                }
                
                if($("mensagem_usuario_cte_con_orc_"+id).value != null && $("mensagem_usuario_cte_con_orc_"+id).value != ""){
                   alert("Mensagem importante para emissão de CT-e do cliente "+ $("consignatario_razao_"+id).value+": "+$("mensagem_usuario_cte_con_orc_"+id).value);
                }
                
                if (window.opener.aoClicarNoLocaliza != null) {
                    window.opener.aoClicarNoLocaliza("LocalizaOrc");
                    
                }
                
                window.opener.recalcular(false);
                window.close();
            }
            
            function pesquisarOSColeta(){
                var form = document.getElementById("formPorColeta");                
                form.action = "localiza_orcamento.jsp?idconsignatario=<%=idConsignatario%>&idfilial=<%=idFilial%>&con_rzs=<%=consignatario%>&iddestinatario=<%=idDestinatario%> +&dest_rzs='' &idcidadedestino=<%=idCidadeDestino%>&idColeta=<%=idColeta%>&numeroColeta=<%=numeroColeta%>&mostrarTodos="+document.getElementById("mostrarTodos").checked;
                form.submit();
            }
            
            function aoCarregar(){
            }
        </script>

        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Localizar Or&ccedil;amento</title>
        <link href="../estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style8 {font-size: 11px}
            -->
        </style>
    </head>

    <body onLoad="javascript:applyFormatter(); aoCarregar();">
        <img src="../img/banner.gif"  alt=""><br>
        <table width="99%" align="center" class="bordaFina" >
            <tr>
                <td>
                    <div align="left">
                        <b>Localizar Or&ccedil;amento</b>
                    </div>
                </td>
            </tr>
        </table>
        <br>
      <form action="" method="post" name="formPorColeta" id="formPorColeta">
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <% if (idColeta != 0) { %>
            <tr class="celula">
                <td width="36%"  height="5">
                </td>
                        <td width="36%"  height="5">
                            <input type="checkbox" id="mostrarTodos" onclick="pesquisarOSColeta();" <%=mostrarTodos ? "checked" : ""%> name="mostrarTodos" value="" >
                            <label>Mostrar apenas Or&ccedil;amentos da coleta: <%=numeroColeta%> </label>
                        </td>      
                  
            </tr>
                <% }
                %>
            <tr class="celula">
                <td width="36%"  height="5">
                    <div align="right">
                        Apenas o consignat&aacute;rio:
                    </div>
                </td>
                <td width="64%"  >
                    <div align="left">
                        <%=consignatario%>
                    </div>
                </td>
            </tr>
        </table>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="6%">N&uacute;mero</td>
                <td width="8%">Data</td>
                <td width="26%">Rem./Origem</td>
                <td width="26%">Dest./Destino</td>
                <td width="7%">Vl. Merc</td>
                <td width="7%">Peso</td>
                <td width="5%">Vols</td>
                <td width="5%">M³</td>
                <td width="10%">Total Prest.</td>
            </tr>
            
            <% int linha = 0;
               double totalPrestacao = 0;
                        
                if (beanorc.LocalizarOrcamentoCtrc(idConsignatario,idFilial, idDestinatario, idCidadeDestino, idColeta,mostrarTodos, idOrcamento)) {
                    ResultSet rs = beanorc.getResultado();
                    while (rs.next()) {
                        totalPrestacao = rs.getDouble("valor_taxa_fixa")+rs.getDouble("valor_itr")+rs.getDouble("valor_ademe")+rs.getDouble("valor_frete_peso")+rs.getDouble("valor_frete_valor")+rs.getDouble("valor_sec_cat")+rs.getDouble("valor_outros")+rs.getDouble("valor_gris")+rs.getDouble("valor_despacho")+rs.getDouble("valor_pedagio")+rs.getDouble("valor_desconto")+rs.getDouble("icms_imbutido")-rs.getDouble("valor_desconto"); 
                        if(rs.getBoolean("is_tde")){
                            totalPrestacao += rs.getDouble("valor_tde");
                        }
                               
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td>
                    <input type="hidden" name="id_<%=rs.getString("id")%>" id="id_<%=rs.getString("id")%>" value="<%=rs.getString("id")%>">
                    <input type="hidden" name="numero_<%=rs.getString("id")%>" id="numero_<%=rs.getString("id")%>" value="<%=rs.getString("numero")%>">
                    <input type="hidden" name="idremetente_<%=rs.getString("id")%>" id="idremetente_<%=rs.getString("id")%>" value="<%=rs.getString("cliente_id")%>">
                    <input type="hidden" name="razao_social_cli_<%=rs.getString("id")%>" id="razao_social_cli_<%=rs.getString("id")%>" value="<%=rs.getString("razao_social_cli")%>">
                    <input type="hidden" name="cnpj_rem_<%=rs.getString("id")%>" id="cnpj_rem_<%=rs.getString("id")%>" value="<%=rs.getString("cnpj_rem")%>">
                    <input type="hidden" name="rem_tipotaxa_<%=rs.getString("id")%>" id="rem_tipotaxa_<%=rs.getString("id")%>" value="<%=rs.getString("rem_tipotaxa")%>">
                    <input type="hidden" name="rem_tipo_f_pag_<%=rs.getString("id")%>" id="rem_tipo_f_pag_<%=rs.getString("id")%>" value="<%=rs.getString("rem_tipo_f_pag")%>">
                    <input type="hidden" name="rem_tipo_origem_<%=rs.getString("id")%>" id="rem_tipo_origem_<%=rs.getString("id")%>" value="<%=rs.getString("rem_tipo_origem")%>">
                    <input type="hidden" name="rem_endereco_<%=rs.getString("id")%>" id="rem_endereco_<%=rs.getString("id")%>" value="<%=rs.getString("rem_endereco")%>">
                    <input type="hidden" name="remtabelaproduto_<%=rs.getString("id")%>" id="remtabelaproduto_<%=rs.getString("id")%>" value="<%=rs.getString("rem_is_bloqueado")%>">                    
                    <input type="hidden" name="rem_is_bloqueado_<%=rs.getString("id")%>" id="rem_is_bloqueado_<%=rs.getString("id")%>" value="<%=rs.getString("rem_is_bloqueado")%>">
                    <input type="hidden" name="rem_tabela_remetente_<%=rs.getString("id")%>" id="rem_tabela_remetente_<%=rs.getString("id")%>" value="<%=rs.getString("rem_is_utiliza_tabela_remetente")%>">
                    <input type="hidden" name="rem_is_utilizar_tipo_frete_tabela_<%=rs.getString("id")%>" id="rem_is_utilizar_tipo_frete_tabela__<%=rs.getString("id")%>" value="<%=rs.getString("rem_is_utilizar_tipo_frete_tabela")%>">
                    <input type="hidden" name="rem_analise_credito_<%=rs.getString("id")%>" id="rem_analise_credito_<%=rs.getString("id")%>" value="f">
                    <input type="hidden" name="rem_valor_credito_<%=rs.getString("id")%>" id="rem_valor_credito_<%=rs.getString("id")%>" value="0">
                    <input type="hidden" name="rem_is_frete_dirigido_<%=rs.getString("id")%>" id="rem_is_frete_dirigido_<%=rs.getString("id")%>" value="<%=rs.getString("rem_is_frete_dirigido")%>">
                    
                    <input type="hidden" name="cidade_rem_<%=rs.getString("id")%>" id="cidade_rem_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_rem")%>">
                    <input type="hidden" name="uf_rem_<%=rs.getString("id")%>" id="uf_rem_<%=rs.getString("id")%>" value="<%=rs.getString("uf_rem")%>">
                    
                    <input type="hidden" name="cidade_id_rem_<%=rs.getString("id")%>" id="cidade_id_rem_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_id_rem")%>">
                    
                    <input type="hidden" name="cidade_destino_<%=rs.getString("id")%>" id="cidade_destino_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_destino")%>">
                    <input type="hidden" name="cidade_destino_id_<%=rs.getString("id")%>" id="cidade_destino_id_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_destino_id")%>">
                    <input type="hidden" name="uf_destino_<%=rs.getString("id")%>" id="uf_destino_<%=rs.getString("id")%>" value="<%=rs.getString("uf_destino")%>">
                    <input type="hidden" name="cidade_id_des_<%=rs.getString("id")%>" id="cidade_id_des_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_id_des")%>">
                    
                    <input type="hidden" name="cidade_dest_<%=rs.getString("id")%>" id="cidade_dest_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_dest")%>">
                    <input type="hidden" name="uf_dest_<%=rs.getString("id")%>" id="uf_dest_<%=rs.getString("id")%>" value="<%=rs.getString("uf_dest")%>">
                    
                    
                    <input type="hidden" name="cidade_origem_id_<%=rs.getString("id")%>" id="cidade_origem_id_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_origem_id")%>">
                    <input type="hidden" name="cidade_origem_<%=rs.getString("id")%>" id="cidade_origem_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_origem")%>">
                    <input type="hidden" name="uf_origem_<%=rs.getString("id")%>" id="uf_origem_<%=rs.getString("id")%>" value="<%=rs.getString("uf_origem")%>">
                    
                    
                    <input type="hidden" name="peso_solicitado_<%=rs.getString("id")%>" id="peso_solicitado_<%=rs.getString("id")%>" value="<%=rs.getString("peso_solicitado")%>">
                    <input type="hidden" name="volume_solicitado_<%=rs.getString("id")%>" id="volume_solicitado_<%=rs.getString("id")%>" value="<%=rs.getString("volume_solicitado")%>">
                    <input type="hidden" name="valor_mercadoria_<%=rs.getString("id")%>" id="valor_mercadoria_<%=rs.getString("id")%>" value="<%=rs.getString("valor_mercadoria")%>">
                    
                    <input type="hidden" name="quantidade_entregas_<%=rs.getString("id")%>" id="quantidade_entregas_<%=rs.getString("id")%>" value="<%=rs.getString("quantidade_entregas")%>">
                    <input type="hidden" name="tipo_veiculo_id_<%=rs.getString("id")%>" id="tipo_veiculo_id_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_veiculo_id_orc")%>">
                    <input type="hidden" name="tipo_produto_id_<%=rs.getString("id")%>" id="tipo_produto_id_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_produto_id_orc")%>">
                    <input type="hidden" name="tipo_taxa_<%=rs.getString("id")%>" id="tipo_taxa_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_taxa")%>">
                    <input type="hidden" name="valor_taxa_fixa_<%=rs.getString("id")%>" id="valor_taxa_fixa_<%=rs.getString("id")%>" value="<%=rs.getString("valor_taxa_fixa")%>">
                    <input type="hidden" name="valor_itr_<%=rs.getString("id")%>" id="valor_itr_<%=rs.getString("id")%>" value="<%=rs.getString("valor_itr")%>">
                    <input type="hidden" name="valor_despacho_<%=rs.getString("id")%>" id="valor_despacho_<%=rs.getString("id")%>" value="<%=rs.getString("valor_despacho")%>">
                    <input type="hidden" name="valor_ademe_<%=rs.getString("id")%>" id="valor_ademe_<%=rs.getString("id")%>" value="<%=rs.getString("valor_ademe")%>">
                    <input type="hidden" name="valor_frete_peso_<%=rs.getString("id")%>" id="valor_frete_peso_<%=rs.getString("id")%>" value="<%=rs.getString("valor_frete_peso")%>">
                    <input type="hidden" name="valor_frete_valor_<%=rs.getString("id")%>" id="valor_frete_valor_<%=rs.getString("id")%>" value="<%=rs.getString("valor_frete_valor")%>">
                    <input type="hidden" name="valor_sec_cat_<%=rs.getString("id")%>" id="valor_sec_cat_<%=rs.getString("id")%>" value="<%=rs.getString("valor_sec_cat")%>">
                    <input type="hidden" name="valor_outros_<%=rs.getString("id")%>" id="valor_outros_<%=rs.getString("id")%>" value="<%=rs.getString("valor_outros")%>">
                    <input type="hidden" name="valor_gris_<%=rs.getString("id")%>" id="valor_gris_<%=rs.getString("id")%>" value="<%=rs.getString("valor_gris")%>">
                    <input type="hidden" name="valor_pedagio_<%=rs.getString("id")%>" id="valor_pedagio_<%=rs.getString("id")%>" value="<%=rs.getString("valor_pedagio")%>">
                    <input type="hidden" name="valor_desconto_<%=rs.getString("id")%>" id="valor_desconto_<%=rs.getString("id")%>" value="<%=rs.getString("valor_desconto")%>">
                    <input type="hidden" name="base_calculo_icms_<%=rs.getString("id")%>" id="base_calculo_icms_<%=rs.getString("id")%>" value="<%=rs.getString("base_calculo_icms")%>">
                    <input type="hidden" name="aliquota_icms_<%=rs.getString("id")%>" id="aliquota_icms_<%=rs.getString("id")%>" value="<%=rs.getString("aliquota_icms")%>">
                    <input type="hidden" name="tabela_id_<%=rs.getString("id")%>" id="tabela_id_<%=rs.getString("id")%>" value="<%=rs.getString("tabela")%>">
                    <input type="hidden" name="vendedor_id_<%=rs.getString("id")%>" id="vendedor_id_<%=rs.getString("id")%>" value="<%=rs.getString("vendedor_id_orc")%>">
                    <input type="hidden" name="ven_rzs_<%=rs.getString("id")%>" id="ven_rzs_<%=rs.getString("id")%>" value=<%=rs.getString("ven_rzs")%>>
                    
                    <input type="hidden" name="qtdkm_<%=rs.getString("id")%>" id="qtdkm_<%=rs.getString("id")%>" value="<%=rs.getString("qtdkm")%>">
                    <input type="hidden" name="icms_imbutido_<%=rs.getString("id")%>" id="icms_imbutido_<%=rs.getString("id")%>" value="<%=rs.getString("icms_imbutido")%>">
                    <input type="hidden" name="incluir_icms_<%=rs.getString("id")%>" id="incluir_icms_<%=rs.getString("id")%>" value="<%=rs.getString("incluir_icms")%>">
                    <input type="hidden" name="incluirFederais_<%=rs.getString("id")%>" id="incluirFederais_<%=rs.getString("id")%>" value="<%=rs.getString("is_inclui_federais")%>">
                    <input type="hidden" name="clientepagador_<%=rs.getString("id")%>" id="clientepagador_<%=rs.getString("id")%>" value="<%=rs.getString("clientepagador")%>">
                    <input type="hidden" name="destinatario_id_<%=rs.getString("id")%>" id="destinatario_id_<%=rs.getString("id")%>" value="<%=(rs.getString("destinatario_id") == null ? 0 : rs.getString("destinatario_id") )%>">
                    <input type="hidden" name="razao_social_des_<%=rs.getString("id")%>" id="razao_social_des_<%=rs.getString("id")%>" value="<%=rs.getString("razao_social_des")%>">
                    <input type="hidden" name="cnpj_des_<%=rs.getString("id")%>" id="cnpj_des_<%=rs.getString("id")%>" value="<%=rs.getString("cnpj_des")%>">
                    <input type="hidden" name="dest_tipotaxa_<%=rs.getString("id")%>" id="dest_tipotaxa_<%=rs.getString("id")%>" value="<%=rs.getString("dest_tipotaxa")%>">
                    <input type="hidden" name="desttipofpag_<%=rs.getString("id")%>" id="desttipofpag_<%=rs.getString("id")%>" value="<%=rs.getString("dest_tipofpag")%>">
                    <!--<input type="hidden" name="desttipoorigem_" id="desttipoorigem_" value="">-->
                    
                    <input type="hidden" name="consignatario_id_<%=rs.getString("id")%>" id="consignatario_id_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_id")%>">
                    <input type="hidden" name="consignatario_razao_<%=rs.getString("id")%>" id="consignatario_razao_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_razao")%>">
                    <input type="hidden" name="consignatario_cnpj_<%=rs.getString("id")%>" id="consignatario_cnpj_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_cnpj")%>">
                    <input type="hidden" name="consignatario_cidade_<%=rs.getString("id")%>" id="consignatario_cidade_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_cidade")%>">                    
                    <input type="hidden" name="consignatario_uf_<%=rs.getString("id")%>" id="consignatario_uf_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_uf")%>">
                    <input type="hidden" name="consignatario_fpagamento_<%=rs.getString("id")%>" id="consignatario_fpagamento_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_fpagamento")%>">
                    <input type="hidden" name="consignatario_tabela_remetente_<%=rs.getString("id")%>" id="consignatario_tabela_remetente_<%=rs.getString("id")%>" value=<%=rs.getString("consignatario_is_utiliza_tabela_remetente")%>>
                    <input type="hidden" name="consignatario_is_utilizar_tipo_frete_tabela_<%=rs.getString("id")%>" id="consignatario_is_utilizar_tipo_frete_tabela_<%=rs.getString("id")%>" value="<%=rs.getString("consignatario_is_utilizar_tipo_frete_tabela")%>">
                    
                    <input type="hidden" name="desttabelaproduto_<%=rs.getString("id")%>" id="desttabelaproduto_<%=rs.getString("id")%>" value="<%=rs.getString("rem_tabela_produto")%>">
                    <input type="hidden" name="dest_endereco_<%=rs.getString("id")%>" id="dest_endereco_<%=rs.getString("id")%>" value="<%=rs.getString("dest_endereco") + " - " + rs.getString("dest_bairro")%>">
                    <input type="hidden" name="des_analise_credito_<%=rs.getString("id")%>" id="des_analise_credito_<%=rs.getString("id")%>" value=<%=rs.getString("des_is_analise_credito")%>>
                    <input type="hidden" name="des_valor_credito_<%=rs.getString("id")%>" id="des_valor_credito_<%=rs.getString("id")%>" value=<%=rs.getString("des_valor_credito")%>>
                    <input type="hidden" name="des_is_bloqueado_<%=rs.getString("id")%>" id="des_is_bloqueado_<%=rs.getString("id")%>" value=<%=rs.getString("des_is_bloqueado")%>>
                    <input type="hidden" name="des_tabela_remetente_<%=rs.getString("id")%>" id="des_tabela_remetente_<%=rs.getString("id")%>" value=<%=rs.getString("des_is_utiliza_tabela_remetente")%>>
                    <input type="hidden" name="des_is_utilizar_tipo_frete_tabela_<%=rs.getString("id")%>" id="des_is_utilizar_tipo_frete_tabela_<%=rs.getString("id")%>" value="<%=rs.getString("des_is_utilizar_tipo_frete_tabela")%>">
                    
                    <input type="hidden" name="cidade_coleta_id_<%=rs.getString("id")%>" id="cidade_coleta_id_<%=rs.getString("id")%>" value="<%=rs.getString("cidade_coleta_id")%>">
                    <input type="hidden" name="condicaopgt_<%=rs.getString("id")%>" id="condicaopgt_<%=rs.getString("id")%>" value="<%=rs.getString("condicaopgt")%>">
                    <input type="hidden" name="tipo_pagto_frete_<%=rs.getString("id")%>" id="tipo_pagto_frete_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_pagto_frete")%>">
                    <input type="hidden" name="quantidade_pallets_<%=rs.getString("id")%>" id="quantidade_pallets_<%=rs.getString("id")%>" value="<%=rs.getString("quantidade_pallets")%>">
                    <input type="hidden" name="valor_tde_<%=rs.getString("id")%>" id="valor_tde_<%=rs.getString("id")%>" value="<%=rs.getString("valor_tde")%>">
                    <input type="hidden" name="is_tde_<%=rs.getString("id")%>" id="is_tde_<%=rs.getString("id")%>" value="<%=rs.getString("is_tde")%>">
                    <input type="hidden" name="valor_impostos_federais_<%=rs.getString("id")%>" id="valor_impostos_federais_<%=rs.getString("id")%>" value="<%=rs.getString("valor_impostos_federais")%>">
                    <input type="hidden" name="is_inclui_federais_<%=rs.getString("id")%>" id="is_inclui_federais_<%=rs.getString("id")%>" value="<%=rs.getString("is_inclui_federais")%>">
                    <input type="hidden" name="total_prestacao_<%=rs.getString("id")%>" id="total_prestacao_<%=rs.getString("id")%>" value="<%=totalPrestacao%>">
                    
                    <input type="hidden" name="tipo_transporte_<%=rs.getString("id")%>" id="tipo_transporte_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_transporte")%>">
                    <input type="hidden" name="cubagem_metro_<%=rs.getString("id")%>" id="cubagem_metro_<%=rs.getString("id")%>" value="<%=rs.getString("cubagem_metro")%>">
                    <input type="hidden" name="base_<%=rs.getString("id")%>" id="base_<%=rs.getString("id")%>" value="<%=rs.getString("base")%>">
                    <input type="hidden" name="isDescFreteNacional_<%=rs.getString("id")%>" id="isDescFreteNacional_<%=rs.getString("id")%>" value="<%=rs.getString("is_desconto_frete_nacional")%>">
                    <input type="hidden" name="isDescAdvalorem_<%=rs.getString("id")%>" id="isDescAdvalorem_<%=rs.getString("id")%>" value="<%=rs.getString("is_desconto_advalorem")%>">
                    <input type="hidden" name="percentualDesc_<%=rs.getString("id")%>" id="percentualDesc_<%=rs.getString("id")%>" value="<%=rs.getString("percentual_desconto")%>">
                    <input type="hidden" name="mensagem_usuario_cte_con_orc_<%=rs.getString("id")%>" id="mensagem_usuario_cte_con_orc_<%=rs.getString("id")%>" value="<%=rs.getString("mensagem_usuario_cte_con_orc")%>">
                    <input type="hidden" name="tipo_arredondamento_peso_con_orc_<%=rs.getString("id")%>" id="tipo_arredondamento_peso_con_orc_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_arredondamento_peso_con")%>">
                    <input type="hidden" name="id_rota_viagem_<%=rs.getString("id")%>" id="id_rota_viagem_<%=rs.getString("id")%>" value="<%=rs.getString("id_rota_viagem")%>">
                    <input type="hidden" name="rota_viagem_<%=rs.getString("id")%>" id="rota_viagem_<%=rs.getString("id")%>" value="<%=rs.getString("rota_viagem")%>">
                    <input type="hidden" name="distancia_km_<%=rs.getString("id")%>" id="distancia_km_<%=rs.getString("id")%>" value="<%=rs.getString("distancia_km")%>">
                    <input type="hidden" name="prazo_rota_<%=rs.getString("id")%>" id="prazo_rota_<%=rs.getString("id")%>" value="<%=rs.getString("prazo_rota")%>">
                    <input type="hidden" name="tipo_prazo_rota_<%=rs.getString("id")%>" id="tipo_prazo_rota_<%=rs.getString("id")%>" value="<%=rs.getString("tipo_prazo_rota")%>">
                    
                    <div class="linkEditar" onClick="javascript:retornapai(<%=rs.getString("id")%>);">
                        <%=rs.getString("numero")%>
                    </div>
                </td>
                <td><%=formatDate.format(rs.getDate("emissao_em"))%></td>
                <td>
                    <%=rs.getString("razao_social_cli")%>
                    <br/>
                    <%=rs.getString("cidade_origem") + " - " + rs.getString("uf_origem")%>
                </td>
                <td>
                    <%=rs.getString("razao_social_des")%>
                    <br/>
                    <%=rs.getString("cidade_destino") + " - " + rs.getString("uf_destino")%>
                </td>
                <td><%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor_mercadoria"))%></td>
                <td><%=new DecimalFormat("#,##0.00").format(rs.getDouble("peso_solicitado"))%></td>
                <td><%=new DecimalFormat("#,##0.00").format(rs.getDouble("volume_solicitado"))%></td>
                <td><%=new DecimalFormat("#,##0.00").format(rs.getDouble("cubagem_metro"))%></td>
                <td><%=new DecimalFormat("#,##0.00").format(totalPrestacao)%></td>                
            </tr>
            <%
                    linha++;
                }
            }
            %>
        </table>
        <br>
        </form>
    </body>
</html>