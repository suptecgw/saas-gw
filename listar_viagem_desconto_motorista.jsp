<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<fmt:setLocale value="pt-BR" />
<!-- ***     LEMBRETE   ***   PARA O TIPO 'r' -->
<!-- Lembrando que existe duas tr's para a movimentação, uma é apenas para a primeira linha da lista, e a outra para as demais.-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<LINK REL="stylesheet" HREF="css/protoloading.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/scriptaculous.js?load=effects"></script>
<script language="javascript" type="text/javascript" src="script/protoloading.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script language="javascript" type="text/javascript" src="script/protoloading.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="JavaScript" src="script/shortcut.js"></script>

<script type="text/javascript" language="JavaScript">
    var countRow = 0;
    
    function setDefault(){
        $("campoConsulta").value = '${param.campoConsulta}';
        $("dataDe").value = '${param.dataDe}';
        $("dataAte").value = '${param.dataAte}';
        $("idmotorista").value = '${param.idmotorista}';
        $("motor_nome").value = '${param.motor_nome}';
        $("idplanocusto").value = '${param.idplanocusto}';
        $("plcusto_descricao").value = '${param.plcusto_descricao}';
        $("idviagem").value = '${param.idviagem}';
        $("numviagem").value = '${param.numviagem}';
    }

    function pesquisa(){
        $("formulario").action = "ViagemDescontoMotoristaControlador?acao=listar";
        $("formulario").method = "post";
        $("formulario").submit();
    }

    function excluir(id,index){
        if(confirm("Deseja excluir o Lançamento ?" )){
            if(confirm("Tem certeza?" )){
                Element.remove("tr_"+index);
                if (id != 0) {
                        tryRequestToServer(function(){new Ajax.Request("ViagemDescontoMotoristaControlador?acao=excluir&idLancamento=" + id,
                        {
                            method:'get',
                            onSuccess: function(){ alert('Lançamento Removido com Sucesso!')},
                            onFailure: function(){ alert('Something went wrong...') }
                        });     
                    });
                }
            }
        }
    }
    
    function abrirCadastro(){
        window.location= "ViagemDescontoMotoristaControlador?acao=novocadastro","cadDesconto";
    }

    function abrirLocalizarFornecedor(){
        abrirLocaliza("${homePath}/FornecedorControlador?acao=localizarFinan&modulo=gwFinan", "locFornecedorFinan");
    }
    
    function limparFornecedor(){
        $("fornecedor").value = "";
        $("idFornecedor").value = "0";
    }
    
    function carregarCadastro(id){
        window.location = "ViagemDescontoMotoristaControlador?acao=carregar&idLancamento=" + id;
    }
    
    function aoClicarNoLocaliza(idjanela){
        if(idjanela == "Plano"){
            $("idplanocusto").value = $("idplanocusto_despesa").value;
            $("plcusto_descricao").value = $("plcusto_descricao_despesa").value;
        }
    }
    
</script>

