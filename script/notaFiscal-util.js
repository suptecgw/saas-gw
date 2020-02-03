/**
	Mï¿½todos ï¿½teis para manipulacao de notas fiscais em um cadastro.
*/

/*--- Variaveis globais ---*/
var indexesForColeta = new Array();
var countItemNota = 0;
var callNumeroNotaFiscal = "verificaNumeroNotaFiscal(this)";

/**Retorna o prï¿½ximo ID da table*/
function getNextIndexFromTableRoot(idColeta, idTableRoot) {
    if (getObj("trNote1_id"+idColeta) == null)
        return 1;

    var r = 2;
    while (getObj("trNote"+r+"_id"+idColeta) != null)
        ++r;

    return r;
}

function getLastIndexFromTableRoot(idColeta, idTableRoot) {
    var r = 1;
    while (getObj("trNote"+r+"_id"+idColeta) != null)
        ++r;

    return r-1;
}

function toInt(valor){
    if (valor.indexOf('.') > -1)
        return valor.substring(0,valor.indexOf('.') );
    else
        return valor;
}

function localizaNota(evento,sufix, isPossuiItens,idColetaConhecimento){
    var numero = $("nf_numero"+sufix).value;
    var idnota = $("nf_idnota_fiscal"+sufix).value;
    var cliente = "0";
    
    if ($("idremetente_cl") != null){
        cliente = $("idremetente_cl").value;
    }else if ($("idremetente") != null){
        cliente = $("idremetente").value;
    }
    
    if (isPossuiItens == 'false'){
        return false;
    }

    if(evento.keyCode == 13 && numero != "" && idnota == "0") {
        if (cliente == "0" || cliente == ""){
            return alert("Informe o cliente corretamente.");
        }

        espereEnviar("",true);
        if ($(numero) != null){
            espereEnviar("",false);
            return alert("A nota fiscal " + numero + " já foi inclusa.");
        }
        
        new Ajax.Request("./cadcoleta.jsp?acao=getNotaByNumero&numero="+ numero + "&cliente="+cliente,
        {
            method:"get",
            onSuccess: function(transport){
                var response = transport.responseText;
                carregaNotaAjax(response, sufix, idColetaConhecimento);
            },
            onFailure: function(){ }
        });
    }
}

var tarifas = {};
function carregaNotaAjax(textoresposta,sufix,idColetaConhecimento){
    try {
        
        //var textoresposta = transport.responseText;
        espereEnviar("",false);
    
        if (textoresposta == "load=0") {    
            //fechaClientesWindow(); // Ã© necessÃ¡rio?
            if ($('idremetente_cl') != null){
                return alert("Não foi encontrada nenhuma nota fiscal com este número para este cliente.");
            }else{
                $("nf_serie"+sufix).focus();
                $("nf_serie"+sufix).select();
                return false;
            }
        }
        tarifas = eval('('+textoresposta+')');

        //    removeNote("trNote" + sufix);
        //excluir linha nova sem confirm - inicio
        getObj("trNote" + sufix).parentNode.removeChild(getObj("trNote" + sufix));
        getObj("trNoteCte" + sufix).parentNode.removeChild(getObj("trNoteCte" + sufix));
        if(tarifas.is_baixa_entrega_nota == "true" || tarifas.is_baixa_entrega_nota == true){
            getObj("nf_tr2_" + sufix).parentNode.removeChild(getObj("nf_tr2_" + sufix));
        }
    
        //removendo o indice no array(como o array comeï¿½a em 0, subtraimos 1)
        markFlagNote(extractIdColeta("trNote" + sufix), extractIdNote("trNote" + sufix), false);

        //atualizando a soma do peso
        if (window.updateSum != null)
            updateSum(true);
        //excluir linha nova sem confirm - fim


        //var idcoleta = $("idcoleta").value;
        var idcoleta = '0';
        if ($("id_janela") == null || $("id_janela") == undefined) {
            idcoleta = $("idcoleta").value;
        }
        //alert(tarifas.is_baixa_entrega_nota + " ");

        var xTableRoot = ($('idremetente_cl') != null ? 'node_notes' : 'tableNotes0');

        sufix = addNote(idcoleta,
            xTableRoot,
            tarifas.idnota_fiscal,
            tarifas.numero,
            tarifas.serie,
            tarifas.emissao,
            tarifas.valor,
            tarifas.vl_base_icms,
            tarifas.vl_icms,
            tarifas.vl_icms_st,
            tarifas.vl_icms_frete,
            tarifas.peso,
            tarifas.volume,
            tarifas.embalagem,
            tarifas.descricao_produto,
            '0',
            tarifas.pedido,
            false,
            tarifas.largura,
            tarifas.altura,
            tarifas.largura,
            tarifas.comprimento,
            tarifas.idmarca,
            tarifas.desc_marca,
            tarifas.modelo_veiculo,
            tarifas.ano_veiculo,
            tarifas.cor_veiculo,
            tarifas.chassi_veiculo,
            '0',
            'true',
            tarifas.cfop_id,
            tarifas.cfop,
            tarifas.chave_acesso,
            "false", // is agendado
            "", // data agendamento
            "",// hora agendamento
            "", // obs agenda
            tarifas.is_baixa_entrega_nota,
            "",//Previsao entrega
            "",// Hora previsao entrega
            tarifas.id_destinatario,
            tarifas.destinatario,
            true,
            "0",//maxItensMetro
            "0" //minuta
            );
        

if (countIdxNotes != null){
            countIdxNotes++;
        }

        if ($('idremetente_cl') != null) {
            addNewNote(idColetaConhecimento,'node_notes','true',tarifas.is_baixa_entrega_nota);
        }

        if (countIdxNotes != null){
            countIdxNotes++;
            if (window.totaisNotas != null){
                totaisNotas();
            }
            if ($('idremetente') != null) {
                if ($('vlmercadoria') != null) {
                    $('vlmercadoria').value = sumValorNotes('0');
                }
                if ($('peso') != null) {
                    $('peso').value = sumPesoNotes('0');
                }
                if ($("volume") != null) {
                    $("volume").value = sumVolumeNotes('0');
                }
                if (window.alteraTipoTaxa != null){
                    alteraTipoTaxa($("tipotaxa").value);
                }
            }
        }

        espereEnviar("",false);
    } catch (e) { 
        alert(e.message);
        espereEnviar("",false);
    }
}

//Função para mudar o tipo de nota_fiscal quando tiver chave de acesso.
function mudarNF(index){
    if($("nf_chave_nf"+index) != "" && $("nf_chave_nf"+index) != null && $("nf_chave_nf"+index) != undefined){
       if ($("nf_chave_nf"+index).value.substring(20,22) == '55'){
           $("nf_tipoDocumento"+index).value = "NE";
       } 
    }
    //if($("nf_chave_nf"+index).value == ""){
       //$("nf_tipoDocumento"+index).value = "NF";
    //}
}

/**@exemplo - addNote(idColeta, idTableRoot, idnota_fiscal, numero, serie, emissao, valor, vl_base_icms,
                    vl_icms, vl_icms_st, vl_icms_frete, peso, volume, embalagem, conteudo, idCTRC)*/

var isFocoNF = false;
var contadorNf=0;
function addNote(idColeta,idTableRoot, idnota_fiscal,
    numero, serie, emissao,
    valor, vl_base_icms,vl_icms,
    vl_icms_st,vl_icms_frete,peso,
    volume, embalagem, descricao_produto,
    idCTRC, pedido, readOnly,
    largura, altura, comprimento,
    metroCubico, idMarcaVeiculo, marcaVeiculo,
    modeloVeiculo, anoVeiculo, corVeiculo,
    chassiVeiculo,maxItens,isPossuiItens,
    cfopId,cfop,chaveNFe,
    isAgendado, dataAgenda, horaAgenda,
    obsAgenda, isBaixaNota, previsaoEntrega, previsaoAs,
    idDestinatario, destinatario, isEdi,maxItensMetro, minutaId, tpDoc, 
    placa, veiculoNovo, corFab, marcaModelo, travarCampos)
{
    
    try{
        
    readOnly = (readOnly == undefined || readOnly == null || readOnly == 'f' || readOnly == 'false' ? false : readOnly);
    isEdi = (isEdi == undefined || isEdi == null || isEdi == 'f' || isEdi == 'false' ? false : isEdi);
    travarCampos = (travarCampos == undefined || travarCampos == null || travarCampos == 'f' || travarCampos == 'false' ? false : travarCampos);
    var tableRoot = getObj(idTableRoot);
    var indice = getNextIndexFromTableRoot(idColeta, idTableRoot);
    
    contadorNf++;
    if ($("contadorNF") != null && $("contadorNF") != undefined) {
        $("contadorNF").innerHTML = contadorNf;
    }
    //alert(idColeta + " - " + idTableRoot);
    
    //simplificando na hora da chamada
    var sufixID = indice+"_id"+idColeta;
    var nameTR = "trNote" + sufixID;

    var trNote = makeElement("TR", "class=colorClear&id="+nameTR);
    var trNote3 = makeElement("TR", "class=colorClear&id="+nameTR);

    //fabricando o botãoo de excluir
    //appendObj(trNote, makeWithTD("IMG","src=img/cancelar.png&border=0&onclick=removeNote('"+nameTR+"')&class=imagemLink&title=Remover esta nota"));
    var tdDel = Builder.node("td",{
        align:"left"
    });
    var imgDel = Builder.node("img", {
        src:"img/lixo.png",
        id:"lbRemoveNF"+sufixID,
        name:"lbRemoveNF"+sufixID,
        border:"0",
        onClick:"removeNote('"+nameTR+"','nf_tr2_"+sufixID+"');calcularFreteCarreteiro()",
        className:"imagemLink",
        title:"Remover esta nota"
    });
    var maxItem = Builder.node("input", {
        type:"hidden",
        id:"maxItens"+sufixID,
        name:"maxItens"+sufixID,
        value:maxItens
    });
    
    var maxItemMetro = Builder.node("input", {
        type:"hidden",
        id:"maxItensMetro"+sufixID,
        name:"maxItensMetro"+sufixID,
        value:maxItensMetro
    });
    
    
    var numeroH = Builder.node("input", {
        type:"hidden",
        id:numero,
        name:numero,
        value:""
    });
    var minutaId = Builder.node("input", {
        type:"hidden",
        id:"minutaId_"+sufixID,
        name:"minutaId_"+sufixID,
        value:minutaId+""
    });
    
    tdDel.appendChild(numeroH);
    tdDel.appendChild(maxItem);
    tdDel.appendChild(maxItemMetro);
    tdDel.appendChild(minutaId);
    tdDel.appendChild(imgDel);
    trNote.appendChild(tdDel);

    //appendObj(trNote, makeWithTD("IMG","src=img/page_edit.png&name=nf_edit"+sufixID+"&id=nf_edit"+sufixID+"&border=0&onclick=editNote('"+sufixID+"')&class=&title=imagemLink&Visualizar todos os dados dessa nota"));
    var tdEdit = Builder.node("td",{
        align:"left"
    });
    var imgEdit = Builder.node("img", {
        src:"img/page_edit.png",
        name:"nf_edit"+sufixID,
        id:"nf_edit"+sufixID,
        border:"0",
        onClick:"editNote('"+sufixID+"','"+isPossuiItens+"','"+isBaixaNota+"','"+readOnly+"','"+isEdi+"', '" + travarCampos + "')",
        className:"imagemLink",
        title:"Visualizar todos os dados dessa nota"
    });
    tdEdit.appendChild(imgEdit);
    trNote.appendChild(tdEdit);
    //-------------------------------------------------------------------------- Visualizar Nota Fiscal
    var tdVisualizar = Builder.node("td",{
        align:"left"
    });
    var imgVisualizar = Builder.node("img", {
        src:"img/lupa.gif",
        name:"nf_visualizar"+sufixID,
        id:"nf_visualizar"+sufixID,
        border:"0",
        onClick:"visualizarNota("+ idnota_fiscal +")",
        className:"imagemLink",
        title:"Visualizar Dados da Nota Fiscal"
    });
    tdVisualizar.appendChild(imgVisualizar);
    trNote.appendChild(tdVisualizar);
//
    //<img id="lupa_5350" class="imagemLink" align="right" onclick="javascript:tryRequestToServer(function(){mostrarDetalhes('000001');});" title="Mostrar todos os detalhes" name="lupa_5350" src="img/lupa.gif">
    
//appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_numero"+sufixID+"&id=nf_numero"+sufixID+"&maxLength=30&size=8&value="+numero));
    //appendObj(trNote, makeElement("INPUT","type=hidden&name=nf_idnota_fiscal"+sufixID+"&id=nf_idnota_fiscal"+sufixID+"&value="+idnota_fiscal));
    var tdNote = Builder.node("td",{
        align:"left"
    });
    var inNote = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_numero"+sufixID,
        name:"nf_numero"+sufixID,
        maxLength:"30",
        size:"8",
        key: indice,
        onblur: callNumeroNotaFiscal,
        onkeypress:(isPossuiItens == "true" ? "localizaNota(event,'"+sufixID+"','"+isPossuiItens+"','"+idColeta+"')" : ""),
        onchange:"javascript:seNaoIntReset(this,'')",
        value:numero
    });
    
    if ((travarCampos == true || travarCampos == 'true' || travarCampos == 't') && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        inNote.readOnly = true;
        inNote.className = 'inputReadOnly8pt'
    }

    var inIdNote = Builder.node("input", {
        type:"hidden",
        id:"nf_idnota_fiscal"+sufixID,
        name:"nf_idnota_fiscal"+sufixID,
        value:idnota_fiscal
    });
    var inImportacaoEDI = Builder.node("input", {
        type:"hidden",
        id:"nf_isImportacaoEDI_"+sufixID,
        name:"nf_isImportacaoEDI_"+sufixID,
        value: isEdi === undefined ? 'false' : isEdi
    });
    tdNote.appendChild(inNote);
    tdNote.appendChild(inIdNote);
    tdNote.appendChild(inImportacaoEDI);
    trNote.appendChild(tdNote);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_serie"+sufixID+"&id=nf_serie"+sufixID+"&maxLength=3&size=4&value="+serie));
    var tdSerie = Builder.node("td",{
        align:"left"
    });
    var inSerie = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_serie"+sufixID,
        name:"nf_serie"+sufixID,
        maxLength:"3",
        size:"4",
        value:serie
    });

    if (travarCampos === 'true' && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        inSerie.readOnly = true;
        inSerie.className = 'inputReadOnly8pt'
    }

    tdSerie.appendChild(inSerie);
    trNote.appendChild(tdSerie);

    var nf_emissao_ob = "$('nf_emissao"+sufixID+"')";
    var nf_agenda_ob = "$('nf_data_agenda"+sufixID+"')";
    var nf_previsao_em_ob = "$('nf_previsao_em"+sufixID+"')";
    //appendObj(trNote, makeWithTD("INPUT", "type=text&class=fieldMin&name=nf_emissao"+sufixID+"&id=nf_emissao"+sufixID+"&maxLength=10&size=13&value="+emissao+"&onblur=alertInvalidDate("+nf_emissao_ob+")&onkeydown=fmtDate("+nf_emissao_ob+", event)&onkeyUp=fmtDate("+nf_emissao_ob+", event)&onkeypress=fmtDate("+nf_emissao_ob+", event)"));
    var tdEmissao = Builder.node("td",{
        align:"left"
    });
    var inEmissao = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_emissao"+sufixID,
        name:"nf_emissao"+sufixID,
        maxLength:"10",
        size:"10",
        value:emissao,
        onBlur:"alertInvalidDate("+nf_emissao_ob+")",
        onKeyDown:"fmtDate("+nf_emissao_ob+", event)",
        onKeyUp:"fmtDate("+nf_emissao_ob+", event)",
        onKeyPress:"fmtDate("+nf_emissao_ob+", event)"
    });
    tdEmissao.appendChild(inEmissao);
    trNote.appendChild(tdEmissao);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_valor"+sufixID+"&id=nf_valor"+sufixID+"&maxLength=11&size=10"+commonField+"nf_valor"+commonSufix + "&value="+formatoMoeda(valor)));
    var tdValor = Builder.node("td",{
        align:"left"
    });
    var inValor = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_valor"+sufixID,
        name:"nf_valor"+sufixID,
        maxLength:"11",
        size:"10",
        value:formatoMoeda(valor),
        onChange:"seNaoFloatReset(this,'0.00')"
    });

    if ((travarCampos == true || travarCampos == 'true' || travarCampos == 't') && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        inValor.readOnly = true;
        inValor.className = 'inputReadOnly8pt'
    }
        
    tdValor.appendChild(inValor);
    trNote.appendChild(tdValor);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_peso"+sufixID+"&id=nf_peso"+sufixID+"&maxLength=10&size=9"+commonField+"nf_peso"+commonSufix + "&value="+peso));
    var tdPeso = Builder.node("td",{
        align:"left"
    });
    var inPeso = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_peso"+sufixID,
        name:"nf_peso"+sufixID,
        maxLength:"10",
        size:"9",
        value: roundABNT(peso,3),
        onBlur: "calcularFreteCarreteiro()",
        onChange:"seNaoFloatReset(this,'0.00')"
    });

    if ((travarCampos == true || travarCampos == 'true' || travarCampos == 't') && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        inPeso.readOnly = true;
        inPeso.className = 'inputReadOnly8pt'
    }

    tdPeso.appendChild(inPeso);
    trNote.appendChild(tdPeso);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_volume"+sufixID+"&id=nf_volume"+sufixID+"&maxLength=10&size=7"+commonField+"nf_volume"+commonSufix + "&value="+volume));
    var tdVolume = Builder.node("td",{
        align:"left"
    });
    var inVolume = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_volume"+sufixID,
        name:"nf_volume"+sufixID,
        maxLength:"10",
        size:"7",
        value: roundABNT(volume,4),
        onChange:"seNaoFloatReset(this,'0.00')"
    });

    if ((travarCampos == true || travarCampos == 'true' || travarCampos == 't') && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        inVolume.readOnly = true;
        inVolume.className = 'inputReadOnly8pt'
    }

    tdVolume.appendChild(inVolume);
    trNote.appendChild(tdVolume);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_embalagem"+sufixID+"&id=nf_embalagem"+sufixID+"&maxLength=20&size=17&value="+embalagem));
    var tdEmbalagem = Builder.node("td",{
        align:"left"
    });
    var inEmbalagem = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_embalagem"+sufixID,
        name:"nf_embalagem"+sufixID,
        maxLength:"20",
        size:"17",
        value:embalagem
    });
    tdEmbalagem.appendChild(inEmbalagem);
    trNote.appendChild(tdEmbalagem);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_conteudo"+sufixID+"&id=nf_conteudo"+sufixID+"&maxLength=30&size=20&value=" + conteudo));
    var tdConteudo = Builder.node("td",{
        align:"center"
    });
    
