function marcarItemAdicionar(e) {
    var elemento = jQuery(e);
    if (elemento.hasClass('selecionado')) {
        elemento.removeClass('selecionado');
        var div = elemento.find('.cidade');
        jQuery(div).find('img').remove();
    } else {
        elemento.addClass('selecionado');
        var div = elemento.find('.cidade');
        jQuery(div).append('<img src="' + homePath + '/assets/img/certo.png" width="15px" style="float: left; margin-right: 5px;">');
    }
}

function marcarItemRemover(e) {
    var elemento = jQuery(e);
    elemento.removeClass('selecionado');

    if (elemento.hasClass('remover-selecionado')) {
        elemento.removeClass('remover-selecionado');
        var div = elemento.find('.cidade');
        jQuery(div).find('img').remove();
    } else {
        elemento.addClass('remover-selecionado');
        var div = elemento.find('.cidade');
        jQuery(div).append('<img src="' + homePath + '/assets/img/certo.png" width="15px" style="float: left; margin-right: 5px;">');
    }
}

function passarItensSelecionados() {
    var cloneSelecionado = jQuery('.selecionado').clone();
    jQuery('.selecionado').remove();
    jQuery(cloneSelecionado).prependTo('#topo-resultados-col2');
    jQuery(cloneSelecionado).find('img').remove();
    jQuery(cloneSelecionado).removeClass('selecionado');
    jQuery(cloneSelecionado).attr('onclick', 'marcarItemRemover(this);');
}

function voltarItensSelecionados() {
    var cloneSelecionado = jQuery('.remover-selecionado').clone();
    jQuery('.remover-selecionado').remove();
    jQuery(cloneSelecionado).prependTo('#topo-resultados-col1');
    jQuery(cloneSelecionado).find('img').remove();
    jQuery(cloneSelecionado).removeClass('remover-selecionado');
    jQuery(cloneSelecionado).attr('onclick', 'marcarItemAdicionar(this);');
}

function passarTodosItens() {
    var cloneItens = jQuery('#topo-resultados-col1 li').clone();
    jQuery('#topo-resultados-col1 li').remove();
    jQuery(cloneItens).prependTo('#topo-resultados-col2');

    var index = 0;
    while (cloneItens[index] !== undefined) {
        jQuery(cloneItens[index]).removeClass('selecionado');
        jQuery(cloneItens[index]).removeClass('remover-selecionado');

        if (jQuery(cloneItens[index]).find('img') !== undefined) {
            jQuery(cloneItens[index]).find('img').remove();
        }

        jQuery(cloneItens[index]).attr('onclick', 'marcarItemRemover(this);');
        index++;
    }
}

function voltarTodosItens() {

    var cloneItens = jQuery('#topo-resultados-col2 li').clone();
    jQuery('#topo-resultados-col2 li').remove();
    jQuery(cloneItens).prependTo('#topo-resultados-col1');

    var index = 0;
    while (cloneItens[index] !== undefined) {
        jQuery(cloneItens[index]).removeClass('selecionado');
        jQuery(cloneItens[index]).removeClass('remover-selecionado');

        if (jQuery(cloneItens[index]).find('img') !== undefined) {
            jQuery(cloneItens[index]).find('img').remove();
        }

        jQuery(cloneItens[index]).attr('onclick', 'marcarItemAdicionar(this);');
        index++;
    }
}

