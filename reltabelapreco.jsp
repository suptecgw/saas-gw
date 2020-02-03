<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.text.*,
         java.util.Date,
         nucleo.*" errorPage="" %>
<%@ page import="br.com.gwsistemas.filial.FilialBO" %>
<%@ page import="java.util.Objects" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>



<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("cadtabelacliente") > 0);
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    String condicao = "";
    SimpleDateFormat dataFormatadaAtual = new SimpleDateFormat("yyyy-MM-dd");

    if (acao.equals("exportar")) {
        String modelo = request.getParameter("modelo");

        String pesoDe = request.getParameter("idPesoKgDe") != null ? request.getParameter("idPesoKgDe").replaceAll(",", ".") : "";
        String pesoAte = request.getParameter("idPesoKgAte") != null ? request.getParameter("idPesoKgAte").replaceAll(",", ".") : "";

        String nfDe = request.getParameter("idNfDe") != null ? request.getParameter("idNfDe").replaceAll(",", ".") : "";
        String nfAte = request.getParameter("idNfAte") != null ? request.getParameter("idNfAte").replaceAll(",", ".") : "";

        String volumeDe = request.getParameter("idVolumeDe") != null ? request.getParameter("idVolumeDe").replaceAll(",", ".") : "";
        String volumeAte = request.getParameter("idVolumeAte") != null ? request.getParameter("idVolumeAte").replaceAll(",", ".") : "";

        String freteDe = request.getParameter("idFreteMDe") != null ? request.getParameter("idFreteMDe").replaceAll(",", ".") : "";
        String freteAte = request.getParameter("idFreteMAte") != null ? request.getParameter("idFreteMAte").replaceAll(",", ".") : "";

        String outrosDe = request.getParameter("idVoutrosDe") != null ? request.getParameter("idVoutrosDe").replaceAll(",", ".") : "";
        String outrosAte = request.getParameter("idVoutrosAte") != null ? request.getParameter("idVoutrosAte").replaceAll(",", ".") : "";

        String seguroDe = request.getParameter("idSeguroDe") != null ? request.getParameter("idSeguroDe").replaceAll(",", ".").replaceAll(",", ".") : "";
        String seguroAte = request.getParameter("idSeguroAte") != null ? request.getParameter("idSeguroAte").replaceAll(",", ".").replaceAll(",", ".") : "";

        String grisDe = request.getParameter("idGrisDe") != null ? request.getParameter("idGrisDe").replaceAll(",", ".") : "";
        String grisAte = request.getParameter("idGrisAte") != null ? request.getParameter("idGrisAte").replaceAll(",", ".") : "";

        String pedagioDe = request.getParameter("idPedagioDe") != null ? request.getParameter("idPedagioDe").replaceAll(",", ".") : "";
        String pedagioAte = request.getParameter("idPedagioAte") != null ? request.getParameter("idPedagioAte").replaceAll(",", ".") : "";

        String taxaFixaDe = request.getParameter("idTaxaFixaDe") != null ? request.getParameter("idTaxaFixaDe").replaceAll(",", ".") : "";
        String taxaFixaAte = request.getParameter("idTaxaFixaAte") != null ? request.getParameter("idTaxaFixaAte").replaceAll(",", ".") : "";

        String secCatDe = request.getParameter("idScDe") != null ? request.getParameter("idScDe").replaceAll(",", ".") : "";
        String secCatAte = request.getParameter("idScAte") != null ? request.getParameter("idScAte").replaceAll(",", ".") : "";

        String tipoPeso = request.getParameter("idTipoPeso") != null ? request.getParameter("idTipoPeso") : "";

        Date datasEmVemDe = Apoio.paraDate(request.getParameter("idDatasEmVemDe"));
        Date datasEmVemAte = Apoio.paraDate(request.getParameter("idDatasEmVemAte"));
        String selectEmissaoVencimento = request.getParameter("idDataEmissaoVencimento") != null || !Objects.equals(request.getParameter("idDataEmissaoVencimento"), "selecione") ? request.getParameter("idDataEmissaoVencimento") : "";

        condicao = !Objects.equals(freteDe, "") && !Objects.equals(freteAte, "") ? " and valor_frete_minimo between " + freteDe + " and " + freteAte : "";
        condicao += !Objects.equals(outrosDe, "") && !Objects.equals(outrosAte, "") ? " and valor_outros between " + outrosDe + " and " + outrosAte : "";
        condicao += !Objects.equals(seguroDe, "") && !Objects.equals(seguroAte, "") ? " and percentual_advalorem between " + seguroDe + " and " + seguroAte : "";
        condicao += !Objects.equals(grisDe, "") && !Objects.equals(grisAte, "") ? " and percentual_gris between " + grisDe + " and " + grisAte : "";
        condicao += !Objects.equals(pedagioDe, "") && !Objects.equals(pedagioAte, "") ? " and valor_pedagio between " + pedagioDe + " and " + pedagioAte : "";
        condicao += !Objects.equals(taxaFixaDe, "") && !Objects.equals(taxaFixaAte, "") ? " and valor_taxa_fixa between " + taxaFixaDe + " and " + taxaFixaAte : "";
        condicao += !Objects.equals(secCatDe, "") && !Objects.equals(secCatAte, "") ? " and valor_sec_cat between " + secCatDe + " and " + secCatAte : "";

        String dataEmissao = dataFormatadaAtual.format(datasEmVemDe);
        String dataVencimento = dataFormatadaAtual.format(datasEmVemAte);

        if (selectEmissaoVencimento.equals("emissao_em")) {
            condicao += !Objects.equals(dataEmissao, "") && !Objects.equals(dataVencimento, "") ? " and data_emissao between '" + dataEmissao + "' and '" + dataVencimento + "'" : "";

        } else if (selectEmissaoVencimento.equals("vencimento_em")) {
            condicao += !Objects.equals(dataEmissao, "") && !Objects.equals(dataVencimento, "") ? " and valida_ate between '" + dataEmissao + "' and '" + dataVencimento + "'" : "";
        }

        if (modelo.equals("1")) {
            if (!Objects.equals(pesoDe, "") && !Objects.equals(pesoAte, "")) {

                if (tipoPeso.equals("f")) {
                    condicao += (!Objects.equals(pesoDe, "") && !Objects.equals(pesoAte, "")
                            ? "and (valor_maritimo_faixa between " + pesoDe + " and " + pesoAte
                            + " OR valor between " + pesoDe + " and " + pesoAte + ") and tipo_valor = 'f'" : "");
                } else if (tipoPeso.equals("k")) {
                    condicao += (!Objects.equals(pesoDe, "") && !Objects.equals(pesoAte, "")
                            ? "and (valor_maritimo_faixa between " + pesoDe + " and " + pesoAte
                            + " OR valor between " + pesoDe + " and " + pesoAte + ") and tipo_valor = 'k'" : "");

                } else if (tipoPeso.equals("t")) {
                    condicao += (!Objects.equals(pesoDe, "") && !Objects.equals(pesoAte, "") ? "and (valor between " + pesoDe + " and " + pesoAte + ") and tipo_valor = 't'" : "");

                }
//                    else{
//                    condicao += (pesoDe != "" && pesoAte != "" ? " and (peso_inicial between " + pesoDe + " and " + pesoAte : "");
//                    condicao += (pesoAte != "" && pesoDe != "" ? " or peso_final between " + pesoDe + " and " + pesoAte +")" : "");
//                    condicao += tipoPeso != "" ? " and tipo_valor = '" + tipoPeso + "'" : "";                       
//                }

            }
        }

        if (modelo.equals("2")) {
            condicao += !Objects.equals(pesoDe, "") && !Objects.equals(pesoAte, "") ? " and valor_peso between " + pesoDe + " and " + pesoAte : "";
            condicao += !Objects.equals(nfDe, "") && !Objects.equals(nfAte, "") ? " and percentual_nf between " + nfDe + " and " + nfAte : "";
            condicao += !Objects.equals(volumeDe, "") && !Objects.equals(volumeAte, "") ? " and valor_volume between " + volumeDe + " and " + volumeAte : "";
        }

        int filialResponsavelId = Apoio.parseInt(request.getParameter("apenasFilial"));
        if (filialResponsavelId > 0) {
            condicao += " AND filial_responsavel_id IN (" + filialResponsavelId + ") ";
        }

        java.util.Map param = new java.util.HashMap(11);
        param.put("CLIENTE", (request.getParameter("idconsignatario").equals("0") ? " AND cliente_id is null " : (request.getParameter("idconsignatario").equals("-1") ? "" : " AND cliente_id = " + request.getParameter("idconsignatario"))));
        param.put("VENDEDOR", (request.getParameter("idvendedor").equals("0")) ? "" : "AND idvendedor =" + request.getParameter("idvendedor"));
        param.put("AREA_ORIGEM", (request.getParameter("idareaorigem").equals("0") ? "" : " and area_origem_id=" + request.getParameter("idareaorigem")));
        param.put("AREA_DESTINO", (request.getParameter("idareadestino").equals("0") ? "" : " and area_destino_id=" + request.getParameter("idareadestino")));
        param.put("CIDADE_ORIGEM", (request.getParameter("idcidadeorigem").equals("0") ? "" : " and cidade_origem_id=" + request.getParameter("idcidadeorigem")));
        param.put("CIDADE_DESTINO", (request.getParameter("idcidadedestino").equals("0") ? "" : " and cidade_destino_id=" + request.getParameter("idcidadedestino")));
        param.put("TIPO_PRODUTO", (request.getParameter("tipo_produto_id").equals("0") ? "" : " and product_type_id=" + request.getParameter("tipo_produto_id")));
        param.put("CONDICAO", condicao);
        param.put("TIPO_PESO", tipoPeso);
        param.put("USUARIO", Apoio.getUsuario(request).getNome());
        param.put("CLIENTE_LICENCA", (Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", "tabelaprecomod" + modelo);
        
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    } else if (acao.equals("iniciar")) {
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_TABELA_PRECO_RELATORIO.ordinal());
        request.setAttribute("filiais", new FilialBO().carregarFiliais());
    }

%>


<script language="javascript" type="text/javascript">

    function modelos(modelo) {
        getObj("modelo1").checked = false;
        getObj("modelo2").checked = false;
        getObj("modelo3").checked = false;
        getObj("modelo4").checked = false;
        getObj("modelo" + modelo).checked = true;

        if (getObj("modelo2").checked) {
            visivel($("trPesoKg"));
            visivel($("trNfKg"));
            visivel($("trVolumeKg"));
            invisivel($("idTipoPeso"));
        } else if (getObj("modelo1").checked) {
            visivel($("trPesoKg"));
            invisivel($("trNfKg"));
            invisivel($("trVolumeKg"));
            visivel($("idTipoPeso"));
        } else {
            invisivel($("trPesoKg"));
            invisivel($("trNfKg"));
            invisivel($("trVolumeKg"));

        }

    }

    function popRel() {
        var modelo;
        if (getObj("modelo1").checked)
            modelo = '1';
        else if (getObj("modelo2").checked)
            modelo = '2';
        else if (getObj("modelo3").checked)
            modelo = '3';
        else if (getObj("modelo4").checked)
            modelo = '4';

        var impressao;

        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";

        launchPDF('./reltabelapreco.jsp?acao=exportar&modelo=' + modelo + '&impressao=' + impressao + '&' + concatFieldValue("idconsignatario,idcidadeorigem,idcidadedestino,idareaorigem,idareadestino,idvendedor,idFreteMDe,idFreteMAte,idVoutrosDe,idVoutrosAte,idSeguroDe,idSeguroAte,idGrisDe,idGrisAte,idPedagioDe,idPedagioAte,idTaxaFixaDe,idTaxaFixaAte,idScDe,idScAte,idPesoKgDe,idPesoKgAte,idNfDe,idNfAte,idVolumeDe,idVolumeAte,idTipoPeso,idDatasEmVemDe,idDatasEmVemAte, idDataEmissaoVencimento,tipo_produto_id,apenasFilial"));
        //não sei quem ou por que trocaram o certo pelo .submit, mas estava
        //abrindo o relatorio na propria pagina.
        //$("formTPreco").action = './reltabelapreco.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&'+concatFieldValue("idconsignatario,idcidadeorigem,idcidadedestino,idareaorigem,idareadestino,idvendedor");
        //$("formTPreco").submit();

    }

    function aoClicarNoLocaliza(idjanela)
    {
        if (idjanela == "Area_Origem") {
            $('idareaorigem').value = $('area_id').value;
            $('area_ori').value = $('sigla_area').value;
        } else if (idjanela == "Area_Destino") {
            $('idareadestino').value = $('area_id').value;
            $('area_des').value = $('sigla_area').value;
        }
    }





</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Relatório de Tabelas de preços</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onload="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');
            aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <form id="formTPreco" action="./reltabelapreco.jsp?acao=exportar" method="post">    
            <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
                <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
                <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
                <input type="hidden" name="area_id" id="area_id" value="0">
                <input type="hidden" name="sigla_area" id="sigla_area" value="0">
                <input type="hidden" name="idareaorigem" id="idareaorigem" value="0">
                <input type="hidden" name="idareadestino" id="idareadestino" value="0">
                <input type="hidden" id="idvendedor" name="idvendedor" value="0"/>
                <input type="hidden" id="tipo_produto_id" name="tipo_produto_id" value="0"/>
            </div>
            <table width="90%" height="28" align="center" class="bordaFina" >
                <tr>
                    <td height="22"><b>Relat&oacute;rio de Tabelas de pre&ccedil;os</b></td>
                </tr>
            </table>
            <br>
            <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                <tr>
                    <td>
                        <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                            <tr class="tabela" id="">
                                <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                    <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<div id="tabPrincipal">

    <table width="90%" border="0" class="bordaFina" align="center">
        <tr class="tabela"> 
            <td colspan="3"><div align="center">Modelos</div></td>
        </tr>
        <tr> 
            <td width="50%" height="24" class="TextoCampos"> <div align="left"> 
                    <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos('1');">
                <label for="modelo1">Modelo 1</label></div></td>
            <td width="378" colspan="2" class="CelulaZebra2">Tabelas de pre&ccedil;os por faixa de peso</td>
        </tr>
        <tr> 
            <td width="99" height="24" class="TextoCampos"> <div align="left"> 
                    <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos('2');">
                <label for="modelo2">Modelo 2</label></div></td>
            <td width="378" colspan="2" class="CelulaZebra2">Tabelas de pre&ccedil;os por peso/vol/% NF</td>
        </tr>
        <tr> 
            <td width="99" height="24" class="TextoCampos"> <div align="left"> 
                    <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos('3');">
                <label for="modelo3">Modelo 3</label></div></td>
            <td width="378" colspan="2" class="CelulaZebra2">Tabelas de pre&ccedil;os por tipo de veículo</td>
        </tr>
        <tr> 
            <td width="99" height="24" class="TextoCampos"> <div align="left"> 
                    <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos('4');">
                <label for="modelo4">Modelo 4</label></div></td>
            <td width="378" colspan="2" class="CelulaZebra2">Tabelas de pre&ccedil;os por Km</td>
        </tr>
        <tr class="tabela"> 
            <td height="18" colspan="3"> 
                <div align="center">Filtros</div></td>
        </tr>

        <tr> 

            <td colspan="3"> 
                <table width="100%" border="0" align="center">

                    <tr>

                        <td class="CelulaZebra2">
                            <div align="right">
                                <select id="idDataEmissaoVencimento" name="idDataEmissaoVencimento" class="inputtexto">
                                    <option value="selecione"> Selecione </option>
                                    <option value="emissao_em">Data de Emissão</option>
                                    <option value="vencimento_em">Data de Vencimento</option>
                                </select>
                            </div>
                        </td>
                        <td class="CelulaZebra2">
                            <input id="idDatasEmVemDe" name="idDatasEmVemDe" size="10" class="fieldDate" type="text" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" maxlength="10"/>
                            à
                            <input id="idDatasEmVemAte" name="idDatasEmVemAte" size="10" class="fieldDate" type="text" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" maxlength="10"/>
                        </td>

                    </tr>
                    <tr id="trPesoKg">
                        <td class="TextoCampos">Peso/kg: </td>   
                        <td class="CelulaZebra2">            
                            <input type="text" size="10" id="idPesoKgDe" class="inputTexto" name="idPesoKgDe" value="">
                            à 
                            <input type="text" size="10" id="idPesoKgAte" class="inputTexto" name="idPesoKgAte" value="">
                            <select name="idTipoPeso" id="idTipoPeso" style="font-size:8pt;" class="inputtexto">
                                <option value="f" >FIXO</option>
                                <option value="k" >KG</option>
                                <option value="t" >TON</option>
                            </select>
                        </td>
                    </tr>
                    <tr id="trNfKg" style="display: none">
                        <td class="TextoCampos">% Nota Fiscal: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idNfDe" class="inputTexto" name="idNfDe"  value="">
                            à 
                            <input type="text" size="10" id="idNfAte" class="inputTexto" name="idNfAte"  value="">
                        </td>
                    </tr>
                    <tr id="trVolumeKg" style="display: none">
                        <td class="TextoCampos">R$ Volume: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idVolumeDe" class="inputTexto" name="idVolumeDe"  value="">
                            à 
                            <input type="text" size="10" id="idVolumeAte" class="inputTexto" name="idVolumeAte" value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Frete mínimo: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idFreteMDe" class="inputTexto" name="idFreteMDe"  value="">
                            à 
                            <input type="text" size="10" id="idFreteMAte" class="inputTexto" name="idFreteMAte"  value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Valor outros: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idVoutrosDe" class="inputTexto" name="idVoutrosDe"  value="">
                            à 
                            <input type="text" size="10" id="idVoutrosAte" class="inputTexto" name="idVoutrosAte"  value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Seguro: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idSeguroDe" class="inputTexto" name="idSeguroDe"  value="">
                            à 
                            <input type="text" size="10" id="idSeguroAte" class="inputTexto" name="idSeguroAte"  value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">GRIS: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idGrisDe" class="inputTexto" name="idGrisDe"  value="">
                            à 
                            <input type="text" size="10" id="idGrisAte" class="inputTexto" name="idGrisAte"  value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Pedágio: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idPedagioDe" class="inputTexto" name="idPedagioDe"  value="">
                            à 
                            <input type="text" size="10" id="idPedagioAte" class="inputTexto" name="idPedagioAte"  value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Taxa Fixa: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idTaxaFixaDe" class="inputTexto" name="idTaxaFixaDe"  value="">
                            à 
                            <input type="text" size="10" id="idTaxaFixaAte" class="inputTexto" name="idTaxaFixaAte"  value="">
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">SEC/CAT: </td>   
                        <td class="CelulaZebra2">
                            <input type="text" size="10" id="idScDe" class="inputTexto" name="idScDe"  value="">
                            à 
                            <input type="text" size="10" id="idScAte" class="inputTexto" name="idScAte"  value="">
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Tipo de Produto / Operação:</td>
                        <td class="CelulaZebra2">
                            <strong> 
                                <input name="tipo_produto" type="text" id="tipo_produto" class="inputReadOnly8pt" value="" size="35" maxlength="80" readonly="true">
                                <input name="localiza_tipo_produto" type="button" class="botoes" id="localiza_tipo_produto" value="..." 
                                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=37', 'tipo_produto')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" 
                                     onClick="javascript:getObj('tipo_produto').value = '';
                                     javascript:getObj('tipo_produto_id').value = '0';">
                            </strong>
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos" width="50%">Apenas o Cliente:</td>
                        <td class="CelulaZebra2" width="85%"><strong> 
                                <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly8pt" value="Tabela Principal" size="35" maxlength="80" readonly="true">
                                <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." 
                                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Cliente')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" 
                                     onClick="javascript:getObj('idconsignatario').value = '-1';
                                             javascript:getObj('con_rzs').value = 'Todas as tabelas';">
                            </strong></td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Apenas o Vendedor:</td>
                        <td class="CelulaZebra2">
                            <strong> 
                                <input name="ven_rzs" type="text" id="ven_rzs" class="inputReadOnly8pt" value="" size="35" maxlength="80" readonly="true">
                                <input name="localiza_vendedor" type="button" class="botoes" id="localiza_vendedor" value="..." 
                                       onClick="launchPopupLocate('./localiza?acao=consultar&idlista=27', 'Vendedor')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" 
                                     onClick="javascript:getObj('idvendedor').value = '0';
                                             getObj('ven_rzs').value = ''">
                            </strong>
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Apenas a &aacute;rea origem:</td>
                        <td class="CelulaZebra2">
                            <strong>
                                <input name="area_ori" type="text" id="area_ori" class="inputReadOnly" size="25" maxlength="80" readonly="true" value="">
                                <strong> </strong>

                                <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34', 'Area_Origem')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('area_ori').value = '';
                                        $('idareaorigem').value = 0;">
                            </strong>
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Apenas a &aacute;rea destino:</td>
                        <td class="CelulaZebra2"><strong>
                                <input name="area_des" type="text" id="area_des" class="inputReadOnly" size="25" maxlength="80" readonly="true" value="">
                                <strong> </strong>
                                <strong>
                                    <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34', 'Area_Destino')">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('area_des').value = '';
                                            $('idareadestino').value = 0;"></strong> 
                            </strong></td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">Apenas a cidade origem:</td>
                        <td class="CelulaZebra2"><input name="cid_origem" type="text" id="cid_origem" class="inputReadOnly" size="28" maxlength="80" readonly="true">
                            <input name="uf_origem" type="text" id="uf_origem" class="inputReadOnly" size="2" maxlength="80" readonly="true">
                            <strong>
                                <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade_Origem')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('uf_origem').value = '';
                                        $('cid_origem').value = '';
                                        $('idcidadeorigem').value = 0;"></strong></td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Apenas a cidade destino: </td>
                        <td class="CelulaZebra2"><input name="cid_destino" type="text" id="cid_destino" class="inputReadOnly" size="28" maxlength="80" readonly="true">
                            <input name="uf_destino" type="text" id="uf_destino" class="inputReadOnly" size="2" maxlength="80" readonly="true">
                            <strong>
                                <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=12', 'Cidade_Destino')">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('uf_destino').value = '';
                                        $('cid_destino').value = '';
                                        $('idcidadedestino').value = 0;"></strong></td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">Apenas a filial responsável:</td>
                        <td class="CelulaZebra2">
                            <select id="apenasFilial" name="apenasFilial" class="inputtexto">
                                <option value="0" selected>Todas</option>

                                <c:forEach items="${filiais}" var="filial">
                                    <option value="${filial.id}">${filial.abreviatura}</option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
        </tr>
        <tr>
            <td colspan="3" class="TextoCampos">
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
            <td colspan="3" class="TextoCampos"> <div align="center"> 
                    <% if (temacesso) {%>
                    <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function () {
                                popRel();
                            });">
                    <%}%>
                </div></td>
        </tr>
    </table>

</div>

<div id="tabDinamico">

</div>

</form>
</body>
</html>
