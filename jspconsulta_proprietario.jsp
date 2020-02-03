<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          proprietario.BeanConsultaProprietario,
          proprietario.BeanCadProprietario,
          usuario.BeanUsuario,
          nucleo.Apoio" %>

<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadproprietario") : 0);
    //testando se a sessao eh valida e se o usuario tem acesso
   if (Apoio.getUsuario(request) == null || nivelUser == 0)
       response.sendError(response.SC_FORBIDDEN);

   String campoConsulta = "";
   String valorConsulta = "";
   String operadorConsulta = "";
   String limiteResultados = "";
   Cookie consulta = null;
   Cookie operador = null;
   Cookie limite = null;

   Cookie cookies[] = request.getCookies();
   if (cookies != null){
   	for(int i = 0; i < cookies.length; i++){
   		if(cookies[i].getName().equals("consultaProprietario")){
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
   		consulta = new Cookie("consultaProprietario","");
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
      	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
      	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
   				? request.getParameter("campo") 
   				: (campo.equals("")?"razaosocial":campo));
      	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") 
   				? request.getParameter("ope") 
   				: (operador.getValue().equals("")?"1":operador.getValue()));
      	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
   			? request.getParameter("limite")
   			: (limite.getValue().equals("")?"10":limite.getValue()));
   	consulta.setValue(valorConsulta+"!!"+campoConsulta);
   	operador.setValue(operadorConsulta);
   	limite.setValue(limiteResultados);
       response.addCookie(consulta);
       response.addCookie(operador);
       response.addCookie(limite);
   }else{
   	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("") ? 
               request.getParameter("campo") : "razaosocial");
   	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
               request.getParameter("valor") : "");
   	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? 
               request.getParameter("ope") : "1");
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
               request.getParameter("limite") : "10");
   }

