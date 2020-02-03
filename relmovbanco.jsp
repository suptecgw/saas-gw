<%@page import="java.net.URLDecoder"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="mov_banco.BeanCadMovBanco"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.sql.ResultSet,
         mov_banco.conta.*,
         nucleo.BeanLocaliza,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("relmovbanco") > 0);
            boolean temacessocontas = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("cadconta") == 4);
            int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
            boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
            int idUsuario = Apoio.getUsuario(request).getIdusuario();
            String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

            BeanConfiguracao cfg = null;
            cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();
            if (acao.equals("exportar")) {
                SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
                Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
                Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
                java.util.Map param = new java.util.HashMap(30);
                StringBuilder opcoes = new StringBuilder();
                String modelo = request.getParameter("modelo");
                String conta = request.getParameter("conta");
                String idsContaPrincipal = (conta.equals("") ? "" : conta.substring(0,conta.length()-1));
                String sqlConta = "";
                boolean isTotalDiario = (request.getParameter("mostrarTotalDiario") != null && Boolean.parseBoolean(request.getParameter("mostrarTotalDiario")));
                boolean ocultarDetalhes = Boolean.parseBoolean(request.getParameter("ocultarDetalhes"));
                if (modelo.equals("1")) {
                    sqlConta = (conta.equals("") ? "" : conta.substring(0,conta.length()-1));
                } else if (modelo.equals("3")) {
                    sqlConta = (conta.equals("0") ? "" : " AND mb.idconta in (" + conta.substring(0,conta.length()-1) + ")");
                } else if (modelo.equals("4")){
                    sqlConta = (conta.equals("") ? "" : " AND idconta in (" + conta.substring(0, conta.length() - 1) + ")");
                } else if (modelo.equals("5")) {
                    sqlConta = (conta.equals("") ? "" : " AND vrel.idconta in (" + conta.substring(0,conta.length()-1) + ")");
                } else if (modelo.equals("6")){
//                    sqlConta = (ocultarDetalhes ? "true":"false");
                    sqlConta = (conta.equals("") ? "" : " AND c.idconta in (" + conta.substring(0,conta.length()-1) + ")");
                }else {
                    sqlConta = conta;
                }
                String motivo = "";
                String fornecedor = (request.getParameter("idfornecedor").equals("0") ? "" : " AND fornecedor_id=" + request.getParameter("idfornecedor"));
                String fornecedor2 = "";

                
                if (!request.getParameter("chequeDe").equals("") && !request.getParameter("chequeAte").equals("")) {
                    param.put("TIPODATA", "docum");
                    if (modelo.equals("3")) {
                        param.put("TIPODATA", "docum::integer");
                        param.put("DATA_INI", request.getParameter("chequeDe"));
                        param.put("DATA_FIM", request.getParameter("chequeAte") + " AND docum <> '' ");
                    } else if (modelo.equals("6")) {
                        param.put("TIPODATA", "cd.docum::integer");
                        param.put("DATA_INI", "'" + request.getParameter("chequeDe") + "'::integer");
                        param.put("DATA_FIM", "'" + request.getParameter("chequeAte") + "'::integer");
                    } else {
                        param.put("DATA_INI", "'" + request.getParameter("chequeDe") + "'");
                        param.put("DATA_FIM", "'" + request.getParameter("chequeAte") + "'");
                    }
                } else {
                    param.put("TIPODATA", request.getParameter("tipodata"));
                    param.put("DATA_INI", "'" + new SimpleDateFormat("yyyy-MM-dd").format(dtinicial) + "'");
                    param.put("DATA_FIM", "'" + new SimpleDateFormat("yyyy-MM-dd").format(dtfinal) + "'");
                }
                if (modelo.equals("6") && !request.getParameter("chequeDe").equals("") && !request.getParameter("chequeAte").equals("")) {
                    opcoes.append("Cheques entre ").append(request.getParameter("chequeDe")).append(" até ").append(request.getParameter("chequeAte")).append(".");
                } else {
                    opcoes.append("Período entre ").append(new SimpleDateFormat("dd/MM/yyyy").format(dtinicial)).append(" até ").append(new SimpleDateFormat("dd/MM/yyyy").format(dtfinal));
                    opcoes.append((request.getParameter("idmotorista").equals("0") ? "" : ", Apenas o motorista " + request.getParameter("motor_nome")));
                }

                if (modelo.equals("1") || modelo.equals("7")) {
                    opcoes.append((request.getParameter("idfornecedor").equals("0") ? "" : ", Apenas o fornecedor " + request.getParameter("fornecedor")));
                }
                if (modelo.equals("3")) {
                    motivo = (request.getParameter("idMotivo").equals("0") ? " " : " AND motivo_cheque_cancelado_id=" + request.getParameter("idMotivo"));
                }

                //Sql do fornecedor
                if (modelo.equals("8")) {
                    fornecedor = (request.getParameter("idfornecedor").equals("0") ? "" : " AND fornecedor_id=" + request.getParameter("idfornecedor"));
                    fornecedor2 = (request.getParameter("idfornecedor").equals("0") ? "" : " AND d.idfornecedor=" + request.getParameter("idfornecedor"));
                }
                
                String sqlConciliado = "";
                String sqlMotorista = "";
                String sqlTransferencia = "";
                String sqlStatus = "";
                String sqlHistorico = "";
                String sqlHistoricoId = "";
                String contaTransferencia = "";
                
                int idContaTransferencia = 0;
                boolean mostrarTransferencia = Apoio.parseBoolean(request.getParameter("mostrarTransferencias"));
                if (mostrarTransferencia) {
                    contaTransferencia = request.getParameter("conta_transferencia");
                    System.out.println(contaTransferencia);
                    idContaTransferencia = Apoio.parseInt(request.getParameter("idconta_transferencia"));
                    if (idContaTransferencia != 0) {
                        opcoes.append(". Apenas Transferencias De/Para a conta "+URLDecoder.decode(contaTransferencia, "ISO-8859-1"));
                    }
                }
                
                if (modelo.equals("1")){
                    sqlConta = (conta.equals("") || conta.equals("0") ? "''" : "'"+conta.substring(0,conta.length()-1)+"'");
                    if (request.getParameter("conciliado").equals("and not vrel.conciliado")){
                        sqlConciliado = "'false'::varchar";
                    }else if(request.getParameter("conciliado").equals("and vrel.conciliado")){
                        sqlConciliado = "'true'::varchar";
                    }else{
                        sqlConciliado = "''::varchar";
                    }
                    sqlMotorista = (request.getParameter("idmotorista").equals("0") ? "''::varchar" : "'"+request.getParameter("idmotorista")+"'::varchar");
                    fornecedor = (request.getParameter("idfornecedor").equals("0") ? "''::varchar" : "'"+request.getParameter("idfornecedor")+"'::varchar");
                    sqlTransferencia = (request.getParameter("mostrarTransferencias").equals("true") ? "'t'" : "''::varchar");
                    sqlStatus = (request.getParameter("status").equals("AND true") ? "''" : (request.getParameter("status").equals("AND valor > 0") ? " 'CREDITO' " : " 'DEBITO' " ) );
                    sqlHistoricoId = (request.getParameter("idhist").equals("0") ? "''::varchar" : "'"+request.getParameter("idhist")+"'::varchar");
                    sqlHistorico = "'"+request.getParameter("descricao_historico").trim()+"'::varchar";
                    param.put("isMostrarDetalhe", (ocultarDetalhes ? false : true));
                    param.put("TIPODATA", "'"+request.getParameter("tipodata")+"'::varchar");
                    param.put("TIPO_DATA_ORDER", request.getParameter("tipodata"));
                    param.put("DATA_INI", "'" + new SimpleDateFormat("yyyy-MM-dd").format(dtinicial) + "'::date");
                    param.put("DATA_FIM", "'" + new SimpleDateFormat("yyyy-MM-dd").format(dtfinal) + "'::date");
                }else if (modelo.equals("5")){
                    sqlConciliado = (request.getParameter("conciliado").equals("todos") ? "" : request.getParameter("conciliado"));
                    sqlMotorista = (request.getParameter("idmotorista").equals("0") ? "" : " AND motorista_id=" + request.getParameter("idmotorista"));
                    sqlTransferencia = (request.getParameter("mostrarTransferencias").equals("true") ? " and vrel.tipo = 't' " : "");
                    // Fazendo o replace para resolver problema de ambiguidade da coluna "valor", em vrelconciliacao (vrel) e mov_banco (mv).
                    // Caused by: org.postgresql.util.PSQLException: ERROR: column reference "valor" is ambiguous
                    sqlStatus = StringUtils.replace(request.getParameter("status"), "valor", "vrel.valor");
                }else{
                    sqlConciliado = (request.getParameter("conciliado").equals("todos") ? "" : StringUtils.replace(request.getParameter("conciliado"), "vrel.", ""));
                    sqlMotorista = (request.getParameter("idmotorista").equals("0") ? "" : " AND motorista_id=" + request.getParameter("idmotorista"));
                    sqlTransferencia = (request.getParameter("mostrarTransferencias").equals("true") ? " and tipo = 't' " : "");
                }
                param.put("CONCILIADO", sqlConciliado);
                param.put("MOTORISTA", sqlMotorista);
                param.put("FORNECEDOR", fornecedor);
                param.put("FORNECEDOR2", fornecedor2);
                param.put("IDCONTA", sqlConta);
                param.put("TRANSFERENCIA", sqlTransferencia);
                param.put("OPCOES", opcoes.toString());
                param.put("MOTIVO", motivo);
                param.put("EMPRESA", Apoio.getUsuario(request).getFilial().getRazaosocial() + " CNPJ: " + Apoio.getUsuario(request).getFilial().getCnpj());
                param.put("CIDADE_EMPRESA", Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade());
                param.put("MOSTRAR_TOTAL_DATA", (isTotalDiario ? "S" : "N"));
                param.put("STATUS", sqlStatus);
                param.put("HISTORICO", sqlHistorico);
                param.put("HISTORICO_ID", sqlHistoricoId);
                param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                param.put("IDCLIENTE",(request.getParameter("idconsignatario")));     
                param.put("VEICULO_ID", request.getParameter("idveiculo"));
                param.put("CONTA_TRANSFERENCIA_ID", idContaTransferencia);
                param.put("CONTA_PRINCIPAL", idsContaPrincipal);
                param.put("AJUDANTE_ID", Apoio.parseInt(request.getParameter("idajudante")));
                param.put("FUNCIONARIO_ID", Apoio.parseInt(request.getParameter("idFuncionario")));
                
                request.setAttribute("map", param);
                request.setAttribute("rel", "movbancomod" + modelo);

                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
                dispacher.forward(request, response);
            }else if (acao.equals("iniciar")){
                request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_MOVIMENTACAO_BANCARIA_RELATORIO.ordinal());
            }

