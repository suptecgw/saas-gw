<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="conhecimento.orcamento.BeanOrcamento,
         conhecimento.orcamento.BeanConsultaOrcamento,
         conhecimento.orcamento.BeanCadOrcamento,
         nucleo.Apoio,
         nucleo.impressora.*,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         java.util.Date" %>


<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanorcamento") : 0);

    String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
 
    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null)) {
        BeanCadOrcamento cadorc = new BeanCadOrcamento();
        cadorc.setConexao(Apoio.getUsuario(request).getConexao());
        cadorc.setExecutor(Apoio.getUsuario(request));
        cadorc.getOrcamento().setId(Integer.parseInt(request.getParameter("id")));
%><script language="javascript"><%
    if (!cadorc.Deleta()) {
    %>alert("Erro ao tentar excluir!");
    <%}%>
        location.replace("./consulta_orcamento.jsp?acao=iniciar");
</script><%}

//Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String filial = "";
    String status = "";
    String tipoCliente = "";
    String operadorConsulta = "";
    String limiteResultados = "";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;

    String idRemetente = "";
    String remetente = "";
    String idConsignatario = "";
    String consignatario = "";
    String idDestinatario = "";
    String destinatario = "";
    String teste = "";

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaOrcamento")) {
                consulta = cookies[i];
            } else if (cookies[i].getName().equals("operadorConsulta")) {
                operador = cookies[i];
            } else if (cookies[i].getName().equals("limiteConsulta")) {
                limite = cookies[i];
            }
            if (consulta != null && operador != null && limite != null) { //se já encontrou os cookies então saia
                break;
            }
        }
        if (consulta == null) {//se não achou o cookieu então inclua
            consulta = new Cookie("consultaOrcamento", "");
        }
        if (operador == null) {//se não achou o cookieu então inclua
            operador = new Cookie("operadorConsulta", "");
        }
        if (limite == null) {//se não achou o cookieu então inclua
            limite = new Cookie("limiteConsulta", "");
        }
        consulta.setMaxAge(60 * 60 * 24 * 90);
        operador.setMaxAge(60 * 60 * 24 * 90);
        limite.setMaxAge(60 * 60 * 24 * 90);

        String[] splitConsulta = URLDecoder.decode(consulta.getValue(), "ISO-8859-1").split("!!");

        String valor = (consulta.getValue().isEmpty() || splitConsulta.length < 1 ? "" : splitConsulta[0]);
        String campo = (consulta.getValue().isEmpty() || splitConsulta.length < 2 ? "" : splitConsulta[1]);
        String dt1 = (consulta.getValue().isEmpty() || splitConsulta.length < 3 ? fmt.format(new Date()) : splitConsulta[2]);
        String dt2 = (consulta.getValue().isEmpty() || splitConsulta.length < 4 ? fmt.format(new Date()) : splitConsulta[3]);
        String fl = (consulta.getValue().isEmpty() || splitConsulta.length < 5 ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : splitConsulta[4]);
        String rem = (consulta.getValue().isEmpty() || splitConsulta.length < 6 ? "Todos os remetentes" : splitConsulta[5]);
        String idRem = (consulta.getValue().isEmpty() || splitConsulta.length < 7 ? "0" : splitConsulta[6]);
        String des = (consulta.getValue().isEmpty() || splitConsulta.length < 8 ? "Todos os destinatarios" : splitConsulta[7]);
        String idDes = (consulta.getValue().isEmpty() || splitConsulta.length < 9 ? "0" : splitConsulta[8]);
        String con = (consulta.getValue().isEmpty() || splitConsulta.length < 10 ? "Todos os consignatarios" : splitConsulta[9]);
        String idCon = (consulta.getValue().isEmpty() || splitConsulta.length < 11 ? "0" : splitConsulta[10]);
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));

        idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : (idRem));

        remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : (rem));
        idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : (idDes));
        destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : (des));
        idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : (idCon));
        consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : (con));

        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "o.emissao_em" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        consulta.setValue(URLEncoder.encode(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" + filial + "!!"
                + remetente + "!!"
                + idRemetente + "!!"
                + destinatario + "!!"
                + idDestinatario + "!!"
                + consignatario + "!!"
                + idConsignatario, "ISO-8859-1"));
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);

    } else {
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("") ? request.getParameter("campoDeConsulta") : "dtsolicitacao");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));

        idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0");
        remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "Todos os remetentes");
        idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0");
        destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "Todos os destinatários");
        idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0");
        consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "Todos os consignatários");

        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? request.getParameter("operador") : "1");
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? request.getParameter("limiteResultados") : "10");


    }

