
<%@page import="java.sql.ResultSet"%>
<%@page import="nucleo.impressora.BeanConsultaImpressora"%>
<%@page import="java.util.Vector"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">


<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jQuery/jquery.js" type="text/javascript"></script>
<script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
<jsp:include page="/importAlerts.jsp">
    <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
    <jsp:param name="nomeUsuario" value="<%= Apoio.getUsuario(request).getNome() %>"/>
</jsp:include>
<script type="text/javascript" language="JavaScript">
    <%
        BeanConfiguracao configuracao = new BeanConfiguracao();
        configuracao.setConexao(Apoio.getUsuario(request).getConexao());
        configuracao.setExecutor(Apoio.getUsuario(request));
            boolean carregaConfig = configuracao.CarregaConfig();
        request.setAttribute("configTecnica", getServletContext().getAttribute("configTecnica"));

    %>

    var homePath = '${homePath}';
    let certificadoAtualizado = '${configTecnica.certificadoAtualizadoEm != null}';

    shortcut.add("enter", function() {
        pesquisa()
    });
    jQuery.noConflict();
    
    function desativarBotoes() {
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';


        if (atual == '1') {
            //desabilitar(document.formularioAnt.botaoAnt);
            document.formularioAnt.botaoAnt.disabled = true;
        }
        if (parseFloat(atual) >= parseFloat(paginas)) {
            //desabilitar(document.formularioAnt.botaoProx);
            document.formularioProx.botaoProx.disabled = true;
        }

        //document.formulario.valorConsulta.focus();
    }

    function setDefault() {
        $("valorConsulta").focus();
        $("limiteResultados").value = '<c:out value="${param.limiteResultados}"/>';
        $("operadorConsulta").value = '<c:out value="${param.operadorConsulta}"/>';
        $("campoConsulta").value = '<c:out value="${param.campoConsulta}"/>';
        $("valorConsulta").value = '<c:out value="${param.valorConsulta}"/>';
        $("dataDe").value = '<c:out value="${param.dataDe}"/>';
        $("dataAte").value = '<c:out value="${param.dataAte}"/>';
        $("filial").value = '<c:out value="${param.filialId}"/>';
        
        $("idmotorista").value = '<c:out value="${param.idmotorista}"/>';
        $("idveiculo").value = '<c:out value="${param.idveiculo}"/>';
        $("motor_nome").value = '<c:out value="${param.motor_nome}"/>';
        $("vei_placa").value = '<c:out value="${param.vei_placa}"/>';
        $("fornecedor").value = '<c:out value="${param.fornecedor}"/>';
        $("idfornecedor").value = '<c:out value="${param.idfornecedor}"/>';
        $("tipoFiltroCiot").value = '<c:out value="${param.tipoFiltroCiot}"/>';
        $("tipoFiltroCancelados").value = '<c:out value="${param.tipoFiltroCancelados}"/>';
        $("isMeuUser").checked = ('<c:out value="${param.isMeuUser}"/>' == "true"? true: false);
        $("tipoFiltroStatus").value = '<c:out value="${param.tipoFiltroStatus}"/>';
        $("tipoFiltroOrdenacao").value = '<c:out value="${param.tipoFiltroOrdenacao}"/>';
        $("tipoFiltroOrdenacao2").value = '<c:out value="${param.tipoFiltroOrdenacao2}"/>';
    
        //validando campos referente a geração de CIOT
        var empresaCiot = '${usuario.filial.stUtilizacaoCfeS}';
        $('nddEnviaMotorista').style.display = 'none';
        $('nddLbEnviaMotorista').style.display = 'none';
        $('lbCiotNao').style.display = 'none';
        $('divBotaoCiot').style.display = 'none';
        if (empresaCiot == 'R'){
            $('divBotaoCiot').style.display = '';
        }else if (empresaCiot == 'P'){
            $('divBotaoCiot').style.display = '';
        }else if (empresaCiot == 'D'){
            $('nddEnviaMotorista').style.display = '';
            $('nddLbEnviaMotorista').style.display = '';
            $('divBotaoCiot').style.display = '';
        }else if(empresaCiot == 'E'){
            $('nddEnviaMotorista').style.display = '';
            $('nddLbEnviaMotorista').style.display = '';
            $('divBotaoCiot').style.display = '';
        }else if(empresaCiot == 'X'){
            $('nddEnviaMotorista').style.display = '';
            $('nddLbEnviaMotorista').style.display = '';
            $('divBotaoCiot').style.display = '';
        }else if(empresaCiot == 'G'){
            $('nddEnviaMotorista').style.display = '';
            $('nddLbEnviaMotorista').style.display = '';
            $('divBotaoCiot').style.display = '';
        }else if(empresaCiot == 'A'){
            $('nddEnviaMotorista').style.display = '';
            $('nddLbEnviaMotorista').style.display = '';
            $('divBotaoCiot').style.display = '';
        }else{
            $('lbCiotNao').style.display = '';
        }    
    }

    function habilitaConsultaDePeriodo(opcao) {
        if ($("campoConsulta").value != "cf.data"){
            document.getElementById("valorConsulta").style.display = "";
            document.getElementById("operadorConsulta").style.display = "";
            if (document.getElementById("operadorConsulta").value == ''){
                document.getElementById("operadorConsulta").value = '1';
            }
            document.getElementById("div1").style.display = "none";
            document.getElementById("div2").style.display = "none";
        } else {
            document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");
        }
    }

    function abrirCadastro() {
        window.location = "ContratoFreteControlador?acao=novoCadastro", "lanCadContratoFrete";
    }

    function excluir(id) {
        if (confirm("Deseja excluir este contrato de frete?")) {
            if (confirm("Tem certeza?")) {
                window.open("ContratoFreteControlador?acao=excluir&id=" + id,
                        "pop", "width=210, height=100");
            }
        }
    }

    function pesquisa() {
        if ($("campoConsulta").options[$("campoConsulta").selectedIndex].text == "Data") {
            validarDatas();
        }
        $("formulario").action += "&isMeuUser="+$("isMeuUser").checked;
        
        $("formulario").submit();
    }

    function validarDatas(){
        alertInvalidDate($("dataDe"));
        alertInvalidDate($("dataAte"));
    }
    
    function duplicar(value, isTac) {
        $("isTac").value = isTac;
        $("idContratoFrete").value = value;
    }

    function cancelar(idContrato, numero, ciot) {
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        tryRequestToServer(function() {
            if (confirm("Tem certeza que deseja cancelar o contrato de frete de número: '" +
                    numero + "' e CIOT: '" + ciot + "'")) {
                if (confirm("Tem certeza?")) {
                    window.open("RepomControlador?acao=cancelar&idContratoFrete=" + idContrato, "pop", "width=210, height=100");
                }
            }
        })
    }
    
    function cancelarEFrete(idContrato, numero, ciot, cod) {
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        if(ciot=='0'){
            alert("Não existe CIOT para o contrato de frete"+idContrato+"! O cancelamento não poderá ser realizado. ")
        }else{       
        
            tryRequestToServer(function() {
                if (confirm("Tem certeza que deseja cancelar o contrato de frete de número: '" +numero + "' e CIOT: '" + ciot + "/"+cod+"'")) {
                    var textoCancelamento = prompt("Qual o motivo do cancelamento?" ,"");
                    if(textoCancelamento != null){
                        if (confirm("Tem certeza?")) {
                            window.open("EFreteControlador?acao=cancelarCiot&idContratoFrete=" + idContrato+"&motivo="+textoCancelamento, "pop", "width=210, height=100");
                        }
                    }
                }
            })
        }

    }
    function cancelarExpeRS(idContrato, numero, ciot, cod) {
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        if(ciot=='0'){
            alert("Não existe CIOT para o contrato de frete"+idContrato+"! O cancelamento não poderá ser realizado. ")
        }else{       
        
            tryRequestToServer(function() {
                if (confirm("Tem certeza que deseja cancelar o contrato de frete de número: '" +numero + "' e CIOT: '" + ciot + "/"+cod+"'")) {
                    var textoCancelamento = prompt("Qual o motivo do cancelamento?" ,"");
                    if(textoCancelamento != null){
                        if (confirm("Tem certeza?")) {
                            window.open("ExpersControlador?acao=cancelarCiot&idContratoFrete=" + idContrato+"&motivo="+textoCancelamento, "pop", "width=210, height=100");
                        }
                    }
                }
            })
        }

    }
    
    function cancelarPagBem(idContrato, numero, ciot, cod) {
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        if(ciot=='0'){
            alert("Não existe CIOT para o contrato de frete"+idContrato+"! O cancelamento não poderá ser realizado. ")
        }else{       
        
            tryRequestToServer(function() {
                if (confirm("Tem certeza que deseja cancelar o contrato de frete de número: '" +numero + "' e CIOT: '" + ciot + "/"+cod+"'")) {
                    
                   
                        if (confirm("Tem certeza?")) {
                            window.open("PagBemControlador?acao=cancelarCiot&idContratoFrete=" + idContrato, "pop", "width=210, height=100");
                        }
                  
                }
            })
        }

    }
    
    function encerrarEFrete(idContrato, ciot, cancelada) {
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        if(ciot=='0'){
                alert("Não existe CIOT para o contrato de frete "+idContrato+". Este contrato não poderá ser encerrado! ");        
        }else{           
            if(cancelada=='true'){
                alert("O Contrato '"+idContrato+"' está cancelado. Este contrato não poderá ser encerrado! ");
            }else{
                tryRequestToServer(function() {
                    if (confirm("Tem certeza que deseja encerrar o contrato de frete de número: '" +idContrato + "'")) {
                        if (confirm("Tem certeza?")) {
                            window.open("EFreteControlador?acao=encerrarCiot&idContratoFrete=" + idContrato, "pop", "width=210, height=100");
                        }
                    }
                })
            }
        }
    }


    function finalizarAgregado(idContrato){
    //função para mudar o status do CF para 4
    //0 - pendente e 3 - enviado... criaremos o 4 - FINALIZADO
    //esse status é especial para o TAC agregado para informar
    //que o tacBASE foi finalizado, forçando a ideia que caso
    //o proximo CF caso seja TAC, o mesmo sera o BASE para os futuros
    //CF's agregados, até que valide ele como status 4, dando vez a novas bases.
     if (confirm("Deseja Finalizar este contrato de frete?")) {
            if (confirm("Tem certeza?")) {
    window.open("NddControlador?acao=finalizarAgregado&idContrato=" + idContrato,
                        "pop", "width=210, height=100");
            }
        }
        
    }

    function validaCfe() {
        if (certificadoAtualizado === 'false') {
            chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

            return;
        }

        try {
            var isTac =$("isTac").value;
            var xIdCarta = $("idContratoFrete").value;
            if (xIdCarta == '0') {
                alert("Selecione um contrato de frete para enviar.");
                return false;
            }

            if ($('isPrecisaAutorizacao_id'+xIdCarta).value == 'true' && $('isAutorizado_id'+xIdCarta).value == 'false'){
                alert("ATENÇÃO! Esse contrato de frete não foi autorizado, geração do CIOT não permitida.");
                return false;
            }    

            if (isTac == "false") {
                
                if($("stUtilizacaoCfeS").value == 'E') {
                    if ($("isTacFilial_"+xIdCarta).value == 'false'){
                        alert("Atenção! O Contratado não é um TAC ou equiparado, geração do CIOT não permitida. Dica: Essa opção poderá ser habilitada no cadastro da filial. ");
                        return false;
                    }
                }else if ($("stUtilizacaoCfeS").value != 'E' && $("stUtilizacaoCfeS").value != 'G'){
                    if (!confirm("O tranportador não se enquadra na lei do TAC!\nDeseja continuar mesmo assim?")) {
                        return false;
                    }
                }


            }
            
            // Verifica se tem pagamentos baixados no Contrato de Frete, se tiver, não deixar gerar o CIOT.
            var podeEnviarCIOT = true;
            jQuery.ajax({
                url: '${homePath}/ContratoFreteControlador',
                type: 'POST',
                async: false,
                data: {
                    acao: 'verificarDespesasBaixadas',
                    'id': xIdCarta
                },
                success: function (data, textStatus, jqXHR) {
                    if (data) {
                        if (data['pago'] === true) {
                            chamarAlert('Já existe pelo menos um adiantamento ou saldo baixados, ação não poderá ser completada.');

                            podeEnviarCIOT = false;
                        }
                    }
                }
            });

            if (podeEnviarCIOT) {
                var form = $("formularioCfe");

                tryRequestToServer(function () {
                    window.open("about:blank", "pop", "width=210, height=100");
                    $("isEnviarMotorista").value = $("motorista").checked;
                    $("isEnviarProprietario").value = $("proprietario").checked;

                    form.submit();
                    $("botaoCIOT").disabled = true;
                });
            }
        } catch (e) {
            console.log(e);
        }
    }
    
    
    //Função para retornar só a quantidade de checkados para imprimir todos.
    function getQtdCheckedCtrcs(){
        var ids = 0;
        var i=1;
        for (var i = 1; getObj("chk_" + i) != null; i++){
            if (getObj("chk_" + i).checked){
                ids += 1;
            }
        }
        return ids;
    }

    
    
    
