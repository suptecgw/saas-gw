<%-- 
    Document   : cadastrar_porto
    Created on : 17/06/2013, 13:26:45
    Author     : Anderson Espana
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" import="nucleo.Apoio"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>

<script type="text/javascript" language="JavaScript">   

    function carregar(){

    }
    
    function voltar(){
        window.close();
    }
    
    function salvar(){
        var formu = document.formulario;   
        
        if (document.getElementById("chaveAcesso").value == "" || document.getElementById("chaveAcesso").length == 44) {
            alert("Chave de acesso não pode ser vazia e precisa ter 44 caracteres!");
            return false;
        }
        if (document.getElementById("protocolo").value == "") {
            alert("Protocolo não pode ficar em branco");
            return false;
        }
        if (document.getElementById("cnpj").value == "") {
            alert("Cnpj não pode ficar em branco");
            return false;
        }
        if (document.getElementById("codigo_ibge_destino").value == "") {
            alert("Cidade de encerramento não pode ficar em branco");
            return false;
        }
        
        window.open('about:blank', 'pop', 'width=210, height=100');
        formu.action = "MDFeControlador?acao=encerrar";
        formu.submit();
        return true;
            
    }
    
    function limparCidade(){
        document.getElementById("destino").value = "";
        document.getElementById("codigo_ibge_destino").value = "";
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
        <title>Webtrans - Encerrar MDFe</title>
    </head>
    <body >
        <img src="img/banner.gif" width="30%" height="80">

        <table class="bordaFina" width="60%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Encerrar Manifesto (${param.stUtilizacaoMDFe == "H" ? "Homologação" : "Produção"})</span></td>
            </tr>
        </table>
        <br>

        <form action="MDFeControlador?acao=encerrar"  id="formulario" name="formulario" method="post" target="pop">
         <table width="60%" align="center" class="bordaFina" >

                <tr>
                    <td colspan="4" align="center" class="tabela" >Dados principais</td>
                </tr>

                <tr>
                    <td class="TextoCampos" width="20%">Chave de Acesso:</td>                        
                    <td class="CelulaZebra2" width="30%">
                        <input name="chaveAcesso" id="chaveAcesso" type="text" value="" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                </tr>
                <tr>
                    
                    <td class="TextoCampos" width="20%">
                        <label>Protocolo:</label>
                    </td>
                    <td class="CelulaZebra2" width="30%">
                        <input name="protocolo" id="protocolo" type="text" class="inputtexto" size="20" />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%">
                        Cnpj:
                    </td>
                    <td class="CelulaZebra2" width="30%">
                        <input name="cnpj" readonly id="cnpj" value="${filial.abreviatura}" type="text" class="inputReadOnly" size="10" />
                        <input name="numeroCnpj" id="numeroCnpj" value="${filial.cnpj}" type="hidden" class="inputtexto" />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="20%">
                      Cidade de encerramento:
                    </td>
                    <td class="CelulaZebra2" width="30%">
                        <input name="destino" type="text" id="destino" class="inputReadOnly8pt" size="24" readonly="true">
                        <input name="codigo_ibge_destino" type="hidden" value="" id="codigo_ibge_destino" class="inputReadOnly8pt">
                        <input name="localiza_cidade" type="button" class="botoes" id="localiza_cidade" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=12','Cidade','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limparCidade()"/>
                    </td>
                </tr>    
                
                <tr >
                    <td class="CelulaZebra2" colspan="2">
                        <center>
                            <input type="button" id="encerrar" name="encerrar" class="botoes" value="Encerrar" onclick="salvar();" >
                        </center>
                    </td>
                </tr>
                
        </table>
           
        </form>

    </body>
</html>

