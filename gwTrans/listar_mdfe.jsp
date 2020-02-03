<%-- 
    Document   : listar_mdfe
    Created on : 12/11/2013, 13:58:59
    Author     : gleidson
--%>

<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html; charset=iso-8859-1"%>
<%@taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="pt-BR" />
<%
    request.setAttribute("versao", Apoio.WEBTRANS_VERSION);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Manifesto Eletronico (MDF-e)</title>

        <link rel="stylesheet" href="${homePath}/estilo.css?v=${random.nextInt()}">

        <script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/beans/nota_fiscal-util.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <script type="text/javascript" src="${homePath}/script/jQuery/jquery-ui.js?v=${random.nextInt()}"></script>
        <script type="text/javascript" language="JavaScript">
            var homePath = '${homePath}';
            let certificadoAtualizado = '${configTecnica.certificadoAtualizadoEm != null}';
        jQuery.noConflict();
        
            function Campos(campoConsulta ,valorConsulta ,operadorConsulta ,dtInicial ,dtFinal ,status ,limiteResultados ,motor_nome ,idmotorista ,idveiculo ,vei_placa ,statusMDFe ,filial ,numeroPedido ,meuscts, rotaId){
                this.campoConsulta = (campoConsulta == null || campoConsulta == undefined ? $("campoConsulta").value : campoConsulta);
                this.valorConsulta = (valorConsulta == null || valorConsulta == undefined ? $("valorConsulta").value : valorConsulta);
                this.operadorConsulta = (operadorConsulta == null || operadorConsulta == undefined ? $("operadorConsulta").value : operadorConsulta);
                this.dtInicial = (dtInicial == null || dtInicial == undefined ? $("dtInicial").value : dtInicial);
                this.dtFinal = (dtFinal == null || dtFinal == undefined ? $("dtFinal").value : dtFinal);
                this.status = (status == null || status == undefined ? $("status").value : status);
                this.limiteResultados = (limiteResultados == null || limiteResultados == undefined ? $("limiteResultados").value : limiteResultados);
                this.motor_nome = (motor_nome == null || motor_nome == undefined ? $("motor_nome").value : motor_nome);
                this.idmotorista = (idmotorista == null || idmotorista == undefined ? $("idmotorista").value : idmotorista);
                this.idveiculo = (idveiculo == null || idveiculo == undefined ? $("idveiculo").value : idveiculo);
                this.vei_placa = (vei_placa == null || vei_placa == undefined ? $("vei_placa").value : vei_placa);
                this.statusMDFe = (statusMDFe == null || statusMDFe == undefined ? $("statusMDFe").value : statusMDFe);
                this.filial = (filial == null || filial == undefined ? $("filial").value : filial);
                this.numeroPedido = (numeroPedido == null || numeroPedido == undefined ? $("numeroPedido").value : numeroPedido);
                this.meuscts = (meuscts == null || meuscts == undefined ? $("meuscts").checked : meuscts);
                this.rotaId = (rotaId == null || rotaId == undefined ? $("rota_id").value: rotaId);
                
                this.toParams = function(){
                    try{
                        return "&campoConsulta="+this.campoConsulta
                        +"&valorConsulta="+this.valorConsulta
                        +"&operadorConsulta="+this.operadorConsulta
                        +"&dtInicial="+this.dtInicial
                        +"&dtFinal="+this.dtFinal
                        +"&status="+this.status
                        +"&statusMDFe="+this.statusMDFe
                        +"&limiteResultados="+this.limiteResultados
                        +"&motor_nome="+this.motor_nome
                        +"&idmotorista="+this.idmotorista
                        +"&idveiculo="+this.idveiculo
                        +"&vei_placa="+this.vei_placa
                        +"&filial="+this.filial
                        +"&numeroPedido="+this.numeroPedido
                        +"&meuscts="+this.meuscts;
                        +"&rota="+this.rotaId;;
                    }catch(e){
                        alert(e);
                    }
                };
            }

            function setDefault(){
               
                document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';
                document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
                var campoConsulta = '<c:out value="${param.campoConsulta}"/>';
                document.formulario.campoConsulta.value = campoConsulta;
                document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
                document.formulario.dtInicial.value = '<c:out value="${param.dataDe}"/>';
                document.formulario.dtFinal.value = '<c:out value="${param.dataAte}"/>';
                document.formulario.status.value = '<c:out value="${param.status}"/>';
                document.formulario.statusMDFe.value = '<c:out value="${param.statusMDFe}"/>';
                document.formulario.filial.value= '<c:out value="${param.filial}"/>';
                document.formulario.numeroPedido.value= '<c:out value="${param.numeroPedido}"/>';
                document.formulario.rota_id.value= '<c:out value="${param.rotaID}"/>';
                document.formulario.rota_desc.value= '<c:out value="${param.rotaDesc}"/>';
                
                if ($('modelo') != undefined) {
                    $('modelo').value = '<c:out value="${param.modeloMdfe}"/>';
                }
                                
                if('<c:out value="${param.meuscts}"/>' =='true'){
                    document.formulario.meuscts.checked = 'true';
                }
                if('<c:out value="${param.impresso}"/>' =='true'){
                    document.formulario.impresso.checked = 'true';
                }
                
                //formulario.filial.disabled = "{param.statusNfe =="L" || param.statusNfe == "C" ? "" : ""}";
               
            
                if(campoConsulta == 'm.dt_emissao'){
                    habilitaConsultaDePeriodo(true, '<c:out value="${param.dataDe}"/>', '<c:out value="${param.dataAte}"/>');
                }
                
                if($("status").value == "L"){   
                    for (var i = 1; getObj("mdfe_" + i) != null; ++i){
                        document.getElementById("numero_"+i).style.color = "red";
                        document.getElementById("cidadeUfOrig_"+i).style.color = "red";
                        document.getElementById("cidadeUfDest_"+i).style.color = "red";
                        document.getElementById("abrevFilial_"+i).style.color = "red";
                        document.getElementById("abrevFilialDest_"+i).style.color = "red";
                        document.getElementById("nome_"+i).style.color = "red";
                        document.getElementById("dtlancamento_"+i).style.color = "red";
                    }
                }

                if($("status").value == "C"){
                    document.getElementById('statusMDFe').style.display = '';
                }
                
                if($("statusMDFe").value != ""){
                    document.getElementById("statusMDFe").value = "${param.statusMDFe}";    
                }
                
            }
            
            function pesq(){
                $("formulario").action = "MDFeControlador?acao=listarMDFe";
                $("formulario").target = "";
                $("formulario").submit();
                
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

                for(var i = 0; i <= $("max").value; i++){
                    if(document.getElementById("pdf_"+i) != null){
                        document.getElementById("pdf_"+i).style.display = "none";
                        document.getElementById("excel_"+i).style.display = "none";
                        document.getElementById("ie_"+i).style.display = "none";
                        document.getElementById("word_"+i).style.display = "none";

                        document.getElementById(img+i).style.display = "";
                    }
                }
            }
        
            function marcarTodos(){
                var i=1;
                while($("mdfe_"+i)!=null){
                    if($("ckTodos").checked == true){
                        $("mdfe_"+i).checked = true;
                    }else{
                        $("mdfe_"+i).checked = false;
                    }
                    i++;
                }
            }
            
            
            function habilitaConsultaDePeriodo(opcao, data1, data2){   
                
                if(opcao){
                    document.getElementById("valorConsulta").style.display = "none"; //= (opcao ? "none" : "");
                    document.getElementById("operadorConsulta").style.display = "none"; //(opcao ? "none" : "");
                    document.getElementById("div1").style.display = "";
                    document.getElementById("div2").style.display= "";
                    
                    if(data1==undefined && data2==undefined){
                        document.getElementById("dtInicial").value = "<%=Apoio.getDataAtual()%>";
                        document.getElementById("dtFinal").value = "<%=Apoio.getDataAtual()%>";
                    }else{
                        document.getElementById("dtInicial").value = data1;
                        document.getElementById("dtFinal").value = data2;
                    }
                    
                }else{
                    document.getElementById("valorConsulta").style.display = ""; //= (opcao ? "none" : "");
                    document.getElementById("operadorConsulta").style.display = "" //(opcao ? "none" : "");
                    document.getElementById("div1").style.display = "none";
                    document.getElementById("div2").style.display= "none";
               
                }
            }
            
            //metodo para consultar a chave de acesso.
            function submeterConsulta(chaveConsulta){
                if (certificadoAtualizado === 'false') {
                    chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                    return;
                }

                /*abrirMax('about:blank', 'popConsultaCompleta')
                $("chaveConsulta").value = chaveConsulta; 
                $("formConsulta").submit();*/
                var pop = window.open('about:blank', 'pop', 'width=400, height=200');
                var formu = $("formulario");
                formu.action = 'MDFeControlador?acao=consultarChaveAcesso&chaveConsulta='+ chaveConsulta;
                formu.submit();
            }//fim do metodo submeterConsulta

            function getCamposConsulta(){
                
            }

            //funcao para consultar o protocolo..
            function consultarProtocolo(idManifesto){
                if (certificadoAtualizado === 'false') {
                    chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                    return;
                }

                var camposConsulta = new Campos();
                
                console.log("camposConsulta="+camposConsulta.toParams());
                
                if(confirm("ATENÇÃO!\r\n A rotina de atualização de protocolo, deve ser usada apenas em \r\n"     
                    +  "casos onde o MDF-e encontre-se devidamente confirmado e em divergência de 'Status' com o sistema webtrans.\r\n"
                    +  "O uso incorreto poderá danificar a assinatura do xml.\r\n" +
                    "Deseja continuar?")){
                    if(confirm("Tem certeza?")){
                        window.open("./MDFeControlador?acao=consultarProtocolo&idManifesto="+ idManifesto
                        +camposConsulta.toParams()
                        , idManifesto + "consultaProtocolo", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                    }//se confirmado, chama o controlador para consultar o protocolo passando o idManifesto
                }            
            }//fim do metodo consultarProtocolo
            
            //metodo para impressao do XML
            function ImprimirXML(idManifesto, chaveAcesso, status){
                if (idManifesto == null)
                    return null;
                window.open("./"+chaveAcesso+"-mdfe.xml?acao=gerarXmlMDFe&idmanifesto=" + idManifesto+"&status=" + status, "xmlMDFe" +idManifesto, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
            }//fim do metodo ImprimirXML
            
            function desligarManifesto(idManifesto){
                chamarConfirm('ATENÇÃO: Você escolheu a opção de encerrar o MDF-e. Após encerrar o MDF-e não poderá cancelá-lo posteriormente caso precise. Você realmente quer ENCERRAR O MANIFESTO?','executarDesligarManifesto('+idManifesto+')','',1);
            }
            //funcao de desligar o manifesto
            function executarDesligarManifesto(idManifesto){
                    var pop = window.open('about:blank', 'pop', 'width=400, height=200');
                    var formu = $("formulario");
                    formu.action = 'MDFeControlador?acao=desligarManifesto&idManifesto='+idManifesto;
                    formu.submit();            
            }//fim da funcao desligarManifesto
            
            function atualizarRecibo(idManifesto, numeroRecibo){
                if (certificadoAtualizado === 'false') {
                    chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                    return;
                }

                var pop = window.open('about:blank', 'pop', 'width=400, height=200');
                var formu = $("formulario");
                formu.action = 'MDFeControlador?acao=atualizarRecibo&idManifesto='+idManifesto+"&numeroRecibo="+numeroRecibo;
                formu.submit();
            
            }//fim da funcao desligarManifesto
            
            
            function encerrarManifesto(){
                if (certificadoAtualizado === 'false') {
                    chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                    return;
                }

                if (confirm("Deseja encerrar esse MDF-e?")){
                    window.open("MDFeControlador?acao=novoEncerramento",'','height=600,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1');
                }
            }
    
            function enviar(){
                if (certificadoAtualizado === 'false') {
                    chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                    return;
                }

                $("botaoEnviar").disabled = true;            
                $("botaoEnviar").value = " ENVIANDO... ";            
            
                var manifesto = jQuery("input[id^='mdfe_']:checked").val();
                
                if(manifesto==undefined && manifesto==""){
                    $("botaoEnviar").disabled = false;            
                    $("botaoEnviar").value = "ENVIAR";            
                    return alert("Selecione ao menos um Manifesto!");
                }
                var manifestoFilhos = null;
                var idsChecados = jQuery("input[id^='mdfe_']:checked").attr('id');
                console.log("idsChecados="+idsChecados);
                if (idsChecados != null) {
                    manifestoFilhos = jQuery("#idsFilhos_"+idsChecados.substring(5));
                    var pop = window.open('about:blank', 'pop', 'width=400, height=200');
                    var formu = $("formulario");
                    formu.action = 'MDFeControlador?acao=enviar&idManifesto=' + manifesto + "&idFilhos=";
                    formu.submit();
                } else {
                    $("botaoEnviar").disabled = false;            
                    $("botaoEnviar").value = "ENVIAR";            
                    return alert("Selecione ao menos um Manifesto!");
                }
            }
            
        function cancelar(numero,id){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            if(confirm("Deseja cancelar o MDF-e '" + numero + "'?" )){
                var textoCancelamento = prompt("Qual o motivo do cancelamento?" ,"");

                if(textoCancelamento != null){
                    if(confirm("Deseja cancelar o MDF-e?")){
                        if(confirm("Tem certeza?")){
                            window.open("./MDFeControlador?acao=cancelar&idManifesto=" + id + "&motivo="+textoCancelamento , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
                        }
                    }
                }
            }
        }//fim do metodo cancelar
            
        function popManifesto(id, isContingencia){
           
            var modelo;
            if(isContingencia == true){
               modelo = "Contingencia";
            }else{
               modelo = $("modelo").value;
            }
           
         
           
            try {
                var idM = "";
                if (id == "" || id == null){
                   for (var i = 1; getObj("mdfe_" + i) != null; ++i){
                        if (getObj("mdfe_" + i).checked){
                            idM += ",'" + getObj("impTudo_" + i).value + "'";
                        }
                        id = idM.substr(1);
                    }
                    var wName = 'DAMDFE';
                }
                if (id !="") {
                   launchPDF('MDFeControlador?acao=imprimirDamdfe&modelo='+modelo+'&idManifestos=' + id, wName);
                   atualizarImpressaoMDFe(id);
                }
            } catch (e) {
                alert(e);
            }
        }//fim do metodo popManifesto
        
        //  function atualizarImpressaoMDFe(idManifesto){                
        //          var formu = $("formulario");
        //          formu.action = 'MDFeControlador?acao=atualizarImpressaoMDFe&idManifesto='+idManifesto;
        //          formu.submit();            
        // }//fim da funcao atualizarImpressaoMDFe
            
        function atualizarImpressaoMDFe(id){
            espereEnviar("",true);
            new Ajax.Request("MDFeControlador?acao=atualizarImpressaoMDFe&idManifesto="+ id,{
                method:"get",
                onSuccess: function(transport){
                    espereEnviar("",false);
                    
                    //alert(textResposta.responseJSON);
                },
                onFailure: function(){}
            });
        }
        
        function editarManifesto(idmanifesto, podeexcluir){
            launchPopupLocate("./cadmanifesto?acao=editar&id="+idmanifesto+(podeexcluir != null ? "&ex="+podeexcluir : ""));
            
        }
        
        
        function consultaNaoEnc(){
                window.open("MDFeControlador?acao=consultarMDFeNaoEnc", 'pop','location=1,status=1,width=1000,height=600');
            }
            
        function alterarStatus(){
            if($("status").value=="C"){
                $("divImpressos").style.display = "";
            }else{
                $("divImpressos").style.display = "none";
                $("impresso").checked = false;
            }
        }
        
      
        function visualizarImagemSolucao(nomeImagem, idMDFe){
            console.log("chegou aqui");
            var imagem = 'img/solucao_mdfe/';
            console.log("imagem: "+imagem.trim()+nomeImagem.trim());
            window.open("./ImagemControlador?acao=imgpdf&imagem=" + imagem.trim()+nomeImagem.trim()+ "&idmanifesto="+idMDFe, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
        
        function getVariosMdef(){
           
        var idManifesto = "0";
        var manifesto =  "0";
            for (var i = 1; getObj("mdfe_" + i) != null; ++i){

               if (getObj("mdfe_" + i).checked && getObj("mdfe_averbado_" + i).value === 'true'){
                   manifesto = manifesto  + ',' +  getObj("mdfe_" + i).value;
               }  
            }
            idManifesto = manifesto.replace("0,","");

            if(manifesto == "0"){
                alert("Selecione pelo menos um Nº Manifesto!");
            }
            console.log("getVariosMdef : " + manifesto);
            
             confirmVariosDAMDFe(idManifesto,false);
         }
        
        function compareDate(dataInicio,dataFim){
            var nova_dataIncio = parseInt(dataInicio.split("-")[2].toString() + dataInicio.split("-")[1].toString() + dataInicio.split("-")[0].toString());
            var nova_dataFim = parseInt(dataFim.split("-")[2].toString() + dataFim.split("-")[1].toString() + dataFim.split("-")[0].toString());
             if (nova_dataFim > nova_dataIncio)
              return false;
             else if (nova_dataIncio == nova_dataFim)
              return true;
             else
              return true;
        }
        
        function confirmDAMDFe2(idManifesto, isContingencia){
            var isUsaGenRisco = "";
            var tipoBloqMonitoramento = "";
            var isConfirmadoGen = "";
            var max = $("limiteResultados").value;
            var dataUsoGoldenService = "";
            var dataDoManifesto = "";
                for(var i = 1 ; i<= max ; i++){
                
                    if ($("mdfe_"+i).value != null && ($("mdfe_"+i).value == idManifesto)){
                        
                        isUsaGenRisco = ($("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value == null ? "0" 
                                                        : $("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value);
                                                        
                        tipoBloqMonitoramento = ($("tipoBloqueioMonitoramento_"+i).value == null ? "" : $("tipoBloqueioMonitoramento_"+i).value);
                        isConfirmadoGen = ($("protocoloGerenciamentoRisco_"+i).value == null ? "" : $("protocoloGerenciamentoRisco_"+i).value );
                        dataUsoGoldenService = $("dataUsoGoldenService_"+i).value;
                        dataDoManifesto = $("dataLancamento_"+i).value;

                if(isUsaGenRisco != '0'){    
                    if(compareDate(dataDoManifesto,dataUsoGoldenService)){
                         if(tipoBloqMonitoramento == '1'){
                            if(confirm("Deseja imprimir DAMDF-e ? "))
                                        popManifesto(idManifesto);  
                                    break;
                                } else if (isConfirmadoGen == "") {
                                    alert("O(s) manifesto(s) " + $("nmanifesto_" + i).value + " não está(ão) confirmado(s) na Gerenciadora de Risco");
                                    break;
                                } else {
                                    popManifesto(idManifesto, isContingencia);
                                    break;
                                }
                            } else {
                                popManifesto(idManifesto, isContingencia);
                                break;
                            }
                        } else {
                            popManifesto(idManifesto, isContingencia);
                            break;
                        }
                    }
                }
            }


        function confirmVariosDAMDFe(idManifesto, isContingencia) {
            var isUsaGenRisco = "";
            var tipoBloqMonitoramento = "";
            var isConfirmadoGen = "";
            var nmanifesto = "";
            var dataUsoGoldenService = "";
            var dataDoManifesto = "";
            var ids = idManifesto;
            var idsliberados = "";
            var idsbloqueados = "";
            var idsTipoA = 0;
            
            for (var i = 1; $("mdfe_"+i) != null; i++) {
                isUsaGenRisco = ($("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value == null ? "" : $("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value);
                isUsaGenRisco = ($("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value == null ? "" : $("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value);
                tipoBloqMonitoramento =($("tipoBloqueioMonitoramento_"+i).value == null ? "" : $("tipoBloqueioMonitoramento_"+i).value);
                nmanifesto = $("nmanifesto_" + i).value;
                isConfirmadoGen = ($("protocoloGerenciamentoRisco_"+i).value == null ? "" : $("protocoloGerenciamentoRisco_"+i).value );
                dataUsoGoldenService = $("dataUsoGoldenService_"+i).value;
                dataDoManifesto = $("dataLancamento_"+i).value;
                
                if (isUsaGenRisco == "0") {
                    for (var j = 1; j <= ids.split(",").length; j++) {
                        if ($("mdfe_"+i).value == ids.split(",")[j-1]) {
                            if(ids.split(",")[j-1]){
                                if (idsliberados == "") {
    //                                idsliberados += ids.split(",")[i-1];
                                    idsliberados += ids.split(",")[j-1];
                                } else {
    //                                idsliberados += "," + ids.split(",")[i-1];
                                        idsliberados += "," + ids.split(",")[j - 1];
                                    }
                                }
                            }
                        }
                    } else {
                        if (ids.split(",")[i - 1]) {
                            if (isUsaGenRisco != "0") {
                                if (tipoBloqMonitoramento == "1") {
                                    idsTipoA++;
                                }
                                if (compareDate(dataDoManifesto, dataUsoGoldenService)) {
                                    if (tipoBloqMonitoramento == "2") {

                                        if (isConfirmadoGen != "") {
                                            if (idsliberados == "") {
                                                idsliberados += ids.split(",")[i - 1];
                                            } else {
                                                idsliberados += "," + ids.split(",")[i - 1];
                                            }
                                        } else {
                                            if (idsbloqueados == "") {
                                                idsbloqueados += nmanifesto;

                                            } else {
                                                idsbloqueados += "," + nmanifesto;

                                            }
                                        }
                                    } else {
                                        if (idsliberados == "") {
                                            idsliberados += ids.split(",")[i - 1];
                                        } else {
                                            idsliberados += "," + ids.split(",")[i - 1];

                                        }
                                    }

                                } else {
                                    if (idsliberados == "") {
                                        idsliberados += ids.split(",")[i - 1];
                                    } else {
                                        idsliberados += "," + ids.split(",")[i - 1];
                                    }
                                }

                            }
                        }
                    }
                }

//            for (var i = 1; i <= ids.split(",").length; i++) {
//                    
//                    if ($("mdfe_"+i).value != null && $("mdfe_"+i).checked && $("mdfe_"+i).value == ids.split(",")[i-1]) {
//                 
//                    isUsaGenRisco = ($("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value == null ? "" : $("tipoUtilizacaoGerenciadoraRiscoGoldenService_"+i).value);
//                    
//                    tipoBloqMonitoramento =($("tipoBloqueioMonitoramento_"+i).value == null ? "" : $("tipoBloqueioMonitoramento_"+i).value);
//
//                    nmanifesto = $("nmanifesto_" + i).value;
//                    isConfirmadoGen = ($("protocoloGerenciamentoRisco_"+i).value == null ? "" : $("protocoloGerenciamentoRisco_"+i).value );
//                    dataUsoGoldenService = $("dataUsoGoldenService_"+i).value;
//                    dataDoManifesto = $("dataLancamento_"+i).value;
//                    
//                    if (isUsaGenRisco != "0") {
//                        if (tipoBloqMonitoramento == "1") {
//                            idsTipoA++;
//                        }
//                        if (compareDate(dataDoManifesto, dataUsoGoldenService)) {
//                            if (tipoBloqMonitoramento == "2") {
//                                
//                                if (isConfirmadoGen != "") {
//                                    if (idsliberados == "") {
//                                        idsliberados += ids.split(",")[i-1];
//                                    } else {
//                                        idsliberados += "," + ids.split(",")[i-1];
//                                    }
//                                } else {
//                                    if (idsbloqueados == "") {
//                                        idsbloqueados += nmanifesto;
//
//                                    } else {
//                                        idsbloqueados += "," + nmanifesto;
//
//                                    }
//                                }
//                            } else {
//                                if (idsliberados == "") {
//                                    idsliberados += ids.split(",")[i-1];
//                                } else {
//                                    idsliberados += "," + ids.split(",")[i-1];
//
//                                }
//                            }
//
//                        } else {
//                            if (idsliberados == "") {
//                                idsliberados += ids.split(",")[i-1];
//                            } else {
//                                idsliberados += "," + ids.split(",")[i-1];
//                            }
//                        }
//
//                    } else {
//                        
//                        if (idsliberados == "") {
//                            idsliberados += ids.split(",")[i-1];
//                        } else {
//                            idsliberados += "," + ids.split(",")[i-1];
//                        }
//                    }
//                }else{
//                    break;
//                }
//            }

                if (idsbloqueados != 0) {
                    alert(" O(s) manifesto(s): " + idsbloqueados + " não " + (idsbloqueados.split().length > 1 ? "possui" : "possuem") + " protocolo de confirmação na Gerenciadora de Risco");
                }

                if (idsliberados != 0) {
                    if (idsTipoA != 0) {
                        if (confirm("Deseja imprimir os relatórios? ")) {
                            popManifesto(idsliberados, isContingencia);
                        }
                    } else {
                        popManifesto(idsliberados, isContingencia);
                    }
                }
            }
    
        function limpaRota(){
            $("rota_id").value = "";
            $("rota_desc").value = "";
        }

        function enviarEmail(idmanifesto, status, isContingencia){
            if (idmanifesto === null || status === null) {
               return null;
            }
            
            var aux;
            var modelodanf;
            
            if(isContingencia == true){
                modelodanf = "Contingencia";
            }else{
                aux = $("modelo").value;
                if (aux.indexOf("personalizado_") > -1) {
                    modelodanf = aux;
                }else{
                    modelodanf = "1";
                }
            }
            window.open("./MDFeControlador?acao=enviarEmail&idManifesto=" + idmanifesto + "&status=" + status + "&modelodanf=" + modelodanf, 'popEmail','location=1,status=1,width=1000,height=600');
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
    </head>
    <body onLoad="setDefault();applyFormatter();alterarStatus();">
        <img src="img/banner.gif"  alt="">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="80%" align="left" >
                    
                    <span class="style4">&nbsp;Webtrans - Manifesto Eletronico (MDF-e ${(param.utilizacaoMDFe == "H" ? "Homologação" : "Produção")}) - Versão ${param.versaoMDFe}</span>
                </td>
                <td align="right" width="10%">
                    <input name="encerrarManifesto" type="button" class="botoes" id="encerrarManifesto"  value="Encerrar MDFe" onClick="tryRequestToServer(function(){encerrarManifesto()});">
                </td>
                
                <td width="20%">
                        <div align="center">
                            <input name="consultar" type="button" class="inputbotao" value="Consultar MDF-e(s) não encerrado(s)" onclick="javascript: tryRequestToServer(function(){consultaNaoEnc();})"  />
                        </div>
                </td>
            </tr>
        </table>
        <br>
        <form action="MDFeControlador?acao=listarMDFe" id="formulario" target="pop" name="formulario" method="post">
            <table class="bordaFina" width="90%" align="center">
                <tr>
                    <td width="15%" class="CelulaZebra1">

                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onChange="javascript:habilitaConsultaDePeriodo(this.value=='m.dt_emissao');">
                            <option value="m.nmanifesto">Manifesto</option>   
                            <option selected="" value="m.dt_emissao">Lançamento</option>   
                            <option value="m.chave_acesso_mdfe">Chave MDFe</option>   
                        </select>
                    </td>
                    <td width="25%" class="CelulaZebra1" height="20">

                        <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                        <div id="div1" style="display:none ">
                            De:<input name="dtInicial" type="text" id="dtInicial" size="10" maxlength="10" value="<%=Apoio.getDataAtual()%>" class="fieldDate" onBlur="alertInvalidDate(this)">
                        </div>

                    </td>
                    <td width="25%" class="CelulaZebra1">
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25">
                        <div id="div2" style="display:none ">Para:
                            <input name="dtFinal" type="text" id="dtFinal" size="10" maxlength="10" value="<%=Apoio.getDataAtual()%>" class="fieldDate" onBlur="alertInvalidDate(this)" >
                        </div>
                    </td>
                    <td width="20%" class="CelulaZebra1">Status MDF-e: 
                        <select name="status" id="status" class="inputtexto" onchange="javascript: tryRequestToServer(function(){alterarStatus();pesq();})">
                            <option value="P" selected>Pendente</option>
                            <option value="C">Confirmado</option>
                            <option value="E">Enviado</option>
                            <option value="N">Negado</option>
                            <option value="L">Cancelado</option>
                        </select>
                    </td>
                    <td width="15%" class="CelulaZebra1">
                        <select id="limiteResultados"  name="limiteResultados" class="inputtexto" >
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                    <td width="20%" rowspan="2" class="CelulaZebra1">
                        <div align="center">
                            <input name="pesquisar" type="button" class="inputbotao" value="Pesquisar" onclick="javascript: tryRequestToServer(function(){pesq();})"  />


                        </div>
                    </td>
                </tr>
                <tr class="celula" style="text-align: right" name="trMDFe">
                    <td width="7%">Motorista:</td>
                    <td width="15%">
                        <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" size="20" readonly="true" value="${param.motorista}">
                        <input name="localiza_rem3" type="button" class="botoes" id="localiza_rem3" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=10', 'Motorista');;">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';getObj('motor_nome').value = '';">
                        <input type="hidden" name="idmotorista" id="idmotorista" value="${param.motoristaId}">
                    </td>
                    <td width="6%" >Veículo:</td>
                    <td width="15%">
                        <input type="hidden" name="idveiculo"   id="idveiculo" value="${param.veiculoId}">
                        <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" size="10" readonly="true" value="${param.veiculo}">
                        <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=7','Veículo','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idveiculo').value = '0';getObj('vei_placa').value = '';"/>
                    </td>
                    <td width="15%" class="CelulaZebra1" name="tdStatusMDFe" id="tdStatusMDFe">
                        <select   name="statusMDFe" id="statusMDFe" class="inputtexto"  style="display: none">
                            <option value="T">Mostrar Tudo</option>
                            <option value="R">Apenas Encerrados</option>
                            <option value="C">Apenas Não Encerrados</option>
                        </select>
                    </td>
                </tr>
                <tr class="celula" style="text-align: right" >
                     <td class="celula">Filial:                        
                          <select  name="filial" id="filial" class="inputtexto" >
                              <option value="0">Todas</option>
                            <c:forEach var="filial" items="${filiais}">
                                <option value="${filial.idfilial}">${filial.abreviatura}</option>
                            </c:forEach>
                          </select>                         
                    </td>    
                    <td class="celula">N° Pedido:
                          <input name="numeroPedido" id="numeroPedido" type="text" class="inputtexto"/>
                                             
                    </td>    
                      
                    <td class="celula" colspan="1">                       
                        <div align="left">                            
                            <input name="meuscts" type="checkbox" id="meuscts"  value="checkbox">
                            <span class="style8">Mostrar MDF-e(s) Criados Por Mim</span>
                        </div>               
                    </td>                   
                   
                    <td class="celula">
                        <div align="left" id="divImpressos">
                            <input name="impresso" type="checkbox" id="impresso" >
                            <span class="style8">Mostrar apenas n&atilde;o impressos.</span>                            
                        </div>              
                    </td>    
                    <td class="celula">    
                    </td>              
                    <td class="celula">                   
                    </td>
                   <tr class="celula" style="text-align: right" >
                    <td align="right">Apenas a rota: </td>
                            <td align="left">
                                <input type="text" class="inputReadOnly8pt" id="rota_desc" name="rota_desc" value="${param.rotaDesc}"/>
                                <input type="hidden" id="rota_id" name="rota_id" value="${param.rotaID}" />
                                <input name="localiza_rota" type="button" class="botoes" id="localiza_rota" value="..." 
                                       onclick="javascript:tryRequestToServer(function(){window.open('./localiza?acao=consultar&idlista=63', 'Rota', 'top=80,left=150,height=600,width=800,resizable=yes,status=1,scrollbars=1');});" />
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaRota()">
                            </td>
                            <td></td>
                            <td colspan="3"></td>
                </tr>
                               
                </tr>
            </table>
            <table class="bordaFina" width="90%" align="center">
                <tr>             
                    <td class="tabela" width="1%" align="left">
                    <c:if test="${param.status == 'C' || param.status == 'R'}" >
                    <input name="ckTodos" type="checkbox" value="1" id="ckTodos" onClick="marcarTodos()">
                    </c:if>
                    </td>
                    <td class="tabela" width="3%" align="left" name="tdImpTudo" id="tdImpTudo">
                        <c:if test="${param.status == 'C' || param.status == 'R' }" >
                             <img src="img/pdf.jpg" width="19" height="19" border="0" id="img_imprimir" class="imagemLink" title="Imprimir todos os DAMDFE's selecionados"
                                  onClick="javascript:tryRequestToServer(function(){getVariosMdef('${mdfe.beanManifesto.idmanifesto}', false);});">
                        </c:if>
                    </td>
                    <td class="tabela" width="3%" align="left"></td>
                    <td class="tabela" width="4%" align="left">MANIFESTO</td>
                    <td class="tabela" width="14%" align="left">PROTOCOLO</td>
                    <td class="tabela" width="18%" align="left">CIDADE ORIGEM</td>
                    <td class="tabela" width="18%" align="left">CIDADE DESTINO</td>
                    <td class="tabela" width="7%" align="left">FILIAL ORIGEM</td>
                    <td class="tabela" width="7%" align="left">FILIAL DESTINO</td>
                    <td class="tabela" width="18%" align="left">MOTORISTA</td> 
                    <td class="tabela" width="4%" align="left">LANÇAMENTO</td>
                    <td class="tabela" width="3%" align="left"></td>
                </tr>

                <c:forEach var="mdfe" varStatus="status" items="${listaMDFe}">  
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                        <td>
                            <c:if test="${param.status == 'C' || param.status == 'R'}" >
                            <input type="checkbox" id="mdfe_${status.count}" name="mdfe_${status.count}" value="${mdfe.beanManifesto.idmanifesto}" >
                             </c:if>
                            <c:if test="${param.status != 'C' && param.status != 'R'}" >
                            <input type="radio" id="mdfe_${status.count}" name="mdfe" value="${mdfe.beanManifesto.idmanifesto}" >
                            </c:if>

                            <input type="hidden" id="mdfe_averbado_${status.count}" name="mdfe_averbado_${status.count}" value="${mdfe.imprimirAverbacao}">
                        </td>
                        <td>
                            <c:if test="${(param.status == 'C' || param.status == 'R' || param.utilizacaoMDFe =='C') and mdfe.imprimirAverbacao}" >
                                <img src="img/pdf.jpg" width="19" height="19" border="0" class="imagemLink" title="Imprimir DAMDFE"
                                     onClick="javascript:tryRequestToServer(function(){confirmDAMDFe2('${mdfe.beanManifesto.idmanifesto}', ${param.status =='P'});});">
                                     <input type="hidden" id="impTudo_${status.count}" name="impTudo_${status.count}" value="${mdfe.beanManifesto.idmanifesto}" >
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${param.status == 'C'}">
                                <c:choose>
                                    <c:when test="${mdfe.isEnviaEmailMDFe}">                    
                                        <img class="imagemLink" alt="" title="Enviar MDFe para Cliente, já Enviado" id="" onClick="javascript:tryRequestToServer(function(){enviarEmail('${mdfe.beanManifesto.idmanifesto}', '${mdfe.reciboMDFe.status}', ${param.status =='P'});})" width="25px" src="img/outc.png">
                                    </c:when>
                                    <c:otherwise>
                                        <img class="imagemLink" alt="" title="Enviar MDFe para Cliente" id="" onClick="javascript:tryRequestToServer(function(){enviarEmail('${mdfe.beanManifesto.idmanifesto}', '${mdfe.reciboMDFe.status}', ${param.status =='P'});})" width="25px"  src="img/out.png">
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </td>
                        <td width="center">
                            <div width="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarManifesto('${mdfe.beanManifesto.idmanifesto}',null);});">  <!-- favor futuramente fazer uma regra para o bloqueio caso ele seja alterado. (Anderson) -->
                                ${mdfe.beanManifesto.nmanifesto}
                            </div>
                        </td>  
                        <td><label id="numero_${status.count}">${mdfe.beanManifesto.protocoloAutorizacaoMDFe.numero}</label></td>
                        <td><label id="cidadeUfOrig_${status.count}">${mdfe.beanManifesto.cidadeorigem.cidade} / ${mdfe.beanManifesto.cidadeorigem.uf}</label></td>
                        <td><label id="cidadeUfDest_${status.count}">${mdfe.beanManifesto.cidadedestino.cidade} / ${mdfe.beanManifesto.cidadedestino.uf}</label></td>
                        <td><label id="abrevFilial_${status.count}">${mdfe.beanManifesto.filial.abreviatura}</label></td>
                        <td><label id="abrevFilialDest_${status.count}">${mdfe.beanManifesto.filialdestino.abreviatura}</label></td>
                        <td><label id="nome_${status.count}">${mdfe.beanManifesto.motorista.nome}</label></td> 
                        <td><label id="dtlancamento_${status.count}"><fmt:formatDate value="${mdfe.beanManifesto.dtlancamento}" pattern="dd/MM/yyyy"/></label></td>
                        <input type="hidden" name="protocoloGerenciamentoRisco_${status.count}" id="protocoloGerenciamentoRisco_${status.count}" value="${mdfe.beanManifesto.protocoloGerenciamentoRisco}">
                        <input type="hidden" name="tipoUtilizacaoGerenciadoraRiscoGoldenService_${status.count}" id="tipoUtilizacaoGerenciadoraRiscoGoldenService_${status.count}" value="${mdfe.beanManifesto.filial.filialGerenciadorRisco.stUtilizacao}">
                        <input type="hidden" name="tipoBloqueioMonitoramento_${status.count}" id="tipoBloqueioMonitoramento_${status.count}" value="${mdfe.beanManifesto.filial.filialGerenciadorRisco.tipoBloqueioRastreamento}">
                        <input type="hidden" name="nmanifesto_${status.count}" id="nmanifesto_${status.count}" value="${mdfe.beanManifesto.nmanifesto}">
                        <input type="hidden" name="dataUsoGoldenService_${status.count}" id="dataUsoGoldenService_${status.count}" value="${mdfe.beanManifesto.filial.filialGerenciadorRisco.dataInicioUso}" />
                        <input type="hidden" name="dataLancamento_${status.count}" id="dataLancamento_${status.count}" value="${mdfe.beanManifesto.dtlancamento}">
                        <input type="hidden" name="idsFilhos_${status.count}" id="idsFilhos_${status.count}" value="${mdfe.beanManifesto.mdfeFilhos}">
                        <td id=''>

                            <c:if test="${mdfe.reciboMDFe.status == 'C'}" >
                                <img class="imagemLink" alt="" title="Cancelar MDF-e" src="./img/cancelar.png" id="bot_cancelar" onClick="javascript:tryRequestToServer(function(){cancelar('${mdfe.beanManifesto.nmanifesto}',${mdfe.beanManifesto.idmanifesto});})">
                            </c:if>
                        </td>
                    </tr>
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                        <td rowspan="2"></td>
                        <td rowspan="2" width="3%">
                            <img align="center" class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml_0" 
                                 onClick="javascript:tryRequestToServer(function(){ImprimirXML(${mdfe.beanManifesto.idmanifesto},'${mdfe.beanManifesto.chaveAcesso}','${mdfe.reciboMDFe.status}')})" width="25px" 
                                 src="img/xml.png">

                        </td>
                        <td rowspan="2" width="3%">
                            <img align="center" class="imagemLink" alt="" title="Consultar chave de acesso" id="img_consultar${mdfe.beanManifesto.idmanifesto}" onClick="javascript:tryRequestToServer(function(){submeterConsulta('Chave de Acesso Não Criada ainda...')})" width="30px" src="img/pesquisar_cte.png">
                        </td>
                        <td colspan="3" rowspan="2" >
                            <c:if test="${mdfe.reciboMDFe.status == 'E'}" >
                                Recibo:<label class="linkEditar" onclick="javascript:tryRequestToServer(function(){atualizarRecibo('${mdfe.beanManifesto.idmanifesto}','${mdfe.reciboMDFe.numero}');})" >${mdfe.reciboMDFe.numero}</label><br/>
                            </c:if>
                            <c:if test="${mdfe.reciboMDFe.status != 'E'}" >
                                Recibo:<label class="linkEditar">${mdfe.reciboMDFe.numero}</label><br/>
                            </c:if>
                            <label>Descrição do Status : ${mdfe.status.cod == 0 ? "0 " : mdfe.status.cod}-${mdfe.status.descricao == "" ||  mdfe.status.descricao  == null ? (mdfe.reciboMDFe.status == 'P' ? ' Pendente ' : ' Enviado ') : mdfe.status.descricao }</label>
                        </td>
                        <td colspan="3">
                            <label>Chave:${mdfe.beanManifesto.chaveAcesso}</label>
                        </td>
                        <td rowspan="2">
                            <c:if test="${mdfe.reciboMDFe.status == 'C'}" >
                                <div class="linkEditar"  onclick="javascript:tryRequestToServer(function(){desligarManifesto('${mdfe.beanManifesto.idmanifesto}',null);})">
                                    Encerrar Manifesto
                                </div>
                            </c:if>
                        </td>
                        <td>
                        </td>
                        <td width="2%" rowspan="2">
                            <img class="imagemLink" onclick="consultarProtocolo('${mdfe.beanManifesto.idmanifesto}')"
                                 alt="" title="Atualizar protocolo de autorização" src="./img/atualiza.png">
                        </td>
                    </tr>
                    
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                        <td >
                            <label>Cavalo:${mdfe.beanManifesto.cavalo.placa}</label>
                        </td>
                        <td >
                            <label>${mdfe.beanManifesto.carreta.placa}</label>
                        </td>
                        <td >
                            <label>${mdfe.beanManifesto.biTrem.placa}</label>
                        </td>
                        <td>
                        </td>
                    </tr>
                     <c:if test="${mdfe.reciboMDFe.status == 'N'}" >
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                                               
                        <td>
                            <label></label>
                        </td>                   
                        <td>
                            <label></label>
                        </td>                   
                        <td>
                            <label></label>
                        </td>                   
                        <td colspan="4">
                            <label>Possível Solução: ${mdfe.status.possiveisSolucoes}</label>
                        </td>                   
                             
                         <td>
                            <label></label>
                        </td>     
                         <td>
                            <label></label>
                        </td>     
                         <td>
                            <label></label>
                        </td>     
                         <td>
                            <label></label>
                        </td>     
                        <td>
                            <img width="25px" height="25px" src="img/consulta_48.png" class="imagemLink" alt="Imagem"  
                                 onclick="visualizarImagemSolucao('${mdfe.status.caminhoImagem}');" ${mdfe.status.caminhoImagem =="" ? "style='display:none'" : ""} />
                        </td>     
                        
                    </tr>
                     </c:if>
                    <c:if test="${mdfe.beanManifesto.filial.transmitirMDFeSeguradora and not (param.status eq 'P' or param.status eq 'E' or param.status eq 'N')}">
                        <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')} trAverbacao">
                            <td colspan="3"></td>
                            <td colspan="2">
                                <label>
                                    <c:choose>
                                        <c:when test="${mdfe.reciboMDFe.status == 'C'}">
                                            Averbado:
                                        </c:when>
                                        <c:when test="${mdfe.reciboMDFe.status == 'L'}">
                                            Averbacao Cancelada:
                                        </c:when>
                                        <c:when test="${mdfe.reciboMDFe.status == 'R'}">
                                            Encerramento Averbado:
                                        </c:when>
                                    </c:choose>
                                    <strong class="consultarProtocoloAverbacao linkEditar"
                                            data-protocolo="${mdfe.protocolo}">
                                        <c:out value="${mdfe.averbado ? 'Sim' : 'Não'}"/></strong>
                                </label>
                            </td>
                            <td colspan="2">
                                <c:if test="${mdfe.averbado}">
                                    <label>Protocolo: <span><c:out value="${mdfe.protocolo}"/></span></label>
                                </c:if>
                                <c:if test="${not mdfe.averbado}">
                                    <label>Motivo: <span><c:out value="${mdfe.descCompleta}"/></span></label>
                                </c:if>
                            </td>
                            <td colspan="5">
                                <c:if test="${not mdfe.averbado}">
                                    <strong class="averbarMDFe linkEditar"
                                            data-manifesto-id="<c:out value="${mdfe.beanManifesto.idmanifesto}"/>"
                                            data-manifesto-numero="<c:out value="${mdfe.beanManifesto.nmanifesto}"/>"
                                            data-filial-id="<c:out value="${mdfe.beanManifesto.filial.idfilial}"/>">
                                        Averbar manualmente
                                    </strong>
                                </c:if>
                            </td>
                        </tr>
                    </c:if>
                </c:forEach>
            </table>
        </form>
        <table class="bordaFina" width="90%" align="center" >
            <tr class="CelulaZebra1" width="20%" >
                <td align="center" colspan="2">Total de Ocorr&ecirc;ncias
                    <c:out value="${param.qtdResultados}"/></td>
                <td align="center" width="20%">P&aacute;ginas
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
                <td align="center" width="20%">
                    <form id="formularioAnt" name="formularioAnt" action="MDFeControlador?acao=listarMDFe" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>                     

                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td align="center" width="20%">
                    <form id="formularioProx" name="formularioProx"  action="MDFeControlador?acao=listarMDFe" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>"/> 

                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>

                <td align="center" width="20%">
                    <c:if test="${(param.status == 'P' || param.status == 'N' )&& param.utilizacaoMDFe !='C'}" >
                        <input name="botaoEnviar" type="button" class="inputbotao" id="botaoEnviar" onclick="javascript: tryRequestToServer(function(){enviar()});" value="ENVIAR">
                    </c:if>
                </td>
                <c:if test="${param.status == 'C'}" >
                     <td width="40%">Modelo DAMDFE:
                            <select name="modelo" id="modelo"  class="inputtexto">
                                <option value="1">DAMDFe</option>
                                <option value="2">DAMDF-e (Rodoviário)</option>
                                <option value="3">DAMDF-e (Aéreo)</option>
                                <option value="4">DAMDF-e (Aquaviário)</option>
                                <% for (String rel : Apoio.listMDFe(request)) {%>
                                    <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                <%}%>
                            </select>
                        </td>
                </c:if>
            </tr>
        </table>
        <div class="bloqueio-enviando-averbacao" style="display: none;">
            <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt="" style="display: inline-block;">
            <strong class="gif-bloq-tela"
                    style="display: inline-block;margin-left:-95px;font-size:20px;margin-top:70px;">
                Enviando averbação...
            </strong>
        </div>
        <div class="bloqueio-tela"></div>
    <script>
        jQuery(document).ready(function () {
           var trAverbacao = jQuery('.trAverbacao');

           trAverbacao.on('click', '.averbarMDFe', function () {
               if (certificadoAtualizado === 'false') {
                   chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                   return;
               }

               var elemento = jQuery(this);

               var manifestoNumero = elemento.attr('data-manifesto-numero');
               var manifestoId = elemento.attr('data-manifesto-id');
               var filialId = elemento.attr('data-filial-id');

               chamarConfirm('Tem certeza de que deseja averbar manualmente o manifesto: ' + manifestoNumero + '?', 'averbarMDFeSim("' + manifestoId + '", "' + filialId + '")');
           });

           trAverbacao.on('click', '.consultarProtocoloAverbacao', function() {
               var elemento = jQuery(this);

               var protocolo = elemento.attr('data-protocolo');

               chamarAlert('Protocolo de averbação: ' + protocolo);
           })
        });

        function averbarMDFeSim(manifestoId, filialId) {
            jQuery('.bloqueio-tela').show();
            jQuery('.bloqueio-enviando-averbacao').show();

            jQuery.post('${homePath}/MDFeControlador', {
                'acao': 'averbarMDFe',
                'manifestoId': manifestoId,
                'filialId': filialId
            }, function (data) {
                jQuery('.bloqueio-tela').hide();
                jQuery('.bloqueio-enviando-averbacao').hide();

                chamarAlert(data, function() {
                    window.location.reload(true);
                });
            });
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
    <c:if test="${param['status'] eq 'N'}">
        <jsp:include page="blip/chat_blip.jsp"/>
        <script>
            configurarChatBlip('${configTecnica.blipChaveApp}', 0, {
                'id': '${user.id}',
                'nome': '${user.nome}',
                'email': '${user.email}'
            }, {
                'razao_social': '${user.filial.razaosocial}',
                'cnpj': '${user.filial.cnpj}',
                'telefone': '${user.filial.fone}',
                'cidade': '${user.filial.cidade.descricaoCidade}',
                'versao': '${versao}'
            }, true, false, {'tela': 'mdfe'});

            executarChatBlip();
        </script>
    </c:if>
    </body>
</html>
