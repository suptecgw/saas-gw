<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
                 nucleo.BeanLocaliza,
                 conhecimento.manifesto.BeanConsultaManifesto,
                 java.util.Date,
                 java.text.SimpleDateFormat,
                 nucleo.Apoio" %>

<%  //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaColeta conColeta = null;
    String acao = request.getParameter("acao");

    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null)
      response.sendError(response.SC_FORBIDDEN,"É preciso estar logado no sistema para ter acesso a esta página.");  

    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA
    
    //Instanciando o bean pra trazer os CTRC's
    conColeta = new BeanConsultaColeta();
    conColeta.setConexao( Apoio.getUsuario(request).getConexao() );
%>

<script language="javascript" type="" >

  function fechar(){
     window.close();
  }

  function seleciona(qtdlinha){
    var retorno = "";
    var cobs = "";
    for (i = 0; i <= qtdlinha - 1; ++i){
      if ($("chk_"+i).checked){
        if (retorno == ""){
          retorno += $("chk_"+i).value
          cobs += $("ped_"+i).innerHTML
        }else{
          retorno += ","+$("chk_"+i).value
          cobs += ","+$("ped_"+i).innerHTML
        }
      }
    }

    if (window.opener.addColetaCobranca != null)
       window.opener.addColetaCobranca(retorno, cobs);
       
    fechar();   
  }

  function coletaSelecionado(id){
    var sels = '<%=request.getParameter("coletas")%>';
    for(x=0; x < sels.split(',').length; x++){
       if (sels.split(',')[x] == id)
          return true;
    }
    return false;  
  }

  function marcaTodos(){
    var i = 0;
    while ($("chk_"+i) != null){
       $("chk_"+i).checked = $("chkTodos").checked;
       i++;
    }
  }

</Script>

<%@page import="conhecimento.BeanConsultaConhecimento"%>
<%@page import="conhecimento.coleta.BeanConsultaColeta"%>
<html>
<head>
<script language="javascript" src="../script/funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt-br" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Selecionar Coletas/OS</title>
<link href="../estilo.css" rel="stylesheet" type="text/css">
</head>

<body>

<br>
<table width="90%" align="center" class="bordaFina" >
  <tr>
    <td width="619"><div align="left"><b>Selecionar Coletas/OS</b></div></td>
    <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
  </tr>
</table>
<br>
<table width="90%" align="center" cellspacing="1" class="bordaFina">
  <tr> 
    <td width="2%" class="tabela"><input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcaTodos();"></td>
    <td width="9%" class="tabela">Número</td>
    <td width="14%" class="tabela">Categoria</td>
    <td width="9%" class="tabela">Data</td>
    <td width="14%" class="tabela">Contato</td>
    <td width="12%" class="tabela">Nº pedido</td>
    <td width="40%" class="tabela">Destinatário</td>
  </tr>
  <% //variaveis da paginacao
      int linha = 0;

      // se conseguiu consultar
      if (conColeta.localizarColetaCobranca(Integer.parseInt(request.getParameter("idcliente")), request.getParameter("coletas"))){
         ResultSet rs = conColeta.getResultado();
	     while (rs.next()){
%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
            <td>
               <input name="<%="chk_" + linha %>" type="checkbox" id="<%="chk_" + linha %>" value="<%=rs.getString("id")%>">
               <Script>$('chk_'+<%=linha%>).checked = coletaSelecionado(<%=rs.getString("id")%>);</Script> 
            </td>
<%
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
%>
            <td><label name="<%="ped_" + linha %>" id="<%="ped_" + linha %>"><%=rs.getString("numero")%></label></td>
            <td><%=rs.getString("categoria")%></td>
            <td><%=formato.format(rs.getDate("solicitada_em"))%></td>
            <td><%=rs.getString("contato")%></td>
            <td><%=rs.getString("pedido_cliente")%></td>
            <td><%=rs.getString("cliente_destino")%></td>
            </tr>
<%          linha++;
        }
     } 
%>
  <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
    <td colspan="11"><div align="center">
        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
      </div></td>
  </tr>
</table>

</body>
</html>
