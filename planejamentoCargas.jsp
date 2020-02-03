<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="conhecimento.coleta.BeanColeta,
         veiculo.BeanConsultaVeiculo,
         conhecimento.coleta.BeanConsultaColeta,
         java.text.DecimalFormat,
         java.text.DecimalFormatSymbols,
         java.util.Locale,
         nucleo.Apoio,
         nucleo.BeanLocaliza,
	 nucleo.impressora.*,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         nucleo.BeanConfiguracao,
         java.util.Date" %>
        <script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
            BeanConsultaVeiculo beanveiculo = null;

            DecimalFormatSymbols dfs = new DecimalFormatSymbols(new Locale("pt", "BR"));
            dfs.setDecimalSeparator(',');
            DecimalFormat fmtvl = new DecimalFormat("#,##0.00", dfs);
            fmtvl.setDecimalSeparatorAlwaysShown(true);
            SimpleDateFormat formatador = new SimpleDateFormat("MM/dd/yyyy");


            int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);
            int nivelUserToFilial = (nivelUser > 0 ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
            int nivelUserCtrc = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
            int nivelNf = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
            String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }

            SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

            BeanConfiguracao cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            cfg.CarregaConfig();


//Iniciando Cookie
            String dataInicial = "";
            String dataFinal = "";
            String campoConsulta = "";
            String filial = "";
            String remetente = "";
            String idRemetente = "0";
            String destinatario = "";
            String idDestinatario = "0";
            String motorista = "";
            String idMotorista = "0";
            boolean emAtraso = true;

            campoConsulta = "dtsolicitacao";
            dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : fmt.format(new Date()));
            dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
            filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
            remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "Todos os clientes");
            idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0");
            destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "Todos os destinatarios");
            idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0");
            motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "Todos os motoristas");
            idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0");
            emAtraso = (request.getParameter("atraso") != null ? new Boolean(request.getParameter("atraso")) : true);