//    var inConteudo = Builder.node("input", {
//        type:"text",
//        className:"fieldMin",
//        id:"nf_conteudo"+sufixID,
//        name:"nf_conteudo"+sufixID,
//        maxLength:"30",
//        size:"17",
//        value:conteudo
//    });

    var inConteudo = Builder.node("input", {
        type:"text",
        id:"nf_conteudo"+sufixID,
        name:"nf_conteudo"+sufixID,
        size:"10",
        maxLength:"60",
        className:"fieldMin",        
        value: (descricao_produto == null || descricao_produto == undefined ? "" : descricao_produto)
    });
    
    var btLocalizaProdCtrcNf = Builder.node("input", {
        type:"button",
        id:"nf_prod_localiza"+sufixID,
        name:"nf_prod_localiza"+sufixID,
        className:"botoes",
        onClick:"javascript:localizarProdutoCtrcNF('"+ sufixID +"');",
        value:"..."
    });

    var labelProduto = Builder.node("label",{});
    labelProduto.innerHTML = "&nbsp;";
    
    tdConteudo.appendChild(inConteudo);
    tdConteudo.appendChild(labelProduto);
    tdConteudo.appendChild(btLocalizaProdCtrcNf);
    trNote.appendChild(tdConteudo);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_base_icms"+sufixID+"&id=nf_base_icms"+sufixID+"&maxLength=10&size=7"+commonField+"nf_base_icms"+commonSufix + "&value=" + formatoMoeda(vl_base_icms)));
    var tdBaseIcms = Builder.node("td",{
        align:"left"
    });
    var inBaseIcms = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_base_icms"+sufixID,
        name:"nf_base_icms"+sufixID,
        maxLength:"10",
        size:"7",
        value:formatoMoeda(vl_base_icms),
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdBaseIcms.appendChild(inBaseIcms);
    trNote.appendChild(tdBaseIcms);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_icms"+sufixID+"&id=nf_icms"+sufixID+"&maxLength=10&size=7"+commonField+"nf_icms"+commonSufix + "&value="+formatoMoeda(vl_icms)));
    var tdIcms = Builder.node("td",{
        align:"left"
    });
    var inIcms = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_icms"+sufixID,
        name:"nf_icms"+sufixID,
        maxLength:"10",
        size:"7",
        value:formatoMoeda(vl_icms),
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcms.appendChild(inIcms);
    trNote.appendChild(tdIcms);

    //appendObj(trNote, makeWithTD("INPUT", commonObj + "&name=nf_icms_st"+sufixID+"&id=nf_icms_st"+sufixID+"&maxLength=10&size=7"+commonField+"nf_icms_st"+commonSufix + "&value="+formatoMoeda(vl_icms_st)));
    var tdIcmsSt = Builder.node("td",{
        align:"left"
    });
    var tdNfVeiculo = Builder.node("td",{
        align:"left"
    });
    var inIcmsSt = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_icms_st"+sufixID,
        name:"nf_icms_st"+sufixID,
        maxLength:"10",
        size:"7",
        value:formatoMoeda(vl_icms_st),
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcmsSt.appendChild(inIcmsSt);

    var inIcmsFrete = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_icms_frete"+sufixID,
        name:"nf_icms_frete"+sufixID,
        maxLength:"10",
        size:"7",
        value:formatoMoeda(vl_icms_frete),
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcmsSt.appendChild(inIcmsFrete);

    //appendObj(trNote, makeElement("INPUT", "type=hidden&name=nf_largura"+sufixID+"&id=nf_largura"+sufixID+"&maxLength=10&size=7&value="+formatoMoeda(largura)));
    var inLargura = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_largura"+sufixID,
        name:"nf_largura"+sufixID,
        maxLength:"10",
        size:"7",
        value:largura,
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcmsSt.appendChild(inLargura);
    //appendObj(trNote, makeElement("INPUT", "type=hidden&name=nf_altura"+sufixID+"&id=nf_altura"+sufixID+"&maxLength=10&size=7&value="+formatoMoeda(altura)));
    var inAltura = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_altura"+sufixID,
        name:"nf_altura"+sufixID,
        maxLength:"10",
        size:"7",
        value:altura,
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcmsSt.appendChild(inAltura);
    //appendObj(trNote, makeElement("INPUT", "type=hidden&name=nf_comprimento"+sufixID+"&id=nf_comprimento"+sufixID+"&maxLength=10&size=7&value="+formatoMoeda(comprimento)));
    var inComprimento = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_comprimento"+sufixID,
        name:"nf_comprimento"+sufixID,
        maxLength:"10",
        size:"7",
        value:comprimento,
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcmsSt.appendChild(inComprimento);

    //appendObj(trNote, makeElement("INPUT", "type=hidden&name=nf_metroCubico"+sufixID+"&id=nf_metroCubico"+sufixID+"&maxLength=10&size=7&value="+formatoMoeda(metroCubico)));
    var inMetro = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_metroCubico"+sufixID,
        name:"nf_metroCubico"+sufixID,
        maxLength:"10",
        size:"7",
        value:metroCubico,
        onChange:"seNaoFloatReset(this,'0.00')"
    });
    tdIcmsSt.appendChild(inMetro);

    var inIdMarcaVeiculo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_id_marca_veiculo"+sufixID,
        name:"nf_id_marca_veiculo"+sufixID,
        maxLength:"10",
        size:"7",
        value:idMarcaVeiculo
    });
    tdIcmsSt.appendChild(inIdMarcaVeiculo);

    var inMarcaVeiculo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_marca_veiculo"+sufixID,
        name:"nf_marca_veiculo"+sufixID,
        maxLength:"10",
        size:"7",
        value:marcaVeiculo
    });
    tdIcmsSt.appendChild(inMarcaVeiculo);

    var inModeloVeiculo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_modelo_veiculo"+sufixID,
        name:"nf_modelo_veiculo"+sufixID,
        maxLength:"30",
        size:"7",
        value:modeloVeiculo
    });
    tdIcmsSt.appendChild(inModeloVeiculo);

    var inAnoVeiculo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_ano_veiculo"+sufixID,
        name:"nf_ano_veiculo"+sufixID,
        maxLength:"30",
        size:"7",
        value:anoVeiculo
    });
    tdIcmsSt.appendChild(inAnoVeiculo);

    var inCorVeiculo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_cor_veiculo"+sufixID,
        name:"nf_cor_veiculo"+sufixID,
        maxLength:"30",
        size:"7",
        value:corVeiculo
    });
    tdIcmsSt.appendChild(inCorVeiculo);

    var inChassiVeiculo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_chassi_veiculo"+sufixID,
        name:"nf_chassi_veiculo"+sufixID,
        maxLength:"30",
        size:"7",
        value:chassiVeiculo
    });
    tdIcmsSt.appendChild(inChassiVeiculo);
    
    var inPlaca = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_placa_veiculo"+sufixID,
        name:"nf_placa_veiculo"+sufixID,
        maxLength:"30",
        size:"7",
        value:(placa==undefined? "": placa)
    });
    tdNfVeiculo.appendChild(inPlaca);
    
    
    var inVeiculoNovo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_veiculo_novo"+sufixID,
        name:"nf_veiculo_novo"+sufixID,
        maxLength:"30",
        size:"7",
        value:(veiculoNovo == null || veiculoNovo == undefined ? '' : veiculoNovo)
    });  
    tdNfVeiculo.appendChild(inVeiculoNovo);
    
    var inCorFab = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_cor_fab"+sufixID,
        name:"nf_cor_fab"+sufixID,
        maxLength:"30",
        size:"7",
        value:(corFab==undefined? "": corFab)
    });  
    tdNfVeiculo.appendChild(inCorFab);
    
    var inMarcaModelo = Builder.node("input", {
        type:"hidden",
        className:"fieldMin",
        id:"nf_marcamodelo_veiculo"+sufixID,
        name:"nf_marcamodelo_veiculo"+sufixID,
        maxLength:"30",
        size:"7",
        value:(marcaModelo==undefined? "": marcaModelo)
    });  
    tdNfVeiculo.appendChild(inMarcaModelo);  

    if (isBaixaNota == "false" || isBaixaNota == false){
        var inPrevisaoEntrega = Builder.node("input", {
            type:"hidden",
            id:"nf_previsao_entrega"+sufixID,
            name:"nf_previsao_entrega"+sufixID,
            value:previsaoEntrega
        });
        tdIcmsSt.appendChild(inPrevisaoEntrega);

        var inPrevisaoAs = Builder.node("input", {
            type:"hidden",
            id:"nf_previsao_as"+sufixID,
            name:"nf_previsao_as"+sufixID,
            onkeypress: "mascaraHora(this)",
            value:previsaoAs
        });
        tdIcmsSt.appendChild(inPrevisaoAs);


        var inDataAgenda = Builder.node("input", {
            type:"hidden",
            id:"nf_data_agenda"+sufixID,
            name:"nf_data_agenda"+sufixID,
            value:dataAgenda
        });
        tdIcmsSt.appendChild(inDataAgenda);

        var inHoraAgenda = Builder.node("input", {
            type:"hidden",
            id:"nf_hora_agenda"+sufixID,
            name:"nf_hora_agenda"+sufixID,
            value:horaAgenda
        });
        tdIcmsSt.appendChild(inHoraAgenda);

        var inDestinatario = Builder.node("input", {
            type:"hidden",
            id:"nf_destinatario"+sufixID,
            name:"nf_destinatario"+sufixID,
            value:destinatario
        });
        tdIcmsSt.appendChild(inDestinatario);

        var inIsAgendado = Builder.node("input", {
            type:"hidden",
            id:"nf_is_agendado"+sufixID,
            name:"nf_is_agendado"+sufixID,
            value:isAgendado
        });
        tdIcmsSt.appendChild(inIsAgendado);

        var inObsAgenda = Builder.node("input", {
            type:"hidden",
            id:"nf_obs_agenda"+sufixID,
            name:"nf_obs_agenda"+sufixID,
            value:obsAgenda
        });
        tdIcmsSt.appendChild(inObsAgenda);
    }
    var inIdDestinatario = Builder.node("input", {
        type:"hidden",
        id:"nf_id_destinatario"+sufixID,
        name:"nf_id_destinatario"+sufixID,
        value:idDestinatario
    });
    tdIcmsSt.appendChild(inIdDestinatario);

    trNote.appendChild(tdIcmsSt);
    trNote3.appendChild(tdNfVeiculo);
    trNote3.style.display = 'none';
    //adicionando a linha na tabela
    tableRoot.lastChild.appendChild(trNote);
    tableRoot.lastChild.appendChild(trNote3);

    var nameTRCte = "trNoteCte" + sufixID;
    var trNoteCte = makeElement("TR", "class=colorClear&id="+nameTRCte);

    var tdCteLbCfop = Builder.node("td",{colSpan:"2"},"CFOP:");
    var tdCteCfop = Builder.node("td",{colSpan:"2"});
    var inCfopId = Builder.node("input", {
        type:"hidden",
        id:"nf_cfopId"+sufixID,
        name:"nf_cfopId"+sufixID,
        value:(cfopId == "null" ? "0" : cfopId)
    });
    tdCteCfop.appendChild(inCfopId);

    var inCfop = Builder.node("input", {
        type:"text",
        id:"nf_cfop"+sufixID,
        name:"nf_cfop"+sufixID,
        size:"4",
        className:"inputReadOnly8pt",
        readOnly:"true",
        value:cfop
    });
    
    var labelCfop = Builder.node("label",{});
    labelCfop.innerHTML = "&nbsp;";

    var btLocalizaCfop = Builder.node("input", {
        type:"button",
        id:"nf_cfop_localiza"+sufixID,
        name:"nf_cfop_localiza"+sufixID,
        className:"botoes",
        onClick:"javascript:localizacfopNotaTRCte('"+sufixID+"');",
        value:"..."
    });

    tdCteCfop.appendChild(inCfop);
    tdCteCfop.appendChild(labelCfop);
    tdCteCfop.appendChild(btLocalizaCfop);

    var tdCteLbChave = Builder.node("td",{colSpan:"2"},"Chave de Acesso NF-e:");
    var tdCteChave = Builder.node("td",{colSpan:"3"});

    var inChaveNFe = Builder.node("input", {
        type:"text",
        id:"nf_chave_nf"+sufixID,
        name:"nf_chave_nf"+sufixID,
        className:"fieldMin",
        size:"54",
        maxLength:"44",
        onchange:"javascript:mudarNF('"+sufixID+"');",
        onBlur:"javascript:seNaoIntReset(this,'');",
        value:chaveNFe
    });
    if (travarCampos === 'true' && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        inChaveNFe.readOnly = true;
        inChaveNFe.className = 'inputReadOnly8pt'
    }
    tdCteChave.appendChild(inChaveNFe);
    
    var tdCteLbTpDoc = Builder.node("td","Tipo Documento:");
    var tdCteTpDoc = Builder.node("td",{colSpan:"2"});

    var inTpDoc = Builder.node("select",{id:"nf_tipoDocumento"+sufixID, name:"nf_tipoDocumento"+sufixID, className: "fieldMin"});
    
    var optTpDoc_ = Builder.node("option", {value: 'NF'}, 'NF');
    var optTpDoc4_ = Builder.node("option", {value: 'NE'}, 'NF-e');
    var optTpDoc1_ = Builder.node("option", {value: '00'}, 'Declaração');
    var optTpDoc2_ = Builder.node("option", {value: '10'}, 'Dutoviário');
    var optTpDoc3_ = Builder.node("option", {value: '99'}, 'Outros');
    var optTpDoc5_ = Builder.node("option", {value: '59'}, 'CF-e SAT');
    var optTpDoc6_ = Builder.node("option", {value: '65'}, 'NFC-e');

    inTpDoc.appendChild(optTpDoc_);
    inTpDoc.appendChild(optTpDoc1_);
    inTpDoc.appendChild(optTpDoc2_);
    inTpDoc.appendChild(optTpDoc3_);
    inTpDoc.appendChild(optTpDoc4_);
    inTpDoc.appendChild(optTpDoc5_);
    inTpDoc.appendChild(optTpDoc6_);
    
    //Comentei esse trecho porque o o cliente pode escolher o tipo Outro e colocar a chave de acesso de uma CT-e. Com isso o sistema sempre estava alterando o tipo Para NF-e
    //if(chaveNFe != ""){
       //inTpDoc.value = "NE";
    //}else 
    if(tpDoc!=undefined){
       inTpDoc.value = tpDoc;
    }else{
       inTpDoc.selectedIndex = "NE";
    }
    
    
    tdCteTpDoc.appendChild(inTpDoc);

    var tdCteLbPedido = Builder.node("td","Pedido:");
    var tdCtePedido = Builder.node("td",{colSpan:"2"});

    var inPedido = Builder.node("input", {
        type:"text",
        className:"fieldMin",
        id:"nf_pedido"+sufixID,
        name:"nf_pedido"+sufixID,
        maxLength:"15",
        size:"13",
        value:pedido
    });
    tdCtePedido.appendChild(inPedido);
    
    
    trNoteCte.appendChild(tdCteLbCfop);
    trNoteCte.appendChild(tdCteCfop);
    trNoteCte.appendChild(tdCteLbChave);
    trNoteCte.appendChild(tdCteChave);
    trNoteCte.appendChild(tdCteLbPedido);
    trNoteCte.appendChild(tdCtePedido);
    
    trNoteCte.appendChild(tdCteLbTpDoc);
    trNoteCte.appendChild(tdCteTpDoc);

    //adicionando a linha na tabela
    tableRoot.lastChild.appendChild(trNoteCte);

    if (isBaixaNota == "true" || isBaixaNota == true){
        var trNote2 = Builder.node("tr", {
            id:"nf_tr2_"+ sufixID,
            name:"nf_tr2_"+ sufixID
        });
        var tdnull = Builder.node("td",{
            colSpan:"15"
        });
        var tableNewTr = Builder.node("table",{
            width:"100%",
            border:"0",
            cellpadding:"1",
            cellspacing:"2"
        });
        var trTableNewTr = Builder.node("tr", {
            name: "trTable_" + sufixID,
            id: "trTable_" + sufixID
        });

        //lb data previsao
        var tdLbDataPrevisao = Builder.node("td", {
            width:"12%",
            align:"right",
            className: "colorClear"
        });
        var inLbDataPrevisao = Builder.node("label", {
            name: "lbDataPrevisao_"+sufixID,
            id:"lbDataPrevisao_"+sufixID
        },"Prev. entrega:");
        tdLbDataPrevisao.appendChild(inLbDataPrevisao);

        //data previsao
        var tdDataPrevisao = Builder.node("td", {
            width:"8%",
            className: "colorClear",
            align:"left"
        });
        var inDataPrevisao2 = Builder.node("input", {
            type:"text",
            className:"fieldMin",
            id:"nf_previsao_entrega"+sufixID,
            name:"nf_previsao_entrega"+sufixID,
            maxLength:"10",
            size:"11",
            value:previsaoEntrega,
            onBlur:"alertInvalidDate(this, true)",
            onKeyDown:"fmtDate(this, event)",
            onKeyUp:"fmtDate(this, event)",
            onKeyPress:"fmtDate(this, event)"
        });
        tdDataPrevisao.appendChild(inDataPrevisao2);

        //lb hora previsao
        var tdLbHoraPrevisao = Builder.node("td", {
            width:"2%",
            className: "colorClear",
            align:"right"
        });
        var inLbHoraPrevisao = Builder.node("label", {
            name: "lbHoraPrevisao_"+sufixID,
            id:"lbHoraPrevisao_"+sufixID
        },"às");
        tdLbHoraPrevisao.appendChild(inLbHoraPrevisao);

        //hora previsao
        var tdHoraPrevisao = Builder.node("td", {
            width:"5%",
            className: "colorClear",
            align:"left"
        });
        var inHoraPrevisao2 = Builder.node("input", {
            type:"text",
            className:"fieldMin",
            id:"nf_previsao_as"+sufixID,
            name:"nf_previsao_as"+sufixID,
            maxLength:"5",
            size:"5",
            value:previsaoAs,
            onKeyDown:"mascaraHora(this)",
            onKeyUp:"mascaraHora(this)",
            onKeyPress:"mascaraHora(this)",
            onBlur:"verificaHora(this)"
        });
        tdHoraPrevisao.appendChild(inHoraPrevisao2);

        //lb data agenda
        var tdLbDataAgenda = Builder.node("td", {
            width:"14%",
            className: "colorClear",
            align:"right"
        });
        var ckIsAgendado = Builder.node("input", {
            type:"checkbox",
            id:"ck_is_agendado"+sufixID,
            name:"ck_is_agendado"+sufixID,
            onClick:"clickAgendado('"+sufixID+"');"
        });
        var inIsAgendado = Builder.node("input", {
            type:"hidden",
            id:"nf_is_agendado"+sufixID,
            name:"nf_is_agendado"+sufixID,
            value:isAgendado
        });
        var inLbDataAgenda = Builder.node("label", {
            name: "lbDataAgenda_"+sufixID,
            id:"lbDataAgenda_"+sufixID
        },"Agendado para:");
        tdLbDataAgenda.appendChild(ckIsAgendado);
        tdLbDataAgenda.appendChild(inIsAgendado);
        tdLbDataAgenda.appendChild(inLbDataAgenda);

        //data agenda
        var tdDataAgenda = Builder.node("td", {
            width:"8%",
            className: "colorClear",
            align:"left"
        });
        var inDataAgenda2 = Builder.node("input", {
            type:"text",
            className:"fieldMin",
            id:"nf_data_agenda"+sufixID,
            name:"nf_data_agenda"+sufixID,
            maxLength:"10",
            size:"11",
            value:dataAgenda,
            onBlur:"alertInvalidDate("+nf_agenda_ob+",true)",
            onKeyDown:"fmtDate("+nf_agenda_ob+", event)",
            onKeyUp:"fmtDate("+nf_agenda_ob+", event)",
            onKeyPress:"fmtDate("+nf_agenda_ob+", event)"
        });
        tdDataAgenda.appendChild(inDataAgenda2);

        //lb hora agenda
        var tdLbHoraAgenda = Builder.node("td", {
            width:"2%",
            className: "colorClear",
            align:"right"
        });
        var inLbHoraAgenda = Builder.node("label", {
            name: "lbHoraAgenda_"+sufixID,
            id:"lbHoraAgenda_"+sufixID
        },"às");
        tdLbHoraAgenda.appendChild(inLbHoraAgenda);

        //hora agenda
        var tdHoraAgenda = Builder.node("td", {
            width:"5%",
            className: "colorClear",
            align:"left"
        });
        var inHoraAgenda2 = Builder.node("input", {
            type:"text",
            className:"fieldMin",
            id:"nf_hora_agenda"+sufixID,
            name:"nf_hora_agenda"+sufixID,
            maxLength:"5",
            size:"5",
            value:horaAgenda,
            onKeyDown:"mascaraHora(this)",
            onKeyUp:"mascaraHora(this)",
            onKeyPress:"mascaraHora(this)",
            onBlur:"verificaHora(this)"
        });
        tdHoraAgenda.appendChild(inHoraAgenda2);

        //Label OBS
        var tdLbObs = Builder.node("td", {
            width:"4%",
            className: "colorClear",
            align:"right"
        });
        var inLbObs = Builder.node("label", {
            name: "lbObs_"+sufixID,
            id:"lbObs_"+sufixID
        },"OBS:");
        tdLbObs.appendChild(inLbObs);

        //Observacao
        var tdObs = Builder.node("td", {
            width:"20%",
            className: "colorClear",
            align:"left"
        });
        var inObsAgenda = Builder.node("input", {
            type:"text",
            id:"nf_obs_agenda"+sufixID,
            name:"nf_obs_agenda"+sufixID,
            size:"32",
            className:"fieldMin",
            value:obsAgenda
        });
        tdObs.appendChild(inObsAgenda);

        //Label Destinatï¿½rio
        var tdLbDest = Builder.node("td", {
            width:"4%",
            className: "colorClear",
            align:"right"
        });
        var inLbDest = Builder.node("label", {
            name: "lbDest_"+sufixID,
            id:"lbDest_"+sufixID
        },"Dest.:");
        tdLbDest.appendChild(inLbDest);

        //Destinatï¿½rio
        var tdDest = Builder.node("td", {
            width:"14%",
            className: "colorClear",
            align:"left"
        });
        var inDest = Builder.node("input", {
            type:"text",
            id:"nf_destinatario"+sufixID,
            name:"nf_destinatario"+sufixID,
            className:"inputReadOnly8pt",
            readOnly:"true",
            size:"21",
            value:destinatario
        });
        tdDest.appendChild(inDest);

        trTableNewTr.appendChild(tdLbDataPrevisao);
        trTableNewTr.appendChild(tdDataPrevisao);
        trTableNewTr.appendChild(tdLbHoraPrevisao);
        trTableNewTr.appendChild(tdHoraPrevisao);
        trTableNewTr.appendChild(tdLbDataAgenda);
        trTableNewTr.appendChild(tdDataAgenda);
        trTableNewTr.appendChild(tdLbHoraAgenda);
        trTableNewTr.appendChild(tdHoraAgenda);
        trTableNewTr.appendChild(tdLbObs);
        trTableNewTr.appendChild(tdObs);
        trTableNewTr.appendChild(tdLbDest);
        trTableNewTr.appendChild(tdDest);

        var _aTBody = Builder.node("tbody", {
            id: "body_"+sufixID,
            name:"body_"+sufixID
        }); // cria uma tbody com o id da linha vigente, para futuro uso com o metodo addEnderecamento
        
        _aTBody.appendChild(trTableNewTr);
        //inserimdo a tr na table
        tableNewTr.appendChild(_aTBody);
        //inserindo a table na td
        tdnull.appendChild(tableNewTr);
        //inserindo a nova td na linha
        trNote2.appendChild(tdnull);
        tableRoot.lastChild.appendChild(trNote2);
    
    }
    /*
    -- tbody diversas medidas -- inicio 
    var _trNote3 = Builder.node("tr", {
        id:"nf_tr2_"+ sufixID,
        name:"nf_tr2_"+ sufixID
    });
    
    var _tdnull_2 = Builder.node("td",{
        colSpan:"14"
    });
        
    var _tableNewTr_2 = Builder.node("table",{
        width:"100%",
        border:"0",
        cellpadding:"1",
        cellspacing:"2"
    });
    /-*
    var _trTableNewTr_2 = Builder.node("tr", {
        name: "trTableM_" + sufixID,
        id: "trTableM_" + sufixID
    });
    *-/
    var _aTBody_2 = Builder.node("tbody", {
        id: "bodyM_"+sufixID,
        name:"bodyM_"+sufixID
    }); 
    
    //_aTBody_2.appendChild(_trTableNewTr_2); 
    _tableNewTr_2.appendChild(_aTBody_2);
    _tdnull_2.appendChild(_tableNewTr_2);
    _trNote3.appendChild(_tdnull_2);
    tableRoot.lastChild.appendChild(_trNote3);
     tbody diversas medidas -- fim 
    */
    
    markFlagNote(idColeta, indice, true);

    if (isFocoNF){
        $('nf_numero'+sufixID).focus();
    }
    if(readOnly == true|| readOnly == 't' || readOnly == 'true'){ // ALERTA DE PULO DO GATO, AO INCLUIR MAIS DE 3MIL MINUTAS CAUSAVA UM ERRO COM A CHAMADA DO READONLY NO PROTOTYPE. NÃO RETIRE O 'IF'
        $('nf_peso'+sufixID).readOnly = readOnly;
        $('nf_volume'+sufixID).readOnly = readOnly;
        $('nf_valor'+sufixID).readOnly = readOnly;
        $('lbRemoveNF'+sufixID).style.display = (readOnly ? 'none' : '');
    }

    if (isAgendado == true || isAgendado =='true' && ($('ck_is_agendado'+sufixID) != null)){
        $('ck_is_agendado'+sufixID).checked = true;
    }

    if ((travarCampos == true || travarCampos == 'true' || travarCampos == 't') && (isEdi == true || isEdi =='true' || isEdi =='t')){
        $('nf_numero'+sufixID).readOnly = true;
        $('nf_serie'+sufixID).readOnly = true;
        $('nf_emissao'+sufixID).readOnly = true;
        $('nf_valor'+sufixID).readOnly = true;
        $('nf_peso'+sufixID).readOnly = true;
        $('nf_volume'+sufixID).readOnly = true;
        $('nf_base_icms'+sufixID).readOnly = true;
        $('nf_icms'+sufixID).readOnly = true;
        $('nf_icms_st'+sufixID).readOnly = true;
        $('nf_icms_frete'+sufixID).readOnly = true;

        $('nf_numero'+sufixID).className = 'inputReadOnly8pt';
        $('nf_serie'+sufixID).className = 'inputReadOnly8pt';
        $('nf_emissao'+sufixID).className = 'inputReadOnly8pt';
        $('nf_valor'+sufixID).className = 'inputReadOnly8pt';
        $('nf_peso'+sufixID).className = 'inputReadOnly8pt';
        $('nf_volume'+sufixID).className = 'inputReadOnly8pt';
        $('nf_base_icms'+sufixID).className = 'inputReadOnly8pt';
        $('nf_icms'+sufixID).className = 'inputReadOnly8pt';
        $('nf_icms_st'+sufixID).className = 'inputReadOnly8pt';
        $('nf_icms_frete'+sufixID).className = 'inputReadOnly8pt';
    }
    //var qtdNF = $("qtdNF").innerHTML.replace("(", "").replace(")", "");
    if($("qtdNF")!=null)
        $("qtdNF").innerHTML = "("+indice+")";
    //chamando um possivel metodo que aplica eventos em alguns campos da nota adicionada
    if (window.applyEventInNote != null){
        applyEventInNote(idColeta);
    }
    }catch(e){
        console.log(e);
    }
    return sufixID;
}

