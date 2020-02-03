<%-- 
    Document   : cadastrar_protocolo
    Created on : 24/08/2012, 08:06:14
    Author     : renan
--%>

<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script type="text/javascript" language="JavaScript">    
    jQuery.noConflict();
    
    var idFilial = 0;
    var filial = "";
    var idFilialExterno = 0;
    var filialExterno = "";
    var listaFiliais = new Array();
    var countFilial = 0;
    function carregar(){
        var action = '<c:out value="${param.acao}"/>';
        var form = document.formulario;
        
        <c:forEach var="filial" varStatus="status" items="${listaFiliais}">
            listaFiliais[++countFilial] = new Option('${filial.idfilial}','${filial.abreviatura}');
        </c:forEach>
        
        povoarSelect($("slcFilialDestino"),listaFiliais);
        povoarSelect($("filialCte"),listaFiliais);
        
        idFilial = '<c:out value="${param.idFilial}"/>';
        filial = '<c:out value="${param.filial}"/>';
        
        $("filialCte").value = '<c:out value="${param.idFilial}"/>';
        
        if(action == 2){  
            //Dados pricipais
            form.id.value = '<c:out value="${protocolo.id}"/>';
            form.idfilial.value = '<c:out value="${protocolo.origem.idfilial}"/>';
            form.fi_abreviatura.value = '<c:out value="${protocolo.origem.abreviatura}"/>';
            form.data.value = '<c:out value="${protocolo.data}"/>';           
            form.slcTipo.value = '<c:out value="${protocolo.tipo}"/>';
            
            idFilialExterno = '<c:out value="${protocolo.origem.idfilial}"/>';
            filialExterno = '<c:out value="${protocolo.origem.abreviatura}"/>';
    
            if (form.slcTipo.value == 'e') {
                form.iddestinatario.value = '<c:out value="${protocolo.destino.idcliente}"/>';
                form.dest_rzs.value = '<c:out value="${protocolo.destino.razaosocial}"/>';
                $("filialCte").disabled = true;
            }else if(form.slcTipo.value == 'i'){
                form.slcFilialDestino.value = '<c:out value="${protocolo.filialDestino.idfilial}"/>';
                $("divFilialDestino").style.display = "";
                $("divCliente").style.display = "none";
            }
            
            <c:forEach var="ctrc" items="${protocolo.ctrcs}">
               addProtocoloCtrc(new ProtocoloCtrc('${ctrc.id}', '${ctrc.conhecimento.id}', '${ctrc.conhecimento.numeroCarga}', '${ctrc.conhecimento.numero}', '${ctrc.conhecimento.chegadaEm}', '${ctrc.conhecimento.cliente.razaosocial}', 'null', '${ctrc.conhecimento.filial.idfilial}'));
            </c:forEach>
                
         }else{
            form.data.value = '<%=Apoio.getDataAtual()%>';          
            
         }

        //form.descricao.focus();
    }
    
    function voltar(){
        window.location = "ProtocoloControlador?acao=listar";
    }
    
    function salvar(){
        var form = document.formulario;
        
        if(form.idfilial.value == ""){
            alert("O campo 'origem' não pode ficar em branco!");            
            form.origem.focus();
            return false;            
        }   
        if(form.slcTipo.value == "e" && (form.iddestinatario.value == "" || form.iddestinatario.value == "0")){
            alert("O campo 'Destino' não pode ficar em branco!");
            form.destino.focus();
            return false;
        }
        if(form.data.value == ""){
            alert("O campo 'Data' não pode ficar em branco!");
            form.destino.focus();
            return false;
        }
        qtdSelecionado = 0;
        if(countProtocoloCtrc == 0){
            alert("Informe no mínimo um CT-e!");
            return false;
        }
        else{
            //Testando se existe pelomenos uma tr
            for(i=0; i<= countProtocoloCtrc;i++){
                if($("tr_"+i)!= null ||$("tr_"+i)!= undefined){
                  qtdSelecionado++;  
                }
            }
            if(qtdSelecionado == 0){
                alert("Informe no mínimo um CT-e!");
                return false;
            }
            
        }
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("slcTipo").disabled = false;
        form.submit();
        return true;
    }
    
    function abrirLocalizarFilial(){
         launchPopupLocate('./localiza?acao=consultar&idlista=08','Filial');
    }
    function abrirLocalizarCliente(){
         launchPopupLocate('./localiza?acao=consultar&idlista=04','Cliente');
    }
        
        

    function ProtocoloCtrc(protocoloCtrcId,idCtrc,carga,numero,chegadaEm,destinatario,notaFiscal,idFilialCtrc){        
        this.protocoloCtrcId = (protocoloCtrcId != undefined && protocoloCtrcId != null ? protocoloCtrcId : 0);
        this.idCtrc = (idCtrc != undefined && idCtrc != null ? idCtrc : 0);
        this.carga = (carga != undefined && carga != null ? carga : 0);
        this.numero = (numero != undefined && numero != null ? numero : 0);
        this.chegadaEm = (chegadaEm != undefined && chegadaEm != null ? chegadaEm :"");
        this.notaFiscal = (notaFiscal != undefined && notaFiscal != null ? notaFiscal :"");
        this.destinatario = (destinatario != undefined && destinatario != null ? destinatario :"");
        this.idFilialCtrc = (idFilialCtrc != undefined && idFilialCtrc != null ? idFilialCtrc : 0);
    }
    
    var countProtocoloCtrc = 0;
    function addProtocoloCtrc(protocoloCtrc){

     try{   
      if(protocoloCtrc == null || protocoloCtrc == undefined){
          protocoloCtrc = new ProtocoloCtrc();
      }
      
      countProtocoloCtrc++;
      var tabelaBase = $("tbProtocoloCtrc");
      
      var hiddenCtrc = Builder.node("input",{
          id:"idCtrc_"+countProtocoloCtrc,
          name:"idCtrc_"+countProtocoloCtrc,
          value:protocoloCtrc.idCtrc,
          type:"hidden"
      });
      var hiddenProtocoloCtrc = Builder.node("input",{
          id:"protocoloCtrcId_"+countProtocoloCtrc,
          name:"protocoloCtrcId_"+countProtocoloCtrc,
          value:protocoloCtrc.protocoloCtrcId,
          type:"hidden"
      }); 
      var im0 = Builder.node("img",{
          id:"excluir_"+countProtocoloCtrc,
          name:"excluir_"+countProtocoloCtrc,
          onclick:"excluirProtocoloCtrc("+hiddenProtocoloCtrc.value+","+countProtocoloCtrc+")",
          className:"imagemLink",
          src:"img/lixo.png"
      });
      //var imPdf = Builder.node("img",{id:"imgImpRelatorio_"+countProtocoloCtrc,name:"imgImpRelatorio_"+countProtocoloCtrc,onclick:"imprimir("+hiddenProtocoloCtrc.value+")",className:"imagemLink",src:"img/pdf.gif"});

      
      var hiddenNumeroCtrc = Builder.node("input",{
          type:"hidden",
          id:"ctrcNumero_"+countProtocoloCtrc,
          name:"ctrcNumero_"+countProtocoloCtrc,
          value:protocoloCtrc.numero
      });
      
      var hiddenIdFilialCte = Builder.node("input",{
          type:"hidden",
          id:"idfilialCtrc_"+countProtocoloCtrc,
          name:"idfilialCtrc_"+countProtocoloCtrc,
          value:protocoloCtrc.idFilialCtrc
      });
      

      var tr = Builder.node("tr",{
          name:"tr_"+countProtocoloCtrc,
          id:"tr_"+countProtocoloCtrc,
          className:"CelulaZebra2"
      });
      var td0 = Builder.node("td",{
          name:"td_0_"+countProtocoloCtrc,
          id:"td_0_"+countProtocoloCtrc
      });
      var td1 = Builder.node("td",{
          name:"td_1_"+countProtocoloCtrc,
          id:"td_1_"+countProtocoloCtrc
      });
      var td2 = Builder.node("td",{
          name:"td_2_"+countProtocoloCtrc,
          id:"td_2_"+countProtocoloCtrc
      });
      var td3 = Builder.node("td",{
          name:"td_3_"+countProtocoloCtrc,
          id:"td_3_"+countProtocoloCtrc
      });
      var td4 = Builder.node("td",{
          name:"td_4_"+countProtocoloCtrc,
          id:"td_4_"+countProtocoloCtrc
      });
        
        
        //td0.appendChild(imPdf);
        td1.innerHTML= protocoloCtrc.numero;
        td1.appendChild(hiddenCtrc);
        td1.appendChild(hiddenProtocoloCtrc);
        td1.appendChild(hiddenNumeroCtrc);
        td1.appendChild(hiddenIdFilialCte);
        td2.innerHTML =  protocoloCtrc.destinatario;
        td3.appendChild(im0);
        
        
        //tr.appendChild(td0);
        tr.appendChild(td1);
        tr.appendChild(td2);
        tr.appendChild(td3);

     
        tabelaBase.appendChild(tr);
        $("countProtocoloCtrc").value = countProtocoloCtrc;
        $("qtdCtes").innerHTML = countProtocoloCtrc;
        $("slcTipo").disabled = true;
     }
     catch(e){
         alert(e);
     }
      limparNumeroCte();
    }
    
    function addProtolocoAoSelecionar(protocoloCtrc) {
        if(countProtocoloCtrc > 0){
            qtdSelecionado = 0;
            for(i=1;i <= countProtocoloCtrc;i++){
                
                if($("ctrcNumero_"+i).value == protocoloCtrc.numero && $("idfilialCtrc_"+i).value == protocoloCtrc.idFilialCtrc){
                    qtdSelecionado++;
                }
            }
            if(qtdSelecionado != 0){
                alert("Esse CT-e " + protocoloCtrc.numero + " já foi selecionado!");
            }else{
                addProtocoloCtrc(protocoloCtrc);
            }
        }else{
            addProtocoloCtrc(protocoloCtrc);
        }
    }
    
    function verificaCtrcs(qtdLinhas){
        var retorno = "";
        for (i = 0; i <= qtdLinhas - 1; ++i){
            if (retorno == "")
                retorno += $("linha-"+i).value;
            else
                retorno += ","+$("linha-"+i).value;
        }
        return (retorno);
    }
    
    function selecionar_ctrc(){
        var marcados = "";
        var i;
        for(i = 0; i <= countProtocoloCtrc; i++){
            if($("idCtrc_"+i) != null){
                if (marcados == "") {
                    marcados += ($("idCtrc_"+i).value);
                }else{
                    marcados += (","+$("idCtrc_"+i).value);
                }
            }
        }
        
        if ($("slcTipo").value == "e" && ($('iddestinatario').value == "0" || $('iddestinatario').value == "")) {
            alert("Atenção: Informe o destino do protocolo corretamente!");
            return false;
        }
        
        window.open("./pops/jspseleciona_ctrc_protocolo.jsp?acao=iniciar&marcados="+marcados+"&dtinicial=<%=Apoio.getDataAtual()%>&dtfinal=<%=Apoio.getDataAtual()%>&iddestinatario="+$('iddestinatario').value+
                "&tipoProtocolo="+$("slcTipo").value+"&chkNormal=true",
        "CtrcProtocolo", "top=50,left=0,height=600,width=950,resizable=yes,status=1,scrollbars=1");
    }

    function localizarCtrc(){
        
     try{
       function e(transport){
            var textoresposta = transport.responseText;
            if (textoresposta == "-1"){
                alert("Atenção: Houve algum problema ao requistar o CT-e.");
            }else{
                var lista = jQuery.parseJSON(textoresposta);
                var ctrc = lista.conhecimento;

                //Verificando se retornou algum CTRC
                if($("slcTipo").value == 'e'){
                    if(ctrc.protocolo != null && ctrc.protocolo != undefined){
                        if (ctrc.protocolo.id != null && ctrc.protocolo.id != undefined && ctrc.protocolo.id != '') {
                            if(ctrc.protocolo.tipo == 'e'){
                                alert("Atenção: O CT-e digitado não poderá ser adicionado, pois encontra-se no protocolo : " +ctrc.protocolo.numero);     
                                return false;
                            }
                        }
                    }
                }
                
            if(ctrc.id == 0){
                  alert("Atenção: O CT-e digitado não poderá ser adicionado ao protocolo pois a entrega não foi realizada.");   
                }else if($("slcTipo").value == "e" && $("iddestinatario").value != ctrc.cliente.idcliente){
                    alert("Atenção: O CT-e digitado não pertence ao cliente "+$('dest_rzs').value+"!");
                }else{
                    
                    //testando se o ctrc selecionado ja foi selecionado
                    if(countProtocoloCtrc > 0){
                        qtdSelecionado = 0;
                        for(i=1;i <= countProtocoloCtrc;i++){
                            if($("ctrcNumero_"+i).value == ctrc.numero && $("idfilialCtrc_"+i).value == ctrc.filial.idfilial){
                                qtdSelecionado++;
                            }
                        }
                        if(qtdSelecionado != 0){
                            alert("Atenção: Esse CT-e já foi selecionado!");
                        }else{
                            addProtocoloCtrc(new ProtocoloCtrc(null,ctrc.id,ctrc.numeroCarga,ctrc.numero,ctrc.chegadaEm,ctrc.destinatario.razaosocial,null,ctrc.filial.idfilial));
                        }
                            
                    }else{
                        addProtocoloCtrc(new ProtocoloCtrc(null,ctrc.id,ctrc.numeroCarga,ctrc.numero,ctrc.chegadaEm,ctrc.destinatario.razaosocial,null,ctrc.filial.idfilial));
                    }
                    
                }
                
            }
        }
        //testando se existe um destinatario
        if($("slcTipo").value == "e" && ($("iddestinatario").value == '0'||$("iddestinatario").value == '')){
            alert("Atenção: Informe o destino do protocolo corretamente!");
        }else{
            tryRequestToServer(function(){
                new Ajax.Request("ProtocoloControlador?acao=localizarCtrc&numeroCtrc="+$('numeroCtrc').value+"&serieCtrc="+$('serieCtrc').value
                        +"&idfilial="+$('idfilial').value+"&iddestinatario="+$('iddestinatario').value+"&idFilialDestino="+$("slcFilialDestino").value
                        +"&tipo="+$("slcTipo").value+"&idFilialCte="+$("filialCte").value,
                {method:'post', onSuccess: e, onError: e});
            });
        }
      }catch(e){
          alert(e);
      }
    }
    
    function limparNumeroCte(){
        $("numeroCtrc").value = "";
    }
    function excluirProtocoloCtrc(id,linha){
        try{
            if(confirm("Deseja excluir o CT-e \'"+$("ctrcNumero_"+linha).value+"\'?")){
                        if(confirm("Tem certeza?")){ 
                            new Ajax.Request("ProtocoloControlador?acao=excluirProtocoloCtrc&idProtocoloCtrc="+id);
                            Element.remove($("tr_"+linha));
                            $("countProtocoloCtrc").value--;
                            countProtocoloCtrc--;
                            $("qtdCtes").innerHTML = countProtocoloCtrc;
                        
                            if($("qtdCtes").innerHTML == '0'){
                                $("slcTipo").disabled = false; 
                            }
                    
                        }
            }
        }catch(e){
            alert(e);
        }
    }
    
    function tipoProtocolo(){
        
        if ($("slcTipo").value == "e") {
            $("idfilial").value = idFilialExterno;
            $("fi_abreviatura").value = filialExterno;            
            $("localizaOrigem").style.display = "";
            $("divFilialDestino").style.display = "none";
            $("divCliente").style.display = "";
            $("filialCte").disabled = true;
        }else if ($("slcTipo").value == "i") {
            $("idfilial").value = idFilial;
            $("fi_abreviatura").value = filial;            
            $("localizaOrigem").style.display = "none";
            $("divFilialDestino").style.display = "";
            $("divCliente").style.display = "none";
            $("slcFilialDestino").value = idFilial;
            $("dest_rzs").value = "";
            $("iddestinatario").value = "0";
            $("filialCte").disabled = false;
            
        }
        
    }
    
    function localizarCtrcChaveAcesso(chaveAcesso){
        
        if (chaveAcesso == "") {
            alert("Atenção: Informe a chave de acesso");
            return false;
        }
        
        if ($("slcTipo").value == "e" && ($("iddestinatario").value == '0'||$("iddestinatario").value == '')) {
            alert("Atenção: Informe o destino do protocolo corretamente!");
            return false;
        }
        
        function e(transport){
            var textoresposta = transport.responseText;
            if (textoresposta == "-1"){
                alert("Atenção: Houve algum problema ao requistar o CT-e.");
            }else{
                var lista = jQuery.parseJSON(textoresposta);                
                var cte = lista.conhecimento;

                if(lista.null=="" || cte.id == 0){
                    alert("Atenção: CT-e não encontrado!");
                }else if($("slcTipo").value == "e" && $("iddestinatario").value != cte.cliente.idcliente){
                    alert("Atenção: O CT-e digitado não pertence ao cliente "+$('dest_rzs').value+"!");
                }else{
                    
                    if(countProtocoloCtrc > 0){
                        qtdSelecionado = 0;
                        for(i=1;i <= countProtocoloCtrc;i++){
                            if($("ctrcNumero_"+i).value == cte.numero && $("idfilialCtrc_"+i).value == cte.filial.idfilial){
                                qtdSelecionado++;
                            }
                        }
                        if(qtdSelecionado != 0){
                            alert("Atenção: Esse CT-e já foi selecionado!");
                        }else{
                            addProtocoloCtrc(new ProtocoloCtrc(null,cte.id,cte.numeroCarga,cte.numero,cte.chegadaEm,cte.destinatario.razaosocial,null,cte.filial.idfilial));
                        }
                            
                    }else{
                        addProtocoloCtrc(new ProtocoloCtrc(null,cte.id,cte.numeroCarga,cte.numero,cte.chegadaEm,cte.destinatario.razaosocial,null,cte.filial.idfilial));
                    }
                    
                    $("chaveAcesso").value = "";
                    
                }
            }
        }
        
        tryRequestToServer(function(){
            new Ajax.Request("ProtocoloControlador?acao=localizarCteChaveAcesso&chaveAcesso="+$('chaveAcesso').value+"&idfilial="+$('idfilial').value
                    +"&iddestinatario="+$('iddestinatario').value+"&tipo="+$("slcTipo").value,
            {method:'post', onSuccess: e, onError: e});
        });
        
    }
   
