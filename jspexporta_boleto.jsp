
<%@page import="nucleo.Conexao"%>
<%@page import="conhecimento.duplicata.fatura.BeanCadFatura"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="nucleo.Apoio,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         java.util.Date,
         mov_banco.conta.BeanConsultaConta" %>
<%@page import="nucleo.Apoio"%>
<script language="javascript" src="script/funcoes.js"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<%
    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanfatura") : 0);
    String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    int nivelCtrc = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelCtrcFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelNf = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    
    String codFaturas = "";

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
//Iniciando Cookie
    String filial = "";
    String campoConsulta = "";
    String valorConsulta = "";
    String anoFatura = "";
    String dataInicial = "";
    String dataFinal = "";
    String finalizada = "";
    String consignatario = "Todos";
    String idConsignatario = "0";
    String operadorConsulta = "";
//String limiteResultados = "";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;

    BeanConsultaFatura conFat = new BeanConsultaFatura();
    ResultSet r = null;

 //Carregando todas as contas cadastradas
    BeanConsultaConta contaSelc = new BeanConsultaConta();
    contaSelc.setConexao(Apoio.getUsuario(request).getConexao());
    contaSelc.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
    ResultSet rsconta = contaSelc.getResultado();
// FIM - Carregando todas as contas cadastradas
    
    BeanCadFatura beanCadFatura = new BeanCadFatura();
    beanCadFatura.setConexao(Apoio.getUsuario(request).getConexao());
    

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {

        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaExportaBoleto")) {
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
            consulta = new Cookie("consultaExportaBoleto", "");
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

        String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
        String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
        String ano = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[2]);
        String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
        String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[4]);
        String fl = (consulta.getValue().equals("") ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : consulta.getValue().split("!!")[5]);
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        anoFatura = (request.getParameter("anoFatura") != null ? request.getParameter("anoFatura") : (ano));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));

        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "vencimento_fatura" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
//        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
//                ? request.getParameter("limiteResultados")
//                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + anoFatura + "!!" + dataInicial + "!!" + dataFinal + "!!" + filial);
        operador.setValue(operadorConsulta);
//        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
    } else {
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta") : "vencimento_fatura");
        anoFatura = (request.getParameter("anoFatura") != null && !request.getParameter("anoFatura").trim().equals("")
                ? request.getParameter("anoFatura") : "");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador") : "1");
//        operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
//                ? request.getParameter("limiteResultados") : "10");
    }

//Finalizando Cookie
    conFat.setCampoDeConsulta(campoConsulta);
    conFat.setFilial(filial);
    conFat.setBaixado(finalizada);
//    conFat.setLimiteResultados(Integer.parseInt(limiteResultados));
    conFat.setOperador(Integer.parseInt(operadorConsulta));
    conFat.setValorDaConsulta(valorConsulta);
    conFat.setDataVenc1(dataInicial);
    conFat.setDataVenc2(dataFinal);
    conFat.setAnoFatura(anoFatura);
    conFat.setIdConsignatario(Integer.parseInt(idConsignatario));
    conFat.setPaginaResultados(request.getParameter("paginaResultados") == null ? 1 : Integer.parseInt(request.getParameter("paginaResultados")));

