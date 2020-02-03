<%-- 
    Document   : cadastrar_caixa_postal_seguradora
    Created on : 26/05/2015, 09:56:20
    Author     : eli
--%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">
    jQuery.noConflict();
    
    function stAba(menu,conteudo){
        this.menu = menu;
        this.conteudo = conteudo;
    }
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
    
    function carregar() {
        try{
            var action = '<c:out value="${param.acao}"/>';
                $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
                $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
                
            if(action == 2){
                $("id").value = '<c:out value="${caixaPostal.id}"/>';
                $("descricao").value = '<c:out value="${caixaPostal.descricao}"/>';
                $("codaverbacao").value = '<c:out value="${caixaPostal.codigoAverbacao}"/>';
                $("login").value = '<c:out value="${caixaPostal.loginAverbacao}"/>';
                $("senha").value = '<c:out value="${caixaPostal.senhaAverbacao}"/>';
                
            }
            
        } catch (e) {
            alert(e);
        }
    }
    
    function salvar() {   
           
    if(($("descricao").value).trim() == "" || $("descricao").value == null){
            alert("O campo 'Descrição' não pode ficar em branco!");  
            $("descricao").focus();
            return false;
        }else if(($("codaverbacao").value).trim() == "" || $("codaverbacao").value == null){
            alert("O campo 'Código de Averbação' não pode ficar em branco!");
            return false;
        }else if(($("login").value).trim() == "" || $("login").value == null){
            alert("O campo 'Login' não pode ficar em branco!");
            return false;
        }else if(($("senha").value).trim() == "" || $("senha").value == null){
            alert("O campo 'senha' não pode ficar em branco!");
            return false;
        }
        
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").submit();
        return true;
        
    }
    
    function voltar() {
        tryRequestToServer(function(){(window.location  = "CaixaPostalSeguradoraControlador?acao=listar")});
    
    }
    function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "caixa_postal_seguradora";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    
    
</script>    

<!DOCTYPE html>
<html>
    <style>
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
        <title>WebTrans - Cadastro de Caixa Postal de Seguradora</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css"></style>
    </style>
    </head>
    <body onLoad="carregar(); applyFormatter();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria');">
        <img src="img/banner.gif">
        <br>
        <form action="CaixaPostalSeguradoraControlador?acao=${param.acao == 2 ? "editar": "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" name="id" id="id" value="0">
            <table width="50%" align="center" class="bordaFina" >
                <tr>
                    <td width="82%" align="left"> <span class="style4">Cadastro de Caixa Postal de Seguradora</span></td>
                <td width="18%" align="right">
                    <input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/>
                </td>
                </tr>
                
            </table>
        <br>
            <table width="50%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td colspan="5" align="center">Dados principais</td>
                </tr>
                <tr>
                    <td class="TextoCampos">Descrição:</td>
                    <td colspan="5" class="CelulaZebra2">
                        <input name="descricao" type="text" id="descricao" value="" size="20" maxlength="40" class="inputtexto">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">C&oacute;digo de Averbaç&atilde;o:</td>
                    <td colspan="5" class="CelulaZebra2">
                        <input name="codaverbacao" type ="text" id="codaverbacao" value="" size="20" maxlength="20" class="inputtexto">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Login:</td>
                    <td class="CelulaZebra2">
                        <input name="login" type="text" id="login" value="" size="10" maxlength="20" class="inputtexto">
                    </td>
                    <td class="TextoCampos">Senha:</td>
                    <td class="CelulaZebra2">
                        <input name="senha" type="password" id="senha" value="" size="10" maxlength="20" class="inputtexto">
                    </td>    
                </tr>
            </table>
                <table width="50%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdAbaAuditoria" name="tdAbaAuditoria" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                  
                                </tr>
                            </table>
                        </td> 
                    </tr>                   
                </table>       
                 
                 <table align="center"  width="50%" class="bordaFina" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' >
                    <tr>
                        <td>
                              <div id="divAuditoria" width="80%" >
                                  
                                <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                  <%@include file="template_auditoria.jsp" %>
                                </table>
                              </div> 
                        </td>            
                     </tr>
                          <tr>
                              <tr>
                                  <td colspan="6">
                                      <table class="bordaFina" align="center" width="100%">
                                        <tr class="CelulaZebra2">
                                           <td class="TextoCampos" width="15%">Incluso:</td>
                                           <td class="CelulaZebra2" width="35%"> 
                                              em: ${caixaPostal.criadoEm} <br/> por: ${caixaPostal.criadoPor.nome}
                                            </td>
                                            <td class="TextoCampos" width="15%">Alterado:</td>
                                            <td class="CelulaZebra2" width="35%">
                                            em: ${caixaPostal.alteradoEm} <br/> por: ${caixaPostal.alteradoPor.nome}
                                            </td>
                                        </tr>
                                       </table>
                                   </td>
                               </tr>
                              
                        </tr>
                 </table>
                    
                                           <br/>
                       <table align="center"  width="50%" class="bordaFina" >          
                        <tr>
                          <c:if test="${param.nivel >= param.bloq}">
                            <td colspan="6" class="CelulaZebra2" >
                                <div align="center">
                                    <input type="button" value="  SALVAR  " class="inputbotao" id="botSalvar" onclick="salvar()"/>
                                </div>
                            </td>
                                </c:if>
                        </tr>
                       </table> 
        </form>
        
    </body>
</html>
