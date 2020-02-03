<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="mov_banco.conta.BeanConta"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("lanfatura") > 0);
            boolean temacessofiliais = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
            
            boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
            int idUsuario = Apoio.getUsuario(request).getIdusuario();

            String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

            //exportacao da Cartafrete para arquivo .pdf
            if (acao.equals("exportar")) {
                SimpleDateFormat formatador = new SimpleDateFormat("MM-dd-yyyy");
                String cliente = "";
                String fatura = "";
                String ano_fatura = "";
                String tipoData = "";
                String tipoData2 = "";
                String idFilial = "";
                String serieCtrc = "";
                String ordenacao = (request.getParameter("ordenacao").equals("f") ? "ordem" : "firma,ordem");
                String conta = "";
                String criterioDataSecundario = "";
                String filtroTipoData2="";
                String modelo = request.getParameter("modelo");
                String sqlTipoCobranca = "";
                String tipoCobranca = request.getParameter("tipoCobranca");
                String statusFatura = "";
                String mostrarCteSemFaturas = "";
                
                if (request.getParameter("modelo").equals("1")){
                    tipoData = request.getParameter("tipodata");
                    tipoData2 = request.getParameter("tipodata2");
                    cliente = (!request.getParameter("idconsignatario").equals("0") ? "and idconsignatario=" + request.getParameter("idconsignatario") : "");
                    fatura = (!request.getParameter("fatura").equals("") ? "and fatura::varchar='" + request.getParameter("fatura") + "'" : "");
                    ano_fatura = (!request.getParameter("anofatura").equals("") ? "and ano_fatura::varchar='" + request.getParameter("anofatura") + "'" : "");
                    if(request.getParameter("filiais").equals("fc")){
                        idFilial = (!request.getParameter("idfilial").equals("0") ? " and idfilial_emissao=" + request.getParameter("idfilial") : "");                        
                    }else if(request.getParameter("filiais").equals("fct")){
                        idFilial = (!request.getParameter("idfilial").equals("0") ? " and filial_sale_id=" + request.getParameter("idfilial") : "");                        
                    }
                    serieCtrc = (!request.getParameter("serieCtrc").equals("") ? " and serie_ctrc = '"+ request.getParameter("serieCtrc")+"'" : "");
                    conta = (!request.getParameter("contaBancaria").equals("0") ? " AND vfat.conta_fatura=" + request.getParameter("contaBancaria") : "");
                    if (Apoio.parseBoolean(request.getParameter("chkCriterio"))){
                        criterioDataSecundario = " " + request.getParameter("tipoCondicao") + " " + 
                                         request.getParameter("tipodata2") + 
                                         " between '" + formatador.format(Apoio.paraDate(request.getParameter("dtinicial2"))) + "' AND '" + formatador.format(Apoio.paraDate(request.getParameter("dtfinal2"))) + "' ";
                    }
                    if (Apoio.parseBoolean(request.getParameter("chkCriterio"))){
                        if (request.getParameter("tipoCondicao").equals("AND")){
                            filtroTipoData2 = " E ";
                        }else{
                            filtroTipoData2 = " OU ";
                        }
                        if(request.getParameter("tipodata2").equals("dtemissao")){
                            filtroTipoData2 +=  "Data de Emissão do Conhecimento." ;
                        }else if(request.getParameter("tipodata2").equals("dtvenc")){
                            filtroTipoData2 +=  "Data de Vencimento";
                        }else if(request.getParameter("tipodata2").equals("emissao_fatura")){
                            filtroTipoData2 +=  "Data de Emissão da Fatura";
                        }
                        filtroTipoData2 += " entre " + request.getParameter("dtinicial2") + " e " + request.getParameter("dtfinal2") + " ";
                    }
                }else{
                    tipoData = (request.getParameter("tipodata").equals("dtvenc") ? "ft.vence_em" : request.getParameter("tipodata").equals("emissao_fatura") ? "ft.emissao_em" : "s.emissao_em");
                    cliente = (!request.getParameter("idconsignatario").equals("0") ? "and consignatario_id=" + request.getParameter("idconsignatario") : "");
                    fatura = (!request.getParameter("fatura").equals("") ? "and ft.numero::varchar='" + request.getParameter("fatura") + "'" : "");
                    ano_fatura = (!request.getParameter("anofatura").equals("") ? "and ft.ano_fatura::varchar='" + request.getParameter("anofatura") + "'" : "");
                    idFilial = (!request.getParameter("idfilial").equals("0") ? " and ft.filial_cobranca_id=" + request.getParameter("idfilial") : "");
                    serieCtrc = (!request.getParameter("serieCtrc").equals("") ? " and s.serie = '"+ request.getParameter("serieCtrc")+"'" : "");
                    conta = (!request.getParameter("contaBancaria").equals("0") ? " AND ft.conta_id=" + request.getParameter("contaBancaria") : "");
                }
                //filtro do tipo da data
                String filtroTipoData="";
                if(request.getParameter("tipodata").equals("dtemissao")){
                    filtroTipoData =  "Data de Emissão do Conhecimento." ;
                }else if(request.getParameter("tipodata").equals("dtvenc")){
                    filtroTipoData =  "Data de Vencimento";
                }else if(request.getParameter("tipodata").equals("emissao_fatura")){
                    filtroTipoData =  "Data de Emissão da Fatura";
                }
                

                String tipoTomador = request.getParameter("tipoFrete");
                String sqlTipoTomador = "";
                if (modelo.equals("1")){
                    sqlTipoTomador = (tipoTomador.trim().equals("")?"": " AND tipo_tomador_servico = '"+tipoTomador+"' ");
                    //TIpo de Cobrança
                    sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
                }else if (modelo.equals("2")){
                    //Tipo do tomador
                    if (tipoTomador.equals("CIF")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.remetente_id ";
                    }else if (tipoTomador.equals("FOB")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.destinatario_id ";
                    }else if (tipoTomador.equals("RED")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.redespacho_id ";
                    }else if (tipoTomador.equals("FOB")){
                        sqlTipoTomador = " AND s.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,ct.redespacho_id) ";
                    }else{
                        sqlTipoTomador = "";
                    }
                    //TIpo de Cobrança
                    sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
                }else if (modelo.equals("3")){
                    if (tipoTomador.equals("CIF")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.remetente_id ";
                    }else if (tipoTomador.equals("FOB")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.destinatario_id ";
                    }else if (tipoTomador.equals("RED")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.redespacho_id ";
                    }else if (tipoTomador.equals("FOB")){
                        sqlTipoTomador = " AND s.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,ct.redespacho_id) ";
                    }else{
                        sqlTipoTomador = "";
                    }
                    //TIpo de Cobrança
                    sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
                }else if (modelo.equals("4")){
                    if (tipoTomador.equals("CIF")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.remetente_id ";
                    }else if (tipoTomador.equals("FOB")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.destinatario_id ";
                    }else if (tipoTomador.equals("RED")){
                        sqlTipoTomador = " AND s.consignatario_id = ct.redespacho_id ";
                    }else if (tipoTomador.equals("FOB")){
                        sqlTipoTomador = " AND s.consignatario_id NOT IN (ct.remetente_id,ct.destinatario_id,ct.redespacho_id) ";
                    }else{
                        sqlTipoTomador = "";
                    }
                    //TIpo de Cobrança
                    sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
                }
                
                // Filtros para o modelo 5                
                if(modelo.equals("5")){
                    
                    if(request.getParameter("tipodata").equals("dtvenc")){
                        tipoData = "vencimento_fatura";
                    }
                    if(request.getParameter("tipodata").equals("emissao_fatura")){
                        tipoData = "emissao_fatura";
                    }
                    if(request.getParameter("tipodata").equals("dtemissao")){
                        tipoData = "dtemissao";
                    }
                    if(!request.getParameter("idconsignatario").equals("0")){
                        cliente = " AND id_cliente = " + request.getParameter("idconsignatario");
                    }
                    if(!request.getParameter("idfilial").equals("0")){
                        idFilial = " AND id_filial = " + request.getParameter("idfilial");
                    }                    
                    if(!request.getParameter("fatura").equals("")){
                        fatura = " and numero_fatura::varchar='" + request.getParameter("fatura") + "'";                                                
                    }
                    if (!request.getParameter("serieCtrc").equals("")){
                        serieCtrc = " and serie_ctrcs = UPPER('" + request.getParameter("serieCtrc") + "')";
                    }                    
                    if(!request.getParameter("contaBancaria").equals("0")){
                        conta = " and conta_fatura_id= " + request.getParameter("contaBancaria");
                    }                    
                    if(!request.getParameter("tipoFrete").equals("")){
                        tipoTomador = request.getParameter("tipoFrete");
                        
                        if (tipoTomador.equals("CIF")){
                            sqlTipoTomador = " AND id_consignatario = ctrc_remetente_id ";
                        }else if (tipoTomador.equals("FOB")){
                            sqlTipoTomador = " AND id_consignatario = ctrc_destinatario_id ";
                        }else if (tipoTomador.equals("RED")){
                            sqlTipoTomador = " AND id_consignatario = ctrc_redespacho_id ";
                        }else if (tipoTomador.equals("FOB")){
                            sqlTipoTomador = " AND id_consignatario NOT IN (ctrc_remetente_id,ctrc_destinatario_id,ctrc_redespacho_id) ";
                        }else{
                            sqlTipoTomador = "";
                        }
                    }
                    //TIpo de Cobrança
                    sqlTipoCobranca = (tipoCobranca.equals("") ? "" : (tipoCobranca.equals("b") ? " AND is_gera_boleto " : " AND NOT is_gera_boleto " ));
                    
                    
                    // Status Fatura, novos filtros
                    boolean chkQuitada = Boolean.parseBoolean(request.getParameter("chkQuitada"));
                    boolean chkAberta = Boolean.parseBoolean(request.getParameter("chkAberta"));
                    boolean chkParcial = Boolean.parseBoolean(request.getParameter("chkParcial"));
                    String valorQuitada = "{t}";
                    String valorAberta = "{f}";
                    String valorParcial = "{f,t}";
                    if(chkQuitada){
                        statusFatura = " AND status_parcela IN ('" + valorQuitada + "')";
                    }
                    if(chkAberta){
                        statusFatura = " AND status_parcela IN ('" + valorAberta + "')";
                    }
                    if(chkParcial){
                        statusFatura = " AND status_parcela IN ('" + valorParcial + "')";
                    }
                    if(chkQuitada && chkAberta){
                        statusFatura = " AND status_parcela IN ('" + valorQuitada + "','" + valorAberta + "')";
                    }
                    if(chkQuitada && chkParcial){
                        statusFatura = " AND status_parcela IN ('" + valorQuitada + "','" + valorParcial + "')";
                    }
                    if(chkAberta && chkParcial){
                        statusFatura = " AND status_parcela IN ('" + valorAberta + "','" + valorParcial + "')";
                    }
                    if(chkQuitada && chkAberta && chkParcial){
                        statusFatura = " AND status_parcela IN ('" + valorQuitada + "','" + valorAberta + "','" + valorParcial + "')";
                    }                  
                    
                }
                
                if(modelo.equals("1")){
                    if(request.getParameter("chkMostrarCteSemFaturas").equals("false")){
                        mostrarCteSemFaturas = "and fatura_id is not null";
                    }
                }
                
                //Verificando se vai filtrar apenas um ano fatura
                java.util.Map param = new java.util.HashMap(11);
                param.put("DTINICIAL", "'" + formatador.format(Apoio.paraDate(request.getParameter("dtinicial"))) + "'");
                param.put("DTFINAL", "'" + formatador.format(Apoio.paraDate(request.getParameter("dtfinal"))) + "'");
                param.put("IDFILIAL", idFilial);
                param.put("IDCONSIGNATARIO", cliente);
                param.put("ANALITICO", request.getParameter("chkModelo1Sintetico"));
                param.put("NUM_FATURA", fatura);
                param.put("SERIE_CTRC", serieCtrc);
                param.put("ANO_FATURA", ano_fatura);
                param.put("OPCOES", "Consulta por: " + filtroTipoData + ". Período selecionado: " + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") + filtroTipoData2 + "." + (!request.getParameter("serieCtrc").equals("")?"Apenas CTRCs da Série: " +request.getParameter("serieCtrc") + "." : "Todas as series."));
                param.put("TIPO_DATA", tipoData);
                param.put("ORDENACAO", ordenacao);
                param.put("ID_CONTA", conta);
                param.put("CRITERIO_DATA_2", criterioDataSecundario);
                param.put("TIPO_TOMADOR", sqlTipoTomador);
                param.put("TIPO_COBRANCA", sqlTipoCobranca);
                param.put("STATUS_FATURA", statusFatura);
                param.put("CTE_SEM_FATURAS", mostrarCteSemFaturas);
                param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                
                request.setAttribute("map", param);
                request.setAttribute("rel", "relfaturamod" + request.getParameter("modelo"));

                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
                dispacher.forward(request, response);
            }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_FATURAR_BOLETO_RELATORIO.ordinal());
    }  

