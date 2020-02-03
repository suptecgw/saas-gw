<%-- 
    Document   : report_builder
    Created on : 23/03/2015
    Author     : Anderson Espana
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_7_2.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script type="text/javascript">
    jQuery.noConflict();    

        
    jQuery(function() {
        
        window.REPORT_BUILDER_CONTROLLER = {
                
            init :function() {
                this.bindEvents();
            },
                
            bindEvents : function() {
                var self = this;
                jQuery("select[name=report-view]").change(function () {
                        
                    var viewLabel = jQuery(this).find('option:selected').text();
                    self.loadColumns(jQuery(this).val(), viewLabel);
                });
                    
            },
                
            loadColumns : function(viewName, viewLabel) {
                jQuery.ajax({
                    url: '<c:url value="/ReportBuilderControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        viewName : viewName,
                        viewLabel : viewLabel,
                        carregarAcao : "1",
                        idRelatorio : '${param.idRelatorio}',
                        modulo : '${param.modulo}',
                        acao : "getColumns"
                    },
                    success: function(data) {
                        var columns = jQuery("#columns")
                        columns.html(data);
                    }
                });
            }
        }
            
        REPORT_BUILDER_CONTROLLER.init();
            
    });
    
    function voltar(){
        tryRequestToServer(function(){
            window.location = "${homePath}/ReportBuilderControlador?acao=listar&modulo=${param.modulo != '' ? param.modulo : ''}";
        });
    }
    
    function carregar(){
        var action = '<c:out value="${param.acao}"/>';                
        
        if (action == 2) {
           jQuery("#views").val('<c:out value="${reportBuilder.table.name}"/>');
            var viewName = '<c:out value="${reportBuilder.table.name}"/>';
            var viewLabel = '<c:out value="${reportBuilder.table.label}"/>';
            espereEnviar("Aguarde...",true);
            
            jQuery.ajax({
                    url: '<c:url value="/ReportBuilderControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        viewName : viewName,
                        viewLabel : viewLabel,
                        carregarAcao : "2",
                        idRelatorio : '${param.idRelatorio}',
                        acao : "getColumns",
                        reportPerm : "${relatorio.permissao}"
                    },
                    success: function(data) {
                        var columns = jQuery("#columns")
                        columns.html(data);
                        
                        <c:forEach var="coluna" varStatus="status" items="${reportBuilder.columns}">
//                            jQuery("#inpTDescricao_"+$ {status.count}).val();
                            jQuery("input:text[name='label[${coluna.name}]']").val('${coluna.label}');
                            jQuery("input:checkbox[name='column[${coluna.name}]']")[0] != null ? jQuery("input:checkbox[name='column[${coluna.name}]']")[0].checked = true : "";

                            if (jQuery("input:checkbox[name='isTotalizador[${coluna.name}]']").length >= 1) {
                                if(${coluna.isTotalizador}){
                                    jQuery("input:checkbox[name='isTotalizador[${coluna.name}]']")[0].checked = '${coluna.isTotalizador}';
                                }
                            }
                        </c:forEach>
                            
                        //forEach de filtros
                        <c:forEach var="filtro" varStatus="status" items="${reportBuilder.filters}">
                            var col = '${filtro.column.name}';
                            var descId = jQuery("input[name*='label["+col+"]']").attr("id") != undefined ? jQuery("input[name*='label["+col+"]']").attr("id") : ""; 
                            var index = (descId.substring((descId.indexOf("_")+1)));
                            var operadores = jQuery("#operadores_"+col) != null ? jQuery("#operadores_"+col).val() : "";
                            var operadoresArray = operadores != null ? (operadores.substr(1,((operadores + "").length-2))).split(",") : "";
                            carregarFiltros('${filtro.column.name}', '${filtro.column.label}', index, '${filtro.column.id}', '${filtro.column.type}', '${filtro.column.isFiltroObrigatorio}'
                                    ,'${filtro.column.padraoTipoConsultaFiltro}','${filtro.column.padraoValorConsultaFiltro}','${filtro.column.padraoAlteravelConsultaFiltro}', 
                                    '${filtro.column.padraoCaseSensitiveFiltro}', '${filtro.column.padraoValoresDataFiltro}', operadoresArray);
                        </c:forEach>
                            
                        jQuery("#report-title").val('<c:out value="${reportBuilder.title}"/>');
                        <c:forEach items="${itemsOrdem}" var="ordem" varStatus="status">
                            carregandoOrdem('${ordem.colunaNome}', '${ordem.colunaDescricao}', '${status.count}', '${ordem.idOrdem}', '${ordem.orientacao}', '${status.count}');
                        </c:forEach>
                        espereEnviar("Aguarde...",false);
                    }
                });
            
        }
        
    }    
    
    function carregandoOrdem(columnName, columnLabel, indexOrdem, idOrder, ordemOrientacao) {
                
                var filterEntry = 
                    '<tr id="trRemoverOrdem_'+indexOrdem+'" class="CelulaZebra2 indexOrdens" >' +
                    '<td><span style="cursor:auto"><img src="img/ordenar.png" width="13px" heigth="13px" class="handler"></span></td>'+
                    '   <td width="40%" id="ordem-' +columnName+ '">' +
                    '<label class="TESTE_ESCRITA_ORDEM">' + indexOrdenacao + '- </label>' + columnLabel + 
                    '      <input type="hidden" id="hidNomeOrdem_'+indexOrdem+'" name="ordem[' + columnName + ']" value="' + columnName + '" >' + 
                    '      <input type="hidden" id="hidlabelOrdem_'+indexOrdem+'" name="ordemLabel[' + columnName + ']" value="' + columnLabel + '" >' + 
                    '      <input type="hidden" id="hidIdOrdem_'+indexOrdem+'" name="ordemId[' + columnName + ']" value="' + idOrder + '" >' + 
                    '      <input type="hidden" class="hidOrdem_"  id="hidOrdem_'+ indexOrdem +'" name="hidOrdem[' + columnName + ']" value="' + indexOrdenacao + '" >' +
                    '   </td>' +
                    '   <td width="20%">' +
                    '       <select id="selectOrdem_'+ columnName +'" name="selectOrdem['+columnName+']" class="inputtexto">' +
                    '           <option value="ASC" ' + (ordemOrientacao != "" && ordemOrientacao != undefined && ordemOrientacao != null? (ordemOrientacao == "ASC" ? 'selected' : '' ) : '') + '> Crescente </option>' + 
                    '           <option value="DESC" ' + (ordemOrientacao != "" && ordemOrientacao != undefined && ordemOrientacao != null? (ordemOrientacao == "DESC" ? 'selected' : '' ) : '') + '> Decrescente </option>' + 
                    '       </select>' +
                    '   </td>' +
                    '   <td width="50%">' +
                    '      <input type="button" id="removerFilter" class="inputbotao" value="Remover" onclick="removerOrdem('+indexOrdem+')" />' +
                    '   </td>' +
                    '</tr>';
                    
                jQuery("#ordenacoes").append(filterEntry);
                indexOrdenacao = indexOrdenacao + 1;
            }
    
    function carregarFiltros(columnName, columnLabel, indexColuna, idColuna, columnType, isFiltroObrigatorio, padraoTipoConsulta, padraoValorConsulta, padraoAlteravelConsulta, 
    padraoCaseSensitiveFiltro, padraoValoresDataFiltro,operadoresArray) {

        var isDate = (columnType.toUpperCase().indexOf("Date".toUpperCase()) != -1);


            var options = "<option value='SELECIONE'>Selecione</option>";
            var tipoData = "";
            var isCaseSensitive = "";
            
            console.log(operadoresArray.length);
            for (var i = 0; i < operadoresArray.length; i++) {
                console.log(operadoresArray[i] + " - " + i);
                    if (operadoresArray[i].trim() == "IN") {
                        if ((columnType.toUpperCase().indexOf("String".toUpperCase()) != -1)) {//if tipo = String
                            options += "<option value='IN'>Igual a Palavra/Frase</option>";
                        }else {
                            options += "<option value='IN'>Apenas</option>";
                        }
                    }else if (operadoresArray[i].trim() == "NOT_IN") {
                        options += "<option value='NOT_IN'>Exceto</option>";
                    }else if (operadoresArray[i].trim() == "ALL_PARTS") {
                        options += "<option value='ALL_PARTS'>Todas as partes com</option>";
                    }else if (operadoresArray[i].trim() == "ONLY_START") {
                        options += "<option value='ONLY_START'>Apenas inicio</option>";
                    }else if (operadoresArray[i].trim() == "ONLY_END") {
                        options += "<option value='ONLY_END'>Apenas fim</option>";
                    }else if (operadoresArray[i].trim() == "EQUAL_MULTIPLE") {
                        options += "<option value='EQUAL_MULTIPLE'>Igual a palavra/frase(V&aacute;rios por virgula)</option>";
                    }else if (operadoresArray[i].trim() == "MAIOR_QUE") {
                        options += "<option value='MAIOR_QUE'>Maior que</option>";
                    }else if (operadoresArray[i].trim() == "MENOR_QUE") {
                        options += "<option value='MENOR_QUE'>Menor que</option>";
                    }else if (operadoresArray[i].trim() == "BETWEEN") {
                        options += "<option value='BETWEEN'>Entre</option>";
                    }else if (operadoresArray[i].trim() == "BOOLEAN") {
                        options = "<option value='Ambos'>Ambos</option>"
                                 +"<option value='TRUE'>SIM</option>"
                                 +"<option value='FALSE'>NÃO</option>";
                    }
                }
                
            if (columnType.toUpperCase().indexOf("String".toUpperCase()) != -1) {//String
//                options += "<option  value='ALL_PARTS'>Todas as partes com</option>"
//                          +"<option  value='IN'>Apenas</option>"
//                          +"<option  value='ONLY_START'>Apenas inicio</option>"
//                          +"<option  value='ONLY_END'>Apenas fim</option>"
//                          +"<option  value='EQUAL_MULTIPLE'>Igual a palavra/frase(V&aacute;rios por virgula)</option>";
//
                isCaseSensitive = "<br> <input type='checkbox' name='isCaseSensitive["+columnName+"]' id='isCaseSensitive_"+indexColuna+"' "+(padraoCaseSensitiveFiltro == "true" ? "checked" : "")+" /> Diferenciar Maiúsculas de minúsculas"
//            }else if (columnType.toUpperCase().indexOf("integer".toUpperCase()) != -1) {//Int
//                options += "<option value='IN'>Igual</option>"
//                          +"<option value='BETWEEN'>Entre</option>"
//                          +"<option value='MAIOR_QUE'>Maior que</option>"
//                          +"<option value='MENOR_QUE'>Menor que</option>";
//
//            }else if (columnType.toUpperCase().indexOf("Double".toUpperCase()) != -1) {//Double, numeric ou float
//                options += "<option value='IN'>Igual</option>"
//                          +"<option value='BETWEEN'>Entre</option>"
//                          +"<option value='MAIOR_QUE'>Maior que</option>"
//                          +"<option value='MENOR_QUE'>Menor que</option>";
//
//            }else if (columnType.toUpperCase().indexOf("BigDecimal".toUpperCase()) != -1) {//Double, numeric ou float
//                options += "<option value='IN'>Igual</option>"
//                          +"<option value='BETWEEN'>Entre</option>"
//                          +"<option value='MAIOR_QUE'>Maior que</option>"
//                          +"<option value='MENOR_QUE'>Menor que</option>";
//
//            }else if (columnType.toUpperCase().indexOf("boolean".toUpperCase()) != -1) {//boolean
//                //obs quanto a booleano: não tem SELECIONE é apenas AMBOS, 
//                //logo, ele não recebe o primeiro option e sim sobrescreve com suas proprias opcoes
//                options = "<option value='Ambos'>Ambos</option>"
//                         +"<option value='TRUE'>SIM</option>"
//                         +"<option value='FALSE'>NÃO</option>";
//
            }else if (columnType.toUpperCase().indexOf("Date".toUpperCase()) != -1) {//Date
//                options += "<option value='BETWEEN'>Entre</option>"
//                          +"<option value='IN'>Apenas</option>";
                    
                tipoData = "<select class='inputtexto' name='padraoValorDataConsulta["+columnName+"]' id='padraoValorDataConsulta_"+indexColuna+"'>"
                          +"<option value='DIA_ATUAL'>Dia Atual</option>"
                          +"<option value='SEMANA_ATUAL'>Semana Atual</option>"
                          +"<option value='QUINZENA_ATUAL'>Quinzena Atual</option>"
                          +"<option value='MES_ATUAL'>Mês atual</option>"
                          +"</select>"
                          +"<input type='hidden' id='hidIsData_"+indexColuna+"' value='"+isDate+"' name='hidIsData_"+indexColuna+"'>";
              }
//                  
//            }else if (columnType.toUpperCase().indexOf("Time".toUpperCase()) != -1) {//Time
//                options += "<option value='BETWEEN'>Entre</option>"
//                          +"<option value='IN'>Apenas</option>";
//
//            }
            
            var select = "<select name='padraoTipoConsulta["+columnName+"]' id='padraoTipoConsulta_"+indexColuna+"' class='inputtexto' style=' width:150px'>"
                         +options
                         +"</select>";
                 
            var filterEntry = 
                '<tr id="trRemoverFilter_'+indexColuna+'" class="CelulaZebra2" >' +
                '   <td width="20%" id="filter-' +columnName+ '">' + columnLabel + 
                '      <input type="hidden" id="hidNomeColuna_'+indexColuna+'" name="filter[' + columnName + ']" value="' + columnName + '" >' + 
                '      <input type="hidden" id="hidIdColuna_'+indexColuna+'" value="' + idColuna + '" >' + 
                '   </td>' +
                '   <td width="10%">'+
                    select+
                    isCaseSensitive+
                '   </td>' +
                '   <td>'+
                (isDate? tipoData :
                '       <input type="text" name="padraoValorConsulta['+columnName+']" id="padraoValorConsulta_'+indexColuna+'" value="'+padraoValorConsulta+'" size="30" class="inputtexto" />')+
                '   </td>' +
                '   <td>'+
                '      <label class="labelAlteravel" id="labelAlteravel_'+indexColuna+'"> <input type="checkbox" '+(padraoAlteravelConsulta == "true" ? "checked" : "" )+' id="padraoIsConsulta_'+indexColuna+'" name="padraoIsConsulta['+columnName+']" >SIM </label>' + 
                '   </td>' +
                '   <td width="35%">' +
                '      <label class="labelObriga" id="labelObrigatorio'+indexColuna+'"> <input type="checkbox"'+(isFiltroObrigatorio == "true" ? "checked" : "" )+' id="checkIsFiltroObrigatorio_'+indexColuna+'" name="isFiltroObrigatorio['+columnName+']" > Campo obrigatório </label>' + 
                '   </td>' +
                '   <td width="25%">' +
                '   <a href="javascript: removerFiltro('+indexColuna+')"><img class="buttonRemoveFilter'+indexColuna+'" id="removerFilter" src="img/lixo.png" title="Remover Filtro"/></a>'+
//                '      <input type="button" id="removerFilter" class="inputbotao buttonRemoveFilter'+indexColuna+'" value="Remover" onclick="removerFiltro('+indexColuna+')" />'+
                '   </td>' +
                '</tr>';

        jQuery("#filters").append(filterEntry);
        
        jQuery("#padraoTipoConsulta_" + indexColuna + " option[value="+(padraoTipoConsulta == "" ? "SELECIONE" : padraoTipoConsulta)+"]").prop("selected",true);
        if (padraoValoresDataFiltro != "") {
            jQuery("#padraoValorDataConsulta_" + indexColuna + " option[value="+padraoValoresDataFiltro+"]").prop("selected",true);
        }
        
        if (isFiltroObrigatorio == 'true') {
            jQuery(".buttonRemoveFilter"+indexColuna).hide();
        }

        if (!isDate) {
                    jQuery("#labelObrigatorio"+indexColuna).hide();
                    jQuery("#labelObrigatorio"+indexColuna).switchClass("labelObriga","labelObrigaHIDE");
                }else{
                    
                    
                    
                        if(isFiltroObrigatorio == 'true'){
                            jQuery("#checkIsFiltroObrigatorio_"+indexColuna).attr("disabled","disabled");
                        }
    
                    
                            jQuery("#checkIsFiltroObrigatorio_"+indexColuna).click(function(){
                                console.log("INDEX = " + indexColuna);
                                
                                jQuery("input[id*=checkIsFiltroObrigatorio_]").removeAttr("checked");
                                jQuery("input[id*=checkIsFiltroObrigatorio_]").removeAttr("disabled");
                                jQuery("#checkIsFiltroObrigatorio_"+indexColuna).attr("disabled","disabled");
                                jQuery("#checkIsFiltroObrigatorio_"+indexColuna).prop("checked",true);
                                jQuery("img[class*='buttonRemoveFilter'").show();                        
                                jQuery(".buttonRemoveFilter"+indexColuna).hide();
                                
                            });
                        
                    
                }
                
    
    }
    
        
