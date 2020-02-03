<%@page import="nucleo.Apoio"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Consulta de Inutilizações (CT-e)</title>

        <%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
        <fmt:setLocale value="pt-BR" />
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">

    <link href="estilo.css" rel="stylesheet" type="text/css">    
    <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
    <script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
    <script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
    <script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
    <script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
    <script type="text/javascript" language="JavaScript">
    shortcut.add("enter",function() {pesq()});
    
        jQuery.noConflict();
        var countRow = 0;
        function abrirCadastro(){            
            window.location = "InutilizacaoControlador?acao=novaInutilizacao";
        }

        function pesq(){
            document.formulario.filial.disabled = false;
            document.formulario.submit();
            document.formulario.filial.disabled = true;
        }

        function habilitaConsultaDePeriodo(opcao)
        {
            document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");
        }

        function setDefault(){
            document.formulario.valorConsulta.focus();
            document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';
            document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
            var campoConsulta = '<c:out value="${param.campoConsulta}"/>';
            document.formulario.campoConsulta.value = campoConsulta;
            document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
            document.formulario.entradaDe.value = '<c:out value="${param.entradaDe}"/>';
            document.formulario.entradaAte.value = '<c:out value="${param.entradaAte}"/>';
            document.formulario.nfIni.value = '<c:out value="${param.nfIni}"/>'.trim();
            document.formulario.nfFin.value = '<c:out value="${param.nfFin}"/>'.trim();
            document.formulario.filial.value = '<c:out value="${param.filial}"/>';

            if(campoConsulta == 'data_hora_autorizacao::date'){
                habilitaConsultaDePeriodo(true);
            }
            var nivel = parseInt('<c:out value="${param.nivelFilial}"/>' ) ;
            if (nivel >0){
                document.formulario.filial.disabled = false;              
            }else{
                document.formulario.filial.disabled = true;              
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
        }

        function popXml(numero, inutId){            
            if (numero == null)
                return null;    
            
            window.open("./"+inutId+"-inutCTe.xml?acao=gerarXmlClienteInut&protocolo=" + numero + "&idInut=" + inutId, "pop", "width=210, height=100");
        }
        
        function pesquisarInutilizacoes(){
            abrirMax('about:blank', 'popConsultaCompleta');
            $("chaveConsulta").value = <%= Apoio.getUsuario(request).getFilial().getCnpj() %>; 
            $("formConsulta").submit();
        }
    </script>

    <style  type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }

        .style5 {
            color:red;
        }
        -->
    </style>

