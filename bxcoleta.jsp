 <%@ page contentType="text/html; charset=iso-8859-1" language="java"
	import="java.sql.ResultSet,
           conhecimento.coleta.*,
           java.text.*,
           nucleo.*"
%>
<% 
   int nivelUser = (Apoio.getUsuario(request) != null ?
                     Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser==0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);


  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  BeanConsultaColeta coletas = null;
  BeanCadColeta altCols = null;

  BeanConfiguracao cfg = new BeanConfiguracao();

  if (!acao.equals("iniciar")) {
      coletas = new BeanConsultaColeta();
      coletas.setConexao( Apoio.getUsuario(request).getConexao() );
      
      altCols = new BeanCadColeta();
      altCols.setConexao(Apoio.getUsuario(request).getConexao() );
      altCols.setExecutor(Apoio.getUsuario(request));
  }
    
  if (acao.equals("consultar")){
        cfg.setConexao(Apoio.getUsuario(request).getConexao());
        cfg.CarregaConfig();
  	coletas.setValorDaConsulta(request.getParameter("idmotorista"));
  }else if (acao.equals("baixar")){
    
    boolean erroBaixar = !altCols.baixar(request);
String scr = "";
    if(erroBaixar) {
        scr += "<script>";
                            scr += "alert('" + altCols.getErros() + "');";
                            scr += "window.close();"
                                    + "window.opener.document.getElementById('salva').disabled = false;"
                                    + "window.opener.document.getElementById('salva').value = 'Salvar';"
                                    + "</script>";
      
    }else{
      response.getWriter().append("<script>"
              + "window.opener.document.location.replace(window.opener.document.location);"
              + "window.close();</script>");
    }
    response.getWriter().append(scr);
    response.getWriter().close();
  }
  
%>

