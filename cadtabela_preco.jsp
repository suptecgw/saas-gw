<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" language="java"
        import="
        nucleo.*, java.text.DecimalFormat,
        java.text.SimpleDateFormat,
        tipo_veiculos.*,
        java.sql.ResultSet,
        cliente.BeanCadTabelaCliente, cliente.BeanTabelaCliente" errorPage=""%>
<!DOCTYPE html>

<%
    //Permissao do usuÃ¡rio nessa pï¿½gina
    int nivelUser = Apoio.getUsuario(request).getAcesso("cadcliente");
    int nivelUserTabela = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadtabelacliente") : 0);

    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }

    String acao = request.getParameter("acao");
    BeanTabelaCliente tab = null;
    BeanTabelaCliente tabClonado = null;
    FaixaPeso fx = new FaixaPeso();
    Tipo_veiculos tpVei = new Tipo_veiculos();
    BeanCadTabelaCliente cadTab = null;
    BeanCadTabelaCliente cadTabClonado = null;
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

    ResultSet rsTpVei = tpVei.all(Apoio.getUsuario(request).getConexao());
    String tiposVeiculos = "";
    while (rsTpVei.next()) {
        tiposVeiculos += (tiposVeiculos.equals("") ? "" : "!-") + rsTpVei.getString("id") + "!!0.00!!0";
    }
    rsTpVei.close();

    if (acao != null) {

        //instrucoes incomuns entre as acoes
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {
            //instanciando o bean de cadastro
            cadTab = new BeanCadTabelaCliente();
            cadTab.setConexao(Apoio.getUsuario(request).getConexao());
            cadTab.setExecutor(Apoio.getUsuario(request));
        }

        //executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            tab = new BeanTabelaCliente();
            int id = Integer.parseInt(request.getParameter("id"));
            tab.setId(id);
            cadTab = new BeanCadTabelaCliente();
            cadTab.setConexao(Apoio.getUsuario(request).getConexao());
            cadTab.setExecutor(Apoio.getUsuario(request));

            cadTab.setTabela(tab);
            //carregando os dados do cliente por completo(atributos, permissoes)
            cadTab.LoadAllPropertys();
        } else if (acao.equals("atualizar") || acao.equals("incluir")) {
            tab = new BeanTabelaCliente();
            cadTab = new BeanCadTabelaCliente();
            cadTab.setConexao(Apoio.getUsuario(request).getConexao());
            cadTab.setExecutor(Apoio.getUsuario(request));

            tab.setId(acao.equals("atualizar") ? Integer.parseInt(request.getParameter("id")) : 0);
            //populando o JavaBean
            tab.getCliente().setIdcliente(Integer.parseInt(request.getParameter("idremetente")));
            tab.getTipoProduto().setId(Integer.parseInt(request.getParameter("tipo_produto_id")));
            tab.setTipoRota(request.getParameter("tipo_rota"));
            tab.getCidadeOrigem().setIdcidade(Integer.parseInt(request.getParameter("idcidadeorigem")));
            tab.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("idcidadedestino")));
            tab.getAreaOrigem().setId(Integer.parseInt(request.getParameter("idareaorigem")));
            tab.getAreaDestino().setId(Integer.parseInt(request.getParameter("idareadestino")));
            tab.setTipoFretePeso(request.getParameter("tipo_peso"));
            tab.setValorPeso(Apoio.parseFloat(request.getParameter("valor_peso")));
            tab.setValorExcedente(Float.parseFloat(request.getParameter("valor_excedente")));
            tab.setValorExcedenteAereo(Float.parseFloat(request.getParameter("valor_excedente_aereo")));
            tab.setBaseCubagem(Float.parseFloat(request.getParameter("base_cubagem")));
            tab.setBaseCubagemAereo(Float.parseFloat(request.getParameter("base_cubagem_aereo")));
            tab.setValorVolume(Float.parseFloat(request.getParameter("valor_volume")));
            tab.setValorPallet(Double.parseDouble(request.getParameter("valor_pallet")));
            tab.setPercentualNf(Float.parseFloat(request.getParameter("percentual_nf")));
            tab.setBaseNfPercentual(Float.parseFloat(request.getParameter("baseNfPercentual")));
            tab.setValorPercentualNf(Float.parseFloat(request.getParameter("valorPercentualNf")));
            tab.setPercentualGris(Float.parseFloat(request.getParameter("percentual_gris")));
            tab.setPercentualAdValorEm(Float.parseFloat(request.getParameter("percentual_advalorem")));
            tab.setValorDespacho(Float.parseFloat(request.getParameter("valor_despacho")));
            tab.setValorOutros(Float.parseFloat(request.getParameter("valor_outros")));
            tab.setValorTaxaFixa(Float.parseFloat(request.getParameter("valor_taxa_fixa")));
            tab.setValorPedagio(Float.parseFloat(request.getParameter("valor_pedagio")));
            tab.setQtdQuiloPedagio(Integer.parseInt(request.getParameter("qtd_quilo_pedagio")));
            tab.setValorFreteMinimo(Float.parseFloat(request.getParameter("valor_frete_minimo")));
            tab.setPrazoEntrega(Integer.parseInt(request.getParameter("prazo_entrega")));
            tab.setPrazoEntregaAereo(Integer.parseInt(request.getParameter("prazo_entrega_aereo")));
            tab.setTipoDiasEntrega(request.getParameter("tipo_dias_entrega"));
            tab.setTipoDiasEntregaAereo(request.getParameter("tipo_dias_entrega_aereo"));
            tab.setValidaAte(request.getParameter("validade").equals("") ? null : Apoio.paraDate(request.getParameter("validade")));
            tab.setIncluiIcms(Boolean.parseBoolean(request.getParameter("incluir_icms")));
            tab.setIncluirFederais(Boolean.parseBoolean(request.getParameter("incluir_federais")));
            tab.setPrecoTonelada(Boolean.parseBoolean(request.getParameter("preco_tonelada")));
            tab.setDesativada(Boolean.parseBoolean(request.getParameter("desativada")));
            tab.setDeduzirPedagioIcms(Boolean.parseBoolean(request.getParameter("deduzirPedagioIcms")));
            tab.setConsiderarMaiorPeso(Apoio.parseBoolean(request.getParameter("considerarPeso")));
            tab.setDesconsideraIcmsMinimo(Boolean.parseBoolean(request.getParameter("chkDesconsiderarIcms")));
            tab.setValorMinimoGris(Double.parseDouble(request.getParameter("valorMinimoGris")));
            tab.setPercentualDevolucao(Double.parseDouble(request.getParameter("valorDevolucao")));
            tab.setPercentualReentrega(Double.parseDouble(request.getParameter("valorReentrega")));
            tab.setValorDificuldadeEntrega(Double.parseDouble(request.getParameter("valorTde")));
            tab.setValorSecCat(Double.parseDouble(request.getParameter("valor_sec_cat")));
            tab.setTipoImpressaoPercentual(request.getParameter("tipoImpressaoPercentual"));
            tab.setTipoImpressaoFreteMinimo(request.getParameter("tipoImpressaoFreteMinimo"));
            tab.setDesconsideraGrisMinimo(Boolean.parseBoolean(request.getParameter("desconsideraGris")));
            tab.setDesconsideraSeguroMinimo(Boolean.parseBoolean(request.getParameter("desconsideraSeguro")));
            tab.setDesconsideraDespachoMinimo(Boolean.parseBoolean(request.getParameter("desconsideraDespacho")));
            tab.setDesconsideraOutrosMinimo(Boolean.parseBoolean(request.getParameter("desconsideraOutros")));
            tab.setDesconsideraPedagioMinimo(Boolean.parseBoolean(request.getParameter("desconsideraPedagio")));
            tab.setDesconsideraTaxaMinimo(Boolean.parseBoolean(request.getParameter("desconsideraTaxa")));
            tab.setDesconsideraSeccatMinimo(Boolean.parseBoolean(request.getParameter("desconsideraSec")));
            tab.setFormulaOutros(request.getParameter("formula_outros"));
            tab.setFormulaVolumes(request.getParameter("formula_volumes"));
            tab.setFormulaPercentual(request.getParameter("formula_percentual"));
            tab.setFormulaSeguro(request.getParameter("formula_seguro"));
            tab.setFormulaGris(request.getParameter("formula_gris"));
            tab.setFormulaDespacho(request.getParameter("formula_despacho"));
            tab.setFormulaTaxaFixa(request.getParameter("formula_taxa_fixa"));
            tab.setFormulaSecCat(request.getParameter("formula_sec_cat"));
            tab.setFormulaMinimo(request.getParameter("formula_minimo"));
            tab.setFormulaPallet(request.getParameter("formula_pallet"));
            tab.setFormulaIcms(request.getParameter("formula_icms"));
            tab.setFormulaFretePeso(request.getParameter("formula_frete_peso"));
            tab.setFormulaTDE(request.getParameter("formula_tde"));
            tab.setFormulaPedagio(request.getParameter("formula_pedagio"));
            tab.setTipoTde(request.getParameter("tipoTde"));
            tab.setTaxaApartirEntrega(Integer.parseInt(request.getParameter("entrega_montagem")));
            tab.setPesoLimiteTaxaFixa(Double.parseDouble(request.getParameter("peso_limite_taxa_fixa")));
            tab.setValorExcedenteTaxaFixa(Double.parseDouble(request.getParameter("valor_excedente_taxa_fixa")));
            tab.setPesoLimiteSecCat(Double.parseDouble(request.getParameter("peso_limite_sec_cat")));
            tab.setValorExcedenteSecCat(Double.parseDouble(request.getParameter("valor_excedente_sec_cat")));
            tab.setTipoInclusaoIcms(request.getParameter("tipo_inclusao_icms"));
            tab.setTipoTaxa(Apoio.parseInt(request.getParameter("tipotaxa")));
            tab.setConsiderarValorMaiorPesoNota(Apoio.parseBoolean(request.getParameter("considerarMaiorValor")));
            tab.setFreteIdaVolta(Apoio.parseBoolean(request.getParameter("chkFreteIdaVolta")));
            tab.setCalculaSecCat(request.getParameter("calculaSecCat"));
            tab.setDataVigencia(request.getParameter("dataVigencia").equals("") ? null : Apoio.paraDate(request.getParameter("dataVigencia")));

            //@Deprecated
//            faixas de peso Antiga, sendo enviada via post
//            if (!request.getParameter("faixas").equals("")) {
//                String[] strFx = request.getParameter("faixas").split(",");
//                FaixaPeso faixa[] = new FaixaPeso[strFx.length];
//                for (int i = 0; i < strFx.length; ++i) {
//                    FaixaPeso fai = new FaixaPeso();
//                    fai.setId(Integer.parseInt(strFx[i].split("_")[0]));
//                    fai.setValorFaixa(Float.parseFloat(strFx[i].split("_")[1]));
//                    fai.setPesoInicial(Float.parseFloat(strFx[i].split("_")[2]));
//                    fai.setPesoFinal(Float.parseFloat(strFx[i].split("_")[3]));
//                    fai.setTipoValor(strFx[i].split("_")[4]);
//                    faixa[i] = fai;
//                }
//                tab.setFaixasPeso(faixa);
//            }
            //Abaixo trexo de código para receber os campos via post
            int maxFaixa = Integer.parseInt(request.getParameter("qtdItensFaixa") != null ? request.getParameter("qtdItensFaixa") : "0");
            FaixaPeso faixa[] = new FaixaPeso[maxFaixa];
            FaixaPeso fa = null;
            for (int i = 0; i < maxFaixa; i++) {
                fa = new FaixaPeso();
                fa.setId(Apoio.parseInt(request.getParameter("id_faixa_" + i)));
                fa.setValorFaixa(Apoio.parseFloat(request.getParameter("valor_peso_faixa_" + i)));
                fa.setPesoInicial(Apoio.parseFloat(request.getParameter("peso_inicial_faixa_" + i)));
                fa.setPesoFinal(Apoio.parseFloat(request.getParameter("peso_final_faixa_" + i)));
                fa.setTipoValor(request.getParameter("tipo_valor_faixa_" + i));

                faixa[i] = fa;
            }
            tab.setFaixasPeso(faixa);

            //@Deprecated
