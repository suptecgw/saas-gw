/**
	Métodos úteis para manipulacao de serviços em um cadastro. 
*/

/*--- Variaveis globais ---*/ 
var indexesForServico = new Array(); 
var listaTrib = null;
/* Armazena o total de serviços lançados */
var qtdServicos = 0;

/**Retorna o próximo ID da table*/
function getNextIndexFromServ(idTableRoot) {
    if (getObj("trServ1_1") == null)
        return 1;
    var r = 2;
    while (getObj("trServ1_"+r) != null)
        ++r;
		
    return 	r;
}

function toInt(valor){
    if (valor.indexOf('.') > -1)
        return valor.substring(0,valor.indexOf('.') );
    else
        return valor;	
}

/**@exemplo - addServ(idTableRoot, id, id_servico, servico, qtd, vl_unitario, vl_total, 
                    perc_iss, vl_iss, trib)*/


function thisMascara(elemento, fixed){
    try {
        var valor = colocarVirgula(elemento.value, fixed);
        elemento.value = colocarPonto(valor);
    } catch (e) { 
        alert(e);
    }

}

function addServ(
    listaTributos,
    idTableRoot, 
    id, 
    id_servico, 
    servico, 
    qtd, 
    vl_unitario, 
    todasTaxas, 
    tribGenerico, 
    id_plano, 
    conta_plano, 
    descricao_plano,
    idColeta, 
    coleta,
    usaDias,
    qtdDias,notas, 
    notaFiscal, 
    embutirISS, 
    incluir, 
    nfsId,
    descCompl, 
    casasDecimaisQuantidade,
    casasDecimaisValor,
    exigibilidadeISS,
    tipoCalculoIss){
    try {
        incluir = (incluir == undefined || incluir== null ? false : incluir);    
        casasDecimaisQuantidade = (casasDecimaisQuantidade == undefined || casasDecimaisQuantidade== null ? 2 : casasDecimaisQuantidade);    
        casasDecimaisValor = (casasDecimaisValor == undefined || casasDecimaisValor== null ? 2 : casasDecimaisValor);    
        exigibilidadeISS = (exigibilidadeISS == undefined || exigibilidadeISS== null ? 1 : exigibilidadeISS);    
        //vl_iss = (vl_iss != null && vl_iss != undefined? arredondar(vl_iss, 2) : vl_iss);
        nfsId = (nfsId != null && nfsId != undefined? nfsId : 0);
        embutirISS = (embutirISS == undefined || embutirISS== null || embutirISS== false || embutirISS== "f"? false : true );
        
        var tableRoot = getObj(idTableRoot);
        var indice = getNextIndexFromServ(idTableRoot);
        
        //simplificando na hora da chamada
        var sufixID = indice;
        var nameTR = "trServ1_" + sufixID;
        var nameTR2 = "trServ2_" + sufixID;
        
        var trServ = makeElement("TR", "class=cellNotes&id="+nameTR);
        
        //fabricando campos e strings de comando
        var commonObj = "type=text&class=fieldMin";
        var commonField = "seNaoFloatReset($(\'";
        var commonSufix = sufixID+"\'),\'0.00\');";
        //var commonSufix = sufixID+"\'),\'0.00\');calculaTotal("+sufixID+");";
        var commonFieldInt = "seNaoIntReset($(\'";
        var commonSufixInt = sufixID+"\'),\'1\');getCalculaTotalServ("+sufixID+","+tipoCalculoIss+");";
        var callGetCalculoTotalServ = "getCalculaTotalServ("+sufixID+","+tipoCalculoIss+");";
        
        var _td1_1 = Builder.node('td');
        var _td1_2 = Builder.node('td');
        var _td1_2_2 = Builder.node('td');
        var _td1_3 = Builder.node('td');
        var _td1_4 = Builder.node('td');
        var _td1_5 = Builder.node('td');
        var _td1_6 = Builder.node('td');
        var _td1_7 = Builder.node('td',{
            align :"center"
        });
        var _td1_8 = Builder.node('td');
        var _td1_9 = Builder.node('td');
        //[nfsId == 0 ? Builder.node('IMG',{ src:'img/cancelar.png', id:'botDel' + sufixID, border:'0', onclick:'removeServ('+nameTR+','+sufixID+');', className:'imagemLink', title:'Remover este serviço'}) :""]
        
        var _img1_1 = Builder.node('IMG',{
            src:'img/lixo.png', 
            id:'botDel' + sufixID, 
            border:'0', 
            onclick:'removeServ('+nameTR+','+sufixID+');', 
            className:'imagemLink', 
            title:'Remover este serviço'
        });
        _td1_1.appendChild(_img1_1);
        
        var _inp1_descServico = Builder.node('INPUT', {
            type:'text', 
            name:'servico'+sufixID, 
            id:'servico'+sufixID, 
            size:'45', 
            value:servico, 
            className:'inputReadOnly8pt', 
            readOnly:'true'
        });
        var _inp2_id = Builder.node('INPUT', {
            type:'hidden', 
            name:'id'+sufixID, 
            id:'id'+sufixID, 
            value:id
        });
        var _inpCasasDecQtd = Builder.node('INPUT', {
            type:'hidden', 
            name:'casasDecQtd_'+sufixID, 
            id:'casasDecQtd_'+sufixID, 
            value:casasDecimaisQuantidade
        });
        var _inpCasasDecVl = Builder.node('INPUT', {
            type:'hidden', 
            name:'casasDecVl_'+sufixID, 
            id:'casasDecVl_'+sufixID, 
            value:casasDecimaisValor
        });
        var _inp3_idServico =  Builder.node('INPUT', {
            type:'hidden', 
            name:'id_servico'+sufixID, 
            id:'id_servico'+sufixID, 
            value:id_servico
        });
        var _inp4_idPlano =  Builder.node('INPUT', {
            type:'hidden', 
            name:'id_plano'+sufixID, 
            id:'id_plano'+sufixID, 
            value:id_plano
        });
        var _inp5_contaPlano = Builder.node('INPUT', {
            type:'hidden', 
            name:'conta_plano'+sufixID, 
            id:'conta_plano'+sufixID, 
            value:conta_plano
        });
        var _inp6_descPlano = Builder.node('INPUT', {
            type:'hidden', 
            name:'descricao_plano'+sufixID, 
            id:'descricao_plano'+sufixID, 
            value:descricao_plano
        });
        var _inp7_descServicoComplementar = Builder.node('INPUT', {
            type:'text', 
            name:'servicoCompl'+sufixID, 
            id:'servicoCompl'+sufixID, 
            size:'25', 
            value:descCompl, 
            className:'fieldMin'
        });
        
        var _inp8Hid_ExigibilidadeISS = Builder.node('INPUT', {
            type:'hidden', 
            name:'exigibilidadeISS_'+sufixID, 
            id:'exigibilidadeISS_'+sufixID, 
            value:exigibilidadeISS, 
        });
        
        _td1_2.appendChild(_inp1_descServico);
        _td1_2_2.appendChild(_inp7_descServicoComplementar);
        _td1_2.appendChild(_inp2_id);
        _td1_2.appendChild(_inp3_idServico);
        _td1_2.appendChild(_inp4_idPlano);
        _td1_2.appendChild(_inp5_contaPlano);
        _td1_2.appendChild(_inp6_descPlano);
        _td1_2.appendChild(_inpCasasDecQtd);
        _td1_2.appendChild(_inpCasasDecVl);
        _td1_2.appendChild(_inp8Hid_ExigibilidadeISS);
        
        var _inp7_qtdDias = Builder.node('INPUT', {
            type:'text', 
            name:'qtdDias_'+sufixID, 
            id:'qtdDias_'+sufixID, 
            size:'5', 
            maxLength:'11', 
            value:qtdDias, 
            onblur:"getCalculaTotalServ("+sufixID+","+tipoCalculoIss+")", 
            className:'fieldMin'
        });
        _td1_3.appendChild(_inp7_qtdDias);

        var _inp12_qtdServ = Builder.node('INPUT', {
            type:'text', 
            name:'qtd'+sufixID, 
            id:'qtd'+sufixID, 
            size:'7', 
            maxLength:'11', 
            value:formatoMoeda(qtd), 
            className:'fieldMin',
            onblur: callGetCalculoTotalServ+ "thisMascara(this,"+casasDecimaisQuantidade+");"
        });
        thisMascara(_inp12_qtdServ, casasDecimaisQuantidade);
        _td1_4.appendChild(_inp12_qtdServ);
        
        var _inp8_valorUnitario = Builder.node('INPUT', {
            type:'text', 
            name:'vl_unitario'+sufixID, 
            id:'vl_unitario'+sufixID, 
            size:'9', 
            maxLength:'11', 
            value:formatoMoeda(vl_unitario), 
            className:'fieldMin', 
            onchange : callGetCalculoTotalServ+ "thisMascara(this,"+casasDecimaisValor+");"
        });
        thisMascara(_inp8_valorUnitario, casasDecimaisValor);
        var _inp9_hiddenValorUnitario =  Builder.node('INPUT', {
            type:'hidden', 
            name:'vl_unitario_hi_'+sufixID, 
            id:'vl_unitario_hi_'+sufixID, 
            value: (!incluir && embutirISS ? vl_unitario -(listaTributos[0].valor/qtd): vl_unitario)
        });
        thisMascara(_inp9_hiddenValorUnitario, casasDecimaisValor);
        
        _td1_5.appendChild(_inp8_valorUnitario);
        _td1_5.appendChild(_inp9_hiddenValorUnitario);
        
        var _inp10_valorTotal = Builder.node('INPUT', {
            type:'text', 
            name:'vl_total'+sufixID, 
            id:'vl_total'+sufixID, 
            size:'9', 
            maxLength:'11', 
            value: vl_unitario * qtd, 
            className:'fieldMin', 
            onchange:commonField+'vl_total'+commonSufix, 
            readOnly:'true'
        });
        _td1_6.appendChild(_inp10_valorTotal);
        
        var _inp11_embutirISS = Builder.node('INPUT', {
            type:"checkbox", 
            name:'embutirISS_'+sufixID, 
            id:'embutirISS_'+sufixID, 
            title:'Embutir ISS no valor do serviço', 
            onClick: "validaTipoTributacao("+sufixID+","+tipoCalculoIss+");"
        });//
        _td1_7.appendChild(_inp11_embutirISS);
        
        var _lab1_coleta = Builder.node('LABEL', {
            name:'coleta'+sufixID, 
            id:'coleta'+sufixID
        }, coleta);
        _td1_8.appendChild(_lab1_coleta);
        
        var _slc1_nota = Builder.node('SELECT', {
            name:'notaServico'+sufixID, 
            id:'notaServico'+sufixID, 
            className:'fieldMin'
        });
        _td1_9.appendChild(_slc1_nota);
        //#############   IMPOSTOS   ################# INICIO
        
        
        var _td2_0 = Builder.node("td");
        var _td2_1 = Builder.node("TD", {
            colSpan:10
        });
        var _table = Builder.node("TABLE",{
            width:"100%"
        });
        var _tbody = Builder.node("tbody", {
            id:'tbody'+sufixID
        });
        var _tr2_1 = Builder.node("TR", {
            className:'cellNotes'
        });
        
        var _td2_1_1 = Builder.node("TD");
        
        var _lab1 = Builder.node("LABEL");
        Element.update(_lab1, "<b>Impostos:</b>&nbsp;");        
        _td2_1_1.appendChild(_lab1);
        //---------------------ISS
        
        var _lab2 = Builder.node("LABEL");
        Element.update(_lab2, "ISS:");        
        _td2_1_1.appendChild(_lab2);
        
        
        var _td2_1_2 = Builder.node("TD"   
            );
        var _ip2_1 = Builder.node("INPUT", {
            name: "perc_iss" + sufixID,
            id: "perc_iss" + sufixID,
            type: "text", 
            value:  arredondar(listaTributos[0].aliquota).toFixed(2),
            size: "4", 
            className:"fieldMin",
            onchange:commonField+'perc_iss'+commonSufix + callGetCalculoTotalServ
        
        });
        _td2_1_2.appendChild(_ip2_1);
        
        var _td2_1_3 = Builder.node("TD");
        var _ip2_2 = Builder.node("INPUT", {
            name: "vl_iss" + sufixID, 
            id: "vl_iss" + sufixID,
            type: "text", 
            value: listaTributos[0].valor,
            size: "5", 
            className:"inputReadOnly8pt", 
            onchange:commonField+'vl_iss'+commonSufix + callGetCalculoTotalServ,
            readOnly:'true'
        });
        _td2_1_3.appendChild(_ip2_2);
        
        
        var _td2_1_4 = Builder.node("TD");
        var _slct2_1 = Builder.node("SELECT", {
            name:"issTrib" + sufixID,
            id:"issTrib" + sufixID, 
            className:"fieldMin",
            style: 'width: 30px;'
        });
        _td2_1_4.appendChild(_slct2_1);
        //---------------------INSS
        var _td2_1_5 = Builder.node("TD");
        var _lab4 = Builder.node("LABEL");
        Element.update(_lab4, "INSS:");        
        _td2_1_5.appendChild(_lab4);
        
        
        var _td2_1_6 = Builder.node("TD");
        var _ip2_3 = Builder.node("INPUT", {
            name: "perc_inss" + sufixID,
            id: "perc_inss" + sufixID,
            type: "text", 
            value:  arredondar(listaTributos[1].aliquota).toFixed(2),
            size: "4", 
            className:"fieldMin",
            onchange :commonField+'perc_inss'+commonSufix + callGetCalculoTotalServ
        });
        _td2_1_6.appendChild(_ip2_3);
        
        var _td2_1_7 = Builder.node("TD");
        var _ip2_4 = Builder.node("INPUT", {
            name: "vl_inss" + sufixID, 
            id: "vl_inss" + sufixID,
            type: "text", 
            value: arredondar(listaTributos[1].valor).toFixed(2),
            size: "5", 
            className:"inputReadOnly8pt", 
            onchange :commonField+'vl_inss'+commonSufix + callGetCalculoTotalServ,
            readOnly:'true'
        });
        _td2_1_7.appendChild(_ip2_4);
        
        
        var _td2_1_8 = Builder.node("TD");
        var _slct2_7 = Builder.node("select", {
            name:"inssTrib" + sufixID,
            id:"inssTrib" + sufixID, 
            className:"fieldMin",
            style: 'width: 30px;'
        });
        
        _td2_1_8.appendChild(_slct2_7);
        
        
        //---------------------PIS
        var _td2_1_9 = Builder.node("TD");
        var _lab5 = Builder.node("LABEL");
        Element.update(_lab5, "PIS:");        
        _td2_1_9.appendChild(_lab5);
        
        
        var _td2_1_10 = Builder.node("td");
        var _ip2_5 = Builder.node("INPUT", {
            name: "perc_pis" + sufixID,
            id: "perc_pis" + sufixID,
            type: "text", 
            value:  arredondar(listaTributos[2].aliquota).toFixed(2),
            size: "4", 
            className:"fieldMin",
            onchange :commonField+'perc_pis'+commonSufix + callGetCalculoTotalServ
        });
        _td2_1_10.appendChild(_ip2_5);
        
        var _td2_1_11 = Builder.node("TD");
        var _ip2_6 = Builder.node("INPUT", {
            name: "vl_pis" + sufixID, 
            id: "vl_pis" + sufixID,
            type: "text", 
            value: arredondar(listaTributos[2].valor).toFixed(2),
            size: "5", 
            className:"inputReadOnly8pt", 
            onchange:commonField+'vl_pis'+commonSufix ,
            readOnly:'true'
        });
        _td2_1_11.appendChild(_ip2_6);
        
        
        var _td2_1_12 = Builder.node("TD");
        var _slct2_12 = Builder.node("SELECT", {
            name:"pisTrib" + sufixID,
            id:"pisTrib" + sufixID, 
            className:"fieldMin",
            style: 'width: 30px;'
        });
        _td2_1_12.appendChild(_slct2_12);
        
        //---------------------COFINS
        var _td2_1_13 = Builder.node("TD");
        var _lab13 = Builder.node("LABEL");
        Element.update(_lab13, "COFINS:");        
        _td2_1_13.appendChild(_lab13);
        
        
        var _td2_1_14 = Builder.node("TD");
        var _ip2_14 = Builder.node("INPUT", {
            name: "perc_cofins" + sufixID,
            id: "perc_cofins" + sufixID,
            type: "text", 
            value:  arredondar(listaTributos[3].aliquota).toFixed(2),
            size: "4", 
            className:"fieldMin",
            onchange :commonField+'perc_cofins'+commonSufix + callGetCalculoTotalServ
        });
        _td2_1_14.appendChild(_ip2_14);
        
        var _td2_1_15 = Builder.node("TD");
        var _ip2_15 = Builder.node("INPUT", {
            name: "vl_cofins" + sufixID, 
            id: "vl_cofins" + sufixID,
            type: "text", 
            value: arredondar(listaTributos[3].valor).toFixed(2),
            size: "5", 
            className:"inputReadOnly8pt", 
            onchange:commonField+'vl_cofins'+commonSufix,
            readOnly:'true'
        });
        _td2_1_15.appendChild(_ip2_15);
        
        
        var _td2_1_16 = Builder.node("TD");
        var _slct2_16 = Builder.node("SELECT", {
            name:"cofinsTrib" + sufixID,
            id:"cofinsTrib" + sufixID, 
            className:"fieldMin",
            style: 'width: 30px;'
        });
        _td2_1_16.appendChild(_slct2_16);
        
        
        //---------------------IR
        var _td2_1_17 = Builder.node("TD");
        var _lab17 = Builder.node("LABEL");
        Element.update(_lab17, "IR:");        
        _td2_1_17.appendChild(_lab17);
        
        
        var _td2_1_18 = Builder.node("TD");
        var _ip2_18 = Builder.node("INPUT", {
            name: "perc_ir" + sufixID,
            id: "perc_ir" + sufixID,
            type: "text", 
            value:  arredondar(listaTributos[4].aliquota).toFixed(2),
            size: "4", 
            className:"fieldMin",
            onchange :commonField+'perc_ir'+commonSufix + callGetCalculoTotalServ
        });
        _td2_1_18.appendChild(_ip2_18);
        
        var _td2_1_19 = Builder.node("TD");
        var _ip2_19 = Builder.node("INPUT", {
            name: "vl_ir" + sufixID, 
            id: "vl_ir" + sufixID,
            type: "text", 
            value: arredondar(listaTributos[4].valor).toFixed(2),
            size: "5", 
            className:"inputReadOnly8pt", 
            onchange:commonField+'vl_ir'+commonSufix,
            readOnly:'true'
        });
        _td2_1_19.appendChild(_ip2_19);
        
        
        var _td2_1_20 = Builder.node("TD");
        var _slct2_20 = Builder.node("SELECT", {
            name:"irTrib" + sufixID,
            id:"irTrib" + sufixID, 
            className:"fieldMin",
            style: 'width: 30px;'
        });
        _td2_1_20.appendChild(_slct2_20);
        
        //---------------------CSSL
        var _td2_1_21 = Builder.node("TD");
        var _lab21 = Builder.node("LABEL");
        Element.update(_lab21, "CSSL:");        
        _td2_1_21.appendChild(_lab21);
        
        
        var _td2_1_22 = Builder.node("TD");
        var _ip2_22 = Builder.node("INPUT", {
            name: "perc_cssl" + sufixID,
            id: "perc_cssl" + sufixID,
            type: "text", 
            value:  arredondar(listaTributos[5].aliquota).toFixed(2),
            size: "4", 
            className:"fieldMin",
            onchange :commonField+'perc_cssl'+commonSufix + callGetCalculoTotalServ
        });
        _td2_1_22.appendChild(_ip2_22);
        
        var _td2_1_23 = Builder.node("TD");
        var _ip2_23 = Builder.node("INPUT", {
            name: "vl_cssl" + sufixID, 
            id: "vl_cssl" + sufixID,
            type: "text", 
            value: arredondar(listaTributos[5].valor).toFixed(2),
            size: "5", 
            className:"inputReadOnly8pt", 
            onchange:commonField+'vl_cssl'+commonSufix,
            readOnly:'true'
        });
        _td2_1_23.appendChild(_ip2_23);
        
        
        var _td2_1_24 = Builder.node("TD");
        var _slct2_24 = Builder.node("SELECT", {
            name:"csslTrib" + sufixID,
            id:"csslTrib" + sufixID, 
            className:"fieldMin",
            style: 'width: 30px;'
        });
        _td2_1_24.appendChild(_slct2_24);
        
        
        _tr2_1.appendChild(_td2_1_1);
        _tr2_1.appendChild(_td2_1_2);
        _tr2_1.appendChild(_td2_1_3);
        _tr2_1.appendChild(_td2_1_4);
        _tr2_1.appendChild(_td2_1_5);
        _tr2_1.appendChild(_td2_1_6);
        _tr2_1.appendChild(_td2_1_7);
        _tr2_1.appendChild(_td2_1_8);
        _tr2_1.appendChild(_td2_1_9);
        _tr2_1.appendChild(_td2_1_10);
        _tr2_1.appendChild(_td2_1_11);
        _tr2_1.appendChild(_td2_1_12);
        _tr2_1.appendChild(_td2_1_13);
        _tr2_1.appendChild(_td2_1_14);
        _tr2_1.appendChild(_td2_1_15);
        _tr2_1.appendChild(_td2_1_16);
        _tr2_1.appendChild(_td2_1_17);
        _tr2_1.appendChild(_td2_1_18);
        _tr2_1.appendChild(_td2_1_19);
        _tr2_1.appendChild(_td2_1_20);
        _tr2_1.appendChild(_td2_1_21);
        _tr2_1.appendChild(_td2_1_22);
        _tr2_1.appendChild(_td2_1_23);
        _tr2_1.appendChild(_td2_1_24);
        
        var _tr = Builder.node("TR",{
            id: nameTR, 
            name: nameTR, 
            className:'cellNotes'
        });
        var _tr2 = Builder.node("TR",{
            id: nameTR2, 
            name: nameTR2, 
            className:'cellNotes'
        });
        
        
        _tr.appendChild(_td1_1);
        _tr.appendChild(_td1_2);
        _tr.appendChild(_td1_2_2);
        _tr.appendChild(_td1_3);
        _tr.appendChild(_td1_4);
        _tr.appendChild(_td1_5);
        _tr.appendChild(_td1_6);
        _tr.appendChild(_td1_7);
        _tr.appendChild(_td1_8);
        _tr.appendChild(_td1_9);
        
        _tbody.appendChild(_tr2_1);
        _table.appendChild(_tbody);
        
        _td2_1.appendChild(_table);
        
        _tr2.appendChild(_td2_1);
        
        //#############   IMPOSTOS   ################# FIM
        //adicionando a linha na tabela
        tableRoot.appendChild(_tr);
        
        tableRoot.appendChild(_tr2);
        
        $("embutirISS_"+sufixID).checked = embutirISS;
        
        //Atribuindo as taxas
        if(todasTaxas != ""){
            for (x=0; x < todasTaxas.split('!!-').length; ++x){
                _slct2_1.appendChild(Builder.node('OPTION', {
                    value:todasTaxas.split('!!-')[x].split(':.:')[0]
                }, todasTaxas.split('!!-')[x].split(':.:')[1]));
            }
        }
        _slct2_1.value = listaTributos[0].idTaxa;
        
        for(var t = 1; t < listaTributos.length; t++){
            if(tribGenerico != ""){
                for (x=0; x < tribGenerico.split('!!-').length; ++x){
                    $(listaTributos[t].descricao+"Trib"+sufixID).appendChild(Builder.node('OPTION', {
                        value: tribGenerico.split('!!-')[x].split(':.:')[0]
                    }, tribGenerico.split('!!-')[x].split(':.:')[1]));
                }
            }
            $(listaTributos[t].descricao+"Trib"+sufixID).value = listaTributos[t].idTaxa;
            if ($(listaTributos[t].descricao+"Trib"+sufixID).selectedIndex==-1) {
                $(listaTributos[t].descricao+"Trib"+sufixID).selectedIndex = 1;
            }
        }
        
        if(notaFiscal != ""){
            
            //Atribuindo as notas
            getObj('notaServico'+sufixID).appendChild(Builder.node('OPTION', {
                value:"0"
            }, "Sem nota Fiscal"));
            for (x=0; x < notas.split('!!-').length; ++x){
                getObj('notaServico'+sufixID).appendChild(Builder.node('OPTION', {
                    value:notas.split('!!-')[x].split(':.:')[0]
                }, notas.split('!!-')[x].split(':.:')[1]));
            }
            getObj('notaServico'+sufixID).value = notaFiscal;
            getObj("notaServico"+sufixID).style.width="70px";
        }else{
            getObj('notaServico'+sufixID).style.display = "none";
        }
        
        //Calculando valor totalz
        getCalculaTotalServ(sufixID, tipoCalculoIss);
        
        if (usaDias == "t" || usaDias == "true"){
            $("qtdDias_"+sufixID).style.display="";
            $("lbDias").style.display="";
        }else{
            $("qtdDias_"+sufixID).style.display="none";
        }
        
        markFlagServ(sufixID, true);
        
        //    $('qtd'+sufixID).focus();
        validaTipoTributacao(sufixID, tipoCalculoIss);
        
        qtdServicos++;
        $("maxServico").value = sufixID;
        //chamando um possivel metodo que aplica eventos em alguns campos do servico adicionado
        if (window.applyEventInServ != null)
            applyEventInServ();
    
        if (window.carregarTotalGeralServicosParaResumo != null){
            carregarTotalGeralServicosParaResumo();
        }
    } catch (e) { 
        alert(e);
    }
  
}
function setValorHidden(idx){
    if($("vl_unitario_hi_"+idx) != null)
        $("vl_unitario_hi_"+idx).value = $("vl_unitario"+idx).value;
}

