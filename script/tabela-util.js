 /**
	Métodos úteis para manipulacao de grupos de clientes/fornecedores em telas de relatórios. 
*/



/*--- Variaveis globais ---*/ 
var indexesForCidade = new Array();

/**Retorna o próximo ID da table*/
function getNextIndexFromTableRoot(idTableRoot) {
    if (getObj("trCidade_id1") == null)
    	return 1;

	var r = 2;
	while (getObj("trCidade_id"+r) != null)
		++r;
		
	return 	r;
}

function toInt(valor){
    if (valor.indexOf('.') > -1)
		return valor.substring(0,valor.indexOf('.') );
	else	
        return valor;
}

/**@exemplo - addCidade*/ 
function addCidade(idCidade, idTableRoot, cidade, uf, area, tipos, acao)
{
	  var tableRoot = $(idTableRoot);
	  var indice = getNextIndexFromTableRoot(idTableRoot);

      //simplificando na hora da chamada    
	  var nameTR = "trCidade_id" + indice;
	  var nameTR2 = "trTipo_id" + idCidade;
	  	  
	  var trCidade = makeElement("TR", "className=colorClear&id="+nameTR);
	  var trTipo = makeElement("TR", "id="+nameTR2);

	  //fabricando campos e strings de comando
	  var commonObj = "type=text&class=fieldMin";
	  
	  appendObj(trCidade, makeElement("INPUT","type=hidden&id=cidade_id"+indice+"&value="+idCidade));
	  appendObj(trCidade, makeWithTD("INPUT", commonObj + "&id=cidade"+indice+"&maxLength=40&size=40&value="+cidade+"&readOnly=true"));
	  appendObj(trCidade, makeWithTD("INPUT", commonObj + "&id=uf"+indice+"&maxLength=40&size=3&value="+uf+"&readOnly=true"));
	  appendObj(trCidade, makeWithTD("INPUT", commonObj + "&id=area"+indice+"&maxLength=40&size=30&value="+area+"&readOnly=true"));

	  var tableTipo = Builder.node('td',{colSpan:4},[Builder.node('table',{style:'margin-left:15;',id:'Tipo_'+idCidade},
	                                  [Builder.node('tbody', 
	                                       [Builder.node('tr',{className:'colorClear',width:'98%'},[Builder.node('td',{width:'9%'},['Tipo veículo']),
	                                                           Builder.node('td',{width:'9%'},['R$/Peso']),
	                                                           Builder.node('td',{width:'6%'},['Peso/Ton.']),
	                                                           Builder.node('td',{width:'8%'},['AdValorEm']),
	                                                           Builder.node('td',{width:'7%'},['Outros']),
	                                                           Builder.node('td',{width:'7%'},['Taxa fixa']),
	                                                           Builder.node('td',{width:'9%'},['Frete mínimo']),
	                                                           Builder.node('td',{width:'9%'},['% nota fiscal']),
	                                                           Builder.node('td',{width:'7%'},['Qtd dias']),
	                                                           Builder.node('td',{width:'8%'},['Inclui Icms']),
	                                                           Builder.node('td',{width:'14%'},['Tipo Produto']),
	                                                           Builder.node('td',{width:'3%'},[''])
	                                                          ])
                                           ])])]); //makeElement("TABLE","border=1"));
	  //adicionando a linha na tabela
	  tableRoot.lastChild.appendChild(trCidade);
      //Adicionando os tipos de veículos
      tableRoot.lastChild.appendChild(trTipo);
      $(nameTR2).appendChild(tableTipo);
	  markFlagCidade(idCidade, indice, true);

      //Lancando os tipos de veiculos
      if (acao=='iniciar'){
    	  for (u = 0; u < tipos.split("!").length - 1; ++u) {
    	     var tupla = tipos.split("!")[u];
             addTipo(0, idCidade, tupla.split("#")[0], 'Tipo_'+idCidade, tupla.split("#")[1], '0.00', '', '0.00', '0.00', '0.00', '0.00', 0, false, false,'0', '');
          }
      }	  
	  
}

/**Marca a nota como ativa ou inativa*/
function markFlagCidade(idCidade, cidadeIndex, flagBool)
{
  		if (indexesForCidade["id"+idCidade] == null)
  		   indexesForCidade["id"+idCidade] = new Array();
 
 		indexesForCidade["id"+idCidade][cidadeIndex] = flagBool;
}
 
function extractIdCidade(nameObj) {
  	return nameObj.substring(nameObj.indexOf("id") + 2);
}

function extractIdCidade(nameObj){
  	return nameObj.substring(6, nameObj.indexOf("_"));
}

function getIndexedCidade(){
	if (indexesForCidade[ "id" ] == null)
		return new Array();
	else
		return indexesForCidade[ "id" ];
}