%>
<jsp:useBean id="consCol" class="conhecimento.coleta.BeanConsultaColeta" />
<%
            consCol.setCampoDeConsulta(campoConsulta);
            consCol.setDtEmissao1(Apoio.paraDate(dataInicial));
            consCol.setDtEmissao2(Apoio.paraDate(dataFinal));
            consCol.setIdFilialColeta(nivelUserToFilial > 0 && request.getParameter("filialId") != null ? Integer.parseInt(filial) : Apoio.getUsuario(request).getFilial().getIdfilial());
            consCol.setClienteId(Integer.parseInt(idRemetente));
            consCol.setDestinatarioId(Integer.parseInt(idDestinatario));
            consCol.setMotoristaId(Integer.parseInt(idMotorista));

            int idVeiculo = (request.getParameter("idveiculoVeic") == null || request.getParameter("idveiculoVeic").equals("") ? 0 : Integer.parseInt(request.getParameter("idveiculoVeic")));
            String placaVeiculo = (request.getParameter("placa") == null ? "" : request.getParameter("placa"));
            String dataAtual = (request.getParameter("dtveiculo") == null || request.getParameter("dtveiculo").equals("") ? fmt.format(new Date()) : request.getParameter("dtveiculo"));
            if (acao.equals("consultarVeiculo")) {
                beanveiculo = new BeanConsultaVeiculo();
                beanveiculo.setConexao(Apoio.getUsuario(request).getConexao());
            } else if (acao.equals("obter_sales")) {
                String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'" + request.getParameter("idcoleta") + ">";
                BeanConsultaColeta cols = new BeanConsultaColeta();
                cols.setConexao(Apoio.getUsuario(request).getConexao());
                cols.obterSales(Integer.parseInt(request.getParameter("idcoleta")));
                ResultSet co = cols.getResultado();
                int row = 0;

                while (co.next()) {
                    resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";


                    resultado += "<td width='2%' align='center'></td>"
                            + "<td width='5%' align='right'>CTRC: </td>"
                            + "<td width='13%'>";


                    if (co.getString("categoria").equals("ns") && nivelNf > 0) {
                        resultado += "<div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + co.getString("id_sale") + ",0);});'>";
                    } else if (co.getString("categoria").equals("ct") && nivelUserCtrc > 0) {
                        if (co.getInt("filial_id") == Apoio.getUsuario(request).getFilial().getIdfilial()) {
                            resultado += "<div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + co.getString("id_sale") + ",1);});'>";
                        } else if (co.getInt("filial_id") != Apoio.getUsuario(request).getFilial().getIdfilial() && nivelUserToFilial > 0) {
                            resultado += "<div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + co.getString("id_sale") + ",1);});'>";
                        }
                    }
                    resultado += co.getString("doc_fiscal") + "-" + co.getString("serie") + "</div></td>";
                    resultado += "<td width='30%'>Destinatário: " + co.getString("destinatario") + "</td>";
                    resultado += "<td width='20%'>Destino: " + co.getString("destino") + "-" + co.getString("uf_destino") + "</td>";
                    resultado += "<td width='15%'>Embarque: " + (co.getDate("embarque_em") == null ? "" : fmt.format(co.getDate("embarque_em"))) + "</td>";
                    resultado += "<td width='15%'>Frete: " + fmtvl.format(co.getDouble("total_receita")) + "</td>";
                    resultado += "</tr>";


                    //***************** nota fiscal
                    BeanConsultaColeta consultaNF = new BeanConsultaColeta();
                    consultaNF.setConexao(Apoio.getUsuario(request).getConexao());
                    String resultado_nf = "<tr>"
                            + "<td class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + "></td>"
                            + "<td colspan='5'>"
                            + "<table width='100%' border='0' class='bordaFina' id='tridNF_'" + request.getParameter("id_sale") + ">";
                    consultaNF.obterNotas(co.getInt("id_sale"));

                    resultado_nf += "<tr class='tabela'>"
                            + "<td width='6%'>NF</td>"
                            + "<td width='6%' align='right'>Valor</td>"
                            + "<td width='6%' align='right'>Peso</td> "
                            + "<td width='6%' align='right'>Volume</td> "
                            + "<td width='15%'>Agendada</td>"
                            + "<td width='23%'>OBS Agendamento</td>  "
                            + "<td width='15%'>Entregue</td>"
                            + "<td width='23%'>OBS Entrega</td>"
                            + "</tr>";

                    ResultSet nf = consultaNF.getResultado();
                    int rowNF = 0;
                    while (nf.next()) {
                        resultado_nf += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";

                        resultado_nf += "<td >" + nf.getString("numero") + "</td>";
                        resultado_nf += "<td align='right'>" + fmtvl.format(nf.getDouble("valor")) + "</td>";
                        resultado_nf += "<td align='right'>" + fmtvl.format(nf.getDouble("peso")) + "</td>";
                        resultado_nf += "<td align='right'>" + fmtvl.format(nf.getDouble("volume")) + "</td>";
                        resultado_nf += "<td >" + (nf.getDate("data_agenda") != null ? fmt.format(nf.getDate("data_agenda")) + " às " + nf.getString("hora_agenda") : "Não agendado") + "</td>";
                        resultado_nf += "<td >" + nf.getString("obs_agenda") + "</td>";
                        resultado_nf += "<td >" + (nf.getDate("entrega_em") != null ? fmt.format(nf.getDate("entrega_em")) + " às " + nf.getString("entrega_as") : "Não entregue") + "</td>";
                        resultado_nf += "<td >" + nf.getString("observacao_entrega") + "</td>";

                        resultado_nf += "</tr>";

                        rowNF++;
                    }

                    resultado_nf += "</table>"
                            + "</td>"
                            + "</tr>";

                    //***************** nota fiscal fim
                    resultado += resultado_nf;

                    row++;
                }

                if (row == 0) {
                    resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">"
                            + "<td width='100%'><b>Não há CTRCs na coleta.</b></td>"
                            + "</tr>";
                }

                resultado += "</table>";
                response.getWriter().append(resultado);

                response.getWriter().close();
            } else if (acao.equals("imprimir")) {
                String filialRel = " and p.filial_id = " + consCol.getIdFilialColeta() + " ";
                String condicoesRel = (emAtraso ? "AND ( pc.coleta_em is null and p.is_cancelada = false) or " : " and ");
                condicoesRel += " ((solicitada_em BETWEEN " + Apoio.SqlFix(formatador.format(consCol.getDtEmissao1()))
                        + " AND " + Apoio.SqlFix(formatador.format(consCol.getDtEmissao2())) + ")";
                condicoesRel += (consCol.getClienteId() == 0 ? "" : " AND p.cliente_id=" + consCol.getClienteId());
                condicoesRel += (consCol.getDestinatarioId() == 0 ? "" : " AND pc.destinatario_id=" + consCol.getDestinatarioId());
                condicoesRel += (consCol.getMotoristaId() == 0 ? "" : " AND pc.motorista_id=" + consCol.getMotoristaId()) + ")";
                String filtros = " Período selecionado de " + Apoio.SqlFix(formatador.format(consCol.getDtEmissao1())) + " Até " + Apoio.SqlFix(formatador.format(consCol.getDtEmissao2()));
                //Exportando
                java.util.Map param = new java.util.HashMap(2);
                param.put("FILIAL", filialRel);
                param.put("CONDICOES", condicoesRel);
                param.put("OPCOES", filtros);
                param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                request.setAttribute("map", param);

                request.setAttribute("rel", "planejamento_cargamod1");


                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
                dispacher.forward(request, response);
            }


