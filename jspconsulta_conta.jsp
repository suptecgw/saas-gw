<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         mov_banco.conta.*,
         usuario.BeanUsuario,
         nucleo.Apoio" %>

<% //ATENCAO! Esta vari�vel vai ser usada em todo o JSP para o teste de
            // privil�gio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);
            //testando se a sessao � v�lida e se o usu�rio tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA

            String campoConsulta = "";
            String valorConsulta = "";
            String operadorConsulta = "";
            String limiteResultados = "";
            Cookie consulta = null;
            Cookie operador = null;
            Cookie limite = null;
            int linha = 0;
            int linhatotal = 0;
            int qtde_pag = 0;


            Cookie cookies[] = request.getCookies();
            if (cookies != null) {
                for (int i = 0; i < cookies.length; i++) {
                    if (cookies[i].getName().equals("consultaContas")) {
                        consulta = cookies[i];
                    } else if (cookies[i].getName().equals("operadorConsulta")) {
                        operador = cookies[i];
                    } else if (cookies[i].getName().equals("limiteConsulta")) {
                        limite = cookies[i];
                    }
                    if (consulta != null && operador != null && limite != null) { //se j� encontrou os cookies ent�o saia
                        break;
                    }
                }
                if (consulta == null) {//se n�o achou o cookieu ent�o inclua
                    consulta = new Cookie("consultaContas", "");
                }
                if (operador == null) {//se n�o achou o cookieu ent�o inclua
                    operador = new Cookie("operadorConsulta", "");
                }
                if (limite == null) {//se n�o achou o cookieu ent�o inclua
                    limite = new Cookie("limiteConsulta", "");
                }
                consulta.setMaxAge(60 * 60 * 24 * 90);
                operador.setMaxAge(60 * 60 * 24 * 90);
                limite.setMaxAge(60 * 60 * 24 * 90);

                String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
                String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
                valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
                campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                        ? request.getParameter("campo")
                        : (campo.equals("") ? "c.descricao" : campo));
                operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                        ? request.getParameter("ope")
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
                campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                        ? request.getParameter("campo") : "c.descricao");
                valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("")
                        ? request.getParameter("valor") : "");
                operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                        ? request.getParameter("ope") : "1");
                limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                        ? request.getParameter("limite") : "10");
            }

%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
            BeanConsultaConta beanconta = null;
            String acao = request.getParameter("acao");
            acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
            //variavel responsavel pela paginacao. Pega o ultimo titulo
            String ultimotitulo = request.getParameter("ultimo");
            String pag = (request.getParameter("pag") != null ? request.getParameter("pag") : "0");

            if (acao.equals("iniciar")) {
                acao = "consultar";
                pag = "1";
            }

            if ((acao.equals("consultar")) || (acao.equals("proxima"))|| (acao.equals("anterior"))) {   //instanciando o bean
                beanconta = new BeanConsultaConta();
                beanconta.setConexao(Apoio.getUsuario(request).getConexao());
                beanconta.setCampoDeConsulta(campoConsulta);
                beanconta.setOperador(Integer.parseInt(operadorConsulta));
                beanconta.setValorDaConsulta(valorConsulta);
                beanconta.setLimiteResultados(Integer.parseInt(limiteResultados));
                beanconta.setPaginaResultados(Integer.parseInt(pag));

            }

            if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null)) {
                BeanConta conta = new BeanConta();
                BeanCadConta cadconta = new BeanCadConta();
                cadconta.setConexao(Apoio.getUsuario(request).getConexao());
                cadconta.setExecutor(Apoio.getUsuario(request));
                conta.setIdConta(Integer.parseInt(request.getParameter("id")));
                cadconta.setConta(conta);
%><script language="javascript"><%
                                if (!cadconta.Deleta()) {
    %>alert("Erro ao tentar excluir!");<%                           }%>
                       location.replace("./consultaconta?acao=iniciar");
</script>
<%}