%>


<script language="javascript" type="text/javascript">
    function voltar(){
        location.replace("./menu");
    }

    function alterandoConta(){
        if (getObj("modelo1").checked){
            var contFor = false;
            for(var i = 0; i < arrayContas.length; i++){
                if($("conta_"+arrayContas[i]).value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%>){
                    contFor = true;        
                }
            }
            if(contFor){
                $('trFornecedor').style.display = "";
            }else{
                $('trFornecedor').style.display = "none";
            }
        }
    }

    function modelos(modelo){
        
        invisivel($("trConta"));
        invisivel($("divApenasConciliado"));
        invisivel($("conciliado"));
        invisivel($("trTipoTransf"));
        $("mostrarTransferencias").checked = false;
        invisivel($("trTipoTransfConta"));
        invisivel($("trConsultaCheque"));
        invisivel($("trFornecedor"));
        invisivel($("trOcultarDetalhes"));
        invisivel($("trTotalDiario"));
        invisivel($("trStatus"));
        invisivel($("trCliente"));
        
        $("tipodata").disabled = false;
    
        getObj("modelo1").checked = false;
        getObj("modelo2").checked = false;
        getObj("modelo3").checked = false;
        getObj("modelo4").checked = false;
        getObj("modelo5").checked = false;
        getObj("modelo6").checked = false;
        getObj("modelo7").checked = false;
        getObj("modelo8").checked = false;
    
        getObj("modelo"+modelo).checked = true;
        HabilitarDesabilitarTodos(false);
        invisivel($("trHistorico"));

        if (modelo == "1"){
            HabilitarDesabilitarTodos(false);
            visivel($("trOcultarDetalhes"));
            visivel($("trTotalDiario"));
            visivel($("trHistorico"));
        }
        if (modelo == "1" || modelo == "5"){
            visivel($("divApenasConciliado"));
            visivel($("conciliado"));
            visivel($("trTipoTransf"));
            $("chequeDe").value = "";
            $("chequeAte").value = "";
            visivel($("divApenasConciliado"));
            visivel($("conciliado"));
            visivel($("trFornecedor"));
            visivel($("trConta"));
            visivel($("trStatus"));
            alterandoConta();
            invisivel($("trMotivoCancelamentoCheque"));
        }
        if (modelo == "2"){
            $("chequeDe").value = "";
            $("chequeAte").value = "";
            visivel($("divApenasConciliado"));
            visivel($("conciliado"));
            visivel($("trConta"));
//            $('conta').value = '0';
            HabilitarDesabilitarTodos(true);
            invisivel($("trMotivoCancelamentoCheque"));
            invisivel($("trStatus"));
        }

        if (modelo == "3") {
            invisivel($("trmotorista"));
            invisivel($("trAjudanteADV"));
            invisivel($("trFuncionarioADV"));
        } else {
            visivel($("trmotorista"));
            visivel($("trAjudanteADV"));
            visivel($("trFuncionarioADV"));
        }
            
        if (modelo == "3" || modelo == "6"){
            HabilitarDesabilitarTodos(false);
            visivel($("trConsultaCheque"));
            visivel($("divApenasConciliado"));
            visivel($("conciliado"));
            visivel($("trConta"));
            
            
            if(modelo == "3"){
                visivel($("trMotivoCancelamentoCheque"));
                visivel($("trStatus"));
            }else {
                invisivel($("trMotivoCancelamentoCheque"));
                invisivel($("trStatus"));
            }
            
        }

        if (modelo == "4"){
            HabilitarDesabilitarTodos(false);
            $("tipodata").value = "dtentrada";
            $("tipodata").disabled = true;
            $("chequeDe").value = "";
            $("chequeAte").value = "";
            visivel($("trConsultaCheque"));
            visivel($("trConta"));
            invisivel($("trMotivoCancelamentoCheque"));
            invisivel($("trStatus"));
        }
        
        if(modelo == "5"){
            visivel($("trCliente"));
        }

        if (modelo == "7"){
            visivel($("trFornecedor"));
            invisivel($("trMotivoCancelamentoCheque"));
            invisivel($("trStatus"));
        }
        if (modelo == "8"){
            visivel($("trFornecedor"));
            invisivel($("trMotivoCancelamentoCheque"));
            invisivel($("trStatus"));
            invisivel($("trAjudanteADV"));
            invisivel($("trFuncionarioADV"));
        }
        
    }

    function validaConta(modelo){
        if (modelo == '3' || modelo == '4' || modelo == '5' || modelo == '6'){
            var marcouConta = false;
            for(var i = 0; i < arrayContas.length; i++){
                if($("conta_"+arrayContas[i]).checked){
                    marcouConta = true;
                }
            }
            if(!marcouConta){
                alert('Informe a conta corretamente!');
                return false;
            }
        }
        return true;
    }

    function popRel(){
        var modelo;
        if (!validaData(document.getElementById("dtinicial").value) || !validaData(document.getElementById("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else{
            
            if (getObj("modelo1").checked)
                modelo = '1';
            else if (getObj("modelo2").checked)
                modelo = '2';
            else if (getObj("modelo3").checked){
                modelo = '3';
                //if (!validaConta('3')) return null;
            }else if (getObj("modelo4").checked){
                modelo = '4';
                if (!validaConta('4')) return null;
            }else if (getObj("modelo5").checked){
                modelo = '5';
                if (!validaConta('5')) return null;
            }else if (getObj("modelo6").checked){
                modelo = '6';
                if (!validaConta('6')) return null;
            }else if (getObj("modelo7").checked)
                modelo = '7';
            else if (getObj("modelo8").checked)
                modelo = '8';

            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";

            if ($("tipodata").disabled){
                $("tipodata").disabled = false;
            }
            /*            if (modelo == "6" && ($("chequeDe").value=="" || $("chequeAte").value=="")){
                alert ("Informe o intervalo de cheques corretamente.");
                return false;
            }
             */
            var contasMarcadas = "";
            for(var i = 0 ; i < arrayContas.length; i++){
                if($("conta_"+arrayContas[i]).checked == true){
                    contasMarcadas += arrayContas[i] + ",";
                }
            }
            
            launchPDF('./relmovbanco?acao=exportar&modelo='+modelo+
                '&impressao='+impressao+
                '&mostrarTransferencias='+$("mostrarTransferencias").checked
                +'&ocultarDetalhes='+$("ocultarDetalhes").checked
                +'&mostrarTotalDiario='+$("chkTotalDiario").checked
                +'&idMotivo=' + $("motivosCancelamentoCheque").value 
                +'&conta=' + contasMarcadas
                +'&conta_transferencia=' + encodeURI($("conta").value)
                +'&idconta_transferencia=' + $("idconta").value
                +'&'+concatFieldValue("tipodata,dtinicial,dtfinal,conciliado,descricao_historico,idhist,"+
                "idmotorista,motor_nome,chequeDe,chequeAte,idfornecedor,fornecedor,status, idconsignatario,idveiculo,idajudante,nome,idFuncionario,nomeFuncionario"));
        }
    }
  
  function localizahist(){
    post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }
  
  
  var arrayContas = new Array();
  
  function retornarContas(){
      var i = 0;
      <%BeanConsultaConta c = new BeanConsultaConta();
        c.setConexao(Apoio.getUsuario(request).getConexao());
        c.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
        ResultSet rs = c.getResultado();
        while (rs.next()) {
        %>
//                contas += <%=rs.getString("idconta")%>+",";
            arrayContas[i] = <%= rs.getString("idconta") %>;
            i++;
      <%}%>
  }
  
  function marcarTodos(objeto){
        for(var i = 0; i < arrayContas.length; i++){
            if(objeto.checked == true){
                $("conta_"+arrayContas[i]).checked = true;
            }else{
                $("conta_"+arrayContas[i]).checked = false;
            }
        }
    }
    
    function HabilitarDesabilitarTodos(param){
        if(param){
            for(var i = 0;i < arrayContas.length; i++){
                $("conta_"+arrayContas[i]).disabled = true;
                $("conta_").disabled = true;
            }
        }else{
            for(var i = 0;i < arrayContas.length; i++){
                $("conta_"+arrayContas[i]).disabled = false;
                $("conta_").disabled = false;
            }
        }
    }
    
    function localizaConsignatario(){
        launchPopupLocate('./localiza?acao=consultar&idlista=5','Cliente');
    }
    
    function clickTransferencia(elemento){
        try {
            if (elemento.checked) {
                $("trTipoTransfConta").style.display="";
            } else {
                $("trTipoTransfConta").style.display="none";
            }
        } catch (e) {
            console.log(e);
        }
    }

    function aoClicarNoLocaliza(idjanela) {
        if (idjanela.indexOf('Fornecedor') > -1) {
            if ($('tipo_controle_conta_corrente').value == 's') {
                jQuery('.td_veiculo_prop').show();
            } else {
                jQuery('.td_veiculo_prop').hide();
            }
        } else if (idjanela === 'Funcionario') {
            $('idFuncionario').value = $('idfornecedor').value;
            $('nomeFuncionario').value = $('fornecedor').value;

            $('idfornecedor').value = '0';
            $('fornecedor').value = '';
        }
    }

    function abrirLocalizarVeiculoProp() {
        launchPopupLocate('./localiza?acao=consultar&paramaux4=' + $("idfornecedor").value + '&idlista=<%=BeanLocaliza.TODOS_VEICULOS%>', 'Veiculo_Prop');
    }
    

    function limparVeiculo() {
        $('idveiculo').value = 0;
        $('vei_placa').value = '';
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

        <title>Webtrans - Relatório de movimentação bancária</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();alterandoConta();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value='${rotinaRelatorio}'/>,'<c:out value="${param.modulo}"/>');retornarContas();clickTransferencia($('mostrarTransferencias'))">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
        </div>
        <input type="hidden" id="idmotorista" value="0">
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de movimenta&ccedil;&atilde;o banc&aacute;ria</b></td>
            </tr>
        </table>
        <br>
         <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"><center>Relatórios Principais</center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');">Relatórios Personalizados</td>
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
                        <label for="modelo1">Modelo 1</label></div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da
                    movimenta&ccedil;&atilde;o banc&aacute;ria</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo2" name="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        <label for="modelo2">Modelo 2</label></div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da
                    movimenta&ccedil;&atilde;o banc&aacute;ria (Sintético)</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo3" name="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        <label for="modelo3">Modelo 3</label></div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o dos cheques emitidos e cancelados</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo4" name="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        <label for="modelo4">Modelo 4</label></div></td>
                <td colspan="2" class="CelulaZebra2"> Impressão de cópias de cheques </td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo5" name="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        <label for="modelo5">Modelo 5</label></div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da
                    movimenta&ccedil;&atilde;o banc&aacute;ria</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo6" name="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                        <label for="modelo6">Modelo 6</label></div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de
                    Cheques por Talão</td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo7" name="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                        <label for="modelo7">Modelo 7</label></div></td>
                <td colspan="2" class="CelulaZebra2"> 
                    Rela&ccedil;&atilde;o de saldo por fornecedor
                </td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos"> <div align="left">
                        <input id="modelo8" name="modelo8" type="radio" value="8" onClick="javascript:modelos(8);">
                        <label for="modelo8">Modelo 8</label></div></td>
                <td colspan="2" class="CelulaZebra2">
                    Movimentação da conta corrente de fornecedor com Recibo
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
            </tr>
            <tr>
                <td height="24" class="TextoCampos">Por data de:</td>
                <td colspan="2" class="CelulaZebra2"> <select id="tipodata" name="tipodata" class="inputtexto">
                        <option value="dtemissao">Emissão</option>
                        <option value="dtentrada" selected>Entrada</option>
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
                <td height="18" colspan="3">
                    <div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td height="30" colspan="3">
                    <table width="100%" border="0" >
                        <tr id="trConta">
                            <td class="TextoCampos">
                                Apenas a conta:
                            </td>
                            <td class="CelulaZebra2" colspan="3">
                                <table width="100%">
                                    <tr>
                                        <td class="CelulaZebra2" colspan="3">                                                   
                                            <input type="checkbox" value="0" checked name="conta_" id="conta_" onclick="marcarTodos(this);">Marcar todos
                                            <input type="hidden" id="inpContasMarcadas" name="inpContasMarcadas" value="">
                                            <input type="hidden" id="inpContasMarcadasDescricao" name="inpContasMarcadasDescricao" value="">
                                        </td>
                                    </tr>
                                        <%BeanConsultaConta contas = new BeanConsultaConta();
                                        contas.setConexao(Apoio.getUsuario(request).getConexao());
                                        contas.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                        ResultSet rsconta = contas.getResultado();
                                        int cont = 0;
                                        while (rsconta.next()) {
                                        cont++;
                                        if(cont % 2 == 1){
                                        
                                        %>
                                        <tr>
                                        <%}%>
                                        
                                            <td class="CelulaZebra2" colspan="3">
                                                <input type="hidden" name="idConta" id="idConta_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("idconta")%>">
                                                <input type="checkbox" checked value="<%=rsconta.getString("idconta")%>"  name="conta_<%=rsconta.getString("idconta")%>" id="conta_<%=rsconta.getString("idconta")%>"><%=rsconta.getString("numero")%> - <%=rsconta.getString("banco")%>
                                            </td>

                                        <%if(cont % 2 == 0){%>
                                        </tr>
                                        <%}%>
                                    <%}%>

                                </table>
                            </td>
                            
                            
                        </tr>
                        <tr id="trStatus">
                            <td width="30%" class="TextoCampos">                                
                                    Mostrar:
                            </td > 
                            <td width="20%" class="CelulaZebra2">
                                <select id="status" name="status" class="inputtexto">
                                    <option value="AND true" selected>Ambos</option>
                                    <option value="AND valor > 0">Apenas Créditos</option>
                                    <option value="AND valor < 0">Apenas Déditos</option>
                                </select>
                            </td>
                            <td width="20%" class="TextoCampos">
                                <div id="divApenasConciliado">
                                    Apenas lan&ccedil;amentos:
                                </div>
                            </td>
                            <td width="30%" class="CelulaZebra2">
                                <select id="conciliado" name="conciliado" class="inputtexto">
                                    <option value="todos" selected>Todos</option>
                                    <option value="and vrel.conciliado">Conciliados</option>
                                    <option value="and not vrel.conciliado">N&atilde;o Conciliados</option>
                                </select></td>
                        </tr>
                        <tr id="trFornecedor"> 
                            <td height="" class="TextoCampos">Fornecedor:</td>
                            <td colspan="3" class="CelulaZebra2">
                                <input type="hidden" id="idfornecedor" name="idfornecedor" value="0"/>
                                <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" size="40" value="" readonly>
                                <input type="hidden" id="tipo_controle_conta_corrente" name="tipo_controle_conta_corrente" value="">
                                <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>&paramaux=1','Fornecedor')" value="...">
                                <img src="img/borracha.gif" id="limpa_forn" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:getObj('idfornecedor').value = 0;javascript:getObj('fornecedor').value = '';">

                                <span class="td_veiculo_prop" style="display: none; padding-left: 1vw;">
                                    <label>Veículo:</label>
                                    <input type="hidden" id="idveiculo" name="idveiculo" value="0">
                                    <input name="vei_placa" type="text" class="inputReadOnly" id="vei_placa" size="10"
                                           value="" readonly>
                                    <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo"
                                           onClick="abrirLocalizarVeiculoProp();" value="...">
                                    <strong>
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink"
                                         title="Limpar Veículo" onClick="limparVeiculo();">
                                    </strong>
                                </span>
                            </td>

                        </tr>
                        <tr id="trmotorista">
                            <td class="TextoCampos">Motorista ADV:</td>
                            <td colspan="3" class="CelulaZebra2">

                                <input name="motor_nome" type="text" class="inputReadOnly" id="motor_nome" size="40" readonly="true">
                                <input name="localiza_motor" type="button" class="botoes" id="localiza_motor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                                <img src="img/borracha.gif" id="limpa_motor" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
                            </td>
                        </tr>
                        <tr id="trAjudanteADV">
                            <td class="TextoCampos">Ajudante ADV:</td>
                            <td colspan="3" class="CelulaZebra2">
                                <input type="hidden" id="idajudante" name="idajudante">
                                <input name="nome" id="nome" type="text" class="inputReadOnly" size="40" readonly>
                                <input type="button" class="botoes" name="localiza_ajudante" id="localiza_ajudante" value="..."
                                       onclick="launchPopupLocate('${homePath}/localiza?acao=consultar&idlista=25', 'Ajudante');">
                                <img src="${homePath}/img/borracha.gif" alt="" class="imagemLink" id="borrachaAj" onclick="$('nome').value=''; $('idajudante').value='0';">
                            </td>
                        </tr>
                        <tr id="trFuncionarioADV">
                            <td class="TextoCampos">Funcionário ADV:</td>
                            <td colspan="3" class="CelulaZebra2">
                                <input type="hidden" id="idFuncionario" name="idFuncionario">
                                <input name="nomeFuncionario" id="nomeFuncionario" type="text" class="inputReadOnly" size="40" readonly>
                                <input type="button" class="botoes" name="localizarFuncionario" id="localizarFuncionario" value="..."
                                       onclick="launchPopupLocate('${homePath}/localiza?acao=consultar&idlista=21&paramaux2=1', 'Funcionario');">
                                <img src="${homePath}/img/borracha.gif" alt="" class="imagemLink" id="limparFuncionario" onclick="$('idFuncionario').value = '0'; $('nomeFuncionario').value = '';">
                            </td>
                        </tr>
                        <tr id="trCliente" style="display: none">
                        <td width="" height="25" class="TextoCampos">Cliente:</td>
                                      <td colspan="5" class="CelulaZebra2">
                                          <div align="left">
                                              <input name="con_cnpj" type="text" id="con_cnpj" size="20" class="inputReadOnly8pt" value="" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj', this.value)">
                                              <input name="con_rzs" type="text" id="con_rzs" value="" size="40" maxlength="50" readonly="true" class="inputReadOnly8pt">
                                              <input name="idconsignatario" type="hidden" id="idconsignatario" value="0" >
                                              <strong>                               
                                                  <input name="button3" type="button" class="botoes" onClick="localizaConsignatario();" value="...">                                
                                              </strong>
                                              <img src="img/borracha.gif" id="limpa_cli" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:getObj('idconsignatario').value = 0;javascript:getObj('con_cnpj').value = '';javascript:getObj('con_rzs').value = '';">
                                          </div>
                                      </td>
                        </tr>
                        <tr id="trHistorico" >
                            <td class="TextoCampos">Apenas o Histórico:</td>
                            <td colspan="3" class="CelulaZebra2">
                                <input name="idhist" type="hidden" id="idhist" value="<%=request.getParameter("idhist") == null ? "0" : request.getParameter("idhist")%>" onBlur="javascript:seNaoIntReset(this,'0');" size="2" maxlength="3">
                                <input name="codigo_historico" class="inputReadOnly" type="text" id="codigo_historico" value="<%=request.getParameter("codigo_historico") == null ? "" : request.getParameter("codigo_historico")%>" onBlur="javascript:seNaoIntReset(this,'0');" size="2" maxlength="3" readOnly >
                                <input name="descricao_historico" type="text" id="descricao_historico" class="inputTexto" size="33" class="inputtexto" maxlength="100" value="<%=request.getParameter("descricao_historico") == null ? "" : request.getParameter("descricao_historico")%>">
                                <input name="model_hist" type="button" class="botoes" id="model_hist2" value="..." onClick="javascript:localizahist()">
                                <img src="img/borracha.gif" id="limpa_historico" border="0" align="absbottom" class="imagemLink" title="Limpar Histórico" onClick="javascript:$('idhist').value = '0';$('codigo_historico').value = '';$('descricao_historico').value = '';">
                            </td>
                        </tr>
                        <tr id="trTipoTransf" >
                            <td height="26" class="TextoCampos" colspan="4" >
                                <div align="center">
                                    <input name="mostrarTransferencias" type="checkbox" id="mostrarTransferencias" onclick="clickTransferencia(this);" >
                                    <label for="mostrarTransferencias">Apenas transferências</label>
                                </div>
                            </td>
                        </tr>
                        <tr id="trTipoTransfConta" >
                            <td class="TextoCampos">Apenas transferencia onde a conta de origem/destino seja:</td>
                            <td colspan="3" class="CelulaZebra2">
                                <input name="idconta" type="hidden"  id="idconta" size="40"  value="0">
                                <input name="conta" type="text" class="inputReadOnly" id="conta" size="40" readonly="true">
                                <input name="localiza_conta" type="button" class="botoes" id="localiza_conta" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=31&paramaux=and true','Conta')" value="...">
                                <img src="img/borracha.gif" id="limpa_conta" border="0" align="absbottom" class="imagemLink" title="Limpar Conta" onClick="javascript:getObj('idconta').value = 0;javascript:getObj('conta').value = '';">
                            </td>
                        </tr>
                        <tr id="trOcultarDetalhes" >
                            <td class="TextoCampos" colspan="4" >
                                <div align="center">
                                    <input name="ocultarDetalhes" type="checkbox" id="ocultarDetalhes" >
                                    Mostrar apenas o total de cada doc/cheque (Em caso de vários pagamentos/recebimentos com o mesmo doc/cheque).
                                </div>
                            </td>
                        </tr>
                        <tr id="trTotalDiario" >
                            <td class="TextoCampos" colspan="4" >
                                <div align="center">
                                    <input name="chkTotalDiario" type="checkbox" id="chkTotalDiario" >
                                    Mostrar Total diário.
                                </div>
                            </td>
                        </tr>
                        <tr id="trConsultaCheque" style="display:none">
                            <td class="TextoCampos" >
                                Intervalo cheque:
                            </td>
                            <td class="CelulaZebra2" colspan="3" >
                                <input name="chequeDe" class="inputtexto" type="text" id="chequeDe" value="" size="8" maxlength="9"/>
                                até
                                <input name="chequeAte" type="text" class="inputtexto" id="chequeAte" value="" size="8" maxlength="9"/>
                            </td>
                        </tr>
                        <tr id="trMotivoCancelamentoCheque" style="display:none">
                            <td class="TextoCampos" >
                                Motivo:
                            </td>
                            <td class="CelulaZebra2" colspan="3" >
                                <select id="motivosCancelamentoCheque" name="motivosCancelamentoCheque" class="inputtexto">
                                    <option value="0" selected>Todos</option>
                                    <%BeanCadMovBanco movBanco = new BeanCadMovBanco();
                                                movBanco.setConexao(Apoio.getUsuario(request).getConexao());
                                                ResultSet rsMotivos = movBanco.mostraMotivosCancelamentoCheque();
                                                    while (rsMotivos.next()) {%>
                                    <option value="<%=rsMotivos.getInt("id")%>" <%=(request.getParameter("idMotivo") != null && request.getParameter("idMotivo").equals(rsMotivos.getInt("id")) ? "selected" : "")%>>
                                        <%=rsMotivos.getString("descricao")%>
                                    </option>
                                    <%}%>
                                </select>
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
