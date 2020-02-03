jQuery(document).ready(function () {

    // Foi comentado a linha abaixo, pois o campo também aceita host, não só IPs.
    // jQuery('#host').mask('099.099.099.099');
    jQuery('#porta').mask('00000');

    jQuery('#chave_seguranca').gwReadFile({
        limit: 51200, // 50kib - 50kb
        destiny: jQuery('#chave_segurancaHidden'),
        callback: function (arquivo) {
            adicionarNomeChaveAcesso(arquivo.name);
            jQuery('#senha').attr('data-validar','false');
        },
        save_file: {
            controller: {
                data: {
                    // extension: ['pem', 'cer', 'pfx'],
                    base64: true
                }
            }
        }
    });

    $('button[class="bt-salvar"]').on('click', function () {
        $('div[id*="obs"]').each(function () {
            var div = $(this);
            var id = div.attr('id');
            var text = div.text();
            $('input[name=' + id + ']').val(text);
        });
    });

    jQuery("#tipoCriptografia, #tipoProtocolo").each(function () {
        $(this).selectmenu().selectmenu("option", "position", {
            my: "top+15",
            at: "top center"
        }).selectmenu("menuWidget").addClass("selects-ui");
    });

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
        $('#idConfTransf').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'FTPControlador',
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

                $('input[name="caminhoRemoto"]').val(obj['caminhoArquivoRemoto']);
                // Observação
                $('#observacao > div').text(obj['observacao']);

                // Chave de segurança
                if (obj['nomeChaveSeguranca']) {
                    adicionarNomeChaveAcesso(obj['nomeChaveSeguranca']);
                    jQuery('#senha').attr('data-validar','false');
                }

                criadoAlteradoAuditoria(obj['usuarioInclusao']['nome'], obj['dtInclusao'], obj['usuarioAlteracao']['nome'], obj['dtAlteracao']);

                // Selectmenu
                $('select').selectmenu('refresh');
                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

    $('#botTestar').on('click', function () {
        checkSession(function () {
            var user = $("#login").val();
            var senha = $("#senha").val();
            var porta = $("#porta").val();
            var ip = $("#host").val();
            var protocolo = $("#tipoProtocolo").val();
            var criptografia = $("#tipoCriptografia").val();
            var chaveSeguranca = $("#chave_segurancaHidden").val();
            var idFtp = $('#idConfTransf').val();

            jQuery.ajax({
                url: 'FTPControlador',
                dataType: "text",
                method: "post",
                data: {
                    ftpServidor: user,
                    ip: ip,
                    porta: porta,
                    senha: senha,
                    tipoProtocolo: protocolo,
                    tipoCriptografia: criptografia,
                    chaveSeguranca: chaveSeguranca,
                    acao: "testeConexao",
                    idFtp: idFtp
                },
                success: function (data) {
                    var ftp = JSON.parse(data);
                    if (ftp.boolean == true) {
                        chamarAlert("Conectado com sucesso!");
                    } else {
                        chamarAlert("Não foi conectado!");
                    }
                }
            });
        }, false);
    });

    $('#excluir_chave_seguranca').on('click', function (e) {
        e.preventDefault();

        checkSession(function () {
            chamarConfirm('Tem certeza que deseja excluir a chave de segurança?', 'confirmouExcluir()')
        }, false);
    });

    $('#baixar_chave_seguranca').on('click', function (e) {
        e.preventDefault();

        checkSession(function () {
            if ($("#nome_chave_seguranca").val() && $("#nome_chave_seguranca").val() !== '') {
                download($('#nome_chave_seguranca').val());
            }
        }, false);
    })
});

function adicionarNomeChaveAcesso(fileName) {
    var elemento = jQuery('#chave_seguranca').parent().find('.js-labelFile');
    var label = elemento.find('.js-fileName');
    var nomeChaveSegurancaElemento = $('#nome_chave_seguranca');

    if (fileName == undefined) {
        elemento.removeClass('has-file');
        label.text('Importar Chave');
        nomeChaveSegurancaElemento.val('');
        $('#excluir_chave_seguranca').removeAttr('has-file');
        $('#is_excluir_chave_seguranca').val('true');
    } else {
        elemento.addClass('has-file');
        label.text(fileName);
        nomeChaveSegurancaElemento.val(fileName);
        $('#excluir_chave_seguranca').attr('has-file', 'true');
        $('#is_excluir_chave_seguranca').val('false');
    }
}

function confirmouExcluir() {
    checkSession(function () {
        var elemento = $('#excluir_chave_seguranca');
        var hasFile = elemento.attr('has-file') === 'true';

        if (hasFile) {
            jQuery('#senha').attr('data-validar','true');
            $('#chave_seguranca').val('');
            $('#chave_segurancaHidden').val('');
            elemento.removeAttr('has-file');

            adicionarNomeChaveAcesso(undefined);
        }
    }, false);
}

function download(filename) {
    checkSession(function () {
        var idFtp = $('#idConfTransf').val();

        if (idFtp && idFtp !== '0') {
            var element = document.createElement('a');
            element.setAttribute('href', 'FTPControlador?acao=baixarChaveSeguranca&id=' + idFtp);
            element.setAttribute('download', filename);

            element.style.display = 'none';
            document.body.appendChild(element);

            element.click();

            document.body.removeChild(element);
        }
    }, false);
}