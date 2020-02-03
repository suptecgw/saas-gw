     <%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.text.*,
                  java.util.Date,
                  nucleo.*,
                  nucleo.etiqueta.*" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>

<%
/*
boolean temacesso = (Apoio.getUsuario(request) != null
                        && Apoio.getUsuario(request).getAcesso("chequecliente") > 0);
*/
boolean temacesso = true;

   if ((Apoio.getUsuario(request) == null) || (! temacesso))
       response.sendError(response.SC_FORBIDDEN);
   
  String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  BenCadEtiqueta cadEt = null;

  if (acao.equals("exportar"))
  {
      /* Rotina necessária para impressao de etiquetas */
      cadEt = new BenCadEtiqueta();
      cadEt.setConexao(Apoio.getUsuario(request).getConexao());
      cadEt.setExecutor(Apoio.getUsuario(request));

      cadEt.setInicioSequencia(Integer.parseInt(request.getParameter("inicioSequencia")));
      cadEt.setQtdLinhas(Integer.parseInt((request.getParameter("modelo").equals("1") ? "24" : "0")));
      cadEt.setQtdPaginas(Integer.parseInt(request.getParameter("qtdPaginas")));

      boolean erro = !cadEt.Inclui();

      if(erro){
          %>alert('<%=(cadEt.getErros())%>');<%
      }else{
        String modelo = request.getParameter("modelo");

        java.util.Map param = new java.util.HashMap(1);

        request.setAttribute("map", param);
        request.setAttribute("rel", "etiquetamod"+modelo);

        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispacher.forward(request, response);
    }    
  }
%>

<script language="javascript" type="text/javascript">
  function modelos(modelo){
    getObj("modelo1").checked = false;
    getObj("modelo"+modelo).checked = true;
  }

  function popRel(){
    var modelo; 
    if (getObj("qtdPaginas").value <= 0){
      alert ("Informe quantidade de páginas válido.");
      return false;
    } 
    if (getObj("modelo1").checked)
        modelo = '1';
    var impressao;
//      if ($("pdf").checked)
        impressao = "1";
/*      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";
*/
    launchPDF('./reletiqueta.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("qtdPaginas,inicioSequencia"));
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

<title>Webtrans - Impressão de etiquetas</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body >
<div align="center">
    <img src="img/banner.gif"  alt="banner">
    <br>
</div>
<table width="489" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Impressão de etiquetas</b></td>
  </tr>
</table>

<br>

<table width="489" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td colspan="2"><div align="center">Medidas</div></td>
  </tr>
  <tr> 
    <td width="28%" height="24" class="TextoCampos">
        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos('1');">
        </td>
    <td width="72%" class="CelulaZebra2">320 X 302 milímetros, 8 X 24 etiquetas por pagina. </td>
  </tr>
  <tr class="tabela"> 
    <td colspan="2"><div align="center">Crit&eacute;rios</div></td>
  </tr>
  <tr> 
    <td class="TextoCampos">Quantidade de páginas:</td>
    <td class="CelulaZebra2"> <strong>
      <input name="qtdPaginas" type="text" id="qtdPaginas" value="1" size="1" maxlength="10"
	  		 onBlur="javascript:seNaoIntReset(this,'1');" class="fieldDate" />
      </strong>
      </td>
  </tr>
  <tr>
    <td class="TextoCampos">Início da sequência:</td>
    <td class="CelulaZebra2"> <strong>
      <input name="inicioSequencia" type="text" id="inicioSequencia" value="0" size="1" maxlength="10"
	  		 onBlur="javascript:seNaoIntReset(this,'0');" class="fieldDate" />
        </strong><font color="red">('0' para continuar a sequencia da última impressão)</font>
      </td>
  </tr>
  <tr>
    <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
  </tr>
  <tr>
    <td colspan="3" class="TextoCampos">
        <div align="center">
        <input type="radio" name="impressao" id="pdf" value="1" checked/>
        <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">

        <!--
        <input type="radio" name="impressao" id="excel" value="2" />
        <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
        <input type="radio" name="impressao" id="word" value="3" />
        <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
        -->
        </div>
    </td>
  </tr>
  <tr> 
    <td colspan="3" class="TextoCampos"> <div align="center"> 
        <% if (temacesso){%>
        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onclick="javascript:tryRequestToServer(function(){popRel();});">
        <%}%>
      </div></td>
  </tr>
</table>
</body>
</html>
