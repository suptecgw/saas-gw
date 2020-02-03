<%-- 
    Document   : listar_notaFiscal
    Created on : 24/10/2013, 17:48:47
    Author     : athos
--%>

<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>

        <script language="javascript">
        shortcut.add("enter",function() {consultar()});
        
        function setDefault(){
            $("valorConsulta").focus();
            $("limiteResultados").value = '<c:out value="${param.limiteResultados}"/>';                
            $("operadorConsulta").value = '<c:out value="${param.operadorConsulta}"/>';               
            $("campoConsulta").value = '<c:out value="${param.campoConsulta}"/>';
            $("valorConsulta").value = '<c:out value="${param.valorConsulta}"/>';
            $("dataDe").value = '<c:out value="${param.dataDe}"/>';
            $("dataAte").value = '<c:out value="${param.dataAte}"/>'; 
            $("idfilial").value = '<c:out value="${param.idFilial}"/>'; 
            $("idremetente").value = '<c:out value="${param.idRemetente}"/>'; 
            $("rem_rzs").value = '<c:out value="${param.rzsRemetente}"/>'; 

        var campoConsulta = '<c:out value="${param.campoConsulta}"/>';

        if(campoConsulta == 'nf.emissao'){
            habilitaConsultaDePeriodo(true);
        }else{
            document.formulario.valorConsulta.focus();
        }
        
        //Cliente pedio para deixar sempre o campo consulta selecionado, 
        //Para almentar a produtividade sempre quando estiver bipando.
        $("valorConsulta").select();    
//        $("rem_rzs").value = "";
            
        }
    
        function abrirCadastro(){
            window.location = "./NotaFiscalControlador?acao=novoCadastro";
        }
        
        function editar(id){
            window.location = "./NotaFiscalControlador?acao=carregar&idNota="+id;
        }
        
        function getCheckedsNotaFiscal(){
            var ids = "";
            for (i = 1; $("ck_" + i) != null; ++i)
                if ($("ck_" + i).checked){
                    ids += ',' + $("ck_" + i).value;
                }
            return ids.substr(1);
        }
        
        function printMatricideNotaFiscal() {
            if (getCheckedsNotaFiscal() == "") {
                alert("Selecione pelo menos uma Nota Fiscal!");
                return null;
            }

            var url =  "./matricidenf.ctrc?idmovs="+getCheckedsNotaFiscal()+"&driverImpressora="+$("driverImpressora").value +"&caminho_impressora="+$("caminhoImpressora").value;

            tryRequestToServer(function(){document.location.href = encodeURI(url);});
        }
        
       function localizaremetente(){
            window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>','Remetente',
                        'top=80,left=150,height=700,width=1400,resizable=yes,status=1,scrollbars=1');
        }
        
        function checkTodos(){
            //seleciona todos os checkbox
            var i = 1 , check = false;
            
            if ($("ckTodos").checked){
                check = true;
            }

            while ($("ck_"+i) != null){
                $("ck_"+i).checked = check;
                i++
            }
        }
        
        function excluir(idNota){       
        if(confirm("Deseja excluir a Nota Fiscal?" )){
            if(confirm("Tem certeza?" )){
                window.open("NotaFiscalControlador?acao=excluir&idNotaFiscal=" + idNota,
                "pop", "width=210, height=100");
            }
        }
    }

        
        function setIcone(valor){
        var img = "";
        switch (valor){
            case "1":
                img = "pdf_";
                break;
            case "2":
                img = "excel_";
                break;
            case "3":
                img = "ie_";
                break;
            case "4":
                img = "word_";
                break;
        }

        for(var i = 0; i <= countRow; i++){
              if(document.getElementById("pdf_"+i) != null){
                    document.getElementById("pdf_"+i).style.display = "none";
                    document.getElementById("excel_"+i).style.display = "none";
                    document.getElementById("ie_"+i).style.display = "none";
                    document.getElementById("word_"+i).style.display = "none";

                    document.getElementById(img+i).style.display = "";
                }
            }
        }


   function habilitaConsultaDePeriodo(opcao){
        document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
        document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
        document.getElementById("div1").style.display = (opcao ? "" : "none");
        document.getElementById("div2").style.display = (opcao ? "" : "none");
    }
    
    
    function selecionaTudo(campo){
        $("valorConsulta").select();
    }
        
    function consultar(){

        $("formulario").submit();
    }

    
        </script>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <title>Consulta de notas fiscais ( Danfe )</title>
    </head>
    <body onload="setDefault()">
         <img src="img/banner.gif">
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <td width="590" align="left"><b>Consulta de Nota Fiscal</b></td>
                <td width="98">
                    <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function(){abrirCadastro();});" value="Novo cadastro">
                </td>
            </tr>
        </table>
        <br>
        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <form action="./NotaFiscalControlador?acao=listar" id="formulario" name="formulario" method="post">
            
            <tr class="celula">
                <td width="92"  height="20">
                    <select name="campoConsulta" id="campoConsulta" class="inputtexto" onchange="habilitaConsultaDePeriodo(this.value == 'nf.emissao')">
                        <option value="nf.numero">Número</option>
                        <option value="nf.emissao">Data de Emissão</option>
                        <option value="nf.chave_acesso">Chave de acesso</option>
                        <option value="nf.numero_romaneio">Número do romaneio</option>
                    </select>
                </td>
                <td width="143">
                    <select name="operadorConsulta" id="operadorConsulta" style="width:100% " class="inputtexto">
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select>
                    <div id="div1" style="display:none">
                         De:
                        <input name="dataDe" type="text" id="dataDe" value="" size="10" maxlength="10" onkeydown="fmtDate(this, event)"  onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                </td>
                <td width="30%" >
                    <input name="valorConsulta" type="text" id="valorConsulta" size="44" maxlength="44" class="inputtexto" onclick="selecionaTudo(this.value);" value="">
                    
                    <div id="div2" style="display:none">
                        At&eacute;:
                       <input name="dataAte" type="text" id="dataAte" size="10" value="" maxlength="10" onkeydown="fmtDate(this, event)" onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                </td>
