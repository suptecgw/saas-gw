<%-- 
    Document   : cadastrar_PreManifesto
    Created on : 20/10/2015, 22:16:47
    Author     : paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" src="script/funcoes.js" type=""></script>
<script language="JavaScript" type="text/javascript">
    var countMani = 0;
    function preManifesto(numCtrc,numNfe,remetente,destinatario,endereco){
        numCtrc = (numCtrc != null && numCtrc != undefined? numCtrc : "");
        numNfe = (numNfe != null && numNfe != undefined? numNfe : "");
        remetente = (remetente != null && remetente != undefined? remetente : "");
        destinatario = (destinatario != null && destinatario != undefined? destinatario : "");
        endereco = (endereco != null && endereco != undefined? endereco : "");
    }

    function removerTrUltimo(){
        var index = $("maxUltimosMani").value;
        Element.remove('trUltimosPreMani_'+ index);
    }
    
    function ultimosPreManifestos(numCtrc,numNfe,remetente,destinatario,endereco){
            
        if ($("maxUltimosMani").value >= 10) {
            removerTrUltimo();
        }

        countMani++;

        var celulaZebrada = ((countMani % 2) == 0 ? 'celulaZebra1' : 'celulaZebra2');

        var _trPreManifesto = Builder.node("tr",{id:"trUltimosPreMani_"+countMani, className:celulaZebrada});

        var _tdCTe = Builder.node("td", {align:"center"});
        var _tdNFe = Builder.node("td", {align:"center"});
        var _tdRemetente = Builder.node("td", {align:"center"});
        var _tdDestinatario = Builder.node("td", {align: "center"});
        var _tdEndereco = Builder.node("td", {align: "center"});

        var _inpNumCTe = Builder.node("input", {
            type: "text",
            name: "numCte_" + countMani,
            id: "numCte_" + countMani,
            size: 6,
            className: 'imputTextDOM',
            value: numCtrc,
            readonly: "true"
        });

        var _inpNumNFe = Builder.node("input", {
            type: "text",
            size: "7",
            name: "numNfe_" + countMani,
            id: "numNfe_" + countMani,
            className: 'imputTextDOM',
            value: numNfe,
            readonly: "true"
        });

        var _inpRemetente = Builder.node("input", {
            type: "text",
            size: 10,
            name: "remetente_" + countMani,
            id: "remetente_" + countMani,
            className: 'imputTextDOM',
            value: remetente,
            readonly: "true"
        });

        var _inpDestinatario = Builder.node("input", {
            type: "text",
            size: 10,
            name: "destinatario_" + countMani,
            id: "destinatario_" + countMani,
            className: 'imputTextDOM',
            value: destinatario,
            readonly: "true"
        });

        var _inpEndereco = Builder.node("input", {
            type: "text",
            size: 10,
            name: "endereco_" + countMani,
            id: "endereco_" + countMani,
            className: 'imputTextDOM',
            value: endereco,
            readonly: "true"
        });

        _tdCTe.appendChild(_inpNumCTe);
        _tdNFe.appendChild(_inpNumNFe);
        _tdRemetente.appendChild(_inpRemetente);
        _tdDestinatario.appendChild(_inpDestinatario);
        _tdEndereco.appendChild(_inpEndereco);

        _trPreManifesto.appendChild(_tdCTe);
        _trPreManifesto.appendChild(_tdNFe);
        _trPreManifesto.appendChild(_tdRemetente);
        _trPreManifesto.appendChild(_tdDestinatario);
        _trPreManifesto.appendChild(_tdEndereco);

        $("ultmosPreManifesto").appendChild(_trPreManifesto);
        $("maxUltimosMani").value = countMani;


    }
    
    function pesquisar(){
        espereEnviar("",true);
        $("msn").innerHTML = "";
        
        var valorConsulta = "";
        var tipoConsulta = $("tipoConsulta").value;
        if (tipoConsulta == 'cb') {
            valorConsulta = $("codBarras").value;
        }else if(tipoConsulta == 'np'){
            valorConsulta = $("numeroPedido").value;
        }
        
        
        function e(transport){
            try{
                var textoResposta = transport.responseText;
            
                if (textoResposta == "-1") {
                    alert('Houve algum problema ao requisitar o servidor, favor informar manualmente.');

                } else {
                    var lista = (jQuery.parseJSON(textoResposta) != null ? jQuery.parseJSON(textoResposta).listaCtrc : null);
                    var colecaoNotas = "";
                    var pesos = 0;
                    var mercadoria = 0;
                    var volume = 0;
                    var notas = (lista != null && lista.ctrc != null && lista.ctrc.notas != undefined && lista.ctrc.notas != null ? lista.ctrc.notas[0] : "");
                    var listaNf = notas["com.sagat.bean.NotaFiscal"];
                    var msn = lista != null && lista.msn != null ? lista.msn[0] : "";
                    var mensagens = msn["br.com.gwsistemas.separacao.mensagem.Mensagem"];

                    var lengthMsn = (mensagens != undefined && mensagens.length != undefined ? mensagens.length : 1);
                    var descricaoMsn = "";

                    if (listaNf != null && listaNf != undefined) {

                        var lengthNf = (listaNf != undefined && listaNf.length != undefined ? listaNf.length : 1);
                        if (lengthNf > 1) {
                            for (var qtdNf = 0; qtdNf < lengthNf; qtdNf++) {

                                if (colecaoNotas == "") {
                                    colecaoNotas += listaNf[qtdNf].numero;
                                } else {
                                    colecaoNotas += "," + listaNf[qtdNf].numero;
                                }
                                
                                pesos += listaNf[qtdNf].peso;
                                volume += listaNf[qtdNf].volume;
                                mercadoria += listaNf[qtdNf].valor;
                            }
                        } else {
                            colecaoNotas = listaNf.numero;
                            $("peso").value = listaNf.peso;
                            $("volume").value = listaNf.volume;
                            $("mercadoria").value = listaNf.valor;
                        }
                        
                        var numCte = lista.ctrc.numero;
                        var numNfe = colecaoNotas;
                        var remetente = lista.ctrc.remetente.razaosocial;
                        var destinatario = lista.ctrc.destinatario.razaosocial;
                        var endereco = lista.ctrc.destinatario.endereco;
                        
                        var descricaoSetor = "";
                        
                        if(lista.ctrc.manifesto != undefined || lista.ctrc.manifesto != null){
                            descricaoSetor = lista.ctrc.manifesto.setorEntrega.descricao;
                        }else if(lista.manifesto != undefined || lista.manifesto != null){
                            descricaoSetor = lista.manifesto.setorEntrega.descricao;                            
                        }
                        
                        this.ultimosPreManifestos(numCte, numNfe, remetente, destinatario, endereco);

                        $("numCte").value = lista.ctrc.numero;
                        $("numNfe").value = colecaoNotas;
                        $("descRemetente").value = lista.ctrc.remetente.razaosocial;
                        $("descDestinatario").value = lista.ctrc.destinatario.razaosocial;
                        $("cidade").value = lista.ctrc.cidadeDestino.descricaoCidade;
                        $("uf").value = lista.ctrc.cidadeDestino.uf;
                        $("endereco").value = lista.ctrc.destinatario.endereco;
                        
                        if (descricaoSetor != undefined) {
                            $("setorEntrega").value = descricaoSetor;    
                        }else{
                            $("setorEntrega").value = "Não cadastrado";                                
                        }
                        if (lengthNf > 1) {
                            $("peso").value = roundABNT(pesos,2);
                            $("volume").value = parseFloat(volume);
                            $("mercadoria").value = mercadoria;
                        }

                        if (lengthMsn > 1) {
                            for (var qtdMsn = 0; qtdMsn < lengthMsn; qtdMsn++) {
                                descricaoMsn += (mensagens != null && mensagens != undefined && mensagens[qtdMsn].descricao != undefined ? mensagens[qtdMsn].descricao : "");
                            }
                        } else {
                            descricaoMsn += (mensagens != null && mensagens != undefined ? mensagens.descricao : "");
                        }

                        $("msn").innerHTML = descricaoMsn;

                        } else {
                            
                        $("numCte").value = "";
                        $("numNfe").value = "";
                        $("descRemetente").value = "";
                        $("descDestinatario").value = "";
                        $("cidade").value = "";
                        $("uf").value = "";
                        $("endereco").value = "";
                        $("peso").value = "";
                        $("volume").value = "";
                        $("mercadoria").value = "";
                        $("setorEntrega").value = "";
                            
                            if (lengthMsn > 1) {
                                for (var qtdMsn = 0; qtdMsn < lengthMsn; qtdMsn++) {
                                    descricaoMsn += (mensagens != null && mensagens != undefined && mensagens[qtdMsn].descricao != undefined ? mensagens[qtdMsn].descricao : "");
                                }
                            } else {
                                descricaoMsn += (mensagens != null && mensagens != undefined ? mensagens.descricao : "");
                            }

                            $("msn").innerHTML = descricaoMsn;
                        }

                    }
                    
                    $("codBarras").value = "";
                    
                    espereEnviar("", false);
                } catch (e) {
                    espereEnviar("", false);
                    console.log(e);
                }
            }
            tryRequestToServer(function() {
                if (valorConsulta == "") {
                    var msn = "";
                    if (tipoConsulta == 'cb') {
                        msn = "Insira um código válido!";
                    }else if(tipoConsulta == 'np'){
                        msn = "Insira um número do pedido válido!";
                    }
                    $("msn").innerHTML = msn;
                    espereEnviar("", false);
                    return false;
                }
                new Ajax.Request("SeparacaoControlador?acao=cadastrar&valorConsulta="+valorConsulta+"&tipoConsulta="+tipoConsulta
                        + "&idFilial=" + $("filial").value + "&layout=" + $("layout").value, {
                    method: 'post',
                    onSuccess: e
                    ,
                    onError: e
                });
            });

    }
    
    function carregar(){
        $("filial").value = ${param.idfilial};
        if (${param.permissaoUsuario} <= 2) {
            $("filial").disabled = true;
        }
        criterioTipoConsulta("chaveAcesso");
    
    }
    function listarManifesto(){
       tryRequestToServer(function(){document.location.replace("ConsultaControlador?codTela=28")});
    }
    
    function alterarCampoConsulta(tipoConsulta){
        if(tipoConsulta == 'cb'){
            $("divCodBarras").style.display = "";
            $("divNumeroPedido").style.display = "none";
        }else if(tipoConsulta == 'np'){
            $("divCodBarras").style.display = "none";
            $("divNumeroPedido").style.display = "";            
        }
    }
    
    function criterioTipoConsulta(layout){
        if (layout == 'chaveAcesso') {
            $("tipoConsulta").value = "cb";
            alterarCampoConsulta($("tipoConsulta").value);
            $("numeroPedido").value = "";
            $("tipoConsulta").disabled = true;
        }else{
            $("tipoConsulta").disabled = false;            
        }
    }
    
