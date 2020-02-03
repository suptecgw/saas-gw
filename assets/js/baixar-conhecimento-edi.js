var settingsAba = null;

(function ($) {
    $.fn.gwTelaCadastro = function (opt) {
        //Caso nao envie nenhuma configuracao existe a default
        var config_padrao = {
            //Nome da tela
            "nome_tela": "Baixar CT-e por Arquivo EDI",
            "identificacao_bt_abas": ".btn-aba",
            "section_geral": ".section-geral",
            "section_bt": ".section-bt",
            //Abas
            abas: {
                1: {
                    "identificacao_aba": "[col-ajuda]",
                    "bt_aba": ".btn-aba-ajuda",
                    "texto_aba": "Ajuda",
                    "texto_aba_oculta": "Exibir Ajuda",
                    "texto_aba_visivel": "Ocultar Ajuda",
                    "largura_max_aba": "25%",
                    "largura_min_aba": "-4%",
                    "cor_aba": "rgb(55, 84, 113)",
                    "velocidade": 200,
                    "is_ativa": false,
                    "ativa": true
                }
            }
        };

        settingsAba = $.extend({}, config_padrao, opt);

        //Abas
        jQuery.each(settingsAba.abas, function (count, aba) {
            if (aba.ativa && !$(aba.identificacao_aba)[0]) {
                alert('A aba de "' + aba.texto_aba + '" não foi encontrada. A funcionalidade da aba está comprometida.');
            } else {
                if (aba.is_ativa === false) {
                    $(aba.identificacao_aba).hide();
                }
                $(aba.identificacao_aba).css('background', aba.cor_aba);

                adicionarOuvinteClick(aba);
            }
        });
    };
})(jQuery);

function adicionarOuvinteClick(aba) {
    $(aba.bt_aba).click(function () {
        if (aba.is_ativa) {
            ocultarAba(aba, true);
        } else {
            //Recarregando os videos
            //recarregarVideos();
            var ocultandoAba = false;
            jQuery.each(settingsAba.abas, function (count, valida_aba) {
                if (aba !== valida_aba && valida_aba.is_ativa === true) {
                    ocultandoAba = true;
                    ocultarAba(valida_aba);
                }
            });
            if (ocultandoAba) {
                setTimeout(function () {
                    abrirAba(aba);
                }, aba.velocidade + 20);
            } else {
                abrirAba(aba);
            }
        }
    });
}

function abrirAba(aba) {
    if (aba.is_ativa === false) {
        $(aba.identificacao_aba).show();
        aba.is_ativa = true;

        $(aba.identificacao_aba).animate({
            'width': aba.largura_max_aba
        }, aba.velocidade);

        let w_section = 'calc(75% - 70px)';
        if (parseInt(aba.largura_max_aba.replace('%', '')) > 25) {
            w_section = 'calc(60% - 70px)';
        }
        $(settingsAba.section_geral).css('width', w_section);
        $(settingsAba.section_bt).css('width', w_section);
        $(aba.bt_aba).text(aba.texto_aba_visivel);
        $('.btn-aba-ajuda').addClass('btn-aba-ajuda-on');
        $('.btn-aba-ajuda-on').removeClass('btn-aba-ajuda');
    }
}

function ocultarAba(aba, redimensionarSection) {
    if (aba.is_ativa === true) {
        aba.is_ativa = false;
        $(aba.identificacao_aba).animate({
            'width': aba.largura_min_aba
        }, aba.velocidade, function () {
            $(aba.identificacao_aba).hide();
        });
        if (redimensionarSection) {
            let w_section = 'calc(100% - 70px)';
            $(settingsAba.section_geral).css('width', w_section);
            $(settingsAba.section_bt).css('width', w_section);
        }
        $('.btn-aba-ajuda-on').addClass('btn-aba-ajuda');
        $('.btn-aba-ajuda').removeClass('btn-aba-ajuda-on');
        $(aba.bt_aba).text(aba.texto_aba_oculta);
    }
}

function adicionarNomeChaveAcesso(fileName) {
    var elemento = jQuery('#arquivo_ocoren').parent().find('.js-labelFile');
    var label = elemento.find('.js-fileName');
    var nomeArquivoOcorenElemento = $('#nome_arquivo_ocoren');

    if (fileName == undefined) {
        elemento.removeClass('has-file');
        label.text('Selecionar Arquivo');
        nomeArquivoOcorenElemento.val('');
        $('#arquivo_ocorenHidden').val('');
    } else {
        elemento.addClass('has-file');
        label.text(fileName);
        nomeArquivoOcorenElemento.val(fileName);
    }

    qtdDom = 0;
    $('#tabela-gwsistemas').find('tbody').empty();
    atualizarContadorQtd();
}

