<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="despesa.pagamentoComissao.PagamentoComissao,
         despesa.pagamentoComissao.ConsultaPagamentoComissao,
         nucleo.Apoio,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         java.util.Date" %>

<script language="javascript" src="script/funcoes.js"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
            int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadpgtocomissao") : 0);
            int nivelUserToFilial = (nivelUser > 0 ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
            String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");

            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }

            SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
//Iniciando Cookie
            String campoConsulta = "";
            String valorConsulta = "";
            String dataInicial = "";
            String dataFinal = "";
            String filial = "";
            //String idFornecedor = "";
            //String fornecedor = "";
            String operadorConsulta = "";
            String limiteResultados = "";
            Cookie consulta = null;
            Cookie operador = null;
            Cookie limite = null;

            Cookie cookies[] = request.getCookies();
            if (cookies != null) {
                for (int i = 0; i < cookies.length; i++) {
                    if (cookies[i].getName().equals("consultaPgtoComissao")) {
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
                    consulta = new Cookie("consultaPgtoComissao", "");
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
                String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
                String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
                //String forn = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[4]);
                String fl = (consulta.getValue().equals("") ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : consulta.getValue().split("!!")[4]);
                //String idForn = (consulta.getValue().equals("") ? "0" : consulta.getValue().split("!!")[6]);
                valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
                dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
                dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
                //fornecedor = (request.getParameter("fornecedor") != null ? request.getParameter("fornecedor") : (forn));
                //idFornecedor = (request.getParameter("idfornecedor") != null ? request.getParameter("idfornecedor") : (idForn));
                filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
                campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                        ? request.getParameter("campoDeConsulta")
                        : (campo.equals("") ? "pc.dt_lancamento" : campo));
                operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                        ? request.getParameter("operador")
                        : (operador.getValue().equals("") ? "1" : operador.getValue()));
                limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                        ? request.getParameter("limiteResultados")
                        : (limite.getValue().equals("") ? "10" : limite.getValue()));
                consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" + filial );
                operador.setValue(operadorConsulta);
                limite.setValue(limiteResultados);
                response.addCookie(consulta);
                response.addCookie(operador);
                response.addCookie(limite);
            } else {
                campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                        ? request.getParameter("campoDeConsulta") : "pc.dt_lancamento");
                dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                        : Apoio.incData(fmt.format(new Date()), -30));
                dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
                //fornecedor = (request.getParameter("fornecedor") != null ? request.getParameter("fornecedor") : "");
                filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
                //idFornecedor = (request.getParameter("idfornecedor") != null ? request.getParameter("idfornecedor") : "0");
                valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                        ? request.getParameter("valorDaConsulta") : "");
                operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                        ? request.getParameter("operador") : "1");
                operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                        ? request.getParameter("limiteResultados") : "10");
            }

if (acao.equals("exportar"))
{
        
        //Verificando qual campo filtrar
        String id = request.getParameter("id");
        String tipoComissao = request.getParameter("tipoComissao");
        
        //Exportando
        java.util.Map param = new java.util.HashMap(1);
        param.put("ID", id);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        param.put("TIPO_COMISSAO", tipoComissao);
        request.setAttribute("map", param);
        request.setAttribute("rel", "pagamentocomissaomod1");

        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
}
//Finalizando Cookie

            int idFilialDespesa = Integer.parseInt(filial);
            int idFilialUser = (!acao.equals("") ? Apoio.getUsuario(request).getFilial().getIdfilial() : 0);
%>
<jsp:useBean id="consDesp" class="despesa.pagamentoComissao.ConsultaPagamentoComissao" />
<jsp:setProperty  name="consDesp" property="campoDeConsulta"  />
<jsp:setProperty  name="consDesp" property="limiteResultados"  />
<jsp:setProperty  name="consDesp" property="operador"  />
<jsp:setProperty  name="consDesp" property="paginaResultados"  />
<jsp:setProperty  name="consDesp" property="valorDaConsulta"  />
<%
            consDesp.getPagamentoComissao().setDtConsultaDe(Apoio.paraDate(dataInicial));
            consDesp.getPagamentoComissao().setDtConsultaAte(Apoio.paraDate(dataFinal));
            consDesp.getPagamentoComissao().getFilial().setIdfilial((nivelUserToFilial < 1 ? idFilialUser : idFilialDespesa));
            //consDesp.setIdFornecedor(Integer.parseInt(idFornecedor));
%>

