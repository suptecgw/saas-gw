let qtdDom = 0;

let filiaisAdicionadas = [];

function adicionarNomeChaveAcesso(fileName) {
    var elemento = jQuery('#certificado').parent().find('.js-labelFile');
    var label = elemento.find('.js-fileName');
    var nomeChaveSegurancaElemento = $('#nome_certificado');
    let inputHiddenFile = $('#certificadoHidden');
    let inputFile = $('#certificado');

    if (fileName == undefined) {
        elemento.removeClass('has-file');
        label.text('Importar Certificado Digital');
        nomeChaveSegurancaElemento.val('');
        inputHiddenFile.val('');
        inputFile.val('');
    } else {
        elemento.addClass('has-file');
        label.text(fileName);
        nomeChaveSegurancaElemento.val(fileName);
    }
}

function enviarRequisicaoCertificado(respostaPrompt) {
    jQuery('#senha').val(respostaPrompt);

    // Realizar Ajax para pegar dados do certificado.
    jQuery.post(homePath + '/CertificadoDigitalControlador', {
        'acao': 'obterInformacoesCertificado',
        'certificado': jQuery('#certificadoHidden').val(),
        'senha': respostaPrompt
    }, function (data) {
        if (data) {
            if (data['erro'] !== undefined) {
                chamarAlert(data['erro']);
                adicionarNomeChaveAcesso(undefined);
            } else {
                jQuery('#razaoSocialCertificado').text(data['razaosocial']);
                jQuery('#cnpjCertificado').text(cnpj(data['cnpj']));
                if (data['dias_vencimento'] > 30) {
                    jQuery('#validadeCertificado').html(`${data['data_vencimento']} <span id="vencimento_lbl" style="color: green;font-weight: bolder;">(${data['dias_vencimento']} dias para vencer)</span>`);
                } else if (data['dias_vencimento'] > 0 && data['dias_vencimento'] <= 30) {
                    jQuery('#validadeCertificado').html(`${data['data_vencimento']} <span id="vencimento_lbl" style="color: #d4ae27;font-weight: bolder;">(Seu certificado vencerá em ${data['dias_vencimento']} dias)</span>`);
                } else {
                    jQuery('#validadeCertificado').html(`${data['data_vencimento']} <span id="vencimento_lbl" style="color: red;font-weight: bolder;">(Seu certificado venceu à ${data['dias_vencimento'] * -1} dias)</span>`);
                }

                if (data['is_cadeia_v2']) {
                    $('#lblCadeiaCertificado').text('V2');
                    $('#certificadoCadeia').val($('#certificadoHidden').val());
                    $('#cadeiaAtualizada').val('true');
                } else {
                    $('#lblCadeiaCertificado').text('V1');
                }
                jQuery('#informacoesCertificado').show();
                jQuery('#cadeiaCertificado').show();
                jQuery('#containerFiliais').show();
            }
        }
    }, 'json');
}

function inptFilial(objeto_envio) {
    if (!filiaisAdicionadas.includes(objeto_envio.inputId)) {
        filiaisAdicionadas.push(objeto_envio.inputId);
        addDomFilial(objeto_envio);
    }
}

function addDomFilial(filial) {
    var container = $('.container-dom-filials .body');
    var div = $('<div class="container-dom-filial col-md-12">');

    $(container).append(div);
    var dados = homePath + "/gwTrans/cadastros/html-dom/dom-filial-certificado.jsp?qtdDom=" + (++qtdDom)
        + "&filialId=" + filial.inputId
        + "&abreviatura=" + encodeURIComponent(filial.abreviatura)
        + "&cnpj=" + encodeURIComponent(cnpj(filial.cnpj))
        + "&cidade=" + encodeURIComponent(filial.cidade)
        + "&uf=" + encodeURIComponent(filial.uf);
    $(div).load(dados);
}