%>



<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    
    function consultar(acao){
        if (!(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }

        document.location.replace("./planejamentoCargas.jsp?acao="+acao+"&atraso="+$("isAtraso").checked +"&"+
            concatFieldValue("dtemissao1,dtemissao2,"+
            "filialId,idremetente,rem_rzs,iddestinatario,dest_rzs,idmotorista,motor_nome,idveiculoVeic"));
    }

    function visualizarVeiculo(){

        var filtros = "";
//        filtros = concatFieldValue("idveiculoVeic,placa,dtveiculo");
        filtros = concatFieldValue("idveiculoVeic,placa");
        document.location.replace("./planejamentoCargas.jsp?acao=consultarVeiculo&"+filtros);

    }

    function aoCarregar(){
        if(<%=emAtraso%>){
            $("isAtraso").checked = true;
        }
    }

    function verCtrc(id){
        window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "CTRC" , "top=0,resizable=yes");
    }

    function editar(id){
        window.open("./cadcoleta?acao=editar&id="+id, "Coleta" , "top=0,resizable=yes,status=1,scrollbars=1");
    }

    function popColetaGeral(){

        //return alert("Em construção");

        if (!(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }

        launchPDF("./planejamentoCargas.jsp?acao=imprimir&modelo=1"+"&atraso="+$("isAtraso").checked +"&"+
            concatFieldValue("dtemissao1,dtemissao2,"+
            "filialId,idremetente,rem_rzs,iddestinatario,dest_rzs,idmotorista,motor_nome"));
    }

    function viewSales(idCol){
        function e(transport){
            var textoresposta = transport.responseText;
            //se deu algum erro na requisicao...
            if (textoresposta == "load=0") {
                return false;
            }else{
                Element.show("col_"+idCol);
                $("col_"+idCol).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
            }
        }//funcao e()
     
        if (Element.visible("col_"+idCol)){
            Element.toggle("col_"+idCol);
            $('plus_'+idCol).style.display = '';
            $('minus_'+idCol).style.display = 'none';
        }else{
            $('plus_'+idCol).style.display = 'none';
            $('minus_'+idCol).style.display = '';
            new Ajax.Request("./planejamentoCargas.jsp?acao=obter_sales&idcoleta="+idCol,{method:'post', onSuccess: e, onError: e});
        }

    }

    function editarSale(id,categ){
        if (categ == 1){
            window.open('./frameset_conhecimento?acao=editar&id='+id+'&ex=false', 'CTRC' , 'top=0,resizable=yes');
        }else{
            window.open('./cadvenda.jsp?acao=editar&id='+id+'&ex=false', 'NF_Servico' , 'top=0,resizable=yes');
        }
    }

</script>

<script language="JavaScript">

    function stAba(menu,conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    var arAbas = new Array();

    arAbas[0] = new stAba('tdCarta','divCarta');
    arAbas[1] = new stAba('tdVeiculo','divVeiculo');

    function AlternarAbas(menu,conteudo)
    {

        for (i=0;i<arAbas.length;i++)
        {
            m = document.getElementById(arAbas[i].menu);
            m.className = 'menu';
            c = document.getElementById(arAbas[i].conteudo)
            c.style.display = 'none';
        }
        m = document.getElementById(menu)
        m.className = 'menu-sel';
        c = document.getElementById(conteudo)
        c.style.display = '';

    }

    function carregar(){
    <% if (acao.equals("consultar") || acao.equals("iniciar")) {%>
            AlternarAbas('tdCarta','divCarta');
    <% } else {%>
            AlternarAbas('tdVeiculo','divVeiculo');
    <%                }
    %>
        }

        function editar(idColeta){
            if (<%=nivelUser > 0%>){
                window.open("./cadcoleta.jsp?acao=editar&id="+idColeta, "Coleta" , "top=0,resizable=yes,status=1,scrollbars=1");
            }else{
                alert("Você não tem privilégios suficientes para acessar a coleta.")
            }
        }

        function aoClicarNoLocaliza(idjanela){
            function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
            if (idjanela == "Consulta_Veiculo"){
                $('idveiculoVeic').value = $('idveiculo').value;
                $('placa').value = $('vei_placa').value;

                $('idveiculo').value = "0";
                $('vei_placa').value = "";
            }
        }
</script>

<%@page import="java.util.Vector"%>
<%@page import="filial.BeanFilial"%>
<html>
    <head>
        <style>

            body, table {
                font-family: Verdana, Arial, Helvetica, sans-serif;
                font-size: 10px;
                color: #000000;
            }

            .menu {
                font-family: Verdana, Arial, Helvetica, sans-serif;
                font-size: 10px;
                font-weight: normal;
                color: #000033;
                background-color: #FFFFFF;
                border-right: 1px solid #000000;
                border-left: 1px solid #000000;
                border-top: 1px solid #000000;
                border-bottom: 1px solid #000000;
                padding: 5px;
                cursor: hand;
            }

            .menu-sel {
                font-family: Verdana, Arial, Helvetica, sans-serif;
                font-size: 10px;
                font-weight: bold;
                color: #000033;
                background-color: #CCCCCC;
                border-right: 1px solid #000000;
                border-left: 1px solid #000000;
                border-top: 1px solid #000000;
                padding: 5px;
                cursor: hand;
            }

            .tb-conteudo {
                border-right: 1px solid #000000;
                border-bottom: 1px solid #000000;
            }

            .conteudo {
                font-family: Verdana, Arial, Helvetica, sans-serif;
                font-size: 10px;
                font-weight: normal;
                color: #000033;
                background-color: #F7F7F7;

                width: 100%;
                height: 100%;

            }

        </style>


        <script language="javascript" src="script/funcoes.js"></script>
        <script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Planejamento de carga</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 9px}
            -->
        </style>
    </head>

    <body onLoad="aoCarregar(); applyFormatter();carregar()">
        <img src="img/banner.gif" width="300" height="40">
        <br>
        <table width="100%" align="center" class="bordaFina" >
            <tr >
                <%    if (nivelUser > 0) {
                %>
                <td align="left"><b>Planejamento de carga</b></td>

                <%}
                %>
                <%    if (nivelUser >= 3){
                %>
                <td width="110"><input name="novo" type="button" class="botoes" id="novo"
                                        onClick="javascript:tryRequestToServer(function(){launchPopupLocate('./cadcoleta?acao=iniciar');});"
                                        value="Novo cadastro">
                  </td>
                <%}
                %>
            </tr>
        </table>
                        <br>
        <table  width="200%" class="bordaFina" >
            <tr>
                <!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ menu @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-->
                <td height="20" width="17%" class="menu" id="tdCarta"
                    onClick="AlternarAbas('tdCarta','divCarta')">
                    Coletas
                </td>
                <td height="20" width="17%" class="menu" id="tdVeiculo"
                    onClick="AlternarAbas('tdVeiculo','divVeiculo')">
                    Veículos disponíveis
                </td>
                <td height="20" width="66%" class="menu" id="tdNeutro">
                    
                </td>
            </tr>

            <tr>
                <td class="tb-conteudo" id="tdConteudo" colspan="6" align="left">
                    <!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ tdCarta @@@@@@@@@@@@@@@@@@@@@@ -->

                    <div id="divCarta" class="conteudo" style="display: none" >


                        <table width="100%" border="0" align="center" class="bordaFina">
                            <tr>
                                <td colspan="13">
                                    <table width="100%">
                                        <tr>
                                            <td width="55%">
                        <table width="100%" align="center" cellspacing="1" class="bordaFina">
                            <tr class="celula">
                                <td width="14%"  height="20" align="right">
                                    Solicitadas de:
                                </td>
                                <td width="8%">
                                    <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10"
                                           value="<%=fmt.format(consCol.getDtEmissao1())%>"
                                           onblur="alertInvalidDate(this)" class="fieldDate">
                                </td>
                                <td width="13%">
                                    <!-- Campo somente para consulta de intervalo de datas -->
                                    At&eacute;:
                                    <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10"
                                           value="<%=fmt.format(consCol.getDtEmissao2())%>"
                                           onblur="alertInvalidDate(this)" class="fieldDate" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">

                                </td>
                                <td width="15%">
                                    <div align="center">
                                        <select name="filialId" id="filialId" style="font-size:8pt;" class="inputtexto">
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
                                    </div></td>
                                <td width="35%" ><div align="center">
                                        <input name="isAtraso" type="checkbox" value="true" id="isAtraso">
                                        Mostrar coletas em atraso.
                                    </div></td>
                                <td width="15%" >
                                    <div align="center">
                                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                                               onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                        <tr>
                                            <td width="33%" class="celula"><input name="rem_rzs" type="text" id="rem_rzs" size="30" readonly="true" value="<%=remetente%>" class="inputReadOnly">
                                                <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente');">
                                                <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os clientes';">
                                                <input type="hidden" name="idremetente" id="idremetente" value="<%=idRemetente%>">
                                            </td>
                                            <td width="34%" class="celula"><input name="dest_rzs" type="text" id="dest_rzs" size="30" readonly="true" value="<%=destinatario%>" class="inputReadOnly">
                                                <strong>
                                                    <input name="localiza_rem2" type="button" class="botoes" id="localiza_rem2" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario');;">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';"></strong>
                                                <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=idDestinatario%>">
                                            </td>
                                            <td width="33%" class="celula"><input name="motor_nome" type="text" id="motor_nome" size="30" readonly="true" value="<%=motorista%>" class="inputReadOnly">
                                                <strong>
                                                    <input name="localiza_rem3" type="button" class="botoes" id="localiza_rem3" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista');;">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';getObj('motor_nome').value = 'Todos os motoristas';"></strong>
                                                <input type="hidden" name="idmotorista" id="idmotorista" value="<%=idMotorista%>">
                                            </td>
                                        </tr>
                                    </table></td>
                                <td class="celula">
                                    <div align="center">
                                        <input name="pesquisar" type="button" class="botoes" id="imprimir" value="Imprimir" title="Faz a pesquisa com os dados informados"
                                               onClick="javascript:tryRequestToServer(function(){popColetaGeral();});">
                                    </div>
                                </td>
                            </tr>
                        </table>
                                            </td>
                                            <td width="45%"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr class="tabela">
                                <td width="1%"></td>
                                <td width="4%">Número</td>
                                <td width="9%">Data</td>
                                <td width="12%">Motorista/Ve&iacute;culo</td>
                                <td width="12%">Remetente</td>
                                <td width="12%">Destinatário</td>
                                <td width="3%">CTRC</td>
                                <td width="6%">Status</td>
                                <td width="4%" align="right">Peso total</td>
                                <td width="4%" align="right">Volumes</td>
                                <td width="4%" align="right">Mercadoria</td>
                                <td width="4%" align="right">Valor frete</td>
                                <td width="6%" >Container</td>
                                <td width="19%" >Observação</td>
                            </tr>
                            <%        int linha = 0;
                                        int linhatotal = 0;
                                        int qtdCanc = 0, qtdAgCarr = 0, qtdCarrAnd = 0, qtdCarregado = 0, qtdEmTransito = 0, qtdEntregue = 0;
                                        String status;

                                        if (acao.equals("iniciar") || acao.equals("consultar")) {
                                            consCol.setConexao(Apoio.getConnectionFromUser(request));
                                            if (consCol.ConsultarPlanejamentoCarga(emAtraso)) {
                                                ResultSet r = consCol.getResultado();
                                                while (r.next()) {
                                                    status = "";

                            %>           <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                <td><img src="img/plus.jpg" id="plus_<%=r.getString("id_pedido")%>" name="plus_<%=r.getString("id_pedido")%>" title="Mostrar duplicatas" class="imagemLink" align="right"
                                         onclick="javascript:tryRequestToServer(function(){viewSales(<%=r.getString("id_pedido")%>);});">
                                    <img src="img/minus.jpg" id="minus_<%=r.getString("id_pedido")%>" name="minus_<%=r.getString("id_pedido")%>" title="Mostrar duplicatas" class="imagemLink" align="right" style="display:none "
                                         onclick="javascript:tryRequestToServer(function(){viewSales(<%=r.getString("id_pedido")%>);});"></td>
                                <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id_pedido")%>);});"><%=r.getString("numero")%></div>              </td>
                                <td>
                                    <span class="style1">
                                        Solicitação:<%=new SimpleDateFormat("dd/MM/yyyy").format(r.getDate("solicitada_em"))%><br>
                                        Programada para:<%=r.getDate("coleta_programada_em") == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(r.getDate("coleta_programada_em"))%>
                                    </span>
                                </td>
                                <td class="style1">
                                    <%=r.getString("motorista")%>
                                    <br>
                                    <%=r.getString("placa_veiculo") + (r.getString("placa_carreta").equals("") ? "" : "/" + r.getString("placa_carreta"))%>
                                    <br>
                                    Valor Frete:<%=fmtvl.format(r.getDouble("valor_combinado"))%>
                                    <br>
                                    Valor Carreteiro:<%=fmtvl.format(r.getDouble("valor_frete_carreteiro"))%>
                                </td>
                                <td class="style1">
                                    <%=r.getString("cliente")%>
                                    <br>
                                    <%=r.getString("cidade_origem") + (r.getString("uf_origem").equals("") ? "" : " - " + r.getString("uf_origem"))%>                </td>
                                <td class="style1">
                                    <%=r.getString("destinatario")%>
                                    <br>
                                    <%=r.getString("cidade_destino") + (r.getString("uf_destino").equals("") ? "" : "-" + r.getString("uf_destino"))%>                </td>
                                <td class="style1"><%=r.getString("ctrc")%></td>

                                <td class="style1">
                                    <% switch (r.getInt("status")) {
                                                                            case 1:
                                                                                status = "CANCELADA";
                                                                                qtdCanc++;
                                                                                break;
                                                                            case 2:
                                                                                status = "AGUARDANDO CARREGAMENTO";
                                                                                qtdAgCarr++;
                                                                                break;
                                                                            case 3:
                                                                                status = "CARREGAMENTO EM ANDAMENTO";
                                                                                qtdCarrAnd++;
                                                                                break;
                                                                            case 4:
                                                                                status = "CARREGADO(AGUARDANDO CTRC)";
                                                                                qtdCarregado++;
                                                                                break;
                                                                            case 5:
                                                                                status = "ENTREGUE";
                                                                                qtdEntregue++;
                                                                                break;
                                                                            default:
                                                                                status = "EM TRÂNSITO";
                                                                                qtdEmTransito++;
                                                                        }
                                    %>
                                    <%=status%>                </td>
                                <td align="right" class="style1"><%=fmtvl.format(r.getDouble("peso_total"))%></td>
                                <td align="right" class="style1"><%=fmtvl.format(r.getDouble("volume_total"))%></td>
                                <td align="right" class="style1"><%=fmtvl.format(r.getDouble("valor_mercadoria"))%></td>
                                <td align="right" class="style1"><%=fmtvl.format(r.getDouble("valor_frete_total"))%></td>
                                <td >
                                    <%=r.getString("numero_container")%><br>
                                    Genset:<%=r.getString("numero_genset")%><br>
                                    Pedido:<%=r.getString("pedido_cliente")%>
                                </td>
                                <td ><%=r.getString("obs")%></td>
                            </tr>
                            <tr style="display:none" id="col_<%=r.getString("id_pedido")%>">
                                <td rowspan="1" class='CelulaZebra1'></td>
                                <td rowspan="1" colspan="7">--</td>
                                <td rowspan="1" colspan="4"></td>
                            </tr>
                            <%
                                                    linha++;
                                                }

                                            }
                                        }
                            %>
                        </table>
                        <div align="left"><br>

                        </div>
                        <table width="20%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                            <tr>
                                <td colspan="2" class="tabela"><div align="center">Total de Cargas por Status</div></td>
                            </tr>
                            <tr>
                                <td width="72%" class="TextoCampos"><strong>Aguardando carregamento</strong></td>
                                <td width="28%" class="CelulaZebra2"><div align="center"><strong><%=qtdAgCarr%></strong></div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos"><strong>Carregamentos em andamento</strong></td>
                                <td class="CelulaZebra2"><div align="center"><strong><%=qtdCarrAnd%></strong></div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos"><strong>Carregadas(Aguardando CTRC)</strong></td>
                                <td class="CelulaZebra2"><div align="center"><strong><%=qtdCarregado%></strong></div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos"><strong>Em tr&acirc;nsito</strong></td>
                                <td class="CelulaZebra2"><div align="center"><strong><%=qtdEmTransito%></strong></div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos"><strong>Entregues</strong></td>
                                <td class="CelulaZebra2"><div align="center"><strong><%=qtdEntregue%></strong></div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos"><strong>Canceladas</strong></td>
                                <td class="CelulaZebra2"><div align="center"><strong><%=qtdCanc%></strong></div></td>
                            </tr>
                        </table>

                    </div>
                    <div id="divVeiculo" class="conteudo" style="display: none">

                        <table width="100%" align="center" cellspacing="1" class="bordaFina">
                            <tr>
                                <td colspan="12">
                                    <table width="100%">
                                        <tr>
                                            <td width="55%">
                        <table width="100%" align="center" cellspacing="1" class="bordaFina">

                            <tr class="celula">
                                <td width="158" align="right" >
                                    Apenas o veiculo:
                                </td>
                                <td width="233">
                                    <input type="hidden" id="idveiculoVeic" value="<%=idVeiculo%>">
                                    <input name="placa" type="text" class="inputReadOnly" id="placa" value="<%=placaVeiculo%>" size="10" readonly="true">
                                    <input type="hidden" id="idveiculo" name="idveiculo" value="0">
                                    <input name="vei_placa" type="hidden" class="inputReadOnly" id="vei_placa" value="0" size="10" readonly="true" style="font-size:8pt;background-color:#FFFFF1">
                                    <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Consulta_Veiculo')" value="...">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ve&iacute;culo" onClick="javascript:getObj('idveiculoVeic').value = 0;javascript:getObj('placa').value = '';">
                                </td>
                                </td>
                                <!--<td align="right" >Informe a data:</td>-->
<!--                                <td width="86">
                                    <input name="dtveiculo" type="text" id="dtveiculo" size="10" style="font-size:8pt;" maxlength="10" value="<%=dataAtual%>" onblur="alertInvalidDate(this)" class="fieldDate">
                                </td>-->
                                <td align="right" ></td>
                                <td width="86"></td>
                                <td width="105"></td>
                            </tr>
                            <tr class="celula">
                                <td  height="20" colspan="6">
                                    <div align="center">
                                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Visualizar" alt="Faz a pesquisa com os dados informados"
                                               onClick="javascript:tryRequestToServer(function(){visualizarVeiculo();});">
                                    </div>
                                </td>
                            </tr>
                        </table>
                                            </td>
                                            <td width="45%">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td width="10%" class="tabela">Motorista</td>
                                <td width="7%" class="tabela">Placa/Carreta</td>
                                <td width="3%" class="tabela">Coleta</td>
                                <td width="4%" class="tabela">Carreg.</td>
                                <td width="16%" class="tabela">Remetente/Origem</td>
                                <td width="16%" class="tabela">Destinatário/Destino</td>
                                <td width="4%" class="tabela">Chegada</td>
                                <td width="4%" class="tabela">Entrega</td>
                                <td width="3%" class="tabela">NF</td>
                                <td width="3%" class="tabela">CTRC</td>
                                <td width="4%" class="tabela">Valor</td>
                                <td width="26%" class="tabela">Obervação</td>
                            </tr>
                            <% //variaveis da paginacao
                                        int linhaV = 0;

                                        // se conseguiu consultar
                                        if (acao.equals("consultarVeiculo") && (beanveiculo.ConsultarVeiculo(idVeiculo, dataAtual))) {
                                            ResultSet rsV = beanveiculo.getResultado();
                                            while (rsV.next()) {
                                                //pega o resto da divisao e testa se é par ou impar
%> <tr class="<%=((linhaV % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                                <td class="style1"><%=rsV.getString("motorista")%></td>
                                <td class="style1"><%=rsV.getString("placa") + "/" + rsV.getString("carreta")%></td>
                                <td class="style1"><%=rsV.getString("coleta")%></td>
                                <td class="style1"><%=(rsV.getDate("coleta_em")==null?"":fmt.format(rsV.getDate("coleta_em")))%></td>
                                <td class="style1"><%=rsV.getString("remetente")%><br><%=rsV.getString("cidade_remetente") + "-" + rsV.getString("uf_remetente")%></td>
                                <td class="style1"><%=rsV.getString("destinatario")%><br><%=rsV.getString("cidade_destino") + "-" + rsV.getString("uf_destino")%></td>
                                <td class="style1"><%=(rsV.getDate("chegada_em")==null?"":fmt.format(rsV.getDate("chegada_em")))%><br> às <%=(rsV.getString("chegada_as")==null?"":rsV.getString("chegada_as"))%></td>
                                <td class="style1"><%=(rsV.getDate("entrega_em")==null?"":fmt.format(rsV.getDate("entrega_em")))%><br> às <%=(rsV.getString("entrega_as")==null?"":rsV.getString("entrega_as"))%></td>
                                <td class="style1"><%=rsV.getString("nf")%></td>
                                <td class="style1"><%=rsV.getString("ctrc")%></td>
                                <td class="style1"><%=fmtvl.format(rsV.getDouble("valor_combinado"))%></td>
                                <td class="style1"><%=rsV.getString("observacao_coleta")%></td>
                            </tr>
                            <% //se for a ultima linhaV
                                                linhaV++;
                                            }//while
                                        }//if
                            %>
                        </table>

                    </div>




                </td>
            </tr>
        </table>


    </body>
</html>