

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
    function voltar(){
        tryRequestToServer(function(){(window.location = "InutilizacaoControlador?acao=listar")});
    }

    function salvar(){
        var formu = document.formulario;
        if(formu.serie.value == ""){
            alert("O campo 'Série' não pode ficar em branco!");
            formu.serie.focus();
            return false;
        }

        if(formu.nfIni.value == ""){
            alert("O campo 'CTRC de' não pode ficar em branco!");
            formu.nfIni.focus();
            return false;
        }

        if(formu.nfFin.value == ""){
            alert("O campo 'CTRC até' não pode ficar em branco!");
            formu.nfFin.focus();
            return false;
        }

        if(formu.motivo.value.trim() == ""){
            alert("O campo 'Motivo' não pode ficar em branco!");
            formu.motivo.focus();
            return false;
        }
        
        if (parseFloat(formu.nfIni.value) > parseFloat(formu.nfFin.value)) {
            alert("O campo 'CTRC de' não pode ser maior que 'CTRC até'!");
            formu.nfIni.focus();
            return false;
        }
        
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        formu.submit();
        return true;
    }
    
    function soNumeros(v){
      return v.replace(/\D/g,"")
    }
    
    function removeZeros(z){
        return z.replace(/^0+/,'') 
    }
    
    
    function carregar(){      
        var nivel = parseInt('<c:out value="${param.nivelCte}"/>' ) ;
        document.formulario.filial.value = '<c:out value="${param.filial}"/>';
        if (nivel >0){
            document.formulario.filial.disabled = false;
        }else{
                document.formulario.filial.disabled = true;              
        }
    }
    
    
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
        <title>Webtrans - Inutilização Numeração CT-e</title>
    </head>
    <body onload="carregar()">
        <img alt="Webtrans" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Inutilização Numeração CT-e</span></td>
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <form action="InutilizacaoControlador?acao=inutilizar" id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" name="id" id="id" value="0"/>
            <table width="50%" align="center" class="bordaFina" >
                <tr>
                <input type="hidden" name="modulo" id="modulo" value="gwLogis"/>
                <td width="100%"  align="center" class="tabela" colspan="6">Dados principais</td>
                </tr>
                <tr>
                    <td width="15%" class="TextoCampos">*Série:</td>
                    <td width="15%" class="CelulaZebra2">
                        <input name="serie" type="text" class="inputtexto" id="serie" maxlength="3" size="4" value="1">
                    </td>
                    <td width="20%" class="TextoCampos">*CT-e de:</td>
                    <td width="15%" class="CelulaZebra2">
                        <input name="nfIni" type="text" class="inputtexto" id="nfIni" value="" maxlength="6" size="8" onkeypress="mascara(this, soNumeros)" onblur="mascara(this, removeZeros)">
                    </td>
                    <td width="20%" class="TextoCampos">*CT-e até:</td>
                    <td width="15%" class="CelulaZebra2">
                        <input name="nfFin" type="text" class="inputtexto" id="nfFin" value="" maxlength="6" size="8" onkeypress="mascara(this, soNumeros)" onblur="mascara(this, removeZeros)">
                    </td>
                </tr>
                <tr>
                    <td  class="TextoCampos">*Motivo:</td>
                    <td colspan="3" class="CelulaZebra2">
                        <input name="motivo" type="text" class="inputtexto" id="motivo" value="" maxlength="255" size="60">
                    </td>
                    <td  class="TextoCampos">Filial:</td>
                    <td  class="TextoCampos" colspan="2">
                        <select name="filial" id="filial" class="inputtexto">
                            <c:forEach var="filial" items="${filiaisListSaidaMercadoria}">
                                <option value="${filial.id}">Apenas a ${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra2" colspan="6">
                        <div align="center">
                            <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                        </div>
                    </td>
                </tr>
            </table>
        </form>

    </body>
</html>
