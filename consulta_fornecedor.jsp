<%@page import="fornecedor.BeanCadFornecedor"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="fornecedor.BeanFornecedor,
         fornecedor.BeanConsultaFornecedor,
         nucleo.Apoio,
         java.sql.ResultSet" %>




<%

    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadfornecedor") : 0);
    String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso

    //if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("idfornecedor") != null)) {
    if ((nivelUser == 4) && (acao.equals("excluir")) && request.getParameter("idfornecedor") != null) {
        BeanCadFornecedor cadforn = new BeanCadFornecedor();
        cadforn.setConexao(Apoio.getUsuario(request).getConexao());
        cadforn.setExecutor(Apoio.getUsuario(request));
        cadforn.getFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor")));
%><script language="javascript"><%
    if (!cadforn.Deleta()) {
    %>alert("Erro ao tentar excluir!");
    <%}%>
        location.replace("./consulta_fornecedor.jsp?acao=iniciar");
</script><%}

    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }

    String campoConsulta = "";
    String valorConsulta = "";
    String operadorConsulta = "";
    String limiteResultados = "";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaFornecedor")) {
                consulta = cookies[i];
            } else if (cookies[i].getName().equals("operadorConsulta")) {
                operador = cookies[i];
            } else if (cookies[i].getName().equals("limiteConsulta")) {
                limite = cookies[i];
            }
            if (consulta != null && operador != null && limite != null) { //se já encontrou os cookies então saia
                break;
            }
        }
        if (consulta == null) {//se não achou o cookieu então inclua
            consulta = new Cookie("consultaFornecedor", "");
        }
        if (operador == null) {//se não achou o cookieu então inclua
            operador = new Cookie("operadorConsulta", "");
        }
        if (limite == null) {//se não achou o cookieu então inclua
            limite = new Cookie("limiteConsulta", "");
        }
        consulta.setMaxAge(60 * 60 * 24 * 90);
        operador.setMaxAge(60 * 60 * 24 * 90);
        limite.setMaxAge(60 * 60 * 24 * 90);

        String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
        String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "razaosocial" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        consulta.setValue(valorConsulta + "!!" + campoConsulta);
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
    } else {
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta") : "razaosocial");
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador") : "1");
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados") : "10");
    }

    if((nivelUser >= 4) && (acao.equals("excluir") && request.getParameter("idfornecedor") != null)){
        BeanCadFornecedor cadFornecedor = new BeanCadFornecedor();
        cadFornecedor.setConexao(Apoio.getUsuario(request).getConexao());
        cadFornecedor.setExecutor(Apoio.getUsuario(request));
        cadFornecedor.getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor")));
        %><script language="javascript"><%
            if (!cadFornecedor.Deleta()){                
                %>alert("Erro ao tentar excluir!");<%
            }else{
                %>alert("Excluido com sucesso!");<%
            }
	    %>location.replace("./consultafornecedor?acao=iniciar");
            </script><%
    }

%>

<jsp:useBean id="consFornec" class="fornecedor.BeanConsultaFornecedor" />
<jsp:setProperty name="consFornec" property="*" />
<%    consFornec.setCampoDeConsulta(campoConsulta);
    consFornec.setValorDaConsulta(valorConsulta);
    consFornec.setOperador(Integer.parseInt(operadorConsulta));
    consFornec.setLimiteResultados(Integer.parseInt(limiteResultados));