</script> 

<html>
    <style type="text/css">
        <!--
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
		.style5 {
			color: #000000
		}
        -->
    </style>
    
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>webtrans - Cadastro de Protocolo</title>
    </head>
    <body onLoad="applyFormatter();carregar();">
        <img src="img/banner.gif">
        
        <table class="bordaFina" width="60%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Protocolo</span>
                </td>
                <td width="18%">
                    <input type="button" value=" Voltar " class="inputbotao" onclick="tryRequestToServer(function(){voltar()})"/>
                </td>
            </tr>
        </table>
        
        <br>
            <form action="ProtocoloControlador?acao=${param.acao==2 ? "editar":"cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
                <table width="60%" align="center" class="bordaFina" >
                     <tr>
                         <td align="center" colspan="6" class="tabela">Dados principais</td>
                     </tr>
                     <tr>
                         <td width="10%" class="TextoCampos">Número:</td>
                         <td width="30%" class="CelulaZebra2"><label>${protocolo.numero}</label></td>
                         <td width="10%" class="TextoCampos">Tipo:</td>
                         <td width="20" class="CelulaZebra2">
                             <select id="slcTipo" name="slcTipo" class="inputTexto" style="width: 100%" onchange="tipoProtocolo()">
                                 <option value="e" selected>Externo (Da Transportadora para o cliente) </option>
                                 <option value="i">Interno (Entre filiais) </option>
                             </select>
                         </td>
                         <td width="10%" class="TextoCampos">*Data:</td>
                         <td width="20" class="CelulaZebra2">
                             <input name="data" id="data" type="text" class="fieldMin" size="10" maxlength="10"   onBlur="alertInvalidDate(this)"  onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)"/>
                         </td>
                     </tr>
                     <tr>
                         <td class="TextoCampos">*Origem:</td>
                         <td class="CelulaZebra2">
                             <input type="hidden" name="countProtocoloCtrc" id="countProtocoloCtrc" value="0"/>
                             <input type="hidden" name="id" id="id" value="0"/>
                             <input name="fi_abreviatura" id="fi_abreviatura" type="text" class="inputReadOnly8pt" size="20" readonly/>
                             <input name="idfilial" id="idfilial" type="hidden" value="${param.idFilial}"/>
                             <input name="localizaOrigem" id="localizaOrigem" type="button" class="inputBotaoMin" value="..." onclick="abrirLocalizarFilial()"/>
                         </td>
                         <td class="TextoCampos">*Destino:</td>
                         <td class="CelulaZebra2" colspan="3">
                             <div id="divCliente" style="display: ">
                                 <input name="dest_rzs" id="dest_rzs" type="text" class="inputReadOnly8pt" size="30" readonly />
                                 <input name="iddestinatario" id="iddestinatario" type="hidden" value="0"/>
                                 <input name="localizaDestino" id="localizaDestino" type="button" class="inputBotaoMin" value="..." onclick="abrirLocalizarCliente()"/>                                 
                             </div>
                             <div id="divFilialDestino" style="display: none">
                                 <select id="slcFilialDestino" name="slcFilialDestino" class="inputtexto" style="width: 20%"></select>
                             </div>
                         </td>                         
                     </tr>
                         <tr class="tabela">
                             <td colspan="6" ><div align="center">Relação dos CT-e(s) Entregues</div></td>
                         </tr>
                     <tr>
                         <td colspan="6">
                             <table class="bordaFina" width="100%">
                                 <tbody id="tbProtocoloCtrc" name="tbProtocoloCtrc">
                                    <tr>
                                        <td class="TextoCampos" colspan="3">
                                            <div align="center">
                                                Digite a série e Nº do CT-e e tecle <i>(Enter)</i>:
                                                <input id="serieCtrc" name="serieCtrc" size="1" class="fieldMin" value="1" />
                                                <input id="numeroCtrc" name="numeroCtrc" size="8" class="fieldMin" onkeypress="if(event.keyCode==13)localizarCtrc();" />
                                                Filial: 
                                                <select id="filialCte" class="inputtexto" style="width: 100px"></select>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos" colspan="3">
                                            <div align="center">
                                                Digite a chave de acesso do CT-e e tecle <i>(Enter)</i>:
                                                <input id="chaveAcesso" name="chaveAcesso" size="44" maxlength="44" class="fieldMin" onkeypress="if(event.keyCode==13)localizarCtrcChaveAcesso(this.value);" />                                                
                                            </div>
                                        </td>                                        
                                    </tr>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos" colspan="3">
                                            <div align="center">
                                                <input type="button" value="Selecionar CT-e(s)" class="inputbotao" onclick="javascritp:tryRequestToServer(function(){selecionar_ctrc();});" />                                                
                                            </div>
                                        </td>
                                    </tr>
                                    <tr class="celula">
                                        <td width="15%">CT-e</td>
                                        <td width="80%" align="left">Destinatário</td>
                                        <td width="5%"></td>
                                    </tr>
                                 </tbody>
                                 <tfoot>
                                     <tr class="celula">
                                         <td align="right">
                                             Qtd CT-e(s):
                                         </td>
                                         <td align="left" colspan="2">
                                             <div id="qtdCtes" name="qtdCtes">0</div>
                                         </td>
                                     </tr>
                                 </tfoot>
                             </table>
                         </td>
                     </tr>
                     <c:if test="${param.acao != 1}">
                     <tr class="tabela">
                         <td colspan="6" >
                             <div align="center">Auditoria</div>
                         </td>
                     </tr>                     
                     <tr>
                        <td class="TextoCampos">Incluso:</td>
                        <td class="CelulaZebra2" colspan="2">Em: ${protocolo.criadoEm} <br>
                                         Por: ${protocolo.criadoPor.nome}
                        </td>
                        <td class="TextoCampos">Alterado:</td>
                        <td class="CelulaZebra2" colspan="2">Em: ${protocolo.atualizadoEm} <br>
                                        Por: ${protocolo.atualizadoPor.nome}
                        </td>
                     </tr>
                     </c:if>
                     <tr>
                         
                         <c:choose>
                             <c:when test="${protocolo.arquivamentoProtocoloId > 0}">
                                 <td class="TextoCampos" colspan="6">
                                     <div align="center">Esse protocolo já foi arquivado conforme número ${protocolo.referencia.referencia}</div>
                                </td>
                             </c:when>
                             <c:otherwise>
                                 <td class="TextoCampos" colspan="6">
                             <c:if test="${param.nivel >= param.bloq}">
                                 <div align="center">
                                    <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                                 </div>
                             </c:if>
                                 </td>
                             </c:otherwise>
                         </c:choose>
                     </tr>
                </table>
             </form> 
       </body>
</html>