<script language="JavaScript" type="text/javascript">
  function habilitaSalvar(opcao){
     getObj("baixar").disabled = !opcao;
     getObj("baixar").value = (opcao ? "Baixar" : "Enviando...");
  }

  function valorAjudante(id,lin){
    if (getObj("chk_"+lin).checked){ 
      getObj("vldiariaajud").value = parseFloat(getObj("vldiariaajud").value) + parseFloat(getObj("aj_"+id).value);
    }else{
      getObj("vldiariaajud").value = parseFloat(getObj("vldiariaajud").value) - parseFloat(getObj("aj_"+id).value);
    }  
  }

  function baixar(linhas)
  {          
    var ids;
    var deuCerto = true;
    var resultado = "";
    if (! validaData(getObj("dtcoleta").value))
        deuCerto = false;
    else if(parseFloat(getObj("vldiaria").value) == 0){
       		if (!confirm("Valor da diária está 0.00, deseja continuar?"))
          		return null;
    }    

    
    var idsColeta = "";
	var i = 1;
	var notes = "";
	while (getObj("chk_" + (i - 1)) != null)
	{
		var checkBox = getObj("chk_" + (i - 1));
		if (checkBox.checked)
	   	{
	   		idCole = checkBox.value;
	   		idsColeta += (idsColeta == "" ? "" : ",") + checkBox.value;
			
	   		
		    if (countNotes(idCole) == 0){
//    			return null;
                    }else{
    			notes += (notes == ""? "" : "&")+getNotes( checkBox.value );	
                    }
	   	}
	   	
	   	++i;
	}//while
	
    
    if (!deuCerto)
      alert('Informe todos os dados da baixa corretamente');
    else if(idsColeta == "")  
      alert('Escolha no mínimo uma coleta');
    else{
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formBx").action="./bxcoleta?acao=baixar&ids=" + idsColeta;
        $("formBx").submit();
        //requisitaPost(notes, "./bxcoleta?acao=baixar&ids=" + idsColeta+"&" + concatFieldValue("vldiaria,vldiariaajud,dtcoleta,hrcoleta"));
    }
  }

  function aoClicarNoLocaliza(idjanela){
        if (idjanela == "marca"){
            $('inIdMarcaVeiculo').value = $('idmarca').value;
            $('inMarcaVeiculo').value = $('descricao').value;
        }else if (idjanela == "Cfop_Nota_fiscal"){
            $('inCfopId').value = $('idcfop').value;
            $('inCfop').value = $('cfop').value;
        }else if (idjanela.split("__")[0] == "Cfop_Nota_fiscal_nfe"){
            var idxCfopNfe = idjanela.split("__")[1];
            $('nf_cfop'+idxCfopNfe).value = $('cfop').value;
            $('nf_cfopId'+idxCfopNfe).value = $('idcfop').value;
        }else if(idjanela.split("__")[0] == "Produto_ctrcs_nf"){
            var idxProdNF = idjanela.split("__")[1];       
            $('nf_conteudo'+idxProdNF).value = $('desc_prod').value;
        }//localizando planocusto
    }
  
  function visualizar()
  {
    var filtros = "";
    if (getObj("idmotorista").value == "0")
      alert ("Informe o motorista corretamente.");
    else  
      filtros = concatFieldValue("idmotorista,motor_nome");

    //Apenas se os filtros estiverem corretos
    if (filtros.trim()!=''){
      location.replace("./bxcoleta?acao=consultar&"+filtros);
    }
  }

  function verColeta(id){
    window.open("./cadcoleta?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes");
  }

  function localizamotorista(){
      post_cad = window.open('./localiza?acao=consultar&idlista=10','Motorista',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function voltar(){
      document.location.replace('ConsultaControlador?codTela=24');
  }

  function checado(tabelaOculta,chk){
      if (chk.checked){
          $(tabelaOculta).style.display= "";
      }else{
          $(tabelaOculta).style.display= "none";
      }
  }

</script>

<html>
<head>
<script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/notaFiscal-util.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>Webtrans - Baixa de coletas</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter(document, $('dtcoleta'))">
   <div align="center">
       <img src="img/banner.gif" alt="banner"><br>
       <input type="hidden" name="idmotorista" id="idmotorista"
	      value="<%=(request.getParameter("idmotorista") != null?request.getParameter("idmotorista"):"0")%>">
       <input name="idmarca" id="idmarca" type="hidden" value="0">
       <input name="descricao" id="descricao" type="hidden" value="">
       <input name="idcfop" id="idcfop" type="hidden" value="0">
       <input name="cfop" id="cfop" type="hidden" value="">
       <input name="desc_prod" id="desc_prod" type="hidden" value="">
   </div>
   <table width="70%" height="28" align="center" class="bordaFina">
	<tr>
	    <td width="86%" height="22">
                <b>Baixa de coletas </b>
            </td>
	    <td width="14%">
                <b> 
                    <input name="Button" type="button" class="botoes" value="Voltar para Consulta" onClick="voltar()"> 
                </b>
            </td>
	</tr>
   </table>
   <br>

   <table width="100%" border="0" class="bordaFina" align="center">
	<tr class="tabela">
	    <td height="18" colspan="3">
		<div align="center">Filtros</div>
		<div align="center"></div>
	    </td>
	</tr>
	<tr>
	    <td width="172" height="22" class="TextoCampos">Informe o motorista:</td>
	    <td width="291" colspan="-1" class="TextoCampos">
		<div align="left">
                    <strong> 
		        <input name="motor_nome" type="text" id="motor_nome" style="font-size:8pt;" class="inputReadOnly"
			       value="<%=(request.getParameter("motor_nome") != null?request.getParameter("motor_nome"):"")%>"
			       size="30" maxlength="80" readonly="true">
                        <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..."
			       onClick="javascript:localizamotorista();"> 
                    </strong>
                </div>
	    </td>
	    <td width="292" class="TextoCampos">
		<% if (nivelUser >= 1){%>
		     <div align="center">
                         <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar"
			        onclick="javascript:tryRequestToServer(function(){visualizar();});">
		         <%}%>
		     </div>
	    </td>
	</tr>
   </table>

   <form method="post" id="formBx" target="pop">
       <table width="100%" border="0" class="bordaFina">
	  <tr class="tabela">
	      <td width="2%">&nbsp;</td>
	      <td width="6%"><strong>Coleta</strong></td>
	      <td width="12%"><strong>Filial</strong></td>
	      <td width="10%"><strong>Data</strong></td>
	      <td width="35%"><strong>Cliente/Remetente</strong></td>
	      <td width="35%"><strong>Cliente/Destinatario</strong></td>
	  </tr>
	  <% //variaveis da paginacao
          int linha = 0;
      
          // se conseguiu consultar
          if ( (acao.equals("consultar")) && (coletas.consultaBx()) ){
             //Apenas as duplicatadas agora
             ResultSet rs = coletas.getResultado();
	     
             while (rs.next()){
             //pega o resto da divisao e testa se é par ou impar
             %>
             
	        <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>">
		     <td>
		         <div class="linkEditar" onClick="">
		              <input name="chk_<%=linha%>" id="chk_<%=linha%>" type="checkbox" value="<%=rs.getString("idcoleta")%>"
			             onClick="javascript:valorAjudante(<%=rs.getString("idcoleta")%>,<%=linha%>);checado('tableNotes<%=rs.getString("idcoleta")%>',this); ">
		         </div>
		     </td>
		     <td>
		         <div class="linkEditar" onclick="javascript:tryRequestToServer(function(){verColeta('<%=rs.getString("idcoleta")%>');});">
		              <font size="1"><%=rs.getString("numcoleta")%></font>
                         </div>
		     </td>
  		     <td>
                         <font size="1"><%=rs.getString("abreviatura")%></font>
                     </td>
		     <td>
                         <font size="1"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtsolicitacao"))%></font>
                     </td>
		     <td>
                         <font size="1"><%=rs.getString("razaosocial")%></font>
                         <input type="hidden" name="idremetente_1_id<%=rs.getString("idcoleta")%>" id="idremetente_1_id<%=rs.getString("idcoleta")%>" value="<%=(rs.getString("idremetente") != null ? rs.getString("idremetente") : 0)%>">
                     </td>
		     <td>
                         <font size="1"><%=(rs.getString("rzs_dest")!=null?rs.getString("rzs_dest"):"")%></font>
		         <input type="hidden" name="aj_<%=rs.getString("idcoleta")%>" id="aj_<%=rs.getString("idcoleta")%>"
			        value="<%=(rs.getString("vlajudante") != null?rs.getFloat("vlajudante"):0)%>">
		     </td>
	       </tr>

	       <!-- tabela de notas -->
	       <tr>
		    <td colspan="6">
                         <table width="100%" cellpadding="1" cellspacing="2" style="display: none; " id="tableNotes<%=rs.getString("idcoleta")%>" name="tableNotes<%=rs.getString("idcoleta")%>">
			        <tr class="colorClear">
				     <td>
                                          <img src="img/add.gif" border="0" onClick="addNewNote('<%=rs.getString("idcoleta")%>', 'tableNotes<%=rs.getString("idcoleta")%>', 'false', '<%=cfg.isBaixaEntregaNota()%>');"
					       title="Adicionar uma nova Nota fiscal" class="imagemLink">
                                     </td>
                                     <td colspan="2"></td>
				     <td>N&uacute;mero</td>
				     <td>S&eacute;rie</td>
				     <td>Emiss&atilde;o</td>
				     <td>Valor</td>
				     <td>Peso</td>
				     <td>Volume</td>
				     <td>Embalagem</td>
				     <td>Conte&uacute;do</td>
				     <td>Base Icms</td>
				     <td>Vl. Icms</td>
				     <td>Icms Subst.Trib.</td>
				</tr>
		        </table>
		  </td>
	     </tr>
	    <%       
              linha++;
             }
         }
     %>
   </table>

   <table width="100%" border="0" class="bordaFina" align="center">
	<tr>
	    <td width="27%" class="TextoCampos">Valor da di&aacute;ria do motorista:</td>
	    <td width="8%" class="Celulazebra2">
                <input name="vldiaria" id="vldiaria" value="0.00" type="text" size="7" class="fieldMin" maxlength="12"
		       onBlur="javascript:seNaoFloatReset(this,'0.00');">
            </td>
	    <td width="19%" class="TextoCampos">Valor da di&aacute;ria do ajudante:</td>
	    <td width="8%" class="Celulazebra2">
                <input name="vldiariaajud" id="vldiariaajud" value="0.00" type="text" size="7" class="fieldMin" maxlength="12"
		       onBlur="javascript:seNaoFloatReset(this,'0.00');">
            </td>
	    <td width="18%" class="TextoCampos">Data da coleta:</td>
	    <td width="20%" class="Celulazebra2">
                <input name="dtcoleta" id="dtcoleta" value="<%=Apoio.getDataAtual()%>" type="text" size="10"
		       style="font-size:8pt;" maxlength="10" class="fieldDate" onBlur="alertInvalidDate(this)" > 
		&agrave;s 
	        <input name="hrcoleta" id="hrcoleta" value="" type="text" size="5" class="fieldMin" maxlength="5" onBlur="" >
            </td>
	</tr>
	<tr>
            <td colspan="6" class="TextoCampos">
		<div align="center">
	   	    <% if (nivelUser >= 2){%> 
		          <input name="salva" type="button" class="botoes" id="salva" value="Baixar"
			         onclick="javascript:tryRequestToServer(function(){baixar(<%=linha%>);});">
		   <%}%>
		</div>
	   </td>
        </tr>
     </table>
    <br>
  </form>
</body>
</html>