//            //faixas de peso aéreo
//            if (!request.getParameter("faixasAereo").equals("")) {
//                String[] strFx = request.getParameter("faixasAereo").split(",");
//                FaixaPeso faixaAereo[] = new FaixaPeso[strFx.length];
//                for (int i = 0; i < strFx.length; ++i) {
//                    FaixaPeso fai = new FaixaPeso();
//                    fai.setId(Integer.parseInt(strFx[i].split("_")[0]));
//                    fai.setValorFaixa(Float.parseFloat(strFx[i].split("_")[1]));
//                    fai.setPesoInicial(Float.parseFloat(strFx[i].split("_")[2]));
//                    fai.setPesoFinal(Float.parseFloat(strFx[i].split("_")[3]));
//                    fai.setTipoValor(strFx[i].split("_")[4]);
//
//                    faixaAereo[i] = fai;
//
//                }
//                tab.setFaixasPesoAereo(faixaAereo);
//            }
            //Abaixo trexo de código para receber os campos via post
            int maxAereo = Integer.parseInt(request.getParameter("qtdItensAereo") != null ? request.getParameter("qtdItensAereo") : "0");
            FaixaPeso faixaAereo[] = new FaixaPeso[maxAereo];
            FaixaPeso fai = null;
            for (int i = 0; i < maxAereo; i++) {
                fai = new FaixaPeso();
                fai.setId(Apoio.parseInt(request.getParameter("id_faixa_aereo_" + i)));
                fai.setValorFaixa(Apoio.parseFloat(request.getParameter("valor_peso_faixa_aereo_" + i)));
                fai.setPesoInicial(Apoio.parseFloat(request.getParameter("peso_inicial_faixa_aereo_" + i)));
                fai.setPesoFinal(Apoio.parseFloat(request.getParameter("peso_final_faixa_aereo_" + i)));
                fai.setTipoValor(request.getParameter("tipo_valor_faixa_aereo_" + i));

                faixaAereo[i] = fai;
            }
            tab.setFaixasPesoAereo(faixaAereo);

            //tipos de veiculos
            if (!request.getParameter("veiculos").equals("")) {
                String[] strVei = request.getParameter("veiculos").split(",");
                Tipo_veiculos tipo[] = new Tipo_veiculos[strVei.length];
                for (int i = 0; i < strVei.length; ++i) {
                    Tipo_veiculos tp = new Tipo_veiculos();
                    tp.setTipoVeiculoId(Integer.parseInt(strVei[i].split("_")[0]));
                    tp.setValorCombinado(Apoio.parseFloat(strVei[i].split("_")[1]));
                    tp.setTipoTaxa(Apoio.parseInt(strVei[i].split("_")[2]));
                    tp.setValorPedagio(Apoio.parseFloat(strVei[i].split("_")[3]));
                    tp.setLimitePedagio(Apoio.parseInt(strVei[i].split("_")[4]));
                    tp.setId(Apoio.parseInt(strVei[i].split("_")[5]));
                    tipo[i] = tp;
                }
                tab.setTipoVeiculo(tipo);
            }

            //faixas de km
            if (!request.getParameter("qtdFaixasKm").equals("0")) {
                int cont = 0;
                int qtdKm = Integer.parseInt(request.getParameter("qtdFaixasKm"));
                FaixaKm faixaK[] = new FaixaKm[(qtdKm + 1) * tiposVeiculos.split("!-").length];
                for (int i = 0; i <= qtdKm; ++i) {
                    if (request.getParameter("kmDe" + i) != null) {
                        for (int j = 0; j < tiposVeiculos.split("!-").length; ++j) {
                            int tipo = Integer.parseInt(tiposVeiculos.split("!-")[j].split("!!")[0]);
                            FaixaKm faiK = new FaixaKm();
                            faiK.setId(Integer.parseInt(request.getParameter("idKm" + i + "-" + tipo)));
                            faiK.setKmDe(Integer.parseInt(request.getParameter("kmDe" + i)));
                            faiK.setKmAte(Integer.parseInt(request.getParameter("kmAte" + i)));
                            faiK.getTipoVeiculo().setId(tipo);
                            faiK.setValor(Double.parseDouble(request.getParameter("vlKm" + i + "-" + tipo)));
                            faixaK[cont] = faiK;
                            cont++;
                        }
                    }
                }
                tab.setFaixasKm(faixaK);
            }

            if (tab.isFreteIdaVolta() && !tab.getTipoRota().equals("k")) {

                cadTabClonado = new BeanCadTabelaCliente();
                cadTabClonado.setConexao(Apoio.getUsuario(request).getConexao());
                cadTabClonado.setExecutor(Apoio.getUsuario(request));


                tabClonado = tab.getClone();

                if (tab.getTipoRota().equals("c")) {
                    tabClonado.setCidadeOrigem(tab.getCidadeDestino());
                    tabClonado.setCidadeDestino(tab.getCidadeOrigem());
                } else if (tab.getTipoRota().equals("a")) {
                    tabClonado.setAreaOrigem(tab.getAreaDestino());
                    tabClonado.setAreaDestino(tab.getAreaOrigem());
                }

                cadTabClonado.setTabela(tabClonado);

            }

            cadTab.setTabela(tab);

            boolean erroSalvar = false;
            if (acao.equals("atualizar")) {
                erroSalvar = !cadTab.Atualiza();
            } else if (acao.equals("incluir") && nivelUser >= 3) {
                erroSalvar = !cadTab.Inclui();

                if (!erroSalvar && cadTabClonado != null) {
                    erroSalvar = !cadTabClonado.Inclui();
                }
            }

            //EXIBINDO MENSAGEM DE CENï¿½RIO E REDIRECIONANDO
            if (erroSalvar) {
                response.getWriter().append("<script>"
                        + "window.opener.habilitaSalvar(true);"
                        + "alert('" + cadTab.getErros() + "');"
                        + "window.close();"
                        + "</script>");
            } else {
                String scr = "";
                scr = "<script>";
                scr += "window.opener.document.location.replace('./consulta_tabelacliente.jsp?acao=iniciar');"
                        + "window.close();"
                        + "</script>";
                response.getWriter().append(scr);
        }
            response.getWriter().close();
    }
    }
    boolean carregaTab = (tab != null && (!acao.equals("incluir") && !acao.equals("atualizar")));

    if (carregaTab) {
        request.setAttribute("tab", tab);
        request.setAttribute("permissaoTabelaRota", Apoio.getUsuario(request).getAcesso("cadrota") >= NivelAcessoUsuario.LER_ALTERAR.getNivel());
    }
    
    request.setAttribute("user", Apoio.getUsuario(request));

%>


