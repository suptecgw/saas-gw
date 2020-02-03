/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var indexesForProduto = new Array();
var ultLinha = 0;

//Retorna o próximo ID da tabela
function getNextIndexFromTableRoot(idTableRoot){
    if(getObj("trProduto_id1") == null){
        return 1;
    }
    var r = 2;
    while(getObj("trProduto_id"+r) != null){
        ++r;
    }
    return r;
}

/**Marca a nota como ativa ou inativa*/
function markFlagProduto(idProduto, produtoIndex, flagBool){
        if(indexesForProduto["id"+idProduto] == null){
           indexesForProduto["id"+idProduto] = new Array();
        }
        indexesForProduto["id"+idProduto][produtoIndex] = flagBool;
}

function addProduto(idProduto, idTableRoot, descricao){
    
      var tableRoot = getObj(idTableRoot);
      var indice = getNextIndexFromTableRoot(idTableRoot);

      //simplificando na hora da chamada    
      var nameTR = "trProduto_id" + indice;

      var trProduto = makeElement("TR", "class=colorClear&id="+nameTR);

      //fabricando campos e strings de comando
      var commonObj = "type=text&class=inputReadOnly";

      //fabricando o botão de excluir	
      appendObj(trProduto, makeWithTD("IMG","src=img/lixo.png&border=0&onclick=removeProduto('"+nameTR+"')&class=imagemLink&title=Remover este produto"));

      appendObj(trProduto, makeElement("INPUT","type=hidden&id=tipo_produto_id"+indice+"&value="+idProduto));
      appendObj(trProduto, makeWithTD("INPUT", commonObj + "&id=descricao"+indice+"&maxLength=40&size=30&value="+descricao+"&readOnly=true"));

      //adicionando a linha na tabela
      tableRoot.appendChild(trProduto);	  	  
      markFlagGrupo(idProduto, indice, true);

      ultLinha++;

      //chamando um possivel metodo que aplica eventos em alguns campos da nota adicionada
      if (window.applyEventInNote != null){
         applyEventInGrupo();              
      }
}

/**Remove uma nota de uma lista*/
function removeProduto(nameObj) {
     if (confirm("Deseja mesmo excluir este Produto ?"))
     	getObj(nameObj).parentNode.removeChild(getObj(nameObj));
     	
     //removendo o indice no array(como o array começa em 0, subtraimos 1)
     markFlagProduto(extractIdProduto(nameObj), extractIdProduto(nameObj), false); 
     
     //atualizando a soma do peso
     if (window.updateSum != null){
     	updateSum(true);         
     }
}

function extractIdProduto(nameObj) {
    return nameObj.substring(nameObj.indexOf("id") + 2);
}

function extractIdProduto(nameObj){
    return nameObj.substring(6, nameObj.indexOf("_"));
}

function getProdutos(){
    var urlData = "";	   		   		
    for (e = 1; e <= ultLinha; ++e){
        if (getObj("tipo_produto_id"+e) != null){
            if (urlData == ""){
              urlData += getObj("tipo_produto_id"+e).value;
            }else{
              urlData += ","+getObj("tipo_produto_id"+e).value;                        
            } 
        }
    }    
    return urlData;
}