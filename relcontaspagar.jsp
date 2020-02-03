<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="despesa.especie.Especie"%>

<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("relcontaspagar") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
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
        String modelo = request.getParameter("modelo");
        String planoCusto = "";
        String operadorFilial = request.getParameter("apenasfilial");
        String ordenacao = request.getParameter("ordenacao");
        String idFornecedor = (!request.getParameter("idfornecedor").equals("0") ? " and idfornecedor" + request.getParameter("forn") + request.getParameter("idfornecedor") : "");
        //16/06/2015
        String mostrarDespesas = (request.getParameter("hidMostrarDespesa").equals("a") ? "" : request.getParameter("hidMostrarDespesa"));
        String despesasEnviadas = "";        
        String despesasEnviadasLeftJoin = "";
        String excetoGrupo = request.getParameter("excetoGrupo");
        String sqlGrupo = "";
        String grupos = (request.getParameter("grupos").equals("") ? "" : request.getParameter("grupos"));

        if (modelo.equals("3") || modelo.equals("6")) {
            planoCusto = (Apoio.parseInt(request.getParameter("idplanocusto_despesa")) == 0) ? "" : " AND " + request.getParameter("idplanocusto_despesa") + " IN (SELECT idplanocusto FROM apropdespesa apd WHERE vbx.idmovimento=apd.idmovimento)";
            if (ordenacao.equals("dtvenc")) {
                ordenacao = "CASE WHEN baixado THEN dtentrada ELSE dtvenc END";
            }
        }else if (modelo.equals("1")) {
            idFornecedor = (!request.getParameter("idfornecedor").equals("0") ? " idfornecedor" + request.getParameter("forn") + request.getParameter("idfornecedor") + " AND " : "");
            planoCusto = (Apoio.parseInt(request.getParameter("idplanocusto_despesa")) == 0) ? "" : " AND " + request.getParameter("idplanocusto_despesa") + " IN (SELECT idplanocusto FROM apropdespesa apd WHERE vrp.idmovimento=apd.idmovimento)";
            
        }else if(modelo.equals("7") || modelo.equals("4") || modelo.equals("5") || modelo.equals("2")){
            planoCusto = (Apoio.parseInt(request.getParameter("idplanocusto_despesa")) == 0) ? "" : " AND " + request.getParameter("idplanocusto_despesa") + " IN (SELECT idplanocusto FROM apropdespesa apd WHERE vrp.idmovimento=apd.idmovimento)";        

        } else {
            planoCusto = (Apoio.parseInt(request.getParameter("idplanocusto_despesa")) == 0) ? "" : "AND " + request.getParameter("idplanocusto_despesa") + " IN(SELECT idplanocusto FROM apropdespesa apd WHERE vbx.idmovimento=apd.idmovimento)";
        }
        String mostraBaixadosApos = "";
        
        if(modelo.equals("2") || modelo.equals("4") || modelo.equals("5") || modelo.equals("7")){
            mostraBaixadosApos = Boolean.parseBoolean(request.getParameter("chkabertodia")) ? " OR (dtpago > '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) 
                + "' AND "+request.getParameter("tipodata")+" <= '"
                + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "' "+ idFornecedor +
                    (!request.getParameter("idfilial").equals("0") ? (operadorFilial.equals("a") ? " and idfilial=" + request.getParameter("idfilial") : " and idfilial <> " + request.getParameter("idfilial")) : "")
                    +")"
                : "";
        }else{
            mostraBaixadosApos = (Boolean.parseBoolean(request.getParameter("chkabertodia")) ? " OR (dtpago > '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "' AND "+request.getParameter("tipodata")+" <= '" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "')" : "");
        }  
        //duplicatas
        
        String alias= "";
        if(modelo.equals("7")){
            alias= "vrp.";
        }
        //16/06/2015
        if(modelo.equals("3") || modelo.equals("6")){
            if(mostrarDespesas.equals("e")){
                despesasEnviadasLeftJoin = " LEFT JOIN contas_pagar_arquivo cpa ON cpa.duplicata_id = vbx.id ";
                despesasEnviadas = " AND cpa.id is not null ";
            }else if(mostrarDespesas.equals("n")){
                despesasEnviadasLeftJoin = " LEFT JOIN contas_pagar_arquivo cpa ON cpa.duplicata_id = vbx.id ";
                despesasEnviadas = " AND cpa.id is null ";
            }
        }else{
           if(mostrarDespesas.equals("e")){
                despesasEnviadasLeftJoin = " LEFT JOIN contas_pagar_arquivo cpa ON cpa.duplicata_id = vrp.id ";
                despesasEnviadas = " AND cpa.id is not null ";
            }else if(mostrarDespesas.equals("n")){
                despesasEnviadasLeftJoin = " LEFT JOIN contas_pagar_arquivo cpa ON cpa.duplicata_id = vrp.id ";
                despesasEnviadas = " AND cpa.id is null ";
            } 
        }       
        
        if(!grupos.equals("")){
            if(excetoGrupo.equals("apenasGrupos")){
                    sqlGrupo = " and idfornecedor IN (select fornecedor_id from fornecedor_grupo_cliente where grupo_cli_for_id IN (" + grupos + "))";
            }else if(excetoGrupo.equals("excetoGrupos")){
                    sqlGrupo = " and idfornecedor IN (select fornecedor_id from fornecedor_grupo_cliente where grupo_cli_for_id NOT IN (" + grupos + "))";
            }
        }
        
        java.util.Map param = new java.util.HashMap(21);
        param.put("PLANO_CUSTO", planoCusto);
        param.put("FORNECEDOR", idFornecedor);
        param.put("FILIAL", (!request.getParameter("idfilial").equals("0") ? (operadorFilial.equals("a") ? " and "+alias+"idfilial=" + request.getParameter("idfilial") : " and "+alias+"idfilial <> " + request.getParameter("idfilial")) : ""));
        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        param.put("TIPO_DATA", request.getParameter("tipodata"));
        param.put("TOTAL_DIARIO", (Boolean.parseBoolean(request.getParameter("totalizar")) ? "S" : "N"));
        param.put("ORDENACAO", ordenacao + ",");
        param.put("LIBERADOS", (request.getParameter("lib").equals("todos") ? "" : " and pagtolib=" + request.getParameter("lib")));
        param.put("SERIE", (request.getParameter("serie").equals("") ? "" : " and serie" + request.getParameter("apenasSerie") + "'" + request.getParameter("serie") + "'"));

        param.put("GRUPOS", sqlGrupo);
        param.put("OPCOES", "Período selecionado entre : " + request.getParameter("dtinicial") + " e " + request.getParameter("dtfinal"));
        param.put("MOSTRA_SALDO", (Boolean.parseBoolean(request.getParameter("mostrarSaldos")) ? " " : " and saldo_carta_autorizado "));
        param.put("MOSTRA_CONTRATO_FRETE", (Apoio.parseBoolean(request.getParameter("mostrar_despesa_contrato")) ? (request.getParameter("mostrar_despesa_contrato_select").equals("mostrar")? " AND is_despesa_carta_frete " : " AND not is_despesa_carta_frete ") : ""));
        param.put("BAIXADOS_POSTERIOR", mostraBaixadosApos);
        param.put("ESPECIE", request.getParameter("especie").equals("") ? "" : " and especie ilike '" + request.getParameter("especie") + "'");
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        param.put("MOSTRAR_DESPESAS", despesasEnviadas);
        param.put("MOSTRAR_DESPESAS_LEFT_JOIN", despesasEnviadasLeftJoin);        
        
        request.setAttribute("map", param);
        request.setAttribute("rel", "contaspagarmod" + request.getParameter("modelo"));
        
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CONTAS_A_PAGAR_E_PAGAS_RELATORIO.ordinal());
    }
