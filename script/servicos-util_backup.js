/**
	Métodos úteis para manipulacao de serviços em um cadastro. 
*/

/*--- Variaveis globais ---*/ 
var indexesForServico = new Array(); 

/* Armazena o total de serviços lançados */
var qtdServicos = 0;

/**Retorna o próximo ID da table*/
function getNextIndexFromServ(idTableRoot) {
    if (getObj("trServ1") == null)
        return 1;
    var r = 2;
    while (getObj("trServ"+r) != null)
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

function addServ(idTableRoot, id, id_servico, servico, qtd, vl_unitario, vl_total,  
    perc_iss, vl_iss, trib, todasTaxas, id_plano, conta_plano, descricao_plano,
    idColeta, coleta,usaDias,qtdDias,notas, notaFiscal, embutirISS, incluir, nfsId){

    incluir = (incluir == undefined || incluir== null ? false : incluir);
    vl_iss = (vl_iss != null && vl_iss != undefined? arredondar(vl_iss, 2) : vl_iss);
    nfsId = (nfsId != null && nfsId != undefined? nfsId : 0);
    embutirISS = (embutirISS == undefined || embutirISS== null || embutirISS== false || embutirISS== "f"? false : true );

    var tableRoot = getObj(idTableRoot);
    var indice = getNextIndexFromServ(idTableRoot);

    //simplificando na hora da chamada
    var sufixID = indice;
    var nameTR = "trServ" + sufixID;
	  	  
    var trServ = makeElement("TR", "class=cellNotes&id="+nameTR);

    //fabricando campos e strings de comando
    var commonObj = "type=text&class=fieldMin";
    var commonField = "seNaoFloatReset($(\'";
    var commonSufix = sufixID+"\'),\'0.00\');calculaTotal("+sufixID+");";
    var commonFieldInt = "seNaoIntReset($(\'";
    var commonSufixInt = sufixID+"\'),\'1\');getCalculaTotalServ("+sufixID+");";

    var _tr = Builder.node('TR', {
        id:nameTR,
        name:nameTR,
        className:'cellNotes'
    },
    [Builder.node('td',[
            nfsId == 0 ?
            Builder.node('IMG',{
            src:'img/lixo.png',
            id:'botDel' + sufixID,
            border:'0',
            onclick:'removeServ('+nameTR+','+sufixID+');',
            className:'imagemLink',
            title:'Remover este serviço'})
        :""]),
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'servico'+sufixID,
            id:'servico'+sufixID,
            size:'45',
            value:servico,
            className:'fieldMin',
            readOnly:'true'
        }),
        Builder.node('INPUT', {
            type:'hidden',
            name:'id'+sufixID,
            id:'id'+sufixID,
            value:id
        }),
        Builder.node('INPUT', {
            type:'hidden',
            name:'id_servico'+sufixID,
            id:'id_servico'+sufixID,
            value:id_servico
        }),
        Builder.node('INPUT', {
            type:'hidden',
            name:'id_plano'+sufixID,
            id:'id_plano'+sufixID,
            value:id_plano
        }),
        Builder.node('INPUT', {
            type:'hidden',
            name:'conta_plano'+sufixID,
            id:'conta_plano'+sufixID,
            value:conta_plano
        }),
        Builder.node('INPUT', {
            type:'hidden',
            name:'descricao_plano'+sufixID,
            id:'descricao_plano'+sufixID,
            value:descricao_plano
        })
        ]),
                                                                 
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'qtdDias_'+sufixID,
            id:'qtdDias_'+sufixID,
            size:'5',
            maxLength:'11',
            value:qtdDias,
            onblur:"getCalculaTotalServ("+sufixID+")",
            className:'fieldMin'
        })
        ]),
        
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'qtd'+sufixID,
            id:'qtd'+sufixID,
            size:'7',
            maxLength:'11',
            value:formatoMoeda(qtd),
            className:'fieldMin'
        })
        ]),
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'vl_unitario'+sufixID,
            id:'vl_unitario'+sufixID,
            size:'9',
            maxLength:'11',
            value:formatoMoeda(vl_unitario),
            className:'fieldMin'
            
        }),
        Builder.node('INPUT', {
            type:'hidden',
            name:'vl_unitario_hi_'+sufixID,
            id:'vl_unitario_hi_'+sufixID,
            size:'9',
            maxLength:'11',
            value: (!incluir && embutirISS ? vl_unitario -(vl_iss/qtd): vl_unitario),
            className:'fieldMin'
        })
        ]),
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'vl_total'+sufixID,
            id:'vl_total'+sufixID,
            size:'9',
            maxLength:'11',
            value:vl_unitario,
            className:'fieldMin',
            onchange:commonField+'vl_total'+commonSufix,
            readOnly:'true'
        })
        ]),
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'perc_iss'+sufixID,
            id:'perc_iss'+sufixID,
            size:'5',
            maxLength:'11',
            value:perc_iss,
            className:'fieldMin'
        })
        ]),
    Builder.node('td',
        [Builder.node('INPUT', {
            type:'text',
            name:'vl_iss'+sufixID,
            id:'vl_iss'+sufixID,
            size:'9',
            maxLength:'11',
            value:vl_iss,
            className:'fieldMin',
            onchange:commonField+'vl_iss'+commonSufix,
            readOnly:'true'
        })
        ]),
    Builder.node('td',
        [Builder.node('SELECT', {
            name:'trib'+sufixID,
            id:'trib'+sufixID,
            className:'fieldMin'
            
        })
        ]),
    Builder.node('td',{align:"center"},
        [Builder.node('INPUT', {
            type:"checkbox",
            name:'embutirISS_'+sufixID,
            id:'embutirISS_'+sufixID,
            title:'Embutir ISS no valor do serviço',
            onClick: "validaTipoTributacao("+sufixID+");"
        })
        ]),
    Builder.node('td',
        [Builder.node('SELECT', {
            name:'notaServico'+sufixID,
            id:'notaServico'+sufixID,
            className:'fieldMin'
        })
        ]),
    
    Builder.node('td',
        [Builder.node('LABEL', {
            name:'coleta'+sufixID,
            id:'coleta'+sufixID
        }, coleta)
        ])
    ]);

    //adicionando a linha na tabela
    tableRoot.appendChild(_tr);

    $("embutirISS_"+sufixID).checked = embutirISS;

    //Atribuindo as taxas
    if(todasTaxas != ""){
        for (x=0; x < todasTaxas.split('!!-').length; ++x){
            getObj('trib'+sufixID).appendChild(Builder.node('OPTION', {
                value:todasTaxas.split('!!-')[x].split(':.:')[0]
            }, todasTaxas.split('!!-')[x].split(':.:')[1]));
        }
    }
    getObj('trib'+sufixID).value = trib;

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

    //Calculando valor total
    getCalculaTotalServ(sufixID);

    if (usaDias == "t" || usaDias == "true"){
        $("qtdDias_"+sufixID).style.display="";
        $("lbDias").style.display="";
    }else{
        $("qtdDias_"+sufixID).style.display="none";
    }

    markFlagServ(sufixID, true);

    $('qtd'+sufixID).focus();
	  
    qtdServicos++;
	  
    //chamando um possivel metodo que aplica eventos em alguns campos do servico adicionado
    if (window.applyEventInServ != null)
        applyEventInServ();
	  
}
function setValorHidden(idx){
    if($("vl_unitario_hi_"+idx) != null)
        $("vl_unitario_hi_"+idx).value = $("vl_unitario"+idx).value;
}

