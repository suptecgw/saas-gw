<%@page import="nucleo.BeanConfiguracao"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          conhecimento.cartafrete.*,
          nucleo.Apoio,
          usuario.BeanUsuario,
          java.text.SimpleDateFormat,
          java.text.*,
          java.util.Date,
          java.util.Vector,
          nucleo.impressora.*" %>
<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("lancartafrete") : 0);
   int impCartaUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("impcartafrete") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

BeanConfiguracao cfg = new BeanConfiguracao();
cfg.setConexao(Apoio.getUsuario(request).getConexao());
cfg.CarregaConfig();


//Iniciando Cookie
String campoConsulta = "";
String valorConsulta = "";
String dataInicial = "";
String dataFinal = "";
String finalizada = "";
String tipoFilial = "";
String operadorConsulta = "";
String limiteResultados = "";
String ordenacao = "";
String tipoOrdenacao = "";
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;

Cookie cookies[] = request.getCookies();
if (cookies != null){
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getName().equals("consultaCartaFrete")){
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
		consulta = new Cookie("consultaCartaFrete","");
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

    String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
    String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
    String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
    String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
    String fin = (consulta.getValue().equals("") ? "1" : consulta.getValue().split("!!")[4]);
    String fl = (consulta.getValue().equals("") ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : consulta.getValue().split("!!")[5]);
    String ord = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 8 ? "cf.idcartafrete" : consulta.getValue().split("!!")[6]);
    String tipoOrd = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 8 ? "" : consulta.getValue().split("!!")[7]);
   	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
   	dataInicial = (request.getParameter("data") != null ? request.getParameter("data") : (dt1));
   	dataFinal = (request.getParameter("data2") != null ? request.getParameter("data2") : (dt2));
   	finalizada = (request.getParameter("baixadas") != null ? request.getParameter("baixadas") : (fin));
   	tipoFilial = (request.getParameter("tipofilial") != null ? request.getParameter("tipofilial") : (fl));
   	ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : (ord));
   	tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : (tipoOrd));
   	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
				? request.getParameter("campo") 
				: (campo.equals("")?"data":campo));
   	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") 
				? request.getParameter("ope") 
				: (operador.getValue().equals("")?"1":operador.getValue()));
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
			? request.getParameter("limite")
			: (limite.getValue().equals("")?"10":limite.getValue()));
	consulta.setValue(valorConsulta+"!!"+campoConsulta+"!!"+dataInicial+"!!"+dataFinal+"!!"+finalizada+"!!"+tipoFilial+"!!"+ordenacao+"!!"+tipoOrdenacao+"!!");
	operador.setValue(operadorConsulta);
	limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(operador);
    response.addCookie(limite);
}else{
	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("") ? 
            request.getParameter("campo") : "data");
	dataInicial = (request.getParameter("data") != null ? request.getParameter("data")
                                                               : Apoio.incData(fmt.format(new Date()),-30));
	dataFinal = (request.getParameter("data2") != null ? request.getParameter("data2") : fmt.format(new Date()));
	finalizada = (request.getParameter("baixadas") != null ? request.getParameter("baixadas") : "1");
	tipoFilial = (request.getParameter("tipofilial") != null ? request.getParameter("tipofilial") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
	ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : "cf.idcartafrete");
	tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : "");
	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
            request.getParameter("valor") : "");
	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? 
            request.getParameter("ope") : "1");
	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
            request.getParameter("limite") : "10");
}
//Finalizando Cookie

