<%-- 
    Document   : cadastrar_origem_captacao_cliente
    Created on : 04/04/2014, 16:38:56
    Author     : ramon
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <script language="javascript" type="text/javascript" src="script/builder.js"></script>
        <script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
        <script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
        
        <script language="javascript" type="text/javascript" src="script/jquery.js"></script>
        <script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
        <style type="text/css">
            <!--
            .style3 {color: #333333}
            .style4 {
                font-size: 14px;
                font-weight: bold;
            }
            -->
        </style>


        <script type="text/javascript" language="JavaScript">
  jQuery.noConflict();
 
    arAbasGenerico = new Array();
    arAbasGenerico[0] = stAba('tdAbaAuditoria','divAuditoria');
    
            function carregar() {
                var action = '<c:out value="${acaoCadOrigemCaptacao}"/>';
                var form = document.formulario;
                 $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
                 $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        
                if (action == 2) {

                    form.descricao.value = '<c:out value="${unidadeCadOrigemCaptacao.descricao}"/>';
                    form.idOrigemCaptacao.value = '<c:out value="${unidadeCadOrigemCaptacao.id}"/>';
}
                form.descricao.focus();
            }

            function voltar() {
                tryRequestToServer(function() {
                    (window.location = "OrigemCaptacaoControlador?acao=listar&modulo=webtrans")
                });
            }

            function salvar() {
                var formu = document.formulario;


                if (formu.descricao.value.trim() == "") {
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
                        var rotina = "origem_captacao_cliente";
                        var dataDe = $("dataDeAuditoria").value;
                        var dataAte = $("dataAteAuditoria").value;
                        var id = $("idOrigemCaptacao").value;
                        console.log(id);
                        consultarLog(rotina, id, dataDe, dataAte);

                    }


        </script> 




        <title>WebTrans - Cadastro de Origens de Captação de Cliente</title>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de Origens de Captação de Cliente</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>

        <form action="OrigemCaptacaoControlador?acao=${param.acao == '1' ? "cadastrar" : "editar"}"  id="formulario" name="formulario" method="post" target="pop">
            <table width="50%" align="center" class="bordaFina" >
                <tr>
                    <td colspan="4" align="center" class="tabela" >Dados principais</td>
                </tr>
                <tr>          
                    <td class="TextoCampos" width="20%">*Descrição:</td>                        
                    <td class="CelulaZebra2" width="30%"><input name="descricao" id="descricao" type="text" class="inputtexto" size="50" maxlength="50"  />
                    <input type="hidden" name="idOrigemCaptacao" id="idOrigemCaptacao"/>
                    </td> 
                </tr>
            </table>
            
            <table align="center" width="50%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                                    </tr>
                                </table>
                            </td> 
                        </tr>
             </table>
               <div id="divAuditoria" >
                   <table width="50%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                        <tr>
                        <%@include file = "/gwTrans/template_auditoria.jsp" %>
                     
                                      
                       
                        </tr>
                            <tr>
                                <td colspan="8"> 
                                    <table width="100%" align="center" class="bordaFina">
                                        <tr class="CelulaZebra2">
                                            <td class="TextoCampos" width="15%"> Incluso:</td>

                                            <td width="35%" class="CelulaZebra2"> em: ${unidadeCadOrigemCaptacao.criadoEm} <br>
                                                por: ${unidadeCadOrigemCaptacao.criadoPor.nome} 
                                            </td>

                                            <td width="15%" class="TextoCampos"> Alterado:</td>
                                            <td width="35%" class="CelulaZebra2"> em: ${unidadeCadOrigemCaptacao.atualizadoEm} <br>
                                                por: ${unidadeCadOrigemCaptacao.atualizadoPor.nome}
                                            </td>
                                        </tr>   
                                    </table>                  
                                </td>
                            </tr>
                       
                      </table>
                </div> 
               
            <br>
                       <table width="50%" align="center" class="bordaFina" style='display: ${param.nivel >= param.bloq ? "" : "none"} ' >
                         
                                    <td colspan="4" class="CelulaZebra2" ><div align="center">
                                            <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function() {
                                                        salvar()
                                                    })"/>
                                        </div></td>
                               
                       </table>                
        </form>


    </body>
</html>
