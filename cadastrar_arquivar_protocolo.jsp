<%-- 
    Document   : arquivar_protocolo
    Created on : 13/06/2016, 09:11:21
    Author     : airton
--%>

<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">
    
    jQuery.noConflict();
    
    function carregar(){
    var action = '<c:out value="${acaoCarregarArqiovamentoProtocolo}"/>';
    var form = document.formulario;

    if(action == 2){  
        if (${param.nivel == 4}) {
            var data = '${param.dataAtual}';
            form.dataDeAuditoria.value = data;
            form.dataAteAuditoria.value = data;
        }


        form.id.value                   = '<c:out value="${carregarArqiovamentoProtocolo.id}"/>'
        form.referencia.value           = '<c:out value="${carregarArqiovamentoProtocolo.referencia}"/>';
        form.arquivadoEm.value          = '<c:out value="${carregarArqiovamentoProtocolo.arquivadoEm}"/>';
        form.ficarArquivadoAte.value    = '<c:out value="${carregarArqiovamentoProtocolo.ficarArquivadoAte}"/>';
        form.localArmazenado.value      = '<c:out value="${carregarArqiovamentoProtocolo.localArmazenado}"/>';
        form.conteudo.value             = '<c:out value="${carregarArqiovamentoProtocolo.conteudo}"/>';

        var prot;

        <c:forEach items="${carregarArqiovamentoProtocolo.protocolos}" var="protocolo">
            prot = new Protocolo();

            prot.idProtocolo     = "${protocolo.id}";
            prot.numeroProtocolo = "${protocolo.numero}";
            prot.abreviatura     = "${protocolo.filialDestino.abreviatura}";
            prot.tipoDestino     = "${protocolo.tipo}";  
            prot.data            = "${protocolo.data}";
            prot.qtdDocumentos   = "${protocolo.qtdDocumentos}";       

            addProtocolo(prot);


        </c:forEach>
    }

    form.referencia.focus();
    totalDocumentos();
    qtdProtocolo();
    
    }
    
    function voltar(){
    window.location = "ArquivarProtocoloControlador?acao=listar";
    }

    function salvar(){
        var form = document.formulario;
        
        if(form.arquivadoEm.value == ""){
            alert("O campo 'Data' não pode ficar em branco!");            
            form.arquivadoEm.focus();
            return false;            
        }
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        form.submit();
        return true;
    }

    function excluirProtocolo(idProtocolo ,excluirIndex){

        var excluindo =  "trProtocolo_" + excluirIndex;       

        if (confirm("Deseja 'remover' o protocolo do arquivamento?")){
            if (confirm("Tem certeza?")){
                if(idProtocolo != 0){
                    jQuery.ajax({
                            url: '<c:url value="./ArquivarProtocoloControlador" />',
                            dataType: "text",
                            method: "post",
                            data: {
                                idProtocolo : idProtocolo,                        
                                acao : "excluirProtocoloSaida"
                            },
                            success: function(data) {
                                var protocolo = JSON.parse(data);
                                console.log(protocolo);                                
                                
                               if(JSON.parse(data).boolean == false){
                                   alert("Atenção: Erro ao excluir!");
                               }else{
                                   Element.remove(excluindo);
                                   alert("Protocolo excluido com sucesso!");                                   
                               }
                                totalDocumentos();
                            }
                        });
                }else{
                   Element.remove(excluindo);
                   alert("Protocolo excluido com sucesso!");
                }
            }
        }     
    }