function validaTipoTributacao(idx, tipoCalculoIss) {    
    var trib = $('issTrib' + idx).value;    
    if(trib=="4"){
        $("embutirISS_"+idx).checked = false;
        desabilitar($("embutirISS_"+idx));
    }else{
        habilitar($("embutirISS_"+idx));
    }    
    getCalculaTotalServ(idx, tipoCalculoIss);
        
}

/**calcula o valor total do serviço e o valor do ISS*/
function getCalculaTotalServ(idx, tipoCalculoIss){
    var valorTotal = 0;
    var valorUnitario = 0;
    if($('embutirISS_'+idx).checked){
        valorUnitario = arredondar((parseFloat($('vl_unitario_hi_'+idx).value)/(1-(parseFloat($('perc_iss'+idx).value) / 100))),parseInt($("casasDecVl_"+idx).value));
        $('vl_unitario'+idx).value = arredondar(valorUnitario, parseInt($("casasDecVl_"+idx).value)).toFixed(parseInt($("casasDecVl_"+idx).value));
    }else{
        valorUnitario = parseFloat($('vl_unitario_hi_'+idx).value);
        $('vl_unitario'+idx).value = arredondar(valorUnitario, parseInt($("casasDecVl_"+idx).value)).toFixed(parseInt($("casasDecVl_"+idx).value));
    }
    
    listaTrib = new Array();
    /**
     * ATENCAO, DENTRO DESSE OBJETO JAVASCRIPT SAO FEITOS CALCULOS QUE LEVAM EM CONSIDERACAO O issTrib (tipo de tributacao)
     */
    listaTrib[0] = new ImpostoServico(valorUnitario * parseFloat($('qtd'+idx).value), parseFloat($('perc_iss'+idx).value), 0, $('qtdDias_'+idx).value, "iss");
    listaTrib[1] = new ImpostoServico(valorUnitario * parseFloat($('qtd'+idx).value), parseFloat($('perc_inss'+idx).value), 0, $('qtdDias_'+idx).value, "inss");
    listaTrib[2] = new ImpostoServico(valorUnitario * parseFloat($('qtd'+idx).value), parseFloat($('perc_pis'+idx).value), 0, $('qtdDias_'+idx).value, "pis");
    listaTrib[3] = new ImpostoServico(valorUnitario * parseFloat($('qtd'+idx).value), parseFloat($('perc_cofins'+idx).value), 0, $('qtdDias_'+idx).value, "cofins");
    listaTrib[4] = new ImpostoServico(valorUnitario * parseFloat($('qtd'+idx).value), parseFloat($('perc_ir'+idx).value), 0, $('qtdDias_'+idx).value, "ir");
    listaTrib[5] = new ImpostoServico(valorUnitario * parseFloat($('qtd'+idx).value), parseFloat($('perc_cssl'+idx).value), 0, $('qtdDias_'+idx).value, "cssl");
    
    valorTotal = roundABNT((parseFloat($('qtdDias_'+idx).value) * parseFloat($('qtd'+idx).value)  * valorUnitario),2).toFixed(2);
    
    //    alert("dias: " + parseFloat($('qtdDias_'+idx).value))
    //    alert("qtd: " + parseFloat($('qtd'+idx).value))
    //    alert("valorUnitario: " + parseFloat($('qtd'+idx).value))
    
    $('vl_total'+idx).value = valorTotal;
    for (var i = 0; i < listaTrib.length; i++) {
        if (tipoCalculoIss == "1") {
          $('vl_'+listaTrib[i].descricao+idx).value = arredondar(listaTrib[i].valor).toFixed(2);
        }else{
          $('vl_'+listaTrib[i].descricao+idx).value = listaTrib[i].valor.toFixed(4);
        }
    }
    
    if(window.refreshTotal != null || window.refreshTotal != undefined){
        refreshTotal(false, false);
    }
    
//$('vl_iss'+idx).value = arredondar((parseFloat($('vl_total'+idx).value) * parseFloat($('perc_iss'+idx).value) / 100),2).toFixed(2);
}