//conFat.consultarFaturaContaBoleto(conta);
    conFat.setConexao(Apoio.getConnectionFromUser(request));
    String conta = (request.getParameter("idConta") != null ? request.getParameter("idConta").split("!!")[0] : "");
    String tipoGerado = (request.getParameter("tipoGerado") != null ? request.getParameter("tipoGerado") : "todos");
    if (!conta.equals("")) {
        conFat.consultarFaturaContaBoleto(conta, tipoGerado);
        r = conFat.getResultado();
    }

    /*
     conFat.setCampoDeConsulta(campoConsulta);
     conFat.setBaixado(finalizada);
     conFat.setLimiteResultados(Integer.parseInt(limiteResultados));
     conFat.setOperador(Integer.parseInt(operadorConsulta));
     conFat.setValorDaConsulta(valorConsulta);
     conFat.setDataVenc1(dataInicial);
     conFat.setDataVenc2(dataFinal);
     conFat.setAnoFatura(anoFatura);
     conFat.setIdConsignatario(Integer.parseInt(idConsignatario));
     conFat.setPaginaResultados(request.getParameter("paginaResultados") == null ? 1 : Integer.parseInt(request.getParameter("paginaResultados")));
     */
    if (acao.equals("obter_ctrcs")) {
        conFat.setConexao(Apoio.getUsuario(request).getConexao());
        conFat.setCodFatura(request.getParameter("id"));
        if (conFat.consultaConhecimentos(0)) {;
            ResultSet ct = conFat.getResultado();
            int row = 0;
            boolean finalizado = false;
            String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'" + request.getParameter("idcarta") + ">"
                    + "<tr class='tabela'>"
                    + "<td width='8%'>Tipo</td>"
                    + "<td width='9%'>Nº doc.</td>"
                    + "<td width='2%'>PC</td>"
                    + "<td width='8%'>Emissao</td>"
                    + "<td width='12%'>Filial</td>"
                    + "<td width='27%'>Remetente</td>"
                    + "<td width='27%'>Destinatário</td>"
                    + "<td width='7%'><div align='right'>Valor</div></td>"
                    + "</tr>";
            while (ct.next()) {
                resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";
                resultado += "<td>" + (ct.getString("categoria").equals("ns") ? "NF Serviço" : "CTRC") + "</td>";
                if (ct.getString("categoria").equals("ns") && nivelNf > 0) {
                    resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + ct.getString("sale_id") + ",0);});'>";
                } else if (ct.getString("categoria").equals("ct") && nivelCtrc > 0) {
                    if (ct.getInt("filial_id") == Apoio.getUsuario(request).getFilial().getIdfilial()) {
                        resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + ct.getString("sale_id") + ",1);});'>";
                    } else if (ct.getInt("filial_id") != Apoio.getUsuario(request).getFilial().getIdfilial() && nivelCtrcFilial > 0) {
                        resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + ct.getString("sale_id") + ",1);});'>";
                    } else {
                        resultado += "<td>";
                    }
                } else {
                    resultado += "<td>";
                }
                resultado += ct.getString("doc") + "-" + ct.getString("serie") + "</div></td>";
                resultado += "<td>" + ct.getString("parcela") + "</td>";
                resultado += "<td>" + (ct.getDate("emissao_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(ct.getDate("emissao_em")) : "") + "</td>";
                resultado += "<td>" + ct.getString("filial") + "</td>";
                resultado += "<td>" + ct.getString("remetente") + "</td>";
                resultado += "<td>" + ct.getString("destinatario") + "</td>";
                resultado += "<td><div align='right'>" + new DecimalFormat("#,##0.00").format(ct.getFloat("valor_parcela")) + "</div></td>";
                resultado += "</tr>";
                row++;
            }
            resultado += "</table>";
            response.getWriter().append(resultado);
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    }

//se a acao eh exportar fatura para arquivo .pdf
    if (acao.equals("exportar")) {
        String codFatura = request.getParameter("codFatura");
        Map param = new java.util.HashMap(2);

        param.put("ID_FATURA", String.valueOf(codFatura));
        param.put("IDFILIAL_EMISSAO", String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        request.setAttribute("map", param);
        request.setAttribute("rel", "faturamod" + request.getParameter("modelo"));
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }

    if (acao.equals("exportarBoleto")) {
        String codFatura = request.getParameter("codFatura");
        response.sendRedirect("./BoletoServlet?acao=gerar&codFatura=" + codFatura);
    }
    
    

%>

<script type="text/javascript" language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    
    function consultar() {
        if (getObj("campoDeConsulta").value == "vencimento_fatura" && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value))) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }
        var idConta = $("conta").value;
        //var isNaoGerado = $("isNaoGerado").checked;
        document.location.replace("./jspexporta_boleto.jsp?acao=consultar" +
                "&idConta=" + idConta + "&" +
                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,dtemissao1,dtemissao2,anoFatura,tipoGerado"));

    }

    function excluir(id) {
        function ev(resp, st) {
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
                else
                    document.location.replace("./consultafatura?acao=iniciar");
            else
                alert("Status " + st + "\n\nNão conseguiu realizar o acesso ao servidor!");
        }

        if (!confirm("Deseja mesmo excluir esta fatura?"))
            return null;

        requisitaAjax("./fatura_cliente?acao=excluir&id=" + id, ev);
    }

    function aoCarregar() {
        getObj("campoDeConsulta").value = "<%=campoConsulta%>";
        getObj("operador").value = "<%=operadorConsulta%>";
        getObj("valorDaConsulta").value = "<%=valorConsulta%>";

    <%   if (conFat.getCampoDeConsulta().equals("") || conFat.getCampoDeConsulta().equals("vencimento_fatura") || conFat.getCampoDeConsulta().equals("emissao_fatura") || conFat.getCampoDeConsulta().equals("exportado_em") || conFat.getCampoDeConsulta().equals("mf.descontada_em")) {
    %>        habilitaConsultaDePeriodo(true);
    <%   }
    %>
    }


    function editar(id) {
        window.open("./fatura_cliente?acao=editar&id=" + id, "cadFatura", 'top=80,left=100, height=400,width=1000,resizable=yes,status=1,scrollbars=1');
        location.replace();
    }

    function editarSale(id, categ) {
        if (categ == 1) {
            window.open('./frameset_conhecimento?acao=editar&id=' + id + '&ex=false', 'CTRC', 'top=80,left=80,height=400,width=1000,resizable=yes,status=1,scrollbars=1');
        } else {
            window.open('./cadvenda.jsp?acao=editar&id=' + id + '&ex=false', 'NF_Servico', 'top=80,left=80,height=400,width=1000,resizable=yes,status=1,scrollbars=1');
        }
    }

    function habilitaConsultaDePeriodo(opcao) {
        getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
        getObj("anoFatura").style.display = (opcao ? "none" : "");
        getObj("operador").style.display = (opcao ? "none" : "");
        getObj("div1").style.display = (opcao ? "" : "none");
        //document.getElementById("div2").style.display = (opcao ? "" : "none");
    }

    function viewCtrcs(idFat) {
        function e(transport) {
            var textoresposta = transport.responseText;
            //se deu algum erro na requisicao...
            if (textoresposta == "load=0") {
                return false;
            } else {
                Element.show("trfat_" + idFat);
                $("trfat_" + idFat).childNodes[(isIE() ? 1 : 3)].innerHTML = textoresposta;
            }
        }//funcao e()
        if (Element.visible("trfat_" + idFat)) {
            Element.toggle("trfat_" + idFat);
            $('plus_' + idFat).className = 'imagemLink, show';
            $('minus_' + idFat).className = 'imagemLink, vanish';
        } else {
            $('plus_' + idFat).className = 'imagemLink, vanish';
            $('minus_' + idFat).className = 'imagemLink, show';
            new Ajax.Request("./consultafatura?acao=obter_ctrcs&id=" + idFat, {method: 'post', onSuccess: e, onError: e});
        }

    }

    function popFatura() {
        var codFat = getCheckedFaturas();
        if (codFat == '') {
            alert('Favor informar a(s) fatura(s) que deseja imprimir.');
        } else {
            pdf = window.open('./consultafatura?acao=exportar&modelo=' + $("cbmodelo").value + '&codFatura=' + codFat, 'fatura',
                    'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
        }
    }
    
    
    var dataDaycoval;
    
    function nomeArquivo(codFat) {
        var conta = $("conta").value;
        var banco = conta.split("!!")[1];
        var nomeArquivo = "";
        switch (banco) {

            case "237":
                nomeArquivo = "CB<%=Apoio.getFormatDataNoParentRemBrad()%>X.tst"
                break;
            case "341":
                nomeArquivo = "C<%=Apoio.getFormatDataNoParentRemItau()%>X.rem"
                break;
            case "104":
                nomeArquivo = "E<%=Apoio.getFormatDataNoParentRemCaixa()%>00001.rem"
                break;           
            default:
                nomeArquivo = "remessa.rem";

        }

        return nomeArquivo;

    }
        
    function popExportacao() {
        var codFat = getCheckedFaturas();
        var conta = $("conta").value;
         var banco = conta.split("!!")[1];
        if (codFat == '') {
            alert('Favor informar a(s) fauras(s) que deseja exportar.');
        } else {
            var nomeArq = nomeArquivo(codFat);
            
            pdf = window.open('./' + nomeArq + '?acao=exportar&faturas=' + codFat + '&conta=' + conta+"&banco="+banco, 'fatura',
                    'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
            
            requisitaAjax("./FaturaRastreabilidadeControlador?acao=arquivoRemessa&codFat=" + codFat, () => {console.log(true)});
        }
    }

    function getCheckedFaturas() {
        var ids = "";
        for (i = 0; getObj("ck" + i) != null; ++i)
            if (getObj("ck" + i).checked)
                ids += ',' + getObj("ck" + i).value;

        return ids.substr(1);
    }

    function exportarTextoMatricial() {
        var codFat = getCheckedFaturas();
        if (codFat == '') {
            alert('Favor informar a(s) fatura(s) que deseja imprimir.');
        } else {
            location.href = './servletMatricideFatura.ctrc?fatura=' + codFat + "&driverImpressora=" + $('driverImpressora').value +
                    "&caminho_impressora=" + $('caminho_impressora').value;
        }
    }

    function marcarTodos(check) {
        //$("lbTotalSelecionado").innerHTML = "0.00";
        var max = $("max").value;
        max = parseInt(max);
        for (var i = 0; i <= (max - 1); i++) {
            $("ck" + i).checked = check;
            calculaSelecao($("ck" + i), i);
        }

    }

    function calculaSelecao(che, linha) {
        var selecionado = parseFloat($("lbTotalSelecionado").innerHTML);
        if (che.checked) {
            selecionado += parseFloat($("valor_" + linha).value);
        } else {
            selecionado -= parseFloat($("valor_" + linha).value);
        }
        $("lbTotalSelecionado").innerHTML = formatoMoeda(selecionado);
    }

</script>
<%@page import="conhecimento.duplicata.fatura.BeanConsultaFatura"%>
<%@page import="nucleo.BeanLocaliza"%>

<%@page import="java.text.DecimalFormat"%>
<%@page import="nucleo.impressora.BeanConsultaImpressora"%>
<%@page import="java.util.Vector"%>
<%@page import="java.util.Map"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Geração De Arquivo De Remessa</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="aoCarregar();
            applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=idConsignatario%>">
        <table width="93%" align="center" class="bordaFina" >
            <tr >
                <%    if (nivelUser >= 2) {
                %>
                <td width="590" align="left"><b>Geração De Arquivo De Remessa</b></td>
                <%    }

                    if (nivelUser >= 3) {
                %>
                <td width="98"><input name="novo" type="button" class="botoes" id="novo"
                                      onClick="javascript:tryRequestToServer(function() {
                                                  document.location.replace('./fatura_cliente?acao=iniciar');
                                              });"
                                      value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="93%" align="center" cellspacing="1" class="bordaFina">
            <tr>
                <td width="8%" class="TextoCampos">Pesquisar por:</td>
                <td width="14%" class="CelulaZebra2">
                    <select name="campoDeConsulta" class="fieldMin" id="campoDeConsulta" style="width: 120px;"
                            onChange="javascript:habilitaConsultaDePeriodo(this.value == 'vencimento_fatura' || this.value == 'emissao_fatura' || this.value == 'exportado_em' || this.value == 'mf.descontada_em');">
                        <option value="numromaneio">Nº Fatura / Ano</option>
                        <option value="vencimento_fatura" selected>Vencimento</option>
                        <option value="emissao_fatura" selected>Data de Emissão</option>
                        <option value="mf.descontada_em" >Data do Borderô (Desconto da duplicata em factoring)</option>
                        <option value="exportado_em" >Data da Exportação</option>
                        <option value="lote_automatico" >Nº Lote</option>
                    </select> </td>
                <td width="20%" class="CelulaZebra2">
                    <select name="operador" id="operador" class="fieldMin">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">
                        De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10"
                               value="<%=dataInicial%>"
                               onblur="alertInvalidDate(this)" class="fieldDate" >
                        At&eacute;:
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10"
                               value="<%=dataFinal%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                        <input name="valorDaConsulta" type="text" id="valorDaConsulta" class="fieldMin" onKeyUp="javascript:if (event.keyCode == 13) $('pesquisar').click();" value="" size="10">
                        <input name="anoFatura" type="text" id="anoFatura" class="fieldMin" onKeyUp="javascript:if (event.keyCode == 13) $('pesquisar').click();" value="" size="4">               
                 </td>
                <td width="10%" class="TextoCampos">Conta:</td>
                <td width="10%" class="CelulaZebra2">
                    <select name="conta" id="conta" class="fieldMin" onChange="consultar()">
                        <%while (rsconta.next()) {%>
                        <option value="<%=rsconta.getString("idconta") + "!!" + rsconta.getString("cod_banco")%>" <%= (request.getParameter("idConta") != null && request.getParameter("idConta").split("!!")[0].equals(rsconta.getString("idconta")) ? "SELECTED" : "")%>>
                            <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%>
                        </option>
                        <%}%>
                    </select>
                </td>
                <td width="10%" class="TextoCampos">Apenas:</td>
                <td width="10%" class="CelulaZebra2">
                    <select name="tipoGerado" id="tipoGerado" class="fieldMin" onChange="consultar()">
                        <option value="todos" <%= (request.getParameter("tipoGerado") == null || request.getParameter("tipoGerado").equals("todos") ? "SELECTED" : "")%>>gerados / não gerados</option>
                        <option value="gerado" <%= (request.getParameter("tipoGerado") != null && request.getParameter("tipoGerado").equals("gerado") ? "SELECTED" : "")%>>gerados</option>
                        <option value="naoGerado" <%= (request.getParameter("tipoGerado") != null && request.getParameter("tipoGerado").equals("naoGerado") ? "SELECTED" : "")%>>não gerados</option>
                    </select>
                </td>
                <td width="20%" align="center" class="TextoCampos">
                    <div align ="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function() {
                                       consultar('consultar');
                                   });">
                    </div>
                </td>
            </tr>
        </table>
        <table width="93%" border="0" align="center" class="bordaFina">
            <tr class="tabela">
                <td width=""></td>
                <td width="">Fatura</td>
                <td width="">Nosso Número</td>
                <td width="">Emissão</td>
                <td width="%">Cliente</td>
                <td width="">Vencimento</td>
                <td width=""><div align="right">Valor</div></td>
                <td width="">
                    <input type="checkbox" name="marcaTodos" id="marcaTodos" onClick="marcarTodos(this.checked)"/>
                </td>
                <td width="">&nbsp;</td>
            </tr>
            <%int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;
                while (r != null && r.next()) {
            %>  
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td>
                    <img alt="plus"  src="img/plus.jpg" id="plus_<%=r.getString("fatura_id")%>" name="plus_<%=r.getString("fatura_id")%>" title="Mostrar duplicatas" class="imagemLink, show" align="middle"
                         onclick="javascript:viewCtrcs('<%=r.getString("fatura_id")%>');">
                    <img alt="minus" src="img/minus.jpg" id="minus_<%=r.getString("fatura_id")%>" name="minus_<%=r.getString("fatura_id")%>" title="Mostrar duplicatas" class="imagemLink, vanish" align="middle"
                         onclick="javascript:viewCtrcs('<%=r.getString("fatura_id")%>');">
                </td>
                <td>
                    <div class="linkEditar" 
                         onClick="javascript:tryRequestToServer(function() {
                             editar(<%=r.getInt("fatura_id")%>);
                            });">
                            <%=r.getString("numero_fatura") + "/" + r.getString("ano_fatura")%>
                    </div>
                </td>
                <td><%=r.getString("boleto_nosso_numero")%></td>
                <td><%=fmt.format(r.getDate("emissao_fatura"))%></td>
                <td><%=r.getString("consignatario")%></td>
                <td><%=(r.getDate("vencimento_fatura") != null ? fmt.format(r.getDate("vencimento_fatura")) : "C/ Apres.")%></td>
                <td>
                    <div align="right">
                        <%=new DecimalFormat("#,##0.00").format(r.getDouble("valor_fatura") - r.getDouble("desconto_fatura"))%>
                        <input type="hidden" name="<%="valor_" + linha%>" id="<%="valor_" + linha%>" value="<%=r.getDouble("valor_fatura") - r.getDouble("desconto_fatura")%>">
                    </div>
                </td>
                <td width="20">
                    <input name="ck<%=linha%>" type="checkbox" value="<%=r.getInt("fatura_id")%>" id="ck<%=linha%>" onClick="calculaSelecao(this,<%=linha%>)">
                </td>
                <td align="center">
                    <img src="img/real.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("356") ? "" : "none")%>">
                    <img src="img/bb.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("001") ? "" : "none")%>">
                    <img src="img/caixa.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("104") ? "" : "none")%>">
                    <img src="img/bradesco.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("237") ? "" : "none")%>">
                    <img src="img/unibanco.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("409") ? "" : "none")%>">
                    <img src="img/itau.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("341") ? "" : "none")%>">
                    <img src="img/santander.gif" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("033") ? "" : "none")%>">
                    <img src="img/daycoval.png" alt="<%=r.getString("banco")%>" style="display:<%=(r.getBoolean("is_gera_boleto") && r.getString("banco").equals("707") ? "" : "none")%>">
                </td>
            </tr>
            <tr style="display:none" id="trfat_<%=r.getString("fatura_id")%>" name="trfat_<%=r.getString("fatura_id")%>">
                <td rowspan="1" class='CelulaZebra1'></td>
                <td rowspan="1" colspan="11">--</td>
            </tr>


            <% if (r.isLast()) {
                        linhatotal = r.getInt("qtde_linhas");
                    }
                    linha++;
                }

                int limit = conFat.getLimiteResultados();
                qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);

            %>
            <input type="hidden" name="max" id="max" value="<%=linhatotal%>">
            <tr class="tabela">
                <td></td>
                <td></td>
                <td></td>
                <td colspan="2" align="right">Total Selecionado:</td>
                <td colspan="2" align="right"><label id="lbTotalSelecionado">0.00</label></td>
                <td></td>
                <td></td>
            </tr>
        </table>
        <br>
        <table width="93%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td height="21">
                    <div align="center">Ocorr&ecirc;ncias: <b><%=linha%></b>
                    </div>
                </td>
                <%if (conFat.getPaginaResultados() < qtde_pag) {%>
                <%}%>
                <td align="center" colspan="2">
                    <input type="button" class="botoes" value="Exportar Boletos" onClick="javascript:tryRequestToServer(function() {
                           popExportacao();
                     });" >
                </td>
            </tr>
        </table>
    </body>
</html>
