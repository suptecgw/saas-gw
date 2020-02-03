<%@page import="nucleo.ModeloRelatorio"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
   import="despesa.BeanDespesa,
           despesa.BeanConsultaDespesa,
           nucleo.Apoio,
           java.sql.ResultSet,
           java.text.SimpleDateFormat, 
           java.util.Date" %>

<script language="javascript" src="script/funcoes.js"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
BeanUsuario usu = Apoio.getUsuario(request);
int nivelUser = (usu != null ? usu.getAcesso("caddespesa") : 0);
int nivelUserToFilial = (nivelUser > 0 ? usu.getAcesso("landespfl") : 0);
int nivelUserImpressaoRecibo = (usu != null ? usu.getAcesso("imprimirreciboavulso") : 0);
String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
if ((usu == null) || (nivelUser == 0))
    response.sendError(response.SC_FORBIDDEN);

SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");   
//Iniciando Cookie
String campoConsulta = "";
String valorConsulta = "";
String dataInicial = "";
String dataFinal = "";
String filial = "";
String idFornecedor = "";
String fornecedor = "";
String operadorConsulta = "";
String limiteResultados = "";
String ordenacao = "";
String status = "";
Cookie consulta = null;
Cookie operador = null;
Cookie limite = null;

Cookie cookies[] = request.getCookies();
if (cookies != null){
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getName().equals("consultaDespesa")){
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
		consulta = new Cookie("consultaDespesa","");
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

    String valor = (consulta.getValue().equals("") ? "" : splitConsulta[0]);
    String campo = (consulta.getValue().equals("") ? "" : splitConsulta[1]);
    String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : splitConsulta[2]);
    String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : splitConsulta[3]);
    String forn = (consulta.getValue().equals("") ? "" : splitConsulta[4]);
    String fl = (consulta.getValue().equals("") ? String.valueOf(usu.getFilial().getIdfilial()) : splitConsulta[5]);
    String idForn = (consulta.getValue().equals("") ? "0" : splitConsulta[6]);
    String ord = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 8 ? "idmovimento" : splitConsulta[7]);
    String sta = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 9 ? "t" : splitConsulta[8]);
   	valorConsulta = (request.getParameter("valorDaConsulta") != null ? "" + request.getParameter("valorDaConsulta") : (valor));
   	dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
   	dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
   	fornecedor = (request.getParameter("fornecedor") != null ? request.getParameter("fornecedor") : (forn));
   	idFornecedor = (request.getParameter("idfornecedor") != null ? request.getParameter("idfornecedor") : (idForn));
   	filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
   	ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : (ord));
   	status = (request.getParameter("status") != null ? request.getParameter("status") : (sta));
   	campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
				? request.getParameter("campoDeConsulta") 
				: (campo.equals("")?"dtentrada":campo));
   	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") 
				? request.getParameter("operador") 
				: (operador.getValue().equals("")?"1":operador.getValue()));
   	limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") 
			? request.getParameter("limiteResultados")
			: (limite.getValue().equals("")?"10":limite.getValue()));
	consulta.setValue(URLEncoder.encode(valorConsulta+"!!"+campoConsulta+"!!"+dataInicial+"!!"+dataFinal+"!!"+fornecedor+"!!"+filial+"!!"+idFornecedor+"!!"+ordenacao+"!!"+status+"!!", "ISO-8859-1"));
	operador.setValue(operadorConsulta);
	limite.setValue(limiteResultados);
    response.addCookie(consulta);
    response.addCookie(operador);
    response.addCookie(limite);
}else{
	campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("") ? 
            request.getParameter("campoDeConsulta") : "dtsolicitacao");
	dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                                                               : Apoio.incData(fmt.format(new Date()),-30));
	dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
	fornecedor = (request.getParameter("fornecedor") != null ? request.getParameter("fornecedor") : "");
	filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(usu.getFilial().getIdfilial()));
	idFornecedor = (request.getParameter("idfornecedor") != null ? request.getParameter("idfornecedor") : "0");
	ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : "idmovimento");
	status = (request.getParameter("status") != null ? request.getParameter("status") : "t");
	valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("") ? 
            request.getParameter("valorDaConsulta") : "");
	operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("") ? 
            request.getParameter("operador") : "1");
	operadorConsulta = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("") ? 
            request.getParameter("limiteResultados") : "10");
}
//Finalizando Cookie

