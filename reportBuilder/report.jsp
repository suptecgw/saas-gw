<%-- 
    Document   : report
    Created on : 04/03/2015, 00:21:06
    Author     : Sostenes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Construtor de Relatórios</title>

        <link rel="stylesheet" type="text/css" href="js/chosen/chosen.min.css">
        <link rel="stylesheet" type="text/css" href="js/jqueryui/jquery-ui.min.css">
    </head>
    <body>
        <form action="<c:url value="ReportBuilderController"/>?acao=doReport&export=yes" method="post">

            <h1>${report.title}</h1>

            <h3>Visão: ${report.table.label}</h3>
            <input type="hidden" name="viewName" value="${report.table.name}">
            <input type="hidden" name="viewLabel" value="${report.table.label}">
            <input type="hidden" name="reportTitle" value="${report.title}">

            <h4>Colunas</h4>
            <ul>
                <c:forEach items="${report.columns}" var="column">
                    <li>
                        ${column.label}
                        <input type="hidden" name="column[${column.name}]" value="${column.name}">
                        <input type="hidden" name="label[${column.name}]" value="${column.label}">
                        <input type="hidden" name="type[${column.name}]" value="${column.type}">
                    </li>
                </c:forEach>
            </ul>

            <h4>Filtros</h4>
            <ul>
                <c:forEach items="${report.filters}" var="filter">
                    <li>
                        <label for="op-${filter.column.label}">${filter.column.label}</label>
                        <input type="hidden" class="column-name" value="${filter.column.name}">
                        <input type="hidden" name="label[${filter.column.name}]" value="${filter.column.label}">
                        <input type="hidden" name="type[${filter.column.name}]" value="${filter.column.type}">
                        
                        <select name="op[${filter.column.name}]" id="op-${filter.column.label}">
                            <c:forEach items="${operators[filter]}" var="operator">
                                <option value="${operator}">${operator.label}</option>
                            </c:forEach>
                        </select>
                        <span class="filterValues"></span>
                    </li>
                </c:forEach>
            </ul>
            <input type="submit" value="Gerar Relatório" >
            <button type="subimit" formaction="<c:url value="ReportBuilderController"/>?acao=doReport" formtarget="_blank">Preview</button>
        </form>
    </body>
</html>
<script type="text/javascript" src="js/jquery-1.11.2.min.js"></script>
<script type="text/javascript" src="js/chosen/chosen.jquery.min.js"></script>
<script type="text/javascript" src="js/jqueryui/jquery-ui.min.js"></script>
<script type="text/javascript">
    
    jQuery(function(){
        
        window.REPORT_EXPORTER_CONTROLLER = {
            
            init : function() {
                
                var self = this;
                
                var viewName = jQuery("input[name=viewName]").val();
                
                self.loadValues(viewName);
            },
            
            loadValues : function (viewName) {
                
                jQuery('select[name^=op]').change(function() {
                            
                    var self = this;
                    
                    var columnName = $(self).parent("li").find('.column-name').val();
                    var columnType = $(self).parent("li").find('input[name^=type]').val();
                    
                    console.log(columnName);
                            
                    var operator = jQuery(self).find('option:selected').val();
                                
                    jQuery.ajax({
                        url: '<c:url value="/ReportBuilderController" />',
                        dataType: "text",
                        data: {
                            viewName : viewName,
                            columnName : columnName,
                            columnType : columnType,
                            operator : operator,
                            acao : "getFilterValues"
                        },
                                
                        success : function(data) {
                                    
                            jQuery(self).parents("li").find(".filterValues").html(data);
                                    
                            jQuery('.chosen-select').chosen({
                                width : "300px" 
                            });
                            
                            jQuery('.rb-date-picker').datepicker({
                                dateFormat: "yy-mm-dd",
                                dayNames: [ "Domingo", "Segunda", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado" ],
                                dayNamesMin: [ "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" ],
                                dayNamesShort: [ "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" ],
                                monthNames: [ "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro" ],
                                monthNamesShort: [ "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" ],
                                changeMonth: true,
                                changeYear: true
                                
                            });
                        }
                    });
                }).change();
            }
        }
        
        REPORT_EXPORTER_CONTROLLER.init();
        
    });
    
</script>