//Finalizando Cookie

    BeanConsultaOrcamento consCol = new BeanConsultaOrcamento();

    consCol.setCampoDeConsulta(campoConsulta);
    consCol.setPaginaResultados(Integer.parseInt((request.getParameter("paginaResultados") == null ? "1" : request.getParameter("paginaResultados"))));
    consCol.setLimiteResultados(Integer.parseInt(limiteResultados));
    consCol.setOperador(Integer.parseInt(operadorConsulta));
    consCol.setValorDaConsulta(valorConsulta);
    consCol.setDtemissao1(Apoio.paraDate(dataInicial));
    consCol.setDtemissao2(Apoio.paraDate(dataFinal));
    consCol.setIdFilialColeta(request.getParameter("filialId") != null ? Integer.parseInt(filial) : Apoio.getUsuario(request).getFilial().getIdfilial());
    consCol.setStatus(request.getParameter("status") != null ? request.getParameter("status") : "todos");

    consCol.setIdRemetente(Integer.parseInt(idRemetente));
    consCol.setIdDestinatario(Integer.parseInt(idDestinatario));
    consCol.setIdConsignatario(Integer.parseInt(idConsignatario));

//exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        String condicao = "";
        condicao = request.getParameter("idorcamento");

        //Exportando
        java.util.Map param = new java.util.HashMap(1);
        String usuario = Apoio.getUsuario(request).getNome();
        param.put("ID_ORCAMENTO", condicao);
        param.put("OPCOES", "Usuário: "+ usuario);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        String model = request.getParameter("modelo");
        String relatorio = "";
        if (model.indexOf("personalizado") > -1) {

            relatorio = "doc_orcamento_" + model;

            request.setAttribute("rel", relatorio);

        } else {
            request.setAttribute("rel", "docorcamentomod" + request.getParameter("modelo"));
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }
    if (acao.equals("exportarSimulacao")) {
        String condicao = "";
        condicao = request.getParameter("simulacaoId");

        //Exportando
        java.util.Map param = new java.util.HashMap(1);
        String usuario = Apoio.getUsuario(request).getNome();
        param.put("ID_SIMULACAO", condicao);
        param.put("OPCOES", "Usuário: "+ usuario);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        String model = request.getParameter("modelo");
        String relatorio = "";
        request.setAttribute("rel", "doc_simulacao_frete_mod" + request.getParameter("modelo"));
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }
%>


<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
     
    function consultar(acao){
        if ($("campoDeConsulta").value == "o.emissao_em" && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }   

        document.location.replace("./consulta_orcamento.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? 
    <%=consCol.getPaginaResultados() + 1%> : (acao=='anterior'?<%=consCol.getPaginaResultados() - 1%>:1))+"&"+
                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,filialId,status,idremetente,rem_rzs,idconsignatario,con_rzs,iddestinatario,dest_rzs"));
    
        }

        function excluir(id){
            if (!confirm("Deseja mesmo excluir este orçamento?"))
                return null;

            document.location.replace("./consulta_orcamento.jsp?acao=excluir&id="+id);
        }

        function aoCarregar(){
            $("valorDaConsulta").focus();
            $("campoDeConsulta").value = "<%=(consCol.getCampoDeConsulta().equals("") ? "o.emissao_em" : consCol.getCampoDeConsulta())%>";
            $("operador").value = "<%=consCol.getOperador()%>";
            $("status").value = "<%=consCol.getStatus()%>";
            $("limiteResultados").value = "<%=consCol.getLimiteResultados()%>";

    <%  if (consCol.getCampoDeConsulta().equals("") || consCol.getCampoDeConsulta().equals("o.emissao_em")) {
    %>  	habilitaConsultaDePeriodo(true);
    <%  }
    %>
        }

        function editar(id){
            location.replace("./cadorcamento.jsp?acao=editar&id="+id);
        }

        function habilitaConsultaDePeriodo(opcao) {
            getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
            getObj("operador").style.display = (opcao ? "none" : "");
            getObj("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");
        }

        function popOrcamento(id){
            if (id == null)
                return null;
           
            launchPDF('./consulta_orcamento.jsp?acao=exportar&modelo=' + getObj('cbmodelo').value + '&idorcamento='+id,'orcamento'+id);
            
        }

        function getCheckeds(){
            var ids = "";
            for (i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked)
                    ids += ',' + getObj("ck" + i).value;

            return ids.substr(1);
        }
        
        function enviarEmail(idOrcamento) {
            var modelo = $("cbmodelo").value;

            function e(transport){
                var textoresposta = transport.responseText;

                if (textoresposta == "-1"){
                    alert('Houve algum problema ao requistar os percursos, favor tente novamente. ');
                    return false;
                }else{
                    var retorno = JSON.parse(textoresposta);
                    
                    if (retorno.enviaEmail != undefined) {
                        atualizarEmail(idOrcamento);
                        alert(retorno.enviaEmail);
                        espereEnviar("", false);
                    }else{
                        alert(retorno.erroEnviar);
                        espereEnviar("", false);
                    }
                    
                }
                
            }
            
            tryRequestToServer(function(){
                espereEnviar("Enviando...", true);
                new Ajax.Request("OrcamentoControlador?acao=enviarEmailOrcamento&idOrcamento="+idOrcamento+"&modelo="+modelo,{method:'post', onSuccess: e, onError: e});
            });
        }
 
 
        function atualizarEmail(idOrcamento){
            $("naoEnviado_"+idOrcamento).style.display = "none";
            $("jaEnviado_"+idOrcamento).style.display = "";
        }
 
        
