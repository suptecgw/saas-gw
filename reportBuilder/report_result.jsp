<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%

    String export = request.getParameter("export");

    if (export != null && !export.isEmpty()) {
        String reportName = request.getParameter("reportTitle");
        //tratamento do nome:
        reportName = (reportName.replace(" ", "_"));
        if (request.getAttribute("tipoImpressao") != null && request.getAttribute("tipoImpressao").equals("word")) {
            String header = "inline; filename="+reportName+".doc";
            response.setContentType("application/vnd.ms-word");
            response.setHeader("Content-Disposition", header);
        }
        
    }
%>
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("xlsx.core.min.js")%>"  language="JavaScript" />
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("Blob.js")%>"  language="JavaScript" />
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("FileSaver.js")%>"  language="JavaScript" />
<script type="text/javascript" src="script/<%=Apoio.noCacheScript("Export2Excel.js")%>"  language="JavaScript" />
<script type="text/javascript"  language="JavaScript">
    var export = "<%=export == null ? "" : export%>";
    function fechar(){
        window.close();
    }
</script>

<c:if test="${param.export == null || param.export == ''}">
        <table border="1" width="75%" align="center">
            <tr>
                    <td width="82%" align="left"> <span>Relatório Personalizado</span></td>
                    <td><input type="button" value=" Fechar " onclick="javascript:window.close();"/></td>
            </tr>
        </table>
</c:if>
<c:choose>
    <c:when test="${empty result}">
        <table width="75%" align="center" id="results">
            <tr>
                <td>Não há resultados para a sua pesquisa</td>
            </tr>
        </table>
    </c:when>
    <c:otherwise>
        <table <c:if test="${param.export == null || param.export == ''}">border="1"</c:if> width="75%" align="center" id="results">
            <tr>
                <td colspan="${report.columns.size() + 1}" align="center" ><font size="4">${report.title}</font></td>
            </tr>
            <tr>
                ${existeTotal?"<td></td>": ""}
                <c:forEach items="${report.columns}" var="column">
                    <td> <b> ${column.label} </b></td> 
                </c:forEach>
            </tr>
            <c:forEach items="${result}" var="values" varStatus="status">
                <tr class="CelulaZebra2">
                    ${existeTotal?"<td></td>": ""}
                    <c:forEach items="${values}" var="value">
                        <td>${value}</td>
                    </c:forEach>
                </tr>
                <c:if test="${status.last && existeTotal}">
                    <tr>
                        ${existeTotal?"<td>Totais:</td>": ""}
                            <c:forEach items="${report.columns}" var="column">
                                <td>
                                <c:forEach items="${listaTotal}" var="total">
                                    <c:if test="${column.name == total}"> 
                                        ${column.totalColunaStr}
                                    </c:if>
                                </c:forEach>
                                </td>
                            </c:forEach>
                    </tr>
                </c:if>
            </c:forEach>
        </table>
                <br>                
</c:otherwise>
</c:choose>