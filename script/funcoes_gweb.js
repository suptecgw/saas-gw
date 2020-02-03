/**  
 * PROTï¿½TIPOS:
 * mï¿½todo String.lpad(int pSize, char pCharPad)
 * mï¿½todo String.trim()
 *
 * String unformatNumber(String pNum)
 * String formatCpfCnpj(String pCpfCnpj, boolean pUseSepar, boolean pIsCnpj)
 * String dvCpfCnpj(String pEfetivo, boolean pIsCnpj)
 * boolean isCpf(String pCpf)
 * boolean isCnpj(String pCnpj)
 * boolean isCpfCnpj(String pCpfCnpj)
 */


NUM_DIGITOS_CPF = 11;
NUM_DIGITOS_CNPJ = 14;
NUM_DGT_CNPJ_BASE = 8;

window.addEventListener('error', function (e) {
    console.log(e.message
            , '\n', e.filename, ':', e.lineno, (e.colno ? ':' + e.colno : '')
            , e.error && e.error.stack ? '\n' : '', e.error ? e.error.stack : undefined
            );
}, false);

/**
 * Adiciona mï¿½todo lpad() ï¿½ classe String.
 * Preenche a String ï¿½ esquerda com o caractere fornecido,
 * atï¿½ que ela atinja o tamanho especificado.
 */
String.prototype.lpad = function (pSize, pCharPad)
{
    var str = this;
    var dif = pSize - str.length;
    var ch = String(pCharPad).charAt(0);
    for (; dif > 0; dif--)
        str = ch + str;
    return (str);
} //String.lpad


/**
 * Adiciona mï¿½todo trim() ï¿½ classe String.
 * Elimina brancos no inï¿½cio e fim da String.
 */
String.prototype.trim = function ()
{
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
} //String.trim


/**
 * Elimina caracteres de formataï¿½ï¿½o e zeros ï¿½ esquerda da string
 * de nï¿½mero fornecida.
 * @param String pNum
 * 	String de nï¿½mero fornecida para ser desformatada.
 * @return String de nï¿½mero desformatada.
 */
function unformatNumber(pNum)
{
    return String(pNum).replace(/\D/g, "").replace(/^0+/, "");
} //unformatNumber


/**
 * Formata a string fornecida como CNPJ ou CPF, adicionando zeros
 * ï¿½ esquerda se necessï¿½rio e caracteres separadores, conforme solicitado.
 * @param String pCpfCnpj
 * 	String fornecida para ser formatada.
 * @param boolean pUseSepar
 * 	Indica se devem ser usados caracteres separadores (. - /).
 * @param boolean pIsCnpj
 * 	Indica se a string fornecida ï¿½ um CNPJ.
 * 	Caso contrï¿½rio, ï¿½ CPF. Default = false (CPF).
 * @return String de CPF ou CNPJ devidamente formatada.
 */
