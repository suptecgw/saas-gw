<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<fmt:setLocale value="pt-BR" />
<!-- ***     LEMBRETE   ***   PARA O TIPO 'r' -->
<!-- Lembrando que existe duas tr's para a movimentação, uma é apenas para a primeira linha da lista, e a outra para as demais.-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<LINK REL="stylesheet" HREF="css/protoloading.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/scriptaculous.js?load=effects"></script>
<script language="javascript" type="text/javascript" src="script/protoloading.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script language="javascript" type="text/javascript" src="script/protoloading.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="JavaScript" src="script/shortcut.js"></script>

<script type="text/javascript" language="JavaScript">
    var countRow = 0;
    
    function setDefault(){
        $("campoConsulta").value = '${param.campoConsulta}';
        $("dataDe").value = '${param.dataDe}';
        $("dataAte").value = '${param.dataAte}';
        $("tipo").value = '${param.tipo}';
        $("idconsignatario").value = '${param.idconsignatario}';
        $("con_rzs").value = '${param.con_rzs}';
        $("numero").value = '${param.numero}';
        $("id").value = '${param.id}';
        $("descricao").value = '${param.descricao}';
        $("fi_abreviatura").value = '${param.fi_abreviatura}';
        $("nota").value = '${param.nota}';
        $("idfilial").value = '${param.idfilial}';
        $("confirmado").value = '${param.confirmado}';
    }

    function pesquisa(){
        $("formulario").action = "MovimentacaoPalletsControlador?acao=listar";
        $("formulario").method = "post";
        $("formulario").submit();
    }

    function excluir(id){ 
        if(confirm("Deseja excluir o Item ?" )){
            if(confirm("Tem certeza?" )){                
                window.open("MovimentacaoPalletsControlador?acao=excluir&idMovimentacao=" + id,
                "pop", "width=210, height=100");
            }
        }
    }
    
    function abrirCadastro(){
        window.location= "MovimentacaoPalletsControlador?acao=novocadastro","cadMovPallets";
    }

    function abrirLocalizarFornecedor(){
        abrirLocaliza("${homePath}/FornecedorControlador?acao=localizarFinan&modulo=gwFinan", "locFornecedorFinan");
    }
    
    function limparFornecedor(){
        $("fornecedor").value = "";
        $("idFornecedor").value = "0";
    }
    
    function carregarCadastro(id){
        window.location = "MovimentacaoPalletsControlador?acao=carregar&id=" + id;
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
        <title>webtrans - Movimenta&ccedil;&atilde;o de Pallets</title>
    </head>
    <body onload="setDefault(); applyFormatter();">
        <img src="img/banner.gif" width="40%" height="44" align="middle">
        <table class="bordaFina" width="85%" align="center">
            <tr>
                <td width="50%" align="left">
                    <span class="style4">Movimenta&ccedil;&atilde;o de Pallets</span>
                </td>
                <td width="30%" align="right">
                </td>
                <td width="20%" align="right">
                    <c:if test="${param.nivel >= 3}">                                       
                        <input name="Novo Lançamento" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro()})" value="Novo Lançamento"/>
                    </c:if>
                    &nbsp;
                </td>
            </tr>
        </table>
        <br>
        <form action="MovimentacaoPalletsControlador?acao=listar" id="formulario" name="formulario" method="post">
            <table class="bordaFina" width="85%" align="center">
                <tr class="CelulaZebra1">
                    <td align="right" width="5%">
                        <select name="campoConsulta" class="inputtexto" id="campoConsulta" >
                            <!--<option value="">Não filtrar por data</option>-->
                            <option value="emissao_em">Por data de Lan&ccedil;amento entre:</option>
                        </select>
                    </td>
                    <td width="24%">
                        <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                         e
                        <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate">
                    </td>
                    <td align="right" width="13%">Apenas o Cliente:</td>
                    <td class="CelulaZebra1" colspan="5">
                        <strong> 
                            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                            <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" value="" size="25" maxlength="80" readonly="true">
                            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                   onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Cliente')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                   onClick="javascript:getObj('idconsignatario').value = '0';javascript:getObj('con_rzs').value = '';"> 
                        </strong>
                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td align="right">Visualizar:</td>
                    <td>
                        <select name="tipo" id="tipo" class="inputtexto">
                            <option value="" selected>Ambos</option>
                            <option value="c">Apenas Entradas</option>
                            <option value="d">Apenas Sa&iacute;das</option>
                        </select>
                    </td>
                    <td align="right">Apenas o N&uacute;mero:</td>
                    <td>
                        <input name="numero" type="text" id="numero" size="10" maxlength="10" onkeypress="mascara(this, soNumeros)" class="inputtexto">
                    </td>
                    <td width="6%" align="right">Pallet:</td>
                    <td colspan="3">
                        <strong> 
                            <input type="hidden" name="id" id="id" value="0">
                            <input name="descricao" type="text" id="descricao" class="inputReadOnly" value="" size="15" maxlength="40" readonly="true">
                            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                    onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.TIPO_PALLET%>', 'Pallets')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                onClick="javascript:getObj('id').value = '0';javascript:getObj('descricao').value = '';"> 
                        </strong>
                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td align="right">Apenas o Nota:</td>
                    <td>
                        <input name="nota" type="text" id="nota" size="10" maxlength="10" onkeypress="mascara(this, soNumeros)" class="inputtexto">
                    </td>
                    <td width="6%" align="right">Filial:</td>
                    <td colspan="5">
                        <strong> 
                            <input type="hidden" name="idfilial" id="idfilial" value="0">
                            <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="" size="15" maxlength="40" readonly="true">
                            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                   onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>', 'Filial')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" 
                                 onClick="javascript:getObj('idfilial').value = '0';javascript:getObj('fi_abreviatura').value = '';"> 
                        </strong>
                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td align="right">Situa&ccedil;&atilde;o:</td>
                    <td>
                        <select name="confirmado" id="confirmado" class="inputtexto">
                            <option value="" selected>Ambos</option>
                            <option value="c">Confirmadas</option>
                            <option value="p">Pendentes</option>
                        </select>
                    </td>
                    <td colspan="6"></td>
                </tr>
                <c:if test="${param.nivel >= 1}">
                    <tr class="CelulaZebra1">
                        <td align="center" colspan="8">                               
                            <input type="button" value="Visualizar" class="inputbotao" onclick="tryRequestToServer(function(){pesquisa()})">
                        </td>
                    </tr>
                </c:if>
            </table>
        </form>
        <form action="MovimentacaoPalletsControlador?acao=listar" id="formularioS" name="formularioS" method="post" target="pop">
            <table width="85%" border="0" cellpadding="0" cellspacing="1" class="bordaFina" align="center">
                <tr class="tabela">
                    <td width="8%"><strong>Nº Nota</strong></td>
                    <td width="8%"><strong>Data</strong></td>
                    <td width="8%"><strong>Tipo</strong></td>
                    <td width="25%"><strong>Cliente</strong></td>
                    <td width="10%"><strong>Filial</strong></td>
                    <td width="10%"><strong>Pallet</strong></td>
                    <td width="5%"><strong>Quantidade</strong></td>
                    <td width="2%"><strong></strong></td>
                </tr>
                <!-- percorre a coleção Inicio-->
                <c:forEach var="movimentacao" varStatus="status" items="${listaMovimentacaoPallet}">
                     <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                         <script>countRow++;</script>
                            <td align="center">
                                <a href="javascript: carregarCadastro('${movimentacao.id}')" class="linkEditar">${movimentacao.nota}</a>
                            </td>
                            <td align="center">
                                ${movimentacao.data}
                            </td>
                            <td align="center">
                                ${movimentacao.tipo}
                            </td>
                            <td>
                                ${movimentacao.cliente.razaosocial}
                            </td>
                            <td>
                                ${movimentacao.filial.abreviatura}
                            </td>
                            <td>
                                <input type="hidden" name="idPallet" id="idPallet" value="${movimentacao.pallet.id}">
                                ${movimentacao.pallet.descricao}
                            </td>
                            <td align="center">
                                ${movimentacao.quantidade}
                            </td>
                            <td align="center">
                                <a href="javascript: excluir('${movimentacao.id}')"> 
                                    <img class="imagemLink" src="img/lixo.png"> 
                                </a>
                            </td>
                      </tr>
                   </c:forEach>
                   <!-- percorre a coleção FIM-->
                   <!-- Ultima linha inicio-->
                   <c:choose>
                       <c:when test="${emissaoAnterior != '' && param.mostrarTotais}">
                            <tr class="${(contadorAlternativo % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td colspan="2" align="right">
                                <b>Totais do dia ${emissaoAnterior}:</b>
                            </td>
                            <td align="right">
                                <b><fmt:formatNumber value="${valorDia < 0 ? valorDia * (-1) : 0}" pattern="#,##0.00#"/></b>
                            </td>
                            <td align="right">
                                <b><fmt:formatNumber value="${valorDia >= 0 ? valorDia : 0}" pattern="#,##0.00#"/></b>
                            </td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            </tr>
                        </c:when>
                    </c:choose>
                    <!-- Ultima linha Fim-->
                 </table>
              <br>
              <c:choose>
                  <c:when test="${param.nivel >= 2}">
                      <table width="85%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
                          <tr class="CelulaZebra1">
                              <td colspan="8" align="center" >
                                   <input type="button" class="inputbotao" value="Salvar" id="salvar" onclick="validaSession(function(){salva();});">
                               </td>
                           </tr>
                       </table>
                  </c:when>
              </c:choose>
            </form>
          </body>
       </html>