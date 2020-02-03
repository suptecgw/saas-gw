<%@page import="despesa.especie.Especie"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.text.*,
         mov_banco.banco.BeanConsultaBanco,
         java.sql.ResultSet,
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
<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relcontaspagar") > 0);
    boolean temacessofiliais = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("reloutrasfiliais") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    
    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    
    //fim da MSA
    String modelo = request.getParameter("modelo");
    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    //String tipoData = (modelo.equals("3") && request.getParameter("tipodata").equals("emissaolanc")? "dtemissao":request.getParameter("tipodata"));

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
        Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
        String numeroCheque = request.getParameter("numeroCheque");
        String ordenacao = "";
        String planoCusto = "";
        String operadorFilial = request.getParameter("apenasfilial");
        String sqlEspecie = (request.getParameter("especie").equals("") ? "" : " and especie " + request.getParameter("apenasEspecie") + "('" + request.getParameter("especie").replaceAll(",", "','") + "') ");        
        //15/06/2015
        String excetoGrupo = request.getParameter("excetoGrupo");
        String sqlGrupo = "";
        String grupos = (request.getParameter("grupos").equals("") ? "" : request.getParameter("grupos"));
        

        if (new Boolean(request.getParameter("grupoFormaPgto"))) {
            ordenacao = " forma_pgamento , ";
        }
        if (new Boolean(request.getParameter("totalizar"))) {
            ordenacao += " dtpago , ";
        }
        ordenacao += (modelo.equals("3") && request.getParameter("ordenacao").equals("emissaolanc") ? "dtemissao" : request.getParameter("ordenacao"));

        planoCusto = (Apoio.parseInt(request.getParameter("idplanocusto_despesa")) == 0) ? "" : " AND " + request.getParameter("idplanocusto_despesa") + " IN (SELECT idplanocusto FROM apropdespesa apd WHERE vbx.idmovimento=apd.idmovimento)";
        
        if(!grupos.equals("")){
            if(excetoGrupo.equals("apenasGrupos")){
                    sqlGrupo = " and idfornecedor IN (select fornecedor_id from fornecedor_grupo_cliente where grupo_cli_for_id IN (" + grupos + "))";
            }else if(excetoGrupo.equals("excetoGrupos")){
                    sqlGrupo = " and idfornecedor IN (select fornecedor_id from fornecedor_grupo_cliente where grupo_cli_for_id NOT IN (" + grupos + "))";
            }
        }
                
        java.util.Map param = new java.util.HashMap(22);
        param.put("ORDENACAO", ordenacao);
        param.put("PLANO_CUSTO", planoCusto);
        param.put("FORNECEDOR", (!request.getParameter("idfornecedor").equals("0") ? "and idfornecedor" + request.getParameter("forn") + request.getParameter("idfornecedor") : ""));
        param.put("FILIAL", (!request.getParameter("idfilial").equals("0") ? (operadorFilial.equals("a") ? " and idfilial=" + request.getParameter("idfilial") : " and idfilial <> " + request.getParameter("idfilial")) : ""));
        param.put("TIPODATA", (modelo.equals("3") && request.getParameter("tipodata").equals("emissaolanc") ? "dtemissao" : request.getParameter("tipodata")));
        param.put("AGRUPAR_FORMA_PGTO", (request.getParameter("grupoFormaPgto")));
        param.put("TOTAL_DIARIO", (Boolean.parseBoolean(request.getParameter("totalizar")) ? "S" : "N"));
        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        param.put("SERIE", (request.getParameter("serie").equals("") ? "" : " and serie" + request.getParameter("apenasSerie") + "'" + request.getParameter("serie") + "' "));
        param.put("CONTA", (!request.getParameter("idconta").equals("0") ? "and idconta=" + request.getParameter("idconta") : ""));
        param.put("CONTA2", (!request.getParameter("idconta").equals("0") ? "and mb.idconta=" + request.getParameter("idconta") : ""));
        param.put("GRUPOS", sqlGrupo);
        param.put("BANCO", (request.getParameter("banco_i").equals("0") ? "" : " and idbanco" + request.getParameter("banc") + "'" + request.getParameter("banco_i") + "' "));
        param.put("CHEQUE", (numeroCheque.trim().equals("") ? "" : " and docum='" + numeroCheque + "' "));
        param.put("MOSTRA_CONTRATO_FRETE", (Apoio.parseBoolean(request.getParameter("mostrar_despesa_contrato")) ? (request.getParameter("mostrar_despesa_contrato_select").equals("mostrar")? " AND is_despesa_carta_frete " : " AND not is_despesa_carta_frete ") : ""));

        String tipoOpcoes = request.getParameter("tipodata").equals("emissaolanc") ? "Emissão" : request.getParameter("tipodata").equals("dtvenc") ? "Vencimento" : "Pagamento";
        param.put("OPCOES", (tipoOpcoes + " entre:" + request.getParameter("dtinicial") + " até " + request.getParameter("dtfinal")));
        //param.put("ESPECIE", request.getParameter("especie").equals("") ? "" : " and especie ilike '" + request.getParameter("especie") + "'");
        param.put("ESPECIE", sqlEspecie);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                
        request.setAttribute("map", param);
        request.setAttribute("rel", "contaspagasmod" + modelo);

    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if (acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_CONTAS_A_PAGAR_E_PAGAS_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">

    function modelos(modelo){
        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("modelo5").checked = false;
   
        $("modelo"+modelo).checked = true;

        if (modelo == 1 || modelo == 2 || modelo == 3){
            $("formaPgto").style.display = ""
        }else{
            $("formaPgto").style.display = "none"
        }
    }
    function mostrarDespesaContrato(){
        if($("mostrar_despesa_contrato").checked == true){
            $("mostrar_despesa_contrato_select").disabled= false;
        }else{
            $("mostrar_despesa_contrato_select").disabled= true;
        }
    }

    function voltar(){
        location.replace("./menu");
    }

    function localizaforn(){
        post_cad = window.open('./localiza?acao=consultar&idlista=21&paramaux=1','Fornecedor',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function limparclifor(){
        document.getElementById("idfornecedor").value = "0";
        document.getElementById("fornecedor").value = "";
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaconta(){
        //Não teve outra alternativa, tive que fazer essa gambi.        
        var limitarUsuarioVisualizarConta = '<%=limitarUsuarioVisualizarConta%>';
        var idUsuario = '<%=idUsuario%>';
        var paramaux4 = "";
        var paramaux = "and true";
        if (limitarUsuarioVisualizarConta == 'true') {
            paramaux4 = "LEFT JOIN usuario_conta uc ON (c.idconta = uc.conta_id) ";
            paramaux = " and uc.usuario_id = " + idUsuario + "";
        }
        post_cad = window.open('./localiza?acao=consultar&idlista=31&paramaux='+paramaux+"&paramaux4="+paramaux4,'Conta',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
    }

    function limparfilial(){
        document.getElementById("idfilial").value = 0;
        document.getElementById("fi_abreviatura").value = "";
    }

    function limparconta(){
        document.getElementById("idconta").value = 0;
        document.getElementById("conta").value = "";
    }
    
    
    function localizaPlanoCusto(){
        post_cad = window.open('./localiza?acao=consultar&idlista=20&paramaux=1','Filial',
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
        if (! validaData(getObj("dtinicial").value) || ! validaData(getObj("dtfinal").value))
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
    
            var impressao;

            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";
        
            launchPDF('./relcontaspagas?acao=exportar&modelo='+modelo+'&impressao='+impressao+
                '&'+concatFieldValue("idfornecedor,idfilial,tipodata,dtinicial,dtfinal,numeroCheque,idplanocusto_despesa,"+
                "serie,idconta,forn,apenasSerie,apenasEspecie,especie,apenasfilial,ordenacao,banco_i,banc, especie")+
                '&grupos='+grupos+'&totalizar='+$('totalPagamento').checked+
                '&mostrar_despesa_contrato='+$('mostrar_despesa_contrato').checked+
                '&mostrar_despesa_contrato_select='+$('mostrar_despesa_contrato_select').value+
                '&grupoFormaPgto='+$('grupoFormaPgto').checked+
                '&excetoGrupo='+$('excetoGrupo').value);
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
  
    
    
  
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Relatório de contas pagas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter(); mostrarDespesaContrato();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');
        aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="idconta" id="idconta" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="0">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de contas pagas</b></td>
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
                <td width="21%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das
                    contas pagas</td>
            </tr>
            <tr>
                <td width="21%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das
                    contas pagas/dados bancários</td>
            </tr>
            <tr>
                <td width="21%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3</div></td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das
                    contas pagas e transferências realizadas</td>
            </tr>
            <tr>
                <td width="21%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4</div></td>
                <td colspan="2" class="CelulaZebra2">Contas pagas agrupadas por data de pagamento (Sintético)</td>
            </tr>
            <tr>
                <td width="21%" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das
                    contas pagas/dados bancários agrupados por fornecedor
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos">Por data de:</td>
                <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="emissaolanc">Emissão (Despesa)</option>
                        <option value="entrada_despesa">Entrada (Despesa)</option>
                        <option value="dtvenc">Vencimento</option>
                        <option value="dtpago" selected>Pagamento</option>
                        <option value="dtemissao">Emissão (Conciliação)</option>
                        <option value="dtentrada">Entrada (Conciliação)</option>
                        <option value="previsao_pagamento" >Previsão de Pagamento</option>
                    </select>
                    entre<strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong></td>
            </tr>
            <tr>
                <td height="24" colspan="2" class="TextoCampos">
                    <div align="center">
                        <input name="totalPagamento" type="checkbox" id="totalPagamento" value="checkbox" checked>
                        Totalizar por data de pagamento
                    </div></td>
                <td width="50%" height="24" class="TextoCampos">
                    <div align="center" id="formaPgto">
                        <input name="grupoFormaPgto" type="checkbox" id="grupoFormaPgto" value="checkbox" >
                        Agrupar por forma de pagamento
                    </div>
                </td>
            </tr>
            <tr class="tabela">
                <td height="18" colspan="3">
                    <div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td colspan="3">

                    <table width="100%" border="0" >
                        <tr>
                            <td class="TextoCampos" >
                                <select id="forn" name="forn" class="inputtexto">
                                    <option value="=" selected>Apenas o fornecedor:</option>
                                    <option value="<>">Exceto o fornecedor:</option>
                                </select>
                            </td>
                            <td class="TextoCampos"><div align="left"><strong>
                                        <input name="fornecedor" type="text" id="fornecedor" class="inputReadOnly" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_clifor" type="button" class="inputBotaoMin" id="localiza_clifor4" value="..." onClick="javascript:localizaforn();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:limparclifor();">
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
                                        <input name="fi_abreviatura" type="text" id="fi_abreviatura" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" class="inputReadOnly" size="35" maxlength="60" readonly="true">
                                        <% if (temacessofiliais) {%>
                                        <input name="localiza_filial" type="button" class="inputBotaoMin" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:limparfilial();">
                                        <%}%>
                                    </strong></div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><select id="apenasSerie" name="apenasSerie" class="inputtexto">
                                    <option value="=" selected>Apenas a s&eacute;rie:</option>
                                    <option value="<>">Exceto a s&eacute;rie:</option>
                                </select></td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="serie" type="text" id="serie" size="2" class="inputtexto">
                                </strong></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos"><select id="apenasEspecie" name="apenasEspecie" class="inputtexto">
                                    <option value=" IN " selected>Apenas a Espécie:</option>
                                    <option value=" NOT IN ">Exceto a Espécie:</option>
                                </select></td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="especie" type="text" id="especie" size="15" class="inputtexto">
                                </strong>Exemplo: NF,NFE,CTE</td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas a conta: </td>
                            <td class="CelulaZebra2"><strong>
                                    <input name="conta" type="text" id="conta" class="inputReadOnly" size="15" maxlength="80" readonly="true">
                                    <input name="localiza_conta" type="button" class="inputBotaoMin" id="localiza_clifor" value="..." onClick="javascript:localizaconta();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:limparconta();"></strong></td>
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
                                    </strong>
                                </div></td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                <select id="banc" name="banc" class="inputtexto">
                                    <option value="=" selected>Apenas o banco:</option>
                                    <option value="<>">Exceto o banco:</option>
                                </select>
                            </td>
                            <td class="CelulaZebra2">

                                <select name="banco_i" id="banco_i" class="inputtexto">
                                    <option value="0" selected>Todos os bancos</option>
                                    <% BeanConsultaBanco banco = new BeanConsultaBanco();
                                        banco.setConexao(Apoio.getUsuario(request).getConexao());
                                        banco.MostrarTudo();
                                        ResultSet rs = banco.getResultado();
                                        while (rs.next()) {%>
                                    <option value="<%=rs.getString("idbanco")%>" ><%=rs.getString("numero") + "-" + rs.getString("descricao")%></option>
                                    <%}%>
                                </select>
                        </tr>
                        <tr>
                            <td class="TextoCampos">
                                Apenas o Doc/Cheque:
                            </td>
                            <td class="CelulaZebra2">
                                <input name="numeroCheque" type="text" id="numeroCheque" size="6" maxlength="12" class="inputtexto">
                            </td>
                        </tr>
                    </table></td>
            </tr>
            <tr>
                            <td colspan="3" class="TextoCampos"><div align="center">
                                    <input type="checkbox" name="mostrar_despesa_contrato" id="mostrar_despesa_contrato" onClick="javascript:mostrarDespesaContrato();" >
                                    <select id="mostrar_despesa_contrato_select" class="inputtexto" >
                                    <option value="mostrar">Mostrar apenas despesas de contratos de fretes (Adiantamento e Saldo)</option>
                                    <option value="naoMostrar">Não mostrar apenas despesas de contratos de fretes (Adiantamento e Saldo)</option>
                                    </select></div></td>
                        </tr>
            <tr style="display: none;">
                <td class="TextoCampos" >Apenas a esp&eacute;cie:</td>
                <td colspan="2" class="CelulaZebra2">
                    <%Especie es = new Especie();
                        rs = es.all(Apoio.getUsuario(request).getConexao());%> 
                    <select name="especieq" id="especieq" class="inputtexto">
                        <option value="">Todas</option>
                        <%while (rs.next()) {%>
                        <option value="<%=rs.getString("especie")%>"><%=rs.getString("especie") + " - " + rs.getString("descricao")%></option>
                        <%}%>   
                    </select>
                </td>
            </tr>
            
            <tr>
                <td colspan="3">
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tr class="cellNotes">
                            <td width="05%" class="CelulaZebra2">
                                <div align="center">
                                    <img src="img/add.gif" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">
                                </div>
                            </td>
                            <td width="95%" class="CelulaZebra2">
                                <div align="center">
                                    <select name="excetoGrupo" id="excetoGrupo" class="inputtexto">
                                        <option value="apenasGrupos" selected>Apenas os grupos de Fornecedores</option>
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
                            <option value="emissaolanc">Emiss&atilde;o</option>
                            <option value="dtvenc" selected>Vencimento</option>
                            <option value="dtpago" >Pagamento</option>
                            <option value="nfiscal">Nota Fiscal</option>
                            <option value="docum">Doc/Cheque</option>
                        </select>
                    </div></td>
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
