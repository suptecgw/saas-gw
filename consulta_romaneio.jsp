<%@page import="usuario.BeanUsuario"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.cfe.pamcard.CategoriaVeiculoBO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="nucleo.Apoio,
         java.sql.ResultSet,
         nucleo.BeanLocaliza,
         java.util.Vector,
         java.text.SimpleDateFormat, 
         nucleo.impressora.*,
         filial.BeanFilial,
         java.util.Date" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.net.URLEncoder" %>

<% 
int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadromaneio") : 0);
int acessoApenasFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanromaneiofilial") : 0);
String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
BeanUsuario autenticado = Apoio.getUsuario(request);
//testando se a sessao é válida e se o usuário tem acesso
if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
    response.sendError(HttpServletResponse.SC_FORBIDDEN);
int nivelRoteirizarEntrega = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("roteirizadorentrega") : 0);
SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");   
//Iniciando Cookie
String campoConsulta = "";
String valorConsulta = "";
String dataInicial = "";
String dataFinal = "";
String finalizada = "";
String filial = "";
String motorista = "";
String idMotorista = "0";
String tipoRomaneio = "";
String operadorConsulta = "";
String limiteResultados = "";
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;

Cookie cookies[] = request.getCookies();
if (cookies != null){
        for(int i = 0; i < cookies.length; i++){
                if(cookies[i].getName().equals("consultaRomaneio")){
                        consulta = cookies[i];
                }else if(cookies[i].getName().equals("operadorConsulta")){
                        operador = cookies[i]; 
                }else if(cookies[i].getName().equals("limiteConsulta")){
                        limite = cookies[i]; 
                }
                if (consulta != null && operador != null && limite != null){ //se já encontrou os cookies então saia
                        break;
                }
        }
        if (consulta == null){//se não achou o cookieu então inclua
                consulta = new Cookie("consultaRomaneio","");
        }
        if (operador == null){//se não achou o cookieu então inclua
                operador = new Cookie("operadorConsulta","");
        }
        if (limite == null){//se não achou o cookieu então inclua
                limite = new Cookie("limiteConsulta","");
        }
    consulta.setMaxAge(60 * 60 * 24 * 90);
    operador.setMaxAge(60 * 60 * 24 * 90);
    limite.setMaxAge(60 * 60 * 24 * 90);

    String[] splitConsulta = URLDecoder.decode(consulta.getValue(), "ISO-8859-1").split("!!");

    String valor = (consulta.getValue().equals("") || splitConsulta.length < 1 ? "" : splitConsulta[0]);
    String campo = (consulta.getValue().equals("") || splitConsulta.length < 2 ? "" : splitConsulta[1]);
    String dt1 = (consulta.getValue().equals("") || splitConsulta.length < 3 ? fmt.format(new Date()) : splitConsulta[2]);
    String dt2 = (consulta.getValue().equals("") || splitConsulta.length < 4 ? fmt.format(new Date()) : splitConsulta[3]);
    String fin = (consulta.getValue().equals("") || splitConsulta.length < 5 ? "false" : splitConsulta[4]);
    String fl = (consulta.getValue().equals("") || splitConsulta.length < 6 ? "0" : splitConsulta[5]);
    String idMot = (consulta.getValue().equals("") || splitConsulta.length < 7 ? "0" : splitConsulta[6]);
    String mot = (consulta.getValue().equals("") || splitConsulta.length < 8 ? "Todos os motoristas" : splitConsulta[7]);
    String tipRom = (consulta.getValue().equals("") || splitConsulta.length < 9 ? "" : splitConsulta[8]);
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : (fin));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : (idMot));
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : (mot));
        tipoRomaneio = (request.getParameter("tipoRomaneio") != null ? request.getParameter("tipoRomaneio") : (tipRom));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                                ? request.getParameter("campoDeConsulta") 
                                : (campo.equals("")?"dtromaneio":campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") 
                                ? request.getParameter("operador") 
                                : (operador.getValue().equals("")?"1":operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") 
                        ? request.getParameter("limiteResultados")
                        : (limite.getValue().equals("")?"10":limite.getValue()));
        consulta.setValue(URLEncoder.encode(valorConsulta+"!!"+campoConsulta+"!!"+dataInicial+"!!"+dataFinal+"!!"+finalizada+"!!"+filial+"!!"+idMotorista+"!!"+motorista+"!!"+tipoRomaneio+"!!", "ISO-8859-1"));
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(operador);
    response.addCookie(limite);
}else{
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("") ? 
            request.getParameter("campoDeConsulta") : "dtromaneio");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                                                               : Apoio.incData(fmt.format(new Date()),-30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : "false");
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : "0");
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0");
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "Todos os motoristas");
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ? 
            request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? 
            request.getParameter("operador") : "1");
        operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? 
            request.getParameter("limiteResultados") : "10");
}
//Finalizando Cookie

    BeanConfiguracao beanConfRomaneio = new BeanConfiguracao();
    beanConfRomaneio.setConexao(Apoio.getUsuario(request).getConexao());
    
    beanConfRomaneio.CarregaConfig();

