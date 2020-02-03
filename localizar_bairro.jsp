<%-- 
    Document   : localizar_bairro
    Created on : 02/07/2015, 16:14:52
    Author     : marcus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    <script language="javascript" type="text/javascript" src="script/builder.js"></script>
    <script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
    <script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
    <script language="javascript" type="text/javascript" src="script/sessao.js"></script>
    
    <script type="text/javascript" language="JavaScript" charset="Iso-8859-1">
        function abrirCadastroBairro(){
            abrirMax("BairroControlador?acao=novoCadastro", "cadbairro");
        }
        
        function desativarBotoes(){
            var atual = '${param.paginaAtual}';
            var paginas = '${param.paginas}';

            if(atual == '1'){   
                $("botaoAnt").disabled = true;
            }   
            if(parseFloat(atual) >= parseFloat(paginas)){
                $("botaoProx").disabled = true;
            }
        }
        
        function retornaPai(idBairro, descricao, cidade, uf, idCidade){
            var pai = window.opener.document;
            var camposBairro = '${param.camposBairro}';
            var idJanela = window.name;
            if(camposBairro == null){
                camposBairro = $("camposBairro").value;
            }
            
            //Bairro cliente origem
            var idBairroOrigem_ = camposBairro.split("!!")[0];
            var bairroOrigem_ = camposBairro.split("!!")[1];
            var cidadeOrigem_ = camposBairro.split("!!")[2];
            var ufOrigem_ = camposBairro.split("!!")[3];
            var idCidadeOrigem_ = camposBairro.split("!!")[4];
            
            //Bairro cliente destino
            var idBairroDestino_ = camposBairro.split("!!")[0];
            var bairroDestino_ = camposBairro.split("!!")[1];
            var cidadeDestino_ = camposBairro.split("!!")[2];
            var ufDestino_ = camposBairro.split("!!")[3];
            var idCidadeDestino_ = camposBairro.split("!!")[4];
            
            try {
                //endereço principal
                if(idJanela == "LocalizarBairro"){
                    if(pai.getElementById("bairro") != null){
                        pai.getElementById("bairro").value = descricao;
                        pai.getElementById("bairro").className = "inputReadOnly";
                        pai.getElementById("bairro").readOnly = true;
                    }
                    if(pai.getElementById("idLocalizaBairro") != null){
                        pai.getElementById("idLocalizaBairro").value = idBairro;
                    }
                    if(pai.getElementById("cidade") != null){
                        pai.getElementById("cidade").value = cidade;
                    }
                    if(pai.getElementById("idcidade") != null){
                        pai.getElementById("idcidade").value = idCidade;
                    }
                    if(pai.getElementById("uf") != null){
                        pai.getElementById("uf").value = uf;
                    }
                }
                
                //endereço de cobrança
                if(idJanela == "LocalizarBairroCobranca"){
                    if(pai.getElementById("bairroCob") != null){
                        pai.getElementById("bairroCob").value = descricao;
                    }
                    if(pai.getElementById("idBairroCob") != null){
                        pai.getElementById("idBairroCob").value = idBairro;
                    }
                    if(pai.getElementById("cidadeCob") != null){
                        pai.getElementById("cidadeCob").value = cidade;
                    }
                    if(pai.getElementById("cidadeCobId") != null){
                        pai.getElementById("cidadeCobId").value = idCidade;
                    }
                    if(pai.getElementById("ufCob") != null){
                        pai.getElementById("ufCob").value = uf;
                    }
                }
                
                //endereco de coleta
                if(idJanela == "LocalizarBairroColeta"){
                    if(pai.getElementById("bairroCol") != null){
                        pai.getElementById("bairroCol").value = descricao;
                    }
                    if(pai.getElementById("idBairroCol") != null){
                        pai.getElementById("idBairroCol").value = idBairro;
                    }
                    if(pai.getElementById("cidadeCol") != null){
                        pai.getElementById("cidadeCol").value = cidade;
                    }
                    if(pai.getElementById("cidadeColId") != null){
                        pai.getElementById("cidadeColId").value = idCidade;
                    }
                    if(pai.getElementById("ufCol") != null){
                        pai.getElementById("ufCol").value = uf;
                    }
                }
                
                
                
                pai.getElementById(idBairroOrigem_).value = idBairro ;
                pai.getElementById(bairroOrigem_).value = descricao ;
                pai.getElementById(cidadeOrigem_).value = cidade ;
                pai.getElementById(ufOrigem_).value = uf ;
                pai.getElementById(idCidadeOrigem_).value = idCidade ;
                
                
                pai.getElementById(idBairroDestino_).value = idBairro ;
                pai.getElementById(bairroDestino_).value = descricao ;
                pai.getElementById(cidadeDestino_).value = cidade ;
                pai.getElementById(ufDestino_).value = uf ;
                pai.getElementById(idCidadeDestino_).value = idCidade ;
               
//               if(window.opener.aoClicarNoLocaliza != null){
//                   window.opener.aoClicarNoLocaliza(idJanela);
//               }
                
            }catch(erro){
                console.debug(erro);
            }
            window.close();
        }
        
        function carregar(){
            document.formulario.camposBairro.value = '<c:out value="${param.camposBairro}"/>';
            document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
            document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
            document.formulario.idCidade.value = '<c:out value="${param.idCidade}"/>';
            document.formulario.camposBairro.focus();
        }
        
        function pesquisarBairro(){
            $("formulario").submit();
        }
        
        function botaoProximo(){
           tryRequestToServer($("formularioPosterior").submit());
        }
        
        function botaoVoltar(){
            tryRequestToServer($("formularioAnterior").submit());
        }
        
    </script>
    
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style5 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>
        
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>WebTrans - Localizar Bairro</title>
    </head>
    <body onload="carregar();desativarBotoes()">
        <img src="img/banner.gif" width="30%" height="44" align="center"/>
        
        <table width="75%" class="bordaFina" align="center">
            <tr>
                <td width="82%">
                    <div align="left" class="style5">Localizar Bairro</div>
                </td>
            </tr>
        </table>
        <br/>
        <table align="center" width="75%" class="bordaFina">
            <form id="formulario" name="formulario" action="BairroControlador?acao=localizarBairro" method="post">
                <input type="hidden" id="camposBairro" name="camposBairro" value="">
                <input type="hidden" id="idCidade" name="idCidade" value="">
                <tr class="CelulaZebra2">
                    <td width="30%" height="20">
                        <select id="campoConsulta" class="inputtexto" name="campoConsulta">
                            <option value="descricao">Bairro</option>
                            <option value="c.cidade">Cidade</option>
                            <option value="c.uf">UF</option>
                        </select>
                    </td>
                    <td width="50%">
                        <select id="operadorConsulta" class="inputtexto" name="operadorConsulta">
                            <option value="1">Todas as partes com</option>
                            <option value="2">Apenas com o início</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual à palavra/frase</option>
                        </select>
                    </td>
                    <td align="center" width="20%" rowspan="2">                        
                         <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function(){document.formulario.submit();});" />
                    </td>
                    <td align="center" width="20%" rowspan="2">                        
                         <input name="novocadastro" type="button" class="inputbotao" value="Novo Cadastro" onclick="tryRequestToServer(function(){abrirCadastroBairro();});" />
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td height="20" colspan="2">                        
                        <input id="valorConsulta" class="inputtexto" type="text" size="41" name="valorConsulta"/>
                    </td>
                </tr>
            </form>
        </table>
        <table align="center" class="bordaFina" width="75%">
            <tr class="tabela">
                <td width="80%">
                    <div align="left">Bairro</div>
                </td>
                <td width="16%">
                    <div align="left">Cidade</div>
                </td>
                <td width="4%">
                    <div align="center">UF</div>
                </td>                
            </tr>
            <c:forEach var="bairro" varStatus="status" items="${listarBairro}">
                <tr class="${(status.count %  2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                    <td>
                        <a href="javascript: retornaPai('${bairro.idBairro}','${bairro.descricao}', '${bairro.cidadeBairro.descricaoCidade}', '${bairro.cidadeBairro.uf}', '${bairro.cidadeBairro.idcidade}');"
                           class="linkEditar">${bairro.descricao}</a>
                    </td>
                    <td>
                        <label>${bairro.cidadeBairro.descricaoCidade}</label>
                    </td>
                    <td>
                        <label>${bairro.cidadeBairro.uf}</label>
                    </td>
                </tr>
            </c:forEach>
        </table>
        <br/>
        <table align="center" width="75%" class="bordaFina">
            <tr class="CelulaZebra2">
                <td width="50%">
                    Total de Ocorrências:
                    <c:out value="${param.qtdResultados}"/>
                </td>
            <form id="formularioAnterior" action="BairroControlador?acao=localizarBairro" method="post" name="formularioAnterior">
                <td width="25%" rowspan="2" align="center">
                    <!--<input name="limiteResultados" type="hidden" value="<c:out value='${param.limiteResultados}'/>"/>-->
                    <input name="operadorConsulta" type="hidden" value="<c:out value='${param.operadorConsultarBairro}'/>"
                    <input name="campoConsulta" type="hidden" value="<c:out value='${param.campoConsulta}'/>"/>
                    <input name="valorConsulta" type="hidden" value="<c:out value='${param.valorConsulta}'/>"
                    <input name="camposBairro" type="hidden" value="<c:out value='${param.camposBairro}'/>"
                    <input name="idCidade" type="hidden" value="<c:out value='${param.idCidade}'/>"
                    <input name="qtdResultados" type="hidden" value="<c:out value='${param.qtdResultadosBairro}'/>"/>
                    <input name="paginaAtual" type="hidden" value="<c:out value='${param.paginaAtual - 1}'/>"/>
                    <input id="botaoAnt" type="button" class="inputbotao" onclick="botaoVoltar();" value="ANTERIOR" name="botaoAnt"/>
                </td>
            </form>
            <form id="formularioPosterior" action="BairroControlador?acao=localizarBairro" method="post" name="formularioPosterior">
                <td width="25%" rowspan="3" align="center">
                    <!--<input name="limiteResultados" type="hidden" value="<c:out value='${param.limiteResultadoBairro}'/>"/>-->
                    <input name="operadorConsulta" type="hidden" value="<c:out value='${param.operadorConsultarBairro}'/>"
                    <input name="campoConsulta" type="hidden" value="<c:out value='${param.campoConsulta}'/>"/>
                    <input name="valorConsulta" type="hidden" value="<c:out value='${param.valorConsulta}'/>"/>
                    <input name="camposBairro" type="hidden" value="<c:out value='${param.camposBairro}'/>"
                    <input name="idCidade" type="hidden" value="<c:out value='${param.idCidade}'/>"
                    <input name="qtdResultados" type="hidden" value="<c:out value='${param.qtdResultadosBairro}'/>"/>
                    <input name="paginaAtual" type="hidden" value="<c:out value='${param.paginaAtual + 1}'/>"/>
                    <input id="botaoProx" type="button" class="inputbotao" onclick="botaoProximo();" value="PRÓXIMO" name="botaoProx"/>
                </td>
            </form>
            </tr>
            <tr class="CelulaZebra2">
                <td>
                    Páginas: <c:out value="${param.paginaAtual} / ${param.paginas}"/>
                </td>
            </tr>
        </table>
    </body>
</html>
