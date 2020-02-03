<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
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
<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relcartafrete") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("lancartafl") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String mostrar = request.getParameter("mostrar");
        String modelo = request.getParameter("modelo");
        String opcoesSels = "";
        java.util.Map param = new java.util.HashMap(18);
        
        opcoesSels = "Período selecionado: " + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") + ";";
        
        String sqlProprietario = "";
        if (modelo.equals("2")) {
            sqlProprietario = (!request.getParameter("idproprietario").equals("0") ? " AND contratado_id=" + request.getParameter("idproprietario") : "");
        } else {
            sqlProprietario = (!request.getParameter("idproprietario").equals("0") ? " AND vei_idprop=" + request.getParameter("idproprietario") : "");
        }

        String agruparFilial = "filial";
        String tipoCarta = " AND (SELECT "
                + "CASE WHEN cm.idmanifesto is not null THEN 'MANIFESTO' "
                + "WHEN cm.coleta_id is not null THEN 'COLETA' "
                + "ELSE 'ROMANEIO' END "
                + "FROM cartafrete_manifesto cm WHERE cm.idcartafrete = cf.idcartafrete LIMIT 1) = ";
        if (request.getParameter("tipoCarta").equals("MANIFESTO")) {
            tipoCarta += "'MANIFESTO'";
        } else if (request.getParameter("tipoCarta").equals("COLETA")) {
            tipoCarta += "'COLETA'";
        } else if (request.getParameter("tipoCarta").equals("ROMANEIO")) {
            tipoCarta += "'ROMANEIO'";
        } else {
            tipoCarta = "";
        }

        String idCidadeDestino = "";
        if (modelo.equals("2")) {
            idCidadeDestino = (request.getParameter("idcidadedestino").equals("0") ? "" : " AND cidade_destino_id = " + request.getParameter("idcidadedestino"));
            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and idfilial=" + request.getParameter("idfilial") : ""));
        }else if(modelo.equals("7")){
            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and cf.idfilial=" + request.getParameter("idfilial") : ""));
        }
        else if(modelo.equals("4")){
            idCidadeDestino = (request.getParameter("idcidadedestino").equals("0") ? "" : " AND COALESCE((SELECT cdo.idcidade FROM cidade cdo LEFT JOIN manifesto m ON m.idcidadedestino = cdo.idcidade LEFT JOIN cartafrete_manifesto cm ON cm.idmanifesto = m.idmanifesto WHERE cm.idcartafrete = cf.idcartafrete LIMIT 1)) = " + request.getParameter("idcidadedestino"));
            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and idfilial=" + request.getParameter("idfilial") : ""));
        }else{
            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and idfilial=" + request.getParameter("idfilial") : ""));
        }
        
        agruparFilial = request.getParameter("agrupaFilial");
        

        String tipoMotorista = request.getParameter("apenasMotoristas");
        //tipos são T, F, A e C
        String tipos = "";
        String tiposDesmarcados = "";
        
        String isAgregado = request.getParameter("is_Agregado");
        String isFrota = request.getParameter("is_Funcionario");
        String isCarreteiro = request.getParameter("is_Carreteiros");
        tipos  = (isAgregado.equals("true")? ",'a'" : "");
        tipos += (isFrota.equals("true")? ",'f'" :"");
        tipos += (isCarreteiro.equals("true")? ",'c'":"");
        
        tiposDesmarcados  = (isAgregado.equals("false")? "',a'" : "");
        tiposDesmarcados += (isFrota.equals("false")? ",'f'" :"");
        tiposDesmarcados += (isCarreteiro.equals("false")? ",'c'" :"");
        
        tipoMotorista = " and tipo_motorista in (''" + tipos + ") ";
        
        
        String sqlFinalizado = "";
        if (mostrar.equals("quitados")){
            sqlFinalizado = " AND finalizada = true ";
        }else if (mostrar.equals("aberto")){
            sqlFinalizado = " AND finalizada = false ";
        }else if (mostrar.equals("abertoA")){
            sqlFinalizado = " AND finalizada = false AND is_saldo_autorizado ";
        }else if (mostrar.equals("abertoN")){
            sqlFinalizado = " AND finalizada = false AND NOT is_saldo_autorizado ";
        }
 
        String sqlCiot = "";
        boolean comCiot = Apoio.parseBoolean(request.getParameter("comCiot"));
        boolean semCiot = Apoio.parseBoolean(request.getParameter("semCiot"));
        opcoesSels += (comCiot && semCiot ? "" : (comCiot ? " Apenas com Ciot;" : ""));
        opcoesSels += (comCiot && semCiot ? "" : (semCiot ? " Apenas sem Ciot;" : ""));

        String sqlCancelado = "";
        boolean cancelados = Apoio.parseBoolean(request.getParameter("cancelados"));
        boolean naoCancelados = Apoio.parseBoolean(request.getParameter("naoCancelados"));
        opcoesSels += (cancelados && naoCancelados ? "" : (naoCancelados ? " Apenas não cancelados;" : ""));
        opcoesSels += (cancelados && naoCancelados ? "" : (cancelados ? " Apenas cancelados;" : ""));

        String sqlCliente = "";
        
        String sqlFreteAutorizado = "";
        boolean isFreteAutorizado = Apoio.parseBoolean(request.getParameter("freteMaiorTabela"));
        opcoesSels += (isFreteAutorizado ? " Apenas fretes com o valor diferente da tabela;" : "");
        
        String sqlPendenteAutorizacao = "";
        boolean isPendenteAutorizacao = Apoio.parseBoolean(request.getParameter("mostrarPendente"));
        opcoesSels += (isPendenteAutorizacao ? " Apenas fretes pendentes de autorização;" : "");
        
        if (modelo.equals("1")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND ciot <> 0 " : "" ) + (semCiot ? " AND (ciot = 0 OR ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (is_precisa_autorizacao AND NOT is_autorizado OR is_precisa_autorizacao = is_autorizado) ":" ");
        }else if (modelo.equals("2")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND ciot <> 0 " : "" ) + (semCiot ? " AND (ciot = 0 OR ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlCliente = (!request.getParameter("idconsignatario").equals("0") ? " AND cliente_id " + request.getParameter("excetoCliente") + request.getParameter("idconsignatario") : "");
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (NOT is_precisa_autorizacao OR is_precisa_autorizacao ) " : " ");
        }else if (modelo.equals("3")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND ciot <> 0 " : "" ) + (semCiot ? " AND (ciot = 0 OR ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlCliente = (!request.getParameter("idconsignatario").equals("0") ? " AND cliente_id " + request.getParameter("excetoCliente") + request.getParameter("idconsignatario") : "");
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (is_precisa_autorizacao AND NOT is_autorizado OR is_precisa_autorizacao = is_autorizado) ":" ");
        }else if (modelo.equals("4")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND ciot <> 0 " : "" ) + (semCiot ? " AND (ciot = 0 OR ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (is_precisa_autorizacao AND NOT is_autorizado OR is_precisa_autorizacao = is_autorizado) ":" ");
        }else if (modelo.equals("5")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND ciot <> 0 " : "" ) + (semCiot ? " AND (ciot = 0 OR ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (is_precisa_autorizacao AND NOT is_autorizado OR is_precisa_autorizacao = is_autorizado) ":" ");
        }else if (modelo.equals("6")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND numero_ciot <> 0 " : "" ) + (semCiot ? " AND (numero_ciot = 0 OR numero_ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (is_precisa_autorizacao AND NOT is_autorizado OR is_precisa_autorizacao = is_autorizado) ":" ");
        }else if (modelo.equals("7")){
            sqlCiot = (comCiot && semCiot ? "" : (comCiot ? " AND ciot <> 0 " : "" ) + (semCiot ? " AND (ciot = 0 OR ciot is null) " : "" ) );
            sqlCancelado = (cancelados && naoCancelados ? "" : (cancelados ? " AND is_cancelada " : "" ) + (naoCancelados ? " AND NOT is_cancelada " : "" ) );
            sqlFreteAutorizado = (isFreteAutorizado?" AND is_precisa_autorizacao AND is_autorizado ":"");
            sqlPendenteAutorizacao = (isPendenteAutorizacao?" AND (is_precisa_autorizacao AND NOT is_autorizado OR is_precisa_autorizacao = is_autorizado) ":" ");
        }
        
        
        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        
        param.put("IDAGENTE", (!request.getParameter("idagente").equals("0") ? request.getParameter("idagente") : "0"));
        param.put("AGENTE", request.getParameter("agente"));
        param.put("IDMOTORISTA", (!request.getParameter("idmotorista").equals("0") ? (modelo.equals("6") ? " AND idmotorista=" + request.getParameter("idmotorista") : " AND motorista_id=" + request.getParameter("idmotorista")) : ""));
        param.put("TIPO_MOTORISTA", tipoMotorista);
        param.put("IDPROPRIETARIO", sqlProprietario);
        param.put("IDCLIENTE", sqlCliente);
        param.put("IDCIDADEDESTINO", idCidadeDestino);
        param.put("IDGRUPO", (!request.getParameter("grupos").equals("") ? " AND grupo_cliente_id " + request.getParameter("excetoGrupo") + " ( " + request.getParameter("grupos") + " ) " : ""));
        param.put("IDVEICULO", (!request.getParameter("idveiculo").equals("0") ? " AND veiculo_id = " + request.getParameter("idveiculo") : ""));
        param.put("FINALIZADA", sqlFinalizado);
        param.put("AGRUPAR_FILIAL", agruparFilial);//Validação 
        param.put("TIPO_CARTA", tipoCarta);
        param.put("ORDENACAO", request.getParameter("tipoOrdenacao"));
        param.put("TIPO_CGC", (!request.getParameter("tipoPessoa").equals("N") ? " AND tipo_cgc='" + request.getParameter("tipoPessoa") + "'" : ""));
        param.put("CIOT", sqlCiot);
        param.put("CANCELADO", sqlCancelado);
        param.put("AUTORIZADO_TABELA", sqlFreteAutorizado);
        param.put("PENDENTE_AUTORIZACAO", sqlPendenteAutorizacao);
        
        //INICIO NOVA FRMA DE ENVIAR PARAMATEROS
        param.put("OPCOES", opcoesSels);
        param.put("NUMERO_CTE", request.getParameter("numero_cte"));
        param.put("OPT_SIMPLES_NACIONAL", Apoio.parseBoolean(request.getParameter("optSimplesNacional")));
        param.put("IS_DIARIA_PARADO", Apoio.parseBoolean(request.getParameter("chkDiariaParado")));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        
        //FIM NOVA FRMA DE ENVIAR PARAMATEROS
        
        request.setAttribute("map", param);
   
        request.setAttribute("rel", "relcartafretemod" +modelo);
           
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
         }else if(acao.equals("iniciar")){
             request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CONTRATO_FRETE_RELATORIO.ordinal());
         }

%>

<script language="javascript" type="text/javascript">

    function modelos(modelo){
        invisivel($("trCliente"));
        invisivel($("trCidadeDestino"));
        invisivel($("trGrupo"));
        invisivel($("trTipoCarta"));
        invisivel($("trAgente"));
        invisivel($("trTipoPessoa"));
        invisivel($("trSaldo"));
        invisivel($("trTituloOrdenacao"));
        invisivel($("trOrdenacao"));
        invisivel($("trCte"));
        invisivel($('trOptSimplesNacional'));
        //invisivel($("contratoCIOT"));
        getObj("modelo1").checked = false;
        getObj("modelo2").checked = false;
        getObj("modelo3").checked = false;
        getObj("modelo4").checked = false;
        getObj("modelo5").checked = false;
        getObj("modelo6").checked = false;
        getObj("modelo7").checked = false;

        switch (parseInt(modelo)){
            case 1:
                visivel($("trAgente"));                
                break;
            case 2:
                getObj("idagente").value = "0";
                getObj("agente").value = "";
                visivel($("trTipoCarta"));
                visivel($("trCliente"));
                visivel($("trCidadeDestino"));                
                visivel($("trTituloOrdenacao"));
                visivel($("trOrdenacao"));
                visivel($("trCte"));
                //visivel($("contratoCIOT"));
                break;
            case 3:
                visivel($("trVeiculo"));
                visivel($("trCliente"));
                //Para evitar erro do grupo_id
                visivel($("trGrupo"));                
                visivel($("trSaldo"));
                break;
            case 4:
                visivel($("trCidadeDestino"));                
                break;
            case 5:
                visivel($("trTipoPessoa"));
                visivel($('trOptSimplesNacional'));
                break;

        }

        getObj("modelo"+modelo).checked = true;
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizamotorista(){
        post_cad = window.open('./localiza?acao=consultar&idlista=10','Motorista',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaprop(){
        post_cad = window.open('./localiza?acao=consultar&idlista=1','Proprietario',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaagente(){
        post_cad = window.open('./localiza?acao=consultar&idlista=16','Agente',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparclifor(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=12','destino','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function popRel(){
        
        var modelo;

        var grupos = getGrupos();
        if (! validaData(getObj("dtinicial").value) || ! validaData(getObj("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        if (getObj("modelo1").checked && getObj("idagente").value == "0")
            alert ("Informe o agente pagador corretamente.");
        else{
            var agrupaFilial = "filial";

            if (getObj("modelo1").checked){
                modelo = '1';
            }else if (getObj("modelo2").checked){
                modelo = '2';
                if (document.getElementById("agrupamentoMod2_2").checked){
                    agrupaFilial = "motorista";
                }else if (document.getElementById("agrupamentoMod2_3").checked){
                    agrupaFilial = "proprietario";
                }    
            }else if (getObj("modelo3").checked){
                modelo = '3';
                if (document.getElementById("agrupamentoMod3_2").checked){
                    agrupaFilial = "motorista";
                }else if (document.getElementById("agrupamentoMod3_3").checked){
                    agrupaFilial = "proprietario";
                }    
            }else if (getObj("modelo4").checked){
                modelo = '4';
            }else if (getObj("modelo5").checked){
                modelo = '5';
            }else if (getObj("modelo6").checked){
                modelo = '6';
            }
            else if (getObj("modelo7").checked){
                modelo = '7';
            }
      
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";
        
            launchPDF('./relcartafrete?acao=exportar&modelo='+modelo+'&impressao='+impressao+
                   "&is_Agregado=" + $("is_Agregado").checked + 
                   "&is_Funcionario=" +$("is_Funcionario").checked +
                   "&is_Carreteiros="+$("is_Carreteiros").checked+
                   "&comCiot="+$("comCiot").checked+
                   "&semCiot="+$("semCiot").checked+
                   "&cancelados="+$("cancelados").checked+
                   "&naoCancelados="+$("naoCancelados").checked+
                   "&freteMaiorTabela="+$("freteMaiorTabela").checked+
                   "&optSimplesNacional="+$("optSimplesNacional").checked+
                   "&mostrarPendente="+$("mostrarPendente").checked+
                   "&chkDiariaParado="+$("chkDiariaParado").checked+
                    '&'+concatFieldValue("dtinicial,dtfinal,idfilial,idagente,agente,idmotorista,numero_cte,"+
                "idproprietario,mostrar,excetoCliente,idconsignatario,idcidadedestino,"+
                "excetoGrupo,idveiculo,apenasMotoristas,tipoCarta,tipoPessoa,tipoOrdenacao")+
                '&grupos='+grupos+"&agrupaFilial="+agrupaFilial);

        }
    }
  
    function aoClicarNoLocaliza(idjanela){
        if (idjanela == "Grupo"){
            addGrupo($('grupo_id').value,'node_grupos', getObj('grupo').value)
        }
    }

    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=41','Veiculo',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
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

        <title>Webtrans - Relatório de Contratos de Fretes</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();modelos(1);AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="idveiculo" id="idveiculo" value="0">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="idagente" id="idagente" value="0">
            <input type="hidden" name="idmotorista" id="idmotorista" value="0">
            <input type="hidden" name="idproprietario" id="idproprietario" value="0">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Contratos de Fretes</b></td>
            </tr>
        </table>

        <br>
        
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
                <td width="50%" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1 </div></td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    contratos de fretes por agente pagador</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos(2);">
                        Modelo 2 </div></td>
                <td width="187" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    contratos de fretes </td>
                <td width="189" class="CelulaZebra2">
                    <input type="radio" name="agrupamentoMod2" id="agrupamentoMod2_1" value="filial" checked >
                    Agrupar por filial <br>
                    <input type="radio" name="agrupamentoMod2" id="agrupamentoMod2_2" value="motorista" >
                    Agrupar por motorista<br>
                    <input type="radio" name="agrupamentoMod2" id="agrupamentoMod2_3" value="proprietario" >
                    Agrupar por proprietário
                </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos(3);">
                        Modelo 3 </div></td>
                <td width="187" class="CelulaZebra2">Rela&ccedil;&atilde;o dos
                    saldos de fretes </td>
                <td width="189" class="CelulaZebra2">
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_1" value="filial" checked >
                    Agrupar por filial <br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_2" value="motorista" >
                    Agrupar por motorista<br>
                    <input type="radio" name="agrupamentoMod3" id="agrupamentoMod3_3" value="proprietario" >
                    Agrupar por proprietário
                </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos(4);">
                        Modelo 4 </div></td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    contratos de fretes com valores dos CTRCs </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo5" id="modelo5" value="5" onClick="javascript:modelos(5);">
                        Modelo 5 </div></td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    contratos de fretes com Impostos Retidos </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo6" id="modelo6" value="6" onClick="javascript:modelos(6);">
                        Modelo 6 </div></td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    Contratos de Fretes agrupado por motorista </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo7" id="modelo7" value="7" checked onClick="javascript:modelos(7);">
                        Modelo 7 </div></td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de 
                    despesas agregadas por contratos de frete</td>
            </tr>
            <tr class="tabela">
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr>
                <td class="TextoCampos">Emitidos entre:</td>
                <td colspan="2" class="CelulaZebra2"> <strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>      </td>
            </tr>
            <tr class="tabela">
                <td colspan="3"> <div align="center">Filtros</div></td>
            </tr>
            <tr >
                <td colspan="3"> <table width="100%" border="0" >
                        <tr id="trAgente">
                            <td class="TextoCampos">Apenas o ag. pagador</td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="agente" type="text" id="agente" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                    <input name="localiza_agente" type="button" class="botoes" id="localiza_agente" value="..." onClick="javascript:localizaagente();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ag. Pagador" onClick="javascript:getObj('idagente').value = '0';javascript:getObj('agente').value = '';">
                                </strong></td>
                        </tr>
                        <tr>
                            <td width="50%" class="TextoCampos">Apenas a filial:</td>
                            <td width="65%" class="CelulaZebra2"><strong>
                                    <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="30" maxlength="80" readonly="true">
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial').value = '0';javascript:getObj('fi_abreviatura').value = '';">
                                </strong></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas o motorista:</td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                    <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizamotorista();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idmotorista').value = '0';javascript:getObj('motor_nome').value = '';">
                                </strong></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas os motoristas: </td>
                            <td class="CelulaZebra2">
                                <select id="apenasMotoristas" name="apenasMotoristas" class="inputtexto" style="display: none">
                                    <option value="t" selected>Todos</option>
                                    <option value="f">Funcion&aacute;rio</option>
                                    <option value="a">Agregado</option>
                                    <option value="c">Carreteiro</option>
                                </select>          
                                <label><input type="checkbox" checked name="is_Agregado" id="is_Agregado">Agregados</label>
                                <label><input type="checkbox" checked name="is_Funcionario" id="is_Funcionario">Funcionários</label>
                                <label><input type="checkbox" checked name="is_Carreteiros" id="is_Carreteiros">Carreteiros</label>
                                
                            
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas o proprietário:</td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="nome" type="text" id="nome" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                    <input name="localiza_prop" type="button" class="botoes" id="localiza_prop" value="..." onClick="javascript:localizaprop();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idproprietario').value = '0';javascript:getObj('nome').value = '';">
                                </strong></td>
                        </tr>
                        <tr id="trSaldo" name="trSaldo" style="display:none;">
                            <td class="TextoCampos">Apenas saldos:</td>
                            <td class="CelulaZebra2"><select id="mostrar" name="mostrar" class="inputtexto">
                                    <option value="ambos">Ambos</option>
                                    <option value="quitados">Quitados</option>
                                    <option value="aberto">Em aberto</option>
                                    <option value="abertoA">Em aberto (Autorizados)</option>
                                    <option value="abertoN">Em aberto (Não Autorizados)</option>
                                </select></td>
                        </tr>
                        <tr id="trTipoPessoa">
                            <td class="TextoCampos">Apenas pessoa:</td>
                            <td class="CelulaZebra2"><select id="tipoPessoa" name="tipoPessoa" onchange="javascript:$('tipoPessoa').value == 'F' ? invisivel($('trOptSimplesNacional')) : visivel($('trOptSimplesNacional'));" class="inputtexto">
                                    <option value="N">Ambas</option>
                                    <option value="F">Física</option>
                                    <option value="J">Jurídica</option>
                                </select></td>
                        </tr>
                        <tr id="trTipoCarta" name="trTipoCarta">
                            <td class="TextoCampos">Apenas do tipo:</td>
                            <td class="CelulaZebra2">
                                <select id="tipoCarta" name="tipoCarta" class="inputtexto">
                                    <option value="TODOS" selected>Todos</option>
                                    <option value="MANIFESTO">Manifesto</option>
                                    <option value="COLETA">Coleta</option>
                                    <option value="ROMANEIO">Romaneio</option>
                                </select>
                            </td>
                        </tr>
                        <tr id="trVeiculo" name="trVeiculo" >
                            <td class="TextoCampos"><label id="veiculo" name="veiculo">Apenas o ve&iacute;culo: </label></td>
                            <td class="CelulaZebra2">
                                <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly" value="" size="15" maxlength="10" readonly="true">
                                <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..."  onClick="javascript:localizaveiculo();">
                                <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink"  id="limpavei" title="Limpar Veículo" onClick="javascript:$('idveiculo').value = '0';javascript:$('vei_placa').value = '';"></td>
                        </tr>
                        <tr id="trCidadeDestino">
                            <td class="TextoCampos">Apenas a cidade de destino:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
                                    <input name="cid_destino" type="text" class="inputReadOnly8pt" id="cid_destino"  value="" size="20" readonly="true">
                                    <input name="uf_destino" type="text" id="uf_destino"  class="inputReadOnly8pt" size="2" readonly="true">
                                    <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();">
                                    <img src="img/borracha.gif" name="apaga_cid_destino" border="0" align="absbottom" class="imagemLink" id="apaga_cid_destino" title="Limpar Cidade de Destino" onClick="javascript:getObj('idcidadedestino').value = 0;javascript:getObj('cid_destino').value = '';getObj('uf_destino').value = '';">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trCliente" name="trCliente" style="display:none; ">
                            <td class="TextoCampos"><select id="excetoCliente" name="excetoCliente" class="inputtexto">
                                    <option value="=" selected>Apenas o cliente</option>
                                    <option value="<>">Exceto o cliente</option>
                                </select>:</td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                    <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizacliente();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();"></strong></td>
                        </tr>

                        <tr>
                            <td class="TextoCampos" rowspan="2">Mostrar Contratos:</td>
                            <td class="CelulaZebra2">
                                <div align="left">
                                    <input type="checkbox" name="comCiot" id="comCiot" value="false" onclick="" checked>
                                    Com CIOT
                                    <input type="checkbox" name="semCiot" id="semCiot" value="false" onclick="" checked>
                                    Sem CIOT
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2">
                                <div align="left">
                                    <input type="checkbox" name="naoCancelados" id="naoCancelados" value="false" onclick="" checked>
                                    Não Cancelados
                                    <input type="checkbox" name="cancelados" id="cancelados" value="false" onclick="">
                                    Cancelados
                                </div>
                            </td>
                        </tr>
                        <tr name="trCte" id="trCte" style="display:none;">
                            <td class="TextoCampos">Contratos do(s) CT-e(s):</td>
                            <td class="CelulaZebra2">
                                        <input name="numero_cte" type="text" id="numero_cte" size="20" maxlength="100" class="inputtexto">
                                        Ex: 010230,010231
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="2">
                                <div align="center">
                                    <input type="checkbox" name="freteMaiorTabela" id="freteMaiorTabela" value="false" onclick="">
                                    Mostrar apenas contratos autorizados com valor diferente da tabela.
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="2">
                                <div align="center">
                                    <input type="checkbox" name="mostrarPendente" id="mostrarPendente" value="false">
                                    Mostrar também contratos de fretes pendentes de autorização.
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="2">
                                <div align="center">
                                    <input type="checkbox" name="chkDiariaParado" id="chkDiariaParado" value="false">
                                    Mostrar apenas contratos de diária parado.
                                </div>
                            </td>
                        </tr>
                        <tr id="trOptSimplesNacional">
                            <td class="CelulaZebra2" colspan="2">
                                <div align="center">
                                    <input type="checkbox" name="optSimplesNacional" id="optSimplesNacional" value="false">
                                    Optante pelo Simples Nacional
                                </div>
                            </td>
                        </tr>

                        <tr id="trGrupo" name="trGrupo" style="display:none; ">
                            <td colspan="9">
                                <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                                    <tr class="cellNotes">
                                        <td width="24%" class="CelulaZebra2"><div align="center"><img src="img/add.gif" border="0"
                                                                                                      title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">          </div></td>
                                        <td width="76%" class="CelulaZebra2" ><div align="center">
                                                <select name="excetoGrupo" id="excetoGrupo" class="inputtexto">
                                                    <option value="IN" selected>Apenas os grupos</option>
                                                    <option value="NOT IN">Exceto os grupos</option>
                                                </select>
                                            </div></td>
                                    </tr>
                                </table>    </td>
                        </tr>
                    </table></td>
            </tr>
            <tr id="trTituloOrdenacao" name="trTituloOrdenacao" style="display: none;">
                <td colspan="3" class="tabela"><div align="center">Ordenação</div></td>
            </tr>
            <tr id="trOrdenacao" name="trOrdenacao" style="display: none;">
                <td class="CelulaZebra2" colspan="3"><div align="center">
                        <select id="tipoOrdenacao" name="tipoOrdenacao" class="inputtexto">
                            <option value="idcartafrete" selected>Nº do Contrato</option>
                            <option value="data">Emissão do Contrato</option>
                        </select></div>
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
                    </div></td>
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