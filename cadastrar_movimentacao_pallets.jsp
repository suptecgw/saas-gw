<%@page import="nucleo.Apoio"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("prototype.js")%>"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("sessao.js")%>"></script>
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("jquery.js")%>"></script>
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>"></script>
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("mascaras.js")%>"></script>
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>"></script>
<script language="javascript" type="text/javascript" src="script/<%=Apoio.noCacheScript("LogAcoesAuditoria.js")%>"></script>
<script type="text/javascript" language="JavaScript">   
    jQuery.noConflict();
    
    var  arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
    
    function carregar(){ 
        var action = '${param.acao}'
        $("data").value = '${param.dataAtual}';
        $("dataDeAuditoria").value = '${param.dataAtual}';
        $("dataAteAuditoria").value = '${param.dataAtual}';
        
        if($("data").value == ""){
            $("data").value = '<c:out value="${movimentacaopallets.data}"/>';
        }
        
        $("numero").value = '<c:out value="${movimentacaopallets.numero}"/>';
        $("tipo").value = '<c:out value="${movimentacaopallets.tipo}"/>';
        $("idconsignatario").value = '<c:out value="${movimentacaopallets.cliente.idcliente}"/>';
        $("quantidade").value = '<c:out value="${movimentacaopallets.quantidade}"/>';
        $("con_rzs").value = '<c:out value="${movimentacaopallets.cliente.razaosocial}"/>';
        $("idMovimentacao").value = '<c:out value="${movimentacaopallets.id}"/>';
        $("id").value = '<c:out value="${movimentacaopallets.pallet.id}"/>';
        $("descricao").value = '<c:out value="${movimentacaopallets.pallet.descricao}"/>';
        $("idfilial").value = '<c:out value="${movimentacaopallets.filial.idfilial}"/>';
        $("fi_abreviatura").value = '<c:out value="${movimentacaopallets.filial.abreviatura}"/>';
        $("nota").value = '<c:out value="${movimentacaopallets.nota}"/>';
        $("confirmado").checked = ('<c:out value="${movimentacaopallets.confirmado}"/>' == "true");
    }

    function salvar(){
        
        if($("data").value == ""){
            alert("O campo 'Data' Não Pode Ficar em Branco!");
            $("data").focus();
            return false;
        }

        if($("tipo").value == ""){
            alert("O campo 'Tipo de Lançamento' Não Pode Ficar em Branco!");
            $("tipo").focus();
            return false;
        }
        
        if($("quantidade").value == ""){
            alert("O campo 'Quantidade' Não Pode Ficar em Branco!");
            $("quantidade").focus();
            return false;
        }
        
        
        if($("id").value == "" || $("id").value == "0"){
            alert("O campo 'Pallets' Não Pode Ficar em Branco!");
            $("id").focus();
            return false;
        }
        
        if($("idfilial").value == "" || $("idfilial").value == "0"){
            alert("O campo 'Filial' Não Pode Ficar em Branco!");
            $("idfilial").focus();
            return false;
        }
        
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        $("formulario").submit();
        return true;
    }

    function limparHistorico(){
        var form = document.formulario;
        form.historicoCodigo.value = "";
        form.descHist.value = "";
        form.historicoId.value = "0";
    }

    function abrirLocalizarHistorico(){
        abrirLocaliza("${homePath}/HistoricoControlador?acao=localizarFinan", "locHistFinan");
    }
    
    function abrirLocalizarFornecedor(){
        abrirLocaliza("FornecedorControlador?acao=localizarFinan&modulo=gwFinan", "locFornecedorFinan");
    }
    
    function limparFornecedor(){
        $("fornecedor").value = "";
        $("idFornecedor").value = "0";
    }
    
    function voltar(){
        window.location = "MovimentacaoPalletsControlador?acao=listar";
    }
        function pesquisarAuditoria() {
                if (countLog != null && countLog != undefined) {
                    for (var i = 1; i <= countLog; i++) {
                        if ($("tr1Log_" + i) != null) {
                            Element.remove(("tr1Log_" + i));
                        }
                        if ($("tr2Log_" + i) != null) {
                            Element.remove(("tr2Log_" + i));
                        }
                    }
                }
                countLog = 0;
                var rotina = "movimentacao_pallets";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id =  $("idMovimentacao").value;
                consultarLog(rotina, id, dataDe, dataAte);
            }
</script>

