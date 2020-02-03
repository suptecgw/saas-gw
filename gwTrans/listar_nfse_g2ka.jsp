<%-- 
    Document   : listar_nfse_g2ka
    Created on : 07/04/2014, 08:40:08
    Author     : paulo
--%>

<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="pt-BR" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="${homePath}/css/estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="JavaScript" src="script/jQuery/jquery.js" type="text/javascript"></script>
<script src="assets/alerts/alerts-min.js" type="text/javascript"></script>
<jsp:include page="/importAlerts.jsp">
    <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
    <jsp:param name="nomeUsuario" value="${user.nome}"/>
</jsp:include>
<script type="text/javascript" language="JavaScript">

    jQuery.noConflict();

    let homePath = '${homePath}';
    let certificadoAtualizado = '${configTecnica.certificadoAtualizadoEm != null}';

    function enviarG2ka(){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        var cont = 0;
        for (cont = 1; getObj("venda_" + cont) != null; cont++){
            if(getObj("venda_"+cont).checked){                
                var venda = getObj("venda_"+cont).value;                
            }
        }        
        if(venda != undefined){
            window.open("NFSeG2kaControlador?acao=enviarG2ka&venda_="+venda, "pop", "width=210, height=100");
        }else{
            alert("Selecione uma nota!");
            return false;
        }
        
    }
    
    function retornoG2ka(){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        var numeroRps = $("numeroRps").value;
        var serieRps = $("serieRps").value;
        var numeroNFSe = $("numeroNFSe").value;
        var descricaoStatus = $("descricaoStatus").value;        
        var codigoStatus = $("codigoStatus").value;
        window.open("NFSeG2kaRetornoControlador?acao=retornoG2ka&numeroRps="+numeroRps+"&serieRps="+serieRps+
                "&numeroNFSe="+numeroNFSe+"&descricaoStatus="+descricaoStatus+"&codigoStatus="+codigoStatus,
        "pop", "width=210, height=100");
    }
    
    var countRow = 0;

    function pesquisa(){
        document.formulario.filial.disabled = false;
        document.formulario.submit();
        document.formulario.filial.disabled = true;
    }
    
    function limparCliente(){
        document.formulario.con_rzs.value = "";
        document.formulario.idconsignatario.value = "0";
    }
    
    function abrirLocalizarCliente(){
        abrirLocaliza("ClienteControlador?acao=localizar", "locClienteNFSe");
    }

