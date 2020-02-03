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
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">   
    jQuery.noConflict();
    
    var arAbasLayout = new Array();
    arAbasLayout[0] = new setAba('tdAbaAuditoria','divAuditoria');

function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

   function AlterneAba(menu, conteudo) {

        if (arAbasLayout != null) {
            for (i = 0; i < arAbasLayout.length; i++) {
                if (arAbasLayout[i] != null && arAbasLayout[i] != undefined) {
                    m = document.getElementById(arAbasLayout[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasLayout[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasLayout[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasLayout[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasLayout[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    }
    
    
    function carregar(){
        var action = '<c:out value="${param.acao}"/>';
        var form = document.formulario;
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        if(action == 2){          
            form.descricao.value = '<c:out value="${cadLayoutEDI.descricao}"/>';
            form.nomeArquivo.value = '<c:out value="${cadLayoutEDI.nomeArquivo}"/>';
            form.extencaoArquivo.value = '<c:out value="${cadLayoutEDI.extencaoArquivo}"/>';
            form.idLayout.value = '<c:out value="${cadLayoutEDI.id}"/>';
            form.funcao.value = '<c:out value="${cadLayoutEDI.funcao}"/>';
            form.tipoEDI.value = '<c:out value="${cadLayoutEDI.tipoEdi}"/>';

            
        }
    }
    
    function voltar(){
        tryRequestToServer(function(){(window.location = "LayoutEDIControlador?acao=listar&modulo=gwTrans")});
    }
    
    function inserirComplemento(elemento){
        $("nomeArquivo").value += elemento.innerHTML;
    }
    
    function salvar(){
        var formu = document.formulario;
        if($("descricao").value.trim() == ""){
            return showErro("Informe a descrição!", $("descricao"));
        }
        if($("nomeArquivo").value.trim() == ""){
            return showErro("Informe o nome do arquivo!", $("nomeArquivo"));
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
                var rotina = "layout_edi";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("idLayout").value;
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
        <title>Webtrans - Cadastro de Layout para EDI</title>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="65%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de Layout para EDI</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>

        <!-- codigo de verificaao de acao editar = 2  ou cadastrar = ?? -->

        <form action="LayoutEDIControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}"  id="formulario" name="formulario" method="post" target="pop">
            <table width="65%" align="center" class="bordaFina" >

                <tr>
                    <td align="center" class="CelulaZebra2" width="100%">
                        <fieldset>
                            <legend>Dados Principais</legend>
                            <table width="100%" class="tabelaZerada">
                                <tr>          
                                    <td class="TextoCampos" width="20%">*Descrição:</td>                        
                                    <td class="CelulaZebra2" width="30%">
                                        <input name="descricao" id="descricao" type="text" class="fieldMin" size="40" maxlength="40"  />
                                        <input type="hidden" name="idLayout" id="idLayout"/>
                                    </td> 
                                    <td class="TextoCampos" width="20%">*Tipo EDI:</td>                        
                                    <td class="CelulaZebra2"width="30%">
                                        <select class="fieldMin" id="tipoEDI" name="tipoEDI">
                                            <option value="c">Conhecimento (CONEMB)</option>
                                            <option value="f">Faturas (DOCCOB)</option>
                                            <option value="o">Entrega (OCOREN)</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>          
                                    <td class="TextoCampos" width="15%">*Nome do Arquivo:</td>                        
                                    <td class="CelulaZebra2" width="35%" colspan="3">
                                        <input name="nomeArquivo" id="nomeArquivo" type="text" class="fieldMin" size="65" maxlength="70"  /><br/>
                                        <label>Variáveis:</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@dia</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@mes</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@ano</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@hora</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@minuto</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@segundo</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@numero_CTE</label>
                                        <label onclick="inserirComplemento(this)" class="linkEditar">@@data_Emissao_CTE</label>
                                        
                                    </td> 
                                </tr>
                                <tr>          
                                    <td class="TextoCampos" width="20%">*Extensão do Arquivo:</td>                        
                                    <td class="CelulaZebra2" width="30%">
                                        <select class="fieldMin" id="extencaoArquivo" name="extencaoArquivo">
                                            <option value="txt">TXT</option>
                                            <option value="env">ENV</option>
                                            <!--<option value="xml">Faturas (DOCCOB)</option>
                                            <option value="xls">Entrega (OCOREN)</option>-->
                                        </select>
                                    </td> 
                                    <td class="TextoCampos" width="20%">Função:</td>                        
                                    <td class="CelulaZebra2"width="30%">
                                        <select class="fieldMin" id="funcao" name="funcao">
                                            <c:forEach var="funcao" varStatus="status" items="${listaFuncoes}">
                                                <option value="${funcao.funcao}">EDI <c:out value="${funcao.descricao}"/></option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
            </table>
            <table align="center" width="65%" >
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
             <table width="65%" align="center" class="bordaFina" id="divAuditoria" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                        <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                    </tr>
                    <tr>
                        <td colspan="8"> 
                            <table width="100%" align="center" class="bordaFina">
                                <tr class="CelulaZebra2">
                                    <td class="TextoCampos" width="15%"> Incluso:</td>

                                    <td width="35%" class="CelulaZebra2"> em: ${cadLayoutEDI.criadoEm} <br>
                                        por: ${cadLayoutEDI.criadoPor.nome} 
                                    </td>

                                    <td width="15%" class="TextoCampos"> Alterado:</td>
                                    <td width="35%" class="CelulaZebra2"> em: ${cadLayoutEDI.atualizadoEm} <br>
                                        por: ${cadLayoutEDI.atualizadoPor.nome}
                                    </td>
                                </tr>   
                            </table>                  
                        </td>
                    </tr>
             </table>
                                    <br/>
             <table width="65%" align="center" class="bordaFina" >                        
                <tr>
                    <c:if test="${param.nivel >= param.bloq}">
                        <td class="CelulaZebra2" ><div align="center">
                                <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                            </div></td>
                        </c:if>  

                </tr>
            </table>
        </form>

    </body>
</html>