if (acao.equals("exportar")){
        String condicao = "";
        //Verificando qual campo filtrar
        condicao = request.getParameter("valorconsulta");
        String modelo = request.getParameter("modelo");
        String relatorio = ""; 
        String nomeModelo = ""; 
        
        nomeModelo = (modelo.indexOf("personalizado") == -1 ? "docdespesamod" : "");
        //Exportando
        java.util.Map param = new java.util.HashMap(1);
        param.put("IDMOVIMENTO", condicao);
        param.put("OPCOES","");     
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", nomeModelo + modelo);
        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
        dispacher.forward(request, response);
}

   if (acao.equals("recibo")) {
      //Preenchendo o array dos conhecimentos
      String condicao = "";
      //recebendo valor do primeiro cheque
      condicao = " where idmovimento in ( " + request.getParameter("id") + ")";    
      

      java.util.Map param = new java.util.HashMap(1);
      param.put("CONDICAO", condicao);
      param.put("OPCOES","");     
      param.put("USUARIO",Apoio.getUsuario(request).getNome());     
      param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
      request.setAttribute("map", param);
      request.setAttribute("rel", "recibopagarmod1");

      RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
      dispacher.forward(request, response);
   }


int idFilialDespesa = Integer.parseInt(filial);
int idFilialUser = (!acao.equals("")? usu.getFilial().getIdfilial() : 0);
%>
<jsp:useBean id="consDesp" class="despesa.BeanConsultaDespesa" />
<jsp:setProperty  name="consDesp" property="campoDeConsulta"  />

<jsp:setProperty  name="consDesp" property="idFilialDespesa" value="<%=(nivelUserToFilial < 1? idFilialUser : idFilialDespesa)%>"/>
<jsp:setProperty  name="consDesp" property="limiteResultados"  />
<jsp:setProperty  name="consDesp" property="operador"  />
<jsp:setProperty  name="consDesp" property="paginaResultados"  />
<jsp:setProperty  name="consDesp" property="valorDaConsulta"  />
<%
consDesp.setDtEmissao1(Apoio.paraDate(dataInicial));
consDesp.setDtEmissao2(Apoio.paraDate(dataFinal));
consDesp.setIdFornecedor(Integer.parseInt(idFornecedor));
consDesp.setNivelConsultaDespesasOutrosUsuarios(usu.getAcesso("consultaDespesasOutrosUsuarios"));
      consDesp.setIdUsuario(usu.getId());
