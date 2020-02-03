<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
                 nucleo.BeanLocaliza,
                 conhecimento.manifesto.BeanConsultaManifesto,
                 java.util.Date,
                 java.text.SimpleDateFormat,
                 nucleo.Apoio" %>

<%  //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaConhecimento conCtrc = null;
    String acao = request.getParameter("acao");

    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null)
      response.sendError(response.SC_FORBIDDEN,"É preciso estar logado no sistema para ter acesso a esta página.");  

    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA
    
    //Instanciando o bean pra trazer os CTRC's
    conCtrc = new BeanConsultaConhecimento();
    conCtrc.setConexao( Apoio.getUsuario(request).getConexao() );
    
%>

<Script language="javascript" type="text/javascript" >

  function fechar(){
     window.close();
  }

  function checkCtrc(evento){
        if( evento.keyCode==13 ) {
            //for (var i = 0; i <= quant; ++i){
                if($("hidden_ctrc_"+$("selCtrc").value) != null){
                    $("chk-"+$("hidden_ctrc_"+$("selCtrc").value).value).checked = true;
                    $("selCtrc").value = "";
                        //break;
                }else{
                    alert("CTRC não encontrado.");
                }
            //}
        }
    }

  function seleciona(qtdlinha){
    var retorno = "";
    var ctrcs = "";
    var avaria = 0; 
    for (i = 0; i <= qtdlinha - 1; ++i){
      if ($("chk-"+i).checked){
        if (retorno == ""){
          retorno += $("chk-"+i).value;
          ctrcs += $("ctr-"+i).innerHTML;
        }else{
          retorno += ","+$("chk-"+i).value;
          ctrcs += $("ctr-"+i).innerHTML;
        }
        avaria += parseFloat($("vl-"+i).value);
      }
    }
    if (window.opener.calculaAvaria != null)
       window.opener.calculaAvaria(retorno, ctrcs, avaria);
       
    fechar();   
  }

</Script>

<%@page import="conhecimento.BeanConsultaConhecimento"%>
<html>
<head>
<script language="javascript" src="../script/funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt-br" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Consulta</title>
<link href="../estilo.css" rel="stylesheet" type="text/css">
</head>

<body>

<br>
<table width="90%" align="center" class="bordaFina" >
  <tr >
    <td width="619"><div align="left"><b>Selecionar Ctrcs para a fatura</b></div></td>
    <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
  </tr>
</table>
<br>
  
<table width="90%" align="center" cellspacing="1" class="bordaFina">
  <tr> 
    <td width="2%" class="tabela"></td>
    <td width="8%" class="tabela">Data</td>
    <td width="5%" class="tabela"><div align="center">Série</div></td>
    <td width="5%" class="tabela">CTRC</td>
    <td width="35%" class="tabela">Remetente</td>
    <td width="35%" class="tabela">Destinatário</td>
    <td width="10%" class="tabela">Avaria</td>
  </tr>
  <% //variaveis da paginacao
      int linha = 0;

      // se conseguiu consultar
      if (conCtrc.consultarCtrcAvaria(Integer.parseInt(request.getParameter("idconsignatario")))){
         ResultSet rs = conCtrc.getResultado();
	     while (rs.next()){
%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
            <td>
                <input name="<%="chk-" + linha %>" type="checkbox" id="<%="chk-" + linha %>" value="<%=rs.getString("id")%>"checked>
            </td>
<%
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
%>
            <td><%=formato.format(rs.getDate("emissao_em"))%></td>
            <td><div align="center" id="numeroDoc"><%=rs.getString("serie")%></div></td>
            <td><label name="<%="ctr-" + linha %>" id="<%="ctr-" + linha %>" value="<%=rs.getString("ctrc")%>"><%=rs.getString("ctrc")%></label></td>
            <td><%=rs.getString("remetente")%></td>
            <td><%=rs.getString("destinatario")%></td>
            <td>
                <input type="hidden" name="<%="vl-" + linha %>" id="<%="vl-" + linha %>" value="<%=rs.getFloat("valor_avaria")%>">
                <%=Apoio.to_curr(rs.getFloat("valor_avaria"))%></td>
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