$(document).ready(function () {
    $(document).gwTelaCadastro();

    jQuery('#tabela-gwsistemas').tabelaGwDraggable({
        redimensionavel: true
    });

    jQuery("#layout_ocoren").each(function () {
        $(this).selectmenu().selectmenu("option", "position", {
            my: "top+15",
            at: "top center"
        }).selectmenu("menuWidget").addClass("selects-ui");
    });

    jQuery('#arquivo_ocoren').gwReadFile({
        limit: 51200, // 50kib - 50kb
        destiny: $('#arquivo_ocorenHidden'),
        callback: function (arquivo) {
            adicionarNomeChaveAcesso(arquivo.name);
        },
        save_file: {
            controller: {
                data: {
                    extension: ['txt'],
                    base64: true
                }
            }
        }
    });

    $('#importar_edi').on('click', function () {
        var button = this;

        button.classList.add('loading');
        button.setAttribute('disabled', 'disabled');

        var tipoOcoren = $('#layout_ocoren').val();

        if (!tipoOcoren || tipoOcoren === '' || tipoOcoren === '0') {
            chamarAlert('O campo Layout é de preenchimento obrigatório!');

            button.classList.remove('loading');
            button.removeAttribute('disabled');

            return;
        }

        var base64 = $('#arquivo_ocorenHidden').val();

        if (!base64 && base64 === '') {
            chamarAlert('O campo Selecionar Arquivo é de preenchimento obrigatório!');

            button.classList.remove('loading');
            button.removeAttribute('disabled');

            return;
        }

        $.post(homePath + '/ConhecimentoControlador', {
            'acao': 'importarOcorenEDI',
            'tipo_ocoren': tipoOcoren,
            'arquivo': base64
        }, function (data) {
            if (data) {
                var objetoJson = JSON.parse(data);

                if (objetoJson) {
                    qtdDom = 0;
                    $('#tabela-gwsistemas').find('tbody').empty();
                    atualizarContadorQtd();

                    $.each(objetoJson, function () {
                        addDom(this);
                    });
                }
            }

            button.classList.remove('loading');
            button.removeAttribute('disabled');
        });
    });

    $('#bt-salvar').on('click', function () {
        var button = this;

        button.classList.add('loading');
        button.setAttribute('disabled', 'disabled');

        $.post(homePath + '/OcorrenciaControlador', {
            'acao': 'cadastrarOcorrenciaCTe',
            'form': $('#formCadastro').gwFormToJson()
        }, function (data) {
            var objetoJson = JSON.parse(data);

            if (objetoJson) {
                if (!objetoJson.success) {
                    if (objetoJson.mensagem === 'existem_ctes_nao_encontrados') {
                        // Procurar CT-e(s) que não foram salvos
                        let cteEncontrados = $('[class="link-cte"]').toArray().map(i => $(i).text()).join(', ');
                        let cteNaoEncontrados = $('[class="sem-link-cte"]').toArray().map(i => $(i).text()).join(', ');

                        if (cteEncontrados.length > 0) {
                            chamarAlert('Foram baixados os CT-e(s): ' + cteEncontrados + ', mas não foram encontrados os CT-e(s): ' + cteNaoEncontrados);
                        } else {
                            chamarAlert('Não foram encontrados os CT-e(s): ' + cteNaoEncontrados);
                        }
                    } else {
                        chamarAlert(objetoJson.mensagem);
                    }
                } else {
                    chamarAlert(objetoJson.mensagem, function () {
                        adicionarNomeChaveAcesso(undefined);
                    });
                }
            }

            button.classList.remove('loading');
            button.removeAttribute('disabled');
        });
    });

    $('#tabela-gwsistemas').find('tbody').on('click', 'tr > td.link-cte', function () {
        var cteId = $(this).parent().find('input[name*=cte_id]').val();

        window.open(homePath + "/frameset_conhecimento?acao=editar&id=" + cteId, "", "width=1200,height=700");
    });

    $('.bt-voltar').on('click', function () {
        window.close();
    });

    carregarAjuda();
    registrarAjuda();
});

var qtdDom = 0;

