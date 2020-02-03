
<%@page import="java.sql.ResultSet"%>
<%@page import="nucleo.Apoio"%>
<%@page import="tipo_veiculos.ConsultaTipo_veiculos"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>"   type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/beans/<%=Apoio.noCacheScript("beans/nota_fiscal-util.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("aliquotaIcmsCtrc.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/beans/<%=Apoio.noCacheScript("beans/CTRC.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>" type="text/javascript"></script>
        <script language="javascript" src="script/<%=Apoio.noCacheScript("tabelaFrete.js")%>" type=""></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("impostos.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("TalaoCheque.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("shortcut.js")%>"></script>

        <script language="JavaScript" type="text/javascript">
            var homePath= '${homePath}';
            //@@@@@@@@@@@@@@@@@@@  CONTROLANDO AS ABAS  
            jQuery.noConflict(); 
            var $a = jQuery.noConflict(); 
            
            
            //Daniel está utlizando esse id para teste no selenium.
            window.id = "importarConhecimentoLote";
            
            var pops = null;
            var arrayExtencoes = new Array();
            var controlaTalonario = "${configuracao.controlarTalonario}";
            var federais = ${configuracao.calcularEmbutirImpostosFederais};
            var piscofins = ${configuracao.pis + configuracao.cofins};
            
            //Campos para valculos de PIS/COFINS/CSSL/IR
            var embutirIr = ${configuracao.embutirIR};
            var embutirCssl = ${configuracao.embutirCssl};
            var embutirPis = ${configuracao.embutirPis};
            var embutirCofins = ${configuracao.embutirCofins};
            var embutirInss = ${configuracao.embutirInss};            
            
            var listaFormaPagamento = new Array();
            var listaConta = new Array();
            var listaBanco = new Array();
            var listaEspecie = new Array();
            var listaStICMS = new Array();
            var listaTipoDocNf = new Array();
            var countListaTipoDocNf = 0;
            arrayExtencoes[0] = 'XML' ;
            arrayExtencoes[1] = 'TXT' ;
            var arrayAbas = new Array();            
            var dataAtual = '${param.dataAtual}';
            shortcut.add("Shift+C",function() {addConhecimentoLote(null,$('tabConhecimento'), $("maxConhecimento"), $("serie"),$('alteraprecocte').value,$('alterainffiscal').value,$('permissao_alteratipofretecte').value,$('embutirICMS').checked,$('embutirPISCOFINS').checked,$('slTipoProduto').value,$('slTipoVeiculo').value,$('obsPadrao').value);});
            shortcut.add("Shift+I",function() {importar();});
            shortcut.add("Shift+S",function() {salva();});
            var listaTipoProdutoAll = new Array();
            var listaTipoVeiculoAll = new Array();
            var listaTipoFreteAll = new Array();
            var listaCategoriaCargaAll = new Array();
            listaTipoFreteAll[0] = new Option(-1, "--Selecione--");
            listaTipoFreteAll[1] = new Option(0, "Peso/Kg");
            listaTipoFreteAll[2] = new Option(1, "Peso/Cubagem");
            listaTipoFreteAll[3] = new Option(2, "% Nota Fiscal");
            listaTipoFreteAll[4] = new Option(3, "Combinado");
            listaTipoFreteAll[5] = new Option(4, "Por Volume");
            listaTipoFreteAll[6] = new Option(5, "Por Km");
            listaTipoFreteAll[7] = new Option(6, "Por Pallet");
            //---------------    variaveis utilizadas para definir o cfop do ctrc  ---- INICIO
            var idCfopComercioDentro = "${configuracao.cfopDefault.idcfop}";
            var cfopComercioDentro = "${configuracao.cfopDefault.cfop}";
            var idCfopComercioFora = "${configuracao.cfopDefault2.idcfop}";
            var cfopComercioFora = "${configuracao.cfopDefault2.cfop}";
            var idCfopIndDentro = "${configuracao.cfopIndustriaDentro.idcfop}";
            var cfopIndDentro = "${configuracao.cfopIndustriaDentro.cfop}";
            var idCfopIndFora = "${configuracao.cfopIndustriaFora.idcfop}";
            var cfopIndFora = "${configuracao.cfopIndustriaFora.cfop}";
            var idCfopPFDentro = "${configuracao.cfopPessoaFisicaDentro.idcfop}";
            var cfopPFDentro = "${configuracao.cfopPessoaFisicaDentro.cfop}";
            var idCfopPFFora = "${configuracao.cfopPessoaFisicaFora.idcfop}";
            var cfopPFFora = "${configuracao.cfopPessoaFisicaFora.cfop}";
            var idCfopOutroEstado = "${configuracao.cfopOutroEstado.idcfop}";
            var cfopOutroEstado = "${configuracao.cfopOutroEstado.cfop}";
            var idCfopOutroEstadoFora = "${configuracao.cfopOutroEstadoFora.idcfop}";
            var cfopOutroEstadoFora = "${configuracao.cfopOutroEstadoFora.cfop}";
            var idCfopTransporteDentro = "${configuracao.cfopTransporteDentro.idcfop}";
            var cfopTransporteDentro = "${configuracao.cfopTransporteDentro.cfop}";
            var idCfopTransporteFora = "${configuracao.cfopTransporteFora.idcfop}";
            var cfopTransporteFora = "${configuracao.cfopTransporteFora.cfop}";
            var idCfopPrestacaoServicoDentro = "${configuracao.cfopPrestadorServicoDentro.idcfop}";
            var cfopPrestacaoServicoDentro = "${configuracao.cfopPrestadorServicoDentro.cfop}";
            var idCfopPrestacaoServicoFora = "${configuracao.cfopPrestadorServicoFora.idcfop}";
            var cfopPrestacaoServicoFora = "${configuracao.cfopPrestadorServicoFora.cfop}";
            var idCfopProdutorRuralDentro = "${configuracao.cfopProdutorRuralDentro.idcfop}";
            var cfopProdutorRuralDentro = "${configuracao.cfopProdutorRuralDentro.cfop}";
            var idCfopProdutorRuralFora = "${configuracao.cfopProdutorRuralFora.idcfop}";
            var cfopProdutorRuralFora = "${configuracao.cfopProdutorRuralFora.cfop}";
            var idCfopExteriorDentro = "${configuracao.cfopExteriorDentro.idcfop}";
            var cfopExteriorDentro = "${configuracao.cfopExteriorDentro.cfop}";
            var idCfopExteriorFora = "${configuracao.cfopExteriorFora.idcfop}";
            var cfopExteriorFora = "${configuracao.cfopExteriorFora.cfop}";
            var idCfopSubContratacaoDentro = "${configuracao.cfopSubContratacaoDentro.idcfop}";
            var cfopSubContratacaoDentro = "${configuracao.cfopSubContratacaoDentro.cfop}";
            var idCfopSubContratacaoFora = "${configuracao.cfopSubContratacaoFora.idcfop}";
            var cfopSubContratacaoFora = "${configuracao.cfopSubContratacaoFora.cfop}";
            //---------------    variaveis utilizadas para definir o cfop do ctrc  ---- FIM

            listaTipoDocNf[countListaTipoDocNf++] = new Option('NF', 'NF');
            listaTipoDocNf[countListaTipoDocNf++] = new Option('NE', 'NF-e');
            listaTipoDocNf[countListaTipoDocNf++] = new Option('00', 'Declaração');
            listaTipoDocNf[countListaTipoDocNf++] = new Option('10', 'Dutoviário');
            listaTipoDocNf[countListaTipoDocNf++] = new Option('99', 'Outros');
            listaTipoDocNf[countListaTipoDocNf++] = new Option('59', 'CF-e SAT');
            listaTipoDocNf[countListaTipoDocNf++] = new Option('65', 'NFC-e');

    
            listaTipoProdutoAll[0] = new Option('', 'NENHUM');
            <c:forEach var="tipo" varStatus="status" items="${listaTipoProduto}">
                listaTipoProdutoAll[${status.count}] = new Option('${tipo.id}', '${tipo.descricao}');
            </c:forEach>
            <c:forEach var="tipo" varStatus="status" items="${listaTipoVeiculo}">
                listaTipoVeiculoAll[${status.count - 1}] = new Option('${tipo.id}', '${tipo.descricao}');
            </c:forEach>
            <c:forEach var="fpgto" varStatus="status" items="${listaFpgto}">
                listaFormaPagamento[${status.count - 1}] = new Option('${fpgto.idFPag}', '${fpgto.descFPag}');
            </c:forEach>
            
            <c:forEach var="conta" varStatus="status" items="${listaConta}">
                listaConta[${status.count - 1}] = new Option('${conta.idConta}', '${conta.numero}-${conta.digito_conta}/${conta.banco.descricao}');
            </c:forEach>
            <c:forEach var="stIcms" varStatus="status" items="${listaStIcms}">
                listaStICMS[${status.count - 1}] = new Option('${stIcms.id}', '${stIcms.codigo}-${stIcms.descricao}');
            </c:forEach>
            <c:forEach var="categ" varStatus="status" items="${listaCategoriaCarga}">
                listaCategoriaCargaAll[${status.count}] = new Option('${categ.id}', '${categ.descricao}');
            </c:forEach>
                function aoClicarNoLocaliza(idJanela){
                    try{
                        var index = $("indexAux").value;
                        
                        if(idJanela == "Remetente"){
                            $("idRemetente_"+index).value = $("idremetente").value;
                            $("remetente_"+index).value = $("rem_rzs").value;
                            $("remetenteCidade_"+index).value = $("rem_cidade").value;
                            $("remetenteCidadeId_"+index).value = $("rem_idcidade").value;
                            $("remetenteUF_"+index).value = $("rem_uf").value;
                            $("remetenteCNPJ_"+index).value = $("rem_cnpj").value;
                            $("remetenteStIcms_"+index).value = $("st_icms").value;
                            $("remetenteTipoPgto_"+index).value = $("remtipofpag").value;
                            $("remetenteQtdDiasPgto_"+index).value = $("rem_pgt").value;
                            $("remetenteObs_"+index).value = $("rem_obs").value;
                            $("cidadeOrigemLocais_"+index).value = $("rem_cidade").value;
                            $("tipoCfopRemetente_"+index).value = $("rem_tipo_cfop").value;
                            $("cidadeOrigemIdLocais_"+index).value = $("rem_idcidade").value;
                            $("ufOrigemLocais_"+index).value = $("rem_uf").value;
                            $("inscricaoEstadualRemetente_"+index).value = $("rem_insc_est").value;
                            $("obrigaTabelaTipoProduto_"+index).value = $("rem_uf").value;
                            $("remetenteTipoCGC_"+index).value = $("rem_tipo_cgc").value;
                            $("remetenteTipoCGC_"+index).value = $("rem_tipo_cgc").value;
                            $("isStMgRemetente_"+index).value = $("rem_st_mg").value;
                            $("tipoTabelaRemetente_"+index).value = $("rem_tipotaxa").value;
                            $("utilizaPautaFiscalRemetente_"+index).value = $("pauta_remetente").value;
                            $("remetenteTipoOrigemFrete_"+index).value = $("remtipoorigem").value;
                            $("remetenteUtilizaTabelaRemetente_"+index).value = $("rem_tabela_remetente").value;
                            $("taxaRouboLocais_"+index).value = $("taxa_roubo").value;
                            $("taxaRouboUrbanoLocais_"+index).value = $("taxa_roubo_urbano").value;
                            $("taxaTombamentoUrbanoLocais_"+index).value = $("taxa_tombamento_urbano").value;
                            $("taxaTombamentoLocais_"+index).value = $("taxa_tombamento").value;
                            $("remetenteVendedor_"+index).value = $("venremetente").value;
                            $("remetenteVendedorId_"+index).value = $("idvenremetente").value;
                            $("remetenteVendedorComissao_"+index).value = $("vlvenremetente").value;
                            $("remetenteUnificadaModalVendedor_" + index).value = $("rem_unificada_modal_vendedor").value;
                            $("remetentePercComissaoRodoviarioFracionadoVendedor_" + index).value = $("rem_comissao_rodoviario_fracionado_vendedor").value;
                            $("remetentePercComissaoRodoviarioLotacaoVendedor_" + index).value = $("rem_comissao_rodoviario_lotacao_vendedor").value;
                            $("rotaLocais_"+index).value = $("rota_viagem").value;
                            $("rotaIdLocais_"+index).value = $("id_rota_viagem").value;
                            $("distanciaKmLocais_"+index).value = $("distancia_km").value;
                            $("utilizaTipoFreteTabelaRemetente_"+ index).value = $("is_utilizar_tipo_frete_tabela").value;
                            $("stIcmsRem_"+ index).value = $("st_icms").value;
                            $("reducaoBaseIcmsRemetente_"+index).value = $("rem_reducao_icms").value;
                            $("utilizarNormativaGSF598GORemetente_"+index).value = $("rem_is_in_gsf_598_03_go").value;
                            $("valorCreditoPresumidoRemetente_"+index).value = $("st_rem_credito_presumido").value;
                            $("utilizarNormativaGSF129816GORemetente_"+index).value = $("rem_is_in_gsf_1298_16_go").value;
                            $("enderecoColetaId_"+ index).value = $("endereco_coleta_id").value;
                            $("_msgRemetente_cte_"+index).value = $("mensagem_usuario_cte_rem").value;
                            $("_tipoArredondamentoPesoRemetente_"+index).value = $("tipo_arredondamento_peso_rem").value;
                            $("_isfreteDirigidoRemetente_"+index).value = $("is_frete_dirigido").value;
                            $("tipoTributacao_Remetente_"+index).value = $("rem_tipo_tributacao").value;
                            $("_utilizarTabelaCliente_id_Remetente_"+index).value = $("rem_utilizar_tabela_cliente").value;
                            removeOptionSelected($("remetenteTipoProduto_" + index).id);
                            var strOption = "";
                            var tiposProduto = $("tipos_produto").value;
                            for (var i = 0; tiposProduto != "" &&  i < tiposProduto.split(",").length; i++) {
                                strOption += "<option value='"+tiposProduto.split(",")[i].split("!!")[0]+"'>";
                                strOption += tiposProduto.split(",")[i].split("!!")[1];
                                strOption += "</option>";
                            }
                            $("remetenteTipoProduto_" + index).innerHTML = strOption;
                            alterarTipoPagamento(index);
                            atribuirCfopPadrao(index);
                            
                           // definirAliquotaIcmsCtrc(index, false);
                           if ($("idRemetente_"+index).value == $("idConsignatario_"+index).value) {
                                getObsCliente(index, getObs($("rem_obs").value));
                            }
                            
                            getPautaFiscal(index);
                            alteraTipoTaxa("S", index);
                            $("tipoDocumentoPadraoRemetente_"+index).value = $("tipo_documento_padrao").value;
                            $("remetenteObsFisco_"+index).value = $("rem_obs_fisco").value;
                            $("remetenteEspecieSerieModalCliente_"+index).value = $("rem_is_especie_serie_modal").value;
                            $("remetenteEspecieCliente_"+index).value = $("rem_especie_cliente").value;
                            $("remetenteSerieCliente_"+index).value = $("rem_serie_cliente").value;
                            $("remetenteModalCliente_"+index).value = $("rem_modal_cliente").value;
                            $("remetenteGerarNfseCidadeOrigemDestinoCteLote_"+index).value = $("rem_gerar_nfse_mesma_cidade").value;
                            $("remetenteTipoNfseCidadeOrigemDestinoCteLote_"+index).value = $("tipo_rem_gerar_nfse_mesma_cidade").value;
                            $("remetente-serie-minuta-"+index).value = $("rem_serie_minuta").value;
                        }else if(idJanela == "Destinatario"){
                            $("idDestinatario_"+index).value = $("iddestinatario").value;
                            $("destinatario_"+index).value = $("dest_rzs").value;
                            $("destinatarioCidade_"+index).value = $("dest_cidade").value;
                            $("destinatarioTipoPgto_"+index).value = $("desttipofpag").value;
                            $("destinatarioQtdDiasPgto_"+index).value = $("dest_pgt").value;
                            $("destinatarioCidadeId_"+index).value = $("cidade_destino_id").value;
                            $("destinatarioUF_"+index).value = $("dest_uf").value;
                            $("destinatarioCNPJ_"+index).value = $("dest_cnpj").value;
                            $("destinatarioStIcms_"+index).value = $("st_icms").value;
                            $("destinatarioObs_"+index).value = $("dest_obs").value;
                            $("tipoCfopDestinatario_"+index).value = $("des_tipo_cfop").value;
                            $("cidadeDestinoLocais_"+index).value = $("dest_cidade").value;
                            $("cidadeDestinoIdLocais_"+index).value = $("cidade_destino_id").value;
                            $("inscricaoEstadualDestinatario_"+index).value = $("dest_insc_est").value;
                            $("ufDestinoLocais_"+index).value = $("dest_uf").value;
                            $("destinatarioTipoCGC_"+index).value = $("dest_tipo_cgc").value;
                            $("isTde_"+index).checked = $("des_inclui_tde").value == "t" ? true : false;
                            $("incluirTdeDestinatario_"+index).value = $("des_inclui_tde").value;
                            $("reducaoBaseIcmsDestinatario_"+index).value = $("des_reducao_icms").value;
                            $("utilizarNormativaGSF598GODestinatario_"+index).value = $("des_is_in_gsf_598_03_go").value;
                            $("valorCreditoPresumidoDestinatario_"+index).value = $("st_des_credito_presumido").value;
                            $("utilizarNormativaGSF129816GODestinatario_"+index).value = $("des_is_in_gsf_1298_16_go").value;
                            $("utilizaPautaFiscalDestinatario_"+index).value = $("pauta_destinatario").value;
                            $("destinatarioTipoOrigemFrete_"+index).value = $("desttipoorigem").value;
                            $("tipoTabelaDestinatario_"+index).value = $("dest_tipotaxa").value;
                            $("destinatarioUtilizaTabelaRemetente_"+index).value = $("des_tabela_remetente").value;
                            $("destinatarioTabelaRemetenteIds_"+index).value = $("cliente_tabela_remetente_ids").value;
                            $("taxaRouboLocais_"+index).value = $("taxa_roubo").value;
                            $("taxaRouboUrbanoLocais_"+index).value = $("taxa_roubo_urbano").value;
                            $("taxaTombamentoUrbanoLocais_"+index).value = $("taxa_tombamento_urbano").value;
                            $("taxaTombamentoLocais_"+index).value = $("taxa_tombamento").value;
                            $("destinatarioVendedor_"+index).value = $("vendestinatario").value;
                            $("destinatarioVendedorId_"+index).value = $("idvendestinatario").value;
                            $("destinatarioVendedorComissao_"+index).value = $("vlvendestinatario").value;
                            $("destinatarioUnificadaModalVendedor_" + index).value = $("des_unificada_modal_vendedor").value;
                            $("destinatarioPercComissaoRodoviarioFracionadoVendedor_" + index).value = $("des_comissao_rodoviario_fracionado_vendedor").value;
                            $("destinatarioPercComissaoRodoviarioLotacaoVendedor_" + index).value = $("des_comissao_rodoviario_lotacao_vendedor").value;
                            $("rotaLocais_"+index).value = $("rota_viagem").value;
                            $("rotaIdLocais_"+index).value = $("id_rota_viagem").value;
                            $("distanciaKmLocais_"+index).value = $("distancia_km").value;
                            $("utilizaTipoFreteTabelaDestinatario_"+ index).value = $("is_utilizar_tipo_frete_tabela").value;
                            $("stIcmsDest_"+ index).value = $("st_icms").value;
                            $("enderecoEntregaId_"+ index).value = $("endereco_entrega_id").value;
                            $("_msgDestinatario_cte_"+index).value = $("mensagem_usuario_cte_des").value;
                            $("_tipoArredondamentoPesoDestinatario_"+index).value = $("tipo_arredondamento_peso_dest").value;
                            $("tipoTributacao_Destinatario_"+index).value = $("dest_tipo_tributacao").value;
                            $("destinatariotipoProdutoDestinatario_"+index).value = $("tipo_produto_destinatario_id").value;
                            $("_utilizarTabelaCliente_id_Destinatario_"+index).value = $("dest_utilizar_tabela_cliente").value;
                            $("destinatarioObsFisco_"+index).value = $("dest_obs_fisco").value;
                            
                            removeOptionSelected($("destinatarioTipoProduto_" + index).id);
                            var strOption = "";
                            var tiposProduto = $("tipos_produto").value;
                            for (var i = 0; tiposProduto != "" &&  i < tiposProduto.split(",").length; i++) {
                                strOption += "<option value='"+tiposProduto.split(",")[i].split("!!")[0]+"'>";
                                strOption += tiposProduto.split(",")[i].split("!!")[1];
                                strOption += "</option>";
                            }
                            $("destinatarioTipoProduto_" + index).innerHTML = strOption;
                            
                            alterarTipoPagamento(index);
                            atribuirCfopPadrao(index);
                                                       // definirAliquotaIcmsCtrc(index, false);
                                                       
                            if ($("idDestinatario_"+index).value == $("idConsignatario_"+index).value) {
                                getObsCliente(index, getObs($("dest_obs").value));
                            }
                            getPautaFiscal(index);
                            alteraTipoTaxa("S", index);
                            $("destinatarioEspecieSerieModalCliente_"+index).value = $("dest_is_especie_serie_modal").value;
                            $("destinatarioEspecieCliente_"+index).value = $("dest_especie_cliente").value;
                            $("destinatarioSerieCliente_"+index).value = $("dest_serie_cliente").value;
                            $("destinatarioModalCliente_"+index).value = $("dest_modal_cliente").value;
                            $("destinatarioGerarNfseCidadeOrigemDestinoCteLote_"+index).value = $("dest_gerar_nfse_mesma_cidade").value;
                            $("destinatarioTipoNfseCidadeOrigemDestinoCteLote_"+index).value = $("tipo_dest_gerar_nfse_mesma_cidade").value;
                            $("destinatario-serie-minuta-"+index).value = $("dest_serie_minuta").value;
                            $("json_taxas_conhecimento_"+index).value = $("json_taxas").value;
                            $("is_nfe_por_entrega_"+index).value = $("rota_is_nfe_por_entrega").value;
                        }else if(idJanela == "Consignatario"){
                            $("idConsignatario_"+index).value = $("idconsignatario").value;
                            $("consignatario_"+index).value = $("con_rzs").value;
                            $("consignatarioCidade_"+index).value = $("con_cidade").value;
                            $("consignatarioCidadeId_"+index).value = $("con_idcidade").value;
                            $("consignatarioUF_"+index).value = $("con_uf").value;
                            $("consignatarioCNPJ_"+index).value = $("con_cnpj").value;
                            $("utilizaPautaFiscalConsignatario_"+index).value = $("pauta_consignatario").value;
                            $("consignatarioTipoOrigemFrete_"+index).value = $("contipoorigem").value;
                            $("tipoTabelaConsignatario_"+index).value = $("con_tipotaxa").value;
                            $("consignatarioUtilizaTabelaRemetente_"+index).value = $("con_tabela_remetente").value;
                            $("consignatarioTipoPgto_"+index).value = $("tipofpag").value;
                            $("consignatarioQtdDiasPgto_"+index).value = $("con_pgt").value;
                            $("consignatarioStIcms_"+index).value = $("st_icms").value;
                            if (parseInt($("consignatarioStIcms_" + index).value, 10) == 0) {
                                $("stIcms_" + index).value = $("stIcmsConfig_" + index).value;
                            } else {
                                $("stIcms_" + index).value = $("consignatarioStIcms_" + index).value;
                            }
                            $("reducaoBaseIcmsConsignatario_"+index).value = $("con_reducao_icms").value;
                            $("utilizarNormativaGSF598GOConsignatario_"+index).value = $("con_is_in_gsf_598_03_go").value;
                            $("valorCreditoPresumidoConsignatario_"+index).value = $("st_cli_credito_presumido").value;
                            $("utilizarNormativaGSF129816GOConsignatario_"+index).value = $("con_is_in_gsf_1298_16_go").value;
                            $("observacaoOutros_"+index).value = getObs($("con_obs").value);
                            $("vendedorOutros_"+index).value = $("ven_rzs").value;
                            $("vendedorIdOutros_"+index).value = $("idvendedor").value;
                            $("vendedorComissaoOutros_"+index).value = $("comissaoVendedor").value;
                            $("consignatarioUnificadaModalVendedor_" + index).value = $("con_unificada_modal_vendedor").value;
                            $("consignatarioPercComissaoRodoviarioFracionadoVendedor_" + index).value = $("con_comissao_rodoviario_fracionado_vendedor").value;
                            $("consignatarioPercComissaoRodoviarioLotacaoVendedor_" + index).value = $("con_comissao_rodoviario_lotacao_vendedor").value;
                            $("_tipoArredondamentoPesoConsignatario_"+index).value = $("tipo_arredondamento_peso_con").value;
                            $("inscricaoEstadualConsignatario_"+index).value = $("con_insc_est").value;
                            $("tipoTributacao_Consignatario_"+index).value = $("con_tipo_tributacao").value;
                            $("_utilizarTabelaCliente_id_Consignatario_"+index).value = $("con_utilizar_tabela_cliente").value;
                            if($("mensagem_usuario_cte_des").value !== "" && $("mensagem_usuario_cte_des").value !== null){
                                setMsgCliente(index, $("_msgDestinatario_cte_"+index).value);
                            }else{
                                limparMsgCliente(index);
                            }
                            if ($("consignatarioUtilizaTabelaRemetente_" + index).value == "n") {
                                $("utilizaTipoFreteTabelaConsignatario_"+ index).value = $("is_utilizar_tipo_frete_tabela").value;
                            } else {
                                $("utilizaTipoFreteTabelaConsignatario_" + index).value = $("utilizaTipoFreteTabelaRemetente_" + index).value;
                            }
                            
                            removeOptionSelected($("consignatarioTipoProduto_" + index).id);
                            var strOption = "";
                            var tiposProduto = $("tipos_produto").value;
                            for (var i = 0; tiposProduto != "" &&  i < tiposProduto.split(",").length; i++) {
                                strOption += "<option value='"+tiposProduto.split(",")[i].split("!!")[0]+"'>";
                                strOption += tiposProduto.split(",")[i].split("!!")[1];
                                strOption += "</option>";
                            }
                            $("consignatarioTipoProduto_" + index).innerHTML = strOption;
                            $("observacaoFiscoOutros_"+index).value = getObs($("con_obs_fisco").value);
                            copyOption($("consignatarioTipoProduto_" + index), $("tipoProdutoTabela_" + index));
                            definiCidadeOrigem(index);
                            definirTipoFrete(index);
                            atribuirCfopPadrao(index);
                            definirComissaoVendedorLote(index);
                            getObsCliente(index, getObs($("con_obs").value));
                            //definirAliquotaIcmsCtrc(index, false);
                            alteraTipoTaxa("S", index);
                            $("consignatarioEspecieSerieModalCliente_"+index).value = $("con_is_especie_serie_modal").value;
                            $("consignatarioEspecieCliente_"+index).value = $("con_especie_cliente").value;
                            $("consignatarioSerieCliente_"+index).value = $("con_serie_cliente").value;
                            $("consignatarioModalCliente_"+index).value = $("con_modal_cliente").value;
                            $("consignatarioGerarNfseCidadeOrigemDestinoCteLote_"+index).value = $("con_gerar_nfse_mesma_cidade").value;
                            $("consignatarioTipoNfseCidadeOrigemDestinoCteLote_"+index).value = $("tipo_con_gerar_nfse_mesma_cidade").value;
                            $("consignatario-serie-minuta-"+index).value = $("con_serie_minuta").value;
                            $("json_taxas_conhecimento_"+index).value = $("json_taxas").value;
                        }else if(idJanela == "Redespacho"){
                            $("idRedespacho_"+index).value = $("idredespacho").value;
                            $("redespacho_"+index).value = $("red_rzs").value;
                            $("redespachoCidade_"+index).value = $("red_cidade").value;
                            $("redespachoCidadeId_"+index).value = $("red_cidade_id").value;
                            $("redespachoUF_"+index).value = $("red_uf").value;
                            $("tipoTabelaRedespacho_"+index).value = $("red_tipotaxa").value;
                            $("redespachoCNPJ_"+index).value = $("red_cnpj").value;
                            $("redespachoUtilizaTabelaRemetente_"+index).value = $("red_tabela_remetente").value;
                            $("utilizaPautaFiscalRedespacho_"+index).value = $("pauta_redespacho").value;
                            $("redespachoTipoOrigemFrete_"+index).value = $("redtipoorigem").value;
                            $("redespachoTipoPgto_"+index).value = $("redtipofpag").value;
                            $("redespachoQtdDiasPgto_"+index).value = $("red_pgt").value;
                            $("redespachoVendedorComissao_"+index).value = $("vlvenredespacho").value;
                            $("redespachoUnificadaModalVendedor_" + index).value = $("red_unificada_modal_vendedor").value;
                            $("redespachoPercComissaoRodoviarioFracionadoVendedor_" + index).value = $("red_comissao_rodoviario_fracionado_vendedor").value;
                            $("redespachoPercComissaoRodoviarioLotacaoVendedor_" + index).value = $("red_comissao_rodoviario_lotacao_vendedor").value;
                            $("utilizaTipoFreteTabelaRedespacho_" + index).value = $("is_utilizar_tipo_frete_tabela").value;
                            $("stIcmsRed_"+ index).value = $("st_icms").value;
                            $("reducaoBaseIcmsRedespacho_"+index).value = $("red_reducao_icms").value;
                            $("utilizarNormativaGSF598GORedespacho_"+index).value = $("red_is_in_gsf_598_03_go").value;
                            $("valorCreditoPresumidoRedespacho_"+index).value = $("st_red_credito_presumido").value;
                            $("utilizarNormativaGSF129816GORedespacho_"+index).value = $("red_is_in_gsf_1298_16_go").value;
                            $("utilizaTipoFreteTabelaRedespacho_" + index).value = $("is_utilizar_tipo_frete_tabela").value;
                            $("_msgRedespacho_cte_"+index).value = $("mensagem_usuario_cte_red").value;
                            $("_tipoArredondamentoPesoRedespacho_"+index).value = $("tipo_arredondamento_peso_red").value;
                            $("inscricaoEstadualRedespacho_"+index).value = $("red_insc_est").value;
                            $("tipoTributacao_Redespacho_"+index).value = $("red_tipo_tributacao").value;
                            $("_utilizarTabelaCliente_id_Redespacho_"+index).value = $("red_utilizar_tabela_cliente").value;
                            removeOptionSelected($("redespachoTipoProduto_" + index).id);
                            var strOption = "";
                            var tiposProduto = $("tipos_produto").value;
                            for (var i = 0; tiposProduto != "" &&  i < tiposProduto.split(",").length; i++) {
                                strOption += "<option value='"+tiposProduto.split(",")[i].split("!!")[0]+"'>";
                                strOption += tiposProduto.split(",")[i].split("!!")[1];
                                strOption += "</option>";
                            }
                            $("redespachoTipoProduto_" + index).innerHTML = strOption;
                            if ($("rec_"+index).checked) {
                                $("recebedor_"+index).value = $("redespacho_"+index).value;
                                $("idRecebedor_"+index).value = $("idRedespacho_"+index).value;
                                $("cidadeDestinoLocais_"+ index).value = $("red_cidade").value;
                                $("cidadeDestinoIdLocais_"+ index).value = $("red_cidade_id").value;
                                $("ufDestinoLocais_"+ index).value = $("red_uf").value;
                                $("idcidadedestino").value = $("cidadeDestinoIdLocais_"+index).value;
                            }else{
                                $("expedidor_"+index).value = $("redespacho_"+index).value;
                                $("idExpedidor_"+index).value = $("idRedespacho_"+index).value;
                                cidadeOrigemExpedidor(index);
                            }

                            $("redespachoObsFisco_"+index).value = $("red_obs_fisco").value;
                            alterarTipoPagamento(index);
                            definirAliquotaIcmsCtrc(index, false);
                            atribuirCfopPadrao(index);
                            recalcular(index);
                            $("redespachoEspecieSerieModalCliente_"+index).value = $("red_is_especie_serie_modal").value;
                            $("redespachoEspecieCliente_"+index).value = $("red_especie_cliente").value;
                            $("redespachoSerieCliente_"+index).value = $("red_serie_cliente").value;
                            $("redespachoModalCliente_"+index).value = $("red_modal_cliente").value;
                        }else if(idJanela == "Cidade_Origem"){
                            $("cidadeOrigemLocais_"+index).value = $("cid_origem").value;
                            $("cidadeOrigemIdLocais_"+index).value = $("idcidadeorigem").value;
                            $("ufOrigemLocais_"+index).value = $("uf_origem").value;
                            $("rotaLocais_"+index).value = $("rota_viagem").value;
                            $("rotaIdLocais_"+index).value = $("id_rota_viagem").value;
                            $("distanciaKmLocais_"+index).value = $("distancia_km").value;
                            definirAliquotaIcmsCtrc(index, false);
                            getPautaFiscal(index);
                            atribuirCfopPadrao(index);
                            alteraTipoTaxa("N", index);
                            definirICMSCTe(index);
                        }else if(idJanela == "Cidade_Destino"){
                            $("cidadeDestinoLocais_"+index).value = $("cid_destino").value;
                            $("cidadeDestinoIdLocais_"+index).value = $("idcidadedestino").value;
                            $("ufDestinoLocais_"+index).value = $("uf_destino").value;
                            $("rotaLocais_"+index).value = $("rota_viagem").value;
                            $("rotaIdLocais_"+index).value = $("id_rota_viagem").value;
                            $("distanciaKmLocais_"+index).value = $("distancia_km").value;
                            definirAliquotaIcmsCtrc(index, false);
                            getPautaFiscal(index);
                            atribuirCfopPadrao(index);
                            alteraTipoTaxa("N", index);
                            definirICMSCTe(index);
                        }else if(idJanela == "Vendedor"){
                            $("vendedorOutros_"+index).value = $("ven_rzs").value;
                            $("vendedorIdOutros_"+index).value = $("idvendedor").value;
                        }else if(idJanela == "Representante"){
                            $("representanteOutros_"+index).value = $("redspt_rzs").value;
                            $("representanteIdOutros_"+index).value = $("idredespachante").value;
                        }else if(idJanela == "Observacao"){
                            $("observacaoOutros_"+index).value = replaceAll($("obs_desc").value, "<br>", "\r\n");
                        }else if(idJanela == "CFOP"){
                            $("cfopCtrc_"+index).value = $("cfop").value;
                            $("cfopCtrcId_"+index).value = $("idcfop").value;
                        }else if(idJanela == "CFOP_Nota"){
                            $("notaCfop_"+index).value = $("cfop").value;
                            $("notaCfopId_"+index).value = $("idcfop").value;
                        }else if(idJanela == "Destinatario_Nota"){
                            $("notaDestinatario_"+index).value = $("dest_rzs").value;
                            $("notaDestinatarioId_"+index).value = $("iddestinatario").value;
                        }else if(idJanela == 'Agente_Pagador'){
                            var idx = $('indexAux').value;
                            //lembrar de colocar o percentual do abastecimento
                            $('agentePgto_'+idx).value = $('agente').value;
                            $('idAgentePgto_'+idx).value = $('idagente').value;
                        }else if (idJanela.substring(0,25) == 'Fornecedor_Contrato_Frete'){
                            var idxForn = idJanela.split('_')[3];
                            $('idFornDespCarta_'+idxForn).value = $('idfornecedor').value;
                            $('fornDespCarta_'+idxForn).value = $('fornecedor').value;
                            $('idPlanoDespCarta_'+idxForn).value = $('idplcustopadrao').value;
                            $('planoDespCarta_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
                        }else if (idJanela.substring(0,14) == 'Fornecedor_ADV'){
                            var idxForn = idJanela.split('_')[2];
                            $('idFornDespADV_'+idxForn).value = $('idfornecedor').value;
                            $('fornDespADV_'+idxForn).value = $('fornecedor').value;
                            $('idPlanoDespADV_'+idxForn).value = $('idplcustopadrao').value;
                            $('planoDespADV_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
                        }else if (idJanela.substring(0,9) == 'Plano_ADV'){
                            var idxPlano = idJanela.split('_')[2];
                            $('idPlanoDespADV_'+idxPlano).value = $('idplanocusto_despesa').value;
                            $('planoDespADV_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
                        }else if (idJanela.substring(0,20) == 'Plano_Contrato_Frete'){
                            var idxPlano = idJanela.split('_')[3];
                            $('idPlanoDespCarta_'+idxPlano).value = $('idplanocusto_despesa').value;
                            $('planoDespCarta_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
                        }else if (idJanela == "MotoristaOutros"){
                            if (($("bloqueado").value == 't' || $("bloqueado").value == "true") && idJanela == "MotoristaOutros") {
                                alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
                                $("motorista_Outros_"+index).value = '';
                                $("motoristaId_Outros_"+index).value = '0';
                                $("bloqueado").value = ''
                            }else{
                            $("motoristaId_Outros_"+index).value = $("idmotorista").value;
                            $("motorista_Outros_"+index).value = $("motor_nome").value;
                            }
                        }else if (idJanela == "VeiculoOutros"){
                            $("veiculoId_Outros_"+index).value = $("idveiculo").value;
                            $("veiculo_Outros_"+index).value = $("vei_placa").value;
                            validarBloqueioVeiculoOutros("Veiculo", index);
                        }else if (idJanela == "CarretaOutros"){
                            $("carretaId_Outros_"+index).value = $("idcarreta").value;
                            $("carreta_Outros_"+index).value = $("car_placa").value;
                            validarBloqueioVeiculoOutros("Carreta", index);
                        }else if (idJanela == "BitremOutros"){
                            $("bitremId_Outros_"+index).value = $("idbitrem").value;
                            $("bitrem_Outros_"+index).value = $("bi_placa").value;
                            validarBloqueioVeiculoOutros("Bitrem", index);
                        }
                       
                        if(idJanela == "Observacao" || idJanela=="CFOP_Nota" || "Destinatario_Nota"){

                        }else{
                            //alteraTipoTaxa("S", index);
                            recalcular(index);
                        }
                        if ((idJanela == "Motorista") || idJanela == "Veiculo" || idJanela == "Carreta" || idJanela == "Bitrem"){
                            carregarAbastecimentos();
                            $("idmotoristaPrincipal").value = $("idmotorista").value;
                            $("motorista_nome").value = $("motor_nome").value;
                            //trazendo placas e validando
                            $("idveiculoPrincipal").value = $("idveiculo").value;
                            $("veiculo_placa").value = $("vei_placa").value;
                            validarBloqueioVeiculo("Veiculo");
                            $("idcarretaPrincipal").value = $("idcarreta").value;
                            $("carreta_placa").value = $("car_placa").value;
                            validarBloqueioVeiculo("Carreta");
                            $("idbitremPrincipal").value = $("idbitrem").value;
                            $("bitrem_placa").value = $("bi_placa").value;
                            validarBloqueioVeiculo("Bitrem");
                            
                            //somando os valores do peso total de todos os conhecimentos
                            var pesoTotal = 0;
                            for (i = 1; i <= parseInt($("maxConhecimento").value); i++) {
                                if($("chkSave_"+i).checked){
                                    pesoTotal += parseFloat(colocarPonto($("valorPesoTotalNF_"+i).value));
                                }
                            }
                            $("peso").value =  pesoTotal;
                            validarBloqueioVeiculoMotorista("veiculo_motorista,carreta_motorista,bitrem_motorista");
                            
                            var tipoVeiculoMotorista = $("tipo_veiculo_motorista");
                            var tipoVeiculoVeiculo = $("tipo_veiculo_veiculo").value;
                            var tipoVeiculoCarreta = $("tipo_veiculo_carreta").value;

                            if(idJanela == "Carreta" && tipoVeiculoCarreta != 0) {
                                tipoVeiculoMotorista.value = tipoVeiculoCarreta;
                            } else if (idJanela == "Veiculo" && tipoVeiculoVeiculo != 0 && $('idcarreta').value == '0') {
                                tipoVeiculoMotorista.value = tipoVeiculoVeiculo;
                            }
                            
                            
                            prepararIniciarContratoFrete();
                            }
                        if(idJanela == "Veiculo"){
                            $("idveiculoPrincipal").value = $("idveiculo").value;
                            $("veiculo_placa").value = $("vei_placa").value;
                                validarBloqueioVeiculo("Veiculo");
                            }
                        if(idJanela == "Carreta"){
                            $("idcarretaPrincipal").value = $("idcarreta").value;
                            $("carreta_placa").value = $("car_placa").value;
                                validarBloqueioVeiculo("Carreta");
                            }
                        if( idJanela == "Bitrem"){
                            $("idbitremPrincipal").value = $("idbitrem").value;
                            $("bitrem_placa").value = $("bi_placa").value;
                                validarBloqueioVeiculo("Bitrem");
                            
                        }else if (idJanela == "Cidade_Origem_Rateio"){
                            $("hiddenCidadeOrigemRateio").value = $("idcidadeorigem").value;
                            $("txtCidadeOrigemRateio").value = $("cid_origem").value;
                            $("txtUfOrigemRateio").value = $("uf_origem").value;
                        }else if (idJanela == "Cidade_Destino_Rateio"){
                            $("hiddenCidadeDestinoRateio").value = $("idcidadedestino").value;
                            $("txtCidadeDestinoRateio").value = $("cid_destino").value;
                            $("txtUfDestinoRateio").value = $("uf_destino").value;
                        }else if (idJanela == "Cliente_Rateio"){
                            $("hiddenConsignatarioRateio").value = $("idconsignatario").value;
                            $("txtConsignatarioRateio").value = $("con_rzs").value;
                            $("tipo_arredondamento_peso_rateio").value = $("tipo_arredondamento_peso_con").value;
                            $("con_utilizar_tabela_cliente_rateio").value = $("con_utilizar_tabela_cliente").value;
                            getTipoProdutos();
                        }else if(idJanela == "Recebedor"){
                            $("idRecebedor_"+index).value = $("idrecebedor").value;
                            $("recebedor_"+index).value = $("rec_rzs").value;
                            $("recebedorCidade_"+index).value = $("rec_cidade").value;
                            $("recebedorCidadeId_"+index).value = $("rec_idcidade").value;
                            $("recebedorUF_"+index).value = $("rec_uf").value;
                            $("recebedorCNPJ_"+index).value = $("rec_cnpj").value;
                            validarCidadeDestinoRecebedor(index);
                        }else if(idJanela == "Expedidor"){
                            $("idExpedidor_"+index).value = $("idexpedidor").value;
                            $("expedidor_"+index).value = $("exp_rzs").value;
                            $("expedidorCidade_"+index).value = $("exp_cidade").value;
                            $("expedidorCidadeId_"+index).value = $("exp_idcidade").value;
                            $("expedidorUF_"+index).value = $("exp_uf").value;
                            $("expedidorCNPJ_"+index).value = $("exp_cnpj").value;
                            validarCidadeOrigemExpedidor(index);
                        }else if (idJanela == "Coleta") {
                            setTimeout(function(){
                                if (confirm("Deseja carregar o valor da coleta no campo valor rateio?")) {
                                    $("isRatearValorFrete").checked = true;
                                    $("valorFrete").value = colocarVirgula($("vlcombinado").value);
                                    mostrarValorRateio();
                                    $("divAdicionarNotaColeta").style.display = "";
                                    $("chkAdicionarNotaColeta").checked = true;
                                }
                            },100);
                            
                        }else if (idJanela.substring(0,11) == 'Nota_Fiscal') {
                            var indexCtrc = idJanela.split('_')[2];
                            var nota = new NotaFiscal();
                            nota.id = $("idnota_fiscal").value;
                            nota.numero = $("numero_nf").value;
                            nota.valor = $("valor_nota").value;
                            nota.peso = $("peso_nota").value;
                            nota.volume = $("volume_nota").value;
                            nota.embalagem = $("embalagem_nota").value;
                            nota.conteudo = $("conteudo_nota").value;
                            nota.baseCalculoIcm = $("vl_base_icms").value;
                            nota.icmsValor = $("vl_icms_nota").value;
                            nota.icmsST = $("vl_icms_st").value;
                            nota.serie = $("serie_nota").value;
                            nota.pedido = $("pedido_nota").value;
                            nota.cfopId = $("cfop_id").value;
                            nota.cfop = $("cfop_nf").value;
                            nota.chaveNFe = $("chave_acesso").value;
                            nota.dataPrevisao = $("nf_previsao_entrega").value;
                            nota.horaPrevisao = $("nf_previsao_entrega_as").value;
                            nota.isAgendado = $("is_agendado").value;
                            nota.dataAgenda = $("data_agenda").value;
                            nota.horaAgenda = $("hora_agenda").value;
                            nota.observacao = $("obs_agenda").value;
                            nota.metroCubico = $("metro_cubico_nota").value;
                            nota.destinatarioId = $("nf_iddestinatario").value;
                            nota.destinatario = $("nf_destinatario").value;                            
                            nota.tipoDocumento = $("tipo_documento").value;
                            
                            var listaCubagens = new Array();
                            var cubagem = null;
                            
                            var maxCubagens = $("max_itens_metro").value;
                            var cubagens = $("cubagens_json").value;
                            var cubagensJson;
                            
                            if (maxCubagens != 0 && cubagens != "") {
                                cubagensJson = JSON.parse(cubagens);    
                            }
                            
                            for (var qtdCb = 0; qtdCb < maxCubagens; qtdCb++) {
                                cubagem = new Cubabem();
                                
                                cubagem.id = cubagensJson.cubagens[qtdCb].id;
                                cubagem.notaFiscalId = nota.id;
                                cubagem.altura = cubagensJson.cubagens[qtdCb].altura;
                                cubagem.comprimento = cubagensJson.cubagens[qtdCb].comprimento;
                                cubagem.largura = cubagensJson.cubagens[qtdCb].largura;
                                cubagem.metroCubico = cubagensJson.cubagens[qtdCb].metro_cubico;
                                cubagem.volume = cubagensJson.cubagens[qtdCb].volumes;
                                listaCubagens[qtdCb] = cubagem;
                                
                            }
                            
                            nota.listaCuabagem = listaCubagens;
                            
                            var classe = ((indexCtrc % 2) != 0 ? 'CelulaZebra2NoAlign' : 'CelulaZebra1NoAlign');
                            addConhecimentoLoteNotasFiscaisConteudo(nota, indexCtrc, classe, $("serie").value, true, false);
                            
                        } else if (idJanela == "Observacao_Fisco") {
                            $("observacaoFiscoOutros_" + index).value = replaceAll($("obs_desc").value, "<br>", "\r\n");
                        }
                        
                    }catch(ex){
                        alert(ex);
                        console.log(ex);
                    }
                }
                
                function fecharPagina(){
                    if(("isFecharPagina").checked){
                        $("isFecharPagina").value = "true";
                    }else{
                        $("isFecharPagina").value = "false";
                    }
                }
                
                function voltar(){
                    tryRequestToServer(function(){parent.document.location.replace("./consultaconhecimento?acao=iniciar")});
                }

    
                function getCtrcsSelecionado(){
                    var lista = new Array();
                    var idx1 = 0;
                    var maxCon = parseInt($("maxConhecimento").value, 10);
                    
                    for (var i = 0; i <= maxCon; i++) {
                        if ($("chkSave_"+i) != null && $("chkSave_"+i).checked) {
                            lista[idx1++] = i;
                        }
                    }
                    return lista;
                }
    
                function salva(acao){
                    //Campo adicionado em 31/03/2016 - Autor : Mateus Veloso - Novo filtro em filial.
                    var filial = $("filial").value;
                    //Campos utilizado na nova validacao.
                    var penultimo = parseFloat(filial.split("@@")[10]);
                    var ultimo = filial.split("@@")[11];
                    
                    
                    var maxCon = parseInt($("maxConhecimento").value, 10);
                    var listCtrcSelecionado = getCtrcsSelecionado();
                    var qtdCtrcAutorizado = getQtdCtrcAutorizados(maxCon);
                    var podeSalvar = true;
                    var tipoConhecimento = $("tipoConhecimento").value;
                    try{
                        if ($("serie") != null && $("serie").value == "") {
                            return showErro("Informe o \'Série\', nos \'Dados Principais\'.", $("serie"));
                        }else if ($("especie") != null && $("serie").value == "") {
                            return showErro("Informe o \'Especie\', nos \'Dados Principais\'.", $("especie"));
                        }

                        if (!$("dataEmissaoCTe") || dataEmissaoCTe.value == '') {
                            return showErro("Informe a 'Data de emissão', nos 'Dados principais'.", $("dataEmissaoCTe"));
                        }

                        for (var i = 1; i <= maxCon; i++) {
                            let valorMercadoriaNF = ($("valorMercadoriaTotalNF_"+i) != undefined ? pontoParseFloat($("valorMercadoriaTotalNF_"+i).value) : 0);
                            if((ultimo == "t" || ultimo == "true") && $("chk_carta_automatica").checked == true && valorMercadoriaNF > penultimo){
                                alert("Atenção : o valor do(s) total(is) da(s) NF(s) é maior que o valor limite da filial de origem.");
                                podeSalvar = false;
                            }
                            if($("chkSave_" + i) != null && $("chkSave_" + i).checked) {
                                if (!validarCtrc(i)) {
                                    podeSalvar =  false;
                                }
                                if ($("qtdNotas_" + i) != null && $("qtdNotas_" + i) != undefined) {
                                    if($("qtdNotas_" + i).value != 0){
                                        for (var n = 1; n <= parseInt($("qtdNotas_" + i).value, 10); n++) {
                                            if ($("notaTipoDocum_"+i+ "_"+n) != null && $("notaTipoDocum_"+i+ "_"+n).value == "NE" && $("notaChaveNFe_"+i+ "_"+n).value == "") {
                                                //localizarNota($("notaNumero_"+i+ "_"+n).value);
                                                return showErro("A nota de número \'"+$("notaNumero_"+i+ "_"+n).value+"\'. No " + 
                                                        i+"º Conhecimento, possui tipo de documento NF-e, mas não foi informada a chave de acesso.");
                                            }
                                            if ($("qtdCubagens_" + i + "_" + n) != null && $("qtdCubagens_" + i + "_" + n) != undefined) {
                                                for (var c = 1; c <= parseInt($("qtdCubagens_" + i + "_" + n).value); c++) {
                                                    if (!validarCubagem(i, n, c)) {
                                                        podeSalvar =  false;
                                                    }
                                                }
                                            }
                                        }
                                    }else {
                                        if(isNumber($("serie").value)){
                                            alert("Favor adicionar Notas Fiscais no CT-e n° "+i );
                                            podeSalvar =  false;
                                        }
                                    }
                                }
                            }
                        //validação para quando o cte for do tipo lotação o motorista é obrigatorio 
                        //coloquei para dentro do for, pois vai validar com o motorista que ven dentro do cte na aba outros
                        if($("modalCTe").value == "l" && ($("idmotoristaPrincipal").value == "0" && $("motoristaId_Outros_"+i).value == "0") && $("chk_carta_automatica").checked){
                            alert("CT-e do tipo Lotação, o campo Motorista é de preenchimento obrigatório!");
                            podeSalvar =  false;
                        }
                        }
                        if ($("chk_carta_automatica").checked && isRetencaoImpostoOperadoraCFeLote()) {
                            let totSaldo = getTotSaldo();
                            let ir = pontoParseFloat($("valorIRInteg").value);
                            let inss = pontoParseFloat($("valorINSSInteg").value);
                            let sest = pontoParseFloat($("valorSESTInteg").value);
                            if (totSaldo < (ir + inss + sest)) {
                                alert("ATENÇÃO: Não é possivel salvar o contrato pois a provisão dos impostos ("
                                            +colocarVirgula((ir + inss + sest))+") é maior que o saldo ("+colocarVirgula(totSaldo)+").");
                                    podeSalvar =  false;
                            }
                        }
                        if (!podeSalvar) {
                            return false;
                        }

                        for(var i = 1;i <= maxCon;i++){
                            habilitar($("aliquotaIcms_"+i));
                            habilitar($("baseCalculoIcms_"+i));
                            habilitar($("stIcms_"+i));
                            habilitar($("valorIcmsBarreira_"+i));
                            
                            habilitar($("tipoFreteTabela_"+i));
                            habilitar($("tipoVeiculoTabela_"+i));
                            
                            habilitar($("isAddIcms_"+i));
                            habilitar($("isAddPisCofins_"+i));
                            habilitar($("isTde_"+i));
                        }
                        
                        
                        habilitar($("filial"));
                        habilitar($("tipoTransporte"));
                        var maxPgtop = $("maxPagContFrete").value;
                        for(var i = 1; i<= maxPgtop; i++){
                            if ($("tipoPagto_"+i) != null && $("tipoPagto_"+i) != undefined) {
                                habilitar($("tipoPagto_"+i));
                                habilitar($("formaPagto_"+i));
                                habilitar($("documPgto2_"+i));
                                habilitar($("contaPgto_"+i));
                                habilitar($("valorPgto_"+i));
                                habilitar($("dataPgto_"+i));
                                habilitar($("documPgto_"+i));
                                habilitar($("tipoContaPgto_"+i));
                                habilitar($("tipoFavorecido_" + i));
                            }
                        }
                        var date = new Date();
                        var acao = "ConhecimentoControlador?acao=importarConhecimentoLote"+
                            "&maxConhecimento="+maxCon +
                            "&maxConhecimentoEnv="+qtdCtrcAutorizado +
                            "&timeTransacao="+(date.getYear() + "-" + date.getMonth() + "-" + date.getDay() + "-" + date.getHours() + "-" + date.getMinutes() + "-" + date.getSeconds() + "-" + date.getMilliseconds()) +
                            "&especie="+$("especie").value +
                            "&serie="+$("serie").value +
                            "&listCtrcSelecionado="+listCtrcSelecionado+
                            "&modalCTe="+$("modalCTe").value +
                            "&numeroCarga="+$("numeroCarga").value +
                            "&pedido="+$("pedido").value +
                            "&idmotoristaPrincipal="+$("idmotoristaPrincipal").value +
                            "&motorista_nome="+$("motorista_nome").value +
                            "&idveiculoPrincipal="+$("idveiculoPrincipal").value +
                            "&veiculo_placa="+$("veiculo_placa").value +
                            "&idcarretaPrincipal="+$("idcarretaPrincipal").value +
                            "&carreta_placa="+$("carreta_placa").value +
                            "&idbitremPrincipal="+$("idbitremPrincipal").value +
                            "&bitrem_placa="+$("bitrem_placa").value +
                            "&dtemissao="+$("dataEmissaoCTe").value +
                            "&tipoTransporte="+$("tipoTransporte").value +
                            "&tipoConhecimento="+$("tipoConhecimento").value +
                            "&filial="+$("filial").value + 
                            "&isFecharPagina="+$("isFecharPagina").checked + 
                            "&tipoServico="+$("tipoServico").value+
                            "&idColeta="+$("idcoleta").value+
                            "&categoriaCarga="+$("categoriaCarga").value+
                            "&chk_reter_impostos="+$("chk_reter_impostos").checked+
                            "&id_funcionario="+$("id_funcionario").value+
                            "&isRetencaoImpostoOpeCFe="+isRetencaoImpostoOperadoraCFeLote()+
                            "&importarConhecimentoLote=true";
                    

                        if ($("containerForms") != null && $("containerForms") != undefined) {
                            Element.remove($("containerForms"));
                        }
                        var divContainer = Builder.node("div", {id: "containerForms"});
                        invisivel(divContainer);
                        setEnv();
                        //                        var pop = window.open('about:blank', "pop", 'width=210, height=100');
                        $("corpo").appendChild(divContainer);
                        
                        var limiteFormCtrcs = 20;
                        
                        var qtdForms = getQtdForms(qtdCtrcAutorizado, limiteFormCtrcs);
                        
                        pops = makePops(qtdForms);
                        
                        var primeiraPosicaoDisponivel = 0;
                        if ("${configuracao.cartaFreteAutomatica}"== "true" && ($("chk_carta_automatica").checked || $("chk_adv_automatica").checked)) {
                            primeiraPosicaoDisponivel =  1;
                        }
                        var listaForms = makeListForms(maxCon, acao, divContainer, limiteFormCtrcs, pops, primeiraPosicaoDisponivel);
                            
                        if ("${configuracao.cartaFreteAutomatica}"== "true"  && ($("chk_carta_automatica").checked || $("chk_adv_automatica").checked)) {
                            var formContratoFrete = $("formContratoFreteViagem");
                            if (formContratoFrete != null) {
                                listaForms[0] = formContratoFrete;
                                
                                formContratoFrete.action = acao + "&thisForm=formContratoFreteViagem" + "&totForm="+listaForms.length;
                                formContratoFrete.method = "post";
                                formContratoFrete.target = "pop_1";
                            }
                        }
                        
                        submeterForms(listaForms);
                        
                        //                        fecharPops(pops);
                        
                        //                        habilitar($("botSalvar"));
                        //                        $("botSalvar").value = "Salvar";
                        //                        window.opener.document.location = "consultaconhecimento?acao=iniciar";
                        
                    
                    }catch(ex){
                        alert(ex);
                    }
                }
                
                function erroSalvarDesabilitar(){
                var maxCon = parseInt($("maxConhecimento").value, 10);
                for(var index = 1; index<= maxCon; index++){
                    if(($('permissao_alteratipofretecte').value) == "false"){
                        desabilitarCampos_alteratipofretecte(index);
                    }
                    if($('alteraprecocte').value == "false"){
                        desabilitarCampos_alteraprecocte(index);
                    }
                    if(($('alterainffiscal').value) == "false"){
                        desabilitarCampos_alterainffiscal(index);
                    }
                }
                }
                
                
                function getCtrcEnv(){
                    var maxCtrc = parseInt($("maxConhecimento").value, 10);
                    var qtdEnv = 0;
                    for (var i = 1; i <= maxCtrc; i++) {
                        if ($("trAba1_" +i ) != null) {
                            qtdEnv++;
                        }
                    }
                    return qtdEnv;
                }
                
                /**
                * Define a quantidade de forms necessarios

                 * @param {int} maxCon
                 * @param {int} limitFormCtrc
                 * @returns {Array}                 */
                function getQtdForms(maxCon, limitFormCtrc){
                    var maxForm = parseInt(maxCon / limitFormCtrc, 10) + (parseInt(maxCon % limitFormCtrc, 10) > 0 ? 1 : 0);
                    return maxForm;
                }
                
                function getPop(indiceForm, listPops){
                    var qtdPops = listPops.length;
                    var resultado = 0;
                    
                    if (qtdPops > 1) {
                        resultado = (indiceForm % 2 == 0 ? 1 : 2);
                    }else{
                        resultado = 1;
                    }
                    
                    return resultado;
                }
                
                /**
                 * Criando lista de forms
                 * @param {int} maxCon
                 * @param {string} acao
                 * @param {HtmlElement} elementoRepositorio
                 * @param {int} limitFormCtrc
                 * @param {int} listPops
                 * @returns {Array}                 */
                function makeListForms(maxCon, acao, elementoRepositorio, limitFormCtrc, listPops, primeiroFormDisponivel){
                    try {
                        var maxForm = getQtdForms(getQtdCtrcAutorizados(maxCon), limitFormCtrc) + primeiroFormDisponivel;
                        var form;
                        var listForms = new Array();
                        var iniForm = 0;
                        var ultimoCtrcAlocado = 0;
                        //varrendo todos os formularios, levando em consideração o primeiro forme, desconciderando formulario de contrato de frete
                        for (var fo = primeiroFormDisponivel; fo < maxForm; fo++) {
                            iniForm = ultimoCtrcAlocado +1;
                            
                            form = makeForm(fo, "post", acao, "pop_"+getPop(fo, listPops));
                            form.action += "&thisForm="+form.id;
                            form.action += "&totForm="+maxForm;
                            form.action += "&primeiraPosicao=" + iniForm;
                            
                            elementoRepositorio.appendChild(form);
                            
                            for (var ct = iniForm, idxQtd = 1; (idxQtd <= limitFormCtrc && ct <= maxCon); ct++) {
                                if ($("trAba1_"+ct) != null && $("chkSave_" + ct) != null && $("chkSave_" + ct) != undefined && $("chkSave_" + ct).checked) {
                                    idxQtd++;
                                    $("tipoProdutoTabelaGamb_" + ct).value = $("tipoProdutoTabela_" + ct).value;
                                    $("tipoFreteTabelaGamb_" + ct).value = $("tipoFreteTabela_" + ct).value;
                                    $("tipoVeiculoTabelaGamb_" + ct).value = $("tipoVeiculoTabela_" + ct).value;
                                    $("observacaoOutrosGamb_" + ct).value = $("observacaoOutros_" + ct).value;
                                    $("stIcmsGamb_" + ct).value = $("stIcms_" + ct).value;//tipoPagamentoF_
                                    $("tipoPagamentoGamb_" + ct).value = ($("tipoPagamentoC_" + ct).checked ? "cif" : ($("tipoPagamentoF_" + ct).checked ? "fob" : "terceiros"));
                                    
                                    for (var nf = 1; nf <= parseInt($("qtdNotas_" + ct).value, 10); nf++) {
                                        if ($("notaTipoDocum_" + ct + "_" + nf) != null) {
                                            $("notaTipoDocumGamb_" + ct + "_" + nf).value = $("notaTipoDocum_" + ct + "_" + nf).value;
                                        }
                                    }
                                    
                                    form.appendChild($("tbodyContainer_"+ct).cloneNode(true));
                                }
                                ultimoCtrcAlocado = ct;
                            }
                            form.action += "&ultimaPosicao=" + ultimoCtrcAlocado;
                            listForms[fo] = form;
                        }
                        return listForms;
                    } catch (e) { 
                        alert(e);
                    }
                }
                
                function retornoSalvar(caminho){
                    fecharPops(pops);
                    if (caminho != null && caminho != undefined && caminho != "") {
                        window.location.href = caminho;
                    }
                }
                
                function fecharPops(listPops){
                    if (listPops != null && listPops != undefined) {
                        for (var p = 0; p < listPops.length; p++) {
                            if (listPops[p] != null && listPops[p] != undefined) {
                                listPops[p].close();
                            }
                        }
                    }
                }
                
                /**
                * 

                 * @returns {undefined}                 */
                function submitForm(formId){
                    try {
                        $(formId).submit();
                    } catch (e) { 
                        alert("erro no form:"+formId);
                    }

                }
                /**
                * Responsavel por criar uma lista de janelas pops

                 * @returns {Array}                 */
                function makePops(qtdForms){
                    var listPops = new Array();
                    var qtdPops = 0;
                    
                    if (parseInt(qtdForms, 10) <= 2) {
                        qtdPops = 1;
                    }else {
                        qtdPops = 2;
                    }
                    //criando os pops a partir da quantidade definida acima
                    for (var p = 1; p <= qtdPops; p++) {
                        listPops[p -1] = window.open('about:blank', "pop_"+p, 'width=210, height=100');
                    }
                    
//                    console.trace();
//                    console.log("listPops:"+listPops);
                    
                    
                    return listPops;
                }
                
                function submeterForms(listForms){
                    try {
                        if (listForms != null && listForms != undefined) {
                            for (var f = 0; f <= listForms.length; f++) {
                                if (listForms[f] != null && listForms[f] != undefined) {
                                    if (f == 0) {
                                        window.setTimeout("submitForm('"+listForms[f].id+"');",0);
                                    }else{
                                        window.setTimeout("submitForm('"+listForms[f].id+"');",10000 * (f + 1));
                                    }
                                }
                            }
                        }
                    } catch (e) { 
                        alert(e);
                    }
                }
                
                function removerForms(listForms){
                    var sizeForms = 0;
                    if (listForms != null && listForms != undefined) {
                        for (var f = 0; f < listForms.length; f++) {
                            if (listForms[f] != null && listForms[f] != undefined) {
                                Element.remove(listForms[f]);
                            }
                        }
                    }
                }

                function excluir(id){
                    if (confirm("Deseja mesmo excluir esta rota?")){
                        location.replace("consulta_rota.jsp?acao=excluir&id="+id);
                    }
                }

                function importar(){
                    var url = "ConhecimentoControlador?acao=novaImportacao";
                    tryRequestToServer(function(){
                        abrirJanela(url, 'importCtrcNFe', 65, 85)
                    });
                }
            
                function iniciarContratoFrete(){
                    var adiantamento = new ContratoFretePagamento();
                    adiantamento.fixo = true;
                    addPagto(adiantamento);
                    var saldo = new ContratoFretePagamento();
                    saldo.tipo ="s";
                    saldo.fixo = true;
                    addPagto(saldo);
                    visivel($("trContratoFreteAutomatico"));
                }
            
                function setDefault(){
                    try {
                        // Limpar sessionStorage da página para limpar o status embutir ICMS/ISS do NFS-e.
                        sessionStorage.clear();

                        var isUtilizaCte = ("${usuario.filial.stUtilizacaoCte}"!="N");
                        if (isUtilizaCte) {
                            $("especie").value = "CTE";
                            $("serie").value = "1";
                        }else{
                            $("especie").value = "CTR";
                            $("serie").value = "${configuracao.seriePadraoCtrc}";
                        }
                        getAliquotasIcmsAjax($("filial").value.split('@@')[0]);
                        //                    invisivel($("trRateio"));
                        habilitar($("filial"));
                        habilitar($("tipoTransporte"));
                        alterarModal();
                        $("cartaDataCC").value = dataAtual;
                        if ("${configuracao.cartaFreteAutomatica}"== "true") {
                            iniciarContratoFrete();
                        }
                        $('modalCTe').value = $("filial").value.split('@@')[5];
                        
                        
                        $("permissao_alteratipofretecte").value = (${param.permissao_alteratipofretecte} == 4);
                        $("alteraprecocte").value = (${param.alteraprecocte} == 4);
                        $("alterainffiscal").value = (${param.alterainffiscal} == 4);
                        $("alteraimpostoscartafrete").value = (${param.alteraimpostoscartafrete} == 4);
                        $("trTipoRateio").style.display = "none";
                        $("trOpcoesRateio1").style.display = "none";
                        $("trOpcoesRateio2").style.display = "none";

                        if (${param.alteraprecocte} != 4){
                            $('isRatearValorFrete').disabled = true;
                            $('isRatearValorFrete').checked = false;
                        }
                      
                        if (${param.alteraimpostoscartafrete} != 4){
                            $('chk_reter_impostos').disabled = true;
                            $('chk_reter_impostos').checked = false;
                        }
                        
                        
                        
                        alterarTipoTranporte();
                        
                    } catch (e) { 
                        alert(e);
                    }
                }
            
                function prepararIniciarContratoFrete(){
                    var cartaValorFrete = 0;
                    var totalNota = 0;
                    var totalPeso = 0;
                    var totalPrestacaoCtes = 0;
                    var totalICMS = 0;
                    var totalKM = 0;
                    var totalPrestacao = 0;
               try{
                   
                    if ($("bloqueado").value == 't' || $("bloqueado").value == "true") {
                        alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
                        $("motorista_nome").value = '';
                        $("idmotoristaPrincipal").value = '0';
                    }else{
                        if  ($('tipo').value == 'f'){
                            //$('chk_adv_automatica').checked = true;
                            $('chk_carta_automatica').checked = false;
                            if ($('percentual_ctrc_contrato_frete').value > 0){
                                $('chk_carta_automatica').checked = true;
                            }
                            if (countADV == 0){
                                incluiADV();
                            }
                        }else{
                            $('chk_carta_automatica').checked = true;
                            //$('chk_adv_automatica').checked = false;
                        }
                        if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
                            $('chk_reter_impostos').checked = true;
                        }else{
                            $('chk_reter_impostos').checked = false;
                        }
                        
                        if (parseFloat($('percentual_valor_cte_calculo_cfe').value) <= 0) {
                            if ($('tipo_valor_rota').value == 'f') {
                                cartaValorFrete = $('valor_rota').value;
                            } else if ($('tipo_valor_rota').value == 'p') {
                                totalPeso = getPesoTotalCtrcs();
                                cartaValorFrete = roundABNT(parseFloat(parseFloat($('valor_rota').value) * (parseFloat(totalPeso) / 1000)), 2);
                                $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                            } else if ($('tipo_valor_rota').value == 'c') {
                                if($("considerar_campo_cte").value == 'tp' || $("considerar_campo_cte").value == ''){
                                    totalPrestacaoCtes = getTotalGeralPrestacao();
                                    totalICMS = getTotalICMS();
                                    totalPrestacao = parseFloat(totalPrestacaoCtes) - parseFloat(totalICMS);
                                }else if ($("considerar_campo_cte").value == 'fp'){
                                    totalPrestacao = parseFloat(getTotalGeralFretePeso());
                                }else if ($("considerar_campo_cte").value == 'fv'){
                                    totalPrestacao = parseFloat(getTotalGeralFreteValor());
                                }
                                cartaValorFrete = roundABNT(parseFloat(parseFloat(totalPrestacao) * (parseFloat($('valor_rota').value) / 100)), 2);
                                        $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                                            } else if ($('tipo_valor_rota').value == 'n') { 
                                         var valorNota = getValorNotas($('percentual_desconto_prop').value ,parseFloat($('rota_valor_minimo').value));
                                         cartaValorFrete = valorNota;
                                        $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                                    } else if ($('tipo_valor_rota').value == 'k') {
                                        totalKM = getTotalGeralKM();
                                        cartaValorFrete = roundABNT(parseFloat(parseFloat(totalKM) * parseFloat($('valor_rota').value)), 2);
                                        $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                                    }
                            
                                    if (cartaValorFrete < parseFloat($('rota_valor_minimo').value)) {
                                        cartaValorFrete = parseFloat($('rota_valor_minimo').value);
                                    }
                                } else {
                                    cartaValorFrete = calcularTabelaMotorista();
                                }

                                var valorPedagio = 0;

                                if ($('is_carregar_pedagio_ctes').value == 'true') {
                                    for (var i = 1; i <= parseInt($("maxConhecimento").value); i++) {
                                        valorPedagio += parseFloat(colocarPonto($('valorPedagio_' + i).value));
                                    }
                                } else {
                                    valorPedagio = $('valor_pedagio_rota').value;
                                }

                                $('cartaPedagio').value = colocarVirgula(valorPedagio);

                                var qtdEntregasRota = parseFloat($('qtd_entregas_rota').value);
                                var qtdEntregasMontagem = getTotalQtdEntregas();
                                if (qtdEntregasMontagem >= qtdEntregasRota) {
                                    cartaValorFrete = parseFloat(cartaValorFrete) + parseFloat($('valor_entrega_rota').value) * (parseFloat(qtdEntregasMontagem - qtdEntregasRota + 1));
                                }

                                if (cartaValorFrete > 0 && $('is_deduzir_pedagio').value === 'true') {
                                    cartaValorFrete -= valorPedagio;
                                }

                                cartaValorFrete += parseFloat($("rota_taxa_fixa").value);
                                if ($("layout").value != '49') {
                                    //esse campo estava cimento nacional(layout numero 49, alterei para que o campo do Contrato de Frete funcionasse para cimento nacional(49)
                                    $('cartaValorFrete').value = colocarVirgula(formatoMoeda(cartaValorFrete));
                                }
                                calcularFreteCarreteiro();
                            }
                        } catch (e) {
                            console.error(e);
                        }
                    }
            
                function isExisteNFe(chaveNFe){
                    var existe = false;
                    var maxCtrc = $("maxConhecimento").value;
                    var maxCtrcNota = 0;

                    for (var i = 1; i <= maxCtrc; i++) {
                        if ($("qtdNotas_"+i) != null) {
                            maxCtrcNota = $("qtdNotas_"+i).value;
                            for (var j = 1; j <= maxCtrcNota; j++) {
                                if ($("notaChaveNFe_"+i+"_"+j) != null && chaveNFe != "" && $("notaChaveNFe_"+i+"_"+j).value == chaveNFe.toString()) {
                                    existe = true;
                                }
                            }
                        }
                    }

                    return existe;
                }
                
                /**
                * @author Gleidson
                * @description Faz uma triagem antes de colocar as informações na tela
                * @param {Object} ctrc - Objeto que representa o conhecimento
                * @param {Object} nf - Objeto que representa a nota fiscal
                * @param {boolean} perguntarAddVariasNotas - Campo que define se caso for encontrado um conhecimento para o mesmo remetente e destinatario, 
                * se irá perguntar ou não ao usuario se a nota será adicionado ao mesmo ou criado um novo conhecimento
                * @returns {undefined}                 
                * */
                function prepararAddCtrc(ctrc, nf, perguntarAddVariasNotas, isAgrupar, isConsiderarPedido, isConsiderarCtrcRedespacho, isAgruparPorVeiculo, AgruparNfUfDestino, isAgruparCTeNumeroFRS, agruparNFeEmissao){
                    try {
                        var index = 0;
                        
                        if (isConsiderarPedido) {                            
                            index = indexCtrcRemetenteDestinatarioPedido(ctrc.remetente.cnpj, ctrc.destinatario.cnpj, $("maxConhecimento"), nf.pedido);
                        } else if (isConsiderarCtrcRedespacho) {
                            index = indexCtrcRemetenteDestinatarioCtrcRedespacho(ctrc.remetente.cnpj, ctrc.destinatario.cnpj, $("maxConhecimento"), ctrc.redespachoCtrc);
                        } else if (isAgrupar && agruparNFeEmissao) {
                            index = indexCtrcRemetenteDestinatarioEmissao(ctrc.remetente.cnpj, ctrc.destinatario.cnpj, $("maxConhecimento"), nf.dataEmissao);
                        } else {
                            index = indexCtrcRemetenteDestinatario(ctrc.remetente.cnpj, ctrc.destinatario.cnpj, $("maxConhecimento"), nf.numeroCarga);
                        }
                        
                        if(isAgruparPorVeiculo){
                            index = indexCtrcVeiculo(ctrc.idVeiculo, ctrc.veiculo, $("maxConhecimento"));
                        }
                        
                        if(AgruparNfUfDestino){
                            index = indexCtrcUfDestino(ctrc.destinatario.uf, $("maxConhecimento"));
                        }
                        
                        if ($("layout").value == "4") {
                            index = indexLayoutCtrcConfirmado(ctrc.numero,$("maxConhecimento"));
                            isAgrupar = true;
                        }       
                   
                        if (isAgruparCTeNumeroFRS && isAgrupar) {                           
                            index = indexCtrcRemetenteDestinatarioNumeroCarga(ctrc.remetente.cnpj, ctrc.destinatario.cnpj, $("maxConhecimento") ,nf.numeroCarga);                            
                        }else  if (isAgruparCTeNumeroFRS){
                                index = indexCTeNumeroCarga(nf.numeroCarga, $("maxConhecimento"));                            
                        }
                        
                        if (index > 0 && nf != null && nf != undefined && (isAgrupar || isAgruparPorVeiculo || AgruparNfUfDestino || isAgruparCTeNumeroFRS || agruparNFeEmissao)) {//existe um conhecimento para o mesmo remetente e destinatario
                            if (!isAgruparPorVeiculo && !AgruparNfUfDestino && !isAgruparCTeNumeroFRS && perguntarAddVariasNotas) {
                                if(confirm("Já existe um 'CT-e' para o mesmo 'Remetente' e 'Destinatario'.\n Deseja inserir a 'Nota Fiscal' no respectivo 'CT-e'? ")){
                                    addConhecimentoLoteNotasFiscaisConteudo(nf, index, null, $("serie").value, false, ctrc.consignatario.travaCamposImportacao);
                                }else{
                                    addConhecimentoLote(ctrc, $("tabConhecimento"), $("maxConhecimento"),$("serie"),$('alteraprecocte').value,$('alterainffiscal').value,$('permissao_alteratipofretecte').value,$("embutirICMS").checked,$("embutirPISCOFINS").checked,$('slTipoProduto').value,$('slTipoVeiculo').value,$('obsPadrao').value);
                                    addConhecimentoLoteNotasFiscaisConteudo(nf, ctrc.index, ctrc.className, $("serie").value, false, ctrc.consignatario.travaCamposImportacao);
                                    calculaPesoTaxado(ctrc.index);
                                        alterarTipoPagamento(ctrc.index, !($("fontePreco").value == "a"));
                                        atribuirCfopPadrao(ctrc.index);                                        
                                        definirAliquotaIcmsCtrc(ctrc.index, false);
                                        getPautaFiscal(ctrc.index);
                                        alteraTipoTaxa("S", ctrc.index);
                                        alterarTipoPagamento(ctrc.index, !($("fontePreco").value == "a"));
                                        if(ctrc.observacao){
                                            $("observacaoOutros_"+ctrc.index).value = replaceAll(ctrc.observacao, "<br>", "\r\n");
                                        }

                                    carregarPrevisaoEntrega(ctrc.calcularPrazoEntregaTabelaPreco, ctrc.index);
                                }
                            }else{                                
                                addConhecimentoLoteNotasFiscaisConteudo(nf, index, null, $("serie").value, false, ctrc.consignatario.travaCamposImportacao);
                            }
                            atribuirCfopPadraoNota(index);
                        }else{
                            addConhecimentoLote(ctrc, $("tabConhecimento"), $("maxConhecimento"), $("serie"),$('alteraprecocte').value,$('alterainffiscal').value,$('permissao_alteratipofretecte').value,$("embutirICMS").checked,$("embutirPISCOFINS").checked,$('slTipoProduto').value,$('slTipoVeiculo').value,$('obsPadrao').value);
                            addConhecimentoLoteNotasFiscaisConteudo(nf, ctrc.index, ctrc.className, $("serie").value, false, ctrc.consignatario.travaCamposImportacao);
                            calculaPesoTaxado(ctrc.index);
                            if (parseFloat(colocarPonto($('cubagemMetroTotalNF_' + ctrc.index).value)) == 0 && parseFloat(ctrc.cubagemMetro) > 0){
                                $('cubagemMetroTotalNF_' + ctrc.index).value = colocarVirgula(arredondar(ctrc.cubagemMetro,2));
                                $('cubagemLarguraTotalNF_' + ctrc.index).value = '1';
                                $('cubagemAlturaTotalNF_' + ctrc.index).value = '1';
                                $('cubagemComprimentoTotalNF_' + ctrc.index).value = '1';
                                $('cubagemMetroTotalCF_' + ctrc.index).value = colocarVirgula(arredondar(ctrc.cubagemMetro,2));
                                $('cubagemLarguraTotalCF_' + ctrc.index).value = '1';
                                $('cubagemAlturaTotalCF_' + ctrc.index).value = '1';
                                $('cubagemComprimentoTotalCF_' + ctrc.index).value = '1';
                            }
                                
                                alterarTipoPagamento(ctrc.index, !($("fontePreco").value == "a"));
                                atribuirCfopPadrao(ctrc.index);                                
                                definirAliquotaIcmsCtrc(ctrc.index, false);
                                getPautaFiscal(ctrc.index);
                                alteraTipoTaxa("S", ctrc.index);
                                //Coloquei para o metodo ser chamado pela segunda vez para o mesmo verifique qual observação deve prevalecer no conhecimento(cliente x aliquota)
                                alterarTipoPagamento(ctrc.index, !($("fontePreco").value == "a"));
                                atribuirCfopPadraoNota(ctrc.index);
                                if(ctrc.observacao){
                                    $("observacaoOutros_"+ctrc.index).value = replaceAll(ctrc.observacao, "<br>", "\r\n");
                                }

                                carregarPrevisaoEntrega(ctrc.calcularPrazoEntregaTabelaPreco, ctrc.index);
                                //Como no inicio ainda não foi pego da tabela de preço a base da cubagem, é necessario ir uma segunda vez
                                //                            alteraTipoTaxa("S", ctrc.index);
//                                setTimeout("alteraTipoTaxa(\"S\", "+ctrc.index+");", 5000);            
                            }
                        //                        calculaPesoTaxado(ctrc.index);
                            
                    } catch (ex) { 
                        console.log(ex);
                        alert(ex);
                    }
                }
                
                
            
                function alterarModal(){
                    var maxCon = parseInt($("maxConhecimento").value, 10);
                    switch($("modalCTe").value){
                        case "l":
                            visivel($("trLotacao"));
                            break;
                        case "f":
                            invisivel($("trLotacao"));
                            break;
                    }
                    for (var i = 1; i <= maxCon; i++) {
                        if ($("vendedorComissaoOutros_" + i) != null && $("vendedorComissaoOutros_" + i) != undefined) {
                            definirComissaoVendedorLote(i);
                        }
                    }
                }
                
                function abrirLocalizaConsignatarioRateio() {
                   launchPopupLocate('./localiza?acao=consultar&idlista=05','Cliente_Rateio');
                }
                
                function abrirLocalizaCidadeOrigemRateio() {
                   launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Origem_Rateio');
                }
                
                function abrirLocalizaCidadeDestinoRateio() {
                   launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_Destino_Rateio');
                }

                function abrirLocalizaMotorista(){
                    //passando os valores dos tipos de produto e id das rotas, caso a opcao de gerar contrato de frete esteja marcada possa gerar o contrato
                    var idRotaLocais = ($('rotaIdLocais_1') == null ? "" : $('rotaIdLocais_1').value);
                    var tipoProdutos = ($("tipos_produto").value == "" ? "is null" : $("tipos_produto").value);
                    launchPopupLocate('./localiza?acao=consultar&paramaux=carta&paramaux2='+tipoProdutos+'&paramaux3='+idRotaLocais+'&idlista=10&fecharJanela=true','Motorista');
                }

                function abrirLocalizaVeiculo(){
                    var idRotaLocais = ($('rotaIdLocais_1') == null ? "" : $('rotaIdLocais_1').value);
                    var tipoProdutos = ($("tipos_produto").value == "" ? "is null" : $("tipos_produto").value);
                    launchPopupLocate('./localiza?acao=consultar&idlista=7&fecharJanela=true&paramaux2='+tipoProdutos+'&paramaux3='+idRotaLocais,'Veiculo');
                }   

                function abrirLocalizaCarreta(){
                    var idRotaLocais = ($('rotaIdLocais_1') == null ? "" : $('rotaIdLocais_1').value);
                    var tipoProdutos = ($("tipos_produto").value == "" ? "is null" : $("tipos_produto").value);
                    launchPopupLocate('./localiza?acao=consultar&idlista=9&fecharJanela=true&paramaux2='+tipoProdutos+'&paramaux3='+idRotaLocais,'Carreta');
                }
                
                function abrirLocalizaBitrem(){
                    launchPopupLocate('./localiza?acao=consultar&idlista=51&fecharJanela=true','Bitrem');
                }
            
                function aplicarEventoAba(){
                    var lastIndex = (parseInt($("maxConhecimento").value));
                    var abaNota = $("tdAbaNotaFiscal_"+lastIndex);

                    if (abaNota != null){
                        
                        abaNota.onClick = function(){
                            AlternarAbas(abaNota);
                        };
                    }
                    var abaCliente = $("tdAbaNotaFiscal_"+lastIndex);
                    if (abaCliente != null){
                        abaCliente.onClick = function(){
                            AlternarAbas(abaCliente);
                        };
                    }
                }
                
                function mostrarOpcoesRateio(){
                    if($("rdAutomatico").checked){
                        $("trOpcoesRateio1").style.display = "";
                        $("trOpcoesRateio2").style.display = "";
                    }else{
                        $("trOpcoesRateio1").style.display = "none";
                        $("trOpcoesRateio2").style.display = "none";
                    }
                }

               function mostrarValorRateio(){
                    if ($("isRatearValorFrete").checked) {
                        $("trTipoRateio").style.display = "";
                        habilitar($("btRateioValorFrete"));
                        notReadOnly($("valorFrete"), "fieldMin"),
                        notReadOnly($("valorTotalTaxaFixa"),"fieldMin"),
                        notReadOnly($("valorAdvalorem"),"fieldMin"),
                        notReadOnly($("valorOutros"),"fieldMin")
                    }else{
                        $("trTipoRateio").style.display = "none";
                        $("valorFrete").value = "0,00";
                        $("valorTotalTaxaFixa").value = "0,00";
                        $("valorAdvalorem").value = "0,00";		
                        $("valorOutros").value = "0,00";
                        readOnly($("valorFrete"), "inputReadOnly8pt"),
                        readOnly($("valorTotalTaxaFixa"), "inputReadOnly8pt"),
                        readOnly($("valorAdvalorem"), "inputReadOnly8pt"),		
                        readOnly($("valorOutros"), "inputReadOnly8pt")
                        desabilitar($("btRateioValorFrete"), "#2E76A6");
                    }
                }
                
                function pesquisaTabelaPreco(){
                    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                    function e(transport){
                        var textoresposta = transport.responseText;
                        if (textoresposta === 'load=0') {
                            $("lblTabelaPreco").innerHTML = "";
                            $("valorOutros").value = '0.00';
                            $("valorTotalTaxaFixa").value = '0.00';
                            $("valorFrete").value = '0.00';
                            $("valorAdvalorem").value = '0.00';
                        //se deu algum erro na requisicao...
                            if ($("tipotaxa").value != 3 && $("tipotaxa").value != 5){
                                alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino.");   		          
                                $("tipotaxa").value = $("rem_tipotaxa").value;
                            }   
                            return false;
                        }else{
                            var lista = jQuery.parseJSON(textoresposta);
                            $("lblTabelaPreco").innerHTML = "Código da Tabela: "+lista.id;
                            calcularFormulaTaxas(lista);
                        }

                        //obtendo o objeto JSON com a tabela de preço
                        tarifas = eval('('+textoresposta+')');
                        $('idtabela').value = tarifas.id;
                        $('lbIdTabel').innerHTML = "Tabela:"+tarifas.id;
                        $('lbIdTabel').style.display = '';

                        //faz o calculo da taxa escolhida e atribui aos respectivos campos
                    }
                   
                    if ($('hiddenConsignatarioRateio').value == '0'){
                        alert('Informe o remetente corretamente!');
                    }else if ($('idcidadeorigem').value == '0'){
                        alert('Informe a cidade de origem corretamente!');
                    }else if ($('idcidadedestino').value == '0'){
                        alert('Informe a cidade de destino corretamente!');
                    }else{
                        //Buscando a tabela de preço 
                        tryRequestToServer(function(){ new Ajax.Request("ConhecimentoControlador?acao=getValorRateio&idcidadeorigem="+$('hiddenCidadeOrigemRateio').value+
                                                        "&idCidadeDestino="+$('hiddenCidadeDestinoRateio').value+"&idTipoProduto="+$('slTipoProduto').value+
                                                        "&idcliente="+$('hiddenConsignatarioRateio').value+"&idTipoVeiculo="+$('slTipoVeiculo').value
                                                        +"&tabelaClienteId="+$('con_utilizar_tabela_cliente_rateio').value,
                                                        {method:'post', onSuccess: e});
                        });		 				 
                    }
                }
                
                function rateandoValorFrete(max){
                    if ($("isRatearValorFrete").checked) {
                        var isRatearCTRCSelecionados = document.getElementById('isRatearCTRCSelecionados').checked;
                        var valorTotal = parseFloat($("valorFrete").value.indexOf(",") > -1 ? colocarPonto($("valorFrete").value) : $("valorFrete").value);
                        var pesoTot = getPesoTotalCtrcs();
                        var pesoCt = 0;
                        var valorFretePeso = 0;
                        var valorAcumulado = 0;
                        var metroCubicoCt = 0;
                        var valorFreteMetroCubico = 0;
                        var metroCubicoTot = getMetroCubicoTotalCtrcs();
                        var valorTotalNF = getValorTotalMercadorias();
                        var valorNfCt = 0;
                        var resultValorNf = 0;
                        var valorFreteNF = 0;
                        var valorTxFxTotal = parseFloat($("valorTotalTaxaFixa").value.indexOf(",") > -1 ? colocarPonto($("valorTotalTaxaFixa").value) : $("valorTotalTaxaFixa").value);
                        var valorTaxaFixaDividida = 0;
                        var valorTaxaFixaAcumulada = 0;
                        var valorTxFxFretePeso = 0;
                        var valorTxFxMetroCubico = 0;
                        var valorTxFxFreteNF = 0;
                        var percAdvalorem = parseFloat($("valorAdvalorem").value.indexOf(",") > -1 ? colocarPonto($("valorAdvalorem").value) : $("valorAdvalorem").value);	
                        var valorOutros = parseFloat($("valorOutros").value.indexOf(",") > -1 ? colocarPonto($("valorOutros").value) : $("valorOutros").value);		
                        var valorOutrosFretePeso = 0;		
                        var valorOutrosMetroCubico = 0;		
                        var valorOutrosNF = 0;		
                        var valorOutrosDividido = 0;		
                        var valorOutrosAcumulado = 0;
                        var frenteValorADV = 0;
                        var percentual = parseFloat($("valorAdvalorem").value.indexOf(",") > -1 ? colocarPonto($("valorAdvalorem").value) : $("valorAdvalorem").value)/100;
                        var countCtChek = 0;
                        var maxCtChek = 0;
                        var countCt = 0;
                        jQuery("[id^=chkSave_]").each(function(i,a){
                           if(a.checked){
                               maxCtChek++;
                           }
                           countCt++;
                        });
                        for (var i = 1; i <= max; i++) {
                            if ($("tipoFreteTabela_"+i) != null && $("tipoFreteTabela_"+i) != undefined) {
                                if((isRatearCTRCSelecionados && $("chkSave_"+i).checked) || (!isRatearCTRCSelecionados)){
                                    countCtChek++;
                                    $("tipoFreteTabela_"+i).value = 3;
                                    pesoCt = parseFloat(colocarPonto($("valorPesoTotalCF_"+i).value));
                                    var result = 0;
                                    if(pesoTot==0){
                                        result = 0;
                                    }else{
                                        result = (pesoCt/ pesoTot);
                                    }
                                    valorFretePeso = roundABNT(valorTotal * result);
                                    valorTxFxFretePeso = roundABNT(valorTxFxTotal * result); 
                                    valorOutrosFretePeso = roundABNT(valorOutros * result);

                                    if(i != max && $("formaRateio").value == "peso"){
                                        valorAcumulado += parseFloat(valorFretePeso); 
                                        valorOutrosAcumulado += parseFloat(valorOutrosFretePeso); 
                                        valorTaxaFixaAcumulada += parseFloat(valorTxFxFretePeso); 
                                    }

                                    metroCubicoCt = parseFloat(colocarPonto($("cubagemMetroTotalCF_"+i).value));

                                    var resultMetro= 0;

                                    if(metroCubicoTot==0){
                                        resultMetro=0;
                                    }else{
                                        resultMetro =(metroCubicoCt / metroCubicoTot);
                                    }                                
                                    valorFreteMetroCubico = roundABNT(valorTotal * resultMetro);
                                    valorTxFxMetroCubico = roundABNT(valorTxFxTotal * resultMetro);
                                    valorOutrosMetroCubico = roundABNT(valorOutros * resultMetro);

                                    if(i != max && $("formaRateio").value == "metroCubico"){
                                        valorAcumulado += parseFloat(valorFreteMetroCubico); 
                                        valorOutrosAcumulado += parseFloat(valorOutrosMetroCubico); 
                                        valorTaxaFixaAcumulada += parseFloat(valorTxFxMetroCubico); 
                                    }

                                    valorNfCt = parseFloat(colocarPonto($("valorMercadoriaTotalNF_"+i).value));

                                    if(valorTotalNF==0){
                                        resultValorNf=0;
                                    }else{
                                        resultValorNf = (valorNfCt / valorTotalNF);
                                    }                                                                
                                    valorFreteNF = roundABNT(valorTotal * resultValorNf);
                                    valorTxFxFreteNF = roundABNT(valorTxFxTotal * resultValorNf);
                                    valorOutrosNF = roundABNT(valorOutros * resultValorNf);

                                    if(i != max && $("formaRateio").value == "valorNf"){
                                        valorAcumulado += parseFloat(valorFreteNF); 
                                        valorOutrosAcumulado+= parseFloat(valorOutrosNF); 
                                        valorTaxaFixaAcumulada+= parseFloat(valorTxFxFreteNF); 
                                    }

                                    if(parseFloat(percAdvalorem) > 0){
                                       frenteValorADV = roundABNT((percentual) * valorNfCt);
                                    }
                                    $("valorFreteValor_"+i).value = colocarVirgula(parseFloat(frenteValorADV),2);

                                    if($("formaRateio").value == "metroCubico"){                                  
                                            $("valorFretePeso_"+i).value = colocarVirgula(valorFreteMetroCubico,2);
                                            $("valorTaxaFixa_"+i).value = colocarVirgula(valorTxFxMetroCubico , 2);
                                            $("valorOutros_"+i).value = colocarVirgula(valorOutrosMetroCubico , 2);                                    
                                    }else if ($("formaRateio").value == "peso") {  
                                            $("valorFretePeso_"+i).value = colocarVirgula(valorFretePeso, 2);
                                            $("valorTaxaFixa_"+i).value = colocarVirgula(valorTxFxFretePeso , 2);
                                            $("valorOutros_"+i).value = colocarVirgula(valorOutrosFretePeso , 2);

                                    }else if($("formaRateio").value == "valorNf"){                                        
                                            $("valorFretePeso_"+i).value = colocarVirgula(valorFreteNF ,2);
                                            $("valorTaxaFixa_"+i).value = colocarVirgula(valorTxFxFreteNF , 2);
                                            $("valorOutros_"+i).value = colocarVirgula(valorOutrosNF , 2);
                                    }else{ 

                                            var isUltimo =  (isRatearCTRCSelecionados ? (i == (maxCtChek + countCtChek)) : (i == max) );
                                            
                                            if(!isUltimo){
                                               valorFretePeso = parseFloat((valorTotal /  (isRatearCTRCSelecionados ? maxCtChek : countCt)).toFixed(2)); 
                                               valorAcumulado += valorFretePeso;
                                               valorTaxaFixaDividida = parseFloat((valorTxFxTotal / (isRatearCTRCSelecionados ? maxCtChek : countCt)).toFixed(2));
                                               valorTaxaFixaAcumulada += valorTaxaFixaDividida;
                                               valorOutrosDividido = parseFloat((valorOutros / (isRatearCTRCSelecionados  ? maxCtChek : countCt)).toFixed(2));		
                                               valorOutrosAcumulado += valorOutrosDividido;
                                            }else{
                                                valorFretePeso = valorTotal - valorAcumulado;
                                                valorTaxaFixaDividida = valorTxFxTotal - valorTaxaFixaAcumulada;
                                                valorOutrosDividido = valorOutros - valorOutrosAcumulado;
                                            }

                                            $("valorFretePeso_"+i).value = colocarVirgula(valorFretePeso, 2);
                                            $("valorTaxaFixa_"+i).value = colocarVirgula(valorTaxaFixaDividida, 2);
                                            $("valorOutros_"+i).value = colocarVirgula(valorOutrosDividido, 2);
                                     }

                                if(i == max){
                                    if($("formaRateio").value == "metroCubico"){
                                     $("valorFretePeso_"+i).value = colocarVirgula(parseFloat(valorTotal - roundABNT(valorAcumulado, 2)));
                                     $("valorTaxaFixa_"+i).value = colocarVirgula(parseFloat(valorTxFxTotal - roundABNT(valorTaxaFixaAcumulada,2)));
                                     $("valorOutros_"+i).value = colocarVirgula(parseFloat(valorOutros - roundABNT(valorOutrosAcumulado,2)));
                                    }else if ($("formaRateio").value == "peso") {
                                     $("valorFretePeso_"+i).value = colocarVirgula(parseFloat(valorTotal - roundABNT(valorAcumulado, 2)));
                                     $("valorTaxaFixa_"+i).value = colocarVirgula(parseFloat(valorTxFxTotal - roundABNT(valorTaxaFixaAcumulada,2)));
                                     $("valorOutros_"+i).value = colocarVirgula(parseFloat(valorOutros - roundABNT(valorOutrosAcumulado,2)));
                                    }else if($("formaRateio").value == "valorNf"){
                                     $("valorFretePeso_"+i).value = colocarVirgula(parseFloat(valorTotal - roundABNT(valorAcumulado, 2)));
                                     $("valorTaxaFixa_"+i).value = colocarVirgula(parseFloat(valorTxFxTotal - roundABNT(valorTaxaFixaAcumulada,2)));
                                     $("valorOutros_"+i).value = colocarVirgula(parseFloat(valorOutros - roundABNT(valorOutrosAcumulado,2)));
                                    } 
                                }    
                                if($("tipoProdutoTabela_"+i) != null && $("tipoProdutoTabela_"+i).value != $("slTipoProduto").value){
                                    $("tipoProdutoTabela_"+i).value = $("slTipoProduto").value;
                                }
                            }else{
                                $("valorFretePeso_"+i).value = colocarVirgula(0, 2);
                                $("valorTaxaFixa_"+i).value = colocarVirgula(0, 2);
                                $("valorOutros_"+i).value = colocarVirgula(0, 2);
                            }
                        }
                    }
                }
            }
                function ratearFretePeso(isPerguntar){
                    var max = parseInt($("maxConhecimento").value);
                    try {
                        if (isPerguntar && confirm("Tem certeza que deseja ratear o valor do frete?")) {
                            rateandoValorFrete(max);
                        }else{
                            rateandoValorFrete(max);
                        }
                        var i = 1;
                        while(i <= max){
                            if ($("tipoFreteTabela_"+i) != null && $("tipoFreteTabela_"+i) != undefined) { 
                                recalcular(i);
                            }
                            i++;
                        }
                        
                    } catch (e) { 
                        console.log(e);
                        alert("Erro ao tentar ratear o valor do frete:"+e);
                    }

                }
                
                function replicaObservacao(){
                    var max = parseInt($("maxConhecimento").value);
                    var i = 1;
                    for (var i = 1; i <= max; i++) {
                        if ($("chkSave_"+i) != null && $("chkSave_"+i).checked) {
                            $("observacaoOutros_"+i).value = $("observacaoOutros_"+i).value + " " + $("obsPadrao").value;
                        }
                    }
                }
            
                //Funções referentes ao contrato de frete e adiantamento de viagem
                //-----------------  INICIO  -------------------------------------
                var countDespesaCarta = 0;
                function incluiDespesaCarta(){
                    countDespesaCarta++;
                    try {
                        $("trDespesaCarta").style.display = "";
                        var descricaoClassName = ((countDespesaCarta % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2");

                        var trDespCarta = Builder.node("TR",{name:"trDespCarta_"+countDespesaCarta, id:"trDespCarta_"+countDespesaCarta, className:descricaoClassName});
                        //TD Lixo
                        var tdDespLixo = Builder.node("TD",{width:"2%"});
                        var imgDespLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerDespCarta("+countDespesaCarta+",true);"});
                        tdDespLixo.appendChild(imgDespLixo);

                        //TD Valor	
                        var tdDespValor = Builder.node("TD",{width:"8%"});
                        var vlDespCarta = Builder.node("INPUT",{type:"text",id:"vlDespCarta_"+countDespesaCarta, name:"vlDespCarta_"+countDespesaCarta, size:"5", maxLength:"12", value: "0,00", className:"fieldMin styleNum", onKeyPress: "mascara(this, reais)", onBlur : "setZero($('vlDespCarta_"+countDespesaCarta+"'), 0,00);calcularFreteCarreteiro();"});
                        tdDespValor.appendChild(vlDespCarta);

                        //TD Fornecedor
                        var tdDespForn = Builder.node("TD",{width:"45%"});
                        var idFornDespCarta = Builder.node("INPUT",{type:"hidden",id:"idFornDespCarta_"+countDespesaCarta, name:"idFornDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
                        var fornDespCarta = Builder.node("INPUT",{type:"text",id:"fornDespCarta_"+countDespesaCarta, name:"fornDespCarta_"+countDespesaCarta, size:"27", maxLength:"60", value: "Fornecedor", className:"inputReadOnly8pt", readOnly:true});
                        var btFornDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaFornecedorDesp_"+countDespesaCarta, name:"localizaFornecedorDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
                        tdDespForn.appendChild(idFornDespCarta);
                        tdDespForn.appendChild(fornDespCarta);
                        tdDespForn.appendChild(btFornDespCarta);

                        //TD Plano
                        var tdDespPlano = Builder.node("TD",{width:"45%"});
                        var idPlanoDespCarta = Builder.node("INPUT",{type:"hidden",id:"idPlanoDespCarta_"+countDespesaCarta, name:"idPlanoDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
                        var planoDespCarta = Builder.node("INPUT",{type:"text",id:"planoDespCarta_"+countDespesaCarta, name:"planoDespCarta_"+countDespesaCarta, size:"27", maxLength:"60", value: "Plano Custo", className:"inputReadOnly8pt", readOnly:true});
                        var btPlanoDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaPlanoDesp_"+countDespesaCarta, name:"localizaPlanoDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=20','Plano_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
                        tdDespPlano.appendChild(idPlanoDespCarta);
                        tdDespPlano.appendChild(planoDespCarta);
                        tdDespPlano.appendChild(btPlanoDespCarta);

                        trDespCarta.appendChild(tdDespLixo);
                        trDespCarta.appendChild(tdDespValor);
                        trDespCarta.appendChild(tdDespForn);
                        trDespCarta.appendChild(tdDespPlano);

                        $("tbDespesaCarta").appendChild(trDespCarta);

                        //Adicionando a segunda linha
                        var trDespCarta2 = Builder.node("TR",{name:"trDespCarta2_"+countDespesaCarta, id:"trDespCarta2_"+countDespesaCarta});
                        var tdDespCarta2 = Builder.node("TD",{colSpan:"4"});
                        var tblDespCarta2 = Builder.node("TABLE",{width:"100%"});
                        var tbdDespCarta2 = Builder.node("TBODY");
                        var trDespCarta2_1 = Builder.node("TR",{className:descricaoClassName});

                        //TD isPago
                        var tdDespPago = Builder.node("TD",{width:"29%"});
                        var DespPago = Builder.node("INPUT",{type:"radio", id:"DespPago_"+countDespesaCarta, name:"DespPago_"+countDespesaCarta, onClick:"$('DespPagar_"+countDespesaCarta+"').checked = !this.checked;getFpagDespCarta("+countDespesaCarta+");"});
                        var lbDespPago = Builder.node("LABEL",{id:"lbDespPago_"+countDespesaCarta, name:"lbDespPago_"+countDespesaCarta});
                        var DespPagar = Builder.node("INPUT",{type:"radio", id:"DespPagar_"+countDespesaCarta, name:"DespPagar_"+countDespesaCarta, checked:"true", onClick:"$('DespPago_"+countDespesaCarta+"').checked = !this.checked;getFpagDespCarta("+countDespesaCarta+");"});
                        var lbDespPagar = Builder.node("LABEL",{id:"lbDespPagar_"+countDespesaCarta, name:"lbDespPagar_"+countDespesaCarta});
                        tdDespPago.appendChild(DespPago);
                        tdDespPago.appendChild(lbDespPago);
                        tdDespPago.appendChild(DespPagar);
                        tdDespPago.appendChild(lbDespPagar);

                        //TD vencimento	
                        var tdDespVencimento = Builder.node("TD",{width:"71%"});
                        var lbDespVencimento = Builder.node("LABEL",{id:"lbDespVencimento_"+countDespesaCarta, name:"lbDespVencimento_"+countDespesaCarta});
                        var vlDespVencimento = Builder.node("INPUT",{type:"text",id:"vlDespVencimento_"+countDespesaCarta, name:"vlDespVencimento_"+countDespesaCarta, size:"9", maxLength:"10", value: dataAtual, className:"fieldDate", style:"font-size:8pt;", onChange:"javascript:alertInvalidDate(this);"});
                        var contaDespCarta = Builder.node("SELECT",{id:"contaDespCarta_"+countDespesaCarta, name:"contaDespCarta_"+countDespesaCarta, className:"fieldMin", style:"width:120px;", onChange:"getFpagDespCarta("+countDespesaCarta+");"});
                        var optConta = null;
                        for(var i = 0; i < listaConta.length; i++){
                            optConta = Builder.node("option", {
                                value: listaConta[i].valor
                            });
                            Element.update(optConta, listaConta[i].descricao);
                            contaDespCarta.appendChild(optConta);
                        }

                        var chqDespCarta = Builder.node("INPUT",{type:"checkbox", id:"chqDespCarta_"+countDespesaCarta, name:"chqDespCarta_"+countDespesaCarta, onClick:"getFpagDespCarta("+countDespesaCarta+");", checked:"true"});
                        var lbChqDespCarta = Builder.node("LABEL",{id:"lbChqDespCarta_"+countDespesaCarta, name:"lbChqDespCarta_"+countDespesaCarta});
                        var docDespCarta = Builder.node("INPUT",{type:"text",id:"docDespCarta_"+countDespesaCarta, name:"docDespCarta_"+countDespesaCarta, size:"10", maxLength:"12", value: "", className:"fieldMin"});
                        var docDespCarta_cb = Builder.node("SELECT",{id:"docDespCarta_cb_"+countDespesaCarta, name:"docDespCarta_cb_"+countDespesaCarta, className:"fieldMin"});

                        tdDespVencimento.appendChild(lbDespVencimento);
                        tdDespVencimento.appendChild(vlDespVencimento);
                        tdDespVencimento.appendChild(contaDespCarta);
                        tdDespVencimento.appendChild(chqDespCarta);
                        tdDespVencimento.appendChild(lbChqDespCarta);
                        tdDespVencimento.appendChild(docDespCarta);
                        tdDespVencimento.appendChild(docDespCarta_cb);

                        trDespCarta2_1.appendChild(tdDespPago);
                        trDespCarta2_1.appendChild(tdDespVencimento);
                        tbdDespCarta2.appendChild(trDespCarta2_1);
                        tblDespCarta2.appendChild(tbdDespCarta2);
                        tdDespCarta2.appendChild(tblDespCarta2);

                        trDespCarta2.appendChild(tdDespCarta2);

                        $("tbDespesaCarta").appendChild(trDespCarta2);

                        $("lbDespPago_"+countDespesaCarta).innerHTML = "Pago";
                        $("lbDespPagar_"+countDespesaCarta).innerHTML = "A Pagar";
                        $("lbDespVencimento_"+countDespesaCarta).innerHTML = "Vencimento:";
                        $("lbChqDespCarta_"+countDespesaCarta).innerHTML = "Cheque    ";
                        $("countDespesaCarta").value = countDespesaCarta;
                        applyFormatter(document, $("vlDespVencimento_"+countDespesaCarta));	
                        getFpagDespCarta(countDespesaCarta);
                    } catch (e) { 
                        console.log(e);
                        alert(e);
                    }
                }

                function abrirLocalizaSeguradora(){
                    launchPopupLocate('./localiza?acao=consultar&paramaux=carta&idlista=57&fecharJanela=true','Seguradora')
                }
            
                function abrirLocalizaAgenteCarga(){
                    launchPopupLocate('./localiza?acao=consultar&paramaux=carta&idlista=58&fecharJanela=true','Agente_Carga')
                }
                
                function abrirLocalizaAgente(index){
                    $("indexAux").value = index;
                    launchPopupLocate('./localiza?acao=consultar&idlista=16&fecharJanela=true','Agente_Pagador')
                }
        
                var countDespesaADV = 0;
                function incluiDespesaADV(){
                    countDespesaADV++;
                    try {
                        var descricaoClassName = ((countDespesaADV % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2");
            
                        var trDespADV = Builder.node("TR",{name:"trDespADV_"+countDespesaADV, id:"trDespADV_"+countDespesaADV, className:descricaoClassName});
                        //TD Lixo
                        var tdDespADVLixo = Builder.node("TD",{width:"2%"});
                        var imgDespADVLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerDespCarta("+countDespesaADV+",false);"});
                        tdDespADVLixo.appendChild(imgDespADVLixo);

                        //TD Valor	
                        var tdDespADVValor = Builder.node("TD",{width:"8%"});
                        var vlDespADV = Builder.node("INPUT",{type:"text",id:"vlDespADV_"+countDespesaADV, name:"vlDespADV_"+countDespesaADV, size:"5", maxLength:"12", value: "0,00", className:"fieldMin styleNum", onKeyPress: "mascara(this, reais)", onBlur : "setZero($('vlDespADV_"+countDespesaADV+"'), false);calcularFreteCarreteiro();"});
                        tdDespADVValor.appendChild(vlDespADV);

                        //TD Fornecedor
                        var tdDespFornADV = Builder.node("TD",{width:"45%"});
                        var idFornDespADV = Builder.node("INPUT",{type:"hidden",id:"idFornDespADV_"+countDespesaADV, name:"idFornDespADV_"+countDespesaADV, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
                        var fornDespADV = Builder.node("INPUT",{type:"text",id:"fornDespADV_"+countDespesaADV, name:"fornDespADV_"+countDespesaADV, size:"24", maxLength:"60", value: "Fornecedor", className:"inputReadOnly8pt", readOnly:true});
                        var btFornDespADV = Builder.node("INPUT",{className:"botoes", id:"localizaFornecedorDespADV_"+countDespesaADV, name:"localizaFornecedorDespADV_"+countDespesaADV, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_ADV_"+countDespesaADV+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
                        tdDespFornADV.appendChild(idFornDespADV);
                        tdDespFornADV.appendChild(fornDespADV);
                        tdDespFornADV.appendChild(btFornDespADV);

                        //TD Plano
                        var tdDespPlanoADV = Builder.node("TD",{width:"45%"});
                        var idPlanoDespADV = Builder.node("INPUT",{type:"hidden",id:"idPlanoDespADV_"+countDespesaADV, name:"idPlanoDespADV_"+countDespesaADV, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
                        var planoDespADV = Builder.node("INPUT",{type:"text",id:"planoDespADV_"+countDespesaADV, name:"planoDespADV_"+countDespesaADV, size:"24", maxLength:"60", value: "Plano Custo", className:"inputReadOnly8pt", readOnly:true});
                        var btPlanoDespADV = Builder.node("INPUT",{className:"botoes", id:"localizaPlanoDespADV_"+countDespesaADV, name:"localizaPlanoDespADV_"+countDespesaADV, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=20','Plano_ADV_"+countDespesaADV+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
                        tdDespPlanoADV.appendChild(idPlanoDespADV);
                        tdDespPlanoADV.appendChild(planoDespADV);
                        tdDespPlanoADV.appendChild(btPlanoDespADV);

                        trDespADV.appendChild(tdDespADVLixo);
                        trDespADV.appendChild(tdDespADVValor);
                        trDespADV.appendChild(tdDespFornADV);
                        trDespADV.appendChild(tdDespPlanoADV);
                        $("countDespesaADV").value = countDespesaADV;
                        $("tbDespesaADV").appendChild(trDespADV);

                    } catch (e) { 
                        alert("Erro ao preparar a inserção das despesas."+e);
                    }
                }

                var countADV = 0;
                function incluiADV(){
                    countADV++;
                    try {
                        var tbADV = $("tbADV");
                        var descricaoClassNameADV = ((countADV % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2");
                                                                        
                        var trADV = Builder.node("TR",{name:"trADV_"+countADV, id:"trADV_"+countADV, className:descricaoClassNameADV});
                        //TD Lixo
                        var tdADVLixo = Builder.node("TD");
                        var imgADVLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerADV("+countADV+");"});
                        tdADVLixo.appendChild(imgADVLixo);

                        //TD Valor
                        var tdADVValor = Builder.node("TD");
                        var vlADV = Builder.node("INPUT",{type:"text",id:"vlADV_"+countADV, name:"vlADV_"+countADV, size:"10", maxLength:"12", value: "0,00", className:"fieldMin styleNum", onKeyPress: "mascara(this, reais)", onBlur : "setZero($('vlADV_"+countADV+"'), false);calcularFreteCarreteiro();"});
                        tdADVValor.appendChild(vlADV);

                        //TD Conta
                        var tdADVConta = Builder.node("TD");
                        var contaADV = Builder.node("SELECT",{id:"contaADV_"+countADV, name:"contaADV_"+countADV, className:"fieldMin", style:"width:120px;", onChange:"getFpagADV("+countADV+");"});
                        for(var i = 0; i < listaConta.length; i++){
                            optConta = Builder.node("option", {
                                value: listaConta[i].valor
                            });
                            Element.update(optConta, listaConta[i].descricao);
                            contaADV.appendChild(optConta);
                        }
                        contaADV.selectedIndex = 0;
                        tdADVConta.appendChild(contaADV);

                        //TD CHQ
                        var tdADVChq = Builder.node("TD");
                        var chqADV = Builder.node("INPUT",{type:"checkbox", id:"chqADV_"+countADV, name:"chqADV_"+countADV, onClick:"getFpagADV("+countADV+");"});
                        var lbChqADV = Builder.node("LABEL",{id:"lbChqADV_"+countADV, name:"lbChqADV_"+countADV});
                        tdADVChq.appendChild(chqADV);
                        tdADVChq.appendChild(lbChqADV);

                        //TD DOC
                        var tdADVDoc = Builder.node("TD");
                        var docADV = Builder.node("INPUT",{type:"text",id:"docADV_"+countADV, name:"docADV_"+countADV, size:"8", maxLength:"12", value: "", className:"fieldMin"});
                        var docADV_cb = Builder.node("SELECT",{id:"docADV_cb_"+countADV, name:"docADV_cb_"+countADV, className:"fieldMin",style:"display:none;"});
                        tdADVDoc.appendChild(docADV);
                        tdADVDoc.appendChild(docADV_cb);

                        trADV.appendChild(tdADVLixo);
                        trADV.appendChild(tdADVValor);
                        trADV.appendChild(tdADVConta);
                        trADV.appendChild(tdADVChq);
                        trADV.appendChild(tdADVDoc);
                        tbADV.appendChild(trADV);

                        $('lbChqADV_'+countADV).innerHTML = 'Em Cheque';	
                        $("countADV").value = countADV;
                    } catch (e) { 
                        console.log(e);
                        alert(e);
                    }
                }

                function removerDespCarta(idxCarta, isCarta){
                    if (isCarta){
                        if (confirm("Deseja mesmo excluir esta despesa do contrato de frete?")){
                            Element.remove('trDespCarta_'+idxCarta);
                            Element.remove('trDespCarta2_'+idxCarta);
                        }
                    }else{
                        if (confirm("Deseja mesmo excluir esta despesa do adiantamento de viagem?")){
                            Element.remove('trDespADV_'+idxCarta);
                        }
                    }
                }

                function removerADV(idxADV){
                    if (confirm("Deseja mesmo excluir este adiantamento de viagem?")){
                        Element.remove('trADV_'+idxADV);
                    }
                }
                
                function calculaSest(baseCalculo, isRetencaoImpostoOpeCFe){
                    isRetencaoImpostoOpeCFe = (isRetencaoImpostoOpeCFe === null || isRetencaoImpostoOpeCFe === undefined) ? false : isRetencaoImpostoOpeCFe;
                    var aliquota = parseFloat("${configuracao.sestSenatAliq}");
                    var sest = new Sest(baseCalculo, aliquota);
                    
                    if (isRetencaoImpostoOpeCFe) {
                        $("valorSESTInteg").value = colocarVirgula(sest.valorFinal);
                    } else {
                        $("baseSEST").value = colocarVirgula(sest.baseCalculo);
                        $("aliqSEST").value = colocarVirgula(sest.aliquota);
                        $("valorSEST").value = colocarVirgula(sest.valorFinal);
                    }
                    

                    return sest;
                }

                function calculaInss(isRetencaoImpostoOpeCFe){
                    isRetencaoImpostoOpeCFe = (isRetencaoImpostoOpeCFe === null || isRetencaoImpostoOpeCFe === undefined) ? false : isRetencaoImpostoOpeCFe;
                    var valorFrete = pontoParseFloat($("cartaValorFrete").value);

                    if (${configuracao.deduzirImpostosOutrasRetencoesCfe}) {
                        var valor = parseFloat($('cartaRetencoes').value);

                        if (isNaN(valor)) {
                            valor = 0;
                        }

                        valorFrete -= valor;
                    }

                    var percentualBase = parseFloat("${configuracao.inssAliqBaseCalculo}");
                    var valorJaRetido = parseFloat($("inss_prop_retido").value);
                    var teto = parseFloat("${configuracao.tetoInss}"); 

                    var faixas = new Array();

                    faixas[0] = new Faixa(0, "${configuracao.inssAte}", "${configuracao.inssAliqAte}");
                    faixas[1] = new Faixa("${configuracao.inssDe1}", "${configuracao.inssAte1}", "${configuracao.inssAliq1}");
                    faixas[2] = new Faixa("${configuracao.inssDe2}", "${configuracao.inssAte2}", "${configuracao.inssAliq2}");
                    faixas[3] = new Faixa("${configuracao.inssDe3}", "${configuracao.inssAte3}", "${configuracao.inssAliq3}");
                    
                    var baseINSSJaRetida = parseFloat($('base_inss_prop_retido').value);
                    var valorINSSJaRetido = parseFloat($('inss_prop_retido').value);
                    var inss = new Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseINSSJaRetida);

                    if (isRetencaoImpostoOpeCFe) {
                        $("valorINSSInteg").value = colocarVirgula(inss.valorFinal);
                    } else {
                        $("baseINSS").value = colocarVirgula(inss.baseCalculo);
                        $("aliqINSS").value = colocarVirgula(inss.aliquota);
                        $("valorINSS").value = colocarVirgula(inss.valorFinal);
                    }
                    
                    return inss;
                }
                
                function calculaIR(inss, isRetencaoImpostoOpeCFe){
                    isRetencaoImpostoOpeCFe = (isRetencaoImpostoOpeCFe === null || isRetencaoImpostoOpeCFe === undefined) ? false : isRetencaoImpostoOpeCFe;
                    var percentualBase = parseFloat("${configuracao.irAliqBaseCalculo}");
                    var isDeduzirInssIr = "${configuracao.deduzirINSSIR}";
                    var faixas = new Array();
                    faixas[0] = new Faixa(0, parseFloat("${configuracao.irDe1}"), 0, 0);
                    faixas[1] = new Faixa(parseFloat("${configuracao.irDe1}"), parseFloat("${configuracao.irAte1}"), parseFloat("${configuracao.irAliq1}"), parseFloat("${configuracao.irdeduzir1}"));
                    faixas[2] = new Faixa(parseFloat("${configuracao.irDe2}"), parseFloat("${configuracao.irAte2}"), parseFloat("${configuracao.irAliq2}"), parseFloat("${configuracao.irDeduzir2}"));
                    faixas[3] = new Faixa(parseFloat("${configuracao.irDe3}"), parseFloat("${configuracao.irAte3}"), parseFloat("${configuracao.irAliq3}"), parseFloat("${configuracao.irDeduzir3}"));
                    faixas[4] = new Faixa(parseFloat("${configuracao.irAte3}"), 99999999, parseFloat("${configuracao.irAliqAcima}"), parseFloat("${configuracao.irdeduzirAcima}"));
                    var baseIRJaRetida = parseFloat($('base_ir_prop_retido').value);
                    var valorIRJaRetido = parseFloat($('ir_prop_retido').value);

                    var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, 0, 0, false, isDeduzirInssIr);
                    
                    if (isRetencaoImpostoOpeCFe) {
                        $("valorIRInteg").value = colocarVirgula(ir.valorFinal);
                    } else {
                        $("valorIR").value = colocarVirgula(ir.valorFinal);
                        $("baseIR").value = colocarVirgula(ir.baseCalculo);
                        $("aliqIR").value = colocarVirgula(ir.aliquota);
                    }
                }

            function calculaImpostos() {
                try {
                    let isRetencaoImpostoOpeCFe = isRetencaoImpostoOperadoraCFeLote();
                    calcularRetencoes();
                    //let isRetencaoImpostoOperadoraCFeLote = isRetencaoImpostoOperadoraCFeLote();
                    var isReter = $("chk_reter_impostos").checked;
                    if (isReter) {
                        var inss = calculaInss(isRetencaoImpostoOpeCFe);
                        calculaSest(inss.baseCalculo, isRetencaoImpostoOpeCFe);
                        calculaIR(inss, isRetencaoImpostoOpeCFe);
                        $('cartaImpostos').value = colocarVirgula(pontoParseFloat($("valorINSS").value) + pontoParseFloat($("valorSEST").value) + pontoParseFloat($("valorIR").value));
                        
                        if (isRetencaoImpostoOpeCFe) {
                            limparImpostosLote();
//                            $("chk_reter_impostos").checked = false;
                        }
                        
                    } else {
                        limparImpostosLote();
                    }
                } catch (e) {
                    console.log(e);
                    alert("Erro ao calcular frete!" + e);
                }
            }

                function calcularFreteCarreteiro(){
                    try {
                        if ("${configuracao.cartaFreteAutomatica}"== "true" || "${configuracao.cartaFreteAutomatica}"== "t") {
                            var PercFreteCadastroProp = parseFloat($('percentual_ctrc_contrato_frete').value);
                            if (PercFreteCadastroProp > 0){
                                var totalFreteCadastroProp = 0;
                                //                            if ($('is_urbano').checked){
                                //                                totalSeguroProp = parseFloat(parseFloat(colocarPonto($('vlmercadoria').value)) * (parseFloat(colocarPonto($('taxa_roubo_urbano').value)) + parseFloat(colocarPonto($('taxa_tombamento_urbano').value))) / 100); 	 
                                //                            }else{
                                //                                totalSeguroProp = parseFloat(parseFloat(colocarPonto($('vlmercadoria').value)) * (colocarPonto(parseFloat($('taxa_roubo').value)) + parseFloat(colocarPonto($('taxa_tombamento').value))) / 100); 	 
                                //                            }
                                var totalDespViagemProp = 0;
                                for(var di = 0; di <= parseInt(countADV); di++){
                                    if ($('trADV_'+di) != null){
                                        totalDespViagemProp += parseFloat(colocarPonto($('vlADV_'+di).value));
                                    }
                                }
                                for(var dd = 0; dd <= parseInt(countDespesaADV); dd++){
                                    if ($('trDespADV_'+dd) != null){
                                        totalDespViagemProp += parseFloat(colocarPonto($('vlDespADV_'+dd).value));
                                    }
                                }
                                for(var dc = 0; dc <= parseInt(countDespesaCarta); dc++){
                                    if ($('trDespCarta_'+dc) != null){
                                        totalDespViagemProp += parseFloat(colocarPonto($('vlDespCarta_'+dc).value));
                                    }
                                }

                                var totalLiquidoProp = parseFloat(parseFloat(getTotalGeralPrestacao()) - parseFloat((getTotalICMS())) 
                                    - getTotalSeguro() - parseFloat(totalDespViagemProp));
                                totalFreteCadastroProp = parseFloat(totalLiquidoProp * parseFloat(PercFreteCadastroProp) / 100);
                                
                                $('cartaValorFrete').value = colocarVirgula(totalFreteCadastroProp);
                                $('valor_maximo_rota').value = colocarVirgula(totalFreteCadastroProp);
                            }
                            //$('cartaValorFrete').value = pontoParseFloat($('cartaValorFrete').value);
                            var freteCarreteiro = pontoParseFloat($('cartaValorFrete').value);
                            var freteOutros = parseFloat($('cartaOutros').value);
                            var fretePedagio = parseFloat($('cartaPedagio').value);
                            var freteLiquido = 0;

                            calculaImpostos();

                            freteLiquido = parseFloat(freteCarreteiro + freteOutros + fretePedagio - pontoParseFloat($('cartaImpostos').value) - parseFloat(colocarPonto($('cartaRetencoes').value)) - parseFloat($("abastecimentos").value));

                            $('cartaLiquido').value = colocarVirgula(freteLiquido);
                            if ($('tipo_desconto_prop').value == '2') {
                                // ^--- Sobre o valor do frete
                                var vlCC = (freteCarreteiro * parseFloat(colocarVirgula($('percentual_desconto_prop').value))) / 100;

                                if (vlCC > parseFloat($('debito_prop').value)) {
                                    vlCC = $('debito_prop').value;
                                }

                                freteLiquido = freteLiquido - vlCC;
                            }
                            $('valorPgto_1').value = colocarVirgula(parseFloat(freteLiquido) * parseFloat(($('perc_adiant').value == "" ? '0' : $('perc_adiant').value)) / 100);
                            var sld = parseFloat(freteLiquido) - parseFloat(colocarPonto($('valorPgto_1').value));
                            sld = parseFloat(sld) < 0 ? 0 : sld;

                            //Verificando se vai descontar do conta corrente
                            if (parseFloat(colocarPonto($('debito_prop').value)) > 0 && parseFloat(($('percentual_desconto_prop').value)) > 0 ){
                                $('trCartaCC').style.display = '';
                                if ($('tipo_desconto_prop').value != '2') {
                                    var percentual_desconto = parseFloat(($('percentual_desconto_prop').value));
                                    var vlCC = (sld == 0 ? 0 : parseFloat(parseFloat(percentual_desconto) * parseFloat(sld) / 100));
                                    if (parseFloat(vlCC) > parseFloat($('debito_prop').value)) {
                                        vlCC = $('debito_prop').value;
                                    }
                                    sld = parseFloat(parseFloat(formatoMoeda(sld)) - parseFloat(formatoMoeda(vlCC)));
                                }
                                $('cartaValorCC').value = colocarVirgula(vlCC);
                            }else{
                                $('trCartaCC').style.display = 'none';
                                $('cartaValorCC').value = '0,00';
                            }


                            $('valorPgto_2').value = colocarVirgula(parseFloat(sld));
                        }
                        //                    alteraFpag('s');
                    } catch (e) { 
                        alert("Erro ao calcular frete!"+e);
                    }
                }
                
                function ContratoFretePagamento(id, tipo, valor, data, fpag, doc, agente_id,
                agente, despesa_id, fixo, percAbastec, baixado, contaId, saldoAutorizado, planoAgente,
                contaAd, agenciaAd, favorecidoAd, bancoAd, tipoFavorecido, undAgente, nfiscal, tipoConta, isPamcard, isRepom, isNdd){

                    this.id= (id == null || id == undefined? 0 : id);
                    this.tipo= (tipo == null || tipo== undefined? "a" : tipo);
                    this.valor= (valor== null || valor== undefined? 0 : valor);
                    this.data= (data== null || data== undefined? dataAtual : data);
                    this.doc= (doc== null || doc== undefined? "" : doc);
                    this.agente_id= (agente_id== null || agente_id== undefined? 0 : agente_id);
                    this.agente= (agente== null || agente== undefined? "" : agente);
                    this.despesa_id= (despesa_id== null || despesa_id== undefined? 0 : despesa_id);
                    this.fixo= (fixo== null || fixo== undefined? false : fixo);
                    this.percAbastec= (percAbastec== null || percAbastec== undefined? 0 : percAbastec);
                    this.baixado= (baixado== null || baixado== undefined? false : baixado);
                    this.contaId= (contaId== null || contaId== undefined? 0 : contaId);
                    this.saldoAutorizado= (saldoAutorizado== null || saldoAutorizado== undefined? false : saldoAutorizado);
                    this.planoAgente= (planoAgente== null || planoAgente== undefined? 0 : planoAgente);
                    this.contaAd= (contaAd== null || contaAd== undefined? "" : contaAd);
                    this.agenciaAd= (agenciaAd== null || agenciaAd== undefined? "" : agenciaAd);
                    this.favorecidoAd= (favorecidoAd== null || favorecidoAd== undefined? "" : favorecidoAd);
                    this.bancoAd= (bancoAd== null || bancoAd== undefined? "" : bancoAd);
                    this.tipoFavorecido= (tipoFavorecido== null || tipoFavorecido== undefined? "" : tipoFavorecido);
                    this.undAgente= (undAgente== null || undAgente== undefined? "" : undAgente);
                    this.nfiscal= (nfiscal== null || nfiscal== undefined? "" : nfiscal);
                    this.tipoConta= (tipoConta== null || tipoConta== undefined? "c" : tipoConta);
                    var filial = ($('filial').value).split("@@")[0];  
                    this.isPamcard= (($('is_tac').value == 't') && ($('filialCfe_'+filial).value === 'P'));
                    this.isRepom= (($('is_tac').value == 't') && ($('filialCfe_'+filial).value === 'R'));
                    this.isNdd= (($('is_tac').value == 't') && ($('filialCfe_'+filial).value === 'D'));
                    
                    if (fpag== null || fpag== undefined){
                        if (this.isPamcard){
                            this.fpag = 11;
                        }else if (this.isRepom){
                            this.fpag = 12;
                        }else if(this.isNdd){
                            this.fpag = 14;
                        }else{
                            this.fpag = formaPagPadrao;
                        }
                    }else{
                        this.fpag = formaPagPadrao;
                    }

                }
                var countPgto= 0;
                var formaPagPadrao = "${configuracao.fpag.idFPag}";
                
                function addPagto(pagamento){
                    try {
                        if(pagamento === null || pagamento === undefined){
                            pagamento = new ContratoFretePagamento();
                        }
                        
                        if (isRetencaoImpostoOperadoraCFeLote()) {
                            if (pagamento.tipo === "s" && getPrimeiroSaldo() !== -1) {
                                alert("ATENÇÂO: Só é possivel adicionar um saldo, pois a opção 'A retenção de impostos será realizada pela REPOM' esta ativa!");
                                return false;
                            }
                        }
                        countPgto++;

                        var celulaZebrada = ((countPgto % 2) == 0 ? 'CelulaZebra1' : 'CelulaZebra2');

                        var _tr1 = Builder.node("TR",{id:"trPgto_"+countPgto, className: celulaZebrada});

                        var _td1 = new Element("TD", {align:"center"});
                        var _td2 = Builder.node("TD", {align:"left"});
                        var _td3 = Builder.node("TD", {align:"left"});
                        var _td4 = Builder.node("TD", {align:"left"});
                        var _td5 = Builder.node("TD", {align:"left"});
                        var _td6 = Builder.node("TD", {align:"left"});
                        var _td7 = Builder.node("TD", {align:"center"});
                        var _td8 = Builder.node("TD", {align:"center"});
                        var _td9 = Builder.node("TD", {align:"center"});

                        //variaveis com as funcoes
                        var callVerDocumPgto  = "verDocumPgto("+countPgto+");";
                        var callLocalizarAgente  = "abrirLocalizaAgente("+countPgto+");";
                        var callAlterarTipoPagamento  = "alterarTipoPag("+countPgto+");";
                        var callVerDesp = "verDesp("+pagamento.despesa_id+");";
                        var callExcluirPagto = "excluirPagto("+countPgto+");";
                        var callBaixar = "baixar("+pagamento.nfiscal+");";
                        var callAlteraFavorecidoPagto  = "alteraTipoFavorecido("+countPgto+");";
                        var callAlterarAdiantamento  = "alterarAdiantamento();";
                        

                        var _lab1 = Builder.node('LABEL', {id:"lab1_"+countPgto});
                        Element.update(_lab1, "Favorecido: ");
                        var _lab2 = Builder.node('LABEL', {id:"lab2_"+countPgto});
                        Element.update(_lab2, "Conta: ");
                        var _lab3 = Builder.node('LABEL', {id:"lab3_"+countPgto});
                        Element.update(_lab3, "Banco: ");
                        var _lab4 = Builder.node('LABEL', {id:"lab4_"+countPgto});
                        Element.update(_lab4, " Ag: ");
                        var _lab5 = Builder.node('LABEL', {className:'linkEditar',onClick: callVerDesp});
                        Element.update(_lab5, pagamento.despesa_id);
                        var _lab6 = Builder.node('LABEL', {id:'status_'+countPgto});
                        var _lab7 = Builder.node('LABEL', {id:"lab7_"+countPgto});
                        Element.update(_lab7, "Debitar: ");
                        var _lab8 = Builder.node('LABEL', {id:"lab8_"+countPgto});
                        Element.update(_lab8, "Ag. Pagador: ");

                        var _inp1 = Builder.node("INPUT", {type:"text",size:9,name:"valorPgto_"+countPgto, id:"valorPgto_"+countPgto, className:'fieldMin styleNum', value: colocarVirgula(pagamento.valor), onKeyPress:callMascaraReais});
                        var _inp2 = Builder.node("INPUT", {type:"text",size:11,name:"dataPgto_"+countPgto,id: "dataPgto_"+countPgto, className:'fieldDateMin', value: pagamento.data});
                        var _inp3 = Builder.node("INPUT", {type:"text",size:10,name:"documPgto_"+countPgto, id:"documPgto_"+countPgto, className:'fieldMin', value: pagamento.doc});
                        var _inp4 = Builder.node("INPUT", {type:"text",size:20,name:"favorecidoAd_"+countPgto, id:"favorecidoAd_"+countPgto, className:'fieldMin', value: pagamento.favorecidoAd});
                        var _inp5 = Builder.node("INPUT", {type:"text",size:10,name:"contaAd_"+countPgto, id:"contaAd_"+countPgto, className:'fieldMin', value: pagamento.contaAd});
                        var _inp6 = Builder.node("INPUT", {type:"text",size:5,name:"agenciaAd_"+countPgto, id:"agenciaAd_"+countPgto, className:'fieldMin', value: pagamento.agenciaAd});
                        var _inp7 = Builder.node("INPUT", {type:"hidden",name:"idPgto_"+countPgto,id: "idPgto_"+countPgto,value: pagamento.id});
                        var _inp8 = Builder.node("INPUT", {type:"text",size:20,name:"agentePgto_"+countPgto, id:"agentePgto_"+countPgto, className:'inputReadOnly8pt', value: pagamento.agente});
                        var _inp9 = Builder.node("INPUT", {type:"hidden",name:"idAgentePgto_"+countPgto, id:"idAgentePgto_"+countPgto, value: pagamento.agente_id});
                        var _inp10 = Builder.node("INPUT", {type:"hidden",name:"percAbast_"+countPgto,id: "percAbast_"+countPgto,value: pagamento.percAbastec});
                        var _inp11 = Builder.node("INPUT", {type:"hidden",name:"despesaPagId_"+countPgto,id: "despesaPagId_"+countPgto,value: pagamento.despesa_id});
                        var _inp12 = Builder.node("INPUT", {type:"hidden",name:"baixado_"+countPgto,id: "baixado_"+countPgto,value: pagamento.baixado});
                        var _inp13 = Builder.node("INPUT", {type:"hidden",name:"saldoAltorizacao_"+countPgto,id: "saldoAltorizacao_"+countPgto,value: pagamento.saldoAutorizado});
                        var _inp14 = Builder.node("INPUT", {type:"hidden",name:"planoAgente_"+countPgto,id: "planoAgente_"+countPgto,value: pagamento.planoAgente});
                        var _inp15 = Builder.node("INPUT", {type:"hidden",name:"undAgente_"+countPgto,id: "undAgente_"+countPgto,value: pagamento.undAgente});
                        var _inp16 = Builder.node("INPUT", {type:"hidden",name:"isPamcard_"+countPgto,id: "isPamcard_"+countPgto});
                        var _inp17 = Builder.node("INPUT", {type:"hidden",name:"isRepom_"+countPgto,id: "isRepom_"+countPgto});
                        var _inp18 = Builder.node("INPUT", {type:"hidden",name:"isNdd_"+countPgto,id: "isNdd_"+countPgto});

                        var _but1 = Builder.node('INPUT', {type:'button', name:'localizaAgente_'+countPgto, id:'localizaAgente_'+countPgto,value:'...', className:'inputBotaoMin',onClick: callLocalizarAgente});

                        var _img1 = Builder.node('IMG', {src:'img/lixo.png', title:'Excluir Pagamento', className:'imagemLink',onClick:callExcluirPagto});
                        var _img2 = Builder.node('IMG', {src:'img/baixar.gif', title:'Baixar este '+(pagamento.tipo=="a"?"Adiantamento":"Saldo"), className:'imagemLink',onClick: callBaixar});

                        var _slc1 = Builder.node('SELECT', {name:'tipoPagto_'+countPgto, id:'tipoPagto_'+countPgto, className:'fieldMin',onChange: callVerDocumPgto});
                        var _optA = Builder.node('OPTION', {value:"a"});
                        var _optS = Builder.node('OPTION', {value:"s"});
                        _slc1.appendChild(Element.update(_optA, "Adiantamento"));
                        _slc1.appendChild(Element.update(_optS, "Saldo"));

                        var _slc2 = Builder.node('SELECT', {name:'formaPagto_'+countPgto, id:'formaPagto_'+countPgto, className:'fieldMin', onChange: callVerDocumPgto});
                        var _slc3 = Builder.node('SELECT', {name:'contaPgto_'+countPgto, id:'contaPgto_'+countPgto, className:'fieldMin', onChange: callVerDocumPgto});
                        var _slc4 = Builder.node('SELECT', {name:'banco_'+countPgto, id:'banco_'+countPgto, className:'fieldMin'});

                        var _slc5 = Builder.node('SELECT', {name:'tipoFavorecido_'+countPgto, id:'tipoFavorecido_'+countPgto, className:'fieldMin', onChange: callAlteraFavorecidoPagto});
                        var _optT = Builder.node('OPTION', {value:"t"});
                        var _optM = Builder.node('OPTION', {value:"m"});
                        var _optP = Builder.node('OPTION', {value:"p"});
                        if (!pagamento.isPamcard){
                            _slc5.appendChild(Element.update(_optT, "Terceiro"));
                        }
                        _slc5.appendChild(Element.update(_optM, "Motorista"));
                        _slc5.appendChild(Element.update(_optP, "Proprietário"));

                        var _slc6 = Builder.node('SELECT', {name:'documPgto2_'+countPgto, id:'documPgto2_'+countPgto, className:'fieldMin'});

                        var _slc7 = Builder.node('SELECT', {name:'tipoContaPgto_'+countPgto, id:'tipoContaPgto_'+countPgto, className:'fieldMin'});
                        var _optCorrente = Builder.node('OPTION', {value:"c"});
                        var _optPoupanca = Builder.node('OPTION', {value:"p"});
                        _slc7.appendChild(Element.update(_optCorrente, "C. Corrente:"));
                        _slc7.appendChild(Element.update(_optPoupanca, "C. Poupança:"));

                        var optPgto = null;

                        for(var i = 0; i < listaFormaPagamento.length; i++){
                            optPgto = Builder.node("option", {value: listaFormaPagamento[i].valor});
                            Element.update(optPgto, listaFormaPagamento[i].descricao);
                            var isMostra = false;
                            if (pagamento.isPamcard){
                                if(listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 11 || listaFormaPagamento[i].valor == pagamento.fpag){
                                    isMostra = true;
                                }
                            }else if (pagamento.isNdd){
                                if(listaFormaPagamento[i].valor == 4 || listaFormaPagamento[i].valor == 14 || listaFormaPagamento[i].valor == pagamento.fpag){
                                    isMostra = true;
                                }
                            }else if(pagamento.isRepom){
                                if(listaFormaPagamento[i].valor == 12 || listaFormaPagamento[i].valor == pagamento.fpag){
                                    isMostra = true;
                                }
                            }else{
                                isMostra = true;
                            }
                            if (isMostra){
                                _slc2.appendChild(optPgto);
                            }
                        }
                        _slc2.value = formaPagPadrao;
                        var optBanco = null;
                        for(var i = 0; i < listaBanco.length; i++){
                            optBanco = Builder.node("option", {
                                value: listaBanco[i].valor
                            });
                            Element.update(optBanco, listaBanco[i].descricao);
                            _slc4.appendChild(optBanco);
                        }
                        var optConta = null;
                        for(var i = 0; i < listaConta.length; i++){
                            optConta = Builder.node("option", {
                                value: listaConta[i].valor
                            });
                            Element.update(optConta, listaConta[i].descricao);
                            _slc3.appendChild(optConta);
                        }
                        _slc3.selectedIndex = 0;

                        // INSERINDO VALORES DOS SELECT'S
                        _slc1.value = pagamento.tipo;

                        _td1.appendChild(_inp7);
                        _td1.appendChild(_inp16);
                        _td1.appendChild(_inp17);
                        _td1.appendChild(_inp18);
                        _td1.appendChild(_slc1);
                        _td2.appendChild(_inp1);
                        _td3.appendChild(_inp2);
                        _td4.appendChild(_slc2);
                         _td5.appendChild(_slc3);
                        _td5.appendChild(_slc5);
                        _td5.appendChild(_inp8);
                        _td5.appendChild(_inp9);
                        _td5.appendChild(_but1);
                        _td6.appendChild(_inp3);
                        _td6.appendChild(_slc6);

                        var _br1 = Builder.node("br",{id:"br1_"+countPgto});
                        var _br2 = Builder.node("br",{id:"br2_"+countPgto});
                        var _br3 = Builder.node("br",{id:"br3_"+countPgto});


                        _tr1.appendChild(_td1);
                        _tr1.appendChild(_td2);
                        _tr1.appendChild(_td3);
                        _tr1.appendChild(_td4);
                        _tr1.appendChild(_td5);
                        _tr1.appendChild(_td6);
                        
                        if(pagamento.fixo){
                            desabilitar(_slc1);
                        }
                        
                        if(pagamento.tipo=="a"){
                            _inp1.onblur = new Function(callAlterarAdiantamento);
                            visivel(_slc3);
                            invisivel(_br1);
                            invisivel(_br2);
                            invisivel(_br3);
                            invisivel(_lab1);
                            invisivel(_slc5);
                            invisivel(_slc4);
                            invisivel(_inp4);
                            invisivel(_lab2);
                            invisivel(_lab3);
                            invisivel(_lab4);
                            invisivel(_inp5);
                            invisivel(_inp6);
                        }else{
                            invisivel(_slc3);
                            invisivel(_slc5);
                        }
                        
                        if(pagamento.fpag != "3" || pagamento.tipo != "a" || ${configuracao.controlarTalonario}){
                            invisivel(_slc6);
                        }

                        if(pagamento.baixado || pagamento.saldoAutorizado){
                            desabilitar(_slc1);
                            desabilitar(_slc3);
                            desabilitar(_slc4);
                            desabilitar(_slc5);
                            desabilitar(_slc6);
                            desabilitar(_slc7);
                            desabilitar(_inp1);
                            desabilitar(_inp2);
                            desabilitar(_inp3);
                            desabilitar(_inp4);
                            desabilitar(_inp5);
                            desabilitar(_inp6);
                            desabilitar(_slc2);

                            if(pagamento.baixado){
                                Element.update(_lab6, "Baixado");
                            }else{
                                Element.update(_lab6, "Autorizado");
                            }
                        }else{
                            if(pagamento.despesa_id != 0){
                                Element.update(_lab6, "Em aberto");
                            }
                        }

                        //Criando todos os elementos
                        $("bodyPagamento").appendChild(_tr1);

                       
                        _inp16.value = pagamento.isPamcard;
                        _inp17.value = pagamento.isRepom;
                        _inp18.value = pagamento.isNdd;

                        _slc1.style.width = '50px';
                        _slc2.style.width = '85px';
                        _slc3.style.width = '140px';
                        //                        //$("tipoFavorecido_"+countPgto).style.width = '60px';
                        //                        $("banco_"+countPgto).style.width = '140px';
                        //
                        $("maxPagContFrete").value= countPgto;
                        verDocumPgto(countPgto);

                    } catch (e) { 
                        console.log(e);
                        alert(e);
                    }
                }

                function getFpagDespCarta(idxCarta){
                    try {
                        var isPago = $('DespPago_'+idxCarta).checked;
                        $('vlDespVencimento_'+idxCarta).style.display = 'none';
                        $("lbDespVencimento_"+idxCarta).style.display = 'none';
                        $('contaDespCarta_'+idxCarta).style.display = 'none';
                        $("chqDespCarta_"+idxCarta).style.display = 'none';
                        $("lbChqDespCarta_"+idxCarta).style.display = 'none';
                        $('docDespCarta_'+idxCarta).style.display = 'none';
                        $('docDespCarta_cb_'+idxCarta).style.display = 'none';
                        if (isPago){
                            $('contaDespCarta_'+idxCarta).style.display = '';
                            $("chqDespCarta_"+idxCarta).style.display = '';
                            $("lbChqDespCarta_"+idxCarta).style.display = '';
                            if ($("chqDespCarta_"+idxCarta).checked) {
                                controlarCheque((${configuracao.controlarTalonario}), $('docDespCarta_cb_'+idxCarta), $('docDespCarta_'+idxCarta), $('contaDespCarta_'+idxCarta).value);
                            }else{
                                $('docDespCarta_'+idxCarta).style.display = '';
                                $('docDespCarta_cb_'+idxCarta).style.display = 'none';
                            }
                        }else{
                            $('vlDespVencimento_'+idxCarta).style.display = '';
                            $("lbDespVencimento_"+idxCarta).style.display = '';
                        }
                    } catch (e) { 
                        console.log(e);
                        alert(e);
                    }
                }

                function getFpagADV(idxADV){
                    var isCheque = $('chqADV_'+idxADV).checked;
                    $('docADV_'+idxADV).style.display = 'none';
                    $('docADV_cb_'+idxADV).style.display = 'none';
                    if (isCheque){
                        controlarCheque((${configuracao.controlarTalonario}), $('docADV_cb_'+idxADV), $('docADV_'+idxADV), $('contaADV_'+idxADV).value);
                    }else{
                        $('docADV_'+idxADV).style.display = '';
                    }
                }
                
                function getPrimeiroSaldo(){
                    for (var i = 0; i <= countPgto; i++) {
                        if ($("tipoPagto_" + i) !== null && $("tipoPagto_" + i).value === "s") {
                            return i;
                        }
                    }
                    return -1;
                }
                
                function verDocumPgto(linha){
                    let index = getPrimeiroSaldo();
                    if (isRetencaoImpostoOperadoraCFeLote()) {
                        if ($("tipoPagto_"+linha).value === "s" && getPrimeiroSaldo() !== -1 && linha !== index) {
                            $("tipoPagto_"+linha).value = "a";
                            alert("ATENÇÂO: Só é possivel adicionar um saldo, pois a opção 'A retenção de impostos será realizada pela REPOM' esta ativa!");
                            return false;
                        }
                    }
                    // se for cheque(forma 3) e o tipo adiantamento e baixa adiantamento e controla talonario ele vai carregar os cheques.
                    if($("formaPagto_"+linha).value=="3" && $("tipoPagto_"+linha).value=="a" && ${configuracao.baixaAdiantamentoCartaFrete} && ${configuracao.controlarTalonario}){
                        controlarCheque(${configuracao.controlarTalonario}, $("documPgto2_"+linha), $("documPgto_"+linha), $('contaPgto_'+linha).value);
                    }else{
                        invisivel($("documPgto2_"+linha));
                        visivel($("documPgto_"+linha));
                    }
                    alterarTipoPagto(linha);
                    if($("tipoPagto_"+linha).value == "a"){
                        verContaBancaria(linha);
                    }else if($("tipoPagto_"+linha).value == "s"){
                        verTipoFavorecido(linha);
                    }
                }
                
                function verTipoFavorecido(linha){
                    if($("formaPagto_"+linha).value=="3" || $("formaPagto_"+linha).value=="4"
                         || $("formaPagto_"+linha).value=="11" || $("formaPagto_"+linha).value=="12" 
                         || $("formaPagto_"+linha).value=="13" || $("formaPagto_"+linha).value=="14" 
                         || $("formaPagto_"+linha).value=="16" || $("formaPagto_"+linha).value=="17" 
                         || $("formaPagto_"+linha).value=="18" || $("formaPagto_"+linha).value=="20"){
                            //visivel($("contaPgto_"+linha));
                            visivel($("tipoFavorecido_"+linha));
                        }else{
                            invisivel($("tipoFavorecido_"+linha));
                    }
                }

                function verContaBancaria(linha){
                    // O campo de conta bancária só aparecer se a forma de pagamento for Cheque
                    if($("formaPagto_"+linha).value=="3" || $("formaPagto_"+linha).value=="11"
                         || $("formaPagto_"+linha).value=="12" || $("formaPagto_"+linha).value=="13" 
                         || $("formaPagto_"+linha).value=="14" || $("formaPagto_"+linha).value=="16" 
                         || $("formaPagto_"+linha).value=="17" || $("formaPagto_"+linha).value=="18" 
                         || $("formaPagto_"+linha).value=="20"){
                            visivel($("contaPgto_"+linha));
                            visivel($("tipoFavorecido_"+linha));
                    }else{
                        invisivel($("contaPgto_"+linha));
                        invisivel($("tipoFavorecido_"+linha));
                    }
                }
                
                function alteraFpagSaldo(linha){
                     if($("formaPagto_"+linha).value=="3" || $("formaPagto_"+linha).value=="12"
                         || $("formaPagto_"+linha).value=="13" || $("formaPagto_"+linha).value=="14"
                         || $("formaPagto_"+linha).value=="4" || $("formaPagto_"+linha).value=="16"
                         || $("formaPagto_"+linha).value=="17" || $("formaPagto_"+linha).value=="18"
                         || $("formaPagto_"+linha).value=="20"){
                        visivel($("contaPgto_"+linha));
                        visivel($("tipoFavorecido_"+linha));
                    }else{
                        invisivel($("contaPgto_"+linha));
                        invisivel($("tipoFavorecido_"+linha));
                    }
                }
                
                function alterarTipoPagto(index){
                    var formaPag = $('formaPagto_'+index).value;
                    if($("tipoPagto_"+index).value=="a"){
                        visivel($("contaPgto_"+index));
                        // se ele baixa automatico o adiantamento
                        if (${configuracao.baixaAdiantamentoCartaFrete}){
                            //                invisivel($("br1_"+index));
                            //                invisivel($("br2_"+index));
                            //                invisivel($("br3_"+index));
                            //                invisivel($("lab1_"+index));
                            //                invisivel($("tipoContaPgto_"+index));
                            //                invisivel($("lab3_"+index));
                            //                invisivel($("lab4_"+index));
                            //                invisivel($("banco_"+index));
                            //                invisivel($("tipoFavorecido_"+index));
                            //                invisivel($("favorecidoAd_"+index));
                            //                invisivel($("contaAd_"+index));
                            //                invisivel($("agenciaAd_"+index));
                            if (formaPag == '8' || formaPag == '12'){
                                //                    invisivel($("lab7_"+index));
                                invisivel($("contaPgto_"+index));
                                //                    visivel($("lab8_"+index));
                                visivel($("agentePgto_"+index));
                                visivel($("localizaAgente_"+index));
                            }else{
                                //                    invisivel($("lab8_"+index));
                                invisivel($("agentePgto_"+index));
                                invisivel($("localizaAgente_"+index));
//                                visivel($("lab7_"+index));
                                visivel($("contaPgto_"+index));
                            }
                        }else{
                            //                invisivel($("br1_"+index));
                            //                invisivel($("lab7_"+index));
                            invisivel($("contaPgto_"+index));
                            if (formaPag == '8' || formaPag == '12'){
                                //                    invisivel($("br2_"+index));
                                //                    invisivel($("br3_"+index));
                                //                    invisivel($("lab1_"+index));
                                //                    invisivel($("tipoContaPgto_"+index));
                                //                    invisivel($("lab3_"+index));
                                //                    invisivel($("lab4_"+index));
                                //                    invisivel($("banco_"+index));
                                //                    invisivel($("tipoFavorecido_"+index));
                                //                    invisivel($("favorecidoAd_"+index));
                                //                    invisivel($("contaAd_"+index));
                                //                    invisivel($("agenciaAd_"+index));
                                //                    visivel($("lab8_"+index));
                                visivel($("agentePgto_"+index));
                                visivel($("localizaAgente_"+index));
                            }else{
                                //                    visivel($("br2_"+index));
                                //                    visivel($("br3_"+index));
                                //                    visivel($("lab1_"+index));
                                //                    visivel($("tipoContaPgto_"+index));
                                //                    visivel($("lab3_"+index));
                                //                    visivel($("lab4_"+index));
                                //                    visivel($("banco_"+index));
                                //                    visivel($("tipoFavorecido_"+index));
                                //                    visivel($("favorecidoAd_"+index));
                                //                    visivel($("contaAd_"+index));
                                //                    visivel($("agenciaAd_"+index));
                                //                    invisivel($("lab8_"+index));
                                invisivel($("agentePgto_"+index));
                                invisivel($("localizaAgente_"+index));
                            }
                        }
                    }else{
                        //                        invisivel($("br1_"+index));
                        //                        invisivel($("lab7_"+index));
                        invisivel($("contaPgto_"+index));
                        if (formaPag == '8' || formaPag == '12'){
                            //                            invisivel($("br2_"+index));
                            //                            invisivel($("br3_"+index));
                            //                            invisivel($("lab1_"+index));
                            //                            invisivel($("tipoContaPgto_"+index));
                            //                            invisivel($("lab3_"+index));
                            //                            invisivel($("lab4_"+index));
                            //                            invisivel($("tipoFavorecido_"+index));
                            //                            invisivel($("banco_"+index));
                            //                            invisivel($("favorecidoAd_"+index));
                            //                            invisivel($("contaAd_"+index));
                            //                            invisivel($("agenciaAd_"+index));
                            //                            visivel($("lab8_"+index));
                            visivel($("agentePgto_"+index));
                            visivel($("localizaAgente_"+index));
                        }else{
                            //                            visivel($("br2_"+index));
                            //                            visivel($("br3_"+index));
                            //                            visivel($("lab1_"+index));
                            //                            visivel($("tipoContaPgto_"+index));
                            //                            visivel($("lab3_"+index));
                            //                            visivel($("lab4_"+index));
                            //                            visivel($("tipoFavorecido_"+index));
                            //                            visivel($("banco_"+index));
                            //                            visivel($("favorecidoAd_"+index));
                            //                            visivel($("contaAd_"+index));
                            //                            visivel($("agenciaAd_"+index));
                            //                            invisivel($("lab8_"+index));
                            invisivel($("agentePgto_"+index));
                            invisivel($("localizaAgente_"+index));
                        }
                    }
                    //Se for Pamcard
                    if ($('isPamcard_'+index).value == true || $('isPamcard_'+index).value == 't' || $('isPamcard_'+index).value == 'true'){
                        //                        visivel($("tipoFavorecido_"+index));
                        if ($("formaPagto_"+index).value=="11"){
                            //                            if ($("tipoPagto_"+index).value=="a"){
                            //                                visivel($("br1_"+index));
                            //                            }
                            //                            invisivel($("br2_"+index));
                            //                            invisivel($("br3_"+index));
                            //                            visivel($("lab1_"+index));
                            //                            invisivel($("tipoContaPgto_"+index));
                            //                            invisivel($("lab3_"+index));
                            //                            invisivel($("lab4_"+index));
                            //                            invisivel($("banco_"+index));
                            //                            invisivel($("favorecidoAd_"+index));
                            //                            invisivel($("contaAd_"+index));
                            //                            invisivel($("agenciaAd_"+index));
                        }else if ($("formaPagto_"+index).value=="4"){
                            //                            if ($("tipoPagto_"+index).value=="a"){
                            //                                visivel($("br1_"+index));
                            //                            }
                            //                            visivel($("br2_"+index));
                            //                            visivel($("br3_"+index));
                            //                            visivel($("lab1_"+index));
                            //                            visivel($("tipoContaPgto_"+index));
                            //                            visivel($("lab3_"+index));
                            //                            visivel($("lab4_"+index));
                            //                            visivel($("banco_"+index));
                            //                            invisivel($("favorecidoAd_"+index));
                            //                            visivel($("contaAd_"+index));
                            //                            visivel($("agenciaAd_"+index));
                        }
                    }
        
                    // SE FOR NDD
                    if ($('isNdd_'+index).value == true || $('isNdd_'+index).value == 't' || $('isNdd_'+index).value == 'true'){
                        visivel($("tipoFavorecido_"+index));
                        if ($("formaPagto_"+index).value=="14"){
                            //                            if ($("tipoPagto_"+index).value=="a"){
                            //                                visivel($("br1_"+index));
                            //                            }
                            //                            invisivel($("br2_"+index));
                            //                            invisivel($("br3_"+index));
                            //                            visivel($("lab1_"+index));
                            //                            invisivel($("tipoContaPgto_"+index));
                            //                            invisivel($("lab3_"+index));
                            //                            invisivel($("lab4_"+index));
                            //                            invisivel($("banco_"+index));
                            //                            invisivel($("favorecidoAd_"+index));
                            //                            invisivel($("contaAd_"+index));
                            //                            invisivel($("agenciaAd_"+index));
                        }else if ($("formaPagto_"+index).value=="4"){
                            //                            if ($("tipoPagto_"+index).value=="a"){
                            //                                visivel($("br1_"+index));
                            //                            }
                            //                            visivel($("br2_"+index));
                            //                            visivel($("br3_"+index));
                            //                            visivel($("lab1_"+index));
                            //                            visivel($("tipoContaPgto_"+index));
                            //                            visivel($("lab3_"+index));
                            //                            visivel($("lab4_"+index));
                            //                            visivel($("banco_"+index));
                            //                            invisivel($("favorecidoAd_"+index));
                            //                            visivel($("contaAd_"+index));
                            //                            visivel($("agenciaAd_"+index));
                        }
                    }
                    //Se for Repom
                    if ($('isRepom_'+index).value == true || $('isRepom_'+index).value == 't' || $('isRepom_'+index).value == 'true'){
                        if ($('idAgentePgto_'+index).value == 0 && $('agente_repom_id_'+$('filial')) !== null){
                            $('idAgentePgto_'+index).value = $('agente_repom_id_'+$('filial').value).value;
                            $('agentePgto_'+index).value = $('agente_repom_'+$('filial').value).value;
                        }
                    }

                }
                
                function makeForm(sufix, metodo, acao, apelido){
                    var form = Builder.node("form",{
                        id: "form_"+ sufix,
                        name: "form_"+ sufix,
                        action: acao,
                        target: apelido,
                        method: metodo
                    });
                    return form;
                }
                
                function carregarCtrcsNaoMarcados(){
                    if (${param.carregarCtrcs != null}) {
                        var ctrc;
                        var nf;
                        var apoioNotas = 0;
                        var idxNota = 0;
                        var listaCubagens;
                        var indexMerc = 0;
                        var listaMercadoria;
                        var cubagem;
                        var indexCubagem;
                        var merc;
                        var carregarCtrcs = '${param.carregarCtrcs}';
                        if (carregarCtrcs == "true") {
                            try{
                                <c:forEach var="ctrc" varStatus="status" items="${ctrcs}">

                                    ctrc = new CTRC();
                                    ctrc.cfopId = "${ctrc.cfop.idcfop}";
                                    ctrc.cfop = "${ctrc.cfop.cfop}";
                                    ctrc.taxaRoubo = "${ctrc.taxaSeguroRoubo}";
                                    ctrc.taxaRouboUrbano = "${ctrc.taxaSeguroRouboUrbano}";
                                    ctrc.taxaTombamento = "${ctrc.taxaSeguroTombamento}";
                                    ctrc.taxaTombamentoUrbano = "${ctrc.taxaSeguroTombamentoUrbano}";
                                    ctrc.taxaTombamentoUrbano = "${ctrc.taxaSeguroTombamentoUrbano}";
                                    ctrc.cubagemMetro = "${ctrc.cubagemMetro}";
                                    ctrc.numeroContainer = "${ctrc.numeroContainer}";
                                    ctrc.numeroCarga = "${ctrc.numeroCarga}";
                                    ctrc.previsaoEntrega = "${ctrc.previsaoEntrega}";
                                    ctrc.idRota = "${ctrc.rota.id}";
                                    ctrc.rota = "${ctrc.rota.descricao}";
                                    ctrc.distancisKm = "${ctrc.distanciaOrigemDestino}";


                                    <c:forEach var="obs" varStatus="status" items="${ctrc.observacao}">
                                    ctrc.observacao += "${obs}";                                    
                                </c:forEach>
                                    ctrc.consignatario.listaTipoProduto = new Array();
                                    var countOptTpProd = 0;
                                <c:forEach var="tipo" varStatus="status" items="${ctrc.cliente.tipoProduto}">
                                    ctrc.consignatario.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
                                </c:forEach>
                                    
                                    ctrc.tipoFrete = 3;
                                    ctrc.valorFretePeso = "${ctrc.valorPeso}";
                                    ctrc.valorTaxaFixa = "${ctrc.valorTaxaFixa}";
                                    ctrc.valorFreteValor  = "${ctrc.valorFrete}";
                                    ctrc.valorPedagio  = "${ctrc.valorPedagio}";
                                    
                                    //consignatario
                                    ctrc.consignatario.razaoSocial = "${ctrc.cliente.razaosocial}";
                                    ctrc.consignatario.id = "${ctrc.cliente.idcliente}";
                                    ctrc.consignatario.cnpj = "${ctrc.cliente.cnpj}";
                                    ctrc.consignatario.cidadeId = "${ctrc.cliente.cidade.idcidade}";
                                    ctrc.consignatario.cidade = "${ctrc.cliente.cidade.descricaoCidade}";
                                    ctrc.consignatario.uf = "${ctrc.cliente.cidade.uf}";
                                    ctrc.consignatario.endereco = "${ctrc.cliente.endereco}";
                                    ctrc.consignatario.isCreditoBloqueado = "${ctrc.cliente.creditoBloqueado}";
                                    ctrc.consignatario.creditoDisponivel = "${ctrc.cliente.creditoDisponivel}";
                                    ctrc.consignatario.tipoCGC = "${ctrc.cliente.cidade.descricaoCidade}";
                                    ctrc.consignatario.tipoCfop = "${ctrc.cliente.tipoCfop}";
                                    ctrc.consignatario.inscEst = "${ctrc.cliente.inscest}";
                                    ctrc.consignatario.isStMG = "${ctrc.cliente.substituicaoTributariaMinasGerais}";
                                    ctrc.consignatario.obrigaTabelaTipoProduto = "${ctrc.cliente.tabelaTipoProduto}";
                                    ctrc.consignatario.utilizaPautaFiscal = "${ctrc.cliente.utilizaPautaFiscal}";
                                    ctrc.consignatario.tipoOrigemFrete = "${ctrc.cliente.tipoOrigemFrete}";
                                    ctrc.consignatario.tipoTabela = "${ctrc.cliente.tipo_tabela}";
                                    ctrc.consignatario.stIcms = "${ctrc.cliente.stIcms.id}";
                                    ctrc.consignatario.obs = "${ctrc.cliente.observacao}";
                                    ctrc.consignatario.tipoPgto = "${ctrc.cliente.tipoPagtoFrete}";
                                    ctrc.consignatario.qtdDiasPgto = "${ctrc.cliente.condicaoPgt}";
                                    ctrc.consignatario.percComissaoVendedor = "${ctrc.cliente.vlcomissaoVendedor}";
                                    ctrc.consignatario.unificadaModalVendedor = "${ctrc.cliente.tipoComissaoVendedor}";
                                    ctrc.consignatario.percComissaoRodoviarioFracionadoVendedor = "${ctrc.cliente.comissaoRodoviarioFracionadoVendedor}";
                                    ctrc.consignatario.percComissaoRodoviarioLotacaoVendedor = "${ctrc.cliente.comissaoRodoviarioLotacaoVendedor}";

                                    ctrc.consignatario.vendedor.razaoSocial = "${ctrc.cliente.vendedor.razaosocial}";
                                    ctrc.consignatario.vendedor.id = "${ctrc.cliente.vendedor.id}";
                                    ctrc.consignatario.percComissaoVendedor = "${ctrc.cliente.vlcomissaoVendedor}";
                                    //remetente
                                    ctrc.remetente.id = "${ctrc.remetente.idcliente}";
                                    ctrc.remetente.razaoSocial = "${ctrc.remetente.razaosocial}";
                                    ctrc.remetente.cnpj = "${ctrc.remetente.cnpj}";
                                    ctrc.remetente.cidadeId = "${ctrc.remetente.cidade.idcidade}";
                                    ctrc.remetente.cidade = "${ctrc.remetente.cidade.descricaoCidade}";
                                    ctrc.remetente.endereco = "${ctrc.remetente.endereco}";

                                    ctrc.remetente.bairro = "${ctrc.remetente.bairro}";
                                    ctrc.remetente.complemento = "${ctrc.remetente.complemento}";
                                    ctrc.remetente.logradouro = "${ctrc.remetente.numeroLogradouro}";

                                    ctrc.remetente.uf = "${ctrc.remetente.cidade.uf}";
                                    ctrc.idCidadeOrigem = "${ctrc.remetente.cidade.idcidade}";
                                    ctrc.cidadeOrigem = "${ctrc.remetente.cidade.descricaoCidade}";
                                    ctrc.ufOrigem = "${ctrc.remetente.cidade.uf}";
                                    ctrc.remetente.tipoCfop = "${ctrc.remetente.tipoCfop}";
                                    ctrc.remetente.inscEst = "${ctrc.remetente.inscest}";
                                    ctrc.remetente.isStMG = "${ctrc.remetente.substituicaoTributariaMinasGerais}";
                                    ctrc.remetente.isCreditoBloqueado = "${ctrc.remetente.creditoBloqueado}";
                                    ctrc.remetente.isAnaliseCredito = "${ctrc.remetente.analiseCredito}";
                                    ctrc.remetente.creditoDisponivel = "${ctrc.remetente.creditoDisponivel}";
                                    ctrc.remetente.obrigaTabelaTipoProduto = "${ctrc.remetente.tabelaTipoProduto}";
                                    ctrc.remetente.incluiPesoContainer = "${ctrc.remetente.incluiContainerFretePeso}";
                                    ctrc.remetente.percComissaoVendedor = "${ctrc.remetente.vlcomissaoVendedor}";
                                    ctrc.remetente.unificadaModalVendedor = "${ctrc.remetente.tipoComissaoVendedor}";
                                    ctrc.remetente.percComissaoRodoviarioFracionadoVendedor = "${ctrc.remetente.comissaoRodoviarioFracionadoVendedor}";
                                    ctrc.remetente.percComissaoRodoviarioLotacaoVendedor = "${ctrc.remetente.comissaoRodoviarioLotacaoVendedor}";

                                    ctrc.remetente.utilizaPautaFiscal = "${ctrc.remetente.utilizaPautaFiscal}";
                                    ctrc.remetente.tipoOrigemFrete = "${ctrc.remetente.tipoOrigemFrete}";
                                    ctrc.remetente.tipoTabela = "${ctrc.remetente.tipo_tabela}";
                                    ctrc.remetente.stIcms = "${ctrc.remetente.stIcms.id}";
                                    ctrc.remetente.obs = "${ctrc.remetente.observacao}";
                                    ctrc.remetente.tipoPgto = "${ctrc.remetente.tipoPagtoFrete}";
                                    ctrc.remetente.qtdDiasPgto = "${ctrc.remetente.condicaoPgt}";
                                    ctrc.tipoProduto = "${ctrc.tipoProduto.id}";
                                    ctrc.remetente.utilizarTabelaRemetente = "${ctrc.remetente.utilizaTabelaRemetente}";
                                    ctrc.remetente.vendedor.razaoSocial = "${ctrc.remetente.vendedor.razaosocial}";
                                    ctrc.remetente.vendedor.id = "${ctrc.remetente.vendedor.id}";
                                    ctrc.remetente.percComissaoVendedor = "${ctrc.remetente.vlcomissaoVendedor}";
                                    ctrc.remetente.tipoDocumentoPadrao = "${ctrc.remetente.tipoDocumentoPadrao}";
                                    ctrc.remetente.isFreteDirigido = "${ctrc.remetente.freteDirigido}";

                                    //destinatario                    

                                    ctrc.destinatario.razaoSocial = "${ctrc.destinatario.razaosocial}";
                                    ctrc.destinatario.id = "${ctrc.destinatario.idcliente}";
                                    ctrc.destinatario.cnpj = "${ctrc.destinatario.cnpj}";
                                    ctrc.destinatario.reducaoIcms = "${ctrc.destinatario.reducaoIcms}";
                                    ctrc.destinatario.isIncluirTde = "${ctrc.destinatario.cobrarTde}";
                                    ctrc.destinatario.inscEst = "${ctrc.destinatario.inscest}";
                                    ctrc.destinatario.isStMG = "${ctrc.destinatario.substituicaoTributariaMinasGerais}";
                                    ctrc.destinatario.isCreditoBloqueado = "${ctrc.destinatario.creditoBloqueado}";
                                    ctrc.destinatario.isAnaliseCredito = "${ctrc.destinatario.analiseCredito}";
                                    ctrc.destinatario.creditoDisponivel = "${ctrc.destinatario.creditoDisponivel}";
                                    ctrc.destinatario.obs = "${ctrc.destinatario.observacao}";
                                    ctrc.destinatario.tipoOrigemFrete = "${ctrc.destinatario.tipoOrigemFrete}";
                                    ctrc.destinatario.cidadeId = "${ctrc.destinatario.cidade.idcidade}";
                                    ctrc.destinatario.cidade = "${ctrc.destinatario.cidade.descricaoCidade}";
                                    ctrc.destinatario.uf = "${ctrc.destinatario.cidade.uf}";
                                    ctrc.destinatario.endereco = "${ctrc.destinatario.endereco}";

                                    ctrc.destinatario.bairro = "${ctrc.destinatario.bairro}";
                                    ctrc.destinatario.complemento = "${ctrc.destinatario.complemento}";
                                    ctrc.destinatario.logradouro = "${ctrc.destinatario.numeroLogradouro}";

                                    ctrc.destinatario.stIcms = "${ctrc.destinatario.stIcms.id}";
                                    ctrc.destinatario.tipoPgto = "${ctrc.destinatario.tipoPagtoFrete}";
                                    ctrc.destinatario.qtdDiasPgto = "${ctrc.destinatario.condicaoPgt}";
                                    ctrc.destinatario.incluiPesoContainer = "${ctrc.destinatario.incluiContainerFretePeso}";
                                    ctrc.idCidadeDestino = "${ctrc.destinatario.cidade.idcidade}";
                                    ctrc.cidadeDestino = "${ctrc.destinatario.cidade.descricaoCidade}";
                                    ctrc.ufDestino = "${ctrc.destinatario.cidade.uf}";
                                    ctrc.destinatario.tipoTabela = "${ctrc.destinatario.tipo_tabela}";            
                                    ctrc.destinatario.utilizaPautaFiscal = "${ctrc.destinatario.utilizaPautaFiscal}";
                                    ctrc.destinatario.obrigaTabelaTipoProduto = "${ctrc.destinatario.tabelaTipoProduto}";
                                    ctrc.destinatario.tipoCfop = "${ctrc.destinatario.tipoCfop}";
                                    ctrc.destinatario.utilizarTabelaRemetente = "${ctrc.destinatario.utilizaTabelaRemetente}";
                                    ctrc.destinatario.percComissaoVendedor = "${ctrc.destinatario.vlcomissaoVendedor}";
                                    ctrc.destinatario.unificadaModalVendedor = "${ctrc.destinatario.tipoComissaoVendedor}";
                                    ctrc.destinatario.percComissaoRodoviarioFracionadoVendedor = "${ctrc.destinatario.comissaoRodoviarioFracionadoVendedor}";
                                    ctrc.destinatario.percComissaoRodoviarioLotacaoVendedor = "${ctrc.destinatario.comissaoRodoviarioLotacaoVendedor}";
                                    ctrc.destinatario.vendedor.razaoSocial = "${ctrc.destinatario.vendedor.razaosocial}";
                                    ctrc.destinatario.vendedor.id = "${ctrc.destinatario.vendedor.id}";
                                    ctrc.destinatario.percComissaoVendedor = "${ctrc.destinatario.vlcomissaoVendedor}";
                                    //cidade de origem
                                    ctrc.cidadeOrigem = "${ctrc.cidadeOrigem.descricaoCidade}";
                                    ctrc.ufOrigem = "${ctrc.cidadeOrigem.uf}";
                                    ctrc.idCidadeOrigem = "${ctrc.cidadeOrigem.idcidade}";
                                    //cidade de destino
                                    ctrc.cidadeDestino = "${ctrc.cidadeDestino.descricaoCidade}";
                                    ctrc.ufDestino = "${ctrc.cidadeDestino.uf}";
                                    ctrc.idCidadeDestino = "${ctrc.cidadeDestino.idcidade}";            
                                    
                                    ctrc.modFrete= "${ctrc.modalidadeFrete}";
                                    ctrc.enderecoEntregaId = "${ctrc.enderecoEntrega.id}";

                                    //redespacho
                                    ctrc.redespacho.razaoSocial = "${ctrc.redespacho.razaosocial}";            
                                    ctrc.redespacho.id = "${ctrc.redespacho.idcliente}";
                                    ctrc.redespacho.cnpj = "${ctrc.redespacho.cnpj}";
                                    ctrc.redespacho.cidadeId = "${ctrc.redespacho.cidade.idcidade}";
                                    ctrc.redespacho.cidade = "${ctrc.redespacho.cidade.descricaoCidade}";
                                    ctrc.redespacho.uf = "${ctrc.redespacho.cidade.uf}";
                                    ctrc.redespacho.tipoPgto = "${ctrc.redespacho.tipoPagtoFrete}";
                                    ctrc.redespacho.qtdDiasPgto = "${ctrc.redespacho.condicaoPgt}";
                                    ctrc.redespacho.tipoCfop = "${ctrc.redespacho.tipoCfop}";
                                    ctrc.redespacho.inscEst = "${ctrc.redespacho.inscest}";
                                    ctrc.redespacho.isStMG = "${ctrc.redespacho.substituicaoTributariaMinasGerais}";
                                    ctrc.redespacho.isCreditoBloqueado = "${ctrc.redespacho.creditoBloqueado}";
                                    ctrc.redespacho.isAnaliseCredito = "${ctrc.redespacho.analiseCredito}";
                                    ctrc.redespacho.creditoDisponivel = "${ctrc.redespacho.creditoDisponivel}";
                                    ctrc.redespacho.obrigaTabelaTipoProduto = "${ctrc.redespacho.tabelaTipoProduto}";
                                    ctrc.redespacho.utilizaPautaFiscal = "${ctrc.redespacho.utilizaPautaFiscal}";
                                    ctrc.redespacho.tipoOrigemFrete = "${ctrc.redespacho.tipoOrigemFrete}";            
                                    ctrc.redespacho.tipoTabela = "${ctrc.redespacho.tipo_tabela}"; 
                                    ctrc.redespacho.utilizarTabelaRemetente = "${ctrc.redespacho.utilizaTabelaRemetente}";
                                    ctrc.redespacho.unificadaModalVendedor = "${ctrc.redespacho.tipoComissaoVendedor}";
                                    ctrc.redespacho.percComissaoRodoviarioFracionadoVendedor = "${ctrc.redespacho.comissaoRodoviarioFracionadoVendedor}";
                                    ctrc.redespacho.percComissaoRodoviarioLotacaoVendedor = "${ctrc.redespacho.comissaoRodoviarioLotacaoVendedor}";

                                    ctrc.redespacho.vendedor.razaoSocial = "${ctrc.redespacho.vendedor.razaosocial}";
                                    ctrc.redespacho.vendedor.id = "${ctrc.redespacho.vendedor.id}";
                                    ctrc.redespacho.percComissaoVendedor = "${ctrc.redespacho.vlcomissaoVendedor}";

                                    ctrc.redespachoCtrc = "${ctrc.redespachoCtrc}";
                                    ctrc.redespachoValor = "${ctrc.redespachoValor}";
                                    ctrc.redespachoValorIcms = "${ctrc.redespachoValorIcms}";
                                    ctrc.redespachoChaveAcesso = "${ctrc.redespachoChaveAcesso}";

                                    //representante
                                    ctrc.representante.razaoSocial = "${ctrc.redespachante.razaosocial}";            
                                    ctrc.representante.id = "${ctrc.redespachante.id}";
                                    ctrc.representante.cnpj = "${ctrc.redespachante.cpfCnpj}";

                                    ctrc.veiculo = "${ctrc.veiculo.placa}";
                                    ctrc.idVeiculo = "${ctrc.veiculo.idveiculo}";
                                    ctrc.motorista = "${ctrc.motorista.nome}";
                                    ctrc.idMotorista = "${ctrc.motorista.idmotorista}";
                                    ctrc.carreta = "${ctrc.carreta.placa}";
                                    ctrc.idCarreta = "${ctrc.carreta.idveiculo}";
                                    ctrc.bitrem = "${ctrc.biTrem.placa}";
                                    ctrc.idBitrem = "${ctrc.biTrem.idveiculo}";
                                    
                                    ctrc.listaNotas = new Array();
                                    
                                    <c:forEach var="nota" varStatus="status" items="${ctrc.notas}">
                                        apoioNotas++;
                                        nf = new NotaFiscal();
                                        nf.numero = "${nota.numero}";
                                        nf.serie = "${nota.serie}";
                                        nf.dataEmissao = "${nota.emissaoStr}";
                                        nf.peso = "${nota.peso}";
                                        nf.valor = "${nota.valor}";
                                        nf.volume = "${nota.volume}";
                                        nf.cfop = "${nota.cfop.cfop}";
                                        nf.cfopId = "${nota.cfop.idcfop}";
                                        nf.chaveNFe = "${nota.chaveNFe}";
                                        nf.destinatario = "${ctrc.destinatario.razaosocial}";
                                        nf.destinatarioId = "${ctrc.destinatario.idcliente}";
                                        nf.baseCalculoIcm = "${nota.vl_base_icms}";
                                        nf.icmsValor  = "${nota.vl_icms}";
                                        nf.pedido= "${nota.pedido}";
                                        nf.isExiste = ("${nota.existe}" == "true");
                                        nf.conteudo = "${nota.conteudo}";
                                        nf.embalagem = "${nota.embalagem}";
                                        nf.observacao = "${nota.observacaoAgenda}";
                                        nf.dataAgenda = "${nota.dataAgendaStr}";
                                        nf.horaAgenda = "${nota.horaAgenda}";
                                        nf.dataPrevisao = "${nota.previsaoEmStr}";
                                        nf.horaPrevisao = "${nota.previsaoAs}";
                                        nf.metroCubico = "${nota.metroCubico}";
                                        nf.tipoDocumento = (nf.chaveNFe == "" ? "NF": "NE");
                                        
                                        nf.adValorem = "${nota.adValorem}";
                                        nf.valorSeguro = "${nota.valorSeguro}";
                                        nf.valorFretePeso = "${nota.valorFretePeso}";
                                        nf.valorTotalTaxas = "${nota.valorTotalTaxas}";
                                        nf.valorGris = "${nota.valorGris}";
                                        nf.valorPedagio = "${nota.valorPedagio}";

                                        listaCubagens = new Array();
                                        indexCubagem = 0;
                                        <c:forEach var="cubagem" varStatus="status" items="${nota.cubagens}">
                                            <c:if test="${cubagem != null}">                                                
                                                cubagem = new Cubabem();
                                                cubagem.volume = "${cubagem.volume}";
                                                cubagem.altura = "${cubagem.altura}";
                                                cubagem.comprimento = "${cubagem.comprimento}";
                                                cubagem.largura = "${cubagem.largura}";
                                                cubagem.existe = "${cubagem.existe}";
                                                listaCubagens[indexCubagem++] = cubagem;
                                            </c:if>

                                        </c:forEach>
                                            nf.listaCuabagem = listaCubagens;
                                            ctrc.listaNotas[idxNota++] = nf;
                                            listaMercadoria = new Array();
                                            indexMerc = 0;

                                            <c:forEach var="merc" varStatus="status" items="${nota.mercadorias}">
                                                merc = new Mercadoria();                    
                                                merc.quantidade = ${merc.quantidade};
                                                merc.valorUnitario = ${merc.valor};
                                                merc.produto = "${merc.produto.descricao}";
                                                merc.produtoId = ${merc.produto.id};                    
                                                listaMercadoria[indexMerc++] = merc;
                                            </c:forEach>
                                        nf.listaMercadoria = listaMercadoria;                                        
                                    </c:forEach>
                                    addCtrcRetornado(ctrc);
                                        
                                </c:forEach>                                                                    
                            }catch(ex){
                                if (!isIE()) {
                                    console.log(ex);
                                    console.trace();
                                    console.log("ERRO AO CARREGAR AS INFORMAÇOES:"+ex);
                                }
                                console.log(ex);
                                alert(ex);
                            }
                        }
                    }
                }
                
                function addCtrcRetornado(ctrc){
                    addConhecimentoLote(ctrc, $("tabConhecimento"), $("maxConhecimento"), $("serie"),$('alteraprecocte').value,$('alterainffiscal').value,$('permissao_alteratipofretecte').value,$("embutirICMS").checked,$("embutirPISCOFINS").checked,$('slTipoProduto').value,$('slTipoVeiculo').value,$('obsPadrao').value);
                    
                    if (ctrc.listaNotas != null && ctrc.listaNotas != undefined && ctrc.listaNotas.size() != 0) {
                        for (var i = 0; i <= ctrc.listaNotas.size(); i++) {
                            if (ctrc.listaNotas[i]) {
                    
                            }
                        }
                    }
                    
                    if (parseFloat(colocarPonto($('cubagemMetroTotalNF_' + ctrc.index).value)) == 0 && parseFloat(ctrc.cubagemMetro) > 0){
                        $('cubagemMetroTotalNF_' + ctrc.index).value = colocarVirgula(arredondar(ctrc.cubagemMetro,2));
                        $('cubagemLarguraTotalNF_' + ctrc.index).value = '1';
                        $('cubagemAlturaTotalNF_' + ctrc.index).value = '1';
                        $('cubagemComprimentoTotalNF_' + ctrc.index).value = '1';
                        $('cubagemMetroTotalCF_' + ctrc.index).value = colocarVirgula(arredondar(ctrc.cubagemMetro,2));
                        $('cubagemLarguraTotalCF_' + ctrc.index).value = '1';
                        $('cubagemAlturaTotalCF_' + ctrc.index).value = '1';
                        $('cubagemComprimentoTotalCF_' + ctrc.index).value = '1';
                    }
                    alterarTipoPagamento(ctrc.index);
                    atribuirCfopPadrao(ctrc.index);
                    definirAliquotaIcmsCtrc(ctrc.index, false);
                    getPautaFiscal(ctrc.index);
                    alteraTipoTaxa("S", ctrc.index);
                    //Como no inicio ainda não foi pego da tabela de preço a base da cubagem, é necessario ir uma segunda vez
                    //                            alteraTipoTaxa("S", ctrc.index);
                    setTimeout("alteraTipoTaxa(\"S\", "+ctrc.index+");", 5000);            
                }
                
                
                function limparMotorista(){
                    $("motorista_nome").value= "";
                    $("idmotoristaPrincipal").value = "0";
                }
                
                function limparVeiculo(){
                    $("veiculo_placa").value= "";
                    $("idveiculoPrincipal").value = "0";
                    validarTipoVeiculo('v');
                }
                
                function limparCarreta(){
                    $("carreta_placa").value= "";
                    $("idcarretaPrincipal").value = "0";
                    validarTipoVeiculo('c');
                }
                
                function limparBitrem(){
                    $("bitrem_placa").value= "";
                    $("idbitremPrincipal").value = "0";
                }
                
                function removerCtrcsCadastrados(indices){
                    try {
                        indices += "";
                        for (var i = 0; i <= indices.split(",").length; i++) {
                            if ($("tbodyContainer_" + indices.split(",")[i]) != null && $("tbodyContainer_" + indices.split(",")[i]) != undefined) {
                                Element.remove($("tbodyContainer_" + indices.split(",")[i]));
                            }
                        }
                        if ($("containerForms") != null && $("containerForms") != undefined) {
                            Element.remove($("containerForms"));
                        }
                        
                        if ("${configuracao.cartaFreteAutomatica}"== "true"  && ($("chk_carta_automatica").checked || $("chk_adv_automatica").checked)) {
                            document.formContratoFreteViagem.reset();
                        }
                        
                        unSetEnv("botSalvar", "Salvar");
                    } catch (e) {
                        console.log(e);
                    }
                }
                
                //-----------------  FIM  -------------------------------------
                
                function alterarTipoTranporte(){
                    if ($("tipoTransporte").value == "a") {
                        $("serie").value = $("filial").value.split("@@")[7];
                    }else if ($("tipoTransporte").value == "q") {
                        $("serie").value = $("filial").value.split("@@")[8];    
                    }else if ($("tipoTransporte").value == "r") {
                        $("serie").value = $("filial").value.split("@@")[9];    
                    }
                }
                
                function limparLocalizaColeta(){
                    $('idcoleta').value = '0';
                    $('numcoleta').value = '';
                }
                
                function abrirLocalizaColeta(){
//                    &paramaux='+$('idremetente').value
                    launchPopupLocate('./localiza?acao=consultar&idlista=22','Coleta');
                }
                
    function validarCidadeOrigemExpedidor(index){
        var cidExped = $("expedidorCidade_"+index).value;
        var idCidExped = $("expedidorCidadeId_"+index).value;
        var ufExped = $("expedidorUF_"+index).value;
        var cidOrig = $("cidadeOrigemLocais_"+index).value;
        var ufOrig = $("ufOrigemLocais_"+index).value;
        setTimeout(function(){
            if(cidExped != cidOrig || ufExped != ufOrig){
               if(confirm("A cidade do expedidor ("+cidExped+"/"+ufExped+") é diferente da cidade de origem ("+cidOrig+"/"+ufOrig+"). Deseja atualizar a cidade de origem do CT-e?")){
                   $("cidadeOrigemLocais_"+index).value = cidExped;
                   $("ufOrigemLocais_"+index).value = ufExped;
                   $("cidadeOrigemIdLocais_"+index).value = idCidExped;
                        definirAliquotaIcmsCtrc(index, false);
                        getPautaFiscal(index);
                        alteraTipoTaxa("N", index);
                        definirICMSCTe(index);
                } 
            }
        },100);   
    }     
    function validarCidadeDestinoRecebedor(index){
        var cidReceb = $("recebedorCidade_"+index).value;
        var ufReceb = $("recebedorUF_"+index).value;
        var idCidReceb = $("recebedorCidadeId_"+index).value;
        var cidDest = $("cidadeDestinoLocais_"+index).value;
        var ufDest = $("ufDestinoLocais_"+index).value;
        setTimeout(function(){
            if(cidReceb != cidDest || ufReceb != ufDest){
               if(confirm("A cidade do recebedor ("+cidReceb+"/"+ufReceb+") é diferente da cidade de destino ("+cidDest+"/"+ufDest+"). Deseja atualizar a cidade de destino do CT-e?")){
                   $("cidadeDestinoLocais_"+index).value = cidReceb;
                   $("ufDestinoLocais_"+index).value = ufReceb;
                   $("cidadeDestinoIdLocais_"+index).value = idCidReceb;
                        definirAliquotaIcmsCtrc(index, false);
                        getPautaFiscal(index);
                        alteraTipoTaxa("N", index);
                        definirICMSCTe(index);
                } 
            }
        },100);   
    }
    
    function padronizarCfops(){
        var maxCount = $("maxConhecimento").value;
        var co = 0;
        for(co = 1; co<= maxCount; co++){
            atribuirCfopPadrao(co);
        }
    }
    
    function validarBloqueioVeiculo(filtro){
            if($("is_bloqueado").value == "t" && filtro == "Veiculo"){
                        setTimeout(function(){
                        alert("O veículo " + $("veiculo_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        limparVeiculo();
                        },100);
            }
            if($("is_bloqueado").value == "t" && filtro == "Carreta"){
                        setTimeout(function(){
                        alert("A carreta " + $("carreta_placa").value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        limparCarreta();
                        },100);
            }
            if($("is_bloqueado").value == "t" && filtro == "Bitrem"){
                        setTimeout(function(){
                        alert("O Bi-trem " + $("bitrem_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        limparBitrem();
                        },100);
            }
        }        

    function validarBloqueioVeiculoOutros(filtro,index){
            if($("is_bloqueado").value == "t" && filtro == "Veiculo"){
                        setTimeout(function(){
                        alert("O veículo " + $("veiculo_Outros_"+index).value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("veiculoId_Outros_"+index).value = "0";
                        $("veiculo_Outros_"+index).value = "";
                        },100);
            }
            if($("is_bloqueado").value == "t" && filtro == "Carreta"){
                        setTimeout(function(){
                        alert("A carreta " + $("carreta_Outros_"+index).value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("carretaId_Outros_"+index).value = "0";
                        $("carreta_Outros_"+index).value = "";
                        },100);
            }
            if($("is_bloqueado").value == "t" && filtro == "Bitrem"){
                        setTimeout(function(){
                        alert("O Bi-trem " + $("bitrem_Outros_"+index).value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("bitremId_Outros_"+index).value = "0";
                        $("bitrem_Outros_"+index).value = "";
                        },100);
            }
        }       

    function validarBloqueioVeiculoMotorista(filtrosM){
        var filtros = filtrosM;
        for(var i = 0; i<= filtros.split(",").length ; i++){
        if($("is_moto_veiculo_bloq").value == "t" && filtros.split(",")[i] == "veiculo_motorista"){
            setTimeout(function (){
                   alert("O veiculo " + $("vei_placa").value + ", vinculado ao motorista " +$("motorista_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
                   $("idveiculoPrincipal").value = "0";
                   $("veiculo_placa").value = "";
            },100);
        }else if($("is_moto_carreta_bloq").value == "t" && filtros.split(",")[i] == "carreta_motorista"){
                setTimeout(function (){
                    alert("A carreta " + $("carreta_placa").value + ", vinculada ao motorista " +$("motorista_nome").value+ ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                    $("idcarretaPrincipal").value = "0";
                    $("carreta_placa").value = "";
                 
                },100);
        }else if($("is_moto_bitrem_bloq").value == "t" && filtros.split(",")[i] == "bitrem_motorista"){
                setTimeout(function (){
                    alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
                    $("idbitremPrincipal").value = "0";
                    $("bitrem_placa").value = "";
                 
                },100);
            }
        }
    }
    function validarBloqueioVeiculoMotoristaOutros(filtrosM,index){
        var filtros = filtrosM;
        for(var i = 0; i<= filtros.split(",").length ; i++){
            var filtro = filtros.split(",")[i];
        if($("is_moto_veiculo_bloq").value == "t" && filtro == "veiculo_motorista"){
            setTimeout(function (){
                   alert("O veiculo " + $("veiculo_Outros_"+index).value + ", vinculado ao motorista " +$("motorista_Outros_"+index).value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
                   $("veiculoId_Outros_"+index).value = "0";
                   $("veiculo_Outros_"+index).value = "";
            },100);
        }else if($("is_moto_carreta_bloq").value == "t" && filtro == "carreta_motorista"){
                setTimeout(function (){
                    alert("A carreta " + $("carreta_Outros_"+index).value + ", vinculada ao motorista " +$("motorista_Outros_"+index).value+ ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                    $("carretaId_Outros_"+index).value = "0";
                    $("carreta_Outros_"+index).value = "";
                 
                },100);
        }else if($("is_moto_bitrem_bloq").value == "t" && filtro == "bitrem_motorista"){
                setTimeout(function (){
                    alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
                    $("bitremId_Outros_"+index).value = "0";
                    $("bitrem_Outros_"+index).value = "";
                 
                },100);
            }
        }
    }
    
    function montarDivChaves(index){
        var promp = document.createElement("DIV");
        promp.id = 'promptRedChave';
        document.body.appendChild(promp);
        var heightDoc = $a(window).scrollTop()+200;
        var widthDoc = $a('html').width();
        var widthDiv = $a('promptRedChave').width();
        var heigthDiv = $a('promptRedChave').height();
        var obj = document.getElementById('promptRedChave').style;
        
        var leftDiv = parseFloat(widthDoc) *0.5;
        var topDiv = parseFloat(heightDoc);
        var marginLeft = widthDiv/2 * -1;
        var marginTop = heigthDiv/2 * -1;
        
        
        obj.width = '22%';
        obj.left = leftDiv+'px';
        obj.top = topDiv+'px';
        obj.zIndex = '10';
        obj.position = 'absolute';
        obj.backgroundColor = '#FFFFFF';
        
        $a("promptRedChave").css({'margin-left':marginLeft});
        $a("promptRedChave").css({'margin-top':marginTop});
        montarDivChaveAcessoLote(index);
        
    }
    
function calcularFormulaTaxas(taxas){
      var lista = taxas;
      var totalMercadorias = 0;
      var totalPesos = 0;
      var totalBaseCubado = 0;
      var totalMetroCubado = 0;
      var totalPallets = 0;
      var totalVolume = 0; 
      var totalEntregas = 0; 
      var totalRedespacho = 0;
      var max = parseInt($("maxConhecimento").value);
      for(var i = 1; i<= max ; i++){
          if($("chkSave_"+i) != null && $("chkSave_"+i).checked){
             totalMercadorias+= parseFloat(colocarPonto($("valorMercadoriaTotalNF_"+i).value));
             totalVolume+= parseFloat(colocarPonto($("valorVolumeTotalNF_"+i).value));
             totalPesos+= parseFloat(colocarPonto($("valorPesoTotalNF_"+i).value));
             totalBaseCubado+= parseFloat(colocarPonto($("cubagemBaseTotalNF_"+i).value));
             totalMetroCubado+= parseFloat(colocarPonto($("cubagemMetroTotalNF_"+i).value));
             totalPallets+= parseFloat(colocarPonto($("qtdPalletsTabela_"+i).value));
             totalEntregas+= parseFloat(colocarPonto($("qtdEntregasTabela_"+i).value));
             totalRedespacho+= parseFloat(colocarPonto($("redespachoValor_"+i).value));            
          }
      }
      
      $("valorOutros").value = colocarVirgula(parseFloat(getOutros(lista.valor_outros, lista.formula_outros, 3, totalPesos, totalMercadorias, totalVolume,totalPallets,
      0, $('slTipoVeiculo').value,lista.is_considerar_maior_peso,totalBaseCubado,totalMetroCubado,
      totalEntregas,$('tipoTransporte').value, lista.tipo_inclusao_icms, ($("aliquotaIcms_1") != null || $("aliquotaIcms_1") != undefined ? $("aliquotaIcms_1").value : '0'),$("tipo_arredondamento_peso_rateio").value)));   
      
      $("valorTotalTaxaFixa").value = colocarVirgula(parseFloat(getTaxaFixa(lista.valor_taxa_fixa, lista.formula_taxa_fixa, 3, totalPesos, totalMercadorias, totalVolume, totalPallets, 0,  
      $('slTipoVeiculo').value,lista.is_considerar_maior_peso,totalBaseCubado,totalMetroCubado,totalEntregas,$('tipoTransporte').value,lista.peso_limite_taxa_fixa, 
      lista.valor_excedente_taxa_fixa, lista.tipo_inclusao_icms, ($("aliquotaIcms_1") != null || $("aliquotaIcms_1") != undefined ? $("aliquotaIcms_1").value : '0'),$("tipo_arredondamento_peso_rateio").value)));
      
      $("valorFrete").value = colocarVirgula(parseFloat(getFretePeso(totalPesos,totalVolume,3,lista.valor_peso,lista.valor_volume,totalBaseCubado,totalMetroCubado,lista.valor_veiculo,lista.valor_por_faixa,
      $("tipoTransporte").value,lista.valor_excedente_aereo ,lista.valor_excedente,lista.maximo_peso_final,lista.ispreco_tonelada,lista.tipo_frete_peso,
      lista.valor_maximo_peso_final,lista.valor_km,lista.is_considerar_maior_peso,lista.tipo_impressao_percentual,totalMercadorias,lista.base_nf_percentual,
      lista.valor_percentual_nf,lista.percentual_nf,totalPallets,0,lista.formula_volumes, $('slTipoVeiculo').value,
      lista.formula_percentual,lista.valor_pallet,lista.formula_pallet,($("isRedespacho_1") != null || $("isRedespacho_1") != undefined ? $("isRedespacho_1").checked : false),totalRedespacho,totalEntregas,
      lista.formula_frete_peso,lista.tipo_inclusao_icms, ($("aliquotaIcms_1") != null || $("aliquotaIcms_1") != undefined ? $("aliquotaIcms_1").value : '0'),parseFloat(colocarPonto($("valorFrete").value)) == 0.00 ? false : true, $("tipo_arredondamento_peso_rateio").value)));
      
      $("valorAdvalorem").value = lista.formula_seguro === "" || lista.formula_seguro === undefined ? lista.percentual_advalorem : '0.00';
    }

    function calcularAdValorem(valor) {
                var vSplit = valor.value;
                var valorSplit = vSplit.split(",")[0];
                var valorDecimal = vSplit.split(",")[1];

                if (valorSplit < 0 || valorSplit > 9) {
                    alert("O valor do Seguro (AdValorEm) precisa ser entre 0 a 9.99 ");
                    $("valorAdvalorem").value = "0.00";
                } else if (valorSplit >= 0 || valorSplit <= 9) {
                    if ( valorDecimal != undefined && valorDecimal.length > 2) {
                        alert("A quantidade das casas decimais não podem ser maior que 2 ");
                        $("valorAdvalorem").value = "0.00";
                    }
                }
            }
    function getTipoProdutos(){
    var tipoAtual = $('slTipoProduto').value;
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);//se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao carregar os tipos de produtos.');
                return false;
            }
            else{
                
                var tipoProd = document.getElementById("tdTipoProd");
                var selectTipo = "<select name='slTipoProduto' id='slTipoProduto' class='fieldMin'>";
                tipoProd.innerHTML = selectTipo+resp+"</select>";
                $('slTipoProduto').value = tipoAtual;
                if ($('slTipoProduto').value == ''){$('slTipoProduto').value = '0';}
            }
        }//funcao e()
        if ($('hiddenConsignatarioRateio').value != ''){
            var idClienteTipoProduto = 0;
            if ($('contabelaproduto').value == 't' || $('contabelaproduto').value == 'true'){idClienteTipoProduto = $('hiddenConsignatarioRateio').value;}
            espereEnviar("",true);
            tryRequestToServer(function(){new Ajax.Request("./cadtipoproduto.jsp?acao=carregaTipos&cliente="+idClienteTipoProduto,{method:'post', onSuccess: e, onError: e});});
        }
}
    
        function alterarAdiantamento() {
        try{
                var vlLiquido = parseFloat(colocarPonto($("cartaLiquido").value));
                var vlAdiantamento = getTotAdiantamento();
                var vlCC = parseFloat(colocarPonto($('cartaValorCC').value == "" ? "0,00" : $('cartaValorCC').value));
                var vlSaldo = vlLiquido - vlAdiantamento - vlCC;
                var qtdSaldos = 0;

                for (let i = 1; i <= countPgto; i++) {
                    
                    if ($("idPgto_" + i) != null && $("tipoPagto_" + i).value == "s") {
                        qtdSaldos++;
                    }
                }
                if (qtdSaldos === 1) {
                    for (let i = 1; i <= countPgto; i++) {
                        if ($("idPgto_" + i) != null && $("tipoPagto_" + i).value == "s") {
                            if($("valorPgto_" + i).disabled == false){
                                $("valorPgto_" + i).value = colocarVirgula(vlSaldo / qtdSaldos, 2);
                            }
                        }
                    }
                }
        }catch (e){
            console.log(e);
            console.error(e);
        }
    }
    
        function abrirLocalizaNatureza() {
            launchPopupLocate('./localiza?acao=consultar&idlista=64&fecharJanela=true', 'Natureza')
        }
        </script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Importar Conhecimento em Lote</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {color: #BB0000}
            .style2 {color: #0000FF}
            .style3 {
                color: red;
                font-size: x-small;
            }
            .style4 {
                color: red;
                font-size: x-small;
            }
            .styleNum {text-align: right}
            -->
        </style>
    </head>

    <body onLoad="setDefault();applyFormatter();mostrarValorRateio();" id="corpo">
        <div id="promptRedChave" name="promptRedChave"></div>
        <div id="bloquearTelaToda" name="bloquearTelaToda" style="display: none"></div>
        <input type="hidden" id="fontePreco" value ="t"/>
        <input type="hidden" id="indexAux" value="0">
        <input type="hidden" name="obs_desc" id="obs_desc" value="">        
        <input type="hidden" id="agente" value="0"  /> 
        <input type="hidden" id="idagente"  /> 
        <input type="hidden" id="taxa_roubo" value="0"  /> 
        <input type="hidden" id="taxa_roubo_urbano" value="0"  /> 
        <input type="hidden" id="taxa_tombamento" value="0"  /> 
        <input type="hidden" id="taxa_tombamento_urbano" value="0"  /> 
        <input type="hidden" id="bloqueado" value="f"  /> 
        <input type="hidden" id="motivobloqueio" value=""  /> 
        <input type="hidden" id="tipo" value=""  /> 
        <input type="hidden" id="id_rota_viagem" value=""  /> 
        <input type="hidden" id="rota_viagem" value=""  /> 
        <input type="hidden" id="distancia_km" value=""  /> 
        <input type="hidden" id="endereco_entrega_id" value=""  /> 
        <input type="hidden" id="endereco_coleta_id" value=""  /> 
        <!--remetente-->
        <input type="hidden" name="idremetente" id="idremetente" value="0">
        <input type="hidden" name="rem_rzs" id="rem_rzs" value="0">
        <input type="hidden" name="rem_cnpj" id="rem_cnpj" value="0">
        <input type="hidden" name="rem_insc_est" id="rem_insc_est" value="0">
        <input type="hidden" name="rem_cidade" id="rem_cidade" value="0">
        <input type="hidden" name="rem_idcidade" id="rem_idcidade" value="0">
        <input type="hidden" name="rem_uf" id="rem_uf" value="0">
        <input type="hidden" name="rem_tipo_cfop" id="rem_tipo_cfop" value="0">
        <input type="hidden" name="rem_tipo_cgc" id="rem_tipo_cgc" value="0">
        <input type="hidden" name="rem_tabela_remetente" id="rem_tabela_remetente" value="">
        <input type="hidden" name="rem_tipotaxa" id="rem_tipotaxa" value="">
        <input type="hidden" name="rem_st_mg" id="rem_st_mg" value="0"> 
        <input type="hidden" name="pauta_remetente" id="pauta_remetente" value="0">
        <input type="hidden" name="remtipoorigem" id="remtipoorigem" value="0">
        <input type="hidden" name="perc_adiant" id="perc_adiant" value="0">
        <input type="hidden" id="rem_st_icms" value="1">
        <input type="hidden" id="rem_reducao_icms" value="0">
        <input type="hidden" id="rem_is_in_gsf_598_03_go" value="f">
        <input type="hidden" name="" id="st_rem_credito_presumido" value=""> 
        <input type="hidden" name="" id="st_des_credito_presumido" value=""> 
        <input type="hidden" name="" id="st_cli_credito_presumido" value=""> 
        <input type="hidden" name="" id="st_red_credito_presumido" value=""> 
        <input type="hidden" name="" id="st_exp_credito_presumido" value=""> 
        <input type="hidden" name="" id="st_rec_credito_presumido" value="">
        <input type="hidden" name="st_credito_presumido" id="st_credito_presumido" value="">
        
        <input type="hidden" name="" id="rem_is_in_gsf_1298_16_go" value=""> 
        <input type="hidden" name="" id="des_is_in_gsf_1298_16_go" value=""> 
        <input type="hidden" name="" id="con_is_in_gsf_1298_16_go" value=""> 
        <input type="hidden" name="" id="red_is_in_gsf_1298_16_go" value=""> 
        <input type="hidden" name="is_in_gsf_1298_16_go" id="is_in_gsf_1298_16_go" value="">
        
        <input type="hidden" id="rem_obs" value="">
        <input type="hidden" id="remtipofpag" value="">
        <input type="hidden" id="rem_pgt" value="">
        <input type="hidden" id="venremetente" value="">
        <input type="hidden" id="idvenremetente" value="0">
        <input type="hidden" id="vlvenremetente" value="0">
        <input type="hidden" id="rem_unificada_modal_vendedor" value="1">
        <input type="hidden" id="rem_comissao_rodoviario_fracionado_vendedor" value="0">
        <input type="hidden" id="rem_comissao_rodoviario_lotacao_vendedor" value="0">
        <input type="hidden"id="tipo_documento_padrao" value="">
        <!--destinatario-->
        <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
        <input type="hidden" name="dest_rzs" id="dest_rzs" value="0">
        <input type="hidden" name="dest_cnpj" id="dest_cnpj" value="0">
        <input type="hidden" name="dest_cidade" id="dest_cidade" value="0">
        <input type="hidden" name="dest_insc_est" id="dest_insc_est" value="0">
        <input type="hidden" name="cidade_destino_id" id="cidade_destino_id" value="0">
        <input type="hidden" name="dest_uf" id="dest_uf" value="0">
        <input type="hidden" name="dest_tipotaxa" id="dest_tipotaxa" value="">
        <input type="hidden" name="dest_tabela_remetente" id="des_tabela_remetente" value="n">
        <input type="hidden" name="des_tipo_cfop" id="des_tipo_cfop" value="0">
        <input type="hidden" name="dest_tipo_cgc" id="dest_tipo_cgc" value="0">
        <input type="hidden" name="des_inclui_tde" id="des_inclui_tde" value="0">
        <input type="hidden" name="reducao_base_icms" id="reducao_base_icms" value="0">
        <input type="hidden" name="is_in_gsf_598_03_go" id="is_in_gsf_598_03_go" value="0">
        <input type="hidden" id="config_reducao_base_icms" value="0">
        <input type="hidden" name="pauta_destinatario" id="pauta_destinatario" value="0">
        <input type="hidden" name="desttipoorigem" id="desttipoorigem" value="0">
        <input type="hidden" name="cliente_tabela_remetente_ids" id="cliente_tabela_remetente_ids" value="0">
        <input type="hidden" id="dest_obs" value="">
        <input type="hidden" id="dest_st_icms" value="1">
        <input type="hidden" id="des_reducao_icms" value="0">
        <input type="hidden" id="des_is_in_gsf_598_03_go" value="f">
        <input type="hidden" id="desttipofpag" value="">
        <input type="hidden" id="dest_pgt" value="">
        <input type="hidden" id="vendestinatario" value="">
        <input type="hidden" id="idvendestinatario" value="0">
        <input type="hidden" id="vlvendestinatario" value="0">
        <input type="hidden" id="des_unificada_modal_vendedor" value="1">
        <input type="hidden" id="des_comissao_rodoviario_fracionado_vendedor" value="0">
        <input type="hidden" id="des_comissao_rodoviario_lotacao_vendedor" value="0">
        <!--consignatario-->
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
        <input type="hidden" name="con_rzs" id="con_rzs" value="0">
        <input type="hidden" name="con_insc_est" id="con_insc_est" value="0">
        <input type="hidden" name="con_cnpj" id="con_cnpj" value="0">
        <input type="hidden" name="con_tipotaxa" id="con_tipotaxa" value="">
        <input type="hidden" name="con_tabela_remetente" id="con_tabela_remetente" value="n">
        <input type="hidden" name="con_cidade" id="con_cidade" value="0">
        <input type="hidden" name="con_idcidade" id="con_idcidade" value="0">
        <input type="hidden" name="con_uf" id="con_uf" value="0">
        <input type="hidden" name="pauta_consignatario" id="pauta_consignatario" value="0">
        <input type="hidden" name="contipoorigem" id="contipoorigem" value="0">
        <input type="hidden" id="con_st_icms" value="1">
        <input type="hidden" id="con_reducao_icms" value="0">
        <input type="hidden" id="con_is_in_gsf_598_03_go" value="f">
        <input type="hidden" id="con_obs" value="">
        <input type="hidden" id="tipofpag" name="tipofpag" value="">
        <input type="hidden" id="con_pgt" name="con_pgt" value="">
        <input type="hidden" id="ven_rzs" value="">
        <input type="hidden" id="idvendedor" value="0">
        <input type="hidden" id="comissaoVendedor" value="0">
        <input type="hidden" id="con_unificada_modal_vendedor" value="1">
        <input type="hidden" id="con_comissao_rodoviario_fracionado_vendedor" value="0">
        <input type="hidden" id="con_comissao_rodoviario_lotacao_vendedor" value="0">
        <!--redespacho-->
        <input type="hidden" name="idredespacho" id="idredespacho" value="0">
        <input type="hidden" name="red_rzs" id="red_rzs" value="0">
        <input type="hidden" name="red_insc_est" id="red_insc_est" value="0">
        <input type="hidden" name="red_cnpj" id="red_cnpj" value="0">
        <input type="hidden" name="red_tipotaxa" id="red_tipotaxa" value="">
        <input type="hidden" name="red_tabela_remetente" id="red_tabela_remetente" value="n">
        <input type="hidden" name="red_cidade" id="red_cidade" value="0">
        <input type="hidden" name="red_cidade_id" id="red_cidade_id" value="0">
        <input type="hidden" name="red_uf" id="red_uf" value="0">
        <input type="hidden" name="pauta_redespacho" id="pauta_redespacho" value="0">
        <input type="hidden" name="redtipoorigem" id="redtipoorigem" value="0">
        <input type="hidden" id="red_obs" value="">
        <input type="hidden" id="redtipofpag" value="">
        <input type="hidden" id="red_pgt" value="">
        <input type="hidden" id="vlvenredespacho" value="0">
        <input type="hidden" id="red_unificada_modal_vendedor" value="1">
        <input type="hidden" id="red_comissao_rodoviario_fracionado_vendedor" value="0">
        <input type="hidden" id="red_comissao_rodoviario_lotacao_vendedor" value="0">
        <input type="hidden" id="red_st_icms" value="0">
        <input type="hidden" id="red_reducao_icms" value="0">
        <input type="hidden" id="red_is_in_gsf_598_03_go" value="f">
        <input type="hidden" name="mensagem_usuario_cte_red" id="mensagem_usuario_cte_red" value="">
        <!--cidade_origem-->
        <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
        <input type="hidden" name="cid_origem" id="cid_origem" value="0">
        <input type="hidden" name="uf_origem" id="uf_origem" value="0">
        <!--destino-->
        <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
        <input type="hidden" name="cid_destino" id="cid_destino" value="0">
        <input type="hidden" name="uf_destino" id="uf_destino" value="0">
        <!--vendedor-->
        <input type="hidden" name="idvendedor" id="idvendedor" value="0">
        <input type="hidden" name="ven_rzs" id="ven_rzs" value="0">        
        <!--redespachante-->
        <input type="hidden" id="idredespachante" value="0">
        <input type="hidden" id="redspt_rzs" value="0">        
        <input type="hidden" id="redspt_cnpj" value="0">        
        <input type="hidden" id="vlkgate" value="0">        
        <input type="hidden" id="vlprecofaixa" value="0">        
        <input type="hidden" id="redspt_vlsobfrete" value="0">        
        <input type="hidden" id="redspt_vlfreteminimo" value="0">        
        <input type="hidden" id="redspt_vlsobpeso" value="0">        
        <!--cfop-->
        <input type="hidden" name="idcfop" id="idcfop" value="0">
        <input type="hidden" name="cfop" id="cfop" value="0">
        <!--cadastro de veiculo-->
        <input type="hidden" name="motor_nome" id="motor_nome" value="0">
        <input type="hidden" name="idmotorista" id="idmotorista" value="0">
        <input type="hidden" name="vei_placa" id="vei_placa" value ="0">
        <input type="hidden" name="idveiculo" id="idveiculo" value="0">
        <input type="hidden" name="car_placa" id="car_placa" value="0">
        <input type="hidden" name="idcarreta" id="idcarreta" value="0">
        <input type="hidden" name="bi_placa" id="bi_placa" value="0">
        <input type="hidden" name="idbitrem" id="idbitrem" value="0">
        <input type="hidden" name="layout" id="layout" value="0">        
        <input type="hidden" name="is_tac" id="is_tac" value="f">
        <input type="hidden" id="is_utilizar_tipo_frete_tabela" value="">
        <input type="hidden" id="tipos_produto" value="">
        <!--Recebedor-->
        <input type="hidden" name="idrecebedor" id="idrecebedor" value="0">
        <input type="hidden" name="rec_rzs" id="rec_rzs" value="">
        <input type="hidden" name="rec_cidade" id="rec_cidade" value="">
        <input type="hidden" name="rec_idcidade" id="rec_idcidade" value="0">
        <input type="hidden" name="rec_cnpj" id="rec_cnpj" value="">
        <input type="hidden" name="rec_uf" id="rec_uf" value="">
        <!--Expedidor-->
        <input type="hidden" name="idexpedidor" id="idexpedidor" value="0">
        <input type="hidden" name="exp_rzs" id="exp_rzs" value="">
        <input type="hidden" name="exp_cidade" id="exp_cidade" value="">
        <input type="hidden" name="exp_idcidade" id="exp_idcidade" value="0">
        <input type="hidden" name="exp_cnpj" id="exp_cnpj" value="">
        <input type="hidden" name="exp_uf" id="exp_uf" value="">
        <input type="hidden" name="tipoCteImpLote" id="tipoCteImpLote" value="">
        <!--Coleta-->
        <input type="hidden" name="vlcombinado" id="vlcombinado" value="0">
        <!--Dados da nota fiscal da coleta-->
        <input type="hidden" name="idnota_fiscal" id="idnota_fiscal" value="0">
        <input type="hidden" name="numero_nf" id="numero_nf" value="0">
        <input type="hidden" name="vl_base_icms" id="vl_base_icms" value="0">
        <input type="hidden" name="vl_icms_nota" id="vl_icms_nota" value="0">
        <input type="hidden" name="vl_icms_st" id="vl_icms_st" value="0">
        <input type="hidden" name="valor_nota" id="valor_nota" value="0">
        <input type="hidden" name="peso_nota" id="peso_nota" value="0">
        <input type="hidden" name="peso" id="peso" value="0">
        <input type="hidden" name="volume_nota" id="volume_nota" value="0">
        <input type="hidden" name="serie_nota" id="serie_nota" value="0">
        <input type="hidden" name="pedido_nota" id="pedido_nota" value="0">
        <input type="hidden" name="cfop_id" id="cfop_id" value="0">
        <input type="hidden" name="cfop_nf" id="cfop_nf" value="">
        <input type="hidden" name="chave_acesso" id="chave_acesso" value="">
        <input type="hidden" name="embalagem_nota" id="embalagem_nota" value="">
        <input type="hidden" name="conteudo_nota" id="conteudo_nota" value="">
        <input type="hidden" name="nf_previsao_entrega" id="nf_previsao_entrega" value="">
        <input type="hidden" name="nf_previsao_entrega_as" id="nf_previsao_entrega_as" value="">
        <input type="hidden" name="is_agendado" id="is_agendado" value="false">
        <input type="hidden" name="data_agenda" id="data_agenda" value="">
        <input type="hidden" name="hora_agenda" id="hora_agenda" value="">
        <input type="hidden" name="obs_agenda" id="obs_agenda" value="">
        <input type="hidden" name="metro_cubico_nota" id="metro_cubico_nota" value="">
        <input type="hidden" name="nf_iddestinatario" id="nf_iddestinatario" value="">
        <input type="hidden" name="nf_destinatario" id="nf_destinatario" value="">
        <input type="hidden" name="cubagens_json" id="cubagens_json" value="">
        <input type="hidden" name="max_itens_metro" id="max_itens_metro" value="">
        <input type="hidden" name="tipo_documento" id="tipo_documento" value="">
        <input type="hidden" name="indexNota" id="indexNota" value="">
        <input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio">    
        <input type="hidden" name="is_bloqueado" id="is_bloqueado">    
        <input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo">    
        <input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq">    
        <input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo">    
        <input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq">
        <input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo">    
        <input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq">
        <input type="hidden" name="mensagem_usuario_cte" id="mensagem_usuario_cte" value="">
        <input type="hidden" name="mensagem_usuario_cte_rem" id="mensagem_usuario_cte_rem" value="">
        <input type="hidden" name="mensagem_usuario_cte_des" id="mensagem_usuario_cte_des" value="">
        <input type="hidden" name="contabelaproduto" id="contabelaproduto" value="">
        <input type="hidden" name="tipo_arredondamento_peso_con" id="tipo_arredondamento_peso_con" value="">
        <input type="hidden" name="tipo_arredondamento_peso_rem" id="tipo_arredondamento_peso_rem" value="">
        <input type="hidden" name="tipo_arredondamento_peso_dest" id="tipo_arredondamento_peso_dest" value="">
        <input type="hidden" name="tipo_arredondamento_peso_red" id="tipo_arredondamento_peso_red" value="">
        <input type="hidden" name="tipo_arredondamento_peso_rateio" id="tipo_arredondamento_peso_rateio" value="">
        <input type="hidden" id="is_frete_dirigido" name="is_frete_dirigido" value="false">
        <input type="hidden" id="rem_tipo_tributacao" name="rem_tipo_tributacao" value="NI">
        <input type="hidden" id="dest_tipo_tributacao" name="dest_tipo_tributacao" value="NI">
        <input type="hidden" id="con_tipo_tributacao" name="con_tipo_tributacao" value="NI">
        <input type="hidden" id="red_tipo_tributacao" name="red_tipo_tributacao" value="NI">
        <input type="hidden" name="tipo_produto_destinatario_id" id="tipo_produto_destinatario_id" value="">
        <input type="hidden" name="red_utilizar_tabela_cliente" id="red_utilizar_tabela_cliente" value="">
        <input type="hidden" name="rem_utilizar_tabela_cliente" id="rem_utilizar_tabela_cliente" value="">
        <input type="hidden" name="dest_utilizar_tabela_cliente" id="dest_utilizar_tabela_cliente" value="">
        <input type="hidden" name="con_utilizar_tabela_cliente" id="con_utilizar_tabela_cliente" value="">
        <input type="hidden" name="con_utilizar_tabela_cliente_rateio" id="con_utilizar_tabela_cliente_rateio" value="">
        <input type="hidden" id="percentual_valor_cte_calculo_cfe" name="percentual_valor_cte_calculo_cfe">
        <input type="hidden" id="tipo_calculo_percentual_valor_cfe" name="tipo_calculo_percentual_valor_cfe">
        <input type="hidden" id="json_taxas" readonly="true">
        <input type="hidden" id="calculo_valor_contrato_frete" name="calculo_valor_contrato_frete">
       
        <c:forEach var="filial" varStatus="status" items="${listaFilial}">
            <input type="hidden" id="stFilialCfe" name="stFilialCfe" />
            <input type="hidden" id="filialCfe_${filial.idfilial}" name="filialCfe_${filial.idfilial}" value="${filial.stUtilizacaoCfe}">
            <input type="hidden" id="agente_repom_id_${filial.idfilial}" name="agente_repom_id_${filial.idfilial}" value="${filial.agentePagadorRepom.idfornecedor}">
            <input type="hidden" id="agente_repom_${filial.idfilial}" name="agente_repom_${filial.idfilial}" value="${filial.agentePagadorRepom.razaosocial}">
            <input type="hidden" id="valor_max_${filial.idfilial}" name="valor_max_${filial.idfilial}" value="${filial.valorMaximo}">
            <input type="hidden" id="is_ativar_valor_${filial.idfilial}" name="is_ativar_valor_${filial.idfilial}" value="${filial.isAtivaControleValorManifesto}">
            <input type="hidden" id="is_retencao_imposto_operadora_cfe_${filial.idfilial}" name="is_retencao_imposto_operadora_cfe_${filial.idfilial}" value="${filial.retencaoImpostoOperadoraCFe}">
        </c:forEach>

            <input type="hidden" name="st_icms" id="st_icms" value="0">

        <!--<form method="post"  id="formulario" target="pop">-->
        <img src="img/banner.gif" >

        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr >
                <td width="70%"><div align="left"><b>Importar Conhecimento em Lote</b></div></td>


                <td width="15%"><input name="btnImportarConhecimentoLote" type="button" class="botoes" id="btnImportarConhecimentoLote" value="Importar Conhecimento" onclick="tryRequestToServer(function(){importar();});"></td>

                <td width="15%" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:tryRequestToServer(function(){voltar();});"></td>
            </tr>
        </table>
        <br>
        <table width="95%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">                
            <tr class="tabela" >
                <td colspan="10">Dados Principais</td>
            </tr>
            <tr>
                <td width="100%">
                    <table width="100%" class="bordaFina">
                        <tr class="CelulaZebra2" >
                            <td class="textoCampos" width="4%">Filial:</td>
                            <td width="12%">
                                <select name="filial" id="filial" class="fieldMin" onchange="getAliquotasIcmsAjax(this.value.split('@@')[0]);$('modalCTe').value = this.value.split('@@')[5];alterarTipoTranporte();">
                                    <c:forEach var="filialItem" varStatus="status" items="${listaFilial}">
                                        <option value="${filialItem.idfilial}@@${filialItem.cidade.uf}@@${filialItem.deduzirPedagioIcms}@@${filialItem.cidade.idcidade}@@${filialItem.cidade.descricaoCidade}@@${filialItem.modalCTE}@@${filialItem.cnpj}@@${filialItem.seriePadraoCTeAereo}@@${filialItem.seriePadraoCTeAquaviario}@@${filialItem.seriePadraoCTeRodoviario}@@${filialItem.valorMaximoSemNotacao}@@${filialItem.isAtivaControleValorManifesto}@@${filialItem.ativarICMSGoias}" 
                                                ${filialItem.idfilial == usuario.filial.idfilial ? 'selected' : ''} >${filialItem.abreviatura}</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td class="textoCampos" width="6%">Data emissão</td>
                            <td width="5%">
                                <input name="dataEmissaoCTe" type="text" id="dataEmissaoCTe" value="${param.dataAtual}"
                                       onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)"
                                       size="10" maxlength="10" style="font-size:8pt;"
                                       class="<c:out value="${altnumctrc > 0 ? 'fieldDate': 'inputReadOnly'}"/>"
                                       <c:if test="${altnumctrc <= 0}">readonly</c:if>
                                >
                            </td>
                            <td class="textoCampos" width="4%">Especie:</td>
                            <td width="4%">
                                <input id="especie" name="especie" maxlength="3" value="" size="4"
                                       class="<c:out value="${altnumctrc > 0 ? 'fieldMin': 'inputReadOnly'}"/>"
                                       <c:if test="${altnumctrc <= 0}">readonly</c:if>
                                >
                            </td>
                            <td class="textoCampos" width="4%">Série:</td>
                            <td width="4%">
                                <input id="serie" name="serie" maxlength="3" value="1" size="2"
                                       class="<c:out value="${altnumctrc > 0 ? 'fieldMin': 'inputReadOnly'}"/>"
                                       <c:if test="${altnumctrc <= 0}">readonly</c:if>
                                >
                            </td>
                            <td class="textoCampos" width="8%">Modal CT-e:</td>
                            <td width="8%">
                                <select name="modalCTe" id="modalCTe"   class="fieldMin" onchange="alterarModal();">
                                    <option value="l">Lotação</option>
                                    <option value="f">Fracionado</option>
                                </select>
                            </td>
                            <td width="10%" align="center">
                                <select name="tipoTransporte" id="tipoTransporte" class="fieldMin" onchange="javascript:alterarTipoTranporte();">
                                    <c:if test="${usuario.emiteRodoviario}">
                                        <option value="r"  selected>CTR - Transp. Rodovi&aacute;rio</option>                                        
                                    </c:if>
                                    <c:if test="${usuario.emiteAereo}">
                                        <option value="a">CTA - Transp. A&eacute;reo</option>
                                    </c:if>
                                    <c:if test="${usuario.emiteAquaviario}">
                                        <option value="q">CTQ - Transp. Aquavi&aacute;rio</option>
                                    </c:if>
                                </select>
                            </td>                            
                            <td width="16%">
                                <label class="textoCampos">Tipo:</label>
                                <select name="tipoConhecimento" id="tipoConhecimento"  class="fieldMin">
                                    <option value="n" selected>Normal</option>
                                    <option value="l">Distribuição Local</option>
                                    <option value="i">Diárias</option>
                                    <option value="p">Pallets</option>
                                    <option value="c">Complementar</option>
                                    <option value="r">Reentrega</option>
                                    <option value="d">Devolução</option>
                                    <option value="b">Cortesia</option>
                                </select>
                            </td>
                            <td class="textoCampos" width="6%">Tipo Serviço:</td>
                            <td width="16%">
                                
                                <select name="tipoServico" id="tipoServico" class="fieldMin" width="50px" onchange="padronizarCfops()">
                                    <option value="n" selected>Normal</option>
                                    <option value="s">SubContratação</option>
                                    <option value="r">Redespacho</option>
                                    <option value="i">Redespacho Intermediário</option>
                                    <option value="m">Multimodal</option>
                                </select>
                            </td>
                        </tr>
                        <tr id="trLotacao">
                            <td colspan="14"  width="100%">
                                <table width="100%" class="bordaFina">
                                    <tr>
                                        <td class="textoCampos" >Motorista:</td>
                                        <td class="celulaZebra2" >
                                            <input type="hidden" name="idmotoristaPrincipal" id="idmotoristaPrincipal" value="0" />
                                            <input name="motorista_nome" id="motorista_nome" type="text" class="inputReadOnly8pt" size="28" readonly /> 
                                            <input type="button" class="inputBotaoMin" id="botaoMotorista" onclick="abrirLocalizaMotorista()" value="..." />                                             
                                            <img class="imagemLink" id="limpM" onclick="limparMotorista()" src="img/borracha.gif" /> 
                                        </td>
                                        <td class="textoCampos"  >Veiculo:</td>
                                        <input name="tipo_veiculo_motorista" type="hidden" id="tipo_veiculo_motorista" class="inputReadOnly8pt" value="0" size="9" readonly="true">
                                        <input name="tipo_veiculo_veiculo" type="hidden" id="tipo_veiculo_veiculo" class="inputReadOnly8pt" value="0" size="9" readonly="true">
                                        <input name="tipo_veiculo_carreta" type="hidden" id="tipo_veiculo_carreta" class="inputReadOnly8pt" value="0" size="9" readonly="true">
                                        <td class="celulaZebra2" >
                                            <input type="text" class="inputReadOnly8pt" name="veiculo_placa" id="veiculo_placa" size="9" maxlength="9" readonly> 
                                            <input type="hidden" name="idveiculoPrincipal" id="idveiculoPrincipal" value="0" /> 
                                            <input type="button" class="inputBotaoMin" id="botaoVeiculo" onclick="abrirLocalizaVeiculo()" value="..." />
                                            <img class="imagemLink" id="limpVei" onclick="limparVeiculo()" src="img/borracha.gif" /> 
                                        </td>
                                        <td class="textoCampos"  >Carreta:</td>
                                        <td class="celulaZebra2" >
                                            <input type="text" class="inputReadOnly8pt" name="carreta_placa" id="carreta_placa" size="9" maxlength="9" readonly> 
                                            <input type="hidden" name="idcarretaPrincipal" id="idcarretaPrincipal" value="0" /> 
                                            <input type="button" class="inputBotaoMin" id="botaoCarreta" onclick="abrirLocalizaCarreta()" value="..." />
                                            <img class="imagemLink" id="limpCar" onclick="limparCarreta()" src="img/borracha.gif" /> 
                                        </td>
                                        <td class="textoCampos"  >Bitrem:</td>
                                        <td class="celulaZebra2" >
                                            <input type="text" class="inputReadOnly8pt" name="bitrem_placa" id="bitrem_placa" size="9" maxlength="9" readonly> 
                                            <input type="hidden" name="idbitremPrincipal" id="idbitremPrincipal" value="0" /> 
                                            <input type="button" class="inputBotaoMin" id="botaoBitrem" onclick="abrirLocalizaBitrem()" value="..." />
                                            <img class="imagemLinkSpc" id="limpBit" onclick="limparBitrem()" src="img/borracha.gif" /> 
                                        </td>
                                        <td class="textoCampos"  >Pedido:</td>
                                        <td class="celulaZebra2" >
                                            <input type="text" class="fieldMin" name="pedido" id="pedido" size="9" maxlength="10" /> 
                                        </td>
                                        <td class="textoCampos"  >Nº Carga:</td>
                                        <td class="celulaZebra2" >
                                            <input type="text" class="fieldMin" name="numeroCarga" id="numeroCarga" size="15" maxlength="20" /> 
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2NoAlign">
                            <td class="TextoCampos">Coleta:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <input name="numcoleta" type="text" id="numcoleta" size="10" maxlength="10" readonly class="inputReadOnly8pt"/>
                               <input type="hidden" id="idcoleta" name="idcoleta" value="0"/>
                               <input name="localiza_coleta" type="button" class="botoes" id="localiza_coleta" value="..." onclick="javascript:tryRequestToServer(function(){abrirLocalizaColeta();})"  />
                               <img src="img/borracha.gif" border="0" class="imagemLink" onclick="limparLocalizaColeta();" />
                            </td>
                            <td class="TextoCamposNoAlign" colspan="4">
                                <div id="divAdicionarNotaColeta" style="display: none" align="center">
                                    <label>
                                        <input id="chkAdicionarNotaColeta" name="chkAdicionarNotaColeta" type="checkbox" value="false"/>
                                        Ao adicionar nota, localizar da coleta.
                                    </label>                                    
                                </div>                                
                            </td>
                            <td class="TextoCampos">
                               Conferente:  
                            </td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="hidden" name="id_funcionario" id="id_funcionario" value="0">
                                <input type="text" class="inputReadOnly8pt" readonly="true" name="nome_funcionario" id="nome_funcionario" value="">
                                <input type="button" value="..." class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=93','Conferente')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conferente" onClick="javascript:getObj('id_funcionario').value = '0';javascript:getObj('nome_funcionario').value = '';">
                            </td>
                            <td class="TextoCamposNoAlign">
                                <div id="divCategorias de Cargas" align="right">
                                    <label>Categoria de Carga:</label>
                                </div>                                
                            </td>
                            <td class="TextoCamposNoAlign" colspan="3">
                                <div id="divCategorias de Cargas" align="left">
                                    <select class="fieldMin" id="categoriaCarga" name="categoriaCarga" value="listaCategoriaCargaAll">
                                            <option value="0">Nenhum</option>
                                        <c:forEach var="cat" varStatus="status" items="${listaCategoriaCarga}">
                                            <option value="${cat.id}">${cat.descricao}</option>
                                        </c:forEach>
                                    </select>
                                </div>                                
                            </td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td colspan="3">
                                Observação do CT-e padrão
                            </td>
                            <td colspan="11">
                                <textarea type="text" name="obsPadrao" id="obsPadrao" value="" class="inputtexto" cols="50" rows="2"></textarea>
                                <img src="img/add.gif" border="0" title="Atribuir a observação nos conhecimentos marcados" class="imagemLink" style="vertical-align:middle;" onclick="replicaObservacao()">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="14">
                                <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                                    <tr class="CelulaZebra2NoAlign" id="trRateio" >
                                        <td align="left" width="25%">
                                             <p><input name="isRatearValorFrete" id="isRatearValorFrete" type="checkbox" class="botoes" onclick="mostrarValorRateio()" value="" />
                                                 Informe o valor total do frete a ser rateado proporcionalmente para todos os conhecimentos levando em consideração o seu peso</p>
                                          </td>                               
                                          <td class="textoCampos" width="5%">
                                            <label id="labValor">Dividir por:</label>
                                        </td>                                
                                        <td class="celulaZebra2" width="6%">
                                            <select class="fieldMin" id="formaRateio">
                                                <option value="peso" selected>Peso</option>
                                                <option value="qtdCtrc">Qtd. CT-e</option>
                                                <option value="metroCubico">Metro Cubico (M³)</option>
                                                <option value="valorNf">Valor da NF</option>
                                            </select>
                                        </td>                                
                                        <td class="textoCampos" width="6%">
                                            <label id="labValor">Frete Peso:</label>
                                        </td>                                
                                        <td class="celulaZebra2"  width="7%">
                                            <input name="valorFrete" id="valorFrete" type="text" class="inputTexto" onkeypress="mascara(this, reais)" size="10" value="" />
                                        </td>
                                         <td class="textoCampos" width="6%">
                                            <label id="labValorOutros">Valor Outros:</label>
                                        </td>                                
                                        <td class="celulaZebra2" width="8%">
                                            <input name="valorOutros" id="valorOutros" type="text" class="inputTexto" onkeypress="mascara(this, reais)" size="10" value="" />
                                        </td> 

                                        <td class="textoCampos" width="7%">
                                            <label id="labValor">Valor Taxa Fixa:</label>
                                        </td>                                
                                        <td class="celulaZebra2"  width="7%">
                                            <input name="valorTotalTaxaFixa" id="valorTotalTaxaFixa" type="text" class="inputTexto" onkeypress="mascara(this, reais)" size="10" value="" />
                                        </td> 
                                        <td class="textoCampos" width="6%">
                                            <label id="labAdvalorem">Advalorem: </label>
                                        </td>                                
                                        <td class="celulaZebra2"  width="7%">
                                            <input name="valorAdvalorem" id="valorAdvalorem" type="text" class="inputTexto" onkeypress="mascara(this, reais)" onblur="calcularAdValorem(this)" size="10" maxlength="4" value="" />
                                        </td> 
                                        <td class="CelulaZebra2NoAlign" width="7%">
                                            <input name="btRateioValorFrete" id="btRateioValorFrete" onclick="ratearFretePeso(true);" type="button" class="botoes" value="Ratear" />
                                        </td>                                
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2NoAlign" id="trTipoRateio" >
                            <td align="left" colspan="2">
                                <input type="radio" id="rdManual" name="rdButon" value="1" onclick="mostrarOpcoesRateio()" checked/>
                                <label name="lbManual" id="lbManual">Informar valor manualmente</label>
                            </td>
                            <td align="left" colspan="6">
                                <input type="radio" id="rdAutomatico" name="rdButon" value="2" onclick="mostrarOpcoesRateio()"/>
                                <label name="lbManual" id="lbManual">Buscar valor na tabela de preço</label>
                            </td>
                            <td align="left" colspan="6">
                                <input name="isRatearCTRCSelecionados" id="isRatearCTRCSelecionados" type="checkbox" class="botoes" value=""/>
                                <label>Ao ratear considerar apenas os conhecimentos selecionados</label>                 
                            </td>
                        </tr>
                        <tr class="CelulaZebra2NoAlign" id="trOpcoesRateio1" >
                            <td align="right" colspan="1">
                                <label name="lbCliente" id="lbCliente">Cliente:</label>
                            </td>
                            <td align="left" colspan="4">
                                <input type="text" class="inputReadOnly8pt" name="txtConsignatarioRateio" id="txtConsignatarioRateio" size="50"/>
                                <input type="hidden" name="hiddenConsignatarioRateio" id="hiddenConsignatarioRateio" value="0"/>
                                <input  type="button" name="btConsignatarioRateio" id="btConsignatarioRateio" class="botoes" onclick="abrirLocalizaConsignatarioRateio()" value="..."/>
                            </td>
                            <td align="left" colspan="2">
                                <label name="lbTipoProduto" id="lbTipoProduto">Tipo de Produto:</label>
                            </td>
                            <td align="left" colspan="2" id="tdTipoProd" name="tdTipoProd">
                                <select id="slTipoProduto" name="slTipoProduto" class="fieldMin"  value="listaTipoProdutoAll">
                                <option value="0">Nenhum</option>
                                     <c:forEach var="tipo" varStatus="status" items="${listaTipoProduto}">
                                         <option value="${tipo.id}">${tipo.descricao}</option>
                                     </c:forEach>
                                </select>
                            </td>
                            <td align="left" colspan="3">
                                <label name="lbTipoVeiculo" id="lbTipoVeiculo">Tipo de Ve&iacute;culo:</label>
                                <select id="slTipoVeiculo" name="slTipoVeiculo" class="fieldMin"  value="listaTipoVeiculoAll">
                                     <option value="0">Nenhum</option>
                                     <c:forEach var="tipo" varStatus="status" items="${listaTipoVeiculo}">
                                         <option value="${tipo.id}">${tipo.descricao}</option>
                                     </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2NoAlign" id="trOpcoesRateio2" >
                            <td align="right" colspan="1">
                                Cidade Origem:
                            </td>
                            <td align="left" colspan="3">
                               <input type="text" class="inputReadOnly8pt" name="txtCidadeOrigemRateio" id="txtCidadeOrigemRateio" size="25"/>
                               <input type="hidden" name="hiddenCidadeOrigemRateio" id="hiddenCidadeOrigemRateio" value="0"/>
                               <input type="text" class="inputReadOnly8pt" name="txtUfOrigemRateio" id="txtUfOrigemRateio" size="4"/>
                               <input  type="button" name="btCidadeOrigemRateio" id="btCidadeOrigemRateio" class="botoes" onclick="abrirLocalizaCidadeOrigemRateio()" value="..."/>
                            </td>
                            <td align="right" colspan="2">
                                Cidade Destino:
                            </td>
                            <td align="left" colspan="3">
                               <input type="text" class="inputReadOnly8pt" name="txtCidadeDestinoRateio" id="txtCidadeDestinoRateio" size="25"/>
                               <input type="hidden" name="hiddenCidadeDestinoRateio" id="hiddenCidadeDestinoRateio" value="0"/>
                               <input type="text" class="inputReadOnly8pt" name="txtUfDestinoRateio" id="txtUfDestinoRateio" size="4"/>
                               <input  type="button" name="btCidadeDestinoRateio" id="btCidadeDestinoRateio" class="botoes" onclick="abrirLocalizaCidadeDestinoRateio()" value="..."/>
                            </td>
                            <td align="left">
                                <input type="button" name="btTabelaPreco" id="btTabelaPreco" class="botoes"  value=" Pesquisar " onclick="pesquisaTabelaPreco()">
                            </td>
                            <td align="left" colspan="2">
                                <label name="lblTabelaPreco" id="lblTabelaPreco"></label>
                            </td>
                                
                        </tr>
                        <tr class="celulaZebra2" id="trNovo">
                            <td colspan="7">
                                <span class="CelulaZebra2">
                                    <img src="img/add.gif" border="0" class="imagemLink " title="Adicionar um novo CT-e (SHIFT + C)" onClick="addConhecimentoLote(null,$('tabConhecimento'),$('maxConhecimento'), $('serie'),$('alteraprecocte').value,$('alterainffiscal').value,$('permissao_alteratipofretecte').value, $('embutirICMS').checked,$('embutirPISCOFINS').checked,$('slTipoProduto').value,$('slTipoVeiculo').value,$('obsPadrao').value);">
                                    <label>Adicione um Conhecimento</label>
                                    <label class="style2" style="font-size: xx-small" >&nbsp;(SHIFT + C)</label>
                                </span>
                                <input type="hidden" id="maxConhecimento" name="maxConhecimento" value="0">
                                <input type="hidden" id="permissao_alteratipofretecte" name="permissao_alteratipofretecte" value="">
                                <input type="hidden" id="alterainffiscal" name="alterainffiscal" value="">
                                <input type="hidden" id="alteraprecocte" name="alteraprecocte" value="">
                                <input type="hidden" id="alteraimpostoscartafrete" name="alteraimpostoscartafrete" value="">
                            </td>
                            <td class="CelulaZebra2NoAlign" align="right">Por Padrão: </td>
                            <td colspan="2"> <input type="checkbox" id="embutirICMS" name="embutirICMS"> Embutir ICMS 
                                             <input type="checkbox" id="embutirPISCOFINS" name="embutirPISCOFINS" > Embutir PIS/COFINS</td>
                            <td width="10%" class="CelulaZebra2NoAlign" align="right">Localizar Nota:</td>
                            <td colspan="3">
                                <input type="text" class="inputTexto" onkeypress="mascara(this, soNumeros)" size="10"  
                                       onKeyUp="javascript:if (event.keyCode==13) localizarNota(this.value)"
                                       onchange="localizarNota(this.value)" />
                            </td>
                        </tr>
                        <tr class="celulaZebra2" id="trNovo">
                            <td colspan="2">
                                <input type="checkbox" id="marcarTodos" name="marcarTodos" checked onclick="marcarCheck(this.checked, $('maxConhecimento').value)" />
                                <span class="CelulaZebra2">
                                    <label>Marcar todos os conhecimentos</label>
                                </span>
                            </td>
                            <td colspan="12">
                                <span class="CelulaZebra2">
                                    <label>
                                        <input type="checkbox" id="isFecharPagina" name="isFecharPagina" checked onclick="fecharPagina()" value="checkbox"/>
                                        Fechar a p&aacute;gina ap&oacute;s salvar o(s) conhecimento(s)
                                    </label>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="14">
                                <table width="100%" class="bordaFina" id="tabConhecimento">
                                </table>
                            </td>
                        </tr>
                        <tr id="trContratoFreteAutomatico" style="display: none">
                            <td width="100%" colspan="14" >
                                <form id="formContratoFreteViagem" name="formContratoFreteViagem" >
                                    <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td id="tdCarta" width="50%" style="vertical-align:top;">
                                                <table class="bordaFina" width="100%">
                                                    <tr>
                                                        <td colspan="2" class="tabela">
                                                            <div align="center">
                                                                <input name="chk_carta_automatica" type="checkbox" id="chk_carta_automatica" value="checkbox"> Gerar Contrato de Frete com o Proprietário
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="10%" class="TextoCampos">Proprietário:</td>
                                                        <td width="40%" class="CelulaZebra2">
                                                            <input name="vei_prop" type="text" id="vei_prop" class="inputReadOnly8pt" size="40" readonly="true" value="">
                                                            <input name="considerar_campo_cte" type="hidden" id="considerar_campo_cte" size="25" class="inputReadOnly8pt" readonly="true" value="tp">
                                                            <input name="vei_prop_cgc" type="text" id="vei_prop_cgc" class="inputReadOnly8pt" size="20" readonly="true" value="">
                                                            <input name="plano_proprietario" type="hidden" id="plano_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input type="hidden" id="idproprietarioveiculo" name="idproprietarioveiculo" value="0"  /> 
                                                            <input name="und_proprietario" type="hidden" id="und_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="valor_rota" type="hidden" id="valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="valor_maximo_rota" type="hidden" id="valor_maximo_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="tipo_valor_rota" type="hidden" id="tipo_valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="f">
                                                            <input name="debito_prop" type="hidden" id="debito_prop" size="10" value="0">
                                                            <input name="percentual_desconto_prop" type="hidden" id="percentual_desconto_prop" size="10" value="0">
                                                            <input name="percentual_ctrc_contrato_frete" type="hidden" id="percentual_ctrc_contrato_frete" size="10" value="0">
                                                            <input name="valor_rota_viagem_2" type="hidden" id="valor_rota_viagem_2" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="valor_pedagio_rota" type="hidden" id="valor_pedagio_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="rota_taxa_fixa" type="hidden" id="rota_taxa_fixa" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="valor_entrega_rota" type="hidden" id="valor_entrega_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="qtd_entregas_rota" type="hidden" id="qtd_entregas_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="base_ir_prop_retido" type="hidden" id="base_ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="ir_prop_retido" type="hidden" id="ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="base_inss_prop_retido" type="hidden" id="base_inss_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                            <input name="inss_prop_retido" type="hidden" id="inss_prop_retido" value="0,00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                            <input name="favorecido_pedagio" type="hidden" id="favorecido_pedagio" value="m" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                            <input name="tipo_desconto_prop" type="hidden" id="tipo_desconto_prop" value="0.00">
                                                            <input name="is_deduzir_pedagio" type="hidden" id="is_deduzir_pedagio" value="false">
                                                            <input name="is_carregar_pedagio_ctes" type="hidden" id="is_carregar_pedagio_ctes" value="false">
                                                            <input name="motorista_valor_minimo" type="hidden" id="motorista_valor_minimo" value="0.00">
                                                            <input name="rota_valor_minimo" type="hidden" id="rota_valor_minimo" value="0.00">
                                                            <input type="hidden" id="rota_is_nfe_por_entrega" name="rota_is_nfe_por_entrega">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="TextoCampos">Seguradora:</td>
                                                        <td class="CelulaZebra2">
                                                            <input name="nome_seguradora" type="text" id="nome_seguradora" class="inputReadOnly8pt" size="27" readonly="true" value="">
                                                            <input name="localiza_seguradora" type="button" class="botoes" id="localiza_seguradora" value="..." onClick="abrirLocalizaSeguradora()">
                                                            Liberação:<input name="motor_liberacao" type="text" id="motor_liberacao" class="fieldMin" size="15" value="">
                                                            <input name="seguradora_id" type="hidden" id="seguradora_id" class="inputReadOnly8pt" size="20" readonly="true" value="0">
                                                        </td>
                                                    </tr>
                                                    <tr>

                                                        <td class="TextoCampos" >Agente de carga:</td>
                                                        <td class="CelulaZebra2" >
                                                            <input name="nome_agente_carga" type="text" id="nome_agente_carga" class="inputReadOnly8pt" value="" size="40"  readonly="true">
                                                            <input name="localiza_agente_carga" type="button" class="botoes" id="localiza_agente_carga" value="..." onClick="abrirLocalizaAgenteCarga()" style="font-size:8pt;">
                                                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Agente de Carga" onClick="">
                                                            <input type="hidden" id="idagente_carga" name="idagente_carga" value="0">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="TextoCampos">Observação:</td>
                                                        <td class="CelulaZebra2">
                                                            <input name="obs_carta_frete" type="text" id="obs_carta_frete" class="fieldMin" value="" size="60" >
                                                        </td>
                                                    </tr>
                                                    <tr><td class="TextoCampos">Natureza da Carga: </td>
                                                        <td class="CelulaZebra2">
                                                            <input type="text"class="inputReadOnly8pt" name="natureza_cod_desc" id="natureza_cod_desc" size="4" readonly> 
                                                            <input type="text"class="inputReadOnly8pt" name="natureza_desc" id="natureza_desc" size="23" readonly> 
                                                            <input type="hidden" name="natureza_cod" id="natureza_cod" value="0" /> 
                                                            <input type="button" class="inputBotaoMin" id="botaoCarreta" onclick="abrirLocalizaNatureza()" value="..." /> 
                                                        </td></tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                                <tr class="celula">
                                                                    <td width="8%" >Frete</td>
                                                                    <td width="8%" >Outros</td>
                                                                    <td width="8%" >Pedágio</td>
                                                                    <td width="15%" class="style1"><input name="chk_reter_impostos" type="checkbox" id="chk_reter_impostos" value="checkbox" onClick="calcularFreteCarreteiro();" > Impostos</td>
                                                                    <td width="16%" class="style1" >Desconto</td>
                                                                    <td width="8%" class="style1" ${(not configuracao.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}><label for="abastecimentos">Abast.</label></td>
                                                                    <td width="15%" >Líquido</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="CelulaZebra2"><input name="cartaValorFrete" type="text" id="cartaValorFrete" value="0,00" size="8" maxlength="12" class="fieldMin styleNum" onkeypress="mascara(this, reais)" onBlur="javascript: setZero(this,false);calcularFreteCarreteiro();" ></td>
                                                                    <td class="CelulaZebra2"><input name="cartaOutros" type="text" id="cartaOutros" value="0,00" size="8" maxlength="12" class="fieldMin styleNum" onkeypress="mascara(this, reais)" onBlur="javascript:setZero(this,false);calcularFreteCarreteiro();"></td>
                                                                    <td class="CelulaZebra2"><input name="cartaPedagio" type="text" id="cartaPedagio" value="0,00" size="8" maxlength="12" class="fieldMin styleNum"  onkeypress="mascara(this, reais)" onBlur="javascript:setZero(this,false);calcularFreteCarreteiro();"></td>
                                                                    <td class="CelulaZebra2">
                                                                        <input name="cartaImpostos" type="text" id="cartaImpostos" value="0,00" size="8" maxlength="12" class="inputReadOnly8pt style1 styleNum"  onBlur="javascript:setZero(this,'0,00');calcularFreteCarreteiro();" readOnly>
                                                                        <img src="img/calculadora.png" border="0" align="absbottom" class="imagemLink" title="Detalhar Impostos" onClick="$('trImpostosCarta').style.display = '';">
                                                                    </td>
                                                                    <td class="CelulaZebra2">
                                                                        <input id="percentualRetencao" name="percentualRetencao" type="text"
                                                                               class="fieldMin style1" size="5" maxlength="9" value="0"
                                                                               onchange="seNaoFloatReset(this, '0.00'); calcularFreteCarreteiro();">&nbsp;%
                                                                        <input name="cartaRetencoes" type="text"
                                                                               id="cartaRetencoes" value="0,00" size="8"
                                                                               maxlength="12"
                                                                               class="fieldMin style1 styleNum"
                                                                               onkeypress="mascara(this, reais)"
                                                                               onBlur="javascript: setZero(this,false);calcularFreteCarreteiro();">
                                                                        <input name="mot_outros_descontos_carta" type="hidden" id="mot_outros_descontos_carta" value="0.00" size="8" maxlength="12">
                                                                        <c:choose>
                                                                            <c:when test="${param.acao eq 'iniciarImportarConhecimentoLote' && configuracao.tipoVlConMotor eq 'f' && configuracao.vlConMotor != 0}">
                                                                                <script>
                                                                                    $('cartaRetencoes').value = colocarVirgula(parseFloat('${configuracao.vlConMotor}'));
                                                                                    readOnly($('percentualRetencao'), 'inputReadOnly8pt');
                                                                                </script>
                                                                            </c:when>
                                                                            <c:when test="${param.acao eq 'iniciarImportarConhecimentoLote' && configuracao.tipoVlConMotor eq 'p' && configuracao.vlConMotor != 0}">
                                                                                <script>
                                                                                    $('percentualRetencao').value = parseFloat('${configuracao.vlConMotor}');
                                                                                    readOnly($('cartaRetencoes'), 'inputReadOnly8pt');
                                                                                </script>
                                                                            </c:when>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td class="celulaZebra2 style1" ${(not configuracao.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}>
                                                                        <input id="abastecimentos" name="abastecimentos" type="text"
                                                                               class="fieldMin style1 inputReadOnly" size="9" maxlength="9" value="0,00"
                                                                               onchange="seNaoFloatReset(this, '0,00')" readonly>
                                                                        <input type="hidden" name="ids_abastecimentos" id="ids_abastecimentos">
                                                                    </td>
                                                                    <td class="CelulaZebra2"><input name="cartaLiquido" type="text" id="cartaLiquido" value="0,00" size="8" maxlength="12" class="inputReadOnly8pt styleNum" readonly onkeypress="mascara(this, reais)" onBlur="javascript: setZero(this,false);calcularFreteCarreteiro();"></td>
                                                                </tr>
                                                                <tr id="trImpostosCarta" name="trImpostosCarta" style="display:none;">
                                                                    <td class="TextoCampos">INSS:</td>
                                                                    <td class="CelulaZebra2">
                                                                        <input name="valorINSSInteg" type="hidden" id="valorINSSInteg" value="0.00" size="8" maxlength="12">
                                                                        <input name="valorINSS" type="text" id="valorINSS" value="0,00" size="8" maxlength="12" class="inputReadOnly8pt style1 styleNum" readonly onBlur="javascript:setZero(this,false);calcularFreteCarreteiro();">
                                                                        <input name="baseINSS" type="hidden" id="baseINSS" value="0,00" size="8" maxlength="12">
                                                                        <input name="aliqINSS" type="hidden" id="aliqINSS" value="0,00" size="8" maxlength="12">
                                                                    </td>
                                                                    <td class="TextoCampos">SEST:</td>
                                                                    <td class="CelulaZebra2">
                                                                        <input name="valorSESTInteg" type="hidden" id="valorSESTInteg" value="0.00" size="8" maxlength="12">
                                                                        <input name="valorSEST" type="text" id="valorSEST" value="0,00" size="8" maxlength="12" class="inputReadOnly8pt style1 styleNum"  onBlur="javascript:setZero(this,false);calcularFreteCarreteiro();" readonly>
                                                                        <input name="baseSEST" type="hidden" id="baseSEST" value="0,00" size="8" maxlength="12">
                                                                        <input name="aliqSEST" type="hidden" id="aliqSEST" value="0,00" size="8" maxlength="12">
                                                                    </td>
                                                                    <td class="TextoCampos">IR:</td>
                                                                    <td class="CelulaZebra2">
                                                                        <input name="valorIRInteg" type="hidden" id="valorIRInteg" value="0.00" size="8" maxlength="12">
                                                                        <input name="valorIR" type="text" id="valorIR" value="0,00" size="8" maxlength="12" class="inputReadOnly8pt style1 styleNum"  onBlur="javascript:setZero(this,false);calcularFreteCarreteiro();" readonly>
                                                                        <input name="baseIR" type="hidden" id="baseIR" value="0,00" size="8" maxlength="12">
                                                                        <input name="aliqIR" type="hidden" id="aliqIR" value="0,00" size="8" maxlength="12">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                                <tr class="celula">
                                                                    <td width="10%">
                                                                        <input type="hidden" name="maxPagContFrete" id="maxPagContFrete" value="0" />
                                                                        <img src="img/add.gif" border="0" onClick="addPagto();" title="Adicionar Pagamentos no Contrato de Frete" class="imagemLink">
                                                                    </td>
                                                                    <td width="12%">Valor</td>
                                                                    <td width="18%">Data</td>
                                                                    <td width="17%">F. Pag</td>
                                                                    <td width="28%">Conta/Ag.Pag.</td>
                                                                    <td width="15%">Doc</td>
                                                                </tr>
                                                                <tbody id="bodyPagamento"></tbody>
                                                                <tr name="trCartaCC" id="trCartaCC" style="display: none">
                                                                    <td class="TextoCampos">C/C.:</td>
                                                                    <td class="TextoCampos"><input name="cartaValorCC" type="text" id="cartaValorCC" value="0,00" size="6" maxlength="12" class="fieldMin" readonly></td>
                                                                    <td class="TextoCampos"><input name="cartaDataCC" type="text" id="cartaDataCC" value="" class="fieldDate" onChange="" size="9" maxlength="10" style="font-size:8pt;"></td>
                                                                    <td class="TextoCampos"><input name="cartaFPagCC" type="hidden" id="cartaFPagCC" value="2"></td>
                                                                    <td class="TextoCampos"><input name="contaCC" type="hidden" id="contaCC" value=""></td>
                                                                    <td class="CelulaZebra2"></td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                                <tr class="celula">
                                                                    <td width="5%">
                                                                        <input type="hidden" name="countDespesaCarta" id="countDespesaCarta" value="0" />
                                                                        <img src="img/add.gif" border="0" onClick="incluiDespesaCarta()" title="Adicionar uma despesa" class="imagemLink">
                                                                    </td>
                                                                    <td colspan="5" width="95%">Despesas de viagem</td>
                                                                </tr>
                                                                <tr id="trDespesaCarta" name="trDespesaCarta" style="display:none;" >
                                                                    <td colspan="6">
                                                                        <input name="fornecedor" type="hidden" id="fornecedor" class="inputReadOnly8pt" size="15" readonly="true" value="Fornecedor">
                                                                        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
                                                                        <input name="idplanocusto_despesa" type="hidden" id="idplanocusto_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="0">
                                                                        <input name="plcusto_descricao_despesa" type="hidden" id="plcusto_descricao_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                                                        <input name="plcusto_conta_despesa" type="hidden" id="plcusto_conta_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                                                        <input name="idplcustopadrao" type="hidden" id="idplcustopadrao" class="inputReadOnly8pt" size="25" readonly="true" value="0">
                                                                        <input name="descricaoplcusto" type="hidden" id="descricaoplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                                                        <input name="contaplcusto" type="hidden" id="contaplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
                                                                        <table width="100%" class="bordaFina">
                                                                            <tbody id="tbDespesaCarta">
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td id="tdViagem" width="50%" style="vertical-align:top;">
                                                <table class="bordaFina" width="100%">
                                                    <tr>
                                                        <td colspan="2" class="tabela">
                                                            <div align="center">
                                                                <input name="chk_adv_automatica" type="checkbox" id="chk_adv_automatica" value="checkbox"> Gerar Adiantamento de viagem para o motorista da casa
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="50%" colspan="2" rowspan="5" style="vertical-align:top;">
                                                            <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                                <tbody id="tbADV">
                                                                    <tr class="celula">
                                                                        <td width="3%" >
                                                                            <img src="img/add.gif" border="0" onClick="incluiADV();" title="Adicionar um adiantamento para o motorista" class="imagemLink">
                                                                            <input type="hidden" name="countDespesaADV" id="countDespesaADV" value="0">
                                                                            <input type="hidden" name="countADV" id="countADV" value="0">
                                                                        </td>
                                                                        <td width="19%" ><div align="center">Valor</div></td>
                                                                        <td width="35%" ><div align="center">Conta</div></td>
                                                                        <td width="23%" ></td>
                                                                        <td width="20%" ><div align="center">Doc</div></td>
                                                                    </tr>
                                                                </tbody>
                                                                <tr>
                                                                    <td colspan="4" class="TextoCampos">
                                                                        Valor Previsto para as Despesas de Viagem: 
                                                                    </td>
                                                                    <td class="CelulaZebra2">
                                                                        <input name="valorPrevistoViagem" type="text" id="valorPrevistoViagem" value="0,00" size="8" maxlength="12" class="fieldMin styleNum" onkeypress="mascara(this, reais)" onBlur="javascript: setZero(this,false);" >                                                                    </td>
                                                                </tr>
                                                                <tr class="celula">
                                                                    <td ><img src="img/add.gif" border="0" onClick="incluiDespesaADV()" title="Adicionar despesa a prazo para o adiantamento de viagem" class="imagemLink"></td>
                                                                    <td colspan="4">Despesas de viagem</td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="5">
                                                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                                            <tbody id="tbDespesaADV">
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>		
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </form>
                            </td>
                        </tr>
                    </table>
                    <input type="hidden" id="rem_obs_fisco">
                    <input type="hidden" id="dest_obs_fisco">
                    <input type="hidden" id="con_obs_fisco">
                    <input type="hidden" id="obs_desc_fisco">
                    <input type="hidden" id="red_obs_fisco">
                    <input type="hidden" id="rem_is_especie_serie_modal"><input type="hidden" id="rem_especie_cliente"><input type="hidden" id="rem_serie_cliente"><input type="hidden" id="rem_modal_cliente">
                    <input type="hidden" id="dest_is_especie_serie_modal"><input type="hidden" id="dest_especie_cliente"><input type="hidden" id="dest_serie_cliente"><input type="hidden" id="dest_modal_cliente">
                    <input type="hidden" id="con_is_especie_serie_modal"><input type="hidden" id="con_especie_cliente"><input type="hidden" id="con_serie_cliente"><input type="hidden" id="con_modal_cliente">
                    <input type="hidden" id="red_is_especie_serie_modal"><input type="hidden" id="red_especie_cliente"><input type="hidden" id="red_serie_cliente"><input type="hidden" id="red_modal_cliente">
                    <input type="hidden" id="rem_gerar_nfse_mesma_cidade"><input type="hidden" id="dest_gerar_nfse_mesma_cidade"><input type="hidden" id="con_gerar_nfse_mesma_cidade">
                    <input type="hidden" id="tipo_rem_gerar_nfse_mesma_cidade"><input type="hidden" id="tipo_dest_gerar_nfse_mesma_cidade"><input type="hidden" id="tipo_con_gerar_nfse_mesma_cidade">
                    <input type="hidden" id="rem_serie_minuta"><input type="hidden" id="dest_serie_minuta"><input type="hidden" id="con_serie_minuta">
                </td>
            </tr>
            <tr class="CelulaZebra2">
                <td height="24" ><center>
                        <input name="botSalvar" type="button" class="botoes" id="botSalvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva();});">
                    </center>
                </td>
            </tr>
        </table>
        <br>
        <!--</form>-->
    </body>
</html>