jQuery(document).ready(function () {
    jQuery('.coluna-centro').hide('fast');
    jQuery('.coluna-escolhidas').hide('fast');
    jQuery('.topo-resultados-estado').css('margin-left', '25px');

    if (jQuery('.opcoes-avancadas').attr('marcado') === 'false') {
        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var cidade = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.cidade').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.controleLocalizarCidades('finalizado','" + cidade + "')");
            i++;
        }
    } else {
        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var cidade = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.cidade').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "marcarItemAdicionar(this);");
            i++;
        }
    }

    jQuery('#inpt-filtrar-por').inputMultiploGw({
        width: '85%'
    });


    jQuery('#chkOpcoesAvancadas').click(function () {
        opcoesAvancadas();

    });



    jQuery('.fechar').click(function () {
        parent.controleLocalizarCidades('fechar', null);
    });


    jQuery("#topo-resultados-col1, #topo-resultados-col2").sortable({
        connectWith: ".connectedSortable",
        start: function (e, item) {
        },
        helper: function (e, item) {
            if (jQuery(item).hasClass('selecionado')) {
                var helper = $('<li/>');
                if (!item.hasClass('selecionado')) {
                    var a = item.addClass('selecionado').siblings().removeClass('selecionado');
                }
                var elements = item.parent().children('.selecionado').clone();
                item.data('multidrag', elements).siblings('.selecionado').remove();
                return helper.append(elements);
            } else {
                var helper = $('<li/>');
                if (!item.hasClass('remover-selecionado')) {
                    var a = item.addClass('remover-selecionado').siblings().removeClass('remover-selecionado');
                }
                var elements = item.parent().children('.remover-selecionado').clone();
                item.data('multidrag', elements).siblings('.remover-selecionado').remove();
                return helper.append(elements);
            }

        },
        stop: function (e, info) {
            info.item.after(info.item.data('multidrag')).remove();
        },
        update: function (event, ui) {
            if (jQuery(event.target).attr('id') === 'topo-resultados-col2') {
                setTimeout(function () {
                    var lis = jQuery('#topo-resultados-col2 li');
                    var i = 0;
                    while (lis[i] !== undefined) {
                        jQuery(lis[i]).removeClass('selecionado');
                        jQuery(lis[i]).removeClass('remover-selecionado');
                        var img = jQuery(lis[i]).find('img');
                        if (img !== undefined) {
                            jQuery(img).remove();
                        }
                        jQuery(lis[i]).attr('onclick', 'marcarItemRemover(this);');
                        i++;
                    }
                }, 300);

            } else if (jQuery(event.target).attr('id') === 'topo-resultados-col1') {
                setTimeout(function () {
                    var lis = jQuery('#topo-resultados-col1 li');
                    var i = 0;
                    while (lis[i] !== undefined) {
                        jQuery(lis[i]).removeClass('selecionado');
                        jQuery(lis[i]).removeClass('remover-selecionado');
                        var img = jQuery(lis[i]).find('img');
                        if (img !== undefined) {
                            jQuery(img).remove();
                        }

                        jQuery(lis[i]).attr('onclick', 'marcarItemAdicionar(this);');
                        i++;
                    }
                }, 300);

            }
        }

    }).disableSelection();


});

function opcoesAvancadas() {
    var elemento = jQuery('.opcoes-avancadas');
    var velocidade = 200;
    jQuery('.topo-resultados-estado').css('margin-left', '9px');

    if (elemento.attr('marcado') === 'false') {
        jQuery('.cidade').css('text-decoration', 'none');
        jQuery('.cidade').css('color', '#444');

        elemento.attr('marcado', 'true');
        //                        elemento.css('background','#13385c');

        jQuery('.footer-localizar').show('fast');

        jQuery('.coluna-pesquisa').animate({
            'width': '43%'
        }, velocidade, function () {
            jQuery('.coluna-centro').animate({
                'width': '8%'
            }, velocidade, function () {
                jQuery('.coluna-centro').show('fast');
            });
            jQuery('.coluna-escolhidas').animate({
                'width': '44%'
            }, velocidade, function () {
                jQuery('.coluna-escolhidas').show('fast');
            });
        });


        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var cidade = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.cidade').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "marcarItemAdicionar(this);");
            i++;
        }

    } else if (elemento.attr('marcado') === 'true') {
        jQuery('.cidade').css('text-decoration', 'underline');
        jQuery('.cidade').css('color', '#13385c');

        elemento.attr('marcado', 'false');
        //                        elemento.css('background','#375471');

        jQuery('.coluna-escolhidas').hide('fast');
        jQuery('.footer-localizar').hide('fast');

        jQuery('.topo-resultados-estado').css('margin-left', '25px');

        jQuery('.coluna-pesquisa').animate({
            'width': '97%'
        }, velocidade, function () {

            jQuery('.coluna-centro').animate({
                'width': '1%'
            }, velocidade, function () {
                jQuery('.coluna-centro').hide('fast');
            });

            jQuery('.coluna-escolhidas').animate({
                'width': '44%'
            }, velocidade, function () {
            });
        });



        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var cidade = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.cidade').html();
//            var uf = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.estado').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.controleLocalizarCidades('finalizado','" + cidade + "',true)");
            i++;
        }


    }
}

