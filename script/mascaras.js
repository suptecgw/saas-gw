/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function mascara(o,f,fixed){
    if (fixed == undefined){
        fixed = '2';
    }
    v_obj=o
    v_fun=f 
    setTimeout("execmascara("+fixed+")",1)
}

function execmascara(fixed){
    v_obj.value=v_fun(v_obj.value,fixed)
}

function soNovePonto(v){
    if(v.charAt(v.length - 1) != "9" && v.charAt(v.length - 1) != "."){
        var a = v.charAt(v.length - 1);
        v = v.replace(a, "");
    }
    return v;
}

function leech(v){
    v=v.replace(/o/gi,"0")
    v=v.replace(/i/gi,"1")
    v=v.replace(/z/gi,"2")
    v=v.replace(/e/gi,"3")
    v=v.replace(/a/gi,"4")
    v=v.replace(/s/gi,"5")
    v=v.replace(/t/gi,"7")
    return v
}

function reais(v, fixed){
    if (fixed==0){
        v=soNumeros(v)
    }else if (fixed==1){
        v=v.replace(/\D/g,"")                //Remove tudo o que não é dígito
        v=v.replace(/(\d{1})$/,",$1")        //Coloca a virgula
        v=v.replace(/(\d+)(\d{3},\d{1})$/g,"$1.$2")     //Coloca o primeiro ponto
    }else if (fixed==2){
        v=v.replace(/\D/g,"")                //Remove tudo o que não é dígito
        v=v.replace(/(\d{2})$/,",$1")        //Coloca a virgula
        v=v.replace(/(\d+)(\d{3},\d{2})$/g,"$1.$2")     //Coloca o primeiro ponto
    }else if(fixed == 3){
        v=v.replace(/\D/g,"")                //Remove tudo o que não é dígito
        v=v.replace(/(\d{3})$/,",$1")        //Coloca a virgula
        v=v.replace(/(\d+)(\d{3},\d{3})$/g,"$1.$2")     //Coloca o primeiro ponto        
    }else if(fixed == 4){
        v=v.replace(/\D/g,"")                //Remove tudo o que não é dígito
        v=v.replace(/(\d{4})$/,",$1")        //Coloca a virgula
        v=v.replace(/(\d+)(\d{3},\d{4})$/g,"$1.$2")     //Coloca o primeiro ponto
    }
    
    return v
}

function IsNumeric(input){
    var RE = /^-{0,1}\d*\.{0,1}\d+$/;
    return (RE.test(input));
} 

function isNumeroBR(v, isSubst){
    var patt = /(,)/g;
    if(!patt.test(v.value)){        
           v.value=v.value.replace(/(\d+)/g,"$1,0")                   
    }
    
    if(v.value.substring(0,1) == ',' || !IsNumeric(colocarPonto(v.value))){
        v.value = "0,0";
    }    
    
}



function reaisManual(v, fixed){
    if (fixed==0){
        v=soNumeros(v)
    }else if (fixed==1){
        v=v.replace(/[^0-9,]/g,"")
        v=v.replace(/(\d+)(,\d{1})(\d+)/g,"$1$2")        
    }else if (fixed==2){
        v=v.replace(/[^0-9,]/g,"")                
        v=v.replace(/(\d+)(,\d{2})(\d+)/g,"$1$2")
    }else if(fixed == 3){
        v=v.replace(/[^0-9,]/g,"")                        
        v=v.replace(/(\d+)(,\d{3})(\d+)/g,"$1$2")
    }else if(fixed == 4){        
        v=v.replace(/[^0-9,]/g,"")
        v=v.replace(/(\d+)(,\d{4})(\d+)/g,"$1$2")
    }    
    return v
}

function reaisManual(v, fixed){
    
    var arrayVirg = v.split('\,')
    var ab = '';
    var a =arrayVirg [0];
    var b = '';
    var virg;
    var patt = /(,)/g;
    if(virg = patt.test(v)){        
        b= arrayVirg [1];
        if(b == null || b == undefined){
            b = '';
        }
           
    }
    
    
    
    a = a.replace(/\D/g, "");
    if(b != ''){
        b = b.replace(/\D/g, "");
        if(fixed == 1){
            b = b.replace(/(\d{1})(\d+)/g, "$1");            
        }else if(fixed == 2){
            b = b.replace(/(\d{2})(\d+)/g, "$1");            
        }else if(fixed == 3){
            b = b.replace(/(\d{3})(\d+)/g, "$1");            
        }else if(fixed == 4){
            b = b.replace(/(\d{4})(\d+)/g, "$1");            
        }
    }
    
    ab = a+(virg ? ',' : '') + b + '';
    return ab;
    
        
    /*
    if (fixed==0){
        v=soNumeros(v)
    }else if (fixed==1){
        v=v.replace(/[^0-9,]/g,"")
        v=v.replace(/(\d+)(,\d{1})(\d+)/g,"$1$2")        
    }else if (fixed==2){
        v=v.replace(/[^0-9,]/g,"")                
        v=v.replace(/(\d+)(,\d{2})(\d+)/g,"$1$2")
    }else if(fixed == 3){
        v=v.replace(/[^0-9,]/g,"")                        
        v=v.replace(/(\d+)(,\d{3})(\d+)/g,"$1$2")
    }else if(fixed == 4){        
        v=v.replace(/[^0-9,]/g,"")
        v=v.replace(/(\d+)(,\d{4})(\d+)/g,"$1$2")
    }    
    return v*/
    
    
}

