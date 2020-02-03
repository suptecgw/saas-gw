<%-- 
    Document   : login_supervisor
    Created on : 17/01/2015, 23:22:17
    Author     : paulo
--%>

<%@page import="nucleo.Apoio"%>
<%@page import="viagem.BeanCadViagem"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type=""></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>"   type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
<!--<script type="text/javascript" src="script/< %=Apoio.noCacheScript("jquery-1.11.2.min.js")%>"></script>-->
<script type="text/javascript" language="javascript">
   jQuery.noConflict();
   
    function validarSenhaSupervisor(){
        espereEnviar("Aguarde...",true);
        
        if ($("login") != null) {
            if ($("login").value.trim() == ""){
                alert("Login invalido!");
                $("login").focus();                
                espereEnviar("Aguarde...",false);
                return false;
            }
        }
        if ($("senha") != null) {
            if ($("senha").value.trim() == "") {
                alert("Senha invalida!");
                $("senha").focus();
                espereEnviar("Aguarde...",false);
                return false;
            }
        }
        var login = $("login").value;
        var senha = $("senha").value;
        var tipoAutorizacao = ${param.tipoAutorizacao};
        var miliSegundos = 0;
        var idCidadeOrigem = 0;
        var idCidadeDestino = 0;
        var idVeiculo = 0;
        var idMotorista = 0;
        
        //Autorizacao para tela ADV = 0
        if (tipoAutorizacao == 0) {
            miliSegundos = '${param.miliSegundos}';
            idVeiculo = ${param.idVeiculo};
            
        }else if(tipoAutorizacao == 1 || tipoAutorizacao == 3 || tipoAutorizacao == 4){//Autorizacao para tela CT-e = 1
            miliSegundos = '${param.miliSegundos}';
            idCidadeOrigem = '${param.idCidadeOrigem}';
            idCidadeDestino = '${param.idCidadeDestino}';            
            idVeiculo = ${param.idVeiculo};            
        }else if (tipoAutorizacao == 2 || tipoAutorizacao == 5) {
            miliSegundos = '${param.miliSegundos}';
            idMotorista = '${param.idMotorista}';
            idVeiculo = '${param.idVeiculo}';
        }
        if (tipoAutorizacao == 2) {
               jQuery.ajax({
                    url: '<c:url value="/AutorizacaoControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        login : login,
                        senha : senha,
                        miliSegundos : miliSegundos,
                        idVeiculo : idVeiculo,
                        idMotorista : idMotorista,
                        tipoAutorizacao : tipoAutorizacao,
                        acao : "validarSenhaSupervisorContratoFrete"
                    },
                    success: function(data) {
                        espereEnviar("Aguarde...",false);
                        if (data=="") {
                            alert("Liberado com sucesso");
                            window.close();    
                        }else{
                            alert(data);                            
                        }
                    }
                });
    
        }else {
                jQuery.ajax({
                    url: '<c:url value="/AutorizacaoControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        login : login,
                        senha : senha,
                        miliSegundos : miliSegundos,
                        idCidadeOrigem : idCidadeOrigem,
                        idCidadeDestino : idCidadeDestino,
                        idVeiculo : idVeiculo,
                        tipoAutorizacao : tipoAutorizacao,
                        acao : "validarSenhaSupervisor"
                    },
                    success: function(data) {
                        espereEnviar("Aguarde...",false);
                        if (data=="") {
                            alert("Liberado com sucesso");
                            window.close();    
                        }else{
                            alert(data);                            
                        }
                    }
                });
            }
}
       
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <title>Login do Supervisor</title>
        <style>
            .inputtexto {
                font-family: Verdana, Arial, Helvetica, sans-serif;
                font-size: 11px;
                border: 1px solid #51A1BE;
            }
            
            .inputbotao {
                font-family: Verdana, Arial, Helvetica, sans-serif;
                font-size: 11px;
                border: 1px solid #003366;
                background-color:#2E76A6;
                color:#FFFFFF;
            }
        </style>
    </head>
    <body>
        <!--<img src="img/topo_gweb.jpg" width="90%" height="26" align="middle">-->
        <div align="center">
            <img src="img/banner.gif" >            
        </div>
        <br>
        <form name="formulario" action="UsuarioControlador?acao=validarSenhaSupervisor" method="post">
            
            <table class="bordaFina" align="center">
                <tr>
                    <td colspan="2" class="tabela"> Autorização do Supervisor </td>
                </tr>
                <label name="mensagem" id="mensagem"><b>ATENÇÃO:<br> Existe OS em aberto para esse Veículo  ${param.placaVeiculo}  é necessário autorização do Supervisor!</label><br><br>
                
                <tr class="TextoCampos">
                    <td class="TextoCampos" align="right">
                        Login:
                    </td>
                    <td >
                        <input class="inputtexto" name="login" type="text" value="" id="login" size="15" maxlength="13">
                    </td>
                </tr>
                <tr class="TextoCampos">
                    <td class="TextoCampos" align="right">
                        Senha:
                    </td>
                    <td>
                        <input class="inputtexto" name="senha" type="password" value="" id="senha" size="15" maxlength="13">
                    </td>
                </tr>
                <tr class="TextoCampos">
                    <td colspan="2" align="center">
                        <input class="inputbotao" name="Button" type="button"  value="Autenticar" onclick="validarSenhaSupervisor();" > &nbsp;
                        <input class="inputbotao" name="Button" type="button"  value="Cancelar" onclick="window.close()">
                    </td>
                </tr>
            </table>
            <br>
        </form>
    </body>
</html>
