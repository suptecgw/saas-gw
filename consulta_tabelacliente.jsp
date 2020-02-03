<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          java.lang.String,
          cliente.ConsultaTabelaCliente,
          cliente.BeanCadTabelaCliente,
          cliente.BeanTabelaCliente,
          nucleo.BeanLocaliza,
          nucleo.Apoio" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>
<%
   //Permissão do usuário
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadtabelacliente") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA

//Iniciando Cookie
String valorConsulta = "";
String idCliente = "";
String cliente = "";
String limiteResultados = "";
Cookie consulta = null;
Cookie limite = null;
Cookie consultaTabela = null;
String idAreaOrigem = "";
String areaOrigem = "";
String idAreaDestino = "";
String areaDestino = "";
String idCidadeOrigem = "";
String cidadeOrigem = "";
String idCidadeDestino = "";
String cidadeDestino = "";
String tipoProduto = "";
String idTipoProduto = "";
String apenasTabelas = "";
String idClientTariff = "";
String dataVigencia = "";
SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

Cookie cookies[] = request.getCookies();
if (cookies != null){
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getName().equals("consultaTabelaCliente")){
			consulta = cookies[i];
		}else if(cookies[i].getName().equals("limiteConsulta")){
			limite = cookies[i]; 
		}else if(cookies[i].getName().equals("consultaEstadoTabela")){
			consultaTabela = cookies[i]; 
		}
                
		if (consulta != null && limite != null && consultaTabela  != null ){ //se já encontrou os cookies então saia
			break;
		}
	}
	if (consulta == null){//se não achou o cookieu então inclua
		consulta = new Cookie("consultaTabelaCliente","");
	}
	if (limite == null){//se não achou o cookieu então inclua
		limite = new Cookie("limiteConsulta","");
	}
	if (consultaTabela == null){//se não achou o cookieu então inclua
		consultaTabela = new Cookie("consultaEstadoTabela","");
	}
	
    consulta.setMaxAge(60 * 60 * 24 * 90);
    limite.setMaxAge(60 * 60 * 24 * 90);
    consultaTabela.setMaxAge(60 * 60 * 24 * 90);

    String[] splitConsulta = URLDecoder.decode(consulta.getValue(), "ISO-8859-1").split("!!");

    String idCli = (consulta.getValue().isEmpty() || splitConsulta.length < 1 ? "0" : splitConsulta[0]);
    String cli = (consulta.getValue().isEmpty() || splitConsulta.length < 2  ? "Tabela Principal" : splitConsulta[1]);
    String idAreaOri = (consulta.getValue().isEmpty() || splitConsulta.length < 3 ? "0" : splitConsulta[2]);
    String idAreaDes = (consulta.getValue().isEmpty() || splitConsulta.length < 4 ? "0" : splitConsulta[3]);
    String idCidOri = (consulta.getValue().isEmpty()  || splitConsulta.length < 5 ? "0" : splitConsulta[4]);
    String idCidDes = (consulta.getValue().isEmpty()  || splitConsulta.length < 6 ? "0" : splitConsulta[5]);
    String areaOri = (consulta.getValue().isEmpty()  || splitConsulta.length < 7 ? "" : splitConsulta[6]);
    String areaDes = (consulta.getValue().isEmpty()  || splitConsulta.length < 8 ? "" : splitConsulta[7]);
    String cidadeOri = (consulta.getValue().isEmpty()  || splitConsulta.length < 9 ? "" : splitConsulta[8]);
    String cidadeDes = (consulta.getValue().isEmpty()  || splitConsulta.length < 10 ? "" : splitConsulta[9]);
    String tipoProd = (consulta.getValue().isEmpty()  || splitConsulta.length < 11 ? "" : splitConsulta[10]);
    String idTipoPro = (consulta.getValue().isEmpty()  || splitConsulta.length < 12 ? "0" : splitConsulta[11]);
    String apnTab = (consulta.getValue().isEmpty()  || splitConsulta.length < 13 ? "0" : splitConsulta[12]);
    String idTabPreco = (consulta.getValue().isEmpty()  || splitConsulta.length < 14 ? "" : splitConsulta[13]);
    String idDatVigencia = (consulta.getValue().isEmpty()  || splitConsulta.length < 15 ? "" : splitConsulta[14]);
   	idCliente = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : (idCli));
   	cliente = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : (cli));
   	idAreaOrigem = (request.getParameter("idareaorigem") != null ? request.getParameter("idareaorigem") : (idAreaOri));
   	idAreaDestino = (request.getParameter("idareadestino") != null ? request.getParameter("idareadestino") : (idAreaDes));
   	idCidadeOrigem = (request.getParameter("idcidadeorigem") != null ? request.getParameter("idcidadeorigem") : (idCidOri));
   	idCidadeDestino = (request.getParameter("idcidadedestino") != null ? request.getParameter("idcidadedestino") : (idCidDes));
   	areaOrigem = (request.getParameter("area_ori") != null ? request.getParameter("area_ori") : (areaOri));
   	areaDestino = (request.getParameter("area_des") != null ? request.getParameter("area_des") : (areaDes));
   	cidadeOrigem = (request.getParameter("cid_origem") != null ? request.getParameter("cid_origem") : (cidadeOri));
   	cidadeDestino = (request.getParameter("cid_destino") != null ? request.getParameter("cid_destino") : (cidadeDes));
   	tipoProduto = (request.getParameter("tipo_produto") != null ? request.getParameter("tipo_produto") : (tipoProd));
   	idTipoProduto = (request.getParameter("tipo_produto_id") != null ? request.getParameter("tipo_produto_id") : (idTipoPro));
   	apenasTabelas = (request.getParameter("estadoTabela") != null ? request.getParameter("estadoTabela") : (apnTab));
   	idClientTariff = (request.getParameter("clientTariffId") != null ? request.getParameter("clientTariffId") : (idTabPreco));
   	limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") 
			? request.getParameter("limiteResultados")
			: (limite.getValue().equals("")?"10":limite.getValue()));
        dataVigencia = (request.getParameter("dataVigenciaConsulta") != null ? request.getParameter("dataVigenciaConsulta") : idDatVigencia);
   	        
        consulta.setValue(URLEncoder.encode(idCliente+"!!"+cliente+"!!"+idAreaOrigem+"!!"+idAreaDestino+"!!"+idCidadeOrigem
                +"!!"+idCidadeDestino
                +"!!"+areaOrigem
                +"!!"+areaDestino
                +"!!"+cidadeOrigem
                +"!!"+cidadeDestino
                +"!!"+tipoProduto
                +"!!"+idTipoProduto
                +"!!"+apenasTabelas
                +"!!"+idClientTariff
                +"!!"+dataVigencia, "ISO-8859-1")
        );
	limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(limite);
}else{
	idCliente = (request.getParameter("idconsignatario") != null && !request.getParameter("idconsignatario").trim().equals("") ? 
            request.getParameter("idconsignatario") : "0");
	cliente = (request.getParameter("con_rzs") != null && !request.getParameter("con_rzs").trim().equals("") ? 
            request.getParameter("con_rzs") : "Tabela Principal");
	limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? 
            request.getParameter("limiteResultados") : "10");
        idAreaOrigem = (request.getParameter("idareaorigem") != null && !request.getParameter("idareaorigem").trim().equals("")? request.getParameter("idareaorigem") : "0");
   	idAreaDestino = (request.getParameter("idareadestino") != null && !request.getParameter("idareadestino").trim().equals("")? request.getParameter("idareadestino") : "0");
   	idCidadeOrigem = (request.getParameter("idcidadeorigem") != null && !request.getParameter("idcidadeorigem").trim().equals("")? request.getParameter("idcidadeorigem") : "0");
   	idCidadeDestino = (request.getParameter("idcidadedestino") != null && !request.getParameter("idcidadedestino").trim().equals("")? request.getParameter("idcidadedestino") : "0");
   	areaOrigem = (request.getParameter("area_ori") != null && !request.getParameter("area_ori").trim().equals("")? request.getParameter("area_ori") : "");
   	areaDestino = (request.getParameter("area_des") != null && !request.getParameter("area_des").trim().equals("")? request.getParameter("area_des") : "");
   	cidadeOrigem = (request.getParameter("cid_origem") != null && !request.getParameter("cid_origem").trim().equals("")? request.getParameter("cid_origem") : "");
   	cidadeDestino = (request.getParameter("cid_destino") != null && !request.getParameter("cid_destino").trim().equals("")? request.getParameter("cid_destino") : "");
   	tipoProduto = (request.getParameter("tipo_produto") != null && !request.getParameter("tipo_produto").trim().equals("")? request.getParameter("tipo_produto") : "");
   	idTipoProduto = (request.getParameter("tipo_produto_id") != null && !request.getParameter("tipo_produto_id").trim().equals("")? request.getParameter("tipo_produto_id") : "0");
   	apenasTabelas = (request.getParameter("estadoTabela") != null && !request.getParameter("estadoTabela").trim().equals("0")? request.getParameter("estadoTabela") : "0");
   	idClientTariff = (request.getParameter("clientTariffId") != null && !request.getParameter("clientTariffId").trim().equals("")? request.getParameter("clientTariffId") : "");
        dataVigencia = (request.getParameter("dataVigenciaConsulta") != null && !request.getParameter("dataVigenciaConsulta").trim().equals("")? request.getParameter("dataVigenciaConsulta") : "");
        
}
//Finalizando Cookie