</script>
<style type="text/css">
label{
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 18px;
    }
.button{
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 18px;
        border: 1px solid #003366;
        background-color:#2E76A6;
        color:#FFFFFF;
        cursor: pointer;
        border-radius: 3px;
    }
.selectText {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 18px;
        border: 1px solid #003366;
        border-radius: 3px;
    }
.imputText {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 20px;
        border: 1px solid #003366;
        border-radius: 3px;
        background-color: #cccccc;
    }
.imputTextCodBarras {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 19px;
        border: 1px solid #003366;
        border-radius: 3px;
        
    }
.imputTextDOM {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 18px;
        border: 1px solid #003366;
        border-radius: 3px;
        background-color: #cccccc;
    }
#msn{
	width: 686px;
	height:400px;
        padding-top: 10px;
        font-size: 60px;
        line-height: 60px;
    }
#menu  {  	
	float: right;  	
	width: 50%;  	
	/*height: 500px;*/
	/*background: #6F9;*/  
	}
#contents {
        float: left;
	width: 50%;
	/*height:500px;*/
	}
#setorEntrega{
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 30px;
        border: 1px solid #003366;
        border-radius: 3px;
        background-color: #cccccc;
        color: red;
        height: 50px;
        width: 400px;
        }
#sEntregaLabel{
        font-family: Verdana, Arial, Helvetica, sans-serif;
        color: red;
        font-size: 33px;
        }