%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaCartaFrete beanCFrete = null;
    String acao     = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    int pag      = Integer.parseInt((request.getParameter("pag") != null ? request.getParameter("pag") : "1"));
    //Parametro para mostrar somente manifestoss da 
    //filial do usuario logado(se false e usuario poder lancar conh p/ outras filiais 
    //entao mostra todos os manifestos de todas as filiais)
    int lanca_carta_fl = Apoio.getUsuario(request).getAcesso("lancartafl");
    
    if (acao.equals("iniciar"))
    {
      acao = "consultar";
      pag = 1;
    }

    if ((acao.equals("consultar")) || (acao.equals("proxima")) ){   //instanciando o bean
        beanCFrete = new BeanConsultaCartaFrete();
        beanCFrete.setConexao( Apoio.getUsuario(request).getConexao() );
        beanCFrete.setCampoDeConsulta(campoConsulta);
        beanCFrete.setOperador(Integer.parseInt(operadorConsulta));
        beanCFrete.setValorDaConsulta(valorConsulta);
        beanCFrete.setLimiteResultados(Integer.parseInt(limiteResultados));
        BeanUsuario usu = Apoio.getUsuario(request);
        //Se o usuario tiver permissao para lancar conh para outras filiais entao 
		//ele pode visualizar os conh. das outras(quando for 0 vai mostrar todas)
        beanCFrete.setIdFilialCartaFrete(Apoio.getUsuario(request).getFilial().getIdfilial());
        beanCFrete.setBaixadas(Integer.parseInt(finalizada));
        beanCFrete.setTipoFilial(Integer.parseInt(tipoFilial));
        beanCFrete.setData(Apoio.paraDate(dataInicial));
        beanCFrete.setData2(Apoio.paraDate(dataFinal));
        beanCFrete.setOrdenacao(ordenacao + " " + tipoOrdenacao);
        
        beanCFrete.setPaginaResultados(pag);
        // a chamada do método Consultar() está lá em mbaixo
    }
    
    //se o usuario tiver permissao de excluir  
    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
    {
        BeanCadCartaFrete cadCFrete = new BeanCadCartaFrete();
        cadCFrete.setConexao(Apoio.getUsuario(request).getConexao());
        cadCFrete.setExecutor(Apoio.getUsuario(request));
        cadCFrete.getCFrete().setIdcartafrete(Integer.parseInt(request.getParameter("id")));
        %><script language="javascript"><%
        if (! cadCFrete.Deleta())
        {
            %>alert('<%=cadCFrete.getErros()%>');<%
        }
        %>location.replace("./consultacartafrete?acao=iniciar");
        </script><%

    }
    
    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar") && request.getParameter("id") != null)
    {
        
        String idcartafrete = request.getParameter("id");
            idcartafrete = idcartafrete.replace("'", "");
            String ids = "";
            for (int x = 0; x <= idcartafrete.split(",").length - 1; x++) {
                ids += (ids.equals("") ? "" : ",") + "'" + idcartafrete.split(",")[x] + "'";
            }
        
        
        String modelo = request.getParameter("modelo");
        java.util.Map param = new java.util.HashMap(1);
        param.put("IDCARTAFRETE", ids);
        param.put("USUARIO",request.getParameter("usuario"));
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        if (modelo.startsWith("doc_cartafrete_personalizado_")) {//Verificando se o nome começa por personalizado.
            request.setAttribute("rel", modelo);
        }else{
            request.setAttribute("rel", "cartafretemod"+request.getParameter("modelo"));
        }
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }    
    if(acao.equals("updateImpresso") && request.getParameter("ids") != null ){
        beanCFrete = new BeanConsultaCartaFrete();
        beanCFrete.setConexao( Apoio.getUsuario(request).getConexao() );
        beanCFrete.updateImpresso(request.getParameter("ids") );
    }