<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
        <script language="JavaScript" src="script/jQuery/jquery.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script language="JavaScript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js?v=${random.nextInt()}" type="text/javascript"></script>
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
            //
            //   Essa função não esa mais sendo usada, por que estava dando erro ao utilizar, a
            //   solução foi colocar no arquivo externo que no caso foi utilizado o funcoes.js
            //   function tipoPeso(tipo) {
            //        if (tipo == "p") {
            //            $('tipoPeso').checked = true;
            //            $('tipoFaixa').checked = false;
            //            $('valor_peso').disabled = false;
            //            $('precoTonelada').disabled = false;
            //            setReadOnlyFaixa(true);
            //            readOnly($("valor_excedente"));
            //            setReadOnlyFaixaAereo(true);
            //            readOnly($("valor_excedente_aereo"));
            //
            //        } else {
            //            $('tipoPeso').checked = false;
            //            $('tipoFaixa').checked = true;
            //            $('valor_peso').disabled = true;
            //            $('precoTonelada').disabled = true;
            //            setReadOnlyFaixa(false);
            //            notReadOnly($("valor_excedente"));
            //            setReadOnlyFaixaAereo(false);
            //            notReadOnly($("valor_excedente_aereo"));
            //        }
            //    }


            function voltar() {
                location.replace("./consulta_tabelacliente.jsp?acao=iniciar");
            }

            function habilitaSalvar(opcao) {
                $("gravar").disabled = !opcao;
                $("gravar").value = (opcao ? "Salvar" : "Enviando...");
            }

            function validaDataVigencia(){
                    if($('dataVigencia') != null && $('dataVigencia').value == ''){
                        return false;
                    }
                return true;
            }
            //Salva as informaï¿½ï¿½es digitadas
            function salva(acao) {
                //Validando campos em branco
                var freteIdaVolta = false;
                if ($("chkFreteIdaVolta") != null && $("chkFreteIdaVolta").checked) {
                    freteIdaVolta = true;
                }

                if ($("is_utilizar_tipo_frete_tabela").value == 't' || $("is_utilizar_tipo_frete_tabela").value == 'true') {
                    if ($("tipotaxa").value == '-1') {
                        alert("Informe o Tipo de Frete!");
                        return false;
                    }
                }
                if ($("rotaCidade").checked && ($("idcidadeorigem").value == "0" || $("idcidadedestino").value == "0")) {
                    alert("Informe a cidade de origem/destino corretamente.");
                }
                else if ($("rotaArea").checked && ($("idareaorigem").value == "0" || $("idareadestino").value == "0")) {
                    alert("Informe a área de origem/destino corretamente.");
                }else if(!validaDataVigencia()){
                        alert("Atenção! O campo data de vigência é de preenchimento obrigatório");
                }else {

                    var permitirSalvarTabela = true;

                    // Primeiro salva a tabela do carreteiro/rota, se foi carregada
                    if (jQuery('div[class="container-nova-linha"]').size() > 0) {
                        var json = jQuery('.container-tabela-veiculo').gwFormToJson();

                        jQuery.ajax({
                            method: 'POST',
                            async: false,
                            dataType: 'json',
                            url: homePath + '/TabelaPrecoControlador',
                            data: {
                                'acao': 'salvarTabelaPrecoVeiculo',
                                'json': json
                            }
                        }).done(function(data) {
                            if (data) {
                                if (data['erro']) {
                                    permitirSalvarTabela = false;
                                    alert('Tabela Carreteiro: ' + data['erro']);
                                }
                            }
                        });
                    }

                    if (permitirSalvarTabela) {
                        if (acao == "atualizar")
                            acao += "&id=<%=(tab != null ? tab.getId() : 0)%>&";

                        //salvando
                        var url = "./cadtabela_preco.jsp?acao=" + acao + "&" +
                            concatFieldValue("idremetente,tipo_produto_id,idcidadeorigem,idcidadedestino,idareaorigem,idareadestino," +
                                "valor_peso,valor_excedente,base_cubagem,base_cubagem_aereo,valor_volume,percentual_nf,percentual_gris," +
                                "percentual_advalorem,valor_despacho,valor_outros,valor_taxa_fixa,valor_pedagio,qtd_quilo_pedagio,valor_frete_minimo," +
                                "prazo_entrega,prazo_entrega_aereo,validade,incluir_icms,baseNfPercentual,valorPercentualNf,valor_excedente_aereo,valorMinimoGris," +
                                "valorTde,valorDevolucao,valorReentrega,valor_sec_cat,tipoImpressaoPercentual,tipoImpressaoFreteMinimo,valor_pallet,tipoTde,tipo_dias_entrega," +
                                "tipo_dias_entrega_aereo,incluir_federais,entrega_montagem,valor_excedente_sec_cat,peso_limite_sec_cat,valor_excedente_taxa_fixa,peso_limite_taxa_fixa," +
                                "tipo_inclusao_icms, tipotaxa,dataVigencia") +
                            //sem o concatFieldValue
                            "&tipo_rota=" + ($("rotaCidade").checked ? "c" : ($("rotaArea").checked ? "a" : "k")) +
                            "&tipo_peso=" + ($("tipoPeso").checked ? "p" : "f") +
                            "&preco_tonelada=" + $("precoTonelada").checked +
                            "&desconsideraGris=" + $("desconsideraGris").checked +
                            "&desconsideraSeguro=" + $("desconsideraSeguro").checked +
                            "&desconsideraDespacho=" + $("desconsideraDespacho").checked +
                            "&desconsideraOutros=" + $("desconsideraOutros").checked +
                            "&desconsideraPedagio=" + $("desconsideraPedagio").checked +
                            "&desconsideraTaxa=" + $("desconsideraTaxa").checked +
                            "&desconsideraSec=" + $("desconsideraSec").checked +
                            //                    "&faixas=" + getFaixas() +
                            "&qtdItensAereo=" + $("qtdItensAereo").value + //Quantidade de itens do DOM Aéreo agora os campos não estão mais sendo enviado via get, e sim, via post
                            "&qtdItensFaixa=" + $("qtdItensFaixa").value + //Quantidade de Itens do DOM Faixa agora os campos não estão mais sendo enviado via get, e sim, via post
                            //                    "&faixasAereo=" + getFaixasAereo() +
                            "&desativada=" + $('chkDesativada').checked +
                            "&deduzirPedagioIcms=" + $('chkDeduzirPedagioIcms').checked +
                            "&chkDesconsiderarIcms=" + $('chkDesconsiderarIcms').checked +
                            "&considerarPeso=" + $('chkConsiderarPeso').checked +
                            "&considerarMaiorValor=" + $('chkConsiderarMaiorValor').checked +
                            "&veiculos=" + getVeiculos() + "&qtdFaixasKm=" + idxKm + "&tiposVeiculos=<%=tiposVeiculos%>"
                        "&chkFreteIdaVolta=" + freteIdaVolta + "&calculaSecCat=" + $("calculaSecCat").value;

                        $('formTab').action = url;
                        window.open('about:blank', 'pop', 'width=210, height=100');
                        habilitaSalvar(false);

                        $('formTab').submit();
                        //            submitPopupForm($('formTab'));
                    }
                }
            }



            function excluirtabela() {
                if (confirm("Deseja mesmo excluir esta tabela?"))
                {
                    location.replace("./consultatabela?acao=excluir&id=" +<%=request.getParameter("id")%>);
                }
            }

            function  setReadOnlyFaixaAereo(isReadOnly) {
                var i = 0;
                var sair = false;

                if (isReadOnly) {

                    while (!sair) {
                        if ($("peso_inicial_faixa_aereo_" + i) != null) {
                            readOnly($("peso_inicial_faixa_aereo_" + i));
                            readOnly($("peso_final_faixa_aereo_" + i));
                            readOnly($("valor_peso_faixa_aereo_" + i));
                            readOnly($("tipo_valor_faixa_aereo_" + i));
                            desabilitar($("tipo_valor_faixa_aereo_" + i));

                        } else {
                            sair = true;
                        }
                        i++;

                    }
                } else {
                    while (!sair) {
                        if ($("peso_inicial_faixa_aereo_" + i) != null) {
                            notReadOnly($("peso_inicial_faixa_aereo_" + i));
                            notReadOnly($("peso_final_faixa_aereo_" + i));
                            notReadOnly($("valor_peso_faixa_aereo_" + i));
                            notReadOnly($("tipo_valor_faixa_aereo_" + i));
                            habilitar($("tipo_valor_faixa_aereo_" + i));

                        } else {
                            sair = true;
                        }
                        i++;
                    }
                }
            }

            function  setReadOnlyFaixa(isReadOnly) {
                var i = 0;
                var sair = false;

                if (isReadOnly) {
                    while (!sair) {
                        if ($("peso_inicial_faixa_" + i) != null) {
                            readOnly($("peso_inicial_faixa_" + i));
                            readOnly($("peso_final_faixa_" + i));
                            readOnly($("valor_peso_faixa_" + i));
                            readOnly($("tipo_valor_faixa_" + i));
                            desabilitar($("tipo_valor_faixa_" + i));
                        } else {
                            sair = true;
                        }
                        i++;
                    }
                } else {
                    while (!sair) {
                        if ($("peso_inicial_faixa_" + i) != null) {
                            notReadOnly($("peso_inicial_faixa_" + i));
                            notReadOnly($("peso_final_faixa_" + i));
                            notReadOnly($("valor_peso_faixa_" + i));
                            notReadOnly($("tipo_valor_faixa_" + i));
                            habilitar($("tipo_valor_faixa_" + i));
                        } else {
                            sair = true;
                        }
                        i++;
                    }
                }
            }

            function seAlterando() {
                //Botï¿½o excluir
                //Apenas se tiver em modo de ediï¿½ï¿½o
            <%if (carregaTab) {%>
                tipoFrota('<%=tab.getTipoRota()%>');
                tipoPesoTelaTabela('<%=tab.getTipoFretePeso()%>');

                $("tipoImpressaoPercentual").value = '<%=tab.getTipoImpressaoPercentual()%>';
                $("tipoImpressaoFreteMinimo").value = '<%=tab.getTipoImpressaoFreteMinimo()%>';
                //Primeiro percorro todo o vetor para concatenar o id, tipo_veiculo_id e valor
            <%String tpVeiculos = "";
                int referencia = 0;
                FaixaKm fxK = new FaixaKm();
                for (int s = 0; s < tab.getFaixasKm().length; ++s) {
                    if (s == 0) {
                        referencia = tab.getFaixasKm()[s].getKmDe();
                    }
                    if (referencia != tab.getFaixasKm()[s].getKmDe()) {
                        referencia = tab.getFaixasKm()[s].getKmDe();
            %>
                addKm(<%=fxK.getId()%>, <%=fxK.getKmDe()%>, <%=fxK.getKmAte()%>, '<%=tpVeiculos%>', false);
            <%tpVeiculos = "";
                }
                fxK = tab.getFaixasKm()[s];
                tpVeiculos += (tpVeiculos.equals("") ? "" : "!-") + fxK.getTipoVeiculo().getId() + "!!" + Apoio.to_curr(fxK.getValor()) + "!!" + fxK.getId();
            %>
            <%}%>
                //validando os campos que contem formula
                isFormulaReadOnly("formula_gris");
                isFormulaReadOnly("formula_outros");
                isFormulaReadOnly("formula_volumes");
                isFormulaReadOnly("formula_pallet");
                isFormulaReadOnly("formula_percentual");
                isFormulaReadOnly("formula_seguro");
                isFormulaReadOnly("formula_taxa_fixa");
                isFormulaReadOnly("formula_despacho");
                isFormulaReadOnly("formula_sec_cat");
                isFormulaReadOnly("formula_minimo");
                isFormulaReadOnly("formula_frete_peso");
                isFormulaReadOnly("formula_pedagio");
                isFormulaReadOnly("formula_tde");
                //Repetir o cï¿½digo para gravar o ultimo registro
            <%if (tab.getFaixasKm().length > 0) {%>
                addKm(<%=fxK.getId()%>, <%=fxK.getKmDe()%>, <%=fxK.getKmAte()%>, '<%=tpVeiculos%>', false);
            <%}
            } else {%>
                tipoFrota('c');
                tipoPesoTelaTabela('p');
            <%}%>
            }

            function tipoFrota(tipo) {

                if (tipo == 'c') {
                    $('rotaCidade').checked = true;
                    $('rotaArea').checked = false;
                    $('rotaKm').checked = false;
                    $('idareaorigem').value = '0';
                    $('area_ori').value = '';
                    $('idareadestino').value = '0';
                    $('area_des').value = '';
                    $('localiza_cidade_origem').disabled = false;
                    $('localiza_cidade_destino').disabled = false;
                    $('localiza_area_origem').disabled = true;
                    $('localiza_area_destino').disabled = true;
                    $('faixaKm').style.display = 'none';
                    $('trCombinado').style.display = '';
                    $('trNotaFiscal').style.display = '';
                    $('trNotaFiscal2').style.display = '';
                    $('trPallet').style.display = '';
                    $('trVolumes').style.display = '';
                    $('trCubagem').style.display = '';
                    $('trCubagem2').style.display = '';
                    $('trCubagem3').style.display = '';
                    $('trPeso').style.display = '';
                    $('trChkConsiderarMaiorValor').style.display = '';
                    $("divFreteIdaVolta").style.display = '<%= carregaTab ? "none" : "" %>';
                } else if (tipo == 'a') {
                    $('rotaCidade').checked = false;
                    $('rotaArea').checked = true;
                    $('rotaKm').checked = false;
                    $('idcidadeorigem').value = '0';
                    $('cid_origem').value = '';
                    $('uf_origem').value = '';
                    $('idcidadedestino').value = '0';
                    $('cid_destino').value = '';
                    $('uf_destino').value = '';
                    $('localiza_cidade_origem').disabled = true;
                    $('localiza_cidade_destino').disabled = true;
                    $('localiza_area_origem').disabled = false;
                    $('localiza_area_destino').disabled = false;
                    $('faixaKm').style.display = 'none';
                    $('trCombinado').style.display = '';
                    $('trNotaFiscal').style.display = '';
                    $('trNotaFiscal2').style.display = '';
                    $('trPallet').style.display = '';
                    $('trVolumes').style.display = '';
                    $('trCubagem').style.display = '';
                    $('trCubagem2').style.display = '';
                    $('trCubagem3').style.display = '';
                    $('trPeso').style.display = '';
                    $('trChkConsiderarMaiorValor').style.display = '';
                    $("divFreteIdaVolta").style.display = '<%= carregaTab ? "none" : "" %>';
                } else {
                    $('rotaCidade').checked = false;
                    $('rotaArea').checked = false;
                    $('rotaKm').checked = true;
                    $('idcidadeorigem').value = '0';
                    $('cid_origem').value = '';
                    $('uf_origem').value = '';
                    $('idcidadedestino').value = '0';
                    $('cid_destino').value = '';
                    $('uf_destino').value = '';
                    $('localiza_cidade_origem').disabled = true;
                    $('localiza_cidade_destino').disabled = true;
                    $('localiza_area_origem').disabled = true;
                    $('localiza_area_destino').disabled = true;
                    $('idareaorigem').value = '0';
                    $('area_ori').value = '';
                    $('idareadestino').value = '0';
                    $('area_des').value = '';
                    $('faixaKm').style.display = '';
                    $('trCombinado').style.display = 'none';
                    $('trNotaFiscal').style.display = 'none';
                    $('trNotaFiscal2').style.display = 'none';
                    $('trPallet').style.display = 'none';
                    $('trVolumes').style.display = 'none';
                    $('trCubagem').style.display = 'none';
                    $('trCubagem2').style.display = 'none';
                    $('trCubagem3').style.display = 'none';
                    $('trPeso').style.display = 'none';
                    $('trChkConsiderarMaiorValor').style.display = 'none';
                    $("divFreteIdaVolta").style.display = "none";
                }
            }

            function aoCarregar() {
                if ($("idHiddenCliente").value != "0" && $("hiddenDescCliente").value != "") {
                    $("rem_rzs").value = $("hiddenDescCliente").value;
                    $("idremetente").value = $("idHiddenCliente").value;
                    $("localiza_rem").style.display = "none";
                    $("borrLocRem").style.display = "none";
                }
                showTipoFrete();
            }

            function aoClicarNoLocaliza(idjanela)
            {
                if (idjanela == "Area_Origem") {
                    $('idareaorigem').value = $('area_id').value
                    $('area_ori').value = $('sigla_area').value
                } else if (idjanela == "Area_Destino") {
                    $('idareadestino').value = $('area_id').value
                    $('area_des').value = $('sigla_area').value
                }

                if (idjanela == "Remetente") {
                    showTipoFrete();
                }

            }

            function showTipoFrete() {
                if ($("is_utilizar_tipo_frete_tabela").value == 't' || $("is_utilizar_tipo_frete_tabela").value == 'true') {
                    $("tdTipoFrete1").style.display = "";
                    //$("tdTipoFrete2").style.display = "";
                } else {
                    $("tdTipoFrete1").style.display = "none";
                    //$("tdTipoFrete2").style.display = "none";
                }
            }

            //    function getFaixas() {
            //        var urlData = "";
            //        for (e = 0; e <= 20; ++e) {
            //            if ($("id_faixa_" + e) != null) {
            //                urlData += (urlData == "" ? "" : ",") + $("id_faixa_" + e).value + "_" + $("valor_peso_faixa_" + e).value + "_" + $("peso_inicial_faixa_" + e).value + "_" + $("peso_final_faixa_" + e).value + "_" + $("tipo_valor_faixa_" + e).value;
            //            }
            //        }//for
            //        return urlData;
            //    }
            //
            //    function getFaixasAereo() {
            //        var urlData = "";
            //        for (e = 0; e <= 50; ++e) {
            //
            //            if ($("id_faixa_aereo_" + e) != null) {
            //                urlData += (urlData == "" ? "" : ",") + $("id_faixa_aereo_" + e).value + "_" + $("valor_peso_faixa_aereo_" + e).value + "_" + $("peso_inicial_faixa_aereo_" + e).value + "_" + $("peso_final_faixa_aereo_" + e).value + "_" + $("tipo_valor_faixa_aereo_" + e).value;
            //            }
            //        }//for
            //        return urlData;
            //    }

            function getVeiculos()
            {
                var urlData = "";
                for (e = 0; e <= parseFloat($("maxVeic").value); ++e)
                {
                    if ($("id_veiculo_" + e) != null)
                    {
                        if (urlData == "")
                            urlData += $("id_veiculo_" + e).value + "_" + $("valor_tipo_veiculo_" + e).value + "_" + $("tipo_taxa_combinado_" + e).value + "_"
                                + $("valor_pedagio_" + e).value + "_" + $("limite_pedagio_" + e).value + "_" + $("tipo_veiculo_id_" + e).value;
                        else
                            urlData += "," + $("id_veiculo_" + e).value + "_" + $("valor_tipo_veiculo_" + e).value + "_" + $("tipo_taxa_combinado_" + e).value + "_"
                                + $("valor_pedagio_" + e).value + "_" + $("limite_pedagio_" + e).value + "_" + $("tipo_veiculo_id_" + e).value;
                    }
                }//for
                return urlData;
            }

            function isFormulaReadOnly(campo) {
                var valor = replaceAll($(campo).value, " ", "\r\n");

                if (valor.trim().length > 0) {
                    switch (campo) {
                        case "formula_gris":
                            readOnly($("percentual_gris"));
                            readOnly($("valorMinimoGris"));
                            break;
                        case "formula_outros":
                            readOnly($("valor_outros"));
                            break;
                        case "formula_pallet":
                            readOnly($("valor_pallet"));
                            break;
                        case "formula_volumes":
                            readOnly($("valor_volume"));
                            break;
                        case "formula_percentual":
                            readOnly($("percentual_nf"));
                            readOnly($("baseNfPercentual"));
                            readOnly($("valorPercentualNf"));
                            break;
                        case "formula_seguro":
                            readOnly($("percentual_advalorem"));
                            break;
                        case "formula_taxa_fixa":
                            readOnly($("valor_taxa_fixa"));
                            break;
                        case "formula_despacho":
                            readOnly($("valor_despacho"));
                            break;
                        case "formula_sec_cat":
                            readOnly($("valor_sec_cat"));
                            break;
                        case "formula_minimo":
                            readOnly($("valor_frete_minimo"));
                            break;
                        case "formula_icms":
                            break;
                        case "formula_frete_peso":
                            readOnly($("valor_peso"));
                            break;
                        case "formula_pedagio":
                            //se for numa formula zerar o valor.
                            $("valor_pedagio").value = "0.00";
                            $("qtd_quilo_pedagio").value = "0";
                            readOnly($("valor_pedagio"));
                            readOnly($("qtd_quilo_pedagio"));
                            break;
                        case "formula_tde":
                            readOnly($("valorTde"));
                            break;
                    }
                } else {
                    switch (campo) {
                        case "formula_gris":
                            notReadOnly($("percentual_gris"));
                            notReadOnly($("valorMinimoGris"));
                            break;
                        case "formula_outros":
                            notReadOnly($("valor_outros"));
                            break;
                        case "formula_pallet":
                            notReadOnly($("valor_pallet"));
                            break;
                        case "formula_volumes":
                            notReadOnly($("valor_volume"));
                            break;
                        case "formula_percentual":
                            notReadOnly($("percentual_nf"));
                            notReadOnly($("baseNfPercentual"));
                            notReadOnly($("valorPercentualNf"));
                            break;
                        case "formula_seguro":
                            notReadOnly($("percentual_advalorem"));
                            break;
                        case "formula_taxa_fixa":
                            notReadOnly($("valor_taxa_fixa"));
                            break;
                        case "formula_despacho":
                            notReadOnly($("valor_despacho"));
                            break;
                        case "formula_sec_cat":
                            notReadOnly($("valor_sec_cat"));
                            break;
                        case "formula_minimo":
                            notReadOnly($("valor_frete_minimo"));
                            break;
                        case "formula_icms":
                            break;
                        case "formula_frete_peso":
                            notReadOnly($("valor_peso"));
                            break;
                        case "formula_pedagio":
                            notReadOnly($("valor_pedagio"));
                            notReadOnly($("qtd_quilo_pedagio"));
                            break;
                        case "formula_tde":
                            notReadOnly($("valorTde"));
                            break;
                    }
                }
            }

            var idxKm = 0;
            var puloKm = 0;
            /**addKm(id, kmDe, kmAte, tipos, incluindo)*/
            function addKm(_id, kmDe, kmAte, tipos, incluindo) {
                if (incluindo) {
                    if ($('kmAte' + idxKm) != null) {
                        if (puloKm == 0) {
                            puloKm = (parseFloat($('kmAte' + idxKm).value) - parseFloat($('kmDe' + idxKm).value));
                        }
                        kmDe = parseFloat($('kmAte' + idxKm).value) + 1;
                        kmAte = parseFloat(kmDe - 1) + parseFloat(puloKm);
                    }
                }
                idxKm++;

                var _tr = Builder.node('TR', {id: 'trKm' + idxKm, className: 'CelulaZebra2'},
                [Builder.node('td', [Builder.node('DIV', {align: 'center'},
                        [Builder.node('IMG', {border: '0', src: './img/cancelar.png',
                                style: 'cursor:pointer;', align: 'center', onclick: 'Element.remove($(\'trKm' + idxKm + '\'))'}
                            )])
                    ]),
                    Builder.node('td', [Builder.node('INPUT', {type: 'text', name: 'kmDe' + idxKm, id: 'kmDe' + idxKm, size: '8', maxlength: '6', className: 'inputtexto',
                            value: kmDe, onChange: 'seNaoIntReset(this,\'0\');'})
                    ]),
                    Builder.node('td', [Builder.node('INPUT', {type: 'text', name: 'kmAte' + idxKm, id: 'kmAte' + idxKm, size: '8', maxlength: '6', className: 'inputtexto',
                            value: kmAte, onChange: 'seNaoIntReset(this,\'0\');'})
                    ]),
                ]);

                $('tKm').appendChild(_tr);

                for (e = 0; e <= tipos.split('!-').length - 1; ++e) {
                    var idTipo = tipos.split('!-')[e].split('!!')[0];
                    var vlTipo = tipos.split('!-')[e].split('!!')[1];
                    var vlIdKM = tipos.split('!-')[e].split('!!')[2];//esse id vem concatenado.
                    $('trKm' + idxKm).appendChild(Builder.node('td', [Builder.node('INPUT', {type: 'text', name: 'vlKm' + idxKm + '-' + idTipo, id: 'vlKm' + idxKm + '-' + idTipo,
                            size: '8', maxlength: '12', value: vlTipo, className: 'inputtexto',
                            onChange: 'seNaoFloatReset(this,\'0.00\');'}),
                        Builder.node('INPUT', {name: 'idKm' + idxKm + '-' + idTipo, id: 'idKm' + idxKm + '-' + idTipo, value: vlIdKM, type: 'hidden'}),
                    ]));
                }

            }

            function marcarTodos(isOnload) {
                if (isOnload) {
                    var checkGris = $('desconsideraGris').checked;
                    var checkSeguro = $('desconsideraSeguro').checked;
                    var checkDespacho = $('desconsideraDespacho').checked;
                    var checkOutros = $('desconsideraOutros').checked;
                    var checkPedagio = $('desconsideraPedagio').checked;
                    var checkTaxa = $('desconsideraTaxa').checked;
                    var checkSec = $('desconsideraSec').checked;

                    if (checkGris && checkSeguro && checkDespacho && checkOutros &&
                            checkPedagio && checkTaxa && checkSec) {
                        $('marcaTodos').checked = true;
                    }

                }else {
                    $('desconsideraGris').checked = $('marcaTodos').checked;
                    $('desconsideraSeguro').checked = $('marcaTodos').checked;
                    $('desconsideraDespacho').checked = $('marcaTodos').checked;
                    $('desconsideraOutros').checked = $('marcaTodos').checked;
                    $('desconsideraPedagio').checked = $('marcaTodos').checked;
                    $('desconsideraTaxa').checked = $('marcaTodos').checked;
                    $('desconsideraSec').checked = $('marcaTodos').checked;
                }
            }

            function exibirFormula__(objx) {
                var promp = document.createElement("DIV");
                promp.id = "promptFormula";
                document.body.appendChild(promp);
                var obj = document.getElementById("promptFormula").style;
                obj.zIndex = "3";
                obj.position = "absolute";
                obj.backgroundColor = "#FFFFFF";
                obj.left = "24%";
                obj.top = "20%";
                obj.width = "52%";
                obj.height = "52%";
                var cmdHtml = "";
                //Criando a tabela
                cmdHtml = "<table width='100%' class='bordaFina'>" +
                        "<tr class='tabela'>" +
                        "<td align='center'>" +
                        "Editar fórmula" +
                        "</td>" +
                        "</tr>" +
                        "<tr class='Celula'>" +
                        "<td align='center'>" +
                        "Variáveis" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td align='center'>" +
                        "<table width='100%'>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Peso:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@peso</td>" +
                        "<td width='25%' class='TextoCampos'>Valor Mercadoria:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@mercadoria</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Volumes:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@volume</td>" +
                        "<td width='25%' class='TextoCampos'>Tipo Frete:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@tipoFrete</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Quantidade KM:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@km</td>" +
                        "<td width='25%' class='TextoCampos'>Paletts:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@pallets</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Tipo de veículo:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@tipoVeiculo</td>" +
                        "<td width='25%' class='TextoCampos'>Qtd de Entregas</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@entregas</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Peso Cubado:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@cubado</td>" +
                        "<td width='25%' class='TextoCampos'>CIF = 0, FOB = 1 ou CON = 2: </td>" +
                        "<td width='25%' class='CelulaZebra2'>@@pagador_frete</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Valor Frete Redespacho:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@frete_redespacho</td>" +
                        "<td width='25%' class='TextoCampos'>ICMS Frete Redespacho:</td>" +
                        "<td width='25%' class='CelulaZebra2'>@@icms_redespacho</td>" +
                        "</tr>" +
                        "</table>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td class='CelulaZebra2'>" +
                        "<textarea cols='70' rows='13' name='ed_formula' type='text' id='ed_formula' style='font-size:8pt;'>" + objx.value + "</textarea>" +
                        "</td>" +
                        "</tr>" +
                        "<tr class='CelulaZebra2'>" +
                        "<td align='center'>" +
                        "<input name='btSalvaFormula' id='btSalvaFormula' type='button' class='botoes' value='Confirmar' alt='Salvar as alterações na fórmula'>" +
                        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<input name='btFechaFormula' id='btFechaFormula' type='button' class='botoes' value='Cancelar' alt='Cancelar as alterações na fórmula'>" +
                        "</td>" +
                        "</tr>" +
                        "</table>";
                document.getElementById("promptFormula").innerHTML = cmdHtml;
                document.getElementById("promptFormula").style.display = "";
                document.getElementById("btSalvaFormula").onclick = function () {
                    objx.value = $('ed_formula').value;
                    document.getElementById("promptFormula").style.display = "none";
                }
                document.getElementById("btFechaFormula").onclick = function () {
                    document.getElementById("promptFormula").style.display = "none";
                }
            }
            function exibirFormula(objx) {
                var promp = document.createElement("DIV");
                promp.id = "promptFormula";
                document.body.appendChild(promp);
                var obj = document.getElementById("promptFormula").style;
                obj.zIndex = "3";
                obj.position = "absolute";
                obj.backgroundColor = "#FFFFFF";
                obj.left = "24%";
                obj.top = "20%";
                obj.width = "52%";
//                obj.height = "52%";
                var cmdHtml = "";
                //Criando a tabela
                cmdHtml = "<table width='100%' class='bordaFina'>" +
                        "<tr class='tabela'>" +
                        "<td align='center'>" +
                        "Editar fórmula" +
                        "</td>" +
                        "</tr>" +
                        "<tr class='celula'>" +
                        "<td align='center'>" +
                        "Variáveis" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td align='center'>" +
                        "<table width='100%' class='bordaFina'>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Peso:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@peso\")'>@@peso</label></td>" +
                        "<td width='25%' class='TextoCampos'>Valor Mercadoria:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@mercadoria\")'>@@mercadoria</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Volumes:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@volume\")'>@@volume</label></td>" +
                        "<td width='25%' class='TextoCampos'>Tipo Frete:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@tipoFrete\")'>@@tipoFrete</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Quantidade KM:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@km\")'>@@km</label></td>" +
                        "<td width='25%' class='TextoCampos'>Paletts:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@pallets\")'>@@pallets</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Tipo de veículo:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@tipoVeiculo\")'>@@tipoVeiculo</label></td>" +
                        "<td width='25%' class='TextoCampos'>Qtd de Entregas</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@entregas\")'>@@entregas</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Peso Cubado:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@cubado\")'>@@cubado</label></td>" +
                        "<td width='25%' class='TextoCampos'>CIF = 0, FOB = 1 ou CON = 2: </td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@pagador_frete\")'>@@pagador_frete</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Valor Frete Redespacho:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@frete_redespacho\")'>@@frete_redespacho</label></td>" +
                        "<td width='25%' class='TextoCampos'>ICMS Frete Redespacho:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@icms_redespacho\")'>@@icms_redespacho</label></td>";

                if (objx.name == 'formula_tde') {
                    cmdHtml += "<tr>" +
                            "<td width='25%' class='TextoCampos'>Frete Peso:</td>" +
                            "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@fretePeso\")'>@@fretePeso</label></td>" +
                            "<td width='25%' class='TextoCampos'>Frete Valor:</td>" +
                            "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@freteValor\")'>@@freteValor</label></td>" +
                            "</tr>"+
                            "<tr><td width='25%' class='TextoCampos'>Total Frete sem TDE:</td>" +
                            "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@totalFrete\")'>@@totalFrete</label></td>" +
                            "<td width='25%' class='CelulaZebra2'></td>" +
                            "<td width='25%' class='CelulaZebra2'></td>";
                }
                cmdHtml += "</tr>";
                cmdHtml += "</table>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td class='CelulaZebra2NoAlign' align='center'>" +
                        "<textarea cols='70' rows='13' name='ed_formula' type='text' id='ed_formula' style='font-size:8pt;'>" + objx.value + "</textarea>" +
                        "</td>" +
                        "</tr>" +
                        "<tr class='CelulaZebra2'>" +
                        "<td align='center'>" +
                        "<input name='btSalvaFormula' id='btSalvaFormula' type='button' class='botoes' value='Confirmar' alt='Salvar as alterações na fórmula'>" +
                        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<input name='btFechaFormula' id='btFechaFormula' type='button' class='botoes' value='Cancelar' alt='Cancelar as alterações na fórmula'>" +
                        "</td>" +
                        "</tr>" +
                        "</table>";

                document.getElementById("promptFormula").innerHTML = cmdHtml;
                document.getElementById("promptFormula").style.display = "";
                document.getElementById("btSalvaFormula").onclick = function () {
                    objx.value = $('ed_formula').value;
                    document.getElementById("promptFormula").style.display = "none";//
                    isFormulaReadOnly(objx.id);
                }
                document.getElementById("btFechaFormula").onclick = function () {
                    document.getElementById("promptFormula").style.display = "none";
                }
            }

            function setVariavelFormula(variavel) {
                $("ed_formula").value += variavel;
            }

            function getTipoIcms() {
                if ($('incluir_icms').value == 'true') {
                    $('tipo_inclusao_icms').style.display = "";
                } else {
                    $('tipo_inclusao_icms').style.display = "none";
                }
            }

            function calcularAdValorem(valor) {
                var vSplit = valor.value;
                var valorSplit = vSplit.split(".")[0];
                var valorDecimal = vSplit.split(".")[1];

                if (valorSplit < 0 || valorSplit > 9) {
                    alert("O valor do Seguro (AdValorEm) precisa ser entre 0 a 9.99 ");
                    $("percentual_advalorem").value = "0.00";
                } else
                if (valorSplit >= 0 || valorSplit <= 9) {
                    if (valorDecimal.length > 2) {
                        alert("A quantidade das casas decimais não podem ser maior que 2 ");
                        $("percentual_advalorem").value = "0.00";
                    }
                }
            }

            //    var linha = 4;

            function addAereo() {

                var linha = $("qtdItensAereo").value - 1;

                linha++;

                var classe = "CelulaZebra2";
                var clase = "inputtexto";
                var floatReset = "seNaoFloatReset(this,'0.00');";
                var maxLengtDefault = 10;

                var _trItemAereo = Builder.node("tr", {
                    className: classe,
                    id: "trItensAereo_" + linha
                });

                var _tdImg = Builder.node("td", {
                    align: "center",
                    id: "tdImg_" + linha
                });

                var _tdDe = Builder.node("td", {
                    width: "2%",
                    id: "tdDe_" + linha
                });

                var _tdAte = Builder.node("td", {
                    width: "10%",
                    id: "tdAte_" + linha
                });

                var _tdValor = Builder.node("td", {
                    width: "10%",
                    id: "tdValor_" + linha
                });

                var _tdSelect = Builder.node("td", {
                    width: "10%",
                    id: "tdFaixa_" + linha
                });


                var _inpPesoInicial = Builder.node("input", {
                    id: "peso_inicial_faixa_aereo_" + linha,
                    name: "peso_inicial_faixa_aereo_" + linha,
                    type: "text",
                    value: "0.00",
                    size: 4,
                    className: clase,
                    onchange: floatReset,
                    //            readonly: "",
                    maxlenght: maxLengtDefault
                });

                var _inpPesoFinal = Builder.node("input", {
                    id: "peso_final_faixa_aereo_" + linha,
                    name: "peso_final_faixa_aereo_" + linha,
                    type: "text",
                    value: "0.00",
                    size: 4,
                    className: clase,
                    onchange: floatReset,
                    //            readonly: "",
                    maxlenght: maxLengtDefault
                });

                var _inpValorPeso = Builder.node("input", {
                    id: "valor_peso_faixa_aereo_" + linha,
                    name: "valor_peso_faixa_aereo_" + linha,
                    type: "text",
                    value: "0.00",
                    size: 4,
                    className: clase,
                    onchange: floatReset,
                    //            readonly: "",
                    maxlenght: maxLengtDefault
                });

                var _inpIdFaixaAe = Builder.node("input", {
                    id: "id_faixa_aereo_" + linha,
                    name: "id_faixa_aereo_" + linha,
                    type: "hidden",
                    value: "0"
                });

                var _selectTipoValor = Builder.node("select", {
                    id: "tipo_valor_faixa_aereo_" + linha,
                    name: "tipo_valor_faixa_aereo_" + linha,
                    //            disabled : "",
                    align: "left",
                    type: "text",
                    className: clase
                });

                var _Kg = Builder.node("OPTION", {value: 'k'}, "KG");
                var _Fixo = Builder.node("OPTION", {value: 'f'}, "FIXO");

                _selectTipoValor.appendChild(_Fixo);
                _selectTipoValor.appendChild(_Kg);


                _tdDe.appendChild(_inpPesoInicial);
                _tdAte.appendChild(_inpPesoFinal);
                _tdValor.appendChild(_inpValorPeso);
                _tdValor.appendChild(_inpIdFaixaAe);
                _tdSelect.appendChild(_selectTipoValor);

                _trItemAereo.appendChild(_tdImg);
                _trItemAereo.appendChild(_tdDe);
                _trItemAereo.appendChild(_tdAte);
                _trItemAereo.appendChild(_tdValor);
                _trItemAereo.appendChild(_tdSelect);

                $("tbodyAereo").appendChild(_trItemAereo);
                $("qtdItensAereo").value = linha + 1;
            }

            function mostrarCampos(imgElement) {
                if (imgElement != null && imgElement != undefined) {
                    var idx = imgElement.id.split("_")[1];
                    var estado = imgElement.src;
                    if (estado.indexOf("plus.jpg") > -1) {
                        visivel($("tr2Log_" + idx));
                        imgElement.src = "img/minus.jpg";
                    } else if (estado.indexOf("minus.jpg") > -1) {
                        invisivel($("tr2Log_" + idx));
                        imgElement.src = "img/plus.jpg";
                    }
                }
            }

            function addFaixaTFM() {

                var linhaFaixa = $("qtdItensFaixa").value - 1;

                linhaFaixa++;

                var classe = "CelulaZebra2";
                var clase = "inputtexto";
                var floatReset = "seNaoFloatReset(this,'0.00');";
                var maxLengtDefault = 10;

                var _trItemFiaxa = Builder.node("tr", {
                    className: classe,
                    id: "trItensFaixa_" + linhaFaixa
                });

                var _tdImgFaixa = Builder.node("td", {
                    align: "center",
                    id: "tdImgFaixa_" + linhaFaixa
                });

                var _tdDeFaixa = Builder.node("td", {
                    width: "2%",
                    id: "tdDeFaixa_" + linhaFaixa
                });

                var _tdAteFaixa = Builder.node("td", {
                    width: "10%",
                    id: "tdAteFaixa_" + linhaFaixa
                });

                var _tdValorFaixa = Builder.node("td", {
                    width: "10%",
                    id: "tdValorFaixa_" + linhaFaixa
                });

                var _tdSelectFaixa = Builder.node("td", {
                    width: "10%",
                    id: "tdFaixa_" + linhaFaixa
                });


                var _inpPesoInicialFaixa = Builder.node("input", {
                    id: "peso_inicial_faixa_" + linhaFaixa,
                    name: "peso_inicial_faixa_" + linhaFaixa,
                    type: "text",
                    value: "0.00",
                    size: 4,
                    className: clase,
                    onchange: floatReset,
                    maxlenght: maxLengtDefault
                });

                var _inpPesoFinalFaixa = Builder.node("input", {
                    id: "peso_final_faixa_" + linhaFaixa,
                    name: "peso_final_faixa_" + linhaFaixa,
                    type: "text",
                    value: "0.00",
                    size: 4,
                    className: clase,
                    onchange: floatReset,
                    maxlenght: maxLengtDefault
                });

                var _inpValorPesoFaixa = Builder.node("input", {
                    id: "valor_peso_faixa_" + linhaFaixa,
                    name: "valor_peso_faixa_" + linhaFaixa,
                    type: "text",
                    value: "0.00",
                    size: 4,
                    className: clase,
                    onchange: floatReset,
                    maxlenght: maxLengtDefault
                });

                var _inpIdFaixa = Builder.node("input", {
                    id: "id_faixa_" + linhaFaixa,
                    name: "id_faixa_" + linhaFaixa,
                    type: "hidden",
                    value: "0"
                });

                var _selectTipoValorFaixa = Builder.node("select", {
                    id: "tipo_valor_faixa_" + linhaFaixa,
                    name: "tipo_valor_faixa_" + linhaFaixa,
                    align: "left",
                    type: "text",
                    className: clase
                });

                var _Fixo = Builder.node("OPTION", {value: 'f'}, "FIXO");
                var _Kg = Builder.node("OPTION", {value: 'k'}, "KG");
                var _Tom = Builder.node("OPTION", {value: 't'}, "TON");

                _selectTipoValorFaixa.appendChild(_Fixo);
                _selectTipoValorFaixa.appendChild(_Kg);
                _selectTipoValorFaixa.appendChild(_Tom);

                _tdDeFaixa.appendChild(_inpPesoInicialFaixa);
                _tdAteFaixa.appendChild(_inpPesoFinalFaixa);
                _tdValorFaixa.appendChild(_inpValorPesoFaixa);
                _tdValorFaixa.appendChild(_inpIdFaixa);
                _tdSelectFaixa.appendChild(_selectTipoValorFaixa);

                _trItemFiaxa.appendChild(_tdImgFaixa);
                _trItemFiaxa.appendChild(_tdDeFaixa);
                _trItemFiaxa.appendChild(_tdAteFaixa);
                _trItemFiaxa.appendChild(_tdValorFaixa);
                _trItemFiaxa.appendChild(_tdSelectFaixa);

                $("tbodyFaixa").appendChild(_trItemFiaxa);
                $("qtdItensFaixa").value = linhaFaixa + 1;
            }


