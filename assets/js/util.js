//Array para controle de telas modais.
var btnCarregando = "<div style='margin:0 auto;text-align: center; width: 20em;'><button class='btn btn-default  btn-carregando noLoading'></button></div>";
var telas = new Array();

function mudarHtml(div, conteudo) {
    $(div).html(conteudo);
}

function showMsg(msg, titulo, tipo, largura) {
    if (titulo == null || titulo == undefined) {
        titulo = "Mensagem";
    }
    if (tipo == null || tipo == undefined) {
        tipo = 'type-default';
    } else {
        switch (tipo) {
            case "padrao":
                tipo = 'type-default';
                break;
            case "informacao":
                tipo = 'type-info';
                break;
            case "primario":
                tipo = 'type-primary';
                break;
            case "sucesso":
                tipo = 'type-success';
                break;
            case "atencao":
                tipo = 'type-warning';
                break;
            case "erro":
                tipo = 'type-danger';
                break;
            default:
                tipo = 'type-default';
        }
    }
    if (largura == undefined || largura == null) {
        largura = '';
    }
    BootstrapDialog.show({
        title: titulo,
        message: msg,
        type: tipo,
        width: largura,
        draggable: true,
        buttons: [{
                icon: 'glyphicon glyphicon-ok',
                label: 'OK',
                cssClass: 'btn-primary',
                autospin: false,
                action: function (dialogRef) {
                    dialogRef.close();
                }
            }]
    });
}

function showAguarde(titulo) {
    if (titulo == undefined || titulo == null) {
        titulo = "Aguarde...";
    }
    var dialog = new BootstrapDialog({
        title: titulo,
        message: "<div style='margin:0 auto;text-align: center; width: 20em;'><button  class='btn btn-default  btn-carregando'></button></div>",
        draggable: true,
        closable: false,
        type: 'type-primary'
    });
    dialog.realize();
    dialog.open();
    if (telas != undefined && telas != null) {
        telas[telas.length] = dialog;
    }
    return dialog;
}

function showModal(texto, titulo, rodape, largura, antesExibir, antesFechar) {
    var tm = "";
    if (texto == undefined || texto == null) {
        texto = "Mensagem Modal";
    }
    if (titulo == undefined || titulo == null) {
        titulo = "Mensagem";
    }
    if (rodape == undefined || rodape == null) {
        rodape = '';
    }
    if (largura == undefined || largura == null) {
        largura = '';
    }
    if (antesExibir == undefined || antesExibir == null) {
        antesExibir = '';
    }
    if (antesFechar == undefined || antesFechar == null) {
        antesFechar = '';
    }
    tm = new BootstrapDialog({
        title: titulo,
        message: texto,
        width: largura,
        footer: rodape,
        onshow: antesExibir,
        onhide: antesFechar,
        draggable: true,
        closable: false,
        type: 'type-primary'
    });
    tm.realize();
    tm.open();
    if (telas != undefined && telas != null) {
        telas[telas.length] = tm;
    }
    return tm;
}

function limparAlerts() {
    $(" .alert").slideUp("500");
}

function ajaxPost(elementoTela, url, parametros, msgAguarde, idCombo, callbacksCombo, callbacksComplete) {
    limparAlerts();
    var msgPadrao = "<div style='margin:0 auto;text-align: center; width: 20em;'><button class='btn btn-default  btn-carregando noLoading'></button></div>";
//	var msgPadrao= "<div class='carregando text-center '></div>";
    if (msgAguarde == null || msgAguarde == undefined) {
        msgAguarde = msgPadrao;
    }
    if (parametros == null || parametros == undefined) {
        parametros = "";
    }
    if (elementoTela != null && elementoTela != undefined) {
        $(elementoTela).slideUp("1000", function () {
            $(elementoTela).html(msgAguarde);
            $(elementoTela).slideDown("500", function () {
                $.post(url, parametros,
                        function (data) {
                            $(elementoTela).slideUp("500", function () {
                                $(elementoTela).html(data);
                                if (callbacksComplete != null && callbacksComplete != undefined) {
                                    listCallbacks(callbacksComplete);
                                }
                                if ((idCombo != null && idCombo != undefined) && (callbacksCombo != null && callbacksCombo != undefined)) {
                                    setCombo(idCombo, callbacksCombo);
                                }
                                $(elementoTela).slideDown("1000");
                            });
                        });
            });
        });
    }
    function setCombo(idCombo, callbacks) {
        $(idCombo).select2().on("change", function (e) {
            listCallbacks(callbacks);
        });
    }

    function listCallbacks(callbacks) {
        for (var i = 0; i < callbacks.length; i++) {
            callbacks[i]();
        }
    }

}

