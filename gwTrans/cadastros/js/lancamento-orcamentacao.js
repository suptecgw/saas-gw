let qtdDom = 0;
let qtdPlanos = 0;
let estruturaPlanoCusto = '';
let qtdAnalitica = 0;
let divs = [];

let atualizar = false;

$(document).ready(() => {
    $('#competencia').mask('00/0000').val(String((new Date().getMonth() + 1)).padStart(2, '0') + '/' + new Date().getFullYear());

    $('#filial').selectmenu().selectmenu("option", "position", {
        my: "top+15",
        at: "top center"
    }).selectmenu("menuWidget").addClass("selects-ui");

    $('.bloqueio-tela').show();
    $('.gif-bloq-tela').show();

    let unidadeDiv = $('.col-pl-vl-total.container-unidades');
    let planosContainer = $('.col-body-pl-custo');

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');

        $.post(homePath + '/OrcamentacaoControlador', {
            'acao': 'carregarOrcamentacao',
            'id': qs["id"]
        }, data => {
            if (data) {
                $('#competencia').val(data['competencia']);
                $('#filial').val(data['filial_id']).selectmenu("refresh");

                estruturaPlanoCusto = data['estrutura_plano_custo'];
                qtdAnalitica = estruturaPlanoCusto.split('.').length;

                adicionarUnidades(unidadeDiv, data['planos'][0]['unidades']);
                adicionarPlanos(planosContainer, data['planos']);
                criadoAlteradoAuditoria(data['criado_por'], data['criado_em'], data['atualizado_por'], data['atualizado_em']);
            }
        }, 'json');
    } else {
        $('.container-form').on('change', '#inputLocalizarOrcamentacao', function () {
            $('.bloqueio-tela').show();
            $('.gif-bloq-tela').show();

            let id = $(this).val().split('#@#')[1];
            
            if (id === undefined || id === '') {
                $('.bloqueio-tela').hide();
                $('.gif-bloq-tela').hide();

                return;
            }

            $.post(homePath + '/OrcamentacaoControlador', {
                'acao': 'carregarOrcamentacao',
                'id': id
            }, data => {
                if (data) {
                    // Atualizar valores dos inputs
                    $.each(data['planos'], (index, planoCusto) => {
                        let divConta = $('[data-conta="' + planoCusto['plano']['conta'] + '"]');

                        // Tipo de valor
                        divConta.find('input[type="radio"][value="' + planoCusto['tipo'] + '"]').click();

                        // Valores
                        if (planoCusto['tipo'] === 'g') {
                            let elemento = divConta.find('input[type="text"][id^="valor-total"]');
                            
                            if (elemento.masked === undefined) {
                                for (let i = 1; i <= 10; i++) {
                                    setTimeout(function() {
                                        elemento.val(elemento.masked(parseFloat(planoCusto['valor']).toFixed(2).replace(/\./g, '')));
                                    }, 500 * i);
                                }
                            } else {
                                elemento.val(elemento.masked(parseFloat(planoCusto['valor']).toFixed(2).replace(/\./g, '')));
                            }
                        } else {
                            // Por unidade de custo...
                            $.each(planoCusto['unidades'], (index, unidadeCusto) => {
                                let elemento = divConta.find('input[type="hidden"][id^="id-unidade"][value="' + unidadeCusto['unidade']['id'] + '"]').parent().find('input[type="text"]');

                                if (elemento.masked === undefined) {
                                    for (let i = 1; i <= 10; i++) {
                                        setTimeout(function() {
                                            elemento.val(elemento.masked(parseFloat(valor).toFixed(2).replace(/\./g, '')));
                                        }, 500 * i);
                                    }
                                } else {
                                    elemento.val(elemento.masked(parseFloat(unidadeCusto['valor']).toFixed(2).replace(/\./g, '')));
                                }
                            });
                        }
                    });

                    atualizarValoresTotaisOrcamentacao();

                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }
            }, 'json');
        });

        $('#inputLocalizarOrcamentacao').inputMultiploGw({
            readOnly: 'true',
            classes: 'esconder-input',
            width: '97%',
            isSimples: 'true',
            notX: 'true'
        });

        // Substituir label de ao salvar continuar incluindo
        let labelSalvar = $('label[for="chk-ao-salvar"]');

        // Adicionar novo botão para copiar
        $('.header').append(
            $('<span>', {
                'id': 'copiar-lancamento',
                'class': 'bt bt-copiar-lancamento'
            }).html('<label><i class="far fa-copy"></i> Copiar lançamento</label>')
                .on('click', function () {
                    controlador.acao('abrirLocalizar', 'localizarOrcamentacao');
                })
        );

        labelSalvar.text('');
        labelSalvar.html('<span></span>Salvar as Mesmas informações para as <input type="number" id="qtd_salvar_orcamentacoes" name="qtd_salvar_orcamentacoes" style="width: 40px;text-align: right;margin-left: 10px;margin-right: 10px;" value="0" min="0" max="99" onkeydown="limit(this);" onkeyup="limit(this);"> próximas competências');

        $('.section-check').css('left', 'calc(43% - 165px)');

        $.post(homePath + '/OrcamentacaoControlador', {
            'acao': 'carregarDadosTelaOrcamentacao'
        }, data => {
            if (data) {
                estruturaPlanoCusto = data['estrutura_plano_custo'];
                qtdAnalitica = estruturaPlanoCusto.split('.').length;

                adicionarUnidades(unidadeDiv, data['unidades']);
                adicionarPlanos(planosContainer, data['planos'], data['unidades']);
            }
        }, 'json');
    }

    $('.col-body-pl-custo').on('scroll', function () {
        $('.container-unidades').prop("scrollLeft", this.scrollLeft);
    }).on('click', '.coluna-plano-custo', function () {
        let elemento = $(this);

        let botao = elemento.find('.expandir-icone');

        let ativado = botao.hasClass('fa-minus-square');
        let divPlano = elemento.parent();
        let divLinha = divPlano.parent();

        let planoPai = divPlano.attr('data-conta');

        if (ativado) {
            botao.removeClass('fa-minus-square').addClass('fa-plus-square');
            divLinha.parent().find('div[data-plano-pai^="' + planoPai + '"] .fa-minus-square').trigger('click');
        } else {
            botao.removeClass('fa-plus-square').addClass('fa-minus-square');
        }

        divLinha.parent().find('div[data-plano-pai="' + planoPai + '"]').parent().toggle();
    }).on('change', '.coluna-tipo input[type="radio"]', function () {
        let elemento = $(this);

        let valor = elemento.val();
        let linha = elemento.parent().parent().parent();

        let inputValorUnidades = linha.find('span[data-gw-grupo-lista="unidades"] input[type="text"]');
        let inputValorGeral = linha.find('.coluna-valor-total input[type="text"]');

        if (podeAlterar) {
            if (valor === 'g') {
                // Geral
                inputValorUnidades.val('0,00').attr('disabled', 'disabled').attr('readonly', 'readonly');
                inputValorGeral.removeAttr('disabled').removeAttr('readonly');
            } else {
                // Por unidade de custo
                inputValorGeral.val('0,00').attr('disabled', 'disabled').attr('readonly', 'readonly');
                inputValorUnidades.removeAttr('disabled').removeAttr('readonly');
            }
        }
    }).on('change', '.coluna-valor-total input[type="text"]', function () {
        let elemento = $(this);

        let valor = elemento.val();

        if (valor === undefined || valor === '') {
            elemento.val('0,00');
        } else {
            elemento.val(elemento.masked(parseFloat(valor.replace(/\./g, '').replace(/,/g, '.')).toFixed(2).replace(/\./g, '')));
            let divPlano = elemento.parent().parent().parent();
            let planoPai = divPlano.attr('data-plano-pai');

            atualizarValoresPlano(planoPai);
        }
    }).on('change', 'span[data-gw-grupo-lista="unidades"] input[type="text"]', function () {
        let elemento = $(this);

        let valor = elemento.val();

        if (valor === undefined || valor === '') {
            elemento.val('0,00');
        } else {
            elemento.val(elemento.masked(parseFloat(valor.replace(/\./g, '').replace(/,/g, '.')).toFixed(2).replace(/\./g, '')));

            let divPlano = elemento.parent().parent().parent().parent().parent();
            let plano = divPlano.attr('data-conta');

            atualizarValoresPlanoUnidade(plano);
        }
    });

    $(window).on('resize', function () {
        let size = $('#formCadastro > div').height();

        $('.col-body-pl-custo').trigger('scroll');

        $('.body-pl-custo').css('height', size - 160);
        $('.container-tela-pl-custo').css('height', size - 102);

        // Redimesionar colunas:
        $('.coluna-plano-custo')
            .css('width', $('.col-pl-custo')[0].getBoundingClientRect().width);
        $('.coluna-tipo')
            .css('width', $('.col-pl-tipo')[0].getBoundingClientRect().width - 1)
            .css('left', $('.col-pl-custo')[0].getBoundingClientRect().width + 1);
        $('.coluna-valor-total')
            .css('width', $('.col-pl-vl-total')[0].getBoundingClientRect().width - 1)
            .css('left', ($('.col-pl-custo')[0].getBoundingClientRect().width + $('.col-pl-tipo')[0].getBoundingClientRect().width) + 1)
            .find('input[type="text"]').css('width', $('.col-pl-vl-total')[0].getBoundingClientRect().width - 40);
    }).trigger('resize');

    $('.btn-aba').on('click', function () {
        setTimeout(() => {
            $(window).trigger('resize');
        }, 500);
    });

    $('.bt-salvar').on('click', e => {
        let competenciaElemento = $('#competencia');

        if (competenciaElemento.val() === undefined || competenciaElemento.val() === '') {
            chamarAlert('O campo Competência está inválido!');

            e.stopImmediatePropagation();
            
            return;
        }

        let competenciaSplit = competenciaElemento.val().split('/');

        if (competenciaSplit.length !== 2
            || parseInt(competenciaSplit[0]) < 1
            || parseInt(competenciaSplit[0]) > 12
            || competenciaSplit[1].length !== 4) {
            chamarAlert('O campo Competência está inválido!');

            e.stopImmediatePropagation();
        }
    });

    $('#icone-atualizar').on('click', function () {
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $('[data-nivel="1"]').find('.fa-minus-square').trigger('click');

        atualizar = true;

        $.post(homePath + '/OrcamentacaoControlador', {
            'acao': 'carregarDadosTelaOrcamentacao'
        }, data => {
            if (data) {
                estruturaPlanoCusto = data['estrutura_plano_custo'];
                qtdAnalitica = estruturaPlanoCusto.split('.').length;

                adicionarUnidades(unidadeDiv, data['unidades'], true);
                adicionarPlanos(planosContainer, data['planos'], data['unidades']);
            }
        }, 'json');
    });
    
    if (!podeAlterar) {
        document.getElementsByClassName('section-bt')[0].style.display = 'none';
    }

    jQuery("span[class*='-button']").hover(
        function () {
            jQuery(".campo-helper h2").html($($(this).context).parent().find('input[type="hidden"]')[1].value);
            jQuery(".descri-helper h3").html($($(this).context).parent().find('input[type="hidden"]')[0].value);
        },
        function () {
            jQuery('.campo-helper h2').html('Ajuda');
            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );

    jQuery('.body-pl-custo').on('mouseenter', '.coluna-plano-custo,.coluna-tipo,.coluna-valor-total,.coluna-unidade', function () {
        let ajuda = jQuery(this).attr('data-ajuda');
        
        let elementoAjuda = jQuery('#' + ajuda);

        jQuery(".campo-helper h2").text(elementoAjuda.find('input[type="hidden"]')[1].value);
        jQuery(".descri-helper h3").text(elementoAjuda.find('input[type="hidden"]')[0].value);
    }).on('mouseleave', '', function () {
        jQuery('.campo-helper h2').text('Ajuda');
        jQuery(".descri-helper h3").text('Passe o mouse sobre o campo que deseja ajuda.');
    });
});

