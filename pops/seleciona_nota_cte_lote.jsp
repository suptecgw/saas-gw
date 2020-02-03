<%-- 
    Document   : seleciona_nota_cte_lote
    Created on : 30/03/2016, 14:52:52
    Author     : anderson
--%>

<%@page import="java.util.Arrays"%>
<%@page import="nucleo.Apoio"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="br.com.gwsistemas.NotaFiscal.arquivoImportacaoXML.ConsultaArquivoImportacaoXML"%>
<%@page import="java.util.ArrayList"%>
<%@page import="br.com.gwsistemas.NotaFiscal.arquivoImportacaoXML.ArquivoImportacaoXMLDAO"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.NotaFiscal.arquivoImportacaoXML.ArquivoImportacaoXML"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%

    Collection<ArquivoImportacaoXML> lista = new ArrayList<ArquivoImportacaoXML>();
    StringBuilder filtrosAdicionais = new StringBuilder();
    String dtEmissaoDe="";
    String dtEmissaoAte="";
    String cidadeDestino="";
    String ufDestino="";
    String idCliente;
    DateFormat formatter = new SimpleDateFormat("MM-dd-yyyy");
    Date dataDe = new Date();
    Date dataAte = new Date();
    
    if (request.getParameter("acao") != null && request.getParameter("acao").equals("pesquisarNotas")) {
        ArquivoImportacaoXMLDAO dao = new ArquivoImportacaoXMLDAO();
        ConsultaArquivoImportacaoXML filtro = new ConsultaArquivoImportacaoXML();
        dtEmissaoDe = request.getParameter("dataDe");
        dtEmissaoAte = request.getParameter("dataAte");
        idCliente = request.getParameter("idCliente");
        dataDe = (java.util.Date)formatter.parse(dtEmissaoDe);
        dataAte = (java.util.Date)formatter.parse(dtEmissaoAte);
        cidadeDestino = request.getParameter("cidadeDestino");
        ufDestino = request.getParameter("ufDestino");
        
        String layoutsConsulta = "";
        
        
        
        filtro.setCampoConsulta("num_doc");
        filtrosAdicionais.append(" and e.idcliente = ").append(idCliente);
        filtrosAdicionais.append(" and dt_emissao between '").append(dtEmissaoDe).append("' and '").append(dtEmissaoAte).append("' ");
        
        if(cidadeDestino != null && !cidadeDestino.trim().equals("")){
            filtrosAdicionais.append(" and destinatario_cidade ilike '").append(cidadeDestino).append("' ");
        }
        
        if(ufDestino != null && !ufDestino.trim().equals("")){
            filtrosAdicionais.append(" and destinatario_uf ilike '").append(ufDestino).append("' ");
        }
        
        filtro.setFiltrosAdicionais(filtrosAdicionais);
        filtro.setCte(false);
        filtro.setNfe(true);
        
        
        if (filtro.isCte()) {
            layoutsConsulta = "2";
        }
        if (filtro.isNfe()) {
            layoutsConsulta += (layoutsConsulta.length() > 0 ? "," : "") + "1";
        }
        if (layoutsConsulta.length() > 0) {
            filtrosAdicionais.append(" and aix.layout_doc in (").append(layoutsConsulta).append(") ");
        }
        lista = dao.localizar(filtro);
        
    }
    
%>
<!DOCTYPE html>
<script>
    function fechar(){
        window.close();
    }
    
    function seleciona(){
        pai = window.opener;
        var marcados = jQuery("input[type=checkbox][id^=chk_]:checked");
        var todos = "";
        var todosParaLabel = "";
        var todosPesquisa = "";
        var quantidade = 0;
        for(var i = 0; i < marcados.length; i++){
            todos += ", "+marcados[i].value;
            todosParaLabel += ","+marcados[i].value;
            todosPesquisa += ",'"+marcados[i].value+"'";
            quantidade++;
        }
        if (todos.length > 0) {
            todos = todos.substr(1);
        }
        
        if (todosParaLabel.length > 0) {
            todosParaLabel = todosParaLabel.substr(1);
        }
        
        if (todosPesquisa.length > 0) {
            todosPesquisa = todosPesquisa.substr(1);
        }
        
        if (pai.apenasNotas != null && pai.apenasNotas != undefined){
            pai.apenasNotas.value = todosPesquisa;
            pai.labelNotaEscolhidas.innerHTML = todos;
            pai.labelNotaEscolhidasFiltro.innerHTML = todosParaLabel;
            pai.labelQuantidade.innerHTML = quantidade;
            fechar();
        }
    }
    
    function marcaTodos(marcarTodos){jQuery("input[type=checkbox]").prop("checked",marcarTodos.checked);}
    
    function pesquisar(){
        var acao = "${param.acao}";
        var idCliente = "<%= request.getParameter("idCliente") %>";
        var dataDe = "<%= dtEmissaoDe %>";
        var dataAte = "<%= dtEmissaoAte %>";
        var notasSelecionadas = "<%= request.getParameter("notasSelecionadas") %>";
        var razaoRemetente = "<%= (request.getParameter("razaoRemetente") != null ? request.getParameter("razaoRemetente") : "") %>";
        var cidadeDestino = jQuery("#cidadeDestino").val();
        var ufDestino = jQuery("#ufDestino").val();
        location.href ="seleciona_nota_cte_lote.jsp?acao="+acao+"&idCliente="+idCliente
                +"&dataDe="+dataDe+"&dataAte="+dataAte+"&notasSelecionadas="
                +notasSelecionadas+"&razaoRemetente="+razaoRemetente
                +"&cidadeDestino="+cidadeDestino+"&ufDestino="+ufDestino;
    }