function addDom(ocorrencia) {
    var tbody = $('#tabela-gwsistemas').find('tbody');

    qtdDom++;

    var tr = $('<tr>').attr({
        'data-gw-grupo-serializado': 'ocorrencia_' + qtdDom
    });

    var podeVerCTe = ($("#cadconhecimento").val() === 'true' && $('#filial_id').val() == ocorrencia.conhecimento.filial.idfilial)
        || ($("#lanconhfl").val() === 'true' && $("#filial_id").val() != ocorrencia.conhecimento.filial.idfilial)
        && ocorrencia.conhecimento.id != 0;

    tr.append($('<td>', {'class': podeVerCTe ? 'link-cte lb-link' : 'sem-link-cte'}).text(ocorrencia.conhecimento.numero + '/' + ocorrencia.conhecimento.serie))
        .append($('<td>').text(ocorrencia.conhecimento.filial.razaosocial))
        .append($('<td>').text(ocorrencia.conhecimento.emissao))
        .append($('<td>').text(ocorrencia.nota_fiscal.numero + '/' + ocorrencia.nota_fiscal.serie))
        .append($('<td>').text(ocorrencia.conhecimento.remetente.razaosocial))
        .append($('<td>').text(ocorrencia.conhecimento.destinatario.razaosocial))
        .append($('<td>').text(ocorrencia.ocorrencia.codigo + ' - ' + ocorrencia.ocorrencia.descricao))
        .append($('<td>').text(ocorrencia.data_ocorrencia + ' ' + ocorrencia.hora_ocorrencia))
        .append($('<td>').text(ocorrencia.observacao_ocorrencia));

    var inputHiddens = $('<td hidden>').append($('<input>').attr({
        'type': 'hidden',
        'id': 'cte_id' + qtdDom,
        'name': 'cte_id' + qtdDom,
        'value': ocorrencia.conhecimento.id,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'ocorrencia_cte_id' + qtdDom,
        'name': 'ocorrencia_cte_id' + qtdDom,
        'value': ocorrencia.ocorrencia.id,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'data_ocorrencia' + qtdDom,
        'name': 'data_ocorrencia' + qtdDom,
        'value': ocorrencia.data_ocorrencia,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'hora_ocorrencia' + qtdDom,
        'name': 'hora_ocorrencia' + qtdDom,
        'value': ocorrencia.hora_ocorrencia,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'nota_fiscal_id' + qtdDom,
        'name': 'nota_fiscal_id' + qtdDom,
        'value': ocorrencia.nota_fiscal.id,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'observacao' + qtdDom,
        'name': 'observacao' + qtdDom,
        'value': ocorrencia.observacao_ocorrencia,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'ocorrencia_entrega_realizada' + qtdDom,
        'name': 'ocorrencia_entrega_realizada' + qtdDom,
        'value': ocorrencia.ocorrencia.entregaRealizada,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'ocorrencia_entrega_nao_realizada' + qtdDom,
        'name': 'ocorrencia_entrega_nao_realizada' + qtdDom,
        'value': ocorrencia.ocorrencia.entregaNaoRealizada,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    })).append($('<input>').attr({
        'type': 'hidden',
        'id': 'ocorrencia_enviar_email_cte' + qtdDom,
        'name': 'ocorrencia_enviar_email_cte' + qtdDom,
        'value': ocorrencia.ocorrencia.enviarEmailOcorrenciaCTe,
        'data-gw-campo-grupo-serializado': 'ocorrencia_' + qtdDom
    }));

    tr.append(inputHiddens);
    tbody.append(tr);

    atualizarContadorQtd();
}

function atualizarContadorQtd() {
    $('#qtd_ocorrencias').fadeOut(function () {
        $(this).text(qtdDom).fadeIn();
    });
}

function addAjudaLabel(name, lb, valueInputAjuda) {
    var label = jQuery('#' + name);

    var createInputAjuda = "<input type=\"hidden\" value='" + valueInputAjuda + "'>";
    var createNameAjuda = "<input type=\"hidden\" value='" + lb + "'>";

    label.append(createInputAjuda);
    label.append(createNameAjuda);
}

function addPermissoesTela(codigo, descricao, observacao) {
    jQuery('.table_permissao tbody').append('<tr><td>' + codigo + '</td><td>' + descricao + '</td><td>' + observacao + '</td></tr>');
}

function semPermissao() {
    jQuery('.table_permissao tbody').append('<tr><td colspan="3">Não existe permissões para esta tela.</td></tr>');
}

function carregarAjuda() {
    jQuery.ajax({
        url: "UsuarioControlador?acao=ativarAjuda&codigoTela=" + codigoTela,
        type: 'POST',
        dataType: 'text/html',
        beforeSend: function () {
            if (jQuery('.aguarde') !== undefined) {
                jQuery('.cobre-left').show('fast');
                jQuery('.aguarde').show('fast');
            }
        },
        complete: function (retorno) {
            if (jQuery('.aguarde') !== undefined) {
                jQuery('.aguarde').hide('fast');
                jQuery('.cobre-left').hide('fast');
            }

            if (retorno.responseText !== '') {
                var camposAjuda = JSON.parse(retorno.responseText.split(']')[0] + ']');
                var permissoes = JSON.parse(retorno.responseText.split(']')[1] + ']');

                for (var i = 0; i < camposAjuda.length; i++) {
                    var jsonCampos = camposAjuda[i];
                    addAjudaLabel(jsonCampos.name, jsonCampos.label, jsonCampos.observacao);
                }

                for (var i = 0; i < permissoes.length; i++) {
                    var jsonPerm = permissoes[i];
                    addPermissoesTela(jsonPerm.codigo, jsonPerm.descricao, jsonPerm.observacao);
                }

                if (permissoes.length === 0) {
                    semPermissao();
                }

            } else {
                semPermissao();
            }
        }
    });
}

function registrarAjuda() {
    jQuery("span[class*='-button'],.ativa-helper-data-ajuda").hover(
        function () {
            var t = $(this);
            var attr = t.attr('data-ajuda');
            
            if (t.attr('class').indexOf('-button') !== -1) {
                attr = t.parent().find('select').attr('data-ajuda');
            }
            var elemento = $('#' + attr);
            $(".campo-helper h2").html(elemento.find('input[type=hidden]')[1].value);
            $(".descri-helper h3").html(elemento.find('input[type=hidden]')[0].value);
        },
        function () {
            $('.campo-helper h2').html('Ajuda');
            $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );
}