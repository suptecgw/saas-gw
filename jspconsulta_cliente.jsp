<%@page import="nucleo.BeanConfiguracao"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          java.lang.String,
          cliente.BeanConsultaCliente,
          cliente.BeanCadCliente,
          nucleo.Apoio" %>
<%
   //Permissão do usuário
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadcliente") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA
         BeanConfiguracao cfg = new BeanConfiguracao();
         cfg.setConexao(Apoio.getUsuario(request).getConexao());
         cfg.CarregaConfig();
   
   
String campoConsulta = "";
String valorConsulta = "";
String operadorConsulta = "";
String limiteResultados = "";
String direto = "";
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;



int linha = 0;
int linhatotal = 0;
int qtde_pag = 0;

Cookie cookies[] = request.getCookies();
if (cookies != null){
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getName().equals("consultaClientes")){
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
		consulta = new Cookie("consultaClientes","");
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

    
    direto = request.getParameter("direto") != null ? request.getParameter("direto"): "";
    String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
    String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
   
   boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("cadcliente") > 0);
   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );

  if (acao.equals("exportar"))
  {
    String idcli = request.getParameter("idCliente"); 
    String modelo = request.getParameter("modelo");

    java.util.Map param = new java.util.HashMap(10);
    param.put("IDCLIENTE", "and idcliente=" + idcli);
    param.put("IDVENDEDOR", "");
    param.put("IDGRUPO", "");
    param.put("ATIVO", "true");
    param.put("DIRETO", "");

    String relatorio = "";
    String model = request.getParameter("modelo");
    request.setAttribute("map", param);    
    
    if (model.indexOf("personalizado_") > -1) {

        relatorio = "cliente_" + model;

        request.setAttribute("rel", relatorio);
            
    } else {
            
        request.setAttribute("rel", "clientesmod"+modelo);
    }
    RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports?impressao="+request.getParameter("impressao"));
    dispatcher.forward(request, response);
    
  }
  
    valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
   	campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
				? request.getParameter("campoDeConsulta") 
				: (campo.equals("")?"razaosocial":campo));
   	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") 
				? request.getParameter("operador") 
				: (operador.getValue().equals("")?"1":operador.getValue()));
   	limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") 
			? request.getParameter("limiteResultados")
			: (limite.getValue().equals("")?"10":limite.getValue()));
	consulta.setValue(valorConsulta+"!!"+campoConsulta);
	operador.setValue(operadorConsulta);
	limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(operador);
    response.addCookie(limite);
}else{
	campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("") ? 
            request.getParameter("campoDeConsulta") : "razaosocial");
	valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ? 
            request.getParameter("valorDaConsulta") : "");
	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? 
            request.getParameter("operador") : "1");
	limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? 
            request.getParameter("limiteResultados") : "10");
}
   