function formatCpfCnpj(pCpfCnpj, pUseSepar, pIsCnpj)
{
    if (pIsCnpj == null)
        pIsCnpj = false;
    if (pUseSepar == null)
        pUseSepar = true;
    var maxDigitos = pIsCnpj ? NUM_DIGITOS_CNPJ : NUM_DIGITOS_CPF;
    var numero = unformatNumber(pCpfCnpj);

    numero = numero.lpad(maxDigitos, '0');
    if (!pUseSepar)
        return numero;

    if (pIsCnpj)
    {
        reCnpj = /(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/;
        numero = numero.replace(reCnpj, "$1.$2.$3/$4-$5");
    } else
    {
        reCpf = /(\d{3})(\d{3})(\d{3})(\d{2})$/;
        numero = numero.replace(reCpf, "$1.$2.$3-$4");
    }
    return numero;
} //formatCpfCnpj


/**
 * Calcula os 2 dï¿½gitos verificadores para o nï¿½mero-efetivo pEfetivo de
 * CNPJ (12 dï¿½gitos) ou CPF (9 dï¿½gitos) fornecido. pIsCnpj ï¿½ booleano e
 * informa se o nï¿½mero-efetivo fornecido ï¿½ CNPJ (default = false).
 * @param String pEfetivo
 * 	String do nï¿½mero-efetivo (SEM dï¿½gitos verificadores) de CNPJ ou CPF.
 * @param boolean pIsCnpj
 * 	Indica se a string fornecida ï¿½ de um CNPJ.
 * 	Caso contrï¿½rio, ï¿½ CPF. Default = false (CPF).
 * @return String com os dois dï¿½gitos verificadores.
 */
function dvCpfCnpj(pEfetivo, pIsCnpj)
{
    if (pIsCnpj == null)
        pIsCnpj = false;
    var i, j, k, soma, dv;
    var cicloPeso = pIsCnpj ? NUM_DGT_CNPJ_BASE : NUM_DIGITOS_CPF;
    var maxDigitos = pIsCnpj ? NUM_DIGITOS_CNPJ : NUM_DIGITOS_CPF;
    var calculado = formatCpfCnpj(pEfetivo, false, pIsCnpj);
    calculado = calculado.substring(2, maxDigitos);
    var result = "";

    for (j = 1; j <= 2; j++)
    {
        k = 2;
        soma = 0;
        for (i = calculado.length - 1; i >= 0; i--)
        {
            soma += (calculado.charAt(i) - '0') * k;
            k = (k - 1) % cicloPeso + 2;
        }
        dv = 11 - soma % 11;
        if (dv > 9)
            dv = 0;
        calculado += dv;
        result += dv
    }

    return result;
} //dvCpfCnpj


/**
 * Testa se a String pCpf fornecida ï¿½ um CPF vï¿½lido.
 * Qualquer formataï¿½ï¿½o que nï¿½o seja algarismos ï¿½ desconsiderada.
 * @param String pCpf
 * 	String fornecida para ser testada.
 * @return <code>true</code> se a String fornecida for um CPF vï¿½lido.
 */
function isCpf(pCpf)
{
    var numero = formatCpfCnpj(pCpf, false, false);
    var base = numero.substring(0, numero.length - 2);
    var digitos = dvCpfCnpj(base, false);
    var algUnico, i;

    // Valida dï¿½gitos verificadores
    if (numero != base + digitos)
        return false;

    /* Nï¿½o serï¿½o considerados vï¿½lidos os seguintes CPF:
     * 000.000.000-00, 111.111.111-11, 222.222.222-22, 333.333.333-33, 444.444.444-44,
     * 555.555.555-55, 666.666.666-66, 777.777.777-77, 888.888.888-88, 999.999.999-99.
     */
    algUnico = true;
    for (i = 1; i < NUM_DIGITOS_CPF; i++)
    {
        algUnico = algUnico && (numero.charAt(i - 1) == numero.charAt(i));
    }
    return (!algUnico);
} //isCpf


/**
 * Testa se a String pCnpj fornecida ï¿½ um CNPJ vï¿½lido.
 * Qualquer formataï¿½ï¿½o que nï¿½o seja algarismos ï¿½ desconsiderada.
 * @param String pCnpj
 * 	String fornecida para ser testada.
 * @return <code>true</code> se a String fornecida for um CNPJ vï¿½lido.
 */
function isCnpj(pCnpj)
{
    var numero = formatCpfCnpj(pCnpj, false, true);
    var base = numero.substring(0, NUM_DGT_CNPJ_BASE);
    var ordem = numero.substring(NUM_DGT_CNPJ_BASE, 12);
    var digitos = dvCpfCnpj(base + ordem, true);
    var algUnico;

    // Valida dï¿½gitos verificadores
    if (numero != base + ordem + digitos)
        return false;

    /* Nï¿½o serï¿½o considerados vï¿½lidos os CNPJ com os seguintes nï¿½meros Bï¿½SICOS:
     * 11.111.111, 22.222.222, 33.333.333, 44.444.444, 55.555.555,
     * 66.666.666, 77.777.777, 88.888.888, 99.999.999.
     */
    algUnico = numero.charAt(0) != '0';
    for (i = 1; i < NUM_DGT_CNPJ_BASE; i++)
    {
        algUnico = algUnico && (numero.charAt(i - 1) == numero.charAt(i));
    }
    if (algUnico)
        return false;

    /* Nï¿½o serï¿½ considerado vï¿½lido CNPJ com nï¿½mero de ORDEM igual a 0000.
     * Nï¿½o serï¿½ considerado vï¿½lido CNPJ com nï¿½mero de ORDEM maior do que 0300
     * e com as trï¿½s primeiras posiï¿½ï¿½es do nï¿½mero Bï¿½SICO com 000 (zeros).
     * Esta crï¿½tica nï¿½o serï¿½ feita quando o no Bï¿½SICO do CNPJ for igual a 00.000.000.
     */
    if (ordem == "0000")
        return false;
    return (base == "00000000"
            || parseInt(ordem, 10) <= 300 || base.substring(0, 3) != "0000");
} //isCnpj


/**
 * Testa se a String pCpfCnpj fornecida ï¿½ um CPF ou CNPJ vï¿½lido.
 * Se a String tiver uma quantidade de dï¿½gitos igual ou inferior
 * a 11, valida como CPF. Se for maior que 11, valida como CNPJ.
 * Qualquer formataï¿½ï¿½o que nï¿½o seja algarismos ï¿½ desconsiderada.
 * @param String pCpfCnpj
 * 	String fornecida para ser testada.
 * @return <code>true</code> se a String fornecida for um CPF ou CNPJ vï¿½lido.
 */
function isCpfCnpj(pCpfCnpj)
{
    var numero = pCpfCnpj.replace(/\D/g, "");
    if (numero.length > NUM_DIGITOS_CPF)
        return isCnpj(pCpfCnpj)
    else
        return isCpf(pCpfCnpj);
} //isCpfCnpj

/**
 * Funï¿½ï¿½o criada por Deivid
 * Aceita apenas os digitos referente ao cnpj e nï¿½meros
 */
function digitaCnpj(valor) {
    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;

    if (tecla > 47 && tecla < 58) // numeros de 0 a 9
        return true;
    else
    {
        if (tecla != 8 && tecla != 45 && tecla != 46 && tecla != 47) // backspace, ".","-"."/"
            event.keyCode = 0;
        else
            return true;
    }
}



function digitaCpf() {
    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;
    if (tecla > 47 && tecla < 58) // numeros de 0 a 9
        return true;
    else
    {
        if (tecla != 8 && tecla != 45 && tecla != 46) // backspace, ".","-"."/"
            event.keyCode = 0;
        else
            return true;
    }
}



//--------------------------------------------Formata Reais----------------

documentall = document.all;


function formatamoney(c) {
    var t = this;
    if (c == undefined)
        c = 2;
    var p, d = (t = t.split("."))[1].substr(0, c);
    for (p = (t = t[0]).length; (p -= 3) >= 1; ) {
        t = t.substr(0, p) + "." + t.substr(p);
    }
    return t + "," + d + Array(c + 1 - d.length).join(0);
}

String.prototype.formatCurrency = formatamoney

function demaskvalue(valor, currency) {
    /*
     * Se currency ï¿½ false, retorna o valor sem apenas com os nï¿½meros. Se ï¿½ true, os dois ï¿½ltimos caracteres sï¿½o considerados as 
     * casas decimais
     */
    var val2 = '';
    var strCheck = '0123456789';
    var len = valor.length;
    if (len == 0) {
        return 0.00;
    }

    if (currency == true) {
        /* Elimina os zeros ï¿½ esquerda 
         * a variï¿½vel  <i> passa a ser a localizaï¿½ï¿½o do primeiro caractere apï¿½s os zeros e 
         * val2 contï¿½m os caracteres (descontando os zeros ï¿½ esquerda)
         */

        for (var i = 0; i < len; i++)
            if ((valor.charAt(i) != '0') && (valor.charAt(i) != ','))
                break;

        for (; i < len; i++) {
            if (strCheck.indexOf(valor.charAt(i)) != -1)
                val2 += valor.charAt(i);
        }

        if (val2.length == 0)
            return "0.00";
        if (val2.length == 1)
            return "0.0" + val2;
        if (val2.length == 2)
            return "0." + val2;

        var parte1 = val2.substring(0, val2.length - 2);
        var parte2 = val2.substring(val2.length - 2);
        var returnvalue = parte1 + "." + parte2;
        return returnvalue;

    } else {
        /* currency ï¿½ false: retornamos os valores COM os zeros ï¿½ esquerda, 
         * sem considerar os ï¿½ltimos 2 algarismos como casas decimais 
         */
        val3 = "";
        for (var k = 0; k < len; k++) {
            if (strCheck.indexOf(valor.charAt(k)) != -1)
                val3 += valor.charAt(k);
        }
        return val3;
    }
}


function reais(obj, event) {

    var whichCode = (window.Event) ? event.which : event.keyCode;
    /*
     Executa a formataï¿½ï¿½o apï¿½s o backspace nos navegadores !document.all
     */
    if (whichCode == 8 && !documentall) {
        /*
         Previne a aï¿½ï¿½o padrï¿½o nos navegadores
         */
        if (event.preventDefault) { //standart browsers
            event.preventDefault();
        } else { // internet explorer
            event.returnValue = false;
        }
        var valor = obj.value;
        var x = valor.substring(0, valor.length - 1);
        obj.value = demaskvalue(x, true).formatCurrency();
        return false;
    }
    /*
     Executa o Formata Reais e faz o format currency novamente apï¿½s o backspace
     */
    FormataReais(obj, '.', ',', event);
} // end reais


function backspace(obj, event) {
    /*
     Essa funï¿½ï¿½o basicamente altera o  backspace nos input com mï¿½scara reais para os navegadores IE e opera.
     O IE nï¿½o detecta o keycode 8 no evento keypress, por isso, tratamos no keydown.
     Como o opera suporta o infame document.all, tratamos dele na mesma parte do cï¿½digo.
     */

    var whichCode = (window.Event) ? event.which : event.keyCode;
    if (whichCode == 8 && documentall) {
        var valor = obj.value;
        var x = valor.substring(0, valor.length - 1);
        var y = demaskvalue(x, true).formatCurrency();

        obj.value = ""; //necessï¿½rio para o opera
        obj.value += y;

        if (event.preventDefault) { //standart browsers
            event.preventDefault();
        } else { // internet explorer
            event.returnValue = false;
        }
        return false;

    }// end if		
}// end backspace

function FormataReais(fld, milSep, decSep, e) {
    var sep = 0;
    var key = '';
    var i = j = 0;
    var len = len2 = 0;
    var strCheck = '0123456789';
    var aux = aux2 = '';
    var whichCode = (window.Event) ? e.which : e.keyCode;

    //if (whichCode == 8 ) return true; //backspace - estamos tratando disso em outra funï¿½ï¿½o no keydown
    if (whichCode == 0)
        return true;
    if (whichCode == 9)
        return true; //tecla tab
    if (whichCode == 13)
        return true; //tecla enter
    if (whichCode == 16)
        return true; //shift internet explorer
    if (whichCode == 17)
        return true; //control no internet explorer
    if (whichCode == 27)
        return true; //tecla esc
    if (whichCode == 34)
        return true; //tecla end
    if (whichCode == 35)
        return true;//tecla end
    if (whichCode == 36)
        return true; //tecla home

    /*
     O trecho abaixo previne a aï¿½ï¿½o padrï¿½o nos navegadores. Nï¿½o estamos inserindo o caractere normalmente, mas via script
     */

    if (e.preventDefault) { //standart browsers
        e.preventDefault()
    } else { // internet explorer
        e.returnValue = false
    }

    var key = String.fromCharCode(whichCode);  // Valor para o cï¿½digo da Chave
    if (strCheck.indexOf(key) == -1)
        return false;  // Chave invï¿½lida

    /*
     Concatenamos ao value o keycode de key, se esse for um nï¿½mero
     */
    fld.value += key;

    var len = fld.value.length;
    var bodeaux = demaskvalue(fld.value, true).formatCurrency();
    fld.value = bodeaux;

    /*
     Essa parte da funï¿½ï¿½o tï¿½o somente move o cursor para o final no opera. Atualmente nï¿½o existe como movï¿½-lo no konqueror.
     */
    if (fld.createTextRange) {
        var range = fld.createTextRange();
        range.collapse(false);
        range.select();
    } else if (fld.setSelectionRange) {
        fld.focus();
        var length = fld.value.length;
        fld.setSelectionRange(length, length);
    }
    return false;

}

//------------------------------------------- Mascaras ----------------------------------------------------

function virgula(elemento, fixed) {

    if (fixed == undefined) {
        fixed = '2';
    }
    if (elemento.value != "0" && elemento.value != 0 && elemento.value.indexOf(".", 0) != -1) {
        elemento.value = String(parseFloat(elemento.value).toFixed(fixed)).replace(/\./, ',');
    }

    if (elemento.value == "undefined" || elemento.value == undefined) {
        elemento.value = "0,0";
    }

}
function colocarVirgula(number, fixed) {
    if (fixed == undefined) {
        fixed = 2;
    } else {
        fixed = parseInt(fixed, 10);
    }
    number = parseFloat(number);
    var newNumber = number.toLocaleString('pt-br', {minimumFractionDigits: fixed, maximumFractionDigits: fixed});
    return newNumber;
}
// Função colocarVírgula antiga, para ser utilizada nas telas antigas que não funcionam com pontos (para valores acima de 1000).
function colocarVirgulaOld(number, fixed) {
    if (fixed == undefined) {
        fixed = '2';
    }
    number = String(parseFloat(number).toFixed(fixed)).replace(/\./, ',');
    return number;
}
function colocarVirgulaSt(number) {
    number = number.replace(/\./, ',');
    return number;
}
function colocarPonto(number) {
    number = number.replace(/\./, '');
    number = number.replace(/\,/, '.');
    return number;

}
var janela;
function abrirLocaliza(url, target) {
    janela = window.open(url, target, 'left=0, top=0, height=650, width=800, scrollbars=yes,resizable=yes');
    janela.window.resizeTo(screen.width / 1.5, screen.height - 100);
    janela.focus();

}

function abrirMax(url, target) {
    janela = window.open(url, target, 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
    janela.window.resizeTo(screen.width, screen.height - 50);
    janela.focus();

}
//---------------------------------------------Fim Mascaras----------------------------------------------------
//---------------------------------------------Validaï¿½ï¿½o de data------------------------------------------------


function validaData(data) {
    var barras = data.value.split("/");
    if (barras.length == 3) {
        var dia = barras[0];
        var mes = barras[1];
        var ano = barras[2];
        if (ano.length == 2) {
            if (ano >= 50 && ano <= 99)
                ano = "19" + ano;
            else
                ano = "20" + ano;
        }

        //Verificando se o dia e o mês é válido
        if ((mes < 1 || mes > 12) || (dia < 1 || dia > 31))
            return false;
        //Verificando se o dia está correto para os meses com 30 dias
        else if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia == 31)
            return false;
        //Verificando se o dia foi digitado corretamente para o mês 02
        else if (mes == 2 && dia > 29)
            return false;
        //Verificando a qtd de dígitos do ano
        else if (ano.length != 2 && ano.length != 4)
            return false;
        else if (parseInt(ano) < 1900) // Deivid pediu para caso o ano for menor que 1900, avisar que a data é inválida.
            return false;
        else
            return true;
    } else {
        return false;
    }
}

function validaData2(data) {
    var barras = data.split("/");
    if (barras.length == 3) {
        var dia = barras[0];
        var mes = barras[1];
        var ano = barras[2];
        if (ano.length == 2) {
            if (ano >= 50 && ano <= 99)
                ano = "19" + ano;
            else
                ano = "20" + ano;
        }

        //Verificando se o dia e o mês é válido
        if ((mes < 1 || mes > 12) || (dia < 1 || dia > 31))
            return false;
        //Verificando se o dia está correto para os meses com 30 dias
        else if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia == 31)
            return false;
        //Verificando se o dia foi digitado corretamente para o mês 02
        else if (mes == 2 && dia > 29)
            return false;
        //Verificando a qtd de dígitos do ano
        else if (ano.length != 2 && ano.length != 4)
            return false;
        else
            return true;
    } else {
        return false;
    }
}

