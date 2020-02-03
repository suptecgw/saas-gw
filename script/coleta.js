jQuery(function () {
    jQuery('#resp_coleta').inputMultiploGw({
        readOnly: 'true',
        is_old: true,
        notX: 'true'
    });

    (function () {
        let iframe = jQuery('<iframe>');
        iframe.attr('id', 'localizarRepresentante');
        iframe.attr('name', 'localizarRepresentante');
        iframe.attr('input', 'resp_coleta');
        iframe.attr('src', 'LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarRepresentante&ocultarOpcoesAvancadas=true');
        iframe.attr('frameborder', '0');
        iframe.attr('marginheight', '0');
        iframe.attr('marginwidth', '0');
        iframe.attr('scrolling', 'no');
        jQuery('.localiza').html(iframe);
    })();
});

function carregarAbastecimentos() {
    jQuery.post(homePath + '/ContratoFreteControlador', {
            'acao': 'carregarAbastecimentos',
            'idveiculo': jQuery("#idveiculo").val()
        }, function (data) {
            var obj = JSON.parse(data);
            jQuery('#abastecimentos').val(parseFloat(obj['total_abastecimento']).toFixed(2));
            jQuery('#ids_abastecimentos').val(obj['abastecimentos_ids'].join(','));
        }
    );
}

//controlador.acao('abrirLocalizar','localizarFilial');