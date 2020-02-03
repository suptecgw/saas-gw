<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="nucleo.BeanLocaliza"%>
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


<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("relnfcliente") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        String tc = "";
        String tcDescricao = "";
        String tipoConhecimento = "";
        String remetente = "";
        String consignatario = "";
        String opcoes = "";
        String notasFiscais = "";
        String idOcorrencia = "";
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        //Verificando se vai filtrar apenas um consignatário
        String modelo = request.getParameter("modelo");
        String grupoId = request.getParameter("grupo_id").equals("0") ? ""
                : " and grupo_id=" + request.getParameter("grupo_id");
        
        opcoes = (!request.getParameter("grupo_id").equals("0") ? " Grupo: " + request.getParameter("grupo") : "");
        
        //Apenas os CTs Normais
        tc = (Apoio.parseBoolean(request.getParameter("ct_normal")) ? "'n'" : "");
        //Apenas os CTs Locais
        tc += (Apoio.parseBoolean(request.getParameter("ct_local")) ? (tc.equals("") ? "'l'" : ",'l'") : "");
        //Apenas os CTs Diarias
        tc += (Apoio.parseBoolean(request.getParameter("ct_diaria")) ? (tc.equals("") ? "'i'" : ",'i'") : "");
        //Apenas os CTs Paletização
        tc += (Apoio.parseBoolean(request.getParameter("ct_paletizacao")) ? (tc.equals("") ? "'p'" : ",'p'") : "");
        //Apenas os CTs Complementares
        tc += (Apoio.parseBoolean(request.getParameter("ct_complementar")) ? (tc.equals("") ? "'c'" : ",'c'") : "");
        //Apenas os CTs Reentrega
        tc += (Apoio.parseBoolean(request.getParameter("ct_reentrega")) ? (tc.equals("") ? "'r'" : ",'r'") : "");
        //Apenas os CTs Devolução
        tc += (Apoio.parseBoolean(request.getParameter("ct_devolucao")) ? (tc.equals("") ? "'d'" : ",'d'") : "");
        //Apenas os CTs Cortesia
        tc += (Apoio.parseBoolean(request.getParameter("ct_cortesia")) ? (tc.equals("") ? "'b'" : ",'b'") : "");
        
        
        tcDescricao = (Apoio.parseBoolean(request.getParameter("ct_normal")) ? "Normal" : "");
        //Apenas os CTs Locais
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_local")) ? (tc.equals("") ? "Local" : ",Local") : "");
        //Apenas os CTs Diarias
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_diaria")) ? (tc.equals("") ? "Diária" : ",Diária") : "");
        //Apenas os CTs Paletização
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_paletizacao")) ? (tc.equals("") ? "Paletização" : ",Paletização") : "");
        //Apenas os CTs Complementares
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_complementar")) ? (tc.equals("") ? "Complementar" : ",Complementar") : "");
        //Apenas os CTs Reentrega
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_reentrega")) ? (tc.equals("") ? "Reentrega" : ",Reentrega") : "");
        //Apenas os CTs Devolução
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_devolucao")) ? (tc.equals("") ? "Devolução" : ",Devolução") : "");
        //Apenas os CTs Cortesia
        tcDescricao += (Apoio.parseBoolean(request.getParameter("ct_cortesia")) ? (tc.equals("") ? "Cortesia" : ",Cortesia") : "");

        if (!tcDescricao.equals("")) {
            opcoes += " Mostrar CT(s): (" + tcDescricao + ")";
                
        }
        
        
        if (modelo.equals("1") || modelo.equals("4") || modelo.equals("5")) {
            remetente = (!request.getParameter("idRemetente").equals("0") ? "and idremetente=" + request.getParameter("idRemetente") : "");

        } else {
            remetente = (!request.getParameter("idRemetente").equals("0") ? "and remetente_id=" + request.getParameter("idRemetente") : "");
        }

        if (modelo.equals("3")) {
            remetente = (!request.getParameter("idRemetente").equals("0") ? "and v.idremetente=" + request.getParameter("idRemetente") : "");
        }
        opcoes += !request.getParameter("idRemetente").equals("0") ? " Remetente: " + request.getParameter("remetente") : "";
        
        
        String destinatario = "";
        
        if (modelo.equals("6")) {
            destinatario = (!request.getParameter("iddestinatario").equals("0") ? " and c.destinatario_id=" + request.getParameter("iddestinatario") : "");
            consignatario = (!request.getParameter("idConsignatario").equals("0") ? "and sl.consignatario_id=" + request.getParameter("idConsignatario") : "");
        } else {
            consignatario = (!request.getParameter("idConsignatario").equals("0") ? "and idconsignatario=" + request.getParameter("idConsignatario") : "");
            destinatario = (!request.getParameter("iddestinatario").equals("0") ? " and destinatario_id=" + request.getParameter("iddestinatario") : "");
        }
        opcoes += !request.getParameter("idConsignatario").equals("0") ? " Consignatario: " + request.getParameter("consignatario") : "";
        opcoes += (!request.getParameter("iddestinatario").equals("0") ? " Destinatario: " + request.getParameter("destinatario") : "");
        //TIPO DO CONHECIMENTO
        if (modelo.equals("1") || modelo.equals("4")) {
            tipoConhecimento = (tc.equals("") ? "" : " AND (tipo_conhecimento_ctrc IN (" + tc + ") OR (ctrc = '' OR ctrc is null)) ");
        } else if (modelo.equals("2")) {
            tipoConhecimento = (tc.equals("") ? "" : " AND tipo_conhecimento IN (" + tc + ") ");
        } else if (modelo.equals("3")) {
            tipoConhecimento = (tc.equals("") ? "" : " AND (tipo_conhecimento IN (" + tc + ") OR (tipo_conhecimento = '' OR tipo_conhecimento is null)) ");
        } else if (modelo.equals("5")) {
            tipoConhecimento = (tc.equals("") ? "" : " AND tipo_conhecimento_ctrc IN (" + tc + ") ");            
        } else if (modelo.equals("6")) {
            tipoConhecimento = (tc.equals("") ? "" : " AND sl.tipo IN (" + tc + ") ");
        }

        //Filtro UF 
        String filtroUF = "";
        if (request.getParameter("uf") != null && !request.getParameter("uf").equals("")){
            filtroUF = " AND uf_destinatario " + request.getParameter("apenasUF") + " ('" + request.getParameter("uf").replaceAll(",", "','") + "') ";
            opcoes += " UF(s):(" + request.getParameter("uf") + ")";
        }
        
        java.util.Map param = new java.util.HashMap(20);
        param.put("TIPOCONHECIMENTO", tipoConhecimento);
        param.put("IDREMETENTE", remetente);
        param.put("IDDESTINATARIO", destinatario);
        param.put("IDCONSIGNATARIO", consignatario);
        
        if (modelo.equals("4")) {
            String tipoDataMod4 = request.getParameter("tipoDataMod4");
            param.put("TIPO_DATA", tipoDataMod4);
            if (tipoDataMod4.equals("emissao")) {
                opcoes += " Agrupado por data de emissão da NF ";
            } else if (tipoDataMod4.equals("data_agenda")) {
                opcoes += " Agrupado por data de agendamento da NF ";
            } else if (tipoDataMod4.equals("emissao_em")) {
                opcoes += " Agrupado por data de emissão do CT-e ";
            } else if (tipoDataMod4.equals("coleta_em")) {
                opcoes += " Agrupado por data de coleta ";
            } else if (tipoDataMod4.equals("saida_em")) {
                opcoes += " Agrupado por data de saída (Manifesto) ";
            } else if (tipoDataMod4.equals("chegada_em")) {
                opcoes += " Agrupado por data de chegada no destino ";
            } else if (tipoDataMod4.equals("previsao_entrega_em")) {
                opcoes += " Agrupado por data de previsão de entrega ";
            } else if (tipoDataMod4.equals("entrega_em")) {
                opcoes += " Agrupado por data de entrega ";
            }
        } else if (modelo.equals("5")) {
            String tipoDataModelo5 = request.getParameter("tipoData");
            if (tipoDataModelo5.equals("emissaoCtrc")) {
                tipoDataModelo5 = "emissao_em";
            }
            opcoes += " Tipo Data: " + tipoDataModelo5;
            param.put("TIPO_DATA", tipoDataModelo5);
        }
        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        param.put("GRUPO_ID", grupoId);
        if (modelo.equals("2")) {
            param.put("AREA", request.getParameter("area_id").equals("0") ? "" : " and (select count(*) from area_cidade ac left join areas a on (ac.area_id = a.id)  where ct.ctrc_cidade_destino_id = ac.cidade_id and (a.cliente_id=idconsignatario or a.cliente_id is null) and a.id="+request.getParameter("area_id")+") > 0" );
            param.put("MANIFESTADA", request.getParameter("manifestadas").equals("sim") ? " and nmanifesto is not null " : request.getParameter("manifestadas").equals("nao") ? " and nmanifesto is null " : "");
            param.put("ENTREGA", request.getParameter("entregues").equals("") ? "" : request.getParameter("entregues").equals("sim") ? " and baixa_em is not null " : " and baixa_em is null ");
            param.put("CIDADE_DESTINO", request.getParameter("idcidadedestino").equals("0") ? "" : " and cidade_destinatario_id =" + request.getParameter("idcidadedestino"));
           
        } else if(modelo.equals("3")) {
            param.put("AREA", request.getParameter("area_id").equals("0") ? "" : " and (select count(*) from area_cidade ac left join areas a on (ac.area_id = a.id)  where v.ctrc_cidade_destino_id = ac.cidade_id and (a.cliente_id=idconsignatario or a.cliente_id is null) and a.id="+request.getParameter("area_id")+") > 0" );
            param.put("MANIFESTADA", request.getParameter("manifestadas").equals("sim") ? " and manifesto is not null " : request.getParameter("manifestadas").equals("nao") ? " and manifesto is null " : "");
            param.put("ENTREGA", request.getParameter("entregues").equals("") ? "" : request.getParameter("entregues").equals("sim") ? " and entrega_em is not null " : " and entrega_em is null ");
            param.put("CIDADE_DESTINO", request.getParameter("idcidadedestino").equals("0") ? "" : " and idcidade_destinatario =" + request.getParameter("idcidadedestino"));
        } else if (modelo.equals("6")) {
            param.put("CIDADE_DESTINO", request.getParameter("idcidadedestino").equals("0") ? "" : " and cid_des.idcidade =" + request.getParameter("idcidadedestino"));            
            param.put("ENTREGA", request.getParameter("entregues").equals("") ? "" : request.getParameter("entregues").equals("sim") ? " and baixa_em is not null " : " and baixa_em is null ");
            param.put("MANIFESTADA", request.getParameter("manifestadas").equals("sim") ? " and nmanifesto is not null " : request.getParameter("manifestadas").equals("nao") ? " and nmanifesto is null " : "");
            param.put("AREA", request.getParameter("area_id").equals("0") ? "0" : request.getParameter("area_id"));
            if (request.getParameter("uf") != null && !request.getParameter("uf").equals("")){
                filtroUF = " AND cid_des.uf " + request.getParameter("apenasUF") + " ('" + request.getParameter("uf").replaceAll(",", "','") + "') ";                
            }
        } else {
            param.put("AREA", request.getParameter("area_id").equals("0") ? "" : " and (select count(*) from area_cidade ac left join areas a on (ac.area_id = a.id)  where nf.ctrc_cidade_destino_id = ac.cidade_id and (a.cliente_id=idconsignatario or a.cliente_id is null) and a.id="+request.getParameter("area_id")+") > 0" );
            param.put("MANIFESTADA", request.getParameter("manifestadas").equals("sim") ? " and manifesto is not null " : request.getParameter("manifestadas").equals("nao") ? " and manifesto is null " : "");
            param.put("ENTREGA", request.getParameter("entregues").equals("") ? "" : request.getParameter("entregues").equals("sim") ? " and entrega_em is not null " : " and entrega_em is null ");
            param.put("CIDADE_DESTINO", request.getParameter("idcidadedestino").equals("0") ? "" : " and ctrc_cidade_destino_id =" + request.getParameter("idcidadedestino"));
        }
        
        opcoes += (!request.getParameter("area_id").equals("0") ? " Area : " + request.getParameter("siglaArea") : "");
        opcoes += (request.getParameter("manifestadas").equals("sim") ? " Manifestados: Sim" 
                : request.getParameter("manifestadas").equals("nao") ? " Manifestados: Não" : " Manifestados: Todos");
        opcoes += (request.getParameter("entregues").equals("sim") ? " Entregues: Sim" 
                : request.getParameter("entregues").equals("nao") ? " Entregues: Não" : " Entregues: Ambos");
        
        opcoes += (!request.getParameter("idcidadedestino").equals("0") ? " Cidade Destino: " + request.getParameter("cidadeDestino") : "");
        
        
        if (modelo.equals("6")) {
            String tipoDataModelo6 = request.getParameter("tipoData");
            idOcorrencia = (request.getParameter("idOcorrencia") == null ? "0" : request.getParameter("idOcorrencia"));
            notasFiscais = (request.getParameter("notasFiscais") == null ? "0" : request.getParameter("notasFiscais").replaceAll(",", "','"));
            
            param.put("ID_OCORRENCIA",idOcorrencia);
            param.put("NOTAS_FISCAIS",notasFiscais);
            param.put("SEM_CTRC", Apoio.parseBoolean(request.getParameter("semCtrc")) ? " AND (sl.numero = '' OR sl.numero is null)" : "");
            
            if (tipoDataModelo6.equals("emissao")) {
                tipoDataModelo6 = "emissao";
            } else if (tipoDataModelo6.equals("data_agenda")) {
                tipoDataModelo6 = "data_agenda";
            } else if (tipoDataModelo6.equals("emissaoCtrc")) {
                tipoDataModelo6 = "emissao_em";
            } else if (tipoDataModelo6.equals("saida_em")) {
                tipoDataModelo6 = "dtsaida";
            } else if (tipoDataModelo6.equals("ocorrencia_em")) {
                tipoDataModelo6 = "ocorrencia_em";
            }
            
            param.put("TIPO_DATA", tipoDataModelo6);
        } else {
            param.put("SEM_CTRC", Apoio.parseBoolean(request.getParameter("semCtrc")) ? " AND (ctrc = '' OR ctrc is null)" : "");
        }
        
        opcoes += (Apoio.parseBoolean(request.getParameter("semCtrc")) ? " Sem CT-e Gerados" : "" );
        
        param.put("OPCOES", "Período selecionado: " + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal") + " " + opcoes);
        param.put("UF", filtroUF);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        
        
        request.setAttribute("map", param);
        request.setAttribute("rel", "relnfclientemod" + request.getParameter("modelo"));

    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_NOTA_FISCAL_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">
    function voltar(){
        location.replace("./menu");
    }

    function modelos(modelo){
        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("trSemCtrc").style.display = "none";
        $("tipodata").disabled = true;
        $("tipodata").style.display = "none";
        $("tipodatamod4").style.display = "none";
        $("modelo"+modelo).checked = true;
        $("trGrupo").style.display = "none";
        $("trNotaFiscal").style.display = "none";
        $("trOcorrencia").style.display = "none";
        
        if (modelo == 1){
            $("trSemCtrc").style.display = "";
            $("tipodata").style.display = "";
            $("tipodata").value = "emissao";
            $("trGrupo").style.display = "";
        } else if (modelo == 2){
            $("tipodata").style.display = "";
            $("tipodata").value = "emissaoCtrc";
        } else if (modelo == 3){
            $("tipodata").style.display = "";
            $("tipodata").value = "data_agenda";
        } else if (modelo == 4){
            $("tipodatamod4").style.display = "";
        } else if (modelo == 5){
            $("trGrupo").style.display = "";
            $("tipodata").style.display = "";
            $("tipodata").disabled = false;
            $("trSemCtrc").style.display = "";
            $("tipodata").value = "emissao";
        } else if (modelo == 6) {
            $("trNotaFiscal").style.display = "";
            $("trOcorrencia").style.display = "";
            $("trSemCtrc").style.display = "";
            $("tipodata").disabled = false;
            $("tipodata").style.display = "";
            $("tipodata").value = "ocorrencia_em";
        }
    }

    function localizacliente(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Cliente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizadestinatario(){
        windowDestinatario = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=4&','Destinatario',
        'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
    }
    function localizaconsignatario(){
        windowDestinatario = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5&','Consignatario',
        'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function limpardestinatariofor(){
        $("iddestinatario").value = "0";
        $("dest_rzs").value = "";
    }
    function limparclifor(){
        $("idremetente").value = "0";
        $("rem_rzs").value = "";
    }
    function limparconsignatariofor(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }
    function limparGrupo(){
        $("grupo_id").value = "0";
        $("grupo").value = "";
    }
    function limparCidade(){
        $("cid_destino").value = "0";
        $("uf_destino").value = "0";
        $("cidade_destino").value = "0";
        $("uf_dest").value = "0";                   
    }

    function popRel(){
        var modelo; 

//        var grupos = getGruposAthos();
        
        if (! validaData($("dtinicial").value) || !validaData($("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else{
            if ($("modelo1").checked)
                modelo = '1';
            else if ($("modelo2").checked)
                modelo = '2';
            else if ($("modelo3").checked)
                modelo = '3';
            else if($("modelo4").checked)
                modelo = '4';
            else if($("modelo5").checked)
                modelo = '5';
            else if ($("modelo6").checked) 
                modelo = '6';
    
            
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";

            launchPDF('./relnotafiscalcliente.jsp?acao=exportar&modelo='+modelo
                +'&impressao='+impressao
                +'&idRemetente='+$("idremetente").value
                +'&remetente='+$("rem_rzs").value
                +'&iddestinatario='+$("iddestinatario").value
                +'&destinatario='+$("dest_rzs").value
                +'&idConsignatario='+$("idconsignatario").value
                +'&consignatario='+$("con_rzs").value
                +'&apenasUF='+$('apenasUF').value
                +'&uf='+$('uf').value
                +'&dtinicial='+$("dtinicial").value
                +'&dtfinal='+$("dtfinal").value
                +'&semCtrc='+$('chkSemCTRC').checked
                +'&tipoDataMod4='+$('tipodatamod4').value
                +'&tipoData='+$('tipodata').value
            // Mostrar CTs
                +"&ct_normal=" + $("ct_normal").checked
                +"&ct_local=" + $("ct_local").checked
                +"&ct_diaria=" + $("ct_diaria").checked
                +"&ct_paletizacao=" + $("ct_paletizacao").checked
                +"&ct_complementar=" + $("ct_complementar").checked
                +"&ct_reentrega=" + $("ct_reentrega").checked
                +"&ct_devolucao=" + $("ct_devolucao").checked
                +"&ct_cortesia=" + $("ct_cortesia").checked 
                +"&grupo_id=" + $("grupo_id").value 
                +"&grupo=" + $("grupo").value               
                +"&area_id=" + $("area_id").value
                +"&siglaArea=" + $("sigla_area").value
                +"&manifestadas=" + $("manifestadas").value
                +"&entregues=" + $("entregues").value 
                +"&idcidadedestino=" + $("idcidadedestino").value 
                +"&cidadeDestino=" + $("cid_destino").value
                +"&idOcorrencia="+$("idOcorrencia").value
                +"&notasFiscais="+$("notasFiscais").value);
        }
    }
    
    function limparOcorrencia(){
        $("idOcorrencia").value = "0"
        $("codigoOcorrencia").value = "";
        $("descricaoOcorrencia").value = "";
    }
    
    function abrirLocalizaOcorrencia(){
        launchPopupLocate('./localiza?acao=consultar&idlista=40','Ocorrencia');
    }
    
    function aoClicarNoLocaliza(janela){
        if (janela == "Ocorrencia") {
            $("idOcorrencia").value = $("ocorrencia_id").value;
            $("codigoOcorrencia").value = $("ocorrencia").value;
            $("descricaoOcorrencia").value = $("descricao_ocorrencia").value;
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

        <title>Webtrans - Relatório de notas fiscais de cliente</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);modelos(1);">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
            <input type="hidden" name="idremetente" id="idremetente" value="0">
            <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="0">
            <input type="hidden" name="ocorrencia" id="ocorrencia" value="">
            <input type="hidden" name="descricao_ocorrencia" id="descricao_ocorrencia" value="">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de notas fiscais de clientes </b></td>
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
                        <input id="modelo1" name="modelo" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o das 
                    notas fiscais dos remetentes</td>
            </tr>
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input id="modelo2" name="modelo" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Posição de entrega da nota fiscal</td>
            </tr>
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input id="modelo3" name="modelo" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Agendamento de nota fiscal</td>
            </tr>
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input id="modelo4" name="modelo" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das 
                    notas fiscais</td>
            </tr>
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input id="modelo5" name="modelo" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das 
                    notas fiscais dos pedidos</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input id="modelo6" name="modelo" type="radio" value="6" onClick="javascript:modelos(6);">
                        Modelo 6</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2">Posição das notas fiscais com Ocorrência</td>                
            </tr>
            <tr class="tabela"> 
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos">Por data de:</td>
                <td colspan="2" class="CelulaZebra2"> 
                    <select id="tipodata" name="tipodata" disabled="disabled" class="inputtexto" style="display: none; width: 120px;">
                        <option value="emissao" selected>Emiss&atilde;o da NF</option>
                        <option value="data_agenda">Agendamento</option>
                        <option value="emissaoCtrc">Emiss&atilde;o do CTRC</option>
                        <option value="saida_em">Data da Saída (Manifesto)</option>
                        <option value="ocorrencia_em">Data da Ocorrência</option>
                    </select>
                    <select id="tipodatamod4" name="tipodatamod4" class="inputtexto" style="display: none; width: 120px;">
                        <option value="emissao" selected>Emiss&atilde;o da NF</option>
                        <option value="data_agenda">Agendamento da NF</option>
                        <option value="emissao_em">Emiss&atilde;o do CT-e</option>
                        <option value="coleta_em">Data da Coleta</option>
                        <option value="saida_em">Data da Saída (Manifesto)</option>
                        <option value="chegada_em">Data da Chegada no Destino</option>
                        <option value="previsao_entrega_em">Previsão de Entrega</option>
                        <option value="entrega_em">Data de Entrega</option>
                    </select>
                    entre<strong> 
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong> 
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong></td>
            </tr>
            <tr class="tabela"> 
                <td height="18" colspan="3"> <div align="center">Filtros</div></td>
            </tr>
            <tr> 
                <td colspan="3"> 
                    <table border="0" width="100%" >
                        <tr>
                            <td width="50%" class="TextoCampos" ><label id="lbMotrarCT" name="lbMotrarCT">Mostrar CTs:</label></td>
                            <td width="70%" class="CelulaZebra2">
                                <input name="ct_normal" type="checkbox" id="ct_normal" checked >Normais
                                <input name="ct_local" type="checkbox" id="ct_local" checked >Distrib. locais
                                <input name="ct_diaria" type="checkbox" id="ct_diaria"  >Diárias
                                <input name="ct_paletizacao" type="checkbox" id="ct_paletizacao" checked >Pallets<br/>
                                <input name="ct_complementar" type="checkbox" id="ct_complementar"  >Complementares
                                <input name="ct_reentrega" type="checkbox" id="ct_reentrega" >Reentregas
                                <input name="ct_devolucao" type="checkbox" id="ct_devolucao" >Devoluções
                                <input name="ct_cortesia" type="checkbox" id="ct_cortesia" >Cortesias
                            </td>
                        </tr>
                        <tr id="trNotaFiscal" style="display: none">
                            <td class="TextoCampos">
                                Apenas as notas fiscais:
                            </td>
                            <td class="CelulaZebra2">
                                <input type="text" id="notasFiscais" name="notaFiscais" class="inputTexto"/>
                                Separe as notas fiscais com vírgulas
                            </td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos"><div align="right">Apenas um Remetente:</div></td>
                            <td class="TextoCampos"><div align="left"><strong> 
                                        <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_clifor" type="button" class="botoes" id="localiza_clifor4" value="..." onClick="javascript:localizacliente();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><div align="right">Apenas um Destinatário:</div></td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_dest" type="button" class="botoes" id="localiza_dest" value="..." onClick="javascript:localizadestinatario();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limpardestinatariofor();">
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><div align="right">Apenas um Consignat&aacute;rio:</div></td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_cons" type="button" class="botoes" id="localiza_cons" value="..." onClick="javascript:localizaconsignatario();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparconsignatariofor();">
                                    </strong></div></td>
                        </tr>
                        <tr id="trGrupo"> 
                        <input type="hidden" name="grupo_id" id="grupo_id" value="0">
                        <td class="TextoCampos">Apenas o grupo (Destinatário):</td>
                        <td class="CelulaZebra2"><strong> 
                                <input name="grupo" type="text" id="grupo" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                                <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Grupo" 
                                     onClick="javascript:limparGrupo()"> 
                            </strong></td>
            </tr>
            <tr id="trSemCtrc" name="trSemCtrc">
                <td colspan="2" class="TextoCampos"><div align="center">
                        <input name="chkSemCTRC" type="checkbox" id="chkSemCTRC" value="checkbox">
                        Mostrar apenas notas fiscais sem CTRC gerado. </div></td>
            </tr>
            <tr id="trOcorrencia" style="display: none">
                <td class="TextoCampos">
                    Apenas a ocorrência:
                </td>
                <td class="CelulaZebra2">
                    <input type="hidden" id="idOcorrencia" name="idOcorrencia" class="inputTexto" value="0"/>                    
                    <input type="text" id="codigoOcorrencia" name="codigoOcorrencia" size="5" class="inputReadOnly8pt"/>
                    <input type="text" id="descricaoOcorrencia" name="descricaoOcorrencia" size="20" class="inputReadOnly8pt"/>
                    <input type="button" id="btnLocalizarOcorrencia" name="btnLocalizaOcorrencia" value="..." class="botoes" onclick="tryRequestToServer(function(){abrirLocalizaOcorrencia()});"/>
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ocorrencia" onClick="javascript:limparOcorrencia();">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas a Cidade Destino:</td>
                <td class="CelulaZebra2">
                    <input name="idcidadedestino" value="0" type="hidden" id="idcidadedestino" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true">
                    <input name="cid_destino" type="text" class="inputReadOnly8pt" id="cid_destino" size="20"  readonly="true">
                    <input name="uf_destino" type="text" class="inputReadOnly8pt" id="uf_destino" size="2"  readonly="true">                   
                    <input type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_destino')" value="...">
                     <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('cid_destino').value='';$('uf_destino').value='';$('idcidadedestino').value=0;"></td>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas a Área de Destino:</div></td>
                <td class="CelulaZebra2">                
                    <input name="area_id" type="hidden" id="area_id" value="0" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true">
                    <input name="sigla_area" type="text" id="sigla_area" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true">
                    <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="tryRequestToServer(function(){launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Destino')})">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Área" onClick="javascript:$('sigla_area').value='';$('area_id').value=0;"></td>
            </tr>
            <tr>
                <td class="TextoCampos">Mostrar NF(s) Entregues:</td>
                <td class="CelulaZebra2">
                    <select id="entregues" name="entregues" class="inputtexto">
                        <option value="" selected>Ambas</option>
                        <option value="sim">Sim</option>
                        <option value="nao">Não</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Mostrar NF(s) Manifestadas:</td>
                <td class="CelulaZebra2">
                    <select id="manifestadas" name="manifestadas" class="inputtexto">
                        <option value="" selected>Todas</option>
                        <option value="sim">Sim</option>
                        <option value="nao">Não</option>
                    </select>
                </td>
            </tr>
            <tr id="trUFs">
                <td class="TextoCampos">
                    <select name="apenasUF" id="apenasUF" class="inputtexto">
                        <option value="IN" selected>Apenas as UFs destino</option>
                        <option value="NOT IN">Exceto as UFs destino</option>
                    </select>                            
                </td>
                <td class="CelulaZebra2">
                    <input name="uf" type="text" id="uf" size="20" maxlength="60" onChange="javascript:$('uf').value = $('uf').value.toUpperCase();" class="inputtexto">
                    <label id="descUF" name="descUF" >Separe as UFs com v&iacute;rgulas </label>                            
                </td>
             </tr>
        </table></td>
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
