<%-- 
    Document   : tabGerarReport
    Created on : 10/06/2015, 16:57:46
    Author     : anderson
--%>

<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="br.com.gwsistemas.reportbuilder.ReportBuilderBO"%>
<%@page import="nucleo.Apoio"%>
<%@page import="br.com.gwsistemas.eutil.Consulta"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link href="estilo.css" rel="stylesheet" type="text/css">

<%
    response.setContentType("text/html;charset=ISO-8859-1");
    
    boolean temAcessoCriarReport = (Apoio.getUsuario(request).getAcesso("cadRelatorioPersonalizado") > 0);
    request.setAttribute("acessoReport", temAcessoCriarReport);
    
    

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    if(acao.equals("iniciar")){
        ReportBuilderBO bo = new ReportBuilderBO();
        Consulta filtro = new Consulta();
        filtro.setCampoConsulta("nome_relatorio");
        filtro.setFiltrosAdicionais(new StringBuilder(" and rotina_relatorio = ").append(request.getParameter("rotinaRelatorio")));
        filtro.setLimiteResultados(100);
        Collection lista = bo.listarRelatorios(filtro);
        
        
        request.setAttribute("listaRelatorioPersonalizado", lista);
        response.setContentType("text/html;charset=ISO-8859-1");
        
    }
%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
            <form id="formGerarRelatorio">
                <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                    <tr class="CelulaZebra2NoAlign" align="right">
                        <td colspan="4">
                            <c:if test="${acessoReport}">
                                <input class="inputbotao" type="button" id="" name="" onclick="novoCadastroRelatorioPersonalizado();" value="Novo Relatório" title="Cadastrar um novo relatório personalizado"/>
                                <input type="hidden" id="moduloRel" name="moduloRel"/>
                            </c:if>
                        </td>
                    </tr>
                    <tr class="tabela" align="center">
                        <td colspan="4">
                            Relatórios
                        </td>
                    </tr>
                    
                        <c:forEach items="${listaRelatorioPersonalizado}" var="report" varStatus="status">
                                <c:if test="${status.index%2 == 0}">
                                    <tr>
                                </c:if>
                                        <td class="CelulaZebra2">
                                            <label><input type="radio" name="radio" onclick="javascript:carregarFiltros(${report.id})">${report.table.name}</label>
                                        </td>
                                <c:if test="${status.index%2 == 1}">
                                    </tr>
                                </c:if>
                                <c:if test="${status.index%2 == 0 && status.last}">
                                    <td class="CelulaZebra2"></td>
                                    </tr>
                                </c:if>
                        </c:forEach>
                    <tr class="tabela">
                        <td colspan="2" align="center"> Colunas do Relatório </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <table width="100%" >
                                <tbody id="colunasRelatorioPersonalizado">
                                    
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr class="tabela" align="center">
                        <td colspan="4">
                            Filtros
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                                <input type="hidden" id="inputIdHidden" name="inputIdHidden" value="0">
                                <input type="hidden" id="viewName" name="viewName" value="0">
                                <input type="hidden" id="viewLabel" name="viewLabel" value="0">
                                <input type="hidden" id="reportTitle" name="reportTitle" value="0">
                                <input type="hidden" id="maxFiltro" name="maxFiltro" value="0">
                            <table width="100%" id="tabFiltros">
                                <tbody id="tabBodyFiltros"/>
                            </table>
                        </td>
                    </tr>
                    <tr class="tabela">
                        <td colspan="2" align="center"> Ordenação do Relatório </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <table width="100%" >
                                <tbody id="ordenacaoRelatorio">
                                    
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr class="CelulaZebra2" align="center">
                        <td colspan="4" align="center">
                            <input type="radio" name="impressaoDinamico" id="excel2" value="excel" checked />
                            <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                            <input type="radio" name="impressaoDinamico" id="word2" value="word" />
                            <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                            <input type="radio" name="impressaoDinamico" id="pdf2" value="pdf"/>
                            <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                        </td>
                    </tr>
                    <tr class="CelulaZebra2" align="center">
                        <td colspan="4" align="center">
                            <input type="button" value="Gerar Relatório" onclick="gerarRelatorio()" class="inputbotao" >
                            <input type="button" value="pre-visualizar"  onclick="previsualizar()" class="inputbotao" >
                        </td>
                    </tr>
                </table>
            </form>