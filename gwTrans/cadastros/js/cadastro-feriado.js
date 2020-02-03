$(document).ready(function () {
// funções e etc aqui

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();
        $.ajax({
            url: 'FeriadoControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);
                $('#descricao').val(obj['descricao']);
                $('#slc-dia').val(obj['dia']);
                $('#slc-mes').val(obj['mes']);
                $('#slc-ano').val(obj['ano']);
                $('#slc-tipo').val(obj['tipoFeriado']);
                if (obj['feriadoFinanceiro']) {
                    $('#ck-finan').attr('checked', 'checked');
                }

                if (obj['feriadoOperacional']) {
                    $('#ck-opera').attr('checked', 'checked');
                }

                if (obj['tipoFeriado'] === 'm') {
                    // se for municipio
                  
                        mostrarContainerDom(obj['tipoFeriado']);
                        if (obj['municipio'] !== undefined) {
                            $.each(obj['municipio'], function (index) {
                                addDom('m', this.idFeriadoMunicipio, this.cidade.descricaoCidade + '!!' + this.cidade.idcidade);
                            });
                        }
                    
                } else if (obj['tipoFeriado'] === 'e') {
                    // se for estado
                    mostrarContainerDom(obj['tipoFeriado']);
                    if (obj['estado'] !== undefined) {
                        $.each(obj['estado'], function (index) {
                            addDom('e', this.id, this.uf);
                        });
                    }
                }

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['atualizadoPor']['nome'], obj['atualizadoEm']);

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

    jQuery("#slc-dia, #slc-mes,#slc-ano,#slc-tipo,#slc-estados").each(function () {
        $(this).selectmenu().selectmenu("option", "position", {
            my: "top+15",
            at: "top center"
        }).selectmenu("menuWidget").addClass("selects-ui");
    });
    jQuery('#slc-tipo').selectmenu({change: function () {
            mostrarContainerDom($(this).val());
        }});
    $('.header-dom > img').on('click', function () {
        addDom($('#slc-tipo').val(), 0, '');
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
});

jQuery('.bt-salvar').on('click', function (e) {
    // Validar data
    var anoAtual = new Date().getFullYear();
    var data = jQuery('#slc-dia').val() + '/' + jQuery('#slc-mes').val();

    if (jQuery('#slc-ano').val() === '0') {
        // se for todo os anos, pega o ano atual e passa pro validador
        data += '/' + anoAtual;
    } else {
        data += '/' + jQuery('#slc-ano').val();
    }

    if (!validaDataDatebox(data)) {
        chamarAlert('A data do feriado não é uma data válida!');

        e.stopImmediatePropagation();
    }
});

function mostrarContainerDom(valor) {
    if (valor === 'e') {
        // estado
        $('#container-dom-estado').show();
        $('#container-dom-municipio').hide();
        $('#container-dom-municipio .body').html('');
    } else if (valor === 'm') {
        // municipio
        $('#container-dom-estado').hide();
        $('#container-dom-estado .body').html('');
        $('#container-dom-municipio').show();
    } else {
        $('#container-dom-estado').hide();
        $('#container-dom-municipio').hide();
        $('#container-dom-municipio .body').html('');
        $('#container-dom-estado .body').html('');
    }
}

var qtdDomEstado = 0;
var qtdDomMunicipio = 0;
function addDom(valor, id, valorCampo) {
    if (valor === 'e') {
        // estado
        var container = $('#container-dom-estado').find('.body');
        var div = $('<div class="container-item-dom-estado celula-zebra">');
        $(container).append(div);
        $(div).load(homePath + '/gwTrans/cadastros/html-dom/dom-feriado-estado.jsp?qtdDom=' + (++qtdDomEstado) + '&idEstado=' + id + '&valorCampo=' + encodeURI(valorCampo));
    } else if (valor === 'm') {
        // municipio
        var container = $('#container-dom-municipio').find('.body');
        var div = $('<div class="container-item-dom-municipio celula-zebra">');
        $(container).append(div);
        $(div).load(homePath + '/gwTrans/cadastros/html-dom/dom-feriado-municipio.jsp?qtdDom=' + (++qtdDomMunicipio) + '&idMunicipio=' + id + '&valorCampo=' + encodeURI(valorCampo));
    }
}

function toLocalizar(tipoLocalizar, input) {
    if (tipoLocalizar == 'localizarCidade') {
        jQuery('#localizarCidade').attr('input', input);
        controlador.acao('abrirLocalizar', 'localizarCidade');
    } else {
        chamarAlert('O localizar não foi configurado! ' + input);
    }
}

function excluirItemDom(campoId) {
    $(itemExcluir).parent().parent().parent().animate({
        'margin-left': '1200px'
    }, 500, function () {
        if (campoId !== "") {
            if (campoId.includes('idEstado')) {
                if (jQuery("#excluidosDOMEstado").val() !== '') {
                    jQuery("#excluidosDOMEstado").val(jQuery("#excluidosDOMEstado").val() + ',');
                }
                jQuery("#excluidosDOMEstado").val(jQuery("#excluidosDOMEstado").val() + jQuery("#" + campoId).val());
            } else {
                if (jQuery("#excluidosDOMCidade").val() !== '') {
                    jQuery("#excluidosDOMCidade").val(jQuery("#excluidosDOMCidade").val() + ',');
                }

                jQuery("#excluidosDOMCidade").val(jQuery("#excluidosDOMCidade").val() + jQuery("#" + campoId).val());
            }
        }
        $(this).remove();
    });
}

function reload() {
    window.location.reload();
}


function carregarAjudaData() {
    jQuery(".ativa-helper-data-ajuda").hover(
            function () {
                var t = $(this);
                var attr = t.attr('data-ajuda');

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