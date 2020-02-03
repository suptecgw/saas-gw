<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

        <title>WEBTRANS - Relatório de Orçamentação</title>

        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">

<link rel="stylesheet" href="estilo.css" type="text/css">
<link rel="stylesheet" href="css/jQuery/jquery-ui.min.css" type="text/css">
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script type="text/javascript" src="script/jQuery/jquery-ui.js"></script>

<script type="text/javascript" language="javascript">
        jQuery.noConflict();
    jQuery(function() {
            window.RELATORIO_ORCAMENTACAO = {
                init : function() {
                }
                
            },
            RELATORIO_ORCAMENTACAO.init();
              
            
        });

        function PlanoDeCusto() {
            
        }

        function addPlanoDeCusto(planoDeCusto) {
            if (planoDeCusto == null || planoDeCusto == undefined) {
                planoDeCusto = new PlanoDeCusto();
            }
        }

        function carregar() {
            document.formulario.dataIniCompetencia.value = ('<c:out value="${param.dataAtual}"/>').substr(3, ('<c:out value="${param.dataAtual}"/>').length);
            document.formulario.dataFinalCompetencia.value = ('<c:out value="${param.dataAtual}"/>').substr(3, ('<c:out value="${param.dataAtual}"/>').length);
        }









// Autor: Wagner Cunha
    function aoClicarNoLocaliza(idjanela){
        var planoCusto ;
        if(idjanela == 'Plano'){
            planoCusto = new PlanoCusto();
          
            planoCusto.idPlanoCusto = $("idplanocusto").value;
            planoCusto.descricaoPlanoCusto = $("plcusto_descricao").value;
            planoCusto.plCustoConta = $("plcusto_conta").value;
            addPlanoCusto(planoCusto);
        }
    }
    function PlanoCusto(idPlanoCusto,descricaoPlanoCusto,plCustoConta){
        this.idPlanoCusto = (idPlanoCusto== null || idPlanoCusto == undefined ? 0 : idPlanoCusto);
        this.descricaoPlanoCusto = (descricaoPlanoCusto == null || descricaoPlanoCusto == undefined? 0 : descricaoPlanoCusto);
        this.plCustoConta = (plCustoConta == null || plCustoConta == undefined? 0 : plCustoConta);
    }

    // DOM para escolha dos Plano de Custo Autor: Wagner Cunha
    var countPlanoCusto = 0;
    function addPlanoCusto(planoCusto){
        if(planoCusto == null || planoCusto == undefined){
            planoCusto = new PlanoCusto();
        }
        countPlanoCusto++;
        var tabelaBase = $("bodyPlanoCusto");
        var tr0 = new Element ("tr" ,{
            id : "trPlanoCusto_"+countPlanoCusto ,
            className : "CelulaZebra2"
        });
        
        var td0 = new Element("td", {
            align : "center"
        });
        
        var img0 = Builder.node("img",{
            src: "img/lixo.png", 
            title:"Excluir Plano de Custo", 
            className:"imagemLink" ,
            onClick: "callExcluirPagto("+countPlanoCusto+")"

        });
        td0.appendChild(img0);
        tr0.appendChild(td0);
        var td1 = new Element ("td" , {
            align : "center" 
        }); 
        // Id Plano Custo
        var inp1 = new Element ("input" , {
            type  : "hidden" ,
            name  : "planoCustoId_" + countPlanoCusto , 
            id    : "planoCustoId_" + countPlanoCusto , 
            value : planoCusto.idPlanoCusto
        });
        // Descrição Plano Custo
        var text0 = Builder.node ("input", {
            id : "plCustoConta_" + countPlanoCusto ,
            name : "plCustoConta_" + countPlanoCusto ,
            className:"inputReadOnly8pt" ,
            readonly : true ,
            type  : "text" ,
            size  : "15" ,
            value : planoCusto.plCustoConta
        });   
        var text1 = Builder.node ("input", {
            id : "planoCusto_" + countPlanoCusto ,
            name : "planoCusto_" + countPlanoCusto ,
            className:"inputReadOnly8pt" ,
            readonly : true ,
            type  : "text" ,
            size  : "30" ,
            value : planoCusto.descricaoPlanoCusto
            
        });
        td1.appendChild(inp1);
        td1.appendChild(text0);
        td1.appendChild(text1);
        
        tr0.appendChild(td1);
        tabelaBase.appendChild(tr0);
        
        $("max").value = countPlanoCusto;
    }

