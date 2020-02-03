$(document).ready(function () {
    jQuery("select").each(function () {
        $(this).selectmenu({}).selectmenu("option", "position", {
            my: "top+15",
            at: "top center"
        }).selectmenu("menuWidget").addClass("selects-ui");
    });

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'LayoutEDIControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                $("#descricao").val(obj['descricao']);
                $("#tipoEDI").val(obj['tipoEdi']);
                $("#nomeArquivo").val(obj['nomeArquivo']);
                $("#extensaoArquivo").val(obj['extencaoArquivo']);

                if (obj['funcao'] && obj['funcao'] !== '') {
                    $("#funcao").val(obj['funcao']);
                }

                $('select').selectmenu('refresh');

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['atualizadoPor']['nome'], obj['atualizadoEm']);

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

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

    $('button[class="bt-salvar"]').on('click', function (e) {
        // Validar função
        var selectFuncao = $('#funcao');

        selectFuncao.parent().find('span:first').css('border', '');

        if (selectFuncao.val() === '0') {
            selectFuncao.parent().find('span:first').css('border', '1px solid red');
            chamarAlert('O campo Função do EDI é de preenchimento obrigatório!');

            e.stopImmediatePropagation();
        }
    });

    $('.variaveis').on('click', function (e) {
        var elemento = $(this);
        var elementoNomeArquivo = $('#nomeArquivo');
        var valor = elemento.text();
        var valorAntigo = elementoNomeArquivo.val();
        var valorNovo = valorAntigo + valor;

        if (valorNovo.length > 60) {
            chamarAlert('O nome do arquivo ultrapassou 60 caracteres!');
        } else {
            elementoNomeArquivo.val(valorNovo);
        }
    })
});