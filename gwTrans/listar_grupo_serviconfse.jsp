<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
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

        document.formulario.valorConsulta.focus();
        
    }
            
    function setDefault(){
        $("limiteResultados").value = '<c:out value="${param.limiteResultados}"/>';                
        $("operadorConsulta").value = '<c:out value="${param.operadorConsulta}"/>';               
        $("campoConsulta").value = '<c:out value="${param.campoConsulta}"/>';
        $("valorConsulta").value = '<c:out value="${param.valorConsulta}"/>';
        //não está sendo utilizado.
//        $("dataDe").value = '< c:out value="$ {param.dataDe}"/>';
//        $("dataAte").value = '< c:out value="$ {param.dataAte}"/>';
    }
    /*
    function abrirLocalizarVeiculo(){
        abrirLocaliza("VeiculoControlador?acao=localizarFrota&tipoFrota=", "locVeiculoMulta");
    }
    function limparVeiculo(){
        $("veiculo").value = "";
        $("idVeiculo").value = "0";
    }*/

    function habilitaConsultaDePeriodo(opcao){
        if($("campoConsulta").value == "g.id" || $("campoConsulta").value == "g.descricao"){
            document.getElementById("valorConsulta").style.display =  ""; 
            document.getElementById("operadorConsulta").style.display =  ""; 
            document.getElementById("div1").style.display = "";
//            document.getElementById("div2").style.display =  "none";    
        }else{
            document.getElementById("valorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("operadorConsulta").style.display = (opcao ? "none" : "");
            document.getElementById("div1").style.display = (opcao ? "none" : "");
//            document.getElementById("div2").style.display = (opcao ? "" : "none");
        }
    }
            
    function abrirCadastro(){
        window.location = "GrupoServicoNfseControladador?acao=novoCadastro", "lanCadContratoFrete";
    }          

    function excluir(id){
        if(confirm("Deseja Excluir este Contrato de Frete?" )){
            if(confirm("Tem certeza?" )){                
                window.open("GrupoServicoNfseControladador?acao=excluir&idGrupo=" + id,
                "pop", "width=210, height=100");
            }
        }
    }
    
    function pesquisa(){        
        $("formulario").submit();
    }

    function duplicar(value){
        $("idContratoFrete").value = value;
    }

    function validaCfe(){        
        if($("idContratoFrete").value == '0'){
            alert("Selecione um Contrato de Frete para Enviar.")    
            return false;
        }
        
        window.open("about:blank",
        "pop", "width=210, height=100");    

        return true;
    }
    

    function imrprmir(id,linha){
        if($("isImpresso"+linha).value == "true" && !confirm("A Carta de Frete "+id+" Já Foi Impressa, Deseja Imprimir Novamente?")){
            return null;
        }else{
            launchPDF('./consultacartafrete?acao=exportar&modelo='+document.getElementById("modeloRelatorio").value+'&id='+id+'&usuario='+'${usuario.nome}','carta'+id);
            //location.replace("ContratoFreteControlador?acao=editarImpresso&idContratoFrete="+id);
            new Ajax.Request("ContratoFreteControlador?acao=editarImpresso&idContratoFrete="+id);
            $("isImpresso"+linha).value = true;
        }
                           
    }
     
    function consultarProtocolo(idContratoFrete){
         
        window.open("./NddControlador?idContratoFrete=" + idContratoFrete,
        "pop", "width=210, height=100");
         
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
        <title>WebTrans - Consulta de Contratos de Fretes </title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="desativarBotoes();applyFormatter();setDefault();habilitaConsultaDePeriodo(true);">
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta dos Grupos de Serviço.</span>
                </td>
                <td width="18%">
                    <input name="cadastrar" type="button" class="inputbotao"  onclick="abrirCadastro();" value="Novo Cadastro"/>
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="80%" align="center">
            <form action="GrupoServicoNfseControladador?acao=listar" id="formulario" name="formulario" method="post">
                <tr>
                    <td width="2%" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto"  id="campoConsulta" style="width: 65px;">
                            <option value="g.id">ID</option> 
                            <option value="g.descricao">Descrição</option> 
                        </select>
                        <input type="hidden" name="modulo" id="modulo" value="gwTrans" />
                    </td>
                    <td width="5%" class="CelulaZebra1" height="20">
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                        </select>
                    </td>
                    <td class="CelulaZebra1">
                        <div id="div1" >
                            <input name="valorConsulta" type="text" class="inputtexto" id="valorConsulta" size="15" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                        </div>
                    </td>
                    <td width="7%" class="CelulaZebra1">
                        <div align="right">Filial:</div>
                    </td>
                    <td  width="10%" class="CelulaZebra1" >
                        <select name="filial" class="inputtexto" id="filial" title="Filial do Veículo">
                            <option value="0">Todas</option>
                        </select>
                    </td>
                    <td width="3%" class="CelulaZebra1NoAlign" align="center">
                        <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="Pesquisar" onclick="javascript: tryRequestToServer(function(){pesquisa();})" />
                    </td>
                    <td width="8%" class="CelulaZebra1">
                        <select id="limiteResultados" name="limiteResultados" class="inputtexto">
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                        </select>
                    </td>
                </tr>
            </form>
        </table>
        <table width="80%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>                
                <td class="tabela" width="75%" align="left">DESCRI&Ccedil;&Atilde;O</td>
                <td class="tabela" width="5%" align="left"></td>  
            </tr>
            <c:forEach var="gruposServico" varStatus="status" items="${listaListGrupoServico}">             
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" > 
                    <td>
                        <a href="javascript: tryRequestToServer(function(){window.location='GrupoServicoNfseControladador?acao=iniciarEditar&id=${gruposServico.id}';});" class="linkEditar">${gruposServico.descricao}</a>
                    </td>
                    <td align="center">                      
                        <a href="javascript: tryRequestToServer(function(){excluir('${gruposServico.id}');});"> 
                            <img class="imagemLink" src="img/lixo.png"/> 
                        </a>
                    </td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="80%" align="center" >
            <tr class="CelulaZebra1">
                <td width="37%" align="center">
                    Total de Ocorr&ecirc;ncias:
                    <c:out value="${param.qtdResultados}"/>
                </td>
                <td width="18%" align="center">
                    P&aacute;ginas:
                    <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
                <td width="15%" align="center">
                    <form id="formularioAnt" name="formularioAnt" action="GrupoServicoNfseControladador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>"/>
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript: tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
                    </form>
                </td>
                <td width="15%" align="center">
                    <form id="formularioProx" name="formularioProx"  action="GrupoServicoNfseControladador?acao=listar" method="post">
                        <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual+ 1}'/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript: tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
                    </form>
                </td>
            </tr>
        </table>
    </body>
</html>