const obterTamanhoScrollbar = () => {
    let scrollDiv = document.createElement("div");
    scrollDiv.className = "scrollbar-measure";
    document.body.appendChild(scrollDiv);

    let scrollbarWidth = scrollDiv.offsetWidth - scrollDiv.clientWidth;

    document.body.removeChild(scrollDiv);

    return scrollbarWidth;
};

const atualizarValoresPlano = planoPai => {
    if (planoPai !== '') {
        let divPai = $('div[data-plano-pai="' + planoPai + '"]');

        let valorTotal = divPai.find('input[id^="valor-total"]').map(parseFloatSomar).toArray().reduce(funcaoSomar, 0);

        divPai.first().attr('data-conta');
        let divConta = $('div[data-conta="' + planoPai + '"]');
        let inputConta = divConta.find('.coluna-valor-total input[id^="valor-total"]');

        inputConta.val(inputConta.masked(valorTotal.toFixed(2).replace(/\./g, '')));

        // Unidades
        divPai.first().find('.coluna-unidade').each((index) => {
            let valorUnidade = divPai.find('.coluna-unidade:nth-child(' + (index + 1) + ') input[type="text"]').map(parseFloatSomar).toArray().reduce(funcaoSomar, 0);

            let input = divConta.find('.coluna-unidade:nth-child(' + (index + 1) + ') input[type="text"]');
            input.val(input.masked(valorUnidade.toFixed(2).replace(/\./g, '')));
        });

        let pai = divConta.attr('data-plano-pai');

        if (pai !== undefined && pai !== '') {
            atualizarValoresPlano(pai);
        }
    }
};