function getTotalGeralServico(){
    var notes = getIndexedServ();
    var total = 0;
    for (e = 1; e <= notes.length; ++e){
        if ((notes[e] != null) && (notes[e] == true)){
            total += parseFloat($('vl_total'+e).value);
        }//if (notes[e] == null
    }//for
    return total.toFixed(2);
}

function getTotalISS(taxas, retido){
    var listaImpostos = new Array();
    var valor = 0;
    var valorRet = 0;
    var total = 0;
    var totalIss = 0;
    var totalRet = 0;
    var totalRetIss = 0;//criei essa variavel para contar o valor total retido de ISS.
    var totalImpostosRetido = 0;
    var notes = getIndexedServ();
    
    listaImpostos[0] = "iss";
    listaImpostos[1] = "inss";
    listaImpostos[2] = "pis";
    listaImpostos[3] = "cofins";
    listaImpostos[4] = "ir";
    listaImpostos[5] = "cssl";
    //comentando para facilitar meu entendimento:
    for(var i = 0; i < listaImpostos.length; i++){//vai varrer TODOS os nomes de impostos
        imposto = listaImpostos[i];
        impostoUp = imposto.substr(0, 1).toUpperCase()+imposto.substr(1, imposto.length-1);//deixa a primeira letra MAIUSCULA
        //zerando o total quando o imposto for diferente.
        total = 0;
        totalRet = 0;
        
        for(var j = 0; j <= qtdServicos; j++ ){//vai varrer TODOS os servicos.
            //zerando valores:
            valor = 0;
            valorRet = 0;
            //
            if($("vl_"+imposto + j) != null){
                if ($(imposto+"Trib" + j).value != 4 && $(imposto+"Trib" + j).value != 6){
                    valor = parseFloat($("vl_"+imposto + j).value) + parseFloat(valor);
                    total += valor;
                    
                    if(i==0){
                        totalIss += parseFloat($("vl_"+ listaImpostos[0] + j).value);
                    }
                }else{
                    valorRet += parseFloat($("vl_"+imposto + j).value);
                    totalRet += valorRet;
                    //somando todos os valores de todos os servicos de todos os impostos para ser reduzido do total para virar o liquido.
                    totalImpostosRetido += valorRet;
                    if(i==0){
                        totalRetIss += valorRet;//ele recebe o valor SE e somente SE i = 0, ou seja, imposto = iss, igual com a variavel totalIss..
                    }
                }
            }
        }
        //seta o valor do total no label do campo condizente com o imposto atual do FOR
        if($("valorTot"+impostoUp) != null)
            $("valorTot"+impostoUp).innerHTML = formatoMoeda(total);
        
        if($("valorTot"+impostoUp+"Retido") != null)
            $("valorTot"+impostoUp+"Retido").innerHTML = formatoMoeda(totalRet);
                
    }
    //seta os valores do ISS
    if($("totalISS") != null) 
        $("totalISS").value = formatoMoeda(totalIss);
    
    if($("totalISSRetido") != null) 
        $("totalISSRetido").value = formatoMoeda(totalRetIss);//o valor calculado do total retido ISS e colocado no campo especifico da tela.
    
    if($("totalImpostosRetido") != null)
        $("totalImpostosRetido").value = formatoMoeda(totalImpostosRetido);
}
/**Remove uma nota de uma lista*/
function removeServ(nameObj, idx) {
    if (confirm("Deseja mesmo excluir este serviço da OS ?")){
        if (confirm("Tem certeza?")){
            //getObj(nameObj).parentNode.removeChild(getObj(nameObj));
            Element.remove($(nameObj));
            //removendo o indice no array(como o array começa em 0, subtraimos 1)
            markFlagServ(idx, false);
            var aux = nameObj.id.split("_")[0].substr(0, nameObj.id.split("_")[0].length-1)+2+"_"+idx;
            Element.remove($(aux));    
            if (window.refreshTotal != null) {
                refreshTotal(true,true);            
            }
        }
    }
    //atualizando a soma do peso
    //    if (window.updateSum != null)
    //	updateSum(true);
}

    

