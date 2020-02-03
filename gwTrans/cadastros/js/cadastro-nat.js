$(document).ready(function () {
    // funções e etc aqui
    jQuery('#div-ip-final').hide();

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'NatControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                $('#descricao').val(obj['descricao']);
                $('#tipoAcesso').val(obj['tipoAcesso']);
                $('#ip').val(obj['ip']);
                $('#ipFinal').val(obj['ipFinal']);
                
                criadoAlteradoAuditoria(obj['criadoPor']['nome'], formatarLocalDate(obj['criadoEm']), obj['atualizadoPor']['nome'], formatarLocalDate(obj['atualizadoEm']));

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

    jQuery("#tipoAcesso").selectmenu({
        change: function () {
            hideIpFinal(this);
        },
        create: function (event, ui) {
            hideIpFinal(this);
        }

    }).selectmenu("option", "position", {
        my: "top+15",
        at: "top center"
    }).selectmenu("menuWidget").addClass("selects-ui");
    
    jQuery('#ip').mask('099.099.099.099');
    jQuery('#ipFinal').mask('099.099.099.099');

    
    
});

function hideIpFinal(select) {
    if (select.value == 2) {
        $('#ipFinal').attr('data-validar', 'true');
        $('#div-ip-final').show();
    } else {
        jQuery('#ipFinal').attr('data-validar', 'false');
        jQuery('#div-ip-final').hide();
    }
}