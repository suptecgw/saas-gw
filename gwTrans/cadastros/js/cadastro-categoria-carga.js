$(document).ready(function () {
    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'CategoriaCargaControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                $("#descricao").val(obj.descricao);

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['alteradoPor']['nome'], obj['alteradoEm']);

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }
});