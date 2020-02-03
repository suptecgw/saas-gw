<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="pt-BR" />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<script language="JavaScript" type="text/javascript" src="script/funcoes.js" ></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="JavaScript" type="text/javascript" src="script/prototype.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/ie.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript" type="text/javascript" src="script/mascaras.js"></script>
<html>
    <head>
        <script type="text/javascript">
            
            jQuery.noConflict();
            var idUsuario = "";
            var nomeUsuario = "";

            window.onbeforeunload = function(){
                sessionStorage.clear();
            };

            function importar(){
                try {
                    var form = $("formulario");
                    
                    if($("layoutArquivo").value == ""){
                        alert("Informe o layout para visualização. ");
                        $("layoutArquivo").focus();
                        return false;
                    }
                    
                    if(${param.conteudos != true}){
                        alert("Para importar um arquivo o mesmo tem que ser visualizado primeiro ");
                        return false;
                    }
                    
                    
                    if($("idColetor").value == true || ${param.idColetor == true}){
                        form.action = "ConferenciaControlador?acao=importarColetor&id=${param.manifesto}&caminhoArquivo=${caminhoArquivo}&idConferencia=${conferencia.id}&tipo_operacao=${param.tipo_operacao}&layoutArquivo="+$("layoutArquivo").value;
                    }else if($("idColetor").value == false || ${param.idColetor == false}){
                        form.action = "ConferenciaControlador?acao=importar&id=${param.manifesto}&caminhoArquivo=${caminhoArquivo}&tipo_operacao=${param.tipo_operacao}&layoutArquivo="+$("layoutArquivo").value;
                    }
                    form.enctype = "";
                    setEnv("btImportar");
                    window.open('about:blank', 'pop', 'width=210, height=100');

                    form.submit();

                } catch (e) {
                    alert(e);
                }
            }

            function validarVisualizacao(){
                if($("importCf").value == ""){
                    alert("Informe um arquivo para visualização. ");
                    $("importCf").focus();
                    return false;
                }
                if($("layoutArquivo").value == ""){
                    alert("Informe o layout para visualização. ");
                    $("layoutArquivo").focus();
                    return false;
                }
            }


            function visualizar(){
                try {
                    
                    if($("importCf").value == "" && ($("idColetor").value == true || ${param.idColetor == true} || $("idColetor").value == false || ${param.idColetor == false})){
                        alert("Informe um arquivo para visualização. ");
                        $("importCf").focus();
                        return false;
                    }
                    if($("layoutArquivo").value == "" && ($("idColetor").value == true || ${param.idColetor == true} || $("idColetor").value == false || ${param.idColetor == false})){
                        alert("Informe o layout para visualização. ");
                        $("layoutArquivo").focus();
                        return false;
                    }
                    
                    var form = $("formulario");
                    
                    setEnv("btVisualizar");
                    window.open('about:blank', 'pop', 'width=210, height=100');
                    
                    if($("idColetor").value == true || ${param.idColetor == true}){
//                        validarVisualizacao();
                        form.action = "ConferenciaControlador?acao=visualizarColetor&id=${param.manifesto}&idConferencia=${conferencia.id}&tipo_operacao=${param.tipo_operacao}&nmanifesto=${param.nManifesto}&origem=${param.cidadeOrigem}&uforigem=${param.ufOrigem}&destino=${param.cidadeDestino}&ufdestino=${param.ufDestino}&dataEmissao=${param.dataEmissao}&layoutArquivo="+$("layoutArquivo").value;
                        form.submit();
                    }else if($("idColetor").value == false || ${param.idColetor == false} && $("layoutArquivo").value == "GwSistemas"){
                        form.action = "ConferenciaControlador?acao=visualizarGw&id=${param.manifesto}&tipo_operacao=${param.tipo_operacao}&nmanifesto=${param.nManifesto}&origem=${param.cidadeOrigem}&uforigem=${param.ufOrigem}&destino=${param.cidadeDestino}&ufdestino=${param.ufDestino}&dataEmissao=${param.dataEmissao}&layoutArquivo="+$("layoutArquivo").value;
                        form.submit();
                    }else if($("idColetor").value == false || ${param.idColetor == false}){
//                        validarVisualizacao();
                        form.action = "ConferenciaControlador?acao=visualizar&id=${param.manifesto}&tipo_operacao=${param.tipo_operacao}&nmanifesto=${param.nManifesto}&origem=${param.cidadeOrigem}&uforigem=${param.ufOrigem}&destino=${param.cidadeDestino}&ufdestino=${param.ufDestino}&dataEmissao=${param.dataEmissao}&layoutArquivo="+$("layoutArquivo").value;
                        form.submit();
                    }
                    espereEnviar(" Alguns minutos",true);
                } catch (e) {
                    alert(e);
                }
            }
             
            function esconderDiv(elemento){
                var linha = elemento.id.split("_")[1];

                if ($("bodycliente_"+linha).style.display == "none") {
                    $("bodycliente_"+linha).style.display = "";
                    $("exp_"+linha).src = "img/minus.jpg";
                } else {
                    $("bodycliente_"+linha).style.display = "none";
                    $("exp_"+linha).src = "img/plus.jpg";
                }
                
            }
            
            function esconderDetalheColetor(elemento){
                var linha = elemento.id.split("_")[1];

                if ($("bodycoletor_"+linha).style.display == "none") {
                    $("bodycoletor_"+linha).style.display = "";
                    $("col_"+linha).src = "img/minus.jpg";
                } else {
                    $("bodycoletor_"+linha).style.display = "none";
                    $("col_"+linha).src = "img/plus.jpg";
                }
                
            }
            
            function calcularConferencia(){
                var qtdArquivoCliente = parseInt($("qtdArquivosCliente").value, 10);
                var qtdArquivoColetor = parseInt($("qtdArquivosColetor").value, 10);
                var qtdVolumesColetor = 0;
                var qtdVolumesCliente = 0;
//                var qtdNotasColetor = 0;
//                var qtdNotasCliente = 0;
                
                var contador = 1;
                
                for (i = 1; i <= qtdArquivoCliente; i++) {// Percorrendo a quantidade de arquivos do Cliente
                    contador = 0;
                    var prodColetor = 0;
                    var prodCliente = 0;
                    for (k = 1; k <= qtdArquivoColetor; k++) { // Percorrendo a quantidade de arquivos do Coletor
                        qtdVolumesColetor = parseInt($("volumeColetor_" +k).value, 10); // Pegando o valor dos itens do Coletor
//                        qtdNotasCliente = parseInt($("volumeTotalNotas").value, 10); // Pegando o valor dos itens do Coletor

                        for (j = 1; j <= qtdVolumesColetor; j++) {//Percorrendo os itens do Coletor
                            prodColetor = $("campoColetor_"+k+"_"+j).value;
                            for (c = 1; c <= qtdVolumesCliente; c++) {//Percorrendo os itens do Cliente
                                
                            prodCliente = $("Codigo_"+i+"_"+c).innerHTML
                              if(i == k){
                                if(prodColetor == prodCliente){
                                        contador++;
                                        $("qtdConferidos_"+i).value = contador;
                                        $("quantidadeConferidos_"+i).innerHTML = $("qtdConferidos_"+i).value;
                                        $("coletoConfere_"+j).style.display = "";
                                        $("coletonaoConfere_"+j).style.display = "none";
                                        break;
                                }else{
                                    $("coletoConfere_"+j).style.display = "none";
                                    $("coletonaoConfere_"+j).style.display = "";
                                }
                              }//Fechar do if k == i
                           }
                        }
                    }

                    var vol = qtdVolumesColetor;
                    var conf = parseInt($("qtdConferidos_"+i).value, 10);
                    var diferenca = (vol - conf);
                    $("diferenca_"+i).innerHTML = diferenca;
                    if(diferenca == 0 && qtdArquivoColetor > 0){
                        $("naoConfere_"+i).style.display = "none";
                        $("confere_"+i).style.display = "";
                    }else{
                        $("confere_"+i).style.display = "none";
                        $("naoConfere_"+i).style.display = "";
                    }
                    
                }
                
            }
            
            function setarValores(){
//                    var qtdItensColetor = parseInt("$ {fn:length(conferencia.arquivosColetor[0].itens)}", 10);
//                    var qtdItensCliente = parseInt("$ {fn:length(conferencia.arquivosCliente[0].itens)}", 10);
//                    var somaItens = (qtdItensCliente + qtdItensColetor);                
//                    $("quantidadeItens").innerHTML = somaItens;
            }
            
            
            function recuperarNomeCodigo(valor, idDuplicar){
                var split = valor.split("_");
                var retorno = split[2].replace(".txt", "");
                
                if($(idDuplicar) != null){
                    $(idDuplicar).value = retorno;
                }
                return retorno;
            }

            function desabilitarDrive(){
                $("layoutArquivo").value = $("desDriver").value;
                $("layoutArquivo").disabled = true;
            }
     
            function carregarItensCliente(){
                if($("qtdArquivosCliente").value == "0"){
                   $("qtdArquivosCliente").value = $("itens").value; 
                }

            }
            function carregar(){
                if($("desDriver").value != ""){
                    desabilitarDrive();
                }
                carregarItensCliente(); 
                calcularConferencia();    
                setarValores();
                
                var carga = null;
                var totalVolume = 0;
                var totalNotas = 0;
                <c:forEach var="cte" varStatus="status" items="${listaCte}">
                        
                    <c:forEach var="nota" varStatus="status" items="${cte.notas}">
                        carga = new DadosCarga();
                        
                        carga.idCte = '${cte.id}';
                        carga.numeroCte = '${cte.numero}';
                        carga.idDestinatario = '${cte.destinatario.idcliente}';
                        carga.nomeDestinatario = '${cte.destinatario.razaosocial}';
                        carga.idNota = '${nota.idnotafiscal}';
                        carga.numeroNota = '${nota.numero}';                        
                        carga.codigoBarras = '${nota.codigoBarras}';                        
                        <c:forEach var="cub" varStatus="status" items="${nota.cubagensNotaFiscal}">
                            
                            carga.etiqueta += "," + '${cub.etiqueta}';
                            <c:if test="${status.last}">
                                carga.volume = parseInt('${status.count}');
                            </c:if>                            
                            
                        </c:forEach>
                            
                        totalVolume = totalVolume + carga.volume;
                        totalNotas = totalNotas + 1;
                        addCarga(carga);
                        
                    </c:forEach>
                        
                </c:forEach>
                if (${param.layout == 'm'}) {
                    $("mobly").checked = true;
                    mostrarLayout("m");
                } else if (${param.layout == 't'}) {
                    $("gwTrans").checked = true;
                    mostrarLayout("t");
                } else if (${param.layout == 'c'}) {
                    $("chaveAcesso").checked = true;
                    mostrarLayout("c");
                }
                
                var coletor = null;    
                <c:forEach var="coletor" varStatus="status" items="${listaColetorManRom}">
                    coletor = new DadosColetor();
                    
                    coletor.idColetor = '${coletor.id}';
                    coletor.idCte = '${coletor.conhecimento.id}';
                    coletor.idUsuario = '${coletor.usuario.idusuario}';
                    coletor.nomeUsuario = '${coletor.usuario.nome}';
                    coletor.codigo = '${coletor.etiqueta}';
                    coletor.isExiste = '${coletor.existe}';                    
                    coletor.mensagem = '${coletor.mensagem}';                    

                    addColetor(coletor);
                   atualizarConferencia(coletor);
                    
                </c:forEach>    
                    
                idUsuario = '<c:out value="${param.idUsuario}"/>';
                nomeUsuario = '<c:out value="${param.nomeUsuario}"/>';
                
                    $("volumeTotal").value = totalVolume;    
                    $("totalVolume").innerHTML = totalVolume;
                    $("volumeTotalNotas").value = totalNotas;    
                    $("totalVolumeNotas").innerHTML = totalNotas;
                
                atualizarDiferenca();                        
                atualizarDiferencaNotas();                        
                jQuery('#codigoBarras').focus();
                
                
                if ('${param.isFinalizada}' === 'true') {
                    //Disable all inputs
                    var inputs = document.getElementsByTagName("INPUT");
                    for (var i = 0; i < inputs.length; i++) {
                        if (inputs[i].value.trim() !== 'Fechar') {
                            inputs[i].disabled = true;
                            if (inputs[i].type === 'text') {
                                inputs[i].classList.add('inputReadOnly');
                            } else if (inputs[i].type === 'button' || inputs[i].type === 'submit') {
                                inputs[i].remove();
                            }
                        }
                    }
                    //Disable all select
                    var selects = document.getElementsByTagName('SELECT');
                    for (var i = 0; i < selects.length; i++) {
                        selects[i].disabled = true;
                    }
                    //Remove all onclick
                    var eOnclick = document.querySelectorAll('[onclick]');
                    for (var i = 0; i < eOnclick.length; i++) {
                        if (eOnclick[i].value !== ' Fechar ') {
                            eOnclick[i].removeAttribute("onclick");
                        }
                    }
                    //Remove all class linkEditar
                    var eLinkEditar = document.getElementsByClassName('linkEditar');
                    for (var i = 0; i < eLinkEditar.length; i++) {
                        eLinkEditar[i].removeAttribute("class");
                    }
                    //Remove all class linkEditar
                    var eLinkEditar = document.getElementsByClassName('linkEditar');
                    for (var i = 0; i < eLinkEditar.length; i++) {
                        eLinkEditar[i].removeAttribute("class");
                    }
                }
                
                if ('${param.erroFinalizarConferencia}'.length > 1) {
                    alert('${param.erroFinalizarConferencia}');
                }
            }
            
            
            function mostrarLayout(layout){
                jQuery("img[id*='impressaoEtiquetas_']").hide();
                jQuery("table[id='tableImpressora']").hide();
                if (layout == 'f') {
                    $("trTotalVolumes").style.display = "";
                    $("trTotalNotas").style.display = "none";
                    $("trLayoutFinger").style.display = "";
                    $("trVisualizarLayoutFinger").style.display = "";
                    $("trFinger").style.display = "";
                    $("trMobly").style.display = "none";
                    $("btImportar").style.display = "";
                    $("btAtualizar").style.display = "none";
                    $("tbBipagemVolume").style.display = "none";
                    $("tbBipagemNotas").style.display = "none";
                    jQuery('label[tipo=nota]').hide();
                    jQuery('label[tipo=volume]').hide();
                }else if(layout == 'm' || layout == 't'){
                    $("trTotalVolumes").style.display = "";
                    $("trTotalNotas").style.display = "none";
                    $("trLayoutFinger").style.display = "none";
                    $("trVisualizarLayoutFinger").style.display = "none";                    
                    $("trFinger").style.display = "none";                    
                    $("trMobly").style.display = "";                    
                    $("btImportar").style.display = "none";
                    $("btAtualizar").style.display = "";
                    $("tbBipagemVolume").style.display = "";
                    $("tbBipagemNotas").style.display = "none";
                    jQuery('label[tipo=nota]').hide();
                    jQuery('label[tipo=volume]').show();
                    if(parseFloat($("totalColetor").value) > 0){
                        atualizar();                        
                    }
                    jQuery('#codigoBarras').focus();
                    if (layout == 't') {
                        jQuery("img[id*='impressaoEtiquetas_']").show();
                        jQuery("table[id='tableImpressora']").show();
                    }
                }else if(layout == 'c'){
                    $("trTotalVolumes").style.display = "none";
                    $("trTotalNotas").style.display = "";
                    $("trLayoutFinger").style.display = "none";
                    $("trVisualizarLayoutFinger").style.display = "none";                    
                    $("trFinger").style.display = "none";                    
                    $("trMobly").style.display = "";                    
                    $("btImportar").style.display = "none";
                    $("btAtualizar").style.display = "";
                    $("tbBipagemVolume").style.display = "none";
                    $("tbBipagemNotas").style.display = "";
                    jQuery('label[tipo=nota]').show();
                    jQuery('label[tipo=volume]').hide();
                    if(parseFloat($("totalColetor").value) > 0){
                        atualizar();
                    }
                    jQuery('#codigoBarras').focus();
                }
            }
            
            function DadosColetor(idColetor, idCte, idUsuario, nomeUsuario, codigo, isExiste, mensagem){
                this.idColetor = (idColetor != null && idColetor != undefined ? idColetor : 0);
                this.idCte = (idCte != null && idCte != undefined ? idCte : 0);
                this.idUsuario = (idUsuario != null && idUsuario != undefined ? idUsuario : 0);
                this.nomeUsuario = (nomeUsuario != null && nomeUsuario != undefined ? nomeUsuario : "");
                this.codigo = (codigo != null && codigo != undefined ? codigo : 0);                
                this.isExiste = (isExiste != null && isExiste != undefined ? isExiste : false);                
                this.mensagem = (mensagem != null && mensagem != undefined ? mensagem : "");                
            }
            
            function DadosCarga(idCte, numeroCte, idDestinatario, nomeDestinatario, idNota, numeroNota, volume, etiqueta, codigoBarras){
                this.idCte = (idCte != null && idCte != undefined ? idCte : 0);
                this.numeroCte = (numeroCte != null && numeroCte != undefined ? numeroCte : 0);
                this.idDestinatario = (idDestinatario != null && idDestinatario != undefined ? idDestinatario : 0);
                this.nomeDestinatario = (nomeDestinatario != null && nomeDestinatario != undefined ? nomeDestinatario : "");
                this.idNota = (idNota != null && idNota != undefined ? idNota : 0);
                this.numeroNota = (numeroNota != null && numeroNota != undefined ? numeroNota : 0);
                this.volume = (volume != null && volume != undefined ? volume : 0);                
                this.etiqueta = (etiqueta != null && etiqueta != undefined ? etiqueta : "");                
                this.codigoBarras = (codigoBarras != null && codigoBarras != undefined ? codigoBarras : "");                
            }
            var countCarga = 0;
            function addCarga(carga){
                
                if(carga == null || carga == undefined){
                    carga = new DadosCarga();
                }
                
                countCarga++;
                
                var _trCarga = Builder.node("tr",{
                    className:"CelulaZebra2"
                });
                
                var _tdCte = Builder.node("td",{
                    id:"tdCte_"+countCarga,
                    name:"tdCte_"+countCarga,
                    className:"CelulaZebra2"
                });                
                
                var _tdDestinatario = Builder.node("td",{
                    id:"tdDestinatario_"+countCarga,
                    name:"tdDestinatario_"+countCarga,
                    className:"CelulaZebra2"
                });
                
                var _tdNumeroNota = Builder.node("td",{
                    id:"tdNumeroNota_"+countCarga,
                    name:"tdNumeroNota_"+countCarga,
                    className:"CelulaZebra2"
                });
                
                var _tdVolume = Builder.node("td",{
                    id:"tdVolume_"+countCarga,
                    name:"tdVolume_"+countCarga,
                    className:"CelulaZebra2"
                });
                
                var _tdImpressao = Builder.node("td",{
                    id:"tdImpressao_"+countCarga,
                    name:"tdImpressao_"+countCarga,
                    className:"CelulaZebra2"
                });
                
                var _tdConferencia = Builder.node("td",{
                    id:"tdConferencia_"+countCarga,
                    name:"tdConferencia_"+countCarga,
                    className:"CelulaZebra2"
                });
                
                var _inpIdCte = Builder.node("input",{
                    id:"inpIdCte_"+countCarga,
                    nome:"inpIdCte_"+countCarga,
                    type:"hidden",
                    value:carga.idCte
                });
                
                var _lblNumeroCte = Builder.node("label",{
                    id:"lblNumeroCte_"+countCarga,
                    name:"lblNumeroCte_"+countCarga
                });
                
                _lblNumeroCte.innerHTML = carga.numeroCte;                
                
                var _inpIdDestinatario = Builder.node("input",{
                    id:"inpIdDestinatario_"+countCarga,
                    nome:"inpIdDestinatario_"+countCarga,
                    type:"hidden",
                    value:carga.idDestinatario
                });
                
                var _lblNomeDestinatario = Builder.node("label",{
                    id:"lblNumeroDestinatario_"+countCarga,
                    name:"lblNumeroDestinatario_"+countCarga                    
                });
                _lblNomeDestinatario.innerHTML = carga.nomeDestinatario;
                
                var _lblNumeroNota = Builder.node("label",{
                    id:"lblNumeroNota_"+countCarga,
                    name:"lblNumeroNota_"+countCarga,
                    className:"linkEditar",
                    onclick:"javascript:tryRequestToServer(function(){visualizarNota("+carga.idNota+")});"
                });                
                _lblNumeroNota.innerHTML = carga.numeroNota;                

                var _inpVolumeDinamico = Builder.node("input",{
                   id:"volumeDinamico_"+countCarga, 
                   name:"volumeDinamico_"+countCarga, 
                   type:"hidden",
                   value:"0"
                });

                var _inpImpressaoEtiquetas = Builder.node("img",{
                    src:"img/ctrc.gif",
                    width:"20px",
                    ridth:"40px",
                    id:"impressaoEtiquetas_"+countCarga, 
                    name:"impressaoEtiquetas_"+countCarga,
                    onclick: "imprimirNota("+countCarga+","+carga.idCte+");"
                });
                
                var _lblVolumeDinamico = Builder.node("label",{
                    id:"lblVolumeDinamico_"+countCarga,
                    name:"lblVolumeDinamico_"+countCarga,
                    tipo: "volume"
                });
                
                var _lblVolumeFixo = Builder.node("label",{
                    id:"lblVolumeFixo_"+countCarga,
                    name:"lblVolumeFixo_"+countCarga,
                    tipo: "volume"
                }); 
                    _lblVolumeDinamico.innerHTML = "0";
                    _lblVolumeFixo.innerHTML = "/" + carga.volume;

                var _imgOk = Builder.node("img",{
                    src:"img/ok.png",
                    width:"20px",
                    ridth:"40px",
                    id:"imgOk_"+countCarga,
                    name:"imgOk_"+countCarga,
                    style:"display: none"
                });
                
                var _imgCancelar = Builder.node("img",{
                    src:"img/cancelar.png",
                    width:"20px",
                    ridth:"40px",
                    id:"imgCancelar_"+countCarga,
                    name:"imgCancelar_"+countCarga,
                    style:"display: "
                });
                
                var _divConferencia = Builder.node("div",{
                    align:"center"
                });
                
                var _inpEtiqueta = Builder.node("input",{
                   id:"etiqueta_"+countCarga, 
                   name:"etiqueta_"+countCarga, 
                   type:"hidden",
                   value:carga.etiqueta.substring(1)
                });
                
                var _inpQtdEtiqueta = Builder.node("input",{
                   id:"qtdEtiqueta_"+countCarga, 
                   name:"qtdEtiqueta_"+countCarga, 
                   type:"hidden",
                   value:carga.volume
                });                              
                
                var _codigoNotasFixo = Builder.node("input",{
                    id:"idNotasFixo_"+countCarga,
                    name:"idNotasFixo_"+countCarga,
                    type: "hidden",
                    value: carga.idNota
                });   
                
                var _idNotasFixo = Builder.node("input",{
                    id:"codigoNotasFixo_"+countCarga,
                    name:"codigoNotasFixo_"+countCarga,
                    type: "hidden",
                    value: carga.codigoBarras
                });   
                
                var _lblNotasFixo = Builder.node("label",{
                    id:"lblNotasFixo_"+countCarga,
                    name:"lblNotasFixo_"+countCarga,
                    tipo: "nota"
                });         
                _lblNotasFixo.innerHTML = carga.volume;
                
                _divConferencia.appendChild(_imgCancelar);
                _divConferencia.appendChild(_imgOk);
                _divConferencia.appendChild(_inpEtiqueta);
                _divConferencia.appendChild(_inpQtdEtiqueta);                
                               
                _tdCte.appendChild(_inpIdCte);
                _tdCte.appendChild(_lblNumeroCte);
                _tdDestinatario.appendChild(_inpIdDestinatario);                
                _tdDestinatario.appendChild(_lblNomeDestinatario);
                _tdNumeroNota.appendChild(_lblNumeroNota);
                _tdNumeroNota.appendChild(_codigoNotasFixo);
                _tdNumeroNota.appendChild(_idNotasFixo);
                _tdVolume.appendChild(_inpVolumeDinamico);
                _tdVolume.appendChild(_lblVolumeDinamico);
                _tdVolume.appendChild(_lblVolumeFixo);
                _tdVolume.appendChild(_lblNotasFixo);
                _tdImpressao.appendChild(_inpImpressaoEtiquetas);
                _tdConferencia.appendChild(_divConferencia);

                _trCarga.appendChild(_tdCte);
                _trCarga.appendChild(_tdDestinatario);
                _trCarga.appendChild(_tdNumeroNota);
                _trCarga.appendChild(_tdVolume);
                _trCarga.appendChild(_tdImpressao);
                _trCarga.appendChild(_tdConferencia);
                
                $("maxCte").value = countCarga;
                $("testeCarga").appendChild(_trCarga);
                
            }
            var countColetor=0;
            function addColetor(coletor){
                
                if(coletor == null || coletor == undefined){
                    coletor = new DadosColetor();
                }
                
                countColetor++;
                //Adicionando chave de bipada no storage com o index do registro

                if (coletor.idColetor > 0) {
                    sessionStorage.setItem(coletor.codigo,countColetor);
                }
                
                $("totalColetor").value = countColetor;
                var _trColetor = Builder.node("tr",{
                    id:"trColetor_"+countColetor,
                    name:"trColetor_"+countColetor,
                    className:"CelulaZebra2"
                });
                
                var _tdCodigo = Builder.node("td",{
                    id:"tdCodigo_"+countColetor,
                    name:"tdCodigo_"+countColetor,
                    className:"CelulaZebra2"
                });
                
                var _tdUsuario = Builder.node("td",{
                    id:"tdUsuario_"+countColetor,
                    name:"tdUsuario_"+countColetor,
                    className:"CelulaZebra2"
                });
                
                var _tdExcluir = Builder.node("td",{
                    id:"tdExcluir_"+countColetor,
                    name:"tdExcluir_"+countColetor,
                    className:"CelulaZebra2"
                });
                
                var _lblCodigo = Builder.node("label",{
                    id:"lblCodigo_" + countColetor,
                    name:"lblCodigo_" + countColetor
                });                
                _lblCodigo.innerHTML = coletor.codigo;
                
                if (coletor.idUsuario == 0 || coletor.isExiste == 'false') {
                    _lblCodigo.style.color = "red";
                }
                
                var _lblUsuario = Builder.node("label",{
                    id:"lblUsuario_" + countColetor,
                    name:"lblUsuario_" + countColetor
                });                
                _lblUsuario.innerHTML = coletor.mensagem != "" ? coletor.mensagem : coletor.nomeUsuario;

                if (coletor.idUsuario == 0 || coletor.isExiste == 'false') {
                    _lblUsuario.style.color = "red";
                }
                
                var _inpIdUsuario = Builder.node("input",{
                    id:"idUsuario_"+countColetor,
                    name:"idUsuario_"+countColetor,
                    type:"hidden",
                    valeu:coletor.idUsuario
                });
                
                var _imgExcluir = Builder.node("img",{
                    className:"imagemLink",
                    src:"img/lixo.png",
                    width:"20px",
                    ridth:"40px",
                    onclick:"javascript:excluirBipagem("+countColetor+")"
                });
                
                var _divExcluir = Builder.node("div",{
                    align:"center"
                });
                
                var _inpIdColetor = Builder.node("input",{
                    id:"idColetor_"+countColetor,
                    name:"idColetor_"+countColetor,
                    type:"hidden",
                    value:coletor.idColetor
                });
                
                var _isExisteColetor = Builder.node("input",{
                    id:"isExiste_"+countColetor,
                    name:"isExiste_"+countColetor,
                    type:"hidden",
                    value:coletor.isExiste
                });
                
                if(${param.removerEtiquetasNf == 4}){
                    _divExcluir.appendChild(_imgExcluir);
                }
                
                _tdCodigo.appendChild(_isExisteColetor);
                _tdCodigo.appendChild(_lblCodigo);
                _tdCodigo.appendChild(_inpIdColetor);
                _tdUsuario.appendChild(_lblUsuario);
                _tdUsuario.appendChild(_inpIdUsuario);
                _tdExcluir.appendChild(_divExcluir);
                
                _trColetor.appendChild(_tdCodigo);
                _trColetor.appendChild(_tdUsuario);
                    _trColetor.appendChild(_tdExcluir);
                //Sempre adcionando no começo da lista, foi solicitado por que podem ter repetidos nos últimos.
                jQuery("#tbColetor").after(_trColetor);
            }
            
            
            function getBipagem(){
                try{
                var codigoBarras = ($("codigoBarras") !== null ? $("codigoBarras").value.trim() : "");
                var maxCte = $("maxCte").value;
                var idsCte = "0";
                var idManifesto = $("idmanifesto").value;
                var idRomaneio = 0;
                var tipoOperacao = $("tipo_operacao").value;
                var tipo = $("chaveAcesso").checked ? "nota" : "volume";
                var notas = "";
                var isExiste = (sessionStorage.getItem(codigoBarras) != null && ($("isExiste_"+sessionStorage.getItem(codigoBarras)) != null) ? ($("isExiste_"+sessionStorage.getItem(codigoBarras)).value) : "");
                
                
                var cltr = new DadosColetor();     
                
                //Validando se o código de barras já foi importado e se encontra-se na tela.
                if (sessionStorage.getItem(codigoBarras) != undefined && ($("idColetor_"+sessionStorage.getItem(codigoBarras)) != null)
                        && (isExiste =='t' || isExiste == 'true')) {
                        cltr = new DadosColetor();
                        cltr.idColetor = "0";
                        cltr.idCte = "0";
                        cltr.idUsuario = "0";
                        cltr.nomeUsuario = "Código de barras já importado!";
                        cltr.codigo = codigoBarras;
                        addColetor(cltr);
                        $("codigoBarras").value = '';
                }else {
                    for (var qtdCte = 1; qtdCte <= maxCte; qtdCte++) {
                        if($("inpIdCte_"+qtdCte) != null){
                            idsCte += "," + $("inpIdCte_"+qtdCte).value;
                        }
                        if($("idNotasFixo_"+qtdCte) != null){
                            if(notas == ""){
                                notas = $("idNotasFixo_"+qtdCte).value;
                            }else{
                                notas += "," + $("idNotasFixo_"+qtdCte).value;
                            }
                        }
                    }

                    if (codigoBarras == "") {
                        showErro("Informe o código de barras",$("codigoBarras"));
                        return false;
                    }

                    jQuery.ajax({
                        url: '<c:url value="/ConferenciaControlador" />',
                        dataType: "text",
                        method: "post",
                        data: {
                            idUsuario : idUsuario,
                            tipoOperacao : tipoOperacao,
                            idRomaneio : idRomaneio,
                            idManifesto : idManifesto,
                            idsCte : idsCte,
                            notas : notas,
                            codigoBarras : codigoBarras,
                            idColetor : ($("idColetor_"+sessionStorage.getItem(codigoBarras))!= null ? $("idColetor_"+sessionStorage.getItem(codigoBarras)).value : '0'),
                            acao : "getBipagem",
                            tipo: tipo
                        },
                        success: function(data) {

                            var conf = JSON.parse(data);

                            var coletor = new DadosColetor();     
                            if(conf != null && conf != undefined && conf.null != "" && conf.Conferencia.beanConhecimento != null){
                                    if(conf.Conferencia.id != 0 &&  conf.Conferencia.beanConhecimento.nota != undefined){
                                        coletor.idColetor = conf.Conferencia.id;
                                        coletor.idUsuario = idUsuario;
                                        coletor.nomeUsuario = nomeUsuario;
                                        coletor.isExiste = conf.Conferencia.existe;
                                            if(tipo == "volume"){
                                                if(conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0]["conhecimento.orcamento.Cubagem"]){
                                                    coletor.codigo = conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0]["conhecimento.orcamento.Cubagem"].etiqueta;
						}else{
                                                    coletor.codigo = conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0].cubagem.etiqueta;
						}
                                                coletor.idCte = conf.Conferencia.beanConhecimento.id;
                                            }else{
                                                coletor.codigo= conf.Conferencia.beanConhecimento.nota.codigoBarras;
                                                coletor.idCte= conf.Conferencia.beanConhecimento.id;
                                            }                                                          
                                        coletor.isExiste = true;
                                    }else{
                                        coletor.idUsuario = 0;
                                        coletor.nomeUsuario = (conf.Conferencia.mensagem != undefined && conf.Conferencia.mensagem != null &&  conf.Conferencia.mensagem !="" ? conf.Conferencia.mensagem : conf.Conferencia.mensagemRetorno);
                                        coletor.codigo = codigoBarras;
                                        coletor.isExiste = false;
                                    }

                            }else{                            
                                 coletor.idUsuario = 0;
                                 coletor.nomeUsuario = "Código de barras não pertence a esse manifesto";
                                 coletor.codigo = codigoBarras;                            
                            }                    

                            addColetor(coletor);

                            if(coletor.idUsuario != 0){
                                 atualizarConferencia(coletor);                           
                            } else {
                                alert("Atenção: " + coletor.nomeUsuario);  
                            }

                            $("codigoBarras").value = "";
                        }
                    });
                
                }
                } catch (ex){
                console.log(ex);    
                }
            }
            
            function excluirBipagem(index){
            
                var idColetor = 0;
            
                if (confirm("Deseja excluir a Bipagem?")) {
                    
                    espereEnviar("Aguarde...",true);
                    idColetor = $("idColetor_"+index).value;
                    
                    if(${param.removerEtiquetasNf == 4}){
                        if (idColetor != 0) {

                            jQuery.ajax({
                                url: '<c:url value="/ConferenciaControlador" />',
                                dataType: "text",
                                method: "post",
                            data: {
                                idColetor : idColetor,
                                acao : "excluirBipagem"
                            },
                            success: function(data) {
                                    if(!$("chaveAcesso").checked){
                                        if ($("codigoNotasFixo_"+index) != null) {
                                            atualizarConferenciaExcluir($("codigoNotasFixo_"+index).value);
                                        }
                                    }else{
                                        atualizarConferenciaExcluir($("lblCodigo_"+index).innerHTML);  
                                    }

                                    if ($("lblCodigo_"+index)) {
                                        sessionStorage.removeItem($("lblCodigo_"+index).innerHTML);
                                    }
                                    Element.remove($("trColetor_"+index));
                                    index--;
                                    espereEnviar("Aguarde...",false);

                                }
                            });
                        }else{
                        //Validando se o objeto excluido do sessionStorage tem idColetor, (Quando o objeto já existe na tela, adiciona ele com idColetor = 0)   
                            if (idColetor != 0 && $("lblCodigo_"+index)) {
                                sessionStorage.removeItem($("lblCodigo_"+index).innerHTML);
                            }
                            Element.remove($("trColetor_"+index));
                            index--;
                            espereEnviar("Aguarde...",false);
                        }                   
                    }else{
                        alert("Atenção! Você não possui privilégios suficientes para executar esta ação!");
                    }
                }
            }
            function atualizarConferencia(etiqueta){
                var maxCte = $("maxCte").value;
                var etiquetas = "";
                
                for (var qtdCte = 1; qtdCte <= maxCte; qtdCte++) {
                    if(!$("chaveAcesso").checked){
                        if ($("etiqueta_"+qtdCte) != null && $("etiqueta_"+qtdCte).value != "") {
                            etiquetas = $("etiqueta_"+qtdCte).value;
                            for (var qtdEti = 0; qtdEti < etiquetas.split(",").length; qtdEti++) {
                                if(etiquetas.split(",")[qtdEti] == etiqueta.codigo 
                                        && (etiqueta.isExiste =='t' || etiqueta.isExiste == 'true' || etiqueta.isExiste == true)){                                
                                   $("qtdEtiqueta_"+qtdCte).value -= 1;
                                   $("conferidoTotal").value = parseInt($("conferidoTotal").value) + 1;
                                   $("volumeDinamico_"+qtdCte).value = parseInt($("volumeDinamico_"+qtdCte).value) + 1;
                                   $("lblVolumeDinamico_"+qtdCte).innerHTML = $("volumeDinamico_"+qtdCte).value;
                                }
                            }
                        }
                        if ($("qtdEtiqueta_"+qtdCte).value == 0 && $("etiqueta_"+qtdCte).value != "" 
                                && (etiqueta.isExiste =='t' || etiqueta.isExiste == 'true' || etiqueta.isExiste == true)) {                        
                            $("imgOk_"+qtdCte).style.display = "";
                            $("imgCancelar_"+qtdCte).style.display = "none";
                        }
                    
                        $("totalConferido").innerHTML = $("conferidoTotal").value;
                        $("bipagemTotal").value = $("conferidoTotal").value;
                        $("totalBipagem").innerHTML = $("bipagemTotal").value;
                
                        atualizarDiferenca();
                    }else{
                        if($("codigoNotasFixo_"+qtdCte) != null && $("codigoNotasFixo_"+qtdCte).value != ""){
                            if($("codigoNotasFixo_"+qtdCte).value == etiqueta.codigo && (etiqueta.isExiste =='t' || etiqueta.isExiste == 'true' || etiqueta.isExiste == true)){
                               $("conferidoTotalNotas").value = parseInt($("conferidoTotalNotas").value) + 1;

                               $("imgOk_"+qtdCte).style.display = "";
                               $("imgCancelar_"+qtdCte).style.display = "none";

                               $("totalConferidoNotas").innerHTML = $("conferidoTotalNotas").value;
                               $("bipagemTotalNotas").value = $("conferidoTotalNotas").value;
                               $("totalBipagemNotas").innerHTML = $("bipagemTotalNotas").value;
                            }
                            atualizarDiferencaNotas();
                        }
                    }
                }
            }
            
            function atualizar(){
                var form = $("formAtualizar");
                var idManifesto = $("idmanifesto").value;
                var tipoOperacao = $("tipo_operacao").value;
                var dataEmissao = $("dataEmissao").value;
                var layoutGwTrans = $("gwTrans").checked;
                var layoutChaveAcesso = $("chaveAcesso").checked;
                var dtChegada = jQuery('#dtchegada').val();
                var hrChegada = jQuery('#hrChegada').val();
                var idOcorrencia = jQuery('#idOcorrencia').val();
                var descricaoOcorrencia = jQuery('#descricaoOcorrencia').val();
                var codigoOcorrencia = jQuery('#codigoOcorrencia').val();
                var isConfFinalizada = jQuery("#chkConfFinalizada").is(":checked");
                if (isConfFinalizada && (dtChegada.length <= 0  || hrChegada.length <= 0)) {
                    alert('O campo data de chegada é obrigatório.');
                    return;
                }else if (isConfFinalizada && idOcorrencia == "0") {
                    alert('Informe uma ocorrência.');
                    return;
                }
                
                var layout = "";
                if (layoutGwTrans == true) {
                    layout = "t";
                }else if(layoutChaveAcesso == true){
                    layout = "c";
                }else{
                    layout = "m";            
                }
                form.action = "ConferenciaControlador?acao=importarArquivo&id="+idManifesto
                        +"&tipo_operacao="+tipoOperacao+"&layout="+layout+"&dataEmissao="+dataEmissao+
                        (isConfFinalizada ? "&dtChegada="+dtChegada+"&hrChegada="+hrChegada+"&idOcorrencia="+
                        idOcorrencia+"&descricaoOcorrencia="+descricaoOcorrencia+"&codigoOcorrencia="+codigoOcorrencia+"&isFinalizada=true" : "");
                form.submit();
                
            }
            
            function visualizarNota(idNotaFiscal) {                
                window.open("NotaFiscalControlador?acao=carregar&idNota=" + idNotaFiscal + "&visualizar=true","visualizarNota", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
            }
            
            function atualizarDiferenca(){
                $("hidDiferenca").value = $("conferidoTotal").value - $("volumeTotal").value;
                $("diferenca").innerHTML = $("hidDiferenca").value;
            }
            
            function atualizarDiferencaNotas(){
                $("hidDiferencaNotas").value = $("conferidoTotalNotas").value - $("volumeTotalNotas").value;
                $("diferencaNotas").innerHTML = $("hidDiferencaNotas").value;
            }
            
            function atualizarConferenciaExcluir(etiqueta){
                var maxCte = $("maxCte").value;
                var etiquetas = "";
                var isExiste = sessionStorage.getItem(etiqueta);
                for (var qtdCte = 1; qtdCte <= maxCte; qtdCte++) {
                    if(!$("chaveAcesso").checked){
                        if ($("etiqueta_"+qtdCte) != null && $("etiqueta_"+qtdCte).value != "") {
                            etiquetas = $("etiqueta_"+qtdCte).value;
                            for (var qtdEti = 0; qtdEti < etiquetas.split(",").length; qtdEti++) {
                                if(etiquetas.split(",")[qtdEti] == etiqueta && (isExiste =='t' || isExiste == 'true')){                                
                                   $("qtdEtiqueta_"+qtdCte).value += 1;
                                   $("conferidoTotal").value = parseInt($("conferidoTotal").value) - 1;
                                   if(${param.layout != 'c'}){
                                       $("volumeDinamico_"+qtdCte).value = parseInt($("volumeDinamico_"+qtdCte).value) - 1;
                                       $("lblVolumeDinamico_"+qtdCte).innerHTML = $("volumeDinamico_"+qtdCte).value;
                                   }
                                }
                            }
                        }
                        if ($("qtdEtiqueta_"+qtdCte).value > 0 && $("etiqueta_"+qtdCte).value != "" && (isExiste =='t' || isExiste == 'true')) {                        
                            $("imgOk_"+qtdCte).style.display = "none";
                            $("imgCancelar_"+qtdCte).style.display = "";
                        }
                        
                        $("totalConferido").innerHTML = $("conferidoTotal").value;
                        $("bipagemTotal").value = $("conferidoTotal").value;
                        $("totalBipagem").innerHTML = $("bipagemTotal").value;

                        atualizarDiferenca();
                        
                    }else{
                        if($("codigoNotasFixo_"+qtdCte) != null && $("codigoNotasFixo_"+qtdCte).value != ""){
                            if($("codigoNotasFixo_"+qtdCte).value == etiqueta && (isExiste =='t' || isExiste == 'true')){
                               $("conferidoTotalNotas").value = parseInt($("conferidoTotalNotas").value) - 1;

                               $("imgOk_"+qtdCte).style.display = "none";
                               $("imgCancelar_"+qtdCte).style.display = "";

                               $("totalConferidoNotas").innerHTML = $("conferidoTotalNotas").value;
                               $("bipagemTotalNotas").value = $("conferidoTotalNotas").value;
                               $("totalBipagemNotas").innerHTML = $("bipagemTotalNotas").value;
                            }
                            atualizarDiferencaNotas();
                        }
                    }    
                }
            }
            
            function validarPermDigita(){
                if(${param.codigoBarrasNf != '4'}){
                    jQuery("#codigoBarras").bind('contextmenu',function(e){
                            e.preventDefault();
                    });
                    jQuery("#codigoBarras").bind('keydown',function(e){
                        if(e.ctrlKey){
                            e.preventDefault();
                        }                
                    });
                    
                    jQuery("#codigoBarras").bind('keydown',function(e){
                        var tempo =2000;
                        if ((e.keyCode > 47 && e.keyCode < 58 ) || (e.keyCode > 95 && e.keyCode < 106)){ // numeros de 0 a 9
                                setTimeout(function(e){
                                    document.getElementById('codigoBarras').value = "";
                                },tempo);
                        }                            
                    });
                }
            }
            
            /**
             * 
             * @param {type} index
             * @param {type} id
             * @returns
             */
            function imprimirNota(index, id) {
                var caminho = $("caminho_impressora").value;
                var url = "./matricidectrc.ctrc?idmovs="+id+"&driverImpressora="+$("driverImpressora").value+"&caminho_impressora="+caminho;
                tryRequestToServer(function(){document.location.href = url;});
            }
            //Caso precise remover o foco do codigo de barras só adicionar nessa validacao o id do campo que pode receber foco
            jQuery(document).click(
                function(e){
                    if (!(e.target.id === 'driverImpressora' || e.target.id === 'caminho_impressora' || e.target.id === 'dtchegada' || e.target.id === 'hrChegada')) {
                        jQuery('#codigoBarras').focus();
                    }
                }
            );
    
            function abrirLocalizaOcorrencia(){
                launchPopupLocate('./localiza?acao=consultar&idlista=40','Ocorrencia_CTe');
            }
            
            function aoClicarNoLocaliza(idjanela){
                console.log(jQuery("#ocorrencia").val() + '<');
                if (idjanela == "Ocorrencia_CTe") {
                    jQuery("#codigoOcorrencia").val(jQuery("#ocorrencia").val());
                    jQuery("#descricaoOcorrencia").val(jQuery("#descricao_ocorrencia").val());
                    jQuery("#idOcorrencia").val(jQuery("#ocorrencia_id").val());
                }
            }
            
            function validarDataAtual(e){
                var partesData = e.value.split("/");
                if (e.value.length === 10 && new Date(partesData[2], partesData[1] - 1, partesData[0]) > new Date()) {
                    alert('A data de chegada não pode ser maior que a data atual.');
                    e.value = '';
                }
            }

            <c:if test="${param['codigoBarrasNf'] eq '4'}">
                jQuery(document).ready(function() {
                   jQuery('#txtFileToRead').change(function(e) {
                        var fileExtension = /text.*/;
                        var fileTobeRead = this.files[0];
                        if (fileTobeRead.type.match(fileExtension)) {
                            var fileReader = new FileReader();
                            fileReader.onload = function (e) {
                                var conteudo = fileReader.result;

                                jQuery.post('${homePath}/ConferenciaControlador', {
                                    'acao': 'biparLote',
                                    'etiquetas': conteudo.split("\n").join(),
                                    'romaneio_id': 0,
                                    'manifesto_id': $("idmanifesto").value,
                                    'tipo_operacao': $("tipo_operacao").value === '1' ? 's' : 'e',
                                    'tipo_codigo': $("chaveAcesso").checked ? "nota" : "volume",
                                    'usuario_id': idUsuario,
                                    'notas_ids': ''
                                }, function (data) {
                                    if (data) {
                                        jQuery.each(data.reverse(), function (index, conf) {
                                            console.log(conf);

                                            var coletor = new DadosColetor();

                                            if (conf !== undefined && conf.beanConhecimento !== undefined) {
                                                if (conf.id !== 0 && conf.beanConhecimento.nota !== undefined) {
                                                    coletor.idColetor = conf.id;
                                                    coletor.idUsuario = idUsuario;
                                                    coletor.nomeUsuario = nomeUsuario;
                                                    coletor.isExiste = conf.existe;

                                                    if (!$("chaveAcesso").checked) {
                                                        if (conf.beanConhecimento.nota.cubagensNotaFiscal[0] !== undefined) {
                                                            coletor.codigo = conf.beanConhecimento.nota.cubagensNotaFiscal[0].etiqueta;
                                                        } else {
                                                            coletor.codigo = conf.beanConhecimento.nota.cubagensNotaFiscal[0].cubagem.etiqueta;
                                                        }

                                                        coletor.idCte = conf.beanConhecimento.id;
                                                    } else {
                                                        coletor.codigo = conf.beanConhecimento.nota.codigoBarras;
                                                        coletor.idCte = conf.beanConhecimento.id;
                                                    }

                                                    coletor.isExiste = true;
                                                } else {
                                                    coletor.idUsuario = 0;
                                                    coletor.nomeUsuario = (conf.mensagem !== undefined && conf.mensagem !== "" ? conf.mensagem : conf.mensagemRetorno);
                                                    coletor.codigo = conf.codigoBarras;
                                                    coletor.isExiste = false;
                                                }

                                            } else {
                                                coletor.idUsuario = 0;
                                                coletor.nomeUsuario = "Código de barras não pertence a esse manifesto";
                                                coletor.codigo = conf.codigoBarras;
                                            }

                                            addColetor(coletor);

                                            if (coletor.idUsuario !== 0) {
                                                atualizarConferencia(coletor);
                                            }
                                        });
                                    }
                                }, 'json');
                            };
    
                            fileReader.readAsText(fileTobeRead);
                        } else {
                            alert("Por favor selecione arquivo texto");
                        }
                    });
                });
            </c:if>
        </script>

        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <title> Importar conferência (Manifesto)</title>
    </head>
    <body onload="carregar();calcularConferencia();${param.codigoBarrasNf != '4' ?' validarPermDigita() ' : ''}">
        <img alt="" src="img/banner.gif" align="middle">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="82%" align="left"><b>Importação de conferência ( ${param.tipo_operacao == '0' ? 'Entrada' : 'Saída'} )</b></td>
                <td>
                    <input type="button" value=" Fechar " class="botoes" onclick="fechar();"/>
                </td>
            </tr>
        </table>
        <br/>
        <form method="post" action="ConferenciaControlador?acao=importar&id=${param.manifesto}" target="pop" id="formulario" name="formulario" enctype="multipart/form-data" >
            <input type="hidden" id="ocorrencia_id" value="0">
            <input type="hidden" id="ocorrencia" value="">
            <input type="hidden" id="descricao_ocorrencia" value="">
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela">
                    <td colspan="15"> Manifesto   </td>
                </tr>
                <tr class="CelulaZebra1NoAlign">
                    <td  width="8%" class="TextoCampos" >Número: </td>
                    <td  width="8%" class="celulaZebra2" >
                        <label id="nManifesto">  ${param.nManifesto} </label>

                        <input type="hidden" name="idmanifesto" id="idmanifesto" value="${param.manifesto}" />
                        <input type="hidden" name="caminhoArquivo" id="caminhoArquivo" value="${caminhoArquivo}" />
                        <input type="hidden" name="tipo_operacao" id="tipo_operacao" value="${param.tipo_operacao}" />
                        <input type="hidden" name="dataEmissao" id="dataEmissao" value="${param.dataEmissao}" />
                        <input type="hidden" name="conteudos" id="conteudos" value="${param.conteudos}" >
                        <input type="hidden" name="idColetor" id="idColetor" value="${param.idColetor}" />
                        <input type="hidden" name="idConferencia" id="idConferencia" value="${conferencia.id}" />
                        <input type="hidden" name="numeroManifesto" id="numeroManifesto" value="${param.numeroManifesto}" />
                        <input type="hidden" name="qtdArquivosCliente" id="qtdArquivosCliente" value="${fn:length(conferencia.arquivosCliente)}"/>
                        <input type="hidden" name="qtdArquivosColetor" id="qtdArquivosColetor" value="${fn:length(conferencia.arquivosColetor)}" />
                        <input type="hidden" name="desDriver" id="desDriver" value="${param.idDriverCliente}" />
                        <input type="hidden" name="itens" id="itens" value="${param.itens}" />
                        <input type="hidden" name="totalColetor" id="totalColetor" value="0" />
                    </td>
                    <td width="8%" class="TextoCampos" >
                        Origem: 
                    </td>
                    <td class="celulaZebra2" width="14%">
                        <label id="origem"> ${param.cidadeOrigem} </label>
                    </td>
                    <td class="TextoCampos" width="8%">
                        UF: 
                    </td>
                    <td class="celulaZebra2" width="4%">
                        <label id="ufOrigem">  ${param.ufOrigem} </label>
                    </td>

                    <td class="textoCampos" width="8%">
                        Destino: 
                    </td>
                    <td class="celulaZebra2" width="14%">
                        <label id="destino"> ${param.cidadeDestino} </label>
                    </td>
                    <td class="TextoCampos" width="8%">
                        UF: 
                    </td>
                    <td class="celulaZebra2" width="4%">
                        <label id="ufDestino"> ${param.ufDestino}</label>
                    </td>

                    <td class="textoCampos" width="5%">
                        Data: 
                    </td>
                    <td class="celulaZebra2" width="9%">
                        <label id="data">
                            ${param.dataEmissao}
                        </label>
                    </td>

                </tr>
                <tr class="tabela">
                    <!--<td colspan="15">Arquivo(s) da Carga</td>-->
                    <td colspan="15">Layout</td>
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td colspan="2">
                        <label>
                            <input type="radio" id="gwTrans" name="layout" value="t" onclick="mostrarLayout(this.value)" checked/>
                            GWTrans
                        </label>                        
                    </td>
                    <td colspan="2">
                        <label>
                            <input type="radio" id="mobly" name="layout" value="m" onclick="mostrarLayout(this.value)"/>
                            Mobly
                        </label>                        
                    </td>
                    <td colspan="2">
                        <label>
                            <input type="radio" id="finger" name="layout" value="f" onclick="mostrarLayout(this.value)"/>
                            Finger
                        </label>
                    </td>
                    <td colspan="2">
                        <label>
                            <input type="radio" id="chaveAcesso" name="layout" value="c" onclick="mostrarLayout(this.value)"/>
                            Chave de acesso da NF-e
                        </label>
                    </td>
                    <td colspan="4"></td>
                </tr>
                <tr class="CelulaZebra2NoAlign" id="trLayoutFinger" >
                    <td width="10%" align="right">
                        <label>Layout de entrada:</label>     

                    </td>
                    <td align="left" colspan="5">
                        <select name="layoutArquivo" id="layoutArquivo" class="inputTexto" >
                            <c:forEach var="driver" items="${listDriver}" >
                                <option value="${driver.codigo}" > ${driver.descricao} </option>
                            </c:forEach>
                            <!-- <option value="GwSistemas"> Gw Sistemas </option> -->
                        </select>
                    </td>
                    <td id="tdInput" align="left" colspan="8">
                        <input name="importCf" id="importCf" type="file" multiple="multiple"  class="inputTexto" value="${caminhoArquivo}" size="30"/>
                    </td>

                </tr>
                <tr class="CelulaZebra2NoAlign" id="trVisualizarLayoutFinger">
                    <td colspan="15">
                        <input name="btVisualizar" id="btVisualizar" type="button" class="botoes" value="Visualizar" onclick="javascript:tryRequestToServer(function(){visualizar();});" />
                    </td>
                </tr>
            </table>
            <table width="90%" align="center" class="bordaFina">
                <tr id="trFinger">
                    <td width="50%" style="vertical-align:top;">
                        <div width="50%">
                            <!--Começo da visualização do Cliente-->
                            <table width="100%" align="center" class="bordaFina">
                                <tbody>
                                    <tr class="tabela">
                                        <!--Valor para usar no colspan-->
                                        <td colspan="${fn:length(conferencia.arquivosCliente[0].itens[0].campos)+6}"> 
                                            Arquivo do Cliente
                                        </td>
                                    </tr>
                                    <c:if test="${fn:length(conferencia.arquivosCliente[0].itens[0].campos) > 0}">
                                        <tr class="CelulaZebra1NoAlign">
                                            <c:forEach items="${conferencia.arquivosCliente[0].itens[0].campos}" var="campoD">
                                                <td> ${campoD.descricaoFormatado} </td>
                                            </c:forEach>
                                            <td> Volumes:</td>
                                            <td> Conferidos: </td>
                                            <td> Diferença: </td>
                                            <td> Sit.: </td>
                                        </tr>
                                    </c:if>
                                </tbody>        

                                <c:forEach items="${conferencia.arquivosCliente}" varStatus="status" var="ArquivoCliente">
                                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra1NoAlign')}" >
                                        <td colspan="${fn:length(ArquivoCliente.itens[0].campos)-1}">
                                            <input type="hidden" value="" id="codigoCliente_${status.count}" name="codigoCliente_${status.count}">
                                            Pedido:  <label id="cli_${status.count}"><script>document.write(recuperarNomeCodigo('${ArquivoCliente.arquivo.descricao}','codigoCliente_${status.count}' ))</script> </label>
                                            <img src="img/plus.jpg"  name="exp_${status.count}" id="exp_${status.count}" align="left" width="20px" height="20px" onclick=" esconderDiv(this)" alt="Visulizar"/>
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${ArquivoCliente.volumes}" pattern="###0"/>
                                            <input type="hidden" value="${ArquivoCliente.volumes}" id="itensCliente" name="itensCliente">
                                            <input type="hidden" value="${fn:length(ArquivoCliente.itens)}" id="qtdItensArqCliente_${status.count}" name="qtdItensArqCliente_${status.count}">
                                        </td>

                                        <td><!--Volumes-->
                                            <fmt:formatNumber value="${ArquivoCliente.volumes}" pattern="###0"/>
                                            <input type="hidden" value="${ArquivoCliente.volumes}" id="vol_${status.count}" name="vol_${status.count}"/>
                                        </td>
                                        <td ><!--Volumes Conferidos-->
                                            <label name="quantidadeConferidos_${status.count}" id="quantidadeConferidos_${status.count}">0</label>
                                            <input type="hidden" name="qtdConferidos_${status.count}" id="qtdConferidos_${status.count}" value="0" />
                                        </td>
                                        <td><!--Diferença-->
                                            <label id="diferenca_${status.count}" name="diferenca_${status.count}">0</label>
                                            <input type="hidden" name="dif_${status.count}" id="dif_${status.count}" value="0" />
                                        </td>
                                        <td><!--Imagens de confirmado ou não -->
                                            <img src="img/x.png" align="middle" id="naoConfere_${status.count}" style="display:none" name="naoConfere_${status.count}" width="20px" height="20px" alt="Não confere!">
                                            <img src="img/v.png" align="middle" id="confere_${status.count}" style="display:none" name="confere_${status.count}" width="20px" height="20px" alt="confere!">
                                        </td>
                                    </tr>
                                    <tbody id="bodycliente_${status.count}" style="display:none">
                                        <c:forEach items="${ArquivoCliente.itens}" var="item" varStatus="statusItem">
                                            <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra1NoAlign')}" >
                                                <c:forEach items="${item.campos}" var="campo">
                                                    <td class="TextoCampos">
                                                        <label id="${campo.descricao}_${status.count}_${statusItem.count}">${campo.valor}</label>
                                                    </td>
                                                </c:forEach>
                                                <td class="TextoCampos">
                                                </td>
                                                <td class="TextoCampos">
                                                </td>
                                                <td class="TextoCampos">
                                                </td>
                                                <td class="TextoCampos">
                                                </td>
                                            </tr>                 
                                        </c:forEach>
                                    </tbody>
                                </c:forEach><!--Final do forEach do cliente-->    

                                <c:if test="${conferencia.arquivosCliente == null}">
                                    <tr class="CelulaZebra1NoAlign">
                                        <td> Descrição:</td>
                                        <td> .::    ::. </td>
                                        <td> Volumes:</td>
                                        <td> Conferidos: </td>
                                        <td> Diferença: </td>
                                        <td> Sit.: </td>
                                    </tr>

                                    <c:forEach items="${listaConferencia}" varStatus="status" var="conferenciaCliente">
                                        <c:forEach items="${conferenciaCliente.conhecimento}" var="conhecimentoCliente">
                                        <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra1NoAlign')}" >
                                            <td >
                                                <input type="hidden" value="" id="codigoCliente_${status.count}" name="codigoCliente_${status.count}">
                                                Pedido: <label width="5%" id="cli_${status.count}">${conhecimentoCliente.numero}</label>
                                                <img src="img/plus.jpg"  name="exp_${status.count}" id="exp_${status.count}" align="left" width="20px" height="20px" onclick=" esconderDiv(this)" alt="Visulizar"/>
                                            </td>
                                            <td >
                                                <input type="hidden" value="${conferenciaCliente.volumes}" id="itensCliente" name="itensCliente">
                                                <input type="hidden" value="${conferenciaCliente.volumes}" id="qtdItensArqCliente_${status.count}" name="qtdItensArqCliente_${status.count}">
                                            </td>
                                            <td ><!--Volumes-->
                                                ${conferenciaCliente.volumes}
                                                <input type="hidden" value="${conferenciaCliente.volumes}" id="vol_${status.count}" name="vol_${status.count}"/>
                                            </td>
                                            <td ><!--Volumes Conferidos-->
                                                <label name="quantidadeConferidos_${status.count}" id="quantidadeConferidos_${status.count}">0</label>
                                                <input type="hidden" name="qtdConferidos_${status.count}" id="qtdConferidos_${status.count}" value="0" />
                                            </td>
                                            <td ><!--Diferença-->
                                                <label id="diferenca_${status.count}" name="diferenca_${status.count}">0</label>
                                                <input type="hidden" name="dif_${status.count}" id="dif_${status.count}" value="0" />
                                            </td>
                                            <td ><!--Imagens de confirmado ou não -->
                                                <img src="img/x.png" align="middle" id="naoConfere_${status.count}" style="display:none" name="naoConfere_${status.count}" width="20px" height="20px" alt="Não confere!">
                                                <img src="img/v.png" align="middle" id="confere_${status.count}" style="display:none" name="confere_${status.count}" width="20px" height="20px" alt="confere!">
                                            </td>
                                        </tr>
                                        <tbody id="bodycliente_${status.count}" style="display:none">
                                            <c:forEach items="${conhecimentoCliente.notaFiscal}" var="nota" varStatus="statusItem">
                                                <tr class="${(statusItem.count % 2 == 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra1NoAlign')}" >
                                                    <td class="TextoCampos">
                                                        <label>${nota.numero}</label>
                                                    </td>
                                                    <td class="TextoCampos">
                                                        <label><fmt:formatDate type="date" value="${nota.emissao}" /></label>
                                                    </td>
                                                    <td class="TextoCampos">
                                                        <label>${nota.valor}</label>
                                                    </td>
                                                    <td class="TextoCampos">
                                                        <label>${nota.serie}</label>
                                                    </td>
                                                    <td class="TextoCampos">
                                                    </td>
                                                </tr>                 
                                            </c:forEach>
                                        </tbody>
                                        </c:forEach><!-- Fim do forEach do Cliente usando o Manifesto -->
                                    </c:forEach><!-- Fim do forEach do Cliente usando o Manifesto -->
                                </c:if>    
                                <!--Fim da visualização do Cliente-->
                            </table>
                        </div>
                    </td>                           
                    <td width="50%" style="vertical-align:top;">
                        <div width="50%">
                            <!--Começo da visualização do arquivo do coletor -->
                            <table width="100%" align="center" class="bordaFina">
                                <tbody>
                                    <tr class="tabela">
                                        <!--<td  colspan="${fn:length(conferencia.arquivosColetor[0].itens[0].campos)}">-->
                                        <td  colspan="10">
                                            Arquivo do Coletor
                                        </td>
                                    </tr>
                                    <c:if test="${fn:length(conferencia.arquivosColetor[0].itens[0].campos) > 0}">
                                        <tr class="CelulaZebra1NoAlign">
                                            <td width="30px">
                                                Sit..
                                            </td>
                                            <c:forEach items="${conferencia.arquivosColetor[0].itens[0].campos}" var="campoD">
                                                <td>
                                                    ${campoD.descricaoFormatado}
                                                </td>
                                            </c:forEach>
                                        </tr>
                                    </c:if>
                                </tbody>

                                <c:forEach items="${conferencia.arquivosColetor}" varStatus="status" var="confArquivo">
                                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra1NoAlign')}">
                                        <td colspan="${fn:length(confArquivo.itens[0].campos)}" >
                                            <img src="img/plus.jpg" name="col_${status.count}" id="col_${status.count}" align="left" width="20px" height="20px" onclick="esconderDetalheColetor(this)" alt="Visulizar"> 
                                            ${confArquivo.arquivo.descricao}
                                            <input type="hidden" name="driveColetor_${status.count}" id="driveColetor_${status.count}" value="${confArquivo.driver.codigo}"/>
                                            <input type="hidden" name="volumeColetor_${status.count}" id="volumeColetor_${status.count}" value="${fn:length(confArquivo.itens)}" />
                                        </td>
                                        <td>${fn:length(confArquivo.itens)}</td>
                                    </tr>
                                    <tbody id="bodycoletor_${status.count}" style="display:none">
                                        <c:forEach items="${confArquivo.itens}" varStatus="statusItensColetor" var="item">
                                            <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1NoAlign' : 'CelulaZebra1NoAlign')}" >
                                                <td class="TextoCampos" width="10px"><!--Imagens de confirmado ou não -->
                                                    <img src="img/x.png" align="middle" id="coletonaoConfere_${statusItensColetor.count}" style="display:none" name="coletonaoConfere_${statusItensColetor.count}" width="20px" height="20px" alt="Não confere!">
                                                    <img src="img/v.png" align="middle" id="coletoConfere_${statusItensColetor.count}" style="display:none" name="coletoConfere_${statusItensColetor.count}" width="20px" height="20px" alt="confere!">
                                                </td>
                                                <c:forEach items="${item.campos}"  var="campo">
                                                    <td class="TextoCampos">
                                                        <label id="${campo.descricao}_${status.count}_${status.count}">${campo.valor}</label>
                                                        <input type="hidden" id="campoColetor_${status.count}_${statusItensColetor.count}" name="campoColetor_${status.count}_${statusItensColetor.count}" value="${campo.valor}">
                                                    </td>
                                                </c:forEach>
                                            </tr>                 
                                        </c:forEach>
                                    </tbody>
                                </c:forEach>
                                <!--Fim da visualização do arquivo do coletor-->
                            </table>
                        </div>
                    </td>
                </tr>                
            </table>
            </form>
            <table width="90%" align="center" class="bordaFina">
                <tr id="trMobly" style="display: none">
                    <td width="50%" style="vertical-align:top;">
                        <table width="100%" align="center" class="bordaFina">
                            <tbody>
                                <tr class="tabela">
                                    <td>
                                        Dados da Carga                                        
                                    </td>
                                </tr>                                
                            </tbody>
                        </table>
                        <table width="100%" align="center" class="bordaFina">
                            <tbody id="testeCarga">
                                <tr class="CelulaZebra1">
                                    <td width="15%">
                                        <b>CT-e</b>
                                    </td>
                                    <td width="50%">
                                        <b>Destinatário</b>
                                    </td>
                                    <td width="15%">
                                        <b>Nota</b>
                                    </td>
                                    <td width="10%">
                                        <b>Vol(s)</b>
                                    </td>
                                    <td width="5%"></td>
                                    <td width="5%"></td>
                                </tr>
                            </tbody>
                        </table>
                        <table width="100%" align="center" class="bordaFina">
                            <input type="hidden" id="maxCte" name="maxCte" value="0"/>
                            <tbody>
                                <tr class="CelulaZebra1NoAlign" id="trTotalVolumes">
                                    <td align="right" width="15%"><b>Total Volume:</b></td>
                                    <td width="15%" align="left">
                                        <input type="hidden" id="volumeTotal" name="volumeTotal" value="0"/>
                                        <label id="totalVolume"></label>
                                    </td>
                                    <td align="right" width="20%"><b>Total Conferido:</b></td>
                                    <td width="15%" align="left">
                                        <input type="hidden" id="conferidoTotal" name="conferidoTotal" value="0"/>
                                        <label id="totalConferido"></label>
                                    </td>
                                    <td align="right" width="15%"><b>Diferença:</b></td>
                                    <td width="20%" align="left">
                                        <input type="hidden" id="hidDiferenca" name="hidDiferenca" value="0"/>
                                        <label id="diferenca"></label>                                        
                                    </td>
                                </tr>                                
                                <tr class="CelulaZebra1NoAlign" id="trTotalNotas" style="display: 'none' ">
                                    <td align="right" width="15%"><b>Total Notas:</b></td>
                                    <td width="15%" align="left">
                                        <input type="hidden" id="volumeTotalNotas" name="volumeTotalNotas" value="0"/>
                                        <label id="totalVolumeNotas"></label>
                                    </td>
                                    <td align="right" width="20%"><b>Total Conferido:</b></td>
                                    <td width="15%" align="left">
                                        <input type="hidden" id="conferidoTotalNotas" name="conferidoTotalNotas" value="0"/>
                                        <label id="totalConferidoNotas"></label>
                                    </td>
                                    <td align="right" width="15%"><b>Diferença:</b></td>
                                    <td width="20%" align="left">
                                        <input type="hidden" id="hidDiferencaNotas" name="hidDiferencaNotas" value="0"/>
                                        <label id="diferencaNotas"></label>                                        
                                    </td>
                                </tr>                                
                            </tbody>
                        </table>
                        <table class="bordaFina" width="100%" align="center" id="tableImpressora">
                            <tr class="CelulaZebra1NoAlign">
                                <td>
                                    Driver:
                                </td>
                                <td>
                                    <select class="inputTexto" id="driverImpressora"  style="max-width: 200px;">
                                        <c:forEach items="${driversMAN}" var="m">
                                            <option value="${m}">${m}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td>
                                    Impressora:
                                </td>
                                <td>
                                    <select class="inputTexto" id="caminho_impressora" style="max-width: 200px;">
                                        <c:forEach items="${impressoras}" var="imp">
                                            <option value="${imp}">${imp}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td width="50%" style="vertical-align:top;">
                        <table width="100%" align="center" class="bordaFina">
                            <tbody>
                                <tr class="tabela">                                    
                                    <td align="right">
                                        Código de Barras:
                                    </td>
                                    <td align="left">
                                        <input type="text" ${param.codigoBarrasNf == '4' ? 'class="inputtexto"' : ' class="inputReadOnly8pt" '} id="codigoBarras" name="codigoBarras" size="40" maxlength="50" onKeyUp="codigoBarras(this);javascript:if (event.keyCode==13) $('pesquisar').click();" />
                                        <input type="button" id="pesquisar" name="pesquisar" class="botoes" value=" Pesquisar " onclick="javascript:tryRequestToServer(function(){getBipagem();});"/>
                                    </td>
                                    <td>
                                        <c:if test="${param['codigoBarrasNf'] eq '4'}">
                                            <input type="file" name="file" id="txtFileToRead" style="width:0.1px; height:0.1px; float: left;">
                                            <label for="txtFileToRead" class="botoes" style="font-weight: normal; padding: 0 10px;">Importar</label>
                                        </c:if>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <table width="100%" align="center" id="conteudo" class="bordaFina">
                            <tbody id="tbColetor">
                            <div id="div_coletor">
                                
                            </div>
                                <tr class="CelulaZebra1">
                                    <td width="30%">
                                       <b>Código</b>
                                    </td>
                                    <td width="60%">                                        
                                       <b>Usuário</b> 
                                    </td>
                                    <td width="10%"></td>                                    
                                </tr>
                            </tbody>
                        </table>
                        <table width="100%" align="center" class="bordaFina" id="tbBipagemVolume">
                            <tbody>
                                <tr class="CelulaZebra1NoAlign">
                                    <td align="right" width="20%"><b>Total Bipagem:</b></td>
                                    <td width="80%" align="left">
                                        <input type="hidden" id="bipagemTotal" name="bipagemTotal" value="0"/>
                                        <label id="totalBipagem"></label>
                                    </td>
                                </tr>                                
                            </tbody>
                        </table>
                        <table width="100%" align="center" class="bordaFina" id="tbBipagemNotas">
                            <tbody>
                                <tr class="CelulaZebra1NoAlign">
                                    <td align="right" width="30%"><b>Total Bipagem de Notas:</b></td>
                                    <td width="70%" align="left">
                                        <input type="hidden" id="bipagemTotalNotas" name="bipagemTotalNotas" value="0"/>
                                        <label id="totalBipagemNotas"></label>
                                    </td>
                                </tr>                                
                            </tbody>
                        </table>
                    </td>
                </tr>
            </table>
            <table width="90%" align="center" class="bordaFina">
                <tr class="CelulaZebra1NoAlign  ">
                    <td width="15%" class="CelulaZebra2NoAlign" style="text-align: center;">
                        <input type="checkbox" name="chkConfFinalizada" id="chkConfFinalizada" ${param.acao == 'importarArquivo' && param.isFinalizada == 'true' ? 'checked':''} style="margin: 0;">
                        <label for="chkConfFinalizada" style="line-height: 11px;margin-left: 2px;">Conferência finalizada</label>
                    </td>
                    <td width="10%" class="TextoCampos">
                        <label>Data de Chegada:</label>
                    </td>
                    <td width="15%" class="celulaZebra2">
                        <input name="dtchegada" type="text" id="dtchegada" size="10" style="font-size:8pt;width: 66px;" maxlength="10" value="${param.acao == 'importarArquivo' && param.isFinalizada ? param.dtChegada : ''}" onblur="alertInvalidDate(this);validarDataAtual(this);" class="fieldDate" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                        <label> às </label>
                        <input name="hrChegada" id="hrChegada" class="fieldMin" type="text" size="5" maxlength="5" value="${param.acao == 'importarArquivo' && param.isFinalizada ? param.hrChegada : ''}" onkeyup="mascaraHora(this)">
                    </td>
                    <td width="10%" class="TextoCampos">
                        <label>Ocorrência:</label>
                    </td>
                    <td width="50%" class="celulaZebra2">
                        <input type="text" id="codigoOcorrencia" name="codigoOcorrencia" class="inputReadOnly" size="5" value="${param.acao == 'importarArquivo' && param.isFinalizada ? param.codigoOcorrencia : ''}" readonly/>
                        <input type="text" id="descricaoOcorrencia" name="descricaoOcorrencia" class="inputReadOnly" size="25" value="${param.acao == 'importarArquivo' && param.isFinalizada ? param.descricaoOcorrencia : ''}" readonly/>
                        <input type="hidden" id="idOcorrencia" name="idOcorrencia" value="0"/>
                        <input type="button" id="btnLocalizarOcorrencia" name="btnLocalizarOcorrencia" value="..." class="inputbotao" title="Localizar Ocorrência" onclick="javascript:tryRequestToServer(function(){abrirLocalizaOcorrencia()});"/>
                    </td>
                </tr>
                <tr class="CelulaZebra1NoAlign" style="${param.acao == 'importarArquivo' && param.isFinalizada == 'true' ? '':'display:none;'}">
                    <td class="TextoCampos">
                        Usuario Finalização:
                    </td>
                    <td class="celulaZebra2" style="font-weight: bold;">
                        ${param.usuarioFinalizacao}
                    </td>
                    <td class="TextoCampos">
                        Data Finalização:
                    </td>
                    <td class="celulaZebra2" colspan="2">
                        ${param.dataFinalizacao} às ${param.horaFinalizacao}
                    </td>
                </tr>
            </table>
            <br/>
            <table width="90%" align="center" class="bordaFina">
                <tr class="CelulaZebra2NoAlign">  
                    <td width="70%">
                        <input name="btImportar" id="btImportar" type="button" class="botoes" value=" Importar " onclick="javascript:tryRequestToServer(function(){importar();});" style="display: none"/>
                        <form action="" id="formAtualizar" name="formAtualizar" method="post" >
                            <input name="btAtualizar" id="btAtualizar" type="button" class="botoes" value=" Atualizar " onclick="javascript:tryRequestToServer(function(){atualizar();});" style="display: "/>                            
                        </form>
                    </td>                                
                </tr>
            </table>
<!--        <table width="90%" align="center" class="bordaFina">
            <tr class="CelulaZebra2NoAlign"> 
                <td width="10%"> </td>
            </tr>
        </table>-->
    </body>
</html>