<%-- 
    Document   : configuracaoTecnica
    Created on : 13/10/2015, 16:19:06
    Author     : anderson
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<!--<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>-->
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script type="text/javascript" src="${homePath}/script/tiny_mce/tiny_mce.js"></script>
<script type="text/javascript" language="JavaScript">   
    
    function carregar(){
        var action = '<c:out value="${acao}"/>';
        var form = document.formulario;
            form.linkGweb.value = '<c:out value="${config.linkGweb}"/>';
            form.linkWebtrans.value = '<c:out value="${config.linkWebtrans}"/>';
            form.proxyEndereco.value = '<c:out value="${config.proxyEndereco}"/>';
            form.proxyPorta.value = '<c:out value="${config.proxyPorta}"/>';
            form.caminhoGwBoletos.value = '<c:out value="${config.linkGwBoletos}"/>';
            form.linkGWi.value = '<c:out value="${config.linkGWi}"/>';
            form.caminhoMetadata.value = '<c:out value="${config.linkMetadata}"/>';
    }
    
    function voltar(){
        window.close();
    }
    
    function salvar(){
        var formu = document.formulario;   
        setEnv(); 
        window.open('about:blank', 'pop', 'width=210, height=100');
        
        formu.submit();
        return true;
    }

    tinyMCE.init({
        // General options
        mode: "exact",
        elements: "mensagemErro",
        theme: "advanced",
        plugins: "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups",
        // Theme options
        theme_advanced_buttons1: "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect",
        theme_advanced_buttons2: "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
        theme_advanced_buttons3: "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
        theme_advanced_buttons4: "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak",
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left",
        theme_advanced_statusbar_location: "bottom",
        theme_advanced_resizing: false,
        // Example word content CSS (should be your site CSS) this one removes paragraph margins
        content_css: "css/word.css",
        document_base_url: "",
        // Replace values for the template plugin
        template_replace_values: {
            username: "Some User",
            staffid: "991234"
        }
    });
</script> 

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Configuração Tecnica</title>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="76%" align="center">
            <tr>
                <td width="76%" align="left"> <span class="style4">Configuração Tecnica</span></td>  
                <td><input type="button" value=" Fechar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <form action="ConfiguracaoTecnicaControlador?acao=editar"  id="formulario" name="formulario" method="post" target="pop">
            <table width="76%" align="center" class="bordaFina" >

                <tr>
                    <td colspan="4" align="center" class="tabela" >Dados principais</td>
                </tr>

                <tr>
                    <td class="TextoCampos" width="20%"> Link do GWEB : </td>                        
                    <td class="CelulaZebra2" width="20%"><input name="linkGweb" id="linkGweb" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Link do WEBTRANS : </td>                        
                    <td class="CelulaZebra2" width="20%"><input name="linkWebtrans" id="linkWebtrans" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Link do GW-i : </td>                        
                    <td class="CelulaZebra2" width="20%"><input name="linkGWi" id="linkGWi" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Caminho PROXY : </td>                        
                    <td class="CelulaZebra2" width="20%"><input name="proxyEndereco" id="proxyEndereco" type="text" class="inputtexto" size="20" maxlength="20"  />
                    &nbsp;&nbsp;
                    Porta <input name="proxyPorta" id="proxyPorta" type="text" class="inputtexto" size="5" maxlength="5"/>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Caminho Gw Sistemas : </td>                        
                    <td class="CelulaZebra2" width="20%"><input name="caminhoGwBoletos" id="caminhoGwBoletos" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Caminho Metadata : </td>                        
                    <td class="CelulaZebra2" width="20%"><input name="caminhoMetadata" id="caminhoMetadata" type="text" class="inputtexto" size="50" maxlength="100"  />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Chave App BLiP</td>
                    <td class="CelulaZebra2" width="20%"><input name="blipChaveApp" id="blipChaveApp" type="text" class="inputtexto" size="50" maxlength="100" value="${config.blipChaveApp}"></td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Link Base de Conhecimento </td>
                    <td class="CelulaZebra2" width="20%"><input name="linkBaseDeConhecimento" id="linkBaseDeConhecimento" type="text" class="inputtexto" size="50" maxlength="100" value="${config.linkBaseDeConhecimento}"></td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Link GW OCR </td>
                    <td class="CelulaZebra2" width="20%"><input name="linkGwOCR" id="linkGwOCR" type="text" class="inputtexto" size="50" maxlength="100" value="${config.linkGwOCR}"></td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"> Migração certificado </td>
                    <c:choose>
                        <c:when test="${config.certificadoAtualizadoEm != null}">
                            <td class="CelulaZebra2" width="20%">O certificado foi migrado em ${config.certificadoAtualizadoEmS} por ${config.certificadoAtualizadoPor.nome}</td>
                        </c:when>
                        <c:otherwise>
                            <td class="CelulaZebra2" width="20%">O certificado ainda não foi migrado.</td>
                        </c:otherwise>
                    </c:choose>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%"><label for="mensagemErro"> Mensagem erro : </label></td>
                    <td class="CelulaZebra2" width="20%"><textarea name="mensagemErro" id="mensagemErro" type="text" class="inputtexto" cols="50" rows="10">${config.mensagemErro}</textarea>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" class="CelulaZebra2" >
                        <div align="center">
                            <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                        </div>
                    </td>
                </tr>
            </table>
        </form>

    </body>
</html>