const atualizarValoresPlanoUnidade = conta => {
    let divPai = $('div[data-conta="' + conta + '"]');
    let tipoOrcamentacao = divPai.find('input[type="radio"]:checked');

    if (tipoOrcamentacao.val() === 'u') {
        let valoresUnidade = divPai.find('.coluna-unidade input[type="text"]').map(parseFloatSomar).toArray().reduce(funcaoSomar, 0);

        let inputValorTotal = divPai.find('.coluna-valor-total input[id^="valor-total"]');

        inputValorTotal.val(inputValorTotal.masked(valoresUnidade.toFixed(2).replace(/\./g, '')));

        atualizarValoresPlano(divPai.attr('data-plano-pai'));
    }
};

const adicionarUnidades = (unidadeDiv, unidades, atualizar) => {
    let primeiraUnidade = unidadeDiv.find('div').first();
    let ultimaUnidade = unidadeDiv.find('div').last();

    ultimaUnidade.css('width', primeiraUnidade.width());

    $.each(unidades, (index, unidadeCusto) => {
        // Verificar se não tem alguma unidade de custo que não tem na tela.
        if ($('[data-unidade-id="' + unidadeCusto['unidade']['id'] + '"]').length === 0) {
            unidadeDiv.append($('<div>', {
                'class': 'col-pl-vl-total1',
                'data-unidade-id': unidadeCusto['unidade']['id']
            }).text(unidadeCusto['unidade']['descricao']));

            if (atualizar) {
                $('.unidades').each(function (index, el) {
                    let elemento = $(el);
                    let divPai = elemento.parent();
                    adicionarColunaUnidade(elemento, parseInt(divPai.attr('data-qtd-dom')), elemento.find('.coluna-unidade').length - 1, unidadeCusto, divPai.attr('data-analitica'));
                });
            }
        }
    });

    ultimaUnidade = unidadeDiv.find('div').last();
    ultimaUnidade.css('width', ultimaUnidade.width() + obterTamanhoScrollbar());
};

