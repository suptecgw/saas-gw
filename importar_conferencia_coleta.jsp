<%-- 
    Document   : importar_conferencia_coleta
    Created on : 14/06/2016, 14:18:49
    Author     : paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="pt-BR" />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<script language="JavaScript" type="text/javascript" src="script/funcoes.js" ></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="JavaScript" type="text/javascript" src="script/prototype.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/ie.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
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
        var idColeta = $("idColeta").value;
        var tipoOperacao = $("tipoOperacao").value;
        form.action = "ConferenciaControlador?acao=importarArquivoColeta&idColeta="+idColeta+"&tipoOperacao="+tipoOperacao;
        form.submit();

    }
    
    function carregar(){
        
        var carga = null;
        var totalVolume = 0;
        var coletor = null;
        
        <c:forEach var="coleta" varStatus="status" items="${listaColeta}">
            carga = new DadosCarga();
            
            carga.idColeta = '${coleta.id}';
            carga.numeroColeta = '${coleta.numero}';
            carga.idDestinatario = '${coleta.destinatario.idcliente}';
            carga.nomeDestinatario = '${coleta.destinatario.razaosocial}';                

            <c:forEach var="conf" varStatus="status" items="${coleta.conferencias}">

                carga.etiqueta += "," + '${conf.codigoBarras}';
                <c:if test="${status.last}">
                    carga.volume = parseInt('${status.count}');
                </c:if>

            </c:forEach>                

            totalVolume = totalVolume + carga.volume;

            addCarga(carga);
                
        </c:forEach>
            
        <c:forEach var="coletor" varStatus="status" items="${listaColetorManRom}">
            
            coletor = new DadosColetor();

            coletor.idColetor = '${coletor.id}';
            coletor.idColeta = '${coletor.coleta.id}';
            coletor.idUsuario = '${coletor.usuario.idusuario}';
            coletor.nomeUsuario = '${coletor.usuario.nome}';
            coletor.codigo = '${coletor.etiqueta}';                    

            addColetor(coletor);

            atualizarConferencia(coletor.codigo);

        </c:forEach>
            
        idUsuario = '<c:out value="${param.idUsuario}"/>';
        nomeUsuario = '<c:out value="${param.nomeUsuario}"/>';
        
        $("volumeTotal").value = totalVolume;    
        $("totalVolume").innerHTML = totalVolume;
        
        atualizarDiferenca();
    }
    
    function getBipagem(){
        
        var codigoBarras = $("codigoBarras").value;
        var maxColeta = $("maxColeta").value;
        var idsColeta = "0";
        var idColeta = $("idColeta").value;
        var tipoOperacao = $("tipoOperacao").value;
                
        for (var qtdColeta = 1; qtdColeta <= maxColeta; qtdColeta++) {
            if($("inpIdColeta_"+qtdColeta) != null){
                idsColeta += "," + $("inpIdColeta_"+qtdColeta).value;
            }
        }

        if (codigoBarras == "") {
            showErro("Informe o código de barras",$("codigoBarras"));
            return false;
        }
        
        var cltr = new DadosColetor();
        
        if (sessionStorage.getItem(codigoBarras) != undefined) {
                cltr = new DadosColetor();
                cltr.idColetor = "0";
                cltr.idCte = "0";
                cltr.idUsuario = "0";
                cltr.nomeUsuario = "Código de barras já importado!";
                cltr.codigo = codigoBarras;
                addColetor(cltr);
        }else {
            jQuery.ajax({
                url: '<c:url value="/ConferenciaControlador" />',
                dataType: "text",
                method: "post",
                data: {
                    idUsuario : idUsuario,
                    tipoOperacao : tipoOperacao,               
                    idColeta : idColeta,
                idsCte: idsColeta,
                codigoBarras: codigoBarras,
                acao: "getBipagemColeta"
            },
            success: function (data) {

                    var conf = JSON.parse(data);

                    console.log(conf);

                    var coletor = new DadosColetor();

                    if (conf != null && conf != undefined && conf.null != "") {

                        if (conf.Conferencia.id != 0) {
                            coletor.idColetor = conf.Conferencia.id;
                            coletor.idUsuario = idUsuario;
                            coletor.nomeUsuario = nomeUsuario;
                            coletor.idColeta = conf.Conferencia.coleta.id;
                            coletor.codigo = conf.Conferencia.codigoBarras;

                        } else {
                            coletor.idUsuario = 0;
                            coletor.nomeUsuario = conf.Conferencia.mensagemRetorno;
                            coletor.codigo = codigoBarras;
                        }

                    } else {
                        coletor.idUsuario = 0;
                        coletor.nomeUsuario = "Código de barras não pertence a essa coleta";
                        coletor.codigo = codigoBarras;
                    }

                    addColetor(coletor);

                    if (coletor.idUsuario != 0) {
                        atualizarConferencia(coletor.codigo);
                    } else {
                        alert("Atenção: " + coletor.nomeUsuario);
                    }

                    $("codigoBarras").value = "";
                }
            });
        }
    }
    
    function DadosColetor(idColetor, idColeta, idUsuario, nomeUsuario, codigo){
        this.idColetor = (idColetor != null || idColetor != undefined ? idColetor : 0);
        this.idColeta = (idColeta != null || idColeta != undefined ? idColeta : 0);
        this.idUsuario = (idUsuario != null || idUsuario != undefined ? idUsuario : 0);
        this.nomeUsuario = (nomeUsuario != null || nomeUsuario != undefined ? nomeUsuario : "");
        this.codigo = (codigo != null || codigo != undefined ? codigo : 0);                
    }
            
    function DadosCarga(idColeta, numeroColeta, idDestinatario, nomeDestinatario, volume, etiqueta){
        this.idColeta = (idColeta != null || idColeta != undefined ? idColeta : 0);
        this.numeroColeta = (numeroColeta != null || numeroColeta != undefined ? numeroColeta : 0);
        this.idDestinatario = (idDestinatario != null || idDestinatario != undefined ? idDestinatario : 0);
        this.nomeDestinatario = (nomeDestinatario != null || nomeDestinatario != undefined ? nomeDestinatario : "");
        this.volume = (volume != null || volume != undefined ? volume : 0);                
        this.etiqueta = (etiqueta != null || etiqueta != undefined ? etiqueta : "");                
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
                
        var _tdColeta = Builder.node("td",{
            id:"tdColeta_"+countCarga,
            name:"tdColeta_"+countCarga,
            className:"CelulaZebra2"
        });                

        var _tdDestinatario = Builder.node("td",{
            id:"tdDestinatario_"+countCarga,
            name:"tdDestinatario_"+countCarga,
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

        var _inpIdColeta = Builder.node("input",{
            id:"inpIdColeta_"+countCarga,
            nome:"inpIdColeta_"+countCarga,
            type:"hidden",
            value:carga.idColeta
        });
                
        var _lblNumeroColeta = Builder.node("label",{
            id:"lblNumeroColeta_"+countCarga,
            name:"lblNumeroColeta_"+countCarga
        });

        _lblNumeroColeta.innerHTML = carga.numeroColeta;                

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

        _tdColeta.appendChild(_inpIdColeta);
        _tdColeta.appendChild(_lblNumeroColeta);
        _tdDestinatario.appendChild(_inpIdDestinatario);                
        _tdDestinatario.appendChild(_lblNomeDestinatario);
        _tdVolume.appendChild(_inpVolumeDinamico);
        _tdVolume.appendChild(_lblVolumeDinamico);
        _tdVolume.appendChild(_lblVolumeFixo);
        _tdConferencia.appendChild(_divConferencia);


        _trCarga.appendChild(_tdColeta);
        _trCarga.appendChild(_tdDestinatario);        
        _trCarga.appendChild(_tdVolume);
        _trCarga.appendChild(_tdConferencia);

        $("maxColeta").value = countCarga;
        $("Carga").appendChild(_trCarga);
                
    }
    
    var countColetor=0;
    function addColetor(coletor){

        if(coletor == null || coletor == undefined){
            coletor = new DadosColetor();
        }

        countColetor++;
        
        //Adicionando chave de bipada no storage com o index do registro
        sessionStorage.setItem(coletor.codigo,countColetor);

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

        if (coletor.idUsuario == 0) {
            _lblCodigo.style.color = "red";
        }

        var _lblUsuario = Builder.node("label",{
            id:"lblUsuario_" + countColetor,
            name:"lblUsuario_" + countColetor
        });                
        _lblUsuario.innerHTML = coletor.nomeUsuario;
                
        if (coletor.idUsuario == 0) {
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

        _divExcluir.appendChild(_imgExcluir);

        _tdCodigo.appendChild(_lblCodigo);
        _tdCodigo.appendChild(_inpIdColetor);
        _tdUsuario.appendChild(_lblUsuario);
        _tdUsuario.appendChild(_inpIdUsuario);
        _tdExcluir.appendChild(_divExcluir);

        _trColetor.appendChild(_tdCodigo);
        _trColetor.appendChild(_tdUsuario);
        _trColetor.appendChild(_tdExcluir);               

        jQuery("#tbColetor").after(_trColetor);
    }
    
    function atualizarDiferenca(){        
        $("hidDiferenca").value = $("conferidoTotal").value - $("volumeTotal").value;
        $("diferenca").innerHTML = $("hidDiferenca").value;
    }
    
    function atualizarConferencia(etiqueta){
        var maxColeta = $("maxColeta").value;
        var etiquetas = "";

        for (var qtdColeta = 1; qtdColeta <= maxColeta; qtdColeta++) {                    
            if ($("etiqueta_"+qtdColeta) != null && $("etiqueta_"+qtdColeta).value != "") {
                etiquetas = $("etiqueta_"+qtdColeta).value;
                for (var qtdEti = 0; qtdEti < etiquetas.split(",").length; qtdEti++) {
                    if(etiquetas.split(",")[qtdEti] == etiqueta){                                
                       $("qtdEtiqueta_"+qtdColeta).value -= 1;
                       $("conferidoTotal").value = parseInt($("conferidoTotal").value) + 1;
                       $("volumeDinamico_"+qtdColeta).value = parseInt($("volumeDinamico_"+qtdColeta).value) + 1;
                       $("lblVolumeDinamico_"+qtdColeta).innerHTML = $("volumeDinamico_"+qtdColeta).value;
                    }
                }
            }

            if ($("qtdEtiqueta_"+qtdColeta).value == 0 && $("etiqueta_"+qtdColeta).value != "") {                        
                $("imgOk_"+qtdColeta).style.display = "";
                $("imgCancelar_"+qtdColeta).style.display = "none";
            }
        }

        $("totalConferido").innerHTML = $("conferidoTotal").value;
        $("bipagemTotal").value = $("conferidoTotal").value;
        $("totalBipagem").innerHTML = $("bipagemTotal").value;

        atualizarDiferenca();
    }
    
    function excluirBipagem(index){
            
        var idColetor = 0;

        if (confirm("Deseja excluir a Bipagem?")) {

            espereEnviar("Aguarde...",true);

            idColetor = $("idColetor_"+index).value;
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
            }else{
                //Validando se o objeto excluido do sessionStorage tem idColetor, (Quando o objeto já existe na tela, adiciona ele com idColetor = 0)
                if (idColetor != 0 && $("lblCodigo_"+index)) {
                    sessionStorage.removeItem($("lblCodigo_"+index).innerHTML);
                }
                Element.remove($("trColetor_"+index));                    
                espereEnviar("Aguarde...",false);
            }

        }
    }
    
    function visualizarNota(idNotaFiscal) {                
        window.open("NotaFiscalControlador?acao=carregar&idNota=" + idNotaFiscal + "&visualizar=true","visualizarNota", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
    }
    
    function atualizarConferenciaExcluir(etiqueta){
        var maxColeta = $("maxColeta").value;
        var etiquetas = "";

        for (var qtdCoelta = 1; qtdCoelta <= maxColeta; qtdCoelta++) {                    
            if ($("etiqueta_"+qtdCoelta) != null && $("etiqueta_"+qtdCoelta).value != "") {
                etiquetas = $("etiqueta_"+qtdCoelta).value;
                for (var qtdEti = 0; qtdEti < etiquetas.split(",").length; qtdEti++) {
                    if(etiquetas.split(",")[qtdEti] == etiqueta){                                
                       $("qtdEtiqueta_"+qtdCoelta).value += 1;
                       $("conferidoTotal").value = parseInt($("conferidoTotal").value) - 1;
                       $("volumeDinamico_"+qtdCoelta).value = parseInt($("volumeDinamico_"+qtdCoelta).value) - 1;
                       $("lblVolumeDinamico_"+qtdCoelta).innerHTML = $("volumeDinamico_"+qtdCoelta).value;
                    }
                }
            }
            if ($("qtdEtiqueta_"+qtdCoelta).value > 0 && $("etiqueta_"+qtdCoelta).value != "") {                        
                $("imgOk_"+qtdCoelta).style.display = "none";
                $("imgCancelar_" + qtdCoelta).style.display = "";
            }
        }

        $("totalConferido").innerHTML = $("conferidoTotal").value;
        $("bipagemTotal").value = $("conferidoTotal").value;
        $("totalBipagem").innerHTML = $("bipagemTotal").value;

        atualizarDiferenca();
    }
    
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <title> Importar conferência (Coleta)</title>
    </head>
    <body onload="carregar();">
        <img alt="" src="img/banner.gif" align="middle">
        <table class="bordaFina" width="90%" align="center">
            <tr>
                <td width="82%" align="left">
                    <b>Importação de conferência ( ${param.tipoOperacao == '0' ? 'Carregamento' : 'Descarregamento'} )</b>
                </td>
                <td>
                    <input type="button" value=" Fechar " class="botoes" onclick="fechar();"/>
                </td>
            </tr>
        </table>
        <br/>
        <table width="90%" align="center" class="bordaFina">
            <tr class="tabela">
                <td colspan="15"> Coleta  </td>
            </tr>
            <tr>
                <td width="8%" class="TextoCampos">Número:</td>
                <td width="8%" class="celulaZebra2">
                    <label>${param.numeroColeta}</label>
                    <input type="hidden" name="idColeta" id="idColeta" value="${param.idColeta}" />
                    <input type="hidden" name="tipoOperacao" id="tipoOperacao" value="${param.tipoOperacao}" />
                </td>
                <td width="8%" class="TextoCampos">
                    Origem: 
                </td>
                <td class="CelulaZebra2" width="14%">
                    <label id="origem"> ${param.cidadeOrigem} </label>
                </td>
                <td class="TextoCampos" width="8%">
                    UF: 
                </td>
                <td class="CelulaZebra2" width="4%">
                    <label id="ufOrigem"> ${param.ufOrigem} </label>
                </td>

                <td class="textoCampos" width="8%">
                    Destino: 
                </td>
                <td class="CelulaZebra2" width="14%">
                    <label id="destino"> ${param.cidadeDestino == 'null' ? '' : param.cidadeDestino} </label>
                </td>
                <td class="TextoCampos" width="8%">
                    UF: 
                </td>
                <td class="CelulaZebra2" width="4%">
                    <label id="ufDestino"> ${param.ufDestino == 'null' ? '' : param.ufDestino} </label>
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
        </table>
        <table width="90%" align="center" class="bordaFina">
            <tr>
                <td width="50%" style="vertical-align:top; ${param.tipoOperacao == '0' ? 'display: none' : ''}">
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
                        <tbody id="Carga">
                            <tr class="CelulaZebra1">
                                <td width="15%">
                                    <b>Coleta</b>
                                </td>
                                <td width="50%">
                                    <b>Remetente</b>
                                </td>                                
                                <td width="10%">
                                    <b>Conferência</b>
                                </td>
                                <td width="10%"></td>
                            </tr>
                        </tbody>
                    </table>
                    <table width="100%" align="center" class="bordaFina">
                        <input type="hidden" id="maxColeta" name="maxColeta" value="0"/>
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
                                    <input type="text" class="inputtexto" id="codigoBarras" name="codigoBarras" size="40" maxlength="50" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" />
                                    <input type="button" id="pesquisar" name="pesquisar" class="botoes" value=" Pesquisar " onclick="javascript:tryRequestToServer(function(){getBipagem();});"/>
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
        <br/>
        <table width="90%" align="center" class="bordaFina">
            <tr class="CelulaZebra2NoAlign">  
                <td width="70%">
                    <form action="" id="formAtualizar" name="formAtualizar" method="post" >
                        <input name="btAtualizar" id="btAtualizar" type="button" class="botoes" value=" Atualizar " onclick="javascript:tryRequestToServer(function(){atualizar();});"/>                            
                    </form>                        
                </td>                                
            </tr>
        </table>
    </body>
</html>