function alertInvalidDate(ob) {
    var no_alert_if_blank = (arguments.length > 1 && arguments[1] == true)
    if (no_alert_if_blank && ob.value == "")
        return true;

    var dataAtual = new Date();
    var mesAtual = dataAtual.getMonth() + 1;
    if (mesAtual < 10) {
        mesAtual = '0' + mesAtual;
    }
    var anoAtual = dataAtual.getFullYear();

    //Completando a data se baseando apenas pelo dia    
    if (ob.value.length == 2) {
        ob.value = ob.value.substr(0, 2) + "/" + mesAtual + "/" + anoAtual;
    }
    if (ob.value.length == 3 || ob.value.length == 4) {
        ob.value = ob.value.substr(0, 3) + mesAtual + "/" + anoAtual;
    }

    //Completando a data se baseando apenas pelo dia/mes    
    if (ob.value.length == 5) {
        ob.value = ob.value.substr(0, 5) + "/" + anoAtual;
    }
    if (ob.value.length == 6 || ob.value.length == 7) {
        ob.value = ob.value.substr(0, 6) + anoAtual;
    }

    //Completando a data com o ano
    if (ob.value.length == 8) {
        ob.value = ob.value.substr(0, 6) + "20" + ob.value.substr(6, 2);
    }

    if (!validaData(ob))
    {
        // esses caracteres \u00e9 é para colocar acento é e esse \u00e1 acento no á
        alert('A data "' + ob.value + '" \u00e9 inv\u00e1lida');
        //Comentado por que não funciona no FireFox e no Chrome ele funciona, porém não deixa mais alterar nada.
        //por quê o pop-up não sai mais e sempre o foco volta pra o campo.
//        ob.focus();
        ob.value = "";
    }
    return false;

}
/**    exemplo
 *  CEP
 *  OnKeyPress="formatar(this, '#####-###')"
 *  DATA:
 *  OnKeyPress="formatar(this, '##/##/####')"
 */