//            function alterarTipoTaxa() {
//                if ($("tipotaxa").value == '2') {
//                    $("chkConsiderarMaiorValor").disabled = 'false';
//                    $("chkConsiderarMaiorValor").checked = false;
//                    $("chkConsiderarMaiorValor").disabled = 'true';
//                } else {
//                    $("chkConsiderarMaiorValor").disabled = false;
//                    $("chkConsiderarMaiorValor").checked = false;
//                }
//            }

            arAbasGenerico = new Array();
            arAbasGenerico[0] = new stAba('tdTiposFrete', 'divTiposFrete,divGeneralidades');
            <c:if test="${tab.tipoRota eq 'c' and permissaoTabelaRota}">
                arAbasGenerico[1] = new stAba('tdTabelaCarreteiro', 'divTabelaCarreteiro');
            </c:if>
            arAbasGenerico[2] = new stAba('tdAuditoria', 'divAuditoria');

            function pesquisarAuditoria() {
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }
                countLog = 0;
                var rotina = "tabelaPreco";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = "<%=(tab != null ? tab.getId() : 0)%>";
                consultarLog(rotina, id, dataDe, dataAte);
            }

        </script>
        <%@page import="cliente.faixaPeso.FaixaPeso"%>
        <%@page import="cliente.faixaKm.FaixaKm"%>
        <%@ page import="br.com.gwsistemas.eutil.NivelAcessoUsuario" %>

        <title>WebTrans - Cadastro de tabela de preços</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <%--<link href="${homePath}/assets/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">--%>
        <script>
            var homePath = '${homePath}';
        </script>
    </head>
    <body onLoad="javascript:seAlterando();
            marcarTodos(true);
            aoCarregar();
            applyFormatter();
            getTipoIcms();