</script>
<script language="javascript" src="script/funcoes.js"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>

<script>
    
    
    
</script>

<%@page import="filial.BeanFilial"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.net.URLEncoder" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Or&ccedil;amento</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="aoCarregar(); applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <%if (nivelUser >= 2) {%>
                <td width="547" align="left">
                    <b>Consulta de Or&ccedil;amento</b>
                </td>
                <td width="99">

                </td>
                <%}%>
                <%if (nivelUser >= 3) {%>
                <td width="97"></td>
                <%}
                    if (nivelUser >= 3) {%>
                <td width="110">
                    <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function(){document.location.replace('./cadorcamento.jsp?acao=iniciar');});"
                           value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="10%" >
                    <div align="right">
                        <select name="campoDeConsulta" style="font-size:8pt;" id="campoDeConsulta" class="inputtexto"
                                onChange="javascript:habilitaConsultaDePeriodo(this.value=='o.emissao_em');">
                            <option value="o.numero">N&uacute;mero</option>
                            <option value="o.emissao_em">Data de Emiss&atilde;o</option>
                            <option value="ori.cidade">Cidade de origem</option>
                            <option value="ori.uf">UF de origem</option>
                            <option value="des.cidade">Cidade de destino</option>
                            <option value="des.uf">UF de destino</option>
                        </select>
                    </div>
                </td>
                <td width="16%">
                    <select name="operador" id="operador" class="inputtexto" style="width: 190px;font-size:8pt">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (V&aacute;rios separados por v&iacute;rgula)</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10"
                               value="<%=fmt.format(consCol.getDtemissao1())%>" onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                </td>
                <td width="22%">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">At&eacute;:
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10"
                               value="<%=fmt.format(consCol.getDtemissao2())%>" onblur="alertInvalidDate(this)" class="fieldDate" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" style="font-size:8pt;" value="<%=consCol.getValorDaConsulta()%>" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
                </td>
                <td width="18%">
                    <div align="center">
                        <select name="filialId" id="filialId" class="fieldMin">
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                            %>
                            <!--%>-->
                            <option value="0">TODAS AS FILIAIS</option>
                            <%
                                while (rsFl.next()) {
                            %>
                            <option value="<%=rsFl.getString("idfilial")%>"
                                    <%=(filial.equals(rsFl.getString("idfilial")) ? "selected" : "")%>>APENAS A <%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                        </select>
                    </div>
                </td>
                <td width="10%" rowspan="2">
                    <div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                    </div>
                </td>
                <td width="20%" rowspan="2">
                    <div align="center"></div>
                    <div align="center">Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="fieldMin">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td   align="right" colspan="2">
                    Apenas o Status:
                </td>
                <td>
                    <div align="left">
                        <select name="status" id="status" class="fieldMin">
                            <option value="todos">Todos</option>
                            <option value="0">Em aberto</option>
                            <option value="1">Aprovado</option>
                            <option value="2">N&atilde;o aprovado</option>
                        </select>
                    </div>
                </td>
                <td></td>

            </tr>
            <tr class="celula" >
                <td td width="20%">
                    <input name="idremetente" type="hidden" id="idremetente" value="<%=idRemetente%>">
                    <input name="rem_rzs" type="text" id="rem_rzs" value="<%=remetente%>" size="20" readonly="true" class="inputReadOnly8pt">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');;">
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os remetentes';">

                </td>
                <td td width="20%">
                    <input name="iddestinatario" type="hidden" id="iddestinatario" value="<%=idDestinatario%>">
                    <input name="dest_rzs" type="text" id="dest_rzs" value="<%=destinatario%>" size="20" readonly="true" class="inputReadOnly8pt">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                </td>

                <td td width="20%">
                    <input name="idconsignatario" type="hidden" id="idconsignatario" value="<%=idConsignatario%>">
                    <input name="con_rzs" type="text" id="con_rzs" value="<%=consignatario%>" size="20" readonly="true" class="inputReadOnly8pt">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Consignatario_');">
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idconsignatario').value = '0';getObj('con_rzs').value = 'Todos os consignatarios';">
                </td>
                <td>
                </td>
                <td>
                </td>
                <td>
                </td>
            </tr>
        </table>
        <table width="90%" border="0" align="center" class="bordaFina">
            <tr class="tabela">
                <td width="2%">&nbsp;</td>
                <td width="6%">N&uacute;mero</td>
                <td width="7%">Emissao</td>
                <td width="20%">Cliente</td>
                <td width="12%">Origem</td>
                <td width="13%">Destino</td>
                <td width="12%">Filial</td>
                <td width="10%">Status</td>
                <td width="15%">Valor Or&ccedil;amento</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
            </tr>
            <%
                int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;

                if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                    consCol.setConexao(Apoio.getConnectionFromUser(request));
                    if (consCol.Consultar()) {
                        ResultSet r = consCol.getResultado();
                        while (r.next()) {
            %>           <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td>
                    <div align="center">
                        <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                             onClick="javascript:tryRequestToServer(function(){popOrcamento('<%=r.getString("id")%>');});">
                    </div>
                </td>
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id")%>);});">
                        <%=r.getString("numero")%>
                    </div>
                </td>
                <td><%=fmt.format(r.getDate("emissao_em"))%></td>
                <td><%=r.getString("cliente")%></td>
                <td><%=r.getString("cidade_origem") + (r.getString("uf_origem").equals("") ? "" : "-" + r.getString("uf_origem"))%></td>
                <td><%=r.getString("cidade_destino") + (r.getString("uf_destino").equals("") ? "" : "-" + r.getString("uf_destino"))%></td>
                <td><%=r.getString("filial")%></td>
                <td><%=r.getString("status")%></td>
                <td><div align="right"><%= r.getString("base_calculo_icms").replace(".", ",")%></div></td>
                <td>
                    <img src="img/out.png" id="naoEnviado_<%=r.getInt("id")%>" class="imagemLink"  title="Enviar Orçamento por e-mail" onClick="tryRequestToServer(function(){enviarEmail(<%=r.getInt("id")%>);});" style="display:<%=(!r.getBoolean("is_email_enviado") ? "" : "none")%>">
                    <img src="img/outc.png"  id="jaEnviado_<%=r.getInt("id")%>" class="imagemLink"  title="Reenviar Orçamento por e-mail" onClick="tryRequestToServer(function(){enviarEmail(<%=r.getInt("id")%>);});" style="display:<%=(r.getBoolean("is_email_enviado") ? "" : "none")%>">
                </td>
                <td>
                    <% if (nivelUser == 4 && r.getBoolean("pode_excluir")) {
                    %>    <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("id")%>);});">
                    <% }
                    %>
                </td>
            </tr>
            <%  if (r.isLast()) {
                                linhatotal = r.getInt("qtde_linhas");
                            }
                            linha++;
                        }

                        int limit = consCol.getLimiteResultados();
                        qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                    }
                }%>
        </table>
        <br>
        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="19%" height="10">
            <center>
                Ocorr&ecirc;ncias: 
                <b><%=linha%> / <%=linhatotal%></b>
            </center>
        </td>
        <td width="19%" height="11">
            <div align="center">
                P&aacute;ginas: 
                <b><%=(qtde_pag == 0 ? 0 : consCol.getPaginaResultados())%> / <%=qtde_pag%></b>
            </div>
        </td>
        <%if (consCol.getPaginaResultados() <= qtde_pag) {%>
        <td width="11%" rowspan="2" align="center">
            <input name="ANTERIOR" type="button" class="botoes" id="anterior"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
            
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
        </td>
        <%}%>
        <td align="right">Modelo de impress&atilde;o em PDF:
            <select name="cbmodelo" id="cbmodelo" class="inputtexto">
                <option value="1" selected>Modelo 1</option>
                <option value="2" >Modelo 2</option>
                <option value="3" >Modelo 3</option>
                <option value="4" >Modelo 4 (Aéreo)</option>
                <option value="5" >Modelo 5 (Simulação de Frete)</option>
                <option value="6" >Modelo 6</option>
                <%for (String rel : Apoio.listOrcamentos(request)) {%>
                <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase()%></option>
                <%}%>

            </select>
        </td>
    </tr>
</table>
</body>
</html>