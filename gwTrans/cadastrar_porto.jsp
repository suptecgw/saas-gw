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
    jQuery.noConflict();
    
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
     
    function carregar(){
        var action = '<c:out value="${acaoCadPorto}"/>';
        var form = document.formulario;
        
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        
        if(action == 2){          
            
            form.descricao.value = '<c:out value="${unidadeCadPorto.descricao}"/>';
            form.idPorto.value = '<c:out value="${unidadeCadPorto.id}"/>'

            
        }
    }
    
    function voltar(){
        location.replace("ConsultaControlador?codTela=33");
    }
    
    function salvar(){
        var formu = document.formulario;   
        
        if(formu.descricao.value.trim() == ""){
            alert("O campo 'Descrição' não pode ficar em branco!");             
            formu.descricao.focus();
            return false;            
        }       
        
        setEnv(); 
        window.open('about:blank', 'pop', 'width=210, height=100');
        
        formu.submit();
        return true;
            
    }
     function mostrarCampos(imgElement) {
                if (imgElement != null && imgElement != undefined) {
                    var idx = imgElement.id.split("_")[1];
                    var estado = imgElement.src;
                    if (estado.indexOf("plus.jpg") > -1) {
                        visivel($("tr2Log_" + idx));
                        imgElement.src = "img/minus.jpg";
                    } else if (estado.indexOf("minus.jpg") > -1) {
                        invisivel($("tr2Log_" + idx));
                        imgElement.src = "img/plus.jpg";
                    }
                }
    }
    
    
      function pesquisarAuditoria() {    
                console.log("countLog: "+countLog);
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }
                countLog = 0;
                var rotina = "porto";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("idPorto").value;
                consultarLog(rotina, id, dataDe, dataAte);
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
        <title>Webtrans - Cadastro de Porto</title>
    </head>
    <body onload="carregar();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de Porto</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>

        <!-- codigo de verificaao de acao editar = 2  ou cadastrar = ?? -->
         
        <form action="PortoControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}"  id="formulario" name="formulario" method="post" target="pop">
         <table width="50%" align="center" class="bordaFina" >

                <tr>
                    <td colspan="4" align="center" class="tabela" >Dados principais</td>
                </tr>

                <tr>
                    <td class="TextoCampos" width="20%">Descrição:</td>                        
                    <td class="CelulaZebra2" width="30%"><input name="descricao" id="descricao" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                <input type="hidden" value="" name="idPorto" id ="idPorto">
                </tr>
                
         </table>
         
         <table align="center" width="50%">
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       <td style='display: ${acaoCadPorto == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
              <c:if test="${acaoCadPorto == 2 && param.nivel == 4}">  
                 <table align="center"  width="50%" class="bordaFina" >
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
                                    <td colspan="8"> 
                                                <table width="100%" align="center" class="bordaFina">        
                                                   <tr class="CelulaZebra2">
                                                       <td class="TextoCampos" width="15%"> Incluso:</td>

                                                       <td width="35%" class="CelulaZebra2"> em: ${unidadeCadPorto.createdAt} <br>
                                                           por: ${unidadeCadPorto.createdBy.nome} 
                                                       </td>

                                                       <td width="15%" class="TextoCampos"> Alterado:</td>
                                                       <td width="35%" class="CelulaZebra2"> em: ${unidadeCadPorto.updatedAt} <br>
                                                           por: ${unidadeCadPorto.updatedBy.nome}
                                                       </td>
                                                   </tr>   
                                                </table>
                                           </td>
                                </tr> 
                                   
                    </table>
                 </c:if>                            <br/>
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