//            alterarTipoTaxa();
            AlternarAbasGenerico('tdTiposFrete', 'divTiposFrete,divGeneralidades');
          " >
        <form method="post" id="formTab" action="./cadtabela_preco.jsp" target="pop" method="post">
            <img src="img/banner.gif" >
            <br>
            <input type="hidden" name="idremetente" id="idremetente" value="<%=(carregaTab ? tab.getCliente().getIdcliente() : 0)%>">
            <input type="hidden" name="tipo_produto_id" id="tipo_produto_id" value="<%=(carregaTab ? tab.getTipoProduto().getId() : 0)%>">
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="<%=(carregaTab ? tab.getCidadeOrigem().getIdcidade() : 0)%>">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="<%=(carregaTab ? tab.getCidadeDestino().getIdcidade() : 0)%>">
            <input type="hidden" name="area_id" id="area_id" value="0">
            <input type="hidden" name="sigla_area" id="sigla_area" value="0">
            <input type="hidden" name="idareaorigem" id="idareaorigem" value="<%=(carregaTab ? tab.getAreaOrigem().getId() : 0)%>">
            <input type="hidden" name="idareadestino" id="idareadestino" value="<%=(carregaTab ? tab.getAreaDestino().getId() : 0)%>">
            <input type="hidden" name="idHiddenCliente" id="idHiddenCliente" value="<%=request.getParameter("id") != null ? request.getParameter("id") : "0"%>">
            <input type="hidden" name="hiddenDescCliente" id="hiddenDescCliente" value="<%=request.getParameter("descCliente") != null ? request.getParameter("descCliente") : ""%>">
            <input type="hidden" name="is_utilizar_tipo_frete_tabela" id="is_utilizar_tipo_frete_tabela" value="<%=(carregaTab ? tab.getCliente().isUtilizarTipoFreteTabela() : request.getParameter("utilizartipofretetabela") != null ? request.getParameter("utilizartipofretetabela") : 'f')%>">
            <!--<input id="qtdItensAereo" name="qtdItensAereo" type="hidden" value="0" />-->
            <!--        <input id="qtdItensFaixa" name="qtdItensFaixa" type="hidden" value="0" />-->

            <div id="conteudoGeral">
                <div id="cabecalho">
                    <table width="85%" align="center" class="bordaFina" >
                        <tr >
                            <td width="462" height="22">
                                <div align="left">
                                    <b>Cadastro de Tabela de preços</b>
                                </div>
                            </td>
                            <% if ((acao.equals("iniciar")) && (nivelUser >= 3)) {%>
                            <td width="93">
                                <input  name="Button" type="button" class="botoes" value="Incluir tabela para v&aacute;rias cidades / Copiar tabela de outro cliente" alt="Incluir tabela para v&aacute;rias cidades / Copiar tabela de outro cliente" onClick="javascript:tryRequestToServer(function () {
                                            location.replace('./cadtabela_preco_dinamica.jsp?acao=iniciar')
                                        });">
                            </td>
                            <%}%>
                            <td width="101">
                                <% if ((acao.equals("editar")) && (nivelUser == 4) && (Boolean.parseBoolean(request.getParameter("ex")))) //se o paramentro vier com valor diferente de nulo ai pode excluir
                                    {%>
                                <input  name="excluir" type="button" class="botoes" value="Excluir" alt="Exclui o cliente atual" onClick="javascript:excluircliente();">
                            </td>
                            <%}%>
                            <td width="7">&nbsp;</td>
                            <td width="78">
                                <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Voltar para Consulta" onClick="javascript:voltar();">
                            </td>
                        </tr>
                    </table>
                    <br>
                </div>
                <div id="divDadosPrincipais">
                    <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tr class="tabela">
                            <td height="20" colspan="6" align="center"><a name="topo">Dados principais</a></td>
                        </tr>
                        <tr>
                            <!--<td width="109" class="TextoCampos">C&oacute;digo:</td>-->
                            <td width="8%" class="TextoCampos">C&oacute;digo:</td>