function callExcluirPagto(id){
        if (confirm("Tem certeza que deseja remover o plano de custo " + $('planoCusto_'+id).value+ " da lista abaixo?")){
            Element.remove($('trPlanoCusto_' + id));
        }
    }
    
    function imprimir(){
        var formulario = $("formulario");
        var filiaisDesmarcadas = true;
        for (var i = 1;i <= $("maxFilial").value;i++) {
            if (document.getElementById("filial_"+i).checked) {
                filiaisDesmarcadas = false;
            }
        }
        if (filiaisDesmarcadas) {
            alert("Selecione pelo menos uma filial.");
            return false;
        }
        
        
       var modelo = jQuery('input[name="modelo"]:checked').val(); 
       var impressao;
          if ($("pdf").checked)
            impressao = "1";
          else if ($("excel").checked)
            impressao = "2";
          else
            impressao = "3";
        
        
        
            formulario.action = "${homePath}/RelatorioControlador?acao=relOrcamentacao&modelo="+modelo+"&impressao="+impressao;
                    
            formulario.enctype = "";
//            setEnv("btImportar");
          var janela = window.open('about:blank', 'pop1', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');

//        var janela = window.open('about:blank', 'pop1', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
//        launchPDF('$ {homePath}/RelatorioControlador?acao=relOrcamentacao&modelo='+modelo+'&impressao='+impressao);
        
        formulario.submit();
        return true;
    }

    jQuery(document).ready(function() {
        jQuery('input[name="modelo"]').on('change', function() {
            var valor = this.value;
            
            if (valor === '2' || valor === '3') {
                jQuery('#tipoData').val('c').attr('disabled', 'disabled');
            } else {
                jQuery('#tipoData').removeAttr('disabled');
            }
        });
    });

    </script>
    <!DOCTYPE html>

    <style type="text/css">
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }trContasBancarias
    </style>


