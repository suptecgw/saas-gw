<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<c:choose>
    <c:when test="${operator eq 'BETWEEN'}">

        <input name="filter[${columnName}]" <c:if test="${columnType eq 'java.sql.Date'}" > class="rb-date-picker" </c:if> /> e 
        <input name="filter[${columnName}]" <c:if test="${columnType eq 'java.sql.Date'}" > class="rb-date-picker" </c:if> />

    </c:when>
    <c:otherwise>

        <c:if test="${columnType eq 'java.sql.Date'}" >
            <input name="filter[${columnName}]" class="rb-date-picker" />
        </c:if>

        <c:if test="${columnType ne 'java.sql.Date'}" >
            <select class="chosen-select" data-placeholder="Selecione um ou mais valores" name="filter[${columnName}]" multiple>
                <c:forEach items="${columnValues}" var="value">
                    <option value="${value}">
                        <c:choose>
                            <c:when test="${not empty value}">
                                ${value}
                            </c:when>
                            <c:otherwise>
                                Não informado
                            </c:otherwise>
                        </c:choose>
                    </option>
                </c:forEach>
            </select>
        </c:if>

    </c:otherwise>
</c:choose>