<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
          java.lang.String,         
         conhecimento.ocorrencia.*,
         nucleo.Apoio" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
            // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadocorrencia") : 0);
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
            
            BeanUsuario autenticado = Apoio.getUsuario(request);

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
                    if (cookies[i].getName().equals("consultaOcorrencia")) {
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
                    consulta = new Cookie("consultaOcorrencia", "");
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
                valorConsulta = (request.getParameter("valor_consulta") != null ? request.getParameter("valor_consulta") : (valor));
                campoConsulta = (request.getParameter("campo_consulta") != null && !request.getParameter("campo_consulta").trim().equals("")
                        ? request.getParameter("campo_consulta")
                        : (campo.equals("") ? "codigo" : campo));
                operadorConsulta = (request.getParameter("operador_consulta") != null && !request.getParameter("operador_consulta").trim().equals("")
                        ? request.getParameter("operador_consulta")
                        : (operador.getValue().equals("") ? "1" : operador.getValue()));
                limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                        ? request.getParameter("limite")
                        : (limite.getValue().equals("") ? "10" : limite.getValue()));
                consulta.setValue(valorConsulta + "!!" + campoConsulta);
                operador.setValue(operadorConsulta);
                limite.setValue(limiteResultados);
                response.addCookie(consulta);
                response.addCookie(operador);
                response.addCookie(limite);
            } else {
                campoConsulta = (request.getParameter("campo_consulta") != null && !request.getParameter("campo_consulta").trim().equals("") ? request.getParameter("campo") : "codigo");
                valorConsulta = (request.getParameter("valor_consulta") != null && !request.getParameter("valor_consulta").trim().equals("") ? request.getParameter("valor") : "");
                operadorConsulta = (request.getParameter("operador_consulta") != null && !request.getParameter("operador_consulta").trim().equals("") ? request.getParameter("ope") : "1");
                limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? request.getParameter("limite") : "10");
            }
%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
            BeanConsultaOcorrencia con = new BeanConsultaOcorrencia();;
            String acao = request.getParameter("acao");
            acao = ((acao == null) || (nivelUser == 0) ? "" : acao);

            if (acao.equals("iniciar")) {
                acao = "consultar";
                //pag = "1";
            }

            if ((acao.equals("consultar")) || (acao.equals("proxima"))|| (acao.equals("anterior"))) {   //instanciando o bean
                //con = new BeanConsultaOcorrencia();
                con.setConexao(Apoio.getUsuario(request).getConexao());
                con.setCampoDeConsulta(campoConsulta);
                con.setOperador(Integer.parseInt(operadorConsulta));
                con.setValorDaConsulta(valorConsulta);
                con.setLimiteResultados(Integer.parseInt(limiteResultados));
                con.setPaginaResultados(request.getParameter("paginaResultados") == null ? 1 : Integer.parseInt(request.getParameter("paginaResultados")));
            }

            if (acao.equals("excluir") && request.getParameter("id") != null) {
                BeanCadOcorrencia cad = new BeanCadOcorrencia();
                cad.setConexao(Apoio.getUsuario(request).getConexao());
                cad.setExecutor(Apoio.getUsuario(request));
                cad.getOcorrenciaCtrc().setId(Integer.parseInt(request.getParameter("id")));
%><script language="javascript"><%
                if (!cad.Deleta()) {
    %>alert("Erro ao tentar excluir!");<%        }%>
        location.replace("./consulta_ocorrencia.jsp?acao=iniciar");
</script>
<%}%>


