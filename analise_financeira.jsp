<%-- 
    Document   : analise_financeira
    Created on : 27/11/2012, 16:45:57
    Author     : renan
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>  
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<LINK REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
    shortcut.add("enter",function() {pesquisar()});
    
    jQuery.noConflict();
    var countFaturas = 0;
    var countFaturasPorFilial = 0;
    var faturas = new Array();
      
    function setDefault(){
        $("campoConsulta").value = '<c:out value="${param.campoConsulta}"/>';
        $("tipoDataDesp").value = '<c:out value="${param.tipoDataDesp}"/>';
        $("dtinicial").value = '<c:out value="${param.dataDe}"/>';
        $("dtfinal").value = '<c:out value="${param.dataAte}"/>';
        $("mostrarDespesas").value = '<c:out value="${param.mostrarDespesas}"/>';
        //total das faturas
    <c:forEach var="analiseFinan" varStatus="status" items="${listaFaturamento}">
        <c:if test="${status.count == 1}">
                <c:forEach var="faturamento" varStatus="status" items="${analiseFinan.faturamentos}">                      
                        $("${faturamento.mes}_${faturamento.ano}").innerHTML = formatoMoeda(${faturamento.fatura}) ;
            </c:forEach>
        </c:if>
        <c:if test="${status.count > 1}">
                <c:forEach var="faturamento" varStatus="status" items="${analiseFinan.faturamentos}">   
                        var faturaArmazenada = parseFloat($("${faturamento.mes}_${faturamento.ano}").innerHTML);
                        $("${faturamento.mes}_${faturamento.ano}").innerHTML = formatoMoeda(faturaArmazenada + ${faturamento.fatura}) ;
            </c:forEach>
        </c:if>    
    </c:forEach>
        
            //total das despesas
    <c:forEach var="analiseDesp" varStatus="status" items="${listaDespesa}">
        <c:if test="${status.count == 1}">
                <c:forEach var="desp" varStatus="status" items="${analiseDesp.despesas}">                      
                        $("despesa_${desp.mes}_${desp.ano}").innerHTML = formatoMoeda(${desp.total}) ;
            </c:forEach>
        </c:if>
        <c:if test="${status.count > 1}">
                <c:forEach var="desp" varStatus="status" items="${analiseDesp.despesas}">   
                        var despesaArmazenada = parseFloat($("despesa_${desp.mes}_${desp.ano}").innerHTML);
                        $("despesa_${desp.mes}_${desp.ano}").innerHTML = formatoMoeda(despesaArmazenada + ${desp.total});
            </c:forEach>
        </c:if>    
    </c:forEach>  
            
            mostrarAnalisesPorFiliais(1);
            mostrarAnalisesPorFiliais(2);
            
            
        }
           
        function mostrarAnalisesPorFiliais(tipo){
            //            parametros 
            //            se 1 é faturas
            //            se 2 é despesas
            //            se 3 é plano custos  
        
            if(tipo == 1){
                $("plusTotalFat").style.display = ($("plusTotalFat").style.display == "none")?"":"none";
                $("minusTotalFat").style.display = ($("minusTotalFat").style.display == "none")?"":"none";
                var i = 1;
                while($("trFilial_"+i) != undefined && $("trFilial_"+i) != null ){
                    $("trFilial_"+i).style.display = ($("trFilial_"+i).style.display =="none")?"":"none";                
                    i++;
                }
            }else if(tipo == 2){
                $("plusTotalDesp").style.display = ($("plusTotalDesp").style.display == "none")?"":"none";
                $("minusTotalDesp").style.display = ($("minusTotalDesp").style.display == "none")?"":"none";
                var i = 1;
                while($("trDespFilial_"+i) != undefined && $("trDespFilial_"+i) != null ){
                    $("trDespFilial_"+i).style.display = ($("trDespFilial_"+i).style.display =="none")?"":"none";                
                    i++;
                }
            }else if(tipo == 3){
                $("plusTotalPlan").style.display = ($("plusTotalPlan").style.display == "none")?"":"none";
                $("minusTotalPlan").style.display = ($("minusTotalPlan").style.display == "none")?"":"none";
                var j = 1;
                //$("trPlanoCustoLbl").style.display = ($("trPlanoCustoLbl").style.display =="none")?"":"none";
                while($("trPlanoCusto_"+j) != undefined && $("trPlanoCusto_"+j) != null ){
                    $("trPlanoCusto_"+j).style.display = ($("trPlanoCusto_"+j).style.display =="none")?"":"none";                
                    j++;
                }
            }
        
        }
        
          function pesquisar(){
            
            $("formulario").submit();
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
        .mylimite{
            height:60%;
            width: 100%;
            margin-left: auto;
            margin-right:auto;
            overflow-y:none;
            overflow-x:scroll;
            /*background-color:#DBE9F1;*/
        }
        -->
    </style>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>WebTrans - Análise Financeira</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>


    <body onload="setDefault(); "  >
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="82%" align="center">
            <tr>
                <td width="82%" align="left" > 
                    <span class="style4">Análise Financeira</span>
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="100%" align="center">
            <form action="AnaliseFinanceiraControlador?acao=consultaAnaliseFinanceira&" id="formulario" name="formulario" method="post">
                <tr> 
                    <td class="textoCampos" width="25%"> 

                    </td>
                    <td class="textoCampos" width="25%">
                        Período de
                        <strong>
                            <input name="dtinicial" type="text" id="dtinicial" value="" size="10" maxlength="10" 
                                   onblur="alertInvalidDate(this)"      onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)"class="fieldDate" />
                        </strong>                        
                    </td>
                    <td class="CelulaZebra2" width="25%">
                        até
                        <strong> 
                            <input name="dtfinal" type="text" id="dtfinal" value="" size="10" maxlength="10" 
                                   onblur="alertInvalidDate(this)"   onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" class="fieldDate" />
                        </strong> 
                        <input type="button" value="pesquisar" class="inputBotao" onclick="tryRequestToServer(function(){$('formulario').submit();})"/>
                    </td>
                    <td class="CelulaZebra2" width="25%">                                                
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra2" colspan="2" style="text-align: center"><strong> Filtros Receita</strong></td>
                    <td class="CelulaZebra2" colspan="2"  style="text-align: center"><strong>Filtros Despesa</strong></td>
                </tr>
                <tr>

                    <td  class="celulaZebra2" >
                        Critério de datas:
                        <select id="campoConsulta" name="campoConsulta" class="inputtexto" >
                            <option value="s.emissao_em" selected>Emissão CT/NFS</option>
                            <option value="f.emissao_em">Emiss&atilde;o Fatura</option>
                        </select>
                    </td>
                    <td class="celulaZebra2"></td>
                    <td class="celulaZebra2">
                        Critério de datas:
                        <select id="tipoDataDesp" name="tipoDataDesp" class="inputtexto">
                            <option value="dtemissao" >Emiss&atilde;o</option>
                            <option value="dtentrada">Entrada/Saída</option>
                            <option value="vencimento">Vencimento</option>
                            <option value="dtpago">Pagamento</option>
                            <!--                            <option value="competencia">Competência</option>-->
                        </select>
                    </td>
                    <td class="celulaZebra2">
                        Mostrar apenas:
                        <select id="mostrarDespesas" name="mostrarDespesas" class="inputtexto">
                            <option value="ambas">Ambas</option>
                            <option value="quitadas">Quitadas</option>
                            <option value="aberto">Em aberto</option>
                        </select>              
                    </td>

                </tr>
                <!--                <tr>
                                    <td class="TextoCampos" colspan="3">
                                        <div align="center" id="divDistribuicao" name="divDistribuicao" style="display:none;">
                                            Em caso de entregas locais, utilizar valores
                                            <select id="slDistribuicao" name="slDistribuicao" class="fieldMin">
                                                <option value="nf">da Nota de Servi&ccedil;o</option>
                                                <option value="ct" selected>do Conhecimento</option>
                                            </select>
                                        </div>
                                    </td>
                                </tr>-->
            </form>
        </table>
        <div class="mylimite" width="100%" align="center">
            <table class="bordaFina" width="100%" align="center">
                <tr>                
                    <td>
                        <table width="100%" >
                            <tbody id="tbAnaliseFinanceira">

                                <c:forEach var="analiseFinan" varStatus="status" items="${listaFaturamento}">
                                    <c:if test="${status.count == 1}">
                                        <tr class="tabela">
                                            <td colspan="100%" >Receitas</td>
                                        </tr>
                                        <tr id="trData">
                                            <td width="5%" class="CelulaZebra1"></td>
                                            <td  class="CelulaZebra1" width="7%" style="font-size: 10px;">MESES:</td>
                                            <c:forEach var="faturamento" varStatus="status" items="${analiseFinan.faturamentos}">
                                                <td class="CelulaZebra1" style="text-align:center">${faturamento.mes}/${faturamento.ano}</td>
                                            </c:forEach>
                                        </c:if>
                                    </c:forEach>
                                    <c:forEach var="analiseFinan" varStatus="status" items="${listaFaturamento}">
                                        <c:if test="${status.count == 1}">
                                        </tr>
                                    </c:if>
                                </c:forEach>            

                                <tr id="trFatura">

                                    <c:forEach var="analiseFinan" varStatus="status" items="${listaFaturamento}">
                                        <c:if test="${status.count == 1}">
                                            <td width="5%" class="CelulaZebra1">
                                                <img id="plusTotalFat" onclick="mostrarAnalisesPorFiliais(1)" src="img/plus.jpg" style="display:none"/><!--logica inversa-->
                                                <img id="minusTotalFat" onclick="mostrarAnalisesPorFiliais(1)" src="img/minus.jpg" />
                                            </td>

                                            <td  class="CelulaZebra1" width="7%" style="font-size: 10px;">
                                                FATURAS:
                                                <c:forEach var="faturamento" varStatus="status" items="${analiseFinan.faturamentos}">
                                                <td class="CelulaZebra2" style="text-align: right">
                                                    <label id="${faturamento.mes}_${faturamento.ano}" style="text-aling:right;"></label>
                                                </td>
                                            </c:forEach>
                                        </c:if>
                                    </c:forEach>
                                </tr>
                                <!-- FATURAS POR FILIAL-->
                                <c:forEach var="analiseFinan" varStatus="status" items="${listaFaturamento}">

                                    <tr id="trFilial_${status.count}">
                                        <td width="5%" class="CelulaZebra1"></td>
                                        <td  class="CelulaZebra2" width="7%" style="font-size: 8px;background-color: #CCCCCC;">
                                            ${analiseFinan.filial.abreviatura}
                                        </td>
                                        <c:forEach var="faturamento" varStatus="status" items="${analiseFinan.faturamentos}">
                                            <td class="CelulaZebra2" style="font-size: 8px;text-align: right;">
                                                <label>
                                                    <fmt:formatNumber value="${faturamento.fatura}" pattern="#,##0.00#"/>
                                                </label>
                                            </td>
                                        </c:forEach>
                                    </tr>
                                </c:forEach>                                
                                <c:forEach var="analiseDesp" varStatus="status" items="${listaDespesa}">
                                    <c:if test="${status.count == 1}">
                                        <tr class="tabela">
                                            <td colspan="100%" >Despesas</td>
                                        </tr>
                                        <tr id="trDespesaTotal">
                                            <td width="5%" class="CelulaZebra1">
                                                <img id="plusTotalDesp" onclick="mostrarAnalisesPorFiliais(2)" src="img/plus.jpg" style="display:none" /><!--logica inversa-->
                                                <img id="minusTotalDesp" onclick="mostrarAnalisesPorFiliais(2)" src="img/minus.jpg" />
                                            </td>
                                            <td class="CelulaZebra1" style="font-size: 10px;">TOT.DESP:</td>
                                            <c:forEach var="desp" varStatus="status" items="${analiseDesp.despesas}">
                                                <td class="CelulaZebra2" style="text-align: right">
                                                    <label id="despesa_${desp.mes}_${desp.ano}" style="text-aling:right;"></label>
                                                </td>                          
                                            </c:forEach>
                                        </tr>           
                                    </c:if>   
                                </c:forEach>