<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});

    function popComissao(id){
        var tipoComissao = $("tipoComissao").value;
        if (id == null)
            return null;
        launchPDF('./consulta_pagamento_comissao.jsp?acao=exportar&id='+id+"&tipoComissao="+tipoComissao,'Comissao'+id);

    }
  
    function consultar(acao){
        if (($("campoDeConsulta").value == "pc.dt_lancamento") && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
	    return null;
        }

        document.location.replace("./consulta_pagamento_comissao.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=consDesp.getPaginaResultados() + 1%> : (acao=='anterior'?<%=consDesp.getPaginaResultados() - 1%>:1) )+"&"+
            concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,filialId"));
    }

    function excluir(id, idDespesa){
        if (!confirm("Deseja mesmo excluir o Pagamento de Comissão?"))
            return null;
        //passando o id despesa por paramentro para funcção de excluir
        requisitaPost("acao=excluir&id="+id+"&idDespesa="+idDespesa, "./cadpagamento_comissao.jsp");
    }

    function aoCarregar(){
        
        getObj("campoDeConsulta").value = "<%=(campoConsulta)%>";
        getObj("operador").value = "<%=operadorConsulta%>";
        getObj("limiteResultados").value = "<%=limiteResultados%>";
        getObj("filialId").value = "<%=filial%>";
//        getObj("idfornecedor").value = "";
//        getObj("fornecedor").value = "";
        getObj("dtemissao1").value = "<%=dataInicial%>";
        getObj("dtemissao2").value = "<%=dataFinal%>";

    <%   if (campoConsulta.equals("") || campoConsulta.equals("pc.dt_lancamento")) {
    %>        habilitaConsultaDePeriodo(true);
    <%   }
    %>
    }

    function editarDespesa(id, podeExcluir){
    window.open("./caddespesa?acao=editar&id="+id+"&podeExcluir="+podeExcluir, "Despesa", "height=500,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1");
    
}

    function editar(id, podeExcluir){
        location.replace("./cadpagamento_comissao.jsp?acao=editar&id="+id+"&podeExcluir="+podeExcluir);
    }

    function habilitaConsultaDePeriodo(opcao) {
        $("valorDaConsulta").style.display = (opcao ? "none" : "");
        $("operador").style.display = (opcao ? "none" : "");
        $("div1").style.display = (opcao ? "" : "none");
        $("div2").style.display = (opcao ? "" : "none");
    }

/*
    function viewDups(idMov){
        function e(transport){
            var textoresposta = transport.responseText;
            //se deu algum erro na requisicao...
            if (textoresposta == "load=0") {
                return false;
            }else{
                Element.show("mov_"+idMov);
                $("mov_"+idMov).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
            }
        }//funcao e()

        if (Element.visible("mov_"+idMov)){
            Element.toggle("mov_"+idMov);
            $('plus_'+idMov).style.display = '';
            $('minus_'+idMov).style.display = 'none';
        }else{
            $('plus_'+idMov).style.display = 'none';
            $('minus_'+idMov).style.display = '';
            new Ajax.Request("./consulta_despesa.jsp?acao=obter_duplicatas&idmovimento="+idMov,{method:'post', onSuccess: e, onError: e});
        }

    }

    function limparclifor(){
        $("idfornecedor").value = "0";
        $("fornecedor").value = "";
    }
*/
</script>
<%@page import="filial.BeanFilial"%>
<%@page import="java.text.DecimalFormat"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Pagamentos de comissão</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="aoCarregar();applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
        <table width="98%" align="center" class="bordaFina" >
            <tr>
                <td width="590" align="left">
                    <b>Consulta de Pagamentos de comissão</b>
                </td>
                <% if (nivelUser >= 3) {%>
                <td width="98">
                    <input name="novo" type="button" class="botoes" id="novo"
                           onClick="javascript:tryRequestToServer(function(){document.location.replace('./cadpagamento_comissao.jsp?acao=iniciar');});"
                           value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="149"  height="20">
                    <div align="right">
                        <select name="campoDeConsulta" id="campoDeConsulta" class="inputtexto"
                                onChange="javascript:habilitaConsultaDePeriodo(this.value=='pc.dt_lancamento');">
                            <option value="pc.dt_lancamento" selected>Emiss&atilde;o</option>
                        </select>
                    </div>
                </td>
                <td width="187">
                    <select name="operador" id="operador" class="inputtexto">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none " align="left">De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10"
                               value="<%=fmt.format((consDesp.getCampoDeConsulta().equals("pc.dt_lancamento")? consDesp.getPagamentoComissao().getDtConsultaDe() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>	
                </td>
                <td colspan="2">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none " align="left">Para:
                        <input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10"
                               value="<%=fmt.format((consDesp.getCampoDeConsulta().equals("pc.dt_lancamento")? consDesp.getPagamentoComissao().getDtConsultaAte() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <div align="left">
                        <input name="valorDaConsulta" type="text" id="valorDaConsulta" value="<%=consDesp.getValorDaConsulta()%>" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
                    </div>
                </td>
                <td width="76" rowspan="2">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                </td>
                <td width="120" rowspan="2">
                    <div align="center">Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="inputtexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td  colspan="2">
                    <div align="right">Apenas a filial (Despesas): </div>
                </td>
                <td>
                    <div align="left">
                        <select name="filialId" id="filialId" style="font-size:8pt;" class="fieldMin">
                            <option value="0" selected="selected">TODAS</option>
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                                while (rsFl.next()) {
                                    if (nivelUserToFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                                        <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                                    <%}%>
                                <%}%>
                        </select>
                    </div>
                </td>
                <td width="257"></td>
            </tr>
        </table>
        <table width="98%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="2%">
                    <div align="center"></div>
                </td>
                <td width="10%">Emiss&atilde;o</td>
                <td width="10%">
                    <div align="center">Despesa</div>
                </td>
                <td width="66%">Vendedor/Representante</td>
                <td width="10%">
                    <div align="right">Valor</div>
                </td>
                <td width="2%">&nbsp;</td>
            </tr>
            <%
                        int linha = 0;
                        int linhatotal = 0;
                        int qtde_pag = 0;

                        if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                            consDesp.setConexao(Apoio.getConnectionFromUser(request));
                            if (consDesp.Consultar()) {
                                ResultSet r = consDesp.getResultado();
                                while (r.next()) {%>
                                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                        <td>
                                            <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                                                onClick="javascript:tryRequestToServer(function(){popComissao('<%=r.getString("id")%>');});">
                                            <input type="hidden" name="tipoComissao" id="tipoComissao" value="<%=r.getString("tipo_comissao")%>">
                                        </td>
                                        <td>
                                            <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id")%>,<%=r.getBoolean("podeexcluir")%>);});">
                                                <%=fmt.format(r.getDate("dt_lancamento"))%>
                                            </div>
                                        </td>
                                        <td>
                                            <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarDespesa(<%=r.getInt("despesa_id")%>,<%=r.getBoolean("podeexcluir")%>);});">
                                                <%=r.getInt("despesa_id")%>
                                            </div>
                                        </td>
                                        <td><%=r.getString("fornecedor")%></td>
                                        <td>
                                            <div align="right"><%=r.getString("valor")%></div>
                                        </td>
                                        <td>
                                            <%
                                            if (nivelUser == 4 && r.getBoolean("podeexcluir")
                                                && !(!r.getString("fi_abrev").equals(Apoio.getUsuario(request).getFilial().getAbreviatura()) && nivelUserToFilial < 4)) {
                                            %>  <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                                                    onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("id")%>,<%=r.getInt("despesa_id")%>);});">
                                            <%               }
                                            %>
                                        </td>
                                    </tr>
                                    <%  if (r.isLast()) {
                                                    linhatotal = r.getInt("qtde_linhas");
                                        }
                                    linha++;
                                }

                                int limit = consDesp.getLimiteResultados();
                                qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                            }
                        }
                        %>

        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="18%" height="22">
                    <center>
                        Ocorr&ecirc;ncias: 
                        <b><%=linha%> / <%=linhatotal%></b>
                    </center>
                </td>
                <td width="15%" align="center">P&aacute;ginas:
                    <b><%=(qtde_pag == 0 ? 0 : consDesp.getPaginaResultados())%> / <%=qtde_pag%></b>
                </td>
                <%if (consDesp.getPaginaResultados() < qtde_pag) {%>
                <td width="7%" align="right">
                    <input name="avancar" type="button" class="botoes" id="avancar"
                           value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
                    <br>
                    <input name="avancar" type="button" class="botoes" id="avancar"
                           value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
                </td>
                <%}%>
                <td colspan="5" align="right">
                    <!--
    	Modelo de impress&atilde;o em PDF:
                       <select name="cbmodelo" id="cbmodelo" class="inputtexto">
                            <option value="1" selected>Autorização de pagamento (Modelo 1)</option>
                            <option value="2">Recibo de pagamento a autonomo - RPA</option>
                        </select>
                    -->
                </td>
            </tr>
        </table>
    </body>
</html>
