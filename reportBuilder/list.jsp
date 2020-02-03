<%-- 
    Document   : index
    Created on : 10/01/2015, 15:29:03
    Author     : Sostenes
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Report Builder</title>
    </head>
    <body>
        <h3>Construtor de Relatórios</h3>
        
        <p><a href="<c:url value="ReportBuilderController?acao=getViews"/>">Criar Relatório</a></p>

        <c:if test="${!empty reportMap}">
        <h4>Lista de Relatórios</h4>
            <table border="1">
                <c:forEach items="${reportMap}" var="entry">
                    <tr>
                        <td>
                            <a href="<c:url value="ReportBuilderController" />?acao=openReport&reportId=${entry.key}" >
                                <c:out value="${entry.value}" />
                            </a>
                        </td>
                        <td>
                            
                            <form action="<c:url value="ReportBuilderController" />" method="post">
                                <input type="hidden" name="reportId" value="${entry.key}" >
                                <input type="hidden" name="acao" value="deleteReport" >
                                <input type="submit" value="Remover" >
                            </form>
                            
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </c:if>
    </body>
</html>