function clickAgendado(sufixID){
    if ($('ck_is_agendado'+sufixID).checked){
        $('nf_is_agendado'+sufixID).value = 'true';
        if ($('nf_previsao_entrega'+sufixID).value != ''){
            $('nf_data_agenda'+sufixID).value = $('nf_previsao_entrega'+sufixID).value;
            $('nf_hora_agenda'+sufixID).value = $('nf_previsao_as'+sufixID).value;
        }
    }else{
        $('nf_is_agendado'+sufixID).value = 'false';
    }
}

function addUpdateNotaFiscal2(tr,idNota,id,sufix,descricao,quant,valor,count,idProdNota,basePallet,alturaPallet){
    var j = sufix+count;
    
    var trNota = getObj(tr);

    var _a = Builder.node("input", {
        type:"hidden",
        id:"itemIdNota_"+j,
        name:"itemIdNota_"+j,
        value:idNota
    });
    var _b = Builder.node("input", {
        type:"hidden",
        id:"itemId_"+j,
        name:"itemId_"+j,
        value:id
    });
    //Id do produto caso o  usuári tenha selecionado pelo localizar produto.
    var inputIdProdutoNota = Builder.node("input", {
        type:"hidden",
        id:"produtoId"+j,
        name:"produtoId"+j,
        value:idProdNota
    });
    
    var _c = Builder.node("input", {
        type:"hidden",
        id:"itemDescricao_"+j,
        name:"itemDescricao_"+j,
        value:descricao
    });
    
    var inputBase = Builder.node("input", {
        type:"hidden",
        id:"basePallet"+ j,
        name:"basePallet"+ j,
        value:basePallet
    });
    
    var inputAltura = Builder.node("input", {
        type:"hidden",
        id:"alturaPallet"+ j,
        name:"alturaPallet"+ j,
        value:alturaPallet
    });
    
    var _d = Builder.node("input", {
        type:"hidden",
        id:"itemQuantidade_"+j,
        name:"itemQuantidade_"+j,
        value:quant
    });
    var _e = Builder.node("input", {
        type:"hidden",
        id:"itemValor_"+j,
        name:"itemValor_"+j,
        value:valor
    });
    
    //tableRoot.lastChild.appendChild(trNote);
    trNota.appendChild(_a);
    trNota.appendChild(_b);
    trNota.appendChild(inputIdProdutoNota);//Id do produto caso seja utlizado o localizar produto.
    trNota.appendChild(_c);
    trNota.appendChild(inputBase);//Base da paletização do produto
    trNota.appendChild(inputAltura);//Altura da paletização do produto
    trNota.appendChild(_d);
    trNota.appendChild(_e);

}