<!--                <td >
                    
                </td>-->
                
                <td width="76">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados" onClick="javascript:tryRequestToServer(function(){consultar(this);});">
                </td>
                
                <td width="191">
                    <div align="right"> Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="inputtexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td width="8%" >
                    
                </td>
                    
                 <td>Remetente: </td>
                    <td>
                        <input name="rem_rzs" type="text" id="rem_rzs" size="40" value="" class="inputReadOnly8pt">
                        <input id="idremetente" name="idremetente"  type="hidden"   value="0" >
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaremetente();">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = '';">
                    </td>
                    <td>
                        
                    </td>
                    <!--<td>-->
                    <td>
                        Filial: 
                        <select id="idfilial" class="fieldMin" name="idfilial">
                            <option value="0"> Todas as filiais </option>
                            <c:forEach var="filial" items="${listaFilial}">
                                <option value="${filial.idfilial}">${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                    </td>
            </tr>
            
            </form>
        </table>
        <table>
             <tr class="celula">
                <td width="100%"></td>
            </tr>
        </table>
        <table width="90%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="1%"><input type="checkbox" name="ckTodos" onclick="checkTodos()" value="" id="ckTodos" checked="true">  </td>
                <td width="10%">Número </td>
                <td width="5%">Emissão</td>
                <td width="5%">Vl. Mercadoria</td>
                <td width="5%">Peso</td>
                <td width="5%">Volume</td>
                <td width="5%">Conteúdo</td>
                <td width="10%">Embalagem</td>
                <td width="10%">N. CTRC</td>
                <td width="5%">N. Coleta</td>
                <td width="5%">N. Manifesto</td>
                <td width="5%">Setor Entrega</td>
                <td class="tabela" width="5%" align="left"></td>          
            </tr>

            <c:forEach var="notaFiscal" varStatus="status" items="${listarNotaFiscal}">
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra2' : 'CelulaZebra1')}">
                    <td class="">
                        <center>
                            <input type="checkbox" checked="true" name="ck_${status.count}" value="${notaFiscal.idnotafiscal}" id="ck_${status.count}">
                        </center>
                    </td>
                    
                    <td class="">
                    <input type="hidden" id="idNota" name="idNota" value="${notaFiscal.idnotafiscal}">
                        <center>
                            <a onclick="editar(${notaFiscal.idnotafiscal})" class="linkEditar"> 
                                ${notaFiscal.numero}
                            </a>
                         </center>
                    </td>
                    <td class="">
                        <center>
                           <fmt:formatDate type="date" value="${notaFiscal.emissao}" />
                        </center>
                    </td>
                    <td class="">
                        
                        <center>
                              <fmt:formatNumber value="${notaFiscal.valor}" pattern="#,##0.00"/>  
                        </center>  
                    </td>
                    <td class="">
                        <center> 
                            <fmt:formatNumber value="${notaFiscal.peso}" pattern="#,##0.00"/>  
                        </center>
                    </td>
                    <td class="">
                        <center>   
                            <fmt:formatNumber value="${notaFiscal.volume}" pattern="#,##0.00"/>  
                        </center>
                    </td>
                    <td class="">
                        <center>   
                            ${notaFiscal.conteudo}
                        </center>
                    </td>
                    <td class="">
                        <center>   
                            ${notaFiscal.embalagem}
                        </center>
                    </td>
                    <td class="">
                        <center>
                            ${notaFiscal.conhecimento.numero}
                        </center>
                    </td>
                    <td class="">
                        <center>   
                            ${notaFiscal.coleta.numero}
                        </center>
                    </td>
                    <td class="">
                        <center>   
                            ${notaFiscal.conhecimento.manifesto.nmanifesto}
                        </center>
                    </td>
                    <td class="">
                        <center>   
                            ${notaFiscal.conhecimento.manifesto.setorEntrega.descricao}
                        </center>
                    </td>
                    <td>
                        <c:if test="${notaFiscal.coleta.numero == '' && notaFiscal.conhecimento.numero == ''}">
                            <a href="javascript: tryRequestToServer(function(){excluir('${notaFiscal.idnotafiscal}');});"> 
                                <img alt="" class="imagemLink" src="img/lixo.png"/>
                            </a>
                        </c:if>
                    </td>
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra2' : 'CelulaZebra1')}">
                        <td class="" colspan="2">
                            <center>
                                Chave de acesso: 
                            </center>
                        </td>
                        <td  colspan="5">
                                ${notaFiscal.chaveNFe}
                        </td>
                        <td class="" colspan="2">
                            <center>
                                Status Gerenciamento de Risco: 
                            </center>
                        </td>
                        <td  colspan="4">
                                ${notaFiscal.statusMonitoramento}
                        </td>
                    </tr>
                    
                    
                </tr>
            </c:forEach>
        </table>
        <br>
         <table class="bordaFina" width="90%" align="center" >
 
            <tr class="CelulaZebra1">
                <!-- Modelo para futura impressão de relatórios -->
                <!--<td align="center">Formato da Impressão:
                    <input type="radio" name="impressao" id="impressao_1" onClick="setIcone(this.value)" value="1" checked/>
                    <img src="./img/pdf.gif" style="vertical-align: middle" >
                    <input type="radio" name="impressao" id="impressao_2" onClick="setIcone(this.value)" value="2" />
                    <img src="./img/excel.gif"  style="vertical-align: middle">
                    <input type="radio" name="impressao" id="impressao_3" onClick="setIcone(this.value)" value="3" />
                    <img src="./img/ie.gif"  style="vertical-align: middle">
                    <input type="radio" name="impressao" id="impressao_4" onClick="setIcone(this.value)" value="4" />
                    <img src="./img/word.gif"  style="vertical-align: middle">                    
                </td>
                <td align="center">Modelo do relat&oacute;rio:</td>-->
                <td>
                    <select name="caminhoImpressora" id="caminhoImpressora"  class="inputtexto">
                        <c:forEach var="impr" items="${impressoras}">
                             <option value="${impr.descricao}" ${param.impressora==impr.descricao?"selected":""} >${impr.descricao}</option>
                        </c:forEach>
                    </select>
                </td>
                <td colspan="2" align="center">
                    <select   name="driverImpressora" id="driverImpressora" class="inputtexto">
                        <c:forEach var="driver" varStatus="status" items="${drivers}">
                                <option value="${driver}" >${driver}</option>
                        </c:forEach>
                    </select>
                </td>
                <td>
                    <img src="img/ctrc.gif" class="imagemLink" title="Imprimir Notas selecionadas" onClick="printMatricideNotaFiscal();">
                </td>
                
                <td align="center">
                    Total de Ocorr&ecirc;ncias: 
                    <c:out value="${param.qtdResultados}"/>
                </td>
                <td align="center">
                    P&aacute;ginas: 
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                
                <form id="formularioAnt" name="formularioAnt" action="./NotaFiscalControlador?acao=listar" method="post">
                    <td align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input type="hidden" name="idremetente" value="<c:out value='${param.idRemetente}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript:tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </td>
                </form>
                <form id="formularioProx" name="formularioProx" action="./NotaFiscalControlador?acao=listar" method="post">
                    <td align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                        <input type="hidden" name="idremetente" value="<c:out value='${param.idRemetente}'/>"/>
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript:tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </td>
                </form>
            </tr>

            
        </table>

        
        
    </body>
</html>
