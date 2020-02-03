<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="nucleo.BeanAlteraTaxaSeguro,
           nucleo.Apoio,
           java.util.*" errorPage="" %>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("alttaxa") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>
<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  BeanAlteraTaxaSeguro beantaxa = null;

  if (acao.equals("editar") || acao.equals("atualizar"))
  {     //instanciando o bean de cadastro
        beantaxa = new BeanAlteraTaxaSeguro();
        beantaxa.setConexao(Apoio.getUsuario(request).getConexao());
        beantaxa.setExecutor(Apoio.getUsuario(request));
  }

  if (acao.equals("editar"))
  {
        beantaxa.LoadAllPropertys();
  }

  if ((nivelUser >= 2) && (acao.equals("atualizar")))
  {
      //populando o JavaBean
      //Criando o vetor
      Hashtable vestados = new Hashtable();
      // Criando o nome da chave e do elemento
      Enumeration altestado = vestados.keys();
      Enumeration alttaxa = vestados.elements();
      //Variável que receberá o split do parametro estados
      String registro;
      for (int w = 0;w < Integer.parseInt(request.getParameter("qtd"));++w)
      {
        registro = request.getParameter("estados").split("::")[w];
        vestados.put(registro.split("_")[0]+"_"+registro.split("_")[1], registro.split("_")[2]+"_"+registro.split("_")[3]);
      }
      //enviando o vetor do jsp para o bean
      beantaxa.setVtaxas(vestados);

      boolean erro = !beantaxa.Atualiza();

      //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
        if (erro)
        {
          %>alert('<%=(beantaxa.getErros())%>');
        <%}%>
        window.close();
       </script>

 <%}%>
<script language="javascript" type="">
  var vlurl="";
  var qtdalt=0;
  function voltar(){
     document.location.replace("./menu");
  }

  function salva(){
    document.getElementById("salvar").disabled = true;
    document.getElementById("salvar").value = "Enviando...";

    vlurl = "./alterataxa?acao=atualizar&estados="+vlurl+"&qtd="+qtdalt;
    document.location.replace(vlurl);
  }

  function criaurl(estado,objr,objt){
    qtdalt = qtdalt + 1;
    vlurl = vlurl + estado + "_" + document.getElementById(objr).value + "_" + document.getElementById(objt).value + "::";
  }
  
  
</script>
<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Cadastro</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body>
<img src="img/banner.gif">
<br>
<table width="700" align="center" class="bordaFina" >
  <tr >
    <td width="613"><div align="left"><b>Taxas de seguro contra roubo e tombamento de cada estado</b></div></td>
  </tr>
</table>
<br>
<br>
<table width="1200" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
  <% if (acao.equals("editar"))
  {%>
    <tr class="tabela">
      <td><font size="1"></font></td>
      <%
      //Primeiro listando todos os estados de destino que ficarão na parte superior da tela
      for (Enumeration estados = beantaxa.getVuf().keys();estados.hasMoreElements();)
      {
        String estado = (String)estados.nextElement();
        String sigla = beantaxa.getVuf().get(estado).toString();
        %>
        <td align="center"><font size="1"><%=sigla%></font></td>
        <%
      }%>
    </tr>

    <%
    int i = 0;
    int z = 0;
    //percorrendo o vetor da origem
    for (Enumeration estados = beantaxa.getVuf().keys();estados.hasMoreElements();)
    {
      String estado = (String)estados.nextElement();
      String sigla = beantaxa.getVuf().get(estado).toString();
      %>
      <tr>
        <td  class="tabela"><font size="1"><%=sigla%></font></td>
      <%
      //Percorrendo o vetor do destino
      for (Enumeration estadosdest = beantaxa.getVuf().keys();estadosdest.hasMoreElements();)
      {
        String estadodest = (String)estadosdest.nextElement();
        String sigladest = beantaxa.getVuf().get(estadodest).toString();
        //percorrendo os registros do bd pra verificar se é igual a origem e destino
        for (Enumeration ufs = beantaxa.getVtaxas().keys();ufs.hasMoreElements();)
        {
          String uf = (String)ufs.nextElement();
          float taxaroubo = Float.parseFloat(beantaxa.getVtaxas().get(uf).toString().split("_")[0]);
          float tombamento = Float.parseFloat(beantaxa.getVtaxas().get(uf).toString().split("_")[1]);
          if (sigla.equals(uf.split("_")[0]) && sigladest.equals(uf.split("_")[1]))
          {%>
            <td class="<%=((i % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")%>">
              <font size="1">
                R:<input type="text" align="right" name="<%=uf%>" class="fieldMin"
                  id="<%="taxaroubo" + z%>" 
                  value="<%=taxaroubo%>" 
                  maxlength="5" 
                  size="1"
                  style="font-size: 7pt" 
                  title="<%="Origem: " + uf.split("_")[0] + "\nDestino: " + uf.split("_")[1] + "\nTipo: Roubo"%>" 
                  onKeyPress="javascript:digitaValores();" 
                  onchange="javascript:criaurl('<%=uf%>','<%="taxaroubo" + z%>','<%="taxatombamento" + z%>');"
                />
                T:<input type="text" align="right" name="<%=uf%>+T" 
                  id="<%="taxatombamento" + z%>" class="fieldMin"
                  value="<%=tombamento%>" 
                  maxlength="5" 
                  size="1" 
                  style="font-size: 7pt" 
                  title="<%="Origem: " + uf.split("_")[0] + "\nDestino: " + uf.split("_")[1] + "\nTipo: Tombamento"%>" 
                  onKeyPress="javascript:digitaValores();"
                  onchange="javascript:criaurl('<%=uf%>','<%="taxaroubo" + z%>','<%="taxatombamento" + z%>');"
                />  
              </font>
            </td>
            <%
            break;
          }
        }
        z++;
      }
      i++;
      %>
      </tr>
      <%
    }
  }%>
</table>
 <%if (nivelUser >= 2){%>
	<table width="1270" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
	  <tr class="CelulaZebra2">
		<td colspan="2">
		  <center>
			<input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva();});">
		  </center></td>
	  </tr>
	</table>
  <%}%>
<br>

