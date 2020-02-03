<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
        <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>
        <script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/impostos.js"	type="text/javascript"></script>
        <script language="JavaScript" src="script/shortcut.js"></script>

        <script language="JavaScript" type="text/javascript">     
            //@@@@@@@@@@@@@@@@@@@  CONTROLANDO AS ABAS  
            jQuery.noConflict();
            shortcut.add("enter",function() {pesquisa()});
            function aoClicarNoLocaliza(idJanela){
                try{
                    if (idJanela == "Agregado") {
                        $("agregadoId").value = $("agregado_id").value;
                        $("agregadoCnpj").value = $("agregado_cnpj").value;
                    }
                }catch(ex){
                    alert(ex);
                }
            }
            
            function abrirLocalizarProprietario(){
                popLocate(65,"Agregado");
            }
                
            function baixar(acao){
                
                if($("agregado").value == "" || $("agregadoCnpj").value == ""){
                    alert("Os campos não podem ficar vazio, por favor adicione um agregado.");
                    return false;
                }
                
                var teste = eDate.compare($("dataVencimento").value, $("dataFechamento").value);
                if (teste < 0) {
                    alert("Data de vencimento deve ser maior que a de fechamento!");
                    $("dataVencimento").focus();
                    return false;
                }
                
                try{
                    $("formulario").action = "ContratoFreteControlador?acao=baixarContratosAgregado";
                    setEnv();
            //        window.open('about:blank', 'pop', 'width=210, height=100');
                    $("formulario").submit();
                }catch(ex){
                    alert(ex);
                }
            }
            
            function validarValorSaldo(index){
                var valor = parseFloat(colocarPonto($("totalContasCorrentes_"+ index).value));
                var valorH = parseFloat($("totalContasCorrentesH_"+ index).value);
                
                if (valor <= 0) {
                    showErro("O valor da Conta corrente não pode ser \'0.00\'.", $("totalContasCorrentes_"+ index));
                    $("totalContasCorrentes_"+ index).value = colocarVirgula(valorH);
                }
                if (valor > valorH) {
                    showErro("O valor da Conta corrente não pode ser maior do que o saldo do proprietario.", $("totalContasCorrentes_"+ index));
                    $("totalContasCorrentes_"+ index).value = colocarVirgula(valorH);
                }
                calcularTotal(index);
            }
            
            function calcularTotal(index){
                var totalContratos = $("totalContratos_" + index);
                var totalImpostos = $("totalImpostos_" + index);
                var totalContasCorrentes = $("totalContasCorrentes_" + index);
                var totalFecamento = $("totalFechamento_" + index);
                
                if(totalContratos!= null){
                    var valorTotal = (parseFloat(colocarPonto(totalContratos.value)) - parseFloat(colocarPonto(totalImpostos.value)) 
                        - parseFloat(colocarPonto(totalContasCorrentes.value)));
                    totalFecamento.value = colocarVirgula(valorTotal);
                }
            }
            
            function excluir(id){
                if (confirm("Deseja mesmo excluir esta rota?")){
                    location.replace("consulta_rota.jsp?acao=excluir&id="+id);
                }
            }

            function setDefault(){
                $("agregado").value = '<c:out value="${param.agregado}"/>';
                $("agregadoCnpj").value = '<c:out value="${param.agregadoCnpj}"/>';
                $("agregadoId").value = '<c:out value="${param.agregadoId}"/>';
                $("dataDe").value = '<c:out value="${param.dataDe}"/>';
                $("dataAte").value = '<c:out value="${param.dataAte}"/>';
                $("dataFechamento").value = '<c:out value="${param.dataFechamento}"/>';
                $("dataVencimento").value = '<c:out value="${param.dataVencimento}"/>';
            }

            function visualizar(){
                try {
                    if ($("agregadoId").value == "" || $("agregadoId").value == "0") {
                        return showErro("Escolha um Agregado!", $("agregado"));        
                    }
                    $("formulario").submit();
                } catch (ex) { 
                    alert(ex);
                }
            }
            
            function virgula(index){
                try {
                    calcularImpostos(index);
                    var totalContratos = $("totalContratos_" + index);
                    var totalContasCorrentes = $("totalContasCorrentes_" + index);
                    var totalImpostos = $("totalImpostos_" + index);
                    var totalFecamento = $("totalFechamento_" + index);
                    if(totalContratos!= null){
                        var valorTotal = (parseFloat(totalContratos.value) - parseFloat(colocarPonto(totalImpostos.value)) - parseFloat(totalContasCorrentes.value));
                        totalContratos.value = colocarVirgula(totalContratos.value);
                        totalContasCorrentes.value = colocarVirgula(totalContasCorrentes.value);
                        totalFecamento.value = colocarVirgula(valorTotal);
                    }           
                } catch (ex) { 
                    alert(ex);
                }
            }
            
            function ajaxContratosAgregado(index){
                var agregadoId = $("agregadoId_"+ index).value;
                if ($("trContratos"+ agregadoId+"_"+ index) != null) {
                    return false;
                }
                espereEnviar("",true);
                function e(transport){
                    carregarContratosFreteAgregado(transport.responseText, index);
                }
                tryRequestToServer(function(){
                    new Ajax.Request("ContratoFreteControlador?acao=ajaxListarContratosAgregado&agregadoId="+agregadoId+
                        "&dataDe="+$("dataDe").value+"&dataAte="+$("dataAte").value
                    ,{method:'post', onSuccess: e, onError: e});
                });
            }
            
            function ajaxMovBancoAgregado(index){
                var agregadoId = $("agregadoId_"+ index).value;
                if ($("trContaCorrente"+ agregadoId+"_"+ index) != null) {
                    return false;
                }
                espereEnviar("",true);
                function e(transport){
                    carregarMovBancoAgregado(transport.responseText, index);
                }
                tryRequestToServer(function(){
                    new Ajax.Request("ContratoFreteControlador?acao=ajaxListarMovimentacaoBancariaAgregado&agregadoId="+agregadoId+
                        "&dataDe="+$("dataDe").value+"&dataAte="+$("dataAte").value
                    ,{method:'post', onSuccess: e, onError: e});
                });
            }
            
            function carregarContratosFreteAgregado(textoResposta, index){
            
                var lista = jQuery.parseJSON(textoResposta);
                var listContratoFrete = lista.list[0].contratoFrete;
                var length = (listContratoFrete != undefined && listContratoFrete.length != undefined ? listContratoFrete.length : 1);
                
                if (length > 1) {
                    for(var i = 0; i < length; i++){
                        addContratoFrete(listContratoFrete[i], index);
                    }
                }else if(listContratoFrete != null || listContratoFrete != undefined){
                    addContratoFrete(listContratoFrete, index);
                }
                espereEnviar("",false);
            }
            
            function carregarMovBancoAgregado(textoResposta, index){
                var lista = jQuery.parseJSON(textoResposta);
                var listMovBanco = lista.list[0].movBanco;

                var length = (listMovBanco != undefined && listMovBanco.length != undefined ? listMovBanco.length : 1);
                
                if (parseInt(length) > 1) {
                    for(var i = 0; i < length; i++){
                        addMovBanco(listMovBanco[i], index);
                    }
                }else if(listMovBanco != null && listMovBanco != undefined){
                    addMovBanco(listMovBanco, index);
                }
                espereEnviar("",false);
            }
            
            function addContratoFrete(cf, index){
                try {
                    var table = $("tbodyContratos_"+ index);
                    var agregadoId = $("agregadoId_"+ index).value;
                    
                    var dataFmt = (cf.data.$).split("-")[2]+"/"+(cf.data.$).split("-")[1]+"/"+(cf.data.$).split("-")[0];
                    var _tr = Builder.node("tr",{
                        id: "trContratos"+agregadoId+"_"+ index
                    });
                    var _tdNumeroContrato = Builder.node("td");
                    var _tdData = Builder.node("td");
                    var _tdPlaca = Builder.node("td");
                    var _tdValor = Builder.node("td");
                    
                    var _labelNumetoContrato = Builder.node("label",{},cf.id.toString());
                    var _labelData = Builder.node("label",{},dataFmt);
                    var _labelPlaca = Builder.node("label",{},cf.veiculo.placa.toString());
                    var _labelValor = Builder.node("label",{},colocarVirgula(cf.vlFreteMotorista.toString()));

                    _tdNumeroContrato.appendChild(_labelNumetoContrato);
                    _tdData.appendChild(_labelData);
                    _tdPlaca.appendChild(_labelPlaca);
                    _tdValor.appendChild(_labelValor);

                    _tr.appendChild(_tdNumeroContrato);
                    _tr.appendChild(_tdData);
                    _tr.appendChild(_tdPlaca);
                    _tr.appendChild(_tdValor);

                    table.appendChild(_tr);
                } catch (ex) { 
                    alert(ex);
                }
            }
            
            function addMovBanco(mov, index){
                try {
                    var table = $("tbodyContaCorrente_"+ index);
                    var agregadoId = $("agregadoId_"+ index).value;
                    var credito = 0;
                    var debito = 0;
                    var dataFmt = (mov.dtEmissao.$).split("-")[2]+"/"+(mov.dtEmissao.$).split("-")[1]+"/"+(mov.dtEmissao.$).split("-")[0];
                    
                    if (mov.valor > 0) {
                        credito = mov.valor;
                    }else{
                        debito = mov.valor;
                    }
                    
                    var _tr = Builder.node("tr",{
                        id: "trContaCorrente"+agregadoId+"_"+ index
                    });
                       
                    var _tdCredito = Builder.node("td", {style:"text-align:right;color:blue;"}, colocarVirgula(credito));
                    var _tdDebito = Builder.node("td",{style:"text-align:right;color:red;"},colocarVirgula(debito * -1));
                    var _tdDtEmissao = Builder.node("td",dataFmt);
                    var _tdHistorico = Builder.node("td", mov.historico);
                       
                    _tr.appendChild(_tdDtEmissao);
                    _tr.appendChild(_tdCredito);
                    _tr.appendChild(_tdDebito);
                    _tr.appendChild(_tdHistorico);
//                    _tr.appendChild(_tdValor);

                    table.appendChild(_tr);
                } catch (ex) { 
                    alert(ex);
                }
            }
            
            function calculaInss(index){
                var valorFrete = parseFloat($("totalContratos_"+ index).value);
                var percentualBase = <c:out value="${configuracao.inssAliqBaseCalculo}" default="0"/>;
                var valorJaRetido = parseFloat($("valorINSSAnterior_"+ index).value);
                var teto = <c:out value="${configuracao.tetoInss}" default="0"/>;

                var faixas = new Array();

                faixas[0] = new Faixa(0,
                <c:out value="${configuracao.inssAte}" default="0"/>,
                <c:out value="${configuracao.inssAliqAte}" default="0"/>);

                faixas[1] = new Faixa(<c:out value="${configuracao.inssDe1}" default="0"/>,
                <c:out value="${configuracao.inssAte1}" default="0"/>,
                <c:out value="${configuracao.inssAliq1}" default="0"/>);

                faixas [2] = new Faixa(<c:out value="${configuracao.inssDe2}" default="0"/>,
                <c:out value="${configuracao.inssAte2}" default="0"/>,
                <c:out value="${configuracao.inssAliq2}" default="0"/>);

                faixas [3] = new Faixa(<c:out value="${configuracao.inssDe3}" default="0"/>,
                <c:out value="${configuracao.inssAte3}" default="0"/>,
                <c:out value="${configuracao.inssAliq3}" default="0"/>);
                var baseINSSJaRetida = $('baseCalculoINSSAnterior_'+ index).value;
                var inss = new Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseINSSJaRetida);

                $("vlINSS_"+ index).value = colocarVirgula(inss.valorFinal);
                $("baseCalculoINSS_"+ index).value = colocarVirgula(inss.baseCalculo);
                $("aliquotaINSS_"+ index).value = colocarVirgula(inss.aliquota);

                return inss;
            }
            
            function calculaIR(inss, index){
                var percentualBase = <c:out value="${configuracao.irAliqBaseCalculo}" default="0"/>;
                var faixas = new Array(); 

                faixas[0] = new Faixa(0,
                <c:out value="${configuracao.irDe1}" default="0"/>,
                <c:out value="0" default="0"/>,
                <c:out value="0" default="0"/>);

                faixas[1] = new Faixa(<c:out value="${configuracao.irDe1}" default="0"/>,
                <c:out value="${configuracao.irAte1}" default="0"/>,
                <c:out value="${configuracao.irAliq1}" default="0"/>,
                <c:out value="${configuracao.irdeduzir1}" default="0"/>);

                faixas[2] = new Faixa(<c:out value="${configuracao.irDe2}" default="0"/>,
                <c:out value="${configuracao.irAte2}" default="0"/>,
                <c:out value="${configuracao.irAliq2}" default="0"/>,
                <c:out value="${configuracao.irDeduzir2}" default="0"/>);

                faixas[3] = new Faixa(<c:out value="${configuracao.irDe3}" default="0"/>,
                <c:out value="${configuracao.irAte3}" default="0"/>,
                <c:out value="${configuracao.irAliq3}" default="0"/>,
                <c:out value="${configuracao.irDeduzir3}" default="0"/>);

                faixas[4] = new Faixa(<c:out value="${configuracao.irAte3}" default="0"/>,
                <c:out value="999999999999" default="0"/>,
                <c:out value="${configuracao.irAliqAcima}" default="0"/>,
                <c:out value="${configuracao.irdeduzirAcima}" default="0"/>); 

                var baseIRJaRetida = $("baseCalculoIRAnterior_"+ index).value;
                var valorIRJaRetido = $("valorIRAnterior_"+ index).value;
                var valorPorDependente = <c:out value="${configuracao.irVlDependente}" default="0"/>;
                var isCalculaDependente = <c:out value="${configuracao.consideraDependentesIr}" default="false"/>;
                var isDeduzirInssIr = <c:out value="${configuracao.deduzirINSSIR}" default="true"/>;
                var qtdDependente = $("qtdDependente_"+ index).value;
                
                var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, qtdDependente, valorPorDependente, isCalculaDependente, isDeduzirInssIr);
                $("vlIR_"+ index).value = colocarVirgula(ir.valorFinal);
                $("baseCalculoIR_"+ index).value = colocarVirgula(ir.baseCalculo);
                $("aliquotaIR_"+ index).value = colocarVirgula(ir.aliquota);
            }

            function calculaSest(baseCalculo, index){
                var aliquota = <c:out value="${configuracao.sestSenatAliq}" default="0"/>;
                var sest = new Sest(baseCalculo, aliquota);
                $("vlSestSenat_"+ index).value = colocarVirgula(sest.valorFinal);
                $("baseCalculoSestSenat_"+ index).value = colocarVirgula(sest.baseCalculo);
                $("aliquotaSestSenat_"+ index).value = colocarVirgula(sest.aliquota);

                return sest;
            }
            
            function calcularImpostos(index){
                try {
                    var isReter = ($("agregadoTipoCgc_"+ index).value == "F");
                    var isTac = ($("agregadIsTac_"+ index).value == "true");
                    // segundo Deivid, só irá carregar os impostos se for PESSOA FISICA e NÃO TAC;
                    if(isReter && !isTac){
                        var inss = calculaInss(index);
                        calculaSest(inss.baseCalculo, index);
                        calculaIR(inss, index);
                        $("totalImpostos_" + index).value = colocarVirgula(pontoParseFloat($('vlIR_'+ index).value) + pontoParseFloat($('vlINSS_'+ index).value) + pontoParseFloat($('vlSestSenat_'+ index).value),2);
                    }else{
                        $('vlIR_'+ index).value = '0,00';
                        $('vlINSS_'+ index).value = '0,00';
                        $('vlSestSenat_'+ index).value = '0,00';
                        $("totalImpostos_" + index).value = "0,00";
                    }
                
                } catch (ex) { 
                    alert(ex);
                }
            }
            
            function mostrarContratosFrete(img){
                try {
                    var index = img.id.split("_")[1];
                    var name = img.id.split("_")[0].replace("img", "");
                    var tr = $("tr"+ name+ "_"+ index);                

                    if (name == "Contratos") {
                        ajaxContratosAgregado(index);
                    }else if(name == "ContaCorrente"){
                        ajaxMovBancoAgregado(index);
                    }

                    if (isVisivel(tr)) {
                        invisivel(tr);
                        img.src = "img/plus.jpg";
                    }else{
                        img.src = "img/minus.jpg";
                        visivel(tr);
                    }
                } catch (ex) { 
                    alert(ex);
                }
            }
            
            function ajaxCarregarAcumuladoMes(index){
                var agregadoId = $("agregadoId_"+ index).value;
                function e(transport){
                        var lista = jQuery.parseJSON(transport.responseText);
                        var acumulado = lista.acumuladoMes;
                        $("valorIRAnterior_"+ index).value = acumulado.valorIrrfAnterior;
                        $("baseCalculoIRAnterior_"+ index).value = acumulado.baseCalculoIrrfAnterior;
                        $("valorINSSAnterior_"+ index).value = acumulado.valorInssAnterior;
                        $("baseCalculoINSSAnterior_"+ index).value = acumulado.baseCalculoInssAnterior;
                        calcularImpostos(index);
                        espereEnviar("",false);
                    }
                    
                tryRequestToServer(function(){
                    new Ajax.Request("ContratoFreteControlador?acao=carregarAcumuladoMesAjax&agregadoId="+agregadoId+
                        "&dataFechamento="+$("dataFechamento").value
                    ,{method:'post', onSuccess: e, onError: e});
                });
            }
            
            function carregarAcumuladoAll(){
                try {
                    if($("maxCont") != null){
                        var max = parseInt($("maxCont").value);
                            for (i = 1; i <= max; i++) {
                                ajaxCarregarAcumuladoMes(i);
                            }
                    }
                } catch (ex) { 
                    alert(ex);
                }
            }
        </script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Fechamento do Agredado</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {color: #FF0000}
            .style2 {color: #0000FF}
            -->
        </style>
    </head>

    <body onLoad="setDefault();applyFormatter();">
        
        <input type="hidden" name="agregado_id" id="agregado_id" value="">
        <form action="ContratoFreteControlador?acao=visualizarFechamentoAgregado" id="formulario" name="formulario" method="post">
            <img src="img/banner.gif" >
            <input type="hidden" id="agregado_cnpj" value="">

            <br>
            <table width="75%" align="center" class="bordaFina" >
                <tr >
                    <td width="100%">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <div align="left"><b>Fechamento do Agredado</b></div>
                    </td>
                </tr>
            </table>
            <br>
            <table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">                
                <tr class="tabela" >
                    <td colspan="10">Dados Principais</td>
                </tr>
                 <tr class="CelulaZebra2">
                    <td width="20%" class="textoCampos">Apenas o Agregado</td>
                    <td width="80%" colspan="6">
                        <input name="agregado" type="text" class="inputReadOnly8pt"  id="agregado" size="40" readonly value="">
                        <input name="agregadoCnpj" type="text" class="inputReadOnly8pt"  id="agregadoCnpj" size="20" readonly value="">
                        <input name="agregadoId" type="hidden" id="agregadoId" value="0">
                        <input name="realizadaDe" type="hidden" id="realizadaDe" value="${param.dataDe}">
                        <input name="realizadaAte" type="hidden" id="realizadaAte" value="${param.dataAte}">
                        <input name="locProp" type="button" id="locProp" class="inputBotaoMin" value="..." onClick="javascript:tryRequestToServer(function(){abrirLocalizarProprietario();});">
                    </td>
                </tr>
                   <tr class="CelulaZebra2">
                    <td width="15%" class="textoCampos">Emitidos entre:</td>
                    <td width="10%" ><input name="dataDe" type="text" id="dataDe" size="12" maxlength="10"  class="fieldDateMin" onblur="alertInvalidDate(this)"></td>
                    <td width="15%"><input name="dataAte" type="text" id="dataAte" size="12" maxlength="10"  class="fieldDateMin" onblur="alertInvalidDate(this)"></td>
                    <td width="15%" class="textoCampos">Data de Fechamento:</td>
                    <td width="15%" class="celulaZebra2">
                        <input type="text" maxlength="10" class="fieldDateMin" id="dataFechamento" name="dataFechamento" value="" onblur="carregarAcumuladoAll();alertInvalidDate(this);" size="12" />
                    </td>
                    <td width="15%" class="textoCampos">Data de Vencimento:</td>
                    <td width="15%" class="celulaZebra2">
                        <input type="text" maxlength="10" class="fieldDateMin" id="dataVencimento" name="dataVencimento" value="" onblur="alertInvalidDate(this);" size="12" />
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td height="24" colspan="8"><center>
                            <input name="botVisualizar" type="button" class="botoes" id="botVisualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
                        </center>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" class="bordaFina">
                            <tbody>
                                <c:forEach varStatus="status" var="contratoAgregado" items="${listaContratoAgregado}">
                                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                                        <td width="3%" align="center">
                                            <c:if test="${status.last}">
                                                <input type="hidden" name="maxCont" id="maxCont" value="${status.count}">
                                            </c:if>
                                            <img src="img/plus.jpg" id="imgContratos_${status.count}" title="Mostrar todos os contrados deste proprietario." onclick="mostrarContratosFrete(this);"/>
                                            <input type="hidden" name="agregadoId_${status.count}" id="agregadoId_${status.count}" value="${contratoAgregado.agregado.idfornecedor}" />
                                            <input type="hidden" name="agregado_${status.count}" id="agregado_${status.count}" value="${contratoAgregado.agregado.razaosocial}" />
                                            <input type="hidden" name="agregadoTipoCgc_${status.count}" id="agregadoTipoCgc_${status.count}" value="${contratoAgregado.agregado.tipoCgc}" />
                                            <input type="hidden" name="agregadIsTac_${status.count}" id="agregadIsTac_${status.count}" value="${contratoAgregado.agregado.tac}" />
                                            <input type="hidden" name="qtdDependente_${status.count}" id="qtdDependente_${status.count}" value="${contratoAgregado.agregado.quantidadeDependentes}" />
                                        </td>
                                        <td width="22%">Contratos em Aberto:</td>
                                        <td  width="75%">
                                            <input type="text" readonly style="text-align:right;" id="totalContratos_${status.count}" name="totalContratos_${status.count}" 
                                                   class="inputReadOnly" maxlength="12" size="10" value="${contratoAgregado.valorTotal}" 
                                                   onkeypress="mascara(this, reais)" /> (+)
                                        </td>
                                    </tr>
                                    <tr id="trContratos_${status.count}" style="display: none">
                                        <td class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}"></td>
                                        <td colspan="2">
                                            <table width="100%" class="bordaFina">
                                                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                    <td width="15%"><b>Contrado de Frete</b></td>
                                                    <td width="15%"><b>Data</b></td>
                                                    <td width="10%"><b>Placa</b></td>
                                                    <td width="60%"><b>Valor</b></td>
                                                </tr>
                                                <tbody id="tbodyContratos_${status.count}" class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                                        <td width="3%" align="center">
                                            <img src="img/plus.jpg" id="imgImpostos_${status.count}" title="Mostrar o calculo detalhado dos impostos." onclick="mostrarContratosFrete(this);" />
                                        </td>
                                        <td width="22%">Impostos:</td>
                                        <td  width="75%">
                                            <input type="text" readonly style="text-align:right; color: red" id="totalImpostos_${status.count}" 
                                                   name="totalImpostos_${status.count}"  class="inputReadOnly" maxlength="12" size="10" 
                                                   value="${contratoAgregado.valorTotalImpostos}" onkeypress="mascara(this, reais)" /> (-)
                                        </td>
                                    </tr>
                                    <tr id="trImpostos_${status.count}" style="display: none">
                                        <td class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}"></td>
                                        <td colspan="2">
                                            <table width="100%" class="bordaFina">
                                                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                    <td width="10%"><b>IR</b></td>
                                                    <td width="10%"><b>INSS</b></td>
                                                    <td width="80%"><b>SEST/SENAT</b></td>
                                                </tr>
                                                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                    <td width="10%">                                                        
                                                        <input type="text" id="vlIR_${status.count}" name="vlIR_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="baseCalculoIR_${status.count}" name="baseCalculoIR_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="baseCalculoIRAnterior_${status.count}" name="baseCalculoIRAnterior_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="${contratoAgregado.baseCalculoIrrfAnterior}" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="valorIRAnterior_${status.count}" name="valorIRAnterior_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="${contratoAgregado.valorIrrfAnterior}" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="aliquotaIR_${status.count}" name="aliquotaIR_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="" onkeypress="mascara(this, reais)" />
                                                    </td>
                                                    <td width="10%">
                                                        <input type="text" id="vlINSS_${status.count}" name="vlINSS_${status.count}" maxlength="10" size="8" class="inputReadOnly8pt" value="" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="baseCalculoINSS_${status.count}" name="baseCalculoINSS_${status.count}" maxlength="10" size="8" class="inputReadOnly8pt" value="" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="baseCalculoINSSAnterior_${status.count}" name="baseCalculoINSSAnterior_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="${contratoAgregado.baseCalculoInssAnterior}" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="valorINSSAnterior_${status.count}" name="valorINSSAnterior_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="${contratoAgregado.valorInssAnterior}" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="aliquotaINSS_${status.count}" name="aliquotaINSS_${status.count}" maxlength="10" size="8" class="inputReadOnly8pt" value="" onkeypress="mascara(this, reais)" />
                                                    </td>
                                                    <td width="80%">
                                                        <input type="text" id="vlSestSenat_${status.count}" name="vlSestSenat_${status.count}" maxlength="10" size="8" value="" class="inputReadOnly8pt" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="baseCalculoSestSenatAnterior_${status.count}" name="baseCalculoSestSenatAnterior_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="${contratoAgregado.baseCalculoSestSenatAnterior}" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="valorSestSenatAnterior_${status.count}" name="valorSestSenatAnterior_${status.count}" class="inputReadOnly8pt" maxlength="10" size="8" value="${contratoAgregado.valorSestSenatAnterior}" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="baseCalculoSestSenat_${status.count}" name="baseCalculoSestSenat_${status.count}" maxlength="10" size="8" value="" class="inputReadOnly8pt" onkeypress="mascara(this, reais)" />
                                                        <input type="hidden" id="aliquotaSestSenat_${status.count}" name="aliquotaSestSenat_${status.count}" maxlength="10" size="8" value="" class="inputReadOnly8pt" onkeypress="mascara(this, reais)" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                                        <td width="3%" align="center">
                                            <img src="img/plus.jpg" id="imgContaCorrente_${status.count}" title="Mostrar o calculo detalhado do saldo."  onclick="mostrarContratosFrete(this);" />
                                        </td>
                                        <td width="22%">Conta Corrente:</td>
                                        <td  width="75%">
                                            <input type="text" style="text-align:right; color: red" id="totalContasCorrentes_${status.count}" 
                                                   name="totalContasCorrentes_${status.count}"  class="inputtexto" onblur="validarValorSaldo(${status.count})"
                                                   maxlength="12" size="10" value="${contratoAgregado.valorTotalContaCorrente < 0 ? '0,00' : contratoAgregado.valorTotalContaCorrente}" onkeypress="mascara(this, reais)" /> (-)
                                            <input type="hidden" id="totalContasCorrentesH_${status.count}" value="${contratoAgregado.valorTotalContaCorrente}" /> 
                                        </td>
                                    </tr>
                                    <tr id="trContaCorrente_${status.count}" style="display: none">
                                        <td class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}"></td>
                                        <td colspan="2">
                                            <table width="100%" class="bordaFina">
                                                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                    <td width="15%"><b>Saldo Anterior:</b></td>
                                                    <td style="text-align:right;" width="10%">
                                                        <input type="text" style="text-align:right;" id="saldoAnterior_${status.count}" 
                                                               name="saldoAnterior_${status.count}"  class="inputReadOnly8pt" readonly value="0,00" maxlength="12" size="10"
                                                    </td>
                                                    <td colspan="2"width="75%"></td>
                                                </tr>
                                                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                    <td width="15%"><b>Data Emissão</b></td>
                                                    <td style="text-align:right;" width="10%"><b>Crédito</b></td>
                                                    <td style="text-align:right;" width="10%"><b>Débito</b></td>
                                                    <td width="65%"><b>Historico</b></td>
                                                </tr>
                                                <tbody id="tbodyContaCorrente_${status.count}" class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                                        <td width="3%" align="center"></td>
                                        <td width="22%"><b>Total:</b></td>
                                        <td  width="75%">
                                            <input type="text" readonly style="text-align:right;" id="totalFechamento_${status.count}" name="totalFechamento_${status.count}"  
                                                   class="inputReadOnly" maxlength="12" size="10" value="${contratoAgregado.valorTotal}" onkeypress="mascara(this, reais)" />
                                        </td>
                                    </tr>
                                    <script>virgula('${status.count}')</script>
                                </c:forEach>
                            </tbody>
                        </table>
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td height="24" colspan="8"><center>
                            <input name="botSalvar" type="button" class="botoes" id="botSalvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){baixar();});">
                        </center>
                    </td>
                </tr>
            </table>
            <br>
        </form>
    </body>
</html>
