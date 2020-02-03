<%@page import="mov_banco.conta.BeanConta"%>
<%@page import="fornecedor.BeanFornecedor"%>
<%@page import="conhecimento.duplicata.factoring.BeanConsultaFactoring"%>
<%@page import="java.util.Collection"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="nucleo.Apoio,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         java.util.Date" %>
<script language="javascript" src="script/funcoes.js"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
int nivelUser = Apoio.getUsuario(request).getAcesso("lancamentofactoring");
int nivelFatura = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanfatura") : 0);
String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
    response.sendError(HttpServletResponse.SC_FORBIDDEN);

SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");   
//Iniciando Cookie
String campoConsulta = "";
String valorConsulta = "";
String dataInicial = "";
String dataFinal = "";
String operadorConsulta = "";
String limiteResultados = "";
String agenteFactoring = "";
String contaBancaria = "";
//Cookies
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;
Cookie cookieFactoring = null;
Cookie cookieConta = null;

//09/07/2015
BeanConsultaFactoring factoring = new BeanConsultaFactoring();
factoring.setConexao(Apoio.getUsuario(request).getConexao());
Collection<BeanFornecedor> filtrarAgenteFactoring = factoring.listarAgenteFactoring();
request.setAttribute("filtrarAgenteFactoring", filtrarAgenteFactoring);
//10/07/2015
BeanConsultaFactoring conta = new BeanConsultaFactoring();
conta.setConexao(Apoio.getUsuario(request).getConexao());
Collection<BeanConta> filtrarContaBancaria = conta.listarContaBancaria();
request.setAttribute("filtrarContaBancaria", filtrarContaBancaria);
//13/07/2015 Total dos valores, juros e liquidos
double valorFactoring = Apoio.parseDouble(request.getParameter("idValorAgenteFactoring"));
double jurosFactoring = Apoio.parseDouble(request.getParameter("idJurosAgenteFactoring")); 
double liquidosFactoring = Apoio.parseDouble(request.getParameter("idLiquidoAgenteFactoring"));

//Total
double totalValorFactoring = 0.0;
totalValorFactoring += valorFactoring;
double totalJurosFactoring = 0.0;
totalJurosFactoring += jurosFactoring;
double totalLiquidosFactoring = 0.0;
totalLiquidosFactoring += liquidosFactoring;

Cookie cookies[] = request.getCookies();
if (cookies != null){
        for (int i = 0; i < cookies.length; i++) {
                if (cookies[i].getName().equals("consultaFactoring")) {
                    consulta = cookies[i];
                } else if (cookies[i].getName().equals("operadorConsulta")) {
                    operador = cookies[i];
                } else if (cookies[i].getName().equals("limiteConsulta")) {
                    limite = cookies[i];
                } else if (cookies[i].getName().equals("agenteFactoring")) {
                    cookieFactoring = cookies[i];
                } else if (cookies[i].getName().equals("contaBancaria")) {
                    cookieConta = cookies[i];
                }
                if (consulta != null && operador != null && limite != null && cookieFactoring != null && cookieConta != null) { //se já encontrou os cookies então saia
                    break;
                }
            }
        if (consulta == null){//se não achou o cookieu então inclua
                consulta = new Cookie("consultaFactoring","");
        }
        if (operador == null){//se não achou o cookieu então inclua
                operador = new Cookie("operadorConsulta","");
        }
        if (limite == null){//se não achou o cookieu então inclua
                limite = new Cookie("limiteConsulta","");
        }
        if (cookieFactoring == null){//se não achou o cookieFactorin, então incluá-lo
            cookieFactoring = new Cookie("agenteFactoring", "");
        }
        if(cookieConta == null){//se não achou o cookieConta, então incluá-lo
            cookieConta = new Cookie("contaBancaria", "");
        }
        consulta.setMaxAge(60 * 60 * 24 * 90);
        operador.setMaxAge(60 * 60 * 24 * 90);
        limite.setMaxAge(60 * 60 * 24 * 90);
        cookieFactoring.setMaxAge(60 * 60 * 24 * 90);
        cookieConta.setMaxAge(60 * 60 * 24 * 90);
   
        String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
        String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
        
        String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
        String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);

        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "descontada_em" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        
        agenteFactoring = (request.getParameter("idAgenteFactoring") != null && !request.getParameter("idAgenteFactoring").trim().equals("")
                ? request.getParameter("idAgenteFactoring") : cookieFactoring.getValue().equals("") ? "0" : cookieFactoring.getValue());
        contaBancaria = (request.getParameter("idContaBancaria") != null && !request.getParameter("idContaBancaria").trim().equals("")
                ? request.getParameter("idContaBancaria") : cookieConta.getValue().equals("") ? "0" : cookieConta.getValue());

        consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal);
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        cookieFactoring.setValue(agenteFactoring);
        cookieConta.setValue(contaBancaria);

        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
        response.addCookie(cookieFactoring);
        response.addCookie(cookieConta);
    
}else{
    
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("") ?
            request.getParameter("campoDeConsulta") : "descontada_em");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                                                               : Apoio.incData(fmt.format(new Date()),-30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ?
            request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ?
            request.getParameter("operador") : "1");
        operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ?
            request.getParameter("limiteResultados") : "10");
        agenteFactoring = (request.getParameter("idAgenteFactoring") != null && !request.getParameter("idAgenteFactoring").trim().equals("") ?
            request.getParameter("idAgenteFactoring") : "0");
        contaBancaria = (request.getParameter("idContaBancaria") != null && !request.getParameter("idContaBancaria").trim().equals("") ?
            request.getParameter("idContaBancaria") : "0");

    
}
//Finalizando Cookie

