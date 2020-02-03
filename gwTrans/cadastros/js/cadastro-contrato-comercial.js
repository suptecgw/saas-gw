function abrirLocalizarCliente() {
    if ($.grep($('input[name*="tabela"]'), function (elemento) {
        var valor = $(elemento).val();

        return valor || valor.trim().length > 0;
    }).length > 0) {
        chamarAlert('Não é possível alterar o cliente pois existe pelo menos uma tabela de preço selecionada.');

        return false;
    }

    checkSession(function () {
        controlador.acao('abrirLocalizar', 'localizarCliente');
    }, false);

    return true;
}

$(window).on('resize', function () {
    let size = $('.container-form').height();
    $('#body-container > .body').css('height', size - 350);
});

$(document).ready(function () {
    $('button[class="bt-salvar"]').on('click', function (e) {
        $('div[id*="obs"]').each(function () {
            var div = $(this);
            var id = div.attr('id');
            var text = div.find('div').html().replace(/<div><br><\/div>/g, '<br>').replace(/<div>/g, '<br>').replace(/<\/div>/g, '');

            $('input[name=' + id + ']').val(text);
        });
    });

    jQuery('#inptCliente').inputMultiploGw({
        width: '96%',
        readOnly: 'true',
        classes: 'alpha-fora-dom ativa-helper1'
    });
    
    jQuery("#filial").selectmenu({
        change: function () {
        },
        open: function (event, ui) {
        },
        close: function (event, ui) {
        }
    }).selectmenu("option", "position", {
        my: "top+15",
        at: "top center"
    }).selectmenu("menuWidget").addClass("selects-ui");
    $('input[data-data="true"]')
        .mask('00/00/0000')
        .bind('focusout', function (e) {
            var elemento = $(this);
            var obrigatorioData = elemento.attr('data-data-obrigatorio') === 'true';
            var valor = elemento.val();

            if (obrigatorioData || valor.trim().length != 0) {
                completarData(this, e);
            }
        });

    $('.header-dom > img').click(function () {
        var inputCliente = $('#inptCliente');
        var valorCliente = inputCliente.val();

        if (valorCliente === undefined || valorCliente === null || valorCliente.trim() === '') {
            chamarAlert(inputCliente.attr('data-erro-validacao'));

            return;
        }

        var body = null;
        var containerDom = $('#conteudo-aba1');

        if (containerDom.find('.body')[0]) {
            body = containerDom.find('.body');
        } else {
            containerDom.append($('<div class="container-dom" id="body-container"><div class="body">'));
            body = containerDom.find('.body');
        }
        var bodyDom = $('<div class="col-md-12 body-dom celula-zebra-2" style="padding-top:12px;">');
        $(body).append(bodyDom);
        $(bodyDom).load(homePath + '/gwTrans/cadastros/html-dom/dom-tabela-preco.jsp?v=0.1');
    });

    $('.aba').click(function () {
        $('.conteudo-aba').hide();
        $('.aba-selecionada').removeClass('aba-selecionada');
        $(this).addClass('aba-selecionada');
        if ($(this).hasClass('aba01')) {
            $('#conteudo-aba1').show(250);
        } else if ($(this).hasClass('aba02')) {
            $('#conteudo-aba2').show(250);
        } else if ($(this).hasClass('aba03')) {
            $('#conteudo-aba3').show(250);
        } else if ($(this).hasClass('aba04')) {
            $('#conteudo-aba4').show(250);
        }
    });

    setTimeout(function () {
        jQuery(jQuery('.localiza')[0]).html('<iframe id="localizarCliente" input="inptCliente" name="localizarCliente" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente&tema='+tema+'" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
    }, 1);

    jQuery(".ativa-helper1").hover(
        function () {
            jQuery(".campo-helper h2").html($($(this).context).find('input[type="hidden"]')[2].value);
            jQuery(".descri-helper h3").html($($(this).context).find('input[type="hidden"]')[1].value);
        },
        function () {
            jQuery('.campo-helper h2').html('Ajuda');
            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );

    jQuery("#filial-button,.ativa-helper2").hover(
        function () {
            jQuery(".campo-helper h2").html($($(this).context).parent().find('input[type="hidden"]')[1].value);
            jQuery(".descri-helper h3").html($($(this).context).parent().find('input[type="hidden"]')[0].value);
        },
        function () {
            jQuery('.campo-helper h2').html('Ajuda');
            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );
    
    // quando der enter no código, deve importar a tabela
    jQuery("#codigoEnter").on('keydown',function(ev){
         //evento ENTER
        if (ev.keyCode == '13') {
            // SE JA EXISTIR não pode colocar de novo.
            if (jQuery("input[id^='tabela'][value='"+jQuery(this).val()+"#@#"+jQuery(this).val()+"']").length > 0) {
                chamarAlert("Tabela já importada nesse contrato.");
                jQuery("#codigoEnter").val('');
                return false;
            }
            //chama uma função genérica de consulta.
            consultarTabela();
        }
    });
    
    jQuery("#bt-pesquisar-tabela").on('click', function (ev) {
        // SE JA EXISTIR não pode colocar de novo.
        if (jQuery("input[id^='tabela'][value='" + jQuery(this).val() + "#@#" + jQuery(this).val() + "']").length > 0) {
            chamarAlert("Tabela já importada nesse contrato.");
            jQuery("#codigoEnter").val('');
            return false;
        }
        consultarTabela();
    });

    jQuery("#bt-pesquisar-etiqueta").on('click', function(){
        //chama uma função genérica de consulta.
        consultarTabela();
    });
});


function hasDuplicates(array) {
    return (new Set(array)).size !== array.length;
}

var arrayTabelasSelecionadas = new Array();

function beforeSave(){
    
    jQuery("input[id^='tabela']").each(
            function(){
                arrayTabelasSelecionadas.push(jQuery(this).val());
            }
    );
    
    if (hasDuplicates(arrayTabelasSelecionadas)) {
        chamarAlert("Existe tabela duplicada no contrato atual.");
        arrayTabelasSelecionadas = new Array();
        return false;
    }
    
    arrayTabelasSelecionadas = new Array();
    return true;
    
}

function consultarTabela(){
    // colocar o valor do campo em uma variavel para não chamar o jquery muitas vezes.
    var tabelaCodigo = jQuery("#codigoEnter").val();
    // se for vazio faça nada.
    if (tabelaCodigo == '') {
        return false;
    }
    // SE JA EXISTIR não pode colocar de novo.
    if (jQuery("input[id^='tabela'][value='"+tabelaCodigo+"#@#"+tabelaCodigo+"']").length > 0) {
        chamarAlert("Tabela já importada nesse contrato.");
        jQuery("#codigoEnter").val('');
        return false;
    }
    // AJAX
    jQuery.ajax({
        url: "TabelaPrecoControlador",
        data: {
            id: tabelaCodigo,
            acao: "localizarCodigo"
        }
    }).done(function(msg){
        // MSG = '' é por que não achou ou deu erro...
        if (msg == '') {
            chamarAlert("Tabela não encontrada.");
            jQuery("#codigoEnter").val('');
        }else{
            // converter o retorno para JSON
            var json = JSON.parse(msg);
            
            if (json.isDesativada == 't' || json.isDesativada == 'true') {
                chamarAlert("Erro: Tabela de preço desativada.");
                return false;
            } else if (json.isVencida == 't' || json.isVencida == 'true') {
                chamarAlert("Erro: Tabela de preço vencida.");
                return false;
            }
            // incluir uma linha
            $('.header-dom > img').click();

            // quando não tinha o timeout ele não colocava os valore corretamente.
            setTimeout(function(){
                // preencher o ultimo campo.
                var idLocalizar = jQuery("input[id^='tabela']").last().attr('id');
                addValorAlphaInput(idLocalizar, json.idtabela, json.idtabela, true);
                jQuery("input[id^='origem']").last().val(json.origem);
                jQuery("input[id^='destino']").last().val(json.destino);
                jQuery("input[id^='tipoProduto']").last().val(json.tipoProduto);
                jQuery("input[id^='valorFrete']").last().val(json.valorFrete);
                jQuery("input[id^='porcentagemNF']").last().val(json.prcentagemNF);
                jQuery("input[id^='freteMinimo']").last().val(json.freteMinimo);
            }, 100);
            jQuery("#codigoEnter").val('');
        }
    });
}
