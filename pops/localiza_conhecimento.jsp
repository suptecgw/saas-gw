

<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.BeanConsultaConhecimento,
         cfop.BeanCfop,
         conhecimento.orcamento.Cubagem,
         conhecimento.BeanCadConhecimento,
         cliente.BeanCliente,
         marca.BeanCadMarca,
         nucleo.Apoio,
         nucleo.BeanConfiguracao,
         nucleo.impressora.*,
         usuario.BeanUsuario,
         java.text.SimpleDateFormat,
         java.util.Collection,
         net.sf.json.JSONObject,
         java.util.ArrayList,
         com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver,
         com.thoughtworks.xstream.XStream,
         com.sagat.bean.NotaFiscal,         
         java.util.Vector "%>

<%

    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelUserToFilial = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }

    boolean isCancelado = (request.getParameter("isCancelado") == null ? false : Boolean.parseBoolean(request.getParameter("isCancelado")));
    String tipoC =  request.getParameter("tipoConhecimento");

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

// Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String filial = "";
    String operadorConsulta = "";
    String filtrosAdicionais = "";

    campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
            ? request.getParameter("campo") : "emissao_em");
    dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
            : fmt.format(new Date()));
    dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
    filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
    valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("")
            ? request.getParameter("valor") : "");
    operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
            ? request.getParameter("ope") : "1");
    filtrosAdicionais = request.getParameter("tipoConhecimento");


//   Finalizando Cookie

%>

<%  BeanConsultaConhecimento beanconh = null;
    String acao = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