function addUpdateNotaFiscal3(tr,idNota,id,sufix,metroCubico,altura,largura,comprimento,volume,etiqueta,count){
    
    var j = sufix+count;
    
    var trNota = getObj(tr);

    var _a = Builder.node("input", {
        type:"hidden",
        id:"nf_metroIdNota_"+j,
        name:"nf_metroIdNota_"+j,
        value:idNota
    });
    
    var _b = Builder.node("input", {
        type:"hidden",
        id:"nf_metroId_"+j,
        name:"nf_metroId_"+j,
        value:id
    });
    
    var _c = Builder.node("input", {
        type:"hidden",
        id:"nf_metroCubico_"+j,
        name:"nf_metroCubico_"+j,
        value:metroCubico
    });
    
    var _d = Builder.node("input", {
        type:"hidden",
        id:"nf_itemAltura_"+j,
        name:"nf_itemAltura_"+j,
        value:altura
    });
    
    var _e = Builder.node("input", {
        type:"hidden",
        id:"nf_metroLargura_"+j,
        name:"nf_metroLargura_"+j,
        value:largura
    });
    
    var _f = Builder.node("input", {
        type:"hidden",
        id:"nf_metroComprimento_"+j,
        name:"nf_metroComprimento_"+j,
        value:comprimento
    });
    
    var _g = Builder.node("input", {
        type:"hidden",
        id:"nf_metroVolume_"+j,
        name:"nf_metroVolume_"+j,
        value:volume
    });

    var _etiqueta = Builder.node("input", {
        type: "hidden",
        id: "nf_metroEtiqueta_" + j,
        name: "nf_metroEtiqueta_" + j,
        value: etiqueta
    });

    //tableRoot.lastChild.appendChild(trNote);
    trNota.appendChild(_a);
    trNota.appendChild(_b);
    trNota.appendChild(_c);
    trNota.appendChild(_d);
    trNota.appendChild(_e);
    trNota.appendChild(_f);
    trNota.appendChild(_g);
    trNota.appendChild(_etiqueta);
}

function addNewNote(idColeta, idTableRoot, isPossuiItens, isBaixaNota,tpDocPadraoRemetente){
/**    var nodes_tr = null;

    if (isBaixaNota == "true" || isBaixaNota == true){
        var posicao = countNotes(idColeta)*2;
        if (isIE()){
            posicao -=1;
        }
        nodes_tr    = (countNotes(idColeta) > 0 ? $(idTableRoot).lastChild.childNodes[posicao].childNodes : null);
    }else{

        nodes_tr    = (countNotes(idColeta) > 0 ? $(idTableRoot).lastChild.lastChild.childNodes : null);
    }

    var hoje = new Date().getDay() + '/' + new Date().getMonth() + '/' + new Date().getYear();
*/

    var qtdNFRepeat = countNotes(idColeta);
    var repeatData  = (qtdNFRepeat > 0? true : false);

    var idxRepeat = 0;
    if (repeatData){
        if ($('nf_emissao'+(qtdNFRepeat)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat;
        } else if ($('nf_emissao'+(qtdNFRepeat-1)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat-1;
        } else if ($('nf_emissao'+(qtdNFRepeat-2)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat-2;
        } else if ($('nf_emissao'+(qtdNFRepeat-3)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat-3;
        } else {
            repeatData = false;
        }
    }

    isFocoNF = true;
    addNote(idColeta,
        idTableRoot,
        "0",
        "",
        (repeatData ? $('nf_serie'+idxRepeat+'_id'+idColeta).value : "1"),
        (repeatData ? $('nf_emissao'+idxRepeat+'_id'+idColeta).value : now()),
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        ( repeatData? $('nf_embalagem'+idxRepeat+'_id'+idColeta).value : ""),
        ( repeatData? $('nf_conteudo'+idxRepeat+'_id'+idColeta).value : ""),
        "0",
        "",
        false,
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0",
        "",
        "",
        "",
        "0",
        "",
        "0",
        isPossuiItens,
        ( repeatData? $('nf_cfopId'+idxRepeat+'_id'+idColeta).value : "0"),
        ( repeatData? $('nf_cfop'+idxRepeat+'_id'+idColeta).value : ""),
        "",
        "false", //is agendado
        "", // data agendado
        "", // hora
        "",// obs
        isBaixaNota,
        "", //previsao entrega
        "", //Previsao as
        "0", //Fornecedor
        "",
        false, //isEdi
        "0" //maxItensMetro
        ,null,
        (repeatData ? $('nf_tipoDocumento' + idxRepeat + '_id' + idColeta).value : (tpDocPadraoRemetente != undefined ? tpDocPadraoRemetente.value : 'NE'))
        , ""
        , false
        , ""
        , ""
        );
}

function addNewNoteMotagem(idColeta, idTableRoot, isPossuiItens, isBaixaNota,tpDocPadraoRemetente){
/*    var nodes_tr = null;

    if (isBaixaNota == "true" || isBaixaNota == true){
        var posicao = countNotes(idColeta)*2;
        //if (isIE()){
        posicao -=1;
        //}
        nodes_tr    = (countNotes(idColeta) > 0 ? $(idTableRoot).lastChild.childNodes[posicao].childNodes : null);
    }else{

        nodes_tr    = (countNotes(idColeta) > 0 ? $(idTableRoot).lastChild.lastChild.childNodes : null);
    }

    var hoje = new Date().getDay() + '/' + new Date().getMonth() + '/' + new Date().getYear();
*/

    var qtdNFRepeat = countNotes(idColeta);
    var repeatData  = (qtdNFRepeat > 0? true : false);

    var idxRepeat = 0;
    if (repeatData){
        if ($('nf_emissao'+(qtdNFRepeat)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat;
        } else if ($('nf_emissao'+(qtdNFRepeat-1)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat-1;
        } else if ($('nf_emissao'+(qtdNFRepeat-2)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat-2;
        } else if ($('nf_emissao'+(qtdNFRepeat-3)+'_id'+idColeta) != null){
            idxRepeat = qtdNFRepeat-3;
        } else {
            repeatData = false;
        }
    }


    isFocoNF = true;
    addNote(idColeta,
        idTableRoot,
        "0",
        "",
        (repeatData ? $('nf_serie'+idxRepeat+'_id'+idColeta).value : "1"),
        (repeatData ? $('nf_emissao'+idxRepeat+'_id'+idColeta).value : now()),
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        ( repeatData? $('nf_embalagem'+idxRepeat+'_id'+idColeta).value : ""),
        ( repeatData? $('nf_conteudo'+idxRepeat+'_id'+idColeta).value : ""),
        "0",
        "",
        false,
        "0.00",
        "0.00",
        "0.00",
        "0.00",
        "0",
        "",
        "",
        "",
        "0",
        "",
        "0",
        isPossuiItens,
        ( repeatData? $('nf_cfopId'+idxRepeat+'_id'+idColeta).value : "0"),
        ( repeatData? $('nf_cfop'+idxRepeat+'_id'+idColeta).value : ""),
        "",
        "false", //is agendado
        "", // data agendado
        "", // hora
        "",// obs
        isBaixaNota,
        "", //previsao entrega
        "", //Previsao as
        "0", //Fornecedor
        "",
        false, //isEdi
        "0", //maxItensMetro
        "",
        (repeatData ? $('nf_tipoDocumento'+idxRepeat+'_id'+idColeta).value : (tpDocPadraoRemetente != undefined ? tpDocPadraoRemetente.value : 'NE'))
        ,""
        ,false
        ,""
        ,""        
        );//colocar aqui o valor do tipo de nota padrao
}

/**Remove uma nota de uma lista*/
function removeNote(nameObj,nameObj2) {
    if (confirm("Deseja mesmo excluir esta Nota Fiscal ?")){
        
 //       var indexNota = nameObj.substring(6,7);
//        alert("indexNota: "+indexNota);
//        alert("trNote "+getObj("trNote"+indexNota));
//        alert("trNote value "+getObj("trNote"+indexNota).value);
        
        
//        if(getObj("trNote"+indexNota)==null){
//           
//            var indexDest =  nameObj.substring(10,11);
//           
//            var elemento = getObj("nf_idnota_fiscal"+indexNota+"_id"+indexDest);
//            var el = getObj("nf_tr2_"+indexNota+"_id"+indexDest);
//            
//            Element.remove(el);
//            Element.remove(getObj("trNoteCte"+indexNota+"_id"+indexDest));         
//            Element.remove(getObj(nameObj));
//            if((removerNotaFiscalAjax != null || removerNotaFiscalAjax != undefined) && elemento!= null && elemento.value != "0" ){
//                removerNotaFiscalAjax(elemento.value);
//            }         
//                               
//        }else{
        
            //nf_idnota_fiscal 
            contadorNf--;
            if ($("contadorNF") != null && $("contadorNF") != undefined) {
                $("contadorNF").innerHTML = contadorNf == 0 ? "": contadorNf;
            }
            var index = nameObj.replace("trNote",""); 
            var elemento = getObj("nf_idnota_fiscal"+index);
            
            getObj(nameObj).parentNode.removeChild(getObj(nameObj));
            if (getObj(nameObj2) != null){
                getObj(nameObj2).parentNode.removeChild(getObj(nameObj2));
                if ($("qtdNF") != null){
                    var qtdNF = $("qtdNF").innerHTML.replace("(", "").replace(")", "");
                    $("qtdNF").innerHTML = "("+(parseInt(qtdNF)-1)+")";
                }
            }
            if (getObj("trNoteCte"+index) != null){
                getObj("trNoteCte"+index).parentNode.removeChild(getObj("trNoteCte"+index));
            }
           
            if (window.diminuirTotal != null || window.diminuirTotal != undefined){
                window.diminuirTotal();
            }
           
            if((removerNotaFiscalAjax != null || removerNotaFiscalAjax != undefined) && elemento!= null && elemento.value != "0" ){
                removerNotaFiscalAjax(elemento.value);
            }
            
            
      //  }
    }
    
    //removendo o indice no array(como o array comeï¿½a em 0, subtraimos 1)
    markFlagNote(extractIdColeta(nameObj), extractIdNote(nameObj), false);
    if (getObj(nameObj2) != null){
        markFlagNote(extractIdColeta(nameObj2), extractIdNote(nameObj2), false);
    }
    //atualizando a soma do peso
    if (window.updateSum != null)
        updateSum(true);
    //Depois que os valores da nota excluida são alterados calcula o total do peso taxado
    if (window.calculaPesoTaxadoCtrc != null || window.calculaPesoTaxadoCtrc != undefined){
        calculaPesoTaxadoCtrc();
    }
    // Mostra pra o usuário a contagem de notas após excluir uma nota.
    
        
}

/**Marca a nota como ativa ou inativa*/
function markFlagNote(idColeta, noteIndex, flagBool)
{
    if (indexesForColeta["id"+idColeta] == null)
        indexesForColeta["id"+idColeta] = new Array();

    indexesForColeta["id"+idColeta][noteIndex] = flagBool;
}

function extractIdColeta(nameObj) {
    return nameObj.substring(nameObj.indexOf("id") + 2);
}

function extractIdNote(nameObj){
    return nameObj.substring(6, nameObj.indexOf("_"));
}

function getIndexedNotes(idColeta){
    if (indexesForColeta[ "id" + idColeta ] == null)
        return new Array();
    else
        return indexesForColeta[ "id" + idColeta ];
}

function getNotes(idColeta)
{
    var notes = getIndexedNotes( idColeta );
    var urlData = "";
    for (e = 1; e <= notes.length; ++e){
        if ((notes[e] != null) && (notes[e] == true)){
            var sufix_id = e+"_id"+idColeta;
            if (getObj("nf_emissao"+sufix_id) != null){
                if (!validaData(getObj("nf_emissao"+sufix_id).value)){
                    alert("Preencha as datas de emissão da(s) nota(s) fiscal(is) corretamente!");
                    return null;
                }

                if (wasNull("nf_numero"+sufix_id+",nf_serie"+sufix_id)){
                    alert("A série e o numero de uma nota fiscal não podem ser nula!");
                    return null;
                }

                urlData += "&" + concatFieldValueUnescape("nf_numero"+sufix_id+","+
                    "nf_idnota_fiscal"+sufix_id+","+
                    "nf_serie"+sufix_id+","+
                    "nf_emissao"+sufix_id+","+
                    "nf_valor"+sufix_id+","+
                    "nf_base_icms"+sufix_id+","+
                    "nf_icms"+sufix_id+","+
                    "nf_icms_st"+sufix_id+","+
                    "nf_icms_frete"+sufix_id+","+
                    "nf_peso"+sufix_id+","+
                    "nf_volume"+sufix_id+","+
                    "nf_embalagem"+sufix_id+","+
                    "nf_conteudo"+sufix_id+","+
                    "nf_altura"+sufix_id+","+
                    "nf_largura"+sufix_id+","+
                    "nf_comprimento"+sufix_id+","+
                    "nf_metroCubico"+sufix_id+","+
                    "nf_pedido"+sufix_id+","+
                    "nf_id_marca_veiculo"+sufix_id+","+
                    "nf_marca_veiculo"+sufix_id+","+
                    "nf_modelo_veiculo"+sufix_id+","+
                    "nf_ano_veiculo"+sufix_id+","+
                    "nf_cor_veiculo"+sufix_id+","+
                    "nf_chassi_veiculo"+sufix_id + ","+
                    "nf_cfopId"+sufix_id + ","+
                    "nf_cfop"+sufix_id + ","+
                    "nf_chave_nf"+sufix_id +","+
                    //novos campos
                    "nf_data_agenda"+sufix_id +","+
                    "nf_hora_agenda"+sufix_id +","+
                    "nf_obs_agenda"+sufix_id +","+
                    "nf_is_agendado"+sufix_id +","+
                    "nf_previsao_entrega"+sufix_id +","+
                    "nf_previsao_as"+sufix_id +","+
                    "nf_id_destinatario"+sufix_id+","+
                    //Campos novos veiculo cte 3.00
                    "nf_placa_veiculo"+sufix_id+","+ 
                    "nf_veiculo_novo"+sufix_id+","+
                    "nf_cor_fab"+sufix_id+","+
                    "nf_marcamodelo_veiculo"+sufix_id
                );
            }
        }//if (notes[e] == null
    }//for

    return urlData.substring(1);
}

/**Conta quantas notas estï¿½o ativas na lista.
  @idcoleta
  	ï¿½ o id da coleta para contagem das notas.
  	ex.: countNotes(198)	*/
function countNotes(idColeta){
    var notes = getIndexedNotes( idColeta );
    var resultCount = 0;
    for (e = 1; e <= notes.length; ++e)
        if ((notes[e] != null) && (notes[e] == true))
            resultCount++;

    return resultCount;
}

/**Retorna a soma dos valores das notas.
   @exemplo sumValorNotes(idColeta)*/
function sumValorNotes(idColeta){
    var sumValor = 0;
    var notes = getIndexedNotes( idColeta );
            //    for (i = 1; getObj("trNote"+i+"_id"+idColeta) != null; ++i)    
    for (i = 1; i <= notes.length; ++i){
        if(getObj("nf_metroCubico"+i+"_id"+idColeta) != null){

            sumValor += parseFloat(getObj("nf_valor"+i+"_id"+idColeta).value);
        }
    }

    return formatoMoeda(sumValor);
}

/**Retorna a soma dos pesos das notas.
   @exemplo sumPesoNotes(idColeta)*/
function sumPesoNotes(idColeta){
    var sumPeso = 0;
    var notes = getIndexedNotes( idColeta );
    //    for (i = 1; getObj("trNote"+i+"_id"+idColeta) != null; ++i)
    for (i = 1; i <= notes.length; ++i){
        if(getObj("nf_metroCubico"+i+"_id"+idColeta) != null){
            sumPeso += parseFloat(getObj("nf_peso"+i+"_id"+idColeta).value);
        }
    }

    return roundABNT(sumPeso,3);
}

/**Retorna a soma dos pesos das notas.
   @exemplo sumPesoNotes(idColeta)*/
function sumVolumeNotes(idColeta){
    var sumVolume = 0;
    var notes = getIndexedNotes( idColeta );
    //    for (i = 1; getObj("trNote"+i+"_id"+idColeta) != null; ++i)
    for (i = 1; i <= notes.length; ++i){
        if(getObj("nf_metroCubico"+i+"_id"+idColeta) != null){
            sumVolume += parseFloat(getObj("nf_volume"+i+"_id"+idColeta).value);
        }
    }  
    return roundABNT(sumVolume,4);
}

function sumMetroNotes(idColeta){
    var sumMetro = 0;
    var notes = getIndexedNotes( idColeta );
    
    for (i = 1; i <= notes.length; ++i){
        if(getObj("nf_metroCubico"+i+"_id"+idColeta) != null){
            sumMetro += parseFloat(getObj("nf_metroCubico"+i+"_id"+idColeta).value);
        }
    }

    return sumMetro.toFixed(4);
}

/**Adiciona uma nota somente leitura numa tabela.
   @@exemplo addReadOnlyNote(idColeta, idTableRoot, idnota_fiscal, numero, serie, emissao, valor, vl_base_icms,
                    vl_icms, vl_icms_st, vl_icms_frete, peso, volume, embalagem, conteudo, **isCheckable) */
function addReadOnlyNote(idColeta, idTableRoot, idnota_fiscal, numero, serie, emissao, valor, vl_base_icms,
    vl_icms, vl_icms_st, vl_icms_frete, peso, volume, embalagem, descricao_produto, pedido, idMarcaVeiculo,
    marcaVeiculo,modeloVeiculo,anoVeiculo,corVeiculo,chassiVeiculo,cfopId,cfop,chaveNFe,
    isAgendado,dataAgenda,horaAgenda,obsAgenda,previsaoEm,previsaoAs,idDestinatario,destinatario,isEdi,
    altura,largura,comprimento,metro, tpDocumento, placaVeiculo, veiculoNovo, corFab, marcaModelo, travarCampos)

{
    var tableRoot = getObj(idTableRoot);
    var indice = getNextIndexFromTableRoot(idColeta, idTableRoot);

    //simplificando na hora da chamada
    var sufixID = indice+"_id"+idColeta;
    var nameTR = "trNote" + sufixID;
    var trNote = makeElement("TR", "class=colorClear&id="+nameTR);
    //fabricando o botï¿½o de excluir
    appendObj(trNote, makeWithTD("INPUT", "type=checkbox&id=ck"+sufixID));
    appendObj(trNote, makeElement("TD", "id=nf_numero"+sufixID+"&innerHTML="+numero));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_idnota_fiscal"+sufixID+"&value="+idnota_fiscal));
    appendObj(trNote, makeElement("TD", "id=nf_serie"+sufixID+"&innerHTML="+serie));
    appendObj(trNote, makeElement("TD", "id=nf_emissao"+sufixID+"&innerHTML="+emissao));
    appendObj(trNote, makeElement("TD", "id=nf_valor"+sufixID+"&innerHTML="+valor));
    appendObj(trNote, makeElement("TD", "id=nf_base_icms"+sufixID+"&innerHTML=" + vl_base_icms));
    appendObj(trNote, makeElement("TD", "id=nf_icms"+sufixID+"&innerHTML="+vl_icms));
    appendObj(trNote, makeElement("TD", "id=nf_icms_st"+sufixID+"&innerHTML="+vl_icms_st));
    appendObj(trNote, makeElement("TD", "id=nf_icms_frete"+sufixID+"&innerHTML="+vl_icms_frete));
    appendObj(trNote, makeElement("TD", "id=nf_peso"+sufixID+"&innerHTML="+peso));
    appendObj(trNote, makeElement("TD", "id=nf_volume"+sufixID+"&innerHTML="+volume));
    appendObj(trNote, makeElement("TD", "id=nf_embalagem"+sufixID+"&innerHTML="+embalagem));
    appendObj(trNote, makeElement("TD", "id=nf_conteudo"+sufixID+"&innerHTML=" + descricao_produto));
    appendObj(trNote, makeElement("TD", "id=nf_pedido"+sufixID+"&innerHTML=" + pedido));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_id_marca_veiculo"+sufixID+"&value="+idMarcaVeiculo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_marca_veiculo"+sufixID+"&value="+marcaVeiculo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_modelo_veiculo"+sufixID+"&value="+modeloVeiculo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_ano_veiculo"+sufixID+"&value="+anoVeiculo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_cor_veiculo"+sufixID+"&value="+corVeiculo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_chassi_veiculo"+sufixID+"&value="+chassiVeiculo));    

    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_cfopId"+sufixID+"&value="+cfopId));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_cfop"+sufixID+"&value="+cfop));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_chave_nf"+sufixID+"&value="+chaveNFe));

    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_is_agendado"+sufixID+"&value="+isAgendado));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_data_agenda"+sufixID+"&value="+dataAgenda));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_hora_agenda"+sufixID+"&value="+horaAgenda));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_obs_agenda"+sufixID+"&value="+obsAgenda));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_previsao_entrega"+sufixID+"&value="+previsaoEm));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_previsao_as"+sufixID+"&value="+previsaoAs));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_id_destinatario"+sufixID+"&value="+idDestinatario));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_destinatario"+sufixID+"&value="+destinatario));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_is_edi"+sufixID+"&value="+isEdi));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_altura"+sufixID+"&value="+altura));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_largura"+sufixID+"&value="+largura));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_comprimento"+sufixID+"&value="+comprimento));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_metroCubico"+sufixID+"&value="+metro));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_tipoDocumento"+sufixID+"&value="+tpDocumento));
    
    //Campos veiculo cte 3.00
    
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_placa_veiculo"+sufixID+"&value="+placaVeiculo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_veiculo_novo"+sufixID+"&value="+veiculoNovo));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_cor_fab"+sufixID+"&value="+corFab));
    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_marcamodelo_veiculo"+sufixID+"&value="+marcaModelo));

    appendObj(trNote, makeElement("INPUT","type=hidden&id=nf_travarCampos"+sufixID+"&value="+travarCampos));
    
    //adicionando a linha na tabela
    tableRoot.lastChild.appendChild(trNote);
    markFlagNote(idColeta, indice, true);

    //chamando um possivel metodo que aplica eventos em alguns campos da nota adicionada
    if (window.applyEventInNote != null)
        applyEventInNote();
}

