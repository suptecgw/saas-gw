<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="nucleo.importacao.walmart.contasReceber.RegistroArquivo"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.Locale"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         mov_banco.conta.*,
         conhecimento.duplicata.*,
         java.text.*,
         nucleo.Apoio,
         filial.BeanFilial,
         nucleo.BeanLocaliza" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}"></script>
<%
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("bxreceber") : 0);
    int nivelUserConciliacao = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("conbancaria") : 0);
    int nivelUserCtrc = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelUserCtrcFl = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelUserSale = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();

    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {  
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    String fatura = (request.getParameter("fatura") == null ? "" : request.getParameter("fatura"));
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    BeanConsultaFatura dupls = null;
//    Collection<BeanConsultaFatura> faturaImportacaoArquivo = null;
    String faturaImportacaoArquivo = null;
    Collection<RegistroArquivo> valorImportacaoDesconto = null;
    String idCliente = null;
    String razaoSocialCliente = null;
    BeanDuplicata duplicata = null;
    BeanAlteraDuplicata altDupls = null;
    BeanConfiguracao cfg = null;
    cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();
    Collection<RegistroArquivo> listaDescontoFatura = null;
    listaDescontoFatura = (Collection) request.getSession().getAttribute("listaDescontoFatura");
    Locale localFmtValor = new Locale("pt", "BR"); 
    DecimalFormat fmtValor = new DecimalFormat("#,##0.00",new DecimalFormatSymbols(localFmtValor));
    BeanCteArquivoLasa beanCteArquivoLasa = null;
    
    if (!acao.equals("iniciar")) {
        dupls = new BeanConsultaFatura();
        dupls.setConexao(Apoio.getUsuario(request).getConexao());
        duplicata = new BeanDuplicata();
        altDupls = new BeanAlteraDuplicata();
        altDupls.setConexao(Apoio.getUsuario(request).getConexao());
        altDupls.setExecutor(Apoio.getUsuario(request));
    }
    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("consultar")){
        String filtroSituacao = "";
        if(Apoio.parseBoolean(request.getParameter("filtrarSituacao"))){
             filtroSituacao = request.getParameter("filtrosSituacao");
        }
     
        if (!fatura.equals("")) {
            dupls.setTipoConsulta(0);
            dupls.setValorDaConsulta(fatura + "/" + request.getParameter("anofatura"));

        } else if (request.getParameter("documento") != null) {
            
            dupls.setValorDaConsulta(request.getParameter("documento"));
            dupls.setIdConsignatario(Apoio.parseInt(request.getParameter("idconsignatario")));
            dupls.setTipoData(request.getParameter("tipoData") == null ? "vence_em" : request.getParameter("tipoData"));
            dupls.setBaixado(request.getParameter("baixado"));
            dupls.setDataVenc1(request.getParameter("dtinicial"));
            dupls.setDataVenc2(request.getParameter("dtfinal"));
            dupls.setFilial(request.getParameter("idfilial"));
            dupls.setGrupo_id(Integer.parseInt(request.getParameter("grupo_id")));
            dupls.setValor1((request.getParameter("valor1") == null ? 0 : Double.parseDouble(request.getParameter("valor1"))));
            dupls.setValor2((request.getParameter("valor2") == null ? 0 : Double.parseDouble(request.getParameter("valor2"))));
            dupls.setTitulo(request.getParameter("titulo") == null ? "" : request.getParameter("titulo").equals("todos") ? "" : request.getParameter("titulo"));
            if(filtroSituacao != ""){
                dupls.setSituacao(filtroSituacao);
            }
           
            if (request.getParameter("numProcura") != null && request.getParameter("numProcura").equals("numdocumento")) {
                dupls.setTipoConsulta(4);
            } else if (request.getParameter("numProcura") != null && request.getParameter("numProcura").equals("chaveacesso")){
                dupls.setTipoConsulta(8);
            }else{
                dupls.setTipoConsulta(5);
            }

        } else if(request.getParameter("listaFatura") != null){
            String valorParametro = (String) request.getSession().getAttribute("idCliente!!razaoCliente");
            if (request.getSession().getAttribute("listaFaturaImportacao") instanceof String) {
                faturaImportacaoArquivo = (String) request.getSession().getAttribute("listaFaturaImportacao");
            } else if (request.getSession().getAttribute("listaFaturaImportacao") instanceof BeanCteArquivoLasa) {
                beanCteArquivoLasa = (BeanCteArquivoLasa) request.getSession().getAttribute("listaFaturaImportacao");
            }

            idCliente = (String) (
                        valorParametro != null 
                    ? ((String) request.getSession().getAttribute("idCliente!!razaoCliente")).split("!!").length > 0 
                        ? ((String) request.getSession().getAttribute("idCliente!!razaoCliente")).split("!!")[0] 
                        : ""
                    : "");
            razaoSocialCliente = (String) (
                    valorParametro != null 
                    ? ((String) request.getSession().getAttribute("idCliente!!razaoCliente")).split("!!").length > 1 
                        ? ((String) request.getSession().getAttribute("idCliente!!razaoCliente")).split("!!")[1] 
                        : ""
                    : "");
            
            request.getSession().removeAttribute("listaFaturaImportacao");
            request.getSession().removeAttribute("listaDescontoFatura");
            request.getSession().removeAttribute("idCliente!!razaoCliente");
        } else {
            dupls.setTipoConsulta(3);
            dupls.setIdConsignatario(Apoio.parseInt(request.getParameter("idconsignatario")));
            dupls.setTipoData(request.getParameter("tipoData") == null ? "vence_em" : request.getParameter("tipoData"));
            dupls.setBaixado(request.getParameter("baixado"));
            dupls.setDataVenc1(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual());
            dupls.setDataVenc2(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual());
            dupls.setFilial(request.getParameter("idfilial"));
            dupls.setGrupo_id((request.getParameter("grupo_id") != null ? Integer.parseInt(request.getParameter("grupo_id")) : 0));
            dupls.setValor1((request.getParameter("valor1") == null ? 0 : Double.parseDouble(request.getParameter("valor1"))));
            dupls.setValor2((request.getParameter("valor2") == null ? 0 : Double.parseDouble(request.getParameter("valor2"))));
            dupls.setTitulo(request.getParameter("titulo") == null ? "" : request.getParameter("titulo").equals("todos") ? "" : request.getParameter("titulo"));
            if(filtroSituacao != ""){
                dupls.setSituacao(filtroSituacao);
            }
        }
    } else if (acao.equals("baixar")) {
        //Preenchendo o array dos conhecimentos
        String valor = request.getParameter("ids");
        String cheques = request.getParameter("dadoschq");
        int qtdDupls = valor.split(";").length;
        int qtdCheques = cheques.split(";").length;
        BeanDuplicata[] arDupls = new BeanDuplicata[qtdDupls];
        cheque[] arChqs = new cheque[qtdCheques];
        String[] valorAux = valor.split(";");
        //Dados das duplicatas
        for (int k = 0; k < qtdDupls; ++k) {
            BeanDuplicata dp = new BeanDuplicata();
            dp.setId(Integer.parseInt(valorAux[k]));
            dp.setIdmovimento(Integer.parseInt(request.getParameter("movim_" + valorAux[k])));
            dp.setVlduplicata(Apoio.parseDouble(request.getParameter("vldupl_" + valorAux[k]).replace(".", "").replace(",", ".")));
            if (Apoio.parseDouble(request.getParameter("valorAcrescimo")) > 0) {
                
            }
            dp.setVlpago(Apoio.parseDouble(request.getParameter("vlpago_" + valorAux[k])));
            dp.setDtpago(formatador.parse(request.getParameter("dtpago")));
            dp.setDtbaixa(formatador.parse(Apoio.getDataAtual()));
            dp.getFatura().setSituacao(request.getParameter("situacao_" + valorAux[k]));
            dp.setCriaPcs(Boolean.parseBoolean(request.getParameter("criapcs_" + valorAux[k])));
            dp.setDescricaoDesconto(request.getParameter("descricaoDesconto_" + valorAux[k]));
            if (dp.getCriaPcs()){
                dp.setDtNovaPcs(formatador.parse((request.getParameter("dtnovapcs_" + valorAux[k]))));
            }
            dp.getFpag().setIdFPag(Integer.parseInt(request.getParameter("fpag")));
            dp.getMovBanco().getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
            dp.getMovBanco().setDocum(request.getParameter("doc_" + valorAux[k]));
            String todosCTes = "";
            for(int x = 0; x < qtdDupls; x++){
                todosCTes+=request.getParameter("numero_" + valorAux[x]);
                todosCTes += ",";
            }
            todosCTes = "Pagamento dos CT-es " + (todosCTes.length() > 0 ? todosCTes.substring(0,(todosCTes.length()-1)) : "" );
            altDupls.setTodosCTes(todosCTes);
            
            dp.getMovBanco().setHistorico(request.getParameter("hist_" + valor.split(";")[k]));
            dp.getMovBanco().setDtEmissao(formatador.parse(request.getParameter("dtconciliacao")));
            dp.getMovBanco().setDtEntrada(formatador.parse(request.getParameter("dtconciliacao")));
            dp.getMovBanco().setValor(Apoio.parseDouble(request.getParameter("vlpago_" + valorAux[k])));
            dp.getMovBanco().getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
            dp.getMovBanco().setConciliado(Boolean.parseBoolean(request.getParameter("conciliar")));
            dp.getMovBanco().getCliente().setIdcliente(Apoio.parseInt(request.getParameter("clienteID_"+valorAux[k])));
            arDupls[k] = dp;
        }
        altDupls.setArrayBDupls(arDupls);
        //Dados dos cheques
        if (request.getParameter("fpag").equals("3")) {
            for (int y = 0; y < qtdCheques; ++y) {
                cheque ch = new cheque();
                ch.setCheque(cheques.split(";")[y].split("_")[0]);
                ch.getBanco().setIdBanco(Integer.parseInt(cheques.split(";")[y].split("_")[1]));
                ch.setValor(Float.parseFloat(cheques.split(";")[y].split("_")[2]));
                ch.setData(formatador.parse(cheques.split(";")[y].split("_")[3]));
                ch.setEmitente(cheques.split(";")[y].split("_")[4]);
                ch.setCgc(cheques.split(";")[y].split("_")[5]);
                ch.setObservacao(cheques.split(";")[y].split("_")[6]);
                arChqs[y] = ch;
            }
        }
        altDupls.setArrayChq(arChqs);
        boolean erroBaixar = !altDupls.Atualiza(1);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroBaixar) {
            //response.getWriter().append("<script>alert('"+altDupls.getErros()+"');window.close()</script>");
            response.getWriter().append("<script>alert('" + altDupls.getErros() + "');</script>");
            response.getWriter().append("<script>window.opener.habilitaSalvar(true);window.close();</script>");
        } else {
            //   	response.getWriter().append("<script>window.opener.document.location.replace(window.opener.document.location);window.close();</script>");
            response.getWriter().append("<script>window.opener.document.getElementById('visualizar').onclick();window.close();</script>");
        }
        response.getWriter().close();
    } else if (acao.equals(
            "excluir")) {
        //Preenchendo o array dos conhecimentos
        String valor = request.getParameter("id");
        duplicata.setId(Integer.parseInt(valor.split("_")[0]));
        duplicata.getMovBanco().setIdLancamento(Integer.parseInt(request.getParameter("idlancamento")));
        duplicata.getFatura().setSituacao(request.getParameter("situacao"));
        altDupls.setBDupls(duplicata);

        boolean erroExcluir = !altDupls.Atualiza(2);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO

        if (erroExcluir) {
            response.getWriter().append("err<=>" + altDupls.getErros());
            //response.getWriter().append("<script>window.close();</script>");
        } else {
            response.getWriter().append("err<=>");
        }
        response.getWriter().close();
    } else if (acao.equals(
            "excluirFatura")) {
        //Preenchendo o array dos conhecimentos
        String valor = request.getParameter("id");
        duplicata.getFatura().setId(Apoio.parseInt(request.getParameter("idFatura")));
        duplicata.getMovBanco().setDocum(request.getParameter("idlancamento"));
        duplicata.getFatura().setSituacao(request.getParameter("situacao"));
        altDupls.setBDupls(duplicata);

        boolean erroExcluir = !altDupls.Atualiza(4);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO

        if (erroExcluir) {
            response.getWriter().append("err<=>" + altDupls.getErros());
            //response.getWriter().append("<script>window.close();</script>");
        } else {
            response.getWriter().append("err<=>");
        }
        response.getWriter().close();
    } else if (acao.equals(
            "estornar")) {
        //Preenchendo o array dos conhecimentos
        String valor = request.getParameter("id");
        duplicata.setId(Integer.parseInt(valor.split("_")[0]));
        duplicata.getMovBanco().setIdLancamento(Integer.parseInt(request.getParameter("idlancamento")));
        duplicata.getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dataEstorno")));
        duplicata.getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dataEstorno")));
        altDupls.setBDupls(duplicata);

        boolean erroExcluir = !altDupls.Atualiza(3);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroExcluir) {
            response.getWriter().append("err<=>" + altDupls.getErros());
        } else {
            response.getWriter().append("err<=>");
        }
        response.getWriter().close();
    } //Imprimindo recibo
    else if (acao.equals(
            "exportar")) {

        //Preenchendo o array dos conhecimentos
        String recibos = request.getParameter("ids");
        String condicao = "";
        //recebendo valor do primeiro cheque
        java.util.Map param = new java.util.HashMap(3);
        param.put("IDDUPLICATA", request.getParameter("id"));
        param.put("FATURA", (request.getParameter("fatura").equals("0") ? "-1" : request.getParameter("fatura")));
        param.put("ANO_FATURA", (request.getParameter("fatura").equals("0") ? "" : request.getParameter("ano_fatura")));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", "recibomod" + request.getParameter("modelo"));
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }
    boolean carregaconta = (dupls != null && (!acao.equals("consultar") || !acao.equals("consultar")));