BeanConsultaFactoring conFac = new BeanConsultaFactoring();

conFac.setCampoDeConsulta(campoConsulta);
conFac.setLimiteResultados(Integer.parseInt(limiteResultados));
conFac.setOperador(Integer.parseInt(operadorConsulta));
conFac.setValorDaConsulta(valorConsulta);
conFac.setData1(dataInicial);
conFac.setData2(dataFinal);
conFac.setPaginaResultados(request.getParameter("paginaResultados") == null ? 1 : Integer.parseInt(request.getParameter("paginaResultados")));
conFac.setAgenteFactoring(Apoio.parseInt(agenteFactoring));
conFac.setContaBancaria(Apoio.parseInt(contaBancaria));

if (acao.equals("obter_fats")){
      conFac = new BeanConsultaFactoring();
      conFac.setConexao(Apoio.getUsuario(request).getConexao());
              ResultSet ft = conFac.VisualizarFaturas(Integer.parseInt(request.getParameter("id")));
              int row = 0;
              String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'"+ request.getParameter("id") +">"+
                                 "<tr class='tabela'>"+
                                 "<td width='17%'>Número</td>"+
                                 "<td width='39%'>Cliente</td>"+
                                 "<td width='12%'>Vencimento</td>"+
                                 "<td width='12%'><div align='right'>Valor</div></td>"+
                                 "<td width='20%'>Nosso Número</td>"+
                                 "</tr>";
              while (ft.next()){
                  resultado += "<tr class="+((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+">";
                  resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarFatura("+ft.getString("fatura_id")+",0);});'>"+ft.getString("numero_fatura") + "/" + ft.getString("ano_fatura")+"</div></td>";
                  resultado += "<td>"+ft.getString("consignatario")+"</td>";
                  resultado += "<td>"+ft.getString("vencimento_fatura_br")+"</td>";
                  resultado += "<td><div align='right'>"+new DecimalFormat("#,##0.00").format(ft.getFloat("valor_fatura"))+"</div></td>";
                  resultado += "<td>"+ft.getString("boleto_nosso_numero")+"</td>";
                  resultado += "</tr>";
                  row++;
              }
 
              resultado += "</table>";
              response.getWriter().append(resultado);
              response.getWriter().close();
}