%>
<jsp:useBean id="bCli" class="cliente.BeanConsultaCliente" />
<jsp:setProperty name="bCli" property="*" />
<%  
    String acao     = request.getParameter("acao");
    acao = (acao == null ? "": acao);

    //Logo quando entra na página, carrega variáveis com os dados default para pesquisa
    if (acao.equals("iniciar"))
    {
      acao = "consultar";
    }

    //Se clicar em pesquisar ou clicar em proxima página
    if ((acao.equals("consultar")) || (acao.equals("proxima")) || (acao.equals("anterior")))
    {   
        bCli.setConexao( Apoio.getUsuario(request).getConexao() );
        bCli.setCampoDeConsulta(campoConsulta);
        bCli.setOperador(Integer.parseInt(operadorConsulta));
        bCli.setValorDaConsulta(valorConsulta);
        bCli.setLimiteResultados(Integer.parseInt(limiteResultados));
        bCli.setDireto(direto);
        // a chamada do método Consultar() está lá em mbaixo
    }

    //Se clicar em excluir
    if (acao.equals("excluir") && request.getParameter("id") != null)
    {
      BeanCliente cli = new BeanCliente();
      BeanCadCliente cadCli = new BeanCadCliente();
      cadCli.setConexao(Apoio.getUsuario(request).getConexao());
      cadCli.setExecutor(Apoio.getUsuario(request));
      cli.setIdcliente(Integer.parseInt(request.getParameter("id")));
      cadCli.setCliente(cli);
      %>
      <script language="javascript"> <%
         if (! cadCli.Deleta())
         {
             if(cadCli.getErros().indexOf("ctrcs_remetente_id_fkey") > -1){
                 %>alert("Existe lançamento para esse Cliente, por isso ele não pode ser excluido!");<%
             }else{
               %>alert("Erro ao tentar excluir!");<%
             }
         }
	 %>location.replace("./consultacliente?acao=iniciar");
      </script>
    <%
    }
    %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;

  //Chamar o cadastro de cliente
  function cadcliente(){
      location.replace("./cadcliente?acao=iniciar");
  }
  


  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) )
      {%>
           $("valorDaConsulta").focus();
           $("valorDaConsulta").value = "<%=valorConsulta %>";
           $("campoDeConsulta").value = "<%=campoConsulta%>";
           $("operador").value = "<%=operadorConsulta %>";
           $("limiteResultados").value = "<%=limiteResultados%>";
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
   
    function popRel(id){
     var impressao;
      var modelo = $("modelo").value;
       launchPDF('./jspconsulta_cliente.jsp?acao=exportar&modelo='+modelo+'&impressao=1&idCliente='+id);
    }

  function consultar(acao){
     if ($('campoDeConsulta').value == "cnpj") 
		$('valorDaConsulta').value = unformatNumber($('valorDaConsulta').value);

     var url = "./consultacliente?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=bCli.getPaginaResultados() + 1%> : (acao=='anterior'? <%=bCli.getPaginaResultados() - 1%>:1))+"&"+
                              concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,direto");
    document.location.replace(url);

  }

  function editarcliente(idcliente,podeexcluir){
     location.href = "./cadcliente?acao=editar&id="+idcliente+(podeexcluir == true ? "&ex="+podeexcluir : "");
  }

  function excluircliente(idcliente){
       if (confirm("Deseja mesmo excluir este cliente?"))
	   {
	       location.replace("./consultacliente?acao=excluir&id="+idcliente);
	   }
  }
  function popImg(idCliente, razaosocial){
        window.open('./ImagemControlador?acao=carregar&razaosocial='+razaosocial+'&idcliente='+idCliente,
        'ImagensCliente','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
  }
  
</script>

<%@page import="cliente.BeanCliente"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Consulta de clientes</title>
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
<table width="93%" align="center" class="bordaFina" >
  <tr >
    <td width="484" height="22"> <div align="left"><b>Consulta de clientes</b></div></td>
        <td width="49">
            <% if (nivelUser >= 3){%>
             <input name="cadcliente" type="button" class="botoes" id="cadcliente"  onClick="javascript:cadcliente();" value="Novo cadastro">
            <%}%>
        </td>
  </tr>
</table>
<br>
  <table width="93%" align="center" cellspacing="1" class="bordaFina">

    <tr class="celula">
        <td width="10%"><select name="campoDeConsulta" id="campoDeConsulta" class="inputtexto" style="width:120px;">
        <option value="razaosocial" selected>Raz&atilde;o Social</option>
        <option value="endereco">Endereço Principal</option>
        <option value="logradouro">Endereço Entrega/Coleta</option>
        <option value="cidade">Cidade</option>
        <option value="uf">UF</option>
        <option value="cnpj">CPF/CNPJ</option>
        <option value="inscest">Insc. Estadual</option>
        <option value="c.fone">Telefone</option>
        <option value="contato">Contato</option>
        <option value="cc.email">E-mail</option>
        </select>
      </td>
      <td width="15%"><select name="operador" id="operador" class="inputtexto">
        <option value="1" selected>Todas as partes com</option>
        <option value="2">Apenas com in&iacute;cio</option>
          <option value="3">Apenas com o fim</option>
          <option value="4">Igual &agrave; palavra/frase</option>
      </select></td>
      <td colspan="45%" align="left">
          <input name="valorDaConsulta" type="text" id="valorDaConsulta" size="35" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
          <select name="direto" id="direto" class="inputtexto">
              <option value="" <%=direto.equals("")? "selected":""%>>Mostrar Ambos</option>
              <option value="true"<%=direto.equals("true")? "selected":""%> >Apenas Diretos</option>
              <option value="false" <%=direto.equals("false")? "selected":""%>>Apenas Indireto</option>
          </select>
      </td>
      <td width="10%">
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consultar('consultar');});"></td>
      <td width="20%"><div align="right">
        Por p&aacute;g.:
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
  <table width="93%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="4%"class="tabela"></td>
      <td width="2%" class="tabela">&nbsp;</td>
      <td width="6%" class="tabela">Código</td>
      <td width="36%" class="tabela">Raz&atilde;o Social </td>
      <td width="15%"  class="tabela">Cidade</td>
      <td width="5%" class="tabela">UF</td>
      <td width="15%" class="tabela">CNPJ</td>
      <td width="10%" class="tabela">Telefone</td>
      <td width="10%" class="tabela">Contato</td>
      <td width="3%" class="tabela">&nbsp;</td>
    </tr>
     <% //variaveis da paginacao
        String ultima_linha = "";
        // se conseguiu consultar
        if ( (acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) && (bCli.Consultar()) )
        {
            ResultSet rs = bCli.getResultado();
                while (rs.next()) {
            //pega o resto da divisao e testa se é par ou impar
      %>
        <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
            <td width="14">
                <!--Area de imprimir em .PDF-->
                <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                onClick="javascript:tryRequestToServer(function(){popRel('<%=rs.getString("idcliente")%>');});">
            </td>
            <td>
                <img src="img/jpg.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Imagens de documentos"
                    onClick="javascript:tryRequestToServer(function(){popImg('<%=rs.getString("idcliente")%>','<%=rs.getString("razaosocial")%>');});">
            </td>
            <td height="24">
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarcliente(<%=rs.getString("idcliente")%>,<%=rs.getBoolean("podeexcluir")%>);});"><%=rs.getString("idcliente")%></div>
            </td>
            <td height="24">
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarcliente(<%=rs.getString("idcliente")%>,<%=rs.getBoolean("podeexcluir")%>);});"><%=rs.getString("razaosocial")%></div>
            </td>
                    <td><%=rs.getString("cidade")%></td>
                    <td><%=rs.getString("uf")%></td>
                    <td><%=rs.getString("cgc")%></td>
                    <td><%=rs.getString("fone")%></td>
                    <td><%=rs.getString("contato")%></td>
            <td width="24">
			<% if ((nivelUser == 4) && (rs.getBoolean("podeexcluir")))  //Verificando se tem permissão de exclusão
			{%>
			<img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer"
		                                 onClick="javascript:tryRequestToServer(function(){excluircliente(<%=rs.getString("idcliente") %>);});">
            <%}%>
	    </td>
          </tr>
              <% //se for a ultima linha...
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("razaosocial");
                     //Quantidade geral de resultados da consulta
                     linhatotal = rs.getInt("qtde_linhas");
                 }
                 linha++;
          }//while
          //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
          int limit = bCli.getLimiteResultados();
          qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);          
      }//if
	  %>
          <script type="text/javascript" language="javascript" >paginaAtual= <%=bCli == null ? 1 :bCli.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
</table>
<br>
  <table width="93%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
     
      <td width="25%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>

     <td width="25%">Páginas: <b><%=(qtde_pag == 0 ? 0 : bCli.getPaginaResultados())%> / <%=qtde_pag %></b></td>
      <td width="13%">
        <div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
        </div>

     <td width="27%" align="right">Modelo de impress&atilde;o em PDF:</td>
     <td width="10%">
          <select name="modelo" id="modelo" class="inputtexto">
               <option value="1" >Modelo 1</option>
               <option value="2" >Modelo 2</option>
               <option value="3" >Modelo 3</option>
               <option value="4" >Modelo 4</option>
               <option value="5" >Modelo 5</option>
               <%for (String rel : Apoio.listCliente(request)) {%>
             <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase()%></option>
      <%}%>
          </select>
      </td>
     
    </tr>
</table>
  <br>
<br>
<br>
<br>
</body>
</html>