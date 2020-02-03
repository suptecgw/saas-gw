 /**
	Métodos úteis para manipulacao de grupos de clientes/fornecedores em telas de relatórios. 
*/



/*--- Variaveis globais ---*/ 
var indexesForGrupo = new Array(); 
var ultLinha = 0; //Ultima linha cadastrada 

/**Retorna o próximo ID da table*/
function getNextIndexFromTableRoot(idTableRoot) {
    if (getObj("trGrupo_id1") == null)
    	return 1;

	var r = 2;
	while (getObj("trGrupo_id"+r) != null)
		++r;
		
	return 	r;
}
/**Retorna o próximo ID da table
 * Criei uma nova função por que não sei se a mesma é usada em
 * outra parte do sistema.
 * */
function getNextIndexFromTableRootGrupos(idTableRoot) {
    if (getObj("trGrupo_id1") == null)
    	return 1;

	var r = 2;
	while (getObj("trGrupo_id"+r) != null)
		++r;
		
	return 	r;
}

function toInt(valor){
    if (valor.indexOf('.') > -1)
		return valor.substring(0,valor.indexOf('.') );
	else	
        return valor;	
}

/**@exemplo - addGrupo*/ 

function addGrupo(idGrupo, idTableRoot, descricao)
{
	  var tableRoot = getObj(idTableRoot);
	  var indice = getNextIndexFromTableRootGrupos(idTableRoot);

      //simplificando na hora da chamada    
	  var nameTR = "trGrupo_id" + indice;
	  	  
	  var trGrupo = makeElement("TR", "class=colorClear&id="+nameTR);

	  //fabricando campos e strings de comando
	  var commonObj = "type=text&class=inputReadOnly";
	  
	  //fabricando o botão de excluir	
      appendObj(trGrupo, makeWithTD("IMG","src=img/lixo.png&border=0&onclick=removeGrupo('"+nameTR+"')&class=imagemLink&title=Remover este grupo"));

	  appendObj(trGrupo, makeElement("INPUT","type=hidden&id=grupo_id"+indice+"&value="+idGrupo));
	  appendObj(trGrupo, makeWithTD("INPUT", commonObj + "&id=descricao"+indice+"&maxLength=40&size=30&value="+descricao+"&readOnly=true"));
			  
	  //adicionando a linha na tabela
	  tableRoot.appendChild(trGrupo);	  	  
	  markFlagGrupo(idGrupo, indice, true);
	  
	  ultLinha++;
	  
	  //chamando um possivel metodo que aplica eventos em alguns campos da nota adicionada
	  if (window.applyEventInNote != null)
	     applyEventInGrupo();
}

/**Remove uma nota de uma lista*/
function removeGrupo(nameObj) {
     if (confirm("Deseja mesmo excluir este Grupo ?"))
     	getObj(nameObj).parentNode.removeChild(getObj(nameObj));
     	
     //removendo o indice no array(como o array começa em 0, subtraimos 1)
     markFlagGrupo(extractIdGrupo(nameObj), extractIdGrupo(nameObj), false); 
     
     //atualizando a soma do peso
     if (window.updateSum != null)
     	updateSum(true);
}

/**Marca a nota como ativa ou inativa*/
function markFlagGrupo(idGrupo, grupoIndex, flagBool)
{
  		if (indexesForGrupo["id"+idGrupo] == null)
  		   indexesForGrupo["id"+idGrupo] = new Array();
 
 		indexesForGrupo["id"+idGrupo][grupoIndex] = flagBool;
}
 
function extractIdGrupo(nameObj) {
  	return nameObj.substring(nameObj.indexOf("id") + 2);
}

function extractIdGrupo(nameObj){
  	return nameObj.substring(6, nameObj.indexOf("_"));
}

function getIndexedGrupos(){
alert(indexesForGrupo[0]);
	if (indexesForGrupo[ "id" ] == null)
		return new Array();
	else
		return indexesForGrupo[ "id" ];
}

function getGrupos()
{
//    var grupos = getIndexedGrupos();
	var urlData = "";	   		   		
	for (e = 1; e <= ultLinha; ++e)
	{
		if (getObj("grupo_id"+e) != null) 
		{
       		if (urlData == "")
			  urlData += getObj("grupo_id"+e).value;
			else  
			  urlData += ","+getObj("grupo_id"+e).value;
	    }//if (notes[e] == null
	}//for    
	return urlData;
}

/**Conta quantas notas estão ativas na lista.*/
function countGrupos(idGrupo){
	var grupos = getIndexedGrupos();
	var resultCount = 0;
	for (e = 1; e <= grupos.length; ++e)
		if ((grupos[e] != null) && (grupos[e] == true)) 
			resultCount++;
	
	return resultCount;	
}