//se a acao eh exportar fatura para arquivo .pdf
if (acao.equals("exportar")){
    String codFatura = request.getParameter("codFatura");
    Map param = new java.util.HashMap(2);

    param.put("ID_FACT", String.valueOf(codFatura));
    param.put("USUARIO",Apoio.getUsuario(request).getNome());     
    param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
    request.setAttribute("map", param);
    request.setAttribute("rel", "factoringmod"+request.getParameter("modelo"));
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
    dispacher.forward(request, response);
}
%>

<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    
    function consultar(acao){
//        if (getObj("campoDeConsulta").value == "descontar_em" && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
//            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
//            return null;
//        }
            var data1 = $("dtemissao1");
            var data2 = $("dtemissao2");
            if ($("campoDeConsulta").value == "descontar_em" && !(validaData(data1) && validaData(data2))){
                alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
                return null;
            }

        try{
            document.location.replace("./jspconsulta_factoring.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=conFac.getPaginaResultados() + 1%> : 1)+"&"+
                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,idAgenteFactoring,idContaBancaria"));
        //idValorAgenteFactoring, idJurosAgenteFactoring, idLiquidoAgenteFactoring
        
        }catch(e){
            console.log("ERRO: " + e);
        }
    }

    function excluir(id){
        function ev(resp, st){
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
            else
                document.location.replace("./jspconsulta_factoring.jsp?acao=iniciar");
            else
                alert("Status "+st+"\n\nNão conseguiu realizar o acesso ao servidor!");
        }
   
        if (!confirm("Deseja mesmo excluir este desconto?"))
            return null;

        requisitaAjax("./cadmovimentacao_factoring.jsp?acao=excluir&id="+id, ev);
    }

    function aoCarregar(){
        getObj("campoDeConsulta").value = "<%=campoConsulta%>";
        getObj("operador").value = "<%=operadorConsulta%>";
        getObj("limiteResultados").value = "<%=limiteResultados%>";
        getObj("valorDaConsulta").value = "<%=valorConsulta%>";
        getObj("idAgenteFactoring").value = "<%=agenteFactoring%>";
        getObj("idContaBancaria").value = "<%=contaBancaria%>";        
    
    <%   if (conFac.getCampoDeConsulta().equals("") || conFac.getCampoDeConsulta().equals("descontada_em")) {
    %>        habilitaConsultaDePeriodo(true);
    <%   }
    %>
        }

        function editar(id){
            location.replace("./cadmovimentacao_factoring.jsp?acao=editar&id="+id);
        }

        function editarFatura(id){
                window.open('./jspfatura.jsp?acao=editar&id='+id+'&ex=false', 'CTRC' , 'top=0,resizable=yes');
        }

        function habilitaConsultaDePeriodo(opcao) {
            getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
            getObj("operador").style.display = (opcao ? "none" : "");
            getObj("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");
        }

        function viewFats(idDes){
            function e(transport){
                var textoresposta = transport.responseText;
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0") {
                    return false;
                }else{
                    Element.show("trfat_"+idDes);
                    $("trfat_"+idDes).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
                }
            }//funcao e()
            if (Element.visible("trfat_"+idDes)){
                Element.toggle("trfat_"+idDes);
                $('plus_'+idDes).style.display = '';
                $('minus_'+idDes).style.display = 'none';
            }else{
                $('plus_'+idDes).style.display = 'none';
                $('minus_'+idDes).style.display = '';
                new Ajax.Request("./jspconsulta_factoring.jsp?acao=obter_fats&id="+idDes,{method:'post', onSuccess: e, onError: e});
            }

        }

        function popImpressao(id){
             if (id == null)
                return null;

             launchPDF('jspconsulta_factoring.jsp?acao=exportar&modelo='+$('cbmodelo').value +'&codFatura='+id,'fatura'+id);
        }