//  formata a data do json de 11-11-1111 para 11/11/1111
    function formatDateJSON(objeto) {
                    dataBR = "";
                    var data = "";

                    if (objeto != undefined) {
                        data = objeto.$;
                        if (data != undefined) {
                            dia = data.split("-")[2];
                            mes = data.split("-")[1];
                            ano = data.split("-")[0];

                            dataBR = dia + "/" + mes + "/" + ano;
                        }
                    }

                    return dataBR;
                }

    function consultaProtocolo(numeroProtocolo){
      
    if(numeroProtocolo == ""){
        alert("Atenção: Informe o número do protocolo.");
        return false;
    }

        jQuery.ajax({
            url: '<c:url value="./ArquivarProtocoloControlador" />',
            dataType: "text",
            method: "post",
            data: {                       
                numeroProtocolo : numeroProtocolo,                        
                acao : "listarProtocolos"
            },
            success: function(data) {

                var lista = jQuery.parseJSON(data);

                var protocolo;

                protocolo = lista.list[0];
                
                console.log(protocolo);

                //Alerta informando se o protocolo já foi arquivado em outro arquivamento
                if (protocolo == "") {                    
                    alert("Não á protocolo com esse número " + $("filtroProtocolo").value);
                    return false;
                }
                
                if (protocolo.retornoProtocolo.arquivamentoProtocoloId != 0 && protocolo.retornoProtocolo.arquivamentoProtocoloId != "0") {
                    alert("Protocolo já foi adicionado em outro arquivamento");
                    return false;
                }
                
                var idProtocolo     = protocolo.retornoProtocolo.id;
                var numeroProtocolo = protocolo.retornoProtocolo.numero;
                var origem          = protocolo.retornoProtocolo.origem.abreviatura;
                var tipoDestino     = protocolo.retornoProtocolo.tipo;
                var data            = formatDateJSON(protocolo.retornoProtocolo.data);
                var qtdDocumentos   = protocolo.retornoProtocolo.qtdDocumentos;
                var existe          = consultarProtocolo(idProtocolo, numeroProtocolo);

                        if (!existe == true) {

                            protocolo = new Protocolo();
                            protocolo.idProtocolo       = idProtocolo;
                            protocolo.numeroProtocolo   = numeroProtocolo;
                            protocolo.abreviatura       = origem;
                            protocolo.tipoDestino       = tipoDestino;
                            protocolo.data              = data;
                            protocolo.qtdDocumentos     = qtdDocumentos;
                            addProtocolo(protocolo);
                        }
                        totalDocumentos();
//                        qtdProtocolo();
            }
        });
        
        $("filtroProtocolo").value = "";
        
    }
        
    function Protocolo(idProtocolo,numeroProtocolo, abreviatura, tipoDestino, data, qtdDocumentos){
        
        this.idProtocolo    = (idProtocolo != undefined  || idProtocolo != null ? idProtocolo : 0);            
        this.numeroProtocolo = (numeroProtocolo != undefined || numeroProtocolo != null ? numeroProtocolo : 0);
        this.abreviatura    = (abreviatura != undefined  || abreviatura != null ? abreviatura : "");            
        this.tipoDestino    = (tipoDestino != undefined  || tipoDestino != null ? tipoDestino : "");            
        this.data           = (data != undefined  || data != null ? data : "");            
        this.qtdDocumentos  = (qtdDocumentos != undefined  || qtdDocumentos != null ? qtdDocumentos : 0);            

    }
    
    function consultarProtocolo(idProtocolo, numeroProtocolo){
        var maxProtocolo = $("maxProtocolo").value;
        for (var qtdPro = 1; qtdPro <= maxProtocolo; qtdPro++) {
            console.log("idProtocolo : " + idProtocolo);
            if($("idProtocolo_"+qtdPro)!= null && idProtocolo == $("idProtocolo_"+qtdPro).value){
                alert("Atenção: O número " + numeroProtocolo + " já foi adicionado");
                return true;
                break;
            }
        }
        return false;
    }

    //Add em cada linha as informações de function Protocolo no DOM
    var countProtocolo = 0;
    function addProtocolo(protocolo) {
        if (protocolo == undefined || protocolo == null) {
            protocolo = new Protocolo();
        }
        countProtocolo++;

        var table = $("tbodyProtocolo");

        //Linha em zebra
        var classe = ((countProtocolo % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');

        //Estrutura do DOM _tr e _td
        var _trProtocolo = Builder.node("tr", {
            id: "trProtocolo_" + countProtocolo,
            name: "trProtocolo_" + countProtocolo,
            className: classe
        });

        var _imagemExcluir = Builder.node("img", {
            src: "img/lixo.png",
            title: "Excluir Protocolo",
            className: "imagemLink",
            onClick: "excluirProtocolo(" + protocolo.idProtocolo + "," + countProtocolo + ");"
        });

        var _tdNumeroProtocolo = Builder.node("td", {
            id: "numeroProtocolo_" + countProtocolo,
            name: "numeroProtocolo_" + countProtocolo
        });

        var _tdData = Builder.node("td", {
            id: "data_" + countProtocolo,
            name: "data_" + countProtocolo
        });

        var _tdAbreviatura = Builder.node("td", {
            id: "abreviatura_" + countProtocolo,
            name: "abreviatura_" + countProtocolo
        });

        var _tdDestino = Builder.node("td", {
            id: "destino_" + countProtocolo,
            name: "destino_" + countProtocolo
        });

        var _tdQtdDocumento = Builder.node("td", {
            id: "qtdDocumento_" + countProtocolo,
            name: "qtdDocumento_" + countProtocolo,
            align: "center"
        });

        var _tdExcluir = Builder.node("td", {
            id: "excluir_" + countProtocolo,
            name: "excluir_" + countProtocolo,
            align: "center"
        });

        //Recebendo valores e adicionando em _td
        var _lblNumeroProtocolo = Builder.node("label", {
            id: "descricaoNumemroProtocolo_" + countProtocolo,
            name: "descricaoNumemroProtocolo_" + countProtocolo
        });
        _lblNumeroProtocolo.innerHTML = protocolo.numeroProtocolo;

        var _lblAbreviatura = Builder.node("label", {
            id: "descricaoAbreviatura_" + countProtocolo,
            name: "descricaAbreviatura_" + countProtocolo,
        });
        _lblAbreviatura.innerHTML = protocolo.abreviatura;

        var _lblTipoDestino = Builder.node("label", {
            id: "descricaoTipoDestino_" + countProtocolo,
            name: "descricaoTipoDestino_" + countProtocolo,
        });
        _lblTipoDestino.innerHTML = (protocolo.tipoDestino == "e" ? "Externo" : "Interno");

        var _lblData = Builder.node("label", {
            id: "descricaoData_" + countProtocolo,
            name: "descricaoData_" + countProtocolo,
        });
        _lblData.innerHTML = protocolo.data;

        var _lblQtdDocumento = Builder.node("label", {
            id: "descricaoQtdDocumento_" + countProtocolo,
            name: "descricaoQtdDocumento_" + countProtocolo,
        });
        _lblQtdDocumento.innerHTML = protocolo.qtdDocumentos;

        var _inpQtdDocumento = Builder.node("input", {
            id: "inpQtdDocumento_" + countProtocolo,
            name: "inpQtdDocumento_" + countProtocolo,
            type: "hidden",
            value: protocolo.qtdDocumentos,
        });

        var _inpIdProtocolo = Builder.node("input", {
            id: "idProtocolo_" + countProtocolo,
            name: "idProtocolo_" + countProtocolo,
            type: "hidden",
            value: protocolo.idProtocolo
        });       

        var _tdAdd = Builder.node("td", {
            id: "add_" + countProtocolo,
            name: "add_" + countProtocolo
        });

        var _tdAddd = Builder.node("td", {
            id: "add_" + countProtocolo,
            name: "add_" + countProtocolo
        });

        var _tdAdddd = Builder.node("td", {
            id: "add_" + countProtocolo,
            name: "add_" + countProtocolo
        });

        _tdExcluir.appendChild(_imagemExcluir);
        _tdNumeroProtocolo.appendChild(_lblNumeroProtocolo);
        _tdData.appendChild(_lblData);
        _tdAbreviatura.appendChild(_lblAbreviatura);
        _tdDestino.appendChild(_lblTipoDestino);
        _tdQtdDocumento.appendChild(_lblQtdDocumento);
        _tdNumeroProtocolo.appendChild(_inpIdProtocolo);        
        _tdQtdDocumento.appendChild(_inpQtdDocumento);

        //
        _trProtocolo.appendChild(_tdExcluir);
        _trProtocolo.appendChild(_tdNumeroProtocolo);
        _trProtocolo.appendChild(_tdData);
        _trProtocolo.appendChild(_tdAbreviatura);
        _trProtocolo.appendChild(_tdDestino);
        _trProtocolo.appendChild(_tdQtdDocumento);

        table.appendChild(_trProtocolo);

        $("maxProtocolo").value = countProtocolo;

    }

    function totalDocumentos() {

        try {
            var qtdProtocolo = $("maxProtocolo").value;
            var documentoTotal = 0;
            var procoloQtd = 0;

            for (var qtdDocumentos = 0; qtdDocumentos <= qtdProtocolo; qtdDocumentos++) {

                if (jQuery("#trProtocolo_" + qtdDocumentos).is(':visible')) {
                    documentoTotal = documentoTotal + parseInt($("inpQtdDocumento_" + qtdDocumentos).value);
                    procoloQtd = procoloQtd + 1;                    
                }
            }

            $("totalDocumentos").innerHTML = documentoTotal;
            $("quantidadeLinhas").innerHTML = procoloQtd;
        } catch (e) {
            alert(e);
        }
    }
    
    function qtdProtocolo() {
        $("quantidadeLinhas").innerHTML = countProtocolo;
    }
    
    function stAba(menu, conteudo) {
        this.menu = menu;
        this.conteudo = conteudo;
    }
    
    var arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdAuditoria', 'divAuditoria');

    
    function pesquisarAuditoria() { 
        
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "arquivamento_protocolo";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = '<c:out value="${produtoCadProduto.id}"/>';
                console.log(rotina, id);
                consultarLog(rotina, id, dataDe, dataAte);

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
        <title>webtrans - Cadastro de Arquivamento de Protocolo</title>
    </head>
    <body onload="carregar();AlternarAbasGenerico('tdAuditoria', 'divAuditoria');">
        <img src="img/banner.gif">
        
        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Arquivamento de Protocolo</span>
                </td>
                <td>
                    <input type="button" value=" Voltar " class="inputbotao" onclick="tryRequestToServer(function(){voltar()})"/>
                </td>
            </tr>
        </table>
        <br>
        
            <form action="ArquivarProtocoloControlador?acao=${param.acao==2 ? 'editar':'cadastrar'}" id="formulario" name="formulario" method="post" target="pop">
                <table width="50%" align="center" class="bordaFina" >
                     <tr>
                          <td width="100%" align="center" class="tabela" >Dados principais</td>
                     </tr>   
                     <td align="center" >
                          <table  width="100%" border="0" class="bordaFina">
                               <tr>
                                  <td class="TextoCampos" width="15%">Referência:</td>
                                  <td class="CelulaZebra2"  width="70%">
                                       <input type="hidden" name="maxProtocolo" id="maxProtocolo"/>
                                       <input type="hidden" name="id" id="id"/>
                                       <input name="referencia" id="referencia" type="text" class="inputtexto" size="10" maxlength="10"/>
                                  </td>                       
                                  <td class="TextoCampos" width="15%">*Data:</td>
                                  <td class="CelulaZebra2"  width="70%">
                                       <input name="arquivadoEm" type="text" id="arquivadoEm" size="11" maxlength="10"
                                           value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" class="fieldDate">
                                  </td>
                               </tr>
                               <tr>
                                   <td class="TextoCampos" width="20%" >Ficar Arquivado Até:</td>
                                  <td class="CelulaZebra2"  width="70%" colspan="3">
                                      <input name="ficarArquivadoAte" type="text" id="ficarArquivadoAte" size="11" maxlength="10" onkeypress="fmtDate(this,event)"
                                           value="" class="fieldDate">
                                  </td>
                               </tr>
                               <tr>
                                  <td class="TextoCampos" width="20%" >Local Armazenado:</td>
                                  <td class="CelulaZebra2"  width="70%" colspan="3">
                                       <input name="localArmazenado" id="localArmazenado" type="text" class="inputtexto" size="35" maxlength="50" value="" />
                                  </td>
                               </tr>
                               <tr>
                                  <td class="TextoCampos" width="20%" >Conteúdo:</td>
                                  <td class="CelulaZebra2"  width="70%" colspan="3">
                                       <input name="conteudo" id="conteudo" type="text" class="inputtexto" size="60" maxlength="100" value="" />
                                  </td>
                               </tr>
                          </table>
                </TABLE>
                            
                <table width="50%" border="0" class="bordaFina" align="center">
                    <tr>
                        <td width="75%" class="celulaZebra2">
                            
                            <table width="100%">
                                <td width="33%" style="vertical-align:top;">
                                    
                                    <table width="100%" id="tabelaProtocolo" class="bordaFina tabelaZerada" >
                                        <tbody>
                                            <tr class="celulaNoAlign">
                                                <td colspan="3" align="right">
                                                    <label>Digite o Nº do Protocolo e tecle (Enter):</label> 
                                                </td>
                                                <td class="celula" width="1%" colspan="2">
                                                    <input name="filtroProtocolo" type="text" align="left" id="filtroProtocolo" value="" maxlength="6" size="15" class="inputtexto" onkeypress="javascript:if (event.keyCode==13) consultaProtocolo(this.value)" >
                                                </td>
                                                <td class="celula" width="1%">
                                                    <input name="Pesquisar" type="button" class="botoes" id="Pesquisar" value=" Adicionar " onClick="javascript:tryRequestToServer(function () {consultaProtocolo(getObj('filtroProtocolo').value)});">
                                                </td>
                                            </tr>
                                            <tr>
                                            <td class="celula"  width="2%" align="right"> 
                                            </td>
                                            <td class="celula" width="10%">N° Protocolo</td>
                                            <td class="celula" width="10%">Data</td>
                                            <td class="celula" width="10%">Filial</td>
                                            <td class="celula" width="10%">Destino</td>
                                            <td class="celula" width="10%">Qtd Documentos</td>
                                            </tr>
                                            <tbody id="tbodyProtocolo">
                                            </tbody>
                                            <tr class="celulaNoAlign">
                                                <td colspan="2" align="right">
                                                    <LABEL>QTD de CT-e(s):</LABEL>
                                                </td>
                                                <td id="quantidadeLinhas" align="center" width="1%">
                                                </td>
                                                <td colspan="2" width="2%" align="right">
                                                    <LABEL>Total:</LABEL>
                                                </td>
                                                <td align="center" width="1%">
                                                    <label id="totalDocumentos"></label>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    
                                </td>
                            </table>
                            
                        </td>
                    </tr>
                </table>


              <table width="50%" align="center" class="bordaFina" style='display: ${param.acao == '2' && param.nivel == 4 ? "" : "none"}'>
                      <tr>
                        <td>
                            <table width="20%">

                                <td style='display: ${param.acao == '2' && param.nivel == 4 ? "" : "none"}' class="menu" id="tdAuditoria"
                                    onClick="AlternarAbasGenerico('tdAuditoria', 'divAuditoria')">
                                    Auditoria
                                </td>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <table width="100%" id="divAuditoria" align="center">
                                <tr>
                                    <td>
                                        <c:if test="${param.acao == '2'}">
                                             <table width="100%" align="center" class="bordaFina">   
                                                 <tr>
                                                    <td width="100%" class="celulaZebra2" colspan="4">
                                                        <table width="100%" >
                                                            <tr>
                                                                <td>
                                                                    <c:if test="${param.nivel == 4}">
                                                                        <div id="divAuditoria">
                                                                            <table width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                                                              <%@include file="/gwTrans/template_auditoria.jsp" %> 
                                                                            </table>
                                                                        </div> 
                                                                    </c:if>               
                                                                </td>    
                                                            </tr>

                                                            <tr>
                                                                <td width="100%" class="celulaZebra2" >
                                                                    <fieldset >
                                                                        <table class="tabelaZerada">
                                                                            <tr class="CelulaZebra2">
                                                                                <td class="TextoCampos" width="14%"> Incluso:</td>
                                                                                <td width="35%"> 
                                                                                    em: ${carregarArqiovamentoProtocolo.criadoEm} <br>
                                                                                    por: ${carregarArqiovamentoProtocolo.criadoPor.nome}              
                                                                                </td>
                                                                                <td class="TextoCampos" width="15%"> Alterado:</td>
                                                                                <td width="36%"> 
                                                                                    em: ${carregarArqiovamentoProtocolo.atualizadoEm} <br>
                                                                                    por: ${carregarArqiovamentoProtocolo.atualizadoPor.nome}                                
                                                                                </td>

                                                                            </tr>   
                                                                        </table>
                                                                    </fieldset>
                                                                </td>
                                                            </tr>   
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </c:if>
                                    </td>    
                                </tr>
                            </table>
                        </td>
                    </tr>
                
            </table>                  
                                  
                                  
                                  
                  <c:if test="${param.nivel >= param.bloq}"> 
                      <br>
                      <table align="center"  width="50%" class="bordaFina" >          
                        <tr>
                          
                            <td colspan="6" class="CelulaZebra2" >
                                <div align="center">
                                    <input type="button" value="  SALVAR  " class="inputbotao" id="botSalvar" onclick="salvar()"/>
                                </div>
                            </td>
                               
                        </tr>
                       </table>  
                 </c:if>
               
             </form>
        
        
        
    </body>
</html>
