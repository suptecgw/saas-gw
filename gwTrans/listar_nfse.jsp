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
    <jsp:param name="nomeUsuario" value="${nomeUsuario}"/>
</jsp:include>
<script type="text/javascript" language="JavaScript">

    jQuery.noConflict();

    let homePath = '${homePath}';
    let certificadoAtualizado = '${configTecnica.certificadoAtualizadoEm != null}';

    var countRow = 0;

    function pesq(){
        document.formulario.idFilial.disabled = false;
        document.formulario.submit();
    }
    
    function limparCliente(){
        document.formulario.con_rzs.value = "";
        document.formulario.idconsignatario.value = "0";
    }
    
    function abrirLocalizarCliente(){
        abrirLocaliza("ClienteControlador?acao=localizar", "locClienteNFSe");
    }

    function abrirVenda(idVenda){
        //        tryRequestToServer(function(){
        //            abrirMax("VendaControlador?acao=iniciarEditarLogis&id=" + idVenda, "cadVendaServico");
        //        });
    }
    
    
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
            document.formulario.idFilial.value = '<c:out value="${param.idFilial}"/>';
            document.formulario.utilizaAverbacao.value = '<c:out value="${param.utilizaAverbacao}"/>';
            document.formulario.documentoAverbacao.value = '<c:out value="${param.averbacao}"/>';
            
            if(campoConsulta == 'emissao_rps'){
                habilitaConsultaDePeriodo(true);
                document.formulario.dataDe.focus();
            }else{
                document.formulario.valorConsulta.focus();
            }

            var nivel = parseInt('<c:out value="${param.nivelFilial}"/>' ) ;
            
            if (nivel < 1){
                document.formulario.idFilial.value = '<c:out value="${param.filialUser}"/>';
                document.formulario.idFilial.disabled = true;
            }
            
            } catch (e) { 
            alert(e);
        }
    }

    function excluir(id, numero){
        try {
            if(confirm("Deseja Cancelar a NFS-e '" + numero + "'?" )){
                if(confirm("Tem Certeza?" )){
                    var textoCancelamento = prompt("Qual o Motivo do Cancelamento?" ,"");
                    if(textoCancelamento != null){
                        if(confirm("Tem Certeza?")){
                            window.open("./NFSeControlador?acao=cancelar&nfse=" + id + "&numero="+numero+"&motivo="+textoCancelamento , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
                        }
                    }
                }
            }
        } catch (e) { 
            alert(e);
        }
    }

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
            window.open("https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?inscricao=" + mun + "&nf=" + nota + "&verificacao=" +codVerificacao,
            "impressaoConferenciaSaida", "titlebar=no, menubar=no, scrollbars=yes,"+
                " status=yes,  resizable=yes, left=0, top=0");
        }else if(ibge == "3509502"){
           //CAMPINAS
           launchPDF('NFSeControlador?acao=relatorio&id=' + id);        
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
            launchPDF('NFSeControlador?acao=impressaoGeral&ids=' + ids + '&tamanho=' + tamanho);
        }
    }

    function enviarNFSe(){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        window.open("about:blank" ,"pop", "width=210, height=100");
        $("formNFSe").submit();
        $("botEnviar").disabled = true;
    }
    
    function reciboThread(numeroRecibo, idVenda){
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        window.open("NFSeControlador?acao=reciboThread&numeroRecibo=" + numeroRecibo + "&idVenda=" + idVenda ,"pop", "width=210, height=100");
    }
    
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

        launchPDF('NFSeControlador?acao=relatorio&idNota=' +id);

    }
    
        function averbarNFse(){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            var limiteResultados = document.formulario.limiteResultados.value;
            console.log("limiteResultados: "+limiteResultados);
             var utilizaAverbacao = $("utilizaAverbacao").value;
            var idvenda;
            for(var i=1; i<=limiteResultados; i++){
                console.log("i: "+i);
                if($("venda_"+i)!= null && $("venda_"+i)!=undefined){
                    if($("venda_"+i).checked){
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
            var formu = $("formNFSe");
            formu.action = './NFSeControlador?acao=averbarNfse&venda='+idvenda;
            formu.submit();
        }
    
        function cancelarAverbacaoNFse(){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            var limiteResultados = document.formulario.limiteResultados.value;

            var idvenda;
            var utilizaAverbacao = $("utilizaAverbacao").value;
            for(var i=1; i<=limiteResultados; i++){
                console.log("i: "+i);
                if($("venda_"+i)!= null && $("venda_"+i)!=undefined){
                    if($("venda_"+i).checked){
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
            var formu = $("formNFSe");
            formu.action = './NFSeControlador?acao=cancelarAverbacaoNfse&venda='+idvenda;
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
        <title>gwLogis - NFS-e</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="desativarBotoes(), setDefault(), applyFormatter()"  >
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="100%" align="left"> 
                    <span class="style4">NFS-e (${stUtilizacaoNfse})</span>
                </td>
            </tr>
        </table>
        <br>
        <form action="NFSeControlador?acao=listar" id="formulario" name="formulario"  method="post">
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
                     <td  class="CelulaZebra1">
                         Filial:
                        <select name="idFilial" id="idFilial" class="inputtexto" >
                            <option value="0">Todas as Filiais</option>
                            <c:forEach var="idFilial" items="${filiais}">
                                <option value="${idFilial.idfilial}">Apenas a ${idFilial.abreviatura}</option>
                            </c:forEach>
                        </select>
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
                        <select name="stat" class="inputtexto" onchange="pesq()">
                            <option value="P" ${param.status == "P" ? "selected" : ""}> Pendende </option>
                            <option value="E" ${param.status == "E" ? "selected" : ""}> Enviado </option>
                            <option value="C" ${param.status == "C" ? "selected" : ""}> Confirmado </option>
                            <option value="N" ${param.status == "N" ? "selected" : ""}> Negado </option>
                            <option value="L" ${param.status == "L" ? "selected" : ""}> Cancelado </option>
                        </select>
                    </td>
                    <td width="20%" class="CelulaZebra1">
                    Mostrar Apenas Averbados:
                    <select name="documentoAverbacao" id="documentoAverbacao"  class="inputtexto">                        
                        <option value="t" selected>Todos</option>
                        <option value="s" >Sim</option>
                        <option value="n" >Não</option>
                    </select>   
                    </td>
                    <td width="20%" class="CelulaZebra1">
                        <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function(){pesq();});"/>
                    </td>
                         <input type="hidden" id="utilizaAverbacao" name="utilizaAverbacao">
                </tr>
                <tr>
                    <td class="CelulaZebra1">
                        <input name="impressaoGeral" type="button" class="botoes" id="impressaoGeral" onClick="javascript:tryRequestToServer(function(){popImpressaoGeral();});" value="Imprimir Notas Selecionadas">
                    </td>
                    <td colspan="4" class="celulaZebra1">
                    </td>
                </tr>
            </table>
        </form>
        <form action="NFSeControlador?acao=enviar"  method="post" name="formNFSe" id="formNFSe" target="pop">
            <table width="90%"  class="bordaFina" align="center" style="vertical-align:top">
                <tr>
                    <td class="tabela" width="3%" align="left"></td>
                    <td class="tabela" align="left"></td>
                    <td class="tabela" align="center">RPS</td>
                    <td class="tabela" align="center">Emiss&atilde;o</td>
                    <td class="tabela" align="center">Nº Recibo</td>
                    <td class="tabela" align="center">Data/Hora Envio</td>
                    <td class="tabela" align="center">Cliente</td>
                    <td class="tabela" align="center">NFS-e</td>
                    <td class="tabela" align="center">Cod. Verifica&ccedil;&atilde;o</td>
                    <td class="tabela" align="left"></td>
                </tr>
                <c:forEach var="nfse" varStatus="status" items="${listaListNFSe}">
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                        <td style="display:none ">
                            <script type="text/javscript">countRow++;</script>
                        </td>
                        <td>
                            <c:if test="${nfse.venda.filial.enviarVariasNfse}">
                                <input type="hidden" name="variasNfse" id="variasNfse" value="nfse.venda.filial.enviarVariasNfse" />
                                <input type="checkbox" name="venda_${status.count}" id="venda_${status.count}" value="${nfse.venda.id}">
                            </c:if>
                            <c:if test="${!nfse.venda.filial.enviarVariasNfse}">
                                <input type="radio" name="venda" id="venda_${status.count}" value="${nfse.venda.id}">
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${param.status == 'C' || param.status == 'L'}">
                                <a>
                                    <img alt="" class="imagemLink" id="pdf_${status.count}" onclick="imprimir(1, '${nfse.venda.numero}','${nfse.codVerificacao}','${nfse.venda.id}','${nfse.numero}','${nfse.venda.filial.cidade.cod_ibge}');" src="img/pdf.gif" />
                                    <img alt="" class="imagemLink" id="excel_${status.count}" onclick="imprimir(2, '${nfse.venda.numero}','${nfse.codVerificacao}','${nfse.venda.id}','${nfse.numero}','${nfse.venda.filial.cidade.cod_ibge}');" src="img/excel.gif" style="display: none"/>
                                    <img alt="" class="imagemLink" id="ie_${status.count}" onclick="imprimir(3, '${nfse.venda.numero}','${nfse.codVerificacao}','${nfse.venda.id}','${nfse.numero}','${nfse.venda.filial.cidade.cod_ibge}');" src="img/ie.gif" style="display: none"/>
                                    <img alt="" class="imagemLink" id="word_${status.count}" onclick="imprimir(4, '${nfse.venda.numero}','${nfse.codVerificacao}','${nfse.venda.id}','${nfse.numero}','${nfse.venda.filial.cidade.cod_ibge}');" src="img/word.gif" style="display: none"/>
                                </a>
                            </c:if>
                        </td>
                        <td align="center">
                            <a href="javascript:editar(${nfse.venda.id})" class="linkEditar">
                                ${nfse.venda.numero}
                            </a>
                        </td>
                        <td align="center">${nfse.venda.emissaoEmS}</td>
                        <td align="center">
                            <c:if test="${param.status == 'E'}">
                                <a href="javascript:reciboThread(${nfse.numeroRecibo}, ${nfse.idRecibo})">
                            </c:if>

                            ${nfse.numeroRecibo}

                            <c:if test="${param.status == 'E'}">
                                </a>
                            </c:if>
                        </td>
                        <td align="center">${nfse.dataHoraEnvio}</td>
                        <td>
                            ${nfse.venda.cliente.razaosocial}
                            <input type="hidden" id="stUti_${status.count}" name="stUti_${status.count}" value="${nfse.venda.cliente.stUtilizacaoAverbacaoNFSe}">
                            <input type="hidden" id="seguro_${status.count}" name="seguro_${status.count}" value="${nfse.venda.cliente.seguroCarga}">
                        </td>
                        <!--<td ><fmt:formatNumber value="${nfse.venda.totalReceita}" pattern="#,##0.00#"/></td>-->
                        <td align="center">${nfse.numero}</td>
                        <td align="center">
                            <c:if test="${param.status == 'N'}">
                                <a onclick="alert('${nfse.descricaoStatus}')" title="${nfse.descricaoStatus}"/>${nfse.statusNfse}</a>
                            </c:if>
                            <c:if test="${param.status != 'N'}">
                                ${nfse.codVerificacao}
                            </c:if>
                        </td>
                        <td align="center">
                            <c:if test="${param.status == 'C' && param.nivel >= 4}">
                                <a href="javascript: tryRequestToServer(function(){excluir('${nfse.venda.id}','${nfse.venda.numero}');});">
                                    <img title="Cancelamento da Nota" alt="" class="imagemLink" src="img/cancelar.png"/>
                                </a>
                            </c:if>
                        </td>
                    </tr>
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                        <td colspan="7"><div align="right"><c:if test="${param.status=='C' && param.utilizaAverbacao!='N'}"><b>Averbação:</b></div></c:if>
                        </td>
                        <td colspan="5"><div align="left"><c:if test="${param.status=='C' && param.utilizaAverbacao!='N'}"><b>${nfse.venda.mensagemAverbacao}</b></c:if></div>
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
                    <c:if test="${param.status == 'N' || param.status == 'P'}">
                        <input type="button" id="botEnviar" value=" Enviar " class="inputBotao" onclick="enviarNFSe()">
                    </c:if>
                </td>
            </tr>
             <tr class="CelulaZebra1">
                <td colspan="1" align="center"> 
                    <!-- <input class="inputbotao" type="button" name="botaoAverbacao" id="botaoAverbacao" onClick="javascript:tryRequestToServer(function(){cancelarAverbacaoNFse()();});" value="Cancelar Averbação NFS-e via WebSevice (AT&M 2.4)" id="botAverbar"/> --> 
                  </td>
              
                <td colspan="4" align="center">
                    <c:if test="${param.status=='C'}">
                        <input class="inputbotao" type="button" name="botaoAverbacao" id="botaoAverbacao" onClick="javascript:tryRequestToServer(function(){averbarNFse();});" value="Averbar NFS-e via WebSevice (AT&M 2.4)" id="botAverbar"/>    
                    </c:if>
                    <c:if test="${param.status=='L'}">
                        <input class="inputbotao" type="button" name="botaoAverbacao" id="botaoAverbacao" onClick="javascript:tryRequestToServer(function(){cancelarAverbacaoNFse()();});" value="Cancelar Averbação NFS-e via WebSevice (AT&M 2.4)" id="botAverbar"/>  
                    </c:if>
                        
                   
                </td>
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
                    <form id="formularioAnt" name="formularioAnt" action="NFSeControlador?acao=listar" method="post">
                        <input name="naoImpressas" id="naoImpressas" value="false" type="hidden">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input type="hidden" name="dataDe" value="<c:out value="${param.dataDe}"/>">
                        <input type="hidden" name="dataAte" value="<c:out value="${param.dataAte}"/>">
                        <input type="hidden" name="averbacao" value="<c:out value="${param.averbacao}"/>">
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="14%" align="center" colspan="2">
                    <form id="formularioProx" name="formularioProx"  action="NFSeControlador?acao=listar" method="post">
                        <input name="naoImpressas" id="naoImpressas" value="false" type="hidden">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual+ 1}'/>">
                        <input type="hidden" name="dataDe" value="<c:out value="${param.dataDe}"/>">
                        <input type="hidden" name="dataAte" value="<c:out value="${param.dataAte}"/>">
                        <input type="hidden" name="averbacao" value="<c:out value="${param.averbacao}"/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>
            </tr>
        </table>
    </body>
</html>