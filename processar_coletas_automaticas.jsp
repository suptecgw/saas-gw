<%-- 
    Document   : processar_coletas_automaticas
    Created on : 14/02/2014, 10:48:21
    Author     : amanda
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
//    shortcut.add("enter", function() {
//        pesquisa()
//    });    

    jQuery.noConflict();
    function desativarBotoes() {

        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';


        if (atual == '1') {
            desabilitar(document.formularioAnt.botaoAnt, "#2E76A6");
        }
        if (parseFloat(atual) >= parseFloat(paginas)) {
            desabilitar(document.formularioProx.botaoProx, "#2E76A6");
        }

        document.formulario.valorConsulta.focus();

    }
    
    var dataAtual;

    function setDefault() {
                   
        $("rem_rzs").value = '<c:out value="${param.rem_rzs}"/>';
        $("idremetente").value = '<c:out value="${param.idremetente}"/>';
        $("rem_cnpj").value = '<c:out value="${param.rem_cnpj}"/>';
        $("rem_codigo").value = '<c:out value="${param.rem_codigo}"/>';        
        $("filial").value = '<c:out value="${param.filial}"/>';
        dataAtual = '<c:out value="${param.dataAtual}"/>';
       
    }


    function habilitaConsultaDePeriodo(opcao) {
        if ($("campoConsulta").value == "c.numero_carga" || $("campoConsulta").value == "romaneio" || $("campoConsulta").value == "coleta" || $("campoConsulta").value == "pedido_coleta" || $("campoConsulta").value == "ctrcs") {
            document.getElementById("valorConsulta").style.display = "";
            document.getElementById("operadorConsulta").style.display = "";
            document.getElementById("div1").style.display = "none";
            document.getElementById("div2").style.display = "none";
        } else {
            document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");
        }
    }

    function pesquisa() {
        $("formulario").submit();
    }

    function localizaremetente() {
        windowConsignatario = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=3', 'Remetente',
                'top=80,left=70,height=500,width=700,resizable=yes,status=1,scrollbars=1');
    }

    

    function carregarColetas(idCliente, index, plus) {
        var idFilial = $("filial").value;
       
        var maxId = $("maxID").value;
        if(maxId < index){
            $("maxID").value = index;
        }
        
            if(plus==true){
        
                new Ajax.Request('ColetasAutomaticasControlador?acao=carregar' +
                        '&idCliente=' + idCliente +'&idFilial=' + idFilial  +
                        '&idCount=' + index,
                            {
                                method: 'get',
                                onSuccess: function(transport) {
                                    var response = transport.responseText;
                                    carregaAjax(index, response);

                                },
                                onFailure: function() {
                                    alert('Something went wrong...')
                                }
                            });
            }else{
               $('trA_'+index).style.display = 'none';
               $('plus_'+index).style.display = '';
               $('minus_'+index).style.display = 'none';
            }
        
    }

    function carregaAjax(idCount, resposta) {
        var body = document.getElementById("bodyA_" + idCount);
        document.getElementById("trA_" + idCount).style.display = "";
        document.getElementById("minus_" + idCount).style.display = "";
        document.getElementById("plus_" + idCount).style.display = "none";
        Element.update(body, resposta);
    }

    function minimizar(idCount) {
        document.getElementById("minus_" + idCount).style.display = "none";
        document.getElementById("plus_" + idCount).style.display = "";
        document.getElementById("trA_" + idCount).style.display = "none";
    }
    
     function localizaRemetenteCodigo(campo, valor){

            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport){
                var resp = transport.responseText;
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (resp == 'null'){
                    alert('Erro ao localizar cliente.');
                    return false;
                }else if (resp == 'INA'){
                    alert('Cliente inativo.');
                    return false;
                }else if(resp == ''){
                    if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                        window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                    }
                    return false;
                }else{
                    var cliControl = eval('('+resp+')');
                    $('idremetente').value = cliControl.idcliente;
                    $('rem_codigo').value = cliControl.idcliente;
                    $('rem_rzs').value = cliControl.razao;
                    $('rem_cnpj').value = cliControl.cnpj;
                    if (campo == 'c.razaosocial'){
                        getObj('dest_rzs_cl').focus();
                    }
                }
            }//funcao e()

            if (valor != ''){
                espereEnviar("",true);
                tryRequestToServer(function(){
                    new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
                });
            }
        }
        
         function getColetasChecked(){
            var coletas = "";
            
            var maxID = $("maxID").value;
            for (var max = 1; max <= maxID; max++) {
                var qtd = $("qtd_" + max).value;
                for(var i=1; i<=qtd; i++){
                    if($("ckcoleta_" + max + "_" + i)!=null){                 
                        if (getObj("ckcoleta_" + max + "_" + i).checked){
                            coletas += ',' + getObj("idcoleta_" + max + "_" + i).value;       
                        }
                    }                       
                }
            }
            return coletas.substr(1);
        }
        
        
        
            function processarColetas(){
                
                if(getColetasChecked()==""){
                    alert("Escolha pelo menos uma coleta a ser processada!");
                    return false;
                }
                
                $("formulario").action = "ColetasAutomaticasControlador?acao=processar";
                $("formulario").method = "post";

                var formu = document.formulario;
                formu.submit();
            }

            function fechar(){
                window.close();
            }



