<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.util.Collection,nucleo.imagem.*"%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" >  

    function excluirImagem(idveiculo,idImagem){
        var placa = "";

        if (confirm("Deseja mesmo Excluir esta Imagem do Cadastro do Veiculo?")){
            placa = $("placa").value;
               
            location.replace("./ImagemControlador?acao=excluir&idImagem="+idImagem+
                "&idveiculo="+idveiculo + "&placa=" + placa);
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

        var idveiculo = $("idveiculo").value;
        var placa = $("placa").value;
        var descricao = $("descricao").value;

        $("formImg").action ="ImagemControlador?acao=cadastrar&idveiculo="+idveiculo +
            "&placa="+placa + "&isFoto=false&descricao=" + descricao;
        $("formImg").target = "pop";
        $("formImg").method = "post";

        window.open('about:blank', 'pop', 'width=210, height=100');
        document.getElementById("formImg").submit();

        return true;
    }

    function anexaFoto3x4(){
        var arqImg = $("arqImg").value;

        if (arqImg == ""){
            alert("Selecione a Imagem!");
            return false;
        }

        var extensoesOk = ",.gif,.jpg,.pdf,.xml,";

        var extensao    = "," + arqImg.substr( arqImg.length - 4 ).toLowerCase() + ",";
        if( extensoesOk.indexOf( extensao ) == -1 ){
            return  alert( "Extenção de Arquivo Inválida!" );

        }

        var idveiculo = $("idveiculo").value;
        var placa = $("placa").value;
        var descricao = $("descricao").value;
        
        if(descricao.length == 0){
            descricao = "Foto Veiculo";
        }
        

        $("formFoto").action ="ImagemControlador?acao=cadastrar&idveiculo="+idveiculo +
            "&placa="+placa + "&isFoto=true&descricao=" + descricao;
        $("formFoto").target = "pop";
        $("formFoto").method = "post";

        window.open('about:blank', 'pop', 'width=210, height=100');
        document.getElementById("formFoto").submit();

        return true;
    }

    function visualizaImagem(imagem){
               window.open("ImagemControlador?acao=imgpdf&imagem=" + imagem.trim() + "&idveiculo=" + $("idveiculo").value, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
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

        <title>WebTrans - Visualiza&ccedil;&atilde;o de Documentos do Ve&iacute;culo</title>
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
        <img src="img/banner.gif"  alt="">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td>
                    <div align="left">
                        <b>Visualiza&ccedil;&atilde;o de Documentos do Ve&iacute;culo</b>
                    </div>
                </td>
                <td>
                    <input type="button" value=" Fechar " class="botoes" onClick="window.close();" />
                </td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
            <% int linha = 0;

               Collection<VeiculoImagem> listaVeic = (Collection<VeiculoImagem>) request.getSession().getAttribute("listaListImagem");
               for (VeiculoImagem veiculoImagem : listaVeic) {
                   if (linha == 0 && veiculoImagem.isFoto()) {%>
                        <tr class="celula">
                            <td height="20" colspan="2">
                                Veiculo:<%=request.getParameter("placa")%>
                            </td>
                            
                        </tr>
                        <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                            <tr class="celula">
                                <td>
                                      <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                                </td>
                                <td width="48%">
                                    <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar Imagem da Documentação do Veiculo  "
                                           onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                                </td>
                            </tr>
                            <tr class="celula">
                                <td width="37%" colspan="2">
                                    Descri&ccedil;&atilde;o:
                                    <input name="descricao" type="text" id="descricao" size="25" maxlength="25" value="" class="inputtexto">
                                </td>
                            </tr>
                        </form>
          </table>
          <form action="../ImagemControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
            <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                <%} else if (linha == 0 && !veiculoImagem.isFoto()) {%>
                        <tr class="celula">
                            <td height="20" colspan="2">
                                Veiculo:<%=request.getParameter("placa")%>
                            </td>
                        </tr>
                        <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                            <tr class="celula">
                                <td>
                                      <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                                </td>
                                <td width="48%">
                                    <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar Imagem da Documentação do Veiculo  "
                                           onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                                </td>
                            </tr>
                            <tr class="celula">
                                <td width="37%" colspan="3">
                                    Descri&ccedil;&atilde;o:
                                    <input name="descricao" type="text" id="descricao" size="25" maxlength="25" value="">
                                </td>
                            </tr>
                        </form>
            </table>
            <form action="../ImagemControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
                <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <td align="center" width="20%" height="60px">
                            <!--<img width="50px" height="50px" src="img/veiculo/< %=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.jpg" 
                            class="imagemLink" onClick="visualizaImagem('../img/veiculo/< %=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.jpg')" alt="Imagem" />
                            -->
                            
                             <%if(veiculoImagem.getExtensao().trim().equalsIgnoreCase("pdf")){%>
                                 <img width="25px" height="25px" src="img/pdf.gif" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.<%= veiculoImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(veiculoImagem.getExtensao().trim().equalsIgnoreCase("xml")){%>
                                 <img width="25px" height="25px" src="img/xml.png" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.<%= veiculoImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(veiculoImagem.getExtensao().trim().equalsIgnoreCase("jpg") || veiculoImagem.getExtensao().trim().equals("gif")){%>
                                 <img width="50px" height="50px" src="img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.jpg"
                                      class="imagemLink" 
                                      onclick="visualizaImagem('/img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo()%>_<%=veiculoImagem.getId()%>.<%= veiculoImagem.getExtensao() %>')"
                                      alt="Imagem" />
                                 <%}%>
                            
                        
                            <input type="hidden" name="img_<%=linha%>" id="img_<%=linha%>" value="<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>">
                        </td>
                        <td  width="77%" >
                            <b><%=veiculoImagem.getDescricao()%></b>
                        </td>
                        <td width="3%">
                            <img src="img/lixo.png" alt="Excluir esta Imagem" style="cursor:pointer "
                                 onclick="javascript:tryRequestToServer(function(){excluirImagem('<%=veiculoImagem.getVeiculo().getIdveiculo()%>','<%=veiculoImagem.getId()%>');});"
                                 width="21" height="22" border="0" align="right">
                        </td>
                    </tr>
                    <%} else {%>
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <td align="center" width="20%" height="60px">
                            
                            
                             <%if(veiculoImagem.getExtensao().trim().equalsIgnoreCase("pdf")){%>
                                 <img width="25px" height="25px" src="img/pdf.gif" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.<%= veiculoImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(veiculoImagem.getExtensao().trim().equalsIgnoreCase("xml")){%>
                                 <img width="25px" height="25px" src="img/xml.png" class="imagemLink2" 
                                     onclick="visualizaImagem('/img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.<%= veiculoImagem.getExtensao() %>')"
                                     alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <%if(veiculoImagem.getExtensao().trim().equalsIgnoreCase("jpg") || veiculoImagem.getExtensao().trim().equalsIgnoreCase("gif")){%>
                                 <img width="50px" height="50px" src="img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>.jpg"
                                      class="imagemLink" 
                                      onclick="visualizaImagem('/img/veiculo/<%=veiculoImagem.getVeiculo().getIdveiculo()%>_<%=veiculoImagem.getId()%>.<%= veiculoImagem.getExtensao() %>')"
                                      alt="Imagem" />
                                 <%}%>
                                 
                                 
                            <input type="hidden" name="img_<%=linha%>" id="img_<%=linha%>" value="<%=veiculoImagem.getVeiculo().getIdveiculo() + "_" + veiculoImagem.getId()%>">
                        </td>
                        <td  width="77%" >
                            <b><%=veiculoImagem.getDescricao()%></b>
                        </td>
                        <td width="3%">
                            <img src="img/lixo.png" alt="Excluir esta Imagem" style="cursor:pointer "
                                 onclick="javascript:tryRequestToServer(function(){excluirImagem('<%=veiculoImagem.getVeiculo().getIdveiculo()%>','<%=veiculoImagem.getId()%>');});"
                                 width="21" height="22" border="0" align="right">
                        </td>
                    </tr>
                    <%
                        }
                        linha++;
                    }//for
                    //}//if
                    if (listaVeic.size() == 0) {%>
                        <tr class="celula">
                            <td height="20" colspan="2" width="100%">
                                Veiculo:<%=request.getParameter("placa")%>
                            </td>
                        </tr>
                        <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                            <tr class="celula">
                                <td>
                                      <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                                </td>
                                <td width="48%">
                                    <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar Imagem da Documentação do Veiculo  "
                                           onClick="javascript:tryRequestToServer(function(){anexaImg();});">
                                </td>
                            </tr>
                            <tr class="celula">
                                <td width="37%" colspan="3">
                                    Descri&ccedil;&atilde;o:
                                    <input name="descricao" type="text" id="descricao" size="25" maxlength="25" value="">
                                </td>
                            </tr>
                        </form>
                    </table>
                <%
                   }
                %>
                <input type="hidden" name="idveiculo" id="idveiculo" value="<%=request.getParameter("idveiculo")%>">
                <input type="hidden" name="placa" id="placa" value="<%=request.getParameter("placa")%>">
             </table>
         </form>
    </body>
</html>