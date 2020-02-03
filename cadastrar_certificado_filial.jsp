<%@page import="br.com.gwsistemas.filial.certificado.Certificado"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script language="JavaScript"  src="./script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="./script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="./script/builder.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" >  

   
  
    function anexaImg(){
               
        var arqImg01 = $("arqImg01").value;
                
        if (arqImg01 == ""){
            alert("Selecione a Imagem!");
            return false;
        }
        var extensoesOk = ",.pfx,";

        var extensao    = "," + arqImg01.substr( arqImg01.length - 4 ).toLowerCase() + ",";
        if( extensoesOk.indexOf( extensao ) == -1 ){
            return  alert( "Extensão de Arquivo Inválida!" );
        }
       
        var idFilial = $("idFilial").value;
        var senha = $("senha").value;
            
        $("formCertificado").action ="CertificadoControlador?acao=cadastrar&idFilial="+idFilial+"&arqImg01="+arqImg01+"&senha="+senha;
        $("formCertificado").target = "pop";
        $("formCertificado").method = "post";       

        window.open('about:blank', 'pop', 'width=210, height=100');
        document.getElementById("formCertificado").submit();
       
        window.close();
    }   
    
    function carregar(){
        $("idFilial").value = '${param.idFilial}'; 
        $("senha").value = '';
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

        <title>WebTrans - Visualiza&ccedil;&atilde;o de Certificado da Filial</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                      font-size: 13px;
            }
            -->
        </style>
    </head>
    <body onload="carregar();">
        <img src="./img/banner.gif"  alt="">
        <br>
       <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
           <form  method="post" id="formCertificado" name="formCertificado" target="pop" enctype="multipart/form-data">
                <tr class="celula">
                    <td >
                        <div align="center">
                        <input name="arqImg01" id="arqImg01" type="file" style="font-size:8pt;"  size="50" class="inputtexto"/></div>
                    </td>       
                     <div align="center">
                    <td width="5%" class="CelulaZebra1" colspan="1">Senha:</td>
                    <td width="5%" class="CelulaZebra1" colspan="3">
                              <input name="senha" type="password" id="senha" class="inputtexto" value="">
                    </td>
                     </div>
                
                
               
                    <td colspan="3">
                        <input name="anexar01" type="button" class="botoes" id="anexar01" value="   Anexar certificado na filial  "
                               onClick="javascript:tryRequestToServer(function(){anexaImg();});">                     
                    </td>
                </tr>
             </form>
        </table>
       
        <form action="CertificadoControlador?acao=carregar" id="formulario" name="formulario" method="post" target="pop" enctype="multipart/form-data">
            <table width="95%" align="center" cellspacing="1" cellpadding="0" class="bordaFina">
                 <tr class="CelulaZebra1"> 
                        <td><c:out value="${cert.caminho}"/></td>
                       
                 </tr>
            </table> 
        </form>
     <input type="hidden" name="idFilial" id="idFilial" >    
  </body>
</html>