</script>
<%@page import="conhecimento.duplicata.factoring.BeanConsultaFactoring"%>
<%@page import="conhecimento.duplicata.fatura.BeanConsultaFatura"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="nucleo.impressora.BeanConsultaImpressora"%>
<%@page import="java.util.Vector"%>
<%@page import="java.util.Map"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Desconto de Duplicatas em Factoring </title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="aoCarregar();applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <table width="80%" align="center" class="bordaFina" >
            <tr >
                <%    if (nivelUser >= 2) {
                %>
                <td width="590" align="left"><b>Consulta de Desconto de Duplicatas em Factoring </b></td>
                <%    }
            if (nivelUser >= 3) {
                %>
                <td width="98"><input name="novo" type="button" class="botoes" id="novo"
                                      onClick="javascript:tryRequestToServer(function(){document.location.replace('./cadmovimentacao_factoring.jsp?acao=iniciar');});"
                                      value="Novo cadastro">
                </td>
                <%    }
                %>
            </tr>
        </table>
        <br>
        <table width="80%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="105"  height="9"><select name="campoDeConsulta" class="fieldMin" id="campoDeConsulta"
                                                    onChange="javascript:habilitaConsultaDePeriodo(this.value=='descontada_em');">
                        <option value="descontada_em" selected>Data crédito</option>
                        <option value="razaosocial">Factoring</option>
                        <option value="numero_bordero">Numero de Borderô </option>
                    </select> </td>
                <td width="140"> <select name="operador" id="operador" class="fieldMin">
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
                    <div id="div1" style="display:none ">De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10"
                               value="<%=dataInicial%>"
                               onblur="alertInvalidDate(this)" class="fieldDate" >
                    </div></td>
              <td width="200">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">At&eacute;:
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10"
                               value="<%=dataFinal%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" class="fieldMin" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" value="" size="20">
              </td>              
                
                  <td width="187">
                    <div align="right"> Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="fieldMin">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                  </td>
            </tr>
            <table width="80%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="45%">                  
                  Conta:
                  <select id="idContaBancaria" class="fieldMin" style="font-size:8pt;width: 130px;" name="idContaBancaria">
                      <option value="0" selected>Todas</option>
                      <c:forEach var="contaBancaria" items="${filtrarContaBancaria}">
                          <option value="${contaBancaria.idConta}">${contaBancaria.numero}-${contaBancaria.descricao}</option>
                      </c:forEach>
                  </select>
              </td>
              <td width="45%">
                  Agente de Factoring:
                  <select id="idAgenteFactoring" class="fieldMin" style="font-size:8pt;width: 130px;" name="idAgenteFactoring">
                      <option value="0" selected>Todos</option>
                      <c:forEach var="factoring" items="${filtrarAgenteFactoring}">
                          <option value="${factoring.idfornecedor}">${factoring.razaosocial}</option>
                      </c:forEach>
                  </select>
              </td>
              <td width="95" height="20" width="10%"><div align="right"></div>                
                  <div align="center">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                  </div></td>
            </tr>
            </table>
        </table>
        <table width="80%" border="0" align="center" class="bordaFina">
            <tr class="tabela">
                <td width="2%"></td>
                <td width="3%"></td>
                <td width="10%">Crédito em</td>
                <td width="30%">Agente de Factoring</td>
                <td width="10%">Conta</td>
                <td width="10%"><div align="right">Valor</div></td>
                <td width="8%"><div align="right">Juros</div></td>
                <td width="10%"><div align="right">Líquido</div></td>
                <td width="14%">Status</td>
                <td width="3%"></td>
            </tr>
            <%int linha = 0;
            int linhatotal = 0;
            int qtde_pag = 0;
            double totalValor = 0.0;
            double totalLiquido = 0.0;
            double totalJuros = 0.0;
            
            if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima")) {
                conFac.setConexao(Apoio.getConnectionFromUser(request));
                int idContaBancaria = Apoio.parseInt(request.getParameter("idContaBancaria"));
                int idAgenteFactoring = Apoio.parseInt(request.getParameter("idAgenteFactoring"));

                conFac.setAgenteFactoring(idAgenteFactoring);
                conFac.setContaBancaria(idContaBancaria);

                if (conFac.Consultar()) {
                    ResultSet r = conFac.getResultado();
                    while (r.next()) {
            %>           
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td>
                    <img src="img/plus.jpg" id="plus_<%=r.getString("id")%>" name="plus_<%=r.getString("id")%>" title="Mostrar Faturas" class="imagemLink" align="right" 
                         onclick="javascript:viewFats('<%=r.getString("id")%>');">
                    <img src="img/minus.jpg" id="minus_<%=r.getString("id")%>" name="minus_<%=r.getString("id")%>" title="Mostrar Faturas" class="imagemLink" align="right" style="display:none"
                         onclick="javascript:viewFats('<%=r.getString("id")%>');">
                </td>
                <td>
                    <img src="img/pdf.jpg" width="19" height="19" border="0" align="right"
                         class="imagemLink" title="Formato PDF(usado para a impressão)"
			 onClick="javascript:tryRequestToServer(function(){popImpressao('<%=r.getString("id")%>');});">
                </td>
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id")%>);});">
                    <%=fmt.format(r.getDate("descontada_em"))%></div>
                </td>
                <td><%=r.getString("factoring")%></td>
                <td><%=r.getString("conta")%></td>
                <td>
                    <div align="right">
                        <%=new DecimalFormat("#,##0.00").format(r.getDouble("valor_desconto"))%>
                        <%totalValor += Apoio.parseDouble(new DecimalFormat("#,##0.00").format(r.getDouble("valor_desconto")));%>                        
                    </div>
                </td>
                <td>
                    <div align="right">
                        <%=new DecimalFormat("#,##0.00").format(r.getDouble("valor_juros"))%>                        
                        <%totalLiquido += Apoio.parseDouble(new DecimalFormat("#,##0.00").format(r.getDouble("valor_juros")));%>
                    </div>
                </td>
                <td>
                    <div align="right">
                        <%=new DecimalFormat("#,##0.00").format(r.getDouble("valor_desconto") - r.getDouble("valor_juros"))%>                        
                        <%totalJuros += Apoio.parseDouble(new DecimalFormat("#,##0.00").format(r.getDouble("valor_desconto") - r.getDouble("valor_juros")));%>
                    </div>
                </td>
                <td><%=r.getString("situacao")%></td>
                <td>
                    <%               if ((nivelUser == 4) && (r.getBoolean("pode_excluir"))) {
                    %>                   <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("id")%>);});">
                    <%               }
                    %>               
                </td>
            </tr>
            <tr style="display:none" id="trfat_<%=r.getString("id")%>" name="trfat_<%=r.getString("id")%>">
                <td rowspan="1" class='CelulaZebra1'></td>
                <td rowspan="1" colspan="12">--</td>
            </tr>

            <%           if (r.isLast()) {
                            linhatotal = r.getInt("qtde_linhas");
                        }
                        linha++;
                    }

                    int limit = conFac.getLimiteResultados();
                    qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                }                
            }
            %>
            <tr class="tabela">
                <td colspan="4"></td>
                <td>
                    <div align="right">Total:</div>
                </td>               
                <td width="10%"><div align="right"><%=Apoio.roundABNT(totalValor,2)%></div></td>
                <td width="8%"><div align="right"><%=Apoio.roundABNT(totalLiquido,2)%></div></td>
                <td width="10%"><div align="right"><%=Apoio.roundABNT(totalJuros,2)%></div></td>
                <td colspan="2"><div align="right"></div></td>
            </tr>

        </table>
        <br>
        <table width="80%" align="center" cellspacing="1" class="bordaFina">
            
      <tr class="celula">
        <td width="25%" height="22"><center>
                Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
            </center>
        </td>
            <td width="15%" align="center">P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : conFac.getPaginaResultados())%> / <%=qtde_pag %></b></td>
            <%if (conFac.getPaginaResultados() < qtde_pag)
              {%>
                <td width="7%" align="right">
                    <input name="avancar" type="button" class="botoes" id="avancar"
                           value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
                </td>
            <%}%>
            <td align="right">
                Modelo de impress&atilde;o em PDF:
                   <select name="cbmodelo" id="cbmodelo" class="fieldMin">
                        <option value="1" selected>Impressão de borderô(Modelo 1)</option>
                        <option value="2">Impressão de borderô(Modelo 2)</option>
                        <option value="3">Impressão de borderô(Modelo 3)</option>
                    </select>
            </td>
      </tr>
    </table>
    </body>
</html>