<!--                            <script>var valor=  0.00; </script>-->
                            <!-- DESPESAS POR FILIAL-->
                            <c:forEach var="analiseDesp" varStatus="status" items="${listaDespesa}">

                                <tr id="trDespFilial_${status.count}">
                                    <td width="5%" class="CelulaZebra1"></td>
                                    <td  class="CelulaZebra2" width="7%" style="font-size: 8px;background-color: #CCCCCC;">
                                        ${analiseDesp.filial.abreviatura}
                                    </td>
                                    <c:forEach var="desp" varStatus="status" items="${analiseDesp.despesas}">
                                        <td class="CelulaZebra2" style="font-size: 8px;text-align: right;">
                                            <label>
                                                <fmt:formatNumber value="${desp.total - desp.descontos + desp.acrescimos}" pattern="#,##0.00#"/>
<!--                                                <script>valor+=${desp.total - desp.descontos + desp.acrescimos}</script>-->
                                            </label>
                                        </td>
                                    </c:forEach>    
                                </tr>
                            </c:forEach> 
<!--                            <script>alert(valor)</script>-->
                            <tr id="trPlanoCusto" class="tabela">
                                <td colspan="100%" >Plano Custo</td>
                            </tr>
                            <c:forEach var="anaPlanCust" varStatus="status" items="${listaPlanoCusto}">
                                <c:if test="${status.count == 1}">
                                    <tr id="trPlanoCustoLbl" >
                                        <td  class="CelulaZebra1">
                                            <img id="plusTotalPlan" onclick="mostrarAnalisesPorFiliais(3)" src="img/plus.jpg" /><!--logica inversa-->
                                            <img id="minusTotalPlan" onclick="mostrarAnalisesPorFiliais(3)" src="img/minus.jpg" style="display:none" />
                                        </td>
                                        <td class="CelulaZebra1">Conta</td>
                                        <td class="CelulaZebra1">Descrição</td>
                                        <td class="CelulaZebra1">Valor</td>
                                        <td class="CelulaZebra1">Desconto</td>
                                        <td class="CelulaZebra1">Acrésc.</td>
                                    </tr>  
                                </c:if>
                                    <tr id="trPlanoCusto_${status.count}" style="display: none">
                                    <td class="CelulaZebra2"></td>
                                    <td class="CelulaZebra2">${anaPlanCust.conta}</td>
                                    <td class="CelulaZebra2">${anaPlanCust.descricao}</td>
                                    <!-- ATENÇÃO: Foi colocado valorSintetico pois em conversa com Deivid dia 05/04/2019 foi dito que o campo aqui deve ser o liquido por causa dos impostos -->
                                    <td class="CelulaZebra2"><fmt:formatNumber value="${anaPlanCust.valorSintetico}" pattern="#,##0.00#"/></td>
                                    <td class="CelulaZebra2"><fmt:formatNumber value="${anaPlanCust.desconto}" pattern="#,##0.00#"/></td>
                                    <td class="CelulaZebra2"><fmt:formatNumber value="${anaPlanCust.acrescimo}" pattern="#,##0.00#"/></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </td>               
                </tr>
            </table>
        </div>
        <br>

    </table>
</body>
</html>