function removeAllServ(){
    var notes = getIndexedServ();
    for (e = 0; e < notes.length; e++){
        if ((notes[e] != null) && (notes[e] == true)){
            Element.remove($("trServ1_" + e));
            Element.remove($("trServ2_" + e));
            markFlagServ(e, false);
        }
    }
}
function bloqueiaServicos(){
    var notes = getIndexedServ();
    for (e = 0; e < notes.length; e++){
        if ((notes[e] != null) && (notes[e] == true)){

            bloqueiaInput($("servico" + e));
            bloqueiaInput($("qtd" + e));
            bloqueiaInput($("qtdDias_" + e));
            bloqueiaInput($("vl_unitario" + e));
            bloqueiaInput($("vl_total" + e));
            bloqueiaInput($("perc_iss" + e));
            bloqueiaInput($("vl_iss" + e));
            desapareceImg($("botDel" + e));
            desabilitaInput($("trib" + e));
        }
    }
}

function habilitaTrib(){
    var notes = getIndexedServ();
    for (e = 0; e < notes.length; e++){
        if ((notes[e] != null) && (notes[e] == true)){

            var inp = $("issTrib" + e);
            habilitaInput(inp);
            
        }
    }
}

function bloqueiaInput(inp){
    if(inp != null && inp != undefined){
        inp.className = 'inputReadOnly';
        inp.readOnly = true;
    }
    
}