%>
<jsp:useBean id="bCli" class="cliente.ConsultaTabelaCliente" />
<jsp:setProperty name="bCli" property="*" />
<%  
    
    bCli.setLimiteResultados(Integer.parseInt(limiteResultados));
    String acao     = request.getParameter("acao");
    acao = (acao == null ? "": acao);
    //Se clicar em pesquisar ou clicar em proxima página
    if ((acao.equals("consultar")) || (acao.equals("proxima")) || acao.equals("anterior"))
    {   
        bCli.setConexao( Apoio.getUsuario(request).getConexao() );
        bCli.setCliente_id(Integer.parseInt(idCliente));
        bCli.setCidadeOrigem(Integer.parseInt(idCidadeOrigem));
        bCli.setCidadeDestino(Integer.parseInt(idCidadeDestino));
        bCli.setAreaOrigem(Integer.parseInt(idAreaOrigem));
        bCli.setAreaDestino(Integer.parseInt(idAreaDestino));
        bCli.setTipoProduto(Integer.parseInt(idTipoProduto));
        bCli.setEstadoTabela(Integer.parseInt(apenasTabelas));
        bCli.setTabelaId(idClientTariff);
        bCli.setDataVigencia(Apoio.getFormatData(dataVigencia, "d/MM/yyyy"));// yyyy-MM-dd
        // a chamada do método Consultar() está lá em baixo
    }

    //Se clicar em excluir
    if (acao.equals("excluir") && request.getParameter("id") != null)
    {
      BeanCadTabelaCliente cadTab = new BeanCadTabelaCliente();
      BeanTabelaCliente tab = new BeanTabelaCliente();
      cadTab.setConexao(Apoio.getUsuario(request).getConexao());
      cadTab.setExecutor(Apoio.getUsuario(request));
      tab.setId(Integer.parseInt(request.getParameter("id")));
      cadTab.setTabela(tab);
      %>
      <script language="javascript"> <%
         if (! cadTab.Deleta())
         {
           %>alert("Erro ao tentar excluir!");<%
         }
	 %>location.replace("./consulta_tabelacliente.jsp?acao=iniciar&estadoTabela="+request.getParameter("estadoTabela"));
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
  function cadtabcliente(){
      location.replace("./cadtabela_preco.jsp?acao=iniciar");
  }

  function seleciona_campos(){
      $("limiteResultados").value = "<%=limiteResultados%>";
      $("estadoTabela").value = "<%=(apenasTabelas==null?"1":apenasTabelas)%>";
        if ('${param.recarregar}' == "true") {
            consultar('consultar')
        }
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
  }

  function consultar(acao){
     var url = "./consulta_tabelacliente.jsp?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=bCli.getPaginaResultados() + 1%> : (acao=='anterior'? <%=bCli.getPaginaResultados() - 1%> : 1))+"&"+
                              concatFieldValue("limiteResultados,idconsignatario,con_rzs,area_ori,idareaorigem,area_des,idareadestino,idcidadedestino,cid_destino,uf_destino,idcidadeorigem,cid_origem,uf_origem,tipo_produto_id,tipo_produto,estadoTabela,clientTariffId,dataVigenciaConsulta") ;
                              
    document.location.replace(url);

  }

  function editartabela(id,campo,cliente_id,cliente){
     location.href = ("./cadtabela_preco.jsp?acao=editar&id="+id);
  }

  function excluirtabela(id){
       if (confirm("Deseja mesmo excluir esta tabela?"))
	   {
	       location.replace("./consulta_tabelacliente.jsp?acao=excluir&id="+id+"&estadoTabela="+$("estadoTabela").value+"&recarregar=true");
	   }
  }
  
  function localizacliente(){
     	post_cad = window.open('./localiza?acao=consultar&idlista=5','Consignatario',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }
  function localizaproduto(){
      post_cad = window.open('./localiza?acao=consultar&idlista=37','Produto',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  function aoClicarNoLocaliza(idjanela)
  {          
     if (idjanela == "Area_Origem"){
        $('idareaorigem').value = $('area_id').value
        $('area_ori').value = $('sigla_area').value
     } else if (idjanela == "Area_Destino"){
        $('idareadestino').value = $('area_id').value
        $('area_des').value = $('sigla_area').value
     }
  }

</script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Consulta de tabelas de clientes</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="javascript:seleciona_campos();">
<img src="img/banner.gif"  alt=""><br>
  <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=idCliente%>">
  <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="<%=idCidadeOrigem%>">
  <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="<%=idCidadeDestino%>">
  <input type="hidden" name="area_id" id="area_id" value="0">
  <input type="hidden" name="sigla_area" id="sigla_area" value="0">
  <input type="hidden" name="idareaorigem" id="idareaorigem" value="<%=idAreaOrigem%>">
  <input type="hidden" name="idareadestino" id="idareadestino" value="<%=idAreaDestino%>">
  <input type="hidden" name="tipo_produto_id" id="tipo_produto_id" value="<%=idTipoProduto%>">

<table width="93%" align="center" class="bordaFina" >
  <tr >
    <td width="347" height="22"> <div align="left"><b>Consulta de tabelas de clientes</b></div></td>
    <td width="405">
	<% if (nivelUser >= 2){%>
	<input  name="Button" type="button" class="botoes" value="Alterar v&aacute;rias tabelas ao mesmo tempo" alt="Volta para o menu principal" onClick="javascript:location.replace('./cadtabela_preco_dinamica.jsp?acao=');;">
	<%}%></td>
    <td width="155">
	  <% if (nivelUser >= 3){%>
	  <input name="cadcliente" type="button" class="botoes" id="cadcliente"  onClick="javascript:tryRequestToServer(function(){cadtabcliente()});" value="Novo cadastro">
	  <%}%>
	</td>
  </tr>
</table>
<br>
  <table width="93%" align="center" cellspacing="1" class="bordaFina">
      <tr class="celula">
        <td style="text-align: right"> Código da tabela de Preço: </td>
        <td style="text-align: left" colspan="4"> <input type="text" class="inputtexto" id="clientTariffId" name="clientTariffId" value="<%=idClientTariff%>" size="30"/> 
            <label><b>(Ao utilizar este campo, os demais filtros serão ignorados)</b></label>
      </td>
    </tr>  
    <tr class="celula">
      <td class=""><div align="right">Escolha o cliente:</div></td>
      <td><div align="left"><strong><strong>
        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly8pt" size="50" maxlength="80" readonly="true" value="<%=cliente%>">
        </strong>
        <input name="localiza_cli" type="button" class="botoes" id="localiza_cli" value="..." onClick="javascript:tryRequestToServer(function(){localizacliente()});">
      </strong> 
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Consignat&aacute;rio" onClick="javascript:getObj('idconsignatario').value = 0;javascript:getObj('con_rzs').value = 'Tabela Principal';"></div></td>
      <td width="211" colspan="2"><div align="right">
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
        <tr class="celula">
            <td width="20%" class="">
                <div align="right">Apenas a &aacute;rea origem: </div>
            </td>
            <td width="30%">
                <div align="left">
                    <input name="area_ori" type="text" id="area_ori" size="25" maxlength="80" readonly="true" value="<%=areaOrigem%>" class="inputReadOnly8pt">
                    <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="tryRequestToServer(function(){launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Origem')})">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('area_ori').value='';$('idareaorigem').value=0;">
              </div>
            </td>
            <td width="20%">
                <div align="right">Apenas a &aacute;rea destino:</div>
            </td>
            <td width="30%">
                <div align="left">
                    <input name="area_des" type="text" id="area_des" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true" value="<%=areaDestino%>">
                    <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="tryRequestToServer(function(){launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Destino')})">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('area_des').value='';$('idareadestino').value=0;">
                </div>
            </td>
	</tr>
	<tr class="celula">
            <td width="20%"  height="24" class="">
                <div align="right">Apenas cidade origem: </div>
            </td>
            <td>
                <div align="left">
                    <input name="cid_origem" type="text" id="cid_origem" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true" value="<%=cidadeOrigem%>">
                    <input name="uf_origem" type="text" id="uf_origem" class="inputReadOnly8pt" size="2" maxlength="80" readonly="true" value="<%=(request.getParameter("uf_origem")==null?"":request.getParameter("uf_origem"))%>">
          
                    <input name="localiza_cid_origem" type="button" class="botoes" id="localiza_cid_origem" value="..." onClick="tryRequestToServer(function(){launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Origem')})">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('uf_origem').value='';$('cid_origem').value='';$('idcidadeorigem').value=0;">
                </div>
            </td>
            <td>
                <div align="right">Apenas cidade destino: </div>
            </td>
            <td>
                <div align="left">
                    <input name="cid_destino" type="text" id="cid_destino" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true" value="<%=cidadeDestino%>">
                    <input name="uf_destino" type="text" id="uf_destino" class="inputReadOnly8pt" size="2" maxlength="80" readonly="true" value="<%=(request.getParameter("uf_destino")==null?"":request.getParameter("uf_destino"))%>">
                    <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="tryRequestToServer(function(){launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_Destino')})">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('uf_destino').value='';$('cid_destino').value='';$('idcidadedestino').value=0;">
                </div>
            </td>
       </tr>
      
       
       
       
       <tr class="celula">
          <td width="20%">
             <div align="right">
                Apenas o tipo de produto:
             </div>
          </td>
          <td>
             <div align="left">
                <input name="tipo_produto" type="text" id="tipo_produto" class="inputReadOnly8pt" size="30" maxlength="80" readonly="true" value="<%=tipoProduto%>">
                <strong>
                   <input name="localiza_prod" type="button" class="botoes" id="localiza_prod" value="..." onClick="javascript:tryRequestToServer(function(){localizaproduto()});">
                </strong> 
                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Produto" onClick="javascript:getObj('tipo_produto').value = '';javascript:getObj('tipo_produto_id').value = 0;">
             </div>
         </td>
         <td width="20%">
           <div align="right"> 
             Apenas as tabelas:
           </div>
        </td>
        <td width="30%">
           <div align="left"> 
             <select name="estadoTabela" id="estadoTabela" class="inputtexto" >
                  <option value="0">Ambas</option>
                  <option value="1" selected>Ativadas</option>
                  <option value="2">Desativadas</option>
            </select>
          </div> 
        </td>
    </tr>
    <tr class="celula">
        <td>
            <div align="right">
                Data Vigência:
            </div> 
        </td>
        <td colspan="3">
            <div align="left">
                <input type="text" onchange="fmtDate(this, event);" onkeyup="fmtDate(this, event);" onkeydown="fmtDate(this, event);" onkeypress="fmtDate(this, event);" onblur="alertInvalidDate(this)" class="fieldDate" id="dataVigenciaConsulta" name="dataVigenciaConsulta" size="10" maxlength="10" value="<%=dataVigencia%>"/>
            </div>
        </td>
         
    </tr>
    <tr class="celula">
	  <td  height="24" colspan="4" class=""><div align="center">
	    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Mostrar tabelas" alt="Faz a pesquisa com os dados informados"
            onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
      </div></td>
    </tr>
</table>
  <table width="93%" align="center" cellspacing="1" class="bordaFina">
    <tr>
      <td width="6%" class="tabela">Cod.</td>
      <td width="6%" class="tabela">Data vigência</td>
      <td width="18%" class="tabela">Origem</td>
      <td width="18%" class="tabela">Destino</td>
      <td width="15%" class="tabela">Tipo produto</td>
      <td width="7%" class="tabela"><div align="right">Frete/Kg</div></td>
      <td width="8%" class="tabela"><div align="right">Frete valor</div></td>
      <td width="6%" class="tabela"><div align="right">Outros</div></td>
      <td width="7%" class="tabela"><div align="right">Taxa fixa</div></td>
      <td width="6%" class="tabela"><div align="right">% NF</div></td>
      <td width="6%" class="tabela"><div align="right">Mínimo</div></td>
      <td width="5%" class="tabela">&nbsp;</td>
    </tr>
   <% //variaveis da paginacao
      int linha = 0;
      int linhatotal = 0;
      int qtde_pag = 0;
      String ultima_linha = "";
      if ( (acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) && (bCli.Consultar()))
      {
        ResultSet rs = bCli.getResultado();
	    while (rs.next()) {
          //pega o resto da divisao e testa se é par ou impar
          %>
          <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" style="color: <%=rs.getBoolean("is_desativada") ? "red" : ""  %>">
            <td>
              <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editartabela(<%=rs.getString("id")%>);});"><%=rs.getString("id")%>
            </div></td>
            <td>
                <label><%= (rs.getDate("data_vigencia") == null ? "" : fmt.format(rs.getDate("data_vigencia"))) %></label>
            </td>
            <td><%=(rs.getString("cidade_origem").equals("") ? (rs.getString("area_origem").equals("") ? "Tabela por KM" : rs.getString("area_origem")) : rs.getString("cidade_origem") + " - " + rs.getString("uf_origem"))%></td>
            <td><%=(rs.getString("cidade_destino").equals("") ? rs.getString("area_destino") : rs.getString("cidade_destino") + " - " + rs.getString("uf_destino"))%></td>
            <td><%=rs.getString("tipo_produto")%></td>
            <td><div align="right" id="valor_peso"><%=Apoio.to_curr_tres_casas(rs.getFloat("valor_peso"))%></div></td>
            <td><div align="right"><%=Apoio.to_curr(rs.getFloat("percentual_advalorem"))%></div></td>
            <td><div align="right"><%=Apoio.to_curr(rs.getFloat("valor_outros"))%></div></td>
            <td><div align="right"><%=Apoio.to_curr(rs.getFloat("valor_taxa_fixa"))%></div></td>
            <td><div align="right"><%=Apoio.to_curr(rs.getFloat("percentual_nf"))%></div></td>
            <td><div align="right"><%=Apoio.to_curr(rs.getFloat("valor_frete_minimo"))%></div></td>
            <td width="24">
			<% if (nivelUser == 4)  //Verificando se tem permissão de exclusão
			{%>
			<img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer"
		                                 onClick="javascript:tryRequestToServer(function(){excluirtabela(<%=rs.getString("id")%>);});">
            <%}%>
			</td>
          </tr>
              <% //se for a ultima linha...
                 if (rs.isLast()) {
                     ultima_linha = rs.getString("id");
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
      <td width="45%" height="22">
	  <center>
	     Ocorrências: <b><%=linha%> / <%=linhatotal%></b>
	  </center>
     </td>
      <td width="40%">Páginas: <b><%=(qtde_pag == 0 ? 0 : bCli.getPaginaResultados())%> / <%=qtde_pag %></b></td>
            <td width="15%"><div align="center">
			<input name="voltar" type="button" class="botoes" id="voltar"
              value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
			<input name="avancar" type="button" class="botoes" id="avancar"
              value="Próxima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
			</div></td>
    </tr>
</table>
  <br>
<br>
<br>
<br>
</body>
</html>
