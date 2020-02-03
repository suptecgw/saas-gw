<%-- 
    Document   : importar_conferencia_romaneio
    Created on : 21/03/2016, 11:43:23
    Author     : paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<script language="JavaScript" type="text/javascript" src="script/funcoes.js" ></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="JavaScript" type="text/javascript" src="script/prototype.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/ie.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript" type="text/javascript" src="script/mascaras.js"></script>
<script language="JavaScript" type="text/javascript">
    
    jQuery.noConflict();
    
    var idUsuario;
    var nomeUsuario;
    
    function fechar(){
        window.close();
    }
    
    window.onbeforeunload = function(){
        sessionStorage.clear();
    };
    
    function atualizar(){
                
        var form = $("formAtualizar");
        var idRomaneio = $("idRomaneio").value;
        var tipoOperacao = $("tipoOperacao").value;
        var layoutGwTrans = $("gwTrans").checked;        
        var layout = "";
        if (layoutGwTrans == true) {
            layout = "t";
        }else{
            layout = "m";            
        }
        
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
        
        form.action = "ConferenciaControlador?acao=importarArquivoRomaneio&idRomaneio="+idRomaneio+"&tipo_operacao="+tipoOperacao+"&layout="+layout+
        (isConfFinalizada ? "&dtChegada="+dtChegada+"&hrChegada="+hrChegada+"&idOcorrencia="+
        idOcorrencia+"&descricaoOcorrencia="+descricaoOcorrencia+"&codigoOcorrencia="+codigoOcorrencia+"&isFinalizada=true" : "");
        form.submit();

    }
    
    function carregar(){
        
        var carga = null;
        var totalVolume = 0;
        var coletor = null;    
        
        <c:forEach var="cte" varStatus="status" items="${listaCte}">

            <c:forEach var="nota" varStatus="status" items="${cte.notas}">
                carga = new DadosCarga();

                carga.idCte = '${cte.id}';
                carga.numeroCte = '${cte.numero}';
                carga.idDestinatario = '${cte.destinatario.idcliente}';
                carga.nomeDestinatario = '${cte.destinatario.razaosocial}';
                carga.idNota = '${nota.idnotafiscal}';
                carga.numeroNota = '${nota.numero}';                        

                <c:forEach var="cub" varStatus="status" items="${nota.cubagensNotaFiscal}">

                    carga.etiqueta += "," + '${cub.etiqueta}';
                    <c:if test="${status.last}">
                        carga.volume = parseInt('${status.count}');
                    </c:if>                            

                </c:forEach>

                totalVolume = totalVolume + carga.volume;

                addCarga(carga);

            </c:forEach>

        </c:forEach>
                    
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
        
        if (${param.layout == 'm'}) {
            $("mobly").checked = true;
        }else if (${param.layout == 't'}) {
            $("gwTrans").checked = true;    
        }
        
        atualizarDiferenca();
        
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
    
    function DadosColetor(idColetor, idCte, idUsuario, nomeUsuario, codigo, isExiste, mensagem){
        this.idColetor = (idColetor != null && idColetor != undefined ? idColetor : 0);
        this.idCte = (idCte != null && idCte != undefined ? idCte : 0);
        this.idUsuario = (idUsuario != null && idUsuario != undefined ? idUsuario : 0);
        this.nomeUsuario = (nomeUsuario != null && nomeUsuario != undefined ? nomeUsuario : "");
        this.codigo = (codigo != null && codigo != undefined ? codigo : 0);                
        this.isExiste = (isExiste != null && isExiste != undefined ? isExiste : false);                
        this.mensagem = (mensagem != null && mensagem != undefined ? mensagem : "");        
    }
            
    function DadosCarga(idCte, numeroCte, idDestinatario, nomeDestinatario, idNota, numeroNota, volume, etiqueta){
        this.idCte = (idCte != null && idCte != undefined ? idCte : 0);
        this.numeroCte = (numeroCte != null && numeroCte != undefined ? numeroCte : 0);
        this.idDestinatario = (idDestinatario != null && idDestinatario != undefined ? idDestinatario : 0);
        this.nomeDestinatario = (nomeDestinatario != null && nomeDestinatario != undefined ? nomeDestinatario : "");
        this.idNota = (idNota != null && idNota != undefined ? idNota : 0);
        this.numeroNota = (numeroNota != null && numeroNota != undefined ? numeroNota : 0);
        this.volume = (volume != null && volume != undefined ? volume : 0);                
        this.etiqueta = (etiqueta != null && etiqueta != undefined ? etiqueta : "");                
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

        var _lblVolumeDinamico = Builder.node("label",{
            id:"lblVolumeDinamico_"+countCarga,
            name:"lblVolumeDinamico_"+countCarga
        });
        _lblVolumeDinamico.innerHTML = "0";

        var _lblVolumeFixo = Builder.node("label",{
            id:"lblVolumeFixo_"+countCarga,
            name:"lblVolumeFixo_"+countCarga
        });                
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
                
        _divConferencia.appendChild(_imgCancelar);
        _divConferencia.appendChild(_imgOk);
        _divConferencia.appendChild(_inpEtiqueta);
        _divConferencia.appendChild(_inpQtdEtiqueta);                

        _tdCte.appendChild(_inpIdCte);
        _tdCte.appendChild(_lblNumeroCte);
        _tdDestinatario.appendChild(_inpIdDestinatario);                
        _tdDestinatario.appendChild(_lblNomeDestinatario);
        _tdNumeroNota.appendChild(_lblNumeroNota);
        _tdVolume.appendChild(_inpVolumeDinamico);
        _tdVolume.appendChild(_lblVolumeDinamico);
        _tdVolume.appendChild(_lblVolumeFixo);
        _tdConferencia.appendChild(_divConferencia);


        _trCarga.appendChild(_tdCte);
        _trCarga.appendChild(_tdDestinatario);
        _trCarga.appendChild(_tdNumeroNota);
        _trCarga.appendChild(_tdVolume);
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
        if(coletor.idColetor > 0){
            sessionStorage.setItem(coletor.codigo,countColetor);
        }
        
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

        _tdCodigo.appendChild(_lblCodigo);
        _tdCodigo.appendChild(_inpIdColetor);
        _tdCodigo.appendChild(_isExisteColetor);
        _tdUsuario.appendChild(_lblUsuario);
        _tdUsuario.appendChild(_inpIdUsuario);
        _tdExcluir.appendChild(_divExcluir);

        _trColetor.appendChild(_tdCodigo);
        _trColetor.appendChild(_tdUsuario);
        _trColetor.appendChild(_tdExcluir);               

        jQuery("#tbColetor").after(_trColetor);
    }
    
    function getBipagem(){
        
        var codigoBarras = $("codigoBarras").value;
        var maxCte = $("maxCte").value;
        var idsCte = "0";
        var idManifesto = 0;
        var idRomaneio = $("idRomaneio").value;
        var tipoOperacao = $("tipoOperacao").value;
        var isExiste = (sessionStorage.getItem(codigoBarras) != null && ($("isExiste_"+sessionStorage.getItem(codigoBarras)) != null) ? ($("isExiste_"+sessionStorage.getItem(codigoBarras)).value) : "");
        for (var qtdCte = 1; qtdCte <= maxCte; qtdCte++) {
            if($("inpIdCte_"+qtdCte) != null){
                idsCte += "," + $("inpIdCte_"+qtdCte).value;
            }
        }

        if (codigoBarras == "") {
            showErro("Informe o código de barras",$("codigoBarras"));
            return false;
        }
        
        var cltr = new DadosColetor();
        
        if (sessionStorage.getItem(codigoBarras) != undefined  && $("idColetor_"+sessionStorage.getItem(codigoBarras)) != null
                && (isExiste =='t' || isExiste == 'true')) {
            cltr.idColetor = "0";
            cltr.idUsuario = "0";
            cltr.nomeUsuario = "Código de barras já importado!";
            cltr.idCte = "0";
            cltr.codigo = codigoBarras;            
            addColetor(cltr);
            $("codigoBarras").value = '';
            
        }else{
            jQuery.ajax({
                url: '<c:url value="/ConferenciaControlador" />',
                dataType: "text",
                method: "post",
                data: {
                    idUsuario : idUsuario,
                    tipoOperacao : tipoOperacao,
                    idRomaneio : idRomaneio,
                    idManifesto : idManifesto,
                idsCte: idsCte,
                codigoBarras: codigoBarras,
                idColetor: ($("idColetor_"+sessionStorage.getItem(codigoBarras))!= null ? $("idColetor_"+sessionStorage.getItem(codigoBarras)).value : '0'),
                tipo: "volume",
                acao: "getBipagem"
            },
            success: function (data) {

                    var conf = JSON.parse(data);

                    var coletor = new DadosColetor();

                    if (conf != null && conf != undefined && conf.null != "") {

                        if (conf.travarConferencia) {
                            alert(conf.mensagem);
                        } else {
                            if (conf.Conferencia.id != 0 && conf.Conferencia.beanConhecimento != null && conf.Conferencia.beanConhecimento.nota != null) {
                                coletor.idColetor = conf.Conferencia.id;
                                coletor.idUsuario = idUsuario;
                                coletor.nomeUsuario = nomeUsuario;
                                coletor.idCte = conf.Conferencia.beanConhecimento.id;
                                //coletor.codigo = conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0]["conhecimento.orcamento.Cubagem"].etiqueta;
                                if (conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0]["conhecimento.orcamento.Cubagem"]) {
                                    coletor.codigo = conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0]["conhecimento.orcamento.Cubagem"].etiqueta;
                                } else {
                                    coletor.codigo = conf.Conferencia.beanConhecimento.nota.cubagensNotaFiscal[0].cubagem.etiqueta;
                                }
                                coletor.isExiste = true;
                            } else {
                                coletor.idUsuario = 0;
                                coletor.nomeUsuario = (conf.Conferencia.mensagem != undefined && conf.Conferencia.mensagem != null && conf.Conferencia.mensagem != "" ? conf.Conferencia.mensagem : conf.Conferencia.mensagemRetorno);
                                coletor.codigo = codigoBarras;
                                coletor.isExiste = false;
                            }
                        }

                    } else {
                        coletor.idUsuario = 0;
                        coletor.nomeUsuario = "Código de barras não pertence a esse romaneio";
                        coletor.codigo = codigoBarras;
                    }

                    addColetor(coletor);

                    if (coletor.idUsuario != 0) {
                        atualizarConferencia(coletor);
                    } else {
                        alert("Atenção: " + coletor.nomeUsuario);  
                    }

                    $("codigoBarras").value = "";
                }
            });
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
                                atualizarConferenciaExcluir($("lblCodigo_"+index).innerHTML);
                                if ($("lblCodigo_"+index)) {
                                    sessionStorage.removeItem($("lblCodigo_"+index).innerHTML);
                                }
                                Element.remove($("trColetor_"+index));
                                espereEnviar("Aguarde...",false);

                            }
                        });
                        } else{
                        if (idColetor != 0 && $("lblCodigo_"+index)) {
                            sessionStorage.removeItem($("lblCodigo_" + index).innerHTML);
                            }
                            Element.remove($("trColetor_" + index));
                            espereEnviar("Aguarde...", false);
                        }
                } else {
                    alert("Atenção! Você não possui privilégios suficientes para executar esta ação!");
                }
            }
        }
    
    function atualizarConferencia(etiqueta){
        var maxCte = $("maxCte").value;
        var etiquetas = "";

        for (var qtdCte = 1; qtdCte <= maxCte; qtdCte++) {                    
            if ($("etiqueta_"+qtdCte) != null && $("etiqueta_"+qtdCte).value != "") {
                etiquetas = $("etiqueta_"+qtdCte).value;
                for (var qtdEti = 0; qtdEti < etiquetas.split(",").length; qtdEti++) {
                    if(etiquetas.split(",")[qtdEti] == etiqueta.codigo && (etiqueta.isExiste =='t' || etiqueta.isExiste == 'true' || etiqueta.isExiste == true)){                                
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
        }

        $("totalConferido").innerHTML = $("conferidoTotal").value;
        $("bipagemTotal").value = $("conferidoTotal").value;
        $("totalBipagem").innerHTML = $("bipagemTotal").value;

        atualizarDiferenca();
    }
    
    function visualizarNota(idNotaFiscal) {                
        window.open("NotaFiscalControlador?acao=carregar&idNota=" + idNotaFiscal + "&visualizar=true","visualizarNota", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
    }
    
    function atualizarDiferenca(){        
        $("hidDiferenca").value = $("conferidoTotal").value - $("volumeTotal").value;
        $("diferenca").innerHTML = $("hidDiferenca").value;
    }
    
    function atualizarConferenciaExcluir(etiqueta){
        var maxCte = $("maxCte").value;
        var etiquetas = "";
        var isExiste = $("isExiste_"+sessionStorage.getItem(etiqueta)).value;
        for (var qtdCte = 1; qtdCte <= maxCte; qtdCte++) {                    
            if ($("etiqueta_"+qtdCte) != null && $("etiqueta_"+qtdCte).value != "") {
                etiquetas = $("etiqueta_"+qtdCte).value;
                for (var qtdEti = 0; qtdEti < etiquetas.split(",").length; qtdEti++) {
                    if(etiquetas.split(",")[qtdEti] == etiqueta && (isExiste =='f' || isExiste == 'false')){                                
                       $("qtdEtiqueta_"+qtdCte).value += 1;
                       $("conferidoTotal").value = parseInt($("conferidoTotal").value) - 1;
                       $("volumeDinamico_"+qtdCte).value = parseInt($("volumeDinamico_"+qtdCte).value) - 1;
                       $("lblVolumeDinamico_"+qtdCte).innerHTML = $("volumeDinamico_"+qtdCte).value;
                    }
                }
            }
            if ($("qtdEtiqueta_"+qtdCte).value > 0 && $("etiqueta_"+qtdCte).value != "" && (isExiste =='f' || isExiste == 'false')) {                        
                $("imgOk_"+qtdCte).style.display = "none";
                $("imgCancelar_"+qtdCte).style.display = "";
            }
        }

        $("totalConferido").innerHTML = $("conferidoTotal").value;
        $("bipagemTotal").value = $("conferidoTotal").value;
        $("totalBipagem").innerHTML = $("bipagemTotal").value;

        atualizarDiferenca();
    }
    
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
                        'romaneio_id': $("idRomaneio").value,
                        'manifesto_id': 0,
                        'tipo_operacao': $("tipoOperacao").value === '1' ? 's' : 'e',
                        'tipo_codigo': "volume",
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

                                        if (conf.beanConhecimento.nota.cubagensNotaFiscal[0] !== undefined) {
                                            coletor.codigo = conf.beanConhecimento.nota.cubagensNotaFiscal[0].etiqueta;
                                        } else {
                                            coletor.codigo = conf.beanConhecimento.nota.cubagensNotaFiscal[0].cubagem.etiqueta;
                                        }

                                        coletor.idCte = conf.beanConhecimento.id;
                                        coletor.isExiste = true;
                                    } else {
                                        coletor.idUsuario = 0;
                                        coletor.nomeUsuario = (conf.mensagem !== undefined && conf.mensagem !== "" ? conf.mensagem : conf.mensagemRetorno);
                                        coletor.codigo = conf.codigoBarras;
                                        coletor.isExiste = false;
                                    }

                                } else {
                                    coletor.idUsuario = 0;
                                    coletor.nomeUsuario = "Código de barras não pertence a esse romaneio";
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
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <title> Importar conferência (Romaneio) </title>
    </head>
    <body onload="carregar();">
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
        <!--<form id="formAtualizar" name="formAtualizar" method="POST">-->
            <table width="90%" align="center" class="bordaFina">
                <tr class="tabela">
                    <td colspan="15"> Romaneio  </td>
                </tr>
                <tr>
                    <td  width="8%" class="TextoCampos" >Número: </td>
                    <td  width="8%" class="celulaZebra2" >
                        <label id="lbNumeroRomaneio">  ${param.numeroRomaneio} </label>
                        <input type="hidden" name="idRomaneio" id="idRomaneio" value="${param.idRomaneio}" />
                        <input type="hidden" name="caminhoArquivo" id="caminhoArquivo" value="${caminhoArquivo}" />
                        <input type="hidden" name="tipoOperacao" id="tipoOperacao" value="${param.tipo_operacao}" />
                        <input type="hidden" name="conteudos" id="conteudos" value="${param.conteudos}" />
                        <input type="hidden" name="idColetor" id="idColetor" value="${param.idColetor}" />
                        <input type="hidden" name="idConferencia" id="idConferencia" value="${conferencia.id}" />
                        <input type="hidden" name="numeroRomaneio" id="numeroRomaneio" value="${param.numeroRomaneio}" />
                        <input type="hidden" name="qtdArquivosCliente" id="qtdArquivosCliente" value="${fn:length(conferencia.arquivosCliente)}"/>
                        <input type="hidden" name="qtdArquivosColetor" id="qtdArquivosColetor" value="${fn:length(conferencia.arquivosColetor)}" />
                        <input type="hidden" name="desDriver" id="desDriver" value="${param.idDriverCliente}" />
                        <input type="hidden" name="itens" id="itens" value="${param.itens}" />
                        <input type="hidden" id="ocorrencia_id" value="0">
                        <input type="hidden" id="ocorrencia" value="">
                        <input type="hidden" id="descricao_ocorrencia" value="">
                    </td>
                    <td width="8%" class="TextoCampos" >
                        Origem: 
                    </td>
                    <td class="CelulaZebra2" width="14%">
                        <label id="origem"> ${param.cidadeOrigem} </label>
                    </td>
                    <td class="TextoCampos" width="8%">
                        UF: 
                    </td>
                    <td class="CelulaZebra2" width="4%">
                        <label id="ufOrigem">  ${param.ufOrigem} </label>
                    </td>

                    <td class="textoCampos" width="8%">
                        Destino: 
                    </td>
                    <td class="CelulaZebra2" width="14%">
                        <label id="destino"> ${param.cidadeDestino} </label>
                    </td>
                    <td class="TextoCampos" width="8%">
                        UF: 
                    </td>
                    <td class="CelulaZebra2" width="4%">
                        <label id="ufDestino"> ${param.ufDestino}</label>
                    </td>

                    <td class="textoCampos" width="5%">
                        Data: 
                    </td>
                    <td class="CelulaZebra2" width="9%">
                        <label id="data">
                            ${param.dataEmissao}
                        </label>
                    </td>
                </tr>
                <tr class="tabela">                    
                    <td colspan="15">Layout</td>
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td colspan="2">
                        <label>
                            <input type="radio" id="gwTrans" name="layout" value="t" onclick="" checked/>
                            GWTrans
                        </label>                        
                    </td>
                    <td colspan="2">
                        <label>
                            <input type="radio" id="mobly" name="layout" value="m" onclick=""/>
                            Mobly
                        </label>                        
                    </td>
                    <td colspan="8"></td>
                </tr>
            </table>
            <table width="90%" align="center" class="bordaFina">
                <tr id="trMobly" style="display: ">
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
                                    <td width="10%"></td>
                                </tr>
                            </tbody>
                        </table>
                        <table width="100%" align="center" class="bordaFina">
                            <input type="hidden" id="maxCte" name="maxCte" value="0"/>
                            <tbody>
                                <tr class="CelulaZebra1NoAlign">
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
                            </tbody>
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
                                        <input type="text" class="inputtexto" id="codigoBarras" name="codigoBarras" size="40" maxlength="50" onKeyUp="codigoBarras(this);javascript:if (event.keyCode==13) $('pesquisar').click();" />
                                        <input type="button" id="pesquisar" name="pesquisar" class="botoes" value=" Pesquisar " onclick="javascript:tryRequestToServer(function(){getBipagem();});"/>
                                    </td>
                                    <td>
                                        <input type="file" name="file" id="txtFileToRead" style="width:0.1px; height:0.1px; float: left;">
                                        <label for="txtFileToRead" class="botoes" style="font-weight: normal; padding: 0 10px;">Importar</label>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <table width="100%" align="center" class="bordaFina">
                            <tbody id="tbColetor">
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
                        <table width="100%" align="center" class="bordaFina">
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
                    </td>
                </tr>
            </table>
            <table width="90%" align="center" class="bordaFina">
                <tr class="CelulaZebra1NoAlign  ">
                    <td width="15%" class="CelulaZebra2NoAlign" style="text-align: center;">
                        <input type="checkbox" name="chkConfFinalizada" id="chkConfFinalizada" ${param.acao == 'importarArquivoRomaneio' && param.isFinalizada == 'true' ? 'checked':''} style="margin: 0;">
                        <label for="chkConfFinalizada" style="line-height: 11px;margin-left: 2px;">Conferência finalizada</label>
                    </td>
                    <td width="10%" class="TextoCampos">
                        <label>Data de Chegada:</label>
                    </td>
                    <td width="15%" class="celulaZebra2">
                        <input name="dtchegada" type="text" id="dtchegada" size="10" style="font-size:8pt;width: 66px;" maxlength="10" value="${param.acao == 'importarArquivoRomaneio' && param.isFinalizada ? param.dtChegada : ''}" onblur="alertInvalidDate(this);validarDataAtual(this);" class="fieldDate" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)">
                        <label> às </label>
                        <input name="hrChegada" id="hrChegada" class="fieldMin" type="text" size="5" maxlength="5" value="${param.acao == 'importarArquivoRomaneio' && param.isFinalizada ? param.hrChegada : ''}" onkeyup="mascaraHora(this)">
                    </td>
                    <td width="10%" class="TextoCampos">
                        <label>Ocorrência:</label>
                    </td>
                    <td width="50%" class="celulaZebra2">
                        <input type="text" id="codigoOcorrencia" name="codigoOcorrencia" class="inputReadOnly" size="5" value="${param.acao == 'importarArquivoRomaneio' && param.isFinalizada ? param.codigoOcorrencia : ''}" readonly/>
                        <input type="text" id="descricaoOcorrencia" name="descricaoOcorrencia" class="inputReadOnly" size="25" value="${param.acao == 'importarArquivoRomaneio' && param.isFinalizada ? param.descricaoOcorrencia : ''}" readonly/>
                        <input type="hidden" id="idOcorrencia" name="idOcorrencia" value="0"/>
                        <input type="button" id="btnLocalizarOcorrencia" name="btnLocalizarOcorrencia" value="..." class="inputbotao" title="Localizar Ocorrência" onclick="javascript:tryRequestToServer(function(){abrirLocalizaOcorrencia()});"/>
                    </td>
                </tr>
                <tr class="CelulaZebra1NoAlign" style="${param.acao == 'importarArquivoRomaneio' && param.isFinalizada == 'true' ? '':'display:none;'}">
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
                        <form action="" id="formAtualizar" name="formAtualizar" method="post" >
                            <input name="btAtualizar" id="btAtualizar" type="button" class="botoes" value=" Atualizar " onclick="javascript:tryRequestToServer(function(){atualizar();});" style="display: "/>                            
                        </form>                        
                    </td>                                
                </tr>
            </table>
        <!--</form>-->
    </body>
</html>