<html>
    <style type="text/css">
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
    </style>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>webtrans - Lan&ccedil;amento de Pallets</title>
    </head>
    <body onload="carregar();applyFormatter();AlternarAbasGenerico('tdAbaAuditoria','tabelaAuditoria');">
        <img src="img/banner.gif" width="40%" height="44" align="middle">
        <table class="bordaFina" width="85%" align="center">
            <tr>
                <td width="82%" align="left">
                    <span class="style4">Lan&ccedil;amento de Pallets</span>
                    <td align="right">                                            
                        <input type="button" value=" Voltar " class="inputbotao" onclick="tryRequestToServer(function(){voltar()})"/>
                    </td>
                </td>
                <td width="18%" align="left">
                    <input type="button" value=" Fechar " class="inputbotao" onClick="window.close();"/>
                </td>
            </tr>
        </table>
        <br>
        <form action="MovimentacaoPalletsControlador?acao=${param.acao == 2 ? "editar" : "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <table width="85%" align="center" class="bordaFina" >
                <tr>
                    <td>
                        <table width="100%" border="0">
                            <tr>
                                <input type="hidden" name="idMovimentacao" id="idMovimentacao" />
                                <td width="10%" class="TextoCampos">N&uacute;mero:</td>
                                <td width="10%" class="CelulaZebra2">
                                    <input name="numero" type="text" readonly class="inputReadOnly" id="numero" size="8" onkeypress="mascara(this, soNumeros)">
                                </td>
                                <td class="TextoCampos">*Data:</td>
                                <td class="CelulaZebra2">
                                    <input name="data" type="text" id="data" size="10" maxlength="10" onblur="alertInvalidDate(this,true)" class="fieldDate" />
                                </td>
                                <td width="15%" class="TextoCampos">*Tipo Lan&ccedil;amento:</td>
                                <td width="15%" class="CelulaZebra2">
                                    <select name="tipo" id="tipo" class="inputtexto">
                                        <option value="c" selected>Entrada</option>
                                        <option value="d">Sa&iacute;da</option>
                                    </select>
                                </td>
                                <td class="TextoCampos" width="2%">*Quantidade:</td>
                                <td class="CelulaZebra2">
                                    <input name="quantidade" type="text" class="inputtexto" id="quantidade" size="8" onkeypress="mascara(this, soNumeros)">
                                </td>
                            </tr>
                            <tr>
                                <td width="6%" class="TextoCampos">Cliente:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <strong> 
                                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Cliente')">
                                       <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" 
			                    onClick="javascript:getObj('idconsignatario').value = '0';javascript:getObj('con_rzs').value = '';"> 
                                    </strong>
                                </td>
                                <td width="8%" class="TextoCampos">*Tipo de Pallet:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <strong> 
                                        <input type="hidden" name="id" id="id" value="0">
                                        <input name="descricao" type="text" id="descricao" class="inputReadOnly" value="" size="15" maxlength="40" readonly="true">
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.TIPO_PALLET%>', 'Pallets')">
                                       <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Pallet" 
			                    onClick="javascript:getObj('id').value = '0';javascript:getObj('descricao').value = '';"> 
                                    </strong>
                                </td>
                            </tr>
                            <tr>
                                <td width="6%" class="TextoCampos">*Filial:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <strong> 
                                        <input type="hidden" name="idfilial" id="idfilial" value="0">
                                        <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="" size="25" maxlength="80" readonly="true">
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
			                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>', 'Filial')">
                                       <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" 
			                    onClick="javascript:getObj('idfilial').value = '0';javascript:getObj('fi_abreviatura').value = '';"> 
                                    </strong>
                                </td>
                                <td width="8%" class="TextoCampos">Nº Nota:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <strong> 
                                        <input name="nota" type="text" class="inputtexto" id="nota" size="8" onkeypress="mascara(this, soNumeros)">
                                    </strong>
                                </td>
                            </tr>
                            <tr>
                                <td class="CelulaZebra2"  colspan="8">
                                    <div align="right">
                                        <input type="checkbox" name="confirmado" id="confirmado" value="confirmado">
                                        Movimenta&ccedil;&atilde;o Confirmada
                                    </div>
                                </td>
                            </tr>
                       </table>
                    </td>
                </tr> 
            </table>
                     <table align="center" width="85%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','tabelaAuditoria')"> Auditoria</td>

                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>                 
                     <table id="tabelaAuditoria" width="85%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none" }'>
                                <%@include file="/gwTrans/template_auditoria.jsp" %>
                     </table> 
                     <br/>
                   <table width="85%" align="center" class="bordaFina" >                       
                        <tr>
                            <c:if test="${param.nivel >= param.bloq}">
                                <td class="CelulaZebra2" >
                                    <div align="center">
                                        <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                                    </div>
                                </td>
                            </c:if>
                        </tr>
                   </table>
        </form>
    </body>
</html>