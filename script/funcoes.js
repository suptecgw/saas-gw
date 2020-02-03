/**  
 * PROTÓTIPOS:
 * método String.lpad(int pSize, char pCharPad)
 * método String.trim()
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


/**
 * Adiciona método lpad() à classe String.
 * Preenche a String à esquerda com o caractere fornecido,
 * até que ela atinja o tamanho especificado.
 */
String.prototype.lpad = function(pSize, pCharPad)
{
    var str = this;
    var dif = pSize - str.length;
    var ch = String(pCharPad).charAt(0);
    for (; dif > 0; dif--)
        str = ch + str;
    return (str);
} //String.lpad


/**
 * Adiciona método trim() à classe String.
 * Elimina brancos no início e fim da String.
 */
String.prototype.trim = function()
{
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
} //String.trim


/**
 * Elimina caracteres de formatação e zeros à esquerda da string
 * de número fornecida.
 * @param String pNum
 * 	String de número fornecida para ser desformatada.
 * @return String de número desformatada.
 */
function unformatNumber(pNum)
{
    return String(pNum).replace(/\D/g, "").replace(/^0+/, "");
} //unformatNumber


/**
 * Formata a string fornecida como CNPJ ou CPF, adicionando zeros
 * à esquerda se necessário e caracteres separadores, conforme solicitado.
 * @param String pCpfCnpj
 * 	String fornecida para ser formatada.
 * @param boolean pUseSepar
 * 	Indica se devem ser usados caracteres separadores (. - /).
 * @param boolean pIsCnpj
 * 	Indica se a string fornecida é um CNPJ.
 * 	Caso contrário, é CPF. Default = false (CPF).
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
    }
    else
    {
        reCpf = /(\d{3})(\d{3})(\d{3})(\d{2})$/;
        numero = numero.replace(reCpf, "$1.$2.$3-$4");
    }
    return numero;
} //formatCpfCnpj


/**
 * Calcula os 2 dígitos verificadores para o número-efetivo pEfetivo de
 * CNPJ (12 dígitos) ou CPF (9 dígitos) fornecido. pIsCnpj é booleano e
 * informa se o número-efetivo fornecido é CNPJ (default = false).
 * @param String pEfetivo
 * 	String do número-efetivo (SEM dígitos verificadores) de CNPJ ou CPF.
 * @param boolean pIsCnpj
 * 	Indica se a string fornecida é de um CNPJ.
 * 	Caso contrário, é CPF. Default = false (CPF).
 * @return String com os dois dígitos verificadores.
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

function validarEmail(email) {
    var str = email;
    var filtro = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    if (filtro.test(str)) {
        return true;
    } else {
        return false;
    }
}

/**
 * Testa se a String pCpf fornecida é um CPF válido.
 * Qualquer formatação que não seja algarismos é desconsiderada.
 * @param String pCpf
 * 	String fornecida para ser testada.
 * @return <code>true</code> se a String fornecida for um CPF válido.
 */
function isCpf(pCpf)
{
    var numero = formatCpfCnpj(pCpf, false, false);
    var base = numero.substring(0, numero.length - 2);
    var digitos = dvCpfCnpj(base, false);
    var algUnico, i;

    // Valida dígitos verificadores
    if (numero != base + digitos)
        return false;

    /* Não serão considerados válidos os seguintes CPF:
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
 * Testa se a String pCnpj fornecida é um CNPJ válido.
 * Qualquer formatação que não seja algarismos é desconsiderada.
 * @param String pCnpj
 * 	String fornecida para ser testada.
 * @return <code>true</code> se a String fornecida for um CNPJ válido.
 */
function isCnpj(pCnpj)
{
    var numero = formatCpfCnpj(pCnpj, false, true);
    var base = numero.substring(0, NUM_DGT_CNPJ_BASE);
    var ordem = numero.substring(NUM_DGT_CNPJ_BASE, 12);
    var digitos = dvCpfCnpj(base + ordem, true);
    var algUnico;

    // Valida dígitos verificadores
    if (numero != base + ordem + digitos)
        return false;

    /* Não serão considerados válidos os CNPJ com os seguintes números BÁSICOS:
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

    /* Não será considerado válido CNPJ com número de ORDEM igual a 0000.
     * Não será considerado válido CNPJ com número de ORDEM maior do que 0300
     * e com as três primeiras posições do número BÁSICO com 000 (zeros).
     * Esta crítica não será feita quando o no BÁSICO do CNPJ for igual a 00.000.000.
     */
    if (ordem == "0000")
        return false;
    return (base == "00000000"
            || parseInt(ordem, 10) <= 300 || base.substring(0, 3) != "0000");
} //isCnpj


/**
 * Testa se a String pCpfCnpj fornecida é um CPF ou CNPJ válido.
 * Se a String tiver uma quantidade de dígitos igual ou inferior
 * a 11, valida como CPF. Se for maior que 11, valida como CNPJ.
 * Qualquer formatação que não seja algarismos é desconsiderada.
 * @param String pCpfCnpj
 * 	String fornecida para ser testada.
 * @return <code>true</code> se a String fornecida for um CPF ou CNPJ válido.
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
 * Função criada por Deivid
 * Aceita apenas os digitos referente ao cnpj e números
 */
function digitaCnpj(valor) {
    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;
    else if (!document.all)
        return false

    if (tecla > 47 && tecla < 58) // numeros de 0 a 9
        return true;
    else
    {
        if (tecla != 8 && tecla != 45 && tecla != 46 && tecla != 47 && tecla != 9) // backspace, ".","-"."/"
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
            document.getElementById(campos[i]).onkeypress = function() {
                this.style.background = "#FFFFFF";
            };
        }
    }
    return retorno;
}