function formatar(src, mask) {
    var i = src.value.length;
    var saida = mask.substring(0, 1);
    var texto = mask.substring(i)
    if (texto.substring(0, 1) != saida) {
        src.value += texto.substring(0, 1);
    }
}
function fmtDate(ob, ev) {
    var tecla = (window.event ? event.keyCode : ev.which);

    var matches = ob.value.toString().match(/[0-9]/g);
    if (matches == null)
        ob.value = "";

    //escapando as teclas shift, del, backspace, left, right E se a data conter algum caractere fora barra ou 0-9.
    if (ev.keyCode == 46 || ev.keyCode == 37 || ev.keyCode == 39 || ev.keyCode == 9 ||
            ev.keyCode == 8 || ev.keyCode == 13 || ev.keyCode == 16 || matches == null)
        return true;

    if (ob.value.substring(ob.value.length - 1) == "/")
        ob.value = ob.value.substring(0, ob.value.length - 1);

    //montando a data com as barras
    if ((ob.value.length == 2 || ob.value.length == 5) && (ob.value.match(/\//g) == null || ob.value.match(/\//g).length < 2))
        ob.value += "/";

    var containsInvalidChar = (ob.value.match(/\/|[0-9]/g) != null && ob.value.match(/\/|[0-9]/g).join("") != ob.value);

    //se contem caracteres inval
    if (containsInvalidChar || tecla == 47) {
        var _n = matches.join("");
        ob.value = _n.substr(0, 2) + (_n.length >= 2 ? "/" : "") + _n.substr(2, 2) + (_n.length >= 4 ? "/" : "") + _n.substr(4, 4);
    }
}

function applyFormatter() {
    function applyData(obj) {
        if (isIE()) {
            obj.onkeypress = new Function("fmtDate(this, event)");
            obj.onkeyup = new Function("fmtDate(this, event)");
            obj.onkeydown = new Function("fmtDate(this, event)");
        } else {
            obj.setAttribute("onkeypress", "fmtDate(this, event)");
            obj.setAttribute("onkeyup", "fmtDate(this, event)");
            obj.setAttribute("onkeydown", "fmtDate(this, event)");
        }
    }
    function applyDecimal(obj) {
        if (isIE()) {
            obj.onkeypress = new Function("mascara(this, reais);");
        } else {
            obj.setAttribute("onkeypress", "mascara(this, reais);");
        }
    }

    //se passar um objeto como argumento entao formate apenas ele
    if (arguments.length > 1) {
        applyData(arguments[1]);
        return true;
    }

    var elems = elementsByClassName('fieldDate', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyData(elems[i]);

    var elems = elementsByClassName('fieldDateMin', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyData(elems[i]);

    var elems = elementsByClassName('fieldDecimal', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyDecimal(elems[i]);
}


function elementsByClassName(strClass)
{
    var ret = new Array();
    var tag = arguments[1] || "*";
    var node = arguments[2] || document;
    var base = node.getElementsByTagName(tag);
    var tBase = base.length;
    for (var i = 0; i < tBase; i++)
    {
        var aClass = base[i].className.split(" ");
        var taClass = aClass.length;
        for (var j = 0; j < taClass; j++)
        {
            if (aClass[j] == strClass)
            {
                ret[ret.length] = base[i];
                break;
            }
        }
    }
    return ret;
}

function isIE() {
    return (navigator.appName == "Microsoft Internet Explorer");
}

function setEnv(idBotao) {
    idBotao = (idBotao == null ? "botSalvar" : idBotao);
    var botao = document.getElementById(idBotao);
    botao.disabled = true;
    botao.value = "Enviando...";
}
function unSetEnv(idBotao, descricao) {
    idBotao = (idBotao == null ? "botSalvar" : idBotao);
    if (opener.document.getElementById(idBotao) != null) {
        var botao = opener.document.getElementById(idBotao);
        botao.disabled = false;
        if (descricao != null && descricao != undefined && descricao != "") {
            botao.value = descricao;
        } else {
            botao.value = "  SALVAR  ";
        }
    }
}

/**@ob
 objeto para validacao
 @no_alert_if_blank
 (opcional) Se true, nï¿½o valida a data caso esteja em branco */

//------------------------------------------FIM Validaï¿½ï¿½o data---------------------------------------------------------------


function limitaText(campo, permitido) {
    //coloca limite no textarea
    if (campo.value.length > permitido) {
        campo.value = campo.value.substr(0, permitido - 1)
    }
}

//--------------------------------------------SUBTRAï¿½ï¿½O ENTRE DUAS DATAS-------------------------------------------------------

function subtrairData(dataInicio, dataFinal) {
    //recebe duas strings
    //criar array para formatar
    var diaInicio = dataInicio.split('/')[0];
    var mesInicio = dataInicio.split('/')[1];
    var anoInicio = dataInicio.split('/')[2];

    var diaFim = dataFinal.split('/')[0];
    var mesFim = dataFinal.split('/')[1];
    var anoFim = dataFinal.split('/')[2];

    var num1 = new Date(anoFim, mesFim - 1, diaFim);
    var num2 = new Date(anoInicio, mesInicio - 1, diaInicio);

    return (num1 - num2) / (1000 * 60 * 60 * 24);
}

function clone(obj) {

    if (obj == null || typeof (obj) != 'object')
        return obj;

    var temp = new obj.constructor(); // changed (twice)
    for (var key in obj)
        temp[key] = clone(obj[key]);



    return temp;

}

function setUm(obj) {
    // Esta funï¿½ï¿½o serve para setar o valor 1 quando nï¿½o for digitado o valor ou for zero
    var valor = obj.value;
    if (valor == "0" || valor == "")
        obj.value = "1";
}

function blockInterface(fechaCortina)
{
    if (document.getElementById("cortina") == null)
    {
        var layer = document.createElement("LABEL");
        layer.id = "cortina";
        document.body.appendChild(layer);
        var ob = document.getElementById("cortina");
        ob.style.position = "absolute";
        ob.style.width = "100%";
        ob.style.height = "100%";
        ob.style.zIndex = 2;
        ob.style.backgroundColor = "#000000";
        ob.style.left = "0";
        ob.style.top = "0";
        ob.style.filter = "alpha(opacity=15)";
        ob.style.opacity = "0.2";
    }

    document.getElementById("cortina").style.display = (fechaCortina ? "" : "none");

}

function mensagemExcluir(campoExcluir, mensagem)
{
    if (!confirm(mensagem)) {
        return false;
    } else {
        if (campoExcluir.split("!!").length > 1) {
            for (var i = 0; i <= campoExcluir.split("!!").length; i++) {
                if (document.getElementById(campoExcluir.split("!!")[i]) != null) {
                    Element.remove(campoExcluir.split("!!")[i]);
                }
            }
        } else {
            Element.remove(campoExcluir);
        }
        return true;
    }

}

/*
 * 
 * @param array de String
 * @description Limpa campos de formulario, se padrï¿½o do campo comeï¿½a com id entï¿½o seta 0
 */
function limparCampos(campos) {
    for (var i = 0; i < campos.length; i++) {
        if (campos[i].startsWith("id")) {
            $(campos[i]).value = "0";
        } else {
            $(campos[i]).value = "";
        }
    }
}

function espereEnviarPop(msg, mostra) {
    d = document;
    //se nao existe a layer no documento[primeira vez que o mï¿½todo eh chamado no documento]
    if (d.getElementById("layer_espere") == null)
        if (mostra) {
            var wPop = screen.width;
            var hPop = screen.height;
            var layer = document.createElement("div");
            layer.id = "layer_espere";
            layer.style.width = "220px";
            layer.style.height = "140px";
            layer.style.position = "absolute";
            layer.style.top = "50%";
            layer.style.left = "50%";
            layer.style.margin = "-50px";
            layer.style.margin = "-50px";
            layer.style.backgroundColor = "#FFFFFF";
////                        layer.style.position = "absolute";
//                        layer.style.width = "220px";
//                        layer.style.height = "140px";
//                        layer.style.zIndex = "1";
//                        layer.style.left = "350px";
//                        layer.style.top = "300px";



            d.body.appendChild(layer);
        } else
            return null;

    //mostrando/ocultando a mensagem
    d.getElementById("layer_espere").style.display = (mostra == true ? "" : "none");
    if (!mostra)//se (mostra == false) entao oculte e pare a instrucao
        return false;
    //incluindo a mensagem agora
    d.getElementById("layer_espere").innerHTML = '<table width="100%" height="100%" border="1" bordercolor="#996600" cellpadding="0" cellspacing="0">' +
            '<tr><td align="center"><br><img src="img/carregando.gif" align="top" border="0">' +
            '<br><br><label style="font:Verdana, Arial, Helvetica, sans-serif" id="comentario">' +
            (msg == "" ? "Aguarde..." : msg) + '</label></td></tr></table></div>';
}

function espereEnviar(msg, mostra) {
    d = document;
    //se nao existe a layer no documento[primeira vez que o mï¿½todo eh chamado no documento]
    if (d.getElementById("layer_espere") == null)
        if (mostra) {
//            var wPop  = screen.width * 0.50;
//            var hPop  = screen.height * 0.50;
            var layer = document.createElement("LABEL");
            layer.id = "layer_espere";
            layer.style.position = "absolute";
            layer.style.backgroundColor = "#FFFFFF";
            layer.style.width = "220px";
            layer.style.height = "140px";
            layer.style.zIndex = "1";
            layer.style.left = "50%";
            layer.style.top = "50%";
            layer.style.margin = "-50px";
            layer.style.margin = "-50px";

            d.body.appendChild(layer);
        } else
            return null;

    //mostrando/ocultando a mensagem
    d.getElementById("layer_espere").style.display = (mostra == true ? "" : "none");
    if (!mostra)//se (mostra == false) entao oculte e pare a instrucao
        return false;
    //incluindo a mensagem agora
    d.getElementById("layer_espere").innerHTML = '<table width="100%" height="100%" border="1" bordercolor="#996600" cellpadding="0" cellspacing="0">' +
            '<tr><td align="center"><br><img src="img/espere.gif" align="top" border="0">' +
            '<br><br><label style="font:Verdana, Arial, Helvetica, sans-serif" id="comentario">' +
            (msg == "" ? "Aguarde..." : msg) + '</label></td></tr></table></div>';
}

function mascaraHora(hora) {
    var no_alert_if_blank = (arguments.length > 1 && arguments[1] == true)
    var hrs = (hora.value.substring(0, 2));
    var min = (hora.value.substring(3, 5));
    var ponto = '';

    hora.maxLength = "5";
    if (hrs.length == 2) {
        ponto = ":";
    }
    hora.value = hrs + ponto + min;

    if (!no_alert_if_blank && hora.onblur == undefined) {
        hora.onblur = new Function("verificaHora(this)");
    }
}

function verificaHora(hora) {
    if (hora.value.trim().length == 5) {
        hrs = (hora.value.substring(0, 2));
        min = (hora.value.substring(3, 5));

        situacao = "";
        if (hrs != parseFloat(hrs) || min != parseFloat(min)) {
            situacao = "falsa"
        }
        // verifica data e hora
        if ((hrs < 00) || (hrs > 23) || (min < 00) || (min > 59)) {
            situacao = "falsa";
        }

        if (hora.value == "") {
            //situacao = "falsa";
        }

        if (situacao == "falsa") {
            // esses caracteres \u00e1 é para colocar acento á
            alert("Hora inv\u00e1lida!");
            hora.value = "";
        }
    } else if (hora.value.trim() == '') {
        hora.value = "";
    } else {
        // esses caracteres u00e1 é para colocar acento á
        alert("Hora inv\u00e1lida!");
        hora.value = "";
    }


}

function now() {
    function i0(num) {
        return (("" + num).length == 1 ? "0" + num : "" + num)
    }

    var hoje = new Date();
    return i0(hoje.getDate()) + "/" + i0(hoje.getMonth() + 1) + "/" + hoje.getFullYear();
}

function makeElement(tagName, arrayPropertys) {
    var el = document.createElement(tagName);
    if (arrayPropertys == null || arrayPropertys == "")
        return el;

    //setando atributos
    for (x = 0; x < arrayPropertys.split("&").length; ++x)
    {
        var attr = arrayPropertys.split("&")[x].split("=")[0];
        //O IE tem alguns atributos HTML diferentes do padrao W3C.
        attr = (attr.indexOf("class") > -1 && isIE() ? "className" : attr);
        attr = (attr.indexOf("style") > -1 && isIE() ? "cssText" : attr);
        //se o atributo eh um evento...
        if (attr.indexOf("on") > -1 && isIE())
            el.attachEvent(attr, new Function(arrayPropertys.split("&")[x].split("=")[1]));
        else if (attr == "innerHTML")
            el.innerHTML = arrayPropertys.split("&")[x].split("=")[1];
        //else if (attr == "checked")
        //   el.check = true;
        else
            el.setAttribute(attr, arrayPropertys.split("&")[x].split("=")[1]);

    }

    //setando o name para o id
    if (el.name == "")
        el.name = el.id;

    return el;
}


function Option(valor, descricao) {
    this.valor = valor;
    this.descricao = descricao
}

// javascript não possui replaceall
function replaceAll(string, token, newtoken) {
    while (string.indexOf(token) != -1) {
        string = string.replace(token, newtoken);
    }
    return string;
}

/**
 * torna o elemento visivel
 */
function isVisivel(elemento, isAlert) {
    if (isNull(elemento, isAlert)) {
        return elemento.style.display == "";
    }
    return false;
}
function visivel(elemento, isAlert) {
    if (isNull(elemento, isAlert)) {
        if (elemento.style == null || elemento.style == undefined) {
            $("#" + elemento.id).show();
        } else {
            elemento.style.display = "";
        }
    }
}
/**
 * torna o elemento invisivel
 */
function invisivel(elemento) {
    if (isNull(elemento)) {
        if (elemento.style == null || elemento.style == undefined) {
            $("#" + elemento.id).hide();
        } else {
            elemento.style.display = "none";
        }
    }
}

/**
 *
 */
function habilitar(elemento) {
    if (isNull(elemento)) {
        elemento.disabled = false;
    }
}
function isHabilitado(elemento) {
    var retorno = "";
    if (elemento != null) {
        retorno = elemento.disabled;
    } else {
        alert("Elemento nulo.")
    }
    return retorno;
}
/**
 *
 */
function desabilitar(elemento, cor) {
    if (elemento != null) {
        elemento.disabled = true;
        cor = (cor == null || cor == undefined || cor == "" ? "#FFFFF1" : cor);
        setCorBackground(elemento, cor);

    } else {
        alert("Elemento nulo.")
    }
}
function setCorBackground(elemento, cor) {
    elemento.style.backgroundColor = cor;
}

function showErro(texto) {
    var retorno = true;
    var campo = null;
    if (texto != null && texto != undefined && texto.trim() != "") {

        if (arguments.length > 1) {
            for (var i = 1; i < arguments.length; i++) {
                campo = arguments[i];
                console.log("campo" + campo);
                if (campo != null) {
                    campo.style.background = "#FFE8E8";
                    campo.focus();
                }
            }
        }

        retorno = false;
        if (texto != null && texto != undefined && texto.trim() != "") {
            alert(texto);
        }
    } else {
        retorno = false;
    }
    return retorno;
}

function arredondar(x, n) {
    n = (n == undefined || n == null ? 2 : n);
    if (n < 0 || n > 10)
        return x;
    var pow10 = Math.pow(10, n);
    var y = x * pow10;
    return Math.round(y) / pow10;
}

function seNaoFloatReset(obj_input, valor_reset)
{
    /*Se informar um 3º parametro, esse sera considerado boolean
     para inserção ou nao dos zeros a esquerda. Padrao true*/
    var zerosEsquerda = (arguments[2] != null ? arguments[2] : true);
    var vlr = virgulaToPonto((obj_input.value.trim() == "" ? "0" : obj_input.value.trim()));
    obj_input.value = (isNaN(vlr) || parseFloat(vlr) == 0 ?
            valor_reset : (vlr.indexOf('.') < 0 ? vlr + (zerosEsquerda ? '.00' : '') : vlr));
}

//coloca 4 casas decimais quando carregar a tela - historia 3201
function seNaoFloatResetQuatroCasasDecimais(obj_input, valor_reset)
{
    /*Se informar um 3º parametro, esse sera considerado boolean
     para inserção ou nao dos zeros a esquerda. Padrao true*/
    var zerosEsquerda = (arguments[2] != null ? arguments[2] : true);
    var vlr = virgulaToPonto((obj_input.value.trim() == "" ? "0" : obj_input.value.trim()));
    obj_input.value = (isNaN(vlr) || parseFloat(vlr) == 0 ?
            valor_reset : (vlr.indexOf('.') < 0 ? vlr + (zerosEsquerda ? '.0000' : '') : vlr));
}

//atribui valor_reset para o input text se o mesmo contiver um valor nao inteiro
function seNaoIntReset(obj_input, valor_reset)
{
    if (obj_input.value.trim() == "")
    {
        obj_input.value = valor_reset;
        return true;
    }

    obj_input.value = ((isNaN(obj_input.value)) || (obj_input.value.indexOf('.') > -1) ? //ATENCAO!! Kenneth removeu "|| parseInt(vlr) == 0" daqui pq nao aceitava "0"
            valor_reset : obj_input.value);
    obj_input.value = obj_input.value.trim();
}

function virgulaToPonto(valor) {
    var retorno = valor;
    while (retorno.indexOf(',') > - 1)
        retorno = retorno.replace(',', '.');

    return retorno;
}

function isInt(x) {
    var y = parseInt(x);
    if (isNaN(y))
        return false;
    return x == y && x.toString() == y.toString();
}

function getCookie(nomeBiscoito) {
    var cookie = document.cookie;
    var listaCookies = "";
    var retorno = null;

    if (cookie != null && cookie != undefined && cookie != "") {
        listaCookies = cookie.split(";");
        if (listaCookies != undefined && listaCookies != null) {
            for (var i = 0; i < listaCookies.length; i++) {
                if (listaCookies[i] != null && listaCookies[i] != undefined && listaCookies[i] != "") {
                    if (listaCookies[i].trim().split("=")[0] == nomeBiscoito.trim()) {
                        return new CookieGw(listaCookies[i]);
                    }
                }
            }
        }
    }
    return retorno;
}

/*5-4-2006  Kenneth F. Reis
 Testa se a sessão ainda é válida. */
function tryRequestToServer(metodo)
{
    function ev(textoresposta, codestatus) {
        if (codestatus == 200) {
            metodo();
            return true;
        } else if (codestatus == 403)
        {
            blockInterface(true);
            //se o prompt ainda nao existe crie ele no escopo
            if (document.getElementById("promptPasswd") == null)
            {
                //criando a layer do prompt da senha
                var promp = document.createElement("DIV");
                promp.id = "promptPasswd";
                document.body.appendChild(promp);
                var obj = document.getElementById("promptPasswd").style;
                obj.zIndex = "3";
                obj.position = "absolute";
                obj.backgroundColor = "#FFFFEA";
                obj.left = "33%";
                obj.top = "46%";
                //criando objetos da layer
                var inPasswd = document.createElement("INPUT");
                inPasswd.type = "password";
                inPasswd.id = "passw";
                var inBt = document.createElement("INPUT");
                inBt.type = "button";
                inBt.value = "OK";
                inBt.id = "btOkReconnect";
                inBt.onclick = function () {
                    var docum = (window.opener == null ? document : window.opener.document);
                    var userCurrent = "";
                    var cookie = getCookie("loginBiscoito");
                    //se o usuario fechou a tela pai entao eh impossivel o resgate da sessao
                    if (docum.getElementById("usuarioLogado") == null && cookie == null) {
                        alert("A tela principal foi fechada. Impossível resgatar a sessao!");
                        return false;
                    }

                    if (cookie == null) {
                        userCurrent = docum.getElementById("usuarioLogado").innerHTML;
                    } else {
                        userCurrent = cookie.valor;
                    }

                    if (!wasNull("passw"))
                        reconnectUser(userCurrent,
                                document.getElementById("passw").value)
                };
                //inserindo na layer os objetos de login
                document.getElementById("promptPasswd").innerHTML = "<b>Sua sessão expirou!</b><br>Digite sua senha:";
                var pForm = document.createElement("FORM");
                pForm.appendChild(inPasswd);
                pForm.appendChild(inBt);
                pForm.action = "javascript:getObj('btOkReconnect').click();";
                document.getElementById("promptPasswd").appendChild(pForm);
            }
            document.getElementById("promptPasswd").style.display = "";
            document.getElementById("passw").focus();
            return false;
        } else {
            var msg = "";
            switch (codestatus) {
                case "12029" :
                    alert("Status: " + codestatus + "\nO servidor parece está desligado!");
                    break;
                default    :
//                    alert("Status: " + codestatus + "\n Não foi possivel enviar a requisição.");
                    alert("Status: " + codestatus + "\n\
                                Excedeu o tempo limite de espera do servidor. \n\
                                Atualize a página, tente se conectar novamente e caso persista, \n\
                                entre em contato com o suporte técnico pelo fone: (81) 2125-3752");
            }

            return false;
        }
    }

    requisitaAjax("./session_test.jsp", ev);
}

function requisitaAjax(acao, evento_resposta) {
    function ev() {
        if (receiveReq.readyState == 4)
            evento_resposta(receiveReq.responseText, receiveReq.status);
    }
    var receiveReq;
    if (isIE())
        receiveReq = new ActiveXObject("Microsoft.XMLHTTP");
    else
        receiveReq = new XMLHttpRequest();
    receiveReq.open('POST', acao, true);
    receiveReq.onreadystatechange = ev;
    receiveReq.send(null);
}

function getObj(idObj) {
    if (document.getElementsByName(idObj)[0] != null)
        document.getElementsByName(idObj)[0].id = idObj;

    return document.getElementById(idObj);
}

function launchPDF(url, idname) {
    tryRequestToServer(function () {
        var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
        var pdf = window.open("redireciona_relatorio.jsp?url=" + encodeURIComponent(url), idname, cf);
        //bloquearFechamentoPop(pdf, url);
        pdf.window.resizeTo(screen.width, screen.height - 20);
        pdf.focus();
    }
    );
}
/**
 * Deixa o elemento readOnly e a muda a classe
 */
function readOnly(elemento, classe) {
    classe = (arguments[1] == null ? "inputReadOnly" : classe);
    if (elemento != null) {
        elemento.className = classe;
        elemento.readOnly = true;
    } else {
        alert("Elemento nulo.")
    }
}
/**
 *Retira o readonly do elemento
 */
function notReadOnly(elemento, classe) {
    classe = (arguments[1] == null ? "inputtexto" : classe);
    if (elemento != null) {
        elemento.className = classe;
        elemento.readOnly = false;
    } else {
        alert("Elemento nulo.")
    }
}

/**
 * Remove todos os opiton's do select
 */
function removeOptionSelected(id) {
    var elSel = $(id);

    for (var i = elSel.length - 1; i >= 0; i--) {
        elSel.remove(i);
    }
}

function launchPopupLocate(url, idname) {
    var wPop = screen.width * 0.80;
    var hPop = screen.height * 0.70;
    var cf = 'top=' + (((screen.height - hPop) / 2) - 15) + ',left=' + ((screen.width - wPop) / 2) +
            ',height=' + hPop + ',width=' + wPop + ',resizable=yes,status=1,scrollbars=1';
    var popup = window.open(url, idname, cf);
    return popup;
//alertando a janela do popup
//	popup.focus();
}

function wasNull(ids) {
    var campos = ids.split(',');
    if (campos == null)
        return false;
    var i = 0;
    var nulo = 0;
    var retorno = false;
    for (i = 0; i < campos.length; ++i) {
        /*if (document.getElementById(campos[i]) == null)
         alert("wasNull()\n\nO objeto "+campos[i]+" não existe");*/

        if ((document.getElementById(campos[i]) != null) && (document.getElementById(campos[i]).value.trim() == "")) {
            document.getElementById(campos[i]).value = "";// <--- caso o valor seja " " ele zera
            document.getElementById(campos[i]).style.background = "#FFE8E8";
            //se ja achou algum valor nulo anteriormente, entao ficara true
            retorno = true;
            document.getElementById(campos[i]).onkeypress = function () {
                this.style.background = "#FFFFFF";
            };
        }
    }
    return retorno;
}

function reconnectUser(user, passwd)
{
    function ev(textoresposta, codestatus) {
        //usuario digitou a senha incorreta
        if (codestatus == 403)
            alert("A senha está incorreta!");
        else if (codestatus == 200)
        {
            document.getElementById("promptPasswd").style.display = "none";
            blockInterface(false);
        } else
            alert("Status " + codestatus + "\n\nErro ao na tentativa de enviar a requisicao de resgate de sessao!");

        document.getElementById("passw").value = "";
        document.getElementById("btOkReconnect").disabled = false;
        return (codestatus == 200);
    }
    $("btOkReconnect").disabled = true;
    /*Bloco de intrucoes da funcao*/
    requisitaAjax("./home?login=" + user + "&senha=" + passwd + "&textmode=1", ev);
}
/**
 * Recebe o objeto <select>
 * Retorna o valor string do <option> que se encontra 'selected'
 */
function getTextSelect(elemento) {
    return elemento.options[elemento.selectedIndex].innerHTML;
}
/*Transfor*/
function pontoParseFloat(valorStr) {

    return parseFloat(colocarPonto(valorStr));

}

function popLocate(idlista, nomeJanela, indice, camposAdicionais) {
    camposAdicionais = (camposAdicionais == null || camposAdicionais == undefined ? "" : camposAdicionais);
    indice = (indice == null || indice == undefined ? "" : indice);
    popupLocate = launchPopupLocate("./localiza?acao=consultar&suffix=" + indice + "&idlista=" + idlista + camposAdicionais, nomeJanela + indice);
}

function isNull(elemento, isAlert) {
    isAlert = (isAlert == null || isAlert == undefined ? false : isAlert);
    if (elemento != null) {
        return true;
    } else if (isAlert) {
        alert("Elemento não encontrado.");
    }
    return false;
}

//formata um valor Float  1000.00
function formatoMoeda(_num) {
    _num = _num.toString().replace(/\$|\,/g, '');
    var decimal = 2;
    if (arguments.length >= 2) {
        decimal = arguments[1];
    }
    var pow = Math.pow(10, decimal);
    if (isNaN(_num))
        _num = "0";
    var sign = (_num == (_num = Math.abs(_num)));
    _num = Math.floor(_num * pow + 0.50000000001);
    var cents = _num % pow;
    _num = Math.floor(_num / pow).toString();
    if (cents < 10)
        cents = "0" + cents;
    for (var i = 0; i < Math.floor((_num.length - (1 + i)) / 3); i++)
        _num = _num.substring(0, _num.length - (4 * i + 3)) + ',' + _num.substring(_num.length - (4 * i + 3));

    //retirando a virgula
    var retorno = (((sign) ? '' : '-') + _num + '.' + cents);
    while (retorno.indexOf(',') > - 1)
        retorno = retorno.replace(',', '');
    return retorno;
}

function showArgumentos(argumentos) {
    for (i = 0; i < argumentos.length; i++) {
        alert("Valor:" + argumentos[i] + "     \nIndex:" + i);
    }
}

function fillZero(numero, lengthMin) {
    numero = (numero != null && numero != undefined ? numero : "");
    var lengthFinal = lengthMin - numero.toString().length;
    var zeros = "";
    for (i = 0; i < lengthFinal; i++) {
        zeros += "0";
    }
    return zeros + numero;
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds) {
            break;
        }
    }
}

/**8-5-2006
 Incrementa uma data(dd/MM/yyyy) com "n" dias.*/
function incData(dtString, numDias)
{
    function i0(num) {
        return (("" + num).length == 1 ? "0" + num : "" + num)
    }

    var d_dia = parseFloat(dtString.split("/")[0]);
    //o mes começa de 0, entao -1 para fazer os calculos
    var d_mes = parseFloat(dtString.split("/")[1]) - 1;
    var d_ano = parseFloat(dtString.split("/")[2]);

    var dataD = new Date(d_ano, d_mes, d_dia);
    var timeU = dataD.getTime() + (numDias * (24 * 60 * 60 * 1000));
    var nD = new Date(timeU);

    return       i0(nD.getDate()) +
            // ATENCAO! O mes começa de 0, entao somamos +1 depois dos calculos com data
            "/" + i0(nD.getMonth() + 1) +
            "/" + nD.getFullYear();
}

function incDias(dtInicial, dtFinal)
{
    //	function i0(num){ return ((""+num).length == 1 ? "0"+num : ""+num) }
    //Data Inicial
    var d_dia_i = parseFloat(dtInicial.split("/")[0]);
    //o mes começa de 0, entao -1 para fazer os calculos
    var d_mes_i = parseFloat(dtInicial.split("/")[1]) - 1;
    var d_ano_i = parseFloat(dtInicial.split("/")[2]);
    //Data Final
    var d_dia_f = parseFloat(dtFinal.split("/")[0]);
    //o mes começa de 0, entao -1 para fazer os calculos
    var d_mes_f = parseFloat(dtFinal.split("/")[1]) - 1;
    var d_ano_f = parseFloat(dtFinal.split("/")[2]);

    var dataD_i = new Date(d_ano_i, d_mes_i, d_dia_i);
    var dataD_f = new Date(d_ano_f, d_mes_f, d_dia_f);
    var timeU_i = dataD_i.getTime() + (24 * 60 * 60 * 1000);
    var timeU_f = dataD_f.getTime() + (24 * 60 * 60 * 1000);
    var tDias = timeU_f - timeU_i;

    return tDias / 86400000;
}

function fechar() {
    window.close();
}

function concatFieldValue(ids) {
    var str = "";
    for (i = 0; i < ids.split(",").length; ++i) {
        var idname = ids.split(",")[i].trim();
        if (document.getElementById(idname) == null) {
            alert("concatFieldValue()\n\nO objeto com o id \"" + idname + "\" não existe no escopo HTML!");
            return null;
        }

        str += idname + "=" + escape(document.getElementById(idname).value);
        //adicionando o delimitador de paametros
        str += ((i + 1) < ids.split(",").length ? "&" : "");
    }

    return str;
}

function concatFieldValueUnescape(ids) {
    var str = "";
    for (i = 0; i < ids.split(",").length; ++i) {
        var idname = ids.split(",")[i];
        if (document.getElementById(idname) == null) {
            alert("concatFieldValue()\n\nO objeto com o id \"" + idname + "\" não existe no escopo HTML!");
            return null;
        }

        str += idname + "=" + document.getElementById(idname).value;
        //adicionando o delimitador de paametros
        str += ((i + 1) < ids.split(",").length ? "&" : "");
    }

    return str;
}

function isExisteOption(elemento, valor) {
    if (elemento != null && elemento != undefined) {
        var max = elemento.options.length;
        console.log("max = " + max);
        for (var i = 0; i < max; i++) {
            if (elemento.options[i].value == valor) {
                return true;
            }
        }
    }
    return false;
}

function povoarSelect(elemento, lista) {
    var optLayout = null;
    if (lista != null && lista != undefined) {
        for (var i = 0; i < lista.length; i++) {
            if (lista[i] != null && lista[i] != undefined) {
                optLayout = Builder.node("option", {
                    value: lista[i].valor
                });
                Element.update(optLayout, lista[i].descricao);
                elemento.appendChild(optLayout);
            }
        }
        elemento.selectedIndex = 0;
    }
}

function abrirJanela(url, target, percWidth, percHeight, isFocus) {
    isFocus = (isFocus == null || isFocus == undefined ? true : isFocus);
    janela = window.open(url, target, 'left=' + (screen.width / 4) + ', top=0, height=650, width=800, scrollbars=yes,resizable=yes');
    janela.window.resizeTo(screen.width * (percWidth / 100), screen.height * (percHeight / 100));
    if (isFocus) {
        janela.focus();
    }

}

function abrirPop(url, target) {
    abrirJanela(url, target, 40, 30, false);
    return janela;
}

var arAbasGenerico = null;
/**
 *
 */
function stAba(menu, conteudo) {
    this.menu = menu;
    this.conteudo = conteudo;
}
/**
 * Função que controla as abas
 * @param menu: o elemento que contem a descrição da aba
 * @param conteudo: o elemento container (div)
 */
function AlternarAbasGenerico(menu, conteudo) {
    try {
        if (arAbasGenerico != null) {
            for (i = 0; i < arAbasGenerico.length; i++) {
                if (arAbasGenerico[i] != null && arAbasGenerico[i] != undefined) {
                    m = document.getElementById(arAbasGenerico[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasGenerico[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasGenerico[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasGenerico[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasGenerico[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    } catch (e) {
        alert(e);
    }
}

function roundABNT(valor, casasDecimais) {

    casasDecimais = (casasDecimais != undefined && casasDecimais != null ? casasDecimais : 2);
    var retornoS = "";
    var PRECISAO = 10;
    if (casasDecimais >= PRECISAO) {
        alert("Erro: O numero maximo de casas decimais foi excedido, MAX=(" + PRECISAO - 1 + ")")
        return false;
    }

    /**
     * Acabando com possiveis dizimas inexatas.
     */
    valor = valor.toFixed(PRECISAO);


    /**
     * Regras -- boolean
     */
    var isAlgarismoSeguinteUltimoMaiorCinco = false;
    var isAlgarismoSeguinteUltimoIgualCinco = false;
    var isRestoDecimalMaiorZero = false;
    var isAlgarismoUltimoImpar = false;
    var isAdicionarInteiro = false;


    //Parte inteira do numero
    var inteiro = parseInt(valor, 10);
    //Parte decimal que nao se modifica
    var decimalImutavel = null;
    var zerosEsqDecimalImutavel = "";
    var decimalMutavel = 0;
    var decimalMutavelZero;
    var digitosDecimalMutavel;
    //Ultimo algarismo, aquele que pode ser modificado
    var algarismoUltimo = 0;
    //Primeiro algarismo depois do algarismo a ser modificado
    var algarismoSeguinteUltimo = 0;
    //Algarismo que fica depois do "algarismoSeguinteUltimo"
    var restoDecimal = 0;
    var restoDecimalS = "";


    var decimalS = (valor.toString().indexOf(".") == -1 ? '0   ' : valor.toString().split(".")[1]);
    while (decimalS.length < casasDecimais + 1) {
        decimalS += "0";
    }


    if (casasDecimais > 0) {
        decimalImutavel = (casasDecimais == 1 ? null
                : decimalS.substring(0, casasDecimais - 1));

        var i = 0;
        var ch = '0';
        while (i < decimalImutavel.toString().length && ch == '0') {

            ch = decimalImutavel.toString().substring(i, (i + 1));
            zerosEsqDecimalImutavel += (ch == '0' ? "0" : "");
            i++;
        }

        algarismoUltimo = parseInt(decimalS.charAt(casasDecimais - 1) + "", 10);
        algarismoSeguinteUltimo = parseInt(decimalS.charAt(casasDecimais) + "", 10);
        decimalMutavel = parseInt((decimalImutavel != null ? decimalImutavel : "").toString() + algarismoUltimo.toString(), 10);
        digitosDecimalMutavel = (decimalMutavel).toString().length + zerosEsqDecimalImutavel.toString().length;

        restoDecimalS = casasDecimais + 1 == decimalS.toString().length ? "0"
                : decimalS.toString().substring(casasDecimais + 1,
                (decimalS.toString().length < PRECISAO ? decimalS.toString().length : PRECISAO));


//        if(casasDecimais < PRECISAO && casasDecimais + 1 + restoDecimalS.length   > PRECISAO){            
//            restoDecimalS = restoDecimalS.substring(0, PRECISAO - (casasDecimais +1));
//        }

        restoDecimal = (restoDecimalS == "" ? 0 : parseInt(restoDecimalS, 10));

        isAlgarismoSeguinteUltimoMaiorCinco = algarismoSeguinteUltimo > 5;
        isAlgarismoSeguinteUltimoIgualCinco = algarismoSeguinteUltimo == 5;
        isRestoDecimalMaiorZero = restoDecimal > 0;
        isAlgarismoUltimoImpar = (algarismoUltimo % 2) != 0;

        if (isAlgarismoSeguinteUltimoMaiorCinco) {
            decimalMutavel += 1;
        } else if (isAlgarismoSeguinteUltimoIgualCinco && (isRestoDecimalMaiorZero || isAlgarismoUltimoImpar)) {
            decimalMutavel += 1;
        }

        if ((decimalMutavel.toString()).length <= digitosDecimalMutavel) {
            decimalMutavelZero = fillZero(decimalMutavel.toString(), digitosDecimalMutavel);
            //alert("decimalMutavelZero:" + decimalMutavelZero );
        } else {
            decimalMutavelZero = decimalMutavel.toString();
        }

        isAdicionarInteiro = (digitosDecimalMutavel != decimalMutavelZero.toString().length);




        retornoS += ((inteiro + (isAdicionarInteiro ? 1 : 0)) +
                (".") +
                (isAdicionarInteiro ? "0" : decimalMutavelZero));
    } else {
        retornoS += inteiro;
    }

//            alert("int: " + inteiro);
//            alert("decimal: " + decimalS);
//            alert("decimalImut: " + decimalImutavel);
//            alert("decimalS: " + decimalS);
//            alert("restoDecimalS: " + restoDecimalS);
//            alert("restoDecimal: " + restoDecimal);
//            alert("ultimo: " + algarismoUltimo);
//            alert("seguinteUlt: " + algarismoSeguinteUltimo);
//            alert("retorno: " + retornoS);
//            alert("isAlgarismoSeguinteUltimoMaiorCinco: " + isAlgarismoSeguinteUltimoMaiorCinco);
//            alert("isAlgarismoSeguinteUltimoIgualCinco: " + isAlgarismoSeguinteUltimoIgualCinco);
//            alert("isRestoDecimalMaiorZero: " + isRestoDecimalMaiorZero);
//            alert("isAlgarismoUltimoImpar: " + isAlgarismoUltimoImpar);

    return parseFloat(retornoS.toString());
}

function drawszlider(ossz, meik) {
    var szazalek = Math.round((meik * 100) / ossz);
    document.getElementById("szliderbar").style.width = szazalek + '%';
    document.getElementById("szazalek").innerHTML = szazalek + '%';

    if (szazalek < 100) {
        setTimeout("drawszlider(120," + (meik + 1) + " )", 500);
    }
}

function addProgressBar(janela) {
    try {
        if (janela != null && janela != undefined) {
            var teste = "<div id=\"szlider\" > <div id=\"szliderbar\" align='center'></div><div id=\"szazalek\"> </div></div>";
            var script = "<script language=\"JavaScript\"  src=\"script/funcoes_gweb.js\" type=\"text/javascript\"></script>";
            var script2 = "<script language=\"JavaScript\" type=\"text/javascript\">"
                    + "setTimeout(\"drawszlider(100, 1);\",50);"
                    + "</script>";
            var estilo = "<link href=\"estilo.css\" rel=\"stylesheet\" type=\"text/css\">";
            janela.document.write(script + script2 + estilo + teste);
        } else {
            return false;
        }
    } catch (e) {
        alert(e);
    }

}
function addAguardePop(janela) {
    try {
        if (janela != null && janela != undefined) {
            var div = "<div></div>";
            var script = "<script language=\"JavaScript\"  src=\"script/funcoes_gweb.js\" type=\"text/javascript\"></script>";
            var script2 = "<script language=\"JavaScript\" type=\"text/javascript\">"
                    + "setTimeout(\"espereEnviarPop('Aguarde...', true);\",100);"
                    + "</script>";
            var estilo = "<link href=\"estilo.css\" rel=\"stylesheet\" type=\"text/css\">";
            janela.document.write(script + script2 + estilo + div);
        } else {
            return false;
        }
    } catch (e) {
        alert(e);
    }

}

/**
 * @autor: Gleidson de Freitas Silva
 */
function ThreadGw(action, delay, executar) {
    var _action = null;
    var _delay = null;
    var _instanceThread = null;

    var create = function (action, delay) {
        _action = (action != null && action != undefined ? action : _action);
        _delay = (delay != null && delay != undefined ? delay : _delay);
    }

    this.run = function (action, delay) {
        create(action, delay, false);
        if (_action != null && _delay != null) {
            _instanceThread = window.setTimeout(_action, _delay);
        }
    };
    this.start = function () {
        if (_action != null && _delay != null) {
            _instanceThread = window.setTimeout(_action, _delay);
        }
    };
    this.stop = function () {
        window.clearTimeout(_instanceThread);
    }
    this.restart = function () {
        this.stop();
        this.run();
    }

    create(action, delay);
    if (executar != null && executar != undefined && executar) {
        this.start();
    }
}

function CookieGw(texto) {
    this.nome = (texto != null && texto != undefined ? "" : texto.split("=")[0]);
    this.valor = (texto != null && texto != undefined && texto.split("=").length > 2 ? "" : texto.split("=")[1]);
}

function readOnlyAll(fatherElement, classe) {
    if (fatherElement != null && fatherElement != undefined) {
        for (var i = 0; i <= fatherElement.elements.length; i++) {
            var elemento = fatherElement.elements[i];

            if (elemento != undefined && elemento.name != "") {
                if (elemento.valueOf() == "[object HTMLInputElement]") {
                    if (elemento.type == "button") {
                        desabilitar(elemento, "#2E76A6");
                    } else {
                        readOnly(elemento, classe);
                    }
                } else if (elemento.valueOf() == "[object HTMLSelectElement]") {
                    desabilitar(elemento);
                } else {
                    readOnly(elemento, classe);
                }
            }
        }
    } else {
        alert("Elemento nulo.");
    }


}

function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}
function seLimpoReset(obj_input, valor_reset) {
    if (obj_input.value.trim() == "")
    {
        obj_input.value = valor_reset;
        return true;
    }
}

function copyOption(objOrigem, objDestino, optionPreferencia) {
    var strOptions = "";
    var valorAnterior = "";
    if (objOrigem != null && objOrigem != undefined && objDestino != undefined && objDestino != null && objOrigem.options.length > 0) {
        valorAnterior = objDestino.value;
        removeOptionSelected(objDestino.id);
        for (var i = 0, max = objOrigem.options.length; i < max; i++) {
            strOptions += "<option value=" + (objOrigem.options[i]).value + ">";
            strOptions += (objOrigem.options[i]).innerHTML;
            strOptions += "</option>";
        }
        objDestino.innerHTML = strOptions;
    }
    if (optionPreferencia!= undefined && optionPreferencia!= null && optionPreferencia != "" && optionPreferencia != 0 && isExisteOption(objDestino, optionPreferencia)) {
        objDestino.value = optionPreferencia;
    }else if (valorAnterior != "" && isExisteOption(objDestino, valorAnterior)) {
        objDestino.value = valorAnterior;
    }
}

function tipoPesoTelaTabela(tipo) {
    if (tipo == "p") {
        $('tipoPeso').checked = true;
        $('tipoFaixa').checked = false;
        $('valor_peso').disabled = false;
        $('precoTonelada').disabled = false;
        setReadOnlyFaixa(true);
        readOnly($("valor_excedente"));
        setReadOnlyFaixaAereo(true);
        readOnly($("valor_excedente_aereo"));

    } else {
        $('tipoPeso').checked = false;
        $('tipoFaixa').checked = true;
        $('valor_peso').disabled = true;
        $('precoTonelada').disabled = true;
        setReadOnlyFaixa(false);
        notReadOnly($("valor_excedente"));
        setReadOnlyFaixaAereo(false);
        notReadOnly($("valor_excedente_aereo"));
    }
}

function abrirLoginSupervisor(permitirLancamentoOSAbertoVeiculo, tipoAutorizacao, idCidadeOrigem, idCidadeDestino) {
    if ($("os_aberto_veiculo").value == "true" || $("os_aberto_veiculo").value == "t" || $("os_aberto_veiculo").value == true) {

        if (permitirLancamentoOSAbertoVeiculo == 'NP') {
            if (tipoAutorizacao == 0) {
                setTimeout(function () {
                    alert("ATENÇÃO: Existe OS em aberto para esse Veículo " + $("veiculo").value + ", por esse motivo não é possível adiciona-lo. \n Para alterar a permissão, vá em : Configurações -> Alterar configurações!");
                    $("idveiculo").value = "0";
                    $("veiculo").value = "";
                }, 100);
            } else if (tipoAutorizacao == 1 || tipoAutorizacao == 2 || tipoAutorizacao == 3 || tipoAutorizacao == 4 || tipoAutorizacao == 5) {
                setTimeout(function () {
                    alert("ATENÇÃO: Existe OS em aberto para esse Veículo " + $("vei_placa").value + ", por esse motivo não é possível adiciona-lo. \n Para alterar a permissão, vá em : Configurações -> Alterar configurações!");
                    $("idveiculo").value = "0";
                    $("vei_placa").value = "";
                }, 100);

            }
        } else if (permitirLancamentoOSAbertoVeiculo == 'PS') {
            var dataAtual = new Date();
            var miliSegundos = dataAtual.getMilliseconds();
            $("miliSegundos").value = miliSegundos;

            if (tipoAutorizacao == 1 || tipoAutorizacao == 4 || tipoAutorizacao == 5) {
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisor&idCidadeOrigem=" + idCidadeOrigem + "&idCidadeDestino=" + idCidadeDestino + "&idVeiculo=" + $("idveiculo").value + "&placaVeiculo=" + $("vei_placa").value + "&tipoAutorizacao=" + tipoAutorizacao + "&miliSegundos=" + miliSegundos, 'Supervisor', 'top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            } else if (tipoAutorizacao == 3) {
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisor&idCidadeOrigem=" + idCidadeOrigem + "&idVeiculo=" + $("idveiculo").value + "&placaVeiculo=" + $("vei_placa").value + "&tipoAutorizacao=" + tipoAutorizacao + "&miliSegundos=" + miliSegundos, 'Supervisor', 'top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            } else if (tipoAutorizacao == 2) {
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisorContratoFrete&idmotorista=" + $("idmotorista").value + "&idveiculo=" + $("idveiculo").value + "&placaVeiculo=" + $("vei_placa").value + "&tipoAutorizacao=" + tipoAutorizacao + "&miliSegundos=" + miliSegundos, 'Supervisor', 'top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            } else {
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisor&idVeiculo=" + $("idveiculo").value + "&placaVeiculo=" + $("veiculo").value + "&tipoAutorizacao=" + tipoAutorizacao + "&miliSegundos=" + miliSegundos, 'Supervisor', 'top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            }

        }
    }
}

var valueBefore = null;
function applyChangeHandler() {
    function applyChange(obj) {
        var core = null;
        if (obj.onblur != null && obj.onblur != undefined) {
            var blur = obj.onblur + "";
            var inicio = blur.indexOf("{");
            var fim = blur.lastIndexOf("}");
            core = blur.substr(inicio, fim);
        }
        if (isIE()) {
            obj.onfocus = new Function("setBefore(this);");
            if (core != null) {
                obj.onfocus = new Function("if(valueBefore != this.value){" + core + "}");
            }
        } else {
            obj.setAttribute("onfocus", "setBefore(this);");
            if (core != null) {
                obj.setAttribute("onblur", "if(valueBefore != this.value){" + core + "};");
            }
        }
    }

    //se passar um objeto como argumento entao formate apenas ele
    if (arguments.length > 1) {
        applyChange(arguments[1]);
        return true;
    }

    var elems = elementsByClassName('changeHandler', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyChange(elems[i]);

    var elems = elementsByClassName('changeHandler', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyChange(elems[i]);
}

function setBefore(obj) {
    valueBefore = obj.value;
}
function compareChange(obj) {
    if (valueBefore != obj.value) {
        try {
            if (obj.onChange != null && obj.onChange != undefined) {
//                obj.onChange();
            }
        } catch (e) {
            alert(e);
        }
    }
}

function applyFormatterNumber() {
    function applyNumber(obj) {
        var fixed = 2;
        if ((obj.className.indexOf("decimal2") > -1)) {
            fixed = 2;
        } else if ((obj.className.indexOf("decimal3") > -1)) {
            fixed = 3;
        } else if ((obj.className.indexOf("decimal4") > -1)) {
            fixed = 4;
        }

        if (isIE()) {
            obj.onkeydown = new Function("fmtDecimalNumber(this, event," + fixed + ");");
            obj.onkeypress = new Function("fmtDecimalNumber(this, event," + fixed + ");");
            obj.onkeyup = new Function("fmtDecimalNumber(this, event," + fixed + ");");
        } else {
            obj.setAttribute("onkeydown", "fmtDecimalNumber(this, event," + fixed + ");");
            obj.setAttribute("onkeypress", "fmtDecimalNumber(this, event," + fixed + ");");
            obj.setAttribute("onkeyup", "fmtDecimalNumber(this, event," + fixed + ");");
        }
    }

    //se passar um objeto como argumento entao formate apenas ele
    if (arguments.length > 1) {
        applyNumber(arguments[1]);
        return true;
    }

    var elems = elementsByClassName('styleValor', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyNumber(elems[i]);

    var elems = elementsByClassName('styleValor', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        applyNumber(elems[i]);
}

function fmtDecimalNumber(ob, ev, fixed) {
    var tecla = (window.event ? event.keyCode : ev.which);
    fixed = (fixed == null || fixed == undefined ? 2 : fixed);

    var matches = ob.value.toString().match(/[0-9]/g);
    if (matches == null)
        ob.value = "";

    //escapando as teclas shift, del, backspace, left, right E se a data conter algum caractere fora barra ou 0-9.
    if (ev.keyCode == 46 || ev.keyCode == 37 || ev.keyCode == 39 || ev.keyCode == 9 ||
            ev.keyCode == 8 || ev.keyCode == 13 || ev.keyCode == 16 || matches == null)
        return true;

    ob.value = fmtReais(ob.value, fixed);
}
function fmtReais(v, fixed) {
    if (fixed == 0) {
        v = soNumeros(v);
    } else if (fixed == 1) {
        v = v.replace(/\D/g, "");                //Remove tudo o que não é dígito
        v = v.replace(/(\d{1})$/, ",$1");        //Coloca a virgula
        v = v.replace(/(\d+)(\d{3},\d{1})$/g, "$1.$2");     //Coloca o primeiro ponto
    } else if (fixed == 2) {
        v = v.replace(/\D/g, "");                //Remove tudo o que não é dígito
        v = v.replace(/(\d{2})$/, ",$1");        //Coloca a virgula
        v = v.replace(/(\d+)(\d{3},\d{2})$/g, "$1.$2");     //Coloca o primeiro ponto
    } else if (fixed == 3) {
        v = v.replace(/\D/g, "");                //Remove tudo o que não é dígito
        v = v.replace(/(\d{3})$/, ",$1");        //Coloca a virgula
        v = v.replace(/(\d+)(\d{3},\d{3})$/g, "$1.$2");     //Coloca o primeiro ponto        
    } else if (fixed == 4) {
        v = v.replace(/\D/g, "");              //Remove tudo o que não é dígito
        v = v.replace(/(\d{4})$/, ",$1");        //Coloca a virgula
        v = v.replace(/(\d+)(\d{3},\d{4})$/g, "$1.$2");     //Coloca o primeiro ponto
    }

    return v;
}

/**
 * 
 * @param {type} dateBr Data no padrão Brasileiro dd/MM/yyyy
 * @returns {Date} Data no padrão USA
 */
function converterDataUSA(dateBr) {
    var data = dateBr.split('/');
    var novaData = data[1] + "/" + data[0] + "/" + data[2];
    var dataAmericana = new Date(novaData);
    return dataAmericana;
}

/**
 * 
 * @param {type} dataUSA Data no padrão USA MM/dd/yyyy
 * @returns {dataBrasil} Data no padrão BR
 */
function converterDataBR(dataUSA) {
    var dia = dataUSA.getDate();
    var mes = dataUSA.getMonth() + 1;
    var ano = dataUSA.getFullYear();
    if (dia < 10) {
        dia = '0' + dia;
    }
    if (mes < 10) {
        mes = '0' + mes;
    }
    var novaData = dia + "/" + mes + "/" + ano;
    return novaData;
}
/**
 * 
 * @param {type} date Data atual
 * @param {type} days Dias a serem adicionados
 * @returns {addDays.result|Date} Nova data
 */
function addDays(date, days) {
    var result = new Date(date);
    if (days > 0) {
        result.setDate(result.getDate() + days);
    }
    return result;
}

function tratarErro(e) {
    var erro = (e.message
            , '\n', e.filename, ':', e.lineno, (e.colno ? ':' + e.colno : '')
            , e.error && e.error.stack ? '\n' : '', e.error ? e.error.stack : undefined
            );
    return erro;
}