%>


<script language="javascript" type="text/javascript">
    
    function aoClicarNoLocaliza(idJanela){
        var filial = $('filiais').value;
        if(idJanela == "Filial"){
            if(filial == "fc"){
                $('trMostarCteSemFaturas').style.display = "none";
            }
        }
    }
    
    function voltar(){
        location.replace("./menu");
    }

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Consignatario_Fatura',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparclifor(){
        document.getElementById("idconsignatario").value = "0";
        document.getElementById("con_rzs").value = "";
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparfilial(){
        document.getElementById("idfilial").value = 0;
        document.getElementById("fi_abreviatura").value = "";
    }

    function popRel(){
        var modelo;
        if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else{
            //    if (document.getElementById("modelo1").checked)
            if (getObj("modelo1").checked)
                modelo = '1';
            else if (getObj("modelo2").checked)
                modelo = '2';
            else if (getObj("modelo3").checked)
                modelo = '3';
            else if (getObj("modelo4").checked)
                modelo = '4';
            else if (getObj("modelo5").checked)
                modelo = '5';
            
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";

            var tipoCobranca;
            if ($('tipoCobranca1').checked){
                tipoCobranca = '';
            }else if ($('tipoCobranca2').checked){
                tipoCobranca = 'c';
            }else{
                tipoCobranca = 'b';
            }    
            
            launchPDF('./relfaturas.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&idconsignatario='+$("idconsignatario").value+
                '&idfilial='+$("idfilial").value+'&chkModelo1Sintetico='+$("chkModelo1Sintetico").checked+
                '&chkCriterio='+$("chkCriterio").checked+'&tipoCondicao='+$('tipoCondicao').value +'&tipoFrete='+$('tipoFrete').value+
                '&fatura='+$("fatura").value+'&anofatura='+$("anofatura").value+
                '&tipodata='+$("tipodata").value+'&dtinicial='+$("dtinicial").value+'&dtfinal='+$("dtfinal").value + 
                '&tipodata2='+$("tipodata2").value+'&dtinicial2='+$("dtinicial2").value+'&dtfinal2='+$("dtfinal2").value + 
                '&serieCtrc=' + $("serieCtrc").value + '&ordenacao='+$("ordenacao").value + '&contaBancaria=' + $("contaBancaria").value +
                '&tipoCobranca='+tipoCobranca + '&chkQuitada='+$("chkQuitada").checked + '&chkAberta='+$("chkAberta").checked +
                '&chkParcial=' + $("chkParcial").checked + '&chkMostrarCteSemFaturas='+$("chkMostrarCteSemFaturas").checked + '&filiais=' + $("filiais").value);
        }
    }

    function modelos(modelo){
        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("modelo5").checked = false;

        $("modelo"+modelo).checked = true;
        
        viewCriterios(false);
        
    }

    function viewCriterios(isMostra){
        if ($('modelo1').checked){
            if (isMostra){
                $('trCriterios').style.display = '';
                $('plus').style.display = 'none';
                $('minus').style.display = '';
            }else{
                $('trCriterios').style.display = 'none';
                $('plus').style.display = '';
                $('minus').style.display = 'none';
            }
        }else{
            $('trCriterios').style.display = 'none';
            $('plus').style.display = '';
            $('minus').style.display = 'none';
        }
        if($('modelo1').checked){
            $('trMostarCteSemFaturas').style.display = "";
            $('tdCriterioFilial1').style.display = "";
            $('tdCriterioFilial2').style.display = "none";
        }else if($('modelo2').checked){
            $('trMostarCteSemFaturas').style.display = "none";
            $('tdCriterioFilial1').style.display = "none";
            $('tdCriterioFilial2').style.display = "";
        }else if($('modelo3').checked){
            $('trMostarCteSemFaturas').style.display = "none";
            $('tdCriterioFilial1').style.display = "none";
            $('tdCriterioFilial2').style.display = "";
        }else if($('modelo4').checked){
            $('trMostarCteSemFaturas').style.display = "none";
            $('tdCriterioFilial1').style.display = "none";
            $('tdCriterioFilial2').style.display = "";
        }else if($('modelo5').checked){
            $('statusFatura').style.display = "";
            $('statusFaturaLabel').style.display = "";
            $('trMostarCteSemFaturas').style.display = "none";
            $('tdCriterioFilial1').style.display = "none";
            $('tdCriterioFilial2').style.display = "";
        }else{
            $('statusFatura').style.display = "none";
            $('statusFaturaLabel').style.display = "none";            
        }
    }
    
    function mostrarFilial(){
        var filial = $('filiais').value;
        
        if(filial == "fct"){
            $('trMostarCteSemFaturas').style.display = "";
            $('chkMostrarCteSemFaturas').checked = true;
        }else if(filial == "fc"){
            $('trMostarCteSemFaturas').style.display = "none";
        }
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

        <title>Webtrans - Relatório de faturas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de faturas </b></td>
            </tr>
        </table>
        <br/>
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
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo1" name="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    faturas geradas &nbsp;&nbsp;&nbsp;<input name="chkModelo1Sintetico" id="chkModelo1Sintetico" type="checkbox" value="1" checked>Analítico</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo2" name="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    faturas geradas por filial
                </td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo3" name="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    faturas 
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input id="modelo4" name="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4</div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das
                    faturas agrupadas por data de emissão
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"> <div align="left">
                        <input id="modelo5" name="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5</div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o 
                    faturas agrupadas por cliente com ERC (Índice de eficiência de recebimento de clientes)
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos">Por data de:</td>
                <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="dtvenc" selected>Vencimento</option>
                        <option value="emissao_fatura" >Emissão Fatura</option>
                        <option value="dtemissao" >Emissão CT</option>
                    </select>
                    entre<strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <img src="img/plus.jpg" id="plus" name="plus" title="Mostrar mais critérios" class="imagemLink" align="right" onclick="javascript:viewCriterios(true);">
                    <img src="img/minus.jpg" id="minus" name="minus" title="Ocultar mais critérios" class="imagemLink" align="right" style="display:none; " onclick="javascript:viewCriterios(false);">
                </td>
            </tr>
            <tr id="trCriterios" name="trCriterios" style="display: none;">
                <td class="TextoCampos">
                    <input name="chkCriterio" type="checkbox" id="chkCriterio" value="checkbox">
                    <select id="tipoCondicao" name="tipoCondicao" class="inputtexto">
                        <option value="AND" selected>E</option>
                        <option value="OR" >OU</option>
                    </select>
                </td>
                <td class="CelulaZebra2"> <select id="tipodata2" name="tipodata2" class="inputtexto">
                        <option value="dtvenc" selected>Vencimento</option>
                        <option value="emissao_fatura" >Emissão Fatura</option>
                        <option value="dtemissao" >Emissão CT</option>
                    </select>
                    entre<strong>
                        <input name="dtinicial2" type="text" id="dtinicial2" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal2" type="text" id="dtfinal2" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong></td>
            </tr>
            <tr class="tabela">
                <td height="18" colspan="3"> <div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td colspan="3"> 
                    <table width="100%" height="67" border="0" >
                        <tr>
                            <td class="TextoCampos">Apenas um cliente:</td>
                            <td width="77%" class="TextoCampos"><div align="left"><strong>
                                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizacliente();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" id="tdCriterioFilial1" style="display: ">
                                <select id="filiais" name="filiais" class="inputtexto" onchange="mostrarFilial()">
                                    <option value="fc">Filial de cobrança (Fatura)</option>
                                    <option value="fct">Filial de emissão (CT-e/NFS-e)</option>
                                </select>
                            </td>
                            <td class="TextoCampos" id="tdCriterioFilial2" style="display: none">
                                Apenas uma filial:
                            </td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="18" maxlength="60" readonly="true">
                                    <% if (temacessofiliais) {%>
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idfilial').value = 0;javascript:$('fi_abreviatura').value = '';">
                                    <%}%>
                                </strong>
                            </td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos">Apenas a fatura:</td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="fatura" type="text" id="fatura" size="10" maxlength="8" class="inputtexto">
                                        <font size="3">/</font>
                                        <input name="anofatura" type="text" id="anofatura" size="8" maxlength="4" class="inputtexto">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos">Apenas CTRCs da Série:</td>
                            <td class="TextoCampos"><div align="left"><strong>

                                        <input name="serieCtrc" class="inputtexto" type="text" id="serieCtrc" size="10" maxlength="8">                      
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" >Apenas a conta bancária:</td> 
                            <td colspan="2" class="CelulaZebra2"> 
                                <select id="contaBancaria" name="contaBancaria" class="inputtexto">
                                    <option value="0" >Todas</option>
                                    <%
                                    Collection<BeanConta> contas = new ArrayList<BeanConta>();
                                    contas = BeanConsultaConta.mostraContas(0, false, Apoio.getUsuario(request).getConexao(), limitarUsuarioVisualizarConta, idUsuario);
                                    for(BeanConta conta : contas){%>
                                    <option value="<%=conta.getIdConta()%>"><%=conta.getNumero()%>-<%=conta.getDigito_conta()%> - <%=conta.getBanco().getDescricao()%></option>  
                                    <%}%>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td height="24" class="TextoCampos" >Apenas os Fretes:</td> 
                            <td colspan="2" class="CelulaZebra2"> 
                                <select id="tipoFrete" name="tipoFrete" class="inputtexto">
                                    <option value="" >Todas</option>
                                    <option value="CIF" >CIF (Remetente)</option>
                                    <option value="FOB" >FOB (Destinatário)</option>
                                    <option value="CON" >CON (Consignatário)</option>
                                    <option value="RED" >RED (Redespacho)</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="3">
                                <div align="center">
                                <input name="tipoCobranca" id="tipoCobranca1" type="radio" value="a" checked="">Todos os tipos
                                <input name="tipoCobranca" id="tipoCobranca2" type="radio" value="c">Cobrança em Carteira
                                <input name="tipoCobranca" id="tipoCobranca3" type="radio" value="b">Cobrança em Banco
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos" style="display: none" id="statusFaturaLabel">
                                Mostrar Faturas:
                            </td>
                            <td class="CelulaZebra2" colspan="2" style="display: none" id="statusFatura">
                                <div align="left">
                                <input name="chkQuitada" id="chkQuitada" type="checkbox" value="" checked="">Quitadas
                                <input name="chkAberta" id="chkAberta" type="checkbox" value="" checked="">Em Aberto
                                <input name="chkParcial" id="chkParcial" type="checkbox" value="" checked="">Quitadas Parcial
                                </div>
                            </td>
                        </tr>
                        <tr id="trMostarCteSemFaturas" style="display: ">                            
                            <td class="CelulaZebra2" colspan="2">
                                <div align="center">
                                    <label>
                                        <input name="chkMostrarCteSemFaturas" id="chkMostrarCteSemFaturas" type="checkbox" value="" checked="">
                                        Mostrar os CT-e(s) Sem Faturas                                        
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3" class="tabela"><div align="center">Ordena&ccedil;&atilde;o</div></td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="3">
                                <div align="center">
                                    <select id="ordenacao" name="ordenacao" class="inputtexto" style="width: 130px">
                                        <option value="f" selected>N&uacute;mero da fatura</option>
                                        <option value="c" >Cliente</option>
                                    </select> </div>
                            </td>
                        </tr>
                    </table>
                </td>
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
                                    <input type="radio" name="impressao" id="word" value="3" />
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
                                
        <div id="tabDinamico"></div>
           
    </body>
                    </html>