</head>
<body onload="applyFormatter();carregar();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);">
    <form action="${homePath}/RelatorioControlador?acao=relOrcamentacao" id="formulario" name="formulario" method="post" target="pop1"> 

        <img src="img/banner.gif"  alt="banner">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="82%" align="left"><span class="style4">Relatório de Orçamentação</span></td>
                <td><input type="button" value=" Fechar " class="inputbotao" onClick="window.close();"/></td>
            </tr>
        </table>
        <br>
        
         <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <div id="tabPrincipal">

        <table width="90%" align="center" class="bordaFina" >
            <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
            <input type="hidden" name="plcusto_conta" id="plcusto_conta" value="">
            <input type="hidden" name="modulo" id="modulo" value="Webtrans">
            <!--<input type="hidden" name="impressao" id="impressao" value="1">-->
            <tr>
                <td colspan="3" align="center" class="tabela" >Modelos</td>
            </tr>
            <tr>
                <td width="30%" class="CelulaZebra2">
                    <input type="radio" name="modelo" id="modelo1" value="1" checked>
                    <label for="modelo1">Modelo 1</label>
                </td>
                <td class="CelulaZebra2" width="70%">Acompanhamento diário de orçamentação</td>
            </tr>
            <tr>
                <td width="30%" class="CelulaZebra2">
                    <input type="radio" name="modelo" id="modelo2" value="2">
                    <label for="modelo2">Modelo 2</label>
                </td>
                <td class="CelulaZebra2" width="70%">Orçado X Realizado Por Plano de custo</td>
            </tr>
            <tr>
                <td width="30%" class="CelulaZebra2">
                    <input type="radio" name="modelo" id="modelo3" value="3">
                    <label for="modelo3">Modelo 3</label>
                </td>
                <td class="CelulaZebra2" width="70%">
                    <label>Orçado X Realizado Por</label>
                    <input type="radio" name="tipoRelatorio" id="tipoRelatorioFilial" value="f" checked>
                    <label for="tipoRelatorioFilial">Filial</label>
                    <input type="radio" name="tipoRelatorio" id="tipoRelatorioUnidade" value="u">
                    <label for="tipoRelatorioUnidade">Unidade de Custo</label>
                </td>
            </tr>
            <tr>
                <td colspan="3" align="center" class="tabela">Critério de datas</td>
            </tr>
            <tr>
                <td width="30%" class="TextoCampos">Por data de:</td>
                <td class="CelulaZebra2" colspan="2">
                    <select id="tipoData" name="tipoData" class="inputtexto">
                        <option selected="selected" value="e">Emissão</option>
                        <option value="c">Competência</option>
                    </select>
                    entre
                    <input id="dataIniCompetencia" name="dataIniCompetencia" class="inputTexto"type="text"  value="" size="6" maxlength="7" onkeypress="checaData(this)"/>
                    a
                    <input id="dataFinalCompetencia" name="dataFinalCompetencia" class="inputTexto"type="text"  value="" size="6" maxlength="7" onkeypress="checaData(this)"/>
                </td>
            </tr>
            <tr>
                <td align="center" class="tabela" colspan="3">Filtros</td>
            </tr>
            <tr>            
                <td class="CelulaZebra2" colspan="3">
                    <fieldset>
                        <legend align="left">Filiais</legend>
                        <table class="tabelaZerada" width="100%">
                            <tbody id="tbFilais">
                                <c:forEach var="filial" varStatus="status" items="${filiaisRelatorioOrcamentacao}">
                                    <c:if test="${status.count % 2 == 1}">
                                        <tr class="celulaZebra2">
                                    </c:if>
                                            <td>
                                                <label><input type="checkbox" id="filial_${status.count}" name="filial_${status.count}" value="${filial.id}"> </label>
                                                <label id="descFilial_${status.count}" name="descFilial_${status.count}" for="filial_${status.count}">${filial.abreviatura}</label>
                                                <input id="descricaoFilial_${status.count}" name="descricaoFilial_${status.count}" value="${filial.abreviatura}" type="hidden">
                                            </td>
                                    <c:if test="${status.count % 2 == 0}">
                                        </tr>
                                    </c:if>
                                    <c:if test="${status.last && status.count % 2 == 1}">
                                            <td>
                                            </td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${status.last}">
                                        <input type="hidden" name="maxFilial" id="maxFilial" value="${status.count}">
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>            
                <td class="CelulaZebra2" colspan="3">
                    <fieldset>
                        <legend align="left">Unidades de Custo</legend>
                        <table class="tabelaZerada" width="100%">
                            <tbody id="tbUnidades">
                                <c:forEach var="unidade" varStatus="status" items="${unidadesRelatorioOrcamentacao}">
                                    <c:if test="${status.count % 2 == 1}">
                                        <tr class="celulaZebra2">
                                    </c:if>
                                            <td>
                                                <label><input type="checkbox" id="unidade_${status.count}" name="unidade_${status.count}" value="${unidade.id}"> ${unidade.sigla} - ${unidade.descricao}</label>
                                                <input type="hidden" id="descricaoUnidade_${status.count}" name="descricaoUnidade_${status.count}" value="${unidade.sigla} - ${unidade.descricao}">
                                            </td>
                                    <c:if test="${status.last && status.count % 2 == 1}">
                                            <td>
                                            </td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${status.last}">
                                        <input type="hidden" name="maxUndCusto" id="maxUndCusto" value="${status.count}">
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr id="trPlano"> 
                <td colspan="9"> 
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tbody id="bodyPlanoCusto" name="bodyPlanoCusto" > 
                            <tr class="cellNotes"> 
                                <td width="3%" class="CelulaZebra2">
                                    <div align="center">
                                        <img src="img/add.gif" border="0" title="Adiciona um novo Plano de Custo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=32&fecharJanela=true&paramaux=1','Plano')">          
                                    </div>
                                </td>
                                <td width="97%" class="CelulaZebra2" >
                                    <input type="hidden" name="plcusto_descricao" id="plcusto_descricao" value="0"/>
                                    <input type="hidden" name="max" id="max" value="0" />
                                    <div align="center">
                                        <b>
                                            Apenas o(s) plano(s) de custo(s) abaixo
                                        </b>
                                    </div>
                                </td>
                            </tr>
                              <tr>
                                <td colspan="3" class="TextoCampos">
                                    <div align="center">
                                        <input type="radio" name="impressao" id="pdf" value="1" checked/>
                                        <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                                        <input type="radio" name="impressao" id="excel" value="2" />
                                        <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                                        <input type="radio" name="impressao" id="word" value="3" />
                                        <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                                    </div>
                                </td>
                              </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="2" class="CelulaZebra2NoAlign" align="center">
                    <input type="button" class="botoes" value=" Imprimir " onclick="imprimir();">
                </td>
            </tr>
        </table>
        </div>
        <div id="tabDinamico"></div>
    </form>
</body>
</html>
