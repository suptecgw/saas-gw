jQuery(document).ready(function () {
    jQuery('#setorEntrega').inputMultiploGw({
        readOnly: 'true',
        is_old: true,
        width: '150px',
    });

    jQuery('#grupoCliente').inputMultiploGw({
        readOnly: 'true',
        is_old: true,
        width: '158px',
    });

    jQuery('#formulario').on('change', 'input[name="setorEntrega"]', function () {
        var elemento = jQuery(this);
        // Carregar o(s) grupo(s) de cliente do setor de entrega
        if (elemento.val() !== '') {
            jQuery.get(homePath + '/GrupoClienteFornecedorControlador', {
                'acao': 'obterGruposPorSetorEntrega',
                'ids': elemento.val().split('!@!').map(function (e) {
                    return e.split('#@#')[1]
                }).join()
            }, function (data) {
                if (data) {
                    var ids = [];

                    if (jQuery('#grupoCliente').val() !== '') {
                        ids = jQuery('#grupoCliente').val().split('!@!').map(function (e) {
                            return e.split('#@#')[1]
                        });
                    }

                    jQuery.each(data, function (index, grupo) {
                        if (!ids.includes(String(grupo['id']))) {
                            addValorAlphaInput('grupoCliente', grupo['descricao'], String(grupo['id']));
                        }
                    });
                }
            }, 'json');
        }
    });

    if (grupoCliente !== '') {
        jQuery.each(grupoCliente.split('!@!'), function (index, elemento) {
            var split = elemento.split('#@#');
            addValorAlphaInput('grupoCliente', split[0], split[1]);
        });
    }

    if (setorEntrega !== '') {
        jQuery.each(setorEntrega.split('!@!'), function (index, elemento) {
            var split = elemento.split('#@#');
            addValorAlphaInput('setorEntrega', split[0], split[1]);
        });
    }
});