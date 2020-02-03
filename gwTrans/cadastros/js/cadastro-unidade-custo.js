jQuery(document).ready(function () {
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

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);

        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'UnidadeCustoControlador',
            async: true,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);
                
                
                $('#sigla').val(obj['sigla']);
                $('#descricao').val(obj['descricao']);
                $('#ativo').prop('checked', obj['ativo']);
                $('#visualizar_orcamentacao').prop('checked', obj['visualizarNaOrcamentacao']);
                $('#codigo_contabil').val(obj['codigoContabil']);
                $('#integra_contabil').prop('checked', obj['integraContabil']);

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], formatarLocalDate(obj['criadoEm']), obj['atualizadoPor']['nome'], formatarLocalDate(obj['atualizadoEm']));

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

});