jQuery(document).ready(function aoCarregarDocumento() {
    jQuery('#certificado').gwReadFile({
        limit: 102400, // 100kib - 100kb
        destiny: jQuery('#certificadoHidden'),
        callback: function (arquivo) {
            adicionarNomeChaveAcesso(arquivo.name);

            // Pedir senha do certificado
            chamarPrompt('Qual a senha do certificado?', 'enviarRequisicaoCertificado', 'password', 'recusouPrompt');
        },
        save_file: {
            controller: {
                data: {
                    extension: ['pfx'],
                    base64: true
                }
            }
        }
    });

    $('#atualizarCadeiaCertificado').on('click', function aoClicarAtualizarCadeiaCertificado() {
        // Verificar se tem certificado anexado
        let certificado = $('#certificadoHidden').val();

        if (certificado === '') {
            chamarAlert('Não é possível atualizar a cadeia, pois não há certificado vinculado.');

            return;
        }

        jQuery.post(homePath + '/CertificadoDigitalControlador', {
            'acao': 'atualizarCadeiaCertificado',
            'certificado': jQuery('#certificadoHidden').val(),
            'senha': jQuery('#senha').val()
        }, function (data) {
            if (data) {
                if (data['erro'] !== undefined) {
                    chamarAlert(data['erro']);
                } else {
                    if (data['is_cadeia_v2']) {
                        $('#lblCadeiaCertificado').text('V2');
                        $('#certificadoCadeia').val(data['certificado']);
                        $('#cadeiaAtualizada').val('true');
                    }
                }
            }
        }, 'json');
    });

    jQuery('#localizarFilialDom').on('click', function localizarFilialDom() {
        checkSession(function aoClicarAbrirLocalizarFilial() {
            controlador.acao('abrirLocalizar', 'localizarFilial');
        }, false);
    });

    jQuery('.bt-salvar').on('click', function aoClicarBotaoSalvar(e) {
        if ($('#certificadoHidden').val() === '') {
            chamarAlert('O campo Certificado é de preenchimento obrigatório!');

            e.stopImmediatePropagation();

            return false;
        }

        if ($('#lblCadeiaCertificado').text() !== 'V2') {
            chamarAlert('É necessário atualizar a cadeia do certificado antes de salvar!');

            e.stopImmediatePropagation();

            return false;
        }

        // Ao salvar um certificado, caso exista na lista de filiais alguma filial que a raiz
        // do CNPJ seja diferente da raiz do CNPJ do certificado, o sistema deverá
        // mostrar a mensagem ME244;
        let cnpjRaizCertificado = jQuery('#cnpjCertificado').text();
        cnpjRaizCertificado = cnpjRaizCertificado.substring(0, cnpjRaizCertificado.lastIndexOf('/')).replace(/\./g, '');

        jQuery('.container-dom-filial input[type="hidden"][name^="cnpj"]').each(function loopValidacaoCnpjFiliais(index, cnpjFilial) {
            let valor = cnpjFilial.value;

            valor = valor.substring(0, valor.lastIndexOf('/')).replace(/\./g, '');

            if (valor !== cnpjRaizCertificado) {
                chamarAlert(`O CNPJ da filial ${jQuery(cnpjFilial).parent().find('input[type="hidden"][name^="abreviatura"]').val()} não pertence a raiz do CNPJ do certificado digital!`);

                e.stopImmediatePropagation();

                return false;
            }
        });
    });

    jQuery("#excluidosDOM").on('change', function aoExcluirFilialChange() {
        let valores = this.value.split(',');

        for (let valor of valores) {
            if (filiaisAdicionadas.includes(valor)) {
                let index = filiaisAdicionadas.indexOf(valor);
                if (index !== -1) {
                    filiaisAdicionadas.splice(index, 1);
                }
            }
        }
    });

    jQuery('#baixar_certificado').on('click', function baixarCertificado() {
        download('data:application/x-pkcs12;base64,' + $('#certificadoCadeia').val(), $('#nome_certificado').val(), "text/plain");
    });

    jQuery(".container-form").on('mouseenter', "[data-ajuda]:not([data-ajuda=''])", function aoEntrarHover() {
        var t = $(this);
        var attr = t.attr('data-ajuda');

        if (t.attr('class') != undefined) {
            if (t.attr('class').indexOf('-button') !== -1) {
                attr = t.parent().find('select').attr('data-ajuda');
            }
        }
        var elemento = $('#' + attr);
        $(".campo-helper h2").html(elemento.find('input[type=hidden]')[1].value);
        $(".descri-helper h3").html(elemento.find('input[type=hidden]')[0].value);
    }).on('mouseleave', "[data-ajuda]:not([data-ajuda=''])", function aoSairHover() {
            $('.campo-helper h2').html('Ajuda');
            $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);

        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'CertificadoDigitalControlador',
            async: true,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function aoCarregarPorAjax(jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                $('#certificadoBotao').hide();
                $('#baixar_certificado').show();

                $('#descricao').val(obj['descricao']);
                $('#senha').val(obj['senha']);
                $('#razaoSocialCertificado').text(obj['razaoSocial']);
                $('#cnpjCertificado').text(cnpj(obj['cnpj']));

                if (obj['quantidadeDiasVencimento'] > 30) {
                    jQuery('#validadeCertificado').html(`${obj['validade']} <span id="vencimento_lbl" style="color: green;font-weight: bolder;">(${obj['quantidadeDiasVencimento']} dias para vencer)</span>`);
                } else if (obj['dias_vencimento'] > 0 && obj['dias_vencimento'] <= 30) {
                    jQuery('#validadeCertificado').html(`${obj['validade']} <span id="vencimento_lbl" style="color: #d4ae27;font-weight: bolder;">(Seu certificado vencerá em ${obj['quantidadeDiasVencimento']} dias)</span>`);
                } else {
                    jQuery('#validadeCertificado').html(`${obj['validade']} <span id="vencimento_lbl" style="color: red;font-weight: bolder;">(Seu certificado venceu à ${obj['quantidadeDiasVencimento'] * -1} dias)</span>`);
                }

                if (obj['certificadoCadeiaBase64'] !== '') {
                    $('#lblCadeiaCertificado').text('V2');
                } else {
                    $('#lblCadeiaCertificado').text('V1');
                }

                $('#certificadoHidden').val(obj['certificadoOriginalBase64']);
                $('#certificadoCadeia').val(obj['certificadoCadeiaBase64']);
                $('#nome_certificado').val(obj['nomeArquivo']);

                if (obj['filiais'] !== undefined) {
                    jQuery.each(obj['filiais'], function loopFilialCertificado(index, filial) {
                        if (!filiaisAdicionadas.includes(filial['id'])) {
                            filiaisAdicionadas.push(filial['id']);
                            addDomFilial({
                                'inputId': filial['id'],
                                'abreviatura': filial['abreviatura'],
                                'cnpj': filial['cnpj'],
                                'cidade': filial['cidade'],
                                'uf': filial['uf'],
                            });
                        }
                    });
                }

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['atualizadoPor']['nome'], obj['atualizadoEm']);

                jQuery('#informacoesCertificado').show();
                jQuery('#cadeiaCertificado').show();
                jQuery('#containerFiliais').show();

                setTimeout(function esconderBloqueioTela() {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

});

function cnpj(v) {
    v = v.replace(/\D/g, "");                           //Remove tudo o que não é dígito
    v = v.replace(/^(\d{2})(\d)/, "$1.$2");             //Coloca ponto entre o segundo e o terceiro dígitos
    v = v.replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3"); //Coloca ponto entre o quinto e o sexto dígitos
    v = v.replace(/\.(\d{3})(\d)/, ".$1/$2");           //Coloca uma barra entre o oitavo e o nono dígitos
    v = v.replace(/(\d{4})(\d)/, "$1-$2");              //Coloca um hífen depois do bloco de quatro dígitos
    return v
}

function recusouPrompt() {
    adicionarNomeChaveAcesso(undefined);
}