if (acao.equals("obter_duplicatas")){
	  BeanConsultaDespesa desp = new BeanConsultaDespesa();
      desp.setConexao(usu.getConexao());
	  if (desp.ConsultaDuplicatas(Integer.parseInt(request.getParameter("idmovimento")))){;
	      ResultSet du = desp.getResultado();
	      int row = 0;
	      boolean finalizado = false;
	      String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'"+ request.getParameter("idcarta") +">"+
	                         "<tr class='tabela'>"+
      	                 "<td width='4%'>PC</td>"+
      	                 "<td width='7%'><div align='right'>Valor</div></td>"+
      	                 "<td width='8%'>Vencimento</td>"+
      	                 "<td width='10%'>Status</td>"+
      	                 "<td width='10%'><div align='right'>Valor pago</div></td>"+
      	                 "<td width='8%'>Pago em</td>"+
      	                 "<td width='10%'>Pago por</td>"+
      	                 "<td width='8%'>Conta</td>"+
      	                 "<td width='10%'>Cheque/doc</td>"+
      	                 "<td width='12%'>Conciliado</td>"+
      	                 "<td width='4%'></td>"+
      	                 "<td width='10%'></td>"+
	                         "</tr>";
	      while (du.next()){
//	    	  finalizado = ctrc.getDate("baixa_em") != null;
	    	  resultado += "<tr class="+((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+">";
	    	  resultado += "<td>"+ du.getString("duplicata")+"</td>";
	    	  resultado += "<td><div align='right'>"+new DecimalFormat("#,##0.00").format(du.getFloat("vlduplicata"))+"</div></td>";
	    	  resultado += "<td>"+new SimpleDateFormat("dd/MM/yyyy").format(du.getDate("dtvenc"))+"</td>";
	    	  resultado += "<td>"+(du.getBoolean("baixado") ? "Baixado" : (du.getBoolean("is_parcela_cancelada") ? "Cancelada" : "Em aberto"))+"</td>";//
	    	  resultado += "<td><div align='right'>"+new DecimalFormat("#,##0.00").format(du.getFloat("vlpago"))+"</div></td>";
	    	  resultado += "<td>"+(du.getDate("dtpago") != null ? new SimpleDateFormat("dd/MM/yyyy").format(du.getDate("dtpago")) : "")+"</td>";
	    	  resultado += "<td>"+du.getString("usuario_baixa")+"</td>";
	    	  resultado += "<td>"+du.getString("conta_baixa")+"</td>";
	    	  resultado += "<td>"+du.getString("docum")+"</td>";
	    	  resultado += "<td>"+(du.getBoolean("conciliado") ? "Sim" : "Não")+"</td>";
	    	  resultado += "<td>";
                  resultado += "</td>";
                  resultado += "<td>";
                  resultado += "</td>";
	    	  resultado += "</tr>";
                  if(du.getBoolean("is_parcela_cancelada")){
                  resultado += "<tr class="+((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+">";
                      resultado += "<td colSpan='3'>";
                          resultado += "Motivo do Cancelamento : ";
                      resultado += "</td>";
                      resultado += "<td colSpan='9'>";
                          resultado += du.getString("motivo");
                      resultado += "</td>";
                  resultado += "</tr>";
                  }
	    	  row++;
	      }
 	  resultado += "</table>";
      response.getWriter().append(resultado); 
  }else{
		response.getWriter().append("load=0"); 
  }    
  response.getWriter().close();
}

%>

  
<script type="text/javascript"  language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    
    var paginaAtual = <%=consDesp.getPaginaResultados()%>;


    function abrirPopAuditoria() {
        tryRequestToServer(function () {
            var url = "DespesaControlador?acao=auditoriaDespesa&isExclusao=true&isDespesa=true";

            window.open(url, 'auditoriaCteExclusao', 'toolbar=no,left=0,top=0,location=no,status=no,menubar=no,scrollbars=yes,resizable=no');
        });
    }
    
    function popDespesa(id){
        if (id == null){
            return null;
        }
        var modelo = $('cbmodelo').value;
        if (modelo == '2' || modelo == 'rec1'){
            if (<%=nivelUserImpressaoRecibo != 4 %>){
                alert('Você não tem privilégio suficiente para imprimir recibo avulso!');
                return null;
            }
        }

        if (modelo == 'rec1'){
            launchPDF('./consultadespesa?acao=recibo&id='+id,'despesa'+id);
        }else{
            launchPDF('./consultadespesa?acao=exportar&modelo=' + $('cbmodelo').value +'&valorconsulta='+id,'despesa'+id);
        }

    }
    
    function verMotivoCancelamento(motivo){
        alert("Motivo do Cancelamento: " + motivo);
    }

    function consultar(acao){
        
        if (($("campoDeConsulta").value == "vd.dtemissao" || $("campoDeConsulta").value == "dtentrada" || $("campoDeConsulta").value == "du_dtvenc" || $("campoDeConsulta").value == "du_dtpago")   && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
                alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
                return null;
        }

        document.location.replace("./consultadespesa?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=consDesp.getPaginaResultados() + 1%> : (acao=='anterior' && paginaAtual > 1?<%=consDesp.getPaginaResultados() - 1%>:1) )+"&"+
                                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,filialId,idfornecedor,fornecedor,ordenacao,status"));
    }   

    function excluir(id){
            if (!confirm("Deseja mesmo excluir esta despesa?"))
                    return null;

            requisitaPost("acao=excluir&idmovimento="+id, "./caddespesa");         
    }    

    function aoCarregar(){
        $("valorDaConsulta").focus();
        getObj("campoDeConsulta").value = "<%=(campoConsulta)%>";
        getObj("operador").value = "<%=operadorConsulta%>";
        getObj("limiteResultados").value = "<%=limiteResultados%>";
        getObj("filialId").value = "<%=filial%>";
        getObj("idfornecedor").value = "<%=idFornecedor%>";
        getObj("fornecedor").value = "<%=fornecedor%>";
        getObj("dtemissao1").value = "<%=dataInicial%>";
        getObj("dtemissao2").value = "<%=dataFinal%>";
        getObj("ordenacao").value = "<%=ordenacao%>";
        getObj("status").value = "<%=status%>";

        if(paginaAtual <= 1){
            //desabilitar($("voltar"));
        }

    <%   if (campoConsulta.equals("") || campoConsulta.equals("vd.dtemissao") || campoConsulta.equals("dtentrada") || campoConsulta.equals("du_dtvenc") || campoConsulta.equals("du_dtpago")) {
    %>        
            habilitaConsultaDePeriodo(true);
    <%   }
    %>
    }

    function editar(id, podeExcluir){
        location.replace("./caddespesa?acao=editar&id="+id+"&podeExcluir="+podeExcluir);
    }

    function habilitaConsultaDePeriodo(opcao) {
      $("valorDaConsulta").style.display = (opcao ? "none" : "");
      $("operador").style.display = (opcao ? "none" : "");
      $("div1").style.display = (opcao ? "" : "none");
      $("div2").style.display = (opcao ? "" : "none");
}

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

  
    function popImg(id){
        window.open('./ImagemControlador?acao=carregar&idDespesa='+id,'imagensDespesa','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function marcaTodasDespesa(){
        var i = 0;
        while($("ckDespesa_" + i) != null){
            $("ckDespesa_" + i).checked = $("ckConsultaTodos").checked;
            i++;
        }
    }
    
    function getMarcaTodasDespesa(){
        var idConsultaDespesa = "0";
        
        for(i = 0; getObj("ckDespesa_" + i) != null; i++){
            if (getObj("ckDespesa_" + i).checked){
                idConsultaDespesa = idConsultaDespesa + ',' + getObj("ckDespesa_" + i).value; 
            }
        }
        return idConsultaDespesa;
    }
    
    function imprimirConsultaManifesto(){
        var consultaDespesa = getMarcaTodasDespesa();
        var idConsultaDespesa = "0";
        
        idConsultaDespesa = consultaDespesa.replace("0,", "");
        
        if(consultaDespesa == "0"){
            alert("Selecione pelo menos um Nº da Consulta de Despesas!");
            return null;
        }
        popDespesa(idConsultaDespesa);
    }

</script>
<%@page import="filial.BeanFilial"%>
<%@page import="java.text.DecimalFormat"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.net.URLEncoder" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Despesas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="aoCarregar();applyFormatter();habilitaConsultaDePeriodo($('campoDeConsulta').value=='vd.dtemissao' || $('campoDeConsulta').value=='dtentrada' || $('campoDeConsulta').value == 'du_dtvenc' || $('campoDeConsulta').value == 'du_dtpago');">
        <img src="img/banner.gif">
        <br>
        <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
        <table width="98%" align="center" class="bordaFina" >
            <tr>
                <td width="590" align="left">
                    <b>Consulta de Despesas</b>
                </td>
                <td width="98">
                    <input name="auditoria" type="button" class="botoes" id="auditoria" onClick="javascript:abrirPopAuditoria();"
                           value="Visualizar Auditoria">
                <% if (nivelUser >= 3){%>
                        <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function(){document.location.replace('./caddespesa?acao=iniciar');});"
                               value="Novo cadastro">
                <%}%>
                </td>
            </tr>
        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="14%" >
                    <div align="right">
                        <select name="campoDeConsulta" id="campoDeConsulta" class="inputtexto"
                            onChange="javascript:habilitaConsultaDePeriodo(this.value=='vd.dtemissao' || this.value=='dtentrada' || this.value == 'du_dtvenc' || this.value == 'du_dtpago');">
                            <option value="vd.idmovimento">Movimento</option>
                            <option value="vd.nfiscal">Nota Fiscal</option>
                            <option value="vd.dtemissao" >Emiss&atilde;o</option>
                            <option value="dtentrada" selected>Entrada</option>
                            <option value="du_dtvenc" selected>Vencimento</option>
                            <option value="du_dtpago" selected>Pagamento</option>
                        </select>
                    </div>
                </td>
                <td width="26%">
                    <select name="operador" id="operador" class="inputtexto" style="width: 190px;">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (V&aacute;rios separados por v&iacute;rgula)</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none " align="left">
                        De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" 
                               value="<%=fmt.format((consDesp.getCampoDeConsulta().equals("dtemissao") || consDesp.getCampoDeConsulta().equals("dtentrada")
                                    || consDesp.getCampoDeConsulta().equals("du_dtvenc")  || consDesp.getCampoDeConsulta().equals("du_dtpago") ? consDesp.getDtEmissao1() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>	
                </td>
                <td width="18%">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none " align="left">
                        Para:
                        <input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" 
                               value="<%=fmt.format((consDesp.getCampoDeConsulta().equals("dtemissao") || consDesp.getCampoDeConsulta().equals("dtentrada") 
                                || consDesp.getCampoDeConsulta().equals("du_dtvenc")  || consDesp.getCampoDeConsulta().equals("du_dtpago") ? consDesp.getDtEmissao2() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <div align="left">
                        <input name="valorDaConsulta" type="text" id="valorDaConsulta" value="<%=consDesp.getValorDaConsulta()%>" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">	
                    </div>
                </td>
                <td width="22%">
                    <div align="center">
                        Apenas a Filial:
                        <select name="filialId" id="filialId" style="font-size:8pt;" class="fieldMin">
                            <option value="0" selected="selected">TODAS</option>
                                <%BeanFilial fl = new BeanFilial();
                                    ResultSet rsFl = fl.all(usu.getConexao());
                                    while (rsFl.next()){
                                        if (nivelUserToFilial > 0 || usu.getFilial().getIdfilial()==rsFl.getInt("idfilial")){%>
                                            <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                                        <%} %>
                                    <%} %>
                        </select>
                    </div>
                </td>
                <td width="9%" rowspan="2">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="pesquisar" title="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                </td>
                <td width="12%" rowspan="2">
                    <div align="center">
                        Por p&aacute;g.:
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
                <td>
                    <div align="right">Apenas o Fornecedor:</div>
                </td>
                <td>
                    <div align="left">
                        <strong>
                            <input name="fornecedor" type="text" id="fornecedor"  value="" size="28" maxlength="80" readonly="true" class="inputReadOnly8pt">
                            <input name="localiza_clifor" type="button" class="inputBotaoMin" id="localiza_clifor" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=21&paramaux=1','Fornecedor')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:limparclifor();">
                        </strong>
                    </div>
                </td>
                <td>
                    <div align="center">
                        <select name="status" id="status" class="inputtexto">
                            <option value="t" selected>Todas as Despesas</option>
                            <option value="a">Apenas em Aberto</option>
                            <option value="q">Apenas Quitadas</option>
                            <option value="c">Apenas Canceladas</option>
                        </select>
                    </div>
                </td>
                <td>
                    <div align="center">
                        Ordena&ccedil;&atilde;o:
                        <select name="ordenacao" id="ordenacao" class="inputtexto">
                            <option value="idmovimento" selected>Movimento</option>
                            <option value="vd.nfiscal">Nota Fiscal</option>
                            <option value="vd.dtemissao" >Emiss&atilde;o</option>
                            <option value="vd.dtentrada">Entrada</option>
                            <option value="vd.fo_rzs">Fornecedor</option>
                        </select>
                    </div>
                </td>
            </tr>
            
        </table>
        <table width="98%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="2%">
                    <div align="center">
                        <input type="checkbox" id="ckConsultaTodos" name="ckConsultaTodos" value="ckConsultaTodos" onclick="javascript:marcaTodasDespesa();"/>
                    </div>
                </td>
                <td width="2%"><div align="center"></div></td>
                <td width="2%">
                    <div align="right">
                        <img src="img/pdf.jpg" width="19" height="19" border="0" class="imagemLink" title="Formato PDF(usado para mostrar todas impressões)" 
                             onclick="javascript:tryRequestToServer(function (){imprimirConsultaManifesto()});"/>
                    </div>
                </td>
                <td width="2%"><div align="center"></div></td>
                <td width="5%"><div align="center">Mov.</div></td>
                <td width="7%">Nº fiscal</td>
                <td width="10%"><div align="center">Emiss&atilde;o</div></td>
                <td width="10%"><div align="right">Valor</div></td>
                <td width="23%">Fornecedor</td>
                <td width="24%">Hist&oacute;rico</td>
                <td width="13%">Filial</td>
                <td width="2%">&nbsp;</td>
            </tr>
            <%
            int linha = 0;
            int linhatotal = 0;
            int qtde_pag = 0;

            if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                consDesp.setConexao(Apoio.getConnectionFromUser(request));
                consDesp.setOrdenacao(ordenacao);
                consDesp.setStatus(status);
                if(consDesp.getCampoDeConsulta().equals("vd.nfiscal")){
                    consDesp.setCampoDeConsulta(campoConsulta+"::bigint");                    
                }
                if (consDesp.Consultar()){
                    ResultSet r = consDesp.getResultado();
                    while (r.next()){%>
                        <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                            <td align="center">
                                <input type="checkbox" id="ckDespesa_<%=linha%>" name="ckDespesa_<%=linha%>" value="<%=r.getInt("idmovimento")%>"/>
                            </td>
                            <td>
                                <img src="img/plus.jpg" id="plus_<%=r.getString("idmovimento")%>" name="plus_<%=r.getString("idmovimento")%>" title="Mostrar duplicatas" class="imagemLink" align="right" 
                                     onclick="javascript:tryRequestToServer(function(){viewDups(<%=r.getString("idmovimento")%>);});">
                                <img src="img/minus.jpg" id="minus_<%=r.getString("idmovimento")%>" name="minus_<%=r.getString("idmovimento")%>" title="Mostrar duplicatas" class="imagemLink" align="right" style="display:none"
                                     onclick="javascript:tryRequestToServer(function(){viewDups(<%=r.getString("idmovimento")%>);});">							 
                            </td>
                            <td>
                                <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                                     onClick="javascript:tryRequestToServer(function(){popDespesa('<%=r.getString("idmovimento")%>');});">
                            </td>
                            <td>

                            <img src="img/jpg.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Imagens de documentos"

                              

                                onClick="javascript:tryRequestToServer(function(){popImg('<%=r.getString("idmovimento")%>');});">

                        </td>
                            <td>

                                <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("idmovimento")%>,<%=r.getBoolean("podeexcluir")%>);});">
                                    <%=r.getInt("idmovimento")%>
                                </div>
                            </td>
                            <td><%=r.getString("nfiscal")%></td>
                            <td><div align="center"><%=fmt.format(r.getDate("dtemissao"))%></div></td>
                            <td><div align="right"><%=r.getString("valor")%></div></td>
                            <td><%=r.getString("fo_rzs")%></td>
                            <td><%=r.getString("deschistorico")%></td>
                            <td><%=r.getString("fi_abrev")%></td>
                            <td>
                <%               if(nivelUser == 4 && r.getBoolean("podeexcluir") && !r.getBoolean("is_comissao") &&
                                !(!r.getString("fi_abrev").equals(usu.getFilial().getAbreviatura()) && nivelUserToFilial < 4) && !r.getBoolean("is_parcela_cancelada")) {
                %>                      <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                                            onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("idmovimento")%>);});">    
                <%               }
            %>               </td>
                        </tr>
                        <tr style="display:none" id="mov_<%=r.getString("idmovimento")%>">
                            <td rowspan="1" class='CelulaZebra1'></td>
                            <td rowspan="1" colspan="11">--</td>
                        </tr>
            <%           if (r.isLast()) 
                            linhatotal = r.getInt("qtde_linhas");
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
                        Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
                    </center>
                </td>
                <td width="15%" align="center">P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : consDesp.getPaginaResultados())%> / <%=qtde_pag %></b></td>
                    <td width="7%" align="right">
                <%if (consDesp.getPaginaResultados() >= qtde_pag){%>
                        <input name="voltar" type="button" class="botoes" id="voltar"
                            value="Anterior "  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
                <%}%>
                <%if (consDesp.getPaginaResultados() < qtde_pag){%>
                        <input name="avancar" type="button" class="botoes" id="avancar"
                            value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
                        <br>
                <%if (consDesp.getPaginaResultados() != 1){%>
                        <input name="voltar" type="button" class="botoes" id="voltar"
                            value="Anterior "  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
                    </td>
                <%}%>
                <%}%>
                <td colspan="5" align="right">
                    Modelo de impress&atilde;o em PDF:
                    <select name="cbmodelo" id="cbmodelo" class="inputtexto">
                        <option value="1" selected>Autoriza&ccedil;&atilde;o de Pagamento (Modelo 1)</option>
                        <option value="rec1">Recibo Avulso</option>
                        <option value="2">Recibo de Pagamento a Aut&ocirc;nomo - RPA</option>
                        <%for (ModeloRelatorio rel : ModeloRelatorio.stringToModelo(Apoio.listDespesa(request))) {%>
                            <option value="doc_despesa_personalizado_<%=rel.getPrefixo()%>"><%=rel.getDescricao()%></option>
                        <%}%>
                    </select>
                </td>
            </tr>
        </table>
   </body>
</html>