function validaTipoTributacao(idx){
    var trib = $('trib'+idx).value;
    if(trib=="4" || trib =="6"){
        $("embutirISS_"+idx).checked = false;
        desabilitar($("embutirISS_"+idx));
    }else{
        habilitar($("embutirISS_"+idx));
    }
    getCalculaTotalServ(idx);
        
}


/**calcula o valor total do serviço e o valor do ISS*/
function getCalculaTotalServ(idx){
    var valorUnitario = 0;
    if($('embutirISS_'+idx).checked){        
        valorUnitario = (parseFloat($('vl_unitario_hi_'+idx).value)/(1-(parseFloat($('perc_iss'+idx).value) / 100)));
        $('vl_unitario'+idx).value = arredondar(valorUnitario).toFixed(2);
    }else{
        valorUnitario = parseFloat($('vl_unitario_hi_'+idx).value);
        $('vl_unitario'+idx).value = arredondar(valorUnitario).toFixed(2);
    }

    $('vl_total'+idx).value = arredondar((parseFloat($('qtdDias_'+idx).value) * parseFloat($('qtd'+idx).value)  * valorUnitario),2).toFixed(2);
    $('vl_iss'+idx).value = arredondar((parseFloat($('vl_total'+idx).value) * parseFloat($('perc_iss'+idx).value) / 100),2).toFixed(2);
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
    var notes = getIndexedServ();
    var total = 0;
    var totalRetido = 0;
    for (e = 1; e <= notes.length; ++e){
        if ((notes[e] != null) && (notes[e] == true)){
            for (x=0; x < taxas.split('!!-').length; ++x){
                if (getObj('trib'+e).value == taxas.split('!!-')[x].split(':.:')[0]){
                    if (taxas.split('!!-')[x].split(':.:')[1] == '2' || taxas.split('!!-')[x].split(':.:')[1] == '3'){
                        totalRetido += parseFloat($('vl_iss'+e).value);
                    }else{
                        total += parseFloat($('vl_iss'+e).value);
                    }
//                    validaTipoTributacao(e);
                }
            }
        }//if (notes[e] == null
    }//for
    return (retido ? formatoMoeda(totalRetido) : formatoMoeda(total));
}

/**Remove uma nota de uma lista*/
function removeServ(nameObj, idx) {
    if (confirm("Deseja mesmo excluir este serviço da OS ?"))
        //getObj(nameObj).parentNode.removeChild(getObj(nameObj));
        Element.remove($(nameObj));

    //removendo o indice no array(como o array começa em 0, subtraimos 1)
    markFlagServ(idx, false);
     
//atualizando a soma do peso
//    if (window.updateSum != null)
//  	updateSum(true);
}

function removeAllServ(){
    var notes = getIndexedServ();
    for (e = 0; e < notes.length; e++){
        if ((notes[e] != null) && (notes[e] == true)){
            Element.remove($("trServ" + e));
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

            var inp = $("trib" + e);
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
    inp.disabled = true;
}
function habilitaInput(inp){
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
    n = (n != undefined && n != null ? n : 2);
    if (n < 0 || n > 10) return x;
        var pow10 = Math.pow (10, n);
        var y = x * pow10;
    return Math.round (y) / pow10;
}