<%-- 
    Document   : consultar_CaixaSaida
    Created on : 10/09/2014, 08:47:55
    Author     : paulo
--%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
    shortcut.add("enter",function() {pesquisa()});
    jQuery.noConflict();    
    function desativarBotoes(){
       
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';
                
                
        if(atual == '1'){   
            desabilitar(document.formularioAnt.botaoAnt, "#2E76A6");
        }   
        if(parseFloat(atual) >= parseFloat(paginas)){
            desabilitar(document.formularioProx.botaoProx, "#2E76A6");
        }

        
    }
    function pesquisa(){
        $("formulario").submit();
    }    
    
//    function enviarEmailsCaixaSaida(){        
//        var cont = 0;
//        for (cont = 1; getObj("chkCaixaSaida_" + cont) != null; cont++){
//            if(getObj("chkCaixaSaida_"+cont).checked){                
//                var index = cont;                
//            }
//        }
//        if(index != undefined){
//            var idCaixaSaida = $("chkCaixaSaida_"+index).value;
//            new Ajax.Request('./CaixaSaidaControlador?acao=enviarEmailsCaixaSaida&idCaixaSaida='+idCaixaSaida,
//            {
//                method:'GET',
//                onSuccess: function(){ alert("Email Enviado com Sucesso!")},
//                onFailure: function(){ alert("Erro ao Enviar Email!")}
//            });            
//        }else{
//            alert("Selecione um email!");
//            return false;
//        }
//    }

    function enviarEmailsCaixaSaida(){
        var cont = 0;
        for (cont = 1; getObj("chkCaixaSaida_" + cont) != null; cont++){
            if(getObj("chkCaixaSaida_"+cont).checked){                
                var index = cont;                
            }
        }
        if (index != undefined) {
            var idCaixaSaida = $("chkCaixaSaida_"+index).value;
            window.open("./CaixaSaidaControlador?acao=enviarEmailsCaixaSaida&idCaixaSaida="+idCaixaSaida,'pop', 'top=10,left=0,height=300,width=300');
        }else{
            alert("Selecione um email!");
            return false;
        }
    }


    function setDefault(){
        $("limiteResultados").value = '<c:out value="${param.limiteResultados}"/>';                
        $("operadorConsulta").value = '<c:out value="${param.operadorConsulta}"/>';               
        var campoConsulta = '<c:out value="${param.campoConsulta}"/>';
        $("campoConsulta").value = campoConsulta;
        $("emailRemetenteConsulta").value = '<c:out value="${param.emailRemetenteConsulta}"/>';
        $("emailDestinatarioConsulta").value = '<c:out value="${param.emailDestinatarioConsulta}"/>';
        $("assuntoConsulta").value = '<c:out value="${param.assuntoConsulta}"/>';
        $("statusEmail").value = '<c:out value="${param.statusEmail}"/>';
        $("dataInicial").value = '<c:out value="${param.dataInicial}"/>';
        $("dataFinal").value = '<c:out value="${param.dataFinal}"/>';
        
        if($("campoConsulta") != undefined && $("campoConsulta").selectedIndex != -1){
           $("campoConsulta").value = $("campoConsulta");
        }else{
            console.log("else");
           $("campoConsulta").selectedIndex = "0";
        }
        
        if($("operadorConsulta") != undefined && $("operadorConsulta").selectedIndex != -1){
           $("operadorConsulta").value = $("operadorConsulta");
        }else{
           $("operadorConsulta").selectedIndex = "2";
        }

        if($("statusEmail") != undefined && $("statusEmail").selectedIndex != -1){
           $("statusEmail").value = $("statusEmail").value;
        }else{
           $("statusEmail").selectedIndex = "2";
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
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        <title>WebTrans - Consulta da Caixa de Saida</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="desativarBotoes(), setDefault()">
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta Caixa de Saída</span>
                </td>
            </tr>
        </table>
        <br>
        <form action="CaixaSaidaControlador?acao=listar" id="formulario" name="formulario" method="post">
        <table class="bordaFina" width="80%" align="center">
                
                <tr>                    
                    <td width="97" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta"  style="width: 100px;" >
                            <option value="cs.created_at">Emissão</option>                           
                        </select>
                        <input type="hidden" name="modulo" id="modulo" value="" />
                    </td>
                    <td width="183" class="CelulaZebra1" height="20">
                        <div id="divDataInicial">
                            De:
                            <input name="dataInicial" type="text" id="dataInicial" size="10" maxlength="10" onblur="javascript:alertInvalidDate(this);" class="fieldDate" onkeypress="fmtDate(this,event)" onkeyup="fmtDate(this,event)" onkeydown="fmtDate(this,event)" />
                        </div>
                        
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div id="div1" >
                            <div id="divDataFinal">
                                Ate:
                                <input name="dataFinal" type="text" id="dataFinal" size="10" maxlength="10"  onblur="javascript:alertInvalidDate(this);" class="fieldDate" onkeypress="fmtDate(this,event)" onkeyup="fmtDate(this,event)" onkeydown="fmtDate(this,event)" />
                            </div>
                            
                        </div>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div align="right">
                            <label>
                                Status Emails:
                            </label>                            
                        </div>
                    </td>
                    <td width="183" class="CelulaZebra1">                       
                        <select id="statusEmail" name="statusEmail" class="inputtexto">
                            <option value="t">Todos</option>                               
                            <option value="p">Pendente</option>                               
                            <option value="e">Enviado</option>                               
                            <option value="r">Não Enviado</option>                               
                        </select>
                    </td>
                    <td width="15" class="CelulaZebra1NoAlign" align="center">
                        <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="Pesquisar" onclick="javascript:pesquisa()"  />
                    </td>
                    <td width="186" class="CelulaZebra1">
                        <select id="limiteResultados"  name="limiteResultados" class="inputtexto">
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td width="183" class="CelulaZebra1">
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                                <option value="1" selected>Todas as partes com</option>
                                <option value="2">Apenas com in&iacute;cio</option>
                                <option value="3">Apenas com o fim</option>
                                <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div align="right">
                            <label>
                                Assunto:
                            </label>                            
                        </div>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div id="div2">
                            <!--<input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="15" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">-->
                            <input name="assuntoConsulta" type="text" class="inputtexto"  id="assuntoConsulta" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                        </div>
                    </td>
                     <td width="183" class="CelulaZebra1">
                        <div align="right">
                            <label>
                                Email Remetente:
                            </label>                            
                        </div>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div id="div3">
                            <input name="emailRemetenteConsulta" type="text" class="inputtexto"  id="emailRemetenteConsulta" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                        </div>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div align="right">
                            <label>
                            Email Destinatário:
                            </label>                            
                        </div>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <div id="div4">
                            <input name="emailDestinatarioConsulta" type="text" class="inputtexto"  id="emailDestinatarioConsulta" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                        </div>
                    </td>
                </tr>
        </table>
            </form>
        <table width="80%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>                 
                <td class="tabela" width="5%" align="left"></td>
                <td class="tabela" width="10%" align="left">Data/Hora de Criação</td>
                <td class="tabela" width="10%" align="left">Data/Hora de Envio</td>
                <td class="tabela" width="20%" align="left">Email Remetente</td>
                <td class="tabela" width="20%" align="left">Email Destinatário</td>
                <td class="tabela" width="20%" align="left">Assunto</td>                  
                <td class="tabela" width="20%" align="left">Erro</td>                  
                <td class="tabela" width="5%" align="left">Status</td>
            </tr> 
            <c:forEach var="saida" varStatus="status" items="${listaListCaixaSaida}">  
                <input type="hidden" id="dataHoraDaCriacao_${status.count}" name="dataHoraDaCriacao_${status.count}" value="${saida.criadoEm}"/>
                <input type="hidden" id="dataHoraDoEnvio_${status.count}" name="dataHoraDoEnvio_${status.count}" value="${saida.dataEnvio}"/>
                <input type="hidden" id="emailRemetente_${status.count}" name="emailRemetente_${status.count}" value="${saida.emailRemetente.mailRemetente}"/>
                <input type="hidden" id="emailDestinatario_${status.count}" name="emailDestinatario_${status.count}" value="${saida.emailDestinatario}"/>
                <input type="hidden" id="assunto_${status.count}" name="assunto_${status.count}" value="${saida.assunto}"/>
                
                <textarea id="mensagem_${status.count}" name="mensagem_${status.count}" style="display: none">${saida.mensagem}</textarea> 
                
                <input type="hidden" id="erroEnvio_${status.count}" name="erroEnvio_${status.count}" value="${saida.erroEnvio}"/>
                <input type="hidden" id="status_${status.count}" name="status_${status.count}" value="${saida.status}"/>
                <input type="hidden" id="idUsuario_${status.count}" name="idUsuario_${status.count}" value="${saida.usuarioEnvio.id}"/>
                <tr class="${(status.count % 2 == 0 ? 'celulaZebra1' : 'celulaZebra2')}">
                    <td>
                        <div align="center">
                            <input type="radio" id="chkCaixaSaida_${status.count}" name="chkCaixaSaida" value="${saida.id}" />
                        </div>
                    </td>
                    <td>
                        ${saida.criadoEm}
                    </td>
                    <td>
                        ${saida.dataEnvio}
                    </td>
                    <td>
                        ${saida.emailRemetente.mailRemetente}
                    </td>
                    <td>
                        ${saida.emailDestinatario}
                    </td>
                    <td>
                        ${saida.assunto}
                    </td>                    
                    <td>
                        ${saida.erroEnvio}
                    </td>
                    <td>
                        <c:if test="${saida.status == 'e'}">
                            <div align="center">
                                <img width="20px" height="20px" src="./img/v.png" title="Email enviado com sucesso"/>                                                            
                            </div>
                        </c:if>
                        <c:if test="${saida.status == 'r'}">
                            <div align="center">
                                <img width="20px" height="20px" src="./img/cancelar.png" title="Email não enviado"/>
                            </div>
                        </c:if>
                        <c:if test="${saida.status == 'p'}">
                            <div align="center">
                                <img width="20px" height="20px" src="./img/pendente.png" title="Email pendente"/>
                            </div>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="80%" align="center" >
            <tr>
                <td class="CelulaZebra1" colspan="4">
                    <div align="right">
                        <input type="button" id="reenviarEmail" name="reenviarEmail" class="inputbotao" value=" ENVIAR EMAIL " onclick="javascript:enviarEmailsCaixaSaida()" />                        
                    </div>
                </td>
            </tr>
            <tr class="CelulaZebra1">
                <td width="37%" align="center">Total de Ocorr&ecirc;ncias:
                    <c:out value="${param.qtdResultados}"/>
                </td>
                <td width="18%" align="center">P&aacute;ginas:
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                <td width="15%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="CaixaSaidaControlador?acao=listar" method="post">                       
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="dataInicial" value="<c:out value='${param.dataInicial}'/>"/>
                        <input type="hidden" name="dataFinal" value="<c:out value='${param.dataFinal}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript:document.formularioAnt.submit();" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="15%" align="center">
                    <form id="formularioProx" name="formularioProx"  action="CaixaSaidaControlador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="dataInicial" value="<c:out value='${param.dataInicial}'/>"/>
                        <input type="hidden" name="dataFinal" value="<c:out value='${param.dataFinal}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual+ 1}'/>"/>
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript:document.formularioProx.submit();" value="PROXIMA">
                    </form>
                </td>           
            </tr>
        </table>
       
    </body>
</html>
