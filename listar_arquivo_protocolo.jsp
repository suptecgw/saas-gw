<%-- 
    Document   : listar_arquivo_protocolo
    Created on : 13/06/2016, 09:41:48
    Author     : airton
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">



<html>
    <head>

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script type="text/javascript" language="JavaScript">
  // jQuery.noConflict();
    
    function abrirCadastro(){
        window.location = "ArquivarProtocoloControlador?acao=novoCadastro";
    } 
    
    function setDefault(){
        var campoConsulta = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';                
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';               
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
        document.formulario.dataDe.value = '<c:out value="${param.dataDe}"/>';
        document.formulario.dataAte.value = '<c:out value="${param.dataAte}"/>';
        document.formulario.campoConsulta.value = campoConsulta;
        
        habilitaConsultaDePeriodo(campoConsulta);
    }
    
    function excluir(id, referencia){
    if(confirm("Deseja excluir o arquivamento protocolo '" + referencia + "'?" )){
        if(confirm("Tem certeza?" )){                
            window.open("ArquivarProtocoloControlador?acao=excluir&id=" + id + "&referencia=" + referencia,
            "pop", "width=210, height=100");
            }
        }
    }
    
    function desativarBotoes(){
    var atual = '<c:out value="${param.paginaAtual}"/>';
    var paginas = '<c:out value="${param.paginas}"/>';


    if(atual == '1'){   
        document.formularioAnt.botaoAnt.disabled = true;
    }   
    if(parseFloat(atual) >= parseFloat(paginas)){
        document.formularioProx.botaoProx.disabled = true;
    }

    document.formulario.valorConsulta.focus();
    }
    
    function habilitaConsultaDePeriodo(opcao){
        if(opcao == 'ap.arquivado_em' || opcao == 'ap.ficar_arquivado_ate'){
            $("valorConsulta").style.display = (opcao ? "none" : "");
            $("operadorConsulta").style.display = (opcao ? "none" : "");
            $("div1").style.display = (opcao ? "" : "none");
            $("div2").style.display = (opcao ? "" : "none");
        }else{
            $("div1").style.display = (opcao ? "none" : "");
            $("div2").style.display = (opcao ? "none" : "");
            $("valorConsulta").style.display = (opcao ? "" : "none");
            $("operadorConsulta").style.display = (opcao ? "" : "none");
        }
    }
    

    var linha = 0;
    function checkTodos(){
 
       var i = 1 , check = false;
            
        if ($("ckTodos").checked){
            check = true;
        }
        while ($("ck_"+i) != null){
          $("ck_"+i).checked = check;
           i++
        }
    }

    
    function imprimirMarcados(){
        var ids = "0";
        var maxArq = $("maxArquivamento").value;
        for (var qtdArq = 1; qtdArq <= maxArq; qtdArq++) {
            if ($("ck_"+qtdArq) != null && $("ck_"+qtdArq).checked) {
                ids += "," + $("ck_"+qtdArq).value;
            }
        }        
        return ids;
    }
    
    function popArquivamentoProtocolo(id){
        
        if(id == null || id == undefined){
            id = imprimirMarcados();
            if(imprimirMarcados() == 0){
                alert("Selecione ao menos 1 arquivamento protocolo!!!");
                    return null;
            }
        }

        var impressao = "1";
        launchPDF('RelatorioControlador?acao=exportaArquivamentoProtocolo&modelo=' + $('arquivamentoprotocolomodelo').value + "&id="+id+"&impressao="+impressao,'arquivamentoprotocolo'+id);
    }
    
</script>
<style type="text/css">
    <!--
    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }
    -->
