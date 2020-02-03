<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script type="text/javascript" language="JavaScript">   
    function carregar(){ 
        var action = '${param.acao}'
        $("descontar_apartir_de").value = '<c:out value="${desconto.descontarApartirDe}"/>';
        
        if($("descontar_apartir_de").value == ""){
            $("descontar_apartir_de").value = '${param.dataAtual}';
        }
        
        $("idmotorista").value = '<c:out value="${desconto.motorista.idmotorista}"/>';
        $("motor_nome").value = '<c:out value="${desconto.motorista.nome}"/>';
        $("idplanocusto").value = '<c:out value="${desconto.planoCusto.idconta}"/>';
        $("plcusto_descricao").value = '<c:out value="${desconto.planoCusto.descricao}"/>';
        $("idLancamento").value = '<c:out value="${desconto.id}"/>';
        $("idviagem").value = '<c:out value="${desconto.viagem.id}"/>';
        $("numviagem").value = '<c:out value="${desconto.viagem.numViagem}"/>';
        $("valor").value = colocarVirgula('<c:out value="${desconto.valor}"/>');
        
        if($("valor").value == "" || $("valor").value == "NaN"){
            $("valor").value = "0,00";
        }
    }
    
    function aoClicarNoLocaliza(idjanela){
            if(idjanela == "Plano"){
                $("idplanocusto").value = $("idplanocusto_despesa").value;
                $("plcusto_descricao").value = $("plcusto_descricao_despesa").value;
            }
        }

    function salvar(){
        if($("descontar_apartir_de").value == ""){
            alert("O campo 'Descontar a partir de' Não Pode Ficar em Branco!");
            $("descontar_apartir_de").focus();
            return false;
        }

        if($("valor").value == "" || $("valor").value == "0,00"){
            alert("O campo 'Valor' Não Pode Ser Branco ou Zero!");
            $("valor").focus();
            return false;
        }
        
        
        if($("historico").value == "" || $("historico").value.trim() == "") {
            alert("O campo 'Histórico' Não Pode Ficar em Branco!");
            $("historico").focus();
            return false;
        }
        
        
        if($("idmotorista").value == "" || $("idmotorista").value == "0"){
            alert("O campo 'Motorista' Não Pode Ficar em Branco!");
            $("idmotorista").focus();
            return false;
        }
        
        if($("idplanocusto").value == "" || $("idplanocusto").value == "0"){
            alert("O campo 'Plano de Custo' Não Pode Ficar em Branco!");
            $("idplanocusto").focus();
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
        window.location = "ViagemDescontoMotoristaControlador?acao=listar";
    }
    
    function pesquisarViagem(){
        if($("idmotorista").value == "0" || $("idmotorista").value == ""){
            alert("Selecione um Motorista!");
            return false;
        }else{
            popLocate(68, "Viagem","", "&paramaux="+$('idmotorista').value);
        }              
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
        <title>webtrans - Lan&ccedil;amento de Desconto do Motorista</title>
    </head>
    <body onload="carregar();applyFormatter();">
        <input type="hidden" id="idplanocusto_despesa" name="idplanocusto_despesa" value="">
        <input type="hidden" id="plcusto_descricao_despesa" name="plcusto_descricao_despesa" value="">
        <input type="hidden" id="plcusto_conta_despesa" name="plcusto_conta_despesa" value="">
        
        <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="81%" align="center">
            <tr>
                <td width="80%" align="left">
                    <span class="style4">Lan&ccedil;amento de Desconto do Motorista</span>
                <td align="right">                                            
                    <input type="button" value=" Voltar " class="inputbotao" onclick="tryRequestToServer(function(){voltar()})"/>
                </td>
                <td width="18%" align="left">
                    <input type="button" value=" Fechar " class="inputbotao" onClick="window.close();"/>
                </td>
            </tr>
        </table>
        <br>
        <form action="ViagemDescontoMotoristaControlador?acao=${param.acao == '2' ? "editar" : "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <table width="80%" align="center" class="bordaFina" >

                <tr>
                <input type="hidden" name="idLancamento" id="idLancamento" />
                <td width="2%" class="TextoCampos">Motorista:</td>
                <td class="CelulaZebra2" colspan="3">
                    <strong> 
                        <input type="hidden" name="idmotorista" id="idmotorista" value="0" >
                        <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" value="" size="27" maxlength="80" readonly="true">
                        <input name="localiza_motorista" type="button" class="inputBotaoMin" id="localiza_motorista" value="..." 
                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" 
                             onClick="javascript:getObj('idmotorista').value = '0';javascript:getObj('motor_nome').value = '';"> 
                    </strong>
                </td>
                <td width="13%" class="TextoCampos">Plano Custo:</td>
                <td class="CelulaZebra2" colspan="3">
                    <strong> 
                        <input type="hidden" name="idplanocusto" id="idplanocusto" value="0">
                        <input name="plcusto_descricao" type="text" id="plcusto_descricao" class="inputReadOnly" value="" size="20" maxlength="80" readonly="true">
                        <input name="localiza_plano_custo" type="button" class="inputBotaoMin" id="localiza_plano_custo" value="..." 
                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CUSTO_DESPESA %>', 'Plano')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Plano de Custo" 
                             onClick="javascript:getObj('idplanocusto').value = '0';javascript:getObj('plcusto_descricao').value = '';"> 
                    </strong>
                </td>
                </tr>
                <tr>
                    <td width="2%" class="TextoCampos">Valor:</td>
                    <td width="10%" class="CelulaZebra2">
                        <input name="valor" type="text" class="inputtexto" id="valor" size="6" onkeypress="mascara(this, reais)" value="0,00">
                    </td>
                    <td class="TextoCampos">*Desconto a partir:</td>
                    <td class="CelulaZebra2">
                        <input name="descontar_apartir_de" type="text" id="descontar_apartir_de" size="10" maxlength="10" onblur="alertInvalidDate(this,true)" class="fieldDate" />
                    </td>
                    <td width="6%" class="TextoCampos">Viagem:</td>
                    <td class="CelulaZebra2" colspan="3">
                        <strong> 
                            <input type="hidden" name="idviagem" id="idviagem" value="0">
                            <input name="numviagem" type="text" id="numviagem" class="inputReadOnly" value="" size="20" maxlength="80" readonly="true">
                            <input name="localiza_viagem" type="button" class="inputBotaoMin" id="localiza_viagem" value="..." 
                                   onClick="pesquisarViagem();">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" 
                                 onClick="javascript:getObj('idviagem').value = '0';javascript:getObj('numviagem').value = '';"> 
                        </strong>
                    </td>
                </tr>
                <tr>
                    <td width="2%" class="TextoCampos">Hist&oacute;rico:</td>
                    <td class="CelulaZebra2" colspan="7">
                        <textarea name="historico" id="historico" class="inputtexto" cols="73" rows="3" ><c:out value="${desconto.historico}"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td colspan="8">
                        <table width="100%" align="center" border="0" class="bordaFina">
                            <tr  class="CelulaZebra2">
                                <td  class="tabela" colspan="4">
                                    <div align="center">Auditoria</div>
                                </td>
                            </tr>
                            <tr class="CelulaZebra2">
                                <td class="TextoCampos" width="14%"> Incluso:</td>

                                <td width="35%"> 
                                    Em: ${desconto.criadoEm} 
                                    <br>
                                    Por: ${desconto.criadoPor.nome}                                    
                                </td>

                                <td class="TextoCampos" width="15%"> Alterado:</td>
                                <td width="36%"> 
                                    Em: ${desconto.alteradoEm} 
                                    <br>
                                    Por: ${desconto.alteradoPor.nome}                                    
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <c:if test="${param.nivel >= param.bloq}">
                    <tr>
                        <td class="CelulaZebra2" colspan="8" >
                            <div align="center">
                                <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                            </div>
                        </td>
                    </tr>
                </c:if>
            </table>
        </form>
    </body>
</html>