%>

<script language="javascript" type="text/javascript">

    jQuery.noConflict();

    var ultChq = 0;
    function habilitaSalvar(opcao){
        getObj("baixar").disabled = !opcao;
        getObj("baixar").value = (opcao ? "Baixar" : "Enviando...");
    }
    
    var listaDesc = new Array();
    var countDesc = 0;
    
    <c:forEach var="desc" varStatus="status" items="<%=listaDescontoFatura%>">
        listaDesc[countDesc++] = new Option("${desc.vlDesconto}", "${desc.numero}");
    </c:forEach>
        
        
    function setDescontoAll(){
        for (var i = 0; i < listaDesc.length; i++) {
            if (listaDesc[i] != null) {
                setDesconto(listaDesc[i].valor, listaDesc[i].descricao);
            }
        }
    }    
    function setDesconto(valor, numCte){
        try {
            if ($("maxLinha") != null) {
                var max = parseInt($("maxLinha").value, 10);
                var numero = "";
                var ctrcId = "";
                for (var i = 0; i < max; i++) {
                    if ($("numero_"+ i) != null) {
                        numero = $("numero_"+ i).value;
                        if (numero == numCte) {
                            ctrcId = $("idCtrc_"+ i).value;
                            $("vlpago_" + ctrcId).value = colocarVirgulaOld(valor);
                        }
                    }
                }
            }
        } catch (e) {
            console.log(e);
        }

    }
    

    function baixar(linhas)
    {          

        var ids;
        var deuCerto = true;
        var resultado = "";
        //Verificando as duplicatas que serão 
        for (i = 0; i <= linhas - 1; ++i){
            ids = $("chk_"+i).value
            //Verificando se o check está marcado
            if ($("chk_"+i).checked){
                //verificando se a data está válida
                if (wasNull('hist_'+ids)){
                    deuCerto = false;
                }
                else{
                    //Começando a concatenação
                    if (resultado != "")
                        resultado += ";";

                    seNaoFloatReset(getObj("vlpago_"+ids),'0.00');
                    resultado += ids;
                }
            }
        }
        var deuCertoChq = true;
        var resultadoChq = "";
        //Verificando os cheques que serão cadastrados
        if (getObj("fpag").value == '3'){
            for (z = 1; z <= ultChq; ++z){
                if (! validaData(getObj("chq_data"+z))){
                    //verificando se a data está válida
                    deuCertoChq = false;
                }else{ 
                    if (wasNull('chq_cheque'+z)){
                        deuCertoChq = false;
                    }
                    else{
                        //Começando a concatenação
                        if (resultadoChq != "")
                            resultadoChq += ";";
  
                        resultadoChq += getObj("chq_cheque"+z).value + "_" + getObj("chq_idbanco"+z).value + "_" + 
                            getObj("chq_valor"+z).value + "_" + getObj("chq_data"+z).value + "_" + getObj("chq_emitente"+z).value +
                            "_" + getObj("chq_cgc"+z).value + "_" + getObj("chq_observacao"+z).value + "_fim";
                    }
                }
            }
        }
        
        if($("conta").value == ""){
            alert("ATENÇÃO: Escolha uma conta para baixar");
            return false;
        }
        if (!deuCerto){
            alert('Informe todos os dados da baixa corretamente.');
        }else if (!deuCertoChq){
            alert('Informe todos os dados dos cheques corretamente.');
        }else if (! validaData(getObj("dtpago"))){
            alert('Informe todos os dados da baixa corretamente');
            getObj("dtpago").style.background ="#FFE8E8";
        }else if(resultado == ""){
            alert('Escolha uma duplicata corretamente');
        }else if ((getObj('fpag').value == '3') && (getObj('totalchq').value != getObj('totaldup').value)){
            alert('O total dos cheques tem que ser igual ao total das duplicatas selecionadas.');
        }else{
            $("ids").value = resultado;
            $('formBx').action = "./bxcontasreceber?acao=baixar&dtpago="+$("dtpago").value+
                "&dtconciliacao="+$("dtconciliacao").value+
                "&dadoschq="+resultadoChq+"&conciliar="+$("chkconciliado").checked+
                "&fpag="+$("fpag").value+"&conta="+$("conta").value;
            habilitaSalvar(false);
            
            window.open('about:blank', 'pop', 'width=210, height=100');
            $('formBx').submit();
        }
    }

    function excluir(id,idMovBanco,situacao,conciliado)
    {
        var filtrosSituacao = popularFiltrarSituacao();

        function ev(resp, codstatus, situacao) {
            // habilitaSalvar(true);
            if (codstatus==200 && resp=="err<=>")
                location.replace("./bxcontasreceber?acao=consultar&"+concatFieldValue("fatura,anofatura,idfilial,idconsignatario,con_rzs,dtinicial,dtfinal,baixado,ordenacao,grupo_id")+"&filtrarSituacao=" + $("filtrarSituacao").value + "&filtrosSituacao="+filtrosSituacao);

            else
                alert(resp.split("<=>")[1]);
        }

        if (conciliado && <%=(nivelUserConciliacao < 4)%>){
            alert('Esse recebimento já foi conciliado, exclusão cancelada.');
            return null;
        }

        if (confirm("Deseja mesmo excluir a baixa dessa duplicata?")){
            requisitaAjax("./bxcontasreceber?acao=excluir&id="+id+"&idlancamento="+idMovBanco+"&situacao="+situacao,ev);
        }
    }

    function excluirFatura()
    {
        var idFaturaExclusao = '0';
        var conciliadoFatEx = false;
        var situacaoFatEx = false;
        var movBancoIds = '';
        var idxF = 0;
        var idF;

        while ($("chk_"+idxF) != null){
            idF = $("chk_"+idxF).value;
            if ($("baixado_"+idF).value == true || $("baixado_"+idF).value == 'true'){
                if (!conciliadoFatEx){
                    conciliadoFatEx = $("conciliado_"+idF).value;
                }
                idFaturaExclusao = $("faturaId_"+idF).value;
                situacaoFatEx = $("situacao_"+idF).value;
                movBancoIds += ((movBancoIds == '' ? '' : ',') + $("movBancoId_"+idF).value);
            }
            
            idxF++;
        }

        if (idFaturaExclusao == '0'){
            alert('A fatura já encontra-se em aberto!');
            return null;
        }

        if (conciliadoFatEx && <%=(nivelUserConciliacao < 4)%>){
            alert('Esse recebimento já foi conciliado, exclusão cancelada.');
            return null;
        }

        if (confirm("Deseja mesmo excluir a baixa dessa fatura?")) {
            blockInterface(true);
            espereEnviar('', true);

            // Está enviando como AJAX POST, pois caso tiver muita fatura a excluir em GET,
            // irá causar erro 400 bad request no Tomcat. POST é ideal para esse tipo de situação.
            jQuery.ajax({
                url: '${homePath}/bxcontasreceber',
                method: "POST",
                dataType: "text",
                data: {
                    'acao': "excluirFatura",
                    'idFatura': idFaturaExclusao,
                    'idlancamento': movBancoIds,
                    'situacao': situacaoFatEx
                },
                success: function (data) {
                    blockInterface(false);
                    espereEnviar('', false);

                    // habilitaSalvar(true);
                    if (data === "err<=>") {
                        location.replace("./bxcontasreceber?acao=consultar&" + concatFieldValue("fatura,anofatura,idfilial,idconsignatario,con_rzs,dtinicial,dtfinal,baixado,ordenacao,grupo_id"));
                    } else {
                        alert(data.split("<=>")[1]);
                    }
                }
            });
        }
    }

    function estornar(id,idMovBanco)
    {
        var filtrosSituacao = popularFiltrarSituacao();

        function ev(resp, codstatus) {
            // habilitaSalvar(true);
            if (codstatus==200 && resp=="err<=>")
                location.replace("./bxcontasreceber?acao=consultar&"+concatFieldValue("fatura,anofatura,idfilial,idconsignatario,con_rzs,dtinicial,dtfinal,baixado,ordenacao,grupo_id")+"&filtrarSituacao=" + $("filtrarSituacao").value + "&filtrosSituacao="+filtrosSituacao);
            else
                alert(resp.split("<=>")[1]);
        
        }

        if (confirm("ATENÇÃO: Ao estornar a baixa o valor referente a esse estorno continuará aparecendo na conciliação bancária. Deseja mesmo estornar a baixa dessa duplicata?")){
            requisitaAjax("./bxcontasreceber?acao=estornar&id="+id+"&idlancamento="+idMovBanco+"&dataEstorno="+$('dtestorno').value,ev);
        }
    }
    
    function marcarCheckesSituacao(situacaoFatura){
        if(situacaoFatura == null || situacaoFatura == undefined){
            situacaoFatura = new Array();
            situacaoFatura = '<%=(request.getParameter("filtrosSituacao") != null ? request.getParameter("filtrosSituacao").replace("'",""): 0)%>';
        }
        
        if(situacaoFatura != 0){
            
            situacaoFatura = situacaoFatura.split(",");
            
            //Desativa todos para tirar o default que é true;
            $("normal").checked = false;
            $("cartorio").checked = false;
            $("descontada").checked = false;
            $("devedora").checked = false;
            $("semFatura").checked = false;
            //----------------------------------------------
            for(var i = 0; i < situacaoFatura.size();i++){
                if(situacaoFatura[i] != null){
                    switch(situacaoFatura[i]){
                        case 'NM':
                            $("normal").checked = true;
                            break;
                        case 'TC':
                            $("cartorio").checked = true;
                            break;
                        case 'DT':
                            $("descontada").checked = true;
                            break;
                        case 'DE':
                            $("devedora").checked = true;
                            break;
                        case 'SF':
                            $("semFatura").checked = true;
                            break;
                    }
                }
            }
        }
        
        if (situacaoFatura == "0") {
            $("normal").checked = true;
            $("cartorio").checked = true;
            $("descontada").checked = true;
            $("devedora").checked = true;
            $("semFatura").checked = true;
        }
    }
    
    function popularFiltrarSituacao(){
        var filtrosSituacao = "";
        
        $("filtrarSituacao").value = "true";
        if ($("normal").checked) {
            filtrosSituacao += "'NM'" + ",";
        }
        if ($("cartorio").checked) {
            filtrosSituacao += "'TC'" + ",";
        }
        if ($("descontada").checked) {
            filtrosSituacao += "'DT'" + ",";
        }
        if ($("devedora").checked) {
            filtrosSituacao += "'DE'" + ",";
        }
        if ($("semFatura").checked) {
            filtrosSituacao += "'SF'" + ",";
        }
        filtrosSituacao = filtrosSituacao.substring(0,filtrosSituacao.length - 1);
        
        return filtrosSituacao;
    }
  
    function visualizar(){
        var filtros = "";
        var filtrosSituacao = popularFiltrarSituacao();
        
        if (getObj("fatura").value.trim()!='' || getObj("anofatura").value.trim()!=''){
            //Apenas uma fatura
            if (getObj("fatura").value.trim()=='' || getObj("anofatura").value.trim()=='')
                alert('Informe os dados da fatura corretamente');
            else
                filtros = concatFieldValue("fatura,anofatura,dtpago,dtconciliacao,conta,fpag,ordenacao")+"&chkconciliado="+$('chkconciliado').checked+"&filtrarSituacao=" + $("filtrarSituacao").value + "&filtrosSituacao="+filtrosSituacao;
        }
        else if (getObj("documento").value.trim()!=''){
            filtros = concatFieldValue("numProcura,documento,dtpago,dtconciliacao,conta,fpag,idconsignatario,con_rzs,dtinicial,tipoData,dtfinal,baixado,idfilial,ordenacao,grupo_id,grupo,valor1,valor2,titulo")+"&chkconciliado="+$('chkconciliado').checked+"&filtrarSituacao=" + $("filtrarSituacao").value + "&filtrosSituacao="+filtrosSituacao;
        }
        else
            if (! validaData($("dtinicial")) || !validaData($("dtfinal")))
                alert ("Informe o intervalo de datas corretamente.");
        else  
            filtros = concatFieldValue("idconsignatario,con_rzs,dtinicial,tipoData,dtfinal,baixado,idfilial,ordenacao,grupo_id,grupo,dtpago,dtconciliacao,conta,fpag,valor1,valor2,titulo,clienteFiltros,idClienteFiltros")+
            "&fatura=&chkconciliado="+$('chkconciliado').checked+"&filtrarSituacao=" + $("filtrarSituacao").value + "&filtrosSituacao="+filtrosSituacao;
        //Apenas se os filtros estiverem corretos
        if (filtros.trim()!=''){
            location.replace("./bxcontasreceber?acao=consultar&"+filtros);
        }
    }

    function verCtrc(id){
        window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "CTRC" , "top=0,resizable=yes");
    }

    function verSale(id){
        window.open("./cadvenda.jsp?acao=editar&id="+id+"&ex=false", "CTRC" , "top=0,resizable=yes");
    }    

    function verReceita(id){
        window.open("./VendaControlador?acao=iniciarEditarFinan&id="+id, "CTRC" , "top=0,resizable=yes,status=1,scrollbars=1");
    }

    function mostraCombos(){
   
        var valorAcrescimo = $("valorAcrescimo") != null ? $("valorAcrescimo").value : "";
        var maxLinha = $("maxLinha") != null && $("maxLinha") != undefined ? $("maxLinha").value : 0;
        
        var valorAcumulado = 0;
        var valorPago = 0;
        
            for (i = 0; i <= maxLinha-1; i++) {
                
                var isUltimo = (i==maxLinha-1);
                //correção: estava sendo passado o indice errado do ($('vlpago_'+i); Daniel Cassimiro  
                if(parseFloat(valorAcrescimo) > 0 && ($('vlpago_'+$('idCtrc_'+i)) != null)){
                    var vlPago = parseFloat($('vlpago_'+$('idCtrc_'+i).value).value);
                    //Se não for a ultima linha dos resultados divida normal (ValorRateio (valorAcrescimo) menos a quantidade de registro (maxLinha))
                    if(!isUltimo){
                        valorPago = parseFloat((valorAcrescimo / maxLinha-1).toFixed(2));
                        $('vlpago_'+$('idCtrc_'+i).value).value = formatoMoeda(valorPago + vlPago);
                        valorAcumulado += valorPago;
                    }else{
                        //Quando for o último registro divida a o valor do (ValorRateio (valorAcrescimo) - valorAcumulado para trazer a diferença para o ultimo resultado
                        $('vlpago_'+$('idCtrc_'+i).value).value = formatoMoeda((valorAcrescimo - valorAcumulado) + vlPago);
                    }
                }
            }
         
        getObj("baixado").value = '<%=(request.getParameter("baixado") == null ? "false" : request.getParameter("baixado"))%>';
        getObj("ordenacao").value = '<%=(request.getParameter("ordenacao") == null ? "vence_em" : request.getParameter("ordenacao"))%>';
        getObj("titulo").value = '<%=(request.getParameter("titulo") == null ? "todos" : request.getParameter("titulo"))%>';
        $("tipoData").value = '<%=(request.getParameter("tipoData") == null ? "vence_em" : request.getParameter("tipoData"))%>';
        
        if ('${layout}' == "") {
            $("layout").selectedIndex = 0;
        }else{
            $("layout").value = '${layout}';
        }
//        removerSelect();
    }
    
    /*
        Autor: Airton
        Data:11/08/2016
        Motivo - Foi criado a função aoCarregar() para facilitar a compreenção dos campos carregados no load.
    */    
    function aoCarregar() {
        if ($('documento').value > 0) {
            $('documento').select();
        }
        $('documento').focus();
    }

    function aoClicarNoLocaliza(idjanela)
    { 
        
        var campo = "";
        if ((idjanela == "Historico"))
        {
            campo = "hist_"+document.getElementById("id_historico").value;
            getObj(campo).value = getObj("descricao_historico").value;
        }else if (idjanela == "Banco"){
            //Campo idbanco
            campo = "chq_idbanco"+getObj("linha_indice").value;
            getObj(campo).value = getObj("idbanco").value;
            //Campo numero e descricao do banco
            campo = "chq_banco"+getObj("linha_indice").value;
            getObj(campo).value = getObj("banco").value + "-" + getObj("descricao").value;
        }
        
        if(idjanela == "Cliente_Filtros"){
           $("clienteFiltros").value = $("con_rzs").value;
           $("idClienteFiltros").value = $("idconsignatario").value;
        }
        
        if(idjanela == "Cliente_Importacao"){
           $("clienteImportacao").value = $("con_rzs").value;
           $("idClienteImportacao").value = $("idconsignatario").value;
        }

    }

    function localizacliente(aba){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5',aba,
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizahist(obj){
        document.getElementById("id_historico").value = obj.name;
        post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparclifor(aba){
        if (aba == 1) {
            document.getElementById("idClienteFiltros").value = "0";
            document.getElementById("idconsignatario").value = "0";
            document.getElementById("clienteFiltros").value = "";
    
        }else if (aba == 2) {
            document.getElementById("idClienteImportacao").value = "0";
            document.getElementById("clienteImportacao").value = "";
    
        }
        
    }

    function popLocate(indice, idlista, nomeJanela, paramaux){
        document.getElementById("linha_indice").value = indice;
        launchPopupLocate("./localiza?acao=consultar&idlista="+idlista+"&paramaux="+paramaux, nomeJanela); 
    }

    function recibo(id,fatura,ano_fatura){
        var modelo = (fatura == 'null' || fatura == null ? '1' : '2');
        launchPDF('./bxcontasreceber?acao=exportar&modelo='+modelo+'&id='+id+'&fatura='+fatura+'&ano_fatura='+ano_fatura,
        'recibo'+id);
    }

    function criaNovaPcs(ids){
        $("vlpago_"+ids).value = soNumerosVirgula($("vlpago_"+ids).value);
        $("vldupl_"+ids).value = soNumerosVirgula($("vldupl_"+ids).value);
        var isValidando = (parseFloat(colocarPonto($("vldupl_"+ids).value)) > parseFloat(colocarPonto($("vlpago_"+ids).value)));
        
//        if(parseFloat($("vldupl_"+ids).value.replace('.','')) > parseFloat($("vlpago_"+ids).value)){ //Se valor pago for menor que o previsto
//      Comentei essa linha acima por que não estava comparando valores quebrados EX: 19.09 > 19.00
        if(isValidando){ //Se valor pago for menor que o previsto
            if (confirm("O valor pago é menor que o previsto, deseja criar uma nova parcela?")){
                //não tava validando, apenas estava levantando a pergunta duas vezes 
//                if (prompt("Informe o vencimento da nova parcela.", getObj("dtpago").value)) {
                    getObj("dtnovapcs_"+ids).value = prompt("Informe o vencimento da nova parcela.", getObj("dtpago").value);
                    getObj("criapcs_"+ids).value = "true";
                    getObj("dtnovapcs_"+ids).style.display = "";
                    getObj("trVencParcel_"+ids).style.display = "";
                    getObj("trDescrDescnt_" + ids).style.display = "none";
//                }
            }else{
                getObj("criapcs_"+ids).value = "false";
                getObj("dtnovapcs_"+ids).style.display = "none";
                getObj("trVencParcel_"+ids).style.display = "none";
                getObj("trDescrDescnt_"+ids).style.display = "";
            }
        }
    }

    function verFpag(){
        if (getObj("fpag").value == '3'){
            hide('tableChqs', false);
        }else{
            hide('tableChqs', true);
        }
    }

    function getNextIndexFromTableRoot() {
        var r = 1;
        while (getObj("trNote"+r) != null)
            ++r;
		
        return 	r;
    }

    function addChq(cheque,idbanco, banco, valor, data, emitente, cgc, observacao)
    {
        var indice = getNextIndexFromTableRoot();

        //simplificando na hora da chamada    
        var nameTR = "trNote" + indice;
	  	  
        var trNote = makeElement("TR", "class=colorClear&id="+nameTR);

        //fabricando campos e strings de comando
        var commonObj = "type=text&class=fieldMin";
        var commonField = "&onchange=seNaoFloatReset($('";
        var commonSufix = indice+"'),'0.00');getTotalChq();";
	  
        //fabricando o botão de excluir	
        appendObj(trNote, makeWithTD("IMG","src=img/cancelar.png&border=0&onclick=removeChq('"+nameTR+"')&class=imagemLink&title=Remover este cheque"));

        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_cheque"+indice+"&maxLength=6&size=8&value="+cheque+"&onchange=seNaoIntReset($('chq_cheque"+indice+"'),'')")); 
        appendObj(trNote, makeElement("INPUT","type=hidden&id=chq_idbanco"+indice+"&value="+idbanco));
        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_banco"+indice+"&class=inputReadOnly8pt&value="+banco+"&readOnly=true"));
        appendObj(trNote, makeWithTD("INPUT", "type=button"+"&class=botoes&value=...&onclick=popLocate('"+indice+"','29','Banco',0)"));
        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_valor"+indice+"&maxLength=12&size=12"+commonField+"chq_valor"+commonSufix + "&value="+formatoMoeda(valor)));
        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_data"+indice+"&maxLength=12&size=9&value="+data+"&class=fieldDate&onblur=alertInvalidDate(this)&onKeyPress=fmtDate(this, event)"));
        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_emitente"+indice+"&maxLength=50&size=30&value="+emitente));
        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_cgc"+indice+"&maxLength=18&size=22"+"&value="+cgc+"&onchange=validaCgc('chq_cgc"+indice+"');"));
        appendObj(trNote, makeWithTD("INPUT", commonObj + "&id=chq_observacao"+indice+"&size=45"+"&value="+observacao));
			 
        //adicionando a linha na tabela
        tableChqs.lastChild.appendChild(trNote);	  	  
    }
  
    function addNewChq(idTableRoot){
        if (parseFloat(qtdDupSelecionado) > 1 && ultChq > 0)
            alert ('Não é possível cadastrar outro cheque pois existem mais de 1 duplicata selecionada.');
        else{
            addChq("", "0", "", "0.00", "", "", "", "");
            ++ultChq;
        }
    }

    /**Remove um cheque de uma lista*/
    function removeChq(nameObj) {
        if (confirm("Deseja mesmo excluir este cheque ?")){
            getObj(nameObj).parentNode.removeChild(getObj(nameObj));
            getTotalChq();
            --ultChq;
        }
    }

    function getTotalChq() {
        var r = 1;
        var total = 0;
        while (getObj("trNote"+r) != null){
            total = total + parseFloat(getObj("chq_valor"+r).value);
            ++r;
        }	
        getObj("totalchq").value = formatoMoeda(total);
    }

    function validaCgc(obj) {
        if (getObj(obj).value.length == 11){
            if ( ! isCpf(getObj(obj).value))
                alert ("Cpf Inválido.");
        }else{
            if ( ! isCnpj(getObj(obj).value))
                alert ("Cnpj Inválido.");
        }
    }

    function selectDup(obj) {
        if (qtdDupSelecionado > 1 && ultChq > 1){
            alert ('Não é possível selecionar a duplicata, pois existem mais de 1 cheque informado.');
            getObj(obj).checked = false;
        }
    }

    var qtdDupSelecionado = 0;
    var vlSelecionado = 0;
    function getTotalDup(linha, alterou) {
        vlSelecionado = 0;
        qtdDupSelecionado = 0;
        jQuery('[id^=chk_]:checked').each(
                function(i,elem){
                    vlSelecionado += parseFloat(colocarPonto($('vlpago_'+elem.value).value));
                    qtdDupSelecionado++;
                }
            );
        $("totaldup").value = formatoMoeda(vlSelecionado);
    }

    function marcaTodos(){
        jQuery('[id^=chk_]:enabled').each( function(i,elem){
            elem.checked = $("chkTodos").checked;
        });
        getTotalDup();
    }

    //Atribuindo os valores para todas as linhas
    function atribuiValores(obj){
        var r = 0;
        while ($("chk_"+r) != null){
            if($(obj+'_'+$("chk_"+r).value)!=null){
                $(obj+'_'+$("chk_"+r).value).value=$(obj+'_'+$("chk_0").value).value;
            } 
            ++r;
        }  
    }
    
    function setAbaAtual(indice){
        if (indice == 'filtro') {
          $("AbaAtual").value = 1;
        }else {
          $("AbaAtual").value = 2;
	
        }
    }

    var arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdFiltros','tableFiltros');
    arAbasGenerico[1] = new stAba('tdImportacao','tableImportacao');
    
    function importarArquivo () {
        try {
            
        var form = $("formularioImportacao");
        
        if($("layout").value == ""){
            alert("Informe o layout para visualização. ");
            return false;
            $("layout").focus();
        }
        if ($("arquivoImportacao").value == "") {
            alert("Para importar selecione ao menos um arquivo");
            return false;
        }
        
        if ($("idClienteImportacao") == null || $("idClienteImportacao") == undefined || $("idClienteImportacao").value == "" || $("idClienteImportacao").value == "0") {
            alert("Para importar, selecione o cliente");
            return false;
        }

            form.action = "ServletUploadFatura?layout="+$("layout").value+"&idClienteImportacao="+$("idClienteImportacao").value+"&clienteImportacao="
                +encodeURI($("clienteImportacao").value)+"&arquivoImportacao="+encodeURI($("arquivoImportacao").value);
        //        form.action = "ServletUploadFatura?acao=importar&layout=cimentoNacional&arquivoImportacao="+$("arquivoImportacao").value;
        window.open('about:blank', 'pop', 'width=210, height=100');
        form.submit();
        
        } catch (e) {
           alert(e);  
        }
    
    }
    
    function alterarAbasImportarVisualizar(){
        var isImportacao = ${param.listaFatura != true};
        if (isImportacao) {
            AlternarAbasGenerico('tdFiltros','tableFiltros');
            setAbaAtual('filtro');
    
        }else if (!isImportacao) {
            AlternarAbasGenerico('tdImportacao','tableImportacao');
            setAbaAtual('import');
        }  
    
    }
    
    function visualizarEnter(evt) {
        var key_code = evt.keyCode;
        if (key_code == 13) {
            visualizar();
        }
    }
    
</script>

<%@page import="fpag.BeanConsultaFPag"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="conhecimento.duplicata.fatura.BeanConsultaFatura"%>
<%@ page import="br.com.gwsistemas.cte.lasa.BeanCteArquivoLasa" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Baixas de contas a receber</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style2 {font-size: 9pt}
            .style4 {font-family: sans-serif}
            .style5 {font-size: 8pt}
            -->
        </style>
    </head>

    <body onLoad="javascript:mostraCombos();alterarAbasImportarVisualizar();marcarCheckesSituacao();aoCarregar();setDescontoAll();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0")%>">
            <input type="hidden" name="con_rzs" id="con_rzs" value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>"> 
            <input type="hidden" name="idfilial1" id="idfilial1" value="<%=(request.getParameter("idfilial") != null ? request.getParameter("idfilial") : "0")%>">
            <input type="hidden" name="grupo_id" id="grupo_id" value="<%=(request.getParameter("grupo_id") != null ? request.getParameter("grupo_id") : "0")%>">
            <input type="hidden" name="descricao_historico" id="descricao_historico" value="0">
            <input type="hidden" name="id_historico" id="id_historico" value="0">
            <input type="hidden" name="linha_indice" id="linha_indice" value="0">
            <input type="hidden" name="idbanco" id="idbanco" value="0">
            <input type="hidden" name="banco" id="banco" value="">
            <input type="hidden" name="descricao" id="descricao" value="">
            <input type="hidden" name="abaAtual" id="AbaAtual" value="1">
            <input type="hidden" name="existeResultado" id="existeResultado" value="">
        </div>
        <table width="100%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Baixa de contas a receber</b></td>
            </tr>
        </table>

        <br>
        <table width="100%">
            <tr>
                <td>
  <table width="40%"  align="left">
      <tr>
          <td id="tdFiltros" name="tdFiltros" class="menu-sel" onclick="AlternarAbasGenerico('tdFiltros','tableFiltros');setAbaAtual('filtro');"> Filtros </td>
          <td id="tdImportacao" name="tdImportacao" class="menu" onclick="AlternarAbasGenerico('tdImportacao','tableImportacao');setAbaAtual('import');" > Importação </td>
      </tr>
  </table>
                </td>
            </tr>
            <tr id="tableFiltros">
                <td>
        <table width="100%" border="0" class="bordaFina" align="center" id="" name="tableFiltros">
            <tr> 
                <td width="14%" class="TextoCampos">
                    <select name="tipoData" id="tipoData" class="inputtexto">
                        <option value="vence_em" selected>Vencimento</option>
                        <option value="emissao_em">Emiss&atilde;o</option>
                        <option value="pago_em" >Pagamento</option>
                    </select>
                    entre:
                </td>
                <td width="25%" class="CelulaZebra2"><strong>
                        <input name="dtinicial" type="text" id="dtinicial" class="fieldDate" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                               onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </strong>e<strong> 
                        <input name="dtfinal" type="text" id="dtfinal" class="fieldDate" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                               onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </strong></td>
                <td width="18%"colspan="4" class="TextoCampos">Apenas a filial:</td>
                <td width="23%" colspan="2" class="CelulaZebra2">
                    <select name="idfilial" id="idfilial" class="fieldMin">
                        <%BeanFilial fl = new BeanFilial();
                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                            if (nivelUserCtrcFl
                                    > 0) {
                        %>
                        <option value="0">TODAS AS FILIAIS</option>
                        <%}
                            int filial = (request.getParameter("idfilial") != null ? Integer.parseInt(request.getParameter("idfilial"))
                                    : Apoio.getUsuario(request).getFilial().getIdfilial());

                            while (rsFl.next()) {
                                if (nivelUserCtrcFl > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {
                        %>
                        <option value="<%=rsFl.getString("idfilial")%>"
                                <%=(filial == rsFl.getInt("idfilial") ? "selected" : "")%>>APENAS A <%=rsFl.getString("abreviatura")%></option>                            
                        <%}
                            }%>
                    </select>
                </td>
                <td width="9%" class="TextoCampos">Mostrar:</td>
                <td width="11%" class="CelulaZebra2" style="font-size:8pt; "><select name="baixado" id="baixado" class="fieldMin" style="width:75px;" >
                        <option value="todas">Todas</option>
                        <option value="false" selected>Em aberto</option>
                        <option value="true">Quitadas</option>
                    </select></td>
            </tr>
            <tr> 
                <td class="TextoCampos">Apenas o cliente:</td>
                <td colspan="1" class="CelulaZebra2"><strong>
                        <input name="clienteFiltros" type="text" id="clienteFiltros" class="inputReadOnly8pt" value="<%=(request.getParameter("clienteFiltros") != null ? request.getParameter("clienteFiltros") : "")%>" size="30" maxlength="80" readonly="true">
                        <input type="hidden" name="idClienteFiltros" id="idClienteFiltros" value="<%=(request.getParameter("idClienteFiltros") != null ? request.getParameter("idClienteFiltros") : "")%>"/>
                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor" value="..." onClick="javascript:localizacliente('Cliente_Filtros');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:limparclifor(1);"> 
                    </strong></td>
                <td height="22" colspan="4" class="TextoCampos">Apenas o grupo: </td>
                <td height="22" colspan="2" class="CelulaZebra2"><input name="grupo" type="text" id="grupo" class="inputReadOnly8pt" value="<%=(request.getParameter("grupo") != null ? request.getParameter("grupo") : "")%>" size="25" maxlength="80" readonly="true">
                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo');">
                    <img src="img/borracha.gif" border="f" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:$('grupo').value='';$('grupo_id').value=0;"></td>
                <td height="22" class="TextoCampos">Ordena&ccedil;&atilde;o:</td>
                <td height="22" class="CelulaZebra2"><select name="ordenacao" id="ordenacao" class="fieldMin" style="width: 75px;">
                        <option value="vence_em" selected>Vencimento</option>
                        <option value="numero" >CTRC</option>
                        <option value="emissao_em" >Data de emissão</option>
                        <option value="num_fatura" >Número da fatura</option>
                    </select></td>
            </tr>
            <tr> 
                <td class="TextoCampos">Apenas a fatura:</td>
                <td class="CelulaZebra2">
                        <input name="fatura" type="text" id="fatura" class="fieldMin" size="6" value="<%=(request.getParameter("fatura") != null ? request.getParameter("fatura") : "")%>" maxlength="8">
                        / 
                        <input name="anofatura" type="text" id="anofatura" class="fieldMin" size="4" value="<%=(request.getParameter("anofatura") != null ? request.getParameter("anofatura") : "")%>" maxlength="4">
                    </td>
                <td class="CelulaZebra2" style="text-align: right;">
                    <select name="numProcura" id="numProcura" class="fieldMin" style="width: 120px;" >
                        <option value="numdocumento" selected>Apenas o CT-e/NFS</option>
                        <option value="chaveacesso" <%=request.getParameter("numProcura") != null && request.getParameter("numProcura").equals("chaveacesso") ? "selected" : "" %>>Apenas o CT-e (Chave de acesso)</option>
                        <option value="notafiscal" <%=request.getParameter("numProcura") != null && request.getParameter("numProcura").equals("notafiscal") ? "selected" : "" %> >Apenas NF do embarcador</option>
                    </select></td>
                    <td width="4%" colspan="7" class="CelulaZebra2">
                        <input name="documento" type="text" id="documento" class="fieldMin" size="50" value="<%=(request.getParameter("documento") != null ? request.getParameter("documento") : "")%>" onkeypress="visualizarEnter(event);">
                        Exemplo: 001234,001235,001236
                    </td>
            </tr>
            <tr>
                <td class="TextoCampos">Valores Entre:</td>
                <td class="CelulaZebra2">
                    <input name="valor1" id="valor1" value="<%=(request.getParameter("valor1") != null ? request.getParameter("valor1") : "0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="8" class="fieldMin" maxlength="12" align="Right">
                    e
                    <input name="valor2" id="valor2" value="<%=(request.getParameter("valor2") != null ? request.getParameter("valor2") : "0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="8" class="fieldMin" maxlength="12" align="Right">
                </td>
                <td class="TextoCampos" >
                    <div>Apenas os t&iacute;tulos:</div>
                </td>
                <td class="CelulaZebra2">
                    <select name="titulo" class="inputtexto"  id="titulo" style="width: 72px;">
                        <option value="todos" selected>Todos</option>
                        <option value="com" >Com fatura</option>
                        <option value="sem" >Sem fatura</option>
                    </select>  
                </td>
                <td colspan="3" class="CelulaZebra2"><div align="right">Situação da Fatura:</div></td>
                <td class="CelulaZebra2" colspan="3">
                    <label>
                        <input type="checkbox" name="semFatura" id="semFatura">Sem Fatura                        
                    </label>
                    <label>
                        <input type="checkbox" name="normal" id="normal">Normal                        
                    </label>
                    <label>
                        <input type="checkbox" name="cartorio" id="cartorio">Cartório
                    </label>
                    <label>
                        <input type="checkbox" name="descontada" id="descontada">Descontada
                    </label>
                    <label>
                        <input type="checkbox" name="devedora" id="devedora">Devedora
                    </label>
                    <label>
                        <input type="hidden" name="filtrarSituacao" id="filtrarSituacao" value="false">
                    </label>
                </td>
            </tr>
            <tr> 
                <td colspan="10" class="TextoCampos"> <div align="center"> 
                        <% if (nivelUser
                                    >= 1) {%>
                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
                </td>
            </tr>
            <tr>
                <td>
    <form action="ServletUploadFatura?layout=cimentoNacional" method="post" target="pop" id="formularioImportacao" name="formularioImportacao" enctype="multipart/form-data">
        <table width="100%" border="0" class="bordaFina" align="center" id="tableImportacao" name="tableImportacao">
            
            <tr class="CelulaZebra2NoAlign">
                <td width="15%" align="right" class="TextoCampos"> Escolha o Layout: </td>
                <td width="10%" align="left" class="CelulaZebra2">
                    <select id="layout" class="inputTexto" name="layout">
                        <option value="cimentoNacional" selected >Cimento Nacional</option>
                        <option value="cbmc">CBMC</option>
                        <option value="elizabethCimento">Elizabeth Cimento</option>
                        <option value="gerdau">Gerdau S/A</option>
                        <option value="lasa">Lojas Americanas (LASA)</option>
                        <option value="wallmart">Wallmart</option>
                        <option value="walmartExcel">Wallmart (EXCEL)</option>
                        <option value="heinekenExcel">Heineken (EXCEL)</option>
                    </select>
                </td>
                <td width="15%" align="right" class="TextoCampos"> </td>
                <td width="20%" align="left" class="CelulaZebra2"> </td>
            </tr>
            <tr>
                <td width="15%" class="TextoCampos">Apenas o cliente:</td>
                <td width="25%" class="CelulaZebra2">
                    <strong>
                        <input name="clienteImportacao" type="text" id="clienteImportacao" class="inputReadOnly8pt" value="<%= (razaoSocialCliente!= null && (!razaoSocialCliente.equals("")) ? razaoSocialCliente : "") %>"
                               size="30" maxlength="80" readonly="true">
                        <input type="hidden" name="idClienteImportacao" id="idClienteImportacao" value="<%= (idCliente!= null && (!idCliente.equals("")) ? idCliente : 0) %>"/>
                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor" value="..." onClick="javascript:localizacliente('Cliente_Importacao');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:limparclifor(2);"> 
                    </strong>
                </td>
                <td width="15%" class="TextoCampos">Escolha o arquivo: </td>
                <td width="45%" id="tdInput" align="left" class="CelulaZebra2">
                    <input name="arquivoImportacao" id="arquivoImportacao" type="file" multiple="multiple" class="inputTexto" value="" size="50">
                </td>
            </tr>
             <tr> 
                <td colspan="9" class="TextoCampos"> 
                    <div align="center"> 
                        <% if (nivelUser >= 1) {%>
                        <input name="importar" type="button" class="botoes" id="importar" value="Importar" onClick="javascript:tryRequestToServer(function(){importarArquivo();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
    </form>
                </td>
            </tr>
            <tr>
                <td>
                    <br/>
        <form method="post" id="formBx" target="pop">
            <table width="100%" border="0" class="bordaFina">
                <tr class="tabela">
                    <td width="2%">
                        <div align="center">
                            <input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcaTodos();">
                            <input type="hidden" name="ids" id="ids" value=""/>
                        </div>
                    </td>
                    <td width="5%"><strong>Doc.Fisc</strong></td>
                    <td width="3%"><strong>Pc</strong></td>
                    <td width="3%"><strong>Sé.</strong></td>
                    <td width="15%"><strong>Cliente</strong></td>
                    <td width="8%"><strong>Vencim.</strong></td>
                    <td width="6%"><div align="right"><strong>Valor</strong></div></td>
                    <td width="6%"><strong>Fatura</strong></td>
                    <td width="7%"><div align="right"><strong>Vl Pago</strong></div></td>
                    <td width="5%"><strong>Doc&nbsp;<img src="img/add.gif" border="0" title="Repetir o primeiro documento para todas as linhas" class="imagemLink"  style="vertical-align:middle;"
                                                         onClick="javascript:atribuiValores('doc');"></strong></td>
                    <td width="18%"><strong>Histórico&nbsp;<font size="1"><img src="img/add.gif" border="0" title="Repetir o primeiro histórico para todas as linhas" class="imagemLink" style="vertical-align:middle;"
                                                                               onClick="javascript:atribuiValores('hist');"></font></strong></td>
                    <td width="8%"><strong>Pagam.</strong></td>
                    <td width="6%"><strong>Conta</strong></td>
                    <td width="3%">
                        <%if (nivelUser == 4 && request.getParameter("fatura") != null && !request.getParameter("fatura").trim().equals("")) {%>
                        <img src="img/lixo.png" alt="Excluir este registro" title="Excluir este registro" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:excluirFatura()});">
                        <%}%>  
                    </td>
                    <td width="3%">&nbsp;</td>
                    <td width="3%">&nbsp;</td>
                </tr>
                <% //variaveis da paginacao
                    int linha = 0;
                    // se conseguiu consultar

                    if ((acao.equals("consultar"))) {
                        //Apenas as duplicatadas agora
                        ResultSet rs = null;
                        boolean existe = false;
                        
                        if(faturaImportacaoArquivo != null || beanCteArquivoLasa != null){
                            String valorConsulta = "";
                            
                            if (beanCteArquivoLasa != null) {
                                dupls.setValorDaConsulta(beanCteArquivoLasa.getNumeroSerieCteString());
                                dupls.setFilial(String.valueOf(Apoio.getUsuario(request).getFilial().getId()));
                                dupls.setTipoConsulta(BeanConsultaFatura.NUMERO_SERIE_CTRC);
                            } else {
                                dupls.setValorDaConsulta(faturaImportacaoArquivo);
                                dupls.setTipoConsulta(BeanConsultaFatura.NUMERO_CTRC);
                                dupls.setFilial("0");
                            }

                            dupls.setIdConsignatario(Apoio.parseInt(idCliente));
                            dupls.setBaixado("todas");
                            dupls.setValor1(0);
                            dupls.setValor2(0);
                            dupls.setGrupo_id(0);
                            dupls.setTitulo("");
                            dupls.setOrdenacao("numero");

                            dupls.consultarBxReceberArquivo(null);
                            rs = dupls.getResultado();
                        }else if (dupls.consultarBxReceber(request.getParameter("ordenacao"))) {
                            rs = dupls.getResultado();
                        }

                        float percentAplicado = 0;
                        while (rs != null && rs.next()) {
                            existe = true;
                            //Apenas na primeira vez que entrar no laço
                            if (linha == 0 && !fatura.equals("")) {
                                float valordupls = rs.getFloat("totaldupls");
                                float valordesc = rs.getFloat("totaldesc");
                                percentAplicado = (valordesc * 100) / valordupls;
                            }
                            //pega o resto da divisao e testa se é par ou impar
                     %>
                     <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                    <td>
                        <div class="linkEditar" onClick="">
                            <input name="movim_<%=rs.getString("id_duplicata")%>" type="hidden" id="movim_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("sale_id")%>">  
                            <input name="baixado_<%=rs.getString("id_duplicata")%>" type="hidden" id="baixado_<%=rs.getString("id_duplicata")%>" value="<%=rs.getBoolean("is_baixado")%>">  
                            <input name="conciliado_<%=rs.getString("id_duplicata")%>" type="hidden" id="conciliado_<%=rs.getString("id_duplicata")%>" value="<%=rs.getBoolean("conciliado")%>">  
                            <input name="movBancoId_<%=rs.getString("id_duplicata")%>" type="hidden" id="movBancoId_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("idlancamento")%>">  
                            <input name="faturaId_<%=rs.getString("id_duplicata")%>" type="hidden" id="faturaId_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("fatura_cobranca_id")%>">  
                            <input name="chk_<%=linha%>" id="chk_<%=linha%>" type="checkbox" <%=(rs.getBoolean("is_baixado") ? "disabled=true" : "")%> value="<%=rs.getString("id_duplicata")%>" onClick="javascript:selectDup('chk_<%=linha%>');getTotalDup();">
                            <input name="situacao_<%=rs.getString("id_duplicata")%>" type="hidden" id="situacao_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("situacao_fatura")%>">
                            <input name="valorAcrescimo" type="hidden" id="valorAcrescimo" value="<%=rs.getString("acrescimo_fatura")%>">
                            <input name="numero_<%=linha%>" type="hidden" id="numero_<%=linha%>" value="<%=rs.getString("numero")%>">
                            
                            <input name="clienteID_<%=rs.getString("id_duplicata")%>" type="hidden" id="clienteID_<%=rs.getString("id_duplicata")%>" value="<%=rs.getInt("consignatario_id")%>">
                        </div>
                    </td>
                    <td><font size="1">
                        <%if (rs.getString("categoria").equals("ct") && nivelUserCtrc >= 1) {%>
                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("sale_id")%>');});">
                            <%=rs.getString("numero")%>
                        </div>
                        <%} else if (rs.getString("categoria").equals("ns") && nivelUserSale >= 1) {%>
                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verSale('<%=rs.getString("sale_id")%>');});">
                            <%=rs.getString("numero")%>
                        </div>
                        <%} else if (rs.getString("categoria").equals("fn") || rs.getString("categoria").equals("vv") && nivelUserSale >= 1) {%>
                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verReceita('<%=rs.getString("sale_id")%>');});">
                            <%=rs.getString("numero")%>
                        </div>
                        <%}%>
                        
                        <input type="hidden" name="numero_<%=rs.getString("id_duplicata")%>" id="numero_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("numero")%>">
                        <%=rs.getString("abreviatura")%>            
                        </font></td>
                    <td><div align="center"><font size="1"><%=rs.getString("duplicata") + "/" + rs.getString("total_pcs")%></font></div></td>
                    <td><div align="center"><font size="1"><%=rs.getString("serie")%></font></div></td>
                    <td><font size="1"><%=rs.getString("razaosocial")%></font></td>
                    <td><font size="1"><%=(rs.getDate("vence_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("vence_em")) : "")%></font></td>
                    <td><div align="right">
                            <input name="vldupl_<%=rs.getString("id_duplicata")%>" id="vldupl_<%=rs.getString("id_duplicata")%>" value="<%=Apoio.getDecimalFormat(rs.getString("valor"),false,2)%>" type="text" size="7" class="inputReadOnly8pt" readonly="true" maxlength="12" align="Right">
                        </div></td>
                        <td align="center"><font size="1"><%=(rs.getString("num_fatura") == null ? "" : rs.getString("num_fatura"))%></font>                           
                                <label><%=(rs.getString("situacao_status_fatura") == null ? "" : rs.getString("situacao_status_fatura"))%></label>                            
                        </td>
                            
                        <%if (rs.getBoolean("is_baixado")) {%>                     
                     <td>
                        <div align="right">
                             <font size="1"><%=Apoio.getDecimalFormat(rs.getString("valor_pago"),false,2)%></font>
                             <input type="hidden" id="vlpago_<%=rs.getString("id_duplicata")%>" name="vlpago_<%=rs.getString("id_duplicata")%>" value="">
                             <input name="idCtrc_<%=linha%>" id="idCtrc_<%=linha%>" value="<%=rs.getString("id_duplicata")%>" type="hidden">
                        </div>
                    </td>
                    <td><div align="left"><font size="1"><%=rs.getString("docum")%></font></div></td>
                    <td><div align="left"><font size="1"><%=rs.getString("historico")%></font></div></td>
                    <td><font size="1"><%=(rs.getDate("pago_em") != null ? formatador.format(rs.getDate("pago_em")) : "")%></font></td>
                    <td><div align="left"><font size="1"><%=rs.getString("conta")%></font></div></td>
                    <td>
                        <%if (nivelUser == 4) {%>
                        <img src="img/lixo.png" alt="Excluir este registro" title="Excluir este registro" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:excluir('<%=rs.getString("id_duplicata")%>','<%=(rs.getString("idlancamento") == null ? "0" : rs.getString("idlancamento"))%>','<%=rs.getString("situacao_fatura")%>',<%=rs.getBoolean("conciliado")%>)});">
                        <%}%>  
                    </td>
                    <td>
                        <%if (nivelUser == 4 && nivelUserConciliacao == 4) {%>
                        <img src="img/undo.gif" alt="Estornar essa baixa" title="Estornar essa baixa" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:estornar('<%=rs.getString("id_duplicata")%>','<%=rs.getString("idlancamento")%>')});"
                             width="21" height="22" border="0" align="right">
                        <%}%>  
                    </td>
                    <td>
                        <img src="img/pdf.jpg" alt="Imprimir recibo" title="Imprimir recibo" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:recibo('<%=rs.getString("id_duplicata")%>','<%=rs.getString("fatura_id")%>','<%=rs.getString("ano_fatura")%>')});"
                             width="19" height="19" border="0" align="right">
                    </td>
                         
                     <%if (!rs.getString("descricao_desconto").equals("")) {%>
                <tr class="celulaZebra2" name="trDescrDescnt_<%=rs.getString("id_duplicata")%>" id="trDescrDescnt_<%=rs.getString("id_duplicata")%>" style="">
                    <td colspan="16" style="text-align: center; "> Descrição do Desconto: <label><%=rs.getString("descricao_desconto")%></label> </td>
                </tr>
                         <%}%>
                
