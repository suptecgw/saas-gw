<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
                 nucleo.BeanLocaliza,
                 conhecimento.cartafrete.*,
                 java.util.Date,
                 java.text.SimpleDateFormat,
                 nucleo.Apoio" %>

<%  //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaCartaFrete selcarta = null;
    String acao = request.getParameter("acao");

    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null)
      response.sendError(response.SC_FORBIDDEN,"É preciso estar logado no sistema para ter acesso a esta página.");  

    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA
    
    //Instanciando o bean pra trazer os CTRC's
    selcarta = new BeanConsultaCartaFrete();
    selcarta.setConexao( Apoio.getUsuario(request).getConexao() );
    
    String marcados = request.getParameter("marcados");
    boolean mostraTudo = Boolean.parseBoolean(request.getParameter("mostratudo"));
    
%>

<script language="javascript" type="text/javascript" >

  function fechar(){
     window.close();
  }

  function seleciona(qtdlinha){
    var retorno = "";
	var deuCerto = true;
	var cavalo = 0;
	var motorista = 0;
    for (i = 0; i <= qtdlinha - 1; ++i){
      if (document.getElementById("chk-"+i).checked){
        if (retorno == ""){
          retorno += document.getElementById("chk-"+i).value;
		  cavalo = document.getElementById("idcav"+i).value;
		  motorista = document.getElementById("idmot"+i).value;
		}  
        else{  
          retorno += ","+document.getElementById("chk-"+i).value;
		  if (cavalo != document.getElementById("idcav"+i).value)
		    deuCerto = false;
		  if (motorista != document.getElementById("idmot"+i).value)
		    deuCerto = false;
		}  
      }
    }
    if (!deuCerto){
      alert('Para gerar a contrato de frete deverá ser selecionado manifestos do mesmo motorista e do mesmo veículo.');
	}  
    else if (retorno == ""){
      alert('Escolha no mínimo um documento');
	}  
	else if(window.opener.carrega != null){
	  window.opener.carrega(retorno,0,'<%=request.getParameter("acaoDoPai")%>');
          fechar();
	}      
  }

</Script>

<html>
<head>
<script language="javascript" src="funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt-br" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Consulta</title>
<link href="./estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style3 {font-size: 9px}
.style4 {	font-family: Arial, Helvetica, sans-serif;
	font-size: 13px;
}
-->
</style>
</head>

<body>

<br>
<table width="95%" align="center" class="bordaFina" >
  <tr >
    <td width="619"><div align="left"><b>Selecionar Manifestos para a contrato de frete</b></div></td>
    <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
  </tr>
</table>
<br>
  
<table width="100%" align="center" cellspacing="1" class="bordaFina">
  <tr> 
    <td colspan="9" class="tabela"></td>
  </tr>
  <tr> 
    <td width="2%" class="tabela"></td>
    <td width="7%" class="tabela">Data</td>
    <td width="27%" class="tabela">Manifesto</td>
    <td width="15%" class="tabela">Origem</td>
    <td width="15%" class="tabela">Destino</td>
    <td width="7%" class="tabela">Cavalo</td>
    <td width="7%" class="tabela">Carreta</td>
    <td width="20%" class="tabela">Motorista</td>
  </tr>
  <% //variaveis da paginacao
      int linha = 0;

      // se conseguiu consultar
      if (selcarta.SelectManifesto(request.getParameter("filial"),request.getParameter("marcados"),mostraTudo, false, "", Apoio.getConfiguracao(request)))
      {
        ResultSet rs = selcarta.getResultado();
	while (rs.next())
          {
          //pega o resto da divisao e testa se é par ou impar
          %>
          <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
          <td>
		  <%boolean encontrou = false;
          for (int i = 0; i <= marcados.split(",").length - 1; i++){
            if (marcados.split(",")[i].equals(rs.getString("idmanifesto"))){%>
              <input name="<%="chk-" + linha %>" type="checkbox" id="<%="chk-" + linha %>" value="<%=rs.getString("idmanifesto")%>"checked>
            <%encontrou = true;   
            }    
          }
          if (!encontrou){%>
            <input name="<%="chk-" + linha %>" type="checkbox" id="<%="chk-" + linha %>" value="<%=rs.getString("idmanifesto")%>">
      <%}
    SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
    %>
    </td>
    <td><%=formato.format(rs.getDate("dtsaida"))%></td>
    <td><%=rs.getString("nmanifesto")%></td>
    <td><%=rs.getString("origem")%></td>
    <td><input type="hidden" name="<%="idcav"+linha%>" id="<%="idcav"+linha%>" value="<%=rs.getInt("idcavalo")%>"><%=rs.getString("destino")%></td>
    <td><%=rs.getString("cavalo")%></td>
    <td><%=rs.getString("carreta")%></td>
    <td><input type="hidden" name="<%="idmot"+linha%>" id="<%="idmot"+linha%>" value="<%=rs.getInt("idmotorista")%>"><%=rs.getString("motorista")%></td>
  </tr>
  <%linha++;
        }//while
      }  
    %>
  <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
    <td colspan="9"><div align="center">
        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
      </div></td>
  </tr>
</table>

</body>
</html>
