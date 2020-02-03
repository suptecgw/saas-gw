(function ($) {
    var inputDate;
    var divGeral;
    /**
     * Função responsavel por criar um select com divisoes de grupos
     * Atenção a funcão vai mandar ao input o valor escolhido da seguinte maneira.
     * @example Não Realizada = nao-realizada
     */
    $.fn.GWDatePicker = function (options) {
        var opcoesDefaults = {
            espacamentoEntreInput: '12'
        };
        var settings = $.extend({}, opcoesDefaults, options);

        if (!settings.container) {
//            console.info('SelectMultiploGrupoGw não pode ser iniciado : "Configure o campo container"');
//            return false;
        }

        var meses_array = new Array("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro");

        inputDate = jQuery(this);
        divGeral = jQuery('<div class="container">');
                let posX = $(inputDate).offset().left;
                let posY = $(inputDate).offset().top;
                let h = $(inputDate).css('height');
                let
        posTopEl = (parseInt(posY) + parseInt(h) + parseInt(settings.espacamentoEntreInput));
                console.log(posTopEl);
        $(divGeral).css('top', posTopEl + 'px');
        $(divGeral).css('left', posX + 'px');
        
        //containers
        var containertopo = jQuery('<div class="container-topo">');
        var containermesano = jQuery('<div class="container-mes">');
        var containerdiasemana = jQuery('<div class="container-dia-semana">');


        //dados container top
        var labeldia = jQuery('<label class="dia">');
        $(labeldia).text("7");
        var labelmes = jQuery('<label class="mes">');
        $(labelmes).text("Setembro");
        var labelano = jQuery('<label class="ano">');
        $(labelano).text("2017");
        
        //dados container mes e ano
        var mesant = jQuery('<div class="mes-ant">');
        var mesano = jQuery('<label class="mes-ano">');
        $(mesano).text("Setembro 2017");
        var mesprox = jQuery('<div class="mes-prox">');
        var domingo = jQuery('<div class="dia-semana">');

        //dias da semana fixo
        $(domingo).text("D");
        var segunda = jQuery('<div class="dia-semana">');
        $(segunda).text("S");
        var terca = jQuery('<div class="dia-semana">');
        $(terca).text("T");
        var quarta = jQuery('<div class="dia-semana">');
        $(quarta).text("Q");
        var quinta = jQuery('<div class="dia-semana">');
        $(quinta).text("Q");
        var sexta = jQuery('<div class="dia-semana">');
        $(sexta).text("S");
        var sabado = jQuery('<div class="dia-semana">');
        $(sabado).text("S");

        //dvid geral recebe containers
        $(divGeral).append(containertopo);
        $(divGeral).append(containermesano);
        $(divGeral).append(containerdiasemana);
        
        //populando containers
        $(containertopo).append(labeldia);
        $(containertopo).append(labelmes);
        $(containertopo).append(labelano);
        $(containermesano).append(mesant);
        $(containermesano).append(mesano);
        $(containermesano).append(mesprox);

        //dias da semana fixo
        $(containerdiasemana).append(domingo);
        $(containerdiasemana).append(segunda);
        $(containerdiasemana).append(terca);
        $(containerdiasemana).append(quarta);
        $(containerdiasemana).append(quinta);
        $(containerdiasemana).append(sexta);
        $(containerdiasemana).append(sabado);


        $(this).focusin(function () {
            console.log('entrou');
            $('body').append(divGeral);

            $(divGeral).show();

        });

        $(this).focusout(function () {
            console.log('saiu');
            $(divGeral).hide();
        });



    };

}(jQuery));

$('#data').GWDatePicker();