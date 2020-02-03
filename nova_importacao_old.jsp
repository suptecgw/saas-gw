<%-- 
    Document   : novo_anexo
    Created on : 20/09/2011, 09:25:34
    Author     : jonas
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>

<link href="estilo.css" rel="stylesheet" type="text/css"></link>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/beans/nota_fiscal-util.js" type="text/javascript"></script>
<script language="javascript" src="script/notaFiscal-util.js"></script>
<script language="JavaScript" src="script/beans/CTRC.js" type="text/javascript"></script>
<script language="JavaScript" src="script/collection.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js"></script>
<script type="text/javascript" language="JavaScript">
    jQuery.noConflict();
    
    shortcut.add("Ctrl+Shift+A",function() {anexar();});
    
    function abrirLocalizarCfop(){
        abrirLocaliza("CfopControlador?acao=localizarLogis&modulo=Webtrans", "locCfopEntradaLogis");
    }
        
    
    function abrirLocalizarGSM(){
        abrirLocaliza("ConhecimentoControlador?acao=localizarGSM&modulo=gwLogis&tipo=entrada", "locCfopEntradaLogis");
    }
        
    
    function abrirLocalizarCarga(){
        abrirJanela("ConhecimentoControlador?acao=localizarCarga", "locGwConferencia", 80, 80);
    }
    
    function adicionarEnterObs(obs){
        var obsNfe = replaceAll(obs,"<br/>","\n\n\r");
        return obsNfe;
    }
        
    //var extensoesOk = "jpg, doc, docx, odt, txt, rar, zip, gz, tar, xls, xlsx";
    var arrayExtencoes = new Array();
    arrayExtencoes[0] = 'XML' ;
    arrayExtencoes[1] = 'TXT' ;

    function mostrarRedespacho(){
        
        if (($("isRedespacho") != null && $("isRedespacho").checked) || ($("isRedespConsig") != null && $("isRedespConsig").checked)) {
            //visivel($("red_rzs"));
            visivel($("idredespacho"));
            //visivel($("btLocRedesp"));
            //visivel($("labRedesp"));
            //visivel($("trRedespachoConsig"));
        }else{
            //invisivel($("red_rzs"));
            invisivel($("idredespacho"));
            //invisivel($("btLocRedesp"));
            //invisivel($("labRedesp"));
            //invisivel($("trRedespachoConsig"));
        }
    }

    function mostrarRepresentante(){
        try {
            if ($("isRepresentante").checked) {
                visivel($("redspt_rzs"));
//                visivel($("idrepresentante"));
                visivel($("btLocRepre"));
//                visivel($("labRepre"));
            }else{
                invisivel($("redspt_rzs"));
//                invisivel($("idrepresentante"));
                invisivel($("btLocRepre"));
//                invisivel($("labRepre"));
            }
        } catch (e) { 
            alert(e);
        }

    }
    
    function mostrarConsignatario(){
        
        if ($("isConsignatario").checked) {           
            visivel($("idconsignatario"));      
        }else{            
            invisivel($("idconsignatario"));            
        }
    }

    function abrirLocalizarRedespacho(){
        tryRequestToServer(function(){
            popLocate(6, "Redespacho","");
        });
    }
    
    function abrirLocalizarRemetente(){
        tryRequestToServer(function(){
            popLocate(3, "Remetente","");
        });
    }
    
    function abrirLocalizarDestinatario(){
        tryRequestToServer(function(){
            popLocate(4, "Destinatario","");
        });
    }

    function abrirLocalizarRepresentante(){
        tryRequestToServer(function(){
            popLocate(23, "Redespacho","");
        });
    }
    
    function abrirLocalizarConsignatario(){
        tryRequestToServer(function(){
            popLocate(5, "Consignatario","");
        });
    }
    
    function alterarLayout(layout){
        invisivel($("tdCarga1"));
        invisivel($("tdCarga2"));
        invisivel($("trRemetente"));
        invisivel($("tdDtEmissao1"));
        invisivel($("tdChaveAcessoNFe1"));
        invisivel($("trCaptcha"));
        invisivel($("tdChaveAcessoNFe2"));
        invisivel($("tdDtEmissao2"));
        switch(layout){
            case "alpargatas":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "webserviceNDDAvon":
                $("btVisualizar").value = "Pesquisar Notas Disponiveis";
                invisivel($("trRemetente"));
                invisivel($("arq01"));
                invisivel($("tdInput"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("trCaptcha"));
                visivel($("tdDtEmissao1"));
                visivel($("tdDtEmissao2"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "hermes":
                $("btVisualizar").value = "Importar";
                visivel($("trRemetente"));
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "nfeChaveAcesso":
                $("btVisualizar").value = "Importar";
                invisivel($("trRemetente"));
                invisivel($("tdInput"));
                invisivel($("tdDtEmissao1"));
                visivel($("tdChaveAcessoNFe1"));
                visivel($("tdChaveAcessoNFe2"));
                visivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                visivel($("trTransport"));
                ajaxCarregarCaptcha();
                invisivel($("trUnicoDestinatario"));
                break;
            case "nfe":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                visivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "proceda31Marilan":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "proceda31CiaTecidosSantoAntonio":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "procedaDanone":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "procedaDelVale":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
            case "proceda31Alianca":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                visivel($("trUnicoDestinatario"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                break;
            case "proceda31Masterfoods":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
             case "proceda31MDias":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
             case "gsm":
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                invisivel($("tdCarga1"));
                invisivel($("tdCarga2"));
                visivel($("tdGSM1"));
                visivel($("tdGSM2"));
                break;
             case "gwConferencia":
                $("btVisualizar").value = "Importar";
                invisivel($("arq01"));
                invisivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                invisivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                visivel($("tdCarga1"));
                visivel($("tdCarga2"));
                break;
            case "cteConfirmadoXML":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
              $("isAgruparS").disabled = true;
                invisivel($("isAgruparCte"));
                break;
            case "proceda50Ramthun":
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                visivel($("trUnicoDestinatario"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("trCaptcha"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("tdDtEmissao2"));
                visivel($("trFontePreco"));
                break;
            case "mobly":
                visivel($("trUnicoDestinatario"));
                visivel($("trRemetente"));
            break;    
            default:
                $("btVisualizar").value = "Importar";
                visivel($("arq01"));
                visivel($("tdInput"));
                invisivel($("trRemetente"));
                invisivel($("tdDtEmissao1"));
                invisivel($("tdChaveAcessoNFe1"));
                invisivel($("tdChaveAcessoNFe2"));
                invisivel($("trCaptcha"));
                invisivel($("tdDtEmissao2"));
                invisivel($("trFontePreco"));
                invisivel($("trTransport"));
                invisivel($("trUnicoDestinatario"));
                break;
        }
    }
        
    function anexar(){
        window.onbeforeunload = null;
        var pai = window.opener.document;
        var arq01 = $("arq01").value;
        var filial = "";
        var filialCadConhecimento = "";
        var formulario = $("formularioFilho");
        
        try {
            if (pai.getElementById("filial") != null && "${param.tipoImportacao}" != "unico") {
                //                filialId = pai.getElementById("filial").value.split("@@")[0];
                filial = pai.getElementById("filial").value;
            }else if(pai.getElementById("idfilial") != null){
                filial = pai.getElementById("idfilial").value;
            }
            
            if (arq01 == "" && $("layoutArquivo").value != "webserviceNDDAvon" 
                    && $("layoutArquivo").value != "nfeChaveAcesso" 
                    && $("layoutArquivo").value != "gsm"){
                alert("Selecione o arquivo.");
                return false;
                
                var ultimoPonto = arq01.lastIndexOf(".");
                
                var extensao = arq01.substr(ultimoPonto+1).toUpperCase();
                
                var possuiExtencao = false;
                for(var i=0;i<arrayExtencoes.length;i++){
                    
                    if( arrayExtencoes[i].indexOf( extensao ) != -1 ){
                        possuiExtencao = true;
                    }
                }
                
                if(!possuiExtencao){
                    return  alert( "Extensão de arquivo inválida." );
                }
                formulario.enctype = "multipart/form-data";
            }else if($("layoutArquivo").value == "webserviceNDDAvon" && $("dtEmissao").value == ""){
                return showErro("Informe a data de emissão!", $("dtEmissao"));
            }else if($("layoutArquivo").value == "nfeChaveAcesso" && $("chaveAcessoNFe").value == ""){
                return showErro("Informe a chave de acesso da NF-e!", $("chaveAcessoNFe"));
            }else if($("layoutArquivo").value == "gsm" && ($("idGSM").value == "" || $("idGSM").value == "0")){
                return showErro("Informe a GSM!", $("numeroGSM"));
            }else if($("layoutArquivo").value == "gwConferencia" && ($("idCarga").value == "" || $("idCarga").value == "0")){
                return showErro("Informe a Carga!", $("numeroCarga"));
            }else if($("layoutArquivo").value == "proceda50Ramthun" && ($("dest_rzs").value == "")){
                return showErro("Informe o Destinatário!", $("numeroCarga"));
            }
            
            if($("isRedespacho").checked == true && $("red_rzs").value == ""){
                alert("ATENÇÃO: Selecione o redespacho primeiro ");
                return false;
            }
            
          
            formulario.action ="ConhecimentoControlador?acao=importarFile&layoutArquivo="+$("layoutArquivo").value+
                "&filial="+filial+"&isRedespacho="+$("isRedespacho").checked+"&redespachoId="+$("idredespacho").value+
                "&isRepresentante="+$("isRepresentante").checked+"&representanteId="+$("idredespachante").value+
                "&tipoTabela="+$("tipoTabela").value+
                "&caracter="+$("captcha").value+
                "&saidaId="+$("idGSM").value+
                "&cargaId="+$("idCarga").value+
                "&tipoTransporte="+pai.getElementById("tipoTransporte").value+
                "&chaveAcessoNFe="+$("chaveAcessoNFe").value+
                "&tipoImportacao=${param.tipoImportacao}"+
                "&utilizarTabelaRemetente="+$("utilizarTabelaRemetente").value+
                "&idremetente="+$("idremetente").value+
                "&isConsignatario="+$("isConsignatario").checked+"&consignatarioId="+$("idconsignatario").value+
                "&isAgrupar="+($("isAgruparS") != null && $("isAgruparS") != undefined ? $("isAgruparS").checked : false)+
                "&isAgruparPedido="+($("isAgruparPedidoS") != null && $("isAgruparPedidoS") != undefined ? $("isAgruparPedidoS").checked : false)+
                "&isApenasTransp="+($("isApenasTranspS") != null && $("isApenasTranspS") != undefined ? $("isApenasTranspS").checked : false)+
                "&isGrupoCliProdS="+($("isGrupoCliProdS") != null && $("isGrupoCliProdS") != undefined ? $("isGrupoCliProdS").checked : false)+
                "&isDadosMotoristaS="+($("isDadosMotoristaS") != null && $("isDadosMotoristaS") != undefined ? $("isDadosMotoristaS").checked : false)+
//                "&isRedespConsig="+$("isRedespConsig").checked+
                "&dtEmissao="+$("dtEmissao").value+
                "&fontePreco=" + ($("fontePrecoTabela").checked ? "t" : "a")+
                "&isMesmoDest=" + $("isMesmoDest").checked+
                "&idDestinatario="+ $("iddestinatario").value;
        
            //$("formularioFilho").target = "pop";
            formulario.method = "post";
            
            formulario.enctype = "multipart/form-data";
            //window.open('about:blank', 'pop', 'width=210, height=100');
            espereEnviar("Aguarde...", true);
            formulario.submit();
        } catch (e) { 
            console.log(e);
            alert(e);
            espereEnviar("", false);
        }

        return true;
    }
    
    function carregar(){
        try{
            window.onbeforeunload = null;
            var ctrc;
            var nf;
            var nf;
            var index= 0;
            var indexCubagem = 0;
            var pai = window.opener;
            var paiDoc = pai.document;
            var cubagem;
            var apoioNotas = 0;
            var merc;
            var qtdCubagem = 0;
            var listaCubagens;
            var indexMerc = 0;
            var listaMercadoria;
            var isAgrupar = ("${param.isAgrupar}"=="true");
            var isDadosMotorista = ("${param.isDadosMotorista}"=="true");
            var perguntarAddVariasNotasCtrc = (isAgrupar ? false : true);
            var isRedespacho = ("${param.isRedespacho}"=="true");
            var isRepresentante = ("${param.isRepresentante}"=="true");
            var isConsiderarPedidoAgrupamento = ("${param.isAgruparPedido}"=="true");
            
            
            var isConsiderarCtrcRedespacho = false;
            
            
            if (${configuracao.layoutImportacaoXmlDanfe == 'c'}) {
                $("layoutArquivo").value = "nfeChaveAcesso";
                alterarLayout("nfeChaveAcesso");
            }
            
            if ('${param.layoutArquivo}' != "") {
                $("chaveAcessoNFe").value = '${param.chaveAcessoNFe}';
                $("layoutArquivo").value = '${param.layoutArquivo}';
                alterarLayout($("layoutArquivo").value);
            }
            
            $("layoutArquivo").focus();
            
            if ('${param.layoutArquivo}' == 'terphane' || '${param.layoutArquivo}' == 'neogrid' || '${param.layoutArquivo}' == 'proceda30A' || '${param.layoutArquivo}' == 'proceda30Ahermes') {
                perguntarAddVariasNotasCtrc = false;
            }
            if ('${param.layoutArquivo}' == 'ricardoEletro' || '${param.layoutArquivo}' == 'proceda30Ahermes' || '${param.layoutArquivo}' == 'eFacil') {
                isAgrupar = false;
            }
            if ('${param.layoutArquivo}' == 'procedaDelVale') {
                isConsiderarPedidoAgrupamento = true;
            }
            if ('${param.layoutArquivo}' == 'procedaDisplan') {
                isConsiderarCtrcRedespacho = true;
            }
            if ('${param.layoutArquivo}' == 'redespRapidaoCometa' || '${param.layoutArquivo}' == 'proceda50Ramthun') {
                console.log("entra aqyu");
                isAgrupar = true;
            }
            if (pai.$("layout") != null && pai.$("layout") != undefined) {
                pai.$("layout").value = '${param.layoutArquivo}';
            }
            
    <c:forEach var="ctrc" varStatus="status" items="${ctrcs}">
                console.log("size ctrc: "+${ctrcs.size()});
                ctrc = new CTRC();
                ctrc.cfopId = "${ctrc.cfop.idcfop}";
                ctrc.cfop = "${ctrc.cfop.cfop}";
                ctrc.taxaRoubo = "${ctrc.taxaSeguroRoubo}";
                ctrc.taxaRouboUrbano = "${ctrc.taxaSeguroRouboUrbano}";
                ctrc.taxaTombamento = "${ctrc.taxaSeguroTombamento}";
                ctrc.taxaTombamentoUrbano = "${ctrc.taxaSeguroTombamentoUrbano}";
                ctrc.taxaTombamentoUrbano = "${ctrc.taxaSeguroTombamentoUrbano}";
                ctrc.cubagemMetro = "${ctrc.cubagemMetro}";
                ctrc.numeroContainer = "${ctrc.numeroContainer}";
                ctrc.numero = "${ctrc.numero}";
                ctrc.serie = "${ctrc.serie}";
                ctrc.chaveCte = "${ctrc.chaveCte}";
                ctrc.emissaoEm = "${ctrc.emissaoEmS}";
                ctrc.emissaoAs = "${ctrc.emissaoAs}";
                ctrc.numeroCarga = "${ctrc.numeroCarga}";
                ctrc.previsaoEntrega = "${ctrc.previsaoEntrega}";
                ctrc.idRota = "${ctrc.rota.id}";
                ctrc.rota = "${ctrc.rota.descricao}";
                ctrc.distancisKm = "${ctrc.distanciaOrigemDestino}";
                ctrc.tipoFrete = "${ctrc.tipoTaxa}";
                ctrc.valorFreteValor  = "${ctrc.valorFrete}";
                ctrc.isPodeAlterar = "${ctrc.podeAlterar}";
                
        <c:forEach var="obs" varStatus="status" items="${ctrc.observacao}">
                    ctrc.observacao += "${obs}";
        </c:forEach>
            
            
        //crtc.cliente != underfined && crtc.cliente != null ? '' : 
        ctrc.consignatario.listaTipoProduto = new Array();
        var countOptTpProd = 0;
        <c:forEach var="tipo" varStatus="status" items="${ctrc.cliente.tipoProduto}">
            ctrc.consignatario.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
        </c:forEach>
            
        ctrc.remetente.listaTipoProduto = new Array();
        countOptTpProd = 0;
        <c:forEach var="tipo" varStatus="status" items="${ctrc.remetente.tipoProduto}">
            ctrc.remetente.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
        </c:forEach>
            
        ctrc.destinatario.listaTipoProduto = new Array();
        countOptTpProd = 0;
        <c:forEach var="tipo" varStatus="status" items="${ctrc.destinatario.tipoProduto}">
            ctrc.destinatario.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
        </c:forEach>
            
        ctrc.redespacho.listaTipoProduto = new Array();
        countOptTpProd = 0;
        <c:forEach var="tipo" varStatus="status" items="${ctrc.redespacho.tipoProduto}">
            ctrc.redespacho.listaTipoProduto[countOptTpProd++] = new Option('${tipo.id}', '${tipo.descricao}');            
        </c:forEach>
            
                    if ("${param.fontePreco}" == "a") {
                        if (pai.$("fontePreco") != null && pai.$("fontePreco") != undefined) {
                            pai.$("fontePreco").value = "${param.fontePreco}";
                        }
                        ctrc.tipoFrete = 3;
                        ctrc.valorFretePeso = "${ctrc.valorPeso}";
                        ctrc.valorTaxaFixa = "${ctrc.valorTaxaFixa}";
                        ctrc.valorFreteValor  = "${ctrc.valorFrete}";
                        ctrc.valorPedagio  = "${ctrc.valorPedagio}";
                        //isAgrupar = false;
                    }
                    //alert(pai.$("fontePreco").value);
            
                    //consignatario
                    ctrc.consignatario.razaoSocial = "${ctrc.cliente.razaosocial}";
                    ctrc.consignatario.id = "${ctrc.cliente.idcliente}";
                    ctrc.consignatario.cnpj = "${ctrc.cliente.cnpj}";
                    ctrc.consignatario.cidadeId = "${ctrc.cliente.cidade.idcidade}";
                    ctrc.consignatario.cidade = "${ctrc.cliente.cidade.descricaoCidade}";
                    ctrc.consignatario.uf = "${ctrc.cliente.cidade.uf}";
                    ctrc.consignatario.endereco = "${ctrc.cliente.endereco}";
                    ctrc.consignatario.isCreditoBloqueado = "${ctrc.cliente.creditoBloqueado}";
                    ctrc.consignatario.creditoDisponivel = "${ctrc.cliente.creditoDisponivel}";
                    ctrc.consignatario.tipoCGC = "${ctrc.cliente.cidade.descricaoCidade}";
                    ctrc.consignatario.tipoCfop = "${ctrc.cliente.tipoCfop}";
                    ctrc.consignatario.inscEst = "${ctrc.cliente.inscest}";
                    ctrc.consignatario.isStMG = "${ctrc.cliente.substituicaoTributariaMinasGerais}";
                    ctrc.consignatario.obrigaTabelaTipoProduto = "${ctrc.cliente.tabelaTipoProduto}";
                    ctrc.consignatario.utilizaTipoFreteTabela = "${ctrc.cliente.utilizarTipoFreteTabela}";
                    ctrc.consignatario.utilizaPautaFiscal = "${ctrc.cliente.utilizaPautaFiscal}";
                    ctrc.consignatario.tipoOrigemFrete = "${ctrc.cliente.tipoOrigemFrete}";
                    ctrc.consignatario.tipoTabela = "${ctrc.cliente.tipo_tabela}";
                    ctrc.consignatario.stIcms = "${ctrc.cliente.stIcms.id}";
                    console.log("ctrc.ctrc.cliente.observacao = "+"${ctrc.cliente.observacao}");
                    ctrc.consignatario.obs = adicionarEnterObs("${ctrc.cliente.observacao}");
                    ctrc.consignatario.tipoPgto = "${ctrc.cliente.tipoPagtoFrete}";
                    ctrc.consignatario.qtdDiasPgto = "${ctrc.cliente.condicaoPgt}";
                    ctrc.consignatario.percComissaoVendedor = "${ctrc.cliente.vlcomissaoVendedor}";
                    ctrc.consignatario.unificadaModalVendedor = "${ctrc.cliente.tipoComissaoVendedor}";
                    ctrc.consignatario.percComissaoRodoviarioFracionadoVendedor = "${ctrc.cliente.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.consignatario.percComissaoRodoviarioLotacaoVendedor = "${ctrc.cliente.comissaoRodoviarioLotacaoVendedor}";
                    
                    ctrc.consignatario.vendedor.razaoSocial = "${ctrc.cliente.vendedor.razaosocial}";
                    ctrc.consignatario.vendedor.id = "${ctrc.cliente.vendedor.id}";
                    ctrc.consignatario.percComissaoVendedor = "${ctrc.cliente.vlcomissaoVendedor}";
                    //remetente
                    ctrc.remetente.razaoSocial = "${ctrc.remetente.razaosocial}";
                    ctrc.remetente.id = "${ctrc.remetente.idcliente}";
                    ctrc.remetente.cnpj = "${ctrc.remetente.cnpj}";
                    ctrc.remetente.cidadeId = "${ctrc.remetente.cidade.idcidade}";
                    ctrc.remetente.cidade = "${ctrc.remetente.cidade.descricaoCidade}";
                    ctrc.remetente.endereco = "${ctrc.remetente.endereco}";
                    ctrc.remetente.utilizaTipoFreteTabela = "${ctrc.remetente.utilizarTipoFreteTabela}";
                    ctrc.remetente.bairro = "${ctrc.remetente.bairro}";
                    ctrc.remetente.complemento = "${ctrc.remetente.complemento}";
                    ctrc.remetente.logradouro = "${ctrc.remetente.numeroLogradouro}";
                    
                    ctrc.remetente.uf = "${ctrc.remetente.cidade.uf}";
                    ctrc.cidadeOrigem = "${ctrc.remetente.cidade.descricaoCidade}";
                    ctrc.idCidadeOrigem = "${ctrc.remetente.cidade.idcidade}";
                    ctrc.ufOrigem = "${ctrc.remetente.cidade.uf}";
                    ctrc.remetente.tipoCfop = "${ctrc.remetente.tipoCfop}";
                    ctrc.remetente.inscEst = "${ctrc.remetente.inscest}";
                    ctrc.remetente.isStMG = "${ctrc.remetente.substituicaoTributariaMinasGerais}";
                    ctrc.remetente.isCreditoBloqueado = "${ctrc.remetente.creditoBloqueado}";
                    ctrc.remetente.isAnaliseCredito = "${ctrc.remetente.analiseCredito}";
                    ctrc.remetente.creditoDisponivel = "${ctrc.remetente.creditoDisponivel}";
                    ctrc.remetente.obrigaTabelaTipoProduto = "${ctrc.remetente.tabelaTipoProduto}";
                    ctrc.remetente.incluiPesoContainer = "${ctrc.remetente.incluiContainerFretePeso}";
                    ctrc.remetente.percComissaoVendedor = "${ctrc.remetente.vlcomissaoVendedor}";
                    ctrc.remetente.unificadaModalVendedor = "${ctrc.remetente.tipoComissaoVendedor}";
                    ctrc.remetente.percComissaoRodoviarioFracionadoVendedor = "${ctrc.remetente.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.remetente.percComissaoRodoviarioLotacaoVendedor = "${ctrc.remetente.comissaoRodoviarioLotacaoVendedor}";
                
                    ctrc.remetente.utilizaPautaFiscal = "${ctrc.remetente.utilizaPautaFiscal}";
                    ctrc.remetente.tipoOrigemFrete = "${ctrc.remetente.tipoOrigemFrete}";
                    ctrc.remetente.tipoTabela = "${ctrc.remetente.tipo_tabela}";
                    ctrc.remetente.stIcms = "${ctrc.remetente.stIcms.id}";
                    console.log("ctrc.remetente.stIcms="+ctrc.remetente.stIcms);
                    ctrc.remetente.obs = "${ctrc.remetente.observacao}";
                    ctrc.remetente.tipoPgto = "${ctrc.remetente.tipoPagtoFrete}";
                    ctrc.remetente.qtdDiasPgto = "${ctrc.remetente.condicaoPgt}";
                    ctrc.tipoProduto = "${ctrc.tipoProduto.id}";

                    ctrc.remetente.utilizarTabelaRemetente = "${ctrc.remetente.utilizaTabelaRemetente}";
                    ctrc.remetente.vendedor.razaoSocial = "${ctrc.remetente.vendedor.razaosocial}";
                    ctrc.remetente.vendedor.id = "${ctrc.remetente.vendedor.id}";
                    ctrc.remetente.percComissaoVendedor = "${ctrc.remetente.vlcomissaoVendedor}";
                    ctrc.remetente.tipoDocumentoPadrao = "${ctrc.remetente.tipoDocumentoPadrao}";
                    
                    

                    //destinatario                    
                    
                    ctrc.destinatario.razaoSocial = "${ctrc.destinatario.razaosocial}";
                    ctrc.destinatario.id = "${ctrc.destinatario.idcliente}";
                    ctrc.destinatario.cnpj = "${ctrc.destinatario.cnpj}";
                    ctrc.destinatario.reducaoIcms = "${ctrc.destinatario.reducaoIcms}";
                    ctrc.destinatario.isIncluirTde = "${ctrc.destinatario.cobrarTde}";
                    ctrc.isCobrarTde = ("${ctrc.destinatario.cobrarTde}" == "true" || "${ctrc.destinatario.cobrarTde}" == "t");
                    ctrc.destinatario.utilizaTipoFreteTabela = "${ctrc.destinatario.utilizarTipoFreteTabela}";
                    ctrc.destinatario.inscEst = "${ctrc.destinatario.inscest}";
                    ctrc.destinatario.isStMG = "${ctrc.destinatario.substituicaoTributariaMinasGerais}";
                    ctrc.destinatario.isCreditoBloqueado = "${ctrc.destinatario.creditoBloqueado}";
                    ctrc.destinatario.isAnaliseCredito = "${ctrc.destinatario.analiseCredito}";
                    ctrc.destinatario.creditoDisponivel = "${ctrc.destinatario.creditoDisponivel}";
                    ctrc.destinatario.obs = "${ctrc.destinatario.observacao}";
                    ctrc.destinatario.tipoOrigemFrete = "${ctrc.destinatario.tipoOrigemFrete}";
                    ctrc.destinatario.cidadeId = "${ctrc.destinatario.cidade.idcidade}";
                    ctrc.destinatario.cidade = "${ctrc.destinatario.cidade.descricaoCidade}";
                    ctrc.destinatario.uf = "${ctrc.destinatario.cidade.uf}";
                    ctrc.destinatario.endereco = "${ctrc.destinatario.endereco}";
                    
                    ctrc.destinatario.bairro = "${ctrc.destinatario.bairro}";
                    ctrc.destinatario.complemento = "${ctrc.destinatario.complemento}";
                    ctrc.destinatario.logradouro = "${ctrc.destinatario.numeroLogradouro}";
                    
                    ctrc.destinatario.stIcms = "${ctrc.destinatario.stIcms.id}";
                    console.log("ctrc.destinatario.stIcms="+ctrc.destinatario.stIcms);
                    ctrc.destinatario.tipoPgto = "${ctrc.destinatario.tipoPagtoFrete}";
                    ctrc.destinatario.qtdDiasPgto = "${ctrc.destinatario.condicaoPgt}";
                    ctrc.destinatario.incluiPesoContainer = "${ctrc.destinatario.incluiContainerFretePeso}";
                    ctrc.idCidadeDestino = "${ctrc.destinatario.cidade.idcidade}";
                    ctrc.cidadeDestino = "${ctrc.destinatario.cidade.descricaoCidade}";
                    ctrc.ufDestino = "${ctrc.destinatario.cidade.uf}";
                    ctrc.destinatario.tipoTabela = "${ctrc.destinatario.tipo_tabela}";            
                    ctrc.destinatario.utilizaPautaFiscal = "${ctrc.destinatario.utilizaPautaFiscal}";
                    ctrc.destinatario.obrigaTabelaTipoProduto = "${ctrc.destinatario.tabelaTipoProduto}";
                    ctrc.destinatario.tipoCfop = "${ctrc.destinatario.tipoCfop}";
                    ctrc.destinatario.utilizarTabelaRemetente = "${ctrc.destinatario.utilizaTabelaRemetente}";
                    ctrc.destinatario.percComissaoVendedor = "${ctrc.destinatario.vlcomissaoVendedor}";
                    ctrc.destinatario.unificadaModalVendedor = "${ctrc.destinatario.tipoComissaoVendedor}";
                    ctrc.destinatario.percComissaoRodoviarioFracionadoVendedor = "${ctrc.destinatario.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.destinatario.percComissaoRodoviarioLotacaoVendedor = "${ctrc.destinatario.comissaoRodoviarioLotacaoVendedor}";
                    ctrc.destinatario.vendedor.razaoSocial = "${ctrc.destinatario.vendedor.razaosocial}";
                    ctrc.destinatario.vendedor.id = "${ctrc.destinatario.vendedor.id}";
                    ctrc.destinatario.percComissaoVendedor = "${ctrc.destinatario.vlcomissaoVendedor}";
                    //cidade de origem e destino
                    ctrc.cidadeOrigem = "${ctrc.cidadeOrigem.descricaoCidade}";
                    ctrc.ufOrigem = "${ctrc.cidadeOrigem.uf}";
                    ctrc.idCidadeOrigem = "${ctrc.cidadeOrigem.idcidade}";
                    ctrc.cidadeDestino = "${ctrc.cidadeDestino.descricaoCidade}";
                    ctrc.idCidadeDestino = "${ctrc.cidadeDestino.idcidade}";            
                    ctrc.ufDestino = "${ctrc.cidadeDestino.uf}";
                    ctrc.modFrete= "${ctrc.modalidadeFrete}";
                    ctrc.enderecoEntregaId = "${ctrc.enderecoEntrega.id}";
                    console.log("ctrc.stIcms: "+"${ctrc.stIcms.id}");
                    if ($("layoutArquivo").value == "cteConfirmadoXML") {
                        ctrc.stICMS = "${ctrc.stIcms.id}";
                        ctrc.aliquotaIcms = "${ctrc.aliquota}";
                    }
                    //redespacho
                    ctrc.redespacho.razaoSocial = "${ctrc.redespacho.razaosocial}";            
                    ctrc.redespacho.id = "${ctrc.redespacho.idcliente}";
                    ctrc.redespacho.cnpj = "${ctrc.redespacho.cnpj}";
                    ctrc.redespacho.cidadeId = "${ctrc.redespacho.cidade.idcidade}";
                    ctrc.redespacho.cidade = "${ctrc.redespacho.cidade.descricaoCidade}";
                    ctrc.redespacho.uf = "${ctrc.redespacho.cidade.uf}";
                    ctrc.redespacho.tipoPgto = "${ctrc.redespacho.tipoPagtoFrete}";
                    ctrc.redespacho.qtdDiasPgto = "${ctrc.redespacho.condicaoPgt}";
                    ctrc.redespacho.tipoCfop = "${ctrc.redespacho.tipoCfop}";
                    ctrc.redespacho.inscEst = "${ctrc.redespacho.inscest}";
                    ctrc.redespacho.isStMG = "${ctrc.redespacho.substituicaoTributariaMinasGerais}";
                    ctrc.redespacho.isCreditoBloqueado = "${ctrc.redespacho.creditoBloqueado}";
                    ctrc.redespacho.isAnaliseCredito = "${ctrc.redespacho.analiseCredito}";
                    ctrc.redespacho.creditoDisponivel = "${ctrc.redespacho.creditoDisponivel}";
                    ctrc.redespacho.obrigaTabelaTipoProduto = "${ctrc.redespacho.tabelaTipoProduto}";
                    ctrc.redespacho.utilizaPautaFiscal = "${ctrc.redespacho.utilizaPautaFiscal}";
                    ctrc.redespacho.tipoOrigemFrete = "${ctrc.redespacho.tipoOrigemFrete}";            
                    ctrc.redespacho.tipoTabela = "${ctrc.redespacho.tipo_tabela}"; 
                    ctrc.redespacho.utilizarTabelaRemetente = "${ctrc.redespacho.utilizaTabelaRemetente}";
                    ctrc.redespacho.unificadaModalVendedor = "${ctrc.redespacho.tipoComissaoVendedor}";
                    ctrc.redespacho.utilizaTipoFreteTabela = "${ctrc.redespacho.utilizarTipoFreteTabela}";
                    ctrc.redespacho.percComissaoRodoviarioFracionadoVendedor = "${ctrc.redespacho.comissaoRodoviarioFracionadoVendedor}";
                    ctrc.redespacho.percComissaoRodoviarioLotacaoVendedor = "${ctrc.redespacho.comissaoRodoviarioLotacaoVendedor}";
                    
                    ctrc.redespacho.vendedor.razaoSocial = "${ctrc.redespacho.vendedor.razaosocial}";
                    ctrc.redespacho.vendedor.id = "${ctrc.redespacho.vendedor.id}";
                    ctrc.redespacho.percComissaoVendedor = "${ctrc.redespacho.vlcomissaoVendedor}";
                    
                    ctrc.redespachoCtrc = "${ctrc.redespachoCtrc}";
                    ctrc.redespachoValor = "${ctrc.redespachoValor}";
                    ctrc.redespachoValorIcms = "${ctrc.redespachoValorIcms}";
                    ctrc.redespachoChaveAcesso = "${ctrc.redespachoChaveAcesso}";

                    //representante
                    ctrc.representante.razaoSocial = "${ctrc.redespachante.razaosocial}";            
                    ctrc.representante.id = "${ctrc.redespachante.id}";
                    ctrc.representante.cnpj = "${ctrc.redespachante.cpfCnpj}";

                        if(${param.isDadosMotoristaS} == true){
                            ctrc.veiculo = "${ctrc.veiculo.placa}";
                            ctrc.idVeiculo = "${ctrc.veiculo.idveiculo}";
                            ctrc.motorista = "${ctrc.motorista.nome}";
                            ctrc.idMotorista = "${ctrc.motorista.idmotorista}";
                            ctrc.carreta = "${ctrc.carreta.placa}";
                            ctrc.idCarreta = "${ctrc.carreta.idveiculo}";
                            ctrc.bitrem = "${ctrc.biTrem.placa}";
                            ctrc.idBitrem = "${ctrc.biTrem.idveiculo}";
                        } else {
                            ctrc.veiculo = "";
                            ctrc.idVeiculo = "0";
                            ctrc.motorista = "";
                            ctrc.idMotorista = "0";
                            ctrc.carreta = "";
                            ctrc.idCarreta = "0";
                            ctrc.bitrem = "";
                            ctrc.idBitrem = "0";
                            
                        }
                    if (isRedespacho || (ctrc.redespacho != null && ctrc.redespacho.id != '0' && ctrc.redespacho.id != 0)) {
                        //                ctrc.consignatario = ctrc.redespacho;
                        ctrc.isRedespacho = true;
                    }
                    //ModalidadeFrete
        <c:forEach var="nota" varStatus="status" items="${ctrc.notas}">
                console.log("size notas? "+${ctrc.notas.size()});
                <c:if test="${status.first}">
                            if ('${param.layoutArquivo}' == 'ricardoEletro' || '${param.layoutArquivo}' == 'proceda31LojasAmericanas') {
                                pai.$("pedido").value = '${ctrc.pedidoCliente}';
                            }
                </c:if>
                        apoioNotas++;
                        nf = new NotaFiscal();
                        nf.id = "${nota.idnotafiscal}";
                        nf.numero = "${nota.numero}";
                        nf.serie = "${nota.serie}";
                        nf.dataEmissao = "${nota.emissaoStr}";
                        nf.peso = "${nota.peso}";
                        nf.valor = "${nota.valor}";
                        nf.volume = parseFloat("${nota.volume}");
                        
                        nf.cfop = "${nota.cfop.cfop}";
                        nf.cfopId = "${nota.cfop.idcfop}";
                        nf.chaveNFe = "${nota.chaveNFe}";
                        nf.destinatario = "${ctrc.destinatario.razaosocial}";
                        nf.destinatarioId = "${ctrc.destinatario.idcliente}";
                        nf.baseCalculoIcm = "${nota.vl_base_icms}";
                        nf.icmsValor  = "${nota.vl_icms}";
                        nf.pedido= "${nota.pedido}";
                        nf.isExiste = ("${nota.existe}" == "true");
                        nf.conteudo = "${nota.conteudo}";
                        nf.embalagem = "${nota.embalagem}";
                        nf.observacao = "${nota.observacaoAgenda}";
                        nf.dataAgenda = "${nota.dataAgendaStr}";
                        nf.horaAgenda = "${nota.horaAgenda}";
                        nf.dataPrevisao = "${nota.previsaoEmStr}";
                        nf.horaPrevisao = "${nota.previsaoAs}";
                        nf.metroCubico = "${nota.metroCubico}";
                        nf.tipoDocumento = (nf.chaveNFe == "" ? "NF": "NE");
                        nf.cargaId = "${nota.carga.id}";
                        
                        /**
                         * EDI
                         */
                        nf.adValorem = "${nota.adValorem}";
                        nf.valorSeguro = "${nota.valorSeguro}";
                        nf.valorFretePeso = "${nota.valorFretePeso}";
                        nf.valorTotalTaxas = "${nota.valorTotalTaxas}";
                        nf.valorGris = "${nota.valorGris}";
                        nf.valorPedagio = "${nota.valorPedagio}";

                        if ((pai.$("layout") != null && pai.$("layout").value == 'nfe') || (pai.$("layout") != null && pai.$("layout").value == 'nfeChaveAcesso')){
                            nf.isImportacaoEDI = false;
                        }else{
                            nf.isImportacaoEDI = true;
                        }
                
                        listaCubagens = new Array();
                        indexCubagem = 0;
            <c:forEach var="cubagem" varStatus="status" items="${nota.cubagens}">
                        cubagem = new Cubabem();
                        cubagem.volume = "${cubagem.volume}";
                        cubagem.altura = "${cubagem.altura}";
                        cubagem.comprimento = "${cubagem.comprimento}";
                        cubagem.largura = "${cubagem.largura}";
                        cubagem.existe = '<c:out value="${cubagem.existe}"/>';
                        listaCubagens[indexCubagem++] = cubagem;
            </c:forEach>    
                
                        nf.listaCuabagem = listaCubagens;
                    
                        listaMercadoria = new Array();
                        indexMerc = 0;
            <c:forEach var="merc" varStatus="status" items="${nota.mercadorias}">
                        merc = new Mercadoria();
                    
                        merc.quantidade = ${merc.quantidade};
                        merc.valorUnitario = ${merc.valor};
                        merc.produto = "${merc.produto.descricao}";
                        merc.produtoId = ${merc.produto.id};
                    
                        listaMercadoria[indexMerc++] = merc;
            </c:forEach>            
                        nf.listaMercadoria = listaMercadoria;
                        if (pai.isExisteNFe != null && pai.isExisteNFe != undefined && pai.isExisteNFe(nf.chaveNFe)) {
                                alert("Esta 'NF-e' já foi importada!");
                            
                            //                }else if(nf.isExiste){
                            //                    alert("A nota de numero \'"+nf.numero+"\' e serie \'"+nf.serie+"\' do remetente \'"+ctrc.destinatario.razaoSocial+"\' já consta no sistema!");
                        }else {
                            if ($("layoutArquivo").value == "cteConfirmadoXML") {
                                if (pai.prepararAddCtrc != null && pai.prepararAddCtrc != undefined) {
                                        pai.prepararAddCtrc(ctrc, nf, perguntarAddVariasNotasCtrc, isAgrupar, isConsiderarPedidoAgrupamento, isConsiderarCtrcRedespacho);
                                    }
                        }else
                            if (pai.prepararAddCtrc != null && pai.prepararAddCtrc != undefined) {
                                pai.prepararAddCtrc(ctrc, nf, perguntarAddVariasNotasCtrc, isAgrupar, isConsiderarPedidoAgrupamento, isConsiderarCtrcRedespacho);
                            }else if(pai.$("id_janela").value == "jspcadconhecimento"){
                                
                                if (((pai.$('rem_rzs').value != '' && pai.$('rem_rzs').value != ctrc.remetente.razaoSocial && pai.$("idremetente").value != ctrc.remetente.id) || 
                                        (pai.$('dest_rzs').value != '' && pai.$('dest_rzs').value != ctrc.destinatario.razaoSocial && pai.$("iddestinatario").value != ctrc.destinatario.id))){
                                    if ("${configuracao.validacaoCteXmlOutrosDestinatarios}"== "b") {
                                        alert('ATENÇÃO: O cliente informado na nova Nota é diferente do(s) selecionado(s) anteriormente. Por conta disso a nota não será adicionada.');
                                        return false;
                                    } else if ("${configuracao.validacaoCteXmlOutrosDestinatarios}"== "a"){
                                        alert('ATENÇÃO: O cliente informado na nova Nota é diferente do(s) selecionado(s) anteriormente.');
                                    }
                                }
                                
                                
                                //dados do remetente
                                
                                /**
                                 * Como esses campos não evidenciam o remetente e sempre são alterados quando escolhido, remetente, destinatario, consig.... preferi não manipula-los
                                 * 
                                    pai.$('id_rota_viagem').value = ctrc.remetente.id_rota_viagem;
                                    pai.$('rota_viagem').value = ctrc.remetente.rota_viagem;
                                    pai.$('distancia_km').value = ctrc.remetente.distanciakm;
                                    pai.$('prazo_rota').value = ctrc.remetente.prazo_rota;
                                    pai.$('tipo_prazo_rota').value = ctrc.remetente.tipo_prazo_rota;
                                    
                                 **/  
                                 
                                pai.$("rem_codigo").value = ctrc.remetente.id;
                                pai.$("idremetente").value = ctrc.remetente.id; 
                                pai.$("rem_rzs").value = ctrc.remetente.razaoSocial;
                                
                                //Adicionar remetente quando for importar mais de um xml, vai servir para comparação na página pai
                                if(pai.$("rem_rzs_anterior").value == ""){
                                    pai.$("rem_rzs_anterior").value = ctrc.remetente.razaoSocial;
                                }
                                if(pai.$("dest_rzs_anterior").value == ""){
                                    pai.$("dest_rzs_anterior").value = ctrc.destinatario.razaoSocial;
                                }
                                
                               // alert("ctrc.stIcms : " + ctrc.stICMS);
                                pai.$("st_icms").value = ctrc.stICMS;
                               // pai.$("stIcms").value = ctrc.stIcms.id;                                
                                
                                pai.$("rem_cidade").value = ctrc.remetente.cidade;
                                pai.$("rem_uf").value = ctrc.remetente.uf;
                                pai.$("rem_cnpj").value = ctrc.remetente.cnpj;
                                pai.$("rem_pgt").value = ctrc.remetente.qtdDiasPgto;
                                pai.$("rem_tipotaxa").value = ctrc.remetente.tipoTabela;
                                pai.$("venremetente").value = ctrc.remetente.vendedor.razaoSocial;
                                pai.$("idvenremetente").value = ctrc.remetente.vendedor.id;
                                pai.$('vlvenremetente').value = ctrc.remetente.percComissaoVendedor;
                                pai.$("idcidadeorigem").value = ctrc.remetente.cidadeId;
                                pai.$("remidcidade").value = ctrc.remetente.cidadeId;
                                pai.$("remtipofpag").value = ctrc.remetente.tipoPgto;
                                pai.$("remtipoorigem").value = ctrc.remetente.tipoOrigemFrete;
                                pai.$("rem_endereco").value = ctrc.remetente.endereco +", "+ ctrc.remetente.logradouro + " - " + ctrc.remetente.bairro + " " + ctrc.remetente.complemento;  
                                pai.$("remtabelaproduto").value = ctrc.remetente.obrigaTabelaTipoProduto;
                                pai.$("rem_inclui_peso_container").value = ctrc.remetente.incluiPesoContainer;
                                pai.$("rem_tabela_remetente").value = ctrc.remetente.utilizarTabelaRemetente;
                                pai.$("rem_obs").value = ctrc.remetente.obs;
                                pai.$("pauta_remetente").value = ctrc.remetente.utilizaPautaFiscal;
                                pai.$("rem_tipo_cfop").value = ctrc.remetente.tipoCfop;
                                pai.$("rem_st_mg").value = ctrc.remetente.isStMg;
                                pai.$("rem_st_icms").value = ctrc.remetente.stIcms;
                                pai.$("st_icms").value = ctrc.remetente.stIcms;
                                pai.$('rem_unificada_modal_vendedor').value = ctrc.remetente.unificadaModalVendedor;
                                pai.$('rem_comissao_rodoviario_fracionado_vendedor').value = ctrc.remetente.percComissaoRodoviarioFracionadoVendedor;
                                pai.$('rem_comissao_rodoviario_lotacao_vendedor').value = ctrc.remetente.percComissaoRodoviarioLotacaoVendedor;
                                pai.$('rem_is_bloqueado').value = ctrc.remetente.isCreditoBloqueado;
                                pai.$("rem_analise_credito").value = ctrc.remetente.isAnaliseCredito;
                                pai.$("rem_valor_credito").value = ctrc.remetente.creditoDisponivel;
                                pai.$("utilizatipofretetabelarem").value = ctrc.remetente.utilizaTipoFreteTabela;
                                pai.$("is_utilizar_tipo_frete_tabela").value = ctrc.remetente.utilizaTipoFreteTabela;
                                pai.aoClicarNoLocaliza('Remetente');

                                //destinatario
                                pai.$("des_codigo").value = ctrc.destinatario.id;
                                pai.$("iddestinatario").value = ctrc.destinatario.id;
                                pai.$("dest_rzs").value = ctrc.destinatario.razaoSocial;
                                pai.$("dest_cidade").value = ctrc.destinatario.cidade;
                                pai.$("dest_uf").value = ctrc.destinatario.uf;
                                pai.$("dest_insc_est").value = ctrc.destinatario.inscEst;
                                pai.$("dest_cnpj").value = formatCpfCnpj(ctrc.destinatario.cnpj,true,true);
                                pai.$("dest_tipotaxa").value = ctrc.destinatario.tipoTabela;
                                pai.$("desttipofpag").value = ctrc.destinatario.tipoPgto;
                                pai.$("aliquota").value = 0;
                                pai.$("desttipoorigem").value = ctrc.destinatario.tipoOrigemFrete;
                                pai.$("desttabelaproduto").value = ctrc.destinatario.obrigaTabelaTipoProduto;                                
                                pai.$("dest_endereco").value = ctrc.destinatario.endereco +", "+ ctrc.destinatario.logradouro + " - " + ctrc.destinatario.bairro + " " + ctrc.destinatario.complemento;  
                                pai.$("dest_obs").value = ctrc.destinatario.obs;
                                pai.$("des_inclui_tde").value = ctrc.destinatario.isIncluirTde;
                                pai.$("des_inclui_peso_container").value = ctrc.destinatario.incluiPesoContainer;
                                pai.$("vendestinatario").value = ctrc.destinatario.vendedor.razaoSocial;
                                pai.$("idvendestinatario").value = ctrc.destinatario.vendedor.id;
                                pai.$('vlvendestinatario').value = ctrc.destinatario.percComissaoVendedor;
                                pai.$("dest_pgt").value = ctrc.destinatario.qtdDiasPgto;
                                pai.$('des_unificada_modal_vendedor').value = ctrc.destinatario.unificadaModalVendedor;
                                pai.$('des_comissao_rodoviario_fracionado_vendedor').value = ctrc.destinatario.percComissaoRodoviarioFracionadoVendedor;
                                pai.$('des_comissao_rodoviario_lotacao_vendedor').value = ctrc.destinatario.percComissaoRodoviarioLotacaoVendedor;
                                pai.$("des_analise_credito").value = ctrc.destinatario.isAnaliseCredito;
                                pai.$("des_valor_credito").value = ctrc.destinatario.creditoDisponivel;
                                pai.$("des_is_bloqueado").value = ctrc.destinatario.isCreditoBloqueado;
                                pai.$("des_st_icms").value = ctrc.destinatario.stIcms;
                                pai.$("st_icms").value = ctrc.destinatario.stIcms;
                                pai.$("des_tabela_remetente").value = ctrc.destinatario.utilizarTabelaRemetente;
                                pai.$("pauta_destinatario").value = ctrc.destinatario.utilizaPautaFiscal;
                                pai.$("utilizatipofretetabeladest").value = ctrc.destinatario.utilizaTipoFreteTabela;
                                pai.$("is_utilizar_tipo_frete_tabela").value = ctrc.destinatario.utilizaTipoFreteTabela;
                                //pai.$("des_inclui_peso_container").value = $("des_inclui_peso_container_"+id).value;
                                pai.$("des_tipo_cfop").value = ctrc.destinatario.tipoCfop;
                                //cidade de destino
//                                pai.$("idcidadedestino").value = ctrc.destinatario.cidadeId;
//                                pai.$("cid_destino").value = ctrc.destinatario.cidade;
//                                pai.$("uf_destino").value = ctrc.destinatario.uf;
//                                pai.$("cidade_destino_id").value = ctrc.destinatario.cidadeId;
//                                
                                pai.$("idcidadedestino").value = ctrc.idCidadeDestino;
                                pai.$("cid_destino").value = ctrc.cidadeDestino;
                                pai.$("uf_destino").value = ctrc.ufDestino;
                                pai.$("cidade_destino_id").value = ctrc.idCidadeDestino;
//                                pai.$("dest_cidade").value = ctrc.cidadeDestino;
//                                pai.$("dest_uf").value = ctrc.ufDestino;
                                //ctrcs
                                pai.$('taxa_roubo').value = formatoMoeda(ctrc.taxaRoubo);
                                pai.$('taxa_roubo_urbano').value = formatoMoeda(ctrc.taxaRouboUrbano);
                                pai.$('taxa_tombamento').value = formatoMoeda(ctrc.taxaTombamento);
                                pai.$('taxa_tombamento_urbano').value = formatoMoeda(ctrc.taxaTombamentoUrbano);
                                pai.aoClicarNoLocaliza('Destinatario');
//                                pai.localizaRemetenteCodigo("idcliente", ctrc.remetente.id);
//                                pai.localizaDestinatarioCodigo("idcliente", ctrc.destinatario.id);
                                if (ctrc.isRedespacho) {
                                    console.trace();
                                    pai.$("ck_redespacho").checked = ctrc.isRedespacho;
                                    alert("ctrc.isRedespacho");
                                    pai.redespacho(true,true);
                                    pai.$("ctoredespacho").value = ctrc.redespachoCtrc;
                                    pai.$("redespacho_valor").value = ctrc.redespachoValor;
                                    pai.$("redespacho_valor_icms").value = ctrc.redespachoValorIcms;
                                    pai.$("red_codigo").value = ctrc.redespacho.id;
                                    pai.$("idredespacho").value = ctrc.redespacho.id; 
                                    pai.$("red_rzs").value = ctrc.redespacho.razaoSocial;
                                    pai.$("red_cidade").value = ctrc.redespacho.cidade;
                                    pai.$("red_uf").value = ctrc.redespacho.uf;
                                    pai.$("red_cnpj").value = ctrc.redespacho.cnpj;
                                    pai.$("red_chave_acesso").value = ctrc.redespachoChaveAcesso;
                                    pai.$("red_is_bloqueado").value = ctrc.redespacho.isCreditoBloqueado;
                                    pai.$("red_analise_credito").value = ctrc.redespacho.isAnaliseCredito;
                                    pai.$("red_valor_credito").value = ctrc.redespacho.creditoDisponivel;
                                    pai.$("red_tipotaxa").value = ctrc.redespacho.tipoTabela;
                                    pai.$("idvenredespacho").value = ctrc.redespacho.vendedor.id;
                                    pai.$('vlvenredespacho').value = ctrc.redespacho.percComissaoVendedor;
                                    pai.$("red_pgt").value = ctrc.redespacho.qtdDiasPgto;
                                    pai.$('red_unificada_modal_vendedor').value = ctrc.redespacho.unificadaModalVendedor;
                                    pai.$('red_comissao_rodoviario_fracionado_vendedor').value = ctrc.redespacho.percComissaoRodoviarioFracionadoVendedor;
                                    pai.$('red_comissao_rodoviario_lotacao_vendedor').value = ctrc.redespacho.percComissaoRodoviarioLotacaoVendedor;
                                    pai.$("redtipofpag").value = ctrc.redespacho.tipoPgto;
                                    pai.$("red_st_icms").value = ctrc.redespacho.stIcms;
                                    pai.$("st_icms").value = ctrc.redespacho.stIcms;
                                    pai.$("red_tabela_remetente").value = ctrc.redespacho.utilizarTabelaRemetente;
                                    pai.$("utilizatipofretetabelared").value = ctrc.redespacho.utilizaTipoFreteTabela;
                                    pai.$("is_utilizar_tipo_frete_tabela").value = ctrc.redespacho.utilizaTipoFreteTabela;
                                    pai.$("pauta_redespacho").value = ctrc.redespacho.utilizaPautaFiscal;
                                    pai.aoClicarNoLocaliza('Redespacho');
                                }
                                
                                if (${param.isDadosMotoristaS} == true) {
                                    if ("${ctrc.veiculo.idveiculo}" != "0") {
                                        pai.$("vei_placa").value = "${ctrc.veiculo.placa}";
                                        pai.$("idveiculo").value = "${ctrc.veiculo.idveiculo}";
                                        pai.$("motor_nome").value = "${ctrc.motorista.nome}";
                                        pai.$("idmotorista").value = "${ctrc.motorista.idmotorista}";
                                        pai.$("car_placa").value = "${ctrc.carreta.placa}";
                                        pai.$("idcarreta").value = "${ctrc.carreta.idveiculo}";
                                        pai.$("bi_placa").value = "${ctrc.biTrem.placa}";
                                        pai.$("idbitrem").value = "${ctrc.biTrem.idveiculo}";
                                    }else{
                                        alert("O veiculo com placa '${ctrc.veiculo.placa}' não foi encontrado!");
                                    }
                                }else{
                                    pai.$("vei_placa").value = "";
                                    pai.$("idveiculo").value = "0";
                                    pai.$("motor_nome").value = "";
                                    pai.$("idmotorista").value = "0";
                                    pai.$("car_placa").value = "";
                                    pai.$("idcarreta").value = "0";
                                    pai.$("bi_placa").value = "";
                                    pai.$("idbitrem").value = "0";
                                    
                                }
                                //pai.$('contabelaproduto').value = ctrc.destinatario.isTabelaTipoProduto;
                                if (ctrc.modFrete == 0) {
                                    
                                    pai.setFretePago(true);
                                }else{
                                    pai.setFretePago(false);
                                }
                                if ("${param.fontePreco}" == "a") {
                                    pai.$("tipotaxa").value = "3";
                                    pai.$("valor_frete").value = "${ctrc.valorFrete}";
                                    pai.recalcular(false);
                                }
                                if (pai.addNote != null && pai.addNote != undefined) {
                                    var elemento = null;
                                    var indiceNote = 0;
                                    var idColeta = 0;
                                    if (pai.getNextIndexFromTableRoot != null && pai.getNextIndexFromTableRoot != undefined) {
                                        indiceNote = pai.getNextIndexFromTableRoot(idColeta, "tableNotes0");
                                    }
                                    var sufixID = indiceNote +"_id" + idColeta;
                                    elemento = pai.addNote(
                                        idColeta, //idColeta,
                                        "tableNotes0",//idTableRoot, 
                                        0,//idnota
                                        nf.numero,//numero, 
                                        nf.serie,//serie, 
                                        (nf.dataEmissao == "" ? pai.dataAtual : nf.dataEmissao),//emissao,
                                        nf.valor,//valor, 
                                        nf.baseCalculoIcm, //vl_base_icms,
                                        nf.icmsValor, //vl_icms,
                                        nf.icmsST, //vl_icms_st,
                                        nf.icmsFrete, //vl_icms_frete,
                                        nf.peso, //peso,
                                        nf.volume, //volume, 
                                        nf.embalagem,//embalagem, 
                                        nf.conteudo,//descricao_produto,
                                        0, //idCTRC, 
                                        nf.pedido,//pedido, 
                                        false, //readOnly,
                                        0, //largura, 
                                        0, //altura, 
                                        0, //comprimento,
                                        nf.metroCubico, //metroCubico, 
                                        nf.marcaId, //idMarcaVeiculo, 
                                        nf.marca,//marcaVeiculo,
                                        nf.modelo,//modeloVeiculo, 
                                        nf.ano,//anoVeiculo, 
                                        nf.cor,//corVeiculo,
                                        nf.chassi,//chassiVeiculo,
                                        0, //maxItens,
                                        false, //isPossuiItens,
                                        nf.cfopId, //cfopId,
                                        nf.cfop,//cfop
                                        nf.chaveNFe,//chaveNFe,
                                        nf.isAgendado, //isAgendado, 
                                        nf.dataAgenda,//dataAgenda, 
                                        nf.horaAgenda,//horaAgenda,
                                        nf.observacao,//obsAgenda, 
                                        false, //isBaixaNota, 
                                        nf.dataPrevisao,//previsaoEntrega, 
                                        nf.horaPrevisao,//previsaoAs,
                                        ctrc.destinatario.id, //idDestinatario, 
                                        ctrc.destinatario.razaoSocial,//destinatario, 
                                        false, //isEdi,
                                        (nf.listaCuabagem == null || nf.listaCuabagem == undefined ? 0 : nf.listaCuabagem.length), //maxItensMetro, 
                                        0, //minutaId, 
                                        nf.tipoDocumento//tpDoc
                                        );
                                        //variavel responsavel por contar as notas
                                    pai.countIdxNotes++;
                                    var alturaTot = 0;
                                    var larguraTot = 0;
                                    var comprimentoTot = 0;
                                    var volumeTot = 0;
                                    var itemCub = null;
                                    if (nf.listaCuabagem != null && nf.listaCuabagem != undefined && elemento != null && elemento != undefined) {
                                        try {
                                            for (var c = 0; c < nf.listaCuabagem.length; c++) {
                                                var metroCub = roundABNT(parseFloat(nf.listaCuabagem[c].altura) * parseFloat(nf.listaCuabagem[c].largura) * parseFloat(nf.listaCuabagem[c].comprimento) * parseFloat(nf.listaCuabagem[c].volume), 4);
                                                pai.addUpdateNotaFiscal3('trNote'+elemento,
                                                0,
                                                0,
                                                sufixID,
                                                metroCub,
                                                nf.listaCuabagem[c].altura,
                                                nf.listaCuabagem[c].largura,
                                                nf.listaCuabagem[c].comprimento,
                                                nf.listaCuabagem[c].volume,
                                                nf.listaCuabagem[c].etiqueta,
                                                c);
                                                
                                                alturaTot += parseFloat(nf.listaCuabagem[c].altura);
                                                larguraTot += parseFloat(nf.listaCuabagem[c].largura);
                                                comprimentoTot += parseFloat(nf.listaCuabagem[c].comprimento);
                                                volumeTot += parseFloat(nf.listaCuabagem[c].volume);
                                            }
                                            
                                            if (pai.updateSum != null && pai.updateSum != undefined) {
                                                pai.updateSum(true);
                                            }
                                        } catch (e) {
                                            console.log(e);
                                            alert("Erro ao adicionar cubagem.");
                                        }
                                        
                                        pai.$("volume").value = roundABNT(volumeTot, 4);
                                        
//                                        pai.alterouCampoDependente("cub_comprimento");
                                        pai.sumMetroNotes("0");
                                    }
                                    if (pai.applyEventInNote != null && pai.applyEventInNote != undefined && elemento != null && elemento != undefined) {
                                        pai.applyEventInNote();
                                    }
                                }
                                
                                pai.$("vlmercadoria").value = pai.sumValorNotes('0');
                                
                                //                                pai.alterouCampoDependente("vlmercadoria");
                                if ("${configuracao.cartaFreteAutomatica}"== "true") {
                                    pai.calcularFreteCarreteiro();
                                }
                                pai.$("peso").value = pai.sumPesoNotes('0');
                                //                                pai.alterouCampoDependente("peso");
                                pai.$("volume").value = pai.sumVolumeNotes('0');
                                
                                //                                pai.alterouCampoDependente("volume");
                                //                                pai.alterouCampoDependente("cub_base");
                                //                                pai.alterouCampoDependente("cub_altura");
                                //                                pai.alterouCampoDependente("cub_largura");
                                //                                pai.alterouCampoDependente("cub_comprimento");
                                //                                pai.alterouCampoDependegtjnte("cub_metro");
                                //                                pai.getStIcmsConsig();
                                pai.getCidadeOrigem();
                                pai.getDadosIcms();
                                pai.getTipoProdutos();
                                pai.calculaPesoTaxado();
                                pai.calculaPesoTaxadoCtrc();

                                
                                pai.alteraTipoTaxa(pai.$("tipotaxa").value);
                                pai.calculaVlRedespachante();
                                
                                
                                if(ctrc.destinatario.id==0){
                                     if (confirm("Destinatário é do exterior e não é possível realizar o cadastro do mesmo. Deseja realizar o cadastro agora?")){
                                       
                                            window.open('./cadcliente?acao=cadastroExterior&rzs='+ctrc.destinatario.razaoSocial+
                                                    '&endereco='+ctrc.destinatario.endereco+
                                                    '&uf='+ctrc.destinatario.uf+
                                                    '&cidade='+ctrc.destinatario.cidade.descricaoCidade+
                                                    '&idcidade='+ctrc.destinatario.cidade.idcidade+
                                                    '&cep='+ctrc.destinatario.cep+
                                                    '&compl='+ctrc.destinatario.complemento+  '',                                                  
                                                    'Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                        }
                                } 
                                
                               
                                
                                if(ctrc.remetente.id==0){
                                     if (confirm("Rementente é do exterior e não é possível realizar o cadastro do mesmo. Deseja realizar o cadastro agora?")){
                                            window.open('./cadcliente?acao=cadastroExterior&rzs='+ctrc.remetente.razaoSocial+
                                                    '&endereco='+ctrc.remetente.endereco+
                                                    '&uf='+ctrc.remetente.uf+
                                                    '&cidade='+ctrc.remetente.cidade.descricaoCidade+
                                                    '&idcidade='+ctrc.remetente.cidade.idcidade+
                                                    '&cep='+ctrc.remetente.cep+
                                                    '&compl='+ctrc.remetente.complemento+  '',                                                  
                                                    'Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                                        }
                                } 
                                
                            }
                        }
        </c:forEach>            
    </c:forEach>
    <c:if test="${ctrcs != null}">
             window.close();
    </c:if>
                alterarLayout($("layoutArquivo").value);
            }catch(ex){
                if (!isIE()) {
                    console.log(ex);
                    console.log("ERRO AO CARREGAR AS INFORMAÇOES:"+ex);
                }
                alert(ex);
                console.log(ex);
            }
        }

    function ajaxCarregarCaptcha(atualiza){
        atualiza = (atualiza != null && atualiza != undefined ? atualiza : false);
        $("captcha").value = "";
        $("imgCaptcha").src = "";
        tryRequestToServer(
        function(){
            espereEnviar("Aguarde...", true);
            new Ajax.Request("ConhecimentoControlador?acao=iniciarConsultarNFe",{method:'post', 
                onSuccess: e, 
                onFailure: e
            });
        }

    );


        function e(transport){
            try {

                if (transport != null && transport.responseText != "") {
                    if (transport.responseText.indexOf("ERRO") > -1) {
                        alert(transport.responseText);
                        espereEnviar("Aguarde...", false);
                        return false;
                    }else{
                        var imgCaptcha = replaceAll(transport.responseText, "\\", "");
                        $("imgCaptcha").src = imgCaptcha;
                        espereEnviar("Aguarde...", false);
                        if (atualiza) {
                            $("imgCaptcha").src = "";
                            document.location.reload();
                        }
                        $("captcha").focus();
                    }
                }
            } catch (e) { 
                alert(e);
            }

        }
    }
    
    function alterarAgrupamento(valor){
        try {
            if (valor == "f") {
                invisivel($("trIsAgruparPedido"));
            } else {
                visivel($("trIsAgruparPedido"));
            }
        } catch (e) {
            console.log(e);
        }
    }
    
    function alterarAgrupamento(valor){
        try {
            if (valor == "f") {
                invisivel($("trIsAgruparPedido"));
            } else {
                visivel($("trIsAgruparPedido"));
            }
        } catch (e) {
            console.log(e);
        }
    }
    
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Importação de Conhecimento (EDI,XML,DANFE)</title>
    </head>
    <body onload="applyFormatter();carregar();mostrarRedespacho();mostrarRepresentante();">
        <img src="img/banner.gif" >
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="82%" align="left"><b>Importação de Conhecimento (EDI,XML,DANFE)</b></td>
                <td>
                    <input type="button" value=" Fechar " class="inputbotao" onclick="window.onbeforeunload = null;fechar();"/>
                </td>
            </tr>
        </table>
        <br/>        
        <form method="post" id="formularioFilho" enctype="multipart/form-data" >
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela" >
                    <td colspan="10">Seleção do Layout</td>
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td width="15%" align="right">
                        <label>Escolha o Layout:</label>                                
                    </td>
                    <td width="25%" align="left">
                        <select name="layoutArquivo" id="layoutArquivo" class="inputTexto"  
                                style="width: 200px;" onchange="alterarLayout(this.value);">
                            <option value="nfe">NF-e (XML)</option>
                            <option value="nfeChaveAcesso">NF-e (Chave de Acesso)</option>
                            <option value="cteXML">CT-e Redespacho (XML)</option>
                            <c:if test="${param.tipoImportacao != 'unico'}">
                                <option value="cteConfirmadoXML">CT-e confirmado por outra aplicação (XML)</option>
                                <option value="gsm">GSM (gwLogis)</option>
                                <option value="gwConferencia">Gw Confrencia</option>
                                <option value="eFacil">SETCESP-COTIN (eFacil)</option>
                                <option value="mobly">SETCESP-COTIN (Mobly)</option>
                                <option value="ricardoEletro">SETCESP-COTIN (Ricardo Eletro)</option>
                                <option value="ipiranga">Ipiranga</option>
                                <option value="itatiaia">Itatiaia</option>
                                <option value="jetClass">JetClass(Maxxi)</option>
                                <option value="jamef">JAMEF</option>
                                <option value="terphane">Terphane</option>
                                <option value="neogrid">NeoGrid</option>
                                <option value="alpargatas">Alpargatas</option>
                                <option value="proceda30A">Proceda (3.0A)</option>
                                <option value="proceda30B">Proceda (3.0B)</option>
                                <option value="procedaDisplan">Proceda (3.0A - Displan)</option>
                                <option value="proceda30Ahermes">Proceda (3.0A - Hermes)</option>
                                <option value="proceda31Marilan">Proceda (3.1)</option>
                                <option value="proceda31ComChaveAcesso">Proceda (3.1 - Chave de Acesso)</option>
                                <option value="proceda31Alianca">Proceda (3.1 - Aliança)</option>
                                <option value="proceda31CiaTecidosSantoAntonio">Proceda (3.1 - Cia de Tecidos Santo Antônio)</option>
                                <option value="proceda31Cafe3Coracoes">Proceda (3.1 - Café 3 Corações)</option>
                                <option value="proceda31DestSantaCruz">Proceda (3.1 - DIST.MED.SANTA CRUZ)</option>
                                <option value="procedaDanone">Proceda (3.1 - Danone)</option>
                                <option value="proceda31Fujioka">Proceda (3.1 - Fujioka)</option>
                                <option value="procedaDelVale">Proceda (3.1 - Del Vale)</option>
                                <option value="proceda31Jequiti">Proceda (3.1 - Jequiti)</option>                                
                                <option value="proceda31Masterfoods">Proceda (3.1 - Masterfoods)</option>
                                <option value="proceda31MDias">Proceda (3.1 - M. Dias)</option>
                                <option value="proceda31MelhoramentoCPNC">Proceda (3.1 - Melhoramento CPNC)</option>
                                <option value="proceda31LojasAmericanas">Proceda (3.1 - Lojas Americanas)</option>
                                <option value="proceda31Philips">Proceda (3.1 - Philips)</option>
                                <option value="proceda50Ramthun">Proceda (5.0 CONEMB - RAMTHUN)</option>
                                <option value="procedaQuero">Proceda (QUERO)</option>
                                <option value="redespRapidaoCometa">Redespacho (Rapidão Cometa)</option>
                                <option value="hermes">Padrão Hermes (Excel)</option>
                                <option value="tavex">Tavex</option>
                                <option value="tivit50">Tivit (5.0)</option>
                                <option value="whirlpool">Whirlpool</option>
                                <option value="webserviceNDDAvon">Avon (Web Service)</option>
                            </c:if>
                        </select>
                    </td>
                    <td id="tdInput" width="60%" align="left" colspan="2">
                        Escolha o Arquivo:<input name="arq01[]" id="arq01" type="file" multiple="multiple"  class="inputTexto" size="50" />
                    </td>       
                    <td id="tdDtEmissao1" align="right" style="display: none">
                        Data de Emissão das Notas:
                    </td>
                    <td id="tdDtEmissao2" align="left" style="display: none" >
                        <input type="text" id="dtEmissao"  name="dtEmissao" class="fieldDateMin" maxlength="10" size="12" onBlur="alertInvalidDate(this)"  />
                    </td>
                    <td id="tdChaveAcessoNFe1" align="right" style="display: none">
                        Digite a Chave de Acesso:
                    </td>
                    <td id="tdChaveAcessoNFe2" align="left" style="display: none">
                        <input name="chaveAcessoNFe" id="chaveAcessoNFe" type="text" class="inputTexto" size="60"  />
                    </td>
                    <td id="tdGSM1" align="right" style="display: none">
                        Informe a GSM:
                    </td>
                    <td id="tdGSM2" align="left" style="display: none">
                        <input name="numeroGSM" id="numeroGSM" type="text" class="inputReadOnly8pt" size="15"  />
                        <input name="idGSM" id="idGSM" type="hidden" class="inputTexto" size="60"  />
                        <input name="btLocGSM" id="btLocGSM" type="button" class="inputBotaoMin" onclick="abrirLocalizarGSM();" value="..." />
                    </td>
                    <td id="tdCarga1" align="right" style="display: none">
                        Informe a Carga:
                    </td>
                    <td id="tdCarga2" align="left" style="display: none">
                        <input name="numeroCarga" id="numeroCarga" type="text" class="inputReadOnly8pt" size="15"  />
                        <input name="idCarga" id="idCarga" type="hidden" class="inputTexto" size="60"  />
                        <input name="btLocCarga" id="btLocCarga" type="button" class="inputBotaoMin" onclick="abrirLocalizarCarga();" value="..." />
                    </td>
                </tr>
                <tr id="trCaptcha" style="display: none">
                    <td class="TextoCampos">Digite os caracteres ao lado:</td>
                    <td class="celulaZebra2" >
                        <input id="captcha" name="captcha" value="" class="inputTexto" />
                    </td>
                    <td class="CelulaZebra2NoAlign" align="center" colspan="2">
                        <img alt="" src="" id="imgCaptcha">
                        <!--<img alt="atualiza" src="img/atualiza.png" id="atualiza" onclick="ajaxCarregarCaptcha(true);">-->
                        <br>Se os caracteres da imagem estiverem ilegíveis,
                        <span class="linkEditar" onClick="ajaxCarregarCaptcha();">gerar outra imagem</span>.
                    </td>
                </tr>
            </table>    
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela" >
                    <td colspan="4">Informações da Importa&ccedil;&atilde;o</td>
                </tr>
                <tr id="trRemetente">
                    <td class="TextoCampos">O arquivo importado pertence ao remetente:</td>                                
                    <td colspan="3" class="celulaZebra2" >
                        <input name="rem_rzs" id="rem_rzs" type="text" class="inputReadOnly8pt" readonly="true" size="40" value="" />
                        <input name="idremetente" id="idremetente" type="hidden" value="" />
                        <input name="btLocRem" id="btLocRem" type="button" class="inputBotaoMin" onclick="abrirLocalizarRemetente();" value="..." />
                    </td>                                
                </tr>
                <tr>
                    <td width="25%" class="TextoCampos">
                        <input name="isRedespacho" id="isRedespacho" type="checkbox" onclick="mostrarRedespacho()" value="" />
                        Esse arquivo foi enviado pelo Redespacho:
                    </td>
                    <td width="25%" class="CelulaZebra2">
                        <input name="red_rzs" id="red_rzs" type="text" class="inputReadOnly8pt" readonly="true" size="37" value="" />
                        <input name="idredespacho" id="idredespacho" type="hidden" value="" />
                        <input name="btLocRedesp" id="btLocRedesp" type="button" class="inputBotaoMin" onclick="abrirLocalizarRedespacho();" value="..." />
                        <br>
                        <!--Definir como Consignatário:-->
                    </td>
                    <td width="25%" class="TextoCampos">
                        <input name="isRepresentante" id="isRepresentante" type="checkbox" onclick="mostrarRepresentante()" value="" />
                        O(s) CT(s) importados serão entregues pelo Representante:
                    </td>
                    <td width="25%" class="CelulaZebra2">
                        <input name="redspt_rzs" id="redspt_rzs" type="text" class="inputReadOnly8pt" readonly="true" size="35" value="" />
                        <input name="idredespachante" id="idredespachante" type="hidden" value="" />
                        <input name="btLocRepre" id="btLocRepre" type="button" class="inputBotaoMin" onclick="abrirLocalizarRepresentante();" value="..." />
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="TextoCampos">
                        <input name="isConsignatario" id="isConsignatario" type="checkbox" onclick="mostrarConsignatario()" value="" />
                        Considerar consignatário para todos os XMLs:
                    </td>
                    <td  class="CelulaZebra2" colspan="2">
                        <input name="con_rzs" id="con_rzs" type="text" class="inputReadOnly8pt" readonly="true" size="37" value="" />
                        <input name="idconsignatario" id="idconsignatario" type="hidden" value="" />
                        <input name="btLocConsig" id="btLocConsig" type="button" class="inputBotaoMin" onclick="abrirLocalizarConsignatario();" value="..." />
                        <br>
                        
                    </td>
                </tr>
                <tr id="trFontePreco" class="CelulaZebra2NoAlign">
                    <td width="40%" colspan="2" class="TextoCampos">
                        <label>Ao importar, considerar como o valor do frete:</label>
                    </td>                                
                    <td width="60%" colspan="2" class="celulaZebra2" >                                                   
                        <label><input name="fontePreco" id="fontePrecoTabela" checked="true" value="t" type="radio">O cálculo da tabela de preço</label>
                        <label><input name="fontePreco" id="fontePrecoArquivo" value="a" type="radio">O valor informado no arquivo</label>                                                    
                    </td>                                
                </tr>
                <c:if test="${param.tipoImportacao != 'unico'}">
                    <tr id="isAgruparCte">
                        <td colspan="3" class="TextoCampos">
                            <label>Caso existam Notas Fiscais para o mesmo remetente e destinatario, deseja agrupa-las no mesmo CT-e?</label>
                        </td>                                
                        <td colspan="1" class="celulaZebra2" >
                            <label ><input name="isAgrupar" id="isAgruparS" checked="true" value="t" type="radio" onclick="alterarAgrupamento(this.value)">SIM</label>
                            <label ><input name="isAgrupar" id="isAgruparN" value="f" type="radio" onclick="alterarAgrupamento(this.value)">NÃO</label>                                                    
                        </td>                                
                    </tr>
                    <tr id="trIsAgruparPedido">
                        <td colspan="3" class="TextoCampos">
                            <label>Gerar um CT-e para cada numero de pedido?</label>
                        </td>                                
                        <td colspan="1" class="celulaZebra2" >
                            <label ><input name="isAgruparPedido" id="isAgruparPedidoS" value="t" type="radio">SIM</label>
                            <label ><input name="isAgruparPedido" id="isAgruparPedidoN" checked="true" value="f" type="radio">NÃO</label>                                                    
                        </td>                                
                    </tr>
                    <tr >
                        <td colspan="3" class="TextoCampos">
                            <label>Considerar o Grupo de clientes ao localizar o produto?</label>
                        </td>                                
                        <td colspan="1" class="celulaZebra2" >
                            <label ><input name="isGrupoCliProd" id="isGrupoCliProdS" checked="true" value="t" type="radio">SIM</label>
                            <label ><input name="isGrupoCliProd" id="isGrupoCliProdN" value="f" type="radio">NÃO</label>                                                    
                        </td>                                
                    </tr>
                </c:if>
                <tr id="trTransport" class="CelulaZebra2NoAlign">
                    <td colspan="3" class="TextoCampos">
                        <label>Importar arquivos apenas da filial selecionada:</label>
                    </td>                                
                    <td class="celulaZebra2" >                                                   
                        <label ><input name="isApenasTransp" id="isApenasTranspS" checked="true" value="t" type="radio">SIM</label>
                        <label ><input name="isApenasTransp" checked="" id="isApenasTranspN" value="f" type="radio">NÃO</label>
                    </td>                                
                </tr>
                <tr id="trDadosVeiculo" class="CelulaZebra1NoAlign" >
                        <td colspan="3" class="TextoCampos">
                            <label>Utilizar os dados do ve&iacute;culo do xml?</label>
                        </td>
                        <td class="celulaZebra2">
                            <label ><input name="isDadosMotorista" id="isDadosMotoristaS" checked="true" value="t" type="radio">SIM</label>
                            <label ><input name="isDadosMotorista" checked="" id="isDadosMotoristaN" value="f" type="radio">NÃO</label>
                        </td>
                    </tr>
                <tr id="trUnicoDestinatario" class="CelulaZebra1NoAlign">
                    <td width="25%" class="TextoCampos">
                        <label>
                        <input name="isMesmoDest" id="isMesmoDest" type="checkbox" onclick="" value="" />
                        Definir um destinatário para todas as notas
                        </label>
                    </td>
                    <td class="celulaZebra2">
                        <input name="dest_rzs" id="dest_rzs" type="text" class="inputReadOnly8pt" readonly="true" size="30" value="" />
                        <input name="iddestinatario" id="iddestinatario" type="hidden" value="" />
                        <input name="btLocDestinatario" id="btLocDestinatario" type="button" class="inputBotaoMin" onclick="abrirLocalizarDestinatario();" value="..." />
                    </td>
                    <td class="celulaZebra2" colspan="2"></td>
                </tr>
            </table>    
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela">
                    <td colspan="8">Informações ao Cadastrar o Destinatário</td>
                </tr>
                <tr>
                    <td width="10%" class="TextoCampos" align="right" >Tipo tabela:</td>
                    <td width="15%" class="celulaZebra2">
                        <select class="inputTexto" id="tipoTabela" name="tipoTabela" >
                            <option value="-1">-- Selecione --</option>
                            <option value="0">Peso/Kg</option>
                            <option value="1">Peso/Cubagem</option>
                            <option value="2">% Nota Fiscal</option>
                            <option value="3">Combinado</option>
                            <option value="4">Por volume</option>
                            <option value="5">Por Km</option>
                            <option value="6">Por Pallet</option>
                        </select>
                    </td>
                    <td width="15%" class="TextoCampos" >Utilizar Tabela do Remetente:</td>
                    <td width="10%" class="celulaZebra2">
                        <select class="inputTexto" id="utilizarTabelaRemetente" name="utilizarTabelaRemetente" >
                            <option value="n" selected>Nunca</option>
                            <option value="s">Sempre</option>
                        </select>
                    </td>
                    <td width="10%" class="TextoCampos" align="right" ></td>
                    <td width="15%" class="celulaZebra2"></td>
                    <td width="10%" class="TextoCampos" align="right" ></td>
                    <td width="15%" class="celulaZebra2"></td>
                </tr>
            </table>
            <table width="90%" align="center" class="bordaFina">
                <tr style="display: none">
                    <td>
                        <table width="100%" border="0">
                            <tr>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign" align="center">                                
                    <td width="100%"  >
                        <input name="btVisualizar" id="btVisualizar" type="button" class="botoes" onclick="tryRequestToServer(function(){anexar();});" value="Importar" />
                    </td>                                
                </tr>
            </table>
        </form>
    </body>
</html>