<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
    function seleciona_campos(){
    <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
            if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null)) {%>
                $("valor_consulta").focus();
                    document.getElementById("valor_consulta").value = "<%=valorConsulta%>";
                    document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
                    document.getElementById("operador_consulta").value = "<%=operadorConsulta%>";
                    document.getElementById("limite").value = "<%=limiteResultados%>";
                    if(paginaAtual <= 1){
                        desabilitar($("voltar"));
                    }
                    if(paginaAtual == qtde_pag){
                        desabilitar($("avancar"));
                    }
                    if(linhatotal <= 10 && qtde_pag <=0){
                        desabilitar($("voltar"));
                        desabilitar($("avancar"));
                    }
    <%}%>
        }

        function consultar(acao){
            
            var url = "./consulta_ocorrencia.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=con.getPaginaResultados() + 1%> : (acao=='anterior'? <%=con.getPaginaResultados() - 1%>:1))+"&"+
                concatFieldValue("valor_consulta,campo_consulta,operador_consulta,limite");
            document.location.replace(url);
        }

        function editar(id){
            location.replace("./cadocorrencia.jsp?acao=editar&id="+id);
        }

        function excluir(id){
            if (confirm("Deseja mesmo excluir esta ocorrência?")){
                location.replace("./consulta_ocorrencia.jsp?acao=excluir&id="+id);
            }
        }

        function novoCadastro(){
            location.replace("./cadocorrencia.jsp?acao=iniciar");
        }
        
        function checkTodos(){
          
            var valor = $("check").checked;
            var i=0;
            while(getObj("ck_"+i)!=null){
                $("ck_"+i).checked = valor;                
                i++;
            }
             
        }
         var ocoCode = "";
        function getCheckeds(){
            var ocorrencias= "";
            var i=0;
             isSinc = "";
            isNotSinc = "";
            while(getObj("ck_"+i)!=null){
                if($("ck_"+i).checked){
                    if ($("realizada_"+i).value == "true"){
                        if ($("naoRealizada_"+i).value == "true") {
                            alert("Atenção a ocorrencia '" + $("codigo_descricao_"+i).value + "' foi configurada como de entrega e não entrega para o gwMobile só dever haver uma opção marcada.");
                            return "false";
                        }
                    }
                        ocoCode+= "','"+ $("ck_"+i).value;
                }
                i++;
            }
            return ocorrencias.substr(1);
        }

        function getIsSincronizado(){
             isSinc = "";
            isNotSinc = "";
            var i=0;
            while(getObj("isSincronizado_"+i)!=null){
                if($("isSincronizado_"+i).value== true){
                    isSinc+= ","+ $("ck_"+i).value;
                }else{
                    isNotSinc+= ","+ $("ck_"+i).value;
                }
                i++;
            }

        }


        function sincronizarGWMobile(){
            // se estiver marcada como entregae não entrega deverá levantar excessao.
            if (getCheckeds() != "false") {
                window.open("./MobileControlador?acao=sincronizarGWMobileOcorrencia&ocoCode="+ocoCode.substr(3) , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
            }
        }
        
        
        
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Consulta de ocorrências EDI</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                      font-size: 13px;
            }
            -->
        </style>
    </head>

    <body onLoad="javascript:seleciona_campos();">
        <img src="img/banner.gif"  alt="">
        <br>
        <table width="70%" align="center" class="bordaFina" >
            <tr >
                <td width="461"><div align="left"><b>Consulta de ocorrências EDI</b></div></td>
                <% if (nivelUser >= 3) {%>
                <td width="102">
                    <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function(){novoCadastro();});" value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="70%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="83" height="20">
                    <select name="campo_consulta" id="campo_consulta" class="inputtexto">
                        <option value="codigo" selected>Código</option>
                        <option value="descricao">Descrição</option>
                    </select>
                </td>
                <td width="141">
                    <select name="operador_consulta" id="operador_consulta" class="inputtexto">
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select>
                </td>
                <td colspan="2"><input name="valor_consulta" type="text" id="valor_consulta" size="20" class="inputtexto" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar2').click();"></td>

                <td width="76"> <input name="pesquisar" type="button" class="botoes" id="pesquisar2" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
                                       onClick="javascript:tryRequestToServer(function(){consultar('consultar');});"></td>
                <td width="191"><div align="right">
                        Por p&aacute;g.:
                        <select name="limite" id="limite" class="inputtexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div></td>
            </tr>
        </table>
        <table width="70%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="3%" align="center"> 
                    <%if(!autenticado.getFilial().getTipoUtilizacaoGWMobile().equals("N")){  %>
                        <input type="checkbox" id="check" name="check" onclick="checkTodos();">
                         <%}%>
                </td>
                <td width="10%" align="center">Código</td>
                <td width="85%">Descrição</td>
                <td width="5%" ></td>
            </tr>
            <% //variaveis da paginacao
            int linha = 0;
            int linhatotal = 0;
            int qtde_pag = 0;

            //String ultima_linha = "";
            // se conseguiu consultar
            con.setFilialCnpjIntegracao(autenticado.getFilial().getCnpjContratanteGwMobile());
            if ((acao.equals("consultar") || acao.equals("proxima")|| acao.equals("anterior")) && (con.Consultar())) {
                ResultSet rs = con.getResultado();
                while (rs.next()) {
                    //pega o resto da divisao e testa se é par ou impar
            %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td align="center">
                      <%if(!autenticado.getFilial().getTipoUtilizacaoGWMobile().equals("N")){  %>
                    <input type="checkbox" id="ck_<%=linha%>" name="ck_<%=linha%>" value="<%=rs.getString("codigo")%>">
                        <%}%>
                    <input type="hidden" id="isSincronizado_<%=linha%>" name="isSincronizado_<%=linha%>" value="<%=rs.getBoolean("is_enviado_mobile")%>">
                </td>
                <td>
                    <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=rs.getString("id")%>);});">
                        <%=rs.getString("codigo")%>
                        
                    </div>
                </td>
                <td>
                    <%=rs.getString("descricao")%>
                    <input type="hidden" name="realizada_<%=linha%>" id="realizada_<%=linha%>" value="<%= rs.getBoolean("is_entrega_realizada") %>">
                    <input type="hidden" name="naoRealizada_<%=linha%>" id="naoRealizada_<%=linha%>" value="<%= rs.getBoolean("is_entrega_nao_realizada") %>">
                    <input type="hidden" name="codigo_descricao_<%=linha%>" id="codigo_descricao_<%=linha%>" value="<%= rs.getString("codigo") + " - " + rs.getString("descricao") %>">
                </td>
                <% if (nivelUser == 4) {
                %><td align="center">
                    <div align="center">
                        <img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                             onclick="javascript:tryRequestToServer(function(){excluir(<%=rs.getString("id")%>);});"
                             border="0" align="right">
                    </div>
                </td>
                <%} else {%><td ></td>
                <%}%>
            </tr>
            <% //se for a ultima linha................
                    if (rs.isLast()) {
                        //ultima_linha = rs.getString("codigo");
                        //Quantidade geral de resultados da consulta
                        linhatotal = rs.getInt("qtde_linhas");
                    }
                    linha++;
                }//while
                //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
                int limit = con.getLimiteResultados();
                qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
            }//if
            %>