%>
<html>
    <head>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
  shortcut.add("enter",function() {consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value)});
  
    function seleciona_campos(){
        <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
        if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) )
        {%>
           $("valor_consulta").focus();     
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
           document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
           document.getElementById("operador_consulta").value = "<%=operadorConsulta %>";
           document.getElementById("limite").value = "<%=limiteResultados %>";
           document.getElementById("ordenacao").value = "<%=ordenacao%>";
           document.getElementById("tipo_ordenacao").value = "<%=tipoOrdenacao%>";
    <%}%>
  }

  function consulta(campo, operador, valor, limite){
     var data = document.getElementById("data").value.trim();
     var data2 = document.getElementById("data2").value.trim();
     if (campo == "data" && !(validaData(data) && validaData(data2) )) 
	 {
	    alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
	    return null;
	 }
	 
     location.replace("./consultacartafrete?campo="+campo+"&ope="+operador+"&valor="+valor+
	              "&tipofilial="+document.getElementById('tipofilial').value+"&baixadas="+document.getElementById('baixadas').value+
                      "&ordenacao=" + $('ordenacao').value + "&tipo_ordenacao=" + $('tipo_ordenacao').value +
                      (data == "" ? "" : "&data="+data+"&data2="+data2)+"&limite="+limite+"&pag=1&acao=consultar");
  }

  function editarcartafrete(idcartafrete, podeexcluir){
     location.replace("./cadcartafrete?acao=editar&id="+idcartafrete+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function baixarcartafrete(idcartafrete){
     location.replace("./bxcartafrete?acao=editar&id="+idcartafrete);
  }

  function proxima(campo, operador, valor, limite)
  {
     var data = document.getElementById("data").value.trim();
     var data2 = document.getElementById("data2").value.trim();
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultacartafrete?acao=proxima&pag="+<%=(pag + 1)%>+
                      "&valor=" + valor + "&limite="+limite+"&campo="+campo+
                      "&ordenacao=" + $('ordenacao').value + "&tipo_ordenacao=" + $('tipo_ordenacao').value +
    	              "&tipofilial="+document.getElementById('tipofilial').value+"&baixadas="+document.getElementById('baixadas').value+
                      (data == "" ? "" : "&data="+data+"&data2="+data2)+"&ope="+operador+"&acao=proxima");
  }

  function anterior(campo, operador, valor, limite)
  {
     var data = document.getElementById("data").value.trim();
     var data2 = document.getElementById("data2").value.trim();
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultacartafrete?acao=proxima&pag="+<%=(pag - 1)%>+
                      "&valor=" + valor + "&limite="+limite+"&campo="+campo+
                      "&ordenacao=" + $('ordenacao').value + "&tipo_ordenacao=" + $('tipo_ordenacao').value +
    	              "&tipofilial="+document.getElementById('tipofilial').value+"&baixadas="+document.getElementById('baixadas').value+
                      (data == "" ? "" : "&data="+data+"&data2="+data2)+"&ope="+operador+"&acao=anterior");
  }

  function excluircartafrete(idcartafrete)
  {
       if (confirm("Deseja mesmo excluir esta contrato de frete?"))
       {
	       location.replace("./consultacartafrete?acao=excluir&id="+idcartafrete);
       }
  }
  
  function cadcartafrete()
  { 
      location.replace("./cadcartafrete?acao=iniciar");
  }
  
  function habilitaConsultaDePeriodo(opcao)
  {
      document.getElementById("valor_consulta").style.display = (opcao ? "none" : "");
      document.getElementById("operador_consulta").style.display = (opcao ? "none" : "");
      document.getElementById("div1").style.display = (opcao ? "" : "none");
      document.getElementById("div2").style.display = (opcao ? "" : "none");	  
  }
  
  function aoCarregar(){
    seleciona_campos();
    <%if ((acao.equals("consultar") || acao.equals("proxima")) && (campoConsulta.equals("data")))
    {%>
       habilitaConsultaDePeriodo(true);
   <%}%>
  }
  
  function popCarta(id,linha){
     if (id == null)
	    return null;                    
     if($("isImpresso"+linha).value == "true" && !confirm("A(s) Carta(s) de Frete " + $("ck"+linha).value + " já foi(ram) impressa(s), deseja imprimir novamente?")){
        return null;
     }else{
        launchPDF('./consultacartafrete?acao=exportar&modelo='+document.getElementById("cbmodelo").value+'&id='+id+"&usuario="+'${usuario.nome}', 'carta'+id);
        updateImpresso(id);
        $("isImpresso"+linha).value = true;
     }          
  }

  function getCheckedCartaFrete(){
     var ids = "";
     
     for (i = 0; $("ck" + i) != null; ++i){
         if ($("ck" + i).checked){
              ids += ',' + $("ck" + i).value;                 
         }
     }
     
	 return ids.substr(1);
  }
  
  function getCheckedCartaFreteUpdate(){
      var ids = "";
     
     for (i = 0; $("ck" + i) != null; ++i){
            if ($("ck" + i).checked){
                ids += ',' + $("ck" + i).value;
              
            if($("isImpresso"+i).value == "true" && !confirm("A(s) Carta(s) de Frete " + $("ck"+i).value + " já foi(ram) impressa(s), deseja imprimir novamente?")){
                return "";                                                             
            }else{
                $("isImpresso"+i).value = true;
            }
       }
     }
     
	 return ids.substr(1);
  }

  function getCheckedCheques(){
     var ids = "";
     for (i = 0; $("ck" + i) != null; ++i)
	     if ($("ck" + i).checked)
	         ids += ',' + $("chq" + i).value;

	 return ids.substr(1);
  }
  function updateImpresso(ids){     
     new Ajax.Request("./consultacartafrete?acao=updateImpresso&ids="+ids);
  }

  function printMatricideCartaFrete() {
     if (getCheckedCartaFreteUpdate() == "") {
        alert("Selecione pelo menos uma Contrato de Frete!");
        return null;
     }
     var url =  "./matricidecartafrete.ctrc?ids="+getCheckedCartaFrete()+
         "&idCheque="+getCheckedCheques()+
         "&"+concatFieldValue("driverImpressora,caminho_impressora");
     tryRequestToServer(function(){document.location.href = url;});
     updateImpresso(getCheckedCartaFrete());
  }
  
