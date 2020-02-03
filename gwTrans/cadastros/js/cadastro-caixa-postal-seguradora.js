$(document).ready(function () {
    jQuery("#empresa_averbacao").selectmenu({
        change: function (event, ui) {
            var valor = ui.item.value;

            if (valor === '1') {
                $("#divVersaoAverbacao").show();
            } else {
                $("#divVersaoAverbacao").hide();
            }
        }
    }).selectmenu("option", "position", {
        my: "top+15",
        at: "top center"
    }).selectmenu("menuWidget").addClass("selects-ui");

    jQuery("#versao_averbacao").selectmenu().selectmenu("option", "position", {
        my: "top+15",
        at: "top center"
    }).selectmenu("menuWidget").addClass("selects-ui");

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'CaixaPostalSeguradoraControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                $("#descricao").val(obj['descricao']);
                $("#codigo_averbacao").val(obj['codigoAverbacao']);
                $("#login_averbacao").val(obj['loginAverbacao']);
                $("#senha_averbacao").val(obj['senhaAverbacao']);
                $("#empresa_averbacao").val(obj['empresa']).selectmenu('refresh').trigger('selectmenuchange');
                $("#versao_averbacao").val(obj['versao']).selectmenu('refresh');

                if (obj['empresa'] !== 1) {
                    $("#divVersaoAverbacao").hide();
                }

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['alteradoPor']['nome'], obj['alteradoEm']);

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }
});