%>
<jsp:useBean id="consRom" class="conhecimento.romaneio.BeanConsultaRomaneio" />
<jsp:setProperty  name="consRom" property="idFilial"  />
<jsp:setProperty  name="consRom" property="paginaResultados"  />
<%
consRom.setCampoDeConsulta(campoConsulta);
consRom.setFinalizada(finalizada);
consRom.setLimiteResultados(Integer.parseInt(limiteResultados));
consRom.setOperador(Integer.parseInt(operadorConsulta));
consRom.setValorDaConsulta(valorConsulta);
consRom.setDtEmissao1(Apoio.paraDate(dataInicial));
consRom.setDtEmissao2(Apoio.paraDate(dataFinal));
consRom.setFinalizada(finalizada);
consRom.setIdFilial(Integer.parseInt(filial));
consRom.setIdMotorista(Integer.parseInt(idMotorista));
consRom.setFiltroPreRom(tipoRomaneio);

//exportacao da Cartafrete para arquivo .pdf
if (acao.equals("exportar"))
{
        String condicao = "";
        //Verificando qual campo filtrar
        

        //Exportando  
        java.util.Map param = new java.util.HashMap(2);
        request.setAttribute("map", param);
        String relatorio = "";
        String campo = "";
        String model = request.getParameter("modelo");
        if (model.indexOf("personalizado") > -1) {

            relatorio = "doc_romaneio_" + model;

            request.setAttribute("rel", relatorio);
            campo = "rom.idromaneio";
        } else {
            campo = "idromaneio";
            request.setAttribute("rel", "romaneiomod"+request.getParameter("modelo"));
        }    
        
        condicao = " WHERE "+campo+"="+request.getParameter("valorconsulta");
        
        param.put("CONDICAO", condicao);
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
}

   
    
    
   
%>

