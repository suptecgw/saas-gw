function addValorAlphaInput(a,b,c){a="object"==typeof a?a:jQuery("#"+a);var d=jQuery(jQuery(a).parent("div").find("div")[0]);if(null===b||void 0===b||0==parseInt(b.trim().length))return console.error("Valor nulo ou undefinido n�o pode ser adicionado"),!1;if(null!==b&&void 0!==b){var e=jQuery(a).val();void 0!==jQuery(d).parent().parent().attr("readOnly")?null!=c&&void 0!=c?d.append("<li class='gamma-li-chaves' style='background-color:rgba(182,182,182,0.5);color:rgb(70,70,70);'><a class='gamma-li-chaves-a' onclick='removeChaveComIds(this)'></a><div>"+b+"</div></li>"):d.append("<li class='gamma-li-chaves' style='background-color:rgba(182,182,182,0.5);color:rgb(70,70,70);'><a class='gamma-li-chaves-a' onclick='removeChave(this)'></a><div>"+b+"</div></li>"):null!=c&&void 0!=c?d.append("<li class='gamma-li-chaves' ><a class='gamma-li-chaves-a' onclick='removeChaveComIds(this)'></a><div>"+b+"</div></li>"):d.append("<li class='gamma-li-chaves' ><a class='gamma-li-chaves-a' onclick='removeChave(this)'></a><div>"+b+"</div></li>"),void 0!==e&&""!==e.trim()?b=null!=c&&void 0!=c?e+"!@!"+b+"#@#"+c:e+"!@!"+b:null!=c&&void 0!=c&&(b=b+"#@#"+c),jQuery(a).val(b)}}function removerValorInput(a,b){"string"==typeof a&&(a=jQuery('input[name="'+a+'"]')),b&&("undefined"!=typeof localizarCidade&&"inptCidade"==a.attr("name")&&localizarCidade.recarregarLocalizar(),"undefined"!=typeof localizarGrupoCliente&&"inptGrupoCliente"==a.attr("name")&&localizarGrupoCliente.recarregarLocalizarGrupoCliente(),"undefined"!=typeof localizarVendedorIframe&&"inptVendedor"==a.attr("name")&&localizarVendedorIframe.recarregarLocalizarVendedores(),"undefined"!=typeof localizaSupervisorIframe&&"inptSupervisor"==a.attr("name")&&localizaSupervisorIframe.recarregarLocalizarVendedores());var c=jQuery(jQuery(a).parent("div").find("div")[0]);c.html(""),jQuery(a).val("")}function removeChave(a){var b=jQuery(a).parents(".alpha"),c=jQuery(a).parents(".alpha").find(":hidden");jQuery(a).offsetParent().remove(),jQuery(c).val(valueChaves(b[0]))}function valueChaves(a){for(var b=jQuery(a).find(".gamma-li-chaves"),c="",d=0;d<jQuery(b).length;d++)null!==jQuery(b)[d]&&void 0!==jQuery(b)[d]&&"undefined"!==jQuery(jQuery(b)[d]).find("div").html()&&void 0!==jQuery(jQuery(b)[d]).find("div").html()&&(c+=jQuery(jQuery(b)[d]).find("div").html()+"!@!");return c}function removeChaveComIds(a){for(var c=(jQuery(a).parents(".alpha"),jQuery(a).parents(".alpha").find(":hidden")),d=jQuery(c).val().split("!@!"),e="",f=0;f<d.length;f++)d[f].split("#@#").indexOf(jQuery(a).parent().find("div").html())===-1&&void 0!=d[f]&&""!=d[f]&&(e+=d[f]+"!@!");jQuery(a).offsetParent().remove(),jQuery(c).val(e)}var podeOrdenar=!0,idOrderImg=null,caminhoImgUp=null,caminhoImgDown=null,tdAlvoTopo=null,settings=null,img_order=null,tdAntes=null,tdDepois=null,tabelaInicial=null,$inputHidden=null;!function(a){function c(a,c){var d="";if(null!==c.notDraggableClass&&void 0!==c.notDraggableClass.split(" "))for(var i=0;i<=c.notDraggableClass.split(" ").length;i++)void 0!==c.notDraggableClass.split(" ")[i]&&(d+="."+c.notDraggableClass.split(" ")[i]+" ");jQuery(a).on("mousedown mouseup",function(i){jQuery(a).sortable({helper:"clone",tolerance:"pointer",items:"thead th:not("+d+")",cursor:"move",revert:3,opacity:1,start:function(a,b){b.item.startPos=b.item.index()},placeholder:"td-sortable",axis:"x",stop:function(b,d){for(var f=d.item.startPos+1,g=d.item.context.cellIndex+1,h=jQuery(a).children(),i=0,j=jQuery("."+c.setaOrdemClass);null!==j[i]&&void 0!==j[i];)jQuery(j[i]).attr("ordem",i+1),i++;var k=null,l=null;if(f<g)for(var m=f;m<g;m++){k=h.find("> tr > td:nth-child("+m+")").add(h.find("> tr > th:nth-child("+m+")")),l=h.find("> tr > td:nth-child("+(m+1)+")").add(h.find("> tr > th:nth-child("+(m+1)+")"));for(var n=0;n<k.length;n++)0!==n&&e(k[n],l[n])}else for(var m=f;m>g;m--){k=h.find("> tr > td:nth-child("+m+")").add(h.find("> tr > th:nth-child("+m+")")),l=h.find("> tr > td:nth-child("+(m-1)+")").add(h.find("> tr > th:nth-child("+(m-1)+")"));for(var n=0;n<k.length;n++)0!==n&&e(k[n],l[n])}c.callBackDraggable(d)}}).disableSelection(),b.aumentandoTD?h(a):g(a),f(a,!0),"mouseup"==i.type&&f(a,!1)})}function d(a,c){jQuery("html body").on("mousemove mousedown mouseup",function(d){var e="TH"==d.target.nodeName?d.target:jQuery(d.target).parents("TH")[0];if(null!==c.idImgOrder&&"IMG"==d.target.nodeName&&jQuery(d.target).context.id==c.idImgOrder){var g=jQuery(d.target);jQuery(g).css("cursor","pointer")}"mouseup"===d.type&&"col-resize"===jQuery(a).css("cursor")&&(jQuery(a).css("cursor","default"),b.iniciouAumentar=!1);var h=!1,i=!1;if(null!==e&&void 0!==e&&null!==jQuery(e).context&&void 0!==jQuery(e).context&&null!==jQuery(e).context.attributes&&void 0!==jQuery(e).context.attributes&&null!==jQuery(e).context.attributes.class&&void 0!==jQuery(e).context.attributes.class){var j=jQuery(e).context.attributes.class.value;if(null!==j.split(" ")&&void 0!==j.split(" "))for(var k=0;k<=j.split(" ").length;k++)null!==c.notDraggableClass&&void 0!=c.notDraggableClass.split(" ")&&c.notDraggableClass.split(" ").indexOf(j.split(" ")[k])>=0&&(h=!0)}if(null!==e&&void 0!==e&&null!==jQuery(e).context&&void 0!==jQuery(e).context&&null!==jQuery(e).context.attributes&&void 0!==jQuery(e).context.attributes&&null!==jQuery(e).context.attributes.class&&void 0!==jQuery(e).context.attributes.class){var l=jQuery(e).context.attributes.class.value;if(null!==l.split(" ")&&void 0!==l.split(" "))for(var k=0;k<=l.split(" ").length;k++)null!==c.notResizableClass&&void 0!==c.notResizableClass.split(" ")&&c.notResizableClass.split(" ").indexOf(l.split(" ")[k])>=0&&(i=!0)}if(null!==e&&void 0!==e){var m=jQuery(e).offset(),n=jQuery(e).innerWidth();if(Math.abs(d.pageX-Math.round(m.left+n))<=5||b.iniciouAumentar?i||(jQuery(a).removeAttr("cursor"),jQuery(a).css({cursor:"col-resize"}),f(a,!0),b.aumentandoTD=!0,b.podeOrdenar=!1,podeOrdenar=!1):(jQuery(a).removeAttr("cursor"),jQuery(a).css({cursor:"default"}),f(a,!1),h?b.aumentandoTD=!0:b.aumentandoTD=!1,b.podeOrdenar=!0,podeOrdenar=!0),b.iniciouAumentar){var o=b.alvo,p=d.pageX-b.inicialX;o.width(b.widthInicial+p),jQuery(a).width(b.widthInicialTabela+p)}if("mousedown"===d.type&&"col-resize"===jQuery(e).css("cursor")){b.inicialX=d.pageX,b.alvo=jQuery(e),b.iniciouAumentar=!0,b.widthInicial=jQuery(b.alvo).width(),b.widthInicialTabela=jQuery(a).width();for(var q=jQuery(a).children("thead").find("th"),k=0;null!=q[k];){var r=jQuery(b.alvo).context.cellIndex,s=jQuery(q[k]).context.cellIndex;if(r!==s){var t=jQuery(q[k]).width();jQuery(q[k]).css("width",t),jQuery(q[k]).css("min-width",t)}k++}jQuery(b.alvo).css("min-width","30px")}if("mousemove"===d.type&&"col-resize"===jQuery(e).css("cursor"),"mouseup"==d.type){b.finalX=d.pageX,b.iniciouAumentar=!1;var u=0,v=jQuery("#"+jQuery(a).attr("id")+" thead tr th:not("+c.notResizableClass+")");for(null!==b.alvo&&void 0!==b.alvo&&jQuery(b.alvo.context).attr("largura",jQuery(b.alvo).width());null!==v[u]&&void 0!==v[u];)null!==jQuery(v[u]).attr("largura")&&void 0!==jQuery(v[u]).attr("largura")&&""!==jQuery(v[u]).attr("largura").trim()||jQuery(v[u]).attr("largura",""),u++;c.callBackResize(b.alvo)}}})}function e(a,b){var c=a.parentNode,d=a.nextSibling===b?a:a.nextSibling;b.parentNode.insertBefore(a,b),c.insertBefore(b,d)}function f(a,b){b?(jQuery(a).css({"-webkit-touch-callout":""}),jQuery(a).css({"-webkit-touch-callout":""}),jQuery(a).css({"-webkit-user-select":""}),jQuery(a).css({"-khtml-user-select":""}),jQuery(a).css({"-moz-user-select":""}),jQuery(a).css({"-ms-user-select":""}),jQuery(a).css({"--user-select":""})):(jQuery(a).css({"-webkit-touch-callout":"none"}),jQuery(a).css({"-webkit-touch-callout":"none"}),jQuery(a).css({"-webkit-user-select":"none"}),jQuery(a).css({"-khtml-user-select":"none"}),jQuery(a).css({"-moz-user-select":"none"}),jQuery(a).css({"-ms-user-select":"none"}),jQuery(a).css({"--user-select":"none"}))}function g(a){return jQuery(a).sortable(),jQuery(a).sortable("option","disabled",!1),jQuery(a).disableSelection(),!1}function h(a){return jQuery(a).sortable("disable"),!1}var b={aumentandoTD:!1,inicialX:null,finalX:null,iniciouAumentar:!1,movimento:null,widthInicial:null,widthInicialTabela:null,alvo:null,podeOrdenar:!0};a.fn.tabelaGwDraggable=function(b){tabelaInicial=jQuery(this);var e=tabelaInicial.attr("id"),f={redimensionavel:!1,draggable:!1,ordenacao:!1,notResizableClass:null,notDraggableClass:null,notOrderClass:null,idImgOrder:null,caminhoImagemUp:null,caminhoImagemDown:null,armazenarValoresWidth:!1,callBackResize:null,callBackDraggable:null,setaOrdemClass:null};settings=a.extend({},f,b),idOrderImg=settings.idImgOrder,caminhoImgUp=settings.caminhoImagemUp,caminhoImgDown=settings.caminhoImagemDown,settings.draggable&&c(this,settings),settings.redimensionavel&&d(this,settings),settings.ordenacao&&a("#"+e).table_cresc_desc()},function(a){a.fn.table_cresc_desc=function(b){return this.each(function(){var c=a(this);b=b||{},b=a.extend({},a.fn.table_cresc_desc.default_sort_fns,b);var d=function(b,c){for(var d=[],e=0,f=b.slice(0).sort(c),g=b.length,h=0;h<g;h++){for(e=a.inArray(b[h],f);a.inArray(e,d)!=-1;)e++;d.push(e)}return d},e=function(a,b){for(var c=a.slice(0),d=0,e=b.length,f=0;f<e;f++)d=b[f],c[d]=a[f];return c};c.on("click.table_cresc_desc","thead th",function(){if(podeOrdenar){var f=c.children("tbody").children("tr"),g=a(this),h=0,i=a.fn.table_cresc_desc.dir;c.find("thead th").slice(0,g.index()).each(function(){var b=a(this).attr("colspan")||1;h+=parseInt(b,10)});var j=g.data("sort-default")||i.ASC;g.data("sort-dir")&&(j=g.data("sort-dir")===i.ASC?i.DESC:i.ASC);var k=g.data("sort")||null;null===k&&(k="string"),c.trigger("beforetablesort",{column:h,direction:j}),c.css("display"),setTimeout(function(){var l=[],m=b[k];f.each(function(b,c){var d=a(c).children().eq(h),e=d.data("sort-value"),f="undefined"!=typeof e?e:d.text();l.push(f)});var n;n=j==i.ASC?d(l,m):d(l,function(a,b){return-m(a,b)}),c.find("thead th").data("sort-dir",null).removeClass("sorting-desc sorting-asc"),g.data("sort-dir",j).addClass("sorting-"+j);var o=a(e(f,n));c.children("tbody").remove(),c.append("<tbody />").append(o),c.trigger("aftertablesort",{column:h,direction:j}),c.css("display")},10)}})})},a.fn.table_cresc_desc.dir={ASC:"asc",DESC:"desc"},a.fn.table_cresc_desc.default_sort_fns={int:function(a,b){return parseInt(a,10)-parseInt(b,10)},float:function(a,b){return parseFloat(a)-parseFloat(b)},string:function(a,b){return a<b?-1:a>b?1:0},"string-ins":function(a,b){return a=a.toLowerCase(),b=b.toLowerCase(),a<b?-1:a>b?1:0}}}(jQuery)}(jQuery);var input=null,qtdInput=1;!function(a){a.fn.inputMultiploGw=function(b){input=jQuery(this);var c={width:"200px",height:"auto",overflow:"auto",readOnly:"false"},d=a.extend({},c,b),e={class:"alpha",style:"height:"+d.height+";width:"+d.width+";overflow:"+d.overflow+";",id:"divAlpha"+qtdInput},f={class:"beta-ul"},g={class:"container-chaves"},h={class:"container-input"},i={class:"delta-input",type:"text",style:"color:#555555;font-size:14px;width:auto;",id:"deltaInput"+qtdInput},j={type:"hidden",id:jQuery(input[0]).attr("id"),name:jQuery(input[0]).attr("name")},k=jQuery("<div>",e),l=jQuery("<ul>",f),m=jQuery("<div>",g),n=jQuery("<div>",h),o=jQuery("<input>",i);$inputHidden=jQuery("<input>",j),n.html(o),l.append(m),l.append(n),k.append(l),k.append($inputHidden),jQuery(input).replaceWith(k);var p=jQuery("#divAlpha"+qtdInput),q=jQuery("#deltaInput"+qtdInput);"true"===d.readOnly&&(jQuery(q).attr("readOnly","true"),jQuery(q).css("width","1px"),jQuery(p).attr("readOnly","true"),jQuery(p).css("cursor","default"),jQuery(p).css("background","#cccccc")),jQuery(p).click(function(){jQuery(q).focus()}),jQuery(p).focusout(function(){if(""!==jQuery(q).val().trim()){var a=jQuery(this).find("input[type=hidden]").attr("id");addValorAlphaInput(a,jQuery(q).val()),jQuery(q).val("")}}),jQuery(q).on("change paste keyup keydown",function(a){if(""!==jQuery(this).val().trim()){if(13!==a.which&&9!==a.which)return;var b=jQuery(this).parent().parent().parent().find("input[type=hidden]").attr("id");null!==jQuery(this).val()&&void 0!==jQuery(this).val()&&""!==jQuery(this).val().trim()&&addValorAlphaInput(b,jQuery(this).val()),jQuery(this).val("")}}),qtdInput++}}(jQuery);var qtdInput=1;!function(a){a.fn.selectExcetoApenasGw=function(b){var c=jQuery(this),d=c.clone();jQuery(c).parent().append(d),jQuery(d).hide();for(var e=jQuery(c).attr("id"),f=new Array,g=0;jQuery(d).find("option")[g];)f.push(jQuery(jQuery(d).find("option")[g]).html()),g++;var h={width:"150px",height:"auto"},i=a.extend({},h,b),j=jQuery("#"+e+" option:selected").html(),k=jQuery('<div class="div-alpha-exceto-apenas">'),l=jQuery('<div class="div-beta-exceto-apenas">'),m=jQuery('<div class="div-gamma-exceto-apenas">'),n=jQuery("<span>").html(j),o=jQuery('<span class="span-escolha-gw" id="span-escolha-gw-'+qtdInput+'">'),p=jQuery('<img src="'+homePath+'/img/ordenar_with_down01.png" width="10px" style="margin-left: 5px;margin-bottom: 1px;opacity: 0.8;">');o.append(n),o.append(p),l.append(o);for(var q=jQuery('<div class="container-li-valores" id="container-li-valores-'+qtdInput+'">'),r=jQuery('<ul style="width:'+i.width+';">'),s=0;s<f.length;s++){var t=jQuery("<span>").html(f[s]),u=jQuery("<li>").append(t);r.append(u)}q.append(r),m.append(q),k.append(l),k.append(m),jQuery(c).replaceWith(k),jQuery(o).click(function(){"block"==jQuery(q).css("display")?(jQuery(l).find("img").css("-webkit-transform","rotate(0deg)"),jQuery(l).find("img").css("transform","rotate(0deg)"),jQuery(q).hide(250)):(jQuery(l).find("img").css("-webkit-transform","rotate(180deg)"),jQuery(l).find("img").css("transform","rotate(180deg)"),jQuery(q).show(250))}),jQuery(q).find("ul").find("li").click(function(){jQuery(d).find('option:contains("'+jQuery(this).find("span").html()+'")').attr("selected","selected"),jQuery(l).find("img").css("-webkit-transform","rotate(0deg)"),jQuery(l).find("img").css("transform","rotate(0deg)"),jQuery(q).hide();var a=jQuery(this).find("span").html();jQuery(o).hide(250,function(){jQuery(o).find("span").html(a),jQuery(o).show(250)})}),qtdInput++}}(jQuery);var select=null,qtdSelect=1;!function(a){a.fn.selectMultiploGw=function(b){var c=jQuery(this),d=c.clone();jQuery(c).parent().append(d),jQuery(d).hide();var e={titulo:"",width:"150px",idInputHidden:"id-tipos-escolhidos"},f=a.extend({},e,b),g=jQuery('<div class="container-select-multiplo-gw">'),h=jQuery('<div class="container-select-multiplo-gw-A">'),i=jQuery('<input type="text" placeholder="Selecione os Tipos" readonly="true" id="tipos-escolhidos" name="tipos-escolhidos">'),j=jQuery('<input type="hidden" id="'+f.idInputHidden+'" name="'+f.idInputHidden+'" >');h.append(j),h.append(i),g.append(h);var k=jQuery('<div class="container-select-multiplo-gw-A">'),l=jQuery("<ul>");jQuery(d).find("option");for(var m=0;void 0!=jQuery(d).find("option")[m];){var n=jQuery(d).find("option")[m].innerText,o=jQuery(jQuery(d).find("option")[m]).val(),p=jQuery("<li>"),q=jQuery('<img src="'+homePath+'/assets/img/chk.png">'),r=jQuery('<label id="'+o+'">').html(n);p.append(q),p.append(r),l.append(p),m++}k.append(l),g.append(k),jQuery(c).replaceWith(g);var s=!1;jQuery(i).focusin(function(){jQuery(l).show(250),s=!0}).focusout(function(){s=!1,setTimeout(function(){s||jQuery(l).hide(250)},250)}),jQuery(g).click(function(){jQuery(i).focus()}),jQuery(l).find("li").click(function(){var a=jQuery(i).val();a.length>0&&","!=a.charAt(a.length-1)&&(a+=",");var b=jQuery(j).val();b.length>0&&","!=b.charAt(b.length-1)&&(b+=","),jQuery(this).find("img").attr("src").indexOf("checked")!==-1?(jQuery(this).css("background","#fff"),a.length>0&&(a=a.replace(jQuery(this)[0].innerText+",","")),","==a.charAt(a.length-1)&&(a=a.substr(0,a.length-1)),b.length>0&&(b=b.replace(jQuery(jQuery(this)[0]).find("label").attr("id")+",","")),","==b.charAt(b.length-1)&&(b=b.substr(0,b.length-1)),jQuery(this).find("img").attr("src",homePath+"/assets/img/chk.png"),jQuery("#tipos-escolhidos").val(a),jQuery("#id-tipos-escolhidos").val(b)):(jQuery(this).css("background","#efefef"),jQuery(this).find("img").attr("src",homePath+"/assets/img/chk_checked.png"),jQuery(i).val(a+jQuery(this)[0].innerText),jQuery(j).val(b+jQuery(jQuery(this)[0]).find("label").attr("id")))})}}(jQuery);