%>
<script type="text/javascript"  language="javascript">
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
    function consultar(acao) {
        document.location.replace("./consultafornecedor?acao=" + acao + "&paginaResultados=" + (acao == 'proxima' ? <%=consFornec.getPaginaResultados() + 1%> : (acao == 'anterior' ? <%=consFornec.getPaginaResultados() - 1%> : 1)) + "&" +
                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados"));
    }


    
    function excluir(id){
        if(confirm("Deseja Excluir este Fornecedor ? ")){            
            location.replace("./consultafornecedor?acao=excluir&idfornecedor="+id);
        }

    }

    function aoCarregar() {
        $("valorDaConsulta").focus();
        getObj("campoDeConsulta").value = "<%=(consFornec.getCampoDeConsulta().equals("") ? "razaosocial" : consFornec.getCampoDeConsulta())%>";
        getObj("operador").value = "<%=consFornec.getOperador()%>";
        getObj("limiteResultados").value = "<%=consFornec.getLimiteResultados()%>";
        getObj("valorDaConsulta").value = "<%=consFornec.getValorDaConsulta()%>";
        if (paginaAtual <= 1) {
            desabilitar($("voltar"));
        }
        if (paginaAtual == qtde_pag) {
            desabilitar($("avancar"));
        }
        if (linhatotal <= 10 && qtde_pag <= 0) {
            desabilitar($("voltar"));
            desabilitar($("avancar"));
        }
    }

    function editar(id) {
        location.href = "./cadfornecedor?acao=editar&id=" + id;

    }

</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Fornecedor</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="aoCarregar()">
        <img src="img/banner.gif">
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr >
                <td width="590" align="left"><b>Consulta de Fornecedor</b></td>
                <% if (nivelUser >= 3) {%>
                <td width="98"><input name="novo" type="button" class="botoes" id="novo"
                                      onClick="javascript:tryRequestToServer(function() {
                                                  location.href = './cadfornecedor?acao=iniciar';
                                              });"
                                      value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="92"  height="20">
                    <select name="campoDeConsulta" id="campoDeConsulta" class="inputtexto">
                        <option value="razaosocial" selected>Raz&atilde;o Social</option>
                        <option value="cpf_cnpj">CPF/CNPJ</option>
                        <option value="fone1">Fone1</option>
                        <option value="email">Email</option>
                    </select>
                </td>
                <td width="143"><select name="operador" id="operador" style="width:100% " class="inputtexto">
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select></td>
                <td colspan="2"><input name="valorDaConsulta" type="text" id="valorDaConsulta" size="30" onKeyUp="javascript:if (event.keyCode == 13)
                            $('pesquisar').click();" class="inputtexto"></td>
                <td width="76"><input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                                      onClick="javascript:tryRequestToServer(function() {
                                                  consultar('consultar');
                                              });"></td>
                <td width="191"><div align="right"> Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="inputtexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div></td>
            </tr>
        </table>
        <table width="90%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="8%">Código </td>
                <td width="37%">Raz&atilde;o Social </td>
                <td width="13%">CPF/CNPJ</td>
                <td width="15%">Telefone</td>
                <td width="26%">Email</td>
                <td width="1%">&nbsp;</td>
            </tr>

            <%int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;

                if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                    consFornec.setConexao(Apoio.getConnectionFromUser(request));
                    //consultando
                    if (consFornec.Consultar()) {
                        ResultSet r = consFornec.getResultado();
                        while (r.next()) {%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function() {
                            editar(<%=r.getInt("idfornecedor")%>);
                        });">
                        <%=r.getString("idfornecedor")%></div>
                </td>
                <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function() {
                            editar(<%=r.getInt("idfornecedor")%>);
                        });">
                        <%=r.getString("razaosocial")%></div>
                </td>
                <td><%=r.getString("cpf_cnpj")%></td>
                <td><%=r.getString("fone1")%></td>
                <td><%=r.getString("email")%></td>
                <td>
                    <%if ((nivelUser == 4) && (r.getBoolean("podeexcluir"))) {%>
                    <img src="img/lixo.png" title="Excluir este registro" onClick="javascript:tryRequestToServer(function() {
                                excluir(<%=r.getString("idfornecedor")%>);
                            });"
                         class="imagemLink" align="right">
                    <%}%>
                </td>
            </tr>
            <%if (r.isLast()) {
                                linhatotal = r.getInt("qtde_linhas");
                            }
                            linha++;
                        }

                        int limit = consFornec.getLimiteResultados();
                        qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                    }
                }%>

            <script type="text/javascript" language="javascript" >paginaAtual = <%=consFornec == null ? 1 : consFornec.getPaginaResultados()%>;
                qtde_pag = <%=qtde_pag%>;
                linhatotal = <%=linhatotal%>;</script>
        </table>
        <br>
        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="45%" height="22"><center>
                Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
            </center></td>
        <td width="40%" align="center">P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : consFornec.getPaginaResultados())%> / <%=qtde_pag%></b></td>
        <td width="15%" align="center">
            <input name="voltar" type="button" class="botoes" id="voltar"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function() {
                                       consultar('anterior');
                                   });">
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function() {
                                       consultar('proxima');
                                   });">
        </td>
    </tr>
</table>
</body>
</html>