/**Conta quantas notas estão ativas na lista.*/
function countCidades(idCidade){
	var cidades = getIndexedCidades();
	var resultCount = 0;
	for (e = 1; e <= cidades.length; ++e)
		if ((cidades[e] != null) && (cidades[e] == true)) 
			resultCount++;
	
	return resultCount;	
}

//Adicionando o tipo de veículo
function addTipo(id, idCidade, idTipo, idTableRoot, tipo, pesoKg, adValorEm, outros, taxaFixa, freteMinimo, percNF, dias, incluiIcms, porTonelada, produto_id, produto)
{
	  var tableRoot = $(idTableRoot);
	  var indice = getNextIndexTipo();

      //simplificando na hora da chamada    
	  var nameTR = "trTipo" + indice;
	  	  
	  //fabricando campos e strings de comando
	  var commonField = "seNaoFloatReset($('";
	  var commonSufix = "'),'0.00');";
	  var commonSufixInt = "'),'0');";

      var check;  
      if (incluiIcms){
           check = Builder.node('TD',
                     [Builder.node('INPUT',{type:'checkbox',className:'fieldMin',checked:'true',id:'incluiIcms'+indice})
                     ]);
      }else{
           check = Builder.node('TD',
                     [Builder.node('INPUT',{type:'checkbox',className:'fieldMin',id:'incluiIcms'+indice})
                     ]);
      }      

      var checkT;  
      if (porTonelada){
           checkT = Builder.node('TD',
                     [Builder.node('INPUT',{type:'checkbox',className:'fieldMin',checked:'true',id:'porTonelada'+indice})
                     ]);
      }else{
           checkT = Builder.node('TD',
                     [Builder.node('INPUT',{type:'checkbox',className:'fieldMin',id:'porTonelada'+indice})
                     ]);
      }      

      var tableTipos = Builder.node('TR', {className:'colorClear',id:nameTR},
                                [Builder.node('TD',
                                       [Builder.node('INPUT',{type:'hidden',className:'fieldMin',id:'id'+indice,value:id}),
                                        Builder.node('INPUT',{type:'hidden',className:'fieldMin',id:'tipo_id'+indice,value:idCidade+'!'+idTipo}),
                                        Builder.node('INPUT',{type:'text',className:'fieldMin',id:'tipo'+indice,maxLength:'20',size:'13',value:tipo, readonly:'true'})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'pesoKg'+indice,maxLength:'10',size:'9',value:pesoKg,onChange:commonField+'pesoKg'+indice+commonSufix})
                                       ]),
                                 checkT,
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'adValorEm'+indice,maxLength:'9',size:'9',value:adValorEm})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'outros'+indice,maxLength:'10',size:'7',value:formatoMoeda(outros),onChange:commonField+'outros'+indice+commonSufix})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'taxaFixa'+indice,maxLength:'10',size:'7',value:formatoMoeda(taxaFixa),onChange:commonField+'taxaFixa'+indice+commonSufix})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'freteMinimo'+indice,maxLength:'10',size:'7',value:formatoMoeda(freteMinimo),onChange:commonField+'freteMinimo'+indice+commonSufix})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'percNF'+indice,maxLength:'10',size:'7',value:percNF,onChange:commonField+'percNF'+indice+commonSufix})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'dias'+indice,maxLength:'10',size:'7',value:dias})
                                       ]),
                                 check,
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'text',className:'fieldMin',id:'tipo_produto'+indice,name:'tipo_produto'+indice,maxLength:'30',size:'23',value:produto,readOnly:'true'}),
                                           Builder.node('INPUT',{type:'hidden',id:'tipo_produto_id'+indice,name:'tipo_produto_id'+indice,value:produto_id})
                                       ]),
                                 Builder.node('TD',
                                       [Builder.node('INPUT',{type:'button', id:indice, name:indice, className:'botoes', value:'...', onClick:'localizaProdutoLista(this)' })
                                       ])
                                ]);
      
	  tableRoot.lastChild.appendChild(tableTipos);
//	  ultLinha++;
	  
}

/**Retorna o próximo ID da table*/
function getNextIndexTipo() {
    if (getObj("trTipo1") == null)
    	return 1;

	var r = 2;
	while (getObj("trTipo"+r) != null)
		++r;
		
	return 	r;
}

function getValores(){
	var r = 1;
	var resultado = '';
	while (getObj("tipo_id"+r) != null){
	    resultado += $("tipo_id"+r).value + '!' + $("pesoKg"+r).value + '!' + $("adValorEm"+r).value + '!' +
	    $("outros"+r).value + '!' + $("taxaFixa"+r).value + '!' + $("freteMinimo"+r).value + '!' +
	    $("percNF"+r).value + '!' + $("dias"+r).value + '!' + $("incluiIcms"+r).checked + '!' + $("id"+r).value + '!' +
	    $("porTonelada"+r).checked + '!' + $("tipo_produto_id"+r).value + '_';
		++r;
	}	
    return resultado;
}