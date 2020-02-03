jQuery(document).ready(function () {
    jQuery('#chkOpcoesAvancadas').click(function () {
        if (jQuery(this).prop('checked')) {
            parent.controlador.acao('ativarDraggable', jQuery(this).val());
            jQuery('.envolve-topo').css('width','820px');
            jQuery('.envolve-resultados').css('width','820px');

            jQuery('.resultados').css('overflow-x', 'scroll');
            jQuery('.resultados').css('overflow-y', 'hidden');
        } else {
            jQuery('.envolve-topo').animate({
                'width': '108%'
            });
            jQuery('.coluna-pesquisa').css('overflow-x','auto');

            jQuery('.resultados').css('overflow', 'hidden');
        }
        
        parent.controlador.acao('opcoesAvancadas',idLocalizar);
        
    });

    jQuery('.coluna-centro').hide('fast');
    jQuery('.coluna-escolhidas').hide('fast');
    jQuery('.topo-resultados-estado').css('margin-left', '25px');

    if (jQuery('.opcoes-avancadas').attr('marcado') === 'false') {
        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var abreviatura = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.abreviatura').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.controleLocalizarClientes('finalizado','" + abreviatura + "',true)");
            i++;
        }
    } else {
        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var abreviatura = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.abreviatura').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.marcarItemAdicionar(this);");
            i++;
        }
    }

    jQuery('#inpt-filtrar-por').inputMultiploGw({
        width: '85%'
    });

    

});


//Validar o caractere de pagina
function verificaCaracterePagina(element, paginas) {
    element.value = element.value.replace(/[^0-9,]/g, "");

    if (element.value != null && element.value != "" && parseFloat(element.value) > parseFloat(paginas)) {
        element.value = "";
        return true;
    }

    //nao enviar pagina caso seja 0 - já que 0 é menor
    // que a quantidade de paginas sempre e passa das validacoes acima
    if (element.value == "0" || element.value == 0) {
        element.value = "";
    }
}

function limparFiliais() {
    jQuery('#topo-resultados-col1').html('');
    jQuery('#topo-resultados-col2').html('');
}

function limparFiliaisResultado() {
    jQuery('#topo-resultados-col1').html('');
}

function limparFiliaisEscolhidas() {
    jQuery('#topo-resultados-col2').html('');
}
function recarregarLocalizar() {
    window.location = 'FilialControlador?acao=iniciar_localizar';
}