<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
        <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>
        <script language="JavaScript" src="script/shortcut.js"></script>

        <script language="JavaScript" type="text/javascript">     
            jQuery.noConflict();
            
            function abrirLocalizarFornecedor(index){
                $("indexAux").value = index;
                launchPopupLocate('./localiza?acao=consultar&idlista=21&fecharJanela=true','Fornecedor')
            }
            
            function abrirLocalizaPlanoCusto(index){
                $("indexAux").value = index;
                launchPopupLocate('./localiza?acao=consultar&idlista=20&fecharJanela=true','Plano')
            }
            
            function abrirLocalizarUndCusto(index){
                if($("indexAux") != null){
                    $("indexAux").value = index;
                }
                popLocate(39, "Unidade_de_Custo","");
            }
            
            function aoClicarNoLocaliza(idJanela){
                try{
                    var index = $("indexAux").value;

                    if(idJanela == "Fornecedor"){
                        $('descFornecedor_'+index).value = $('fornecedor').value;
                        $('idFornecedor_'+index).value = $('idfornecedor').value;
                        $('historico_'+index).value = ($('descricao_historico').value != "" ? $('descricao_historico').value : $('historico_'+index).value);
                        if($('idplcustopadrao').value != "0"){
                            $("idPlanoCusto_"+ index).value = $('idplcustopadrao').value;
                            $("descPlanoCusto_"+ index).value = $('descricaoplcusto').value;
                            $("siglaUndCusto_"+ index).value = $('sigla_und_forn').value;
                            $("idUndCusto_"+ index).value = $('id_und_forn').value;
                        }
                    }else if(idJanela == "Plano"){
                        $("idPlanoCusto_"+ index).value = $('idplanocusto_despesa').value;
                        $("descPlanoCusto_"+ index).value = $('plcusto_descricao_despesa').value;
                    }else if(idJanela == "Unidade_de_Custo"){
                        $("siglaUndCusto_"+ index).value = $('sigla_und').value;
                        $("idUndCusto_"+ index).value = $('id_und').value;
                    }
                }catch(ex){
                    alert(ex);
                }
            }

            function voltar(){
                tryRequestToServer(function(){parent.document.location.replace("./conciliacaobanco?acao=iniciar")});
            }
            
            function salva(acao){
//                var max = parseInt($("maxConhecimento").value);
                var podeSalvar = true;
                try{
                    
                    $("formulario").action = "MovimentacaoBancariaControlador?acao=conciliacaoBancariaLote&conta="+$("conta").value;
                    setEnv();
                    window.open('about:blank', 'pop', 'width=210, height=100');
                    $("formulario").submit();
                }catch(ex){
                   // alert(ex);
                }
            }

            function excluir(id){
                if (confirm("Deseja mesmo excluir esta rota?")){
                    location.replace("consulta_rota.jsp?acao=excluir&id="+id);
                }
            }

            function importar(){
                var arq01 = $("arqExtrato").value;
                if (arq01 == "") {
                    alert("Selecione o arquivo.");
                    return false;
                }
                try {
                    var form = $("formularioUpload");
                    form.action = "MovimentacaoBancariaControlador?acao=importarExtrato&conta="+$("conta").value;
//                    window.open('about:blank', '', 'width=210, height=100');
                    form.submit();
                } catch (e) { 
                    alert(e);
                }

            }
            
            function setDefault(){
                $("conta").value = "${param.conta}";
            }
            
        </script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Conciliação Bancaria em Lote</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {color: #FF0000}
            .style2 {color: #0000FF}
            .style3 {color: red}
            .alignTextoCenter{text-align: center;}
            .style4{font-size: 14px; font-weight: bold;}
            -->
        </style>
    </head>

    <body onLoad="setDefault();">


        <input type="hidden" name="indexAux" id="indexAux" value="0">        
        <input type="hidden" name="fornecedor" id="fornecedor" value="0">        
        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">        
        <input type="hidden" name="descricao_historico" id="descricao_historico" value="0">        
        <input type="hidden" name="idplcustopadrao" id="idplcustopadrao" value="0">        
        <input type="hidden" name="contaplcusto" id="contaplcusto" value="0">        
        <input type="hidden" name="descricaoplcusto" id="descricaoplcusto" value="0">        
        <input type="hidden" name="sigla_und_forn" id="sigla_und_forn" value="0">        
        <input type="hidden" name="id_und_forn" id="id_und_forn" value="0">        
        <input type="hidden" name="id_und" id="id_und" value="0">        
        <input type="hidden" name="sigla_und" id="sigla_und" value="0">        
        <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="0">        
        <input type="hidden" name="plcusto_descricao_despesa" id="plcusto_descricao_despesa" value="0">        

        <img src="img/banner.gif" >

        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr >
                <td width="85%">
                    <div align="left">
                        <span class="style4">
                            <b>Conciliação Bancaria em Lote</b>                            
                        </span>
                    </div>
                </td>
                <td width="15%" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:tryRequestToServer(function(){voltar();});"></td>
            </tr>
        </table>
        <br>
        <table width="95%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">                
            <tr class="tabela" >
                <td colspan="2">Filtros</td>
            </tr>
            <tr>
                <td width="100%" colspan="2">
                    <form method="post"  id="formularioUpload" enctype="multipart/form-data" >
                        <table width="100%" class="bordaFina">
                            <tr class="CelulaZebra2NoAlign">
                                <td width="30%" class="TextoCampos"><div id="divConta">Conta para baixa:</div></td>
                                <td width="40%" class="CelulaZebra2">
                                    <select name="conta" id="conta" class="fieldMin">
                                        <option class="alignTextoCenter" value=""> --- Selecione uma conta --- </option>
                                        <c:forEach var="conta" varStatus="status" items="${listacbConta}" >
                                            <option  value="${conta.idConta}">${conta.numero}-${conta.digito_conta}/${conta.banco.descricao}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td width="30%" align="right" colspan="2" align="left">
                                    <input name="arqExtrato" id="arqExtrato" type="file" class="inputTexto" size="40" />
                                </td>                                
                            </tr>
                            <tr class="CelulaZebra2">
                                <td height="24" colspan="10"><center>
                                        <input name="botVisualizar" type="button" class="botoes" id="botVisualizar" value=" Visualizar[Alt+V] " onClick="javascript:tryRequestToServer(function(){importar();});">
                                    </center></td>
                            </tr>
                        </table>
                    </form>
                </td>
            </tr>
            <form method="post"  id="formulario" target="pop">

                <tr>
                    <td class="celulaZebra2">
                        <fieldset>
                            <legend>Cheques a compensar</legend>
                            <table class="bordaFina" width="100%">
                                <tr>
                                    <td width="3%"  class="celula"></td>
                                    <td width="10%" class="celula">Número</td>
                                    <td width="10%" class="celula">Dt. Entrada</td>
                                    <td width="10%" class="celula" style="text-align: right;">Valor</td>
                                    <td width="12%" class="celula">Despesa</td>
                                    <td width="40%" class="celula">Historico</td>
                                    <td width="15%" class="celula">Status</td>
                                </tr>
                                <tbody id="tbodyMov">
                                    <c:forEach items="${listaMovBanco}" var="mov" varStatus="status">
                                        <tr class="${status.count%2==0?'CelulaZebra1':'CelulaZebra2'} ${mov.idLancamento == 0 || mov.conciliado ? 'style3' :''}">
                                            <td >
                                                <input type="hidden" id="idLan_${status.count}" name="idLan_${status.count}" value="${mov.idLancamento}">
                                                <input type="checkbox" id="isBaixar_${status.count}" name="isBaixar_${status.count}"
                                                       ${mov.idLancamento == 0 || mov.conciliado ? 'disabled' :''} >
                                            </td>
                                            <td class="alignTextoCenter">${mov.docum}</td>
                                            <td class="alignTextoCenter">
                                                <input type="text" size="10"   id="dtEntrada_${status.count}" name="dtEntrada_${status.count}"  value="<fmt:formatDate value="${mov.dtEntrada}" pattern="dd/MM/yyyy"/>" ${mov.idLancamento == 0 || mov.conciliado ? '  class="inputReadOnly8pt" readonly' : 'class="fieldDate"'} >
                                            </td>    
                                     <td  style="text-align: right;">
                                                <fmt:formatNumber value="${mov.valor}" pattern="#,##0.00#"/>
                                            </td>
                                            <td class="alignTextoCenter">${mov.beanDuplDespesa.idmovimento != 0 ? mov.beanDuplDespesa.idmovimento: ''}</td>
                                            <td >${mov.historico}</td>
                                            <td >${mov.idLancamento == 0? 'Não encontrado' :(mov.conciliado ? 'Conciliado' : 'Não Conciliado')}</td>
                                        </tr>
                                        <c:if test="${status.last}">
                                                <input type="hidden" name="maxMov" id="maxMov" value="${status.count}">
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </fieldset>
                    </td>
                </tr>
                <tr>
                    <td class="celulaZebra2">
                        <fieldset>
                            <legend>Tarifas</legend>
                            <table class="bordaFina" width="100%">
                                <tr>
                                    <td width="10%" class="celula">Número</td>
                                    <td width="10%" class="celula">Dt Emissão</td>
                                    <td width="8%" class="celula" style="text-align: right;">Valor</td>
                                    <td width="22%" class="celula">Fornecedor</td>
                                    <td width="17%" class="celula">Plano Custo</td>
                                    <td width="8%" class="celula">Und. Custo</td>
                                    <td width="25%" class="celula">Historico</td>
                                </tr>
                                <tbody id="tbodyMov">
                                    <c:forEach items="${listaDespesas}" var="desp" varStatus="status">
                                        <tr class="${status.count%2==0?'CelulaZebra1':'CelulaZebra2'}">
                                            <td class="alignTextoCenter" >
                                                ${desp.nfiscal}
                                                <input id="docum_${status.count}" name="docum_${status.count}" type="hidden" value="${desp.nfiscal}" />
                                                <input id="serie_${status.count}" name="serie_${status.count}" type="hidden" value="${desp.serie}" />
                                            </td>
                                            <td class="alignTextoCenter">
                                                <fmt:formatDate value="${desp.dtEmissao}" pattern="dd/MM/yyyy"/>
                                                <input id="dtEmissao_${status.count}" name="dtEmissao_${status.count}" type="hidden" value="<fmt:formatDate value="${desp.dtEmissao}" pattern="dd/MM/yyyy"/>" />
                                            </td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${desp.valor}" pattern="#,##0.00#"/>
                                                <input id="despValor_${status.count}" name="despValor_${status.count}" type="hidden" value="<fmt:formatNumber value="${desp.valor}" pattern="#,##0.00#"/>" />
                                            </td>
                                            <td >
                                                <input id="descFornecedor_${status.count}" name="descFornecedor_${status.count}" type="text" size="26" class="inputReadOnly8pt" readonly value="${desp.fornecedor.razaosocial}" />
                                                <input id="idFornecedor_${status.count}" name="idFornecedor_${status.count}" type="hidden" size="35" class="inputReadOnly8pt" value="${desp.fornecedor.idfornecedor}" />
                                                <input type="button" class="inputBotaoMin" name="botaoFornecedor" id="botaoFornecedor"  onClick="javascript:tryRequestToServer(function(){abrirLocalizarFornecedor(${status.count})})" value="..."/>
                                            </td>
                                            <td >
                                                <input id="descPlanoCusto_${status.count}" name="descPlanoCusto_${status.count}" type="text" size="19" class="inputReadOnly8pt" readonly value="${desp.fornecedor.planoCustoPadrao.descricao}" />
                                                <input id="idPlanoCusto_${status.count}" name="idPlanoCusto_${status.count}" type="hidden" class="inputReadOnly8pt" value="${desp.fornecedor.planoCustoPadrao.idconta}" />
                                                <input type="button" class="inputBotaoMin" name="botaoPlanoCusto" id="botaoPlanoCusto"  onClick="javascript:tryRequestToServer(function(){abrirLocalizaPlanoCusto(${status.count})})" value="..."/>
                                            </td>
                                            <td >
                                                <input id="siglaUndCusto_${status.count}" name="siglaUndCusto_${status.count}" type="text" size="5" class="inputReadOnly8pt" readonly value="${desp.fornecedor.unidadeCusto.sigla}" />
                                                <input id="idUndCusto_${status.count}" name="idUndCusto_${status.count}" type="hidden" class="inputReadOnly8pt" value="${desp.fornecedor.unidadeCusto.id}" />
                                                <input type="button" class="inputBotaoMin" name="botaoUndCusto" id="botaoUndCusto"  onClick="javascript:tryRequestToServer(function(){abrirLocalizarUndCusto(${status.count})})" value="..."/>
                                            </td>
                                            <td >
                                                <input id="historico_${status.count}" name="historico_${status.count}" type="text" size="30" value="${desp.descHistorico}" class="inputTexto" />
                                            </td>
                                        </tr>
                                        <c:if test="${status.last}">
                                                <input type="hidden" name="maxDesp" id="maxDesp" value="${status.count}">
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </fieldset>
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td height="24" colspan="10"><center>
                            <input name="botSalvar" type="button" class="botoes" id="botSalvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva();});">
                        </center>
                    </td>
                </tr>
            </form>
        </table>
        <br>
    </body>
</html>