%>

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaProprietario beanprop = null;
    String acao     = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    int pag      = Integer.parseInt((request.getParameter("pag") != null ? request.getParameter("pag") : "1"));

    if (acao.equals("iniciar"))
    {
      acao = "consultar";
      pag = 1;
    }

    if ((acao.equals("consultar")) || (acao.equals("proxima")) || (acao.equals("anterior")))
    {   //instanciando o bean
        beanprop = new BeanConsultaProprietario();
        beanprop.setConexao( Apoio.getUsuario(request).getConexao() );
        beanprop.setCampoDeConsulta(campoConsulta);
        beanprop.setOperador(Integer.parseInt(operadorConsulta));
        beanprop.setValorDaConsulta(valorConsulta);
        beanprop.setLimiteResultados(Integer.parseInt(limiteResultados));
        beanprop.setPaginaResultados(pag);
        // a chamada do método Consultar() está lá em mbaixo
    }

    if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null))
    {
	    BeanCadProprietario cadprop = new BeanCadProprietario();
	    cadprop.setConexao(Apoio.getUsuario(request).getConexao());
            cadprop.setExecutor(Apoio.getUsuario(request));
            cadprop.getProp().setIdfornecedor(Integer.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
               if (! cadprop.Deleta())
               {
                   %>alert("Erro ao tentar excluir!");<%
               }%>
               location.replace("./consultaproprietario?acao=iniciar");
             </script>
    <%}

%>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" src="script/funcoes.js" type=""></script>
<script language="javascript" type="text/javascript" >
    
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;
  function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
      if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) )
      {%>
           $("valor_consulta").focus();
           document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
           document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
           document.getElementById("operador_consulta").value = "<%=operadorConsulta %>";
           document.getElementById("limite").value = "<%=limiteResultados %>";
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
     location.replace("./consultaproprietario?campo="+campo+"&ope="+operador+"&valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function editarproprietario(idproprietario, podeexcluir){
     location.replace("./cadproprietario?acao=editar&id="+idproprietario+(podeexcluir != null ? "&ex="+podeexcluir : ""));
  }

  function cadproprietario(){
      location.replace("./cadproprietario?acao=iniciar");
  }

  function proxima(){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultaproprietario?pag="+<%=(pag + 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                      "&ope=<%=operadorConsulta%>&acao=proxima");
  }

  function anterior(){
     <%                                               //Somando a pag atual + 1 para a proxima pagina %>
     location.replace("./consultaproprietario?pag="+<%=(pag - 1)%>+
                      "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                      "&ope=<%=operadorConsulta%>&acao=anterior");
  }

  function excluirproprietario(idproprietario){
       if (confirm("Deseja mesmo excluir este proprietário?"))
	   {
	       location.replace("./consultaproprietario?acao=excluir&id="+idproprietario);
	   }
  }
  
    function enviarProprietarioEfrete(idProprietario){
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('EFreteControlador?acao=enviarProprietario&idProprietario='+idProprietario,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    function enviarProprietarioExpers(idProprietario, acao){
        
        if(acao =="consultar"){
            acao = "consultarProprietarioExpers";
        }else if(acao =="enviar"){
            acao = "enviarProprietarioExpers";
        }    
        
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('ExpersControlador?acao='+acao+'&idProprietario='+idProprietario,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    function enviarProprietarioPagBem(idProprietario, acao){
        
        acao = "enviarProprietarioPagBem";
      
        
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('PagBemControlador?acao='+acao+'&idProprietario='+idProprietario,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    function enviarProprietarioRepom(idProprietario, acao){
        
        if(acao =="consultar"){
            acao = "consultarProprietarioRepom";
        }else if(acao =="enviar"){
            acao = "enviarProprietarioRepom";
        }      
        
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('RepomControlador?acao='+acao+'&idProprietario='+idProprietario,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    
    function getRadioValorProprietario(name){
        var rads = document.getElementsByName(name);

        for(var i = 0; i < rads.length; i++){
            if(rads[i].checked){
                return rads[i].value;
            }

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

<title>WebTrans - Consulta de Proprietário</title>
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
<table width="80%" align="center" class="bordaFina" >
  <tr >
    <td width="461"><div align="left"><b>Consulta de Propriet&aacute;rio </b></div></td>
    <% if (nivelUser >= 3)
	{%>
	<td width="102">
	  <input name="novoproprietario" type="button" class="botoes" id="novoproprietario" onClick="javascript:cadproprietario();" value="Novo cadastro">
    </td>
  <%}%>
  </tr>
</table>
<br>
<table width="80%" align="center" cellspacing="1" class="bordaFina">

    <tr class="celula">
      <td width="93"  height="20"><select name="campo_consulta" id="campo_consulta" class="inputtexto">
        <option value="razaosocial" selected>Nome</option>
        <option value="cpf_cnpj">CNPJ/CPF</option>
        <option value="cid.cidade">Cidade</option>
        <option value="endereco">Endere&ccedil;o</option>
        <option value="cid.uf">UF</option>
        <option value="cep">Cep</option>
        <option value="fone1">Telefone</option>
        </select>
      </td>
      <td width="158"><select name="operador_consulta" id="operador_consulta" class="inputtexto">
        <option value="1" selected>Todas as partes com</option>
        <option value="2">Apenas com in&iacute;cio</option>
          <option value="3">Apenas com o fim</option>
          <option value="4">Igual &agrave; palavra/frase</option>
      </select></td>
      <td colspan="2"><input name="valor_consulta" type="text" id="valor_consulta" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto"></td>
      <td width="82">
	  <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});"></td>
      <td width="222"><div align="right">
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
  <table width="80%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="2%" class="tabela"></td>
      <td width="38%" class="tabela">Nome</td>
      <td width="17%" class="tabela">CNPJ/CPF</td>
      <td width="15%" class="tabela">Cidade</td>
      <td width="3%" class="tabela"><div align="center">UF</div></td>
      <td width="10%" class="tabela">CEP</td>
      <td width="13%" class="tabela">Telefone</td>
      <td width="2%" class="tabela"></td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;

      // se conseguiu consultar
      if ( (acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) && (beanprop.Consultar()) )
      {
          ResultSet rs = beanprop.getResultado();
	  while (rs.next())
          {
                            //pega o resto da divisao e testa se é par ou impar
             %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                    <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0) || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)
                            || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)|| Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "R".charAt(0)){%>
                    <td>
                        <input type="radio" name="idProprietarioEfrete" id="idProprietarioEfrete" value="<%=rs.getString("idproprietario")%>">
                    </td>
                    <%}else{%>
                    <td></td>
                    <%}%>
                  <td>
                       <a class="linkEditar" href="javascript:tryRequestToServer(function(){editarproprietario(<%=rs.getString("idproprietario")+","+(rs.getBoolean("podeexcluir") ? "null" : "0")%>);});">
			  <%=rs.getString("nome")%>
 		       </a>
                  </td>
                  <td><%=rs.getString("cgc")%></td>
                  <td><%=rs.getString("cidade")%></td>
                  <td><%=rs.getString("uf")%></td>
                  <td><%=rs.getString("cep")%></td>
                  <td><%=rs.getString("fone")%></td>

                     <% if ((nivelUser == 4) && (rs.getBoolean("podeexcluir")))
                        {
                            %><td width="21"><img id="imgExcluir<%= rs.getString("idproprietario") %>" src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluirproprietario(<%=rs.getString("idproprietario")%>);});"></td>
                    <%}else{%><td width="6"></td>
                    <%}%>
                </tr>
              <% //se for a ultima linha................
                 if (rs.isLast()) {
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
	  %><script type="text/javascript" language="javascript" >paginaAtual= <%=beanprop== null ? 1 :beanprop.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
</table>
<br>
  <table width="80%" align="center" cellspacing="1" class="bordaFina">
   <tr class="celula">
      <td width="20%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
     <td width="10%">
       
        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)){%>
            <input name="enviarExpers" type="button" class="botoes" id="enviarExpers"
            value="Consultar Situação do contratado na ANTT (Expers)"  onClick="javascript:tryRequestToServer(function(){enviarProprietarioExpers(getRadioValorProprietario('idProprietarioEfrete'), 'consultar');});">
        <%}%>
    </td>
     <td width="10%">
        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
            <input name="enviarEfrete" type="button" class="botoes" id="enviarEfrete"
            value="Enviar para e-Frete"  onClick="javascript:tryRequestToServer(function(){enviarProprietarioEfrete(getRadioValorProprietario('idProprietarioEfrete'));});">
        <%}%>
        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)){%>
            <input name="enviarExpers" type="button" class="botoes" id="enviarExpers"
            value="Enviar para ExpeRS"  onClick="javascript:tryRequestToServer(function(){enviarProprietarioExpers(getRadioValorProprietario('idProprietarioEfrete'), 'enviar');});">
        <%}%>
        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)){%>
            <input name="enviarPagBem" type="button" class="botoes" id="enviarPagBem"
            value="Enviar para PagBem"  onClick="javascript:tryRequestToServer(function(){enviarProprietarioPagBem(getRadioValorProprietario('idProprietarioEfrete'), 'enviar');});">
        <%}%>
        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "R".charAt(0)){%>
            <input name="enviarRepom" type="button" class="botoes" id="enviarRepom"
            value="Enviar para Repom"  onClick="javascript:tryRequestToServer(function(){enviarProprietarioRepom(getRadioValorProprietario('idProprietarioEfrete'), 'enviar');});">
        <%}%>
    </td>
      <td width="25%" align="center">Páginas: <b><%=pag %> / <%=qtde_pag %></b></td>
      <td width="20%"><div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior();});">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima();});">
			</div></td>

    </tr>
    </table>
  <br>
<br>
<br>
<br>
</body>
</html>
