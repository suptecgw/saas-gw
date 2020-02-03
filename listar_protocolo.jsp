<%-- 
    Document   : listar_protocolo
    Created on : 23/08/2012, 16:06:50
    Author     : renan
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script type="text/javascript" language="JavaScript">
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
         
    function setDefault(){
        try{
            document.formulario.limiteResultados.value = '<c:out value="${param.limiteResultados}"/>';         
            document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';               
            document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
            document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
            document.formulario.dataIni.value = '<c:out value="${param.dataDe}"/>';
            document.formulario.dataFim.value = '<c:out value="${param.dataAte}"/>';
            document.formulario.filial.value = '<c:out value="${param.filial}"/>';
            habilitaConsultaDePeriodo('<c:out value="${param.campoConsulta}"/>' );
         }catch(e){
             alert(e);
         }
        
    }
    
    function abrirCadastro(){
        window.location = "ProtocoloControlador?acao=novoCadastro";
    }          

    function excluir(id,protocolo){
        if(confirm("Deseja excluir o Protocolo' " + protocolo + "'?" )){
            if(confirm("Tem certeza?" )){                
                window.open("ProtocoloControlador?acao=excluir&id=" + id,
                "pop", "width=210, height=100");
            }
        }
    }
    
    function habilitaConsultaDePeriodo(opcao) {
        
    try{    
       if(opcao.toString() == 'p.data'){
            $("tdConsulta").style.display= "none";
            $("tdOperador").style.display= "none";
            $("div1").style.display = "";
            $("div2").style.display = "";            
            $("divSlcFilial").style.display = "none";
        }else if (opcao.toString() == 's.numero'){
            $("tdConsulta").style.display= "";
            $("tdOperador").style.display= "";
            $("div1").style.display = "none";
            $("div2").style.display = "none";            
            $("divSlcFilial").style.display = "";            
        }else{
            $("tdConsulta").style.display= "";
            $("tdOperador").style.display= "";
            $("div1").style.display = "none";
            $("div2").style.display = "none";            
            $("divSlcFilial").style.display = "none";
        }
    }catch(e){
        alert(e);
    }
}

        function getCheckedCtrcs(){
            var ids = "";
            for (var i = 1; getObj("ck_" + i) != null; i++)
                if (getObj("ck_" + i).checked){
                 if (ids == "") {
                    ids += getObj("ck_" + i).value;
                 }else{
                    ids += ',' + getObj("ck_" + i).value;
                 }
                }
            return ids;
        }
    
        function marcaTodos(){
       
         var i = 1;
            while ($("ck_" + i) != null){                
               // alert("entrou while: "+i)
               // alert($("ck_" + i).value);
                $("ck_"+i).checked = $("ck_0").checked;
                i++;
           }
        }
    
        function imprimir(id,tipoImpressao,idselecionado){

            if(id==undefined){
                id = getCheckedCtrcs(); 
            }
            
            if(id == '' || id == null || id == undefined){
                return false;
            }
            
            var filial = "";
            var count = 1;
            while($("ck_" + count) != null){
                if($("ck_"+count).checked){
                    filial += document.getElementById("filial_origem_"+count).value + "!!";
                }
                count++;
            }
            
        
            try{
                window.open("ProtocoloControlador?acao=exportar&protocolo_id="+id+"&modelo="+$('cbmodelo').value+"&impressao="+tipoImpressao+"&destino="+filial,'pop','top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
            }catch(e){
                alert(e);
            }
       
         }
         
         var countRow = 0;
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
                img = "word_";
                break;
        }
        document.getElementById("pdf_").style.display = "none";
        document.getElementById("excel_").style.display = "none";
        document.getElementById("word_").style.display = "none";

        document.getElementById(img).style.display = "";
        
        for(var i = 0; i <= countRow; i++){
            if(document.getElementById("pdf_"+i) != null){
                document.getElementById("pdf_"+i).style.display = "none";
                document.getElementById("excel_"+i).style.display = "none";
                document.getElementById("word_"+i).style.display = "none";

                document.getElementById(img+i).style.display = "";
            }

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
        <title>webtrans - Consulta do Protocolo</title>
    </head>
    
    <body onload="setDefault();desativarBotoes(); "  > 
        <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="70%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Consulta do Protocolo</span>
                </td>
                <td width="18%">
                    <c:if test="${param.nivel >= 3}">
                        <input name="cadastrar" type="button" class="inputbotao"  onclick="tryRequestToServer(function(){abrirCadastro()})" value="Novo Cadastro"/>
                    </c:if> 
                </td>
            </tr>
        </table>
        <br>
        <form action="ProtocoloControlador?acao=listar" id="formulario" name="formulario" method="post">
        <table class="bordaFina" width="70%" align="center">
            <tr>
            
                <td width="10%" class="CelulaZebra1">
                    <select name="campoConsulta" class="inputtexto"  id="campoConsulta"
                        onChange="javascript:habilitaConsultaDePeriodo(this.value );">
                        <option value='p.data'>Data</option>
                        <option value='nf'>Nº Nota Fiscal</option>
                        <option value='f.abreviatura'>Filial de Origem</option>
                        <option value='c.razaosocial'>Cliente de Destino</option>
                        <option value='p.numero_protocolo'>Número do protocolo</option>
                        <option value='s.numero'>Número do CT-e</option>

                    </select>                    
                </td>
                <td width="20%" class="CelulaZebra1" height="20" id="tdOperador">
                    <select name="operadorConsulta" class="inputtexto" id="operadorConsulta" >
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select>                    
                </td>
                <td class="CelulaZebra1" id="tdConsulta">
                    <input name="valorConsulta" type="text" class="inputtexto"  id="valorConsulta" size="25" >
                </td>
                <td class="CelulaZebra1" id="div1" style="display: none" width="20%">
                    <label>&nbsp;&nbsp;DE: &nbsp;&nbsp;<input name="dataIni" id="dataIni" class="fieldDate" size="10" maxlength="10"   onBlur="alertInvalidDate(this)"  size="10" maxlength="10" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                        </label>                   
                </td>
                <td class="CelulaZebra1" id="div2"  style="display: none" width="20%" >
                   <label>ATE: <input name="dataFim" id="dataFim" class="fieldDate" size="10" maxlength="10"   onBlur="alertInvalidDate(this)"  size="10" maxlength="10" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                   </label>
                </td>                
                <td width="20%" class="CelulaZebra1">                    
                    <div id="divSlcFilial" style="display: none">
                        <select id="filial" name="filial" class="inputtexto" style="width: 50%">
                            <option value="0">Todas as Filiais</option>
                            <c:forEach var="filial" varStatus="status" items="${listaFiliais}">
                                <option value="${filial.idfilial}">${filial.abreviatura}</option>
                            </c:forEach>
                        </select>                        
                    </div>
                </td>
                <td width="20%" class="CelulaZebra1">
                    <input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onClick="javascript:tryRequestToServer(function(){document.formulario.submit();});"  />
                </td>
                <td width="20%" class="CelulaZebra1">
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
    <table width="70%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">
        <tr>
            <td class="tabela" width="2%" align="left"><input name="ck_0" type="checkbox" value="1" id="ck_0" onclick="marcaTodos();" ></td>
            <td class="tabela" width="2%" align="left">
                <img src="img/pdf.gif" id="pdf_" onclick="javascript:tryRequestToServer(function(){imprimir(undefined,'1')});" class="imagemLink">
                <img src="img/excel.gif" id="excel_" onclick="javascript:tryRequestToServer(function(){imprimir(undefined,'2')});" class="imagemLink" style="display: none">
                <img src="img/word.gif" id="word_" onclick="javascript:tryRequestToServer(function(){imprimir(undefined,'3')});" class="imagemLink" style="display: none">
            </td>
            <td class="tabela" width="10%" align="left">NUMERO</td>
            <td class="tabela" width="43%" align="left">FILIAL DE ORIGEM</td>
            <td class="tabela" width="43%" align="left">CLIENTE DE DESTINO</td>
            <td class="tabela" width="2%" align="left"></td>
        </tr>
        <c:forEach var="protocolo" varStatus="status" items="${listaProtocolo}">
            <script>countRow++</script>
            <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" >
                <td><input name="ck_${status.count}" type="checkbox" value="${protocolo.id}" id="ck_${status.count}"></td>
                <td> 
                    
                    <img src="img/pdf.gif" id="pdf_${status.count}" onclick="javascript:tryRequestToServer(function(){imprimir('${protocolo.id}','1',${status.count});});" class="imagemLink">
                    <img src="img/excel.gif" id="excel_${status.count}" onclick="javascript:tryRequestToServer(function(){imprimir('${protocolo.id}','2');});" class="imagemLink" style="display: none">
                    <img src="img/word.gif" id="word_${status.count}" onclick="javascript:tryRequestToServer(function(){imprimir('${protocolo.id}','3');});" class="imagemLink" style="display: none">
                </td>
                <td><a href="javascript:tryRequestToServer(function(){window.location='ProtocoloControlador?acao=iniciarEditar&id=${protocolo.id}'});" class="linkEditar">${protocolo.numero}</a></td>
                <td>
                    <a href="javascript:tryRequestToServer(function(){window.location='ProtocoloControlador?acao=iniciarEditar&id=${protocolo.id}';});" class="linkEditar">${protocolo.origem.abreviatura}</a>
                </td>
                <td>
                    <a href="javascript:tryRequestToServer(function(){window.location='ProtocoloControlador?acao=iniciarEditar&id=${protocolo.id}';});" class="linkEditar">${protocolo.destino.razaosocial}</a>
                    <input type="hidden" name="filial_origem_${status.count}" id="filial_origem_${status.count}" value="${protocolo.filialDestino.abreviatura}">
                </td>
                <td align="center">
                    <c:if test="${param.nivel >= 4}">
                        <a href="javascript:tryRequestToServer(function(){excluir( '${protocolo.id}','${protocolo.numero}');});">
                            <img class="imagemLink" src="img/lixo.png"/> 
                        </a>
                    </c:if>                    
                </td>
            </tr>
        </c:forEach>
    </table>
    <br>
    <table class="bordaFina" width="70%" align="center" >
        <tr class="CelulaZebra1">
            <td class="CelulaZebra1NoAlign" align="left" colspan="5">
                    <div align="left" >
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
        </tr>
        
        <tr class="CelulaZebra1">
            <td width="30%" align="center">Total de Ocorr&ecirc;ncias:
                <c:out value="${param.qtdResultados}"/>
            </td>
            <td width="20%" align="center">P&aacute;ginas:
                <c:out value="${param.paginaAtual} / ${param.paginas}"/>
            </td>

                <td width="13%" align="center">
            <form id="formularioAnt" name="formularioAnt" action="ProtocoloControlador?acao=listar" method="post">
                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                    <input type="hidden" name="dataIni" value="<c:out value='${param.dataDe}'/>">
                    <input type="hidden" name="dataFim" value="<c:out value='${param.dataAte}'/>">
                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual - 1}'/>">
                    <input name="botaoAnt" type="button" class="inputbotao" id="botaoAnt" onclick="javascript:tryRequestToServer(function(){document.formularioAnt.submit();});" value="ANTERIOR"/>
            </form>
                </td>
                <td width="13%" align="center">
            <form id="formularioProx" name="formularioProx"  action="ProtocoloControlador?acao=listar" method="post" >
                    <input type="hidden" name="limiteResultados" value="<c:out value='${param.limiteResultados}'/>">
                    <input type="hidden" name="dataIni" value="<c:out value='${param.dataDe}'/>">
                    <input type="hidden" name="dataFim" value="<c:out value='${param.dataAte}'/>">
                    <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>">
                    <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>">
                    <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>">
                    <input type="hidden" name="paginaAtual" value="<c:out value='${param.paginaAtual + 1}'/>">
                    <input name="botaoProx" type="button" class="inputbotao" id="botaoProx" onclick="javascript:tryRequestToServer(function(){document.formularioProx.submit();});" value="PROXIMA">
            </form>
                </td>
            <td width="24%" align="center">Modelo:
                <SELECT name="cbmodelo" id="cbmodelo" class="inputtexto">
                    <OPTION value="1" selected>Modelo 1</OPTION>
                    <OPTION value="2">Modelo 2</OPTION>
                    <OPTION value="3">Modelo 3</OPTION>
                    <OPTION value="4">Modelo 4</OPTION>
                </SELECT>
            </td>
       </tr>
    </table>
    
</body>
</html>