</script>

<html>
    <head>
        <script type="text/javascript" src="script/tiny_mce/tiny_mce.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Construtor de Relatórios</title>
        <style type="text/css">
            <!--
            .style3 {color: #333333}
            .style4 {
                font-size: 14px;
                font-weight: bold;
            }
            -->
        </style>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif"  alt="banner">
        <table class="bordaFina" width="85%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Construtor de Relatórios</span></td>
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>        
    <br>
    <table class="bordaFina" width="85%" align="center">
        <tr>
            <td colspan="4" align="center" class="tabela">Dados Principais</td>
        </tr>
        <tr>            
            <td class="TextoCampos" width="15%">
                <label for="views">Visão :</label>
            </td>
            <td class="CelulaZebra2">
                <div class="report-builder">
                    <!--caso a ação seja 2(iniciarEditar) é para apenas ver o nome da visão.-->
                    <c:if test="${param.acao == '2'}">
                        ${param.visao}
                    </c:if>
                    <!--caso a ação seja novoCadastro é para poder escolher o nome da visão.-->
                    <c:if test="${param.acao == 'novoCadastro'}">
                        <select name="report-view" id="views" class="inputtexto">
                            <option value="">Selecione uma visão...</option>
                            <c:forEach items="${viewList}" var="view">
                                <option value="${view.name}">${view.label}</option>
                            </c:forEach>
                        </select>
                    </c:if>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2">
               <div id="columns">

               </div>
            </td>
        </tr>
  
       </table>
    </body>

</html>
