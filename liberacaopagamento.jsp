<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  despesa.duplicata.*,
                  java.text.*,
                  java.util.Date,
                  java.util.Hashtable,
                  java.util.Enumeration,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jQuery/jquery.js" type="text/javascript"></script>


<% 
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("bxpagar") : 0);
   int nivelUserFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser<4))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  BeanConsultaDup conPagar = null;
  BeanAlteraDup libPag = null;
  if (!acao.equals("iniciar")){
      conPagar = new BeanConsultaDup();
      conPagar.setConexao( Apoio.getUsuario(request).getConexao() );
      libPag = new BeanAlteraDup();
      libPag.setConexao( Apoio.getUsuario(request).getConexao() );
      libPag.setExecutor(Apoio.getUsuario(request));
  }
  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("consultar"))
  {
    conPagar.setDataVenc1(request.getParameter("dtinicial"));
    conPagar.setDataVenc2(request.getParameter("dtfinal"));
    conPagar.setValorDaConsulta(request.getParameter("idfornecedor"));
    conPagar.setFilial(request.getParameter("idfilial"));
    conPagar.setNfiscal(request.getParameter("nf"));
    conPagar.setCampoDeConsulta(request.getParameter("campoConsulta"));
    conPagar.setSituacaoLiberacao(request.getParameter("situacaoLiberacao"));
    conPagar.setOrdenacao(request.getParameter("campoOrdenacao"));
    conPagar.setCheckmostrarDespContratoFrete(Apoio.parseBoolean(request.getParameter("checkDespesas")));
    conPagar.setMostrarDespContratoFrete(request.getParameter("campoMostrarDespesaContrato"));
  }
  else if (acao.equals("salvar")){
    //Preenchendo o array dos mov_banco
    String valor = request.getParameter("dados");
    int qtdMovs = valor.split(";").length;
    BeanDuplDespesa[] arrayDup = new BeanDuplDespesa[qtdMovs];
    for (int k = 0; k < qtdMovs; ++k){
      BeanDuplDespesa dup = new BeanDuplDespesa();
      dup.setIdmovimento(Integer.parseInt(valor.split(";")[k].split("_")[0]));
      dup.setDuplicata(Integer.parseInt(valor.split(";")[k].split("_")[1]));
      if (Boolean.parseBoolean(valor.split(";")[k].split("_")[4]))
        dup.getUsuarioLib().setIdusuario((valor.split(";")[k].split("_")[2].equals("null") ? Apoio.getUsuario(request).getIdusuario() : Integer.parseInt(valor.split(";")[k].split("_")[2])));
      dup.setObsLiberacao(valor.split(";")[k].split("_")[3]);
      arrayDup[k] = dup;
    }
    libPag.setArrayBDupls(arrayDup);

    boolean erroSalvar = libPag.Atualiza(1);
    //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
    if(erroSalvar) {
      response.getWriter().append("err<=>"+libPag.getErros());
    }else{
      response.getWriter().append("err<=>");
    }
    response.getWriter().close();
  }
  
  boolean carregaConPagar = (conPagar != null && (!acao.equals("consultar")));
%>