//    function getCheckedCtrcs(){
//        
//     var ids = "";
//        for (i = 0; $("ck" + i) != null; ++i){
//	     if ($("ck" + i).checked){
//	         ids += ',' + $("chk_" + i).value;
//             }
//        }
//        
//	return ids.substr(1);
//    }

    function imrprmir(id, linha) {

        if(linha!=null){
            var nivelAutenticadoPodeImprimir = '${cg:getAcesso(usuario, "impcontratociot")}';
            console.log("autenticado="+'${usuario.id}');
            console.log("nivelAutenticadoPodeImprimir="+nivelAutenticadoPodeImprimir);
            var possuiCiot = $("possuiCiot_" + id).value;            
            
            if ((possuiCiot === "false" || possuiCiot === "f") && parseInt(nivelAutenticadoPodeImprimir, 10) < 4 ) {
                alert('Você não tem permissão para imprimir contrato de frete sem CIOT gerado!');
                return null;
            }
            
            if ($("isImpresso" + linha).value === "true" && !confirm("A Carta de Frete " + id + " já foi impressa, deseja imprimir novamente?")) {
                return null;
            } else if ($("isPrecisaAutorizacao" + linha).value == "true" && $("isAutorizado" + linha).value == "false") {    
                alert('ATENÇÃO! Esse contrato de frete não foi autorizado, impressão não permitida.');
            } else {
                launchPDF('./consultacartafrete?acao=exportar&modelo=' + document.getElementById("modeloRelatorio").value + '&id=' + id + '&usuario=' + '${usuario.nome}', 'carta' + id);
                //location.replace("ContratoFreteControlador?acao=editarImpresso&idContratoFrete="+id);
                new Ajax.Request("ContratoFreteControlador?acao=editarImpresso&idContratoFrete=" + id);
                $("isImpresso" + linha).value = true;
            }
        }else{
       //Retorna os marcados para impressão
            id = getQtdCheckedCtrcs();
            
            
            <c:if test="${usuario.filial.stUtilizacaoCfeS == 'A'}">
                // Avisar que esse modelo só poderá imprimir 1 CIOT
                if (document.getElementById("modeloRelatorio").value == '15' && id > 1) {
                    alert('ATENÇÃO: O Modelo 15 (TARGET - Web Service) só poderá ser impresso um contrato de frete por vez.');

                    return false;
                }
            </c:if>

            for (var i = 1; i <= id; i++) {
            
                if ($("isPrecisaAutorizacao" + i).value == "true" && $("isAutorizado" + i).value == "false" && $("chk_"+i).checked) {
                    var numero = $("chk_"+i).value;
                    alert('ATENÇÃO! Esse contrato de frete '+numero+ ' não foi autorizado, impressão não permitida.');
                    
                    $("chk_"+i).checked = false;
                    
                }
            }
            
            <c:if test="${usuario.filial.stUtilizacaoCfeS != 'A'}">
                // Testar se o modelo de contrato selecionado é Target, se for avisar que a filial não usa Target
                if (document.getElementById("modeloRelatorio").value == '15') {
                    alert('ATENÇÃO: Esse modelo é exclusivo para a operadora TARGET.');

                    return false;
                }
            </c:if>
             
            var ids = getCheckedCtrcs();
            
            console.log(" ids : " + ids);
            
            if (ids != "") {
                launchPDF('./consultacartafrete?acao=exportar&modelo=' + document.getElementById("modeloRelatorio").value + '&id=' + ids + '&usuario=' + '${usuario.nome}', 'carta' + id);

                    //location.replace("ContratoFreteControlador?acao=editarImpresso&idContratoFrete="+id);
                    new Ajax.Request("ContratoFreteControlador?acao=editarImpresso&idContratoFrete=" + id); 
            }
              
        }
 
    }
    
    function popContratoFrete(id){
            try {
                var idM = "";
                if (id == "" || id == null){
                    
                     if(getCheckedCtrcs()==null){
                        return null;
                     }else{
                        id = getCheckedCtrcs();
                     }
                   for (var i = 1; getObj("mdfe_" + i) != null; ++i){
                        if (getObj("mdfe_" + i).checked){
                            idM += ",'" + getObj("impTudo_" + i).value + "'";
                        }
                        id = idM.substr(1);
                    }
                    var wName = 'DAMDFE';
                }
                if (id !="") {
                launchPDF('MDFeControlador?acao=imprimirDamdfe&modelo='+1+'&idManifestos=' + id, wName);
                }
            } catch (e) {
                alert(e);
            }
        }

    function anularGUID(idContratoFrete) {
    if(confirm("tem certeza que deseja apagar o GUID do Contrato '" + idContratoFrete + "' ?")){
        window.open("./NddControlador?acao=anularGUID&idContratoFrete=" + idContratoFrete,
                "pop", "width=210, height=100");
            }
                
    }
    function consultarProtocolo(idContratoFrete) {

        window.open("./NddControlador?acao=consultarProtocolo&idContratoFrete=" + idContratoFrete,
                "pop", "width=210, height=100");

    }
    
    function consultarProtocoloEncerramento(idContratoFrete) {

        window.open("./NddControlador?acao=consultarProtocoloEncerramento&idContrato=" + idContratoFrete,
                "pop", "width=210, height=100");

    }
    
    
    function abrirLocalizaVeiculo(){
        popLocate(3, "Veiculo", "", "");
    }
    
    function abrirLocalizaMotorista(){
        popLocate(3, "Motorista", "","")
    }
    
    function limparMotorista(){
        $("motor_nome").value = "";
        $("idmotorista").value = "";
        $("idveiculo").value = "0";
        $("vei_placa").value = "";
    }
    
    function limparVeiculo(){
        $("vei_placa").value = "";
        $("idveiculo").value = "";
    }
    
    function limparContratado(){
        $("fornecedor").value = "";
        $("idfornecedor").value = ""; 
    }
    
    function aoClicarNoLocaliza(idJanela){
        if (idJanela == "Veiculo") {
            $("idveiculo").value = $("idveiculo").value;
            $("vei_placa").value = $("vei_placa").value;
        }
        if (idJanela == "Contratado") {
            $("idfornecedor").value = $("idfornecedor").value;
            $("fornecedor").value = $("fornecedor").value;
        }
        if (idJanela == "Motorista"){
            $("idmotorista").value = $("idmotorista").value;
            $("motor_nome").value = $("motor_nome").value;
        }
    }
    
     function getCheckedCtrcs(){
            var ids = "";
            var i=1;
            for (var i = 1; getObj("chk_" + i) != null; i++){
                if (getObj("chk_" + i).checked){
                    ids += ',' + getObj("chk_" + i).value;
                }
            }
            return ids.substr(1);
        }
        
        function checkTodos(){
            //seleciona todos
            var i = 1 , check = false;

            if ($("ckTodos").checked){
                check = true;
            }

            while ($("chk_"+i) != null){
                $("chk_"+i).checked = check;
                i++
            }
        }