//Carregando as configurações
    cfg.CarregaConfig();

    if (acao.equals("consultar") || acao.equals("iniciar")) {
        beanconh = new BeanConsultaConhecimento();
        beanconh.setConexao(Apoio.getUsuario(request).getConexao());
        beanconh.setCampoDeConsulta(campoConsulta);
        beanconh.setOperador(Integer.parseInt(operadorConsulta));
        beanconh.setValorDaConsulta(valorConsulta);
        BeanUsuario usu = Apoio.getUsuario(request);
        //Se o usuario tiver permissao para lancar conh para outras filiais entao
        //ele pode visualizar os conh. das outras(quando for 0 vai mostrar todas)
        beanconh.setIdFilialConhecimento(Integer.parseInt(filial));
        beanconh.setDtEmissao1(Apoio.paraDate(dataInicial));
        beanconh.setDtEmissao2(Apoio.paraDate(dataFinal));
        beanconh.setFiltrosAdicionais(filtrosAdicionais);
        // a chamada do método Consultar() está lá em mbaixo
    }

    if (acao.equals("obter_nf")) {
        //String resultado = "";
        BeanConsultaConhecimento consNf = new BeanConsultaConhecimento();
        consNf.setConexao(Apoio.getUsuario(request).getConexao());
        Collection lista = consNf.makeNF(Integer.parseInt(request.getParameter("id")));

        if (lista != null) {
            //ResultSet nf = consNf.getResultado();
            //NotaFiscal notaFiscal = null;
            //Collection<NotaFiscal> lista = new ArrayList<NotaFiscal>();

            //while (nf.next()) {

            /*
             resultado += nf.getString("idnota_fiscal") + "!!" //0
             + nf.getString("numero") + "!!" //1
             + nf.getString("serie") + "!!" // 2
             + (nf.getDate("emissao") == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(nf.getDate("emissao"))) + "!!" //3
             + nf.getDouble("valor") + "!!" //4
             + nf.getFloat("vl_base_icms") + "!!" //5
             + nf.getFloat("vl_icms") + "!!" //6
             + nf.getFloat("vl_icms_st") + "!!" //7
             + nf.getFloat("vl_icms_frete") + "!!" // 8
             + nf.getFloat("peso") + "!!"// 9
             + nf.getFloat("volume") + "!!" // 10
             + nf.getString("embalagem") + "!!" // 11
             + nf.getString("conteudo") + "!!" // 12
             + nf.getInt("idconhecimento") + "!!" // 13
             + nf.getString("pedido") + "!!" // 14 
             + nf.getFloat("largura") + "!!" // 15
             + nf.getFloat("altura") + "!!" // 16
             + nf.getFloat("comprimento") + "!!" // 17
             + nf.getFloat("metro_cubico") + "!!" // 18
             + nf.getInt("idmarca") + "!!" // 19
             + nf.getString("desc_marca") + "!!" // 20
             + nf.getString("modelo_veiculo") + "!!" // 21
             + nf.getString("ano_veiculo") + "!!" // 22
             + nf.getInt("cor_veiculo") + "!!" // 23
             + nf.getString("chassi_veiculo") + "!!" // 24
             + nf.getInt("cfop_id") + "!!" // 25
             + nf.getString("cfop") + "!!" // 26
             + nf.getString("chave_acesso") + "!!" // 27
             + nf.getBoolean("is_agendado") + "!!" //28
             + (nf.getDate("data_agenda") != null ? new SimpleDateFormat("dd/MM/yyyy").format(nf.getDate("data_agenda")) : "") + "!!" // 29
             + nf.getString("hora_agenda") + "!!" //30
             + nf.getString("obs_agenda") + "!!" // 31
             + (nf.getDate("previsao_entrega_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(nf.getDate("previsao_entrega_em")) : "") + "!!" // 32
             + nf.getString("previsao_entrega_as") + "!!" //33
             + nf.getString("destinatario") + "!!" //34
             + nf.getString("iddestinatario") + "!!" //35
             + nf.getString("is_importada_edi") + "!! " //36
             + "!A!A";
             */

            //LOG.debug("resultado " + resultado);
            //}
            XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
            xstream.setMode(XStream.NO_REFERENCES);
            xstream.alias("notaFiscal", NotaFiscal.class);
            xstream.alias("cubagem", Cubagem.class);
            xstream.alias("marcaVeiculo", BeanCadMarca.class);
            xstream.alias("cfop", BeanCfop.class);
            xstream.alias("destinatario", BeanCliente.class);
            String json = xstream.toXML(lista);
            response.getWriter().append(json);

            //response.getWriter().append(resultado);
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().flush();
        response.getWriter().close();
    }





%>

<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="java.util.Date"%>
<%@page import="nucleo.EnviaEmail"%>
<%@page import="java.util.Locale"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>


<html>
    <head>
        <script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript"  src="../script/funcoes.js" type="text/javascript"></script>
        <script language="JavaScript"  src="../script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript"  src="../script/jquery.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" >
            jQuery.noConflict();
            var totalCubagem = 0;
            function retornapai(id){

                var pai = window.opener.document;
                var root = window.opener;

                pai.getElementById("id_dev_reen").value = id;

                pai.getElementById("tipoproduto").value = $("tipoproduto_"+id).value;
                
                pai.getElementById("cub_base").value = $("cub_base_"+id).value;
                pai.getElementById("cub_altura").value = $("cub_altura_"+id).value;
                pai.getElementById("cub_largura").value = $("cub_largura_"+id).value;
                pai.getElementById("cub_comprimento").value = $("cub_comprimento_"+id).value;
                pai.getElementById("cub_metro").value = $("cub_metro_"+id).value;
                pai.getElementById("qtde_entregas").value = $("qtde_entregas_"+id).value;
                pai.getElementById("tipoveiculo").value = $("tipoveiculo_"+id).value;

                pai.getElementById("client_tariff_id").value = $("client_tariff_id_"+id).value;
                pai.getElementById("valor_taxa_fixa").value = $("valor_taxa_fixa_"+id).value;
                pai.getElementById("valor_itr").value = $("valor_itr_"+id).value;
                pai.getElementById("valor_despacho").value = $("valor_despacho_"+id).value;
                pai.getElementById("valor_ademe").value = $("valor_ademe_"+id).value;
                pai.getElementById("valor_peso").value = $("valor_peso_"+id).value;
                pai.getElementById("valor_sec_cat").value = $("valor_sec_cat_"+id).value;
                pai.getElementById("valor_outros").value = $("valor_outros_"+id).value;
                pai.getElementById("valor_gris").value = $("valor_gris_"+id).value;
                pai.getElementById("valor_pedagio").value = $("valor_pedagio_"+id).value;
                pai.getElementById("valor_desconto").value = $("valor_desconto_"+id).value;
                pai.getElementById("base_calculo").value = $("base_calculo_"+id).value;
                pai.getElementById("aliquota").value = $("aliquota_"+id).value;
                pai.getElementById("vlicmsbarreira").value = $("vlicmsbarreira_"+id).value;
                pai.getElementById("numeroCarga").value = $("numero_carga_"+id).value;
                pai.getElementById("pedido_cliente").value = $("pedido_Cliente_"+id).value;
                //foi retirado daqui e colocado no final, por causa que ele chama alteratipotaxa e chama getStIcmsConsig, onde retirava essa alterado do stIcms.
//                pai.getElementById("stIcms").value = $("st_icms_"+id).value;
                //Coleta
                pai.getElementById("idcoleta").value = $("idcoleta_"+id).value;
                pai.getElementById("numcoleta").innerHTML = $("numcoleta_"+id).value;

                //cidade origem
                pai.getElementById("idcidadeorigem").value = $("idcidadeorigem_"+id).value;
                pai.getElementById("cid_origem").value = $("cid_origem_"+id).value;
                pai.getElementById("uf_origem").value = $("uf_origem_"+id).value;

                //cidade destino
                pai.getElementById("idcidadedestino").value = $("idcidadedestino_"+id).value;
                pai.getElementById("cid_destino").value = $("cid_destino_"+id).value;
                pai.getElementById("uf_destino").value = $("uf_destino_"+id).value;

                //Rota
                pai.getElementById("id_rota_viagem").value = $("id_rota_viagem_"+id).value;
                pai.getElementById("rota_viagem").value = $("rota_viagem_"+id).value;
                pai.getElementById("distancia_km").value = $("distancia_km_"+id).value;

                
                //Dados do Container
                
                pai.getElementById("numero_container").value = $("numero_container_"+id).value;
                pai.getElementById("genset").value = $("numero_genset_"+id).value;
                pai.getElementById("booking").value = $("numero_booking_"+id).value;
                pai.getElementById("lacre_container").value = $("numero_lacre_"+id).value;
                pai.getElementById("peso_container").value = $("peso_container_"+id).value;
                pai.getElementById("valor_container").value = $("valor_container_"+id).value;
                pai.getElementById("valor_genset").value = $("valor_ganset_"+id).value;
                pai.getElementById("horimetro_inicial").value = $("genset_horimetro_inicial_"+id).value;
                pai.getElementById("horimetro_final").value = $("genset_horimetro_final_"+id).value;
                pai.getElementById("direcaoAquaviario").value = $("direcao_aquaviario_"+id).value;
                pai.getElementById("viagem_container").value = $("numero_viagem_navio_"+id).value;
                pai.getElementById("tipoNavegacao").value = $("tipo_navegacao_aquaviario_"+id).value;
                pai.getElementById("idnavio").value = $("navio_id_"+id).value;
                pai.getElementById("navio").value = $("navio_"+id).value;
                pai.getElementById("porto_embarque_id").value = $("porto_embarque_id_"+id).value;
                pai.getElementById("porto_embarque").value = $("porto_embarque_"+id).value;
                pai.getElementById("porto_destino_id").value = $("porto_destino_id_"+id).value;
                pai.getElementById("porto_destino").value = $("porto_destino_"+id).value;
                pai.getElementById("porto_transbordo_id").value = $("porto_transbordo_id_"+id).value;
                pai.getElementById("porto_transbordo").value = $("porto_transbordo_"+id).value;
                pai.getElementById("idarmador").value = $("armador_id_"+id).value;
                pai.getElementById("armador").value = $("armador_"+id).value;
                pai.getElementById("idterminal").value = $("terminal_id_"+id).value;
                pai.getElementById("terminal").value = $("terminal_"+id).value;
                pai.getElementById("tipo_container").value = $("tipo_container_"+id).value;
                pai.getElementById("st_credito_presumido").value = $("ct_percentual_credito_presumido_"+id).value;


                // Criado a variavel confirmaNotas para validar o confirm de notas fiscais true ou false.
                var confirmaNotas = confirm("Deseja acrescentar as notas fiscais?");
                
                // Inicio do bloco para chamar o confirm, para inversão do Rem e Dest
                var tipoConhecimento = $("tipoConhecimento").value;                
                var confirmaReversao = null;
                if(tipoConhecimento == 'd'){
                    confirmaReversao = confirm("Deseja inverter o Remetente e Destinatário?");
                }
                // Criado a variavel isUtilizarAjaxRemDest para validar o confirm da Inversão de Rem e Dest true ou false.
                var isUtilizarAjaxRemDest =  (confirmaReversao != null && confirmaReversao);
                // Fim do bloco
                    //remetente                    
                    if (!isUtilizarAjaxRemDest && $("idremetente_"+id).value != "0"){                        
                            pai.getElementById("rem_codigo").value = $("idremetente_"+id).value;
                            pai.getElementById("idremetente").value = $("idremetente_"+id).value;
                            pai.getElementById("rem_rzs").value = $("rem_rzs_"+id).value;
                            pai.getElementById("rem_cidade").value = $("rem_cidade_"+id).value;
                            pai.getElementById("rem_uf").value = $("rem_uf_"+id).value;
                            pai.getElementById("rem_cnpj").value = $("rem_cnpj_"+id).value;
                            pai.getElementById("rem_tipotaxa").value = $("rem_tipotaxa_"+id).value;
                            pai.getElementById("idvenremetente").value = $("idvenremetente_"+id).value;
                            pai.getElementById("idcidadeorigem").value = $("idcidadeorigem_"+id).value;
                            pai.getElementById("remidcidade").value = $("idcidadeorigem_"+id).value;
                            pai.getElementById("remtipofpag").value = $("remtipofpag_"+id).value;
                            pai.getElementById("remtipoorigem").value = $("remtipoorigem_"+id).value;
                            pai.getElementById("rem_endereco").value = $("rem_endereco_"+id).value;
                            pai.getElementById("remtabelaproduto").value = $("remtabelaproduto_"+id).value;
                            pai.getElementById("rem_is_bloqueado").value = $("rem_is_bloqueado_"+id).value;
                            pai.getElementById("rem_tabela_remetente").value = $("rem_tabela_remetente_"+id).value;
                            pai.getElementById("rem_analise_credito").value = $("rem_analise_credito_"+id).value;
                            pai.getElementById("rem_valor_credito").value = $("rem_valor_credito_"+id).value;
                            pai.getElementById("pauta_remetente").value = $("pauta_remetente_"+id).value;
                            pai.getElementById("rem_inclui_peso_container").value = $("rem_inclui_peso_container_"+id).value;
                            pai.getElementById("rem_tipo_cfop").value = $("rem_tipo_cfop_"+id).value;
                            pai.getElementById("rem_st_mg").value = $("rem_st_mg_"+id).value;
                            pai.getElementById("utilizatipofretetabelarem").value = $("utilizatipofretetabelarem_"+id).value;
                            pai.getElementById("is_utilizar_tipo_frete_tabela").value = $("utilizatipofretetabelarem_"+id).value;
                            pai.getElementById("is_frete_dirigido").value = $("rem_is_frete_dirigido_"+id).value;
                            pai.getElementById("st_rem_credito_presumido").value = $("st_rem_credito_presumido_"+id).value;
                            pai.getElementById("rem_tipo_tributacao").value = $("rem_tipo_tributacao_"+id).value;
                            pai.getElementById("tipo_arredondamento_peso_rem").value = $("rem_tipo_arredondamento_"+id).value;
                            
                            
                    }

                    //destinatário
                    if (!isUtilizarAjaxRemDest && $("iddestinatario_"+id).value != "0"){                        
                            pai.getElementById("des_codigo").value = $("iddestinatario_"+id).value;
                            pai.getElementById("iddestinatario").value = $("iddestinatario_"+id).value;
                            pai.getElementById("dest_rzs").value = $("dest_rzs_"+id).value;
                            pai.getElementById("dest_cidade").value = $("dest_cidade_"+id).value;
                            pai.getElementById("dest_uf").value = $("dest_uf_"+id).value;
                            pai.getElementById("dest_insc_est").value = $("dest_ie_"+id).value;
                            pai.getElementById("dest_cnpj").value = $("dest_cnpj_"+id).value;
                            pai.getElementById("dest_tipotaxa").value = $("dest_tipotaxa_"+id).value;
                            pai.getElementById("desttipofpag").value = $("desttipofpag_"+id).value;
                            pai.getElementById("aliquota").value = $("aliquota_"+id).value;
                            pai.getElementById("desttipoorigem").value = $("desttipoorigem_"+id).value;
                            pai.getElementById("desttabelaproduto").value = $("desttabelaproduto_"+id).value;
                            pai.getElementById("dest_endereco").value = $("dest_endereco_"+id).value;
                            pai.getElementById("endereco_id").value = $("dest_endereco_id_"+id).value;
                            pai.getElementById("des_analise_credito").value = $("des_analise_credito_"+id).value;
                            pai.getElementById("des_valor_credito").value = $("des_valor_credito_"+id).value;
                            pai.getElementById("des_is_bloqueado").value = $("des_is_bloqueado_"+id).value;
                            pai.getElementById("des_tabela_remetente").value = $("des_tabela_remetente_"+id).value;
                            pai.getElementById("pauta_destinatario").value = $("pauta_destinatario_"+id).value;
                            pai.getElementById("des_inclui_peso_container").value = $("des_inclui_peso_container_"+id).value;
                            pai.getElementById("utilizatipofretetabeladest").value = $("utilizatipofretetabeladest_"+id).value;
                            pai.getElementById("is_utilizar_tipo_frete_tabela").value = $("utilizatipofretetabeladest_"+id).value;
                            pai.getElementById("tipo_produto_destinatario_id").value = $("tipo_produto_destinatario_id_"+id).value;
                            pai.getElementById("st_des_credito_presumido").value = $("st_des_credito_presumido_"+id).value;
                            pai.getElementById("dest_tipo_tributacao").value = $("des_tipo_tributacao_"+id).value;
                            pai.getElementById("tipo_arredondamento_peso_dest").value = $("des_tipo_arredondamento_"+id).value;
                            
                    }
                    // Variavel isUtilizarAjaxRemDest se for true, faz a inversão Rem e Dest, caso contrario faz o processo normal.
                    if(isUtilizarAjaxRemDest){
                        var idRem = $("idremetente_"+id).value;
                        var idDes = $("iddestinatario_"+id).value;
                        var idCon = $("idconsignatario_"+id).value;
                        //vai carregar a cubagem do destinatario quando acontecer a inversão do remetente/destinatario
                        if (idRem == idCon) {
                            pai.getElementById("dest_cub_base").value = $("cub_base_"+id).value;
                        } else if(idDes == idCon){
                            pai.getElementById("rem_cub_base").value = $("cub_base_"+id).value;
                        }
                        // chama função inverterRemDes na tela pai - jspcadconhecimento                        
                        var consignatarioTerceiro = ($("idconsignatario_"+id).value!=$("idremetente_"+id).value && $("idconsignatario_"+id).value!= $("iddestinatario_"+id).value);
                        window.opener.inverterRemDes(idRem,idDes, consignatarioTerceiro);                        
                        
                        //Caso precise inverter, deve inverter também as cidades de origem e destino do CT-e original.
                        //Por isso estou fazendo a alteração aqui
                        //cidade origem
                        setTimeout(function(){
                            pai.getElementById("idcidadeorigem").value = $("idcidadedestino_"+id).value;
                            pai.getElementById("cid_origem").value = $("cid_destino_"+id).value;
                            pai.getElementById("uf_origem").value = $("uf_destino_"+id).value;

                            //cidade destino
                            pai.getElementById("idcidadedestino").value = $("idcidadeorigem_"+id).value;
                            pai.getElementById("cid_destino").value = $("cid_origem_"+id).value;
                            pai.getElementById("uf_destino").value = $("uf_origem_"+id).value;
                        },2500)
;
                    }
                
                  //Redespacho
                    if ($("idredespacho_"+id).value != "0"){
                        pai.getElementById("ck_redespacho").checked = true;
                        window.opener.redespacho(true);
                        if ($("is_redespacho_pago_"+id).value == "t" || $("is_redespacho_pago_"+id).value == "true"){
                            pai.getElementById("is_redespacho_pago").checked = true;
                        }
                        
                        //Adicionando as chaves de acesso do redespacho vindo do banco separado por virgula.
                        var chaves = $("chave_acesso_redespacho_"+id).value.replace("{","").replace("}","");
                        root.montarDivChaveAcesso();
                        for (var i = 0; i < chaves.split(",").length; i++) {
                            if (root.addDomChavesAcesso != null) {
                                root.addDomChavesAcesso(chaves.split(",")[i],i);
                            }
                        }
                        root.salvarChaves(chaves.split(",").length);
                        pai.getElementById("promptRedChave").style.display='none';
                        root.blockInterface(false);
                        
                        pai.getElementById("redespacho_valor").value = $("redespacho_valor_"+id).value;
                        pai.getElementById("redespacho_valor_icms").value = $("redespacho_valor_icms_"+id).value;
                        pai.getElementById("ctoredespacho").value = $("ctoredespacho_"+id).value;
                        pai.getElementById("red_codigo").value = $("idredespacho_"+id).value;
                        pai.getElementById("idredespacho").value = $("idredespacho_"+id).value;
                        pai.getElementById("red_rzs").value = $("red_rzs_"+id).value;
//                        pai.getElementById("red_chave_acesso").value = $("chave_acesso_redespacho_"+id).value.replace("{","").replace("}","");
                        pai.getElementById("red_cidade").value = $("red_cidade_"+id).value;
                        pai.getElementById("red_uf").value = $("red_uf_"+id).value;
                        pai.getElementById("red_cnpj").value = $("red_cnpj_"+id).value;
                        pai.getElementById("red_tipotaxa").value = $("red_tipotaxa_"+id).value;
                        pai.getElementById("redtipoorigem").value = $("redtipoorigem_"+id).value;
                        pai.getElementById("red_analise_credito").value = $("red_analise_credito_"+id).value;
                        pai.getElementById("red_valor_credito").value = $("red_valor_credito_"+id).value;
                        pai.getElementById("red_is_bloqueado").value = $("red_is_bloqueado_"+id).value;
                        pai.getElementById("red_tabela_remetente").value = $("red_tabela_remetente_"+id).value;
                        pai.getElementById("pauta_redespacho").value = $("pauta_redespacho_"+id).value;
                        pai.getElementById("red_inclui_peso_container").value = $("red_inclui_peso_container_"+id).value;
                        pai.getElementById("red_tipo_cfop").value = $("red_tipo_cfop_"+id).value;
                        pai.getElementById("utilizatipofretetabelared").value = $("utilizatipofretetabelared_"+id).value;
                        pai.getElementById("is_utilizar_tipo_frete_tabela").value = $("utilizatipofretetabelared_"+id).value;
                        pai.getElementById("st_red_credito_presumido").value = $("st_red_credito_presumido_"+id).value;
                        pai.getElementById("red_tipo_tributacao").value = $("red_tipo_tributacao_"+id).value;
                        pai.getElementById("tipo_arredondamento_peso_red").value = $("red_tipo_arredondamento_"+id).value;
                        
//                      expedidor
                        pai.getElementById("idexpedidor").value = $("exp_id_"+id).value;
//                      recebedor
                        pai.getElementById("idrecebedor").value = $("rec_id_"+id).value;
                        //faz a validação para colocar se o tipo de repespacho é expedição ou recebimento - historia 3206
                        if ($("exp_id_"+id).value == $("idredespacho_"+id).value) {
                            pai.getElementById("exp").checked = true;
                        }
                        if ($("rec_id_"+id).value == $("idredespacho_"+id).value) {
                            pai.getElementById("rec").checked = true;
                        }
                    }
                    
                //Dados do cte - caso tenha um expedidor ou recebedor vai carregar as informações - historia 3206
                if ($("exp_codigo_"+id) != null && $("exp_codigo_"+id).value != 0) {
                    pai.getElementById("idexpedidor").value = $("exp_codigo_"+id).value;
                    pai.getElementById("exp_codigo").value = $("exp_codigo_"+id).value;
                    pai.getElementById("exp_rzs").value = $("exp_rzs_"+id).value;
                    pai.getElementById("exp_cidade").value = $("exp_cidade_"+id).value;
                    pai.getElementById("exp_uf").value = $("exp_uf_"+id).value;
                    pai.getElementById("exp_cnpj").value = $("exp_cnpj_"+id).value;
                    pai.getElementById("st_exp_credito_presumido").value = $("st_exp_credito_presumido_"+id).value;
                }
                if ($("rec_codigo_"+id) != null && $("rec_codigo_"+id).value != 0) {
                    pai.getElementById("idrecebedor").value = $("rec_codigo_"+id).value;
                    pai.getElementById("rec_codigo").value = $("rec_codigo_"+id).value;
                    pai.getElementById("rec_rzs").value = $("rec_rzs_"+id).value;
                    pai.getElementById("rec_cidade").value = $("rec_cidade_"+id).value;
                    pai.getElementById("rec_uf").value = $("rec_uf_"+id).value;
                    pai.getElementById("rec_cnpj").value = $("rec_cnpj_"+id).value;
                    pai.getElementById("st_rec_credito_presumido").value = $("st_rec_credito_presumido_"+id).value;
                }
                    
                //consignatário
                if ($("is_con_pago_"+id).value != "f"){
                    pai.getElementById("fretepago_sim").checked = true;
                    pai.getElementById("fretepago_nao").checked = false;
                }else{
                    pai.getElementById("fretepago_sim").checked = false;
                    pai.getElementById("fretepago_nao").checked = true;
                }
                if ($("idconsignatario_"+id).value != "0"){
                    pai.getElementById("idconsignatario").value = $("idconsignatario_"+id).value;
                    pai.getElementById("con_codigo").value = $("idconsignatario_"+id).value;
                    pai.getElementById("con_rzs").value = $("con_rzs_"+id).value;
                    pai.getElementById("con_cidade").value = $("con_cidade_"+id).value;
                    pai.getElementById("con_uf").value = $("con_uf_"+id).value;
                    pai.getElementById("con_cnpj").value = $("con_cnpj_"+id).value;
                    pai.getElementById("pauta_consignatario").value = $("pauta_consignatario_"+id).value;
                    pai.getElementById("con_inclui_peso_container").value = $("con_inclui_peso_container_"+id).value;
                    pai.getElementById("con_tipo_cfop").value = $("con_tipo_cfop_"+id).value;
                    pai.getElementById("st_cli_credito_presumido").value = $("st_cli_credito_presumido_"+id).value;
                }
                pai.getElementById("tipotaxa").value = $("tipotaxa_"+id).value;

                if($("idvendedor_"+id).value != "0"){
                    pai.getElementById("idvendedor").value = $("idvendedor_"+id).value;
                    pai.getElementById("ven_rzs").value = $("ven_rzs_"+id).value;
                    pai.getElementById("comissao_vendedor").value = $("comissao_vendedor"+id).value;
                }
                pai.getElementById("contipofpag").value = $("contipofpag_"+id).value;
                pai.getElementById("tipofpag").value = $("tipofpag_"+id).value;
                pai.getElementById("contipoorigem").value = $("contipoorigem_"+id).value;
                pai.getElementById("contabelaproduto").value = $("contabelaproduto_"+id).value;
                pai.getElementById("con_analise_credito").value = $("con_analise_credito_"+id).value;
                pai.getElementById("con_valor_credito").value = $("con_valor_credito_"+id).value;
                pai.getElementById("con_is_bloqueado").value = $("con_is_bloqueado_"+id).value;
                pai.getElementById("con_tabela_remetente").value = $("con_tabela_remetente_"+id).value;
                
                pai.getElementById("utilizatipofretetabelaconsig").value = $("utilizatipofretetabelaconsig_"+id).value;
                pai.getElementById("is_utilizar_tipo_frete_tabela").value = $("utilizatipofretetabelaconsig_"+id).value;
                
//                pai.getElementById("orcamento_id").value = $("orcamento_id_"+id).value;
//                pai.getElementById("numero_orcamento").value = $("orcamento_numero_"+id).value;
//                pai.getElementById("peso_orcamento").value = $("peso_orcamento_"+id).value;
//                pai.getElementById("volume_orcamento").value = $("volume_orcamento_"+id).value;
//                pai.getElementById("mercadoria_orcamento").value = formatoMoeda($("mercadoria_orcamento_"+id).value);
//                pai.getElementById("cubagem_orcamento").value = $("cubagem_orcamento_"+id).value;
                pai.getElementById("con_tipo_tributacao").value = $("con_tipo_tributacao_"+id).value;
                pai.getElementById("tipo_arredondamento_peso_con").value = $("con_tipo_arredondamento_"+id).value;



                //Dados do motorista
                pai.getElementById("idmotorista").value = $("id_motorista_"+id).value;
                pai.getElementById("motor_nome").value = $("motorista_"+id).value;
                pai.getElementById("idveiculo").value = $("id_veiculo_"+id).value;
                pai.getElementById("vei_placa").value = $("veiculo_"+id).value;
                pai.getElementById("idcarreta").value = $("id_carreta_"+id).value;
                pai.getElementById("car_placa").value = $("carreta_"+id).value;
                pai.getElementById("idbitrem").value = $("id_bitrem_"+id).value;
                pai.getElementById("bi_placa").value = $("bitrem_"+id).value;
                
                var obs = "";
                var valorFrete = parseFloat($("total_"+id).value);
                var valorIcms =  (parseFloat($("base_calculo_"+id).value) * parseFloat($("aliquota_"+id).value) / 100).toFixed(2);

                var valorFreteMinimo = parseFloat($("valor_frete_minimo_"+id).value);
                if (<%=isCancelado%>){
                    pai.getElementById("obs_desc").value = $("observacao_"+id).value;
                    window.opener.getObs();
                }else{
                    if ($("tipoConhecimento").value == "c"){
                        obs = "Complemento do CTRC: ";
                    }else if ($("tipoConhecimento").value == "r"){
                        obs = "Reentrega do CTRC: ";
                        if ($("incluirIcms_"+id).value == "t" ||$("incluirIcms_"+id).value == "true"){
                            valorFrete = (parseFloat(valorFrete) - parseFloat(valorIcms)).toFixed(2);
                        }
                        valorFrete = (valorFrete * parseFloat($("valorReentrega_"+id).value)/100);
                    }else if ($("tipoConhecimento").value == "s"){
                        obs = "Substituição do CTRC: ";
                        if ($("incluirIcms_"+id).value == "t" ||$("incluirIcms_"+id).value == "true"){
                            valorFrete = (parseFloat(valorFrete) - parseFloat(valorIcms)).toFixed(2);
                        }
                        valorFrete = (valorFrete);
                    }else if ($("tipoConhecimento").value == "a"){
                        obs = "Anulação do CTRC: ";
                        if ($("incluirIcms_"+id).value == "t" ||$("incluirIcms_"+id).value == "true"){
                            valorFrete = (parseFloat(valorFrete) - parseFloat(valorIcms)).toFixed(2);
                        }
                        valorFrete = (valorFrete);
                    }else if($("tipoConhecimento").value == "i"){
                        obs = "Diária referente a CTRC: ";
                        if ($("incluirIcms_"+id).value == "t" ||$("incluirIcms_"+id).value == "true"){
                            valorFrete = (parseFloat(valorFrete) - parseFloat(valorIcms)).toFixed(2);
                        }
                    }else{
                        obs = "Devolução do CTRC: ";
                        if ($("incluirIcms_"+id).value == "t" ||$("incluirIcms_"+id).value == "true"){
                            valorFrete = (parseFloat(valorFrete) - parseFloat(valorIcms)).toFixed(2);
                        }
                        valorFrete = (valorFrete * parseFloat($("valorDevolucao_"+id).value)/100);
                    }
                    valorFrete = (valorFrete < valorFreteMinimo ? valorFreteMinimo  : valorFrete);
                    pai.getElementById("valor_frete").value = formatoMoeda(valorFrete);
                    pai.getElementById("obs_lin1").value = obs + $("numero_"+id).value;
                }

                if (<%=isCancelado%>){
                    window.opener.alteraTipoTaxa($("tipotaxa_"+id).value);
                }
                window.opener.getPautaFiscalConhecimento();
                
                // variavel confirmaNotas se for true, adiciona notas, se fo false não adiciona.
                    pai.getElementById("vlmercadoria").value = $("valor_nf_"+id).value;
                    pai.getElementById("peso").value = $("valor_peso_nf_"+id).value;
                    pai.getElementById("volume").value = $("volume_nf_"+id).value;
                if (confirmaNotas){
                    viewNf(id);
                    //alert('Notas fiscais carregadas com sucesso.');
                }else{
                    //alert('Descobrir pq n esta carregando');
                }
                totalCubagem = (parseFloat(totalCubagem) == parseFloat(0) ? parseFloat(pai.getElementById("cub_metro").value) : totalCubagem);
                if (parseFloat(totalCubagem) > 0){
                    pai.getElementById("cub_metro").value = totalCubagem;
                }else{
                    pai.getElementById("cub_metro").value = $("cub_metro_"+id).value;
                }
                var xBase = $("cub_base_"+id).value;
                var pesoCubado = 0;
                if (xBase != 0){
                    if (pai.getElementById("tipoTransporte").value == "a"){
                        pesoCubado = (parseFloat(totalCubagem) * parseFloat(1000000)) / parseFloat(xBase);
                    }else{
                        pesoCubado = xBase * totalCubagem;
                    }
                    pesoCubado = parseFloat(pesoCubado);
                }
                pai.getElementById("cub_peso").value = pesoCubado;
                window.opener.calculaPesoTaxadoCtrc();

                window.opener.recalcular(false);

                //window.opener.alterouCampoDependente("cub_comprimento");
                window.opener.pagtoAvista();
                var total = pai.getElementById("total").value;
                pai.getElementById("valor_taxa_fixa").value =  "0.00";
                pai.getElementById("valor_itr").value =  "0.00";
                pai.getElementById("valor_despacho").value =  "0.00";
                pai.getElementById("valor_ademe").value =  "0.00";
                pai.getElementById("valor_peso").value =  "0.00";
//                pai.getElementById("valor_frete").value =  total; --COMENTADO POIS DOBRAVA O VALOR DO CONHECIMENTO.
                pai.getElementById("valor_sec_cat").value =  "0.00";
                pai.getElementById("valor_outros").value =  "0.00";
                pai.getElementById("valor_gris").value =  "0.00";
                pai.getElementById("valor_pedagio").value =  "0.00";
                pai.getElementById("valor_desconto").value =  "0.00";
                pai.getElementById("icms").value =  "0.00";
                pai.getElementById("vlicmsbarreira").value =  "0.00";
                pai.getElementById("total").value = total;

                pai.getElementById("reducao_base_icms").value = $("reducao_base_icms_"+id).value;

                if ($("incluirIcms_"+id).value == "t" ||$("incluirIcms_"+id).value == "true"){
                    pai.getElementById("incluirIcms").checked = true;
                    pai.getElementById("addicms").value = true;
                }

                if ($("incluirFederais_"+id).value == "t" ||$("incluirFederais_"+id).value == "true"){
                    pai.getElementById("incluirFederais").checked = true;
                }

                if (<%=isCancelado%>){
                    window.opener.alteraTipoTaxa($("tipotaxa_"+id).value);
                }

                window.opener.atribuiCfopPadrao();
                
                //foi retiardo la de cima por causa que é chamado o alteratipotaxa que chama getStIcmsConsig, onde retirava o valor setado aqui.
                pai.getElementById("stIcms").value = $("st_icms_"+id).value;
                    
                window.opener.recalcular(false);
                window.opener.localizaOrcamento($("orcamento_id_"+id).value);
            }

            function fecharJanela(){               
               setTimeout("window.close();", 5000);   
            }
            

            function viewNf(id){
      function e(transport){
                    var textoresposta = transport.responseText;     
        
                    if (textoresposta == "" || textoresposta == "load=0") {
                        return alert("Erro ao carregar as notas do conhecimento ");
                    }else{
             
                        var lista = jQuery.parseJSON(textoresposta);
                        var notaFiscais = lista.list[0].notaFiscal;
                        var notaFiscal;
                        var length = (notaFiscais.length == undefined ? 1 : notaFiscais.length);
                        
                        for(var i = 0; i < length; i++){
                            if(length > 1){
                                notaFiscal = notaFiscais[i];
                            }else{
                                notaFiscal = notaFiscais;
                            }
                            
                            var cubagem;
                            var lengthCub=0;
                            var cubagens;

                            if(notaFiscal.cubagens != ""){
                                cubagens = notaFiscal.cubagens[0].cubagem;
                                lengthCub = (cubagens.length == undefined ? 1 : cubagens.length);
                            }
                            //antes de chamar o addNoteLocalizarConhecimento, pego os valores setados no retorna pai. Quando era adicionado a nota no conhecimento estava pegando sempre a cubagem da nota.
                            var altura = window.opener.document.getElementById("cub_altura").value;
                            var largura = window.opener.document.getElementById("cub_largura").value;
                            var comprimento = window.opener.document.getElementById("cub_comprimento").value;
                            var metro = window.opener.document.getElementById("cub_metro").value;
                            
                            var prefix = window.opener.addNoteLocalizarConhecimento("0",
                            //notaFiscal.idnotafiscal,
                            notaFiscal.numero+"",
                            notaFiscal.serie+"",
                            formatDateJSON(notaFiscal.emissao)+"",
                            formatoMoeda(notaFiscal.valor)+"",
                            formatoMoeda(notaFiscal.vl_base_icms)+"",
                            formatoMoeda(notaFiscal.vl_icms)+"",
                            formatoMoeda(notaFiscal.vl_icms_st)+"",
                            formatoMoeda(notaFiscal.vl_icms_frete)+"",
                            formatoMoeda(notaFiscal.peso)+"",
                            formatoMoeda(notaFiscal.volume)+"",
                            notaFiscal.embalagem+"",
                            notaFiscal.conteudo+"",
                            //($("isQuitado_"+id).value == "true" || $("isCteBloqueado_"+id).value == "true" ? "true" : "false"),
                            notaFiscal.idconhecimento+"",
                            notaFiscal.pedido+"",
                            formatoMoeda(notaFiscal.largura)+"",
                            formatoMoeda(notaFiscal.altura)+"",
                            formatoMoeda(notaFiscal.comprimento)+"",
                            formatoMoeda(notaFiscal.metroCubico)+"",
                            notaFiscal.marcaVeiculo.idmarca+"",
                            notaFiscal.marcaVeiculo.descricao+"",
                            notaFiscal.modeloVeiculo+"",
                            notaFiscal.anoVeiculo+"",
                            notaFiscal.corVeiculo+"",
                            notaFiscal.chassiVeiculo+"",
                            notaFiscal.cfop.idcfop+"",
                            notaFiscal.cfop.descricao+"",
                            notaFiscal.chaveNFe+"",
                            notaFiscal.agendado+"",
                            formatDateJSON(notaFiscal.dataAgenda)+"",
                            notaFiscal.horaAgenda+"",
                            notaFiscal.observacaoAgenda+"",
                            formatDateJSON(notaFiscal.PrevisaoEm)+"",
                            notaFiscal.PrevisaoAs+"",                                    
                            notaFiscal.destinatario.idcliente+"",
                            notaFiscal.destinatario.razaosocial+"",
                            notaFiscal.importadaEdi+"",
                            lengthCub, notaFiscal.tipoDocumento
                        );
                            if(notaFiscal.cubagens != ""){
                                for(var j = 0; j < lengthCub; j++){
                                    if(lengthCub > 1){
                                        cubagem = cubagens[j];
                                    }else{
                                        cubagem = cubagens;
                                    }

                                    window.opener.addUpdateNotaFiscal3('trNote'+prefix,
                                    //notaFiscal.idnotafiscal,
                                    "0",
                                    "0",
                                    prefix,
                                    cubagem.metroCubico,
                                    formatoMoeda(cubagem.altura),
                                    formatoMoeda(cubagem.largura),
                                    formatoMoeda(cubagem.comprimento),
                                    formatoMoeda(cubagem.volume),
                                    cubagem.etiqueta,
                                    j
                                );
                                    totalCubagem += cubagem.metroCubico;
                                }
                            }
                            //antes de chamar o addNoteLocalizarConhecimento, pego os valores setados no retorna pai. Quando era adicionado a nota no conhecimento estava pegando sempre a cubagem da nota.
                            if (notaFiscal.altura == 0 && notaFiscal.largura == 0 && notaFiscal.comprimento == 0 && notaFiscal.largura == 0) {
                                window.opener.document.getElementById("cub_altura").value = altura;
                                window.opener.document.getElementById("cub_largura").value = largura;
                                window.opener.document.getElementById("cub_comprimento").value = comprimento;
                                window.opener.document.getElementById("cub_metro").value = metro;
                            }
                        }

                        /*
                        var resp = textoresposta.split("!A!A");
                        //alert("aaa " + resp.length);
                        for(var i = 0; i < resp.length  ; i++){
                            //alert("aaa " + i);
                            if (resp[i] != null){
                                var resp1 = resp[i].split("!!");
                                //alert("aaa " + resp1);
                                if (resp1[0] != null){
                                    window.opener.addNoteLocalizarConhecimento("0",
                                    resp1[1],resp1[2],
                                    resp1[3],resp1[4],resp1[5],resp1[6],resp1[7],
                                    resp1[8],resp1[9],resp1[10],resp1[11],resp1[12],resp1[13],
                                    //($("isQuitado_"+id).value == "true" || $("isCteBloqueado_"+id).value == "true" ? "true" : "false"),
                                    resp1[14],resp1[15],resp1[16],resp1[17],resp1[18],
                                    resp1[19],resp1[20],resp1[21],resp1[22],resp1[23],resp1[24],
                                    resp1[25],resp1[26],resp1[27],resp1[28],resp1[29],
                                    resp1[30],resp1[31],resp1[32],resp1[33],resp1[35],resp1[34],resp1[36]);
                                }
                            }
                        }
                         */
                    }
                      fecharJanela();
                  
                }//funcao e()

                new Ajax.Request("./localiza_conhecimento.jsp?acao=obter_nf&id="+id,{method:'post', onSuccess: e, onError: e});
                
                                   
    
}

            function consulta(campo, operador, valor){

                if(valor.trim().length < 1 &&
                   campo != "emissao_em" && 
                   campo != "baixa_em"){
                alert("Digite um valor valido.");
                    return false;
                }

                var data1 = document.getElementById("dtemissao1").value.trim();
                var data2 = document.getElementById("dtemissao2").value.trim();
                if (campo == "emissao_em" && !(validaData(data1) && validaData(data2) ))
                {
                    alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
                    return null;
                }
                var tipoConhecimento = document.getElementById("tipoConhecimento").value;
                var substituicao = "";
               
                if(tipoConhecimento=="s"){
                    substituicao= "  and ctrc_substituido_id is null "
                }
         
                location.replace("./localiza_conhecimento.jsp?acao=consultar&campo="+campo+"&ope="+operador+"&valor="+valor+
                    "&"+concatFieldValue('filialId')+"&isCancelado=<%=(isCancelado ? "true" : "false")%>"+
                    (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&substituicao="+substituicao+"&acao=consultar&tipoConhecimento="+tipoConhecimento+"&substituicao="+substituicao);
                
                
            }

            function habilitaConsultaDePeriodo(opcao)
            {
                document.getElementById("valor_consulta").style.display = (opcao ? "none" : "");
                document.getElementById("operador_consulta").style.display = (opcao ? "none" : "");
                document.getElementById("div1").style.display = (opcao ? "" : "none");
                document.getElementById("div2").style.display = (opcao ? "" : "none");
            }
  
            function aoCarregar(){
                //seleciona_campos();
            <%if (acao.equals("consultar") && (campoConsulta.equals("emissao_em") || campoConsulta.equals("baixa_em"))) {%>
                    habilitaConsultaDePeriodo(true);
            <%}else if (acao.equals("iniciar")){%>
                    habilitaConsultaDePeriodo(true);
            <%}%>
                }
  
        </script>


        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Localizar Conhecimento de transporte</title>
        <link href="../estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style8 {font-size: 11px}
            -->
        </style>
    </head>

    <body onLoad="javascript:aoCarregar();applyFormatter();">
        <img src="../img/banner.gif"  alt=""><br>
        <table width="99%" align="center" class="bordaFina" >
            <tr>
                <td><div align="left">
                        <%if (isCancelado) {%>
                        <b>Localizar conhecimentos cancelados</b>
                        <%} else if (tipoC.equals("s")){%>
                        <b>Localizar conhecimento para serem substituídos</b>
                        <%} else {%>
                        <b>Localizar conhecimento de transporte para complemento, devolução, reentrega ou diárias</b>
                        <%}%>    
                    </div>
                </td>
            </tr>
        </table>
        <br>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <input type="hidden" name="tipoConhecimento" id="tipoConhecimento" value="">
            <tr class="celula">
                <td width="20%"  height="5">
                    <select name="campo_consulta" id="campo_consulta" class="inputtexto" onChange="javascript:habilitaConsultaDePeriodo(this.value=='emissao_em' || this.value=='baixa_em');">
                        <option value="emissao_em" selected>Data de emiss&atilde;o</option>
                        <option value="baixa_em">Data de entrega</option>
                        <option value="nfiscal" >CTRC</option>
                        <!-- <option value="numero">NF do cliente</option> -->
                        <!-- <option value="pedido">Pedido do cliente</option> -->
                        <option value="numero_carga">Número da carga</option>
                    </select>
                </td>
                <td width="20%">
                    <select name="operador_consulta" id="operador_consulta" class="inputtexto">
                        <option value="1"selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                        <option value="5" >Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De:<input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" value="<%=dataInicial%>"
                                                                   class="fieldDate" onBlur="alertInvalidDate(this)"></div>
                </td>
                <td width="20%">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">Até:<input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" value="<%=dataFinal%>"
                                                                    onblur="alertInvalidDate(this)" class="fieldDate"></div>
                    <input name="valor_consulta" type="text" id="valor_consulta" size="10" class="inputtexto">	  </td>
                <td width="20%">
                    <select name="filialId" id="filialId" style="font-size:8pt; display: <%=(request.getParameter("tipoConhecimento").equals("c") ? "none" : "")%>" class="inputtexto">
                        <%BeanFilial fl = new BeanFilial();
                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                        <%if (nivelUserToFilial > 0) {%>
                        <option value="0">TODAS AS FILIAIS</option>
                        <%}
                            while (rsFl.next()) {
                                if (nivelUserToFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                        <option value="<%=rsFl.getString("idfilial")%>"
                                <%=(filial.equals(rsFl.getString("idfilial")) ? "selected" : "")%>>APENAS A <%=rsFl.getString("abreviatura")%></option>
                        <%}%>
                        <%}%>
                    </select>
                </td>
                <td width="20%">

                    <div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value);">
                    </div></td>
            </tr>
        </table>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="6%">CTRC</td>
                <td width="4%" align="left">Serie</td>
                <td width="4%" align="left">Frete</td>
                <td width="8%">Dt.Emiss&atilde;o</td>
                <td width="10%">Filial/Ag.</td>
                <td width="27%">Remetente</td>
                <td width="27%">Destinat&aacute;rio</td>
                <td align="right" width="7%">Total</td>
            </tr>
            <script language="javascript">
                //alert("jonas");
                $("campo_consulta").value = '<%=beanconh.getCampoDeConsulta()%>';
                $("operador_consulta").value = '<%=beanconh.getOperador()%>';
                $("valor_consulta").value = '<%=beanconh.getValorDaConsulta()%>';
                $("dtemissao1").value = '<%=dataInicial%>';
                $("dtemissao2").value = '<%=dataFinal%>';
                $("filialId").value = '<%=beanconh.getIdFilialConhecimento()%>';
                $("tipoConhecimento").value = '<%=request.getParameter("tipoConhecimento")%>';
                aoCarregar()
            </script>
            <% //variaveis da paginacao
                //int linhatotal = 0;
                int linha = 0;
                //int qtde_pag = 0;
                String cor = "";


                // se conseguiu consultar
                if ((acao.equals("consultar") || acao.equals("proxima")) && (beanconh.LocalizarCtrcReentrega(isCancelado))) {
                    ResultSet rs = beanconh.getResultado();
                    while (rs.next()) {
                        //cor = (rs.getBoolean("is_cancelado") ? "#CC0000" : "");
                        //pega o resto da divisao e testa se é par ou impar
%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >

                <td >
                    <div class="linkEditar" onClick="javascript:retornapai(<%=rs.getString("sale_id")%>);">
                        <%=rs.getString("numero")%>
                    </div>
                    <input type="hidden" name="valor_frete_<%=rs.getString("sale_id")%>" id="valor_frete_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_frete")%>">
                    <input type="hidden" name="valorReentrega_<%=rs.getString("sale_id")%>" id="valorReentrega_<%=rs.getString("sale_id")%>" value="<%=rs.getString("percentual_reentrega")%>">
                    <input type="hidden" name="valorDevolucao_<%=rs.getString("sale_id")%>" id="valorDevolucao_<%=rs.getString("sale_id")%>" value="<%=rs.getString("percentual_devolucao")%>">
                    <input type="hidden" name="valor_frete_minimo_<%=rs.getString("sale_id")%>" id="valor_frete_minimo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_frete_minimo")%>">
                    <input type="hidden" name="total_<%=rs.getString("sale_id")%>" id="total_<%=rs.getString("sale_id")%>" value="<%=rs.getString("ct_total")%>">
                   
                    <input type="hidden" name="numero_<%=rs.getString("sale_id")%>" id="numero_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero")%>">
                    <input type="hidden" name="cubagem_metro_<%=rs.getString("sale_id")%>" id="cubagem_metro_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_metro")%>">

                    <input type="hidden" name="idcoleta_<%=rs.getString("sale_id")%>" id="idcoleta_<%=rs.getString("sale_id")%>" value="<%=rs.getString("coleta_ctrc_id")%>">
                    <input type="hidden" name="numcoleta_<%=rs.getString("sale_id")%>" id="numcoleta_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numcoleta")%>">

                    <input type="hidden" name="tipoproduto_<%=rs.getString("sale_id")%>" id="tipoproduto_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("product_type_id") == null ? "0" : rs.getString("product_type_id"))%>">
                    <input type="hidden" name="cub_altura_<%=rs.getString("sale_id")%>" id="cub_altura_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_altura")%>">
                    <input type="hidden" name="cub_largura_<%=rs.getString("sale_id")%>" id="cub_largura_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_largura")%>">
                    <input type="hidden" name="cub_comprimento_<%=rs.getString("sale_id")%>" id="cub_comprimento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_comprimento")%>">
                    <input type="hidden" name="cub_base_<%=rs.getString("sale_id")%>" id="cub_base_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_base")%>">
                    <input type="hidden" name="peso_taxado_nf<%=rs.getString("sale_id")%>" id="peso_taxado_nf<%=rs.getString("sale_id")%>" value="<%=rs.getString("peso_nf")%>">
                    <input type="hidden" name="cub_metro_<%=rs.getString("sale_id")%>" id="cub_metro_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_metro")%>">
                    <input type="hidden" name="qtde_entregas_<%=rs.getString("sale_id")%>" id="qtde_entregas_<%=rs.getString("sale_id")%>" value="<%=rs.getString("quantidade_entregas")%>">
                    <input type="hidden" name="tipoveiculo_<%=rs.getString("sale_id")%>" id="tipoveiculo_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("tipo_veiculo_id") == null ? "-1" : rs.getString("tipo_veiculo_id"))%>">
                    <input type="hidden" name="incluirIcms_<%=rs.getString("sale_id")%>" id="incluirIcms_<%=rs.getString("sale_id")%>" value="<%=rs.getString("is_added_icms")%>">
                    <input type="hidden" name="incluirFederais_<%=rs.getString("sale_id")%>" id="incluirFederais_<%=rs.getString("sale_id")%>" value="<%=rs.getString("is_inclui_federais")%>">
                    <input type="hidden" name="client_tariff_id_<%=rs.getString("sale_id")%>" id="client_tariff_id_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("client_tariff_id") == null ? "0" : rs.getString("client_tariff_id"))%>">
                    <input type="hidden" name="valor_taxa_fixa_<%=rs.getString("sale_id")%>" id="valor_taxa_fixa_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_taxa_fixa")%>">
                    <input type="hidden" name="valor_itr_<%=rs.getString("sale_id")%>" id="valor_itr_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_itr")%>">
                    <input type="hidden" name="valor_despacho_<%=rs.getString("sale_id")%>" id="valor_despacho_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_despacho")%>">
                    <input type="hidden" name="valor_ademe_<%=rs.getString("sale_id")%>" id="valor_ademe_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_ademe")%>">
                    <input type="hidden" name="valor_peso_<%=rs.getString("sale_id")%>" id="valor_peso_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_peso")%>">
                    <input type="hidden" name="observacao_<%=rs.getString("sale_id")%>" id="observacao_<%=rs.getString("sale_id")%>" value="<%=rs.getString("observacao").replaceAll("\n", "<BR>")%>">
                    <input type="hidden" name="reducao_base_icms_<%=rs.getString("sale_id")%>" id="reducao_base_icms_<%=rs.getString("sale_id")%>" value="<%=rs.getString("reducao_base_icms").replaceAll("\n", "<BR>")%>">

                    <input type="hidden" name="valor_sec_cat_<%=rs.getString("sale_id")%>" id="valor_sec_cat_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_sec_cat")%>">
                    <input type="hidden" name="valor_outros_<%=rs.getString("sale_id")%>" id="valor_outros_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_outros")%>">
                    <input type="hidden" name="valor_gris_<%=rs.getString("sale_id")%>" id="valor_gris_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_gris")%>">
                    <input type="hidden" name="valor_pedagio_<%=rs.getString("sale_id")%>" id="valor_pedagio_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_pedagio")%>">
                    <input type="hidden" name="valor_desconto_<%=rs.getString("sale_id")%>" id="valor_desconto_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_desconto")%>">
                    <input type="hidden" name="base_calculo_<%=rs.getString("sale_id")%>" id="base_calculo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("base_calculo")%>">
                    <input type="hidden" name="aliquota_<%=rs.getString("sale_id")%>" id="aliquota_<%=rs.getString("sale_id")%>" value="<%=rs.getString("aliquota")%>">
                    <input type="hidden" name="vlicmsbarreira_<%=rs.getString("sale_id")%>" id="vlicmsbarreira_<%=rs.getString("sale_id")%>" value="<%=rs.getString("icms_barreira")%>">

                    <input type="hidden" name="idcidadeorigem_<%=rs.getString("sale_id")%>" id="idcidadeorigem_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("idcidadeorigem") == null ? 0 : rs.getString("idcidadeorigem"))%>">
                    <input type="hidden" name="cid_origem_<%=rs.getString("sale_id")%>" id="cid_origem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cidade_origem")%>">
                    <input type="hidden" name="uf_origem_<%=rs.getString("sale_id")%>" id="uf_origem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("uf_origem")%>">

                    <input type="hidden" name="idcidadedestino_<%=rs.getString("sale_id")%>" id="idcidadedestino_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("cidade_destino_id") == null ? 0 : rs.getString("cidade_destino_id"))%>">
                    <input type="hidden" name="cid_destino_<%=rs.getString("sale_id")%>" id="cid_destino_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cidade_destino")%>">
                    <input type="hidden" name="uf_destino_<%=rs.getString("sale_id")%>" id="uf_destino_<%=rs.getString("sale_id")%>" value="<%=rs.getString("uf_destino")%>">
                    <input type="hidden" name="uf_destino_<%=rs.getString("sale_id")%>" id="uf_destino_<%=rs.getString("sale_id")%>" value="<%=rs.getString("uf_destino")%>">
                    <input type="hidden" name="rota_viagem_<%=rs.getString("sale_id")%>" id="rota_viagem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rota_viagem")%>">
                    <input type="hidden" name="id_rota_viagem_<%=rs.getString("sale_id")%>" id="id_rota_viagem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("id_rota_viagem")%>">
                    <input type="hidden" name="distancia_km_<%=rs.getString("sale_id")%>" id="distancia_km_<%=rs.getString("sale_id")%>" value="<%=rs.getString("distancia_origem_destino")%>">
                    <input type="hidden" name="st_icms_<%=rs.getString("sale_id")%>" id="st_icms_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_icms")%>">
                    <input type="hidden" name="ct_percentual_credito_presumido_<%=rs.getString("sale_id")%>" id="ct_percentual_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("ct_percentual_credito_presumido")%>">

                    <!-- remetente -->
                    <input type="hidden" name="idremetente_<%=rs.getString("sale_id")%>" id="idremetente_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("remetente_id") == null ? "0" : rs.getString("remetente_id"))%>">
                    <input type="hidden" name="rem_rzs_<%=rs.getString("sale_id")%>" id="rem_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_rzs")%>">
                    <input type="hidden" name="rem_cidade_<%=rs.getString("sale_id")%>" id="rem_cidade_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_cidade")%>">
                    <input type="hidden" name="rem_uf_<%=rs.getString("sale_id")%>" id="rem_uf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_uf")%>">
                    <input type="hidden" name="rem_cnpj_<%=rs.getString("sale_id")%>" id="rem_cnpj_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_cnpj")%>">
                    <input type="hidden" name="rem_tipotaxa_<%=rs.getString("sale_id")%>" id="rem_tipotaxa_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_tipotaxa")%>">
                    <input type="hidden" name="idvenremetente_<%=rs.getString("sale_id")%>" id="idvenremetente_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("vendedor_id") == null ? "0" : rs.getString("vendedor_id"))%>">
                    <input type="hidden" name="idcidadeorigem_<%=rs.getString("sale_id")%>" id="idcidadeorigem_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("rem_idcidade") == null ? "0" : rs.getString("rem_idcidade"))%>">
                    <input type="hidden" name="remtipofpag_<%=rs.getString("sale_id")%>" id="remtipofpag_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_tipoFpag")%>">
                    <input type="hidden" name="remtipoorigem_<%=rs.getString("sale_id")%>" id="remtipoorigem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_tipoOrigem")%>">
                    <input type="hidden" name="rem_endereco_<%=rs.getString("sale_id")%>" id="rem_endereco_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_endereco") + " - " + rs.getString("rem_bairro")%>">
                    <input type="hidden" name="remtabelaproduto_<%=rs.getString("sale_id")%>" id="remtabelaproduto_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_is_bloqueado")%>">
                    <input type="hidden" name="rem_is_bloqueado_<%=rs.getString("sale_id")%>" id="rem_is_bloqueado_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_valor_credito")%>">
                    <input type="hidden" name="rem_tabela_remetente_<%=rs.getString("sale_id")%>" id="rem_tabela_remetente_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_is_utiliza_tabela_remetente")%>">
                    <input type="hidden" name="rem_analise_credito_<%=rs.getString("sale_id")%>" id="rem_analise_credito_<%=rs.getString("sale_id")%>" value="f">
                    <input type="hidden" name="rem_valor_credito_<%=rs.getString("sale_id")%>" id="rem_valor_credito_<%=rs.getString("sale_id")%>" value="0">
                    <input type="hidden" name="pauta_remetente_<%=rs.getString("sale_id")%>" id="pauta_remetente_<%=rs.getString("sale_id")%>" value="<%=rs.getString("pauta_remetente")%>">
                    <input type="hidden" name="rem_inclui_peso_container_<%=rs.getString("sale_id")%>" id="rem_inclui_peso_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_inclui_peso_container")%>">
                    <input type="hidden" name="rem_tipo_cfop_<%=rs.getString("sale_id")%>" id="rem_tipo_cfop_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_tipo_cfop")%>">
                    <input type="hidden" name="rem_st_mg_<%=rs.getString("sale_id")%>" id="rem_st_mg_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_st_mg")%>">
                    <input type="hidden" name="utilizatipofretetabelarem_<%=rs.getString("sale_id")%>" id="utilizatipofretetabelarem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_is_utilizar_tipo_frete_tabela")%>">
                    <input type="hidden" name="rem_is_frete_dirigido_<%=rs.getString("sale_id")%>" id="rem_is_frete_dirigido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("is_frete_dirigido")%>">
                    <input type="hidden" name="st_rem_credito_presumido_<%=rs.getString("sale_id")%>" id="st_rem_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_rem_credito_presumido")%>">
                    <input type="hidden" name="rem_tipo_tributacao_<%=rs.getString("sale_id")%>" id="rem_tipo_tributacao_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_tipo_tributacao")%>">
                    <input type="hidden" name="rem_tipo_arredondamento_<%=rs.getString("sale_id")%>" id="rem_tipo_arredondamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_arredondamento_peso_rem")%>">

                    <!-- destinatário -->
                    <input type="hidden" name="iddestinatario_<%=rs.getString("sale_id")%>" id="iddestinatario_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("destinatario_id") == null ? "0" : rs.getString("destinatario_id"))%>">
                    <input type="hidden" name="dest_rzs_<%=rs.getString("sale_id")%>" id="dest_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_rzs")%>">
                    <input type="hidden" name="dest_cidade_<%=rs.getString("sale_id")%>" id="dest_cidade_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_cidade")%>">
                    <input type="hidden" name="dest_uf_<%=rs.getString("sale_id")%>" id="dest_uf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_uf")%>">
                    <input type="hidden" name="dest_cnpj_<%=rs.getString("sale_id")%>" id="dest_cnpj_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_cnpj")%>">
                    <input type="hidden" name="dest_ie_<%=rs.getString("sale_id")%>" id="dest_ie_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_ie")%>">
                    <input type="hidden" name="dest_tipotaxa_<%=rs.getString("sale_id")%>" id="dest_tipotaxa_<%=rs.getString("sale_id")%>" value="<%=rs.getString("dest_tipotaxa")%>">
                    <input type="hidden" name="desttipofpag_<%=rs.getString("sale_id")%>" id="desttipofpag_<%=rs.getString("sale_id")%>" value="<%=rs.getString("dest_tipoFpag")%>">
                    <input type="hidden" name="aliquota_<%=rs.getString("sale_id")%>" id="aliquota_<%=rs.getString("sale_id")%>" value="<%=rs.getString("aliquota")%>">
                    <input type="hidden" name="desttipoorigem_<%=rs.getString("sale_id")%>" id="desttipoorigem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_tipoOrigem")%>">
                    <input type="hidden" name="desttabelaproduto_<%=rs.getString("sale_id")%>" id="desttabelaproduto_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rem_tabelaProduto")%>">
                    <input type="hidden" name="reducao_base_icms_<%=rs.getString("sale_id")%>" id="reducao_base_icms_<%=rs.getString("sale_id")%>" value="<%=rs.getString("reducao_base_icms")%>">
                    <input type="hidden" name="dest_endereco_<%=rs.getString("sale_id")%>" id="dest_endereco_<%=rs.getString("sale_id")%>" value="<%=rs.getString("dest_endereco") + " - " + rs.getString("dest_bairro")%>">
                    <input type="hidden" name="dest_endereco_id_<%=rs.getString("sale_id")%>" id="dest_endereco_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("endereco_entrega_id")%>">
                    <input type="hidden" name="des_analise_credito_<%=rs.getString("sale_id")%>" id="des_analise_credito_<%=rs.getString("sale_id")%>" value=<%=rs.getString("des_is_analise_credito")%>>
                    <input type="hidden" name="des_valor_credito_<%=rs.getString("sale_id")%>" id="des_valor_credito_<%=rs.getString("sale_id")%>" value=<%=rs.getString("des_valor_credito")%>>
                    <input type="hidden" name="des_is_bloqueado_<%=rs.getString("sale_id")%>" id="des_is_bloqueado_<%=rs.getString("sale_id")%>" value=<%=rs.getString("des_is_bloqueado")%>>
                    <input type="hidden" name="des_tabela_remetente_<%=rs.getString("sale_id")%>" id="des_tabela_remetente_<%=rs.getString("sale_id")%>" value=<%=rs.getString("des_is_utiliza_tabela_remetente")%>>
                    <input type="hidden" name="pauta_destinatario_<%=rs.getString("sale_id")%>" id="pauta_destinatario_<%=rs.getString("sale_id")%>" value="<%=rs.getString("pauta_destinatario")%>">
                    <input type="hidden" name="des_inclui_peso_container_<%=rs.getString("sale_id")%>" id="des_inclui_peso_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_inclui_peso_container")%>">
                    <input type="hidden" name="des_tipo_cfop_<%=rs.getString("sale_id")%>" id="des_tipo_cfop_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_cfop")%>">
                    <input type="hidden" name="utilizatipofretetabeladest_<%=rs.getString("sale_id")%>" id="utilizatipofretetabeladest_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_is_utilizar_tipo_frete_tabela")%>">
                    <input type="hidden" name="tipo_produto_destinatario_id_<%=rs.getString("sale_id")%>" id="tipo_produto_destinatario_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_produto_destinatario_id")%>">
                    <input type="hidden" name="st_des_credito_presumido_<%=rs.getString("sale_id")%>" id="st_des_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_des_credito_presumido")%>">
                    <input type="hidden" name="des_tipo_tributacao_<%=rs.getString("sale_id")%>" id="des_tipo_tributacao_<%=rs.getString("sale_id")%>" value="<%=rs.getString("des_tipo_tributacao")%>">
                    <input type="hidden" name="des_tipo_arredondamento_<%=rs.getString("sale_id")%>" id="des_tipo_arredondamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_arredondamento_peso_des")%>">

                    <!-- Redespacho -->
                    <input type="hidden" name="ctoredespacho_<%=rs.getString("sale_id")%>" id="ctoredespacho_<%=rs.getString("sale_id")%>" value="<%=rs.getString("redespacho_ctrc")%>">
                    <input type="hidden" name="redespacho_valor_<%=rs.getString("sale_id")%>" id="redespacho_valor_<%=rs.getString("sale_id")%>" value="<%=rs.getString("redespacho_valor")%>">
                    <input type="hidden" name="redespacho_valor_icms_<%=rs.getString("sale_id")%>" id="redespacho_valor_icms_<%=rs.getString("sale_id")%>" value="<%=rs.getString("redespacho_valor_icms")%>">
                    <input type="hidden" name="idredespacho_<%=rs.getString("sale_id")%>" id="idredespacho_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("redespacho_id") == null ? "0" : rs.getString("redespacho_id"))%>">
                    <input type="hidden" name="red_rzs_<%=rs.getString("sale_id")%>" id="red_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_rzs")%>">
                    <input type="hidden" name="chave_acesso_redespacho_<%=rs.getString("sale_id")%>" id="chave_acesso_redespacho_<%=rs.getString("sale_id")%>" value="<%=rs.getString("chave_acesso_doc_ant_redespacho")%>">
                    <input type="hidden" name="red_cidade_<%=rs.getString("sale_id")%>" id="red_cidade_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_cidade")%>">
                    <input type="hidden" name="red_uf_<%=rs.getString("sale_id")%>" id="red_uf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_uf")%>">
                    <input type="hidden" name="red_cnpj_<%=rs.getString("sale_id")%>" id="red_cnpj_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_cnpj")%>">
                    <input type="hidden" name="red_tipotaxa_<%=rs.getString("sale_id")%>" id="red_tipotaxa_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_tipotaxa")%>">
                    <input type="hidden" name="redtipoorigem_<%=rs.getString("sale_id")%>" id="redtipoorigem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_tipoOrigem")%>">
                    <input type="hidden" name="red_analise_credito_<%=rs.getString("sale_id")%>" id="red_analise_credito_<%=rs.getString("sale_id")%>" value=<%=rs.getString("red_is_analise_credito")%>>
                    <input type="hidden" name="red_valor_credito_<%=rs.getString("sale_id")%>" id="red_valor_credito_<%=rs.getString("sale_id")%>" value=<%=rs.getString("red_valor_credito")%>>
                    <input type="hidden" name="red_is_bloqueado_<%=rs.getString("sale_id")%>" id="red_is_bloqueado_<%=rs.getString("sale_id")%>" value=<%=rs.getString("red_is_bloqueado")%>>
                    <input type="hidden" name="red_tabela_remetente_<%=rs.getString("sale_id")%>" id="red_tabela_remetente_<%=rs.getString("sale_id")%>" value=<%=rs.getString("red_is_utiliza_tabela_remetente")%>>
                    <input type="hidden" name="is_redespacho_pago_<%=rs.getString("sale_id")%>" id="is_redespacho_pago_<%=rs.getString("sale_id")%>" value=<%=rs.getString("is_redespacho_pago")%>>
                    <input type="hidden" name="pauta_redespacho_<%=rs.getString("sale_id")%>" id="pauta_redespacho_<%=rs.getString("sale_id")%>" value="<%=rs.getString("pauta_redespacho")%>">
                    <input type="hidden" name="red_inclui_peso_container_<%=rs.getString("sale_id")%>" id="red_inclui_peso_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_inclui_peso_container")%>">
                    <input type="hidden" name="red_tipo_cfop_<%=rs.getString("sale_id")%>" id="red_tipo_cfop_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_tipo_cfop")%>">
                    <input type="hidden" name="utilizatipofretetabelared_<%=rs.getString("sale_id")%>" id="utilizatipofretetabelared_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_is_utilizar_tipo_frete_tabela")%>">
                    <input type="hidden" name="st_red_credito_presumido_<%=rs.getString("sale_id")%>" id="st_red_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_red_credito_presumido")%>">
                    <input type="hidden" name="red_tipo_tributacao_<%=rs.getString("sale_id")%>" id="red_tipo_tributacao_<%=rs.getString("sale_id")%>" value="<%=rs.getString("red_tipo_tributacao")%>">
                    <input type="hidden" name="red_tipo_arredondamento_<%=rs.getString("sale_id")%>" id="red_tipo_arredondamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_arredondamento_peso_red")%>">

                    <!-- Consignatário -->
                    <input type="hidden" name="idconsignatario_<%=rs.getString("sale_id")%>" id="idconsignatario_<%=rs.getString("sale_id")%>" value="<%=(rs.getString("consignatario_id") == null ? "0" : rs.getString("consignatario_id"))%>">
                    <input type="hidden" name="con_rzs_<%=rs.getString("sale_id")%>" id="con_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("con_rzs")%>">
                    <input type="hidden" name="con_cidade_<%=rs.getString("sale_id")%>" id="con_cidade_<%=rs.getString("sale_id")%>" value="<%=rs.getString("con_cidade")%>">
                    <input type="hidden" name="con_uf_<%=rs.getString("sale_id")%>" id="con_uf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("con_uf")%>">
                    <input type="hidden" name="con_cnpj_<%=rs.getString("sale_id")%>" id="con_cnpj_<%=rs.getString("sale_id")%>" value="<%=rs.getString("con_cnpj")%>">
                    <input type="hidden" name="tipotaxa_<%=rs.getString("sale_id")%>" id="tipotaxa_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_taxa")%>">
                    <input type="hidden" name="idvendedor_<%=rs.getString("sale_id")%>" id="idvendedor_<%=rs.getString("sale_id")%>" value=<%=(rs.getString("vendedor_id") == null ? "0" : rs.getString("vendedor_id"))%>>
                    <input type="hidden" name="ven_rzs_<%=rs.getString("sale_id")%>" id="ven_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("ven_rzs")%>">
                    <input type="hidden" name="comissao_vendedor<%=rs.getString("sale_id")%>" id="comissao_vendedor<%=rs.getString("sale_id")%>" value=<%=rs.getString("comissao_vendedor")%>>
                    <input type="hidden" name="contipofpag_<%=rs.getString("sale_id")%>" id="contipofpag_<%=rs.getString("sale_id")%>" value=<%=rs.getString("con_tipoFpag")%>>
                    <input type="hidden" name="tipofpag_<%=rs.getString("sale_id")%>" id="tipofpag_<%=rs.getString("sale_id")%>" value=<%=rs.getString("tipo_fpag")%>>
                    <input type="hidden" name="contipoorigem_<%=rs.getString("sale_id")%>" id="contipoorigem_<%=rs.getString("sale_id")%>" value=<%=rs.getString("con_tipoOrigem")%>>
                    <input type="hidden" name="contabelaproduto_<%=rs.getString("sale_id")%>" id="contabelaproduto_<%=rs.getString("sale_id")%>" value=<%=rs.getString("con_tabelaProduto")%>>
                    <input type="hidden" name="con_analise_credito_<%=rs.getString("sale_id")%>" id="con_analise_credito_<%=rs.getString("sale_id")%>" value=<%=rs.getString("cli_is_analise_credito")%>>
                    <input type="hidden" name="con_valor_credito_<%=rs.getString("sale_id")%>" id="con_valor_credito_<%=rs.getString("sale_id")%>" value=<%=rs.getString("cli_valor_credito")%>>
                    <input type="hidden" name="con_is_bloqueado_<%=rs.getString("sale_id")%>" id="con_is_bloqueado_<%=rs.getString("sale_id")%>" value=<%=rs.getString("cli_is_bloqueado")%>>
                    <input type="hidden" name="con_tabela_remetente_<%=rs.getString("sale_id")%>" id="con_tabela_remetente_<%=rs.getString("sale_id")%>" value=<%=rs.getString("cli_is_utiliza_tabela_remetente")%>>
                    <input type="hidden" name="is_con_pago_<%=rs.getString("sale_id")%>" id="is_con_pago_<%=rs.getString("sale_id")%>" value=<%=rs.getString("is_pago")%>>
                    <input type="hidden" name="pauta_consignatario_<%=rs.getString("sale_id")%>" id="pauta_consignatario_<%=rs.getString("sale_id")%>" value="<%=rs.getString("pauta_consignatario")%>">
                    <input type="hidden" name="con_inclui_peso_container_<%=rs.getString("sale_id")%>" id="con_inclui_peso_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cli_inclui_peso_container")%>">
                    <input type="hidden" name="con_tipo_cfop_<%=rs.getString("sale_id")%>" id="con_tipo_cfop_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cli_tipo_cfop")%>">
                    <input type="hidden" name="utilizatipofretetabelaconsig_<%=rs.getString("sale_id")%>" id="utilizatipofretetabelaconsig_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cli_is_utilizar_tipo_frete_tabela")%>">
                    <input type="hidden" name="st_cli_credito_presumido_<%=rs.getString("sale_id")%>" id="st_cli_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_cli_credito_presumido")%>">
                    <input type="hidden" name="con_tipo_tributacao_<%=rs.getString("sale_id")%>" id="con_tipo_tributacao_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cli_tipo_tributacao")%>">
                    <input type="hidden" name="con_tipo_arredondamento_<%=rs.getString("sale_id")%>" id="con_tipo_arredondamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_arredondamento_peso_con")%>">

                    <!-- Motorista -->
                    <input type="hidden" name="id_motorista_<%=rs.getString("sale_id")%>" id="id_motorista_<%=rs.getString("sale_id")%>" value="<%=rs.getString("idmotorista")%>">
                    <input type="hidden" name="motorista_<%=rs.getString("sale_id")%>" id="motorista_<%=rs.getString("sale_id")%>" value="<%=rs.getString("motorista")%>">
                    <input type="hidden" name="id_veiculo_<%=rs.getString("sale_id")%>" id="id_veiculo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("idveiculo")%>">
                    <input type="hidden" name="veiculo_<%=rs.getString("sale_id")%>" id="veiculo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("ve_placa")%>">
                    <input type="hidden" name="id_carreta_<%=rs.getString("sale_id")%>" id="id_carreta_<%=rs.getString("sale_id")%>" value="<%=rs.getString("idcarreta")%>">
                    <input type="hidden" name="carreta_<%=rs.getString("sale_id")%>" id="carreta_<%=rs.getString("sale_id")%>" value="<%=rs.getString("carreta_placa")%>">
                    <input type="hidden" name="id_bitrem_<%=rs.getString("sale_id")%>" id="id_bitrem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("idbitrem")%>">
                    <input type="hidden" name="bitrem_<%=rs.getString("sale_id")%>" id="bitrem_<%=rs.getString("sale_id")%>" value="<%=rs.getString("bitrem_placa")%>">
                    <!--numero da carga-->
                    <input type="hidden" name="numero_carga_<%=rs.getString("sale_id")%>" id="numero_carga_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero_carga")%>">
                    <!-- pedido cliente -->
                    <input type="hidden" name="pedido_Cliente_<%=rs.getString("sale_id")%>" id="pedido_Cliente_<%=rs.getString("sale_id")%>" value="<%=rs.getString("pedido_Cliente")%>">
                    
                    
                    <!-- Dados do Container -->
                    
                    <input type="hidden" name="numero_container_<%=rs.getString("sale_id")%>" id="numero_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero_container")%>">
                    <input type="hidden" name="numero_genset_<%=rs.getString("sale_id")%>" id="numero_genset_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero_genset")%>">
                    <input type="hidden" name="numero_booking_<%=rs.getString("sale_id")%>" id="numero_booking_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero_booking")%>">
                    <input type="hidden" name="numero_lacre_<%=rs.getString("sale_id")%>" id="numero_lacre_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero_lacre")%>">
                    <input type="hidden" name="peso_container_<%=rs.getString("sale_id")%>" id="peso_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("peso_container")%>">
                    <input type="hidden" name="valor_container_<%=rs.getString("sale_id")%>" id="valor_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_container")%>">
                    <input type="hidden" name="genset_horimetro_inicial_<%=rs.getString("sale_id")%>" id="genset_horimetro_inicial_<%=rs.getString("sale_id")%>" value="<%=rs.getString("genset_horimetro_inicial")%>">
                    <input type="hidden" name="genset_horimetro_final_<%=rs.getString("sale_id")%>" id="genset_horimetro_final_<%=rs.getString("sale_id")%>" value="<%=rs.getString("genset_horimetro_final")%>">
                    <input type="hidden" name="direcao_aquaviario_<%=rs.getString("sale_id")%>" id="direcao_aquaviario_<%=rs.getString("sale_id")%>" value="<%=rs.getString("direcao_aquaviario")%>">
                    <input type="hidden" name="numero_viagem_navio_<%=rs.getString("sale_id")%>" id="numero_viagem_navio_<%=rs.getString("sale_id")%>" value="<%=rs.getString("numero_viagem_navio")%>">
                    <input type="hidden" name="direcao_aquaviario_<%=rs.getString("sale_id")%>" id="direcao_aquaviario_<%=rs.getString("sale_id")%>" value="<%=rs.getString("direcao_aquaviario")%>">
                    <input type="hidden" name="tipo_navegacao_aquaviario_<%=rs.getString("sale_id")%>" id="tipo_navegacao_aquaviario_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_navegacao_aquaviario")%>">
                    <input type="hidden" name="valor_ganset_<%=rs.getString("sale_id")%>" id="valor_ganset_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_genset")%>">
                    
                    <!-- Ids da aba de containers -->
                    
                    <input type="hidden" name="porto_embarque_id_<%=rs.getString("sale_id")%>" id="porto_embarque_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("porto_embarque_id")%>">
                    <input type="hidden" name="porto_embarque_<%=rs.getString("sale_id")%>" id="porto_embarque_<%=rs.getString("sale_id")%>" value="<%=rs.getString("porto_embarque")%>">
                    
                    <input type="hidden" name="porto_destino_id_<%=rs.getString("sale_id")%>" id="porto_destino_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("porto_destino_id")%>">
                    <input type="hidden" name="porto_destino_<%=rs.getString("sale_id")%>" id="porto_destino_<%=rs.getString("sale_id")%>" value="<%=rs.getString("porto_destino")%>">
                    
                    <input type="hidden" name="porto_transbordo_id_<%=rs.getString("sale_id")%>" id="porto_transbordo_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("porto_transbordo_id")%>">
                    <input type="hidden" name="porto_transbordo_<%=rs.getString("sale_id")%>" id="porto_transbordo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("porto_transbordo")%>">
                    
                    <input type="hidden" name="navio_id_<%=rs.getString("sale_id")%>" id="navio_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("navio_id")%>">
                    <input type="hidden" name="navio_<%=rs.getString("sale_id")%>" id="navio_<%=rs.getString("sale_id")%>" value="<%=rs.getString("navio")%>">
                    
                    <input type="hidden" name="armador_id_<%=rs.getString("sale_id")%>" id="armador_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("armador_id")%>">
                    <input type="hidden" name="armador_<%=rs.getString("sale_id")%>" id="armador_<%=rs.getString("sale_id")%>" value="<%=rs.getString("armador")%>">
                    
                    <input type="hidden" name="terminal_id_<%=rs.getString("sale_id")%>" id="terminal_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("terminal_id")%>">
                    <input type="hidden" name="terminal_<%=rs.getString("sale_id")%>" id="terminal_<%=rs.getString("sale_id")%>" value="<%=rs.getString("terminal")%>">
                    
                    <input type="hidden" name="tipo_container_<%=rs.getString("sale_id")%>" id="tipo_container_<%=rs.getString("sale_id")%>" value="<%=rs.getString("tipo_container_id")%>">
                
                    <input type="hidden" name="valor_nf_<%=rs.getString("sale_id")%>" id="valor_nf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("valor_nf")%>">
                    <input type="hidden" name="valor_peso_nf_<%=rs.getString("sale_id")%>" id="valor_peso_nf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("peso_nf")%>">
                    <input type="hidden" name="volume_nf_<%=rs.getString("sale_id")%>" id="volume_nf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("volume_nf")%>">
                    <!--expedidor redespacho-->
                    <input type="hidden" name="exp_id_<%=rs.getString("sale_id")%>" id="exp_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("exp_id")%>">
                    <!--expedidor dados cte-->
                    <input type="hidden" name="exp_codigo_<%=rs.getString("sale_id")%>" id="exp_codigo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("exp_codigo")%>">
                    <input type="hidden" name="exp_rzs_<%=rs.getString("sale_id")%>" id="exp_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("exp_rzs")%>">
                    <input type="hidden" name="exp_cidade_<%=rs.getString("sale_id")%>" id="exp_cidade_<%=rs.getString("sale_id")%>" value="<%=rs.getString("exp_cidade")%>">
                    <input type="hidden" name="exp_uf_<%=rs.getString("sale_id")%>" id="exp_uf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("exp_uf")%>">
                    <input type="hidden" name="exp_cnpj_<%=rs.getString("sale_id")%>" id="exp_cnpj_<%=rs.getString("sale_id")%>" value="<%=rs.getString("exp_cnpj")%>">
                    <input type="hidden" name="st_exp_credito_presumido_<%=rs.getString("sale_id")%>" id="st_exp_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_exp_credito_presumido")%>">
                   
                    <!--recebedor-->
                    <input type="hidden" name="rec_id_<%=rs.getString("sale_id")%>" id="rec_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rec_id")%>">
                    <!--recebedor dados cte-->
                    <input type="hidden" name="rec_codigo_<%=rs.getString("sale_id")%>" id="rec_codigo_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rec_codigo")%>">
                    <input type="hidden" name="rec_rzs_<%=rs.getString("sale_id")%>" id="rec_rzs_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rec_rzs")%>">
                    <input type="hidden" name="rec_cidade_<%=rs.getString("sale_id")%>" id="rec_cidade_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rec_cidade")%>">
                    <input type="hidden" name="rec_uf_<%=rs.getString("sale_id")%>" id="rec_uf_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rec_uf")%>">
                    <input type="hidden" name="rec_cnpj_<%=rs.getString("sale_id")%>" id="rec_cnpj_<%=rs.getString("sale_id")%>" value="<%=rs.getString("rec_cnpj")%>">
                    <input type="hidden" name="st_rec_credito_presumido_<%=rs.getString("sale_id")%>" id="st_rec_credito_presumido_<%=rs.getString("sale_id")%>" value="<%=rs.getString("st_rec_credito_presumido")%>">
                    
                    <input type="hidden" name="orcamento_id_<%=rs.getString("sale_id")%>" id="orcamento_id_<%=rs.getString("sale_id")%>" value="<%=rs.getString("orcamento_id")%>">