<script language="javascript" type="text/javascript">
   jQuery.noConflict();
  var linha = 0;
    
  function calularTotal(){
        var valor = 0;
        for(var i = 0 ;i <= linha; i++){
            if($("valor_"+i)!= null && $("chk_"+i).checked){
                valor += parseFloat(virgulaToPonto($("valor_"+i).innerHTML));
            }
        }
        $("divTot").innerHTML = formatoMoeda(valor);
    } 

  function habilitaSalvar(opcao){
     getObj("salvar").disabled = !opcao;
     getObj("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }

  function salvar(linhas)
  {          
 
    var id;
    var resultado = "";
    for (i = 0; i <= linhas - 1; ++i){
      id = getObj("chk_"+i).value
      //Começando a concatenação
      if (resultado != "")
        resultado += ";";

      resultado += id + "_" + getObj("obs_"+i).value + "_" + getObj("chk_"+i).checked;
    }
    habilitaSalvar(false);
    
  
            
        jQuery.ajax({
            url: './liberacaopagamento',
            async: false,
            dataType: 'text',
            type: 'post',
            data: {
                'acao': 'salvar',
                'dados': resultado
            },
            complete: function (jqXHR, textStatus) {
                habilitaSalvar(true);
                if (jqXHR.status==200 && jqXHR.responseText=="err<=>")
                  location.replace("./liberacaopagamento?acao=consultar&"+concatFieldValue("dtinicial,dtfinal,idfornecedor,fornecedor,idfilial,fi_abreviatura,nf,campoConsulta,situacaoLiberacao,campoOrdenacao"));
                else
                  alert(jqXHR.responseText.split("<=>")[1]);
            }});
  }

  function visualizar(){

    if (! validaData(getObj("dtinicial").value) || (! validaData(getObj("dtfinal").value))){
      alert ("Informe o intervalo de datas corretamente.");
  }else{
        location.replace("./liberacaopagamento?acao=consultar&"+concatFieldValue("dtinicial,dtfinal,idfornecedor,fornecedor,idfilial,fi_abreviatura,nf,campoConsulta,situacaoLiberacao,campoOrdenacao,campoMostrarDespesaContrato") + "&checkDespesas=" + $("checkDespesas").checked)
      }
  }

  function verDesp(id){
    window.open("./caddespesa?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes");
  }

   function popImg(id, index){
       window.open('./ImagemControlador?acao=carregar&idDespesa='+id + '&index=' + (index ? index : 0),'imagensDespesa','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
   }

   function atualizarQtdAnexos(index, qtd_anexos) {
       document.getElementById('qtd-anexos-'+index).innerHTML = qtd_anexos;
   }
  
  
  function setDefault(){
        $("campoConsulta").value = '<%= request.getParameter("campoConsulta")%>' ;
        $("situacaoLiberacao").value = '<%= request.getParameter("situacaoLiberacao")%>' ;
        
        if($("campoConsulta").value.length == 0){
            $("campoConsulta").value = "dtemissao";
        }
        
        if($("situacaoLiberacao").value.length == 0){
            $("situacaoLiberacao").value = "";
        }
        
        $('checkDespesas').checked = <%=(request.getParameter("checkDespesas"))%>;
        if ('${param['campoMostrarDespesaContrato']}' !== '') {
            $('campoMostrarDespesaContrato').value = '${param['campoMostrarDespesaContrato']}';
        }
      
      
  }
          function marcaTodos(){
        var i = 0;

        while($("chk_" +i) != null){
            if ($("chk_"+i).disabled == false){
                $("chk_" +i).checked = $("chkTodos").checked;
               // getTotalDup(i, false,$("situacao_"+i).value);
            }
            i++;
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

<title>Webtrans - Liberação de pagamentos</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onload="setDefault();">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idfornecedor" id="idfornecedor" value="<%=(request.getParameter("idfornecedor") != null?request.getParameter("idfornecedor"):"0")%>">
  <input type="hidden" name="idfilial" id="idfilial" value="<%=(nivelUserFilial>=2?(request.getParameter("idfilial") != null?request.getParameter("idfilial"):"0"):Apoio.getUsuario(request).getFilial().getIdfilial())%>">
</div>
<table width="70%" height="28" align="center" class="bordaFina" >
  <tr> 
    <td height="22"><b>Libera&ccedil;&atilde;o de pagamentos</b></td>
    <% if (nivelUser >= 3){%>
    <%}%>
  </tr>
</table>

<br>

<table width="95%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td colspan="6"><div align="center">Filtros </div>
      <div align="center"></div></td>
  </tr>
  <tr> 
     <td align="right" width="20%" class="TextoCampos">
         <select class="inputtexto"  name="campoConsulta" id="campoConsulta">
           <option value="dtemissao">Emissão</option>
           <option value="dtlancamento">Entrada</option>
           <option value="dtvenc">Vencimento</option>
         </select>
     </td>
    <td width="22%" class="Celulazebra2"><strong> 
      <input name="dtinicial" type="text" id="dtinicial" class="fieldDate" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null?request.getParameter("dtinicial"):Apoio.getDataAtual())%>" size="9" maxlength="10"
	  		 onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
      </strong>e<strong> 
      <input name="dtfinal" type="text" id="dtfinal" class="fieldDate" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null?request.getParameter("dtfinal"):Apoio.getDataAtual())%>" size="9" maxlength="10"
	  		 onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
      </strong></td>
    <td width="20%" class="TextoCampos">Apenas o fornecedor:</td>
    <td width="40%" class="TextoCampos" colspan="3"> <div align="left"><strong> 
        <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" value="<%=(request.getParameter("fornecedor") != null?request.getParameter("fornecedor"):"")%>" size="35">
        <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=21','Fornecedor')" value="...">
        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('idfornecedor').value='0';javascript:getObj('fornecedor').value='';"> 
        </strong></div></td>
  </tr>
  <tr> 
    <td class="TextoCampos">Apenas a NF:</td>
    <td class="Celulazebra2"><strong>
      <input name="nf" type="text" id="nf" class="fieldMin" value="<%=(request.getParameter("nf") != null?request.getParameter("nf"):"")%>" size="9" maxlength="10">
      </strong></td>
    <td class="TextoCampos">Apenas a filial:</td>
    <td class="Celulazebra2"><strong> 
      <input name="fi_abreviatura" type="text" class="inputReadOnly" id="fi_abreviatura" value="<%=(nivelUserFilial>=2?(request.getParameter("fi_abreviatura") != null?request.getParameter("fi_abreviatura"):""):Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="20">
      <%if(nivelUserFilial>=2){%>
        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=8','Filial')" value="...">
        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('idfilial').value='0';javascript:getObj('fi_abreviatura').value='';"> 
      <%}%>  
      </strong></td>
      <td align="right" class="TextoCampos">Apenas:</td>
      <td class="celulaZebra2">
          <select class="inputtexto"  name="situacaoLiberacao" id="situacaoLiberacao">
              <option value="">Ambos</option>
              <option value="true">Liberados</option>
              <option value="false">Não Liberados</option>
          </select>
      </td>
  </tr>
  <tr>
                  <td width="10%" align="right" class="TextoCampos">Ordena&ccedil;&atilde;o:</td>
                  <td width="20%" class="celulaZebra2">
                        <select name="campoOrdenacao" class="inputtexto" id="campoOrdenacao" >
                            <option value="idmovimento" selected>Movimento</option>
                            <option value="nfiscal">Nota fiscal</option>
                            <option value="dtemissao">Data emiss&atilde;o</option>
                            <option value="dtvenc">Data Vencimento</option>
                            <option value="dtentrada">Data Entrada</option>
                            <option value="razaosocial">Fornecedor</option>
                        </select>
                  </td>
                  <td width="20%" class="TextoCampos"> 
                      <input type="checkbox" name="checkDespesas" id="checkDespesas"/>
                  </td>
                  <td width="40%" class="celulaZebra2" colspan="3">
                      <select name="campoMostrarDespesaContrato" id="campoMostrarDespesaContrato" class="inputtexto">
                          <option value="mostrarDespesasContrato" selected>Mostrar apenas as despesas de contrato de frete (Adiantamento e Saldo)</option>
                          <option value="naoMostrarDespesasContrato">Não mostrar despesas de contrato de frete (Adiantamento e Saldo)</option>
                      </select>
                  </td>
  </tr>
  <tr> 
    <td colspan="6" class="TextoCampos"> <div align="center"> 
        <% if (nivelUser >= 1){%>
        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
        <%}%>
      </div></td>
  </tr>
</table>
<table width="95%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
     <td width="2%">
         <input type="checkbox" name="chkTodos" id="chkTodos" onClick="javascript:marcaTodos();calularTotal();">
     </td>
    <td width="2%"></td>  
    <td width="5%"><div align="center"><strong>Mov.</strong></div></td>
    <td width="5%"><strong>N. Fisc.</strong></td>
    <td width="16%">Fornecedor</td>
    <td width="6%"><strong>Emissão</strong></td>
    <td width="16%"><strong>Histórico</strong></td>
    <td width="2%"><div align="center"><strong>PC</strong></div></td>
    <td width="6%"><div align="right"><strong>Valor</strong></div></td>
    <td width="6%"><strong>Vencim.</strong></td>
    <td width="18%"><strong>Plano de Custo</strong></td>
    <td width="8%"><strong>Lib. Por</strong></td>
    <td width="13%"><strong>OBS</strong></td>
  </tr>
  <% //variaveis da paginacao
      int linha = 0;
      // se conseguiu consultar
      if ( (acao.equals("consultar")) && (conPagar.Consultar()) )
      {
          ResultSet rs = conPagar.getResultado();
	  while (rs.next())
          {
            //pega o resto da divisao e testa se é par ou impar
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" > 
              <td> <div class="linkEditar" onClick="" align="center"> 
                      <input name="chk_<%=linha%>" id="chk_<%=linha%>" onclick="calularTotal();" type="checkbox" <%=(rs.getBoolean("pagtolib")?"checked":"")%> value="<%=rs.getString("idmovimento")+"_"+rs.getString("duplicata")+"_"+rs.getString("idusuariolib")%>">
              </div></td>
              <td align="center">
                  <img src="img/jpg.png" width="25" height="25" border="0" align="right" class="imagemLink" title="Imagens de documentos"
                       onClick="javascript:tryRequestToServer(function(){popImg('<%=rs.getString("idmovimento")%>', '<%=linha%>')});"
                       style="float: unset;">
                  <c:set var="qtd_anexos" value='<%= rs.getInt("qtd_anexos") %>'></c:set>
                  <span id="qtd-anexos-<%=linha%>">${qtd_anexos}</span>
              </td>  
              <td><div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){verDesp('<%=rs.getString("idmovimento")%>');});">
                <font size="1"><%=rs.getString("idmovimento")%></font>
              </div></td>
              <td><font size="1"><%=rs.getString("nfiscal")%></font></td>
              <td><font size="1"><%=rs.getString("razaosocial")%></font></td>
              <td><font size="1"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtemissao"))%></font></td>
              <td><font size="1"><%=rs.getString("deschistorico")%></font></td>
              <td><font size="1"><div align="center"><%=rs.getString("duplicata")%></div></font></td>
              <td><font size="1"><div id="valor_<%=linha%>" align="right"><%=new DecimalFormat("0.00").format(rs.getFloat("vlduplicata"))%></div></font></td>
              <td><font size="1"><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtvenc"))%></font></td>
              <td><font size="1"><%=(rs.getString("plano_custo")!=null?rs.getString("plano_custo"):"")%></font></td>
              <td><font size="1"><%=(rs.getString("login")!=null?rs.getString("login"):"")%></font></td>
              <td><font size="1">
                 <input name="obs_<%=linha%>" id="obs_<%=linha%>" type="text" value="<%=rs.getString("obsliberacao")%>" maxlength="100" class="inputtexto">
              </font></td>
            </tr>
            <script>++linha</script>
          <%linha++;
          }
      }%>
      <tr class="tabela"> 
          <td colspan="7"><div align="right">Total:&nbsp;</div></td>
          <td colspan="1"><div id="divTot" align="right">0</div></td>
          <td colspan="5"></td>
      </tr>
</table>
<table width="95%" border="0" class="bordaFina" align="center">
  <tr> 
    <td width="100%" class="TextoCampos"> <div align="center"> 
        <% if (nivelUser >= 2){%>
        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar(<%=linha%>);});">
        <%}%>
      </div></td>
  </tr>
</table>
</body>
</html>
