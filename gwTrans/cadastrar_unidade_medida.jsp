<%-- 
    Document   : cadastrar_UnidadeMedida
    Created on : 16/12/2008, 15:43:49
    Author     : Vladson Pontes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">

    jQuery.noConflict();
    
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria', 'divAuditoria');
    
    function carregar() {
        var action = '<c:out value="${acaoCadUnidadeMedida}"/>';
        var form = document.formulario;
        
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        
        if (action == 2) {

            form.sigla.value = '<c:out value="${unidadeCadUnidadeMedida.sigla}"/>';
            form.descricao.value = '<c:out value="${unidadeCadUnidadeMedida.descricao}"/>';
            form.idUnidadeMedida.value = '<c:out value="${unidadeCadUnidadeMedida.id}"/>';
 }
        form.sigla.focus();
    }

    function voltar() {
        tryRequestToServer(function() {
            (window.location = "ConsultaControlador?codTela=38")
        });
    }

    function salvar() {
        var formu = document.formulario;
        
        if (formu.descricao.value == "") {
            alert("O campo 'Descrição' não pode ficar em branco!");
            formu.descricao.focus();
            return false;
        }

        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        formu.submit();
        return true;

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
                var rotina = "unidade_medida";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("idUnidadeMedida").value;
                console.log(id);
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
        <title>Webtrans - Cadastro de Unidades de Medida</title>
    </head>
    <body onload="carregar();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de Unidades de Medida</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>

        <!-- codigo de verificaao de acao editar = 2  ou cadastrar = ?? -->

        <form action="UnidadeMedidaControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}"  id="formulario" name="formulario" method="post" target="pop">
            <table width="50%" align="center" class="bordaFina" >

                <tr>
                    <td colspan="4" align="center" class="tabela" >Dados principais</td>
                </tr>

                <tr>          
                    <td class="TextoCampos">*Sigla:</td>                        
                    <td class="CelulaZebra2"><input name="sigla" type="text" class="inputtexto" size="7" maxlength="6"  />
                        <input type="hidden" name="idUnidadeMedida" id="idUnidadeMedida"/>
                    </td>
                    <td class="TextoCampos" width="20%">*Descrição:</td>                        
                    <td class="CelulaZebra2" width="30%"><input name="descricao" id="descricao" type="text" class="inputtexto" size="20" maxlength="20"  />
                    </td> 
                </tr>
           </table> 
            
              <table align="center" width="50%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       <td style='display:${acaoCadUnidadeMedida == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
            <table align="center"  width="50%" class="bordaFina" style='display:${acaoCadUnidadeMedida == 2 && param.nivel == 4 ? "" : "none"}' >
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
                                <td colspan="4"> 
                                    <table width="100%" align="center" class="bordaFina">
                                        <tr class="CelulaZebra2">
                                            <td class="TextoCampos" width="15%"> Incluso:</td>

                                            <td width="35%" class="CelulaZebra2"> em: ${unidadeCadUnidadeMedida.criadoEm} <br>
                                                por: ${unidadeCadUnidadeMedida.criadoPor.nome} 
                                            </td>

                                            <td width="15%" class="TextoCampos"> Alterado:</td>
                                            <td width="35%" class="CelulaZebra2"> em: ${unidadeCadUnidadeMedida.atualizadoEm} <br>
                                                por: ${unidadeCadUnidadeMedida.atualizadoPor.nome}
                                            </td>
                                        </tr>   
                                    </table>                  
                                </td>
                            </tr>

                </table>
                  
                       <br/>
                        <table class="bordaFina" width="50%" align="center" style='display: ${param.nivel >= param.bloq ? "" : " none" }'>
                            <tr>
                                <td colspan="6" class="CelulaZebra2" >
                                    <div align="center">
                                        <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                                    </div>
                                </td>
                            </tr>
                        </table>
                <br/>  
        </form>

    </body>
</html>

