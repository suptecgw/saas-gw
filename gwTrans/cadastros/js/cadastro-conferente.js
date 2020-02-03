jQuery(document).ready(function () {
    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'ConferenteControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                $("#nome").val(obj.nome);
                if (obj.ativo === true) {
                    $("#ativo").attr('checked', 'checked');
                }

                criadoAlteradoAuditoria(obj['createdBy']['nome'], obj['createdAt'], obj['updatedBy']['nome'], obj['updatedAt']);

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

    jQuery(".ativa-helper1").hover(
        function () {
            jQuery(".campo-helper h2").html($($(this).context).find('input[type="hidden"]')[1].value);
            jQuery(".descri-helper h3").html($($(this).context).find('input[type="hidden"]')[0].value);
        },
        function () {
            jQuery('.campo-helper h2').html('Ajuda');
            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );
});