</script>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Consulta de Contratos de Fretes</title>
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

<body onLoad="javascript:aoCarregar();applyFormatter();">
<img src="img/banner.gif"  alt=""><br>
<table width="100%" align="center" class="bordaFina" >
  <tr >
    <td width="525"><div align="left"><b>Consulta de Contratos de Fretes</b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="108">
	  <input name="novomanifesto" type="button" class="botoes" id="novomanifesto"  value="Novo cadastro" onClick="javascript:tryRequestToServer(function(){cadcartafrete();});">
    </td>
  <%}%>
  </tr>
</table>
<br>
<table width="100%" align="center" cellspacing="1" class="bordaFina">
  <tr class="celula"> 
      <td width="10%">
          <select name="campo_consulta" id="campo_consulta" onChange="javascript:habilitaConsultaDePeriodo(this.value=='data');" class="fieldMin" style="width: 120px;">
        <option value="cf.idcartafrete">Nº C. Frete</option>
        <option value="data" selected>Data</option>
        <option value="nome">Motorista</option>
        <option value="veiculo">Veículo</option>
        <option value="carreta">Carreta</option>
        <option value="proprietario">Proprietário</option>
        <option value="ctrcs">Nº CTRC</option>
        <option value="numero_carga">Nº Carga</option>
        <option value="coleta">Nº Coleta</option>
        <option value="pedido_coleta">Nº Pedido do Cliente (Coleta)</option>
        <option value="romaneio">Nº Romaneio</option>
      </select> 
      </td>
    <td width="16%"> <select name="operador_consulta" id="operador_consulta" class="fieldMin">
        <option value="1">Todas as partes com</option>
        <option value="2">Apenas com in&iacute;cio</option>
        <option value="3">Apenas com o fim</option>
        <option value="4">Igual &agrave; palavra/frase</option>
        <option value="5">Maior que</option>
        <option value="6">Maior ou igual &aacute;</option>
        <option value="7">Menor que</option>
        <option value="8">Menor ou igual &agrave;</option>
        <option value="9" selected>Igual ao n&uacute;mero</option>
      </select> 
      <!-- Campo somente para consulta de intervalo de datas -->
      <div id="div1" style="display:none ">De: 
        <input name="data" type="text" id="data" size="10" maxlength="10" value="<%=dataInicial%>" style="font-size:8pt;"
			   onblur="alertInvalidDate(this)" class="fieldDate">
      </div></td>
    <td colspan="2"> 
      <!-- Campo somente para consulta de intervalo de datas -->
      <div id="div2" style="display:none ">Para: 
        <input name="data2" type="text" id="data2" size="10" maxlength="10" value="<%=dataFinal%>" style="font-size:8pt;"
			   onblur="alertInvalidDate(this)" class="fieldDate" >
      </div>
      <input name="valor_consulta" type="text" id="valor_consulta" class="fieldMin" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar2').click();">
    </td>
    <td width="23%"><div align="center"><font size="2">Mostrar:
            <select name="tipofilial" id="tipofilial" class="fieldMin">
              <%if (lanca_carta_fl > 0) 
	      {%>
              <option value="0" <%=(tipoFilial.equals("0")?"selected":"")%>>Todas</option>
              <%}%>
              <option value="1" <%=(tipoFilial.equals("1")?"selected":"")%>>Emitidas por: <%=Apoio.getUsuario(request).getFilial().getAbreviatura()%></option>
              <option value="2" <%=(tipoFilial.equals("2")?"selected":"")%>>Destinadas &agrave;: <%=Apoio.getUsuario(request).getFilial().getAbreviatura()%></option>
            </select>
      </font> 
    </div></td>
    <td width="11%" rowspan="2"> <div align="center"><font size="2"> </font> 	  <font size="2">
        <input name="pesquisar" type="button" class="botoes" id="pesquisar2" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"> 
      </font><font size="2">
    </font></div></td>
    <td width="8%" rowspan="2"><div align="right"> <font size="2">Por p&aacute;g.:</font> 
      </div></td>
    <td width="12%" rowspan="2"><select name="limite" id="limite" class="fieldMin">
        <option value="10" selected>10 resultados</option>
        <option value="20">20 resultados</option>
        <option value="30">30 resultados</option>
        <option value="40">40 resultados</option>
        <option value="50">50 resultados</option>
      </select></td>
  </tr>
  <tr class="celula">
    <td><div align="right">Status:</div></td>
    <td><font size="2">
      <select name="baixadas" id="baixadas" class="fieldMin">
        <option value="0" <%=(finalizada.equals("0") ? "selected":"")%>>Todas</option>
        <option value="1" <%=(finalizada.equals("1") ? "selected":"")%>>Em aberto</option>
        <option value="2" <%=(finalizada.equals("2") ? "selected":"")%>>Baixadas</option>
      </select>
    </font></td>
    <td colspan="2">
        <div align="right">
            Ordenação:
        </div>
    </td>
    <td>
        <select name="ordenacao" id="ordenacao" class="fieldMin">
            <option value="cf.idcartafrete" selected>Nº C. Frete</option>
        </select> 
        <select name="tipo_ordenacao" id="tipo_ordenacao" class="fieldMin">
            <option value="" selected>Crescente</option>
            <option value="desc">Decrescente</option>
        </select> 
    </td>
  </tr>