</style>
    
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">       
    <title>webtrans - Arquivar Protocolo</title>
        
    </head>
    <body onload="setDefault();desativarBotoes();">
        <img src="img/banner.gif">
        <table class="bordaFina" width="70%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta de Arquivamento de Protocolo</span>
                </td>
                <c:if test="${param.nivel >= 3}">
                <td width="18%">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro()})" value="Novo Cadastro"/>
                </td>
                </c:if>
            </tr>
        </table>
        <br>
        
                <!--
                Dados da consulta
                -->
                <form action="ArquivarProtocoloControlador?acao=listar" id="formulario" name="formulario" method="post">
        <table class="bordaFina" width="70%" align="center">
            <tr>
                    <td width="110" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onchange="habilitaConsultaDePeriodo(this.value)">
                            <option value="ap.arquivado_em">Data</option>
                            <option value="ap.referencia">Referência</option>
                            <option value="ap.ficar_arquivado_ate">Arquivado Até</option>
                            <option value="ap.local_armazenado">Local Armazenado</option>
                            <option value="ap.conteudo">Conteúdo</option>
                            <option value="numero_protocolos">Número do protocolo</option>
                        </select>                    
                    </td>
                    <td width="168" class="CelulaZebra1" height="20">
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" style="display:none">
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>   
                        <div id="div1" class="CelulaZebra1">De:
                            <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                        </div>
                    </td>
                    
                    <td width="250" class="CelulaZebra1" height="20">
                        <input name="valorConsulta" style="display:none" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                        <div id="div2" class="CelulaZebra1">
                            Até:
                            <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate">
                        </div>
                        <label></label>
                    </td>
                    <td width="10" class="CelulaZebra1">
                        <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onClick="document.formulario.submit();"  />
                    </td>
                    <td width="10" class="CelulaZebra1">
                        <select   name="limiteResultados" class="inputtexto"  >
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
            </tr>
        </table>
                </form>
        
                <!--
                Lista
                -->
        <table width="70%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>
                <td class="tabela" width="2%" align="left"></td>
                <td class="tabela" width="2%"><input name="ckTodos" id="ckTodos" type="checkbox" onClick="checkTodos()"></td>
                <td class="tabela" width="2%"><img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popArquivamentoProtocolo(null);});"></td>
                <td class="tabela" width="15%" align="left">Referência</td>
                <td class="tabela" width="15%" align="left">Data</td>
                <td class="tabela" width="15%" align="left">Arquivado até</td>
                <td class="tabela" width="15%" align="left">Local Armazenado</td>
                <td class="tabela" width="15%" align="left">Conteúdo</td>
                <td class="tabela" width="10%" align="left">QTD de protocolos</td>
            </tr>
            <c:forEach var="tArquivamentoProtocolo" varStatus="status" items="${listaArquivamentoProtocolo}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                    
                    <td align="center">
                        <c:if test="${param.nivel >= 4}">
                            <a href="javascript: excluir( '${tArquivamentoProtocolo.id}','${tArquivamentoProtocolo.referencia}');"> 
                                <img id="excluirPallet" name="excluirPallet" class="imagemLink" src="img/lixo.png"/> 
                            </a>
                        </c:if>                    
                    </td>
                    <td>
                        <input type="checkbox" id="ck_${status.count}" name="ck_${status.count}" value="${tArquivamentoProtocolo.id}">
                    </td>
                    <td>
                        <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popArquivamentoProtocolo('${tArquivamentoProtocolo.id}');});">
                    </td>
                    <td>
                        <a href="javascript: window.location='ArquivarProtocoloControlador?acao=iniciarEditar&id=${tArquivamentoProtocolo.id}';" class="linkEditar">${tArquivamentoProtocolo.referencia}</a>
                        <input id="descricaoArquivamento_${status.count}" name="descricaoArquivamento_${status.count}" value="${tArquivamentoProtocolo.referencia}" type="hidden">
                    </td>
                    <td>
                        ${tArquivamentoProtocolo.arquivadoEm}
                    </td>
                    <td>
                        ${tArquivamentoProtocolo.ficarArquivadoAte}
                    </td>
                    <td>
                        ${tArquivamentoProtocolo.localArmazenado}
                    </td>
                    <td>
                        ${tArquivamentoProtocolo.conteudo}
                    </td>
                    <td align="center">
                        ${tArquivamentoProtocolo.qtdProtocolo}
                        
                    </td>
                </tr>
                <c:if test="${status.last}">
                    <input type="hidden" name="maxArquivamento" id="maxArquivamento" value="${status.count}">
                </c:if>
            </c:forEach>
        </table>
        
                <!--
                Antes e Depois
                -->
        <br>
        <table class="bordaFina" width="70%" align="center" >
            <tr class="CelulaZebra1">
                <td width="18%" align="center">Total de Ocorr&ecirc;ncias:
                    <c:out value="${param.qtdResultados}"/>
                </td>
                <td width="15%" align="center">P&aacute;ginas:
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>

                <td width="10%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="ArquivarProtocoloControlador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="10%" align="center">
                    <form id="formularioProx" name="formularioProx"  action="ArquivarProtocoloControlador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>
           <!--
           Impressão de arquivamento
           -->
           <td colspan="5" align="right">
                Modelo de Impressão em PDF:
                <select name="arquivamentoprotocolomodelo" id="arquivamentoprotocolomodelo" class="inputtexto">
                    <option value="1" selected>Modelo 1</option>

                </select>
            </td>
           </tr>
        </table>
                                
    </body>
</html>