//        function testeEfrete(){
//            
//             var idPagto = 0;
//             var xIdCarta = $("idContratoFrete").value;
//             console.log("idContratoFrete: "+xIdCarta);
//                new Ajax.Request("./ContratoFreteControlador?acao=tempEFrete&idCartaFrete="+xIdCarta,{
//                    method:'post',
//                    onSuccess: function(){  },
//                    onFailure: function(){  }
//                });
//         
//        }

        /**
         * @description função de envio para frete facil
         * @param {int} idCF id do contrato de frete
         * @param {boolean} jaEnviado se o contrato já foi enviado a FreteFacil.
         */
        function enviarFreteFacil(idCF, jaEnviado) {
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            var mensagemFreteFacil = (jaEnviado 
                ? "Contrato já foi enviado a Frete Fácil. Deseja reenviar?" 
                : "Deseja enviar o Contrato de frete para a Frete Fácil?"
            );
            if(confirm(mensagemFreteFacil)){
                window.open("./ContratoFreteControlador?acao=enviarFreteFacil&idContratoFrete=" + idCF,
                "popFF", "width=210, height=100");
            }
        }

        function encerrarTarget(idContrato, ciot, cancelada) {
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            if (ciot == '0') {
                alert("Não existe CIOT para o contrato de frete " + idContrato + ". Este contrato não poderá ser encerrado!");        
            } else {           
                if (cancelada == 'true') {
                    alert("O Contrato '" + idContrato + "' está cancelado. Este contrato não poderá ser encerrado!");
                } else {
                    tryRequestToServer(function() {
                        if (confirm("Tem certeza que deseja encerrar o contrato de frete de número: '" + idContrato + "'?")) {
                            if (confirm("Tem certeza?")) {
                                window.open("TargetControlador?acao=encerrarCiot&idContratoFrete=" + idContrato, "pop", "width=210, height=100");
                            }
                        }
                    });
                }
            }
        }

        function getCheckedCartaFrete(){
             var ids = "";

             for (i = 1; $("chk_" + i) != null; ++i){
                 if ($("chk_" + i).checked){
                      ids += ',' + $("chk_" + i).value;                 
                 }
             }

                 return ids.substr(1);
        
        }
        
        function getCheckedCartaFreteUpdate(){
              var ids = "";

             for (i = 1; $("chk_" + i) != null; ++i){
                    if ($("chk_" + i).checked){
                        ids += ',' + $("chk_" + i).value;

                    if($("isImpresso"+i).value == "true" && !confirm("A(s) Carta(s) de Frete " + $("chk_"+i).value + " já foi(ram) impressa(s), deseja imprimir novamente?")){
                        return "";                                                             
                    }else{
                        $("isImpresso"+i).value = true;
                    }
               }
             }

                 return ids.substr(1);
          }
          
          function getCheckedCheques(){
             var ids = "";
             for (i = 0; $("chk_" + i) != null; ++i)
                     if ($("chk_" + i).checked)
                         ids += ',' + $("chq" + i).value;

                 return ids.substr(1);
          }
          function updateImpresso(ids){     
             new Ajax.Request("./consultacartafrete?acao=updateImpresso&ids="+ids);
          }
          
          function getCheckedCartaFreteUpdate(){
            var ids = "";
            
            for (var i = 1; $("chk_" + i) != null; ++i){
                console.log($('chk_' + i));
            if ($("chk_" + i).checked){
                ids += ',' + $("chk_" + i).value;
                if($("isImpresso"+i).value == "true" && !confirm("A(s) Carta(s) de Frete " + $("chk_"+i).value + " já foi(ram) impressa(s), deseja imprimir novamente?")){
                    return "";                                                             
                }else{
                    $("isImpresso"+i).value = true;
                }
            }
            }
            return ids.substr(1);
        }
  
        function printMatricideCartaFrete() {
            if (getCheckedCartaFreteUpdate() == "") {
            alert("Selecione pelo menos uma Contrato de Frete!");
            return null;
            }
            var url =  "./matricidecartafrete.ctrc?ids="+getCheckedCartaFrete()+
            "&idCheque="+getCheckedCheques()+
            "&"+concatFieldValue("driverImpressora,caminho_impressora");
            tryRequestToServer(function(){document.location.href = url;});
            updateImpresso(getCheckedCartaFrete());
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

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->

        .modal-content {
            text-align: left;
        }
    </style>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>WebTrans - Consulta de Contratos de Fretes </title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>


    <body onload="applyFormatter(); setDefault(); habilitaConsultaDePeriodo(true); desativarBotoes();">
        <img alt="" src="img/banner.gif" align="middle">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta de Contratos de Fretes 
                        <c:if test="${usuario.filial.stUtilizacaoCfeS != 'N'}">
                            (CF-e ${usuario.filial.homologacaoCfe ? "Homologação" : "Produção"})
                        </c:if>
                    </span>
                </td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function() {abrirCadastro();});" value="Novo Cadastro"/>
                    </c:if> 
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="90%" align="center">
            <form action="ContratoFreteControlador?acao=listar" id="formulario" name="formulario" method="post">
                <tr>
                    <td width="15%" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onchange="habilitaConsultaDePeriodo(this.value == 'cf.data')" style="width: 120px;">
                            <option value="cf.idcartafrete">Nº Contrato de Frete</option>
                            <option value="cf.ciot">Nº CIOT</option>
                            <option value="cf.data" selected>Data</option>
                            <option value="mot.nome">Motorista</option>
                            <option value="vei.placa">Veículo</option>
                            <option value="car.placa">Carreta</option>
                            <option value="ctrcs">Nº CT-e</option>
                            <option value="nota_fiscal">Nº NF-e (CT-e)</option>
                            <option value="p.razaosocial">Proprietário</option>
                            <option value="c.numero_carga">Nº Carga</option>
                            <option value="c.pedido_cliente">Nº Pedido do Cliente (CT-e)</option>
                            <option value="coleta">Nº Coleta</option>
                            <option value="pedido_coleta">Nº Pedido do Cliente (Coleta)</option>
                            <option value="romaneio">Nº Romaneio</option>
                            <option value="cod_contrato_repom">Nº Contrato REPOM</option>
                        </select>
                        <input type="hidden" name="modulo" id="modulo" value="gwFrota" />
                    </td>
                    <td width="23%" class="CelulaZebra1" height="20">
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                        <div id="div1" style="display:none">De:
                            <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                        </div>
                    </td>

                    <td class="CelulaZebra1" width="15%" >
                        <div id="div2" style="display:none ">Até:
                            <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate">
                        </div>
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25">
                    </td>
                    <td width="7%" class="CelulaZebra1"><div align="right"> Filial:</div>
                    </td>
                    <td  width="10%" class="CelulaZebra1" >
                        <select name="filial" class="inputtexto" id="filial" title="Filial do Veículo" >
                            <option value="0">Todas</option>
                            <c:forEach var="filial" varStatus="status"
                                       items="${listaFilial}">
                                <option value="${filial.idfilial}">${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                    </td>
                    <td width="15%" class="CelulaZebra1NoAlign" align="center"></td>

                    <td width="15%" class="CelulaZebra1"></td>
                </tr>
                <tr>
                    <td class="CelulaZebra1NoAlign" align="right">Apenas o Motorista: </td>
                    <td class="CelulaZebra1">
                        <input type="text" class="inputReadOnly8pt" name="motor_nome" id="motor_nome" value="" size="26"/> 
                        <input type="hidden" name="idmotorista" id="idmotorista" value="">
                        <input type="button" class="inputbotao" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=10','Motorista','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onclick="limparMotorista();">
                    </td>
                    <td class="CelulaZebra1NoAlign" align="right">Apenas o Veiculo: </td>
                    <td class="CelulaZebra1" colspan="2">
                        <input type="text" class="inputReadOnly8pt" name="vei_placa" id="vei_placa" value="" readonly size="13"/>
                        <input type="hidden" name="idveiculo" id="idveiculo" value="">
                        <input type="button" class="inputbotao" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=7','Veiculo','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"/>
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onclick="limparVeiculo();">
                    </td>
                    <td class="CelulaZebra1NoAlign" align="" colspan="2">
                        <INPUT type="checkbox" id="isMeuUser" name="isMeuUser" checked/>Mostrar Contratos Criados por Mim.                        
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1NoAlign" align="right">Apenas o contratado: </td>
                    <td class="CelulaZebra1">
                        <input type="text" class="inputReadOnly8pt" name="fornecedor" id="fornecedor" value="" readonly size="26"/>
                         <input type="hidden" name="idfornecedor" id="idfornecedor" value="">
                         <input type="button" class="inputbotao" value="..." onclick="javascript:window.open('./localiza?acao=consultar&idlista=21&paramaux=1','Contratado','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"/>
                         <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onclick="limparContratado();">
                    </td>
                    <td class="CelulaZebra1NoAlign" align="right">Apenas os contratos:</td>
                    <td class="CelulaZebra1" colspan="2">
                        <select class="inputtexto" name="tipoFiltroCancelados" id="tipoFiltroCancelados" style="width: 100px;">
                            <option value="a" selected>Ambos</option>
                            <option value="n">Não Cancelados</option>
                            <option value="c">Cancelados</option>
                            <option value="t">Aguardando Autorização</option>
                        </select>
                        <select class="inputtexto" name="tipoFiltroCiot" id="tipoFiltroCiot">
                            <option value="a" selected>Ambos</option>
                            <option value="c">Com CIOT</option>
                            <option value="s">Sem CIOT</option>
                        </select>
                    </td>
                    <td width="15%" class="CelulaZebra1NoAlign" align="center"><input id="pesquisar" name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="javascript: tryRequestToServer(function() {pesquisa();})" /></td>
                    <td class="CelulaZebra1NoAlign" align="center">
                        <select id="limiteResultados"  name="limiteResultados" class="inputtexto"  >
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1NoAlign" align="right">Apenas o Status:</td>
                    <td class="CelulaZebra1NoAlign" align="left">
                        <select class="inputtexto" name="tipoFiltroStatus" id="tipoFiltroStatus">
                            <option value="a" selected>Ambos</option>
                            <option value="e">Em aberto</option>
                            <option value="b">Baixado</option>
                        </select>
                    </td>
                    <td class="CelulaZebra1NoAlign" align="right">Ordenação:</td>
                    <td class="CelulaZebra1NoAlign" colspan="4" align="left">
                        <select class="inputtexto" name="tipoFiltroOrdenacao" id="tipoFiltroOrdenacao">
                            <option value="n" selected>Nº C. Frete</option>
                        </select>
                        <select class="inputtexto" value="inputtexto" name="tipoFiltroOrdenacao2" id="tipoFiltroOrdenacao2">
                            <option value="c" selected>Crescente</option>
                            <option value="d">Decrescente</option>
                        </select>
                    </td>
                </tr>
            </form>
        </table>
        <table width="90%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="1%" ></td>
                 <td width="2%"><input name="ckTodos" type="checkbox" value="1" id="ckTodos" onClick="javascript:tryRequestToServer(function(){checkTodos();});"></td>
                <td width="2%" >
                    <img src="img/pdf.jpg" width="19" height="19" border="0" id="img_imprimir" class="imagemLink" title="Imprimir todos os contratos selecionados" align="right"
                             onClick="javascript:tryRequestToServer(function() {imrprmir(null,null)});">
                </td>
                <td width="1%" ></td>
                <td width="11%" align="center">Contrato</td>
                <td width="9%" align="center">Data</td>
                <td width="9%" align="center">Doc</td>
                <td width="23%" align="center">Motorista/Veículo</td>
                <td width="8%" align="right">Frete</td>
                <td width="8%" align="right">Adiant.</td>
                <td width="8%" align="right">Saldo</td>
                <td width="12%" align="center">Status CF-e</td>

                <td width="2%"></td>
                <td width="3%" align="center"></td>
                <td width="2%"></td>
                <td width="2%"></td>
                <td class="tabela" width="2%" align="left"></td> 
            </tr>
            <c:forEach var="contratoFrete" varStatus="status" items="${listaContratoFrete}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                    <td align="center">

                        <c:if test="${contratoFrete.ciot == 0}">
                            <c:if test="${usuario.filial.stUtilizacaoCfeS == 'P' || usuario.filial.stUtilizacaoCfeS == 'R' || usuario.filial.stUtilizacaoCfeS == 'T'  
                                || usuario.filial.stUtilizacaoCfeS == 'E' || usuario.filial.stUtilizacaoCfeS == 'X'|| usuario.filial.stUtilizacaoCfeS == 'G'
                                || usuario.filial.stUtilizacaoCfeS == 'A'}"> 
                                <input type="radio" value="${contratoFrete.id}" name="opt" onclick="duplicar(this.value, '${contratoFrete.veiculo.proprietario.tac}')">
                            </c:if>
                            <c:if test="${usuario.filial.stUtilizacaoCfeS == 'D' && contratoFrete.guidHeaderNdd == null && contratoFrete.baseTacAgregado == 0}">
                                <input type="radio" value="${contratoFrete.id}" name="opt" onclick="duplicar(this.value, '${contratoFrete.veiculo.proprietario.tac}')">
                            </c:if>


                        </c:if>
                    </td>
                    <td>
                        <div align="center">
                            <input type="checkbox" id="chk_${status.count}" name="chk_${status.count}" value="${contratoFrete.id}" >
                        </div>
                    </td>
                    <td align="center">
                        <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function() {
            imrprmir(${contratoFrete.id},${status.count})
        });">
                        <input type="hidden" name="isImpresso${status.count}" id="isImpresso${status.count}" value="${contratoFrete.impresso}">
                        <input type="hidden" name="isPrecisaAutorizacao${status.count}" id="isPrecisaAutorizacao${status.count}" value="${contratoFrete.precisaAutorizacao}">
                        <input type="hidden" name="isAutorizado${status.count}" id="isAutorizado${status.count}" value="${contratoFrete.autorizado}">
                        <input type="hidden" name="isPrecisaAutorizacao_id${contratoFrete.id}" id="isPrecisaAutorizacao_id${contratoFrete.id}" value="${contratoFrete.precisaAutorizacao}">
                        <input type="hidden" name="isAutorizado_id${contratoFrete.id}" id="isAutorizado_id${contratoFrete.id}" value="${contratoFrete.autorizado}">
                        <input type="hidden" name="isTacFilial_${contratoFrete.id}" id="isTacFilial_${contratoFrete.id}" value="${contratoFrete.filial.permitirCiotContratadosSemTacEquiparados}">
                        <input type="hidden" name="tacAgregado_${contratoFrete.id}" id="tacAgregado_${contratoFrete.id}" value="${contratoFrete.tacAgregado}">
                        <input type="hidden" name="tacAgregado_${contratoFrete.id}" id="tacAgregado_${contratoFrete.id}" value="${contratoFrete.tacAgregado}">
                        <input type="hidden" name="possuiCiot_${contratoFrete.id}" id="possuiCiot_${contratoFrete.id}" value="${contratoFrete.ciot != 0}">
                    </td>
                    <td align="center">
                        <c:if test='${servicoFreteFacil.ambiente > 0}'>
                            <c:if test="${contratoFrete.isConfirmadoServico}">
                                <img src="img/freteFacilOKP.png" align="right" class="imagemLink" title="Contrato de frete já enviado para a Frete Fácil"
                                 onclick="javascript: enviarFreteFacil(${contratoFrete.id}, true);">
                            </c:if>
                            <c:if test="${!contratoFrete.isConfirmadoServico}">
                                <img src="img/freteFacilP.png" align="right" class="imagemLink" title="Enviar o contrato de frete para a Frete Fácil"
                                 onclick="javascript: enviarFreteFacil(${contratoFrete.id}, false);">
                            </c:if>
                        </c:if>
                    </td>
                    <td align="center">
                        <a href="javascript: tryRequestToServer(function(){window.location='ContratoFreteControlador?acao=iniciarEditar&id=${contratoFrete.id}';});" class="linkEditar">
                            ${contratoFrete.id} 
                        </a><br>
                        ${contratoFrete.filial.abreviatura} / ${contratoFrete.filialDestino}
                    </td>
                    <td align="center"><font color="${contratoFrete.isCancelada ? '#CC0000' :''} ">${contratoFrete.data}</font></td>
                    <td align="center"><font color="${contratoFrete.isCancelada ? '#CC0000' :''} ">${contratoFrete.consultaNumeroDocumento}</font></td>
                    <td>
                        <font color="${contratoFrete.isCancelada ? '#CC0000' :''} ">
                            ${contratoFrete.motorista.nome}<br>
                            ${contratoFrete.veiculo.placa}/${contratoFrete.carreta.placa}
                        </font>
                    </td>
                    <td align="right"><font color="${contratoFrete.isCancelada ? '#CC0000' :''} "><script>document.write(colocarVirgula(${contratoFrete.vlLiquido}))</script></font></td>
                    <td align="right"><font color="${contratoFrete.isCancelada ? '#CC0000' :''} "><script>document.write(colocarVirgula(${contratoFrete.totalAdiantamento}))</script></font></td>
                    <td align="right"><font color="${contratoFrete.isCancelada ? '#CC0000' :''} "><script>document.write(colocarVirgula(${contratoFrete.totalSaldo}))</script></font></td>
                    <td align="center">
                        <font color="${contratoFrete.isCancelada ? '#CC0000' :''} ">
                                    <!-- foi dito que se diferente de 0 deve aparecer CONFIRMADO
                                         logo, se for 0 aparecera normal, se nao for zero aparece CONFIRMADO-->
                            <c:if test="${contratoFrete.ciot == 0}">
                                ${contratoFrete.veiculo.proprietario.tac ? contratoFrete.statusCFe.msg : "--"}
                                <c:if test="${contratoFrete.precisaAutorizacao && !contratoFrete.autorizado}">
                                    Aguardando Autorização do supervisor
                                </c:if>
                            </c:if>
                            <c:if test="${contratoFrete.ciot != 0}">
                                   ${contratoFrete.statusCFe.msg}
                                <br>
                                ${contratoFrete.ciot}/${contratoFrete.ciotCodVerificador}

                            </c:if>
                        </font>
                    </td>
                    <td align="center">
                        <c:if test="${usuario.filial.stUtilizacaoCfeS == 'D'}">
                            <c:if test="${contratoFrete.guidHeaderNdd != null && contratoFrete.guidHeaderNdd != '' && contratoFrete.ciot == 0}">
                                <img class="imagemLink" onclick="consultarProtocolo('${contratoFrete.id}')"
                                     alt="" title="Atualizar recibo" src="./img/atualiza.png">
                            </c:if>                            
                        </c:if>
                    </td>
                    <td align="center">
                        <c:if test="${usuario.filial.stUtilizacaoCfeS == 'D'}">
                            <c:if test="${contratoFrete.guidHeaderNdd != null && contratoFrete.guidHeaderNdd != '' && contratoFrete.ciot == 0}">
                                <img class="imagemLink" onclick="anularGUID('${contratoFrete.id}');"
                                     alt="" title="Remover GUID" src="./img/del_baixa.gif">
                            </c:if>                            
                        </c:if>
                    </td>
                    <td align="center">
                        <c:if test="${param.nivel == 4 && contratoFrete.ciot != 0 && usuario.filial.stUtilizacaoCfeS == 'R' && (!contratoFrete.isCancelada)}">
                            <a href="javascript: cancelar(${contratoFrete.id}, '${contratoFrete.id}', '${contratoFrete.ciot}/${contratoFrete.ciotCodVerificador}')">
                                <img alt="" class="imagemLink" src="img/cancelar.png" title="Cancelar CIOT" height="20" width="20"/>
                            </a>
                        </c:if>
                        <c:if test="${param.nivel == 4 && contratoFrete.ciot != 0 && usuario.filial.stUtilizacaoCfeS == 'E' && (!contratoFrete.isCancelada) && contratoFrete.statusCFe.msg != 'ENCERRADO'}">
                            <a href="javascript: cancelarEFrete(${contratoFrete.id}, '${contratoFrete.id}', '${contratoFrete.ciot}','${contratoFrete.ciotCodVerificador}')">
                                <img alt="" class="imagemLink" src="img/cancelar.png" title="Cancelar CIOT" height="20" width="20"/>
                            </a>
                        </c:if>
                        <c:if test="${param.nivel == 4 && contratoFrete.ciot != 0 && usuario.filial.stUtilizacaoCfeS == 'X' && (!contratoFrete.isCancelada)}">
                            <a href="javascript: cancelarExpeRS(${contratoFrete.id}, '${contratoFrete.id}', '${contratoFrete.ciot}','${contratoFrete.ciotCodVerificador}')">
                                <img alt="" class="imagemLink" src="img/cancelar.png" title="Cancelar CIOT" height="20" width="20"/>
                            </a>
                        </c:if>
                        <c:if test="${param.nivel == 4 && contratoFrete.ciot != 0 && usuario.filial.stUtilizacaoCfeS == 'G' && (!contratoFrete.isCancelada)}">
                            <a href="javascript: cancelarPagBem(${contratoFrete.id}, '${contratoFrete.id}', '${contratoFrete.ciot}','${contratoFrete.ciotCodVerificador}')">
                                <img alt="" class="imagemLink" src="img/cancelar.png" title="Cancelar CIOT" height="20" width="20"/>
                            </a>
                        </c:if>
                        <c:if test="${param.nivel == 4 && contratoFrete.ciot != 0 && usuario.filial.stUtilizacaoCfeS == 'A' && (!contratoFrete.isCancelada) && contratoFrete.statusCFe.msg != 'ENCERRADO'}">
                            <a href="javascript: encerrarTarget(${contratoFrete.id}, '${contratoFrete.ciot}', '${contratoFrete.isCancelada}')">
                                <img alt="" class="imagemLink" src="img/cancelar.png" title="Encerrar CIOT" height="20" width="20"/>
                            </a>
                        </c:if>
                    </td>

                    <td align="center">
                        
                        <c:choose>
                            <c:when test="${contratoFrete.ciot=='' || contratoFrete.ciot==null}"> 
                                
                            </c:when>
                            <c:when test="${param.nivel == 4 && contratoFrete.statusCFe.msg != 'FINALIZADO' && contratoFrete.tacAgregado == true && contratoFrete.baseTacAgregado == 0 && (contratoFrete.guidEncerramento==null || contratoFrete.guidEncerramento=='') && usuario.filial.stUtilizacaoCfeS == 'D' }"> 
                                 <a href="javascript: finalizarAgregado(${contratoFrete.id});">
                                    <img alt="" class="imagemLink" src="img/atencao.gif" title="Finalizar TAC agregado" height="20" width="20"/>
                                 </a>          
                            </c:when>
                            <c:when test="${(contratoFrete.guidEncerramento!=null || contratoFrete.guidEncerramento!='') && (contratoFrete.protocoloEncerramento==null || contratoFrete.protocoloEncerramento=='') &&  (contratoFrete.ciot!='' || contratoFrete.ciot!=null) && contratoFrete.tacAgregado == true && contratoFrete.baseTacAgregado == 0 && usuario.filial.stUtilizacaoCfeS == 'D'}"> 
                                 <img class="imagemLink" onclick="consultarProtocoloEncerramento('${contratoFrete.id}')" alt="" title="Consultar Encerramento" src="./img/atualiza.png">
                            </c:when>
                                 
                            <c:when test="${param.nivel == 4 && contratoFrete.ciot != 0 && usuario.filial.stUtilizacaoCfeS == 'E' && contratoFrete.statusCFe.msg != 'ENCERRADO' && (!contratoFrete.isCancelada) && contratoFrete.tacAgregado == true }"> 
                                 <a href="javascript: encerrarEFrete(${contratoFrete.id}, ${contratoFrete.ciot}, '${contratoFrete.isCancelada}');">
                                    <img alt="" class="imagemLink" src="img/atencao.gif" title="Encerrar CIOT" height="20" width="20"/>
                                 </a>          
                            </c:when>

                            <c:otherwise>
                                
                            </c:otherwise>
                        </c:choose>
                    </td>
                    
                    
                    <td align="center">
                        <c:if test="${param.nivel == 4 && contratoFrete.podeExcluir && contratoFrete.statusCFe.msg != 'FINALIZADO' }">
                            <a href="javascript: tryRequestToServer(function(){excluir(${contratoFrete.id});});">
                                <img alt="" class="imagemLink" src="img/lixo.png"/>
                            </a>
                        </c:if>
                    </td>
                    </font>
                </tr>

            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="90%" align="center" >
            <tr>
                <td width="30%">
                    <table width="100%">
                        <tr class="tabela">
                            <td colspan="2" align="center">Paginação</td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td width="50%" align="center">Ocorrências: <c:out value="${param.qtdResultados}"/></td>
                            <td width="50%" align="center">Páginas: <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td  align="center">
                                <form id="formularioAnt" name="formularioAnt" action="ContratoFreteControlador?acao=listar" method="post">
                                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                                    <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function() {
                                            document.formularioAnt.submit();
                                        });" value="ANTERIOR"/>
                                </form>
                            </td>
                            <td  align="center">
                                <form id="formularioProx" name="formularioProx"  action="ContratoFreteControlador?acao=listar" method="post">
                                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                                    <!--<input type="hidden" name="tipoFiltroStatus" value="us}'/>">-->
                                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                                    <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function() {
                                            document.formularioProx.submit();
                                        });" value="PROXIMA">
                                </form>
                            </td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td colspan="3"></td>
                        </tr>
                    </table>
                </td>
                <td width="35%" align="center">
                    <table width="100%">
                        <tr class="tabela">
                            <td colspan="2" align="center">Geração de CIOT</td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td width="50%" align="right"><div id="nddLbEnviaMotorista" name="nddLbEnviaMotorista">Ao transmitir, enviar dados do:</div></td>
                            <td width="50%" align="left">
                                <div id="nddEnviaMotorista" name="nddEnviaMotorista">
                                    <LABEL>
                                        <INPUT type="checkbox" id="motorista" name="motorista" checked/>                        
                                        Motorista
                                    </LABEL>
                                    <LABEL>
                                        <INPUT type="checkbox" id="proprietario" name="proprietario" checked/>
                                        Proprietário
                                    </LABEL>
                                </div>    
                            </td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td  align="center" colspan="2">
                                <form id="formularioCfe" name="formularioCfe" action="${usuario.filial.stUtilizacaoCfeS == 'P' ? "Pamcard" : 
                                                                                        usuario.filial.stUtilizacaoCfeS == 'T' ? "TicketFrete" : 
                                                                                        usuario.filial.stUtilizacaoCfeS == 'D' ? 'Ndd' :
                                                                                        usuario.filial.stUtilizacaoCfeS == 'E' ? "EFrete" :
                                                                                        usuario.filial.stUtilizacaoCfeS == 'X' ? "Expers" :
                                                                                        usuario.filial.stUtilizacaoCfeS == 'G' ? "PagBem" : 
                                                                                        usuario.filial.stUtilizacaoCfeS == 'A' ? "Target" : "Repom"}Controlador?acao=preContrato" target="pop">
                                    <input type="hidden" name="acao" id="acao" value="preContrato">
                                    <input type="hidden" name="isTac" id="isTac" value="false">
                                    <input type="hidden" name="idContratoFrete" id="idContratoFrete" value="0">
                                    <input type="hidden" name="isFilialTac" id="isFilialTac" value="0">
                                    <input type="hidden" name="isEnviarMotorista" id="isEnviarMotorista" value="true">
                                    <input type="hidden" name="isEnviarProprietario" id="isEnviarProprietario" value="true">
                                    <input type="hidden" name="stUtilizacaoCfeS" id="stUtilizacaoCfeS" value="${usuario.filial.stUtilizacaoCfeS}">
                                    <div id="divBotaoCiot" name="divBotaoCiot">
                                        <input type="button" id="botaoCIOT" name="botaoCIOT" onclick="return validaCfe()" value="${usuario.filial.stUtilizacaoCfeS == 'P' ? "GERAR CIOT (PAMCARD)" : 
                                                                                                   usuario.filial.stUtilizacaoCfeS == 'D' ? "GERAR CIOT (NDD CARGO)" : 
                                                                                                   usuario.filial.stUtilizacaoCfeS == 'E' ? "GERAR CIOT (EFRETE)" :
                                                                                                   usuario.filial.stUtilizacaoCfeS == 'X' ? "GERAR CIOT (EXPERS)" : 
                                                                                                   usuario.filial.stUtilizacaoCfeS == 'G' ? "GERAR CIOT (PAGBEM)" :
                                                                                                   usuario.filial.stUtilizacaoCfeS == 'A' ? "GERAR CIOT (TARGET)" : "GERAR CIOT (REPOM)"}" class="inputBotao">
                                       
                                    </div>
                                    <label id="lbCiotNao" name="lbCiotNao">Geração de CIOT não habilitada</label>
                                </form>
                            </td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td colspan="3"></td>
                        </tr>
                    </table>
                </td>
                <td width="35%" align="center">
                    <table width="100%">
                        <tr class="tabela">
                            <td colspan="3" align="center">Impressão de Contrato</td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td align="right" width="50%">Modelo:</td>
                            <td width="50%" colspan="2">
                                <div align="left">
                                    <select   name="modeloRelatorio" id="modeloRelatorio" class="inputtexto"  >
                                        <option value="1" ${configuracao.relDefaultCartaFrete == ("1")?"selected":""}>Modelo 1</option>
                                        <option value="2" ${configuracao.relDefaultCartaFrete == ("2")?"selected":""}>Modelo 2</option>
                                        <option value="3" ${configuracao.relDefaultCartaFrete == ("3")?"selected":""}>Modelo 3</option>
                                        <option value="4" ${configuracao.relDefaultCartaFrete == ("4")?"selected":""}>Modelo 4</option>
                                        <option value="5" ${configuracao.relDefaultCartaFrete == ("5")?"selected":""}>Modelo 5(Saldo)</option>
                                        <option value="6" ${configuracao.relDefaultCartaFrete == ("6")?"selected":""}>Modelo 6</option>
                                        <option value="7" ${configuracao.relDefaultCartaFrete == ("7")?"selected":""}>Modelo 7</option>
                                        <option value="8" ${configuracao.relDefaultCartaFrete == ("8")?"selected":""}>Modelo 8</option>
                                        <option value="9" ${configuracao.relDefaultCartaFrete == ("9")?"selected":""}>Modelo 9(Coleta)</option>
                                        <option value="10" ${configuracao.relDefaultCartaFrete == ("10")?"selected":""}>Modelo 10(Pamcard)</option>
                                        <option value="11" ${configuracao.relDefaultCartaFrete == ("11")?"selected":""}>Modelo 11 (NDD Cargo)</option>
                                        <option value="12" ${configuracao.relDefaultCartaFrete == ("12")?"selected":""}>Modelo 12 (Apenas para Manifesto(s))</option>
                                        <option value="13" ${configuracao.relDefaultCartaFrete == ("13")?"selected":""}>Modelo 13</option>
                                        <option value="14" ${configuracao.relDefaultCartaFrete == ("14")?"selected":""}>Modelo 14 (EFrete)</option>
                                        <option value="15" ${configuracao.relDefaultCartaFrete == ("15")?"selected":""}>Modelo 15 (TARGET - Web Service)</option>
                                        <option value="16" ${configuracao.relDefaultCartaFrete == ("16")?"selected":""}>Modelo 16 - Com extrato C/C</option>
                                        <option value="17" ${configuracao.relDefaultCartaFrete == ("17")?"selected":""}>Modelo 17 - Repom</option>
                                        <% for (String rel : Apoio.listCartaFrete(request)) {%>

                                        <option value="doc_cartafrete_personalizado_<%=rel.toUpperCase()%>" <%=configuracao.getRelDefaultCartaFrete().startsWith("doc_cartafrete_personalizado_") ? "selected" : ""%> > Modelo <%=rel.toUpperCase()%> (Personalizado)</option>


                                        <%}%>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        
                        <tr class="CelulaZebra1">
                            <td width="15%"><div align="right">Impressora:    </div></td>
                            <td width="18%" colspan="2"><div align="left"><span class="CelulaZebra2">
                                        <select name="caminho_impressora" id="caminho_impressora" class="inputtexto">
                                            <option value="">&nbsp;&nbsp;</option>
                                            <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                                                impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                                                impressoras.setLimiteResultados(50);
                                                if (impressoras.Consultar()) {
                                                    ResultSet rs = impressoras.getResultado();
                while (rs.next()) {%>
                                            <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora()) ? "selected" : "")%>><%=rs.getString("descricao")%></option>
                                            <%}%>
                                            <%}%>
                                        </select>
                                    </span>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra1">
                            <td width="14%"><div align="right">Driver:</div></td>
                            <td width="19%"><div align="left"><span class="CelulaZebra2">
                                        <select name="driverImpressora" id="driverImpressora" class="inputtexto">
                                            <%                Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "caf.txt");
                                                for (int i = 0; i < drivers.size(); ++i) {
                                                    String driv = (String) drivers.get(i);
                  driv = driv.substring(0, driv.lastIndexOf("."));%>
                                            <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                                            <%}
                                                Vector driversChq = Apoio.listFiles(Apoio.getDirDrivers(request), "chq.txt");
                                                for (int x = 0; x < driversChq.size(); ++x) {
                                                    String driv = (String) driversChq.get(x);
                                                    driv = driv.substring(0, driv.lastIndexOf("."));
                                            %>
                                            <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                                            <%}%>
                                        </select>
                                    </span></div></td>
                                    <td width="8%"><img src="img/ctrc.gif" class="imagemLink" width="20px" title="Imprimir Cartas-frete selecionadas" onClick="printMatricideCartaFrete()"></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
</html>


