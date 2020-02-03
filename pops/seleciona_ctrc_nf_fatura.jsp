<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         conhecimento.duplicata.fatura.*,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio" %>

<%  
    //Carregando o loading. 
//    nucleo.Apoio.addAguardePopup(out);
    //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP

    // -- INICIO DO MSA
    int linha = 0;
    double limiteFatura = Apoio.parseDouble(request.getParameter("limiteFatura") != null ? request.getParameter("limiteFatura") : "0");
    boolean isIncluirFaturasCTeConfirmados = Apoio.getConfiguracao(request).isIncluirFaturasCTeConfirmados();
    boolean mostrarFreteCifEmitidoPropriaFilialFobs = Apoio.getUsuario(request).getFilial().isMostrarFreteCifEmitidoPropriaFilialFobs();
    if (Apoio.getUsuario(request) == null) {
        response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
    }

    BeanConsultaFatura conFat = null;
    String acao = request.getParameter("acao");
    String marcados = (request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados"));
    String acaoDoPai = request.getParameter("acaoDoPai");
    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA

    //Instanciando o bean pra trazer os CTRC's
    conFat = new BeanConsultaFatura();
    conFat.setConexao(Apoio.getUsuario(request).getConexao());

    String tipoData = (request.getParameter("tipoConsultaData") == null ? "s.emissao_em" : request.getParameter("tipoConsultaData"));
    String modal = (request.getParameter("modalCte") == null ? "" : request.getParameter("modalCte"));
    String tiposConhecimentos = (request.getParameter("tipoConhecimento") == null ? "" : request.getParameter("tipoConhecimento"));
    
    conFat.setTipoPagadorCIF(Apoio.parseBoolean(request.getParameter("tipoPagadorCIF") == null ? "false" : request.getParameter("tipoPagadorCIF")));
    conFat.setTipoPagadorCON(Apoio.parseBoolean(request.getParameter("tipoPagadorCON") == null ? "false" : request.getParameter("tipoPagadorCON")));
    conFat.setTipoPagadorFOB(Apoio.parseBoolean(request.getParameter("tipoPagadorFOB") == null ? "false" : request.getParameter("tipoPagadorFOB")));
    conFat.setTipoPagadorRED(Apoio.parseBoolean(request.getParameter("tipoPagadorRED") == null ? "false" : request.getParameter("tipoPagadorRED")));
    conFat.getConfiguracao().setIncluirFaturasCTeConfirmados(Apoio.parseBoolean(request.getParameter("incluirFaturasCteConfirmados")));
    conFat.getFreteFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(Apoio.parseBoolean(request.getParameter("chkFretesFilial") == null ? "true" : request.getParameter("chkFretesFilial")));
    conFat.getFreteFilial().setIdfilial(Integer.parseInt(request.getParameter("idFilialUsuario") != null ? request.getParameter("idFilialUsuario") : String.valueOf(Apoio.getUsuario(request).getFilial().getId())));
%>
<script language="javascript" src="./script/funcoes.js?v=${random.nextInt()}" type=""></script>
<script language="javascript" src="./script/mascaras.js" type=""></script>
<script type="text/javascript" src="${homePath}/assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}"></script>
<script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var homePath = '${homePath}';

    jQuery.noConflict();

    var quant=0;
    function fechar(){
        window.close();
    }

    function seleciona(qtdlinha){
        var retorno = "";
        for (i = 0; i <= qtdlinha - 1; ++i){
            if ($("chk_"+i) && $("chk_"+i).checked){
                if (retorno == ""){
                    retorno += $("chk_"+i).value
                }else{
                    retorno += ","+$("chk_"+i).value
                }
            }
        }
        if (retorno == ''){
            alert('Escolha, no mínimo, um CTRC/NF.');
        }else{
            if (window.opener.carregaCTRC != null)
                //window.opener.calculaVencimento(true);
                window.opener.carregaCTRC(retorno,0,'<%=(request.getParameter("acaoDoPai") != null ? request.getParameter("acaoDoPai").trim() : "")%>');
            fechar();   
        }
    }

    function ctrcSelecionado(id){
        var sels = '<%=marcados%>';
        for(x=0; x < sels.split(',').length; x++){
            if (sels.split(',')[x] == id)
                return true;
        }
        return false;  
    }

    function isVirgulaUF(){
        var ufs = $("ufDestinoFiltro").value;
        var retorno = true;

        if(ufs.trim().length > 2 && ufs.trim().indexOf(",") == -1){
            alert("Para consultar com mais de uma 'UF' utilizar virgula.");
            retorno = false;
        }
        return retorno;
    }

    function getUFs(){
        var ufs = $("ufDestinoFiltro").value;
      
        var retorno = "";

        if(ufs != ""){          
            for (var i = 0; i < ufs.split(",").length; i++){
                retorno += (retorno != "" ? ",":"")+ "'"+ufs.split(",")[i]+"'";
            }
        }

        return retorno;
    }

    /**
     * Para telas que trazem muitos CTRCs, método inviável. A demora para percorrer
     * a lista, chega a travar o navegador. 
     * @Depracted
     * @returns {undefined}
     */    
    function checkCtrc(evento){
        var isCtrc = false;

        if( evento.keyCode==13 ) {
            for (var i = 0; i <= quant; ++i){
                if($("numeroDoc_"+i)!=null && $("numeroDoc_"+i).innerHTML.split("-")[0]==$("selCtrc").value){
                    $("chk_"+i).checked = true;
                    marcar($("chk_"+i), false);
                    $("selCtrc").value = "";
                    isCtrc = true;
                    break;
                }
            }
            if(!isCtrc){alert("Ctrc não encontrado.");}

        }
    }

    function pesquisarCtrcsMarcados(){
        
        if((!$("tipoPagadorCIF").checked) && (!$("tipoPagadorCON").checked) && (!$("tipoPagadorFOB").checked) && (!$("tipoPagadorRED").checked)){
            alert("Informe o tipo de pagador (CIF,FOB,CON,RED) corretamente!");
            return null;
        }
       
        if(isVirgulaUF()){
            sessionStorage.setItem('tipoProdutos', $('tipo_produtos').value);

//            tryRequestToServer(function(){location.replace("./selecionactrc_fatura?acao=consultar&marcados=<%--<%=marcados%>--%>&acaoDoPai=<%--<%=request.getParameter("acaoDoPai")%>--%>&idconsignatario="+$("idconsignatario").value+"&chkEntregues="+$('chkEntregues').checked+
//                    "&chkGrupos="+$('chkGrupos').checked+
//                    "&isLimiteFatura="+$('isLimiteFatura').checked+
//                    "&idCidadeDestino="+$('idcidadedestino').value+
//                    "&cidadeDestino="+$('cid_destino').value + 
//                    "&ufDestino=" + $('uf_destino').value+
//                    "&pedido="+$("pedido").value+
//                    "&numeroCarga="+$("numeroCarga").value+
//                    "&numeroNota="+$("numeroNota").value+
//                    "&limiteFatura="+$("limiteFatura").value+
//                    "&dtinicial="+$('dtinicial').value+
//                    "&dtfinal="+$('dtfinal').value+
//                    "&filialId="+$('filialId').value+
//                    "&idRemetente="+$('idremetente').value+
//                    "&remetente="+$('rem_rzs').value+
//                    "&idDestinatario="+$('iddestinatario').value+
//                    "&destinatario="+$('dest_rzs').value+
//                    "&modalCte="+$('modalCte').value+
//                    "&con_rzs=<%--<%=request.getParameter("con_rzs")%>--%>&tipoConsultaData="+
//                    $("tipoConsultaData").value+"&ufDestinoFiltro="+getUFs())});
        var form = $("formulario");
        form.action = "./selecionactrc_fatura?acao=consultar&acaoDoPai=<%=request.getParameter("acaoDoPai")%>&ufDestino=" + $('uf_destino').value+
                    "&cidadeDestino="+$('cid_destino').value+
                    "&remetente="+$('rem_rzs').value+                   
                    "&destinatario="+$('dest_rzs').value+                    
                    "&con_rzs=<%=request.getParameter("con_rzs")%>"+
                    "&tipoConsultaData="+$("tipoConsultaData").value+
                    "&ufDestinoFiltro="+getUFs()+
                    "&tipoPagadorCIF="+$('tipoPagadorCIF').checked+
                    "&tipoPagadorCON="+$('tipoPagadorCON').checked+
                    "&tipoPagadorFOB="+$('tipoPagadorFOB').checked+
                    "&tipoPagadorRED="+$('tipoPagadorRED').checked+
                    "&incluirFaturasCteConfirmados="+$("incluirFaturasCteConfirmados").value+
                     "&incluirFaturasCteConfirmados="+$("incluirFaturasCteConfirmados").value+
                    "&chkFretesFilial="+document.getElementById("chkFretesFilial").checked+
                    "&filtroCidade="+(document.querySelector('input[name=filtroCidade]:checked') != null ? document.querySelector('input[name=filtroCidade]:checked').value : null)+
                    "&idRemetente="+$("idremetente").value+
                    "&remetente="+$("rem_rzs").value+
                    "&idDestinatario="+$("iddestinatario").value+
                    "&destinatario="+$("dest_rzs").value+
                    "&idCidadeDestino="+$("idcidadedestino").value+
                    "&cidadeDestino="+$("cid_destino").value + 
                    "&ufDestino=" + $("uf_destino").value+
                    "&filialId="+$("filialId").value+
                    "&tipoProdutos=" + $('tipo_produtos').value.split('!@!').map(function (e) {
                        return e.split('#@#')[1]
                    }).join();
        form.submit();
        }
    }
      
    function carregarCtrcsFatura(){
        espereEnviar("",true);
        $("marcados").value = window.opener.document.getElementById("marcados").value;
        $("filialId").value = '<%= request.getParameter("filialId") == null ? "0" : request.getParameter("filialId") %>';
        var form = $("formulario");
        var isSubmit = '<%=request.getParameter("isSubmit")%>';
        if(isSubmit != null && isSubmit != 'null'){
            form.action = "./selecionactrc_fatura?acao=<%=acao%>&idconsignatario="+$("idconsignatario").value+"&con_rzs="+$("con_rzs").value+"&acaoDoPai=<%=acaoDoPai%>+&incluirFaturasCteConfirmados"+$("incluirFaturasCteConfirmados").value;
            form.submit();            
        }else{
            espereEnviar("",false);
        }
        
        espereEnviar("",false);
    }
  
    function carregar(){
        $("filialId").value = '<%= request.getParameter("filialId")==null? 0:request.getParameter("filialId") %>';
        utilizarLimiteFatura();
        carregarCtrcsFatura();
        carregarFaturasFilial();

        if (sessionStorage.getItem('tipoProdutos') !== undefined && sessionStorage.getItem('tipoProdutos') !== null) {
            var input = jQuery('#tipo_produtos');
            sessionStorage.getItem('tipoProdutos').split('!@!').forEach(function (elemento) {
                var split = elemento.split('#@#');

                addValorAlphaInput(input, split[0], split[1]);
            });
        }

        if ('<%= Apoio.parseBoolean(request.getParameter("chkEntregues")) %>' === 'true') {
            alteraCTeEntregues(true);
        }
    }
    
    
    function carregarFaturasFilial(){
        if (<%=mostrarFreteCifEmitidoPropriaFilialFobs%>) {
            document.getElementById("chkFretesFilial").checked = true;
            document.getElementById("optionNenhum").disabled = true;
            document.getElementById("chkFretesFilial").disabled = true;
            document.getElementById("chkFretesFilialDestino").disabled = true;
        }
    }
  
    function getVlAtualMarcado(){
        var valor = 0;
        for (i = 0; i < quant; i++) {
            if ($("valorCtrc_"+i) != null && $("valorCtrc_"+i) != undefined && $("chk_"+i).checked) {
                valor += parseFloat(colocarPonto($("valorCtrc_"+i).innerHTML));
            }
        }
        return valor;
    }
  
    function utilizarLimiteFatura(){
        if ($("isLimiteFatura").checked) {
            let checks = jQuery('[id^=chk_]');
            let limite = parseFloat(colocarPonto($("limiteFatura").value));
            let totaisFatura = 0;

            habilitar($("limiteFatura"));

            checks.prop('checked', false);

            checks.each(function (index, element) {
                let elementIndex = element.id.substring(element.id.lastIndexOf('_') + 1);
                let valor = parseFloat(colocarPonto($("valorCtrc_" + elementIndex).innerHTML));

                if ((getVlAtualMarcado() + valor) <= limite) {
                    $("chk_" + elementIndex).checked = true;

                    totaisFatura += valor;
                }
            });

            $('lblTotalSelecionado').innerText = colocarVirgulaNovo(totaisFatura);
        }else{
            desabilitar($("limiteFatura"))
        }
      
    }
  
    function marcar(obj, atualizarValores){
        var index = obj.id.replace("chk_", "");
        var limite = parseFloat(colocarPonto($("limiteFatura").value));
        var valor = parseFloat(colocarPonto($("valorCtrc_"+index).innerHTML));
        if ($("isLimiteFatura").checked && obj.checked) {
            obj.checked = false;
            if ((getVlAtualMarcado() + valor) <= limite) {
                obj.checked = true;
            }else{
                alert("Excede o Limite estipulado!") ;
            }
        }

        if (atualizarValores) {
            let valorTotal = parseFloat(colocarPonto($('lblTotalSelecionado').innerText));

            if (obj.checked) {
                valorTotal += valor;
            } else {
                valorTotal -= valor;
            }

            $('lblTotalSelecionado').innerText = colocarVirgulaNovo(valorTotal);
        }
    }

    function marcarTodos(){
        let totaisFatura = parseFloat($('totaisFatura').value);
        let checks = jQuery('[id^=chk_]');

        checks.prop('checked', false);

        if ($("chkTodos").checked) {
            if ($("isLimiteFatura").checked) {
                totaisFatura = 0;

                let limite = parseFloat(colocarPonto($("limiteFatura").value));

                checks.each(function (index, element) {
                    let elementIndex = element.id.substring(element.id.lastIndexOf('_') + 1);
                    let valor = parseFloat(colocarPonto($("valorCtrc_" + elementIndex).innerHTML));

                    if ((getVlAtualMarcado() + valor) <= limite) {
                        $("chk_" + elementIndex).checked = true;

                        totaisFatura += valor;
                    }
                });

            } else {
                checks.prop('checked', true);
            }

            $('lblTotalSelecionado').innerText = colocarVirgulaNovo(totaisFatura);
        } else {
            $('lblTotalSelecionado').innerText = '0.00';
        }
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=12','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function alteraCTeEntregues(checado) {
        if (checado == true || checado == "on") {
            $("divApenasComprovanteEntrega").style.visibility = "visible";
        } else {
            $("divApenasComprovanteEntrega").style.visibility = "hidden";
        }
    }

</script>

<%@page import="java.text.DecimalFormat"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Selecionar CT-e(s)/NFS(s) para fatura</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
        <link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
    </head>

    <body onload="carregar();">
        <form action="" id="formulario" name="formulario" method="post">
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") == null ? "0" : request.getParameter("idconsignatario"))%>">
        <input type="hidden" name="marcados" id="marcados" value="">
        <input type="hidden" name="con_rzs" id="con_rzs" value="<%=(request.getParameter("con_rzs") == null ? "" : request.getParameter("con_rzs"))%>">
        <input type="hidden" name="incluirFaturasCteConfirmados" id="incluirFaturasCteConfirmados" value="<%=isIncluirFaturasCTeConfirmados%>">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="619"><div align="left"><b>Selecionar CTs/NFs para fatura</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="10%" class="TextoCampos">Cliente:</td>
                <td width="23%" class="CelulaZebra2">
                    <label id="con_rzs" name="con_rzs"><b><%=(request.getParameter("con_rzs") == null ? "Cliente não informado" : request.getParameter("con_rzs"))%></b></label>
                </td>
                <td width="13%" class="TextoCampos">
                    <select name="tipoConsultaData" id="tipoConsultaData" class="inputtexto" style="width: 120px;">
                        <option value="" <%= (tipoData.equals("") ? "selected" : "")%>>Todos: </option>
                        <option value="s.emissao_em" <%= (tipoData.equals("s.emissao_em") ? "selected" : "")%>>Emitidos entre: </option>
                        <option value="ct.baixa_em" <%= (tipoData.equals("ct.baixa_em") ? "selected" : "")%>>Entregues entre: </option>
                        <option value="ct.baixado_no_dia" <%= (tipoData.equals("ct.baixado_no_dia") ? "selected" : "")%>>Baixados entre: </option>
                    </select>
                </td>
                <td width="20%" class="CelulaZebra2">
                    <input name="dtinicial" type="text" id="dtinicial" class="fieldDate" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="12" maxlength="10"
                                                            onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                    e
                    <input name="dtfinal" type="text" id="dtfinal" style="font-size:8pt;" class="fieldDate" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="12" maxlength="10"
                           onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                </td>
                <td width="10%" class="TextoCampos">Apenas a Filial:</td>
                <td width="24%" class="CelulaZebra2">
                        <select name="filialId" id="filialId" class="fieldMin" >
                            <option value="0" selected="selected">TODAS</option>
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                                while (rsFl.next()) {
                            %>
                                <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                        </select> 
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Remetente:</td>
                <td class="CelulaZebra2">
                                <input type="hidden" name="idremetente" id="idremetente" value="<%=(request.getParameter("idRemetente") == null ? "0" : request.getParameter("idRemetente"))%>">
                                <input name="rem_rzs" type="text" id="rem_rzs" value="<%=(request.getParameter("remetente") == null ? "" : request.getParameter("remetente"))%>" size="22" readonly="true" class="inputReadOnly8pt">
                                <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');;">
                                <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = '';">                   
                </td>
                <td class="TextoCampos">Destinatário:</td>
                <td class="CelulaZebra2">
                                <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=(request.getParameter("idDestinatario") == null ? "0" : request.getParameter("idDestinatario"))%>">
                                <input name="dest_rzs" type="text" id="dest_rzs" value="<%=(request.getParameter("destinatario") == null ? "" : request.getParameter("destinatario"))%>" size="22" readonly="true" class="inputReadOnly8pt">
                                <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = '';">
                </td> 
                <td class="TextoCampos">Destino:</td>
                <td class="CelulaZebra2">
                    <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="<%=(request.getParameter("idCidadeDestino") == null ? "0" : request.getParameter("idCidadeDestino"))%>">
                    <input name="cid_destino" type="text" class="inputReadOnly8pt" id="cid_destino"  size="19" readonly="true" value="<%=(request.getParameter("cidadeDestino") == null ? "" : request.getParameter("cidadeDestino"))%>">
                    <input name="uf_destino" type="text" id="uf_destino" class="inputReadOnly8pt" size="1" readonly="true" value="<%=(request.getParameter("ufDestino") == null ? "" : request.getParameter("ufDestino"))%>">
                    <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();" >
                    <strong><img src="./img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idcidadedestino').value = '0';javascript:getObj('cid_destino').value = '';javascript:getObj('uf_destino').value = '';"></strong>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="2">
                    <div align="left">
                        <input name="chkGrupos" type="checkbox" id="chkGrupos" value="checkbox" <%=request.getParameter("chkGrupos") == null ? "" : "checked"%>>
                        Mostrar CT-e(s)/NFS(s) emitidos para o mesmo grupo de clientes.</div>
                </td>
                <td class="TextoCampos" colspan="2">
                    <div align="left"><input name="chkEntregues" type="checkbox" id="chkEntregues" value="checkbox" <%=request.getParameter("chkEntregues") == null ? "" : "checked" %>
                                             onclick="alteraCTeEntregues(this.checked)" >
                    <label for="chkEntregues">Mostrar apenas CT-e(s) entregues.</label></div>
                    <div align="left" id="divApenasComprovanteEntrega" style="visibility: hidden;">
                        <input name="chkApenasComprovanteEntrega" type="checkbox" id="chkApenasComprovanteEntrega"
                               value="checkbox" <%=request.getParameter("chkApenasComprovanteEntrega") == null ? "" : Apoio.parseBoolean(request.getParameter("chkApenasComprovanteEntrega")) ? "checked" : ""%>>
                        <label for="chkApenasComprovanteEntrega">Mostrar apenas com comprovante de entrega</label>
                    </div>
                </td>
                <td class="TextoCampos">UF(s) Destino:</td>
                <td class="CelulaZebra2">
                    <input name="ufDestinoFiltro" type="text" id="ufDestinoFiltro" title="Para filtrar por mais de uma UF usar virgula" class="inputtexto" size="15" value="<%=(request.getParameter("ufDestinoFiltro") == null ? "" : request.getParameter("ufDestinoFiltro").replaceAll("'", ""))%>">
                    EX: PE,AL,BA
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Pedido:</td>
                <td class="CelulaZebra2">
                    <input type="text" class="fieldMin" name="pedido" id="pedido" size="9" maxlength="10" value="<%=(request.getParameter("pedido") != null ? request.getParameter("pedido") : "")%>" /> 
                </td>
                <td class="TextoCampos">NF Embarcador:</td>
                <td class="CelulaZebra2">
                    <input type="text" class="fieldMin" name="numeroNota" id="numeroNota" size="35" value="<%=(request.getParameter("numeroNota") != null ? request.getParameter("numeroNota") : "")%>" />
                    <br>EX: 7899,7900,7901,7902
                </td>
                <td class="TextoCampos">Nº Carga:</td>
                <td class="CelulaZebra2">
                    <input type="text" class="fieldMin" name="numeroCarga" id="numeroCarga" size="9" maxlength="10" value="<%=(request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga") : "")%>" /> 
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Modal:</td>
                <td class="CelulaZebra2">
                    <select name="modalCte" id="modalCte" class="inputtexto" style="width: 120px;">
                        <option value="" <%= (modal.equals("") ? "selected" : "")%>>Todos</option>
                        <option value="r" <%= (modal.equals("r") ? "selected" : "")%>>Rodoviário</option>
                        <option value="a" <%= (modal.equals("a") ? "selected" : "")%>>Aéreo</option>
                        <option value="q" <%= (modal.equals("q") ? "selected" : "")%>>Aquaviário</option>
                    </select>
                </td>
                <td class="TextoCampos">
                    Tipo:
                </td>
                <td class="CelulaZebra2">
                    <select name="tipoConhecimento" id="tipoConhecimento" style="width:120px;" class="inputtexto">
                        <option value="" <%= (tiposConhecimentos.equals("") ? "selected" : "")%>>Todos</option>
                        <option value="n" <%= (tiposConhecimentos.equals("n") ? "selected" : "")%>>Normal</option>
                        <option value="l"<%= (tiposConhecimentos.equals("l") ? "selected" : "")%>>Entrega Local (Cobrança)</option>
                        <option value="i" <%= (tiposConhecimentos.equals("i") ? "selected" : "")%>>Diárias</option>
                        <option value="p"<%= (tiposConhecimentos.equals("p") ? "selected" : "")%>>Pallets</option>
                        <option value="c" <%= (tiposConhecimentos.equals("c") ? "selected" : "")%>>Complementar</option>
                        <option value="r"<%= (tiposConhecimentos.equals("r") ? "selected" : "")%>>Reentrega</option>
                        <option value="d" <%= (tiposConhecimentos.equals("d") ? "selected" : "")%>>Devolução</option>
                        <option value="b"<%= (tiposConhecimentos.equals("b") ? "selected" : "")%>>Cortesia</option>
                        <option value="s" <%= (tiposConhecimentos.equals("s") ? "selected" : "")%>>Substituição</option>
                        <option value="t" <%= (tiposConhecimentos.equals("t") ? "selected" : "")%> id="subs" name="subs" style="display: none">Substituído</option>
                    </select>
                </td>
                <td class="TextoCampos">Apenas Fretes:</td>
                <td class="CelulaZebra2">
                    <input type="checkbox" name="tipoPagadorCIF" id="tipoPagadorCIF" <%=request.getParameter("tipoPagadorCIF") == null ? "checked" : Apoio.parseBoolean(request.getParameter("tipoPagadorCIF")) ? "checked" : ""%>>CIF
                    <input type="checkbox" name="tipoPagadorFOB" id="tipoPagadorFOB" <%=request.getParameter("tipoPagadorFOB") == null ? "checked" : Apoio.parseBoolean(request.getParameter("tipoPagadorFOB")) ? "checked" : ""%>>FOB
                    <input type="checkbox" name="tipoPagadorCON" id="tipoPagadorCON" <%=request.getParameter("tipoPagadorCON") == null ? "checked" : Apoio.parseBoolean(request.getParameter("tipoPagadorCON")) ? "checked" : ""%>>CON
                    <input type="checkbox" name="tipoPagadorRED" id="tipoPagadorRED" <%=request.getParameter("tipoPagadorRED") == null ? "checked" : Apoio.parseBoolean(request.getParameter("tipoPagadorRED")) ? "checked" : ""%>>RED                     
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="6">
                    <div align="left">
                        <input type="radio" id="optionNenhum" name="filtroCidade" value="0" <%=request.getParameter("filtroCidade") == null || request.getParameter("filtroCidade").equals("0")? "checked" : ""%>> Nenhum 
                    </div>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="5"><div align="left">
                        <input type="radio" id="chkFretesFilial" name="filtroCidade" value="1" <%=request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("1") ? "checked" : ""%>> Mostrar apenas fretes CIF emitidos pela filial e fretes FOB destinados a filial: 
                    <select name="idFilialUsuario" id="idFilialUsuario" class="inputtexto">
                        <%BeanFilial fl1 = new BeanFilial();
                            ResultSet rsFl1 = fl1.all(Apoio.getUsuario(request).getConexao());%>
                        <%while (rsFl1.next()) {%>
                        <option value="<%=rsFl1.getString("idfilial")%>" <%=((request.getParameter("idFilialUsuario") == null ? Apoio.getUsuario(request).getFilial().getIdfilial() : Apoio.parseInt(request.getParameter("idFilialUsuario"))) == rsFl1.getInt("idfilial") ? "selected" : "")%> ><%=rsFl1.getString("abreviatura")%></option>
                        <%}%>
                    </select>
                </div></td>
<!--                <td class="CelulaZebra2">
                        Apenas a Filial Frete:
                    <select name="idFilialUsuario" id="idFilialUsuario" class="inputtexto">
                        < %BeanFilial fl1 = new BeanFilial();
                            ResultSet rsFl1 = fl1.all(Apoio.getUsuario(request).getConexao());%>
                        < %while (rsFl1.next()) {%>
                        <option value="< %=rsFl1.getString("idfilial")%>" < %=(Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl1.getInt("idfilial") ? "selected" : "")%> >< %=rsFl1.getString("abreviatura")%></option>
                        < %}%>
                    </select>
                </td>-->
<!--                <td class="TextoCampos" colspan="2"><div align="left">
                    <input type="checkbox" id="chkFretesFilial" name="chkFretesFilial" <%=request.getParameter("chkFretesFilial") == null ? "checked" : Apoio.parseBoolean(request.getParameter("chkFretesFilial")) ? "checked" : ""%>> Mostrar apenas fretes CIF emitidos pela filial e fretes FOB destinados a filial
                </td>-->
                <td class="TextoCampos" colspan="2"><div align="left">
                    <input type="checkbox" id="chkCteManifestados" name="chkCteManifestados" value="checkbox" <%= request.getParameter("chkCteManifestados") == null ? "" : "checked" %> > Mostrar Apenas CT-e(s) com manifestos
                </div></td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="6"><div align="left">
                        <input type="radio" id="chkFretesFilialDestino" name="filtroCidade" value="2" <%=request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("2") ? "checked" : ""%>> Mostrar apenas fretes onde a responsabilidade da entrega seja da filial: 
                    <select name="idFilialDestino" id="idFilialDestino" class="inputtexto">
                        <%BeanFilial fl2 = new BeanFilial();
                            ResultSet rsFl2 = fl2.all(Apoio.getUsuario(request).getConexao());%>
                        <%while (rsFl2.next()) {%>
                        <option value="<%=rsFl2.getString("idfilial")%>" <%=((request.getParameter("idFilialDestino") == null ? Apoio.getUsuario(request).getFilial().getIdfilial() : Apoio.parseInt(request.getParameter("idFilialDestino"))) == rsFl2.getInt("idfilial") ? "selected" : "")%> ><%=rsFl2.getString("abreviatura")%></option>
                        <%}%>
                    </select>
                </div></td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="1">
                    <div align="right">
                        <label for="tipo_produtos">Tipo de Produto:</label>
                    </div>
                </td>
                <td class="CelulaZebra2" colspan="5">
                    <div align="left">
                        <input name="tipo_produtos" type="text" id="tipo_produtos" class="inputReadOnly8pt" value="" readonly>
                        <input name="localizar_tipo_produtos" type="button" class="botoes" id="localizar_tipo_produtos" value="..." onClick="controlador.acao('abrirLocalizar','localizarTipoProduto');">
                        <img src="img/borracha.gif" name="limpar_tipo_produto" border="0" align="absbottom" class="imagemLink" id="limpar_tipo_produto" title="Limpar Tipo de Produtos" onClick="removerValorInput('tipo_produtos')">
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="6" class="CelulaZebra2"><div align="center">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="javascript:pesquisarCtrcsMarcados();">
                </div></tr>
        </table>

        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="2%"><div align="center">
                        <input type="checkbox" name="chkTodos" id="chkTodos" value="chkTodos" onClick="javascript:marcarTodos();">
                    </div></td>
                <td width="8%">Tipo</td>
                <td width="10%">Filial</td>
                <td width="7%">Docum.</td>
                <td width="3%"><div align="center">PC</div></td>
                <td width="12%">Data</td>
                <td width="23%">Remetente</td>
                <td width="23%">Destinatário</td>
                <td width="8%"><div align="right">Valor</div></td>
                <td width="9%">Entrega</td>
            </tr>
            <tr>
                <td class="CelulaZebra2" colspan="7">Informe o CTRC:
                    <input name="selCtrc" type="text" style="font-size:8pt;" id="selCtrc" size="7" value="" class="inputtexto" onKeyPress="checkCtrc(event)">
                    <font color="red"> (após informar o número de CTRC tecle "Enter")</font>
                </td>
                <td class="CelulaZebra2" colspan="3" >
                    <input type="checkbox" id="isLimiteFatura" <%=Apoio.parseBoolean(request.getParameter("isLimiteFatura")) ? "checked" : ""%> value="chkTodos" onClick="utilizarLimiteFatura();">
                    Valor Limite para geração da fatura:
                    <input type="text" name="limiteFatura" id="limiteFatura" size="8" value="<%=new DecimalFormat("#,##0.00").format(limiteFatura)%>" class="inputtexto" value="" onblur="utilizarLimiteFatura()" onkeypress="mascara(this, reais, 2)" >
                </td>
            </tr>

            <% //variaveis da paginacao

                conFat.setDataVenc1((request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual()));
                conFat.setDataVenc2((request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual()));
                conFat.setIdConsignatario(Integer.parseInt(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0"));
                
                conFat.setCtrcsEntregues(Boolean.parseBoolean(request.getParameter("chkEntregues") == null ? "false" : "true"));
                conFat.setMostrarCtrcsGrupo(Boolean.parseBoolean(request.getParameter("chkGrupos") == null ? "false" : "true"));
                conFat.setTipoData(tipoData);
                conFat.setPedido(request.getParameter("pedido") != null ? request.getParameter("pedido") : "");
                conFat.setNumeroNota(request.getParameter("numeroNota") != null ? request.getParameter("numeroNota") : "");
                conFat.setNumeroCarga(request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga") : "");
                conFat.setUfs((request.getParameter("ufDestinoFiltro") != null ? request.getParameter("ufDestinoFiltro").trim().toUpperCase() : ""));
                conFat.setValorDaConsulta(marcados);
                conFat.setMostraCtrcAvista("a");
                conFat.setIdCidadeDestino((request.getParameter("idcidadedestino") == null ? 0 : Integer.parseInt(request.getParameter("idcidadedestino"))));
                conFat.setIdRemetente((request.getParameter("idremetente") == null ? 0 : Integer.parseInt(request.getParameter("idremetente"))));
                conFat.setIdDestinatario((request.getParameter("iddestinatario") == null ? 0 : Integer.parseInt(request.getParameter("iddestinatario"))));
                conFat.setFilial((request.getParameter("filialId") == null) ? "0" : request.getParameter("filialId"));
                conFat.setModalCte((request.getParameter("modalCte") == null) ? "" : request.getParameter("modalCte"));
                conFat.setTipoConhecimento((request.getParameter("tipoConhecimento") == null) ? "" : request.getParameter("tipoConhecimento"));
                conFat.setCtrcsManifestados(Boolean.parseBoolean(request.getParameter("chkCteManifestados") == null ? "false" : "true"));
                conFat.getConfiguracao().setIncluirFaturasCTeConfirmados(Boolean.parseBoolean(request.getParameter("incluirFaturasCteConfirmados") == null ? "false" : request.getParameter("incluirFaturasCteConfirmados")));
                if(request.getParameter("filtroCidade") != null && request.getParameter("filtroCidade").equals("1")) {
                    conFat.getFreteFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(true);
                    conFat.getFreteFilial().setIdfilial(Integer.parseInt(request.getParameter("idFilialUsuario") != null ? request.getParameter("idFilialUsuario") : String.valueOf(Apoio.getUsuario(request).getFilial().getId())));
                } else {
                    conFat.getFreteFilial().setMostrarFreteCifEmitidoPropriaFilialFobs(false);
                    conFat.getFreteFilial().setIdfilial(Integer.parseInt(request.getParameter("idFilialDestino") != null ? request.getParameter("idFilialDestino") : String.valueOf(Apoio.getUsuario(request).getFilial().getId())));
                }
                conFat.setFiltroDestino(request.getParameter("filtroCidade"));

                if (request.getParameter("tipoProdutos") != null && !request.getParameter("tipoProdutos").isEmpty()) {
                    for (String tipoProduto : request.getParameter("tipoProdutos").split(",")) {
                        int id = Apoio.parseInt(tipoProduto);

                        conFat.getTipoProdutos().add(id);
                    }
                }

                conFat.setApenasComprovanteEntrega(Apoio.parseBoolean(request.getParameter("chkApenasComprovanteEntrega")));
                double totaisFatura = 0;
                double totaisFaturaSelecionadas = 0;
                SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
                DecimalFormat decimalFormat = new DecimalFormat("#,##0.00");

                if (conFat.visualizarCtrcs()) {

                    ResultSet rs = conFat.getResultado();
                    while (rs.next()) {
                        totaisFatura += rs.getDouble("vlduplicata");
                        
                        if (rs.getBoolean("selected")) {
                            totaisFaturaSelecionadas += rs.getDouble("vlduplicata");
                        }
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td>
                    <input name="<%="chk_" + linha%>" type="checkbox" onclick="marcar(this, true)" id="<%="chk_" + linha%>" value="<%=rs.getString("id")%>">
                    <input type="hidden" name="<%="hidden_ctrc_" + rs.getString("ctrc")%>" id="<%="hidden_ctrc_" + rs.getString("ctrc")%>" value="<%=linha%>">
                    <Script>$('chk_'+<%=linha%>).checked = <%=rs.getBoolean("selected")%>;</Script> 
                </td>
                <td><%= rs.getString("categoria").equals("ct") ? "CT-e" + "<br>" + rs.getString("descricao_modal") : (rs.getString("categoria").equals("fn") ? "Receita financeira" : "NF Serviço")%></td>
                <td><%=rs.getString("filial_lan") == null ? "" : rs.getString("filial_lan")%></td>
                <td><label id="numeroDoc_<%=linha%>" ><%=rs.getString("ctrc") + "-" + rs.getString("serie")%></label></td>
                <td><div align="center"><%=rs.getString("num_dup")%></div></td>
                <td><%=formato.format(rs.getDate("dtemissao"))%></td>
                <td><%=rs.getString("remetente")%></td>
                <td><%=rs.getString("destinatario")%></td>
                <td><div align="right" id="valorCtrc_<%=linha%>"><%=decimalFormat.format(rs.getDouble("vlduplicata"))%></div></td>
                <td><%=(rs.getDate("dtfechamento") == null ? "" : formato.format(rs.getDate("dtfechamento")))%></td>
            </tr>
            <%          linha++;
                    }
                }
            %>
            <script language="javascript">
                quant = <%=linha++%>
            </script>

            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="8">
                    <div align="right">
                        <label><strong>Total selecionado:</strong></label>
                    </div>
                </td>
                <td colspan="1">
                    <div align="right">
                        <label id="lblTotalSelecionado"><%=decimalFormat.format(totaisFaturaSelecionadas)%></label>
                        <input type="hidden" id="totaisFatura" name="totaisFatura" value="<%= totaisFatura %>">
                    </div>
                </td>
                <td colspan="1"></td>
            </tr>

            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="11"><div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
                    </div></td>
            </tr>
        </table>
        </form>
        <div class="localiza">
            <iframe id="localizarTipoProduto" input="tipo_produtos" name="localizarTipoProduto" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarTipoProduto" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="cobre-tudo"></div>
        <script>
            jQuery(document).ready(function() {
                jQuery('#tipo_produtos').inputMultiploGw({
                    readOnly: 'true',
                    is_old: true
                });
            });
        </script>
    </body>
</html>
