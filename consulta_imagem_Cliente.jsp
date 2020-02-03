<%-- 
    Document   : consulta_Imagem_Cliente
    Created on : 22/06/2014, 10:53:03
    Author     : paulo
--%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.util.Collection,nucleo.imagem.*"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
    function excluirImagem(idCliente, idImagem, index){
        if(confirm("Deseja mesmo excluir essa Imagem no Cadastro de Cliente?")){
            Element.remove("tr_"+index);
            location.replace("./ImagemControlador?acao=excluir&idImagem="+idImagem+"&idcliente="+idCliente);
        }
        
    }
    function visualizaImagem(imagem){
        window.open("ImagemControlador?acao=imgpdf&imagem=" + imagem.trim() + "&idcliente=" + $("idCliente").value, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }  
    
    
    function anexaImg(){
        var arqImg01 = $("arqImg01").value;
        
        if(arqImg01 == ""){
            alert("Selecione a Imagem!");
            return false;
        }

        var extensoesOk = ",.gif,.jpg,.pdf,.xml,.doc,.docx,.png,";
        var extensao    = "," + arqImg01.substr( arqImg01.length - 4 ).toLowerCase() + ",";
        
        //validação para aceitar documento com a extensao .docx
        if(extensao == ",docx,"){            
            extensao    = "," + arqImg01.substr( arqImg01.length - 5 ).toLowerCase() + ",";            
        }
        
        if(extensoesOk.indexOf( extensao ) == -1){
            return alert("Extensão de Arquivo Inválida!");
        }
        
        var idCliente = $("idCliente").value;
        var descricao = $("descricao").value;
        var form = $("formulario");
        
        form.action = "ImagemControlador?acao=cadastrar&idcliente="+idCliente+"&descricao="+descricao;
        form.target = "pop";
        form.method = "post";
        form.enctype = "multipart/form-data";
        
        window.open('about:blank', 'pop', 'width=210, height=100');
        form.submit();
        
    }
    
    function fechar(){
       window.close();
    }
    
</script>
<html>
    <style type="text/css">
            <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                      font-size: 13px;
            }
            -->
        </style>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        <title>WebTrans - Visualiza&ccedil;&atilde;o de Documentos do Cliente</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">        
    </head>
    <body>
        <img src="img/banner.gif"  alt="">
        <br>
        <table width="90%" align="center" class="bordaFina">
            <tr>
                <td>
                    <div align="left">
                        <label class="style4"><b>Visualiza&ccedil;&atilde;o de Documentos do Cliente</b></label>
                    </div>
                </td>
                <td>
                    <input type="button" value=" Fechar " class="inputbotao" onclick="fechar()"/>
                </td>
            </tr>
        </table>
        <br>
        <form id="formulario" name="formulario" method="post" target="pop" enctype="multipart/form-data">
            <table width="90%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                <tbody>
                    <tr class="celula">
                        <td>Imagem</td>
                        <td>Descri&ccedil;&atilde;o</td>
                        <input type="hidden" id="idCliente" name="idCliente" value="${param.idCliente}" />
                    </tr>
                    <tr class="CelulaZebra2">
                        <td>  <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/></td>
                        <td><textarea cols="30" rows="3" name="descricao" id="descricao"></textarea></td>
                    </tr>
                    <tr class="celula">
                        <td colspan="2">
                            <input name="anexar01" type="button" class="inputbotao" id="anexar01" value="Salvar" onclick="anexaImg()"/>
                        </td>
                    </tr>
                </tbody>
                
            </table>
        </form>
        <table width="90%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
            <tr class="celula">
                <td>Imagem</td>
                <td>Descri&ccedil;&atilde;o</td>
                <td>Excluir</td>
            </tr>           
            <c:forEach var="imagem" varStatus="status" items="${listaListImagem}">                
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" id="tr_${status.count}">
                    <td>
                        <div align="center">
                            
                            <c:if test="${imagem.getExtensao().trim().equalsIgnoreCase('jpg')}">
                                <img width="45px" height="45px" src="img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}" class="imagemLink2" onclick="visualizaImagem('/img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                            </c:if>
                            <c:if test="${imagem.getExtensao().trim().equalsIgnoreCase('gif')}">
                                <img width="45px" height="45px" src="img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}" class="imagemLink2" onclick="visualizaImagem('/img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                            </c:if>
                            <c:if test="${imagem.getExtensao().trim().equalsIgnoreCase('png')}">
                                <img width="45px" height="45px" src="img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}" class="imagemLink2" onclick="visualizaImagem('/img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                            </c:if>
                            <c:if test="${imagem.getExtensao().trim().equalsIgnoreCase('pdf')}">
                                <img width="45px" height="45px" src="img/pdf.gif" class="imagemLink2" onclick="visualizaImagem('/img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                            </c:if>
                            <c:if test="${imagem.getExtensao().trim().equalsIgnoreCase('doc') || imagem.getExtensao().trim().equals('docx')}">
                                <img width="45px" height="45px" src="img/word.gif" class="imagemLink2" onclick="visualizaImagem('/img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                            </c:if>                            
                            <c:if test="${imagem.getExtensao().trim().equalsIgnoreCase('xml')}">
                                <img width="45px" height="45px" src="img/xml.png" class="imagemLink2" onclick="visualizaImagem('/img/cliente/${imagem.getClienteId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                            </c:if>
                                
                            <input type="hidden" name="img_${status.count}" id="img_${status.count}" value="${imagem.getClienteId()}_${imagem.getId()}"/>
                            <input type="hidden" name="extensao" id="extensao" value="${imagem.getExtensao()}" />  
                        </div>
                    </td>
                    <td>
                        <b>${imagem.getDescricao()}</b>
                    </td>
                    <td>
                        <div align="center">
                            <img src="img/lixo.png" alt="Excluir esta imagem" style="cursor: pointer" onclick="excluirImagem('${imagem.getClienteId()}','${imagem.getId()}','${status.count}')"/>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </body>
</html>
