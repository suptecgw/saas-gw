<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          planocusto.BeanConsultaPlano,
    	  planocusto.BeanCadPlanoCusto,
          nucleo.Apoio" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadplanocusto") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
   
   String valorConsulta = "";
   String limiteResultados = "";
   Cookie consulta = null;
   Cookie limite = null;

   Cookie cookies[] = request.getCookies();
   if (cookies != null){
   	for(int i = 0; i < cookies.length; i++){
   		if(cookies[i].getName().equals("consultaPlanoCusto")){
   			consulta = cookies[i];
   		}else if(cookies[i].getName().equals("limiteConsulta")){
   			limite = cookies[i]; 
   		}
   		if (consulta != null && limite != null){ //se já encontrou os cookies então saia
   			break;
   		}
   	}
   	if (consulta == null){//se não achou o cookieu então inclua
   		consulta = new Cookie("consultaPlanoCusto","");
   	}
   	if (limite == null){//se não achou o cookieu então inclua
   		limite = new Cookie("limiteConsulta","");
   	}
       consulta.setMaxAge(60 * 60 * 24 * 90);
       limite.setMaxAge(60 * 60 * 24 * 90);

       String valor = (consulta.getValue().equals("") ? "" : consulta.getValue());
      	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
      	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
   			? request.getParameter("limite")
   			: (limite.getValue().equals("")?"10":limite.getValue()));
   	consulta.setValue(valorConsulta);
   	limite.setValue(limiteResultados);
       response.addCookie(consulta);
       response.addCookie(limite);
   }else{
   	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
               request.getParameter("valor") : "");
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
               request.getParameter("limite") : "10");
   }
%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaPlano beanplano = null;
    String acao     = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);

    if (acao.equals("iniciar"))
    {
      acao = "consultar";
    }
    if (acao.equals("consultar"))
    {   //instanciando o bean
        beanplano = new BeanConsultaPlano();
        beanplano.setConexao( Apoio.getUsuario(request).getConexao() );
        beanplano.setValorDaConsulta(valorConsulta);
        // a chamada do método Consultar() está lá em mbaixo
    }

    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
    {
        BeanCadPlanoCusto cadplano = new BeanCadPlanoCusto();
        cadplano.setConexao(Apoio.getUsuario(request).getConexao());
        cadplano.setExecutor(Apoio.getUsuario(request));
        cadplano.setIdconta(Integer.parseInt(request.getParameter("id")));
        %><script language="javascript"><%
        if (! cadplano.Deleta())
        {
            if(cadplano.getErros().indexOf("appropriations_planocusto_id_fkey") > -1){ 
                %>alert("Este Plano de Custo está sendo utilizado em um CT-e ou NFS-e!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_diaria_motorista_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_alimentacao_ajudante_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_alimentacao_motorista_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_comissao_motorista_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_diaria_ajudante_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_pedagio_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_pernoite_ajudante_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_pernoite_motorista_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("config_plano_custo_saldo_id_fkey") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado nas Configurações!");<%    
            }else if(cadplano.getErros().indexOf("itens_rateio_idplanocusto_fkey") > - 1){  
                %>alert("Este Plano de Custo está sendo utilizado em uma Despesa!");<%    
            }else if(cadplano.getErros().indexOf("fk_apropdespesa_planocusto") > - 1){
                %>alert("Este Plano de Custo está sendo utilizado em uma Despesa!");<%    
            }else{
                %>alert("Erro ao tentar excluir!" + '<%=cadplano.getErros()%>');<%
            }
        }
        %>location.replace("./consultaplano?acao=iniciar");
        </script><%
    }
    %>

<script language="javascript" type="" >
    function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((valorConsulta != null))
      {%>
        $("valor_consulta").focus();
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
    <%}%>
}

  function consulta(valor){
     location.replace("./consultaplano?valor="+valor+"&acao=consultar");
  }

  function editar(idplano){
     location.replace("./cadplanocusto?acao=editar&id="+idplano);
  }

  function novo(){
      location.replace("./cadplanocusto?acao=iniciar");
  }

  function excluir(idconta){
       if (confirm("Deseja mesmo excluir esta conta?"))
	   {
	       location.replace("./consultaplano?acao=excluir&id="+idconta);
	   }
  }
</script>

<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Consulta do Plano Centro de Custos</title>
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
<table width="60%" align="center" class="bordaFina" >
  <tr >
    <td width="461"><div align="left"><b>Consulta do Plano Centro de Custos</b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="102">
	  <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:novo();" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
  <table width="60%" align="center" cellspacing="1" class="bordaFina">
    <tr class="celula">
      <td width="189"  height="20">      <input name="valor_consulta" type="text" id="valor_consulta"  size="35" maxlength="35" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
      <td width="407">
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:consulta(valor_consulta.value);"></td>
    </tr>
</table>
  <table width="60%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="644" class="tabela">Estrutura</td>
      <td class="tabela"></td>
    </tr>

   <% int linha = 0;

      // se conseguiu consultar
      if (acao.equals("consultar") && beanplano.Consultar())
      {
          ResultSet rs = beanplano.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %><tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                   <td>
                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=rs.getString("idconta")%>);});">
                          <% //codigo de identação
                            if (rs.getString("conta").indexOf(".") >-1)
                            {
                               for (int i=1; i < rs.getString("conta").length(); ++i)
                                  {%>&nbsp;&nbsp;&nbsp;<%}
                            }%>
                                <%=rs.getString("conta")%> - <%=rs.getString("descricao")%>
                        </div>
                   </td>
                   <td width="21">
                     <% if((nivelUser == 4) && (rs.getBoolean("podeexcluir")))
                     {%>
				        <img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                        onclick="javascript:tryRequestToServer(function(){excluir(<%=rs.getString("idconta")%>);});"
                        width="21" height="22" border="0" align="right">
					  <%}%>
				   </td>
               </tr>
             <% linha++;
          }//while
      }//if%>
</table>
  <br>
</body>
</html>
