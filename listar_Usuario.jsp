
<%-- 
    Document   : listar_Usuario
    Created on : 10/05/2012, 14:38:14
    Author     : ricardo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script type="text/javascript" language="JavaScript">
    var countRow = 0;
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
            
    function setDefault(){
        document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';                
        document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';               
        document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
        
        document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
        
        document.formulario.usuarioAtivo.value = '<c:out value="${param.isAtivos}"/>';
        document.formulario.grupoUsuario.value = '<c:out value="${param.grupo}"/>';
    }
            
    function abrirCadastro(){
        window.location = "UsuarioControlador?acao=novoCadastro";       
    }          

    function excluir(id, nome){ 
        if(confirm("Deseja excluir o usuario '" + nome + "'?" )){
            if(confirm("Tem certeza?" )){                
                window.open("UsuarioControlador?acao=excluir&modulo=gWeb&idUsuario=" + id + "&nome=" + nome,
                "pop", "width=210, height=100");
                
            }
        }
        
        
    }
   
    function checaNivel(){
        var nivel = '<c:out value="${param.nivel}"/>'
        if(nivel.trim == '' || nivel <= 0){
            window.location = "sem_Acesso.jsp";
        }
    }

    function imprimir(impressao, id){
        var valor  = parseInt($("modeloRelatorio").value);
        
        switch(valor){
            case 1:
                window.open("${homePath}/UsuarioControlador?acao=imprimirDocumento" +
                    "&id="+id+"&impressao="+impressao,
                "", "titlebar=no, menubar=no, scrollbars=yes,"+
                    " status=yes,  resizable=yes, left=0, top=0");
                break;

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
//            case "3":
//                img = "ie_";
//                break;
            case "3":
                img = "word_";
                break;
        }

        for(var i = 0; i <= countRow; i++){
            if(document.getElementById("pdf_"+i) != null){
                document.getElementById("pdf_"+i).style.display = "none";
                document.getElementById("excel_"+i).style.display = "none";
//                document.getElementById("ie_"+i).style.display = "none";
                document.getElementById("word_"+i).style.display = "none";

                document.getElementById(img+i).style.display = "";
            }

        }
    }
    
    function carregarCadastro(id){

      //  validaSession(function(){
            window.location = "UsuarioControlador?acao=iniciarEditar&idUsuario=" + id;
      //  })
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
        <title>webtrans - Consulta de Usu&aacute;rios</title>
    </head>
    <body onLoad="desativarBotoes(), setDefault()">
    <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta de Usu&aacute;rios</span>
                </td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">                                       
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="abrirCadastro()" value="Novo Cadastro"/>
                    </c:if> 
                </td>
            </tr>
        </table>
        <br>
        <table class="bordaFina" width="80%" align="center">
              <form action="UsuarioControlador?acao=listar" id="formulario" name="formulario" method="post">
            <tr>               
                    <td width="97" class="CelulaZebra1">
                        <select name="campoConsulta" class="inputtexto" id="campoConsulta">
                            <option value="nome">Nome</option>
                            <option value="email">E-mail</option>
                            <option value="f.abreviatura">Filial</option>
                         </select>
                    </td>
                    <td width="183" class="CelulaZebra1" height="20">
                        <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                            <option value="1" selected>Todas as partes com</option>
                            <option value="2">Apenas com in&iacute;cio</option>
                            <option value="3">Apenas com o fim</option>
                            <option value="4">Igual &agrave; palavra/frase</option>
                         </select>
                    </td>
                    <td width="183" class="CelulaZebra1">
                        <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">
                    </td>
                    
                    <td width="15" class="CelulaZebra1">
                        <input name="pesquisar" id="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onClick="document.formulario.submit();" />
                    </td>
                    
                    <td width="186" class="CelulaZebra1">
                        <select   name="limiteResultados" class="inputtexto">
                            <option value="10">10 Resultados</option>
                            <option value="20">20 Resultados</option>
                            <option value="30">30 Resultados</option>
                            <option value="40">40 Resultados</option>
                            <option value="50">50 Resultados</option>
                         </select>
                    </td>
            </tr>
            <tr>
                <td class="CelulaZebra1">
                        Apenas os usuários : 
                </td>
                <td class="CelulaZebra1" >
                    <select class="inputtexto" id="usuarioAtivo" name="usuarioAtivo">
                    <option value="true">Ativos</option> 
                    <option value="false">Inativos</option> 
                    <option value="Ambos">Ambos</option> 
                    </select>    
                </td>
                <td class="CelulaZebra1NoAlign" colspan="2" align="right">
                     Apenas o Grupo de usuários :    
                </td>
                <td class="CelulaZebra1">
                    <select class="inputtexto" id="grupoUsuario" name="grupoUsuario">
                        <option value="0"> selecione </option> 
                        <c:forEach items="${listaGruposUsuario}" var="grupo">
                            <option value="${grupo.id}">${grupo.descricao}</option> 
                        </c:forEach>
                    </select>    
                </td>
            </tr>
                </form>
        </table>
        <table width="80%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
            <tr>  
                <td class="tabela" width="3%" align="left" ></td>
                <td class="tabela" width="42%" align="left" >NOME</td>
                <td class="tabela" width="40%" align="left">E-MAIL</td>                
                <td class="tabela" width="13%" align="left">FILIAL</td> 
                <td class="tabela" width="2%"></td>                              
            </tr>           
            <c:forEach var="usuario" varStatus="status" items="${listaListUsuario}">
                <script>countRow++;</script>
                <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                    <td>
                        <a>
                            <img class="imagemLink" id="pdf_${status.count}" onclick="imprimir(1, '${usuario.id}');" width="19" height="19" border="0" src="img/pdf.jpg" />
                            <img class="imagemLink" id="excel_${status.count}" onclick="imprimir(2, '${usuario.id}');" width="19" height="19" border="0" src="img/excel.gif" style="display: none"/>
                            <!--<img class="imagemLink" id="ie_$ {status.count}" onclick="imprimir(3, '$ {usuario.id}');" width="19" height="19" border="0" src="img/ie.gif" style="display: none"/>-->
                            <img class="imagemLink" id="word_${status.count}" onclick="imprimir(3, '${usuario.id}');" width="19" height="19" border="0" src="img/word.gif" style="display: none"/>
                        </a>
                    </td>
                    <td>
                        <a href="javascript: carregarCadastro(${usuario.id});" class="linkEditar">${usuario.nome}</a>
                    </td>
                    <td>${usuario.email}</td>
                    <td>${usuario.filial.abreviatura}</td>
                    <td>
                        <c:if test="${param.nivel >= 4}">
                            <a href="javascript: excluir(${usuario.id},'${usuario.nome}');"> 
                                <img class="imagemLink" src="img/lixo.png"/> 
                            </a>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <table class="bordaFina" width="80%" align="center" >
            <tr class="CelulaZebra1">
                <td class="CelulaZebra1" width="54%">
                    <div align="center" >
                        Formato da Impress&atilde;o:
                        <input type="radio" name="impressao" id="impressao_1" onClick="setIcone(this.value)" border="0" value="1" checked/>
                        <img src="img/pdf.gif" style="vertical-align: middle" >
                        <input type="radio" name="impressao" id="impressao_2" onClick="setIcone(this.value)" border="0" value="2" />
                        <img src="img/excel.gif"  style="vertical-align: middle">
                        <!--<input type="radio" name="impressao" id="impressao_3" onClick="setIcone(this.value)" border="0" value="3" />-->
                        <!--<img src="img/ie.gif"  style="vertical-align: middle">-->
                        <input type="radio" name="impressao" id="impressao_3" onClick="setIcone(this.value)" border="0" value="3" />
                        <img src="img/word.gif"  style="vertical-align: middle">
                    </div>
                </td>
                <td align="center">
                    <div align="right">Modelo do relat&oacute;rio: </div>
                </td>
                <td colspan="2" align="center">
                    <div align="left">
                        <select   name="modeloRelatorio" id="modeloRelatorio" class="inputtexto"  >
                            <option value="1">Modelo 1</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr class="CelulaZebra1">
                <td width="50%" align="center">Total de Ocorr&ecirc;ncias: <c:out value="${param.qtdResultados}"/></td>
                <td width="20%" align="center">P&aacute;ginas: <c:out value="${param.paginaAtual} / ${param.paginas}"/></td>
                
                <form id="formularioAnt" name="formularioAnt" action="UsuarioControlador?acao=listar" method="post">
                     <td width="15%" align="center">
                        <input type="hidden" name="limiteResultados" value="<c:out value="${param.limiteResultados}"/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value="${param.operadorConsulta}"/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value="${param.campoConsulta}"/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value="${param.valorConsulta}"/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value="${param.paginaAtual - 1}"/>">
                        <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onClick="document.formularioAnt.submit();" value="ANTERIOR"/>
                     </td>   
                </form>
                <form id="formularioProx" name="formularioProx"  action="UsuarioControlador?acao=listar" method="post">
                    <td width="15%" align="center">   
                        <input type="hidden" name="limiteResultados" value="<c:out value="${param.limiteResultados}"/>">
                        <input type="hidden" name="operadorConsulta" value="<c:out value="${param.operador}"/>">
                        <input type="hidden" name="campoConsulta" value="<c:out value="${param.campoConsulta}"/>">
                        <input type="hidden" name="valorConsulta" value="<c:out value="${param.valorConsulta}"/>">
                        <input type="hidden" name="paginaAtual" value="<c:out value="${param.paginaAtual + 1}"/>">
                        <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onClick="document.formularioProx.submit();" value="PROXIMA">
                    </td>
                </form>
            </tr>
        </table>
    </body>
</html>