function mascaraPeso(input) {
    var v = input.value;
    var integer = v.split(',')[0];
    var integer2 = v.split(',')[1];
//    alert(v);
    v = v.replace(/\D/g, "");
    v = v.replace(/^[0]+/, "");
    if (v.length <= 3 || !integer || !integer2) {
        if (v.length === 1)
            v = '0,00' + v;
        if (v.length === 2)
            v = '0,0' + v;
        if (v.length === 3)
            v = '0,' + v;
    }
    v = v.replace(/^(\d{1,})(\d{3})$/, "$1,$2");
    input.value = v;
}

function configurarData() {
    $(".data").mask("99/99/9999");
    $(".data").change(
            function (event) {
                var obj = this;
                var data = obj.value;
                if (data != '') {
                    var dia = data.substring(0, 2);
                    var mes = data.substring(3, 5);
                    var ano = data.substring(6, 10);
                    // Criando um objeto Date usando os valores ano, mes e dia.
                    var novaData = new Date(ano, (mes - 1), dia);
                    var mesmoDia = parseInt(dia, 10) == parseInt(novaData.getDate());
                    var mesmoMes = parseInt(mes, 10) == parseInt(novaData.getMonth()) + 1;
                    var mesmoAno = parseInt(ano) == parseInt(novaData.getFullYear());

                    if (!((mesmoDia) && (mesmoMes) && (mesmoAno))) {
                        showMsg("A Data: <b>" + data + "</b> é inválida!", "Atenção", "primario", null);
                        obj.value = "";
                        $(obj).focus();
                        return false;
                    }
                    return true;
                }
            }

    );

    $('.datepicker').datepicker({
        format: "dd/mm/yyyy",
        autoclose: true,
        todayHighlight: true,
        forceParse: false,
    });
}
//-------------------------------------------------------------- funï¿½ï¿½esde cookies  ------
function setCookie(nome, cookie) {
    var data = new Date();
    data.setTime(data.getTime() + (1000 * 60 * 60 * 24 * 30));
    document.cookie = nome + "=" + cookie + ";expires=" + data.toGMTString();
}

function deleteCookie(nome) {
    var data = new Date();
    data.setTime(data.getTime() - 1);
    document.cookie = nome + "=" + ";expires=" + data.toGMTString();
}

function getCookie(nome) {
    if (document.cookie.length > 0) {
        inicio = document.cookie.indexOf(nome + "=");
        if (inicio != -1) {
            inicio = inicio + nome.length + 1;
            fim = document.cookie.indexOf(";", inicio);
            if (fim == -1)
                fim = document.cookie.length;
            return unescape(document.cookie.substring(inicio, fim));
        }
    }
    return null;
}
//-------------------------------------------------------------------------------------------------------------

function removerEspacos(texto) {
    return texto.replace(/\s*/g, "");
}

function abrirJanela(url, target, percWidth, percHeight, isFocus) {
    isFocus = (isFocus == null || isFocus == undefined ? true : isFocus);
    var janela = window.open(url, target, 'left=' + (screen.width / 4) + ', top=0, height=650, width=800, scrollbars=yes,resizable=yes');
    janela.window.resizeTo(screen.width * (percWidth / 100), screen.height * (percHeight / 100));
    if (isFocus) {
        janela.focus();
    }
    return janela;
}

function isIE() {
    return (navigator.appName == "Microsoft Internet Explorer");
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

function elementsByClassName(strClass) {
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

function alertInvalidDate(ob) {
    var no_alert_if_blank = (arguments.length > 1 && arguments[1] == true)

    var dataAtual = new Date();
    var mesAtual = dataAtual.getMonth() + 1;
    if (mesAtual < 10) {
        mesAtual = '0' + mesAtual;
    }
    var anoAtual = dataAtual.getFullYear();

    if (no_alert_if_blank && ob.value == "")
        return true;

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

        alert('A data "' + ob.value + '" invï¿½lida');
        ob.focus();
        ob.value = "";
    }
    return false;

}

function validaData(data) {
    barras = data.value.split("/");
    if (barras.length == 3) {
        var dia = barras[0];
        var mes = barras[1];
        var ano = barras[2];
        var anoAnt = ano;
        if (ano.length == 2) {
            if (ano >= 50 && ano <= 99)
                ano = "19" + ano;
            else
                ano = "20" + ano;
        }


        //Verificando se o dia e o mï¿½s ï¿½ vï¿½lido
        if ((mes < 1 || mes > 12) || (dia < 1 || dia > 31))
            return false;
        //Verificando se o dia estï¿½ correto para os meses com 30 dias
        else if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia == 31)
            return false;
        //Verificando se o dia foi digitado corretamente para o mï¿½s 02
        else if (mes == 2 && dia > 29)
            return false;
        //Verificando a qtd de dï¿½gitos do ano
        else if (ano.length != 4)
            return false;
        else {
            data.value = dia + "/" + mes + "/" + ano;
            return true;

        }

    } else {
        return false;
    }
}