</head>
<body onload="desativarBotoes(), setDefault(), applyFormatter()"  >
    <img alt="Webtrans" src="img/banner.gif" width="30%" height="44" align="middle">
    <table class="bordaFina" width="75%" align="center">
        <tr>
            <td width="80%" align="left"> <span class="style4">Consulta de Numerações Inutilizadas (CT-e)</span>
            </td>
            <td width="20%">
                <input name="pesquisar" type="button" value="Consultar Inutilização" class="inputbotao" onclick="pesquisarInutilizacoes()">
                <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro();});" value="Nova Inutilização"/>
            </td>
        </tr>
    </table>
    <br>
    <form action="InutilizacaoControlador?acao=listar" id="formulario" name="formulario" method="post">
        <table class="bordaFina" width="75%" align="center">
            <tr>
                <td width="15%" class="CelulaZebra1">
                    <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onchange="habilitaConsultaDePeriodo(this.value == 'data_hora_autorizacao::date')">
                        <option value="numero">Protocolo</option>
                        <option value="data_hora_autorizacao::date">Data</option>
                        <option value="serie_inutilizacao">Série</option>
                    </select>
                </td>
                <td width="25%" class="CelulaZebra1" height="20">
                    <div id="div1" style="display:none">De:
                        <input name="entradaDe" type="text" id="entradaDe" size="10" maxlength="10"  class="fieldDate" onblur="alertInvalidDate(this)">
                    </div>
                    <select name="operadorConsulta" id="operadorConsulta" class="inputtexto">
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select>
                </td>
                <td width="25%" class="CelulaZebra1">
                    <div id="div2" style="display:none ">Até:
                        <input name="entradaAte" type="text" id="entradaAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25">
                </td>
                <td width="20%" class="CelulaZebra1">
                    <div align="center">
                        <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function(){pesq();});" />
                    </div>
                </td>
                <td width="15%" class="CelulaZebra1" rowspan="2">
                    <select   name="limiteResultados" class="inputtexto" >
                        <option value="10">10 Resultados</option>
                        <option value="20">20 Resultados</option>
                        <option value="30">30 Resultados</option>
                        <option value="40">40 Resultados</option>
                        <option value="50">50 Resultados</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="CelulaZebra1" >
                    <div align="right">
                        Entre os CT-es:
                    </div>
                </td>
                <td class="CelulaZebra1">
                    <input name="nfIni" type="text" class="inputtexto"  id="nfIni" size="7">
                    e
                    <input name="nfFin" type="text" class="inputtexto"  id="nfFin" size="7">
                </td>
                <td  class="CelulaZebra1" colspan="2">
                    <select name="filial" id="filial" class="inputtexto" disabled>
                        <option value="0">Todas as Filiais</option>
                        <c:forEach var="filial" items="${filiaisListSaidaMercadoria}">
                            <option value="${filial.id}">Apenas a ${filial.abreviatura}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
        </table>
    </form>
    <form action=""  method="post" name="formMatricial" id="formMatricial" target="pop">
        <table width="75%"  class="bordaFina" align="center" style="vertical-align:top">
            <tr>
                <td class="tabela" width="3%" align="left"></td>
                <td class="tabela" width="32%" align="left">Protocolo</td>
                <td class="tabela" width="10%" align="left">Série</td>
                <td class="tabela" width="10%" align="left">De</td>
                <td class="tabela" width="10%" align="left">Até</td>
                <td class="tabela" width="35%" align="center">Data/Hora Recibo</td>
            </tr>
            <c:forEach var="prot" varStatus="status" items="${listaListInut}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                    <td>                    
                            <a onclick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  href="./${prot.idInutilizacao}-inutCTe.xml?acao=gerarXmlClienteInut&protocolo=${prot.numero}&idInut=${prot.idInutilizacao}"  target="pop3">
                            <img alt="" class="imagemLink" id="imagemLink"  src="img/xml.png" />
                        </a>
                    </td>
                    <td >
                        <script type="text/javascript">countRow++;</script>
                        ${prot.numero}
                    </td>
                    <td >
                        ${prot.serieInutilizacao}
                    </td>
                    <td >
                        ${prot.ctrcDe}
                    </td>
                    <td >
                        ${prot.ctrcAte}
                    </td>
                    <td align="center">
                        <fmt:formatDate dateStyle="short" value="${prot.dataHoraAutorizacao}"/>  /                        
                        <fmt:formatDate pattern="HH:mm" value="${prot.dataHoraAutorizacao}"/> 
                    </td>
                </tr>
            </c:forEach>
        </table>
    </form>
    <table class="bordaFina" width="75%" align="center" >
        <tr class="CelulaZebra1">
            <td width="54%" align="center">Total de Ocorr&ecirc;ncias
                <c:out value="${param.qtdResultados}"/></td>
            <td width="19%" align="center">P&aacute;ginas
                <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
            <td width="13%" align="center">
                <form id="formularioAnt" name="formularioAnt" action="InutilizacaoControlador?acao=listar" method="post">
                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                    <input type="hidden" name="entradade" value="<c:out value="${param.entradaDe}"/>">
                    <input type="hidden" name="entradaAte" value="<c:out value="${param.entradaAte}"/>">
                    <input type="hidden" name="nfIni" value="<c:out value="${param.nfIni}"/>">
                    <input type="hidden" name="nfFin" value="<c:out value="${param.nfFin}"/>">

                    <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                </form>
            </td>
            <td width="14%" align="center">
                <form id="formularioProx" name="formularioProx"  action="InutilizacaoControlador?acao=listar" method="post">
                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>"/>
                    <input type="hidden" name="entradade" value="<c:out value="${param.entradaDe}"/>">
                    <input type="hidden" name="entradaAte" value="<c:out value="${param.entradaAte}"/>">
                    <input type="hidden" name="nfIni" value="<c:out value="${param.nfIni}"/>">
                    <input type="hidden" name="nfFin" value="<c:out value="${param.nfFin}"/>">

                    <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                </form>
                <form action="http://www.cte.fazenda.gov.br/consulta.aspx?tipoConsulta=inutilizacao" id="formConsulta" method="post" target="popConsultaCompleta">
                    <input type="hidden" id="chaveConsulta" name="ctl00$ContentPlaceHolder1$txtCNPJInutilizacao" value=""/>                        
                    <input type="hidden" name="__EVENTARGUMENT">
                    <input type="hidden" name="__EVENTVALIDATION" value="/wEWFQKW+aizCALnzPHfDgKC+5r9AgKv1eaJDQKv1crCCgLKvoxzArbj59AHAtGHzdsKAtix6N8HAtix7N8HAtix0N8HAtix1N8HAtix2N8HAsextNwHAsexuNwHAsex/N8HAsex4N8HArXmppIHArSuz6AIAvu966YBAreF0YcNcF6gInNL1GcEWszrOkGm+DSfC+s=">
                    <input type="hidden" name="__VIEWSTATE" value="/wEPDwUJMTE4NDI1Nzk5D2QWAmYPZBYCAgMPZBYOAgkPDxYCHgRUZXh0BRA2NjUsMDI3IG1pbGjDtWVzZGQCDQ8PFgIfAAUKNjksNzI2IG1pbGRkAg8PDxYCHgtOYXZpZ2F0ZVVybAUVaW5mb0VzdGF0aXN0aWNhcy5hc3B4ZGQCFQ8PFgIfAQU0fi9QZXJndW50YXNGcmVxdWVudGVzLmFzcHg/dGlwb0NvbnRldWRvPWw1aW1PVmxEcVBVPWRkAiEPPCsAEQIADxYEHgtfIURhdGFCb3VuZGceC18hSXRlbUNvdW50AgRkARAWABYAFgAWAmYPZBYMZg8PFgIeB1Zpc2libGVoZGQCAQ9kFgJmD2QWAgIBDw8WBh4NQWx0ZXJuYXRlVGV4dAUrTWFuaWZlc3RvIEVsZXRyw7RuaWNvIGRlIERvY3VtZW50b3MgRmlzY2Fpcx4PQ29tbWFuZEFyZ3VtZW50BSRodHRwczovL21kZmUtcG9ydGFsLnNlZmF6LnJzLmdvdi5ici8eCEltYWdlVXJsBR1+L2ltYWdlbnMvYmFubmVyX21kZmVfT2ZmLnBuZ2RkAgIPZBYCZg9kFgICAQ8PFgYfBQUXTm90YSBGaXNjYWwgRWxldHLDtG5pY2EfBgUdaHR0cDovL3d3dy5uZmUuZmF6ZW5kYS5nb3YuYnIfBwUkfi9pbWFnZW5zL2Jhbm5lcnNfVmlzaXRlX05mZV9PZmYucG5nZGQCAw9kFgJmD2QWAgIBDw8WBh8FBSlTaXN0ZW1hIFDDumJsaWNvIGRlIEVzY3JpdHVyYcOnw6NvIEZpc2NhbB8GBSNodHRwOi8vd3d3MS5yZWNlaXRhLmZhemVuZGEuZ292LmJyLx8HBSV+L2ltYWdlbnMvYmFubmVyc19WaXNpdGVfU3BlZF9PZmYucG5nZGQCBA9kFgJmD2QWAgIBDw8WBh8FBSpTdXBlcmludGVuZMOqbmNpYSBkYSBab25hIEZyYW5jYSBkZSBNYW5hdXMfBgUaaHR0cDovL3d3dy5zdWZyYW1hLmdvdi5ici8fBwUgfi9pbWFnZW5zL2Jhbm5lcnNfbWFuYXVzX09mZi5wbmdkZAIFDw8WAh8EaGRkAi0PZBYEAgEPDxYCHwAFCUNvbnN1bHRhc2RkAgMPZBYEAgEPZBYEAgEPZBYCAgEPZBYEAgIPZBYCAgsPEGQQFQkEMjAxNAQyMDEzBDIwMTIEMjAxMQQyMDEwBDIwMDkEMjAwOAQyMDA3BDIwMDYVCQIxNAIxMwIxMgIxMQIxMAIwOQIwOAIwNwIwNhQrAwlnZ2dnZ2dnZ2dkZAIDD2QWAgILDxBkZBYAZAIDD2QWCAIFDw8WAh4PVmFsaWRhdGlvbkdyb3VwBQxpbnV0aWxpemFjYW9kZAIHDw8WAh8IBQxpbnV0aWxpemFjYW9kZAIJDw8WAh8IBQxpbnV0aWxpemFjYW9kZAINDw8WAh8IBQxpbnV0aWxpemFjYW9kZAIDD2QWAgIBDw8WAh8HBS4vc2NyaXB0cy9zcmYvSW50ZXJjZXB0YS9DYXB0Y2hhLmFzcHg/b3B0PWltYWdlZGQCMQ8PFgIfAAU8UG9ydGFsIGRvIENULWUgMjAxNCAtIENvbmhlY2ltZW50byBkZSBUcmFuc3BvcnRlIEVsZXRyw7RuaWNvZGQYAwUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgUFD2N0bDAwJGlidEJ1c2NhcgUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwMiRJbWFnZUJ1dHRvbjEFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDMkSW1hZ2VCdXR0b24xBSljdGwwMCRnZHZMaW5rc0Rlc3RhcXVlJGN0bDA0JEltYWdlQnV0dG9uMQUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwNSRJbWFnZUJ1dHRvbjEFJmN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkbXZ3Q29uc3VsdGFzDw9kAgJkBRZjdGwwMCRnZHZMaW5rc0Rlc3RhcXVlDzwrAAwBCAIBZHwucXip9zvVNjVdml6PmIKusZJ1">
                    <input type="hidden" name="ctl00$ContentPlaceHolder1$btnConsultar" value="Continuar">
                    <input type="hidden" name="ctl00$ContentPlaceHolder1$txtCaptcha" value="">
                    <input type="hidden" name="ctl00$txtPalavraChave">
                    <input type="hidden" name="hiddenInputToUpdateATBuffer_CommonToolkitScripts" value="1">
               </form>    
            </td>
        </tr>
    </table>
</body>
</html>

