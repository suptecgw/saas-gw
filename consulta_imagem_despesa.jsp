<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.util.Collection,nucleo.imagem.*"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" >  

    function excluirImagem(idDespesa,idImagem){
       

        if (confirm("Deseja mesmo Excluir esta Imagem do Cadastro do Motorista?"))
        {
                 location.replace("./ImagemControlador?acao=excluir&idImagem="+idImagem+
                "&idDespesa="+idDespesa+"&index=${param.index}");
        }
    }

    function saveImg(nomeArquivo){
        document.location.href = './IMG_'+nomeArquivo+'.jpg1?acao=salvar&nomeArquivo='+nomeArquivo;
    }

    function savefile( f ) {
        f = f.elements;  //  reduce overhead

        var w = window.frames.w;
        if( !w ) {
            w = document.createElement( 'iframe' );
            w.id = 'w';
            w.style.display = 'none';
            document.body.insertBefore( w, null );
            w = window.frames.w;
            if( !w ) {
                w = window.open( '', '_temp', 'width=100,height=100' );
                if( !w ) {
                    window.alert( 'Sorry, the file could not be created.' ); return false;
                }
            }
        }

        var d = w.document,
        ext = f.ext.options[f.ext.selectedIndex],
        name = f.filename.value.replace( /\//g, '\\' ) + ext.text;

        d.open( 'text/plain', 'replace' );
        d.charset = ext.value;
        if( ext.text==='.txt' ) {
            d.write( f.txt.value );
            d.close();
        } else {  //  '.html'
            d.close();
            d.body.innerHTML = '\r\n' + f.txt.value + '\r\n';
        }

        if( d.execCommand( 'SaveAs', null, name ) ){
            window.alert( name + ' has been saved.' );
        } else {
            window.alert( 'The file has not been saved.\nIs there a problem?' );
        }
        w.close();
        return false;  //  don't submit the form
    }
    
    function doSaveAs(nomeArquivo){
        nomeArquivo = nomeArquivo.elements;  //  reduce overhead

        var w = window.frames.w;
        if( !w ) {
            w = document.createElement( 'iframe' );
            w.id = 'w';
            w.style.display = 'none';
            document.body.insertBefore( w, null );
            w = window.frames.w;
            if( !w ) {
                w = window.open( '', '_temp', 'width=100,height=100' );
                if( !w ) {
                    window.alert( 'Sorry, the file could not be created.' ); return false;
                }
            }
        }

        var d = w.document,
        ext = f.ext.options[f.ext.selectedIndex],
        name = f.filename.value.replace( /\//g, '\\' ) + ext.text;

        d.open( 'text/plain', 'replace' );
        d.charset = ext.value;
        if( ext.text==='.txt' ) {
            d.write( f.txt.value );
            d.close();
        } else {  //  '.html'
            d.close();
            d.body.innerHTML = '\r\n' + f.txt.value + '\r\n';
        }

        if( d.execCommand( 'SaveAs', null, name ) ){
            window.alert( name + ' has been saved.' );
        } else {
            window.alert( 'The file has not been saved.\nIs there a problem?' );
        }
        w.close();
        return false;  //  don't submit the form
    }

    function anexaImg(){
        var arqImg01 = $("arqImg01").value;

        if (arqImg01 == ""){
            alert("Selecione a Imagem!");
            return false;
        }

        var extensoesOk = ",.gif,.jpg,.pdf,.xml,";

        var extensao    = "," + arqImg01.substr( arqImg01.length - 4 ).toLowerCase() + ",";
        if( extensoesOk.indexOf( extensao ) == -1 ){
            return  alert( "Extensão de Arquivo Inválida!" );

        }

        var idDespesa = $("idDespesa").value;        
        var descricao = $("descricao").value;

        $("formImg").action ="ImagemControlador?acao=cadastrar&idDespesa="+idDespesa +"&isFoto=false&descricao=" +descricao;
        $("formImg").target = "pop";
        $("formImg").method = "post";

        window.open('about:blank', 'pop', 'width=210, height=100');
        document.getElementById("formImg").submit();

        return true;
    }

      function visualizaImagem(imagem){
        window.open("ImagemControlador?acao=imgpdf&imagem=" + imagem.trim() + "&idDespesa=" + $("idDespesa").value, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        //window.open("pops/visualizar_imagem.jsp?imagem=" + imagem, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
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

        <title>WebTrans - Visualiza&ccedil;&atilde;o de Documentos do Motorista</title>
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

    <body onbeforeunload="return atualizarQtdAnexos()">
        <img src="img/banner.gif"  alt="">
        <br>
        <table width="62%" align="center" class="bordaFina" >
            <tr>
                <td>
                    <div align="left">
                        <b>Visualiza&ccedil;&atilde;o de Documentos da Despesa</b>
                    </div>
                </td>
                <td>
                    <input type="button" value=" Fechar " class="botoes" onClick="window.close();" />
                </td>
            </tr>
        </table>
        <br>
        <table width="65%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                <% int linha = 0;

               Collection<DespesaImagem> listaDesp = (Collection<DespesaImagem>) request.getAttribute("listaListImagem");
               for (DespesaImagem despesaImagem : listaDesp) {
                   if (linha == 0 && despesaImagem.isFoto()) {%>
                        
                     
           
                        <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                            <tr class="celula" >
                                   <td width="8%">Imagem</td>
                                   <td width="8%"> Descri&ccedil;&atilde;o</td>
                                   
                              </tr>
                            
                            <tr class="celula">
                                <td>
                                     <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                                </td>
                               
                           
                           
                                <td width="37%" >
                                   
                                   <textarea  COLS=30 ROWS=3 name="descricao" id="descricao"></textarea>
                                     </td>
                              
                            </tr>
                            <tr class="celula" colspan="2" >
                                 <td width="48%">
                                    <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar Imagem da Documentação da Despesa  "
                                           onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                                </td>
                            </tr>
            </form>
          </table>
          <form action="../ImagemControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
            <table width="65%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                <%} else if (linha == 0 && !despesaImagem.isFoto()) {%>
                        
                       
                    
                        <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                          <tr class="celula" >
                                   <td width="8%">Imagem</td>
                                   <td width="8%"> Descri&ccedil;&atilde;o</td>
                
                                   
                              </tr>
                            
                            
                            <tr class="CelulaZebra2">
                                <td>
                                      <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                                </td>
                               
                           
                           
                                <td width="37%" >
                                 
                                   <textarea  COLS=30 ROWS=3 name="descricao" id="descricao"></textarea>
                                     </td>
                           
                            </tr>
                            <tr class="celula" >
                                 <td width="48%" colspan="2">
                                    <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar Imagem da Documentação da Despesa  "
                                           onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                                </td>
                            </tr>
                        </form>
            </table>
            <form action="../ImagemControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
                <table width="65%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                   
                     <c:if test="${status.count == 1}">  
                                 <tr class="celula" >
                                   <td width="13%">Imagem</td>
                                   <td width="71%">Descri&ccedil;&atilde;o</td>                                  
                                   <td width="14%">Excluir</td>                                  
                                  </tr> 
                                   </c:if>
                    
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <td align="center" width="15%" height="60px">
                            
                            
                            <%if(despesaImagem.getExtensao().trim().equalsIgnoreCase("pdf")){%>
                                 <img width="25px" height="25px" src="img/pdf.gif" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()+ "_" + despesaImagem.getId()%>.<%= despesaImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(despesaImagem.getExtensao().trim().equalsIgnoreCase("xml")){%>
                                 <img width="25px" height="25px" src="img/xml.png" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()+ "_" + despesaImagem.getId()%>.<%= despesaImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(despesaImagem.getExtensao().trim().equalsIgnoreCase("jpg") || despesaImagem.getExtensao().trim().equalsIgnoreCase("gif") || despesaImagem.getExtensao().trim().equalsIgnoreCase("png")
                                    || despesaImagem.getExtensao().trim().equalsIgnoreCase("jpeg")){%>
                                 <img width="50px" height="50px" src="img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()+ "_" + despesaImagem.getId()%>.<%=despesaImagem.getExtensao().trim()%>"
                                      class="imagemLink" 
                                      onclick="visualizaImagem('/img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()%>_<%=despesaImagem.getId()%>.<%= despesaImagem.getExtensao() %>')"
                                      alt="Imagem" />
                                 <%}%>
                            <input type="hidden" name="img_<%=linha%>" id="img_<%=linha%>" value="<%=despesaImagem.getDespesa().getIdmovimento() + "_" + despesaImagem.getId()%>">
                        </td>
                        <td  width="76%">
                            <b><%=despesaImagem.getDescricao()%></b>
                        </td>
                        <td width="14%"  >
                            <img src="img/lixo.png" alt="Excluir esta Imagem" style="cursor:pointer "
                                 onclick="javascript:tryRequestToServer(function(){excluirImagem('<%=despesaImagem.getDespesa().getIdmovimento()%>','<%=despesaImagem.getId()%>');});"
                                 width="21" height="22" border="0" align="right">
                        </td>
                    </tr>
                    <%} else {%>
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <td align="center" width="15%" height="60px">
                            <!-- <img width="50px" height="50px" 
                                 src="img/despesa/<%=despesaImagem.getDespesa().getIdmovimento() + "_" + despesaImagem.getId()%>.jpg" class="imagemLink" 
                                 onClick="visualizaImagem('../img/despesa/<%=despesaImagem.getDespesa().getIdmovimento() + "_" + despesaImagem.getId()%>.jpg')" alt="Imagem" />
                            -->
                            
                            
                            <%if(despesaImagem.getExtensao().trim().equalsIgnoreCase("pdf")){%>
                                 <img width="25px" height="25px" src="img/pdf.gif" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()+ "_" + despesaImagem.getId()%>.<%= despesaImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(despesaImagem.getExtensao().trim().equalsIgnoreCase("xml")){%>
                                 <img width="25px" height="25px" src="img/xml.png" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()+ "_" + despesaImagem.getId()%>.<%= despesaImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(despesaImagem.getExtensao().trim().equalsIgnoreCase("jpg") || despesaImagem.getExtensao().trim().equalsIgnoreCase("gif")){%>
                                 <img width="50px" height="50px" src="img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()+ "_" + despesaImagem.getId()%>.jpg"
                                      class="imagemLink" 
                                      onclick="visualizaImagem('/img/despesa/<%=despesaImagem.getDespesa().getIdmovimento()%>_<%=despesaImagem.getId()%>.<%= despesaImagem.getExtensao() %>')"
                                      alt="Imagem" />
                                 <%}%>
                            
                            
                            
                            
                            <input type="hidden" name="img_<%=linha%>" id="img_<%=linha%>" value="<%=despesaImagem.getDespesa().getIdmovimento() + "_" + despesaImagem.getId()%>">
                        </td>
                        <td  width="76%" >
                            <b><%=despesaImagem.getDescricao()%></b>
                        </td>
                        <td width="14%" >
                            <img src="img/lixo.png" alt="Excluir esta Imagem" style="cursor:pointer "
                                 onclick="javascript:tryRequestToServer(function(){excluirImagem('<%=despesaImagem.getDespesa().getIdmovimento() %>','<%=despesaImagem.getId()%>');});"
                                 width="21" height="22" border="0" align="right">
                        </td>
                    </tr>
                    <%
                        }
                        linha++;
                    }//for
                    //}//if
                    if (listaDesp.size() == 0) {%>
                        
                       
                       
                        <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                            
                            <tr class="celula" >
                                   <td width="8%">Imagem</td>
                                   <td width="8%"> Descri&ccedil;&atilde;o</td>
                                   
                              </tr>
                            <tr class="celula">
                                <td>
                                      <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                                </td>
                               
                           
                           
                                <td width="37%" >
                                   
                                   <textarea  COLS=30 ROWS=3 name="descricao" id="descricao"></textarea>
                                     </td>
                             
                            </tr>
                                <tr class="celula" >
                                 <td width="48%" colspan="2">
                                    <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar Imagem da Documentação da Despesa  "
                                           onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                                </td>
                            </tr>
                        </form>
                    </table>
                <%
                   }
                %>
                <input type="hidden" name="idDespesa" id="idDespesa" value="<%=request.getParameter("idDespesa")%>">
                <input type="hidden" name="qtd-anexo" id="qtd-anexo" value="${fn:length(listaListImagem)}">
                </table>
         </form>
    </body>
    <script>
        function atualizarQtdAnexos(){
            window.opener.atualizarQtdAnexos('<%=request.getParameter("index")%>',document.getElementById('qtd-anexo').value);
        }
    </script>
</html>