%>

<jsp:useBean id="desp" class="despesa.BeanDespesa" />
<script language="javascript" type="text/javascript">
    function voltar(){
        location.replace("./menu");
    }

    function modelos(modelo){
        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("modelo5").checked = false;
        $("modelo6").checked = false;
        $("modelo7").checked = false;
        $("trTotalVencimento").style.display = "none";
        $("trMostrarQuitadas").style.display = "";
   
	
        if (modelo==1){
            $("trTotalVencimento").style.display = "";
        }
        if (modelo==2){
            $("ordenacao").value = "razaosocial";
        }
        if(modelo == 3){
            $("trMostrarQuitadas").style.display = "none";
        }
        if(modelo == 5){
            $("trTotalVencimento").style.display = "";
        }
        if(modelo == 6){
            $("trMostrarQuitadas").style.display = "none";
        }
        if (modelo==7){
            $("ordenacao").value = "razaosocial";
        }
    
        $("modelo"+modelo).checked = true;
    }
  
    function localizaforn(){
        post_cad = window.open('./localiza?acao=consultar&idlista=21&paramaux=1','Fornecedor',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparforn(){
        document.getElementById("idfornecedor").value = "0";
        document.getElementById("fornecedor").value = "";
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function limparfilial(){
        document.getElementById("idfilial").value = 0;
        document.getElementById("fi_abreviatura").value = "";
    }
    function localizaPlanoCusto(){
        post_cad = window.open('./localiza?acao=consultar&idlista=20&paramaux=1','Plano_de_Custo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    function limparPlanoCusto(){
        document.getElementById("idplanocusto_despesa").value = 0;
        document.getElementById("plcusto_conta_despesa").value = "";
        document.getElementById("plcusto_descricao_despesa").value = "";
    }

    function popRel(){
        var modelo; 
        var grupos = getGrupos();
        if (! validaData(document.getElementById("dtinicial").value) || !validaData(document.getElementById("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else{
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
            else if (getObj("modelo6").checked)
                modelo = '6';
            else if (getObj("modelo7").checked)
                modelo = '7';
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else  
                impressao = "3";
        
            launchPDF('./relcontaspagar?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+
                concatFieldValue("idfornecedor,idfilial,tipodata,dtinicial,dtfinal,lib,serie,ordenacao,forn,apenasSerie, apenasfilial,idplanocusto_despesa, especie")
                +'&grupos='+grupos+'&totalizar='+$('totalVencimento').checked
                +'&mostrarSaldos='+$('mostrar_saldos').checked
                +'&chkabertodia='+$('chkabertodia').checked
                +'&mostrar_despesa_contrato_select='+$('mostrar_despesa_contrato_select').value
                +'&mostrar_despesa_contrato='+$('mostrar_despesa_contrato').checked
                +'&hidMostrarDespesa=' + $('hidMostrarDespesa').value
                +'&excetoGrupo=' + $('excetoGrupo').value);
        }
    }

    function aoClicarNoLocaliza(idjanela)
    {          
        if (idjanela == "Grupo"){
            addGrupo($('grupo_id').value,'node_grupos', $('grupo').value)
        }
    }
    
    function mostrarDespesaContrato(){
        if($("mostrar_despesa_contrato").checked == true){
            $("mostrar_despesa_contrato_select").disabled= false;
        }else{
            $("mostrar_despesa_contrato_select").disabled= true;
        }
    }
    //função para alternar os valores do type="radio"
    function alternarValues(){       
        if($("mostrarAmbas").checked){
            $("hidMostrarDespesa").value = $("mostrarAmbas").value;           
        }else if($("mostrarEnviadas").checked){
            $("hidMostrarDespesa").value = $("mostrarEnviadas").value;            
        }else if($("mostrarNaoEnviadas").checked){
            $("hidMostrarDespesa").value = $("mostrarNaoEnviadas").value;                        
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

        <title>Webtrans - Relatório de contas a pagar</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();mostrarDespesaContrato();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');
        aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="0">
        </div>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <td><b>Relat&oacute;rio de contas a pagar</b></td>
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
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do
                    contas a pagar</td>
            </tr>
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do
                    contas a pagar (Agrupadas por fornecedor)</td>
            </tr>
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3 </div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do
                    contas a pagar e cheques/Documentos a conciliar </td>
            </tr>  
            <tr> 
                <td width="23%" height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4 </div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do contas a pagar agrupadas por vencimento (Sintético) </td>
            </tr>  
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do contas a pagar com impostos retidos</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo6" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                        Modelo 6 </div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do
                    contas a pagar e cheques/documentos a conciliar (Agrupados por fornecedor) </td>
            </tr>
            <tr> 
                <td class="TextoCampos"> <div align="left"> 
                        <input name="modelo7" id="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                        Modelo 7</div></td>
                <td colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o do
                    contas a pagar (Agrupadas por fornecedor) com apropriação</td>
            </tr>
            <tr class="tabela"> 
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr> 
                <td height="24" class="TextoCampos">Por data de:</td>
                <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="dtemissao">Emissão</option>
                        <option value="entrada_despesa">Entrada</option>
                        <option value="dtvenc" selected>Vencimento</option>
                        <option value="previsao_pagamento" >Previsão de Pagamento</option>
                    </select>
                    entre<strong> 
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong> 
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" onchange="javascript:$('lbDataFinal').innerHTML = this.value;"/>
                    </strong></td>
            </tr>
            <tr id="trTotalVencimento">
                <td height="24" colspan="2" class="TextoCampos">
                    <div align="center">
                        <input name="totalVencimento" type="checkbox" id="totalVencimento" value="checkbox" checked>
                        Totalizar por data de vencimento </div></td>
                <td width="50%" height="24" class="TextoCampos">&nbsp;</td>
            </tr>
            <tr class="tabela"> 
                <td height="18" colspan="3"> <div align="center">Filtros</div></td>
            </tr>
            <tr> 
                <td height="78" colspan="3"> <table width="100%" border="0" >
                        <tr> 
                            <td class="TextoCampos">Apenas os pagtos:</td>
                            <td class="CelulaZebra2"><select id="lib" name="lib" class="inputtexto">
                                    <option value="todos" selected>Todos</option>
                                    <option value="true">Liberados</option>
                                    <option value="false">Não liberados</option>
                                </select></td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos">
                                <select id="forn" name="forn" class="inputtexto">
                                    <option value="=" selected>Apenas o fornecedor:</option>
                                    <option value="<>">Exceto o fornecedor:</option>
                                </select>          </td>
                            <td class="TextoCampos"><div align="left"><strong> 
                                        <input name="fornecedor" type="text" id="fornecedor" class="inputReadOnly" size="31" maxlength="80" readonly="true">
                                        <input name="localiza_forn" type="button" class="inputBotaoMin" id="localiza_forn" value="..." onClick="javascript:localizaforn();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparforn();"> 
                                    </strong></div></td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos">
                                <select id="apenasfilial" name="apenasfilial" class="inputtexto">
                                    <option value="a" selected>Apenas a filial:</option>
                                    <option value="e">Exceto a filial:</option>
                                </select>     

                            </td>

                            <td class="TextoCampos"><div align="left"><strong> 
                                        <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="31" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_filial" type="button" class="inputBotaoMin" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:limparfilial();"> 
                                        <%}%>
                                    </strong></div></td>
                        </tr>
                        <tr> 
                            <td class="TextoCampos"><div align="right">Apenas um Plano de Custo:</div></td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="plcusto_conta_despesa" type="text" id="plcusto_conta_despesa" value="" class="inputReadOnly" size="8" maxlength="60" readonly="true">
                                        <input name="plcusto_descricao_despesa" type="text" id="plcusto_descricao_despesa" value="" class="inputReadOnly" size="23" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_planoCusto" type="button" class="inputBotaoMin" id="planoCusto" value="..." onClick="javascript:localizaPlanoCusto();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Plano de Custo" onClick="javascript:limparPlanoCusto();"> 
                                        <%}%>
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><select id="apenasSerie" name="apenasSerie" class="inputtexto">
                                    <option value="=" selected>Apenas a s&eacute;rie:</option>
                                    <option value="&lt;&gt;">Exceto a s&eacute;rie:</option>
                                </select></td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="serie" type="text" id="serie" size="2" maxlength="3" class="inputtexto">
                                </strong></td>
                        </tr>
                        <tr>
                            <td colspan="2" class="TextoCampos"><div align="center">
                                    <input type="checkbox" name="mostrar_saldos" id="mostrar_saldos" checked>
                                    Mostrar saldos de contratos de fretes n&atilde;o autorizados</div></td>
                        </tr>
                        <tr>
                            <td colspan="2" class="TextoCampos"><div align="center">
                                    <input type="checkbox" name="mostrar_despesa_contrato" id="mostrar_despesa_contrato" onchange="mostrarDespesaContrato();" >
                                    <select id="mostrar_despesa_contrato_select" class="inputtexto">
                                    <option value="mostrar">Mostrar apenas despesas de contratos de fretes (Adiantamento e Saldo)</option>
                                    <option value="naoMostrar">Não mostrar apenas despesas de contratos de fretes (Adiantamento e Saldo)</option>
                                    </select></div></td>
                        </tr>
                        <tr name="trMostrarQuitadas" id="trMostrarQuitadas">
                            <td colspan="2" class="TextoCampos"><div align="center" >
                                    <input type="checkbox" name="chkabertodia" id="chkabertodia" value="check">
                                    Mostrar duplicatas quitadas mas que estavam em aberto até o dia
                                    <label name="lbDataFinal" id="lbDataFinal">
                                        <%=Apoio.getDataAtual()%>
                                    </label>
                                </div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas a esp&eacute;cie:</td>
                            <td class="CelulaZebra2">
                                <%Especie es = new Especie();
                                    ResultSet rs = es.all(Apoio.getUsuario(request).getConexao());%> 
                                <select name="especie" id="especie" class="inputtexto">
                                    <option value="">Todas</option>
                                    <%while (rs.next()) {%>
                                    <option value="<%=rs.getString("especie")%>"><%=rs.getString("especie") + " - " + rs.getString("descricao")%></option>
                                    <%}%>   
                                </select>
                            </td>
                        </tr>
                    </table></td>
            <tr>
                    <td colspan="3">
                        <table width="100%" cellspacing="0,1" cellpadding="8">
                            
                                <td class="TextoCampos" >Mostrar apenas despesas enviadas para o banco (Arquivo de remessa):</td>
                                <td class="CelulaZebra2">
                                    <input id="hidMostrarDespesa" type="hidden" value="a" name="hidMostrarDespesa"/>
                                    <input id="mostrarAmbas" type="radio" value="a" name="mostrarDespesa" onclick="alternarValues();" checked/> Ambas
                                    <input id="mostrarEnviadas" type="radio" value="e" name="mostrarDespesa" onclick="alternarValues();" /> Enviadas
                                    <input id="mostrarNaoEnviadas" type="radio" value="n" name="mostrarDespesa" onclick="alternarValues();"/> Não enviadas
                                </td>
                            
                        </table>
                    </td>
            </tr>                    
            <tr> 
                <td colspan="9"> 
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tr class="cellNotes"> 
                            <td width="05%" class="CelulaZebra2">
                                <div align="center">
                                    <img src="img/add.gif" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">
                                </div>
                            </td>
                            <td width="95%" class="CelulaZebra2">
                                <div align="center">
                                    <select id="excetoGrupo" class="inputtexto" name="excetoGrupo">
                                        <option value="apenasGrupos" selected="">Apenas os Grupos de Fornecedores</option>
                                        <option value="excetoGrupos">Exceto os grupos de Fornecedores</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                    </table>                    
                </td>
            </tr>

            <tr class="tabela"> 
                <td colspan="3"><div align="center">Ordena&ccedil;&atilde;o</div></td>
            </tr>
            <tr> 
                <td colspan="3" class="TextoCampos"><div align="center">
                        <select id="ordenacao" name="ordenacao" class="inputtexto">
                            <option value="dtemissao">Emiss&atilde;o</option>
                            <option value="dtvenc" selected>Vencimento</option>
                            <option value="nfiscal">Nota Fiscal</option>
                            <option value="razaosocial">Fornecedor</option>
                        </select>
                    </div></td>
            </tr>
            <tr>
                <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
            </tr>
            <tr>
                <td colspan="3" class="TextoCampos">
                    <div align="center">
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