<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="javascript">
    shortcut.add("enter", function () {
        consultar('consultar')
    });

    function consultar(acao) {
        if (getObj("campoDeConsulta").value == "dtromaneio" && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value))) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }

        document.location.replace("./consultaromaneio?acao=" + acao + "&paginaResultados=" + (acao == 'proxima' ? <%=consRom.getPaginaResultados() + 1%> : (acao == 'anterior' ? <%=consRom.getPaginaResultados() - 1%> : 1)) + "&" +
                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,finalizada,filialId,motor_nome,idmotorista,tipoRomaneio"));
    }

    function envSincronizacao(id, actionImport) {
        //    var urlSinc = "http://localhost:8084/GwDelivery";
//    var urlSinc = "http://sonssoftware.gwcloud.com.br/GwDelivery";
//    var classeSinc = "Controlador";
//    var acaoSinc = "sincronizarRomaneioMotorista";
//    var janela;
//    if (cpf == null || cpf =="") {
//        alert("Informe o CPF!");
//        return false;
//    }
//    if (chave == null || chave =="") {
//        alert("Informe o chave do WebService!");
//        return false;
//    }
//    if (id == null || id =="") {
//        alert("Informe algum romaneio!");
//        return false;
//    }
//    janela = window.open('about:blank', 'pop', 'width=210, height=500');
//    janela.setTimeout("window.close();", 10000)
//    janela.location.href = urlSinc+"/"+classeSinc+"?acao="+acaoSinc+
//        "&cnpjContratante=< %=Apoio.getUsuario(request).getFilial().getCnpjContratanteGwMobile()%>"+
//        "&cpfMotorista=" + cpf + "&chaveWs="+chave+"&ids="+id;

        window.open("./MobileControlador?acao=sincronizarGWMobileRomaneio&idRomaneio=" + id + "&actionImport="+actionImport, "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
    }

    function excluir(id) {
        function ev(resp, st) {
            if (st == 200) {
                if (resp.split("<=>")[1] != "") {
                    alert(resp.split("<=>")[1]);

                } else {
                    consultar('consultar');
                }
            } else {
                alert("Status " + st + "\n\nNão conseguiu realizar o acesso ao servidor!");
            }
        }
        
        if (!confirm("Deseja mesmo excluir este romaneio?"))
            return null;
        
        requisitaAjax("./cadromaneio?acao=excluir&idromaneio=" + id, ev);
    }

    function excluirbaixa(id) {
        var excluirCTe = true;
        var excluirOcorrCTe = true;
        function ev(resp, st) {
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
                else
                    consultar('consultar');
            else
                alert("Status " + st + "\n\nNão conseguiu realizar o acesso ao servidor!");
        }

        if (!confirm("Deseja mesmo excluir a baixa deste romaneio?"))
            return null;

        if (!confirm("Deseja excluir a baixa do(s) CT-e(s)?"))
            excluirCTe = false;

        if (excluirCTe == true) {
            if (!confirm("Deseja excluir as Ocorrências da baixa?"))
                excluirOcorrCTe = false;
        }
        
        requisitaAjax("./cadromaneio?acao=excluirBaixa&idromaneio=" + id + "&excluirCTe=" + excluirCTe + "&excluirOcorrCTe=" + excluirOcorrCTe, ev);
    }

    function aoCarregar() {
        getObj("campoDeConsulta").value = "<%=campoConsulta%>";
        getObj("finalizada").value = "<%=finalizada%>";
        getObj("operador").value = "<%=operadorConsulta%>";
        getObj("limiteResultados").value = "<%=limiteResultados%>";
        getObj("valorDaConsulta").value = "<%=valorConsulta%>";
        getObj("tipoRomaneio").value = "<%=tipoRomaneio%>";

    <%   if (consRom.getCampoDeConsulta().equals("") || consRom.getCampoDeConsulta().equals("dtromaneio")) {
    %>        habilitaConsultaDePeriodo(true);
    <%   }
    %>
    }

    function editar(id) {
        location.replace("./cadromaneio?acao=editar&id=" + id);
    }

    function baixar(id) {
        location.replace("./cadromaneio?acao=iniciar_baixa&id=" + id);
    }

    function habilitaConsultaDePeriodo(opcao) {
        getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
        getObj("operador").style.display = (opcao ? "none" : "");
        getObj("div1").style.display = (opcao ? "" : "none");
        document.getElementById("div2").style.display = (opcao ? "" : "none");
    }

    function popRomaneio(id) {
        if (id == null)
	    return null;
        launchPDF('./consultaromaneio?acao=exportar&modelo=' + $('cbmodelo').value + '&campo=idromaneio&valorconsulta=' + id, 'romaneio' + id);
  
    }
    function rotasNoMaps(origem, destinos){
        if (origem == null || destinos == null)
                return null;
        var url = "http://maps.google.com/maps/dir/"+origem + "/"+destinos;
        window.open(url,"googMaps","toolbar=no,location=no,scrollbars=no,resizable=no");
//        var threadTeste = new ThreadGw("executarPesquisa();", 5000, true);
    }
    
    function executarPesquisa(){
        var max = window.document.getElementsByClassName("searchbox-searchbutton").length;
        var ele = null;
        for (var i = 0; i < max; i++){
            ele = window.document.getElementsByClassName("searchbox-searchbutton")[i];
            ele.click();
        }
    }

    function printMatricideRomaneio() {
        if (getCheckedsRomaneio() == "") {
            alert("Selecione pelo menos um romaneio!");
            return null;
        }
        var url = "./matricideromaneio.ctrc?ids=" + getCheckedsRomaneio() + "&" + concatFieldValue("driverImpressora,caminho_impressora");
        tryRequestToServer(function () {
            document.location.href = url;
        });
    }

    function getCheckedsRomaneio() {
        var ids = "";
        for (i = 0; getObj("ck" + i) != null; ++i)
            if (getObj("ck" + i).checked)
                ids += ',' + getObj("ck" + i).value;

        return ids.substr(1);
    }

    function novoCadastro() {
        document.location.replace('./cadromaneio?acao=iniciar');
    }

    function roteirizarEntrega() {
        window.open("RoteirizacaoControlador?acao=listar", 'MDFe', 'height=800,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1');
    }
    
    function abrirImportacao(idRomaneio, isEntrada){
        var tipoOperacao = isEntrada ? '0' : '1'; // tipo de importação, 0 = entrada, 1 = saída

        launchPopupLocate("./ConferenciaControlador?acao=importarArquivoRomaneio&idRomaneio=" + idRomaneio + "&tipo_operacao=" + tipoOperacao + "&layout=t", "Romaneio");
    }

    function enviarFusionTrak(idRomaneio) {
        window.open("./RoteirizacaoFusionTrakControlador?acao=enviarRomaneio&idRomaneio=" + idRomaneio, "pop", 'top=10,left=0,height=200,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function sincronizarRoteirizacao() {
        <% if (autenticado.getFilial().getStUtilizacaoFusionTrakRoteirizador() != 'N') {%>
            window.open("./RoteirizacaoFusionTrakControlador?acao=sincronizarRoteirizacao", "pop", 'top=10,left=0,height=200,width=500,resizable=yes,status=1,scrollbars=1');
        <% } %>
    }
</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Romaneio</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="aoCarregar();applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <table width="85%" align="center" class="bordaFina" >
            <tr>
                <% if (nivelUser >= 2){%>
                <td width="590" align="left"><b>Consulta de Romaneio</b></td>
                <%} if(nivelRoteirizarEntrega ==4){%>
                <td width="98"><input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function () {roteirizarEntrega();});" value=" Roteirizador de Entregas ">
                </td>
                <% } if (autenticado.getFilial().getStUtilizacaoFusionTrakRoteirizador() != 'N') {%>
                    <td width="98">
                        <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function () {sincronizarRoteirizacao();});" value="Sincronizar Roteirização">
                    </td>
                <%} if (nivelUser >= 3){%>
                <td width="98"><input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function () {novoCadastro();});" value="Novo cadastro">
                </td>
                <%}%>


            </tr>
        </table>
        <br>
        <table width="85%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula"> 
                <td width="95"  height="20" ><select name="campoDeConsulta" id="campoDeConsulta" 
                                                     onChange="javascript:habilitaConsultaDePeriodo(this.value == 'dtromaneio');" class="fieldMin">
                        <option value="numromaneio">Nº Romaneio</option>
                        <option value="dtromaneio" selected>Data</option>
                    </select> </td>
                <td width="139" > <select name="operador" id="operador" class="fieldMin" style="width: 190px;">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (Vários separados por vírgula)</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select> 
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De: 
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10" 
                               value="<%=fmt.format((consRom.getCampoDeConsulta().equals("dtromaneio") ? consRom.getDtEmissao1() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate" >
                    </div></td>
                <td width="186"> 
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">At&eacute;: 
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10" 
                               value="<%=fmt.format((consRom.getCampoDeConsulta().equals("dtromaneio") ? consRom.getDtEmissao2() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" class="fieldMin" onKeyUp="javascript:if (event.keyCode == 13)
                  $('pesquisar').click();" value="" size="30">    </td>
                <td width="177"><input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                                       onClick="javascript:tryRequestToServer(function () {
                                      consultar('consultar');
                                  });"></td>
                <td width="250"><div align="right"> Por p&aacute;g.: 
                        <select name="limiteResultados" id="limiteResultados" class="fieldMin">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div></td>
            </tr>
            <tr class="celula"> 
                <td><div align="right">Mostrar:</div></td>
                <td>
                    <div align="left">
                        <select name="finalizada" id="finalizada" class="fieldMin">
                            <option value="todas">Todas</option>
                            <option value="false"  selected>Em aberto</option>
                            <option value="true">Finalizadas</option>
                        </select>
                        <select name="tipoRomaneio" id="tipoRomaneio" class="fieldMin">
                            <option value="">Todas</option>
                            <option value="false">Apenas Romaneios</option>
                            <option value="true">Apenas Pré Romaneios</option>
                        </select>
                    </div>
                </td>  
                <td>
                    <select name="filialId" id="filialId" style="font-size:8pt;" class="inputTexto">
                        <%BeanFilial fl = new BeanFilial();
                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                        <%if (acessoApenasFilial > 0) {%>
                        <option value="0">TODAS AS FILIAIS</option>
                        <%}
                            while (rsFl.next()) {
                                if (acessoApenasFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                        <option value="<%=rsFl.getString("idfilial")%>"
                                <%=(filial.equals(rsFl.getString("idfilial")) ? "selected" : "")%>>APENAS A <%=rsFl.getString("abreviatura")%></option>
                        <%}%>
                        <%}%>
                    </select>
                    
                    
                    
                </td>  
                <td><div align="right">Apenas o motorista:</div></td>  
                <td><div align="left">
                        <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" size="28" readonly="true" value="<%=motorista%>">
                        <strong>
                            <input name="localiza_rem3" type="button" class="botoes" id="localiza_rem3" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista');
              ;">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';
              getObj('motor_nome').value = 'Todos os motoristas';"></strong>
                        <input type="hidden" name="idmotorista" id="idmotorista" value="<%=idMotorista%>">
                    </div></td>  
            </tr>
        </table>
        <table width="85%" border="0" align="center" class="bordaFina">
            <tr class="tabela">
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
                <td width="3%">&nbsp;</td>
                <% if (autenticado.getFilial().getStUtilizacaoFusionTrakRoteirizador() != 'N') { %>
                    <td width="3%">&nbsp;</td>
                <% } %>
                <td width="7%">Romaneio</td>
                <td width="10%">Data</td>
                <td width="32%">Motorista</td>
                <td width="23%">Filial</td>
                <td width="10%"></td>
                <td width="3%">&nbsp;</td>
            </tr>
            <%int linha = 0;
              int linhatotal = 0;
              int qtde_pag = 0;
 
              if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                  consRom.setConexao(Apoio.getConnectionFromUser(request));
                  if (consRom.Consultar()){
                      ResultSet r = consRom.getResultado();
                      while (r.next()) {
            %>           <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td>
                    <div align="center">
                        <img src="img/pdf.jpg" width="19" height="19" border="0" class="imagemLink" title="Formato PDF(usado para a impressão)"
                                             onClick="javascript:tryRequestToServer(function () {
                                                            popRomaneio('<%=r.getString("idromaneio")%>');
                                                        });">
                    </div>
                </td>
                <td>
                    <div align="center">        
                        <%if(!autenticado.getFilial().getTipoUtilizacaoGWMobile().equals("N")){
                        if (r.getBoolean("is_pre_romaneio")){%>
                             <img src="img/smartphone.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Romaneios para o GwMobile" 
                             onClick="javascript:tryRequestToServer(function () {
                                          alert('Um pré-Romaneio não pode ser sincronizado com o gwMobile.')
                                      });">
                        <%}else{                     
                        if(r.getBoolean("is_sincronizado_mobile")){%>
                        <% if(r.getBoolean("pode_reenviar")){ %>
                        <!-- 
                            esse icone abaixo não está bom. é como se o TODO o romaneio não foi enviado, mas a regra é que
                                se houver ao menos um ctrc ou coleta ele poderá enviar novamente.
                                    Mas Deivid disse para deixar assim (22/12/16) 
                        -->
                        <img src="img/smartphone.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Romaneios para o GwMobile" 
                             onClick="javascript:tryRequestToServer(function () {
                                          envSincronizacao('<%=r.getString("idromaneio")%>', 'a');
                                      });">
                        <% }else { %>
                        <img src="img/smart3.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Romaneios para o GwMobile" 
                             onClick="javascript:tryRequestToServer(function () {
                                          alert('Romaneio já sincronizado com o gwMobile.')
                                      });">
                        <% } %>
                        <%} else{ %>
                        <%if (!r.getBoolean("finalizado")) {
                        %>
                        <img src="img/smartphone.png" width="19" height="19" border="0" class="imagemLink" title="Sincronizar Romaneios para o GwMobile"
                             onClick="javascript:tryRequestToServer(function () {
                                          envSincronizacao('<%=r.getString("idromaneio")%>');
                                      });">
                        <%
                            }
                        %>

                        <%}}}%>
                    </div>
                </td>
                <td>
                    <div align="center">
                        <%if(r.getString("destinos") != null && !r.getString("destinos").trim().isEmpty())  {%>
                        <img src="img/gmaps.png" width="19" height="19" border="0" class="imagemLink" 
                             title="Visualizar Rotas no Google Maps" onClick="javascript:tryRequestToServer(function () {
                                       rotasNoMaps('<%=r.getString("end_origem")%>', '<%=r.getString("end_destino")%>');
                                   });"> 
                        <% }%>
                    </div>
                </td>
                <td>
                    <div align="center">
                        <img src="img/seta-azul.png" width="19" height="19" border="0" class="imagemLink" onclick="javascript:tryRequestToServer(function(){abrirImportacao(<%=r.getInt("idromaneio")%>);});" />
                    </div>
                </td>
                <td>
                    <div align="center">
                        <img src="img/seta-verde.png" width="19" height="19" border="0" class="imagemLink"
                             onclick="tryRequestToServer(function(){abrirImportacao(<%=r.getInt("idromaneio")%>, true)});"/>
                    </div>
                </td>
                <% if (autenticado.getFilial().getStUtilizacaoFusionTrakRoteirizador() != 'N') { %>
                    <%-- Fusion Trak --%>
                    <td>
                        <div align="center">
                            <% String statusFusionTrak = r.getString("status_envio_roteirizacao"); %>
                            <% if ("P".equals(statusFusionTrak)) {%>
                            <img src="img/fusion_trak/fusion-enviar.png" class="imagemLink imagemFusionTrak"
                                 title="Enviar Romaneio ao Fusion Trak"
                                 onclick="tryRequestToServer(function() { enviarFusionTrak('<%= r.getInt("idromaneio") %>'); });">
                            <% } else if ("E".equals(statusFusionTrak)) {%>
                            <img src="img/fusion_trak/fusion-baixar.png" class="imagemLink imagemFusionTrak"
                                 title="Romaneio enviado a Fusion Trak" style="cursor: default;">
                            <% } else if ("C".equals(statusFusionTrak)) {%>
                            <img src="img/fusion_trak/fusion-confirmado.png" class="imagemLink imagemFusionTrak"
                                 title="Romaneio confirmado pelo Fusion Trak"  style="cursor: default;">
                            <% }%>
                        </div>
                    </td>
                <% } %>
                <td>
                    <div align="center">
                        <input name="ck<%=linha%>" type="checkbox" value="<%=r.getInt("idromaneio")%>" id="ck<%=linha%>">
                    </div>
                </td>
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function () {
                            editar(<%=r.getInt("idromaneio")%>);
                        });">
                        <%= r.getBoolean("is_pre_romaneio") ? "Pré - " : "" %>
                        <%=r.getString("numromaneio")%></div>
                </td>
                <td><%=fmt.format(r.getDate("dtromaneio"))%></td>
                <td><%=(r.getString("nome") != null ? r.getString("nome") : "")%></td>
                <td><%=r.getString("abreviatura")%></td>
                <%               if (!r.getBoolean("finalizado")){ %>
                <td><div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function () {
                                baixar(<%=r.getInt("idromaneio")%>);
                            });">
                        Baixar</div>
                </td>
                <%}else{%>   
                <td><div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function () {
                                excluirbaixa(<%=r.getInt("idromaneio")%>);
                            });">
                        Excluir baixa</div>
                </td>
                <%                 }
                %>                <td>
                    <%               if((nivelUser == 4) && (r.getBoolean("podeexcluir"))) {
                    %>                   <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function () {
                                      excluir(<%=r.getString("idromaneio")%>);
                                  });">    
                    <%               }
                    %>               </td>
            </tr>

            <%           if (r.isLast()) 
                            linhatotal = r.getInt("qtde_linhas");
                          linha++;
                      }
          
                      int limit = consRom.getLimiteResultados();
                      qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);          
                  }
              }
            %> 

        </table>
        <br>
        <table width="85%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td height="22"><center>
                Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
            </center></td>
        <td width="9%" rowspan="2">
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function () {
                               consultar('anterior');
                           });">
            <%if (consRom.getPaginaResultados() < qtde_pag){%>
            <br><input name="avancar" type="button" class="botoes" id="avancar"
                       value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function () {
                               consultar('proxima');
                           });">
            <%}%>
        </td>
        <td width="10%" rowspan="2" align="center"><div align="right">Impressora:</div></td>
        <td width="15%" rowspan="2" align="center"><div align="left">
                <select name="caminho_impressora" id="caminho_impressora" class="fieldMin" style="width: 120px;">
                    <option value="">&nbsp;&nbsp;</option>
                    <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                impressoras.setLimiteResultados(100);
                if (impressoras.Consultar()){
                    ResultSet rs = impressoras.getResultado();
                        while (rs.next()){%>
                    <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora())?"selected":"") %>><%=rs.getString("descricao")%></option>
                    <%}%>
                    <%}%>
                </select>
            </div></td>
        <td width="6%" rowspan="2" align="center"><div align="right">Driver:</div></td>
        <td width="16%" rowspan="2" align="center"><div align="left">
                <select name="driverImpressora" id="driverImpressora" class="fieldMin" style="width: 100px;">
                    <%                Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "rom.txt");
                                              for (int i = 0; i < drivers.size(); ++i) {
                                                  String driv = (String)drivers.get(i);
                                                  driv = driv.substring(0,driv.lastIndexOf("."));
                    %>
                    <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                    <%}%>
                </select>
                <img src="img/ctrc.gif" class="imagemLink" title="Imprimir Romaneios selecionados" onClick="printMatricideRomaneio();">
            </div></td>
        <td width="12%" rowspan="2" align="right">Modelo PDF:</td>
        <td width="11%" rowspan="2" align="left">
            <select name="cbmodelo" id="cbmodelo" class="fieldMin">
                <option value="1"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("1") ? "selected" : "" %>>Modelo 1</option>
                <option value="2"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("2") ? "selected" : "" %>>Modelo 2</option>
                <option value="3"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("3") ? "selected" : "" %>>Modelo 3</option>
                <option value="4"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("4") ? "selected" : "" %>>Modelo 4</option>
                <option value="5"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("5") ? "selected" : "" %>>Modelo 5</option>
                <option value="6"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("6") ? "selected" : "" %>>Modelo 6</option>
                <option value="7"  <%=beanConfRomaneio.getRelDefaultConsultaRomaneio().equals("7") ? "selected" : "" %>>Modelo 7</option>
                <%for (String rel : Apoio.listRomaneios(request)) {%>
                <option value="personalizado_<%=rel%>" <%=(beanConfRomaneio.getRelDefaultConsultaRomaneio().startsWith("personalizado_" + rel) ? "selected" : "")%>>Modelo <%=rel.toUpperCase()%></option>
                <%}%>
            </select>
        </td>
    </tr>
    <tr class="celula">
        <td width="21%" ><div align="center">P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : consRom.getPaginaResultados())%> / <%=qtde_pag %></b></div></td>
    </tr>
</table>
</body>
</html>
