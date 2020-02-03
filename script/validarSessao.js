function checkSession(metodo, isMenu) {
    function ev(textoresposta, codestatus) {
        if (codestatus == 200) {
                metodo();
            return true;
        } else if (codestatus == 403) {
            block(false);

//            window.open("./login_Novamente.jsp?acao=iniciar","pop", 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0,height=220, width=250');
            if (document.getElementById("divGeral") === null) {

                var divGeral = document.createElement("DIV");
                divGeral.id = "divGeral";
                document.body.appendChild(divGeral);
                var estiloDivGeral = document.getElementById("divGeral").style;
                estiloDivGeral.zIndex = "99999999";
                estiloDivGeral.position = "absolute";
                estiloDivGeral.background = "#fff";
//                estiloDivGeral.border = "1px solid #13385C";
                estiloDivGeral.top = "50%";
                estiloDivGeral.left = "50%";
                estiloDivGeral.width = "400px";
                estiloDivGeral.height = "270px";
                estiloDivGeral.marginLeft = "-200px";
                estiloDivGeral.marginTop = "-100px";
                estiloDivGeral.marginTop = "-100px";
                estiloDivGeral.borderRadius = "5px";
                estiloDivGeral.boxShadow = "0px 2px 3px 0px rgba(0,0,0,0.75)";

                var iframe = document.createElement("IFRAME");
                iframe.src = "./UsuarioControlador?acao=iniciarLogarNovamenteSemPopUp&isMenu=" + (isMenu == null || isMenu == undefined ? false : isMenu);
                iframe.id = "re-login";
                iframe.frameBorder = "0";
                iframe.marginHeight = "0";
                iframe.marginWidth = "0";
                iframe.scrolling = "no";
//                frameborder="0" marginheight="0" marginwidth="0" scrolling="no"
                divGeral.appendChild(iframe);
                var estiloIframe = document.getElementById('re-login');
                estiloIframe.width = '400px';
                estiloIframe.height = '270px';

            } else {
                document.getElementById("divGeral").style.display = "block";
            }



        } else {
            var msg = "";
            console.log("codestatus="+codestatus);
            switch (codestatus) {
                case "12029" :
                    alert("Status: " + codestatus + "\nO servidor parece está desligado!");
                    break;
                case 0 :
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
    var url = './session_test';
//    var url = window.location.origin + '/session_test';
    
    requisitaAjax(url, ev);
}

function isIE() {
    return (navigator.appName == "Microsoft Internet Explorer");
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

function block(fechaCortina) {
    if (document.getElementById("cortina") == null) {
        var layer = document.createElement("LABEL");
        layer.id = "cortina";
        document.body.appendChild(layer);
        var ob = document.getElementById("cortina");
        ob.style.position = "absolute";
        ob.style.width = "100%";
        ob.style.height = "100%";
        ob.style.zIndex = 99999999;
        ob.style.backgroundColor = "#000000";
        ob.style.left = "0";
        ob.style.top = "0";
        ob.style.filter = "alpha(opacity=40)";
        ob.style.opacity = "0.40";
    }

    document.getElementById("cortina").style.display = (fechaCortina ? "none" : "");
}


jQuery(document).ready(function () {

    jQuery(".validarSessao").click(function (event) {
        if (jQuery(this).attr("href") != undefined && jQuery(this).attr("href") !== "") {
            if (jQuery(this).attr("largura") == undefined) {
                jQuery(this).attr("largura", screen.width);
            }
            if (jQuery(this).attr("altura") == undefined) {
                jQuery(this).attr("altura", screen.height);
            }

            var tipoRelatorio = "";
            http://www.mastercard.com/br/black/static/widget_html.html
                    //modelo é o nome do RADIO que será procurado na tela.

                    if (jQuery(this).attr("tipoImpressao") != undefined) {
//                alert("tipo = " + tipoRelatorio)
                jQuery("input:radio[name=" + jQuery(this).attr("tipoImpressao") + "]").each(function () {
//Verifica qual está seleceionado
                    if (jQuery(this).is(':checked'))
                        tipoRelatorio = "&impressao=" + jQuery(this).val();
                });
            }
            var thisAttrId = jQuery(this).attr("id");
            thisAttrId = (thisAttrId != null && thisAttrId != undefined && thisAttrId != '' ? thisAttrId.substring(0, (thisAttrId.indexOf("_"))) : '');
            var thisAttrLargura = jQuery(this).attr("largura");
            var thisAttrAltura = jQuery(this).attr("altura");
            var thisAttrHREF = jQuery(this).attr("href");
            checkSession(function () {
                window.open(thisAttrHREF + tipoRelatorio, (thisAttrId), 'width=' + thisAttrLargura + ',height=' + thisAttrAltura + ",scrollbars=yes" + ",top=0" + ",left=0" + ",resizable=yes");
            }, false);
        }
        return false;
    });

    jQuery(".validarSessaoMenu").click(function (event) {
        if (jQuery(this).attr("href") !== undefined && jQuery(this).attr("href") !== "") {
            if (jQuery(this).attr("largura") == undefined) {
                jQuery(this).attr("largura", screen.width);
            }
            if (jQuery(this).attr("altura") == undefined) {
                jQuery(this).attr("altura", screen.height);
            }

            var tipoRelatorio = "";
            http://www.mastercard.com/br/black/static/widget_html.html
                    //modelo é o nome do RADIO que será procurado na tela.

                    if (jQuery(this).attr("tipoImpressao") != undefined) {
//                alert("tipo = " + tipoRelatorio)
                jQuery("input:radio[name=" + jQuery(this).attr("tipoImpressao") + "]").each(function () {
//Verifica qual está seleceionado
                    if (jQuery(this).is(':checked'))
                        tipoRelatorio = "&impressao=" + jQuery(this).val();
                });
            }
            var thisAttrId = jQuery(this).attr("id");
            var thisAttrLargura = jQuery(this).attr("largura");
            var thisAttrAltura = jQuery(this).attr("altura");
            var thisAttrHREF = jQuery(this).attr("href");
            checkSession(function () {
                var pop = window.open(thisAttrHREF + tipoRelatorio, (thisAttrId.substring(0, (thisAttrId.indexOf("_")))), 'width=' + thisAttrLargura + ',height=' + thisAttrAltura + ",scrollbars=yes" + ",top=0" + ",left=0" + ",resizable=yes");
                if(!pop){chamarAlert('O Pop-up do seu navegador está bloqueado, para abrir está tela é necessário desbloquea-lo.')}
            }, true );
        }
        return false;
    });

});