</script>
<html>
    <head>
        <script language="javascript" src="../script/funcoes.js" type=""></script>
        <script language="javascript" src="../script/jquery-1.11.2.min.js" type="text/javascript">jQuery.noConflict();</script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Escolher notas manualmente</title>
        <link href="../estilo.css" rel="stylesheet" type="text/css">
    </head> 

    <body>
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <td width="619"><div align="left"><b>WebTrans - Escolher notas manualmente </b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celulaZebra2">
                <td></td>
                <td class="textoCampos">Cliente :</td>
                <td><%= (request.getParameter("razaoRemetente") != null ? request.getParameter("razaoRemetente") : "") %></td>
                <td class="textoCampos">Data de emissão :</td>
                <td><%= Apoio.fmt(dataDe, "dd/MM/YYYY") %> à <%= Apoio.fmt(dataAte, "dd/MM/YYYY") %></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <tr class="celulaZebra2">
                <td></td>
                <td class="textoCampos">Filtros:</td>
                <td class="textoCampos">Cidade:</td>
                <td class="textoCampos"><input type="text" name="cidadeDestino" id="cidadeDestino" value="<%= (request.getParameter("cidadeDestino") != null ? request.getParameter("cidadeDestino") : "") %>" class="inputTexto"></td>
                <td class="textoCampos">UF:</td>
                <td><input type="text" name="ufDestino" id="ufDestino" value="<%= (request.getParameter("ufDestino") != null ? request.getParameter("ufDestino") : "") %>" class="inputTexto" size="4" maxlength="2"></td>
                <td><input type="button" value="Filtrar" class="botoes" onclick="javascript: pesquisar();"></td>
                <td></td>
            </tr>
            <tr> 
                <td width="2%" class="tabela"><input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcaTodos(this);"></td>
                <td width="9%" class="tabela">Número da NF</td>
                <td width="14%" class="tabela">Série</td>
                <td width="9%" class="tabela">Data de emissão</td>
                <td width="14%" class="tabela">Valor</td>
                <td width="12%" class="tabela">chave de acesso</td>
                <td width="12%" class="tabela">Cidade</td>
                <td width="12%" class="tabela">UF</td>
            </tr>
            <% 
                String notasSelecionadas = request.getParameter("notasSelecionadas");
                String[] arrayNotas = notasSelecionadas.split(",");
                for(ArquivoImportacaoXML arq : lista){ 
            %>
                <tr class="celulaZebra1" >
                    <td><input type="checkbox" name="chk_<%= arq.getId() %>" id="chk_<%= arq.getId() %>" value="<%= arq.getNumDoc() %>" <%= Arrays.asList(arrayNotas).contains(arq.getNumDoc()) ? "checked" : "" %> ></td>
                    <td><%= arq.getNumDoc() %></td>
                    <td class="CelulaZebra1NoAlign" align="center"><%= arq.getSerie() %></td>
                    <td class="CelulaZebra1NoAlign" align="center"><%= arq.getDtEmissao() %></td>
                    <td class="CelulaZebra1NoAlign" align="right"><%= Apoio.to_curr2(arq.getVlDoc()) %></td>
                    <td><%= arq.getChaveAcesso() %></td>
                    <td><%= arq.getDestinatario().getEnderecoEntregaUtilizado().getCidade().getDescricaoCidade() %></td>
                    <td><%= arq.getDestinatario().getEnderecoEntregaUtilizado().getCidade().getUf() %></td>
                </tr>
            <% } %>
            <tr class="celulaZebra1" >
                <td colspan="11">
                    <div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona();">
                    </div>
                </td>
            </tr>
        </table>

    </body>
</html>