<%--                    <input style="font-size:8pt;" type="" name="descricaoDesconto" id="descricaoDesconto" value="<%=rs.getString("descricao_desconto")%>" class="fieldMin" size="30"/>--%>
                
                    <%} else {%>
                    <td><div align="right"><font size="1"> 
                            <input name="vlpago_<%=rs.getString("id_duplicata")%>" id="vlpago_<%=rs.getString("id_duplicata")%>" value="<%=(fatura.equals("") ? Apoio.getDecimalFormat(rs.getString("valor"),false,2) : Apoio.getDecimalFormat(Apoio.to_curr(rs.getFloat("valor") - (rs.getFloat("valor_desconto")) + (rs.getFloat("valor_acrescimo"))),false,2))%>" onBlur="javascript:colocarVirgulaOld(this,'0.00');getTotalDup();criaNovaPcs('<%=rs.getString("id_duplicata")%>');" type="text" size="7" class="fieldMin" style="display:<%=(rs.getString("situacao_fatura").equals("DT") ? "none" : "")%>" maxlength="12" align="Right">
                            <%=(rs.getString("situacao_fatura").equals("DT") ? "DESCONTADA" : "")%>
                            <input name="vlpagoaux_<%=rs.getString("id_duplicata")%>" type="hidden" id="vlpagoaux_<%=rs.getString("id_duplicata")%>" value="<%=Apoio.getDecimalFormat(rs.getString("valor"), false, 2)%>">
                            <input name="criapcs_<%=rs.getString("id_duplicata")%>" type="hidden" id="criapcs_<%=rs.getString("id_duplicata")%>" value="false">  
<%--                            <input name="dtnovapcs_<%=rs.getString("id_duplicata")%>" id="dtnovapcs_<%=rs.getString("id_duplicata")%>" value="<%=Apoio.getDataAtual()%>" onkeypress="fmtDate(this, event)" type="text" size="9" style="font-size:8pt;display:none" maxlength="12">--%>
                            <input name="idCtrc_<%=linha%>" id="idCtrc_<%=linha%>" value="<%=rs.getString("id_duplicata")%>" type="hidden">
                            </font></div>

                        </font></div>
                    </td>
                    <td>
                        <font size="1"> 
                        <input name="doc_<%=rs.getString("id_duplicata")%>" id="doc_<%=rs.getString("id_duplicata")%>" value="" type="text" size="5" class="fieldMin" maxlength="15" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');">
                        </font>
                    </td>
                    <td> <font size="1"> 
                        <input name="hist_<%=rs.getString("id_duplicata")%>" id="hist_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("deschistorico").trim()%>"  type="text" size="23" class="fieldMin" maxlength="120" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');">
                        <strong>
                            <input name="<%=rs.getString("id_duplicata")%>" type="button" class="botoes" id="<%=rs.getString("id_duplicata")%>" value="..." onClick="javascript:localizahist(this);">
                        </strong> </font> 
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                
                   
                    <%}%>
                <tr class="celulaZebra2" name="trVencParcel_<%=rs.getString("id_duplicata")%>" id="trVencParcel_<%=rs.getString("id_duplicata")%>" style="display: none;">
                    <td colspan="16" style="text-align: center; ">
                        Data de vencimento da nova parcela: <input name="dtnovapcs_<%=rs.getString("id_duplicata")%>" id="dtnovapcs_<%=rs.getString("id_duplicata")%>" value="<%=Apoio.getDataAtual()%>" onkeypress="fmtDate(this, event)" type="text" size="12" style="font-size:8pt;display:none" class="fieldMin" maxlength="12"> 
                        Descrição do Desconto: <input style="font-size:8pt;" type="text" name="descricaoDesconto_<%=rs.getString("id_duplicata")%>" id="descricaoDesconto_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("descricao_desconto")%>" class="fieldMin" size="30"/> 
                    </td>
                    
                </tr>
                <tr class="celulaZebra2" name="trDescrDescnt_<%=rs.getString("id_duplicata")%>" id="trDescrDescnt_<%=rs.getString("id_duplicata")%>" style="display: none;">
                    <td colspan="16" style="text-align: center; "> Descrição do Desconto: <input style="font-size:8pt;" type="text" name="descricaoDesconto_<%=rs.getString("id_duplicata")%>" id="descricaoDesconto_<%=rs.getString("id_duplicata")%>" value="<%=rs.getString("descricao_desconto")%>" class="fieldMin" size="30"/></td>
                </tr>
                
                    <%
                                linha++;
                            }
                        
                        if(faturaImportacaoArquivo!= null || beanCteArquivoLasa != null){
                            if (!rs.next()) {%>
                                <script>
                                    $("existeResultado").value = '<%=existe%>';
                                    if($("existeResultado").value == false || $("existeResultado").value == "false"){
                                        alert("Nenhuma Nota Fiscal encontrada!");
                                    }
                                </script>
                        <%  }
                        }
                        
                        
                        
                        }%>

                
                <input type="hidden" id="maxLinha" name="maxLinha" value="<%=linha%>">
        </table>
        </form>
                </td>
            </tr>
            <tr>
                <td>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr> 
                <td width="18%" class="TextoCampos"><div align="right">Data da baixa:</div>
                    <div align="right"></div></td>
                <td width="12%" class="CelulaZebra2"><font size="1">
                    <input name="dtpago" id="dtpago" value="<%=(request.getParameter("dtpago") == null ? Apoio.getDataAtual() : request.getParameter("dtpago"))%>" type="text" size="9" class="fieldDate" style="font-size:8pt;" maxlength="12"
                           onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </font></td>
                <td width="16%" class="TextoCampos">Conta para baixa:</td>
                <td width="18%" class="CelulaZebra2">
                    <select name="conta" id="conta" class="fieldMin">      
                        <option value="">Selecione</option>
                        <%                            //Carregando todas as contas cadastradas
                            BeanConsultaConta conta = new BeanConsultaConta();

                            conta.setConexao(Apoio.getUsuario(request).getConexao());
                            conta.mostraContas(
                                    (nivelUserCtrcFl >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                            ResultSet rsconta = conta.getResultado();
                            //carregando as contas num vetor

                            while (rsconta.next()) {%>
                        <option value="<%=rsconta.getString("idconta")%>" <%=((request.getParameter("conta") != null && request.getParameter("conta").equals(rsconta.getString("idconta")) ? "selected" : rsconta.getInt("idconta") == cfg.getConta_padrao_id().getIdConta() ? "selected" : ""))%>  ><%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%></option>
                        <%}%>                  
                    </select>	</td>
                <td colspan="2" class="TextoCampos"><div align="center"> 
                        <input name="chkconciliado" type="checkbox" id="chkconciliado" <%=(request.getParameter("chkconciliado") == null || request.getParameter("chkconciliado").equals("false") ? "" : "checked")%>>
                        Ao baixar, conciliar o mov. bancário.</div></td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos">Data da concilia&ccedil;&atilde;o </td>
                <td class="CelulaZebra2"><font size="1">
                    <input name="dtconciliacao" id="dtconciliacao" class="fieldDate" value="<%=(request.getParameter("dtconciliacao") == null ? Apoio.getDataAtual() : request.getParameter("dtconciliacao"))%>" type="text" size="9" style="font-size:8pt;" maxlength="12"
                           onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </font></td>
                <td class="CelulaZebra2">&nbsp;</td>
                <td colspan="2" class="TextoCampos">&nbsp;</td>
                <td class="CelulaZebra2">&nbsp;</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos">Forma de pagamento:</td>
                <td class="CelulaZebra2"><span class="CelulaZebra2">
                        <select name="fpag" id="fpag" onChange="verFpag();" class="fieldDate">
                            <%BeanConsultaFPag fpag = new BeanConsultaFPag();

                                fpag.setConexao(Apoio.getUsuario(request).getConexao());
                                fpag.MostrarTudo();
                                ResultSet rs = fpag.getResultado();

                                while (rs.next()) {%>
                            <option value="<%=rs.getString("idfpag")%>" style="background-color:#FFFFFF" <%=(request.getParameter("fpag") != null && request.getParameter("fpag").equals(rs.getString("idfpag")) ? "selected" : (rs.getString("descfpag").equals("Dinheiro") && request.getParameter("fpag") == null ? "Selected" : ""))%>><%=rs.getString("descfpag")%></option>
                            <%}%>
                        </select>
                    </span></td>
                <td class="CelulaZebra2">&nbsp;</td>
                <td colspan="2" class="TextoCampos">Em caso de estorno, informar a data de estorno aqui: </td>
                <td width="8%" class="CelulaZebra2"><font size="1">
                    <input name="dtestorno" id="dtestorno" value="<%=Apoio.getDataAtual()%>" class="fieldDate" type="text" size="9" style="font-size:8pt;" maxlength="12"
                           onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </font></td>
            </tr>
            <tr>
                <td colspan="5"><font size="10">
                    <table cellpadding="1" cellspacing="2" style="margin-left:15; display:none; " id="tableChqs">
                        <tr class="colorClear">
                            <td><img src="img/add.gif" border="0"
                                     onClick="addNewChq('tableChqs')"
                                     title="Adicionar um cheque" class="imagemLink"></td>
                            <td>Cheque</td>
                            <td>Banco</td>
                            <td></td>
                            <td>Valor</td>
                            <td>Data</td>
                            <td>Emitente</td>
                            <td>CPF/CNPJ</td>
                            <td>Observação</td>
                        </tr>
                    </table></font>		</td>
            </tr>
            <tr>
                <td class="TextoCampos">Total cheques: </td>
                <td class="CelulaZebra2"><input name="totalchq" id="totalchq" value="0.00" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="12" class="inputReadOnly8pt" readonly="true" maxlength="12" align="Right"></td>
                <td class="TextoCampos">Duplicatas selecionadas: </td>
                <td class="CelulaZebra2"><input name="totaldup" id="totaldup" value="0.00" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="12" class="inputReadOnly8pt" readonly="true" maxlength="12" align="Right"></td>
                <td colspan="2" class="TextoCampos">&nbsp;</td>
            </tr>
            <tr> 
                <td colspan="6" class="TextoCampos"> <div align="center"> 
                        <% if (nivelUser
                                    >= 2) {%>
                        <input name="baixar" type="button" class="botoes" id="baixar" value="Baixar" onClick="javascript:tryRequestToServer(function(){baixar(<%=linha%>);});">
                        <%}%>
                    </div></td>
            </tr>
        </table>
                </td>
            </tr>
        </table>
    </body>
</html>
 
