<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<fmt:setLocale value="pt-BR" />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css"/>
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
    shortcut.add("enter",function() {if($("dataDe").value.length < 10 || $("dataAte").value.length < 10){return null}else{pesquisa()}});
    var countRow = 0;
    
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

//    function habilitaConsultaDePeriodo(opcao){
//        document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
//        document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
//        document.getElementById("div1").style.display = (opcao ? "" : "none");
//        document.getElementById("div2").style.display = (opcao ? "" : "none");
//    }

    function setDefault(){
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
        document.formulario.dataDe.value = '<c:out value="${param.dataDe}"/>';
        document.formulario.dataAte.value = '<c:out value="${param.dataAte}"/>';
        document.formulario.numeroMovimento.value = '<c:out value="${param.numeroMovimento}"/>';
        $("idFilial").value = '${param.idFilial}';
        $("idconsignatario").value = '${param.idconsignatario}';
        $("con_rzs").value = '${param.cliente}';
        $("idveiculo").value = '${param.idVeiculo}';
        $("vei_placa").value = '${param.veiculoPlaca}';
        $("serie").value = '${param.serie}';

        
        var campoConsulta = '<c:out value="${param.campoConsulta}"/>';

        if(campoConsulta == 's.emissao_em'){
            habilitaConsultaDePeriodo(true);
            document.formulario.dataDe.focus();
        }else{
            document.formulario.valorConsulta.focus();
        }
        alterarSelect();
    }

    function abrirCadastro(){
        window.location = "${homePath}/VendaControlador?acao=novoCadastroFinan&modulo=gwFinan";
    }

    function excluir(id, nota, vendedor, dataLancamentoComissao){
        if(confirm("Deseja Excluir a Receita: " + nota + "'?" )){
            if(confirm("Tem certeza?" )){
                window.open("${homePath}/VendaControlador?acao=excluirFinan&modulo=gwFinan&id=" + id + "&numero=" + nota + "&vendedor=" + vendedor + "&dataLancamentoComissao=" + dataLancamentoComissao,
                "pop", "width=210, height=100");
            }
        }
    }

    function pesquisa(){
        document.formulario.submit();
        alterarSelect();
    }

    function abrirLocalizarCliente(){
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=5', 'Consignatario_Receita');
//        abrirLocaliza("${homePath}/ClienteControlador?acao=localizarFinan", "locCliFinan");
    }

    function limparCliente(){
        $("idconsignatario").value = "0";
        $("con_rzs").value = "";
    }
    
    function abrirLocalizarVeiculo(){
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=7', 'Veiculo_Receita');
    }
    
    function limparVeiculo(){
        $("vei_placa").value = "";
        $("idveiculo").value = "0";
    }
    
    function alterarSelect(){
           var campoConsulta = $('campoConsulta').value; 
           
           
           if(campoConsulta == 's.emissao_em') {
               $('tdOperador').style.display = "none";
               $('tdDateDe').style.display = "";
               $('tdDataAte').style.display = "";
               $('tdValorConsulta').style.display = "none";
               $('tdNumeroMovimento').style.display = "none"; 
               
               //Limpar os campos dos input text
               $('valorConsulta').value = "";
               $('numeroMovimento').value = "";
               
           }else if(campoConsulta == 's.numero'){
               $('tdOperador').style.display = "";
               $('tdDateDe').style.display = "none";
               $('tdDataAte').style.display = "none";
               $('tdValorConsulta').style.display = "";
               $('tdNumeroMovimento').style.display = "none";
               
               //Limpar os campos dos input text              
               $('numeroMovimento').value = "";
               
           }else{
               $('tdOperador').style.display = "none";
               $('tdDateDe').style.display = "none";
               $('tdDataAte').style.display = "none";
               $('tdValorConsulta').style.display = "none";
               $('tdNumeroMovimento').style.display = "";
               
               //Limpar os campos dos input text
                $('valorConsulta').value = "";
           }
        }
    
</script>