/**Percorre a tabela de notas para saber se alguma nota com id especificado ja existe.
  @syntax noteExist(idnota_fiscal, idColeta) */
function noteExist(idnota_fiscal, idColeta)
{
    var f = 1;
    while($('nf_idnota_fiscal'+f+'_id'+idColeta))
    {
        var suf = f+'_id'+idColeta;
        if ($('nf_idnota_fiscal'+suf).value == idnota_fiscal)
            return true;

        ++f;
    }

    return false;
}

function removerItemNota(coletaId,coletaOrdem){
    if(excluirItemNotaFiscalColeta != null){
        excluirItemNotaFiscalColeta(coletaId,coletaOrdem);
    }else{
        Element.remove("trItemNota_"+ coletaOrdem);
        calcMetro(coletaId);
    }
    
}

/*
 *Função auxiliar para verificar se o campo é vázio.
 *@param recebe o valor e retorna false se o campo não for vázio e true se ele for vázio.
 */
function isVazio(valor){
    return (valor.trim() == "" ? true : false);
}
/**
 *Função que verifica se as descrições dos itens da notal fiscal foram preenchidos
 *@param Retorna uma mensagem informando a ordem e as linhas que as descrições não foram informadas.
 */
function getMsgErrosDestinatariosItensNota(previa){
    var countErros = 0;
    var countLinha = 0;
    var msg = "";
    var maximo = parseFloat(document.getElementById("maxItens"+previa).value);
    for(var i = 0; i <= maximo;i++){
        if($("nf_conteudo"+previa+i) != null){
            countLinha++;
            if(isVazio($("nf_conteudo"+previa+i).value)){
                countErros++;
                msg +=  countErros+"- A descrição do item da nota fiscal na linha "+countLinha+" não foi informada.\n"; 
            }
        }
    }
    return msg;
}

function addItemNota(id,coletaId,descricao,quantidade,valor,idProdNota,basePallet,alturaPallet){
    countItemNota = parseFloat($("maxItens"+ coletaId).value) + 1;
    var _tr = Builder.node("tr", {
        name: "trItemNota_" + coletaId +countItemNota,
        id: "trItemNota_" + coletaId + countItemNota,
        className: "CelulaZebra1"
    });

    //primeiro Campo excluir
    var _td1 = Builder.node("td",{
        width:"3%"
    });
    var _ip1 = Builder.node("img", {
        src: "img/lixo.png" ,
        onclick:"removerItemNota('"+coletaId+"','"+coletaId +countItemNota+"')"
    });
    var _ip1_1 = Builder.node("input", {
        type:"hidden",
        id:"idItemNota_"+ coletaId +countItemNota,
        name:"idItemNota_"+ coletaId +countItemNota,
        value:id
    });
    _td1.appendChild(_ip1_1);
    _td1.appendChild(_ip1);

    //descricao
    var _td2 = Builder.node("td",{
        width:"47%"
    });
    
    var hiddenProdutoNota = Builder.node("input",{
        type:"hidden", 
        name:"produtoId"+ coletaId +countItemNota, 
        id:"produtoId" + coletaId +countItemNota,
        value: idProdNota
    });
    var _ip2 = Builder.node("input", {
        name: "nf_conteudo" + coletaId +countItemNota,
        id: "nf_conteudo" + coletaId + countItemNota,
        type: "text",
        value: descricao,
        className: "fieldMin",
        size: "48",
        style:"font-size:8pt;"
    });
    
    var buttonProduto = Builder.node("input",{//Botão que chamará à função
        type:"button",
        id:"btnProduto"+ countItemNota,
        name:"btnProduto"+ countItemNota,
        value:"...",
        className:"inputBotaoMin",
        onclick: "localizarProdutoCtrcNFItem('"+ coletaId +countItemNota+"')"//Função que chama o localizar o produto.
    })
    var imgBorrachaProduto =  Builder.node("img",{
        name: "imgBorrachaProduto"+countItemNota,
        id: "imgBorrachaProduto"+countItemNota,
        src: "img/borracha.gif",
        title: "Limpar Produto",
        className: "imagemLink",
        style: "margin-left: 5px;",
        onClick:"limparProdutoNota('"+ coletaId +countItemNota+"');"
    });
    _td2.appendChild(hiddenProdutoNota);
    _td2.appendChild(_ip2);
    _td2.appendChild(buttonProduto)
    _td2.appendChild(imgBorrachaProduto)
    
    //--------------------------- TD  Base  ------------
        var tdBase = Builder.node("td",{//Td do Palet
            id:"tdBase"+countItemNota, name:"tdBase"+countItemNota,width:"10%"
        });
        var inputBase = Builder.node("input",{//Descrição do Destiinatário
            type:"text",
            id:"basePallet"+ coletaId +countItemNota,
            name:"basePallet"+ coletaId +countItemNota,
            size:"8",
            className:"fieldMin styleValor",
            value: basePallet,
            onkeypress: "mascara(this, soNumeros)"//Função que só permite digitar números  inteiros.
        });
        tdBase.appendChild(inputBase)//Adicionando o input basePaletizacao na tdPaletizacao
        
        //-------------------------------------------------------------
        
        //--------------------------- TD  Altura ------------
        var tdAltura = Builder.node("td",{//Td da Altura
            id:"tdAltura"+countItemNota, name:"tdAltura"+countItemNota,width:"10%"
        });
        var inputAltura = Builder.node("input",{//número da altura
            type:"text",
            id:"alturaPallet"+ coletaId +countItemNota,
            name:"alturaPallet"+ coletaId +countItemNota,
            size:"8",
            className:"fieldMin styleValor",
            value: alturaPallet,
            onChange: "mascara(this, soNumeros)"//Função que só permite digitar números  inteiros.
        });
        tdAltura.appendChild(inputAltura)//Adicionando o input basePaletizacao na tdPaletizacao
        
    // --------------------------------------------------------------------
    
    //quantidade
    var _td3 = Builder.node("td",{
        width:"10%"
    });
    var _ip3 = Builder.node("input", {
        name: "quantidadeItemNota_" + coletaId +countItemNota,
        id: "quantidadeItemNota_" + coletaId + countItemNota,
        type: "text",
        className: "fieldMin",
        value: quantidade,
        size: "8",
        onBlur:"seNaoFloatReset(this,0.00);multiplicaItensNota('"+coletaId+"','"+countItemNota+"')",
        style:"font-size:8pt;"
    });
    _td3.appendChild(_ip3);
    
    //botão 
    //vl unitario
    var _td4 = Builder.node("td",{
        width:"10%"
    });
    var _ip4 = Builder.node("input", {
        name: "vlUnitarioItemNota_" + coletaId +countItemNota,
        id: "vlUnitarioItemNota_" + coletaId + countItemNota,
        type: "text",
        className: "fieldMin",
        value: valor,
        size: "8",
        onBlur:"seNaoFloatReset(this,0.00);multiplicaItensNota('"+coletaId+"','"+countItemNota+"')",
        style:"font-size:8pt;"
    });
    _td4.appendChild(_ip4);

    //vl total
    var _td5 = Builder.node("td",{
        width:"10%"
    });
    var _ip5 = Builder.node("input", {
        name: "totalItemNota_" + coletaId +countItemNota,
        id: "totalItemNota_" + coletaId + countItemNota,
        type: "text",
        className: "fieldMin",
        value: "0.00",
        size: "8",
        readOnly : true,
        style:"font-size:8pt;background-color:#FFFFF1"
    });
    _td5.appendChild(_ip5);


    _tr.appendChild(_td1);
    _tr.appendChild(_td2);
    _tr.appendChild(_td3);
    _tr.appendChild(_td4);
    _tr.appendChild(_td5);
    _tr.appendChild(tdBase);//Adicionando a tdBasePaletizacao na nova linha
    _tr.appendChild(tdAltura);//Adicionando a tdAltura na nova linha

   

    document.getElementById("tbItensNota").appendChild(_tr);
    
    document.getElementById("maxItens"+coletaId).value = countItemNota;

    multiplicaItensNota(coletaId, countItemNota);

}

function multiplicaItensNota(previa,posicao){
    var qtd = parseFloat(document.getElementById("quantidadeItemNota_"+previa+posicao).value);
    var uni = parseFloat(document.getElementById("vlUnitarioItemNota_"+previa+posicao).value);

    document.getElementById("totalItemNota_"+previa+posicao).value = formatoMoeda(qtd*uni);

    totalItensNota(previa);
}

function totalItensNota(previa){
    var qtdTotal = 0;
    var vlTotal = 0;
    var maximo = parseFloat(document.getElementById("maxItens"+previa).value);

    for (var i = 0; i <= maximo; i++){
        if (document.getElementById("quantidadeItemNota_"+previa+i) != null){
            qtdTotal += parseFloat(document.getElementById("quantidadeItemNota_"+previa+i).value);
            vlTotal += parseFloat(document.getElementById("totalItemNota_"+previa+i).value);
        }
    }

    document.getElementById("qtdTotal").value = formatoMoeda(qtdTotal);
    document.getElementById("valorTotal").value = formatoMoeda(vlTotal);

}

function calcMetro(sufix){
    var contador = document.getElementById("maxCubagem").value;
    var metroCubicoTotal = 0;
    var valorCubagem = 0;

    for (var i = 0 ; i <= contador; i++){
        if (document.getElementById("inVolume_"+sufix+i) != null){
            valorCubagem = parseFloat(document.getElementById("inVolume_"+sufix+i).value) *
            parseFloat(document.getElementById("inLargura_"+sufix+i).value) *
            parseFloat(document.getElementById("inAltura_"+sufix+i).value) *
            parseFloat(document.getElementById("inComprimento_"+sufix+i).value);
            metroCubicoTotal += valorCubagem;
            document.getElementById("inMetroCubico_"+sufix+i).value = valorCubagem.toFixed(4);
        }
    }
    document.getElementById("inMetroCubico").value= metroCubicoTotal.toFixed(4);

}

function somaVolume(sufix){
    
    var contador = document.getElementById("maxCubagem").value;
    var VolumeTotal = 0;
 
    for (var i = 0 ; i <= contador; i++){
        if (document.getElementById("inVolume_"+sufix+i) != null)
            VolumeTotal += parseFloat(document.getElementById("inVolume_"+sufix+i).value);
    }
    //Comentando o valor para não somar o total dos volumes e ter que alterar manualmente na tela de cadconhecimento;
    document.getElementById("inVolume").value= formatoMoeda(VolumeTotal);

    
}