function soNumeros(v){
    return v.replace(/\D/g,"");
}

function soNumerosVirgula(v){
    return v.replace(".", ",");
}

function soLetras(v){
    return v.replace(/\d/g,"");
    
}

function semMascara(v){
    return v;
}

function telefone(v){
    v=v.replace(/\D/g,"")                 //Remove tudo o que não é dígito
    v=v.replace(/^(\d\d)(\d)/g,"($1) $2") //Coloca parênteses em volta dos dois primeiros dígitos
    v=v.replace(/(\d{4})(\d)/,"$1-$2")    //Coloca hífen entre o quarto e o quinto dígitos
    return v
}
function mascaraCompetencia(v){
    v=v.replace(/\D/g,"")                 //Remove tudo o que não é dígito
    v=v.replace(/^(\d{2})(\d)/,"$1/$2")
    return v
}

function cpf(v){
    v=v.replace(/\D/g,"")                    //Remove tudo o que não é dígito
    v=v.replace(/(\d{3})(\d)/,"$1.$2")       //Coloca um ponto entre o terceiro e o quarto dígitos
    v=v.replace(/(\d{3})(\d)/,"$1.$2")       //Coloca um ponto entre o terceiro e o quarto dígitos
    //de novo (para o segundo bloco de números)
    v=v.replace(/(\d{3})(\d{1,2})$/,"$1-$2") //Coloca um hífen entre o terceiro e o quarto dígitos
    return v
}

function cep(v){
    v=v.replace(/D/g,"")                //Remove tudo o que não é dígito
    v=v.replace(/^(\d{5})(\d)/,"$1-$2") //Esse é tão fácil que não merece explicações
    return v
}

function cnpj(v){
    v=v.replace(/\D/g,"")                           //Remove tudo o que não é dígito
    v=v.replace(/^(\d{2})(\d)/,"$1.$2")             //Coloca ponto entre o segundo e o terceiro dígitos
    v=v.replace(/^(\d{2})\.(\d{3})(\d)/,"$1.$2.$3") //Coloca ponto entre o quinto e o sexto dígitos
    v=v.replace(/\.(\d{3})(\d)/,".$1/$2")           //Coloca uma barra entre o oitavo e o nono dígitos
    v=v.replace(/(\d{4})(\d)/,"$1-$2")              //Coloca um hífen depois do bloco de quatro dígitos
    return v
}

function romanos(v){
    v=v.toUpperCase()             //Maiúsculas
    v=v.replace(/[^IVXLCDM]/g,"") //Remove tudo o que não for I, V, X, L, C, D ou M
    //Essa é complicada! Copiei daqui: http://www.diveintopython.org/refactoring/refactoring.html
    while(v.replace(/^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/,"")!="")
        v=v.replace(/.$/,"")
    return v
}

function site(v){
    //Esse sem comentarios para que você entenda sozinho ;-)
    v=v.replace(/^http:\/\/?/,"")
    dominio=v
    caminho=""
    if(v.indexOf("/")>-1)
        dominio=v.split("/")[0]
    caminho=v.replace(/[^\/]*/,"")
    dominio=dominio.replace(/[^\w\.\+-:@]/g,"")
    caminho=caminho.replace(/[^\w\d\+-@:\?&=%\(\)\.]/g,"")
    caminho=caminho.replace(/([\?&])=/,"$1")
    if(caminho!="")dominio=dominio.replace(/\.+$/,"")
    v="http://"+dominio+caminho
    return v
}
function setZero(elemento, isInt){
    if(elemento.value == "" || elemento.value == "0" || elemento.value == ",00"){
        elemento.value = "0,00";
        if(isInt)
            elemento.value = 0;
    }
}
function codigoBarras(elemento){
    elemento.value=elemento.value.replace(/[^0-9a-z._\/-]/g, '');
}