</style>            
<html>
    <head>
        <link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Cadastrar Pré-Manifesto</title>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif" > 
        <table class="bordaFina" width="100%">
            <tr>
            <td width="100%" align="left">
                <label for="cadastrarSeparacao">
                    Cadastrar Separação                    
                </label>
            </td>
            <td width="18%">
                <input name="Voltar" type="button" class="button" onclick="listarManifesto();" value="Voltar para consulta"/>
            </td>
            </tr>
        </table>
        <br/>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td align='center' width="50%">
                    <label for="dadosPrincipais">
                        Dados Principais                        
                    </label>
                </td>
            </tr>
        </table>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr>
                <td width="5%" class="TextoCampos">
                    <label for="fila"> Filial: </label>
                </td>
                <td width="10%" class="CelulaZebra2">
                    <select class="selectText" id="filial" name="filial">
                        <c:forEach items="${filial}" var="fil">
                            <option value="${fil.idfilial}">${fil.abreviatura}</option>
                        </c:forEach>
                    </select>
                </td>
                <td width="5%" class="TextoCampos">
                    <label for="layout"> Layout:</label>
                </td>
                <td width="15%" class="CelulaZebra2">
                    <select class="selectText" id="layout" onchange="criterioTipoConsulta(this.value);">
                        <option value="chaveAcesso" >Chave de acesso</option>
                        <option value="jequiti" >Jequiti</option>
                        <option value="marisa" >Marisa</option>
                        <option value="4estacoes" >4 Estações</option>
                        <option value="pierre" >Pierre</option>
                        <option value="privalia" >Privália</option>
                        <option value="odorata" >Odorata Cosméticos</option>
                    </select>
                </td>
                <td width="11%" class="TextoCampos">
                    <!--<label for="codigoBarras"> Cód. Barras:</label>-->                    
                    <select name="tipoConsulta" id="tipoConsulta" class="selectText" style="width:150px;" onclick="alterarCampoConsulta(this.value)">
                        <option value="cb" selected>Cod. Barras</option>
                        <option value="np">Nº do Pedido</option>
                    </select>
                </td>
                <td width="40%" class="CelulaZebra2">
                    <div id="divCodBarras" style="display: ">
                        <input type="text" id="codBarras" class="imputTextCodBarras" name="codBarras" onkeypress="if (event.keyCode == 13){pesquisar()}" size="44">                        
                    </div>
                    <div id="divNumeroPedido" style="display: none">
                        <input type="text" id="numeroPedido" class="imputTextCodBarras" name="numeroPedido" onkeypress="if (event.keyCode == 13){pesquisar()}" size="20">                        
                    </div>
                </td>
                <td width="20%" class="CelulaZebra2">
                    <input type="button" id="pesquisa" class="button" value="Pesquisar" onclick="pesquisar()" name="pesquisa">                    
                </td>
            </tr>
        </table>
        <div id="contents">  
            <table width="50%" border="0" class="bordaFina" align="left">
                <tr>
                    <td width="15%" class="TextoCampos">                    
                        <label for="numeroCte"> Nº CT-e:</label>
                    </td>
                    <td width="100%" class="CelulaZebra2">
                        <input type="text" class="imputText" id="numCte"  name="numCte" value="" readonly>
                    </td>
                </tr>
                <tr>
                    <td width="10%" class="TextoCampos">
                        <label for="numeroNFe"> Nº NF-e: </label>
                    </td>
                    <td width="30%" class="CelulaZebra2">
                        <input type="text" class="imputText" id="numNfe" class="inputtexto" name="numNfe" value="" readonly>
                    </td>
                </tr>
                <tr>
                    <td width="10%" class="TextoCampos">
                        <label for="remetente">  Remetente:</label>
                    </td>
                    <td width="30%" class="CelulaZebra2">
                        <input type="text" class="imputText" id="descRemetente" class="input" name="descRemetente" readonly>

                    </td>
                </tr>     
                <tr>
                    <td width="10%" class="TextoCampos">
                        <label for="Destinatario"> Destinatário:</label>
                    </td>
                    <td width="30%" class="CelulaZebra2">
                        <input type="text" id="descDestinatario" class="imputText"  name="descDestinatario" value="" readonly>
                    </td>
                </tr>           
                <tr>
                    <td width="10%" class="TextoCampos">
                        <label for="endereco">  Endereço: </label>
                    </td>
                    <td width="30%" class="CelulaZebra2">
                        <input type="text" class="imputText" id="endereco" name="endereco"  value="" readonly>
                    </td>
                </tr>           
                <tr>
                    <td width="10%" class="TextoCampos">
                        <label for="cidade"> Cidade: </label>
                    </td>
                    <td width="33%" class="CelulaZebra2">
                        <input type="text" class="imputText" id="cidade" name="cidade" value="" readonly>
                        <input type="text" class="imputText" id="uf" name="uf" value=""  size="4" readonly>
                    </td>
                </tr>
                <tr>
                    <td width="10%" class="TextoCampos">
                        <label for="setorEntrega" id="sEntregaLabel"> Setor : </label>
                    </td>
                    <td width="33%" class="CelulaZebra2">
                        <input type="text" class="imputText" id="setorEntrega" name="setorEntrega" value="" readonly>                        
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" border="0" class="bordaFina" align="left">
                            <tr>
                                <td class="TextoCampos">
                                    <label for="peso">
                                        Peso:                                    
                                    </label>
                                </td>
                                <td  class="CelulaZebra2">
                                    <input type="text" id="peso" class="imputTextDOM" name="peso" size="8"  value="" readonly>
                                </td>

                                <td class="TextoCampos">
                                    <label for="volume">
                                        Vol:                                    
                                    </label>
                                </td>
                                <td class="CelulaZebra2">
                                    <input type="text" size="8" class="imputTextDOM" id="volume" name="volume" value="" readonly>
                                </td>

                                <td class="TextoCampos">
                                    <label for="valorMercadoria">
                                        R$ NF:                                    
                                    </label>
                                </td>
                                <td class="CelulaZebra2">
                                    <input type="text" id="mercadoria" size="8" class="imputTextDOM" name="mercadoria" value="" readonly>
                                </td>
                            </tr>    
                        </table>
                    </td>
                </tr>
                <tr>
                     <input type="hidden" id="maxUltimosMani" value="" name="maxUltimosMani"> 
                    <td colspan="2">
                        <table width="100%" border="0" class="bordaFina" align="center">
                            <tr class="tabela">
                                <td align='center' colspan="5">
                                    <label for="ultimos">
                                        Últimos 10                                    
                                    </label>
                                </td>
                            </tr>
                        <tr>
                            <td width="10%" class="CelulaZebra1">
                                <label> N. CTE </label>
                            </td>
                            <td width="10%" class="CelulaZebra1">
                                <label> N. NFE </label>
                            </td>
                            <td width="10%" class="CelulaZebra1">
                                <label> Remetente </label>
                            </td>                
                            <td width="10%" class="CelulaZebra1">
                                <label> Destinatário </label>
                            </td>                
                            <td width="10%" class="CelulaZebra1">
                                <label> Endereço </label>
                            </td>
                        </tr>
                        <tbody id="ultmosPreManifesto"></tbody>

                        </table>
                    </td>
                </tr>
        </table>  
    </div>
        <div id="menu">
            <table class="bordaFina" border="0" width="100%" align="right">
                <tr class="tabela">
                    <td align='center' width="100%">
                        <label>
                            Mensagem de Retorno                        
                        </label>
                    </td>
                </tr>            
            </table> 

            <div id="mansagem" >
            <label id="msn" ></label>
            </div>
        </div>    
    </body>
</html>