function enviarCidadesSelecionadas() {
    var lis = jQuery('#topo-resultados-col2 li');

    parent.removerValorInput('inptCidade');
    if (lis.size() > 0) {
        var index = 0;
        while (lis[index]) {
            var cidade = jQuery(lis[index]).find('.cidade').html();
            var estado = jQuery(lis[index]).find('.estado').html();
            parent.controleLocalizarCidades('finalizado', cidade + '!@!' + estado);
            index++;
        }
    } else {
        parent.controleLocalizarCidades('mensagem', 'Selecione ao menos uma cidade.');
    }

    voltarTodosItens();
    limparCidades();
}

function popularListaCidades(cidade) {
    if (jQuery('#chkOpcoesAvancadas').prop('checked') == true) {
                    jQuery('#topo-resultados-col1').append('<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="cidade">' + cidade.cidade + '</div><div class="estado">' + cidade.uf + '</div></li>');
                    jQuery('.cidade').css('text-decoration', 'none');
                    jQuery('.cidade').css('color', '#444');
        } else {
        jQuery('#topo-resultados-col1').append('<li class="ui-state-default" onclick="parent.controleLocalizarCidades(' + "'" + "finalizado" + "'" + ',popularOnClick(this),true);"><div class="cidade">' + cidade.cidade + '</div><div class="estado">' + cidade.uf + '</div></li>');
        jQuery('.cidade').css('text-decoration', 'underline');
        jQuery('.cidade').css('color', '#13385c');
    }
}

function popularListaCidadesEscolhidas(cidade, uf) {
    if (jQuery('#chkOpcoesAvancadas').prop('checked') == true) {
        jQuery('#topo-resultados-col2').append('<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="cidade">' + cidade + '</div><div class="estado">' + uf + '</div></li>');
        jQuery('.cidade').css('text-decoration', 'none');
        jQuery('.cidade').css('color', '#444');

    } else {
        jQuery('#topo-resultados-col2').append('<li class="ui-state-default" onclick="parent.controleLocalizarCidades(' + "'" + "finalizado" + "'" + ',popularOnClick(this),true);"><div class="cidade">' + cidade + '</div><div class="estado">' + uf + '</div></li>');
        jQuery('.cidade').css('text-decoration', 'underline');
        jQuery('.cidade').css('color', '#13385c');
    }
}

function popularPaginacao(paginacao) {
    var paginas = parseInt(paginacao.paginas);

    jQuery('#span-total-paginas').html('de ' + paginas);
    jQuery('#pagina').val(paginacao.paginaAtual);

    jQuery('#paginaAtual').val(paginacao.paginaAtual);
    jQuery('#totalPaginas').val(paginas);

    if (paginacao.paginaAtual > 1) {
        jQuery('#anterior').prop('href', 'javascript:anteriorLocalizar()');
        jQuery('#anterior').prop('class', 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain');
    } else {
        jQuery('#anterior').prop('href', 'javascript:;');
        jQuery('#anterior').prop('class', 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled');
    }

    if (paginas >= 1 && paginacao.paginaAtual < paginas) {
        jQuery('#proxima').prop('href', 'javascript:proximaLocalizar();');
        jQuery('#proxima').prop('class', 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain');
    } else {
        jQuery('#proxima').prop('href', 'javascript:;');
        jQuery('#proxima').prop('class', 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled');
    }

//    if (parseInt(jQuery('#paginaAtual').val()) > 1) {
//        jQuery('#anterior').prop('href', 'javascript:anterior();');
//        jQuery('#anterior').prop('class', 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain');
//    } else {
//        jQuery('#anterior').prop('href', '');
//        jQuery('#anterior').prop('class', 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled');
//    }
//
//    if (parseInt(jQuery('#totalPaginas').val()) >= 1 && parseInt(jQuery('#paginaAtual').va()) < parseInt(jQuery('#totalPaginas').val())) {
//        jQuery('#proxima').prop('href', 'javascript:proxima();');
//        jQuery('#proxima').prop('class', 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain');
//    } else {
//        jQuery('#proxima').prop('href', 'javascript:proxima();');
//        jQuery('#proxima').prop('class', 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled');
//    }
//    var html = jQuery('#divPaginacao').html();
//    jQuery('#divPaginacao').append(html);

}

function popularOnClick(element) {
    return jQuery(element).find('.cidade').html() + "!@!" + jQuery(element).find('.estado').html();
}
