<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.util.Collection,nucleo.imagem.*"%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" >  
  function consulta(campo, operador, valor, limite){
     location.replace("./consulta_area.jsp?campo="+campo+"&ope="+operador+"&valor="+valor+
                      "&limite="+limite+"&pag=1&acao=consultar");
  }

  function cadarea(){
      location.replace("./consulta_imagem.jsp?acao=cadastrar");
  }

  function excluirImagem(idmotorista,idImagem){
      var nome = "";
      var cpf = "";

       if (confirm("Deseja mesmo excluir esta imagem do cadastro do motorista?"))
	   {
               nome = $("nome").value;
               cpf = $("cpf").value;
               
	       location.replace("./ImagemControlador?acao=excluir&idImagem="+idImagem+
                   "&idmotorista="+idmotorista + "&nome=" + nome + "&cpf=" + cpf);
	   }
  }

  function anexa(){
      //espereEnviar("",true);

      var conta = $("contaRet").value;
      $("formRet").action ="./consulta_imagem.jsp?acao=anexar"+conta ;
      $("formRet").target = "pop";
      $("formRet").method = "post";

      window.open('about:blank', 'pop', 'width=210, height=100');
      document.getElementById("formRet").submit();

      return true;
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

<title>WebTrans - Visualização de documentos do motorista</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
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
<img src="img/banner.gif"  alt=""><br>
<table width="80%" align="center" class="bordaFina" >
  <tr>
    <td>
        <div align="left"><b>Visualização de documentos do motorista</b></div>
    </td>
    <td><input type="button" value=" Fechar " class="botoes" onclick="window.close();"/></td>
  </tr>
</table>

<br>

<table width="80%" align="center" cellspacing="1" class="bordaFina">
      <% //variaveis da paginacao
      int linha = 0;
      
      //if (acao.equals("consultar") && img.LoadAllPropertys()){
          //ResultSet rs = area.getResultado();
	  //while (rs.next()){
          //for (MotoristaImagem motoristaImagem : img.getListaMotorista()) {
          Collection<MotoristaImagem> listaMot = (Collection<MotoristaImagem>)request.getSession().getAttribute("listaListImagem");
          for (MotoristaImagem motoristaImagem : listaMot) {
               if(linha == 0){             //pega o resto da divisao e testa se é par ou impar
             %>
                    <tr class="celula">
                        <td height="20" width="85%">Motorista:<%=request.getParameter("nome")%></td>
                        <td rowspan="4" width="15%" align="center">
                            <img width="60px" height="80px" src="img/motorista/<%=motoristaImagem.getMotoristaId() + "_" + motoristaImagem.getId()%>.jpg" class="imagemLink" onclick="visualizaImagem('<%=motoristaImagem.getMotoristaId() + "_" + motoristaImagem.getId()%>')" alt="foto 3X4" />
                            <input type="hidden" name="img_<%=linha%>" id="img_<%=linha%>" value="<%=motoristaImagem.getMotoristaId() + "_" + motoristaImagem.getId()%>">
                        </td>
                    </tr>
                    <tr class="celula">
                        <td >CPF:<%=request.getParameter("cpf")%>
                        </td>
                     </tr>
                     <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                        <tr class="celula">
                            <td>
                               <input name="arqImg" id="arqImg" type="file" style="font-size:8pt;"  size="20" />
                               <input name="anexar" type="button" class="botoes" id="anexar" value="   Anexar foto do motorista  "
                                      onClick="javascript:tryRequestToServer(function(){anexaFoto3x4();});">
                            </td>
                        </tr>
                        <tr class="celula">
                            <td >
                               <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" />
                               <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar imagem da Documentação do motorista  "
                                      onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                            </td>
                        </tr>
                    </form>
                </table>
          <form action="../ImagemControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
                <table width="80%" align="center" cellspacing="1" class="bordaFina">
            <%}else{%>
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                        <td align="center" width="20%" height="60px">
                            <img width="50px" height="50px" src="img/motorista/<%=motoristaImagem.getMotoristaId() + "_" + motoristaImagem.getId()%>.jpg" class="imagemLink" onclick="visualizaImagem('<%=motoristaImagem.getMotoristaId() + "_" + motoristaImagem.getId()%>')" alt="imagem" />
                            <input type="hidden" name="img_<%=linha%>" id="img_<%=linha%>" value="<%=motoristaImagem.getMotoristaId() + "_" + motoristaImagem.getId()%>">
                        </td>
                        <td  width="77%" >
                            <b><%=motoristaImagem.getDescricao()%></b>
                            <!--<input name="descricao" type="text" id="descricao" value="" size="25" maxlength="25">-->
                        </td>
                        <td width="3%">
                            <img src="img/lixo.png" alt="Excluir esta imagem" style="cursor:pointer "
                                  onclick="javascript:tryRequestToServer(function(){excluirImagem('<%=motoristaImagem.getMotoristaId()%>','<%=motoristaImagem.getId()%>');});"
                                  width="21" height="22" border="0" align="right">
                        </td>
                    </tr>
              <% 
              }
                 linha++;
          }//for          
      //}//if
      if (listaMot.size() == 0){%>
                    <tr class="celula">
                        <td height="20" width="85%">Motorista:<%=request.getParameter("nome")%></td>

                        <td rowspan="4" width="15%" align="center">
                            <img width="50px" height="50px" src="img/jpg.png" class="imagemLink" alt="foto 3X4" />
                        </td>
                    </tr>
                    <tr class="celula">
                        <td >CPF:<%=request.getParameter("cpf")%></td>
                     </tr>
                     <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                        <tr class="celula">
                            <td>
                               <input name="arqImg" id="arqImg" type="file" style="font-size:8pt;"  size="20" />
                               <input name="anexar" type="button" class="botoes" id="anexar" value="   Anexar foto do motorista  "
                                      onClick="javascript:tryRequestToServer(function(){anexaFoto3x4();});">
                            </td>
                        </tr>
                        <tr class="celula">
                            <td >
                               <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" />
                               <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar imagem da Documentação do motorista  "
                                      onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                            </td>
                        </tr>
                    </form>
                </table>
          <%
          }
          %>
          <input type="hidden" name="cpf" id="cpf" value="<%=request.getParameter("cpf")%>">
          <input type="hidden" name="nome" id="nome" value="<%=request.getParameter("nome")%>">
   </table>

   </form>
</body>
</html>