const parseFloatSomar = function () {
    return parseFloat($(this).val().replace(/\./g, '').replace(/,/g, '.'))
};

const funcaoSomar = (a, b) => a + b;

const adicionarPlanos = (planosContainer, planos, unidades) => {
    qtdPlanos = planos.filter(planoCusto => planoCusto['plano']['conta'].length === 1).length;
    
    if (qtdDom === planos.length) {
        $('.bloqueio-tela').hide();
        $('.gif-bloq-tela').hide();

        if (atualizar) {
            chamarAlert('Atualizado com sucesso!');
            atualizar = false;
        }

        return;
    }

    $.each(planos, (index, planoCusto) => {
        if ($('[data-conta="' + planoCusto['plano']['conta'] + '"]').length === 0) {
            ++qtdDom;

            let unidade = planoCusto['unidades'];

            if (unidades !== undefined) {
                unidade = unidades
            }

            sessionStorage.setItem('unidades_' + qtdDom, JSON.stringify(unidade));

            let planoPai = (planoCusto['plano']['conta'].substring(0, planoCusto['plano']['conta'].lastIndexOf('.')));
            let div = $('<div>', {
                'class': 'linha',
                'style': (planoCusto['plano']['conta'].split('.').length !== 1 ? 'display: none;' : '')
            }).load(homePath + '/gwTrans/cadastros/html-dom/dom-orcamentacao-plano-custo.jsp' +
                '?qtdDom=' + qtdDom +
                '&id=' + planoCusto['id'] +
                '&idPlano=' + planoCusto['plano']['id'] +
                '&conta=' + encodeURIComponent(planoCusto['plano']['conta']) +
                '&descricao=' + encodeURIComponent(planoCusto['plano']['descricao']) +
                '&tipo=' + planoCusto['tipo'] +
                '&valor=' + planoCusto['valor'] +
                '&isAnalitica=' + (planoCusto['plano']['conta'].split('.').length === qtdAnalitica) +
                '&nivel=' + planoCusto['plano']['conta'].split('.').length +
                '&qtdAnalitica=' + qtdAnalitica +
                '&planoPai=' + planoPai +
                '&podeAlterar=' + podeAlterar
            );

            // verifica se tem um plano pai para colocar
            let divProcura = divs.reverse().find(value => value['conta'].startsWith(planoPai));

            if (divProcura !== undefined) {
                divProcura['div'].after(div);
            } else {
                planosContainer.append(div);
            }

            divs.push({'conta': planoCusto['plano']['conta'], 'div': div});
        }
    });
};