</script>
<html>
<title>Webtrans - Processar Coletas Automáticas</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="setDefault();">
    <div align="center">
        <img src="img/banner.gif" alt="banner"><br>   
    </div>
    <table width="70%" height="28" align="center" class="bordaFina">
        <tr>
            <td width="86%" height="22">
                <b>Processar Coletas Automáticas</b>
            </td>
            <td width="14%">
                <b> 
                    <input name="Button" type="button" class="botoes" value="Fechar" onClick="fechar()"> 
                </b>
            </td>
        </tr>
    </table>    
    <br>
    <form action="ColetasAutomaticasControlador?acao=visualizar" id="formulario" name="formulario" method="post">
    <table width="70%" border="0" class="bordaFina" align="center">
        
        <input type="hidden" id="maxID" name="maxID" value="0"/>
            <tr>
                <td class="TextoCampos">Cliente:</td>
               <td class="celulaZebra2" colspan="7">
                        <input name="rem_codigo" type="text" id="rem_codigo" size="3" value="" onkeyup="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value)" class="fieldMin">
                        <input name="rem_cnpj" type="text" class="inputReadOnly8pt" id="rem_cnpj" maxlength="18" size="18" value="" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value)">
                        
                        <input id="idremetente" name="idremetente"  type="hidden"   value="0" >
                        <input name="rem_rzs" type="text" id="rem_rzs" size="39" value="" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaremetente();">
                        <img src="img/borracha.gif" border="0" id="borracharem" name="borracharem" align="absbottom" class="imagemLink" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = '';getObj('rem_cnpj').value = '';getObj('rem_codigo').value = '';">
                    </td>
                <td width="6%" class="TextoCampos">Filial:</td>
                <td width="13%" class="celulaZebra2">
                    <select name="filial"  id="filial" class="inputtexto" style="width: 90px;">
                        <option value="0">TODAS</option>
                        <c:forEach var="filial" varStatus="status" items="${listaFilial}"> 
                            <option value="${filial.idfilial}">${filial.abreviatura}</option>
                        </c:forEach></select> 
                </td>
                <td width="3%" class="CelulaZebra1NoAlign" align="center"><input name="pesquisar" type="button" class="inputbotao" value="Pesquisar" onclick="javascript: tryRequestToServer(function() {
                            pesquisa();
                        })"  /></td>
            </tr>
      
    </table>
    <table width="70%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
        <tr>       
            <td class="tabela" width="5%" align="left"></td>
            <td class="tabela" width="40%" align="left">Cliente</td>
            <td class="tabela" width="40%" align="left">Período de geração das coletas</td>
            <td class="tabela" width="15%" align="left">Qtd de coletas na semana.</td>
        </tr>

        <c:forEach var="c" varStatus="status" items="${clientes}">             
            <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                <td> <img src="img/plus.jpg" id="plus_${status.count}" name="plus_${status.count}" title="Mostrar Coletas" class="imagemLink" align="right"
                          onclick="javascript:tryRequestToServer(function() {
                                      carregarColetas(${c.idcliente}, ${status.count}, true);
                                  });">                                
                    <img src="img/minus.jpg" id="minus_${status.count}" name="minus_${status.count}" title="Mostrar duplicatas" class="imagemLink" align="right" style="display:none "
                         onclick="javascript:tryRequestToServer(function() {
                                     carregarColetas(${c.idcliente}, ${status.count}, false);
                                 });">
                </td>
                <td><input type="hidden" id="idcliente_${status.count}" name="idcliente_${status.count}" value="${c.idcliente}">
                    ${c.razaosocial}
                    <input type="hidden" id="clienteHidden_${status.count}" name="clienteHidden_${status.count}" value="${c.razaosocial}">
                    <input type="hidden" id="cidadeIdHidden_${status.count}" name="cidadeIdHidden_${status.count}" value="${c.cidade.idcidade}">
                    <input type="hidden" id="bairroIdHidden_${status.count}" name="bairroIdHidden_${status.count}" value="${c.bairroBean.idBairro}">
                    <input type="hidden" id="bairroHidden_${status.count}" name="bairroHidden_${status.count}" value="${c.bairro}">
                    <input type="hidden" id="foneHidden_${status.count}" name="foneHidden_${status.count}" value="${c.fone}">
                </td>
                
                <td width="10%" >
                    <input name="dataDe_${status.count}"  type="text" id="dataDe_${status.count}" size="10" maxlength="10" value="${param.dataAtual}" class="fieldDate" onblur="alertInvalidDate(this)" onkeypress="fmtDate(this, event)"  onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                à <input name="dataAte_${status.count}" type="text" id="dataAte_${status.count}" size="10" value="${param.dataAtual}" maxlength="10" class="fieldDate"  onblur="alertInvalidDate(this)" onkeypress="fmtDate(this, event)"  onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)"></td>
               
                <td><input type="hidden" id="qtd_${status.count}" name="qtd_${status.count}" value="${c.coletasAutomaticas[0].qtd}"/>${c.coletasAutomaticas[0].qtd}</td>
               
            </tr>      

            <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" id="trA_${status.count}" style="display: none">
                <td></td>
                <td >
                    
                    <table width="40%" class="bordaFina" id="table_${status.count}">
                        
                        <tbody id="bodyA_${status.count}"></tbody>
                    </table>
                </td>
                <td     ></td>
                <td     ></td>
            </tr>
        </c:forEach>
    </table>            


    <table width="70%" border="0" class="bordaFina" align="center">	
        <tr>
            <td colspan="6" class="TextoCampos">
                <div align="center">	   	 
                        <input name="pesquisar" type="button" class="inputbotao" value="Processar Coleta" onclick="javascript: tryRequestToServer(function(){processarColetas();})"  />

                </div>
            </td>
        </tr>
    </table>
    <br>
    
</form>
</body>
</html>