<script type="text/javascript" language="javascript" >paginaAtual= <%=con == null ? 1 :con.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
        </table>
        <br>
        <table width="70%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td colspan="2" height="22"></td>
                <td width="40%" height="22">
                    <%if(!autenticado.getFilial().getTipoUtilizacaoGWMobile().equals("N")){  %>
                        <center>
                            <input name="sincronizar" type="button" class="botoes" id="sincronizar" value="Sincronizar GWMobile <%=(autenticado.getFilial().getTipoUtilizacaoGWMobile().equals("P") ? "(Produção)" : "(Homologação)")%> "  onClick="javascript:tryRequestToServer(function(){sincronizarGWMobile()('proxima');});">
                        </center>
                    <%}%>
                </td>
                </tr>
            <tr class="celula">
                <td width="40%" height="22">
                    <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
                    </center>
                </td>
                <td width="40%" align="center">Páginas: <b><%=(qtde_pag == 0 ? 0 : con.getPaginaResultados())%> / <%=qtde_pag%></b></td>
                <td width="20%"><div align="center">
                        <input name="voltar" type="button" class="botoes" id="voltar"
                               value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
                        <input name="avancar" type="button" class="botoes" id="avancar"
                               value="Próxima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
                    </div></td>
            </tr>
        </table>
    </body>
</html>