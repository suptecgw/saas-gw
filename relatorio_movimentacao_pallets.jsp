<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <script language="JavaScript" src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
        <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
        <script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript">
    function popRel() {
                var formu = document.formulario;

                janela = window.open('about:blank', 'pop', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');

                formu.submit();
                return true;
            }

            function abrirLocalizarProprietario() {
                tryRequestToServer(function () {
                    popLocate(65, "Agregado")
                });
            }

            function setDefalt() {
                $("dtinicial").value = "${param.dataAtual}";
                $("dtfinal").value = "${param.dataAtual}";
            }
        </script>

        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();setDefalt();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center">
            <img src="img/banner.gif"  alt="banner"> 
            <br>
            <input type="hidden" name="idvendedor" id="idvendedor" value="0">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td>
                    <b>Relat&oacute;rio de Movimenta&ccedil;&atilde;o de Pallets</b>
                </td>
            </tr>
        </table>
        <br>
        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
                        </tr>
                    </table>
                </td>
            </tr>
    </table>
        <div id="tabPrincipal">
            <form action="ContratoFreteControlador?acao=imprimirMovimentacaoPallets" id="formulario" name="formulario" method="post" target="pop">
            <table width="90%" border="0" class="bordaFina" align="center">
                <tr class="tabela"> 
                    <td colspan="2">
                        <div align="center">Modelos</div>
                    </td>
                </tr>
                <tr> 
                    <td width="50%" class="TextoCampos"> 
                        <div align="left">
                            <input type="radio" name="modelo" id="modelo1" value="1" checked onClick="">
                            Modelo 1 
                        </div>
                    </td>
                    <td width="83%" class="CelulaZebra2">Relat&oacute;rio de Movimenta&ccedil;&atilde;o de Pallets</td>
                </tr>
                <tr class="tabela"> 
                    <td colspan="2">
                        <div align="center">Crit&eacute;rio de datas</div>
                    </td>
                </tr>
                <tr> 
                    <td class="TextoCampos">
                        <label id="tipo_data" name="tipo_data">Emitidos entre:</label>
                    </td>
                    <td class="CelulaZebra2"> 
                        <strong> 
                            <input name="dtinicial" type="text" id="dtinicial" value="" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                        </strong>e
                        <strong> 
                            <input name="dtfinal" type="text" id="dtfinal" value="" size="10" maxlength="10" onBlur="alertInvalidDate(this)" class="fieldDate" />
                        </strong>
                    </td>
                </tr>
                <tr class="tabela"> 
                    <td height="18" colspan="2">
                        <div align="center">Filtros</div>
                    </td>
                </tr>
                <tr> 
                    <td colspan="2"> 
                        <table width="100%" border="0" >
                            <tr> 
                                <td width="33%" class="TextoCampos">
                                    <div align="right">Apenas o Cliente:</div>
                                </td>
                                <td width="298" class="CelulaZebra2">
                                    <strong> 
                                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly" value="" size="25" maxlength="80" readonly="true">
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Cliente')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                             onClick="javascript:getObj('idconsignatario').value = '0';
                                                     javascript:getObj('con_rzs').value = '';"> 
                                    </strong>
                                </td>
                                <td width="14%" class="TextoCampos">Apenas o Pallet:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <strong> 
                                        <input type="hidden" name="id" id="id" value="0">
                                        <input name="descricao" type="text" id="descricao" class="inputReadOnly" value="" size="10" maxlength="40" readonly="true">
                                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.TIPO_PALLET%>', 'Pallets')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
                                             onClick="javascript:getObj('id').value = '0';
                                                    javascript:getObj('descricao').value = '';"> 
                                    </strong>
                                </td>
                            </tr>
                            <tr class="CelulaZebra2">
                                <td align="right">Situa&ccedil;&atilde;o:</td>
                                <td>
                                    <select name="confirmado" id="confirmado" class="inputtexto">
                                        <option value="" selected>Ambos</option>
                                        <option value="c">Confirmadas</option>
                                        <option value="p">Pendentes</option>
                                    </select>
                                </td>
                                <td align="right">Apenas:</td>
                                <td colspan="4">
                                    <select name="tipo" id="tipo" class="inputtexto">
                                        <option value="ambos" selected>Entradas/Saídas</option>
                                        <option value="entrada">Entradas</option>
                                        <option value="saida">Saídas</option>                                        
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="tabela">
                        <div align="center">Formato do Relat&oacute;rio </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="TextoCampos">
                        <div align="center">
                            <input type="radio" name="impressao" id="pdf" value="1" checked/>
                            <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                            <input type="radio" name="impressao" id="excel" value="2" />
                            <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                            <input type="radio" name="impressao" id="word" value="3" />
                            <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                        </div>
                    </td>
                </tr>
                <tr> 
                    <td colspan="2" class="TextoCampos"> 
                        <div align="center">
                            <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function () {
                                        popRel();
                                    });">
                        </div>
                    </td>
                </tr>
            </table>
        </form>
        </div>
        <div id="tabDinamico"></div>
        
    </body>
</html>