<!--                    <input type="hidden" name="orcamento_numero_<%=rs.getString("sale_id")%>" id="orcamento_numero_<%=rs.getString("sale_id")%>" value="<%=rs.getString("orcamento_numero")%>">
                    <input type="hidden" name="peso_orcamento_<%=rs.getString("sale_id")%>" id="peso_orcamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("peso_orcamento")%>">
                    <input type="hidden" name="volume_orcamento_<%=rs.getString("sale_id")%>" id="volume_orcamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("volume_orcamento")%>">
                    <input type="hidden" name="mercadoria_orcamento_<%=rs.getString("sale_id")%>" id="mercadoria_orcamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("mercadoria_orcamento")%>">
                    <input type="hidden" name="cubagem_orcamento_<%=rs.getString("sale_id")%>" id="cubagem_orcamento_<%=rs.getString("sale_id")%>" value="<%=rs.getString("cubagem_orcamento")%>">-->
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("serie")%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=(rs.getBoolean("is_pago") ? "CIF" : "FOB")%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("emissao_em"))%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("fi_abreviatura") + (rs.getString("agencia_abreviatura") == null ? "" : "<br>" + rs.getString("agencia_abreviatura"))%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("rem_rzs")%>
                    </font>
                </td>
                <td>
                    <font color=<%=cor%>>
                    <%=rs.getString("des_rzs")%>
                    </font>
                </td>
                <td align="right">
                    <font color=<%=cor%>>
                    <%=rs.getString("ct_total")%>
                    </font>
                </td>

            </tr>
            <%
                        linha++;
                    }
                }
            %>


        </table>
        <br>
    </body>
</html>