const adicionarColunaUnidade = (divUnidades, qtdDom, index, unidade, analitica) => {
    var inputValor = $('<input>', {
        'type': 'text',
        'class': 'input-form-gw',
        'id': "valor" + qtdDom + "_" + index,
        'name': "valor" + qtdDom + "_" + index,
        'value': (unidade['valor'] === undefined ? '0.00' : unidade['valor']),
        'required': 'required',
        'data-mask': '#.##0,00',
        'data-mask-reverse': 'true',
    });

    if (analitica === 'true') {
        inputValor.attr('readonly', 'readonly');
    }

    inputValor.attr('disabled', 'disabled');

    divUnidades.append(
        $('<div>', {'class': 'coluna-unidade', 'data-ajuda': 'valor_und_custo_ajuda'}).append(
            $('<span>', {'class': 'container-input-form-gw'}).append(
                $('<span>', {
                    'data-gw-grupo-objeto': '',
                    'data-gw-grupo-lista': 'unidades',
                    'data-gw-campo-grupo-serializado': 'dom-plano-custo' + qtdDom
                }).append(
                    $('<input>', {
                        'type': 'hidden',
                        'id': "id" + qtdDom + "_" + index,
                        'name': "id" + qtdDom + "_" + index,
                        'value': (unidade['id'] === undefined ? '0' : unidade['id']),
                    })
                ).append(
                    $('<input>', {
                        'type': 'hidden',
                        'id': "id-unidade" + qtdDom + "_" + index,
                        'name': "id-unidade" + qtdDom + "_" + index,
                        'value': unidade['unidade']['id'],
                    })
                ).append(inputValor)
            )
        )
    );
};

const atualizarValoresTotaisOrcamentacao = () => {
    let vistos = [];

    jQuery('div[data-analitica]').each(function (index, e) {
        let elemento = $(e);
        let pai = elemento.attr('data-plano-pai');

        elemento.find('input[type="radio"][value="u"]:checked').trigger('change');

        if (elemento.find('input[type="radio"]:checked').val() === 'g') {
            if (!vistos.includes(pai)) {
                vistos.push(pai);

                elemento.find('.coluna-valor-total input[type="text"]').first().trigger('change');
            }
        } else {
            elemento.find('span[data-gw-grupo-lista="unidades"] input[type="text"]').first().trigger('change');
        }
    });
};

function limit(element) {
    var max_chars = 2;

    if (element.value.length > max_chars) {
        element.value = element.value.substr(0, max_chars);
    }
}