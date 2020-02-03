<%@page import="java.sql.ResultSetMetaData"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         conhecimento.duplicata.fatura.*,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio" %>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="mov_banco.conta.BeanCadConta"%>

<%  //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP
    int nivelUserClient = Apoio.getUsuario(request).getAcesso("cadcliente");
    int nivelCtrcFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    boolean isIncluirFaturasCTeConfirmados = Apoio.getConfiguracao(request).isIncluirFaturasCTeConfirmados();
    boolean mostrarFreteCifEmitidoPropriaFilialFobs = Apoio.getUsuario(request).getFilial().isMostrarFreteCifEmitidoPropriaFilialFobs();
    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null) {
        response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
    }
    
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();

    BeanConsultaFatura conFat = null;
    BeanConsultaFatura conFat2 = null;
    String acao = request.getParameter("acao");
    String marcados = "";
    String tipoData = "";
    String tiposConhecimentos = (request.getParameter("tipoConhecimento") == null ? "" : request.getParameter("tipoConhecimento"));
    boolean isLimiteFatura = Apoio.parseBoolean(request.getParameter("isLimiteFatura"));

    acao = ((acao == null) ? "" : acao);
    if (acao.equals("obter_destalhes")) {
        conFat2 = new BeanConsultaFatura();
        conFat2.setConexao(Apoio.getUsuario(request).getConexao());
        //setar campos necessários
        conFat2.setIdConsignatario(Integer.parseInt(request.getParameter("idConsignatario")));
        conFat2.setMostrarCtrcsGrupo(Boolean.parseBoolean(request.getParameter("chkGrupos")));
        conFat2.setTipoData(request.getParameter("tipoConsultaData"));
        conFat2.setMostraCtrcAvista(request.getParameter("tipoFpag"));
        conFat2.setValor1(Double.parseDouble(request.getParameter("valor1")));
        conFat2.setValor2(Double.parseDouble(request.getParameter("valor2")));
        conFat2.setDataVenc1(request.getParameter("dtinicial") == null ? Apoio.getDataAtual() : request.getParameter("dtinicial"));
        conFat2.setDataVenc2(request.getParameter("dtfinal") == null ? Apoio.getDataAtual() : request.getParameter("dtfinal"));
        conFat2.setCtrcsEntregues(Boolean.parseBoolean(request.getParameter("chkEntregues")));
        conFat2.setUmaFaturaPorCT(Boolean.parseBoolean(request.getParameter("chkUmaParaCada")));
        conFat2.setManifesto(request.getParameter("manifesto"));
        conFat2.setIdParcels(request.getParameter("idParcels"));
        conFat2.setAnoManifesto(request.getParameter("anoManifesto"));
        conFat2.setTipoConhecimento((request.getParameter("tipoConhecimento") == null) ? "" : request.getParameter("tipoConhecimento"));
        conFat2.setIdFilial(Apoio.parseInt(request.getParameter("idFilial")));
        conFat2.setSerie(request.getParameter("serie"));
        conFat2.setCtrcsManifestados(Boolean.parseBoolean(request.getParameter("chkCteManifestados")));
        conFat2.getConfiguracao().setIncluirFaturasCTeConfirmados(Apoio.parseBoolean(request.getParameter("incluirFaturasCteConfirmados")));
        conFat2.setTipoPagadorCIF(Apoio.parseBoolean(request.getParameter("tipoPagadorCIF") == null ? "false" : request.getParameter("tipoPagadorCIF")));
        conFat2.setTipoPagadorCON(Apoio.parseBoolean(request.getParameter("tipoPagadorCON") == null ? "false" : request.getParameter("tipoPagadorCON")));
        conFat2.setTipoPagadorFOB(Apoio.parseBoolean(request.getParameter("tipoPagadorFOB") == null ? "false" : request.getParameter("tipoPagadorFOB")));
        conFat2.setTipoPagadorRED(Apoio.parseBoolean(request.getParameter("tipoPagadorRED") == null ? "false" : request.getParameter("tipoPagadorRED")));
        conFat2.getFreteFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(Apoio.parseBoolean(request.getParameter("chkFretesFilial") == null ? "false" : request.getParameter("chkFretesFilial")));
        conFat2.getFreteFilial().setIdfilial(Integer.parseInt(request.getParameter("idFilialUsuario") != null ? request.getParameter("idFilialUsuario") : Apoio.getUsuario(request).getFilial().getId() + ""));


        if (conFat2.visualizarCtrcs()) {
            //; 
            ResultSet ct = conFat2.getResultado();
            int row = 0;
            boolean finalizado = false;
            StringBuilder resultado = new StringBuilder();
            resultado.append("<table width='100%' border='0' class='bordaFina' id='trid_'");
            resultado.append(request.getParameter("idcarta"));
            resultado.append(">");
            resultado.append("<tr class='tabela'>");
            resultado.append("<td width='1%'></td>");
            resultado.append("<td width='8%'>Tipo</td>");
            resultado.append("<td width='7%'>Docum.</td>");
            resultado.append("<td width='3%'><div align='center'>PC</div></td>");
            resultado.append("<td width='9%'>Data</td>");
            resultado.append("<td width='27%'>Remetente</td>");
            resultado.append("<td width='27%'>Destinatário</td>");
            resultado.append("<td width='8%'><div align='right'>Valor</div></td>");
            resultado.append("<td width='9%'>Entrega</td>");
            resultado.append("</tr>");
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
            DecimalFormat decimalFormat = new DecimalFormat("#,##0.00");
            while (ct.next()) {
                resultado.append("<tr class=").append((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2").append(">");
                resultado.append("<td>").append("<img src=\"img/jpg.png\" width=\"20\" height=\"20\" border=\"0\" align=\"right\" class=\"imagemLink anexoCTRC\" title=\"Imagens de documentos\" ");
                resultado.append("data-id=\"").append(ct.getInt("idmovimento")).append("\" data-filial-id=\"").append(ct.getString("filial_lan")).append("\" ");
                resultado.append("data-numero=\"").append(ct.getString("ctrc")).append("\" data-data=\"").append(Apoio.getFormatData(ct.getDate("dtemissao"))).append("\"");
                resultado.append(">").append("</td>");
                resultado.append("<td>").append(ct.getString("categoria").equals("ct") ? "CTRC" : "NF Serviço").append("</td>");
                resultado.append("<td>").append(ct.getString("ctrc")).append("-").append(ct.getString("serie")).append("</td>");
                resultado.append("<td><div align='center'>").append(ct.getString("num_dup")).append("</div></td>");
                resultado.append("<td>").append(formato.format(ct.getDate("dtemissao"))).append("</td>");
                resultado.append("<td>").append(ct.getString("remetente")).append("</td>");
                resultado.append("<td>").append(ct.getString("destinatario")).append("</td>");
                resultado.append("<td><div align='right'>").append(decimalFormat.format(ct.getDouble("vlduplicata"))).append("</div></td>");
                resultado.append("<td>").append(ct.getDate("dtfechamento") == null ? "" : formato.format(ct.getDate("dtfechamento"))).append("</td>");

                row++;
            }
            resultado.append("</table>");
            response.getWriter().append(resultado.toString());
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    } else if (acao.equals("consultar")) {

        marcados = (request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados"));
        //Instanciando o bean pra trazer os CTRC's
        conFat = new BeanConsultaFatura();
        conFat.setConexao(Apoio.getUsuario(request).getConexao());

        tipoData = (request.getParameter("tipoConsultaData") == null ? "s.emissao_em" : request.getParameter("tipoConsultaData"));

        conFat.setValor1(Double.parseDouble(request.getParameter("valor1") != null ? request.getParameter("valor1") : "0"));
        conFat.setValor2(Double.parseDouble(request.getParameter("valor2") != null ? request.getParameter("valor2") : "0"));
        conFat.setDataVenc1((request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual()));
        conFat.setDataVenc2((request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual()));
        conFat.setIdConsignatario(Integer.parseInt(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0"));
        conFat.setCtrcsEntregues(Boolean.parseBoolean(request.getParameter("chkEntregues") == null ? "false" : request.getParameter("chkEntregues")));
        conFat.setUmaFaturaPorCT(Boolean.parseBoolean(request.getParameter("chkUmaParaCada") == null ? "false" : request.getParameter("chkUmaParaCada")));
        conFat.setManifesto(request.getParameter("manifesto"));
        conFat.setSerie(request.getParameter("serie") != null ? request.getParameter("serie") : "");
        conFat.setAnoManifesto(request.getParameter("anoManifesto"));
        conFat.setTipoData(tipoData);
        conFat.setValorDaConsulta(marcados);
        conFat.setMostraCtrcAvista(request.getParameter("tipoFpag") == null ? "p" : request.getParameter("tipoFpag"));
        conFat.setTipoCobranca(request.getParameter("tipoCobranca") == null ? "a" : request.getParameter("tipoCobranca"));
        conFat.setTipoConhecimento((request.getParameter("tipoConhecimento") == null) ? "" : request.getParameter("tipoConhecimento"));
        conFat.setIdFilial(Apoio.parseInt(request.getParameter("idFilial")));
        conFat.setTipoPagadorCIF(Apoio.parseBoolean(request.getParameter("tipoPagadorCIF") == null ? "false" : request.getParameter("tipoPagadorCIF")));
        conFat.setTipoPagadorCON(Apoio.parseBoolean(request.getParameter("tipoPagadorCON") == null ? "false" : request.getParameter("tipoPagadorCON")));
        conFat.setTipoPagadorFOB(Apoio.parseBoolean(request.getParameter("tipoPagadorFOB") == null ? "false" : request.getParameter("tipoPagadorFOB")));
        conFat.setTipoPagadorRED(Apoio.parseBoolean(request.getParameter("tipoPagadorRED") == null ? "false" : request.getParameter("tipoPagadorRED")));
        conFat.setCtrcsManifestados(Apoio.parseBoolean(request.getParameter("chkCteManifestados")));
        conFat.setFiltrosPeriodicidade(request.getParameter("periodicidade") == null ? "" : request.getParameter("periodicidade"));
        conFat.getConfiguracao().setIncluirFaturasCTeConfirmados(isIncluirFaturasCTeConfirmados);
        if(request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("1")) {
            conFat.getFreteFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(true);
            conFat.getFreteFilial().setIdfilial(Integer.parseInt(request.getParameter("idFilialUsuario") != null ? request.getParameter("idFilialUsuario") : Apoio.getUsuario(request).getFilial().getId() + ""));
        } else {
            conFat.getFreteFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(false);
            conFat.getFreteFilial().setIdfilial(Integer.parseInt(request.getParameter("idFilialDestino") != null ? request.getParameter("idFilialDestino") : Apoio.getUsuario(request).getFilial().getId() + ""));
        }
        conFat.setFiltroDestino(request.getParameter("filtroCidade"));

        if (request.getParameter("tipoProdutos") != null && !request.getParameter("tipoProdutos").isEmpty()) {
            for (String tipoProduto : request.getParameter("tipoProdutos").split(",")) {
                int id = Apoio.parseInt(tipoProduto);

                conFat.getTipoProdutos().add(id);
            }
        }

        conFat.setApenasComprovanteEntrega(Apoio.parseBoolean(request.getParameter("chkApenasComprovanteEntrega")));
        conFat.setLimiteFatura(isLimiteFatura);
    } else if (acao.equals("salvar")) {
        BeanFatura ft = null;
        BeanCadFatura cadFat = null;
        cadFat = new BeanCadFatura();
        cadFat.setConexao(Apoio.getUsuario(request).getConexao());
        cadFat.setExecutor(Apoio.getUsuario(request));
        boolean erro = false;

        int count = Integer.parseInt(request.getParameter("count"));
        BeanFatura[] aFat = new BeanFatura[count];
        int countArr = 0;


        for (int i = 0; i <= count; i++) {
            if (request.getParameter("chk_" + i) != null) {


                ft = new BeanFatura();
                String emissao = request.getParameter("dtemissao");
                ft.setNumero("");
                ft.setAnoFatura(emissao.split("/")[2]);
                ft.setEmissaoEm(Apoio.paraDate(emissao));
                ft.getCliente().setRazaosocial(request.getParameter("con_rzs"));
                //ft.getCliente().setCnpj(request.getParameter("con_cnpj"));
                ft.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
                //ft.setValorAcrescimo(Double.parseDouble((request.getParameter("valorAcrescimo"))));
                ft.setDeduzirDesconto(true);
                //ft.setDescricaoDesconto(request.getParameter("descricaoDesconto"));
                ft.setMultaAcrescimo(Double.parseDouble((request.getParameter("multa"))));
                ft.setJurosAcrescimo(Double.parseDouble((request.getParameter("juros"))));
                ft.setObservacao(request.getParameter("observacao"));

                //ft.setCtrcsAvaria(request.getParameter("ctrcs_avaria"));
                ft.getFilialCobranca().setIdfilial(Integer.parseInt(request.getParameter("filialCobrancaId")));
                ft.setGeraBoleto(request.getParameter("geraBoleto") != null ? true : false);
                ft.setBoletoNossoNumero(Integer.parseInt(request.getParameter("nossoNumero")));
                ft.setAceite(request.getParameter("aceite") != null ? true : false);
                ft.setEspecieBoleto(request.getParameter("especieBoleto"));
                ft.setBoletoInstrucao1(request.getParameter("instrucao1"));
                ft.setBoletoInstrucao2(request.getParameter("instrucao2"));
                ft.setBoletoInstrucao3(request.getParameter("instrucao3"));
                ft.setBoletoInstrucao4(request.getParameter("instrucao4"));
                ft.setBoletoInstrucao5(request.getParameter("instrucao5"));
                ft.setSituacao(request.getParameter("situacao"));
                if(Apoio.parseBoolean(request.getParameter("clienteProtestar_"+i))){
                    ft.setCodProtesto(3);
                }else{   
                    ft.setCodProtesto(Integer.parseInt(request.getParameter("codProtesto")));
                }
                ft.setDiasProtesto(Integer.parseInt(request.getParameter("diasProtesto")));
                ft.setDiasDevolucao(Apoio.parseInt(request.getParameter("diasDevolucao")));
                ft.setCodDevolucao(Apoio.parseInt(request.getParameter("codDevolucao")));
                ft.setValorLiquido(Double.parseDouble(request.getParameter("total_" + i)));
                ft.setNumeroLote(1);

                ft.getCliente().setIdcliente(Integer.parseInt(request.getParameter("idConsig_" + i)));
                ft.setVenceEm(Apoio.paraDate(request.getParameter("vencimento_" + i)));
                ft.setValorDesconto(Double.parseDouble((request.getParameter("desconto_" + i))));
                ft.setCtrcs(request.getParameter("chk_" + i).replace("{", "").replace("}", ""));

                ft.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));

                BeanCadConta cadConta = new BeanCadConta();
                cadConta.setConexao(Apoio.getUsuario(request).getConexao());
                cadConta.getConta().setIdConta(ft.getConta().getIdConta());
                boolean foi = cadConta.LoadAllPropertys();

                if (foi) {
                    ft.setConta(cadConta.getConta());
                }

                aFat[countArr] = ft;
                countArr++;
            }
        }
        cadFat.setArrayFatura(aFat);
        String msgErro = "";
        try{
            erro = !cadFat.IncluiLoteFatura();
        }catch(Exception e){
            erro = true;
            msgErro = e.getMessage();
        }

        // EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        String scr = "";
        if (erro) {
            scr = "<script>";
            scr += "window.opener.document.getElementById('salvar').disabled = false;";
            scr += "window.opener.document.getElementById('salvar').value = 'Salvar';";
            if (cadFat.getErros().indexOf("unk_fatura") > 0) {
                String suggestId = cadFat.getProximaFatura();
                scr += "if (confirm('A fatura " + ft.getNumero() + "/" + ft.getAnoFatura() + " já existe. \\n "
                        + "Deseja que o sistema crie com o número " + suggestId + "/" + ft.getAnoFatura() + " ?')){"
                        + "window.opener.document.getElementById('numFatura').value = '" + suggestId + "';"
                        + "window.opener.document.getElementById('salvar').onclick();"
                        + "}";
            } else {
                scr += "alert('" + (msgErro.equals("") ? cadFat.getErros() : msgErro) + "');";
            }
            scr += "window.close();"
                    + "</script>";
            acao = (acao.equals("atualizar") ? "editar" : "iniciar");
        } else {// <-- Se nao teve erro redirecione para a consulta
            scr = "<script>";

            if (request.getParameter("geraBoleto") != null && Apoio.getUsuario(request).getAcesso("geraremessabanco") > 0) {
                conFat = new BeanConsultaFatura();
                conFat.setConta(request.getParameter("conta"));
                conFat.setCampoDeConsulta("fatura_id");
                conFat.setValorDaConsulta(cadFat.getFatura().getId() + "");
                conFat.setConexao(Apoio.getConnectionFromUser(request));
                int lote = 0;
                if (conFat.Consultar()) {
                    ResultSet r = conFat.getResultado();
                    while (r.next()) {
                        lote = r.getInt("lote_automatico");
                    }
                }

                scr += "if(confirm('Deseja gerar arquivo de remessa do lote?')){"
                        + "window.open('./jspexporta_boleto.jsp?acao=consultar&"
                        + "campoDeConsulta=lote_automatico&valorDaConsulta=" + lote
                        + "&idConta=" + request.getParameter("conta") + "','exporta_boleto',"
                        + "'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1'); "
                        + "}";
            }

            scr += "window.opener.document.location.replace('./consultafatura?acao=iniciar');"
                    + "window.close();"
                    + "</script>";
        }
        response.getWriter().append(scr);
        response.getWriter().close();

    }

    // -- FIM DO MSA
%>
<script language="javascript" src="script/funcoes.js" type=""></script>
<script type="text/javascript" src="${homePath}/assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/script/mascaras.js?v=${random.nextInt()}" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var homePath = '${homePath}';

    var qtdResultados = 0;
    jQuery.noConflict();
    function fechar(){
        window.close();
    }

    function replaceAll(string, token, newtoken) {
        while (string.indexOf(token) != -1) {
            string = string.replace(token, newtoken);
        }
        return string;
    }

    function salva(qtdlinha){
        var formu = $("formulario");
        var selecao = "";



        var dataEmissao = new Date($('dtemissao').value.substring(6,10),$('dtemissao').value.substring(3,5),$('dtemissao').value.substring(0,2));
        for (var i = 0; i <= qtdlinha - 1; ++i){
            if ($("chk_"+i).checked){
                selecao = "true";
                var dataVencimento = new Date($('vencimento_' + i).value.substring(6,10),$('vencimento_' + i).value.substring(3,5),$('vencimento_' + i).value.substring(0,2));
                if (dataVencimento.getTime() < dataEmissao.getTime()){
                    alert('A data de vencimento não pode ser inferior a data de emissão.');
                    $('vencimento_' + i).select();
                    return false;
                }
            }
        }

        if (selecao == "" || qtdlinha == 0){
            alert('Escolha, no mínimo, um Cliente.');
            return false;
        }

        if($("geraBoleto").checked && $("conta").value == 0){
            return alert('Para gerar boleto é nessario selecionar uma conta.');
        }

        $("salvar").disabled = true;
        $("salvar").value = "Enviando...";
        window.open('about:blank', 'pop', 'width=210, height=100');

        formu.submit();
        //submitPopupForm();
        return true;
    }

    function pesquisar(){
        if((!$("tipoPagadorCIF").checked) && (!$("tipoPagadorCON").checked) && (!$("tipoPagadorFOB").checked) && (!$("tipoPagadorRED").checked)){
            alert("Informe o tipo de pagador (CIF,FOB,CON,RED) corretamente!");
            return null;
        }

        sessionStorage.setItem('tipoProdutos', $('tipo_produtos').value);

        location.replace("./cadfatura_lote.jsp?acao=consultar&marcados=0"+
            "&acaoDoPai=<%=request.getParameter("acaoDoPai")%>"+
            "&idconsignatario="+$("idconsignatario").value+
            "&con_rzs="+$("con_rzs").value+
            "&chkEntregues="+$('chkEntregues').checked+
            "&chkUmaParaCada="+$('chkUmaParaCada').checked+
            "&tipoFpag="+$('tipoFpag').value+
            //"&chkGrupos="+$('chkGrupos').checked+
            "&dtinicial="+$('dtinicial').value+
            "&dtfinal="+$('dtfinal').value+
            "&dtvencimento="+$('dtvencimento').value+
            "&tipoCobranca="+$('tipoCobranca').value+
            "&manifesto="+$('valorConsulta').value+
            "&serie="+$('serie').value+
            "&anoManifesto="+$('anoManifesto').value+
            "&valor1="+$('valor1').value+
            "&valor2="+$('valor2').value+
            "&tipoConhecimento="+$('tipoConhecimento').value+
            "&tipoConsultaData="+$("tipoConsultaData").value+
            "&idFilial="+$("idFilial").value+
            "&tipoPagadorCIF="+$('tipoPagadorCIF').checked+
            "&tipoPagadorCON="+$('tipoPagadorCON').checked+
            "&tipoPagadorFOB="+$('tipoPagadorFOB').checked+
            "&tipoPagadorRED="+$('tipoPagadorRED').checked+
            "&chkCteManifestados="+$('chkCteManifestados').checked+
            "&periodicidade="+$('periodicidade').value+
            "&chkCteManifestados="+$('chkCteManifestados').checked+
            "&incluirFaturasCteConfirmados="+'<%=isIncluirFaturasCTeConfirmados%>'+
            "&chkFretesFilial="+document.getElementById("chkFretesFilial").checked+
            "&optionNenhum="+document.getElementById("optionNenhum").checked+
            "&chkFretesFilial="+document.getElementById("chkFretesFilial").checked+
            "&chkFretesFilialDestino="+document.getElementById("chkFretesFilialDestino").checked+
            "&filtroDestino="+document.querySelector('input[name=filtroCidade]:checked').value+
            "&filtroCidade="+document.querySelector('input[name=filtroCidade]:checked').value+
            "&idFilialUsuario="+$('idFilialUsuario').value+
            "&idFilialDestino="+$("idFilialDestino").value+
            "&tipoProdutos=" + $('tipo_produtos').value.split('!@!').map(function (e) {
                return e.split('#@#')[1]
            }).join() +
            "&chkApenasComprovanteEntrega=" + $('chkApenasComprovanteEntrega').checked+
            "&isLimiteFatura=" + $('isLimiteFatura').checked+
            "&limiteFatura=" + $('limiteFatura').value
        );
    }

    function atribuiValores(objeto){
        for(var i = 0; i <= qtdResultados; i++){
            if($("vencimento_"+i) != null){
                $("vencimento_"+i).value = objeto.value;
            }
        }
    }

    function localizaconsignatario(){
        windowConsignatario = window.open('localiza?categoria=loc_cliente&acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>','Consignatario_Fatura',
        'top=80,left=70,height=500,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
     
                function getDias(indice, data) {
                    var dataEmissao = data;
                    var idCliente = $("idconsignatario_"+indice).value;
                    new Ajax.Request("./ClienteControlador?acao=localizaDiasVencimento&idCliente=" + idCliente + "&dataEmissao=" + dataEmissao,
                    {
                        method: "get",
                        onSuccess: function(transport) {
                            var response = transport.responseText;
                           if(response==''){
                                $("vencimento_"+indice).value = $("dtvencimento").value;
                                $("vencimento_"+indice).value = diaSemana($("vencimento_"+indice).value,indice);
                           }else{
                                preencheDiasVencimento(response, indice, dataEmissao);
                           }
                        },
                        onFailure: function() {
                           
                        }
                    });
                }

                function preencheDiasVencimento(resposta, indice, data) {
                    
                    var dataJson = jQuery.parseJSON(resposta);
                    $("dia_vencimento").value = dataJson.dia_vencimento;
                    $("mes").value = dataJson.mes;
        
                    var dataEmissao = data;
                    var dtVencimento = montaData(dataEmissao, $('dia_vencimento').value,$('mes').value );
                    if(validaData(dtVencimento)){
                        $("vencimento_"+indice).value = diaSemana(dtVencimento,indice);
                    }else{
                        alert("Erro ao carregar data de vencimento do cliente: "+$("rzsCli_"+indice).value+ " , favor preencher manualmente.");
                        $("vencimento_"+indice).value = '';
                    } 
                 }
                 
                 function diaSemana(dtVencimento,indice){
                    var dataAmericana = new Date();
                    var dataBr = new Date();
                    dataAmericana = converterDataUSA(dtVencimento);
                    var dataInvalida = false;
                    //recebe o dia da semana da emissão
                    var diaPagamento = new Array(7);
                    diaPagamento[0] = ($('domingo_'+indice).value == 't' || $('domingo_'+indice).value == 'true');
                    diaPagamento[1] = ($('segunda_'+indice).value == 't' || $('segunda_'+indice).value == 'true');
                    diaPagamento[2] = ($('terca_'+indice).value == 't' || $('terca_'+indice).value == 'true');
                    diaPagamento[3] = ($('quarta_'+indice).value == 't' || $('quarta_'+indice).value == 'true');
                    diaPagamento[4] = ($('quinta_'+indice).value == 't' || $('quinta_'+indice).value == 'true');
                    diaPagamento[5] = ($('sexta_'+indice).value == 't' || $('sexta_'+indice).value == 'true');
                    diaPagamento[6] = ($('sabado_'+indice).value == 't' || $('sabado_'+indice).value == 'true');
                    
                    var dataReferencia = dataAmericana;
                    for (var i = 0, max = 7; i < max; i++) {
                        if (!diaPagamento[dataReferencia.getDay()]) {
                            dataReferencia = addDays(dataReferencia, 1);
                            dataInvalida = true;
                        }else{
                            dataInvalida = false;
                            break;
                        }
                    }
                    if(!dataInvalida){
                        dataBr = converterDataBR(dataReferencia);
                    }else{
                        dataBr = converterDataBR(dataAmericana);
                    }
                    return dataBr;
                }

    function verCliente(){
        var idCliente = 0;
        idCliente = $('idconsignatario').value;
        if (idCliente != ""){
            window.open('cadcliente?acao=editar&id=' + idCliente ,'Cliente',
            'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }else{
            alert("Informe o cliente.")
        }
    }

    function totalValor(indice){
        var valor = $("valor_"+indice).value;
        var desconto = $("desconto_"+indice).value;

        $("total_"+indice).value = formatoMoeda(parseFloat(valor) - parseFloat(desconto));
    }

    function calculaVencimento(dias,indice,tipoVencimento, dataEmissao){
        if($("tppgto_"+indice).value=='v'){
            try{              
                getDias(indice, $("dtvencimento").value);
            }catch(e){
                console.log(e);
            }
        }else{
            if (tipoVencimento == 'f'){
                if(dataEmissao==null){
                var data = new Date;
                var dia = data.getDate();
                var mes = data.getMonth()+1;
                var ano = data.getFullYear();
                var dtString = (dia.length ==1? "0" +dia : dia)  + "/" + mes + "/" + ano;
                $("vencimento_"+indice).value = incData(dtString, dias);
                }else{
                    $("vencimento_"+indice).value = incData(dataEmissao, dias);
                }            
            $("vencimento_"+indice).value = diaSemana($("vencimento_"+indice).value,indice);
            }else{
                $("vencimento_"+indice).value = $("novo_vencimento_"+indice).value;
            }
            $("vencimento_"+indice).value = diaSemana($("vencimento_"+indice).value,indice);
        }
    }
    
    function getDataVencimento(){
        
        for (var i = 0; getObj("tppgto_" + i) != null; ++i){
                if (getObj("tppgto_" + i).value=='v'){
                    getDias(i, $("dtemissao").value);
                }else{
                    calculaVencimento($("condicaoPgto_"+i).value,i,$("tipoDiasVencimento_"+i).value, $("dtemissao").value);
                }
        }
        
        
    }

    function limpaConsig(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }

    function viewDetalhes(idConsignatario, idParcels, idFilial){
        var serie = $("serie").value;
        if (Element.visible("trfat_"+idConsignatario+"_"+idParcels)){
            Element.hide("trfat_"+idConsignatario+"_"+idParcels);
            $('plus_'+idConsignatario+"_"+idParcels).style.display = '';
            $('minus_'+idConsignatario+"_"+idParcels).style.display = 'none';
        }else{
            $('plus_'+idConsignatario+"_"+idParcels).style.display = 'none';
            $('minus_'+idConsignatario+"_"+idParcels).style.display = '';
            jQuery.ajax({
                    url: 'cadfatura_lote.jsp',
                    dataType: "text",
                    method: "post",
                    data: {
                        acao : "obter_destalhes",
                        idFilial : idFilial,                       
                        serie : serie,
                        tipoConhecimento : "<%=request.getParameter("tipoConhecimento") == null ? "" : request.getParameter("tipoConhecimento")%>",
                        tipoConsultaData : "<%=request.getParameter("tipoConsultaData") == null ? "s.emissao_em" : request.getParameter("tipoConsultaData")%>",
                        idParcels : idParcels,
                        anoManifesto:$('anoManifesto').value,
                        manifesto:$('valorConsulta').value,
                        valor2: '<%=request.getParameter("valor2") == null ? "0" : request.getParameter("valor2")%>',
                        valor1: '<%=request.getParameter("valor1") == null ? "0" : request.getParameter("valor1")%>',
                        idConsignatario:idConsignatario,
                        chkEntregues:"<%=request.getParameter("chkEntregues") == null ? false : request.getParameter("chkEntregues")%>",
                        chkUmaParaCada:"<%=request.getParameter("chkUmaParaCada") == null ? false : request.getParameter("chkUmaParaCada")%>",
                        chkGrupos:false,
                        tipoFpag:"<%=request.getParameter("tipoFpag") == null ? "a" : request.getParameter("tipoFpag")%>",
                        dtinicial:"<%=request.getParameter("dtinicial") == null ? Apoio.getDataAtual() : request.getParameter("dtinicial")%>",
                        dtfinal:"<%=request.getParameter("dtfinal") == null ? Apoio.getDataAtual() : request.getParameter("dtfinal")%>",
                        tipoPagadorCIF :$("tipoPagadorCIF").checked,
                        tipoPagadorFOB :$("tipoPagadorFOB").checked,
                        tipoPagadorCON :$("tipoPagadorCON").checked,
                        tipoPagadorRED :$("tipoPagadorRED").checked
                
                    },
                    success: function(data) { 
                            //se deu algum erro na requisicao...
                            if (data == "load=0") {
                                return false;
                            }else{
                                Element.show("trfat_"+idConsignatario+"_"+idParcels);
                                $("trfat_"+idConsignatario+"_"+idParcels).childNodes[(isIE()? 1 : 3)].innerHTML = data;
                            }
                        }
                });            
        }
    }

    function controlaTrBoleto(checked){
        if(checked){
            $("trBoleto").style.display = "";
        }else{
            $("trBoleto").style.display = "none";
        }
    }

    function valoresDefaultBoleto(idConta){
        if($("hdInstrucao1_" + idConta) != null){
            $("instrucao1").value = $("hdInstrucao1_" + idConta).value;
            $("instrucao2").value = $("hdInstrucao2_" + idConta).value;
            $("instrucao3").value = $("hdInstrucao3_" + idConta).value;
            $("instrucao4").value = $("hdInstrucao4_" + idConta).value;
            $("instrucao5").value = $("hdInstrucao5_" + idConta).value;
            if($("codProtesto") != null){
                $("codProtesto").value = $("hdCodProtesto_" + idConta).value;
                $("diasProtesto").value = $("hdDiasProtesto_" + idConta).value;
                $("juros").value = $("hdJuros_" + idConta).value;
                $("multa").value = $("hdMulta_" + idConta).value;
            }
            if($("codDevolucao") != null){
                $("diasDevolucao").value = $("hdDiasDevolucao_" + idConta).value;
                $("codDevolucao").value = $("hdCodDevolucao_" + idConta).value;
            }
        }

    }

    //Quando o usuário clica em voltar
    function voltar(){
        parent.document.location.replace("./consultafatura?acao=iniciar");
    }

    function alteraCampo(){
        if ($('tipoConsultaData').value == 'm.nmanifesto'){
            $('dtinicial').style.display = "none";
            $('dtfinal').style.display = "none";
            $('lbData').style.display = "none";
            $('valorConsulta').style.display = "";
            $('anoManifesto').style.display = "";
    
        }else{
            $('dtinicial').style.display = "";
            $('dtfinal').style.display = "";
            $('lbData').style.display = "";
            $('valorConsulta').style.display = "none";
            $('anoManifesto').style.display = "none";
    
        }
        if(!$("optionNenhum").checked && !$("chkFretesFilial").checked && !$("chkFretesFilialDestino").checked){
            $("optionNenhum").checked = 't';
        }

        if (sessionStorage.getItem('tipoProdutos') !== undefined && sessionStorage.getItem('tipoProdutos') !== null) {
            var input = jQuery('#tipo_produtos');
            sessionStorage.getItem('tipoProdutos').split('!@!').forEach(function (elemento) {
                var split = elemento.split('#@#');

                addValorAlphaInput(input, split[0], split[1]);
            });
        }

        if ('<%= Apoio.parseBoolean(request.getParameter("chkEntregues")) %>' === 'true') {
            alteraCTeEntregues(true);
        }
    }


    function marcarTodos(){
        $("lbTotalSelecionado").innerHTML = "0.00";
        var i = 0;
        while ($("chk_"+i) != null){
            if (jQuery($("chk_" + i)).attr('data-somente-visualizar') !== 'true') {
                if ($("chkTodos").checked) {
                    $("chk_" + i).checked = true;
                    calculaSelecao($("chk_" + i), i);
                } else {
                    $("chk_" + i).checked = false;
                }
            }
            i++;
        }
    }

    function calculaSelecao(che, linha){
        if (che.checked && $('isLimiteFatura').checked && !$('chkUmaParaCada').checked && jQuery(che).attr('data-somente-visualizar') === 'true') {
            alert("Excede o limite estipulado!");

            che.checked = false;
        } else {
            var selecionado = parseFloat($("lbTotalSelecionado").innerHTML);

            if (che.checked) {
                selecionado += parseFloat($("valor_" + linha).value);
            } else {
                selecionado -= parseFloat($("valor_" + linha).value);
            }
            $("lbTotalSelecionado").innerHTML = formatoMoeda(selecionado);
        }
    }
    
    function clienteNuncaProtestar(slcProtesto){
        if(($("is_nunca_protestar").value == "t" || $("is_nunca_protestar").value == "true") && slcProtesto != "3" && $("geraBoleto").checked){
            alert("Atenção: Não está autorizado protestar boleto para o Cliente: " + $("con_rzs").value + "! \nCaso queira protestar boleto para esse cliente, vá em seu cadastro na Aba 'inf. financeiras' \ndesmaque a opção: Não protestar títulos/boletos desse cliente ");
            $("codProtesto").value = "3";
        }
    }
    
    function getPeriodicidade(){
        var filtrosSelecionados = "";
        for(var i = 0 ; i <= 4 ; i ++){
            if($("chkPeriodicidade_"+i).checked){
                filtrosSelecionados += $("chkPeriodicidade_"+i).value+",";
            } 
        }    
        $("periodicidade").value = filtrosSelecionados;
    }
    
    function loadCheckPeriodi(){
       var filtrosPeriodicidade = $("periodicidade").value;
       for(var c = 0; c <  filtrosPeriodicidade.split(",").length; c++){
           var opcao = filtrosPeriodicidade.split(",")[c];
            if(opcao =="d"){
               $("chkPeriodicidade_0").checked = true; 
            }else if(opcao == "s"){
                $("chkPeriodicidade_1").checked = true;  
            }else if(opcao == "c"){
                $("chkPeriodicidade_2").checked = true;  
            }else if(opcao == "q"){
                $("chkPeriodicidade_3").checked = true;  
            }else if(opcao == "m"){
                $("chkPeriodicidade_4").checked = true;  
            }
       }
    }
    function carregarFaturasFilial(){
        if (<%=mostrarFreteCifEmitidoPropriaFilialFobs%>) {
            $("chkFretesFilial").checked = true;
            $("chkFretesFilial").disabled = true;
        }else{
            
        }
    }

    function alteraCTeEntregues(checado) {
        if (checado == true || checado == "on") {
            $("divApenasComprovanteEntrega").style.visibility = "visible";
        } else {
            $("divApenasComprovanteEntrega").style.visibility = "hidden";
        }
    }
    
    function utilizarLimiteFatura(checkbox) {
        if (checkbox.checked) {
            alert('Para utilizar a opção "Valor limite para geração da fatura", deverá pesquisar novamente.');
        }
    }
    
    function mostrarOcultarLimiteFatura(checkbox) {
        if (checkbox.checked) {
            invisivel($('checkFaturaDiv'));
        } else {
            visivel($('checkFaturaDiv'));
        }
    }
</script>

<%@page import="java.text.DecimalFormat"%>
<%@page import="filial.BeanFilial"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@ page import="java.util.List" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> 
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />                   
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Faturar CTs/NFs em lote </title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
        <link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
    </head>
    <body onLoad="javascript:alteraCampo();loadCheckPeriodi();carregarFaturasFilial();"> 
        <form action="./cadfatura_lote.jsp?acao=salvar" id="formulario" name="formulario" method="post" target="pop" >
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") == null ? "0" : request.getParameter("idconsignatario"))%>">
            <input type="hidden" name="dia_vencimento" id="dia_vencimento" value="">
            <input type="hidden" name="mes" id="mes" value="">
            <input type="hidden" name="dataVencTemp" id="dataVencTemp" value="">
            <input type="hidden" id="is_nunca_protestar" name="is_nunca_protestar" value=""/>
            <input type="hidden" id="periodicidade" name="periodicidade" value="<%= (request.getParameter("periodicidade")!= null && !request.getParameter("periodicidade").equals("") ? request.getParameter("periodicidade") : "") %>" >
            <br>
            <table width="95%" align="center" class="bordaFina" >
                <tr>
                    <td width="619">
                        <div align="left">
                            <b>Faturar CTs/NFs em lote</b>
                        </div>
                    </td>
                    <td width="69">
                        <input name="volta" type="button" class="botoes" id="volta" value="Voltar para Consulta" onClick="javascript:tryRequestToServer(function(){voltar()});">
                    </td>
                </tr>
            </table>
            <br>
            <table width="95%" align="center" class="bordaFina" >
                <tr>
                    <td width="1%" class="TextoCampos">
                        <select name="tipoConsultaData" id="tipoConsultaData" onChange="alteraCampo();" class="inputtexto">
                            <option value="s.emissao_em" <%= (tipoData.equals("s.emissao_em") ? "selected" : "")%>>Emitidos entre </option>
                            <option value="ct.baixa_em" <%= (tipoData.equals("ct.baixa_em") ? "selected" : "")%>>Entregues entre </option>
                            <option value="ct.baixado_no_dia" <%= (tipoData.equals("ct.baixado_no_dia") ? "selected" : "")%>>Baixados entre </option>
                            <option value="m.nmanifesto" <%= (tipoData.equals("m.nmanifesto") ? "selected" : "")%>>Nº Manifesto </option>                            
                        </select>
                    </td>
                    <td width="8%" class="CelulaZebra2">
                        <div name="filtroData" id="filtroData">
                            <input name="dtinicial" type="text" class="fieldDate" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                   onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                            <label name="lbData" id="lbData">e</label>
                            <input name="dtfinal" type="text" id="dtfinal" class="fieldDate" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                   onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                        </div>

                        <div name="filtroCampo" id="filtroCampo">
                            <input name="valorConsulta" type="text" id="valorConsulta" style="font-size:8pt;display:none;" value="<%=(request.getParameter("manifesto") != null ? request.getParameter("manifesto") : "")%>" size="6" maxlength="6" class="fieldMin">
                            <input name="anoManifesto" type="text" id="anoManifesto" style="font-size:8pt;display:none;" value="<%=(request.getParameter("anoManifesto") != null ? request.getParameter("anoManifesto") : "")%>" size="4" maxlength="4" class="fieldMin">
                        </div>
                    </td>
                    <td width="12%" class="TextoCampos">Cliente:</td>
                    
                    <td  class="CelulaZebra2" width="20%" colspan="2">
                        <input name="con_rzs" type="text" id="con_rzs" size="32" readonly class="inputReadOnly8pt"
                               value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>">
                        <strong>
                            <input name="localiza_con" type="button" class="botoes" id="localiza_con" value="..." onClick="javascript:localizaconsignatario();">
                        </strong>
                        <img alt="" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaConsig();">
                        <%if (nivelUserClient > 0) {%>
                        <img alt="" src="img/page_edit.png" border="0" onClick="javascript:verCliente();"
                             title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">

                        <%}%>                    
                    </td>
                    
                    <td width="4%" class="CelulaZebra2" rowspan="6">
                        <div align="center">
                            <input name="pesquisa" type="button" class="botoes" id="pesquisa" value="Pesquisar" onClick="javascript:tryRequestToServer(function(){pesquisar()});">
                        </div>
                    </td>
                    
                </tr>
                <tr>
                    <td class="CelulaZebra2" width="133">
                        <div align="right">
                            Valores entre:
                        </div>
                    </td>
                    <td class="CelulaZebra2">
                        <input name="valor1" type="text" id="valor1" class="inputtexto" value="<%=(request.getParameter("valor1") != null ? request.getParameter("valor1") : "0.00")%>" 
                               size="9" maxlength="15" onBlur="javascript:seNaoFloatReset(this,'0.00');">
                        <label name="lbValor" id="lbData">e</label>
                        <input name="valor2" type="text" id="valor2" class="inputtexto" value="<%=(request.getParameter("valor2") != null ? request.getParameter("valor2") : "0.00")%>" 
                               size="9" maxlength="15" onBlur="javascript:seNaoFloatReset(this,'0.00');">
                    </td>                                        
                    <td class="TextoCampos">
                        Mostrar CTRCs na forma de pagto:</td>
                    <td class="CelulaZebra2" width="127" colspan="2">
                        <select name="tipoFpag" id="tipoFpag" class="inputtexto">
                            <option value="a" <%=(request.getParameter("tipoFpag") != null && request.getParameter("tipoFpag").equals("a") ? "selected" : "")%>>Ambas</option>
                            <option value="v" <%=(request.getParameter("tipoFpag") != null && request.getParameter("tipoFpag").equals("v") ? "selected" : "")%>>&Agrave; vista</option>
                            <option value="p" <%=(request.getParameter("tipoFpag") != null && request.getParameter("tipoFpag").equals("p") ? "selected" : "")%>>&Agrave; prazo</option>
                            <option value="c" <%=(request.getParameter("tipoFpag") != null && request.getParameter("tipoFpag").equals("c") ? "selected" : "")%>>Conta Corrente</option>
                        </select>
                    </td> 
                                       
                </tr>
                <tr>                  
                    <td width="207" class="CelulaZebra2" aling="left">
                        <div align="right">
                            Apenas a Filial:
                        </div>
                    </td>
                    <td class="TextoCampos">
                        <div align="left">
                        <select name="idFilial" id="idFilial" style="width: 80px" class="inputtexto">
                            <option value="0">Todas</option>
                                <%BeanFilial fil = new BeanFilial();
                                    ResultSet rsFil = fil.all(Apoio.getUsuario(request).getConexao());%>
                                <%  while (rsFil.next()) {%>
                                    <option  
                                        
                                        value="<%=rsFil.getString("idfilial")%>" <%= (request.getParameter("idFilial") != null ? (Apoio.parseInt(request.getParameter("idFilial")) == rsFil.getInt("idFilial") ? "selected" : "") 
                                                : (Apoio.getUsuario(request).getFilial().getIdfilial() == rsFil.getInt("idfilial") ? "selected" : "")) %> > 
                                        
                                        <%=rsFil.getString("abreviatura")%>
                                    </option>
                                <%}%>          
                        </select>
                        </div>
                    </td>
                    <td class="TextoCampos">
                        <table width="100%" border="0">
                            <tbody id="cid"></tbody>
                            </table>
                        <div align="center">
                            <input name="chkEntregues" type="checkbox" id="chkEntregues" value="checkbox" <%=request.getParameter("chkEntregues") == null ? "" : Boolean.parseBoolean(request.getParameter("chkEntregues")) ? "checked" : ""%>
                                   onclick="alteraCTeEntregues(this.checked)" >
                            <label for="chkEntregues">Mostrar apenas CT-e(s) entregues.</label>
                        </div>                                   
                    </td>
                    <td class="TextoCampos" width="11%">
                        <div align="left" id="divApenasComprovanteEntrega" style="visibility: hidden;">
                            <input name="chkApenasComprovanteEntrega" type="checkbox" id="chkApenasComprovanteEntrega"
                                   value="checkbox" <%=request.getParameter("chkApenasComprovanteEntrega") == null ? "" : Apoio.parseBoolean(request.getParameter("chkApenasComprovanteEntrega")) ? "checked" : ""%>>
                            <label for="chkApenasComprovanteEntrega">Mostrar apenas com comprovante de entrega</label>
                        </div>
                    </td>
                    <td class="TextoCampos" colspan="1" >
                        <div align="center">
                            <input name="chkUmaParaCada" type="checkbox" id="chkUmaParaCada" value="checkbox" <%=request.getParameter("chkUmaParaCada") == null ? "" : Boolean.parseBoolean(request.getParameter("chkUmaParaCada")) ? "checked" : ""%>
                                   onClick="mostrarOcultarLimiteFatura(this);">
                            Gerar uma fatura para cada CT/NFS.
                        </div>
                    </td>            
                  
                </tr>                
                <tr>
                    <td class="TextoCampos">
                        Tipo:
                    </td>
                    <td class="CelulaZebra2">
                        <select name="tipoConhecimento" id="tipoConhecimento" style="width:120px;" class="inputtexto">
                            <option value="" <%= (tiposConhecimentos.equals("") ? "selected" : "")%>>Todos</option>
                            <option value="n" <%= (tiposConhecimentos.equals("n") ? "selected" : "")%>>Normal</option>
                            <option value="l"<%= (tiposConhecimentos.equals("l") ? "selected" : "")%>>Entrega Local (Cobrança)</option>
                            <option value="i" <%= (tiposConhecimentos.equals("i") ? "selected" : "")%>>Diárias</option>
                            <option value="p"<%= (tiposConhecimentos.equals("p") ? "selected" : "")%>>Pallets</option>
                            <option value="c" <%= (tiposConhecimentos.equals("c") ? "selected" : "")%>>Complementar</option>
                            <option value="r"<%= (tiposConhecimentos.equals("r") ? "selected" : "")%>>Reentrega</option>
                            <option value="d" <%= (tiposConhecimentos.equals("d") ? "selected" : "")%>>Devolução</option>
                            <option value="b"<%= (tiposConhecimentos.equals("b") ? "selected" : "")%>>Cortesia</option>
                            <option value="s" <%= (tiposConhecimentos.equals("s") ? "selected" : "")%>>Substituição</option>
                            <option value="t" <%= (tiposConhecimentos.equals("t") ? "selected" : "")%> id="subs" name="subs" style="display: none">Substituído</option>
                        </select>
                    </td>
                        <td class="TextoCampos">
                        <div align="center">
                            Apenas a Série:
                            <input name="serie" type="text" class="fieldMin" id="serie" style="font-size:8pt;" value="<%=(request.getParameter("serie") != null ? request.getParameter("serie") : "")%>" size="3" maxlength="3">
                        </div>
                    </td>
                    <td class="TextoCampos" colspan="2">
                        <div align="center">
                            <select name="tipoCobranca" id="tipoCobranca" class="inputtexto" style="width: 130px;">
                                <option value="a" <%=(request.getParameter("tipoCobranca") != null && request.getParameter("tipoCobranca").equals("a") ? "selected" : "")%>>Mostrar Todas</option>
                                <option value="c" <%=(request.getParameter("tipoCobranca") != null && request.getParameter("tipoCobranca").equals("c") ? "selected" : "")%>>Em Carteira</option>
                                <option value="b" <%=(request.getParameter("tipoCobranca") != null && request.getParameter("tipoCobranca").equals("b") ? "selected" : "")%>>Em Banco</option>
                            </select>                  
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Apenas Fretes:</td>
                        <td class="CelulaZebra2">
                            <input type="checkbox" name="tipoPagadorCIF" id="tipoPagadorCIF" <%=request.getParameter("tipoPagadorCIF") == null ? "checked" : Boolean.parseBoolean(request.getParameter("tipoPagadorCIF")) ? "checked" : ""%>>CIF
                            <input type="checkbox" name="tipoPagadorFOB" id="tipoPagadorFOB" <%=request.getParameter("tipoPagadorFOB") == null ? "checked" : Boolean.parseBoolean(request.getParameter("tipoPagadorFOB")) ? "checked" : ""%>>FOB
                            <input type="checkbox" name="tipoPagadorCON" id="tipoPagadorCON" <%=request.getParameter("tipoPagadorCON") == null ? "checked" : Boolean.parseBoolean(request.getParameter("tipoPagadorCON")) ? "checked" : ""%>>CON
                            <input type="checkbox" name="tipoPagadorRED" id="tipoPagadorRED" <%=request.getParameter("tipoPagadorRED") == null ? "checked" : Boolean.parseBoolean(request.getParameter("tipoPagadorRED")) ? "checked" : ""%>>RED
                        </td>
                         <td class="TextoCampos" style="text-align: center">
                             <input type="checkbox" id="chkCteManifestados" name="chkCteManifestados" value="checkbox" <%= Apoio.parseBoolean(request.getParameter("chkCteManifestados")) == false ? "" : "checked" %> > Mostrar Apenas CT-e(s) com manifesto
                        </td>
<!--                        <td class="CelulaZebra2">
                            <input type="checkbox" id="chkPeriodicidade_1" name="chkPeriodicidade_1" value="d" <%= request.getParameter("chkPeriodicidade_1") != null && request.getParameter("chkPeriodicidade_1").equals("d") ? "checked" : "" %> onclick="javascript: getPeriodicidade();"> Diário
                            <input type="checkbox" id="chkPeriodicidade_2" name="chkPeriodicidade_2" value="s" <%= request.getParameter("chkPeriodicidade_2") != null && request.getParameter("chkPeriodicidade_2").equals("s") ? "checked" : "" %> onclick="javascript: getPeriodicidade();"> Semanal
                            <input type="checkbox" id="chkPeriodicidade_3" name="chkPeriodicidade_3" value="c" <%= request.getParameter("chkPeriodicidade_3") != null && request.getParameter("chkPeriodicidade_3").equals("c") ? "checked" : "" %> onclick="javascript: getPeriodicidade();"> Dicêndio
                            <input type="checkbox" id="chkPeriodicidade_4" name="chkPeriodicidade_4" value="q" <%= request.getParameter("chkPeriodicidade_4") != null && request.getParameter("chkPeriodicidade_4").equals("q") ? "checked" : "" %> onclick="javascript: getPeriodicidade();"> Quizenal
                            <input type="checkbox" id="chkPeriodicidade_5" name="chkPeriodicidade_5" value="m" <%= request.getParameter("chkPeriodicidade_5") != null && request.getParameter("chkPeriodicidade_5").equals("m") ? "checked" : "" %> onclick="javascript: getPeriodicidade();"> Mensal
                        </td>-->
                        <td class="TextoCampos" style="text-align: center" colspan="2"><label>Periodicidade: </label>
                            <input type="checkbox" id="chkPeriodicidade_0" name="chkPeriodicidade_0" value="d" onclick="javascript: getPeriodicidade();"> Diário
                            <input type="checkbox" id="chkPeriodicidade_1" name="chkPeriodicidade_1" value="s" onclick="javascript: getPeriodicidade();"> Semanal
                            <input type="checkbox" id="chkPeriodicidade_2" name="chkPeriodicidade_2" value="c" onclick="javascript: getPeriodicidade();"> Dicêndio
                            <input type="checkbox" id="chkPeriodicidade_3" name="chkPeriodicidade_3" value="q" onclick="javascript: getPeriodicidade();"> Quizenal
                            <input type="checkbox" id="chkPeriodicidade_4" name="chkPeriodicidade_4" value="m" onclick="javascript: getPeriodicidade();"> Mensal
                        </td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="6"><div align="left">
                            <input type="radio" id="optionNenhum" name="filtroCidade" value="0" <%=request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("0") ? "checked" : ""%>> Nenhum 
                    </div></td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="6"><div align="left">
                            <input type="radio" id="chkFretesFilial" name="filtroCidade" value="1" <%=request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("1") ? "checked" : ""%>> Mostrar apenas fretes CIF emitidos pela filial e fretes FOB destinados a filial: 
                        <select name="idFilialUsuario" id="idFilialUsuario" class="inputtexto">
                            <%BeanFilial fl1 = new BeanFilial();
                                ResultSet rsFl1 = fl1.all(Apoio.getUsuario(request).getConexao());%>
                            <%while (rsFl1.next()) {%>
                            <option value="<%=rsFl1.getString("idfilial")%>" <%=((request.getParameter("idFilialUsuario") == null ? Apoio.getUsuario(request).getFilial().getIdfilial() : Apoio.parseInt(request.getParameter("idFilialUsuario"))) == rsFl1.getInt("idfilial") ? "selected" : "")%> ><%=rsFl1.getString("abreviatura")%></option>
                            <%}%>
                        </select>
                    </div></td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="6"><div align="left">
                            <input type="radio" id="chkFretesFilialDestino" name="filtroCidade" value="2" <%=request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("2") ? "checked" : ""%>> Mostrar apenas fretes onde a responsabilidade da entrega seja da filial: 
                        <select name="idFilialDestino" id="idFilialDestino" class="inputtexto">
                            <%BeanFilial fl2 = new BeanFilial();
                                ResultSet rsFl2 = fl2.all(Apoio.getUsuario(request).getConexao());%>
                            <%while (rsFl2.next()) {%>
                            <option value="<%=rsFl2.getString("idfilial")%>" <%=((request.getParameter("idFilialDestino") == null ? Apoio.getUsuario(request).getFilial().getIdfilial() : Apoio.parseInt(request.getParameter("idFilialDestino"))) == rsFl2.getInt("idfilial") ? "selected" : "")%> ><%=rsFl2.getString("abreviatura")%></option>
                            <%}%>
                        </select>
                    </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" colspan="1">
                        <div align="right">
                            <label for="tipo_produtos">Tipo de Produto:</label>
                        </div>
                    </td>
                    <td class="CelulaZebra2" colspan="5">
                        <div align="left">
                            <input name="tipo_produtos" type="text" id="tipo_produtos" class="inputReadOnly8pt" value="" readonly>
                            <input name="localizar_tipo_produtos" type="button" class="botoes" id="localizar_tipo_produtos" value="..." onClick="controlador.acao('abrirLocalizar','localizarTipoProduto');">
                            <img src="img/borracha.gif" name="limpar_tipo_produto" border="0" align="absbottom" class="imagemLink" id="limpar_tipo_produto" title="Limpar Tipo de Produtos" onClick="removerValorInput('tipo_produtos')">
                        </div>
                    </td>
                </tr>
            </table>
            <table width="95%" align="center" cellspacing="1" class="bordaFina" id="tabelaCTRCs">
                <tr>
                    <td width="2%" class="tabela">
                        <div align="center">
                            <input type="checkbox" id="chkTodos" name="chkTodos" value="chkTodos" onClick="javascript:marcarTodos();">
                        </div>
                    </td>
                    <td colspan="2" class="tabela">Marcar Todos</td>
                    <td colspan="3" class="tabela">
                        <div id="checkFaturaDiv" <%= Boolean.parseBoolean(request.getParameter("chkUmaParaCada")) ? "style=\"display: none;\"" : "" %>>
                            <input type="checkbox"
                                   id="isLimiteFatura" value="chkTodos" onClick="utilizarLimiteFatura(this);"
                                <%=Apoio.parseBoolean(request.getParameter("isLimiteFatura")) ? "checked" : ""%>>
                            <label for="isLimiteFatura">Valor limite para geração da fatura:</label>
                            <input type="text" name="limiteFatura" id="limiteFatura" size="8"
                                   value="<%=new DecimalFormat("#,##0.00").format(Apoio.parseDouble(request.getParameter("limiteFatura")))%>"
                                   class="inputtexto" onblur="utilizarLimiteFatura()" onkeypress="mascara(this, reais, 2)">
                        </div>
                    </td>
                    <td colspan="2" class="tabela">
                        <div align="right">Repetir Vencimento:</div>
                    </td>
                    <td class="tabela">
                        <input name="dtvencimento" type="text" class="fieldDate" id="dtvencimento" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtvencimento") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                               onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;"
                             onClick="javascript:atribuiValores($('dtvencimento'));">
                    </td>
                </tr>
                <tr class="tabela">
                    <td width="2%"></td>
                    <td width="2%"></td>
                    <td width="37%">Nome</td>
                    <td width="15%">CNPJ</td>
                    <td width="3%"><div align="center">QTD</div></td>
                    <td width="10%"><div align="right">Valor</div></td>
                    <td width="10%">Desconto</td>
                    <td width="9%">Total</td>
                    <td width="11%">Vencimento</td>
                </tr>
                <% //variaveis da paginacao
                    // se conseguiu consultar
                    int qtdFaturas = 0;
                    double totalFaturas = 0;
                    if (acao.equals("consultar")) {
                        if (conFat.visualizarCtrcsFaturaLote()) {
                            ResultSet rs = conFat.getResultado();

                            //Condição para verificar se vai trazer todas as filiais ou não.
                            //caso seja todas as filiais, não existe no ResultSet, foi retirado da sql, por isso é necessário fazer essa validação,
                            //caso existe entra no entra no if de existeFilial == true.
                            boolean existeFilial = false;
                            ResultSetMetaData rsSet = rs.getMetaData();
                            for (int qtdColunas = 1; qtdColunas <= rsSet.getColumnCount(); qtdColunas++) {
                                if (rsSet.getColumnName(qtdColunas).equals("idfilial")) {
                                    existeFilial = true;

                                    break;
                                }
                            }

                            List<BeanFaturaCtrcLote> beanFaturaCtrcLotes = conFat.obterBeanFaturaCtrcLote(rs, existeFilial);
                            
                            if (isLimiteFatura && !conFat.isUmaFaturaPorCT()) {
                                double limiteFatura = Apoio.parseDouble(request.getParameter("limiteFatura"));
                                beanFaturaCtrcLotes = conFat.agruparPorLimiteFatura(beanFaturaCtrcLotes, limiteFatura);
                            }

                            qtdFaturas = beanFaturaCtrcLotes.size();
                            for (BeanFaturaCtrcLote beanFaturaCtrcLote : beanFaturaCtrcLotes) {
                                totalFaturas += beanFaturaCtrcLote.getValorTotal();
                            }

                            for (int linha = 0; linha < beanFaturaCtrcLotes.size(); linha++) {
                                BeanFaturaCtrcLote beanFaturaCtrcLote = beanFaturaCtrcLotes.get(linha);
                %>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                    <td>
                        <input name="<%="chk_" + linha%>" type="checkbox" id="<%="chk_" + linha%>" value="<%=beanFaturaCtrcLote.getId()%>" onClick="calculaSelecao(this,<%=linha%>)" data-somente-visualizar="<%= beanFaturaCtrcLote.isSomenteVisualizar() %>">
                        <input name="<%="id_" + linha%>" type="hidden" id="<%="id_" + linha%>" value="<%=beanFaturaCtrcLote.getId()%>">
                    </td>
                    <%if(existeFilial) {%>
                    <td>
                        <img src="img/plus.jpg" id="plus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>"
                             name="plus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>" title="Mostrar duplicatas"
                             class="imagemLink" align="right" 
                             onclick="javascript: viewDetalhes('<%=beanFaturaCtrcLote.getConsignatarioId()%>','<%=beanFaturaCtrcLote.getId()%>','<%=beanFaturaCtrcLote.getFilialId()%>');">
                        <img src="img/minus.jpg" id="minus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>"
                             name="minus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>" title="Mostrar duplicatas"
                             class="imagemLink" align="right" style="display:none"
                             onclick="javascript: viewDetalhes('<%=beanFaturaCtrcLote.getConsignatarioId()%>','<%=beanFaturaCtrcLote.getId()%>','<%=beanFaturaCtrcLote.getFilialId()%>');">
                        <input type="hidden" id="<%="idconsignatario_" + linha%>" name="<%="idconsignatario_" + linha%>" value="<%=beanFaturaCtrcLote.getConsignatarioId()%>">
                        <input type="hidden" id="<%="clienteProtestar_" +linha%>" name="<%="clienteProtestar_" +linha%>" value="<%=beanFaturaCtrcLote.isNuncaProtestar()%>">
                    </td>
                    <%}else{%>
                    <td>
                        <img src="img/plus.jpg" id="plus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>"
                             name="plus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>" title="Mostrar duplicatas"
                             class="imagemLink" align="right" 
                             onclick="javascript: viewDetalhes('<%=beanFaturaCtrcLote.getConsignatarioId()%>','<%=beanFaturaCtrcLote.getId()%>','0');">
                        <img src="img/minus.jpg" id="minus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>"
                             name="minus_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>" title="Mostrar duplicatas"
                             class="imagemLink" align="right" style="display:none"
                             onclick="javascript: viewDetalhes('<%=beanFaturaCtrcLote.getConsignatarioId()%>','<%=beanFaturaCtrcLote.getId()%>','0');">
                        <input type="hidden" id="<%="idconsignatario_" + linha%>" name="<%="idconsignatario_" + linha%>" value="<%=beanFaturaCtrcLote.getConsignatarioId()%>">
                    </td>                    
                    <%}%>
                    <td><%=(beanFaturaCtrcLote.getCte().equals("")? "" : "CT-e:" + beanFaturaCtrcLote.getCte() + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;") + beanFaturaCtrcLote.getConsignatarioNome()%>
                    <input type="hidden" id="<%="rzsCli_" + linha%>" name="<%="rzsCli_" + linha%>" value="<%=beanFaturaCtrcLote.getConsignatarioNome()%>">
                    </td>
                    <td><%=beanFaturaCtrcLote.getConsignatarioCnpj()%> <input type="hidden" id="<%="tppgto_" + linha%>" name="<%="tppgto_" + linha%>" value="<%=beanFaturaCtrcLote.getTipoPagamento()%>"></td>
                    
                    <td><div align="right"><%=beanFaturaCtrcLote.getQuantidade()%></div></td>
                    <td><div align="right"><%=beanFaturaCtrcLote.getValorTotalString()%></div>
                        <input type="hidden" name="<%="valor_" + linha%>" id="<%="valor_" + linha%>"
                               value="<%=beanFaturaCtrcLote.getValorTotalString()%>">
                        <input type="hidden" name="<%="idConsig_" + linha%>" id="<%="idConsig_" + linha%>"
                               value="<%=beanFaturaCtrcLote.getConsignatarioId()%>">
                    </td>
                    <td><input name="<%="desconto_" + linha%>" type="text" class="inputtexto" id="<%="desconto_" + linha%>"
                               value="0.00"  maxlength="10" size="7" onChange="seNaoFloatReset(this,'0.00');totalValor('<%=linha%>')"></td>
                    <td><input name="<%="total_" + linha%>" type="text" id="<%="total_" + linha%>" class="inputReadOnly"
                               readonly value="0.00" size="10" maxlength="10"></td>
                    <td>
                        <input name="<%="vencimento_" + linha%>" type="text" id="<%="vencimento_" + linha%>" size="10" maxlength="10" value="" onBlur="alertInvalidDate(this)" class="fieldDate" >
                        <input name="<%="novo_vencimento_" + linha%>" type="hidden" id="<%="novo_vencimento_" + linha%>" size="10" maxlength="10" value="<%= Apoio.getFormatData(beanFaturaCtrcLote.getNovoVencimento()) %>" onBlur="alertInvalidDate(this)" class="fieldDate" >
                        
                        <input type="hidden" id="<%="segunda_" + linha%>" name="<%="segunda_" + linha%>" value="<%=beanFaturaCtrcLote.isSegunda()%>">
                        <input type="hidden" id="<%="terca_" + linha%>" name="<%="terca_" + linha%>" value="<%=beanFaturaCtrcLote.isTerca()%>">
                        <input type="hidden" id="<%="quarta_" + linha%>" name="<%="quarta_" + linha%>" value="<%=beanFaturaCtrcLote.isQuarta()%>">
                        <input type="hidden" id="<%="quinta_" + linha%>" name="<%="quinta_" + linha%>" value="<%=beanFaturaCtrcLote.isQuinta()%>">
                        <input type="hidden" id="<%="sexta_" + linha%>" name="<%="sexta_" + linha%>" value="<%=beanFaturaCtrcLote.isSexta()%>">
                        <input type="hidden" id="<%="sabado_" + linha%>" name="<%="sabado_" + linha%>" value="<%=beanFaturaCtrcLote.isSabado()%>">
                        <input type="hidden" id="<%="domingo_" + linha%>" name="<%="domingo_" + linha%>" value="<%=beanFaturaCtrcLote.isDomingo()%>">
                        
                        <input type="hidden" id="<%="condicaoPgto_" + linha%>" name="<%="condicaoPgto_" + linha%>" value="<%=beanFaturaCtrcLote.getCondicaoPagamento()%>">
                        <input type="hidden" id="<%="tipoDiasVencimento_" + linha%>" name="<%="tipoDiasVencimento_" + linha%>" value="<%=beanFaturaCtrcLote.getTipoDiasVencimento()%>">
                        <script language="javascript" type="text/javascript" >
                            qtdResultados++;
                            calculaVencimento("<%=beanFaturaCtrcLote.getCondicaoPagamento()%>","<%=linha%>","<%=beanFaturaCtrcLote.getTipoDiasVencimento()%>", null);
                            totalValor("<%=linha%>");
                        </script>
                    </td>
                </tr>
                <tr style="display:none" id="trfat_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>" name="trfat_<%=beanFaturaCtrcLote.getConsignatarioId()+"_"+beanFaturaCtrcLote.getId()%>">
                    <td rowspan="1" class='CelulaZebra1'></td>
                    <td rowspan="1" colspan="12">--</td>
                </tr>   
                <%
                            }
                        }
                    }
                %>
                <tr class="tabela">
                    <td></td>
                    <td></td>
                    <td></td>
                    <td colspan="2" align="right">Total:</td>
                    <!--<td></td>-->
                    <td align="right"><%=new DecimalFormat("#,##0.00").format(totalFaturas)%></td>
                    <!--<td></td>-->
                    <td colspan="2" align="right">Total Selecionado:</td>
                    <td><label id="lbTotalSelecionado">0.00</label></td>
                </tr>
                <tr class="tabela">
                    <td height="17" colspan="9" align="center">Dados do pagamento</td>
                </tr>
                <tr>
                    <td height="17" colspan="9" align="center">
                        <table width="100%" border="0" class="bordaFina">
                            <tr>
                                <td width="19%" class="TextoCampos">Conta para dep&oacute;sito:</td>
                                <td colspan="2" class="CelulaZebra2">
                                    <select name="conta" id="conta" class="inputtexto" onChange="valoresDefaultBoleto(this.value)">
                                        <%

                                            //Carregando todas as contas cadastradas
                                            BeanConsultaConta conta = new BeanConsultaConta();
                                            conta.setConexao(Apoio.getUsuario(request).getConexao());
                                            conta.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                            ResultSet rsconta = conta.getResultado();

                                            //carregando as contas num vetor
%>
                                        <option value="0">N&atilde;o informar</option>
                                        <%
                                            while (rsconta.next()) {%>
                                        <option value="<%=rsconta.getString("idconta")%>" > <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%> </option>
                                        <%}%>
                                    </select>
                                </td>
                                <td width="11%" class="TextoCampos"></td>
                                <td width="15%" class="TextoCampos">Emiss&atilde;o:</td>
                                <td width="30%" class="CelulaZebra2">
                                    <strong>
                                        <input name="dtemissao" type="text" id="dtemissao" value="<%= Apoio.getDataAtual()%>" size="9" maxlength="10" class="fieldDate"
                                               onBlur="alertInvalidDate(this);getDataVencimento();" onKeyPress="fmtDate(this, event)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" />
                                    </strong>
                                </td>
                                <%
                                        conta.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                        rsconta = conta.getResultado();
                                        while (rsconta.next()) {%>
                            <input type="hidden" name="hdInstrucao1_<%=rsconta.getString("idconta")%>" id="hdInstrucao1_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao1")%>">
                            <input type="hidden" name="hdInstrucao2_<%=rsconta.getString("idconta")%>" id="hdInstrucao2_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao2")%>">
                            <input type="hidden" name="hdInstrucao3_<%=rsconta.getString("idconta")%>" id="hdInstrucao3_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao3")%>">
                            <input type="hidden" name="hdInstrucao4_<%=rsconta.getString("idconta")%>" id="hdInstrucao4_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao4")%>">
                            <input type="hidden" name="hdInstrucao5_<%=rsconta.getString("idconta")%>" id="hdInstrucao5_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao5")%>">
                            <input type="hidden" name="hdCodProtesto_<%=rsconta.getString("idconta")%>" id="hdCodProtesto_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("cod_protesto")%>">
                            <input type="hidden" name="hdDiasProtesto_<%=rsconta.getString("idconta")%>" id="hdDiasProtesto_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("dias_protesto")%>">
                            <input type="hidden" name="hdDiasDevolucao_<%=rsconta.getString("idconta")%>" id="hdDiasDevolucao_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("dias_devolucao")%>">
                            <input type="hidden" name="hdCodDevolucao_<%=rsconta.getString("idconta")%>" id="hdCodDevolucao_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("cod_devolucao")%>">
                            <input type="hidden" name="hdJuros_<%=rsconta.getString("idconta")%>" id="hdJuros_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("juros_acrescimo")%>">
                            <input type="hidden" name="hdMulta_<%=rsconta.getString("idconta")%>" id="hdMulta_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("multa")%>">
                            <%}%>
                            </tr>
                            <tr>
                                <td colspan="4" class="TextoCampos">Ap&oacute;s o vencimento aplicar multa de
                                    <input name="multa" type="text" id="multa"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0" size="4" maxlength="12" class="inputtexto">
                                    % e juros de
                                    <input name="juros" type="text" id="juros"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0" size="4" maxlength="12" class="inputtexto">
                                    % ao m&ecirc;s.</td>
                                <td class="CelulaZebra2"></td>
                                <td class="CelulaZebra2"></td>
                            </tr>
                            <tr>
                                <td colspan="2" class="TextoCampos">Filial respons&aacute;vel pela cobran&ccedil;a: </td>
                                <td colspan="2" class="CelulaZebra2">
                                    <select name="filialCobrancaId" id="filialCobrancaId" class="inputtexto">
                                        <%BeanFilial fl = new BeanFilial();
                                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                                        <%while (rsFl.next()) {%>
                                        <option value="<%=rsFl.getString("idfilial")%>" <%=(Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : "")%> ><%=rsFl.getString("abreviatura")%></option>
                                        <%}%>
                                    </select>
                                </td>
                                <td class="TextoCampos">Situa&ccedil;&atilde;o:</td>
                                <td class="CelulaZebra2">
                                    <label>
                                        <select name="situacao" id="situacao" class="inputtexto">
                                            <option value="NM" selected>Normal</option>
                                            <option value="CA">Cancelada</option>
                                            <option value="CO">Cortesia</option>
                                            <option value="TC">Cart&oacute;rio</option>
                                            <option value="DT">Descontada</option>
                                            <option value="DE">Devedora</option>
                                        </select>
                                    </label>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Observa&ccedil;&atilde;o:</td>
                                <td colspan="5" class="CelulaZebra2">
                                    <textarea name="observacao" class="inputtexto" cols="70" rows="4" id="observacao"></textarea>                                        </td>
                            </tr>
                            <tr>
                                <td align="center" colspan="6" class="CelulaZebra2">
                                    <div align="center">
                                        Gerar Boleto <input type="checkbox" name="geraBoleto" id="geraBoleto" onClick="controlaTrBoleto(this.checked);clienteNuncaProtestar($('codProtesto').value);" >
                                    </div>                                                                    
                                </td>
                            </tr>
                            <tr id="trBoleto" style="display:none">
                                <td colspan="6">
                                    <table class="bordaFina" width="100%">
                                        <tr>
                                            <td colspan="2">
                                                <table class="bordaFina" width="100%">
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos">Nosso N°:</td>
                                                        <td class="CelulaZebra2">
                                                            <input type="text" name="nossoNumero" id="nossoNumero" class="inputReadOnly" readonly  value="0" size="10">
                                                        </td>
                                                        <td align="center" >
                                                            <input type="checkbox" name="aceite" id="aceite" value="aceite" >
                                                            <label for="aceite">Aceite</label>
                                                        </td>
                                                        <td class="TextoCampos">Esp&eacute;cie Doc.:</td>
                                                        <td class="CelulaZebra2">
                                                            <select name="especieBoleto" id="especieBoleto" class="inputtexto">
                                                                <option value="DM" selected>DM</option>
                                                                <option value="DS" >DS</option>
                                                            </select>
                                                        </td>
                                                    </tr>
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos">Protesto</td>
                                                        <td class="CelulaZebra2">
                                                            <select name="codProtesto" id="codProtesto" class="inputtexto" style="width: 247px" onclick="clienteNuncaProtestar(this.value);">
                                                                <option value="1" >Protestar dias corridos</option>
                                                                <option value="2" >Protestar dias &uacute;teis</option>
                                                                <option value="3" >Não protestar</option>
                                                                <option value="4" >Protestar fim falimentar - Dias &uacute;teis</option>
                                                                <option value="5" >Protestar fim falimentar - Dias corridos</option>
                                                                <option value="9" >Cancelamento protesto autom&aacute;tico</option>
                                                            </select>
                                                        </td>
                                                        <td class="TextoCampos">Dias protesto</td>
                                                        <td class="CelulaZebra2" colspan="2">
                                                            <input type="text" class="inputtexto" size="7" id="diasProtesto" onChange="seNaoIntReset(this, '0')" name="diasProtesto" value="0">
                                                        </td>
                                                    </tr>
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos">Devolução</td>

                                                        <td class="CelulaZebra2">
                                                            <select name="codDevolucao" id="codDevolucao" class="inputtexto" style="width: 80px" >
                                                                <option value="1">SIM</option>
                                                                <option value="2">NÃO</option>
                                                            </select>
                                                        </td>
                                                        <td class="TextoCampos" >
                                                            Dias Devolução
                                                        </td>
                                                        <td class="CelulaZebra2">
                                                            <input type="text" class="inputtexto" size="7" id="diasDevolucao" onChange="seNaoIntReset(this, '0')" name="diasDevolucao" value="0">
                                                        </td>
                                                        <td class="TextoCampos" >
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instru&ccedil;&atilde;o 1:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao1" id="instrucao1" maxlength="60" class="inputTexto" value="" size="50">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instru&ccedil;&atilde;o 2:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao2" id="instrucao2" maxlength="60" class="inputTexto" value="" size="50">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instru&ccedil;&atilde;o 3:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao3" id="instrucao3" maxlength="60" class="inputTexto" value="" size="50">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instru&ccedil;&atilde;o 4:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao4" id="instrucao4" maxlength="60" class="inputTexto" value="" size="50">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instru&ccedil;&atilde;o 5:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao5" id="instrucao5" maxlength="60" class="inputTexto" value="" size="50">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>

                    </td>
                </tr>
                <tr class="<%=((qtdFaturas % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                    <td colspan="9">
                        <div align="center">
                            <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva(<%=qtdFaturas%>)});">
                            <input type="hidden" name="count" id="count" value="<%=qtdFaturas%>">
                        </div>
                    </td>
                </tr>
            </table>
        </form>
        <div class="localiza">
            <iframe id="localizarTipoProduto" input="tipo_produtos" name="localizarTipoProduto" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarTipoProduto" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="cobre-tudo"></div>
        <script>
            jQuery(document).ready(function() {
                jQuery('#tipo_produtos').inputMultiploGw({
                    readOnly: 'true',
                    is_old: true
                });
            });

            jQuery('#tabelaCTRCs').on('click', '.anexoCTRC', function() {
                var elemento = jQuery(this);

                window.open('./ImagemControlador?acao=carregar&idconhecimento=' + elemento.attr('data-id')
                    + '&numero=' + elemento.attr('data-numero') + '&data=' + elemento.attr('data-data') + '&filial=' + elemento.attr('data-filial-id')
                    + '&visualizar=true',
                    'imagensConhecimento', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            });
        </script>
    </body>
</html>
