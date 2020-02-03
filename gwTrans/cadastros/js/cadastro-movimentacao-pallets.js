$(document).ready(function () {
    jQuery('#numero_nota').mask("#");
    jQuery('#quantidade').mask("#");
    $('#tipo_pallet_id').inputMultiploGw({
        readOnly: 'true',
        width: '97%',
        notX: true
    });
    $('#filial_id').inputMultiploGw({
        readOnly: 'true',
        width: '97%',
        notX: true
    });
    $('#cliente_id').inputMultiploGw({
        readOnly: 'true',
        width: '97%',
        notX: true
    });

    jQuery("#tipo_lancamento").selectmenu().selectmenu({

    }).selectmenu({width: '79px'}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui").addClass("select");

    jQuery('#data').gwDatebox({
        'icone_classe': 'combo-arrow-escuro-cte',
        'funcao_apos_criacao': function (elemento) {
            elemento.parent().find('.datebox').css('width', '100%').hover(
                    function () {
                        try {
                            jQuery(".campo-helper h2").html($($(this).context).parent().find('input[type="hidden"]')[1].value);
                            jQuery(".descri-helper h3").html($($(this).context).parent().find('input[type="hidden"]')[0].value);
                        } catch (exception) {

                        }
                    },
                    function () {
                        jQuery('.campo-helper h2').html('Ajuda');
                        jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                    }
            );

            elemento.parent().find('.datebox').css('width', '93%');
            elemento.parent().find('.textbox-text').css('width', '93%').css('font-size', '14px');
        }
    });

    jQuery("span[class*='-button'],.ativa-helper1").hover(
            function () {
                try {
                    jQuery(".campo-helper h2").html($($(this).context).parent().find('input[type="hidden"]')[1].value);
                    jQuery(".descri-helper h3").html($($(this).context).parent().find('input[type="hidden"]')[0].value);
                } catch (exception) {

                }
            },
            function () {
                jQuery('.campo-helper h2').html('Ajuda');
                jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
            }
    );

    jQuery("#filial_id,#cliente_id,#tipo_pallet_id").parent().hover(
            function () {
                var elemento = $($(this).context).find('input[type="hidden"]:first').find('input[type=hidden]');

                jQuery(".campo-helper h2").html(elemento[1].value);
                jQuery(".descri-helper h3").html(elemento[0].value);
            },
            function () {
                jQuery('.campo-helper h2').html('Ajuda');
                jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
            }
    );
    
    if (qs['modulo'] === 'editar') {

        $.ajax({
            url: 'MovimentacaoPalletsControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'iniciarEditar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                try {
                    var obj = JSON.parse(jqXHR.responseText);

                    $("#id").val(obj['id']);


                    $("#data").val(obj['data']);
                    $("#numero").val(obj['numero']);
                    addValorAlphaInput('filial_id', String(obj.filial.abreviatura), String(obj.filial.idfilial));

                    addValorAlphaInput('cliente_id', String(obj.cliente.razaosocial), String(obj.cliente.idcliente));
                    addValorAlphaInput('tipo_pallet_id', String(obj.pallet.descricao), String(obj.pallet.id));

                    $("#tipo_lancamento").val(obj['tipo']);
                    $("#quantidade").val(obj['quantidade']);
                    $("#numero_nota").val(obj['nota']);
                    $("#numero_manifesto").val(obj.manifesto.nmanifesto);
                    $("#numero_coleta").val(obj.coleta.numero);
                    $("#confirmado").prop('checked', obj['confirmado']);

                    $("#div_manifesto_coleta").show();


                    // Selectmenu
//                    $('select').selectmenu('refresh');

                    criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['atualizadoPor']['nome'], obj['atualizadoEm']);

                    setTimeout(function () {
                        $('.bloqueio-tela').hide();
                        $('.gif-bloq-tela').hide();
                    }, 1000);

                } catch (exception) {
                    console.error(exception);
                    if (jqXHR.responseText.includes('ERROR:') || jqXHR.responseText.includes('A nome da coluna')) {
                        chamarAlert(jqXHR.responseText, function () {
                            window.location = 'ConsultaControlador?codTela=126';
                        });
                    } else {
                        chamarAlert(exception, function () {
                            window.location = 'ConsultaControlador?codTela=126';
                        });
                    }
                    setTimeout(function () {
                        $('.bloqueio-tela').hide();
                        $('.gif-bloq-tela').hide();
                    }, 1000);
                }
            }
        });
    } else if (qs['modulo'] === 'cadastrar') {
        let userFilialId = $('#userFilialId').val();
        let userFilialAbreviatura = $('#userFilialAbreviatura').val();

        if (userFilialId != undefined && userFilialId != null && userFilialAbreviatura != undefined && userFilialAbreviatura != null) {
            addValorAlphaInput('filial_id', userFilialAbreviatura, userFilialId);
        }
    }
});

function toLocalizar(localizar) {
    if (localizar == 'cliente') {
        controlador.acao('abrirLocalizar', 'localizarCliente');
    } else if (localizar == 'filial') {
        controlador.acao('abrirLocalizar', 'localizarFilial');
    } else if (localizar == 'pallet') {
        controlador.acao('abrirLocalizar', 'localizarTipoPallet');
    }
}