function validaData(data) {
    barras = data.split("/");

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

function digitaValores() {
    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;
    if (tecla > 47 && tecla < 58) // numeros de 0 a 9
        return true;
    else
    {
        if (tecla == 44 || tecla == 46) // Teclas igual a vírgula ou ponto
            event.keyCode = 44;
        else
            event.keyCode = 0;
    }
}

function digitaNumeros() {
    if (document.all) // Internet Explorer
        var tecla = event.keyCode;
    else if (document.layers) // Nestcape
        var tecla = e.which;
    if (tecla > 47 && tecla < 58) // numeros de 0 a 9
        event.keyCode = tecla;
    else
    {
        event.keyCode = 0;
    }
}

/**Funcao q requisita um "post" dinamicamente atraves de um popup
 carregado com os paramentros informados.
 Uso: -O param "chaves_valores" eh uma string carregada com os nomes e
 valores dos parametros. Ex.: 'nome_input=valor&nome_input2=valor2'.
 
 -O param "action_post" eh o action do form usaddo para a requisicao.
 *ATENÇÃO: TOTALMENTE EM DESUSO (SE VC ENCONTRAR ESTE METODO ALTERE IMEDIATAMENTE PARA POST)
 *Deprected
 */
function requisitaPost(chaves_valores, action_post)
{
    var popup = null;
    popup = window.open('./menu', 'registro', 'titlebar=1,menubar=0,scrollbars=0,status=1,resizable=0,height=167,width=170,top=50,left=50');
    popup.document.open("text/html", "replace");
    popup.document.writeln('<script>'
            + 'function envia(){document.getElementById("frm").submit();}</script>'
            + '<html><head><title>Aguarde executando...</title>' +
            '</head><body><br><b>Executando..' +
            '</b><br><br><img src="./img/espere.gif">');
    popup.document.writeln('<form name="frm" id="frm" method="post" action="' + action_post + '">');
    for (i = 0; i < chaves_valores.split("&").length; ++i)
        popup.document.writeln('<input name="' + chaves_valores.split("&")[i].split('=')[0] +
                '" type="hidden" id="' + chaves_valores.split("&")[i].split('=')[0] +
                '" value="' + chaves_valores.split("&")[i].split('=')[1] + '">');
    popup.document.writeln('</form></body></html>');
    popup.document.close();
    popup.envia();
}

/**Cria um popup com um objeto form passado como parametro, depois 
 executa o metodo submit do form criado.
 submitPopupForm(form_obj)
 */
function submitPopupForm(form_obj) {
    var funcaosubmit = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"><script>' +
            'function submitform(){ document.forms[0].submit(); }</script></head><body>';
    var popup = window.open('about:blank', 'popup', 'titlebar=1,menubar=0,scrollbars=0,status=1,resizable=1,height=167,width=170,top=50,left=50');
    popup.document.writeln('<b>Enviando ...</b><br><br><br><br>');
    popup.document.writeln(funcaosubmit);
    if (isIE()) {
        popup.document.writeln('<form action="' + form_obj.action + '" method="POST">' + form_obj.innerHTML + '</form></body></html>');
    } else {
        popup.document.writeln('</body></html>');
        popup.document.body.appendChild(form_obj.cloneNode(true));
    }

    popup.document.close();
    popup.submitform();
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

/**Atribui valor_reset para o input text se o mesmo contiver um valor nao inteiro
 se for Float e tiver decimal ele inclui o '.00'
 @Exemplo - seNaoFloatReset(this, 0) */
function seNaoFloatReset(obj_input, valor_reset)
{    
    /*Se informar um 3º parametro, esse sera considerado boolean
     para inserção ou nao dos zeros a esquerda. Padrao true*/
    var zerosEsquerda = (arguments[2] != null ? arguments[2] : true);
    var vlr = virgulaToPonto((obj_input.value.trim() == "" ? "0" : obj_input.value.trim()));
    obj_input.value = (isNaN(vlr) || parseFloat(vlr) == 0 ?
            valor_reset : (vlr.indexOf('.') < 0 ? vlr + (zerosEsquerda ? '.00' : '') : (vlr)));
}

/**Igual a funçao de cima so que o retorno sao de 3 casas decimais
 @Exemplo - seNaoFloatResetVolume(this, 0) */
function seNaoFloatResetVolume(obj_input, valor_reset)
{    
    /*Se informar um 3º parametro, esse sera considerado boolean
     para inserção ou nao dos zeros a esquerda. Padrao true*/
    var zerosEsquerda = (arguments[2] != null ? arguments[2] : true);
    var vlr = virgulaToPonto((obj_input.value.trim() == "" ? "0" : obj_input.value.trim()));
    obj_input.value = (isNaN(vlr) || parseFloat(vlr) == 0 ?
            valor_reset : (vlr.indexOf('.') < 0 ? vlr + (zerosEsquerda ? '.00' : '') : (vlr)));
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


//formata um valor Float  1000.00
function formatoMoedaVolume(_num) {
    _num = _num.toString().replace(/\$|\,/g, '');
    if (isNaN(_num))
        _num = "0";
    var sign = (_num == (_num = Math.abs(_num)));
    _num = Math.floor(_num * 1000 + 0.50000000001);
    var cents = _num % 1000;
    _num = Math.floor(_num / 1000).toString();
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

function colocarVirgula(number, fixed) {

    if (fixed == undefined) {
        fixed = '2';
    }
    number = String(parseFloat(number).toFixed(fixed)).replace(/\./, ',');
    return number;
}

function colocarPonto(number) {
    number = number.replace(/\./, '');
    number = number.replace(/\,/, '.');
    return number;

}

//substitui , por .
function virgulaToPonto(valor) {
    var retorno = valor;
    while (retorno.indexOf(',') > - 1)
        retorno = retorno.replace(',', '.');

    return retorno;
}

/* 
 Autor: KLenneth F. Reis
 Descricao: faz uma requisicao usando a técnica "Ajax".
 Parametros: <acao(url)>, <objeto funcao para a implementacao
 do evento "onReadyStateChange">
 */
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

/*autor: Kenneth F. Reis
 comentario: Exibe uma mensagem de espera com um gif animado.
 parametros: "msg"[String]:  breve texto q será exibido na mensagem. 
 Valor padrao: 'Aguarde...'
 "mostra"[boolean]: oculta/exibe a mensagem.
 */
function espereEnviar(msg, mostra) {
    d = document;
    //se nao existe a layer no documento[primeira vez que o método eh chamado no documento]
    if (d.getElementById("layer_espere") == null)
        if (mostra) {
            var layer = document.createElement("LABEL");
            layer.id = "layer_espere";
            layer.style.position = "absolute";
            layer.style.backgroundColor = "#FFFFFF";
            layer.style.width = "220px";
            layer.style.height = "140px";
            layer.style.zIndex = "1";
            layer.style.left = "50%";
            layer.style.top = "50%";
            layer.style.margin="-50px";
            layer.style.margin="-50px";

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


/** 
 *injecao de javascript em pop-up 
 *@author Vladson Pontes
 */

/**
 *injecao de javascript em pop-up --
 *captura o fechamento da janela pop e dispara um ajax para fechamento de atributo de sessao  (o mesmo controla a vida da conex?o *que utiliza)
 *@author Vladson Pontes
 */
function bloquearFechamentoPop(pop, url) {





    pop.document.write("<html>");
    pop.document.write("<head></head>");
    pop.document.write("<body onload='init()'>");

    pop.document.write("<iframe src ='" + url + "' width='100%' height='100%'>");
    pop.document.write("</iframe>");


    pop.document.write("</body>");
    pop.document.write("</html>");

    pop.document.write("<script language='JavaScript'  src='script/jquery.js' type='text/javascript'></script>");
    pop.document.write("<script language='JavaScript'  src='script/shortcut.js' type='text/javascript'></script>");
    pop.document.write("<script language='JavaScript'  src='script/prototype.js' type='text/javascript'></script>");

    pop.document.write("<script type='text/javascript'>");

    pop.document.write("jQuery.noConflict();");

    pop.document.write("var bClose = false;");
    pop.document.write("function confirma_sair(e){");
    pop.document.write("if (!bClose)");
    pop.document.write("ajaxConexao()");
    pop.document.write("}");




    pop.document.write("");
    pop.document.write("function ajaxConexao(){");
    // pop.document.write("new Ajax.Request('./ExporterReports?acao=derrubarSessionConexao', { method:'get' });");
    pop.document.write("}");
    pop.document.write("");

    pop.document.write("function init(){");
    pop.document.write("window.onbeforeunload = confirma_sair;");
    pop.document.write("}");

    pop.document.write("jQuery(document).ready(function(){");
    pop.document.write("jQuery('a').click(function()");
    pop.document.write("{");
    pop.document.write("jQuery('body').removeAttr('onbeforeunload','');");
    pop.document.write("});");
    pop.document.write("});");

    pop.document.write("shortcut.add('F5', function()");
    pop.document.write("{");
    pop.document.write("jQuery('body').removeAttr('onbeforeunload','');");
    pop.document.write("history.go(0);");
    pop.document.write("return false;");
    pop.document.write("});");

    pop.document.write("init()");

    pop.document.write("</script>");

}


/*Kenneth F. Reis
 10-3-2006
 Cria um popup com a url e o id especificado, tb redimensiona o popup com o tamanho da tela. */
function launchPDF(url, idname) {
    tryRequestToServer(function() {
        var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
        var pdf = window.open("redireciona_relatorio.jsp?url=" + encodeURIComponent(url), idname, cf);
        //bloquearFechamentoPop(pdf, url);
        pdf.window.resizeTo(screen.width, screen.height - 20);
        pdf.focus();
    }
    );
}

/*Kenneth F. Reis
 10-3-2006
 Lança um popup com a url e o id da janela informado. */
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

function popLocate(idlista, nomeJanela, indice, camposAdicionais) {
    camposAdicionais = (camposAdicionais == null || camposAdicionais == undefined ? "" : camposAdicionais);
    indice = (indice == null || indice == undefined ? "" : indice);
    popupLocate = launchPopupLocate("./localiza?acao=consultar&suffix=" + indice + "&idlista=" + idlista + "&" + camposAdicionais, nomeJanela + indice);
}
/** 
 Concatena [input_id]"="[input_value]"&"[input_id]"="[inp...
 @ids - String com os ids dos elementos separados por virgula. 
 Sabendo-se que os mesmos devem ser nomeados no atributo "id" da tag HTML. 
 @author Kenneth    
 */
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


/*8-4-2006  Kenneth F. Reis
 Bloqueia todas as funcoes do documento atual usando uma cortina preta. */
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
                inBt.onclick = function() {
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

/*10-4-2006  Kenneth F. Reis
 Reconecta o usuario(resgata uma sessao q foi expirada)*/
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
            alert("Status " + codestatus + "\n\nErro ao na tentativa de enviar a requisição de resgate de sessao!");

        document.getElementById("passw").value = "";
        document.getElementById("btOkReconnect").disabled = false;
        return (codestatus == 200);
    }
    $("btOkReconnect").disabled = true;
    /*Bloco de intrucoes da funcao*/
    requisitaAjax("./home?login=" + user + "&senha=" + passwd + "&textmode=1", ev);
}

/*Kenneth F. Reis
 18-4-2006
 Retorna o objeto com o id/name especificado. Abreviacao de document.getElementById(<ID/NAME>).*/
function getObj(idObj) {
    if (document.getElementsByName(idObj)[0] != null)
        document.getElementsByName(idObj)[0].id = idObj;

    return document.getElementById(idObj);
}


/*Deivid wagner
 19-4-2006
 substitui um caracter por outro*/
function apenasPonto(obj_input, esse, por_esse) {
    var retorno = obj_input.value;
    while (retorno.indexOf(esse) > - 1)
        retorno = retorno.replace(esse, por_esse);
    obj_input.value = retorno;
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

function montaData(dtString, numDias, mes)
{
   function i0(numDias) {
        return (("" + numDias).length == 1 ? "0" + numDias : "" + numDias)
    }
    
   
   
    var d_dia = parseFloat(dtString.split("/")[0]);
    //o mes começa de 0, entao -1 para fazer os calculos
    var d_mes = parseFloat(dtString.split("/")[1]) - 1;
    var d_ano = parseFloat(dtString.split("/")[2]);
    
    if(mes=='a'){
        
        return       i0(numDias) +
            // ATENCAO! O mes começa de 0, entao somamos +1 depois dos calculos com data
            "/" + i0(d_mes + 1) +
            "/" + d_ano;
    }else{
        if((i0(d_mes + 1))==12){
            d_mes =-1;          
            d_ano = d_ano+1;
        }
        return       i0(numDias) +
            // ATENCAO! O mes começa de 0, entao somamos +1 depois dos calculos com data
            "/" + i0(d_mes + 2) +
            "/" + d_ano;
    }    
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

/*Kenneth F. Reis
 15-5-2006
 Retorna a data atual do cliente(dd/MM/yyyy)*/
function now() {
    function i0(num) {
        return (("" + num).length == 1 ? "0" + num : "" + num)
    }

    var hoje = new Date();
    return i0(hoje.getDate()) + "/" + i0(hoje.getMonth() + 1) + "/" + hoje.getFullYear();
}

/**16-5-2006
 Cria um objeto HTML com a tag especificada setando atributos(usando um array nome=valor).
 Ex.: makeElement("INPUT", "type=TEXT&value=234") */
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

/*Kenneth F. Reis
 16-5-2006
 Destrói os elementos com o id=(prefixo + (initNum ate quando nulo) */
function removeElementsByPrefix(prefix, initNum) {
    while ($(prefix + initNum) != null) {
        Element.remove($(prefix + initNum));
        ++initNum;
    }
}


/*Kenneth F. Reis
 17-5-2006
 Retorna se o browser eh o IE.*/
function isIE() {
    return (navigator.appName == "Microsoft Internet Explorer");
}

/**Kenneth F. Reis
 17-5-2006
 Acrescenta o objeto filho no pai e retorna o pai*/
function appendObj(objPai, objFilho) {
    objPai.appendChild(objFilho);
    return objPai;
}

/**Kenneth F. Reis
 17-5-2006
 O mesmo que "makeElement()", e depois adiciona o elemetno em uma tag TD.*/
function makeWithTD(tagName, arrayPropertys) {
    return appendObj(makeElement("TD", ""), makeElement(tagName, arrayPropertys));
}


/*Limpa o atributo value dos objs com id especificado separados por virgula.
 Ex: clean("idhist,descHist");*/
function clean(ids) {
    for (i = 0; i < ids.split(",").length; ++i) {
        var idname = ids.split(",")[i];
        if (getObj(idname) == null) {
            alert("clean()\n\nO objeto com o id \"" + idname + "\" não existe no escopo HTML!");
            return null;
        } else
            getObj(idname).value = "";
    }
}

/**Mostra ou esconde um objeto no escopo HTML usando a propriedade css "display".
 exemplo:
 - hide(objID, flagHide)*/
function hide(objID, flagHide) {
    getObj(objID).style.display = (flagHide ? "none" : "");
}

/*Retorna o obj com ID especificado */
function $(idobj) {
    return document.getElementById(idobj);
}

/*Retorna o VALUE do obj com ID especificado */
function $v(idobj) {
    return document.getElementById(idobj).value;
}

/*Faz a atribuicao de campos de um documento com um objeto JSON*/
function proc_result_set(update_hash, doc) {
    for (var i in update_hash) {
        var elem = doc.$(i);

        if (elem != null)
            if (elem.tagName != "INPUT" && elem.tagName != "SELECT") {
                elem.innerHTML = update_hash[i];
            } else
                elem.value = update_hash[i];

    }

}
/**tagSelect(attributes, options)*/
function tagSelect(attributes, options) {

    var _tagselect = Builder.node('SELECT', attributes, options);
    _tagselect.value = attributes.value;

    return _tagselect;
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
//zz
    //se contem caracteres inval
    if (containsInvalidChar || tecla == 47) {
        var _n = matches.join("");
        ob.value = _n.substr(0, 2) + (_n.length >= 2 ? "/" : "") + _n.substr(2, 2) + (_n.length >= 4 ? "/" : "") + _n.substr(4, 4);
    }
}

function applyFormatter() {

    function apply(obj) {
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

    //se passar um objeto como argumento entao formate apenas ele
    if (arguments.length > 1) {
        apply(arguments[1]);
        return true;
    }

    var elems = elementsByClassName('fieldDate', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        apply(elems[i]);

    elems = elementsByClassName('fieldDateMin', 'input', arguments[0] || document);
    for (i = 0; i < elems.length; ++i)
        apply(elems[i]);
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

/**@ob
 objeto para validacao
 @no_alert_if_blank
 (opcional) Se true, não valida a data caso esteja em branco */
function alertInvalidDate(ob,isValidar)
{
    var no_alert_if_blank = (arguments.length > 1 && arguments[1] == true);
    var dataAtual = new Date();
    var mesAtual = dataAtual.getMonth()+1;
    if (mesAtual < 10){
        mesAtual = '0' + mesAtual;
    }
    var anoAtual = dataAtual.getFullYear();
    
    if (no_alert_if_blank && ob.value == "")
        return true;

    //Completando a data se baseando apenas pelo dia    
    if (ob.value.length == 2){
        ob.value = ob.value.substr(0, 2) + "/"+ mesAtual + "/" + anoAtual;
    }
    if (ob.value.length == 3 || ob.value.length == 4){
        ob.value = ob.value.substr(0, 3) + mesAtual + "/" + anoAtual;
    }
    
    //Completando a data se baseando apenas pelo dia/mes    
    if (ob.value.length == 5){
        ob.value = ob.value.substr(0, 5) + "/" + anoAtual;
    }
    if (ob.value.length == 6 || ob.value.length == 7){
        ob.value = ob.value.substr(0, 6) + anoAtual;
    }
    
    //Completando a data com o ano
    if (ob.value.length == 8){
        ob.value = ob.value.substr(0, 6) + "20" + ob.value.substr(6, 2);
    }
    
    if (isValidar == "false") {
    }else
    if (!validaData(ob.value))
    {
        // esses caracteres \u00e9 é para colocar acento é e esse \u00e1 acento no á
        alert('A data "' + ob.value + '" \u00e9 inv\u00e1lida');

//        ob.focus();
        ob.value = "";
    }

}

function mascaraHora(hora) {

    hora.maxLength = "5";
    var myhora = '';
    myhora = myhora + hora.value;
    if (myhora.length == 2) {
        myhora = myhora + ':';
        hora.value = myhora;
    }

    if (hora.onblur == undefined) {
        hora.onblur = new Function("verificaHora(this)");
    }
}

function verificaHora(hora) {

    if (hora.value.trim().length == 5) {
        hrs = (hora.value.substring(0, 2));
        min = (hora.value.substring(3, 5));

        situacao = "";
        //verifica se o usuario digitou numeros
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
        // esses caracteres \u00e1 é para colocar acento á
        alert("Hora inv\u00e1lida!");
        hora.value = "";
    }


}

// essa função ja existia no webtrans, por não saber em quais locais ela é usada, preferi
//permanecer com ela no "js", mas ela nao formata o campo
function alertInvalidTime(ob) {
    if (ob.value == "" || ob.value.length != 5) {
        ob.value = "";
    } else {
        var horas = parseFloat(ob.value.substr(0, 1));
        var min = parseFloat(ob.value.substr(3, 5));

        if (hrs != parseInt(hrs) || min != parseInt(min)) {
            // esses caracteres \u00e1 é para colocar acento á
            alert("Hora inv\u00e1lida!");
            ob.value = "";
        }

        if (horas < 0 || horas > 24 || min < 0 || min > 60) {
            // esses caracteres \u00e1 é para colocar acento á
            alert("Hora inv\u00e1lida!");
            ob.value = "";
        }
    }
    return true;
}

function getAnaliseCredito(isAlterando, isBloq, valorCredito, valorFrete, valorFreteOld, isAlterouCliente) {

    var retorno = "";
    if (isAlterando) {
        if ((parseFloat(valorFreteOld) != parseFloat(valorFrete)) || isAlterouCliente) {
            var novoValorCredito = (isAlterouCliente ? parseFloat(valorCredito) : parseFloat(valorCredito) + parseFloat(valorFreteOld));
            if (parseFloat(novoValorCredito) < parseFloat(valorFrete)) {
                retorno = "Limite de crédito do cliente excedido.";
            }
        }
    } else {
        if ((isBloq == 't' || isBloq == 'true' || isBloq == true)) {
            retorno = "Crédito do cliente bloqueado.";
        } else {
            if (parseFloat(valorCredito) < parseFloat(valorFrete)) {
                retorno = "Limite de crédito do cliente excedido.";
            }
        }
    }

    return retorno;

}


// javascript não possui replaceall
function replaceAll(string, token, newtoken) {
    while (string.indexOf(token) != -1) {
        string = string.replace(token, newtoken);
    }
    return string;
}
// fecha a janela
function fechar() {
    window.close();
}
// da um alert na tela retornando o false
function alertMsg(msgText) {
    alert(msgText);
    return false;
}

/**
 * torna o elemento visivel
 */
function visivel(elemento) {
    if (elemento != null) {
        elemento.style.display = "";
    } else {
        alert("Elemento " + elemento + " não encontrado.")
    }
}
/**
 * torna o elemento invisivel
 */
function invisivel(elemento) {
    if (elemento != null) {
        elemento.style.display = "none";
    } else {
        alert("Elemento " + elemento + " não encontrado.")
    }
}
/**
 *
 */
function habilitar(elemento) {
    if (elemento != null) {
        elemento.disabled = false;
    } else {
        alert("Elemento nulo.")
    }
}
/**
 * Deixa o campo readOnly e a muda a classe
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
 *
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
 *
 */
function desabilitar(elemento) {
    if (elemento != null) {
        elemento.disabled = true;
    } else {
        alert("Elemento nulo.")
    }
}

/*Formatação de data que vem do JSON*/
function formatDateJSON(objeto) {
    var dataBR = "";
    var data = "";

    if (objeto != undefined) {
        data = objeto.$;
        if (data != undefined) {
            var dia = data.split("-")[2];
            var mes = data.split("-")[1];
            var ano = data.split("-")[0];


            dataBR = dia + "/" + mes + "/" + ano;
        }
    }

    return dataBR;
}

/**
 * Desabilita todos os elementos contidos no elemento passado como parametro
 */
function desabledAllElement(fatherElement) {

    if (fatherElement != null && fatherElement != undefined) {
        for (var i = 0; i <= fatherElement.elements.length; i++) {
            var elemento = fatherElement.elements[i];

            if (elemento != undefined && elemento.name != "") {
                desabilitar(elemento);
            }
        }
    } else {
        alert("Elemento nulo.");
    }
}

function readOnlyAll(fatherElement, classe) {
    if (fatherElement != null && fatherElement != undefined) {
        for (var i = 0; i <= fatherElement.elements.length; i++) {
            var elemento = fatherElement.elements[i];

            if (elemento != undefined && elemento.name != "") {
                readOnly(elemento, classe);
            }
        }
    } else {
        alert("Elemento nulo.");
    }
}

function showErro(texto) {
    var retorno = true;
    var campo = null;
    if (texto != null && texto != undefined && texto.trim() != "") {

        if (arguments.length > 1) {
            for (var i = 1; i < arguments.length; i++) {
                campo = arguments[i];
                
                console.log("campo"+campo);
                
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

function mascaraCompetencia(competencia) {
    var no_alert_if_blank = (arguments.length > 1 && arguments[1] == true)
    var mes = (competencia.value.substring(0, 2));
    var ano = (competencia.value.substring(3, 7));
    var ponto = '';

    competencia.maxLength = "7";
    if (mes.length == 2) {
        ponto = "/";
    }
    competencia.value = mes + ponto + ano;

    if (!no_alert_if_blank && competencia.onblur == undefined) {
        competencia.onblur = new Function("verificaCompetencia(this)");
    }
}

function verificaCompetencia(competencia) {
    if (competencia.value.trim().length == 7) {
        mes = (competencia.value.substring(0, 2));
        ano = (competencia.value.substring(3, 7));

        situacao = "";
        if (mes != parseFloat(mes) || ano != parseFloat(ano)) {
            situacao = "falsa"
        }
        // verifica data e hora
        if ((mes < 01) || (mes > 12)) {
            situacao = "falsa";
        }

        if (competencia.value == "") {
            situacao = "falsa";
        }

        if (situacao == "falsa") {
            alert("Competência inválida!");
            competencia.value = "";
        }
    } else {
        alert("Competência inválida!");
        competencia.value = "";
    }
}

function setEnv(idBotao) {
    idBotao = (idBotao == null ? "botSalvar" : idBotao);
    var botao = document.getElementById(idBotao);
    botao.disabled = true;
    botao.value = "Enviando...";
}

function Option(valor, descricao) {
    this.valor = valor;
    this.descricao = descricao;
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
/**
 * Remove todos os opiton's do select
 */
function removeOptionSelected(id) {
    var elSel = $(id);

    for (var i = elSel.length - 1; i >= 0; i--) {
        elSel.remove(i);
    }
}

/**
 * Recebe o objeto <select>
 * Retorna o valor string do <option> que se encontra 'selected'
 */
function getTextSelect(elemento) {
    return elemento.options[elemento.selectedIndex].innerHTML;
}


function arredondar(x, n) {
    n = (n == undefined || n == null ? 2 : n);
    if (n < 0 || n > 10)
        return x;
    var pow10 = Math.pow(10, n);
    var y = x * pow10;
    return Math.round(y) / pow10;
}
/*
 * Início de eDate
 */
var eDate = {
    units: {
        minute: 60000,
        hour: 3600000,
        day: 86400000
    },
    clone: function(date) {
        return new Date(date);
    },
    getInput: function(i) {
        var s;
        if (i['dd/mm/yyyy']) {
            s = i['dd/mm/yyyy'].split('/');
            i.day = s[0];
            i.month = s[1];
            i.year = s[2];
        }
        if (i['mm/dd/yyyy']) {
            s = i['mm/dd/yyyy'].split('/');
            i.month = s[0];
            i.day = s[1];
            i.year = s[2];
        }
        if (i['yyyy/mm/dd']) {
            s = i['mm/dd/yyyy'].split('/');
            i.year = s[0];
            i.month = s[1];
            i.day = s[2];
        }
        return {
            day: parseInt(i.day, 10),
            month: parseInt(i.month, 10) - 1,
            year: parseInt(i.year, 10)
        };
    },
    isValid: function(i) {
        var index, fi = this.getInput(i);
        for (index in fi) {
            if (isNaN(fi[index])) {
                return false;
            }
        }
        var
                testDate = new Date(fi.year, fi.month, fi.day),
                testDateString =
                testDate.getFullYear().toString() +
                testDate.getMonth().toString() +
                testDate.getDate().toString(),
                inputString =
                fi.year.toString() +
                fi.month.toString() +
                fi.day.toString();

        return (testDateString === inputString);
    },
    getNew: function(i) {
        var fi = this.getInput(i);
        return new Date(fi.year, fi.month, fi.day);
    },
    zeroDay: function(date) {
        date.setHours(0);
        date.setMinutes(0);
        date.setSeconds(0);
        date.setMilliseconds(0);
        return date;
   },
    getToday: function() {
        return this.zeroDay(new Date());
    },
    add: function(i) {
        i.date.setTime(
                i.date.getTime() +
                (parseInt(i.value, 10) *
                        this.units[i.unit])
                );
    },
    addDays: function(date, value) {
        this.add({
            'date': date,
            'unit': 'day',
            'value': value
        });
    },
    diffDays: function(date1, date2) {
        var
                cdate1 = this.zeroDay(this.clone(date1)),
                cdate2 = this.zeroDay(this.clone(date2)),
                diff = cdate1.getTime() - cdate2.getTime();
        if (diff === 0) {
            return 0;
        }
        return Math.round(diff / this.units.day);
    },
    isOverAge: function(date, age) {
        c = this.getToday();
        c.setDate(date.getDate());
        c.setMonth(date.getMonth());
        c.setFullYear(date.getFullYear() + age);
        if (this.getToday().getTime() < c.getTime()) {
            return false;
        }
        return true;
    },compare: function(date1, date2) {
        var
                cdate1 = this.zeroDay(this.clone(date1)),
                cdate2 = this.zeroDay(this.clone(date2)),
                diff = cdate1.getTime() - cdate2.getTime();
                var nova_data1 = parseInt(date1.split("/")[2].toString() + date1.split("/")[1].toString() + date1.split("/")[0].toString());
                var nova_data2 = parseInt(date2.split("/")[2].toString() + date2.split("/")[1].toString() + date2.split("/")[0].toString());
                var diferenca = nova_data1-nova_data2;
                
        return diferenca;
    }

};

/*
 * Fim de eDate
 */
function isVisivel(elemento, isAlert) {
    if (isNull(elemento, isAlert)) {
        return elemento.style.display == "";
    }
    return false;
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

function povoarSelect(elemento, lista) {
    var optLayout = null;
    if (lista != null) {
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

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds) {
            break;
        }
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

function abrirMax(url, target) {
    janela = window.open(url, target, 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
    janela.window.resizeTo(screen.width, screen.height - 50);
    janela.focus();
}

/**
 *
 * @param valor
 * @param casasDecimais
 * @return Esta norma tem por fim estabelecer as regras de arredondamento na
 * Numeração Decimal.
 *
 * 2. REGRAS DE ARREDONDAMENTO
 *
 * 2.1 Quando o algarismo imediatamente seguinte ao último algarismo a ser
 * conservado for inferior a 5, o último algarismo a ser conservado
 * permanecerá sem modificação.
 *
 * Exemplo:
 *
 * 1,333 3 arredondado à primeira decimal tornar-se-á 1,3.
 *
 * 2.2 Quando o algarismo imediatamente seguinte ao último algarismo a ser
 * conservado for superior a 5, ou, sendo 5, for seguido de no mínimo um
 * algarismo diferente de zero, o último algarismo a ser conservado deverá
 * ser aumentado de uma unidade.
 *
 * Exemplo:
 *
 * 1,666 6 arredondado à primeira decimal tornar-se-á: 1,7. 4,850 5
 * arredondados à primeira decimal tornar-se-ão : 4,9.
 *
 * 2.3 Quando o algarismo imediatamente seguinte ao último algarismo a ser
 * conservado for 5 seguido de zeros, dever-se-á arredondar o algarismo a
 * ser conservado para o algarismo par mais próximo. Conseqüentemente, o
 * último a ser retirado, se for ímpar, aumentará uma unidade.
 *
 * Exemplo:
 *
 * 4,550 0 arredondados à primeira decimal tornar-se-ão: 4,6.
 *
 * 2.4 Quando o algarismo imediatamente seguinte ao último a ser conservado
 * for 5 seguido de zeros, se for par o algarismo a ser conservado, ele
 * permanecerá sem modificação.
 *
 * Exemplo:
 *
 * 4,850 0 arredondados à primeira decimal tornar-se-ão: 4,8.
 */

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
    valor = parseFloat(valor);
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
            decimalMutavelZero = fillZero(decimalMutavel.toString() , digitosDecimalMutavel);
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

/**
 * @autor: Gleidson de Freitas Silva
 */
function ThreadGw(action, delay, executar) {
    var _action = null;
    var _delay = null;
    var _instanceThread = null;

    var create = function(action, delay) {
        _action = (action != null && action != undefined ? action : _action);
        _delay = (delay != null && delay != undefined ? delay : _delay);
    }

    this.run = function(action, delay) {
        create(action, delay, false);
        if (_action != null && _delay != null) {
            _instanceThread = window.setTimeout(_action, _delay);
        }
    };
    this.start = function() {
        if (_action != null && _delay != null) {
            _instanceThread = window.setTimeout(_action, _delay);
        }
    };
    this.stop = function() {
        window.clearTimeout(_instanceThread);
    }
    this.restart = function() {
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


function replaceEncode(texto){
    texto = texto.replace("&#034;" ,'"');
    return texto;
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

function abrirLoginSupervisor(permitirLancamentoOSAbertoVeiculo,tipoAutorizacao,idCidadeOrigem,idCidadeDestino){
    if ($("os_aberto_veiculo").value == "true" || $("os_aberto_veiculo").value == "t" || $("os_aberto_veiculo").value == true) {
        
        if (permitirLancamentoOSAbertoVeiculo == 'NP') {
            if (tipoAutorizacao == 0) {
                setTimeout(function(){
                    alert("ATENÇÃO: Existe OS em aberto para esse Veículo "  + $("veiculo").value + ", por esse motivo não é possível adiciona-lo. \n Para alterar a permissão, vá em : Configurações -> Alterar configurações!");
                    $("idveiculo").value = "0";
                    $("veiculo").value = "";                
                },100);                
            }else if (tipoAutorizacao == 1 || tipoAutorizacao == 2 || tipoAutorizacao == 3 || tipoAutorizacao == 4 || tipoAutorizacao == 5) {
                setTimeout(function(){
                    alert("ATENÇÃO: Existe OS em aberto para esse Veículo "  + $("vei_placa").value + ", por esse motivo não é possível adiciona-lo. \n Para alterar a permissão, vá em : Configurações -> Alterar configurações!");
                    $("idveiculo").value = "0";
                    $("vei_placa").value = "";                
                },100);                
                
            }
        }else if(permitirLancamentoOSAbertoVeiculo == 'PS'){
                var dataAtual = new Date();
                var miliSegundos = dataAtual.getMilliseconds();
                $("miliSegundos").value = miliSegundos;
                
            if (tipoAutorizacao == 1 || tipoAutorizacao == 4 || tipoAutorizacao == 5) {
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisor&idCidadeOrigem="+idCidadeOrigem+"&idCidadeDestino="+idCidadeDestino+"&idVeiculo="+$("idveiculo").value+"&tipoAutorizacao="+tipoAutorizacao+"&miliSegundos="+miliSegundos, 'Supervisor','top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            }else if (tipoAutorizacao == 3) {
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisor&idCidadeOrigem="+idCidadeOrigem+"&idVeiculo="+$("idveiculo").value+"&tipoAutorizacao="+tipoAutorizacao+"&miliSegundos="+miliSegundos, 'Supervisor','top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            }else if (tipoAutorizacao == 2) {                
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisorContratoFrete&idmotorista="+$("idmotorista").value+"&idveiculo="+$("idveiculo").value+"&tipoAutorizacao="+tipoAutorizacao+"&miliSegundos="+miliSegundos,'Supervisor','top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');
            }else{
                window.open("./AutorizacaoControlador?acao=iniciarLoginSupervisor&idVeiculo="+$("idveiculo").value+"&tipoAutorizacao="+tipoAutorizacao+"&miliSegundos="+miliSegundos, 'Supervisor', 'top=80,left=70,height=300,width=300,resizable=yes,status=1,scrollbars=1');                          
            }
            
        }
    }
}
/**
 * 
 * @param {type} dateBr Data no padrão Brasileiro dd/MM/yyyy
 * @returns {Date} Data no padrão USA
 */
function converterDataUSA(dateBr){
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
function converterDataBR(dataUSA){
    var dia = dataUSA.getDate();
    var mes = dataUSA.getMonth()+ 1;
    var ano = dataUSA.getFullYear();
    if(dia<10){
        dia='0'+dia;
    } 
    if(mes<10){
        mes='0'+mes;
    } 
    var novaData = dia + "/" + mes + "/" + ano;
    return novaData;
}

/**
 * Recebe uma data yyyy-MM-dd
 * @param {type} dataBanco
 * @returns {undefined}
 */
function converterDataBancoParaBR(dataBanco){
    if (!dataBanco) {
        return '';
    }
    var dataDividida = dataBanco.split('-');
    return dataDividida[2]+"/"+dataDividida[1]+"/"+dataDividida[0];
}

/**
 * 
 * @param {type} date Data atual
 * @param {type} days Dias a serem adicionados
 * @returns {addDays.result|Date} Nova data
 */
function addDays(date, days) {
    var result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
}

function colocarVirgulaNovo(number, fixed) {
    if (fixed == undefined) {
        fixed = 2;
    } else {
        fixed = parseInt(fixed, 10);
    }
    number = parseFloat(number);
    var newNumber = number.toLocaleString('pt-br', {minimumFractionDigits: fixed, maximumFractionDigits: fixed});
    return newNumber;
}