//    function abrirVenda(idVenda){
//                tryRequestToServer(function(){
//                    abrirMax("VendaControlador?acao=iniciarEditarLogis&id=" + idVenda, "cadVendaServico");
//                });
//    }
    
    
    function editar(id){
        url = "./cadvenda.jsp?acao=editar&id=" + id;
        
        tryRequestToServer(function() {
            var popu = window.open(url, '', 'titlebar=no,menubar=no,scrollbars=yes,status=yes,resizable=yes,top=0,left=0');
            popu.window.resizeTo(screen.width, screen.height - 50);
        });
    }
    
    function habilitaConsultaDePeriodo(opcao){
        document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
        document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
        document.getElementById("div1").style.display = (opcao ? "" : "none");
        document.getElementById("div2").style.display = (opcao ? "" : "none");
    }

    function desativarBotoes(){
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';

        if(atual == '1'){
            document.formularioAnt.botaoAnt.disabled = true;
        }
        if(parseFloat(atual) >= parseFloat(paginas)){
            document.formularioProx.botaoProx.disabled = true;
        }
    }

    function setDefault(){
        try {
            document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';
            document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
            var campoConsulta = '<c:out value="${param.campoConsulta}"/>';
            document.formulario.campoConsulta.value = campoConsulta;
            document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
            document.formulario.dataDe.value = '<c:out value="${param.dataDe}"/>';
            document.formulario.dataAte.value = '<c:out value="${param.dataAte}"/>';
            document.formulario.idconsignatario.value = '<c:out value="${param.idCliente}"/>';
            document.formulario.con_rzs.value = '<c:out value="${param.cliente}"/>';
            document.formulario.filial.value = '<c:out value="${autenticado.filial.idfilial}"/>';
            document.formulario.utilizaAverbacao.value = '<c:out value="${param.utilizaAverbacao}"/>';
           
            if(campoConsulta == 'emissao_rps'){
                habilitaConsultaDePeriodo(true);
                document.formulario.dataDe.focus();
            }else{
                document.formulario.valorConsulta.focus();
            }
            
            var nivel = parseInt('<c:out value="${param.nivelFilial}"/>' ) ;
            if (nivel >= 1){
                document.formulario.filial.disabled = false;
                document.formulario.filial.value = '<c:out value="${param.idFilial}"/>';
            }
           
        } catch (e) { 
            alert(e)
        }
    }
    function excluirNFSeG2ka(id, numero, index){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        var retirarVinculoCTeNFSe = false;
        try {
            
            <c:if test="${param.codigoIbge == '2927408'}">
                alert("Atenção: Opção de cancelamento desabilitado para esta prefeitura. Para cancelar, acesse o portal da prefeitura.");
                return false;
            </c:if>
            
            
            if(confirm("Deseja Cancelar a NFS-e G2ka '" + numero + "'?" )){
                if(confirm("Tem Certeza?" )){
                    if ($("temFatura_"+index).value == "true"){
                        alert("A NFS-e tem a Fatura: "+ $("numeroFatura_"+index).value +" vinculada não pode ser cancelada!");
                        return false;
                    }
                    var textoCancelamento = prompt("Qual o Motivo do Cancelamento?" ,"");
                    if(textoCancelamento != null){
                        if ($("idCTe_"+index).value != 0) {
                            if(confirm("Deseja retirar o vínculo desse CT-e com a NFS-e?")){
                                retirarVinculoCTeNFSe = true;
                            }                        
                        }
                        window.open("./NFSeG2kaCancelamentoControlador?acao=envioCancelamentoNFSeG2ka&nfseg2ka=" + id + "&numeroNFSe="+numero+"&motivo="+textoCancelamento+"&retirarVinculoCTeNFSe="+retirarVinculoCTeNFSe , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');    
                    }
                }
            } 
        }catch (e) { 
            alert(e);
        }
    }
    
    //Function não é utilizada para G2ka, tem que adicionar o link na Classe CidadeURL que está na lib gw_g2ka.
    //Adicionar também na NFSeG2kaImpressaoControlador.
    //A function que é chamada é imprimirNFSeG2ka aqui no jsp.
    function imprimir(impressao, numero, codVerificacao, id, nota, ibge){
        
        var mun = '<c:out value="${param.inscricaoMunicipal}"/>';
        
        codVerificacao = codVerificacao.replace("-", "");
        
        
        if(ibge == "2611606"){
            //RECIFE
            window.open("https://nfse.recife.pe.gov.br/nfse.aspx?ccm=" + mun + "&nf=" + nota + "&cod=" + codVerificacao,
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        }else if(ibge == "3550308"){
            //SAO PAULO
            window.open("https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?inscricao=" + mun + "&nf=" + numero + "&verificacao=" +codVerificacao,
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        }else if(ibge == "3304557"){
            //RIO DE JANEIRO
//            window.open("https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?inscricao=" + mun + "&nf=" + nota + "&verificacao=" +codVerificacao,
            window.open("https://notacarioca.rio.gov.br/contribuinte/nfse.aspx?ccm=" + mun + "&nf=" + nota + "&cod=" +codVerificacao,
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        }else if(ibge == "3509502"){
           //CAMPINAS
           launchPDF('NFSeG2kaControlador?acao=relatorio&id=' + id);        
        }else if(ibge == "2927408"){            
           //SALVADOR
//        nfse.salvador.ba.gov.br/site/contribuinte/nota/notaprint.aspx?inscricao=39130000183&nf=68&verificacao=XTLQFTQS
//           window.open("https://nfse.salvador.ba.gov.br/site/contribuinte/nota/notaprint.aspx?inscricao=" + mun + "&nf=" + nota + "&verificacao=" + codVerificacao,
           window.open("https://nfse.salvador.ba.gov.br/site/contribuinte/nota/notaprint.aspx?inscricao=39130000183"+"&nf=68"+"&verificacao=XTLQFTQS",
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        
         }else if(ibge == "2930709"){            
           //SIMOES FILHO

           window.open("http://201.49.29.18/el-nfse0/paginas/sistema/login.jsf",
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        
         }else if(ibge == "3518800"){            
           //GUARULHOS

           window.open("http://guarulhos.ginfes.com.br",
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        
         }else if(ibge == "2307650"){
           //MARACANAU

           window.open("http://maracanau.ginfes.com.br",
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        }else{
            alert("Não encontrado!");
        }
    }
    
    function popImpressaoGeral(){
        var cont = $("max").value;
        var ids = "";
        var tamanho = 0;
        for (cont = 1; getObj("venda_" + cont) != null; cont++){
            if (getObj("venda_" + cont).checked){
                if(ids == ""){
                    ids += getObj("venda_" + cont).value;
                    tamanho++;
                }else{
                    ids += ',' + getObj("venda_" + cont).value;
                    tamanho++;
                }
            }
        }
        
        if(ids == ""){
            alert("Selecione pelo menos uma nota!");
        }else{
            launchPDF('NFSeG2kaControlador?acao=impressaoGeral&ids=' + ids + '&tamanho=' + tamanho);
        }
    }

    function enviarNFSeG2ka(){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        window.open("about:blank" ,"pop", "width=210, height=100");
        $("formNFSeG2ka").submit();
        $("botEnviar").disabled = true;
    }
    
//    function reciboThread(numeroRecibo, idVenda){
//        window.open("NFSeG2kaControlador?acao=reciboThread&numeroRecibo=" + numeroRecibo + "&idVenda=" + idVenda ,"pop", "width=210, height=100");
//    }
    
    function setIcone(valor){
        var img = "";
        switch (valor){
            case "1":
                img = "pdf_";
                break;
            case "2":
                img = "excel_";
                break;
            case "3":
                img = "ie_";
                break;
            case "4":
                img = "word_";
                break;
        }
        
        for(var i = 1; i <= $("max").value; i++){
            if(document.getElementById("pdf_"+i) != null){
                document.getElementById("pdf_"+i).style.display = "none";
                document.getElementById("excel_"+i).style.display = "none";
                document.getElementById("ie_"+i).style.display = "none";
                document.getElementById("word_"+i).style.display = "none";
                document.getElementById(img+i).style.display = "";
            }
        }
    }
    
    
    function popNota(){
        var id = $("idNota");

        if (id == null)
            return null;

        launchPDF('NFSeG2kaControlador?acao=relatorio&idNota=' +id);

    }
    
    function imprimirNFSeG2ka(inscricao, verificacao, nf){
           abrirMax("NFSeG2kaImpressaoControlador?acao=impressaoNFSeG2ka&inscricao="+inscricao+"&verificacao="+verificacao+"&nf="+nf,"");
    }
    
    function enviarEmailNFSeG2ka(nf){         
           window.open("NFSeG2kaControlador?acao=enviarEmail&nf="+nf,'pop', 'top=10,left=0,height=300,width=300');
    }
    
    function averbarNFseG2Ka(){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        var limiteResultados = document.formulario.limiteResultados.value;
        console.log("limiteResultados: "+limiteResultados);
        var idvenda;
        var utilizaAverbacao = $("utilizaAverbacao").value;
        console.log("utilizaAverbacao: "+utilizaAverbacao);
        for(var i=1; i<=limiteResultados; i++){
            console.log("i: "+i);
            if($("venda_"+i)!= null && $("venda_"+i)!=undefined){
                if($("venda_"+i).checked){
                    console.log("st: "+$("stUti_"+i).value);
                        console.log("seguro_ "+$("seguro_"+i).value);
                    if(($("stUti_"+i).value!='N' && $("seguro_"+i).value=='c') || (utilizaAverbacao !='N') ){
                            idvenda = $("venda_"+i).value;
                    }else{
                        alert("Filial e Cliente não possuem Caixa Postal para averbação de NFS-e.");
                        return false;
                    }
                }
            }
        }
        window.open("about:blank" ,"pop", "width=210, height=100");
        var formu = $("formNFSeG2ka");
        formu.action = './NFSeG2kaControlador?acao=averbarNfseG2ka&venda='+idvenda;
        formu.submit();
    }
    
    
    function cancelarAverbacaoNFseG2KA(){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

            var limiteResultados = document.formulario.limiteResultados.value;
            var idvenda;
            var utilizaAverbacao = $("utilizaAverbacao").value;
            console.log("utilizaAverbacao: "+utilizaAverbacao);
            for(var i=1; i<=limiteResultados; i++){
                console.log("i: "+i);
                if($("venda_"+i)!= null && $("venda_"+i)!=undefined){
                    if($("venda_"+i).checked){
                        console.log("st: "+$("stUti_"+i).value);
                        console.log("seguro_ "+$("seguro_"+i).value);
                        if(($("stUti_"+i).value!='N' && $("seguro_"+i).value=='c') || (utilizaAverbacao !='N') ){
                            idvenda = $("venda_"+i).value;
                        }else{
                            alert("Filial e Cliente não possuem Caixa Postal para averbação de NFS-e.");
                            return false;
                        }
                    }
                }
            }
            window.open("about:blank" ,"pop", "width=210, height=100");
            var formu = $("formNFSeG2ka");
            formu.action = './NFSeG2kaControlador?acao=cancelarAverbacaoNfseG2ka&venda='+idvenda;
            formu.submit();
        }

    function efetuarLogOff() {
        location.replace("UsuarioControlador?acao=logoff");
    }

    function usuarioAceitouAtualizarCertificado() {
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        jQuery.post(`${homePath}/CertificadoDigitalMigracaoControlador`, {'acao': 'migrar'}, function retornoAjaxAtualizarCertificados(data) {
            $('.bloqueio-tela').hide();
            $('.gif-bloq-tela').hide();

            chamarAlert(data['mensagem'], function () {
                if (data['mensagem'].indexOf('Erro') === -1) {
                    efetuarLogOff();
                }
            });
        }, 'json');
    }

    function usuarioNaoAceitouAtualizarCertificado() {
        chamarAlert('O envio dos documentos fiscais não irão funcionar até que essa atualização seja feita.');
    }

</script>
<style  type="text/css">
    <!--
    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }

    .style5 {
        color:red;
    }
    -->

    .modal-content {
        text-align: left;
    }
</style>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>gwLogis - NFS-e G2ka</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="desativarBotoes(), setDefault(), applyFormatter()"  >
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="100%" align="left"> 
                    <span class="style4">NFS-e G2ka</span>
                </td>
            </tr>
        </table>
        <br>
        <form action="NFSeG2kaControlador?acao=listar" id="formulario" name="formulario"  method="post">
            <table class="bordaFina" width="90%" align="center">
                <tr>
                    <td width="15%" class="CelulaZebra1">
                        <input name="naoImpressas" id="naoImpressas" value="false" type="hidden">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onchange="habilitaConsultaDePeriodo(this.value == 'emissao_rps')">
                            <option value="emissao_rps">Emiss&atilde;o</option>
                            <option value="numero_nfse">N&uacute;mero NFS-e</option>
                            <option value="numero_rps">N&uacute;mero RPS</option>
                        </select>
                    </td>
                    <td width="25%" class="CelulaZebra1" height="20">
                        <div id="div1" style="display:none">
                            De:
                            <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                        </div>
                        <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com In&iacute;cio</option>
                            <option value="3">Apenas com o Fim</option>
                            <option value="4">Igual &agrave; Palavra/Frase</option>
                        </select>
                    </td>
                    <td width="25%" class="CelulaZebra1">
                        <div id="div2" style="display:none">
                            At&eacute;:
                            <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate">
                        </div>
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25">
                    </td>
                    <td width="20%" class="CelulaZebra1">
                        <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function(){pesquisa();});"/>
                    </td>
                    <td width="15%" class="CelulaZebra1">
                        <select   name="limiteResultados" class="inputtexto" >
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                            <option value="100">100 resultados</option>
                            <option value="200">200 resultados</option>
                            <option value="1000">1000 resultados</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1" colspan="2">
                        Apenas o Cliente:
                        <input name="con_rzs" id="con_rzs" class="inputReadOnly" value="" size="30" type="text" readonly>
                        <input name="idconsignatario" id="idconsignatario" value="0" type="hidden">
                        <input value="..." class="inputBotaoMin" type="button" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>','Consignatario')">
                        <img alt="borracha" src="img/borracha.gif" id="borracha" onclick="limparCliente()" class="imagemLink"/>
                    </td>
                    <td  class="CelulaZebra1">
                        Status NFS-e:
                        <select name="stat" class="inputtexto" onchange="pesquisa()">
                            <option value="P" ${param.status == "P" ? "selected" : ""}> Pendente </option>
                            <option value="E" ${param.status == "E" ? "selected" : ""}> Enviado </option>
                            <option value="C" ${param.status == "C" ? "selected" : ""}> Confirmado </option>
                            <option value="N" ${param.status == "N" ? "selected" : ""}> Negado </option>
                            <option value="L" ${param.status == "L" ? "selected" : ""}> Cancelado </option>
                        </select>
                    </td>
                    <td  class="CelulaZebra1" colspan="2">
                        <select name="idFilial" id="filial" class="inputtexto" disabled>
                            <option value="0">Todas as Filiais</option>
                            <c:forEach var="filial" items="${filiais}">
                                <option value="${filial.idfilial}">Apenas a ${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                        <input type="hidden" id="utilizaAverbacao" name="utilizaAverbacao">
                    </td>
                </tr>
                <tr>
                    <!--<td class="CelulaZebra1" colspan="5">-->
                        <!--<input name="impressaoNFSeG2ka" type="button" class="botoes" id="impressaoNFSeG2ka" onClick="javascript:tryRequestToServer(function(){imprimirNFSeG2ka()});" value="Imprimir Notas Selecionadas">-->
                    <!--</td>-->
<!--                    <td class="celulaZebra1">
                        <%--<c:if test="${param.status=='P' || param.status=='N'}">--%>
                            <input name="g2ka" id="g2ka" type="button" class="inputbotao" value="  Enviar G2ka  " onclick="tryRequestToServer(function(){enviarG2ka();});"/>                            
                        <%--</c:if>--%>
                    </td>
                    <td colspan="3" class="celulaZebra1">
                        <input name="retorno_g2ka" id="retorno_g2ka" type="button" class="inputbotao" value="  Retorno G2ka  " onclick="tryRequestToServer(function(){retornoG2ka();});"/>
                    </td>-->
                </tr>
            </table>
        </form>
        <form action="NFSeG2kaControlador?acao=enviar"  method="post" name="formNFSeG2ka" id="formNFSeG2ka" target="pop">
            <table width="90%"  class="bordaFina" align="center" style="vertical-align:top">
                <tr>
                    <td class="tabela" width="3%" align="left"></td>
                    <td class="tabela" align="left"></td>
                    <td class="tabela" align="left"></td>
                    <td class="tabela" align="center">RPS</td>
                    <td class="tabela" align="center">Emiss&atilde;o</td>
                    <td class="tabela" align="center">Nº Recibo</td>
                    <td class="tabela" align="center">Data/Hora Envio</td>
                    <td class="tabela" align="center">Cliente</td>
                    <td class="tabela" align="center">NFS-e</td>
                    <td class="tabela" align="center">Cod. Verifica&ccedil;&atilde;o</td>
                    <td class="tabela" align="center">Motivo</td>
                    <td class="tabela" align="left"></td>
                </tr>
                <c:forEach var="nfseg2ka" varStatus="status" items="${listaListNFSeG2ka}">
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                        <input type="hidden" name="idCTe_${status.count}" id="idCTe_${status.count}" value="${nfseg2ka.venda.ctrcId}" />
                        <input type="hidden" name="temFatura_${status.count}" id="temFatura_${status.count}" value="${nfseg2ka.venda.temFatura}" />
                        <input type="hidden" name="numeroFatura_${status.count}" id="numeroFatura_${status.count}" value="${nfseg2ka.venda.fatura.numero}" />
                        <td style="display:none ">
                            <script type="text/javscript">countRow++;</script>
                        </td>
                        <td>
                            <c:if test="${nfseg2ka.venda.filial.enviarVariasNfse}">
                                <input type="hidden" name="variasNfseG2ka" id="variasNfseG2ka" value="${nfseg2ka.venda.filial.enviarVariasNfse}" />
                                <input type="checkbox" name="venda_${status.count}" id="venda_${status.count}" value="${nfseg2ka.venda.id}">
                            </c:if>
                            <c:if test="${!nfseg2ka.venda.filial.enviarVariasNfse}">
                                <input type="radio" name="venda" id="venda_${status.count}" value="${nfseg2ka.venda.id}">
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${param.status == 'C' || param.status == 'L'}">
                                <a>
                                    <img alt="" class="imagemLink" id="pdf_${status.count}" onclick="imprimirNFSeG2ka('${nfseg2ka.venda.cliente.inscMunicipal}','${nfseg2ka.codVerificacao}','${nfseg2ka.numero}');" src="img/pdf.gif" />
                                    <!--<img alt="" class="imagemLink" id="excel_$ {status.count}" onclick="imprimir(2, '$ {nfseg2ka.venda.numero}','$ {nfseg2ka.codVerificacao}','$ {nfseg2ka.venda.id}','$ {nfseg2ka.numero}','$ {nfseg2ka.venda.filial.cidade.cod_ibge}');" src="img/excel.gif" style="display: none"/>-->
                                    <!--<img alt="" class="imagemLink" id="ie_$ {status.count}" onclick="imprimir(3, '$ {nfseg2ka.venda.numero}','$ {nfseg2ka.codVerificacao}','$ {nfseg2ka.venda.id}','$ {nfseg2ka.numero}','$ {nfseg2ka.venda.filial.cidade.cod_ibge}');" src="img/ie.gif" style="display: none"/>-->
                                    <!--<img alt="" class="imagemLink" id="word_$ {status.count}" onclick="imprimir(4, '$ {nfseg2ka.venda.numero}','$ {nfseg2ka.codVerificacao}','$ {nfseg2ka.venda.id}','$ {nfseg2ka.numero}','$ {nfseg2ka.venda.filial.cidade.cod_ibge}');" src="img/word.gif" style="display: none"/>-->
                                </a>
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${(param.status == 'C' || param.status == 'L')}">                                
                                <a>
                                    <img alt="" class="imagemLink" onclick="enviarEmailNFSeG2ka('${nfseg2ka.venda.id}');" src="img/outc.png" title="Enviar E-mail" />
                                </a>
                            </c:if>
                          
                        </td>
                        
                        <td align="center">
                            <a href="javascript:editar(${nfseg2ka.venda.id})" class="linkEditar">
                                ${nfseg2ka.venda.numero}
                            </a>
                            <input type="hidden" id="numeroRps" name="numeroRps" value="${nfseg2ka.venda.numero}"/>
                            <input type="hidden" id="serieRps" name="serieRps" value="${nfseg2ka.venda.serie}"/>
                            <input type="hidden" id="temfatura" name="temfatura" value="${nfseg2ka.venda.temFatura}"/>
                            <input type="hidden" id="numeroNFSe" name="numeroNFSe" value="${nfseg2ka.numero}"/>
                            <input type="hidden" id="descricaoStatus" name="descricaoStatus" value="${nfseg2ka.descricaoStatus}"/>
                            <input type="hidden" id="codigoStatus" name="codigoStatus" value="${nfseg2ka.statusNFSeG2ka}"/>
                        </td>
                        <td align="center">${nfseg2ka.venda.emissaoEmS}</td>
                        <td align="center">
                            <c:if test="${param.status == 'E'}">
                                <a href="javascript:reciboThread(${nfseg2ka.numeroRecibo}, ${nfseg2ka.idRecibo})">
                            </c:if>

                            ${nfseg2ka.numeroRecibo}

                            <c:if test="${param.status == 'E'}">
                                </a>
                            </c:if>
                        </td>
                        <td align="center">${nfseg2ka.dataHoraEnvio}</td>
                        <td>
                            ${nfseg2ka.venda.cliente.razaosocial}
                            <input type="hidden" id="stUti_${status.count}" name="stUti_${status.count}" value="${nfseg2ka.venda.cliente.stUtilizacaoAverbacaoNFSe}">
                            <input type="hidden" id="seguro_${status.count}" name="seguro_${status.count}" value="${nfseg2ka.venda.cliente.seguroCarga}">
                        </td>
                        <!--<td ><fmt:formatNumber value="${nfseg2ka.venda.totalReceita}" pattern="#,##0.00#"/></td>-->
                        <td align="center">${nfseg2ka.numero}</td>
                        <td align="center">
                            <c:if test="${param.status == 'N'}">
                                <!--<a onclick="alert('${nfseg2ka.motivoRetornoNFSeG2ka}')" title="${nfseg2ka.descricaoStatus}"/>${nfseg2ka.statusNFSeG2ka}</a>-->
                                <a title="${nfseg2ka.descricaoStatus}"/>${nfseg2ka.statusNFSeG2ka}</a>
                            </c:if>
                            <c:if test="${param.status != 'N'}">
                                ${nfseg2ka.codVerificacao}
                            </c:if>
                        </td>
                        <td align="center">
                            <c:if test="${param.status == 'N'}">
                                <a onclick="alert('${nfseg2ka.motivoRetornoNFSeG2ka}')" title="${nfseg2ka.descricaoStatus}"/>
                                    <img width="25px" height="25px" title="Verificar o motivo da Rejeição" src="img/consulta_48.png" class="imagemLink"/>
                                </a>                                
                            </c:if>
                        </td>
                        <td align="center">
                            <c:if test="${param.status == 'C' && param.nivel >= 4}">
                                <a href="javascript: tryRequestToServer(function(){excluirNFSeG2ka('${nfseg2ka.venda.id}','${nfseg2ka.numero}','${status.count}');});">
                                    <img title="Cancelamento da Nota" alt="" class="imagemLink" src="img/cancelar.png"/>
                                </a>
                            </c:if>
                        </td>
                    </tr>
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                        <td align="center">
                        </td>
                        <td  colspan="6">
                            <c:if test="${param.status == 'L'}">
                                Usuário Cancelamento : ${nfseg2ka.usuarioCancelamento}
                            </c:if>
                            <c:if test="${param.status == 'C'}">
                                Usuário Confirmação : ${nfseg2ka.usuarioConfirmacao}
                            </c:if>
                        </td>
                       
                        <td colspan="1"><div align="right"><c:if test="${param.status=='C' && param.utilizaAverbacao!='N'}"><b>Averbação:</b></div></c:if>
                        </td>
                        <td colspan="4"><div align="left"><c:if test="${param.status=='C' && param.utilizaAverbacao!='N'}"><b>${nfseg2ka.venda.mensagemAverbacao}</b></c:if></div>
                        </td>
                        
                       
                    </tr>
                    <c:if test="${status.last}">
                        <tr style="display:none">
                            <td>
                                <input type="hidden" name="max" id="max" value="${status.count}">
                            </td>
                        </tr>
                    </c:if>
                </c:forEach>
            </table>
        </form>
        <table class="bordaFina" width="90%" align="center" >
            <tr class="CelulaZebra1">
                <td class="CelulaZebra1" width="54%">
                    <div align="center" >
                        Formato da Impress&atilde;o:
                        <input type="radio" name="impressao" id="impressao_1" onClick="setIcone(this.value)" value="1" checked/>
                        <img alt="" src="img/pdf.gif" style="vertical-align: middle" >
                        <input type="radio" name="impressao" id="impressao_2" onClick="setIcone(this.value)" value="2" />
                        <img alt="" src="img/excel.gif"  style="vertical-align: middle">
                        <input type="radio" name="impressao" id="impressao_3" onClick="setIcone(this.value)" value="3" />
                        <img alt="" src="img/ie.gif"  style="vertical-align: middle">
                        <input type="radio" name="impressao" id="impressao_4" onClick="setIcone(this.value)" value="4" />
                        <img alt="" src="img/word.gif"  style="vertical-align: middle">
                    </div>
                </td>
                <td align="center"><div align="right">Modelo do Relat&oacute;rio:</div></td>
                <td colspan="2" align="center">
                    <div align="left">
                        <select class="inputtexto"   name="modeloRelatorio" id="modeloRelatorio">
                            <option value="1">RPS</option>
                        </select>
                    </div>
                </td>
                <td align="center">
                    <%--<c:if test="${param.status == 'N' || param.status == 'P'}">--%>
                        <!--<input type="button" id="botEnviar" value=" Enviar " class="inputBotao" onclick="enviarNFSeG2ka()">-->
                    <%--</c:if>--%>
                    <c:if test="${param.status=='P' || param.status=='N'}">
                        <input name="g2ka" id="g2ka" type="button" class="inputbotao" value="  Enviar G2ka  " onclick="tryRequestToServer(function(){enviarG2ka();});"/>                            
                    </c:if>
                </td>
            </tr>
            <tr class="CelulaZebra1">
                
                <td width="54%" align="center">
                    <c:if test="${param.status=='C'}">
                        <input class="inputbotao" type="button" name="botaoAverbacao" id="botaoAverbacao" onClick="javascript:tryRequestToServer(function(){averbarNFseG2Ka();});" value="Averbar NFS-e G2Ka via WebSevice (AT&M 2.4)" id="botAverbar"/>    
                    </c:if>
                    <c:if test="${param.status=='C'}">
                        <input class="inputbotao" type="button" name="botaoAverbacao" id="botaoAverbacao" onClick="javascript:tryRequestToServer(function(){cancelarAverbacaoNFseG2KA();});" value="Cancelar Averbação NFS-e G2Ka via WebSevice (AT&M 2.4)" id="botAverbar"/>    
                    </c:if>
                </td>
                <td colspan="4" align="center"><input type="hidden"> </td>
            </tr>
            <tr class="CelulaZebra1">
                <td width="54%" align="center">
                    Total de Ocorr&ecirc;ncias
                    <c:out value="${param.qtdResultados}"/>
                </td>            
                <td width="19%" align="center">
                    P&aacute;ginas
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                <td width="13%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="NFSeG2kaControlador?acao=listar" method="post">
                        <input name="naoImpressas" id="naoImpressas" value="false" type="hidden">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input type="hidden" name="dataDe" value="<c:out value="${param.dataDe}"/>">
                        <input type="hidden" name="dataAte" value="<c:out value="${param.dataAte}"/>">
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="14%" align="center" colspan="2">
                    <form id="formularioProx" name="formularioProx"  action="NFSeG2kaControlador?acao=listar" method="post">
                        <input name="naoImpressas" id="naoImpressas" value="false" type="hidden">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input type="hidden" name="dataDe" value="<c:out value="${param.dataDe}"/>">
                        <input type="hidden" name="dataAte" value="<c:out value="${param.dataAte}"/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>
            </tr>
        </table>
    </body>
</html>