</table>
<table width="100%" align="center" cellspacing="1" class="bordaFina">
    <tr>
    <td width="2%" class="tabela"></td>
    <td width="2%" class="tabela"></td>
      <td width="6%"  class="tabela"><div align="center">Número</div></td>
      <td width="6%" class="tabela">Data</td>
      <td width="11%" class="tabela">FL Origem / Destino</td>
      <td width="8%" class="tabela">Doc</td>
      <td width="23%" class="tabela">Motorista</td>
      <td width="12%" class="tabela">Veículo/Carreta</td>
      <td width="7%" class="tabela">Frete</td>
      <td width="6%" class="tabela">Adiant.</td>
      
    <td width="6%" class="tabela">Saldo</td>
      
    <td width="9%" class="tabela"><div align="center">Status</div></td>
      
    <td width="2%" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;
      String ultima_linha = "";
      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima")) && (beanCFrete.Consultar()) )
      {
          ResultSet rs = beanCFrete.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                  <td width="20">
                    <input name="ck<%=linha%>" type="checkbox" value="<%=rs.getInt("idcartafrete")%>" id="ck<%=linha%>"></td>
                    <input name="chq<%=linha%>" type="hidden" value="<%=rs.getString("ids_cheques")%>" id="chq<%=linha%>">
                    <input name="isImpresso<%=linha%>" id="isImpresso<%=linha%>" type="hidden" value="<%=rs.getBoolean("is_impresso")%>">
                  <td>
                     <% if((impCartaUser == 4) && ((rs.getInt("idfilial")==Apoio.getUsuario(request).getFilial().getIdfilial()) || ((rs.getInt("idfilial")!=Apoio.getUsuario(request).getFilial().getIdfilial()) && (lanca_carta_fl >= 1))))
                     {%>
                        <div align="center"><img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
					        onClick="javascript:tryRequestToServer(function(){popCarta('<%=rs.getString("idcartafrete")%>','<%=linha%>');});">
                    <%}%>
                        </div>
                  <td>
                      <div align="center" class="<%=(rs.getInt("idfilial")!=Apoio.getUsuario(request).getFilial().getIdfilial() && lanca_carta_fl == 0?"":"linkEditar")%>"  
 onclick="<%=(rs.getInt("idfilial")!=Apoio.getUsuario(request).getFilial().getIdfilial() && lanca_carta_fl == 0?"":"javascript:tryRequestToServer(function(){editarcartafrete("+rs.getString("idcartafrete")+","+(rs.getBoolean("podeexcluir") ? "null" : "0")+");});")%>">
							<%=rs.getString("idcartafrete")%>
				    </div>
                  </td>
                  <td>
                  		<font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
                  			<%=new SimpleDateFormat("dd/MM/yyyy").format( rs.getDate("data"))%>
                  		</font>	
				  </td>
                  <td>
                  		<font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
							<%=rs.getString("abreviatura")%>
						</font>
				  </td>
                  <td>
                  		<font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
							<%=rs.getString("ctrcs")%>
						</font>
				  </td>
                  <td>
                  		<font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
							<%=rs.getString("nome")%>
						</font>
				  </td>
                  <td>
                  		<font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
							<%=rs.getString("veiculo")+"/"+rs.getString("carreta")%>
				  		</font>
				  </td>
                  <td>
						<font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
							<%=new DecimalFormat("#,##0.00").format(rs.getFloat("vlliquido"))%>
						</font>
				  </td>
                  <td>
	  				    <font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
                  			<%=new DecimalFormat("#,##0.00").format(rs.getFloat("total_adiantamento"))%>
                  		</font>
                  </td>
                  <td>
	  				    <font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
                  			<%=new DecimalFormat("#,##0.00").format(rs.getFloat("total_saldo"))%>
                  		</font>
                  </td>
                  <td>
                  
                      <%if (rs.getBoolean("is_cancelada")) {%>
				    <div align="center">  
                         <font color=<%=(rs.getBoolean("is_cancelada") ? "#CC0000":"")%>>
	                         Cancelada
                         </font>
			        </div>
                      <%}else if(rs.getBoolean("saldobaixado")){ %> 
				    <div align="center">  
                         Baixada
			        </div>
                      <%}else{%> 
  		    		  <div align="center">  
                         Em aberto
	    		      </div>
                      <%}%> 
			      </td>
				  <%-- se o usuario tem permissao para excluir.... --%>
                             
    <td width="21"> 
      <% if((nivelUser == 4) && (rs.getBoolean("podeexcluir")) && ((rs.getInt("idfilial")==Apoio.getUsuario(request).getFilial().getIdfilial()) || ((rs.getInt("idfilial")!=Apoio.getUsuario(request).getFilial().getIdfilial()) && (lanca_carta_fl == 4))))
                             {%>
      <div align="center"><img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluircartafrete(<%=rs.getString("idcartafrete")%>);});"> 
        <%}%>
      </div></td>
					