function desapareceImg(img){
    img.style.display = 'none';
}
function desabilitaInput(inp){
    if(inp != null)
        inp.disabled = true;
}
function habilitaInput(inp){
    if(inp != null)
        inp.disabled = false;
}

/**Marca a nota como ativa ou inativa*/
function markFlagServ(noteIndex, flagBool){
    if (indexesForServico == null)
        indexesForServico = new Array();
 
    indexesForServico[noteIndex] = flagBool;
}
 
function getIndexedServ(idColeta){
    if (indexesForServico == null)
        return new Array();
    else
        return indexesForServico;
}

function getServ(){
    var notes = getIndexedServ();
    var urlData = "";
    for (e = 1; e <= notes.length; ++e){
        if ((notes[e] != null) && (notes[e] == true)){
            urlData += "&" + concatFieldValueUnescape("id"+e+","+
                "id_servico"+e+","+
                "qtd"+e+","+
                "vl_unitario"+e+","+
                "perc_iss"+e+","+
                "trib"+e);
        }//if (notes[e] == null
    }//for
    urlData += "&qtdServ="+ e;
	
    return urlData;
}

/**Conta quantas notas estão ativas na lista. 
  @idcoleta
  	É o id da coleta para contagem das notas.
  	ex.: countNotes(198)	*/
function countServ(idColeta){
    var notes = getIndexedNotes( idColeta );
    var resultCount = 0;
    for (e = 1; e <= notes.length; ++e)
        if ((notes[e] != null) && (notes[e] == true))
            resultCount++;
	
    return resultCount;
}

/**Percorre a tabela de notas para saber se alguma nota com id especificado ja existe. 
  @syntax noteExist(idnota_fiscal, idColeta) */
function servExist(id){
    var f = 1;
    while($('id'+f)){
        var suf = f;
        if ($('id'+suf).value == id)
            return true;
   	   		
        ++f;
    }
    return false;
}

function arredondar (x, n){    
    var PRECISAO = 10;
    x = x.toFixed(PRECISAO);            
    
    n = (n != undefined && n != null ? n : 2);
    if (n < 0 || n > 10){
        return x;
    } 
    
    var pow10 = Math.pow (10, n);
    var y = x * pow10;
    return Math.round (y) / pow10;
}