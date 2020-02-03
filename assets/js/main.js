$(function() {

	var wWidth = $(window).width();

	//header
	$(window).on('scroll', function() {

		// distancia to scroll em relacao ao topo da página
		var top = $(window).scrollTop();

		var topDefault = 90;

		// pegando a distancia e aplicando na barra de menu
		// para ele seguir a barra de rolagem
		$('.menu-top-sub').css('top', parseInt(topDefault - top));
	})

	// content
	$('.toggle-container').on('click', '.toggle-btn', function(e) {
		$(this).toggleClass('toggle-btn--closed');
		$(e.delegateTarget).find('.toggle-wrapper').slideToggle();
	});


	$('.alertas').on('click', function() {
		$('.group-toggle').slideToggle();
	})

	$('.header-logos-mobile__btn').on('click', function(e){
		e.preventDefault();
		$('.nav-main-mobile').toggleClass('nav-main-mobile--active');
		$('.header-logos').toggleClass('header-logos--active');
	});

	$('.header-nav-tablet').on('click', '.header-nav-tablet__btn', function(e) {
		e.preventDefault();
		$(e.delegateTarget).toggleClass('header-nav-tablet--closed');
	});

	$('.header-mobile-top__btn').on('click', function() {
		$('.header-nav-mobile').toggleClass('header-nav-mobile--closed');
		$('.show-mobile').toggleClass('show-mobile--nav-active');
	});

	$('.util, .content-dicas-internas-footer').on('click', function() {
		$(this).remove()
	});


//SLIDER

	var $slider = $('.slider'),
		$items 	= $slider.find('.slider-wrapper li');

	var pos 	= 0,
		sliderWidth = $('.slider').width(),
		total = $items.length;

  function goTo() {
		$slider.find('.slider-wrapper ul').css('marginLeft', - parseInt(pos * sliderWidth));
		// $slider.find('.slider-wrapper li').text(pos + 1);
  }

  $slider.find('.slider-pagination__btn').on('click', function(e) {
    e.preventDefault();

    if($(this).hasClass('slider-pagination__btn--prev')) {
      pos--;
      if(pos < 0) pos = 0;
    } else {
      pos++;
      if(pos >= total) pos = total -1;
    }

    if(pos >= 0 && pos < total) {
      goTo();
    }

  })

	$(window).on('resize',function(){
		wWidth = this.innerWidth;
		sliderWidth = $('.slider').width();
		$items.width(sliderWidth);
		$slider.find('.slider-wrapper').width(sliderWidth);
	}).trigger('resize');

});

$(document).ready(function() {
	$(".more").click(function(event) {
        if ($(this).attr("data-href") != "") {
        var thisAttrId = jQuery(this).attr("id");
        var thisAttrLargura = jQuery(this).attr("largura");
        var thisAttrAltura = jQuery(this).attr("altura");
        var thisAttrHREF = $(this).attr('data-href');
        
        tryRequestToServer(         function(){
            window.open(thisAttrHREF,(thisAttrId.substring(0,(thisAttrId.indexOf("_")))), 'width='+thisAttrLargura+',height='+thisAttrAltura+",scrollbars=yes" + ",top=0" + ",left=0" + ",resizable=yes");
        });
        }
        return false;
//        location.href = $(this).attr('data-href');
        
        //location.href = 'http://hugocesar.com.br';
	});
        
        jQuery(".openWindow").click(function(event){
//            alert(jQuery(this).attr("id").substring(0,(jQuery(this).attr("id").indexOf("_"))));
//            console.log(jQuery(this).substring(0,(jQuery(this).attr("id").indexOf("_"))));
        if ($(this).attr("href") != "") {
            if ($(this).attr("largura") == undefined) {
                $(this).attr("largura", screen.width);
            }
            if ($(this).attr("altura") == undefined) {
                $(this).attr("altura", screen.height);
            }
            
            var tipoRelatorio = "";http://www.mastercard.com/br/black/static/widget_html.html
            //modelo é o nome do RADIO que será procurado na tela.
            
            if (jQuery(this).attr("tipoImpressao") != undefined) {
//                alert("tipo = " + tipoRelatorio)
                $("input:radio[name="+jQuery(this).attr("tipoImpressao")+"]").each(function() {
                    //Verifica qual está selecionado
                    if ($(this).is(':checked'))
                        tipoRelatorio = "&impressao="+$(this).val();
                });
            }
        var thisAttrId = jQuery(this).attr("id");
        var thisAttrLargura = jQuery(this).attr("largura");
        var thisAttrAltura = jQuery(this).attr("altura");
        var thisAttrHREF = jQuery(this).attr("href");
   tryRequestToServer(         function(){
       window.open(thisAttrHREF + tipoRelatorio,(thisAttrId.substring(0,(thisAttrId.indexOf("_")))), 'width='+thisAttrLargura+',height='+thisAttrAltura+",scrollbars=yes" + ",top=0" + ",left=0" + ",resizable=yes");
   });
        }
           return false;
        });
});

//------------------------ ABAIXO SÃO FUNÇÕES EXPECIFICA PARA VALIDAR SESSÃO E CHAMAR O POP-UP ------------------------ //



/*10-4-2006  Kenneth F. Reis
 Reconecta o usuario(resgata uma sessao q foi expirada)*/
function reconnectUser(user, passwd)
{
    function ev(textoresposta, codestatus) {
        console.log(textoresposta);
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





function CookieGw(texto) {
    this.nome = (texto != null && texto != undefined ? "" : texto.split("=")[0]);
    this.valor = (texto != null && texto != undefined && texto.split("=").length > 2 ? "" : texto.split("=")[1]);
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





/*Kenneth F. Reis
 18-4-2006
 Retorna o objeto com o id/name especificado. Abreviacao de document.getElementById(<ID/NAME>).*/
function getObj(idObj) {
    if (document.getElementsByName(idObj)[0] != null)
        document.getElementsByName(idObj)[0].id = idObj;

    return document.getElementById(idObj);
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





/*Kenneth F. Reis
 17-5-2006
 Retorna se o browser eh o IE.*/
function isIE() {
    return (navigator.appName == "Microsoft Internet Explorer");
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
            window.open("./login_Novamente.jsp?acao=iniciar","pop", 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0,height=220, width=250');
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