<!--                            <td colspan="4" class="CelulaZebra2">
                                <b>< %=(carregaTab ? tab.getId() : 0)%>
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;<input name="chkDesativada" type="checkbox" id="chkDesativada" value="checkbox" < %=carregaTab && tab.isDesativada() ? "checked" : ""%>>
                                    Tabela desativada
                                </b>
                            </td>                -->
                            <td width="32%" colspan="2" class="CelulaZebra2">
                                <b>
                                    <%=(carregaTab ? tab.getId() : 0)%>
                                </b>
                            </td>
                            <td width="30%" class="CelulaZebra2">
                                <b>
                                    <label>
                                        <input name="chkDesativada" type="checkbox" id="chkDesativada" value="checkbox" <%=carregaTab && tab.isDesativada() ? "checked" : ""%>>
                                        Tabela desativada
                                    </label>
                                </b>
                            </td>
                            <td width="30%" class="CelulaZebra2">
                                <div id="divFreteIdaVolta" style="display:'<%= !carregaTab? "" : "none" %>' ">
                                    <b>
                                        <label>
                                            <input name="chkFreteIdaVolta" type="checkbox" id="chkFreteIdaVolta" value="checkbox" <%=carregaTab && tab.isDesativada() ? "checked" : ""%>>
                                            Frete Ida e Volta
                                        </label>
                                    </b>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Cliente:</td>
                            <td colspan="4" class="CelulaZebra2">
                                <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly8pt" value="<%=(carregaTab ? tab.getCliente().getRazaosocial() : "Tabela Principal")%>"  size="70" readonly>
                                <%if (!carregaTab) { %>
                                <span class="Celulazebra2">
                                    <strong>
                                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=3', 'Remetente')">
                                        <img src="img/borracha.gif" border="0" id="borrLocRem" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('rem_rzs').value = 'Tabela Principal';
                                                javascript:getObj('idremetente').value = '0';">
                                    </strong>
                                </span>
                                <%}%>

                                <label id="tdTipoFrete1" name="tdTipoFrete1" style="display: none" width="10%" class="TextoCampos">
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    Tipo de Frete específico para essa tabela:
                                    <select name="tipotaxa" id="tipotaxa" class="fieldMin" onchange="javascript:alterarTipoTaxa();">
                                        <option value="-1">--Selecione--</option>
                                        <option value="0" <%=(carregaTab ? (tab.getTipoTaxa() == 0 ? "selected" : "") : "")%>>Peso/Kg</option>
                                        <option value="1" <%=(carregaTab ? (tab.getTipoTaxa() == 1 ? "selected" : "") : "")%>>Peso/Cubagem</option>
                                        <option value="2" <%=(carregaTab ? (tab.getTipoTaxa() == 2 ? "selected" : "") : "")%>>% Nota Fiscal</option>
                                        <option value="3" <%=(carregaTab ? (tab.getTipoTaxa() == 3 ? "selected" : "") : "")%>>Combinado</option>
                                        <option value="4" <%=(carregaTab ? (tab.getTipoTaxa() == 4 ? "selected" : "") : "")%>>Por Volume</option>
                                        <option value="5" <%=(carregaTab ? (tab.getTipoTaxa() == 5 ? "selected" : "") : "")%>>Por Km</option>
                                        <option value="6" <%=(carregaTab ? (tab.getTipoTaxa() == 6 ? "selected" : "") : "")%>>Por Pallet</option>
                                    </select>
                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Tipo de produto: </td>
                            <td colspan="5" class="CelulaZebra2">
                                <strong>
                                    <input name="tipo_produto" type="text" id="tipo_produto" classname="fieldMin" class="inputReadOnly8pt"
                                           value="<%=(carregaTab ? tab.getTipoProduto().getDescricao() : "")%>" size="55" maxlength="9" align="right" readonly="true">
                                    <input  name="localiza_cliente" type="button" class="botoes" id="localiza_produto" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=37', 'Tipo_Produto')" value="...">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar tipo de produto" onClick="javascript:$('tipo_produto').value = '';
                                            javascript:$('tipo_produto_id').value = '0';">
                                </strong>
                            </td>
                        </tr>
                        <tr>
                            <td height="67" class="TextoCampos">Tipo de Rota: </td>
                            <td colspan="5" class="TextoCampos">
                                <table width="100%" height="100%" border="1" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td colspan="2" class="TextoCampos">
                                            <div align="center">
                                                <input name="rotaCidade" id="rotaCidade" type="radio" value="radiobutton" checked onClick="javascript:tipoFrota('c');" <%=(carregaTab ? "disabled" : "")%> >
                                                Por Cidade
                                            </div>
                                        </td>
                                        <td colspan="2" class="TextoCampos">
                                            <div align="center">
                                                <input name="rotaArea" id="rotaArea" type="radio" value="radiobutton" onClick="javascript:tipoFrota('a');" <%=(carregaTab ? "disabled" : "")%>>
                                                Por &Aacute;rea
                                            </div>
                                        </td>
                                        <td class="TextoCampos">
                                            <div align="center">
                                                <input name="rotaKm" id="rotaKm" type="radio" value="radiobutton" onClick="javascript:tipoFrota('k');" <%=(carregaTab ? "disabled" : "")%>>
                                                Km
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="9%" class="TextoCampos">Origem:</td>
                                        <td width="47%" class="CelulaZebra2">
                                            <span class="CelulaZebra2">
                                                <strong>
                                                    <input name="cid_origem" type="text" id="cid_origem" classname="fieldMin" class="inputReadOnly8pt"
                                                           value="<%=(carregaTab ? tab.getCidadeOrigem().getCidade() : "")%>" size="40" maxlength="9" align="right" readonly="true">
                                                    <strong>
                                                        <input name="uf_origem" type="text" id="uf_origem" classname="fieldMin" class="inputReadOnly8pt"
                                                               value="<%=(carregaTab ? tab.getCidadeOrigem().getUf() : "")%>" size="2" maxlength="2" align="right" readonly="true">
                                                        <strong>
                                                            <input  name="localiza_cidade_origem" type="button" class="botoes" id="localiza_cidade_origem" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade_Origem')" value="..." style="display:<%=(carregaTab && (nivelUserTabela < 4 || tab.getCidadeOrigem().getIdcidade() == 0) ? "none" : "")%>;">
                                                        </strong> 
                                                    </strong> 
                                                </strong>
                                            </span>
                                        </td>
                                        <td width="10%" class="TextoCampos">Origem:</td>
                                        <td width="23%" class="CelulaZebra2">
                                            <span class="CelulaZebra2">
                                                <strong>
                                                    <input name="area_ori" type="text" id="area_ori" class="inputReadOnly8pt" size="10" maxlength="80" readonly="true" value="<%=(carregaTab ? tab.getAreaOrigem().getSigla() : "")%>">
                                                    <input name="localiza_area_origem" type="button" class="botoes" disabled id="localiza_area_origem"  value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34', 'Area_Origem')" style="display:<%=(carregaTab && (nivelUserTabela < 4 || tab.getAreaOrigem().getId() == 0) ? "none" : "")%>;">
                                                </strong>
                                            </span>
                                        </td>
                                        <td width="11%">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Destino:</td>
                                        <td class="CelulaZebra2"><span class="CelulaZebra2"><strong>
                                                    <input name="cid_destino" type="text" id="cid_destino" classname="fieldMin" class="inputReadOnly8pt"
                                                           value="<%=(carregaTab ? tab.getCidadeDestino().getCidade() : "")%>" size="40" maxlength="9" align="right" readonly="true">
                                                    <strong>
                                                        <input name="uf_destino" type="text" id="uf_destino" classname="fieldMin" class="inputReadOnly8pt"
                                                               value="<%=(carregaTab ? tab.getCidadeDestino().getUf() : "")%>" size="2" maxlength="2" align="right" readonly="true">
                                                        <strong>
                                                            <strong>
                                                                <strong>
                                                                    <strong>
                                                                        <input  name="localiza_cidade_destino" type="button" class="botoes" id="localiza_cidade_destino" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=12', 'Cidade_Destino')" value="..." style="display:<%=(carregaTab && (nivelUserTabela < 4 || tab.getCidadeDestino().getIdcidade() == 0) ? "none" : "")%>;">
                                                                    </strong>
                                                                </strong>
                                                            </strong>
                                                        </strong>
                                                    </strong>
                                                </strong>
                                            </span>
                                        </td>
                                        <td class="TextoCampos">Destino:</td>
                                        <td class="CelulaZebra2">
                                            <span class="CelulaZebra2">
                                                <strong>
                                                    <input name="area_des" type="text" id="area_des" size="10" maxlength="80" readonly="true" value="<%=(carregaTab ? tab.getAreaDestino().getSigla() : "")%>" class="inputReadOnly8pt">
                                                    <input name="localiza_area_destino" type="button" class="botoes"  disabled id="localiza_area_destino" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34', 'Area_Destino')" style="display:<%=(carregaTab && (nivelUserTabela < 4 || tab.getAreaDestino().getId() == 0) ? "none" : "")%>;">
                                                </strong>
                                            </span>
                                        </td>
                                        <td>&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divAbas" <%=nivelUserTabela != 4 || !carregaTab ? "style='display: none'" : ""%>>
                    <table align="center" width="88%" class="bordaFina" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                        <td id="tdTiposFrete" class="menu-sel" onclick="AlternarAbasGenerico('tdTiposFrete', 'divTiposFrete,divGeneralidades');">Informações da Tabela</td>
                                        <c:if test="${tab.tipoRota eq 'c' and permissaoTabelaRota}">
                                            <td id="tdTabelaCarreteiro"  class="menu" onclick="AlternarAbasGenerico('tdTabelaCarreteiro', 'divTabelaCarreteiro');">Tabela Carreteiro</td>
                                        </c:if>
                                        <td id="tdAuditoria"  class="menu" onclick="AlternarAbasGenerico('tdAuditoria', 'divAuditoria');">Auditoria</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divTiposFrete">
                    <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tr>
                            <td colspan="6" class="tabela"><div align="center">Tipos de frete</div></td>
                        </tr>

                        <tr id="trPeso" name="trPeso">
                            <td class="TextoCampos"><strong>Peso/Kg</strong></td>
                            <td colspan="5" class="CelulaZebra2">
                                <table width="100%" height="100%" border="1" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td colspan="2" class="TextoCampos">
                                            <div align="center">
                                                <input name="tipoPeso" type="radio" id="tipoPeso" value="radiobutton" checked onClick="tipoPesoTelaTabela('p')">
                                                R$ / Peso
                                            </div>
                                        </td>
                                        <td colspan="4" class="TextoCampos">
                                            <div align="center">
                                                <input name="tipoFaixa" id="tipoFaixa" type="radio" value="radiobutton" onClick="tipoPesoTelaTabela('f')">
                                                R$ / Faixa de Peso
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="10%" rowspan="2" class="TextoCampos">Valor:</td>
                                        <td width="12%" rowspan="2" class="CelulaZebra2">
                                            <input name="valor_peso" type="text" id="valor_peso" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr_tres_casas(tab.getValorPeso()) : "0.00")%>" class="inputtexto">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_frete_peso'));">
                                                </a>
                                            </strong>
                                        </td>
                                        <td width="39%" colspan="2" class="CelulaZebra2">
                                            <div align="center">
                                                <b>Terrestre, fluvial, Mar&iacute;timo</b>
                                            </div>
                                        </td>
                                        <td width="39%" colspan="2" class="CelulaZebra2">
                                            <div align="center">
                                                <b>A&eacute;reo</b>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" class="CelulaZebra2" style="vertical-align:top;">
                                            <table width="100%" border="1" cellpadding="0" cellspacing="0">
                                                <tr class="celula">
                                                    <td class="Celulazebra2" id="idDesabTd">
                                                        <img src="img/add.gif" width="14px" id="imgFaixa" alt="Adcionar mais Campos" onclick="addFaixaTFM();">
                                                    </td>
                                                    <td width="25%">De (Kg) </td>
                                                    <td width="25%">At&eacute; (Kg) </td>
                                                    <td width="25%">Valor R$ </td>
                                                    <td width="25%">&nbsp;</td>
                                                </tr>
                                                <%int linha = 0;
                                                    if (!carregaTab) {
                                                        ResultSet rs = fx.all(Apoio.getUsuario(request).getConexao());
                                                        while (rs.next()) {%>
                                                <tbody>
                                                    <tr>
                                                        <td class="Celulazebra2">
                                                        </td>
                                                        <td class="CelulaZebra2">
                                                            <input name="peso_inicial_faixa_<%=linha%>" type="text" id="peso_inicial_faixa_<%=linha%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                                   size="4" maxlength="10" value="<%=rs.getFloat("peso_inicial")%>" class="inputtexto">
                                                        </td>
                                                        <td class="CelulaZebra2">
                                                            <input name="peso_final_faixa_<%=linha%>" type="text" id="peso_final_faixa_<%=linha%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                                   size="4" maxlength="10" value="<%=rs.getFloat("peso_final")%>" class="inputtexto">
                                                        </td>
                                                        <td class="CelulaZebra2">
                                                            <input name="id_faixa_<%=linha%>" type="hidden" id="id_faixa_<%=linha%>" value="<%=rs.getString("id")%>">
                                                            <input name="valor_peso_faixa_<%=linha%>" type="text" id="valor_peso_faixa_<%=linha%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                                   size="4" maxlength="10" value="0.00" class="inputtexto">
                                                        </td>
                                                        <td class="CelulaZebra2">
                                                            <select name="tipo_valor_faixa_<%=linha%>" id="tipo_valor_faixa_<%=linha%>" style="font-size:8pt;">
                                                                <option value="f" selected>FIXO</option>
                                                                <option value="k">KG</option>
                                                                <option value="t">TON</option>
                                                            </select>
                                                        </td>
                                                    </tr>
                                                </tbody>

                                                <% linha++;
                                                    }%>
                                                <tbody id="tbodyFaixa"></tbody>
                                                <input id="qtdItensFaixa" name="qtdItensFaixa" type="hidden" value="<%=linha%>" />
                                                <%} else {
                                                    for (int u = 0; u < tab.getFaixasPeso().length; ++u) {
                                                        FaixaPeso fxp = tab.getFaixasPeso()[u];
                                                %>
                                                <tr>
                                                    <td class="Celulazebra2">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="peso_inicial_faixa_<%=linha%>" type="text" id="peso_inicial_faixa_<%=linha%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=fxp.getPesoInicial()%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="peso_final_faixa_<%=linha%>" type="text" id="peso_final_faixa_<%=linha%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=fxp.getPesoFinal()%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="id_faixa_<%=linha%>" type="hidden" id="id_faixa_<%=linha%>" value="<%=fxp.getId()%>">
                                                        <input name="valor_peso_faixa_<%=linha%>" type="text" id="valor_peso_faixa_<%=linha%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=Apoio.to_curr(fxp.getValorFaixa())%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <select name="tipo_valor_faixa_<%=linha%>" id="tipo_valor_faixa_<%=linha%>" style="font-size:8pt;" class="inputtexto">
                                                            <option value="f" <%=(fxp.getTipoValor() != null && fxp.getTipoValor().equals("f") ? "selected" : "")%>>FIXO</option>
                                                            <option value="k" <%=(fxp.getTipoValor() != null && fxp.getTipoValor().equals("k") ? "selected" : "")%>>KG</option>
                                                            <option value="t" <%=(fxp.getTipoValor() != null && fxp.getTipoValor().equals("t") ? "selected" : "")%>>TON</option>
                                                        </select>
                                                    </td>
                                                </tr>
                                                <%  linha++;
                                                    }%>
                                                <tbody id="tbodyFaixa"></tbody>
                                                <input id="qtdItensFaixa" name="qtdItensFaixa" type="hidden" value="<%=linha%>" />
                                                <%}%>
                                            </table>
                                        </td>
                                        <td colspan="2" class="CelulaZebra2" style="vertical-align:top;">
                                            <table width="100%" border="1" cellpadding="0" cellspacing="0">
                                                <tr class="celula">
                                                    <td class="Celulazebra2" id="idDesabTd">
                                                        <img src="img/add.gif" width="14px" id="imgDesab" alt="Adcionar mais Campos" onclick="addAereo();">
                                                    </td>
                                                    <td width="25%">De (Kg) </td>
                                                    <td width="25%">At&eacute; (Kg) </td>
                                                    <td width="25%">Valor R$ </td>
                                                    <td width="25%">&nbsp;</td>
                                                </tr>
                                                <%int linhaAe = 0;
                                                    if (!carregaTab) {
                                                        BeanCadTabelaCliente allA = new BeanCadTabelaCliente();
                                                        allA.allAereo();
                                                        for (int u = 0; u < allA.getTabela().getFaixasPesoAereo().length; ++u) {
                                                            FaixaPeso fxp = allA.getTabela().getFaixasPesoAereo()[u];%>
                                                <tr>
                                                    <td class="Celulazebra2">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="peso_inicial_faixa_aereo_<%=linhaAe%>" type="text" id="peso_inicial_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=fxp.getPesoInicial()%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="peso_final_faixa_aereo_<%=linhaAe%>" type="text" id="peso_final_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=fxp.getPesoFinal()%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="id_faixa_aereo_<%=linhaAe%>" type="hidden" id="id_faixa_aereo_<%=linhaAe%>" value="<%=fxp.getId()%>">
                                                        <input name="valor_peso_faixa_aereo_<%=linhaAe%>" type="text" id="valor_peso_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="0.00" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <select name="tipo_valor_faixa_aereo_<%=linhaAe%>" id="tipo_valor_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" class="inputtexto">
                                                            <option value="f" selected>FIXO</option>
                                                            <option value="k">KG</option>
                                                        </select>
                                                    </td>
                                                </tr>
                                                <%linhaAe++;%>
                                                <%}%>
                                                <tbody id="tbodyAereo"></tbody>
                                                <input id="qtdItensAereo" name="qtdItensAereo" type="hidden" value="<%=linhaAe%>"/>

                                                <%} else {
                                                    for (int u = 0; u < tab.getFaixasPesoAereo().length; ++u) {
                                                        FaixaPeso fxp = tab.getFaixasPesoAereo()[u];%>
                                                <tr>
                                                    <td class="Celulazebra2">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="peso_inicial_faixa_aereo_<%=linhaAe%>" type="text" id="peso_inicial_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=Apoio.to_curr(fxp.getPesoInicial())%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="peso_final_faixa_aereo_<%=linhaAe%>" type="text" id="peso_final_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=Apoio.to_curr(fxp.getPesoFinal())%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <input name="id_faixa_aereo_<%=linhaAe%>" type="hidden" id="id_faixa_aereo_<%=linhaAe%>" value="<%=fxp.getId()%>">
                                                        <input name="valor_peso_faixa_aereo_<%=linhaAe%>" type="text" id="valor_peso_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                               size="4" maxlength="10" value="<%=Apoio.to_curr(fxp.getValorFaixa())%>" class="inputtexto">
                                                    </td>
                                                    <td class="CelulaZebra2">
                                                        <select name="tipo_valor_faixa_aereo_<%=linhaAe%>" id="tipo_valor_faixa_aereo_<%=linhaAe%>" style="font-size:8pt;" class="inputtexto">
                                                            <option value="f" <%=(fxp.getTipoValor() != null && fxp.getTipoValor().equals("f") ? "selected" : "")%>>FIXO</option>
                                                            <option value="k" <%=(fxp.getTipoValor() != null && fxp.getTipoValor().equals("k") ? "selected" : "")%>>KG</option>
                                                        </select>
                                                    </td>
                                                </tr>

                                                <%  linhaAe++;%>
                                                <%}%>
                                                <tbody id="tbodyAereo"></tbody>
                                                <input id="qtdItensAereo" name="qtdItensAereo" type="hidden" value="<%=linhaAe%>"/>
                                                <%}%>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" class="TextoCampos">
                                            <div align="center">
                                                <input name="precoTonelada" type="checkbox" id="precoTonelada" value="checkbox" <%=(carregaTab && tab.isPrecoTonelada() ? "checked" : "")%>>
                                                Pre&ccedil;o por tonelada
                                            </div>
                                        </td>
                                        <td class="TextoCampos">Excedente:</td>
                                        <td class="CelulaZebra2">
                                            <input name="valor_excedente" type="text" id="valor_excedente" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? tab.getValorExcedente() : "0.00")%>" class="inputtexto">
                                        </td>
                                        <td class="TextoCampos">Excedente:</td>
                                        <td class="CelulaZebra2">
                                            <input name="valor_excedente_aereo" type="text" id="valor_excedente_aereo" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorExcedenteAereo()) : "0.00")%>" class="inputtexto">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="trCubagem" name="trCubagem">
                            <td rowspan="3" class="TextoCampos">
                                <strong>Peso/Cubagem</strong>
                            </td>
                            <td width="85" class="TextoCampos">Base Rodov.:</td>
                            <td width="647" colspan="4" class="CelulaZebra2">
                                <input name="base_cubagem" type="text" id="base_cubagem" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="5" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getBaseCubagem()) : "0.00")%>" class="inputtexto">
                                Exemplo: Volumes * Comprimento(m) * Largura(m) * Altura(m) * base = Peso Cubado
                            </td>
                        </tr>
                        <tr id="trCubagem2" name="trCubagem2">
                            <td class="TextoCampos">Base A&eacute;reo:</td>
                            <td colspan="4" class="CelulaZebra2">
                                <input name="base_cubagem_aereo" type="text" id="base_cubagem_aereo" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="5" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getBaseCubagemAereo()) : "6000.00")%>" class="inputtexto">
                                Exemplo: Volumes * Comprimento(cm) * Largura(cm) * Altura(cm) / base = Peso Cubado
                            </td>
                        </tr>
                        <tr id="trCubagem3" name="trCubagem3">
                            <td colspan="5" class="TextoCampos">
                                <div align="left">
                                    <input name="chkConsiderarPeso" type="checkbox" id="chkConsiderarPeso" value="checkbox" <%=carregaTab && tab.isConsiderarMaiorPeso() ? "checked" : ""%>>
                                    Considerar Peso/Cubagem caso o peso da mercadoria seja inferior ao peso cubado.
                                </div>
                            </td>
                        </tr>
                        <tr id="trVolumes" name="trVolumes">
                            <td class="TextoCampos"><strong>QTD Volumes</strong></td>
                            <td class="TextoCampos">Valor:</td>
                            <td colspan="4" class="CelulaZebra2">
                                <input name="valor_volume" type="text" id="valor_volume" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="4" maxlength="10" value="<%=(carregaTab ? tab.getValorVolume() : "0.00")%>" class="inputtexto">
                                <strong>
                                    <a href="#topo">
                                        <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_volumes'));">
                                    </a>
                                </strong>
                            </td>
                        </tr>
                        <tr id="trNotaFiscal" name="trNotaFiscal">
                            <td rowspan="3" class="TextoCampos">
                                <strong>% Nota Fiscal ou % CT-e (P/ Redespacho):</strong>
                            </td>
                            <td class="TextoCampos">%:</td>
                            <td colspan="4" class="CelulaZebra2">
                                <input name="percentual_nf" type="text" id="percentual_nf" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getPercentualNf()) : "0.00")%>" class="inputtexto">
                                Caso o valor das notas n&atilde;o ultrapassem
                                <input name="baseNfPercentual" type="text" id="baseNfPercentual" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="5" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getBaseNfPercentual()) : "0.00")%>" class="inputtexto">
                                cobrar
                                <input name="valorPercentualNf" type="text" id="valorPercentualNf" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorPercentualNf()) : "0.00")%>" class="inputtexto">
                                e n&atilde;o aplicar o %.
                                <strong>
                                    <a href="#topo">
                                        <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_percentual'));">
                                    </a>
                                </strong>
                            </td>
                        </tr>
                        <tr name="trNotaFiscal2" id="trNotaFiscal2">
                            <td colspan="4" class="CelulaZebra2">Ao lan&ccedil;ar um CT-e o percentual ser&aacute; calculado no campo
                                <select name="tipoImpressaoPercentual" id="tipoImpressaoPercentual" style="font-size:8pt;" class="inputtexto">
                                    <option value="v" selected>Frete Valor</option>
                                    <option value="p">Frete Peso</option>
                                </select>
                            </td>
                        </tr>
                        <tr id="trChkConsiderarMaiorValor">
                            <td colspan="5" class="TextoCampos" style="">
                                <div align="left">
                                    <input name="chkConsiderarMaiorValor" type="checkbox" id="chkConsiderarMaiorValor" value="checkbox" <%=carregaTab && tab.isConsiderarValorMaiorPesoNota() ? "checked" : ""%>>
                                    Considerar o valor de frete maior entre Peso/kg e % Nota Fiscal.
                                </div>
                            </td>
                        </tr>
                        <tr name="trPallet" id="trPallet">
                            <td class="TextoCampos">
                                <b>QTD Pallets</b>
                            </td>
                            <td class="TextoCampos">Valor:</td>
                            <td colspan="4" class="CelulaZebra2">
                                <input name="valor_pallet" type="text" id="valor_pallet" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                       size="4" maxlength="10" value="<%=(carregaTab ? tab.getValorPallet() : "0.00")%>" class="inputtexto">
                                <strong>
                                    <a href="#topo">
                                        <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_pallet'));">
                                    </a>
                                </strong>
                            </td>
                        </tr>
                        <tr id="trCombinado" name="trCombinado">
                            <td class="TextoCampos">
                                <strong>Valor combinado</strong>
                            </td>
                            <td colspan="5" class="CelulaZebra2">
                                <table width="600" height="100%" border="1" cellpadding="0" cellspacing="0">
                                    <tr class="celula">
                                        <td width="25%">
                                            <div align="left">Tipo ve&iacute;culo </div>
                                        </td>
                                        <td width="15%">
                                            <div align="left">Valor</div>
                                        </td>
                                        <td width="15%">
                                            <div align="left">Tipo</div>
                                        </td>
                                        <td width="45%">
                                            <div align="left">Pedágio</div>
                                        </td>
                                    </tr>
                                    <%int linhaV = 0;
                                        if (!carregaTab) {
                                            rsTpVei = tpVei.all(Apoio.getUsuario(request).getConexao());
                                            while (rsTpVei.next()) {%>
                                    <tr>
                                        <td class="CelulaZebra2">
                                            <%=rsTpVei.getString("descricao")%>
                                        </td>
                                        <td class="CelulaZebra2">
                                            <input name="valor_tipo_veiculo_<%=linhaV%>" type="text" id="valor_tipo_veiculo_<%=linhaV%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="9" maxlength="10" value="0.00" class="inputtexto">
                                            <input name="tipo_veiculo_id_<%=linhaV%>" type="hidden" id="tipo_veiculo_id_<%=linhaV%>" value="<%=rsTpVei.getString("id")%>">
                                            <input name="id_veiculo_<%=linhaV%>" type="hidden" id="id_veiculo_<%=linhaV%>" value="<%=rsTpVei.getString("id")%>">
                                        </td>
                                        <td class="CelulaZebra2">
                                            <select name="tipo_taxa_combinado_<%=linhaV%>" id="tipo_taxa_combinado_<%=linhaV%>" style="font-size:8pt;" class="inputtexto">
                                                <option value="1" selected>Valor Fixo</option>
                                                <option value="2">Por Kg</option>
                                                <option value="3">Por Ton.</option>
                                            </select>
                                        </td>
                                        <td class="CelulaZebra2">
                                            <input name="valor_pedagio_<%=linhaV%>" type="text" id="valor_pedagio_<%=linhaV%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="9" maxlength="10" value="0.00" class="inputtexto">
                                            a cada
                                            <input name="limite_pedagio_<%=linhaV%>" type="text" id="limite_pedagio_<%=linhaV%>" style="font-size:8pt;" onChange="seNaoIntReset(this, '0');"
                                                   size="5" maxlength="10" value="0" class="inputtexto">
                                            kg ou fração.
                                        </td>
                                    </tr>
                                    <%linhaV++;
                                        }
                                        rsTpVei.close();
                                    } else {
                                        for (int u = 0; u < tab.getTipoVeiculo().length; ++u) {
                                            Tipo_veiculos tpv = tab.getTipoVeiculo()[u];%>
                                    <tr>
                                        <td class="CelulaZebra2"><%=tpv.getDescricao()%></td>
                                        <td class="CelulaZebra2">
                                            <input name="valor_tipo_veiculo_<%=linhaV%>" type="text" id="valor_tipo_veiculo_<%=linhaV%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="9" maxlength="10" value="<%=Apoio.to_curr(tpv.getValorCombinado())%>" class="inputtexto">
                                            <input name="id_veiculo_<%=linhaV%>" type="hidden" id="tipo_veiculo_id_<%=linhaV%>" value="<%=tpv.getId()%>">
                                            <input name="id_veiculo_<%=linhaV%>" type="hidden" id="id_veiculo_<%=linhaV%>" value="<%=tpv.getTipoVeiculoId()%>">
                                        </td>
                                        <td class="CelulaZebra2">
                                            <select name="tipo_taxa_combinado_<%=linhaV%>" id="tipo_taxa_combinado_<%=linhaV%>" style="font-size:8pt;" class="inputtexto">
                                                <option value="1" <%=(tpv.getTipoTaxa() == 1 ? "selected" : "")%>>Valor Fixo</option>
                                                <option value="2" <%=(tpv.getTipoTaxa() == 2 ? "selected" : "")%>>Por Kg</option>
                                                <option value="3" <%=(tpv.getTipoTaxa() == 3 ? "selected" : "")%>>Por Ton.</option>
                                            </select>
                                        </td>
                                        <td class="CelulaZebra2">
                                            <input name="valor_pedagio_<%=linhaV%>" type="text" id="valor_pedagio_<%=linhaV%>" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="9" maxlength="10" value="<%=Apoio.to_curr(tpv.getValorPedagio())%>" class="inputtexto">
                                            a cada
                                            <input name="limite_pedagio_<%=linhaV%>" type="text" id="limite_pedagio_<%=linhaV%>" style="font-size:8pt;" onChange="seNaoIntReset(this, '0');"
                                                   size="5" maxlength="10" value="<%=tpv.getLimitePedagio()%>" class="inputtexto">
                                            kg ou fração.
                                        </td>
                                    </tr>
                                    <%  linhaV++;
                                            }
                                        }%>
                                        <tr><td> <input type="hidden" id="maxVeic" name="maxVeic" value="<%=linhaV%>"</td></tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="faixaKm" name="faixaKm" style="display:none">
                            <td class="TextoCampos"><strong>Faixas de Km</strong></td>
                            <td colspan="5" class="CelulaZebra2">

                                <table width="100%"  border="1" cellpadding="0" cellspacing="0">
                                    <tbody id="tKm">
                                        <tr>
                                            <td width="5%">
                                                <div align="center">
                                                    <img src="img/add.gif" border="0"
                                                         title="Adicionar uma nova faixa de KM" class="imagemLink" onClick="javascript:addKm(0, 0, 100, '<%=tiposVeiculos%>', true);">
                                                </div>
                                            </td>
                                            <td width="10%" class="CelulaZebra2">De</td>
                                            <td width="10%" class="CelulaZebra2">At&eacute;</td>
                                            <%rsTpVei = tpVei.all(Apoio.getUsuario(request).getConexao());
                                                while (rsTpVei.next()) {%>
                                            <td width="10%" class="CelulaZebra2">
                                                <%=rsTpVei.getString("descricao")%>
                                            </td>
                                            <%      linhaV++;
                                                }
                                                rsTpVei.close();%>
                                        </tr>
                                    </tbody>
                                </table>
                                <input name="formula_outros" type="hidden" id="formula_outros" value="<%=(carregaTab ? tab.getFormulaOutros() : "")%>">
                                <input name="formula_pallet" type="hidden" id="formula_pallet" value="<%=(carregaTab ? tab.getFormulaPallet() : "")%>">
                                <input name="formula_volumes" type="hidden" id="formula_volumes" value="<%=(carregaTab ? tab.getFormulaVolumes() : "")%>">
                                <input name="formula_percentual" type="hidden" id="formula_percentual" value="<%=(carregaTab ? tab.getFormulaPercentual() : "")%>">
                                <input name="formula_seguro" type="hidden" id="formula_seguro" value="<%=(carregaTab ? tab.getFormulaSeguro() : "")%>">
                                <input name="formula_gris" type="hidden" id="formula_gris" value="<%=(carregaTab ? tab.getFormulaGris() : "")%>">
                                <input name="formula_despacho" type="hidden" id="formula_despacho" value="<%=(carregaTab ? tab.getFormulaDespacho() : "")%>">
                                <input name="formula_taxa_fixa" type="hidden" id="formula_taxa_fixa" value="<%=(carregaTab ? tab.getFormulaTaxaFixa() : "")%>">
                                <input name="formula_sec_cat" type="hidden" id="formula_sec_cat" value="<%=(carregaTab ? tab.getFormulaSecCat() : "")%>">
                                <input name="formula_minimo" type="hidden" id="formula_minimo" value="<%=(carregaTab ? tab.getFormulaMinimo() : "")%>">
                                <input name="formula_icms" type="hidden" id="formula_icms" value="<%=(carregaTab ? tab.getFormulaIcms() : "")%>">
                                <input name="formula_frete_peso" type="hidden" id="formula_frete_peso" value="<%=(carregaTab ? tab.getFormulaFretePeso() : "")%>">
                                <input name="formula_pedagio" type="hidden" id="formula_pedagio" value="<%=(carregaTab ? tab.getFormulaPedagio() : "")%>">
                                <input name="formula_tde" type="hidden" id="formula_tde" value="<%=(carregaTab ? tab.getFormulaTDE() : "")%>">
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divGeneralidades">
                    <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tr>
                            <td colspan="6" class="tabela">
                                <div align="center">Generalidades</div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="6">
                                <table width="100%"  border="0" cellspacing="1" cellpadding="2">
                                    <tr>
                                        <td width="13%" class="TextoCampos">GRIS:</td>
                                        <td colspan="2" class="CelulaZebra2">
                                            <input name="percentual_gris" type="text" id="percentual_gris" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="4" value="<%=(carregaTab ? Apoio.to_curr(tab.getPercentualGris()) : "0.00")%>" class="inputtexto">
                                            M&iacute;nimo:
                                            <input name="valorMinimoGris" type="text" id="valorMinimoGris" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="4" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorMinimoGris()) : "0.00")%>" class="inputtexto">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_gris'));">
                                                </a>
                                            </strong>
                                        </td>
                                        <td width="15%" class="TextoCampos">Seguro (AdValorEm):</td>
                                        <td width="9%" class="CelulaZebra2">
                                            <input name="percentual_advalorem" type="text" id="percentual_advalorem" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');
                                                    calcularAdValorem(this);"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getPercentualAdValorEm()) : "0.00")%>" class="inputtexto">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_seguro'));">
                                                </a>
                                            </strong>
                                        </td>
                                        <td width="8%" class="TextoCampos">Despacho:</td>
                                        <td width="10%" class="CelulaZebra2">
                                            <input name="valor_despacho" type="text" id="valor_despacho" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorDespacho()) : "0.00")%>" class="inputtexto">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_despacho'));">
                                                </a>
                                            </strong>
                                        </td>
                                        <td width="7%" class="TextoCampos">Outros:</td>
                                        <td width="11%" class="CelulaZebra2">
                                            <input name="valor_outros" type="text" id="valor_outros" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorOutros()) : "0.00")%>" class="inputtexto">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar fórmula" onClick="javascript:exibirFormula($('formula_outros'));">
                                                </a>
                                            </strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Ped&aacute;gio:</td>
                                        <td colspan="2" class="CelulaZebra2">
                                            <input name="valor_pedagio" type="text" id="valor_pedagio" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorPedagio()) : "0.00")%>" class="inputtexto">
                                            a cada
                                            <input name="qtd_quilo_pedagio" type="text" id="qtd_quilo_pedagio" style="font-size:8pt;" onChange="seNaoIntReset(this, '0');"
                                                   size="2" maxlength="10" value="<%=(carregaTab ? tab.getQtdQuiloPedagio() : 0)%>" class="inputtexto">
                                            Kg ou fra&ccedil;&atilde;o.
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar fórmula" onClick="javascript:exibirFormula($('formula_pedagio'));">
                                                </a>
                                            </strong>
                                            <input name="chkDeduzirPedagioIcms" style="display:none;" type="checkbox" id="chkDeduzirPedagioIcms" value="checkbox" <%=carregaTab && tab.isDeduzirPedagioIcms() ? "checked" : ""%>></td>
                                        <td class="TextoCampos"></td>
                                        <td class="CelulaZebra2"></td>
                                        <td class="TextoCampos"></td>
                                        <td colspan="3" class="CelulaZebra2"></td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">SEC/CAT<br>(Taxa Destino):</td>
                                        <td class="CelulaZebra2" colspan="2">
                                            <input name="valor_sec_cat" type="text" id="valor_sec_cat" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto" size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorSecCat()) : "0.00")%>">
                                            <a href="#topo">
                                                <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_sec_cat'));">
                                            </a>
                                            Até
                                            <input name="peso_limite_sec_cat" type="text" id="peso_limite_sec_cat" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto" size="2" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getPesoLimiteSecCat()) : "0")%>">
                                            Kg(s)
                                            <br>
                                            Excedente:
                                            <input name="valor_excedente_sec_cat" type="text" id="valor_excedente_sec_cat" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto" size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorExcedenteSecCat()) : "0.00")%>">
                                            por Kg
                                            <select name="calculaSecCat" id="calculaSecCat" style="font-size:8pt;" class="inputtexto">
                                                <option value="c" <%=(carregaTab && tab.getCalculaSecCat().equals("c") ? "selected" : "")%> >Sempre calcular</option>
                                                <option value="p" <%=(carregaTab && tab.getCalculaSecCat().equals("p") ? "selected" : "")%>>Perguntar</option>
                                            </select>
                                        </td>
                                        <td class="TextoCampos">Taxa Fixa<br>(Taxa Origem):</td>
                                        <td class="CelulaZebra2" colspan="5">
                                            <input name="valor_taxa_fixa" type="text" id="valor_taxa_fixa" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorTaxaFixa()) : "0.00")%>" class="inputtexto">
                                            <a href="#topo"><img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_taxa_fixa'));"></a>
                                            Até
                                            <input name="peso_limite_taxa_fixa" type="text" id="peso_limite_taxa_fixa" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto" size="2" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getPesoLimiteTaxaFixa()) : "0")%>">
                                            Kg(s).
                                            Excedente:
                                            <input name="valor_excedente_taxa_fixa" type="text" id="valor_excedente_taxa_fixa" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto" size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorExcedenteTaxaFixa()) : "0.00")%>"> por Kg
                                            <br>Cobrar apartir da
                                            <input name="entrega_montagem" type="text" id="entrega_montagem" style="font-size:8pt;" onChange="seNaoIntReset(this, '0');" class="inputtexto" size="1" maxlength="2" title="Esse campo só funcionará na rotina de montagem de carga." value="<%=(carregaTab ? tab.getTaxaApartirEntrega() : 0)%>">ª entrega na montagem de carga.
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="67"  class="TextoCampos">Frete M&iacute;nimo:<br>Calcular em:</td>
                                        <td width="10%" class="CelulaZebra2">
                                            <input name="valor_frete_minimo" type="text" id="valor_frete_minimo" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');" class="inputtexto"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorFreteMinimo()) : "0.00")%>">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_minimo'));">
                                                </a>
                                            </strong>
                                            <br>
                                            <select name="tipoImpressaoFreteMinimo" id="tipoImpressaoFreteMinimo" style="font-size:8pt;" class="inputtexto">
                                                <option value="v" selected>Frete Valor</option>
                                                <option value="p">Frete Peso</option>
                                            </select>
                                        </td>
                                        <td colspan="2" class="CelulaZebra2">
                                            <div align="right">Desconsiderar no c&aacute;lculo do frete m&iacute;nimo:</div>
                                        </td>
                                        <td colspan="5" class="CelulaZebra2">
                                            <table width="100%" border="1" cellspacing="1" cellpadding="2">
                                                <tr>
                                                    <td class="CelulaZebra2"><label>
                                                            <input type="checkbox" name="desconsideraGris" id="desconsideraGris" <%=carregaTab && tab.isDesconsideraGrisMinimo() ? "checked" : ""%>>
                                                            GRIS</label></td>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="desconsideraSeguro" id="desconsideraSeguro" <%=carregaTab && tab.isDesconsideraSeguroMinimo() ? "checked" : ""%>>
                                                        Seguro</td>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="desconsideraDespacho" id="desconsideraDespacho" <%=carregaTab && tab.isDesconsideraDespachoMinimo() ? "checked" : ""%>>
                                                        Despacho</td>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="desconsideraOutros" id="desconsideraOutros" <%=carregaTab && tab.isDesconsideraOutrosMinimo() ? "checked" : ""%>>
                                                        Outros</td>
                                                </tr>
                                                <tr>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="desconsideraPedagio" id="desconsideraPedagio" <%=carregaTab && tab.isDesconsideraPedagioMinimo() ? "checked" : ""%>>
                                                        Ped&aacute;gio</td>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="desconsideraTaxa" id="desconsideraTaxa" <%=carregaTab && tab.isDesconsideraTaxaMinimo() ? "checked" : ""%>>
                                                        Taxa fixa</td>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="desconsideraSec" id="desconsideraSec" <%=carregaTab && tab.isDesconsideraSeccatMinimo() ? "checked" : ""%>>
                                                        SEC/CAT</td>
                                                    <td class="CelulaZebra2"><input type="checkbox" name="marcaTodos" id="marcaTodos" onClick="marcarTodos(false);">
                                                        <strong>Todos</strong></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">TDE:</td>
                                        <td colspan="2" class="CelulaZebra2">
                                            <input name="valorTde" type="text" id="valorTde" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getValorDificuldadeEntrega()) : "0.00")%>" class="inputtexto">
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_tde'));">
                                                </a>
                                            </strong>
                                            <select name="tipoTde" id="tipoTde" style="font-size:8pt;" class="inputtexto">
                                                <option value="v" <%=(carregaTab && tab.getTipoTde().equals("v") ? "selected" : "")%> >R$ sobre o total do frete</option>
                                                <option value="p" <%=(carregaTab && tab.getTipoTde().equals("p") ? "selected" : "")%>>% sobre o total do frete</option>
                                            </select>
                                        </td>
                                        <td class="TextoCampos">Reentrega:</td>
                                        <td colspan="3" class="CelulaZebra2">
                                            <input name="valorReentrega" class="inputtexto" type="text" id="valorReentrega" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getPercentualReentrega()) : "0.00")%>">
                                            % do frete origem
                                        </td>
                                        <td class="TextoCampos">Devolu&ccedil;&atilde;o:</td>
                                        <td class="CelulaZebra2">
                                            <input name="valorDevolucao" class="inputtexto" type="text" id="valorDevolucao" style="font-size:8pt;" onChange="seNaoFloatReset(this, '0.00');"
                                                   size="4" maxlength="10" value="<%=(carregaTab ? Apoio.to_curr(tab.getPercentualDevolucao()) : "0.00")%>">
                                            %
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Incluir ICMS:</td>
                                        <td class="CelulaZebra2">
                                            <select name="incluir_icms" id="incluir_icms" style="font-size:8pt;" class="inputtexto" onclick="getTipoIcms()">
                                                <option value="true" <%=(carregaTab && tab.isIncluiIcms() ? "selected" : "")%>>Sim</option>
                                                <option value="false" <%=(!carregaTab || (carregaTab && !tab.isIncluiIcms()) ? "selected" : "")%>>N&atilde;o</option>
                                            </select>
                                            <select name="tipo_inclusao_icms" id="tipo_inclusao_icms" style="font-size:8pt;width: 65pt;" class="inputtexto">
                                                <option value="t" <%=(!carregaTab || (carregaTab && tab.getTipoInclusaoIcms().equals("t")) ? "selected" : "")%>>Sobre o Total da prestação</option>
                                                <option value="i" <%=(carregaTab && tab.getTipoInclusaoIcms().equals("i") ? "selected" : "")%>>Sobre as taxas individualmente</option>
                                            </select>
                                            <strong>
                                                <a href="#topo">
                                                    <img src="img/formula.png" border="0" align="absbottom" class="imagemLink" title="Editar f&oacute;rmula" onClick="javascript:exibirFormula($('formula_icms'));" style="display:none;">
                                                </a>
                                            </strong>
                                        </td>
                                        <td width="19%" class="TextoCampos">Incluir PIS/COFINS:</td>
                                        <td class="CelulaZebra2">
                                            <select name="incluir_federais" id="incluir_federais" style="font-size:8pt;" class="inputtexto">
                                                <option value="true" <%=(carregaTab && tab.isIncluirFederais() ? "selected" : "")%>>Sim</option>
                                                <option value="false" <%=(!carregaTab || (carregaTab && !tab.isIncluirFederais()) ? "selected" : "")%>>N&atilde;o</option>
                                            </select>
                                        </td>
                                        <td colspan="5" class="CelulaZebra2">
                                            <input name="chkDesconsiderarIcms" type="checkbox" id="chkDesconsiderarIcms" value="checkbox" <%=carregaTab && tab.isDesconsideraIcmsMinimo() ? "checked" : ""%>>
                                            Desconsiderar inclus&atilde;o de ICMS e PIS/COFINS sobre o total da prestação em caso de frete m&iacute;nimo.
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Prazo de Entrega:</td>
                                        <td colspan="4" >
                                            <table width="100%" border="1" cellspacing="1" cellpadding="2">
                                                <tr>
                                                    <td class="TextoCampos" width="13%">Rodoviário:</td>
                                                    <td class="CelulaZebra2" width="37%">
                                                        <input name="prazo_entrega" type="text" id="prazo_entrega" style="font-size:8pt;" onChange="seNaoIntReset(this, '0');" class="inputtexto"
                                                               size="1" maxlength="10" value="<%=(carregaTab ? tab.getPrazoEntrega() : 0)%>">
                                                        <select name="tipo_dias_entrega" class="inputtexto" id="tipo_dias_entrega" style="font-size:8pt;width:170px;">
                                                            <option value="u" <%=(carregaTab && tab.getTipoDiasEntrega().equals("u") ? "selected" : "")%>>Dias Úteis</option>
                                                            <option value="c" <%=(!carregaTab || (carregaTab && tab.getTipoDiasEntrega().equals("c")) ? "selected" : "")%>>Dias Corridos</option>
                                                            <option value="e" <%=(!carregaTab || (carregaTab && tab.getTipoDiasEntrega().equals("e")) ? "selected" : "")%>>Dias Corridos c/ entrega em dia útil</option>
                                                        </select>
                                                    </td>
                                                    <td class="TextoCampos" width="10%">Aéreo:</td>
                                                    <td class="CelulaZebra2" width="40%">
                                                        <input name="prazo_entrega_aereo" type="text" id="prazo_entrega_aereo" style="font-size:8pt;" onChange="seNaoIntReset(this, '0');" class="inputtexto"
                                                               size="1" maxlength="10" value="<%=(carregaTab ? tab.getPrazoEntregaAereo() : 0)%>">
                                                        <select name="tipo_dias_entrega_aereo" class="inputtexto" id="tipo_dias_entrega_aereo" style="font-size:8pt;width:170px;">
                                                            <option value="u" <%=(carregaTab && tab.getTipoDiasEntregaAereo().equals("u") ? "selected" : "")%>>Dias Úteis</option>
                                                            <option value="c" <%=(!carregaTab || (carregaTab && tab.getTipoDiasEntregaAereo().equals("c")) ? "selected" : "")%>>Dias Corridos</option>
                                                            <option value="e" <%=(!carregaTab || (carregaTab && tab.getTipoDiasEntregaAereo().equals("e")) ? "selected" : "")%>>Dias Corridos c/ entrega em dia útil</option>
                                                        </select>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td class="TextoCampos">Data Vigência:</td>
                                        <td class="CelulaZebra2">
                                            <input name="dataVigencia" type="text" id="dataVigencia" size="11" maxlength="10" style="font-size:8pt;"
                                                   value="<%=(carregaTab && tab.getDataVigencia() != null ? fmt.format(tab.getDataVigencia()) : "")%>" onBlur="alertInvalidDate(this, true)" class="fieldDate">
                                        </td>
                                        <td class="TextoCampos">Validade:</td>
                                        <td  class="CelulaZebra2">
                                            <input name="validade" type="text" id="validade" size="10" maxlength="10" style="font-size:8pt;"
                                                   value="<%=(carregaTab && tab.getValidaAte() != null ? fmt.format(tab.getValidaAte()) : "")%>" onBlur="alertInvalidDate(this, true)" class="fieldDate">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>

                <div id="divAuditoria" <%=nivelUserTabela <= 4 ? "style='display: none'" : ""%> >
                    <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tbody id="tbAuditoriaCabecalho">
                            <tr>
                                <td colspan="6"  class="tabela"><div align="center">Auditoria</div></td>
                            </tr>
                            <tr class="celulaNoAlign">
                                <td colspan="3"  align="left">
                                    <label>Data da Ação:</label>&ApplyFunction;
                                    <input type="text" class="fieldDate" id="dataDeAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" />
                                    <label> Até </label>
                                    <input type="text" class="fieldDate" id="dataAteAuditoria" maxlength="10" size="10" value="<%=Apoio.getDataAtual()%>" />
                                </td>
                                <td colspan=""  >
                                    <input type="button" class="botoes" id="btPesquisarAuditoria" value=" Pesquisar " onclick="javascript:tryRequestToServer(function () {
                                                pesquisarAuditoria();
                                            });" >
                                </td>
                                <td colspan="2"  ></td>
                            </tr>
                            <tr class="celula">
                                <td width="3%"></td>
                                <td width="17%">Usuário</td>
                                <td width="15%">Data</td>
                                <td width="15%">Ação</td>
                                <td width="10%">IP</td>
                                <td width="50%"></td>
                            </tr>
                        </tbody>
                        <tbody id="tbAuditoriaConteudo">
                        </tbody>
                                <tr>
                                    <td colspan="6">
                                        <table width="100%"  border="0">
                                            <tr>
                                                <td width="10%" class="TextoCampos">Incluso:</td>
                                                <td width="40%" class="CelulaZebra2">Em: <%=carregaTab && tab.getCreatedAt() != null ? fmt.format(tab.getCreatedAt()) : ""%> <br>
                                                    Por: <%=carregaTab && tab.getCreatedAt() != null ? tab.getCreatedBy().getNome() : ""%></td>
                                                <td width="10%" class="TextoCampos">Alterado:</td>
                                                <td width="40%" class="CelulaZebra2">Em: <%=(carregaTab && tab.getUpdatedAt() != null) ? fmt.format(tab.getUpdatedAt()) : ""%><br>
                                                    Por: <%=(carregaTab && tab.getUpdatedBy().getNome() != null) ? tab.getUpdatedBy().getNome() : ""%></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                    </table>
                </div>
            <c:if test="${tab.tipoRota eq 'c' and permissaoTabelaRota}">
                <div id="divTabelaCarreteiro">
                    <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tr>
                            <td colspan="6" class="tabela"><div align="center">Tabela Carreteiro</div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" align="left">
                                <div align="left">
                                    <label class="botoes" style="margin-left: 20px;padding-left: 10px;padding-right:10px;" id="visualizarTabelaCarreteiro">Visualizar valores da rota</label>
                                </div>
                                <div class="container-tabela-veiculo">
                                    <div class="container-cabecalho">
                                        <div class="cabecalho">
                                            <label>Tipo de Veículo</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Cliente</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Produto/Oper.</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Tabela</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Valor</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>2° Viagem</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Pedágio</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Taxa de Entrega</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Diária</label>
                                        </div>
                                        <div class="cabecalho">
                                            <label>Taxa Fixa</label>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </c:if>
            </div>
            <% if (nivelUserTabela >= 2) {%>
            <br/>
            <table width="88%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="CelulaZebra2">
                    <td height="24" colspan="6">
                <center>
                    <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function () {
                                salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');
                            });">
                </center>
                </td>
                </tr>
            </table>
            <%}%>
        </form>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>
        <link rel="stylesheet" href="${homePath}/assets/css/estiloTelaTabelaPreco.css?v=${random.nextInt()}">
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/script/funcoesTelaTabelaPreco.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/script/mascaras.js?v=${random.nextInt()}"></script>
    </body>
</html>
