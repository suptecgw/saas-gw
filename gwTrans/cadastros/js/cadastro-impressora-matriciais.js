jQuery(document).ready(function () {

    jQuery("span[class*='-button'],.ativa-helper2").hover(
        function () {
            jQuery(".campo-helper h2").html($($(this).context).parent().find('input[type="hidden"]')[1].value);
            jQuery(".descri-helper h3").html($($(this).context).parent().find('input[type="hidden"]')[0].value);
        },
        function () {
            jQuery('.campo-helper h2').html('Ajuda');
            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );

    if (qs['modulo'] === 'editar') {
        $('#idImpressora').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'ImpressoraControlador',
            async: true,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);
                Object.keys(obj).forEach(function (chave) {
                    var valor = obj[chave];
                    $("#" + chave).val(valor);
                });

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], formatarLocalDate(obj['criadoEm']), obj['atualizadoPor']['nome'], formatarLocalDate(obj['atualizadoEm']));

                // Selectmenu
                $('select').selectmenu('refresh');
                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

});