%>

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

        function consulta(campo, operador, valor, limite){
            location.replace("./consultaconta?campo="+campo+"&ope="+operador+"&valor="+valor+
                "&limite="+limite+"&pag=1&acao=consultar");
        }

        function editarconta(idconta, podeexcluir){
            location.replace("./cadconta?acao=editar&id="+idconta+(podeexcluir != null ? "&ex="+podeexcluir : ""));
        }

        function cadconta(){
            location.replace("./cadconta?acao=iniciar");
        }

        function anterior(ultimo_titulo){
    <%                                               //Somando a pag atual + 1 para a proxima pagina %>
             location.replace("./consultaconta?pag="+<%=(Integer.parseInt(pag) - 1)%>+
             "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                 "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=anterior");
         }

        function proxima(ultimo_titulo){
    <%                                               //Somando a pag atual + 1 para a proxima pagina %>
             location.replace("./consultaconta?pag="+<%=(Integer.parseInt(pag) + 1)%>+
             "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                 "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=proxima");
         }

         function excluirconta(idconta){
             if (confirm("Deseja mesmo excluir esta conta banc�ria/caixa?"))
             {
                 location.replace("./consultaconta?acao=excluir&id="+idconta);
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

        <title>WebTrans - Consulta de contas banc�rias/caixa</title>
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
        <img src="img/banner.gif"  alt=""><br>
        <table width="70%" align="center" class="bordaFina" >
            <tr >
                <td width="461"><div align="left"><b>Consulta de contas banc&aacute;rias/caixa</b></div></td>
                <% if (nivelUser >= 3) {%>
                <td width="102">
                    <input name="novaconta" type="button" class="botoes" id="novaconta" onClick="javascript:tryRequestToServer(function(){cadconta();});" value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="70%" align="center" cellspacing="1" class="bordaFina">

            <tr class="celula">
                <td width="93"  height="20"><select name="campo_consulta" id="campo_consulta" class="inputtexto">
                        <option value="c.descricao" selected>Descri��o</option>
                        <option value="c.numero">N�mero</option>
                        <option value="agencia">Agencia</option>
                        <option value="b.descricao">Banco</option>
                    </select>
                </td>
                <td width="158"><select name="operador_consulta" id="operador_consulta" class="inputtexto">
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select></td>
                <td colspan="2"><input name="valor_consulta" type="text" id="valor_consulta" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
                <td width="82">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
                <td width="201"><div align="right">
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
            <tr>
                <td width="25%" class="tabela">Descri��o</td>
                <td width="15%" class="tabela">N�mero</td>
                <td width="15%" class="tabela">Ag�ncia</td>
                <td width="27%" class="tabela">Banco</td>
                <td width="15%" class="tabela">Filial</td>
                <td width="3%" class="tabela"></td>
            </tr>
            <% //variaveis da paginacao

                        String ultima_linha = "";
                        // se conseguiu consultar
                        if ((acao.equals("consultar") || acao.equals("proxima")|| acao.equals("anterior")) && (beanconta.Consultar())) {
                            ResultSet rs = beanconta.getResultado();
                            while (rs.next()) {
                                //pega o resto da divisao e testa se � par ou impar
%> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarconta(<%=rs.getString("idconta") + "," + rs.getBoolean("podeexcluir")%>);});">
                        <%=rs.getString("descconta")%>
                    </div>
                </td>
                <td><%=rs.getString("numero") + "-" + rs.getString("digito_conta")%></td>
                <td><%=rs.getString("agencia") + "-" + rs.getString("digito_agencia")%></td>
                <td><%=rs.getString("descbanco")%></td>
                <td><%=rs.getString("abreviatura")%></td>

                <% if ((nivelUser == 4) && (rs.getBoolean("podeexcluir"))) {
                %><td width="21"><img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                    onclick="javascript:tryRequestToServer(function(){excluirconta(<%=rs.getString("idconta")%>);});"
                                    width="21" height="22" border="0" align="right"></td>
                <%} else {%><td width="6"></td>
                <%}%>
            </tr>
            <% //se for a ultima linha................
                                if (rs.isLast()) {
                                    ultima_linha = rs.getString("descconta");
                                    //Quantidade geral de resultados da consulta
                                    linhatotal = rs.getInt("qtde_linhas");
                                }
                                linha++;
                            }//while
                            //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
                            qtde_pag = ((linhatotal % Integer.parseInt(limiteResultados)) == 0
                                    ? (linhatotal / Integer.parseInt(limiteResultados))
                                    : (linhatotal / Integer.parseInt(limiteResultados)) + 1);
                        }//if
                        pag = (qtde_pag == 0 ? "0" : pag);
            %>
            <script type="text/javascript" language="javascript" >paginaAtual= <%=beanconta == null ? 1 :beanconta.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
        </table>
        <br>
        <table width="70%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="40%" height="22">
                    <center>
	     Ocorr�ncias: <b><%=linha%> / <%=linhatotal%></b>
                    </center>
                </td>
                <td width="40%" align="center">P�ginas: <b><%=pag%> / <%=qtde_pag%></b></td>

                <td width="20%"><div align="center">
                        <input name="voltar" type="button" class="botoes" id="voltar"
                               value="Anterior"  onClick="javascript:anterior();">
                        <input name="avancar" type="button" class="botoes" id="avancar"
                               value="Pr�xima"  onClick="javascript:proxima();">
                    </div></td>

            </tr>
        </table>
        <br>
        <br>
        <br>
        <br>
    </body>
</html>