</tr>
				
              <% //se for a ultima linha................
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("idcartafrete");
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
      pag = ( qtde_pag == 0 ? 0 : pag );
   

   %>
</table>
<br>
<table width="100%" align="center" cellspacing="1" class="bordaFina">
  <tr class="celula"> 
    <td width="18%" height="10"> <center>
        Ocorrências: <b><%=linha%> / <%=linhatotal%></b> </center></td>
    <td width="8%" rowspan="2" align="center"> 
      <div align="center">
        <input name="avancar" type="button" class="botoes" id="avancar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});">
    <%
        //se tiver mais pags entao mostre o botao 'proxima'
        if (pag < qtde_pag)
        {%>
        <br><input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});">
        
    <%}%></div></td>
    <td height="27" colspan="2"><div align="right">      </div></td>
    <td height="27" colspan="3"><div align="right">Ao imprimir utilizar:
        <select name="cbmodelo" id="cbmodelo" class="inputtexto">
          <option value="1" <%=cfg.getRelDefaultCartaFrete().equals("1")?"selected":""%>>Modelo 1</option>
          <option value="2" <%=cfg.getRelDefaultCartaFrete().equals("2")?"selected":""%>>Modelo 2</option>
          <option value="3" <%=cfg.getRelDefaultCartaFrete().equals("3")?"selected":""%>>Modelo 3</option>
          <option value="4" <%=cfg.getRelDefaultCartaFrete().equals("4")?"selected":""%>>Modelo 4</option>
          <option value="5" <%=cfg.getRelDefaultCartaFrete().equals("5")?"selected":""%>>Modelo 5 (Saldo)</option>
          <option value="6" <%=cfg.getRelDefaultCartaFrete().equals("6")?"selected":""%>>Modelo 6</option>
          <option value="7" <%=cfg.getRelDefaultCartaFrete().equals("7")?"selected":""%>>Modelo 7</option>
          <option value="8" <%=cfg.getRelDefaultCartaFrete().equals("8")?"selected":""%>>Modelo 8</option>
          <option value="9" <%=cfg.getRelDefaultCartaFrete().equals("9")?"selected":""%>>Modelo 9 (Coleta)</option>
          <option value="12" <%=cfg.getRelDefaultCartaFrete().equals("12")?"selected":""%>>Modelo 12</option>
          <option value="13" <%=cfg.getRelDefaultCartaFrete().equals("13")?"selected":""%>>Modelo 13</option>
          <%for (String rel : Apoio.listCartaFrete(request)) {%> 
            <option value="doc_cartafrete_personalizado_<%=rel%>" <%=cfg.getRelDefaultCartaFrete().equals("doc_cartafrete_personalizado_"+rel) ? "selected" : ""%>>Modelo <%=rel.toUpperCase() %></option>
          <%}%>
        </select>
    </div></td>
  </tr>
  <tr class="celula">
    <td width="18%" height="11"><div align="center">P&aacute;ginas: <b><%=pag %> / <%=qtde_pag %></b></div></td>
    <td width="15%" class="celula"><div align="right">Impressora:    </div></td>
    <td width="18%" class="celula"><div align="left"><span class="CelulaZebra2">
      <select name="caminho_impressora" id="caminho_impressora" class="inputtexto">
        <option value="">&nbsp;&nbsp;</option>
        <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
        impressoras.setConexao(Apoio.getUsuario(request).getConexao());
        impressoras.setLimiteResultados(50);
        if (impressoras.Consultar()){
            ResultSet rs = impressoras.getResultado();
  	        while (rs.next()){%>
        <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora())?"selected":"") %>><%=rs.getString("descricao")%></option>
        <%}%>
        <%}%>
      </select>
    </span>
    </div></td>
    <td width="14%"><div align="right">Driver:</div></td>
    <td width="19%"><div align="left"><span class="CelulaZebra2">
    <select name="driverImpressora" id="driverImpressora" class="inputtexto">
          <%                Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "caf.txt");
                  for (int i = 0; i < drivers.size(); ++i) {
                      String driv = (String)drivers.get(i);
                      driv = driv.substring(0,driv.lastIndexOf("."));%>
                  <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                  <%}
                          Vector driversChq = Apoio.listFiles(Apoio.getDirDrivers(request), "chq.txt");
                  for (int x = 0; x < driversChq.size(); ++x) {
                      String driv = (String)driversChq.get(x);
                      driv = driv.substring(0,driv.lastIndexOf("."));
%>
          <option value="<%=driv%>"><%=driv%>&nbsp;</option>
          <%}%>
        </select>
</span></div></td>
    <td width="8%"><img src="img/ctrc.gif" class="imagemLink" title="Imprimir Cartas-frete selecionadas" onClick="printMatricideCartaFrete()"></td>
  </tr>
</table>
<br>
<br>
<br>
<br>
</body>
</html>