<html>
    <style type="text/css">
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
    </style>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>webtrans - Movimenta&ccedil;&atilde;o de Desconto do Motorista</title>
    </head>
    <body onload="setDefault(); applyFormatter();">
        <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="85%" align="center">
            <tr>
                <td width="50%" align="left">
                    <span class="style4">Movimenta&ccedil;&atilde;o de Desconto do Motorista</span>
                </td>
                <td width="30%" align="right">
                </td>
                <td width="20%" align="right">
                    <input name="Novo Lançamento" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro()})" value="Novo Lançamento"/>
                    &nbsp;
                </td>
            </tr>
        </table>
        <br>
        <form action="ViagemDescontoMotoristaControlador?acao=listar" id="formulario" name="formulario" method="post">
            <input type="hidden" id="idplanocusto_despesa" name="idplanocusto_despesa" value="">
            <input type="hidden" id="plcusto_descricao_despesa" name="plcusto_descricao_despesa" value="">
            <input type="hidden" id="plcusto_conta_despesa" name="plcusto_conta_despesa" value="">
            <table class="bordaFina" width="85%" align="center">
                <tr class="CelulaZebra1">
                    <td align="right" width="5%">
                        <select name="campoConsulta" class="inputtexto" id="campoConsulta" >
                            <option value="descontar_apartir_de">Descontos Entre:</option>
                        </select>
                    </td>
                    <td width="28%">
                        <input name="dataDe" type="text" id="dataDe" size="11" maxlength="10"  class="fieldDateMin" onblur="alertInvalidDate(this)">
                         e
                        <input name="dataAte" type="text" id="dataAte" size="11" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDateMin">
                    </td>
                    <td align="right" width="13%">Motorista:</td>
                    <td class="CelulaZebra1" colspan="5">
                        <strong> 
                            <input type="hidden" name="idmotorista" id="idmotorista" value="0">
                            <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" value="" size="25" maxlength="80" readonly="true">
                            <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." 
                                   onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" 
                                   onClick="javascript:getObj('idmotorista').value = '0';javascript:getObj('motor_nome').value = '';"> 
                        </strong>
                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td width="6%" align="right">Plano de Custo:</td>
                    <td colspan="2">
                        <strong> 
                            <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
                            <input name="plcusto_descricao" type="text" id="plcusto_descricao" class="inputReadOnly" value="" size="15" maxlength="40" readonly="true">
                            <input name="localiza_plano_custo" type="button" class="botoes" id="localiza_plano_custo" value="..." 
                                   onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CUSTO_DESPESA%>', 'Plano')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                 onClick="javascript:getObj('idplanocusto').value = '0';javascript:getObj('plcusto_descricao').value = '';"> 
                        </strong>
                    </td>
                    <td width="6%" align="right">Viagem:</td>
                    <td colspan="3">
                        <strong> 
                            <input type="hidden" name="idviagem" id="idviagem" value="0">
                            <input name="numviagem" type="text" id="numviagem" class="inputReadOnly" value="" size="15" maxlength="40" readonly="true">
                            <input name="localiza_viagem" type="button" class="botoes" id="localiza_viagem" value="..." 
                                   onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VIAGEM%>', 'Viagem')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Viagem" 
                                 onClick="javascript:getObj('idviagem').value = '0';javascript:getObj('numviagem').value = '';"> 
                        </strong>
                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td align="center" colspan="8">                               
                        <input type="button" value="Visualizar" class="inputbotao" onclick="tryRequestToServer(function(){pesquisa()})">
                    </td>
                </tr>
            </table>
        </form>
        <form action="ViagemDescontoMotoristaControlador?acao=listar" id="formularioS" name="formularioS" method="post" target="pop">
            <table width="85%" border="0" cellpadding="0" cellspacing="1" class="bordaFina" align="center">
                <tr class="tabela">
                    <td width="8%"><strong>Id</strong></td>
                    <td width="8%"><strong>Data</strong></td>
                    <td width="25%"><strong>Motorista</strong></td>
                    <td width="8%"><strong>Viagem</strong></td>
                    <td width="10%"><strong>Plano</strong></td>
                    <td width="2%"></td>
                </tr>
                <c:forEach var="desconto" varStatus="status" items="${listaDesconto}">
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" id="tr_${status.count}">
                         <script>countRow++;</script>
                            <td align="center">
                                <a href="javascript: carregarCadastro('${desconto.id}')" class="linkEditar">${desconto.id}</a>
                            </td>
                            <td align="center">
                                ${desconto.descontarApartirDe}
                            </td>
                            <td align="center">
                                ${desconto.motorista.nome}
                            </td>
                            <td>
                                ${desconto.viagem.numViagem}
                            </td>
                            <td>
                                ${desconto.planoCusto.descricao}
                            </td>
                            <td align="center">
                                <a href="javascript: excluir('${desconto.id}', '${status.count}')"> 
                                    <img class="imagemLink" src="img/lixo.png"> 
                                </a>
                            </td>
                      </tr>
                 </c:forEach>
              </table>
              <br>
              <table width="85%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
                <tr class="CelulaZebra1">
                    <td colspan="8" align="center" >
                        
                    </td>
                </tr>
              </table>
         </form>
     </body>
</html>