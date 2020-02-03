<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE HTML>
<%@ page contentType="text/html; charset=iso-8859-1"
         language="java" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" > 
    jQuery.noConflict();

    <c:if test="${param['visualizar'] ne 'true'}">
    function excluirImagem(idImagem){
        var qtdAnexo = document.getElementById('qtd-anexo').value;

        if (confirm("Deseja mesmo excluir esta imagem do conhecimento?"))
        {
            document.getElementById('qtd-anexo').value = parseInt(qtdAnexo) - 1;

            var idconhecimento = $("idconhecimento").value;
            var ocorrenciaId = $("ocorrencia_id").value;
            location.replace("./ImagemControlador?acao=excluir&idImagem="+idImagem+ "&idconhecimento="+idconhecimento+"&ocorrencia_id="+ocorrenciaId);
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
            alert("Selecione a imagem.");
            return false;
        }
        
        var extensoesOk = ",.gif,.jpg,.pdf,.xml,.jpeg,.png,";
        var extensao    = "," + arqImg01.substr( arqImg01.lastIndexOf(".") ).toLowerCase() + ",";
        if( extensoesOk.indexOf( extensao ) == -1 ){
            return  alert( "Extensão de arquivo inválida." );

        }

        var idconhecimento = $("idconhecimento").value;
        var ocorrenciaId = $("ocorrencia_id").value;
        var notaFiscalId = $("slcNotaFiscais").value;
        var descricao = $("descricao").value;

        $("formImg").action ="ImagemControlador?acao=cadastrar&idconhecimento="+idconhecimento+"&descricao=" +descricao+"&ocorrencia_id="+ocorrenciaId+'&nota_fiscal_id='+notaFiscalId;
        $("formImg").target = "pop";
        $("formImg").method = "post";
        
        sessionStorage.setItem('anexar_nfe_selecionada', notaFiscalId);

        window.open('about:blank', 'pop', 'width=210, height=100');
        document.getElementById("formImg").submit();

        return true;
    }
    </c:if>

    function visualizaImagem(imagem){
        window.open("./ImagemControlador?acao=imgpdf&imagem=" + imagem.trim() + "&idconhecimento=" + $("idconhecimento").value, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        //window.open("pops/visualizar_imagem.jsp?imagem=" + imagem, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function visualizaAudio(audio,title){
        window.open("./ImagemControlador?acao=ouvirAudio&imagem=" + audio.trim() + "&idconhecimento=" + $("idconhecimento").value+"&title="+title, "visualizaAudio", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    jQuery(document).ready(function aoCarregarDocumento() {
        // Fazer uma requisição AJAX para obter as informações do CT-e
        jQuery.post('${homePath}/ImagemControlador', {
            acao: 'carregarInfoCTe',
            conhecimento_id: $("idconhecimento").value
        }, function aoCarregarAjaxCTe(data) {
            if (data !== null) {
                jQuery('[data-json]').each((index, value) => {
                    let elemento = jQuery(value);
                    
                    elemento.text(data[elemento.attr('data-json')]);
                });
                
                let slcNotaFiscais = jQuery('#slcNotaFiscais');
                
                data['notas_fiscais'].forEach((value) => {
                    slcNotaFiscais.append(jQuery('<option>', {'value': value['id']}).text(value['numero']));
                });
                
                if (sessionStorage.getItem('anexar_nfe_selecionada') !== null) {
                    slcNotaFiscais.val(sessionStorage.getItem('anexar_nfe_selecionada'))
                }
            }
        }, 'json');
    });
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Visualização de comprovante de Entrega</title>
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
        <img src="img/banner.gif"  alt=""><br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td>
                    <div align="left"><b>Visualização de comprovante de Entrega</b></div>
                </td>
                <td><input type="button" value=" Fechar " class="botoes" onClick="window.close();"/></td>
            </tr>
        </table>

        <br>

        <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
            <tr class="celula">
                <td height="20" width="5%" style="white-space: nowrap;">CT-e:</td>
                <td height="20" width="5%" style="white-space: nowrap;text-align: left;"><label data-json="numero"></label></td>
                <td height="20" width="5%" style="white-space: nowrap;">Série:</td>
                <td height="20" width="4%" style="white-space: nowrap;text-align: left;"><label data-json="serie"></label></td>
                <td height="20" width="5%" style="white-space: nowrap;">Filial:</td>
                <td height="20" width="5%" style="white-space: nowrap;text-align: left;"><label data-json="filial"></label></td>
                <td height="20" width="5%" style="white-space: nowrap;">Emissão:</td>
                <td height="20" width="6%" style="white-space: nowrap;text-align: left;"><label data-json="emissao"></label></td>
                <td height="20" width="5%" style="white-space: nowrap;">Cliente:</td>
                <td height="20" width="20%" style="white-space: nowrap;text-align: left;"><label data-json="cliente"></label></td>
            </tr>
            <tr class="celula">
                <td height="20" style="white-space: nowrap;" colspan="2">Anexo da NF:</td>
                <td height="20" style="white-space: nowrap;text-align: left;padding-left: 5px;" colspan="8">
                    <select class="inputtexto" style="width: 150px;" id="slcNotaFiscais">
                        <option value="todas" selected>Todas</option>
                    </select>
                </td>
            </tr>

            <c:if test="${param['visualizar'] ne 'true'}">
            <form method="post" id="formImg" target="pop" enctype="multipart/form-data">
                <tr class="celula">
                    <td height="20" style="white-space: nowrap;" colspan="7">
                        <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="20" class="inputtexto" multiple="multiple"/>
                    </td>
                        <td align="right" colspan="1">
                            Descrição:
                        </td>
                        <td align="left" colspan="2">
                            <input name="descricao" type="text" id="descricao" size="25" maxlength="25" value="" class="inputtexto">
                        </td>
                </tr>
                <tr class="celula">
                    <td colspan="10">
                        <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar imagem na documentação do conhecimento  "
                               onClick="tryRequestToServer(function(){anexaImg();});">
                     
                    </td>
                </tr>

            </form>
            </c:if>
        </table>
        <form action="../ImagemControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
            <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                <thead>
                <tr class="tabela">
                    <td width="10%"></td>
                    <td width="37%"><label>Descrição</label></td>
                    <td width="20%"><label>Ocorrência</label></td>
                    <td width="20%"><label>Nota Fiscal</label></td>
                    <c:if test="${param['visualizar'] ne 'true'}">
                        <td width="5%"></td>
                    </c:if> 
                </tr>
                </thead>
                <c:forEach var="conhecimentoImagem" varStatus="conhecimentoImagemStatus" items="${listaListImagem}">
                    <tr class="${conhecimentoImagemStatus.count % 2 eq 0 ? "CelulaZebra1" : "CelulaZebra2"}">
                        <td align="center" height="60px">
                            <c:choose>
                                <c:when test="${fn:containsIgnoreCase(conhecimentoImagem.extensao, 'pdf')}">
                                    <img width="24" height="24" src="${homePath}/img/pdf.gif" class="imagemLink"
                                         onclick="visualizaImagem('${homePath}/img/conhecimento/${conhecimentoImagem.conhecimento.id}_${conhecimentoImagem.id}.${conhecimentoImagem.extensao}')"
                                         alt="Imagem">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(conhecimentoImagem.extensao, 'xml')}">
                                    <img width="24" height="24" src="${homePath}/img/xml.png" class="imagemLink"
                                         onclick="visualizaImagem('/img/conhecimento/${conhecimentoImagem.conhecimento.id}_${conhecimentoImagem.id}.${conhecimentoImagem.extensao}')"
                                         alt="Imagem">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(conhecimentoImagem.extensao, 'mp3')}">
                                    <img width="50px" height="50px" src="${homePath}/img/musica.png" class="imagemLink"
                                         onclick="visualizaAudio('/img/conhecimento/${conhecimentoImagem.conhecimento.id}_${conhecimentoImagem.id}.${conhecimentoImagem.extensao}', '${conhecimentoImagem.descricao}')"
                                         alt="Imagem">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(conhecimentoImagem.extensao, 'txt')}">
                                    <img width="24" height="24" src="${homePath}/img/jpg.png" class="imagemLink"
                                         onclick="visualizaImagem('/img/conhecimento/${conhecimentoImagem.conhecimento.id}_${conhecimentoImagem.id}.${conhecimentoImagem.extensao}')"
                                         alt="Arquivo OCOREN">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(conhecimentoImagem.extensao, 'jpg')
                                 or fn:containsIgnoreCase(conhecimentoImagem.extensao, 'jpeg') 
                                 or fn:containsIgnoreCase(conhecimentoImagem.extensao, 'gif')
                                 or fn:containsIgnoreCase(conhecimentoImagem.extensao, 'png')}">
                                    <img width="50px" height="50px" src="${homePath}/img/conhecimento/${conhecimentoImagem.conhecimento.id}_${conhecimentoImagem.id}.${conhecimentoImagem.extensao}" class="imagemLink"
                                         onclick="visualizaImagem('/img/conhecimento/${conhecimentoImagem.conhecimento.id}_${conhecimentoImagem.id}.${conhecimentoImagem.extensao}')"
                                         alt="Imagem">
                                </c:when>
                            </c:choose>
                        </td>
                        <td>
                            <strong>${conhecimentoImagem.descricao}</strong>
                        </td>
                        <td>
                            <strong>
                                <c:if test="${conhecimentoImagem.ocorrencia.ocorrencia.codigo != null}">
                                    ${conhecimentoImagem.ocorrencia.ocorrencia.codigo} - ${conhecimentoImagem.ocorrencia.ocorrencia.descricao}
                                </c:if>
                            </strong>
                        </td>
                        <td>
                            <strong>
                                <c:choose>
                                    <c:when test="${conhecimentoImagem.notaFiscal.numero != null}">
                                        ${conhecimentoImagem.notaFiscal.numero}
                                    </c:when>
                                    <c:otherwise>
                                        Todas as notas
                                    </c:otherwise>
                                </c:choose>
                            </strong>
                        </td>
                        <c:if test="${param['visualizar'] ne 'true'}">
                            <td align="center">
                                <img src="img/lixo.png" alt="Excluir esta imagem" class="imagemLink"
                                     onclick="tryRequestToServer(function(){excluirImagem('${conhecimentoImagem.id}');});"
                                     width="22" height="24" border="0">
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
            
                <input type="hidden" name="idconhecimento" id="idconhecimento" value="${param['idconhecimento']}">
                <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="${param['ocorrencia_id']}">
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
