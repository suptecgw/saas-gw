
<%@page import="java.sql.ResultSet"%>
<%@page import="fpag.BeanConsultaFPag"%>
<%@page contentType="text/html; charset=iso-8859-1" language="java"   import="nucleo.Apoio" errorPage="" %>
<%@page import="java.util.ArrayList"%>
<%@page import="fpag.BeanFPag"%>
<%@page import="java.util.Collection"%>
<%@page import="fpag.CadFPag"%>

  <script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadformapagamento") : 0);
   boolean souadm = Apoio.getUsuario(request).getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%
  BeanConsultaFPag bcfp = new BeanConsultaFPag();
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  CadFPag cad = new CadFPag();
  Collection<BeanFPag> listaFPags =null;
  BeanFPag fpag = null;
  cad.setConexao(Apoio.getUsuario(request).getConexao());
  bcfp.setConexao(Apoio.getUsuario(request).getConexao());
  cad.setExecutor(Apoio.getUsuario(request));
  if (acao.equals("editar") || acao.equals("iniciarEditar")){     //instanciando o bean de cadastro
  }if ((nivelUser >= 2) && acao.equals("editar")){
      listaFPags = new ArrayList<BeanFPag>();
    int qtd = Integer.parseInt(request.getParameter("qtdLinhas"));

    for(int i = 1; i<= qtd ; i++){
        fpag = new BeanFPag();

        fpag.setUtilizaNaCartaFrete((request.getParameter("isUtilizadoNaCartaFrete_"+i)!= null?true:false));
        fpag.setConsiderarDataConciliacao((request.getParameter("isConsiderarDataConciliacao_"+i)!= null?true:false));
        fpag.setIdFPag(Integer.parseInt(request.getParameter("id_"+i)));

        listaFPags.add(fpag);
    }
  cad.setListaPags(listaFPags);
  boolean erro = !(cad.Atualiza());


//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro)
         {
             acao = (acao.equals("editar") ? "editar" : "iniciarEditar");
             %>alert('<%=(cad.getErros())%>');
        <%}else{%>
             fechar();
        <%}}%>
       </script>

 <script language="javascript" type="text/javascript">

  //Em caso de alteração, o combo UF recebe o valor do BD
  //Está sendo utilizado no onload do body
var linha = 0;
  function salva(acao){
     var form = $("formulario");

     form.action ="cadFormaPagamento.jsp?acao=editar&qtdLinhas="+linha;
     form.submit();
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

<title>WebTrans - Cadastro de formas de pagamento</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body>
    <form action="" method="post"  id="formulario" >
        <img src="img/banner.gif" >
        <br>
        <table width="421" align="center" class="bordaFina" >
            <tr>
                <td width="268">
                    <div align="left">
                        <b>Formas de Pagamento</b>
                    </div>
                </td>
                <td width="74" ></td>
            </tr>
        </table>
        <br>
        <table width="631" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="3" align="center">Dados principais</td>
            </tr>
            <tr>
                <td class="CelulaZebra1" width="40%">
                    <b>Descrição</b>
                </td>
                <td class="CelulaZebra1NoAlign" align="center" width="20%">
                    <b>Utilizado no Contrato de Frete</b>
                </td>
                <td class="CelulaZebra1NoAlign" align="center" width="40%">
                    <b>Considerar data da conciliação na integração contábil. (Apenas se em configurações considerar a data de entrada como data da baixa)</b>
                </td>
            </tr>
            <%
                int linha = 0;

                if (bcfp.MostrarTudo()){
                ResultSet rs =bcfp.getResultado();
                while(rs.next()){
                    linha++;
                %>
                <script>linha++;</script>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign")%>">
                    <td width="40%"><%=rs.getString("descfpag")%></td>
                    <td align="center" width="20%">
                        <input type="checkbox" id="isUtilizadoNaCartaFrete_<%=linha%>" name="isUtilizadoNaCartaFrete_<%=linha%>" value="<%=rs.getInt("idfpag")%>" <%=(rs.getBoolean("is_carta_frete")?"checked":"")%>>
                        <input type="hidden" id="id_<%=linha%>" name="id_<%=linha%>" value="<%=rs.getInt("idfpag")%>">
                    </td>
                    <td align="center" width="40%">
                        <input type="checkbox" id="isConsiderarDataConciliacao_<%=linha%>" name="isConsiderarDataConciliacao_<%=linha%>" value="<%=rs.getInt("idfpag")%>" <%=(rs.getBoolean("is_integracao_data_conciliacao")?"checked":"")%>>
                    </td>
                </tr>
                <%}
                }%>    
                <tr class="CelulaZebra2">
                    <td colspan="5">
                        <% if (nivelUser >= 2){%>
                            <center>
                               <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onclick="salva();">
                            </center>
                        <%}%>
                    </td>
                </tr>
        </table>
        <br>
    </form>
  </body>
</html>