<html>    
    <head>
        <style type="text/css">
            .style3 {color: #333333}
            .style4 {
                font-size: 14px;
                font-weight: bold;
            }
        </style>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>gwFinan - Consulta de Receitas</title>
    </head>
    <body onload="desativarBotoes(), setDefault(), applyFormatter();">
        <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="95%" align="center">
            <tr>
                <td width="82%" align="left">
                    <span class="style4">Consulta de Receitas</span>
                </td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="javascript:tryRequestToServer(function(){abrirCadastro();})" value="Novo Cadastro"/>
                    </c:if>
                </td>
            </tr>
        </table>
        <br>
        <form action="VendaControlador?acao=listar" id="formulario" name="formulario" method="post">
            <table class="bordaFina" width="95%" align="center">
                <tr class="CelulaZebra1">
                    <td width="13%" align="right">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" onchange="alterarSelect();">
                            <option value="s.emissao_em" selected>Emiss&atilde;o</option>
                            <option value="s.numero">N&uacute;mero</option>
                            <option value="id">Número do Movimento</option>
                        </select>
                    </td>
                    <td width="18%"  height="20" style="display:none" id="tdOperador">                        
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" style="width: 190px;">
                            <option value="1" selected>Todas as Partes com</option>
                            <option value="2">Apenas com In&iacute;cio</option>
                            <option value="3">Apenas com o Fim</option>
                            <option value="4">Igual &agrave; Palavra/Frase</option>
                            <option value="13">Igual &agrave; Palavra/Frase (Vários Separados por Vírgula)</option>
                        </select>                        
                    </td>
                    <td id="tdDateDe" style="display: ">
                            De:
                            <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10"  onblur="alertInvalidDate(this)" class="fieldDate" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                    </td>
                    <td id="tdDataAte" style="display: ">
                            At&eacute;:
                            <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                    </td>
                    <td  style="display: none" id="tdValorConsulta">
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25">                        
                    </td>
                    <td id="tdNumeroMovimento" style="display: none" colspan="2">                        
                        <input id="numeroMovimento" name="numeroMovimento" class="inputtexto" type="text" size="9"/>                        
                    </td>
                    <td colspan="3"> 
                         <div>
                             Apenas o Ve&iacute;culo:
                             <input name="vei_placa" id="vei_placa" type="text" class="inputReadOnly" size="10" readonly/>
                             <input type="button" class="inputbotao" name="botaoVeiculo" id="botaoVeiculo"  onClick="javascript:tryRequestToServer(function(){abrirLocalizarVeiculo();})" value="..."/>
                             <input type="hidden" name="idveiculo" id="idveiculo" value="0"/>
                             <input type="hidden" name="idFilialVeiculo" id="idFilialVeiculo" value="0"/>
                             <img alt="" src="${homePath}/img/borracha.gif" id="borracha" onclick="limparVeiculo()" class="imagemLink"/>
                         </div>        
                    </td>    
                    <td width="10%" rowspan="2" align="center" >
                        <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="javascript:tryRequestToServer(function(){pesquisa();});"  />
                    </td>
                    <td width="13%" rowspan="2" align="center" >
                        <select   name="limiteResultados" class="inputtexto"  >
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                </tr>
                <tr class="CelulaZebra1">
                    <td align="right">Apenas a Filial:</td>
                    <td>
                        <select class="inputtexto"  name="idFilial" id="idFilial">
                            <option value="0">TODAS</option>
                            <c:forEach var="filial" items="${filiais}">
                                <option value="${filial.id}">${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                    </td>
                    
                    <td align="right">Apenas a série:</td>
                    <td width="9%">
                        <input type="text" width="9%" size="14" id="serie" class="inputtexto" name="serie" style="" value="">
                    </td>
                    <td width="12%" align="right">Apenas o Cliente:</td>
                    <td width="25%">
                        <input name="con_rzs" type="text" id="con_rzs" size="30" readonly="true" class="inputReadOnly">
                        <input name="localiza_clifor" type="button" class="inputbotao" id="localiza_clifor" value="..." onClick="javascript:tryRequestToServer(function(){abrirLocalizarCliente();});">
                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                        <img src="${homePath}/img/borracha.gif" class="imagemLink" onclick="limparCliente()">
                    </td>
                </tr>
            </table>
        </form>
        <table width="95%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="3%"></td>
                <td width="7%" align="left">Mov.</td>
                <td width="7%" align="left">N&uacute;mero</td>
                <td width="5%" align="left">S&eacute;rie</td>
                <td width="5%" align="left">Emiss&atilde;o</td>
                <td width="8%" align="right">Valor</td>
                <td width="25%" align="left">Cliente</td>
                <td width="25%" align="left">Hist&oacute;rico</td>
                <td width="12%" align="left">Filial</td>
                <td width="3%" align="left"></td>
            </tr>
            <c:forEach var="venda" varStatus="status" items="${listaListVenda}">
                <script>countRow++;</script>                    
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >                
                    <c:choose>
                        <c:when test="${venda.cancelado}">
                            <td>
                            </td>
                            <td>
                                <a href="javascript: alert('Receita cancelada.');" class="linkEditar">
                                    ${venda.id}
                                </a>
                            </td>
                            <td>
                                <a href="javascript: alert('Receita cancelada.');" class="linkEditar">                            
                                    ${venda.numero}
                                </a>
                            </td>
                            <td><font color="red">${venda.serie}</font></td>
                            <td><font color="red">${venda.emissaoEm}</font></td>
                            <td><font color="red">
                                    <fmt:formatNumber value="${venda.valor}" pattern="#,##0.00#"/>
                                </font>
                            </td>
                            <td><font color="red">${venda.consignatario.razaosocial}</font></td>
                            <td><font color="red">${venda.historico}</font></td>
                            <td><font color="red">${venda.filial.abreviatura}</font></td>
                            <td align="center">
                                <c:if test="${param.nivel >= 4}">
                                    <a href="javascript: alert('Receita cancelada.');"> <img class="imagemLink" src="${homePath}/img/lixo.png"/></a>
                                </c:if>
                            </td>                                    
                        </c:when>
                        <c:otherwise>
                            <td></td>
                            <td>
                                <a href="javascript: tryRequestToServer(function(){window.location='${homePath}/VendaControlador?acao=iniciarEditarFinan&id=${venda.id}&idveiculo=${param.idVeiculo}&vei_placa=${param.veiculo}';});" class="linkEditar">
                                    ${venda.id}
                                </a>
                            </td>
                            <td>
                                <a href="javascript: tryRequestToServer(function(){window.location='${homePath}/VendaControlador?acao=iniciarEditarFinan&id=${venda.id}&idveiculo=${param.idVeiculo}&vei_placa=${param.veiculo}';});" class="linkEditar">
                                    ${venda.numero}
                                </a>
                            </td>
                            <td>${venda.serie}</td>
                            <td><fmt:formatDate value="${venda.emissaoEm}" pattern="dd/MM/yyyy"/></td>
                            <td align="right">
                                <fmt:formatNumber value="${venda.valor}" pattern="#,##0.00#"/>
                            </td>
                            <td>${venda.consignatario.razaosocial}</td>
                            <td>${venda.historico}</td>
                            <td>${venda.filial.abreviatura}</td>
                            <td align="center">
                                <c:if test="${param.nivel >= 4}">
                                    <a href="javascript: tryRequestToServer(function(){excluir( '${venda.id}','${venda.numero}','${venda.vendedor.razaosocial}','<fmt:formatDate pattern="dd/MM/yyyy" value="${venda.fatura.emissaoEm}"/>');});"> <img class="imagemLink" src="${homePath}/img/lixo.png"/></a>
                                </c:if>
                            </td>                            
                        </c:otherwise>
                    </c:choose>
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="95%" align="center" >
            <tr class="CelulaZebra1">
                <td width="47%" align="center">
                    Total de Ocorr&ecirc;ncias: <c:out value="${param.qtdResultados}"/>
                </td>
                <td width="23%" align="center">
                    P&aacute;ginas:<c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                <td width="15%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="${homePath}/VendaControlador?acao=listar&moduloLancamento=fn&modulo=gwFinan" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input type="hidden" name="idFilial" value="<c:out value='${param.idFilial}'/>"/>
                        <input type="hidden" name="idFornecedor" value="<c:out value='${param.idFornecedor}'/>"/>
                        <input type="hidden" name="fornecedor" value="<c:out value='${param.fornecedor}'/>"/>
                        <input type="hidden" name="numeroMovimento" value="<c:out value='${param.numeroMovimento}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript:tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="15%" align="center">
                    <form id="formularioProx" name="formularioProx"  action="${homePath}/VendaControlador?acao=listar&moduloLancamento=fn&modulo=gwFinan" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input type="hidden" name="idFilial" value="<c:out value='${param.idFilial}'/>"/>
                        <input type="hidden" name="idFornecedor" value="<c:out value='${param.idFornecedor}'/>"/>
                        <input type="hidden" name="fornecedor" value="<c:out value='${param.fornecedor}'/>"/>
                        <input type="hidden" name="numeroMovimento" value="<c:out value='${param.numeroMovimento}'/>"/>
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript:tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>
            </tr>
        </table>
    </body>
</html>