function somaMetroCubico(sufix){
    
    var contador = document.getElementById("maxCubagem").value;
    var MetroTotal = 0;

    for (var i = 0 ; i <= contador; i++){
        if (document.getElementById("inMetroCubico_"+sufix+i) != null)
            MetroTotal += parseFloat(document.getElementById("inMetroCubico_"+sufix+i).value);
    }
    document.getElementById("inMetroCubico").value= MetroTotal.toFixed(4);
    
}

function AlternarAbasNota(){
    $("tdItens").className = 'menu';
    $("divItens").style.display = 'none';

    $("tdNotaDados").className = 'menu-sel';
    $("divNota").style.display = '';
}

function AlternarAbasItens(){
    $("tdItens").className = 'menu-sel';
    $("divItens").style.display = '';

    $("tdNotaDados").className = 'menu';
    $("divNota").style.display = 'none';
}

function localizacfopNota(){
    post_cad = window.open('./localiza?acao=consultar&idlista=2','Cfop_Nota_fiscal',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

function localizacfopNotaTRCte(idx){
    post_cad = window.open('./localiza?acao=consultar&idlista=2','Cfop_Nota_fiscal_nfe__'+idx,
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

function localizarProdutoCtrcNF(idxProd){
    var remetente_id = 0;
    if ($("idremetente") != null){        
        remetente_id = $("idremetente").value;
    }else if ($("idremetente_"+idxProd) != null){
        remetente_id = $("idremetente_"+idxProd).value;
    }
    post_cad = window.open('./localiza?acao=consultar&idlista=77&paramaux='+remetente_id,'Produto_ctrcs_nf__'+idxProd,
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

function localizarProdutoCtrcNFItem(idxProd){
    var remetente_id = 0;
    if ($("idremetente") != null){        
        remetente_id = $("idremetente").value;
    }else if ($("idremetente_"+idxProd) != null){
        remetente_id = $("idremetente_"+idxProd).value;
    }
    post_cad = window.open('./localiza?acao=consultar&idlista=77&paramaux='+remetente_id,'Produto_ctrcs_nf_item__'+idxProd,
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

function addUpdateNotaFiscal(acao, idColeta, table, numero, serie, emissao, valor, peso, //8
    volume, altura, largura,comprimento, metroCubico, embalagem, descricao_produto, baseIcms,//8
    valorIcms, icmsSt,icmsFrete, pedido, idMarcaVeiculo, marcaVeiculo, modeloVeiculo,//7
    anoVeiculo, corVeiculo, chassiVeiculo,maxItem,isPossuiItens,cfopId,cfop,chaveNFe,//8
    isAgendado, dataAgenda, horaAgenda, observacaoAgenda, isBaixaNota, previsaoEntrega, previsaoAs,//7
    idDestinatario, destinatario, isReadOnly, isEdi, //4
    placaVei, veiculoNovo, corFab, marcaModelo, travarCampos){//4
        
    var divisaoAbsoluta = Math.pow((parseFloat(metroCubico))/(parseFloat(volume)),1/3);

    var isImportadaEdi = ''+isEdi;
    //se o prompt ainda nao existe crie ele no escopo
    //criando a layer do prompt da senha
    var promp = document.createElement("DIV");
    promp.id = "promptNF";
    document.body.appendChild(promp);
    var obj = document.getElementById("promptNF").style;
    obj.zIndex = "3";
    obj.position = "absolute";
    obj.backgroundColor = "#FFFFFF";
    obj.left = "5%";
    obj.top = "20%";
    obj.width = "90%";
    //obj.height = "80%";
    //inserindo na layer os objetos da nota fiscal
    var cmdHtml = "";
    //Criando a tabela
    cmdHtml = "<table width='100%' class='bordaFina'>"+
    "<tr>" ;
    if (isPossuiItens == 'true'){
        cmdHtml +=
        //<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Menu @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-->
        "<td  width='33%' class='menu-sel' id='tdNotaDados' onClick='AlternarAbasNota()'>" +
    " Dados Principais " +
    "</td>" +
    "<td  width='33%' class='menu' id='tdItens' onClick='AlternarAbasItens()'> "+
    " Dados dos Itens da nota fiscal " +
    "</td> " +
    "<td  width='33%' id='tdItens' > "+
    "</td> ";
    }
    /*
    else{
        cmdHtml +=
        "<td  colspan='3' class='menu-sel' id='tdNotaDados' >" +
    " Dados da nota fiscal " +
    "</td>";
    }*/

    cmdHtml +=
    "</tr>" +
    "<tr>"+
    "<td class='tb-conteudo' id='tdConteudo' colspan='3'>" +
    //<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Dados nota @@@@@@@@@@@@@@@@@@@@@@ -->
    "<div id='divNota' class='conteudo' > " +
    "<table class='bordaFina' width='100%'>" +
    "<tr class='tabela' align='center'>" +
    "<td colspan='10'> Dados da nota fiscal </td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' width='10%' >Número:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+numero+"' id='inNotaFiscal' style='font-size:8pt;' size='8' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='11%'>Série:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+serie+"' id='inSerie' style='font-size:8pt;' size='4' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='9%'>Emissão:</td>" +
    "<td class='CelulaZebra2' width='11%'><INPUT type='text' value='"+emissao+"' id='inEmissao' style='font-size:8pt;' size='9' onBlur='alertInvalidDate(this)' class='fieldDate' /></td>" +
    "<td class='TextoCampos' width='9%'>Valor:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+valor+"' id='inValor' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='7%'>Peso:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+peso+"' id='inPeso' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "</tr>" +
    "<tr>" +
    "<td colspan='11'>" +
    "<table width='100%'  border='0'>" +
    "<tbody id='tbCubagem' name='tbCubagem'>" +
    "<tr id='trCubagem' name='trCubagem' class='CelulaZebra2'>" +
    "<input type='hidden' name='maxCubagem' id='maxCubagem' value='0'>" +
    /*
    "<input type='hidden' name='inLargura' id='inLargura' value='0'>" +
    "<input type='hidden' name='inAltura' id='inAltura' value='0'>" +
    "<input type='hidden' name='inComprimento' id='inComprimento' value='0'>" +
    
    */
    "<input type='hidden' name='metroid_"+idColeta+"0' id='metroid_"+idColeta+"0' value='0'>" +
    "<input type='hidden' name='maxItens' id='maxItens' value='0'>" +
    "<input type='hidden' name='maxItensMetro' id='maxItensMetro' value='0'>" +
    "<td class='TextoCampos' width='3%'><img src='img/add.gif' id='imgAddItemCubagem' name='imgAddItemCubagem' border='0' onClick='addItemCubagem(\""+idColeta+"\");' title='Adicionar um novo item' class='imagemLink'></td>" +
    "<td class='TextoCampos' width='10%'>Volume:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+roundABNT(volume, 3)+"' name='inVolume_"+idColeta+"0' id='inVolume_"+idColeta+"0' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0.00);calcMetro(\""+idColeta+"\");somaVolume(\""+idColeta+"\");' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='9%'>Comp.:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+formatoMoeda(divisaoAbsoluta)+"' name='inComprimento_"+idColeta+"0' id='inComprimento_"+idColeta+"0' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0.00);calcMetro(\""+idColeta+"\")' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='9%'>Largura:</td>" +
    "<td class='CelulaZebra2' width='11%'><INPUT type='text' value='"+formatoMoeda(divisaoAbsoluta)+"' name='inLargura_"+idColeta+"0' id='inLargura_"+idColeta+"0' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0.00);calcMetro(\""+idColeta+"\")' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='11%'>Alt.:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+formatoMoeda(divisaoAbsoluta)+"' name='inAltura_"+idColeta+"0' id='inAltura_"+idColeta+"0' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0.00);calcMetro(\""+idColeta+"\")' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='7%'>M³:</td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='"+formatoMoeda(metroCubico)+"' name='inMetroCubico_"+idColeta+"0' id='inMetroCubico_"+idColeta+"0' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0.00);somaMetroCubico(\""+idColeta+"\")' class='fieldMin'/></td>" +
    "</tr >" +
    "</tbody>" +
    "</table>" +
    "</td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' >Tot Vol.:</td>" +
    "<td class='CelulaZebra2'><INPUT type='text' value='"+volume+"' id='inVolume' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "<td class='TextoCampos'>&nbsp;</td>" +
    "<td class='TextoCampos'>&nbsp;</td>" +
    "<td class='TextoCampos'>&nbsp;</td>" +
    "<td class='TextoCampos'>&nbsp;</td>" +
    "<td class='TextoCampos'>&nbsp;</td>" +
    "<td class='TextoCampos'>&nbsp;</td>" +
    "<td class='TextoCampos'>Tot M³:</td>" +
    "<td class='CelulaZebra2'><INPUT type='text' value='"+metroCubico+"' id='inMetroCubico' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);'/ class='fieldMin'></td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' >Embalag.:</td>" +
    "<td class='CelulaZebra2' colspan='4'><INPUT type='text' value='"+embalagem+"' id='inEmbalagem' style='font-size:8pt;' size='30' maxlength='20' class='fieldMin'/></td>" +
    "<td class='TextoCampos'>Conteúdo:</td>" +
    "<td class='CelulaZebra2' colspan='4'><INPUT type='text' value='"+descricao_produto+"' id='inConteudo' style='font-size:8pt;' size='30' maxlength='30' class='fieldMin'/></td>" +
    "</tr>" +

    "<tr class='tabela' align='center'>" +
    "<td colspan='10'> Dados Fronteira Digital (FRONTDIG) </td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' >Base ICMS:</td>" +
    "<td class='CelulaZebra2'><INPUT type='text' value='"+baseIcms+"' id='inBaseIcms' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "<td class='TextoCampos'>Valor ICMS:</td>" +
    "<td class='CelulaZebra2'><INPUT type='text' value='"+valorIcms+"' id='inValorIcms' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "<td class='TextoCampos'>ICMS ST:</td>" +
    "<td class='CelulaZebra2'><INPUT type='text' value='"+icmsSt+"' id='inIcmsSt' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "<td class='TextoCampos' colspan='2'>ICMS FRETE:</td>" +
    "<td class='CelulaZebra2' colspan='2'><INPUT type='text' value='"+icmsFrete+"' id='inIcmsFrete' style='font-size:8pt;' size='8' onBlur='javascript:seNaoFloatReset(this,0);' class='fieldMin'/></td>" +
    "</tr>" +
    "<tr class='tabela' align='center'>" +
    "<td colspan='10'> Dados CT-e </td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos'>CFOP:</td>" +
    "<td class='CelulaZebra2'>"+
    "<INPUT type='hidden' value='"+cfopId+"' id='inCfopId' style='font-size:8pt;' size='8' maxlength='10'/>"+
    "<INPUT type='text' value='"+cfop+"' id='inCfop' style='font-size:8pt;' size='3' maxlength='10' readonly class='inputReadOnly'/>" +
    "<INPUT name='localiza_cfopNota' type='button' class='botoes' id='localiza_cfopNota' value='...' />" +
    "</td>" +
    "<td class='TextoCampos' colspan='2'>Chave NF-e:</td>" +
    "<td class='CelulaZebra2' colspan='6' ><INPUT type='text' value='"+chaveNFe+"' id='inChaveNFe' style='font-size:8pt;' size='44' maxlength='44' onBlur='javascript:seNaoIntReset(this,0);' class='fieldMin'/></td>" +
    "</tr>" +

    "<tr class='tabela' align='center'>" +
    "<td colspan='10'> Informações do veículo transportado </td>" +
    "</tr>" +
    "<tr>" +
    "<td colspan='10'>" +
    "<table width='100%'>" +
    "<tr>" +
    "<td class='TextoCampos' width='6%'>Marca:</td>" +
    "<td class ='CelulaZebra2' width='18%'>"+
    "<INPUT type='hidden' value='"+idMarcaVeiculo+"' id='inIdMarcaVeiculo' style='font-size:8pt;' size='8' maxlength='10'/>"+
    "<INPUT type='text' value='"+marcaVeiculo+"' id='inMarcaVeiculo' style='font-size:8pt;' size='13' maxlength='10' class='inputReadOnly' readonly/>" +
    "<INPUT name='localiza_marca' type='button' class='botoes' id='localiza_marca' value='...' />" +
    "</td>" +
    "<td class='TextoCampos' width='7%'>Modelo:</td>" +
    "<td class='CelulaZebra2' width='12%'><INPUT type='text' value='"+modeloVeiculo+"' id='inModeloVeiculo' style='font-size:8pt;' size='11' maxlength='30' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='4%'>Ano:</td>" +
    "<td class='CelulaZebra2' width='8%'><INPUT type='text' value='"+anoVeiculo+"' id='inAnoVeiculo' style='font-size:8pt;' size='6' maxlength='9' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='4%'>Cor:</td>" +
    "<td class='CelulaZebra2' width='15%'>"+
    "<select name='inCorVeiculo' id='inCorVeiculo' style='font-size:8pt;' class='fieldMin'>" +
    "<option value='0' selected>Nao Informado</option>" +
    "<option value='1'>BRANCA</option>" +
    "<option value='2'>AMARELA</option>" +
    "<option value='3'>AZUL</option>" +
    "<option value='4'>VERDE</option>" +
    "<option value='5'>VERMELHA</option>" +
    "<option value='6'>LARANJA</option>" +
    "<option value='7'>PRETA</option>" +
    "<option value='8'>PRATA</option>" +
    "<option value='9'>CINZA</option>" +
    "<option value='10'>BEGE</option>" +
    "<option value='11'>ROXO</option>" +
    "<option value='12'>VINHO</option>" +
    "<option value='13'>GREN&Aacute;</option>" +
    "<option value='14'>MARROM</option>" +
    "<option value='15'>ROSA</option>" +
    "<option value='16'>FANTASIA</option>" +
    "<option value='17'>DOURADA</option>" +
    "</select>" +
    "</td>" +
    "<td class='TextoCampos' width='7%'>Chassi:</td>" +
    "<td class='CelulaZebra2' width='19%'><INPUT type='text' value='"+chassiVeiculo+"' id='inChassiVeiculo' style='font-size:8pt;' size='20' maxlength='30' class='fieldMin'/></td>" +
    "</tr>" +
     "<tr>" +
    "<td class='TextoCampos' width='7%'>Placa:</td>" +   //placaVei, veiculoNovo, corFab, marcaModelo
    "<td class='CelulaZebra2' width='12%'><INPUT type='text' value='"+(placaVei == undefined? "": placaVei)+"' id='placaVei' name='placaVei' style='font-size:8pt;' size='8' maxlength='7' class='fieldMin'/></td>" +
    "<td class='TextoCampos' colspan='2'><div align='center'>Veículo Novo"+
    "<input name='veiculoNovo' type='checkbox' id='veiculoNovo' value='checkbox'>" +
     "<td class='TextoCampos' width='20%'>Cor no Fabricante:</td>" +
    "<td class='CelulaZebra2' width='12%'><INPUT type='text' value='"+corFab+"' id='corFabricante' name='corFabricante' style='font-size:8pt;' size='4' maxlength='4' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='7%'>Marca/Modelo:</td>" +
    "<td class='CelulaZebra2' width='12%'><INPUT type='text' value='"+marcaModelo+"' id='marcaModelo' name='marcaModelo' style='font-size:8pt;' size='6' maxlength='6' class='fieldMin'/></td>" +
    "<td class='TextoCampos' width='7%'></td>" +
    "<td class='TextoCampos' width='7%'></td>" +
    "</tr>" +
    "</table>" +
    "</td>" +
    "</tr>" +
    "<tr class='tabela' align='center'>" +
    "<td colspan='10'> Outros </td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' colSpan='3'>Nota fiscal importada via EDI:</td>" +
    "<td class='CelulaZebra2'><b>"+(isImportadaEdi == 'true' || isImportadaEdi == 't'?"SIM":"NÃO")+"</b></td>" +
    "<td class='TextoCampos' colSpan='6'></td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' >Pedido/Carga:</td>" +
    "<td class='CelulaZebra2'><INPUT type='text' value='"+pedido+"' id='inPedido' style='font-size:8pt;' size='8' maxlength='10' class='fieldMin'/></td>" +
    "<td class='TextoCampos' colspan='2'><div align='center'>Agendado"+
    "<input name='inIsAgenda' type='checkbox' id='inIsAgenda' value='checkbox' "+(isAgendado == "true" ? "checked" : "")+">" +
    "</div></td>" +
    "<td class='TextoCampos'>Data:</td>" +
    "<td class='CelulaZebra2' colspan='2'><INPUT type='text' class='fieldDate' onBlur='alertInvalidDate(this,true)' value='"+dataAgenda+"' id='inDataAgenda' name='inDataAgenda' style='font-size:8pt;' size='9' maxlength='10'/></td>" +
    "<td class='TextoCampos'>Hora:</td>" +
    "<td class='CelulaZebra2' colspan='2'><INPUT type='text' value='"+horaAgenda+"' id='inHoraAgenda' name='inHoraAgenda' style='font-size:8pt;' onKeyUp='mascaraHora(this)', size='5' maxlength='5' class='fieldMin'/></td>" +
    "</tr>" +
    "<tr>" +
    "<td class='TextoCampos' colspan='2'>Observação:</td>" +
    "<td class='CelulaZebra2' colspan='9'><INPUT type='text' value='"+observacaoAgenda+"' id='inObsAgenda' name='inObsAgenda' style='font-size:8pt;' size='105' class='fieldMin'/></td>" +
    "</tr>" +
    "<tr style='display:"+(isBaixaNota == 'true' || isBaixaNota == true?'':'none')+";'>" +
    "<td class='TextoCampos'>Previsão:</td>" +
    "<td class='CelulaZebra2' colspan='2'><INPUT type='text' value='"+previsaoEntrega+"' id='inPrevisao' name='inPrevisao' style='font-size:8pt;' size='10' maxlength='10' class='fieldDate' onBlur='alertInvalidDate(this,true)'/> às <INPUT type='text' value='"+previsaoAs+"' id='inPrevisaoAs' name='inPrevisaoAs' style='font-size:8pt;' size='6' maxlength='5' class='fieldMin'/></td>" +
    "<td class='TextoCampos' colspan='2'>Destinatário:</td>" +
    "<td class='CelulaZebra2' colspan='5'>" +
    "<INPUT type='text' value='"+destinatario+"' id='indestinatarionota' name='indestinatarionota' style='font-size:8pt;' readonly size='40' class='inputReadOnly'/>"+
    "<INPUT type='hidden' value='"+idDestinatario+"' id='iniddestinatarionota' name='iniddestinatarionota' style='font-size:8pt;'/>"+
    "<INPUT name='localiza_destinatario' type='button' class='botoes' id='localiza_destinatario' value='...' />" +
    "</td>" +
    "</tr>" +
    "</table>" +
    "</div>" +
    "</td>" +
    "</tr>" +
 
    //<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Dados itens nota fiscal @@@@@@@@@@@@@@@@@@@@@@ -->
    //"<div id='divItens' class='conteudo' style='display:none' > " +
    "<tr id='divItens' style='display:none' class='conteudo'> " +
    "<td width='100%' colspan='3'>" +
    "<table width='100%' class='bordaFina'>" +
    "<tr>" +
    "<td width='100%'>" +
    "<div class='limiteMov'>" +
    "<table width='100%'  class='bordaFina'>" +
    "<tr id='trItensNota' name='trItensNota' class='titulo'>" +
    "<td class='TextoCampos' width='3%'><img src='img/add.gif' border='0' onClick=\"addItemNota('0','"+idColeta+"','','1.00','0.00','inserir',0,0,0);\" title='Adicionar um novo ítem' class='imagemLink'></td>" +
    "<td class='CelulaZebra2' width='47%'><b>Descrição</b></td>" +
    "<td class='CelulaZebra2' width='10%'><b>Quant.</b></td>" +
    "<td class='CelulaZebra2' width='10%'><b>Vl unit</b></td>" +
    "<td class='CelulaZebra2' width='10%'><b>Total</b></td>" +
    "<td class='CelulaZebra2' width='10%'><b>Base</b></td>" +
    "<td class='CelulaZebra2' width='10%'><b>Altura</b></td>" +
    "</tr >" +
    "</table>" +
    "</div> " +
    "</td>"+
    "</tr>" +
    "<tr>" +
    "<td width='100%'>" +
    "<div class='limite'>" +
    "<table width='100%'  class='bordaFina'>" +
    "<tbody id='tbItensNota' name='tbItensNota'>" +
    "</tbody>" +
    "</table>" +
    "</div>" +
    "</td>" +
    "</tr>" +
    "<tr>" +
    "<td width='100%'>" +
    "<div class='limiteMov'>" +
    "<table width='100%'  class='bordaFina'>" +
    "<tr id='trItensNota' name='trItensNota' class='titulo'>" +
    "<td class='TextoCampos' width='3%'></td>" +
    "<td class='CelulaZebra2' width='47%'><b><div align='right'>Totais:</div></td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='0.00' id='qtdTotal' style='font-size:8pt;' size='8' maxlength='30' class='fieldMin'/></td>" +
    "<td class='CelulaZebra2' width='10%'></td>" +
    "<td class='CelulaZebra2' width='10%'><INPUT type='text' value='0.00' id='valorTotal' style='font-size:8pt;' size='8' maxlength='30' class='fieldMin'/></td>" +
    "<td class='CelulaZebra2' width='10%'></td>" +
    "<td class='CelulaZebra2' width='10%'></td>" +
    "</tr >" +
    "</table>" +
    "</div> " +
    "</td>"+
    "</tr>" +
    "</table>" +
    "</td>" +
    "</tr>" +
    //"</div>" +
    "<tr class='CelulaZebra2' align='center'>" +
    "<td align='center'><input name='salvar_nf' type='button' class='botoes' id='salvar_nf' value='Salvar'></td>" +
    "<td align='center'><input name='salvar2' type='button' class='botoes' id='salvar2' value='Salvar e incluir outra NF'></td>" +
    "<td align='center'><input name='fechar' type='button' class='botoes' id='fechar' value='Fechar'></td>" +
    "</tr>" +
    "</table>";

    document.getElementById("promptNF").innerHTML = cmdHtml;
    document.getElementById("promptNF").style.display = "";

    applyFormatter();

    if (acao == 'editar'){
        $('salvar2').style.display = 'none';
    }

    $('inNotaFiscal').focus();
    $('inCorVeiculo').value = corVeiculo;
    $("veiculoNovo").checked = (veiculoNovo=="false"? false: true);

    if (isReadOnly == true || isReadOnly == 'true' || isReadOnly == 't'){
        $('inValor').disabled = true;
        $('inPeso').disabled = true;
        if ($('inAltura_0') != null){
            $('inAltura_0').disabled = true;
            $('inLargura_0').disabled = true;
            $('inComprimento_0').disabled = true;
            $('inMetroCubico_0').disabled = true;
            $('inVolume_0').disabled = true;
        }
        if ($('inVolume_'+idColeta+'0') != null){
            $('inComprimento_'+idColeta+'0').disabled = true;
            $('inVolume_'+idColeta+'0').disabled = true;
            $('inLargura_'+idColeta+'0').disabled = true;
            $('inAltura_'+idColeta+'0').disabled = true;
            $('inMetroCubico_'+idColeta+'0').disabled = true;
        }
        $('inMetroCubico').disabled = true;
        $('inVolume').disabled = true;
        $('imgAddItemCubagem').style.display = 'none';
    }

    if (travarCampos === 'true' && (isEdi == true || isEdi == 'true' || isEdi == 't')){
        readOnly($('inNotaFiscal'), 'inputReadOnly8pt');
        readOnly($('inNotaFiscal'), 'inputReadOnly8pt');
        readOnly($('inSerie'), 'inputReadOnly8pt');
        readOnly($('inValor'), 'inputReadOnly8pt');
        readOnly($('inEmissao'), 'inputReadOnly8pt');
        readOnly($('inPeso'), 'inputReadOnly8pt');
        if ($('inAltura_0') != null){
            readOnly($('inAltura_0'), 'inputReadOnly8pt');
            readOnly($('inLargura_0'), 'inputReadOnly8pt');
            readOnly($('inComprimento_0'), 'inputReadOnly8pt');
            readOnly($('inMetroCubico_0'), 'inputReadOnly8pt');
            readOnly($('inVolume_0'), 'inputReadOnly8pt');
        }
        readOnly($('inMetroCubico'), 'inputReadOnly8pt');
        readOnly($('inVolume'), 'inputReadOnly8pt');
        readOnly($('inBaseIcms'), 'inputReadOnly8pt');
        readOnly($('inValorIcms'), 'inputReadOnly8pt');
        readOnly($('inIcmsSt'), 'inputReadOnly8pt');
        readOnly($('inIcmsFrete'), 'inputReadOnly8pt');
    }

    //Atribuindo método aos botoes
    document.getElementById("fechar").onclick = function(){
        document.getElementById("promptNF").style.display='none';
            
            
            
            
            
        blockInterface(false);
        if ($('tipoTransporte') != null){
            $('tipoTransporte').style.display = '';
        }
        if ($('tipoConhecimento') != null){
            $('tipoConhecimento').style.display = '';
        }
        if ($('tipoFpag') != null){
            $('tipoFpag').style.display = '';
        }
        if ($('clientepagador') != null){
            $('clientepagador').style.display = '';
        }
    };
    document.getElementById("localiza_marca").onclick = function(){
        window.open('./localiza?acao=consultar&idlista=0','marca','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    };
    document.getElementById("localiza_destinatario").onclick = function(){
        window.open('./localiza?acao=consultar&idlista=55','destinatario_nota','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    };
    document.getElementById("localiza_cfopNota").onclick = function(){
        localizacfopNota();
    };
    document.getElementById("salvar_nf").onclick = function(){
        var msg = getMsgErrosDestinatariosItensNota(idColeta);
        if(msg.trim() != ""){
            alert(msg);
            return false
        }
        
        //pegar o indice da nota do conhecimento
        var lastIndex = (getNextIndexFromTableRoot('0', 'tableNotes0') - 1);
        
        if ($("nf_volume"+ lastIndex + "_id0") != null) {
            if (parseFloat($("nf_volume" + lastIndex + "_id0").value) != parseFloat(document.getElementById("inVolume").value)) {
                if (confirm("O valor total da cubagem difere do valor total da nota, deseja alterar?")) {
                    $('nf_volume' + idColeta).value = $('inVolume').value;
                }
            }
        }else if ($('nf_volume' + idColeta) != null) {
            if (parseFloat($('nf_volume' + idColeta).value) != parseFloat(document.getElementById("inVolume").value)) {
                if (confirm("O valor total da cubagem difere do valor total da nota, deseja alterar?")) {
                    $('nf_volume' + idColeta).value = $('inVolume').value;
                }
            }
        }

        
        document.getElementById("salvar2").onclick();
        document.getElementById("fechar").onclick();
    };
    
    
    document.getElementById("salvar2").onclick = function(){

        if (acao == 'incluir'){
            addNote(idColeta, table, 0, document.getElementById('inNotaFiscal').value,
                document.getElementById('inSerie').value, document.getElementById('inEmissao').value,
                document.getElementById('inValor').value, document.getElementById('inBaseIcms').value,
                document.getElementById('inValorIcms').value, document.getElementById('inIcmsSt').value,
                document.getElementById('inIcmsFrete').value, document.getElementById('inPeso').value,
                document.getElementById('inVolume').value, document.getElementById('inEmbalagem').value,
                document.getElementById('inConteudo').value, 0, document.getElementById('inPedido').value,
                false,
                document.getElementById('inLargura').value, document.getElementById('inAltura').value,
                document.getElementById('inComprimento').value, document.getElementById('inMetroCubico').value,
                document.getElementById('maxItens').value,isPossuiItens,
                document.getElementById('inCfopId').value,document.getElementById('inCfop').value,
                document.getElementById('inChaveNFe').value,document.getElementById('inIsAgenda').value,
                document.getElementById('inDataAgenda').value,document.getElementById('inHoraAgenda').value,
                document.getElementById('inObsAgenda').value,isBaixaNota,
                document.getElementById('inPrevisao').value,document.getElementById('inPrevisaoAs').value,
                document.getElementById('indestinatarionota').value,document.getElementById('iniddestinatarionota').value,
                document.getElementById('maxItensMetro').value
                
                ,document.getElementById('placaVei').value
                ,document.getElementById('veiculoNovo').checked
                ,document.getElementById('corFabricante').value
                ,document.getElementById('marcaModelo').value
                );

            limparPrompt();
        }else{
            $('nf_numero'+idColeta).value = $('inNotaFiscal').value;
            $('nf_serie'+idColeta).value = $('inSerie').value;
            $('nf_emissao'+idColeta).value = $('inEmissao').value;
            $('nf_valor'+idColeta).value = $('inValor').value;
            $('nf_base_icms'+idColeta).value = $('inBaseIcms').value;
            $('nf_icms'+idColeta).value = $('inValorIcms').value;
            $('nf_icms_st'+idColeta).value = $('inIcmsSt').value;
            $('nf_icms_frete'+idColeta).value = $('inIcmsFrete').value;
            $('nf_peso'+idColeta).value = $('inPeso').value;
//            $('nf_volume'+idColeta).value = $('inVolume').value;
            $('nf_embalagem'+idColeta).value = $('inEmbalagem').value;
            $('nf_conteudo'+idColeta).value = $('inConteudo').value;
            $('nf_pedido'+idColeta).value = $('inPedido').value;
            //            $('nf_largura'+idColeta).value = $('inLargura').value;
            //            $('nf_altura'+idColeta).value = $('inAltura').value;
            //            $('nf_comprimento'+idColeta).value = $('inComprimento').value;
            $('nf_metroCubico'+idColeta).value = $('inMetroCubico').value;
            $('nf_id_marca_veiculo'+idColeta).value = $('inIdMarcaVeiculo').value;
            $('nf_marca_veiculo'+idColeta).value = $('inMarcaVeiculo').value;
            $('nf_modelo_veiculo'+idColeta).value = $('inModeloVeiculo').value;
            $('nf_ano_veiculo'+idColeta).value = $('inAnoVeiculo').value;
            $('nf_cor_veiculo'+idColeta).value = $('inCorVeiculo').value;
            $('nf_chassi_veiculo'+idColeta).value = $('inChassiVeiculo').value;
            //campos novos cte 300
           
            var placa = $('placaVei').value;
            $('nf_placa_veiculo'+idColeta).value = placa;
            $('nf_veiculo_novo'+idColeta).value = $('veiculoNovo').value;
            $('nf_cor_fab'+idColeta).value = $('corFabricante').value;
            $('nf_marcamodelo_veiculo'+idColeta).value = $('marcaModelo').value;            
            
            $('nf_cfopId'+idColeta).value = $('inCfopId').value;
            $('nf_cfop'+idColeta).value = $('inCfop').value;
            $('nf_chave_nf'+idColeta).value = $('inChaveNFe').value;
            //novos campos
            $('nf_is_agendado'+idColeta).value = $('inIsAgenda').checked;
            if ($('ck_is_agendado'+idColeta) != null){
                $('ck_is_agendado'+idColeta).checked = $('inIsAgenda').checked;
            }
            $('nf_data_agenda'+idColeta).value = $('inDataAgenda').value;
            $('nf_hora_agenda'+idColeta).value = $('inHoraAgenda').value;
            $('nf_obs_agenda'+idColeta).value = $('inObsAgenda').value;
            $('nf_previsao_entrega'+idColeta).value = $('inPrevisao').value;
            $('nf_previsao_as'+idColeta).value = $('inPrevisaoAs').value;
            $('nf_id_destinatario'+idColeta).value = $('iniddestinatarionota').value;
            $('nf_destinatario'+idColeta).value = $('indestinatarionota').value;
            //$('nf_destinatario'+idColeta).innerHTML = $('indestinatarionota').value;
            
            var tr = 'trNote'+idColeta;
            var idNota =  $("nf_idnota_fiscal"+idColeta).value;
            
            if (isPossuiItens == "true"){
                var maxItens = parseFloat($("maxItens"+idColeta).value);

                for (var ia = 0 ; ia <= maxItens ; ia++){
                    if ($("itemIdNota_"+ idColeta+ia) != null){
                        Element.remove("itemIdNota_"+ idColeta+ia);
                        Element.remove("itemId_"+ idColeta+ia);
                        Element.remove("itemDescricao_"+ idColeta+ia);
                        Element.remove("itemQuantidade_"+ idColeta+ia);
                        Element.remove("itemValor_"+ idColeta+ia);
                        Element.remove("produtoId"+ idColeta+ia);
                        Element.remove("basePallet"+ idColeta+ia);
                        Element.remove("alturaPallet"+ idColeta+ia);
                    }
                }

                for (var i = 0 ; i <= maxItens;i++){
                    if ( $("idItemNota_"+idColeta+i) != null ){
                        var id = $("idItemNota_" +idColeta+ i).value;
                        var idProdNota = $("produtoId"+ idColeta +i).value;
                        var descricao = $("nf_conteudo" +idColeta+ i).value;
                        var quant = $("quantidadeItemNota_" +idColeta+ i).value;
                        var valor = $("vlUnitarioItemNota_" +idColeta+ i).value;
                        var posicao = i;
                        var basePallet = $("basePallet" + idColeta +i).value;
                        var alturaPallet = $("alturaPallet"+ idColeta +i).value;
                        addUpdateNotaFiscal2(tr,idNota,id,idColeta,descricao,quant,valor,posicao,idProdNota, basePallet,alturaPallet);
                    }
                }
            }
            
            /*itens MEtro - inicio*/
            var maxItensMetro = parseFloat($("maxItensMetro"+idColeta).value);

            for (var ia = 0 ; ia <= maxItensMetro ; ia++){
                if ($("nf_metroVolume_"+ idColeta+ia) != null){
                    Element.remove("nf_metroVolume_"+ idColeta+ia);
                    Element.remove("nf_metroComprimento_"+ idColeta+ia);
                    Element.remove("nf_metroLargura_"+ idColeta+ia);
                    Element.remove("nf_itemAltura_"+ idColeta+ia);
                    Element.remove("nf_metroCubico_"+ idColeta+ia);
                    Element.remove("nf_metroId_"+ idColeta+ia);
                    Element.remove("nf_metroIdNota_"+ idColeta+ia);
                    Element.remove("nf_metroEtiqueta_"+ idColeta+ia);
                }
            }
            
            for (var i = 0 ; i <= maxItensMetro;i++){
                
                if ( $("metroid_"+idColeta+i) != null ){
                    var id1 = $("metroid_" +idColeta+ i).value;
                    var metroCubico = $("inMetroCubico_" +idColeta+ i).value;
                    var altura = $("inAltura_" +idColeta+ i).value;
                    var largura = $("inLargura_" +idColeta+ i).value;
                    var comprimento = $("inComprimento_" +idColeta+ i).value;
                    var volume = $("inVolume_" +idColeta+ i).value;
                    var posicao1 = i;

                    addUpdateNotaFiscal3(tr,idNota,id1,idColeta,metroCubico,altura,largura,comprimento,volume,'',posicao1);
                }
            }
        /*itens MEtro - fim*/
            
        }

        if (isReadOnly == false || isReadOnly == 'false' || isReadOnly == 'f'){
            //atualizando a soma do peso
            if (window.updateSum != null){
                updateSum(true);
            }
            if (window.applyEventInNote != null){
                var coletaId = idColeta.split("id")[1];
                applyEventInNote(coletaId);
            }
        }
    }
}

function limparPrompt(){
    document.getElementById('inNotaFiscal').value = '';
    document.getElementById('inSerie').value = '1';
    document.getElementById('inValor').value = '0.00';
    document.getElementById('inBaseIcms').value = '0.00';
    document.getElementById('inValorIcms').value = '0.00';
    document.getElementById('inIcmsSt').value = '0.00';
    document.getElementById('inIcmsFrete').value = '0.00';
    document.getElementById('inPeso').value = '0.00';
    document.getElementById('inVolume').value = '0.00';
    document.getElementById('inEmbalagem').value = '';
    document.getElementById('inConteudo').value = '';
    document.getElementById('inPedido').value = '';
    document.getElementById('inAltura').value = '0.00';
    document.getElementById('inLargura').value = '0.00';
    document.getElementById('inComprimento').value = '0.00';
    document.getElementById('inMetroCubico').value = '0.00';
    document.getElementById('maxItens').value = '0';
    document.getElementById('maxItensMetro').value = '0';
    countItemNota= 0;
}

function limparProdutoNota(index){
    $("nf_conteudo"+index).value = "";
    $("produtoId"+index).value = 0;
}

/**Remove uma nota de uma lista*/
function editNote(sufix,isPossuiItens,isBaixaNota,isReadOnly,isEdi,travarCampos) {

    if ($('tipoTransporte') != null){
        $('tipoTransporte').style.display = 'none';
    }
    if ($('tipoConhecimento') != null){
        $('tipoConhecimento').style.display = 'none';
    }
    if ($('tipoFpag') != null){
        $('tipoFpag').style.display = 'none';
    }
    if ($('clientepagador') != null){
        $('clientepagador').style.display = 'none';
    }
    addUpdateNotaFiscal('editar',sufix,'tableNotes0',$('nf_numero'+sufix).value,$('nf_serie'+sufix).value,
        $('nf_emissao'+sufix).value, $('nf_valor'+sufix).value, $('nf_peso'+sufix).value,
        $('nf_volume'+sufix).value, $('nf_altura'+sufix).value,
        $('nf_largura'+sufix).value, $('nf_comprimento'+sufix).value, $('nf_metroCubico'+sufix).value,
        $('nf_embalagem'+sufix).value, $('nf_conteudo'+sufix).value, $('nf_base_icms'+sufix).value,
        $('nf_icms'+sufix).value, $('nf_icms_st'+sufix).value, $('nf_icms_frete'+sufix).value,
        $('nf_pedido'+sufix).value, $('nf_id_marca_veiculo'+sufix).value,
        $('nf_marca_veiculo'+sufix).value, $('nf_modelo_veiculo'+sufix).value,
        $('nf_ano_veiculo'+sufix).value, $('nf_cor_veiculo'+sufix).value,
        $('nf_chassi_veiculo'+sufix).value,maxItens,isPossuiItens,
        $('nf_cfopId'+sufix).value,$('nf_cfop'+sufix).value,$('nf_chave_nf'+sufix).value,
        $('nf_is_agendado'+sufix).value,$('nf_data_agenda'+sufix).value,$('nf_hora_agenda'+sufix).value,
        $('nf_obs_agenda'+sufix).value,isBaixaNota,$('nf_previsao_entrega'+sufix).value, $('nf_previsao_as'+sufix).value,
        $('nf_id_destinatario'+sufix).value,$('nf_destinatario'+sufix).value,isReadOnly,isEdi
        ,$('nf_placa_veiculo'+sufix).value, $('nf_veiculo_novo'+sufix).value, $('nf_cor_fab'+sufix).value, $('nf_marcamodelo_veiculo'+sufix).value, travarCampos);
      
    var maxItens = $('maxItens'+sufix).value;

    $('maxItens'+sufix).value = "0";
    
    for (var i = 0 ; i <= maxItens;i++){
        if ( $("itemIdNota_"+sufix+i) != null ){
            var id = $("itemId_" +sufix+ i).value;
            var descricao = $("itemDescricao_" +sufix+ i).value;
            var quant = $("itemQuantidade_" +sufix+ i).value;
            var valor = $("itemValor_" +sufix+ i).value;
            var idProdNota = $("produtoId" +sufix+ i).value;
            var basePallet = $("basePallet" +sufix+ i).value;
            var alturaPallet = $("alturaPallet" +sufix+ i).value;
            addItemNota(id,sufix,descricao,quant,valor,idProdNota,basePallet,alturaPallet);
        }
    }
    
    var maxItensMetro = $('maxItensMetro'+sufix).value;
    var itemCubagem;
    $('maxItensMetro'+sufix).value = "0";
    for (var i = 1 ; i <= maxItensMetro;i++){
        
        if ( $("nf_metroVolume_"+sufix+i) != null ){
            itemCubagem = new ItemCubagem($("nf_metroId_" +sufix+ i).value, $("nf_metroVolume_" +sufix+ i).value, $("nf_metroComprimento_" +sufix+ i).value, $("nf_metroLargura_" +sufix+ i).value, $("nf_itemAltura_" +sufix+ i).value, $("nf_metroCubico_" +sufix+ i).value, $("nf_metroEtiqueta_" +sufix+ i).value);
            addItemCubagem(sufix,itemCubagem);
        }
    }
    
    
    
    if($('nf_itemAltura_'+sufix+"0") != null){    
        $('metroid_'+sufix+"0").value = $('nf_metroId_'+sufix+"0").value;
        $('inAltura_'+sufix+"0").value = $("nf_itemAltura_" +sufix+ "0").value
        $('inMetroCubico_'+sufix+"0").value = $("nf_metroCubico_" +sufix+ "0").value
        $('inLargura_'+sufix+"0").value = $("nf_metroLargura_" +sufix+ "0").value
        $('inVolume_'+sufix+"0").value = $("nf_metroVolume_" +sufix+ "0").value
        $('inComprimento_'+sufix+"0").value = $("nf_metroComprimento_" +sufix+ "0").value
    }

    blockInterface(true);

}

//function ItemCubagem(id, notaFiscalId, volume, comprimento, largura, altura, metroCubico,tbodyI,isDisplayNone){
function ItemCubagem(id, volume, comprimento, largura, altura, metroCubico, etiqueta){
    this.id=(id==null || id==undefined?"0":id);
    //this.notaFiscalId=(notaFiscalId==null || notaFiscalId==undefined?"0":notaFiscalId);
    this.volume=(volume==null || volume==undefined?"0.00":volume);
    this.comprimento=(comprimento==null || comprimento==undefined?"0.00":comprimento);
    this.largura=(largura==null || largura==undefined?"0.00":largura);
    this.altura=(altura==null || altura==undefined?"0.00":altura);
    this.metroCubico=(metroCubico==null || metroCubico==undefined?"0.00":metroCubico);
    this.etiqueta = (etiqueta == null || etiqueta == undefined ? "" : etiqueta);
}

var countCubagem = 0;
function addItemCubagem(sufix,itemCubagem){
    countCubagem++;
    
    if (itemCubagem == undefined){
        itemCubagem = new ItemCubagem();
    }

    var _tr = Builder.node("tr", {
        name: "trCubagem_"+sufix + countCubagem,
        id: "trCubagem_"+sufix + countCubagem,
        className: "CelulaZebra2"
    });

    //primeiro Campo excluir
    var _td1 = Builder.node("td",{
        className:"CelulaZebra2"
    });
        
    var _ip1 = Builder.node("img", {
        src: "img/lixo.png" ,
        onclick:"Element.remove('trCubagem_"+sufix+countCubagem+"');calcMetro('"+sufix+"')"
    });
    var _ip1a = Builder.node("input", {
        type:"hidden",
        id:"metroid_"+sufix+countCubagem,
        name:"metroid_"+sufix+countCubagem,
        value:itemCubagem.id
    });
    /*
    var _ip1b = Builder.node("input", {
        type:"hidden",
        id:"metronotaid_"+countCubagem,
        name:"metronotaid_"+countCubagem,
        value:itemCubagem.notaFiscalId
    });*/
    
    _td1.appendChild(_ip1);
    _td1.appendChild(_ip1a);
    //_td1.appendChild(_ip1b);
        
    
    
    //lb Volume
    var _td2 = Builder.node("td",{
        className:"TextoCampos"
    });
    var _ip2 = Builder.node("label", {
        name: "lbVolume_" +sufix+ countCubagem,
        id: "lbVolume_" +sufix+ countCubagem
    });
    _td2.appendChild(_ip2);

    //Volume
    var _td3 = Builder.node("td",{
        className:"CelulaZebra2"
    });
    var _ip3 = Builder.node("input", {
        name: "inVolume_" +sufix+ countCubagem,
        id: "inVolume_" +sufix+ countCubagem,
        type: "text",
        value:itemCubagem.volume,
        size: "8",
        className: "fieldMin",
        style:"font-size:8pt;",
        onBlur:"seNaoFloatReset(this,0.00);calcMetro('"+sufix+"');somaVolume('"+sufix+"')"
    });
    _td3.appendChild(_ip3);

    //lb Comprimento
    var _td8 = Builder.node("td",{
        className:"TextoCampos"
    });
    var _ip8 = Builder.node("label", {
        name: "lbComprimento_" +sufix+ countCubagem,
        id: "lbComprimento_" +sufix+ countCubagem
    });
    _td8.appendChild(_ip8);

    //Comprimento
    var _td9 = Builder.node("td",{
        className:"CelulaZebra2"
    });
    var _ip9 = Builder.node("input", {
        name: "inComprimento_" + sufix+countCubagem,
        id: "inComprimento_" + sufix+countCubagem,
        type: "text",
        className: "fieldMin",
        value:itemCubagem.comprimento,
        size: "8",
        onBlur:"seNaoFloatReset(this,0.00);calcMetro('"+sufix+"');",
        style:"font-size:8pt;"
    });
    _td9.appendChild(_ip9);

    //lb Largura
    var _td6 = Builder.node("td",{
        className:"TextoCampos"
    });
    var _ip6 = Builder.node("label", {
        name: "lbLargura_" + sufix+countCubagem,
        id: "lbLargura_" + sufix+countCubagem
    });
    _td6.appendChild(_ip6);

    //Largura
    var _td7 = Builder.node("td",{
        className:"CelulaZebra2"
    });
    var _ip7 = Builder.node("input", {
        name: "inLargura_" +sufix+ countCubagem,
        id: "inLargura_" +sufix+ countCubagem,
        type: "text",
        value:itemCubagem.largura,
        className: "fieldMin",
        size: "8",
        onBlur:"seNaoFloatReset(this,0.00);calcMetro('"+sufix+"');",
        style:"font-size:8pt;"
    });
    _td7.appendChild(_ip7);

    //lb Altura
    var _td4 = Builder.node("td",{
        className:"TextoCampos"
    });
    var _ip4 = Builder.node("label", {
        name: "lbAltura_" + sufix+countCubagem,
        id: "lbAltura_" + sufix+countCubagem
    });
    _td4.appendChild(_ip4);

    //Altura
    var _td5 = Builder.node("td",{
        className:"CelulaZebra2"
    });
    var _ip5 = Builder.node("input", {
        name: "inAltura_" + sufix+countCubagem,
        id: "inAltura_" + sufix+countCubagem,
        type: "text",
        className: "fieldMin",
        value:itemCubagem.altura,
        size: "8",
        onBlur:"seNaoFloatReset(this,0.00);calcMetro('"+sufix+"');",
        style:"font-size:8pt;"
    });
    _td5.appendChild(_ip5);

    //lb Metro
    var _td10 = Builder.node("td",{
        className:"TextoCampos"
    });
    var _ip10 = Builder.node("label", {
        name: "lbMetroCubico_" +sufix+ countCubagem,
        id: "lbMetroCubico_" + sufix+countCubagem
    });
    _td10.appendChild(_ip10);

    //Metro
    var _td11 = Builder.node("td",{
        className:"CelulaZebra2"
    });
    var _ip11 = Builder.node("input", {
        name: "inMetroCubico_" +sufix+ countCubagem,
        id: "inMetroCubico_" + sufix+ countCubagem,
        type: "text",
        className: "fieldMin",
        value:itemCubagem.metroCubico,
        size: "8",
        onBlur:"seNaoFloatReset(this,0.00);somaMetroCubico('"+sufix+"')",
        style:"font-size:8pt;"
    });
    _td11.appendChild(_ip11);

    _tr.appendChild(_td1);
    _tr.appendChild(_td2);
    _tr.appendChild(_td3);
    _tr.appendChild(_td8);
    _tr.appendChild(_td9);
    _tr.appendChild(_td6);
    _tr.appendChild(_td7);
    _tr.appendChild(_td4);
    _tr.appendChild(_td5);
    _tr.appendChild(_td10);
    _tr.appendChild(_td11);

    document.getElementById("tbCubagem").appendChild(_tr);
    document.getElementById("maxCubagem").value = countCubagem;
    document.getElementById("maxItensMetro"+sufix).value = countCubagem;

    document.getElementById("lbVolume_"+sufix + countCubagem).innerHTML = "Volume:";
    document.getElementById("lbAltura_"+sufix + countCubagem).innerHTML = "Alt.:";
    document.getElementById("lbLargura_"+sufix + countCubagem).innerHTML = "Largura:";
    document.getElementById("lbComprimento_"+sufix + countCubagem).innerHTML = "Comp.:";
    document.getElementById("lbMetroCubico_" +sufix+ countCubagem).innerHTML = "M³:";
}

function verificaNumeroNotaFiscal(e) {
    document.querySelectorAll('[key]').forEach(function(b){
        let serieAnt = e.parentNode.nextSibling.firstChild;
        let serieProx = b.parentNode.nextSibling.firstChild;
        
        if (e !== b && b.value === e.value && serieAnt.value === serieProx.value && b.value.trim() !== '' && e.value.trim() !== '') {
            alert('A nota com o número : ' + b.value + ' já existe');
            return false;
        }
    });
}
