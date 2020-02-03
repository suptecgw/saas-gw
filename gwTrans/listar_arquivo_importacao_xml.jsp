
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>

<script type="text/javascript" language="JavaScript" charset="Iso-8859-1">
    function receberEmail(){
        abrirJanela("ArquivoImportacaoXMLControlador?acao=receberEmail&isCte="+$("isCte").checked+"&isNfe="+$("isNfe").checked+"&isMdfe="+$("isMdfe").checked, "bxXmlEmail", 20, 20);
    }
    
    function ConsultaDestinatario(){
        abrirJanela("ArquivoImportacaoXMLControlador?acao=ConsultaDestinatario","bxXmlEmail", 20, 20);
    }
    
    function desativarBotoes(){
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';
                
        document.formulario.valorConsulta.focus();
                
        if(atual == '1'){   
            document.formularioAnt.botaoAnt.disabled = true;
        }   
        if(parseFloat(atual) >= parseFloat(paginas)){
            document.formularioProx.botaoProx.disabled = true;
        }
    }
    
    function marcarTodos(){
        var i=1;
        while($("chk_"+i)!=null){
            if($("ckTodos").checked == true){
                $("chk_"+i).checked = true;
            }else{
                $("chk_"+i).checked = false;
            }
            i++;
        }
    }
    
    
    
    function getArquivosMarcados(){
        var ids = "";
        var i=1;
        while($("chk_"+i)!=null){
            console.log("entrou no laço");
            if ($("chk_"+i).checked == true) {
                ids += "," + $("chk_"+i).value;
            }
            i++;
        }
        return (ids == "" ? "" : ids.substr(1));
    }
    function exportarMarcados(){
        var ids = getArquivosMarcados();
        if (ids == "") {
            return false;
        }
        abrirJanela("ArquivosBaixadosXML.zip?acao=xmlImportado&arqIds="+ids, "bxZipEmail", 20, 20);
    }
    
    function setDefault(){
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';                
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';               
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';

        if (document.formulario.campoConsulta.selectedIndex == -1) {
            document.formulario.campoConsulta.selectedIndex = 0;
        }

        if ('<c:out value="${param.campoConsulta}"/>' == "aix.vl_doc") {
            $("vlDocIni").value = '<c:out value="${param.vlDocIni}"/>';
            $("vlDocFin").value = '<c:out value="${param.vlDocFin}"/>';
        }
        $("dataDe").value = '<c:out value="${param.dataDe}"/>';
        $("dataAte").value = '<c:out value="${param.dataAte}"/>';
        $("isCte").checked = ('<c:out value="${param.isCte}"/>' == "true");        
        $("isNfe").checked = ('<c:out value="${param.isNfe}"/>' == "true");        
        $("isMdfe").checked = ('<c:out value="${param.isMdfe}"/>' == "true");
        $("isCteCancelamento").checked = ('<c:out value="${param.isCteCancelamento}"/>' == "true");
        $("isNfeFrete").checked = ('<c:out value="${param.isNfeFrete}"/>' == "true");
        $("isMotorista").checked = ('<c:out value="${param.isMotorista}"/>' == "true");
        $("isProprietario").checked = ('<c:out value="${param.isProprietario}"/>' == "true");
        $("isVeiculo").checked = ('<c:out value="${param.isVeiculo}"/>' == "true");
        $("isNotfis").checked = ('<c:out value="${param.isNotfis}"/>' == "true");
        $("isMdfeCancelamento").checked = ('<c:out value="${param.isMdfeCancelamento}"/>' == "true");
        $("isMdfeEncerramento").checked = ('<c:out value="${param.isMdfeEncerramento}"/>' == "true");
        document.querySelector('input[name="radioTipoXML"][value="${param.radioTipoXML}"]').click();
        $('valorConsultaEmissor').value = '${param.valorConsultaEmissor}';
    }
       
    function abrirCadastro(){
        window.location = "ArquivoImportacaoXMLControlador?acao=novoCadastro&modulo=gwTrans";
    }          

    function excluir(id, chave, tipoDocumento){
        if(confirm("Deseja Excluir o Arquivo "+chave+" ?" )){
            if(confirm("Tem certeza?" )){
                if (tipoDocumento != '9') {
                    // Se não for Notfis
                    window.open("ArquivoImportacaoXMLControlador?acao=excluir&modulo=gwTrans&arquivoId=" + id+"&chaveAcesso="+chave,
                    "pop", "width=210, height=100");
                } else {
                    // Se for Notfis
                    window.open("ArquivoImportacaoXMLControlador?acao=excluirNotfis&modulo=gwTrans&arquivoId=" + id, "pop", "width=210, height=100");
                }
            }
        }
    }

    function habilitaConsultaDePeriodo(elemento) {
        var valor = elemento.value;
        
        document.getElementById("valorConsulta").style.display = "";
        document.getElementById("operadorConsulta").style.display = "";
        document.getElementById("div1").style.display = "none";
        document.getElementById("div2").style.display = "none";
        document.getElementById("div3").style.display = "none";
        document.getElementById("div4").style.display = "none";
        
        switch(valor){
            case "aix.vl_doc":
                document.getElementById("operadorConsulta").style.display = "none";
                document.getElementById("valorConsulta").style.display = "none";
                document.getElementById("div3").style.display = "";
                document.getElementById("div4").style.display = "";
                break;
            case "aix.dt_emissao::date":
                document.getElementById("operadorConsulta").style.display = "none";
                document.getElementById("valorConsulta").style.display = "none";
                document.getElementById("div1").style.display = "";
                document.getElementById("div2").style.display = "";
                break;
            case "aix.created_at::date":
                document.getElementById("operadorConsulta").style.display = "none";
                document.getElementById("valorConsulta").style.display = "none";
                document.getElementById("div1").style.display = "";
                document.getElementById("div2").style.display = "";
                break;
            default:
                document.getElementById("valorConsulta").style.display = "";
                document.getElementById("operadorConsulta").style.display = "";
                if (document.getElementById("operadorConsulta").value == ''){
                    document.getElementById("operadorConsulta").value = '1';
                }
                break;
        }
    }
    
    function baixarNFes(){
        window.open("ArquivoImportacaoXMLControlador?acao=baixarNFE", "BaixarNotas", "width=210, height=100");
    }
    function baixarCTes(){
        window.open("ArquivoImportacaoXMLControlador?acao=baixarCTE", "BaixarConhecimentos", "width=210, height=100");
    }
    
    function alterarStatusNotfisGWi(idNotfis, numeroNotfis, desativado) {
        if (confirm("Deseja " + (desativado ? "ativar" : "desativar") + " o Notfis número " + numeroNotfis + " do GW-i?")) { 
            window.open("ArquivoImportacaoXMLControlador?acao=alterarStatusNotfis&idNotfis=" + idNotfis, "pop", "width=500, height=200");
        }
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
        <title>Webtrans - Consulta de XML Sincronizado E-mail/SEFAZ</title>
        
    </head>
    
    
    <body onload="applyFormatter();desativarBotoes(), setDefault(); habilitaConsultaDePeriodo($('campoConsulta'));"> 
        <img src="img/banner.gif" alt=""><br/>
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="50%" align="left"> <span class="style4">Consulta de XML Sincronizado E-mail/SEFAZ</span></td>
                <td width="50%" align="right">
                    <!--Consultar Destinatario não está sendo utilizado no momento.-->
                    <input name="btConsultaDest" id="btConsultaDest" type="button" class="inputbotao" value="  Consultar Destinatário  " style="display: none" onclick="tryRequestToServer(function(){ConsultaDestinatario();});" />
                    <input name="btReceberEmail" id="btReceberEmail" type="button" class="inputbotao" value="  Baixar XML(s) do E-mail  " onclick="tryRequestToServer(function(){receberEmail();});" />
                    <input type="button" value="Baixar NF-e da SEFAZ" onclick="javascript:baixarNFes()" class="inputbotao" >
                    <input type="button" value="Baixar CT-e da SEFAZ" onclick="javascript:baixarCTes()" class="inputbotao" >
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="90%" align="center">
            <form action="ArquivoImportacaoXMLControlador?acao=listar&modulo=gwTrans" id="formulario" name="formulario" method="post">
                <tr>
                    <td width="23%" class="CelulaZebra1">
                        <select name="campoConsulta"  id="campoConsulta" class="inputtexto" 
                                onclick="habilitaConsultaDePeriodo(this)">
                            <option value="aix.dt_emissao::date">Dt. Emissão do Documento</option>
                            <option value="aix.created_at::date">Dt. Importação do Documento</option>
                            <option value="aix.num_doc">Número do Documento</option>
                            <option value="aix.chave_acesso">Chave de Acesso do Documento</option>
                            <option value="aix.vl_doc">Valor do Documento</option>
                        </select>             
                    </td>
                    <td width="17%" class="CelulaZebra1NoAlign" align="center" height="20">
                        <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                        <div id="div1" style="display:none">De:
                            <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                        </div>
                        <div id="div3" style="display:none">De:
                            <input name="vlDocIni" type="text" id="vlDocIni" size="10" maxlength="10"  class="fieldDecimal">
                        </div>
                    </td>
                    <td width="30%" class="CelulaZebra1NoAlign" align="center">
                        <div id="div2" style="display:none ">Até:
                            <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                        </div>
                        <div id="div4" style="display:none ">Até:
                            <input name="vlDocFin" type="text" id="vlDocFin" size="10" maxlength="10"  class="fieldDecimal">
                        </div>
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                    </td>
                    <td width="20%" class="CelulaZebra1NoAlign" align="center">  
                        <select   name="limiteResultados"  class="inputtexto">
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                    <td width="20%" class="CelulaZebra1NoAlign" rowspan="4" align="center">
                        <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" 
                               value="  Pesquisar  " onclick="tryRequestToServer(function(){document.formulario.submit();});" />
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1">  
                        Tipo do Documento:
                    </td>
                    <td class="CelulaZebra1" colspan="3">  
                        <label>
                            <input type="checkbox" name="isCte" id="isCte" /> CT-e
                        </label>
                        <label>
                            <input type="checkbox" name="isNfe" id="isNfe" /> NF-e
                        </label>
                        <label>
                            <input type="checkbox" name="isMdfe" id="isMdfe" /> MDF-e
                        </label>
                        <label>
                            <input type="checkbox" name="isCteCancelamento" id="isCteCancelamento" /> CT-e Cancelamento                            
                        </label>
                        <label>
                            <input type="checkbox" name="isNfeFrete" id="isNfeFrete" /> NFe Frete                            
                        </label>
                        <label>
                            <input type="checkbox" name="isMotorista" id="isMotorista" /> Motorista
                        </label>
                        <label>
                            <input type="checkbox" name="isProprietario" id="isProprietario" /> Proprietário
                        </label>
                        <label>
                            <input type="checkbox" name="isVeiculo" id="isVeiculo" /> Veículo
                        </label>
                        <label>
                            <input type="checkbox" name="isNotfis" id="isNotfis" /> Notfis
                        </label>
                        <label>
                            <input type="checkbox" name="isMdfeCancelamento" id="isMdfeCancelamento" /> MDFe Cancelamento
                        </label>
                        <label>
                            <input type="checkbox" name="isMdfeEncerramento" id="isMdfeEncerramento" /> MDFe Encerramento
                        </label>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1">
                        Emissor:
                    </td>
                    <td class="CelulaZebra1" colspan="3">
                        <input name="valorConsultaEmissor" type="text" class="inputtexto" id="valorConsultaEmissor" size="50" onKeyUp="if (event.keyCode==13) $('pesquisar').click();">
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1">  
                        Mostrar os XMLS baixados:
                    </td>
                    <td class="CelulaZebra1" colspan="3">
                        <label>
                            <input type="radio" name="radioTipoXML" value="ambos" checked> Ambos
                        </label>
                        <label>
                            <input type="radio" name="radioTipoXML" value="sefaz"> Pela SEFAZ
                        </label>
                        <label>
                            <input type="radio" name="radioTipoXML" value="email"> Por e-mail
                        </label>
                    </td>
                </tr>
            </form>
        </table>
        <table width="90%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>                
                <td class="tabela" width="3%" align="center">
                    <input type="checkbox" id="ckTodos" name="ckTodos" onclick="marcarTodos();" />
                </td>
                <td class="tabela" width="3%" align="center"></td>
                <td class="tabela" width="3%" align="center">
                    <img class="imagemLink" alt="" title="Baixar Todos Arquivos Selecionados" onclick="exportarMarcados();" id="img_down_all" width="25px" src="img/down.png">
                </td>
                <td class="tabela" width="5%" align="center">Tipo Doc.</td>
                <td class="tabela" width="5%" align="center">Num. Doc</td>
                <td class="tabela" width="4%" align="center">Série</td>
                <td class="tabela" width="6%" align="center">Dt. Emissão</td>
                <td class="tabela" width="17%" align="center">Emissor</td>
                <td class="tabela" width="11%" align="center">CNPJ</td>
                <td class="tabela" width="6%" align="right">Valor</td>
                <td class="tabela" width="20%" align="center">Chave Acesso</td>
                <td class="tabela" width="9%" align="center">Dt. Inclusão</td>
                <td class="tabela" width="3%" align="center">NSU</td>
                <td class="tabela" width="3%" align="center"></td>
            </tr>
            <c:forEach var="arquivo" varStatus="status" items="${listaArquivos}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                    <td align="center">
                        <input type="checkbox" value="${arquivo.id}" id="chk_${status.count}" name="selecionarTodos"  />
                    </td>
                    <td align="center">
                        <c:choose>
                            <c:when test="${arquivo.layoutDoc != NOTFIS}">
                                <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  
                                   href="./${arquivo.chaveAcesso}.xml?acao=gerarXmlImportado&arqId=${arquivo.id}" target="pop3">
                                    <img class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml_${status.count}" width="25px" src="img/xml.png">
                                </a>
                            </c:when>
                            <c:otherwise>
                                <!-- Botão ativar/desativar notfis do GW-i -->
                                <a onClick="javascript:tryRequestToServer(function(){alterarStatusNotfisGWi('${arquivo.id}', '${arquivo.numDoc}', '${arquivo.desativado}');});">
                                    <img class="imagemLink" alt="" title="${arquivo.desativado ? "Ativar" : "Desativar"} Notfis do GW-i"
                                         id="img_xml_${status.count}" width="25px"
                                         src="img/gwi-${arquivo.desativado ? "desativado" : "ativo"}.png">
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td align="center">
                        <c:choose>
                            <c:when test="${arquivo.layoutDoc != NOTFIS}">
                                <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  
                                   href="./${arquivo.chaveAcesso}.zip?acao=xmlImportado&arqIds=${arquivo.id}" target="pop3">
                                    <img class="imagemLink" alt="" title="Baixar XML Cliente" id="img_down_${status.count}" width="25px" src="img/down.png">
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  
                                   href="./Notfis_${arquivo.numDoc}.zip?acao=baixarNotfis&arqIds=${arquivo.id}" target="pop3">
                                    <img class="imagemLink" alt="" title="Baixar Notfis" id="img_down_${status.count}" width="25px" src="img/down.png">
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <!--<td align="center">$ {arquivo.layoutDoc == 1 ? 'NF-e' : arquivo.layoutDoc == 2 ? 'CT-e' : arquivo.layoutDoc == 3 ? 'MDF-e' : arquivo.layoutDoc == 4 ? 'CT-e Cancelamento' : 'NFe Frete'}</td>-->
                    <td align="center">${arquivo.descricaoDoc}</td>
                    <td align="center">${arquivo.numDoc}</td>
                    <td align="center">${arquivo.serie}</td>
                    <td align="center">${arquivo.dtEmissao}</td>
                    <td align="center">${arquivo.emissor.razaosocial}</td>
                    <td align="center">${arquivo.emissor.cnpj}</td>
                    <td align="right"><fmt:formatNumber value="${arquivo.vlDoc}" pattern="###0.00"/></td>
                    <td align="center">${arquivo.chaveAcesso}</td>
                    <td align="center">${arquivo.criadoEm}</td>
                    <td align="center">${arquivo.nsu}</td>
                    <td align="center"><img class="imagemLink" alt="" title="Excluir arquivo" src="./img/lixo.png" id="bot_excluir_${status.count}" onClick="javascript:tryRequestToServer(function(){excluir(${arquivo.id},'${arquivo.chaveAcesso}','${arquivo.layoutDoc}');})"></td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="90%" align="center" >
            <tr class="CelulaZebra1">
                <td width="50%" align="center">Total de Ocorr&ecirc;ncias: 
                  <c:out value="${param.qtdResultados}"/></td>
                <td width="20%" align="center">P&aacute;ginas: 
                  <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
                
                
                <form id="formularioAnt" name="formularioAnt" action="ArquivoImportacaoXMLControlador?acao=listar&modulo=gwTrans" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input type="hidden" name="isCte" value="<c:out value='${param.isCte}'/>"/>
                        <input type="hidden" name="isNfe" value="<c:out value='${param.isNfe}'/>"/>
                        <input type="hidden" name="isMdfe" value="<c:out value='${param.isMdfe}'/>"/>
                        <input type="hidden" name="isNfeFrete" value="<c:out value='${param.isNfeFrete}'/>"/>
                        <input type="hidden" name="isMotorista" value="<c:out value='${param.isMotorista}'/>"/>
                        <input type="hidden" name="isProprietario" value="<c:out value='${param.isProprietario}'/>"/>
                        <input type="hidden" name="isVeiculo" value="<c:out value='${param.isVeiculo}'/>"/>
                        <input type="hidden" name="isNotfis" value="<c:out value='${param.isNotfis}'/>"/>
                        <input type="hidden" name="isMdfeCancelamento" value="<c:out value='${param.isMdfeCancelamento}'/>"/>
                        <input type="hidden" name="isMdfeEncerramento" value="<c:out value='${param.isMdfeEncerramento}'/>"/>
                        <input type="hidden" name="radioTipoXML" value="<c:out value='${param.radioTipoXML}'/>"/>
                        <input type="hidden" name="valorConsultaEmissor" value="<c:out value='${param.valorConsultaEmissor}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </td>
                </form>
                <form id="formularioProx" name="formularioProx"  action="ArquivoImportacaoXMLControlador?acao=listar&modulo=gwTrans" method="post">
                    <td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input type="hidden" name="isCte" value="<c:out value='${param.isCte}'/>"/>
                        <input type="hidden" name="isNfe" value="<c:out value='${param.isNfe}'/>"/>
                        <input type="hidden" name="isMdfe" value="<c:out value='${param.isMdfe}'/>"/>
                        <input type="hidden" name="isNfeFrete" value="<c:out value='${param.isNfeFrete}'/>"/>
                        <input type="hidden" name="isMotorista" value="<c:out value='${param.isMotorista}'/>"/>
                        <input type="hidden" name="isProprietario" value="<c:out value='${param.isProprietario}'/>"/>
                        <input type="hidden" name="isVeiculo" value="<c:out value='${param.isVeiculo}'/>"/>
                        <input type="hidden" name="isNotfis" value="<c:out value='${param.isNotfis}'/>"/>
                        <input type="hidden" name="isMdfeCancelamento" value="<c:out value='${param.isMdfeCancelamento}'/>"/>
                        <input type="hidden" name="isMdfeEncerramento" value="<c:out value='${param.isMdfeEncerramento}'/>"/>
                        <input type="hidden" name="radioTipoXML" value="<c:out value='${param.radioTipoXML}'/>"/>
                        <input type="hidden" name="valorConsultaEmissor" value="<c:out value='${param.valorConsultaEmissor}'/>"/>
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </td>
                </form>
            </tr>
        </table>
        
    </body>
</html>

