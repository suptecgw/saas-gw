function marcarItemAdicionar(e) {
    var elemento = jQuery(e);
    if (elemento.hasClass('selecionado')) {
        elemento.removeClass('selecionado');
        var div = elemento.find('.nome');
        jQuery(div).find('img').remove();
    } else {
        elemento.addClass('selecionado');
        var div = elemento.find('.nome');
        jQuery(div).append('<img src="' + homePath + '/assets/img/certo.png" width="15px" style="float: left; margin-right: 5px;">');
    }
}

function marcarItemRemover(e) {
    var elemento = jQuery(e);
    elemento.removeClass('selecionado');

    if (elemento.hasClass('remover-selecionado')) {
        elemento.removeClass('remover-selecionado');
        var div = elemento.find('.nome');
        jQuery(div).find('img').remove();
    } else {
        elemento.addClass('remover-selecionado');
        var div = elemento.find('.nome');
        jQuery(div).append('<img src="' + homePath + '/assets/img/certo.png" width="15px" style="float: left; margin-right: 5px;">');
    }
}

/*
 * Funcao responsavel por validar se existe um item que j� foi escolhido.
 */
function podeEscolher(clone) {
    var i = 0;
    while (jQuery('#topo-resultados-col2').find('li')[i]) {
        if (jQuery(jQuery('#topo-resultados-col2').find('li')[i]).find('input[type=hidden]').val() === jQuery(clone).find('input[type=hidden]').val()) {
            parent.chamarAlert('O motorista "' + jQuery(jQuery('#topo-resultados-col2').find('li')[i]).find('.nome').html() + '" j� foi selecionado.');
            return false;
        }
        i++;
    }
    return true;
}

function passarItensSelecionados() {
    var cloneSelecionado = jQuery('.selecionado').clone();
    if (!podeEscolher(cloneSelecionado))
        return false;

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
    if (!podeEscolher(cloneItens))
        return false;
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
    jQuery('#chkOpcoesAvancadas').click(function () {
        if (jQuery(this).prop('checked')) {
            jQuery('.envolve-topo').css('width', '700px');
            jQuery('.envolve-resultados').css('width', '750px');

            jQuery('.resultados').css('overflow-x', 'scroll');
            jQuery('.resultados').css('overflow-y', 'hidden');
        } else {
            jQuery('.envolve-topo').animate({
                'width': '97%'
            });

            jQuery('.resultados').css('overflow', 'hidden');
        }
    });


    jQuery('.coluna-centro').hide('fast');
    jQuery('.coluna-escolhidas').hide('fast');
    jQuery('.topo-resultados-estado').css('margin-left', '25px');

    if (jQuery('.opcoes-avancadas').attr('marcado') === 'false') {
        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var nome = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.nome').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.controleLocalizarMotoristas('finalizado','" + nome + "',true)");
            i++;
        }
    } else {
        var i = 0;
        while (jQuery('#topo-resultados-col1 li')[i] !== undefined) {
            var nome = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.nome').html();
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
        jQuery('#topo-resultados-col2 li').remove();
        parent.controleLocalizarMotoristas('fechar', null);
    });


    jQuery("#topo-resultados-col1, #topo-resultados-col2").sortable({
        connectWith: ".connectedSortable",
        start: function (e, item) {
            if (jQuery(e.currentTarget).attr('id') != 'topo-resultados-col2') {
                podeEscolher(item.item);
            }
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
        jQuery('.codigo').css('text-decoration', 'none');
        jQuery('.codigo').css('color', '#444');
        jQuery('.nome').css('text-decoration', 'none');
        jQuery('.nome').css('color', '#444');
        jQuery('.cpf').css('text-decoration', 'none');
        jQuery('.cpf').css('color', '#444');
        jQuery('.placa').css('text-decoration', 'none');
        jQuery('.placa').css('color', '#444');
        jQuery('.veiculo').css('text-decoration', 'none');
        jQuery('.veiculo').css('color', '#444');
        jQuery('.vencnh').css('text-decoration', 'none');
        jQuery('.vencnh').css('color', '#444');

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
            var nome = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.nome').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "marcarItemAdicionar(this);");
            i++;
        }

    } else if (elemento.attr('marcado') === 'true') {
        jQuery('.codigo').css('text-decoration', 'underline');
        jQuery('.codigo').css('color', '#13385c');
        jQuery('.nome').css('text-decoration', 'underline');
        jQuery('.nome').css('color', '#13385c');
        jQuery('.cpf').css('text-decoration', 'underline');
        jQuery('.cpf').css('color', '#13385c');
        jQuery('.placa').css('text-decoration', 'underline');
        jQuery('.placa').css('color', '#13385c');
        jQuery('.veiculo').css('text-decoration', 'underline');
        jQuery('.veiculo').css('color', '#13385c');
        jQuery('.vencnh').css('text-decoration', 'underline');
        jQuery('.vencnh').css('color', '#13385c');

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
            var nome = jQuery(jQuery('#topo-resultados-col1 li')[i]).find('.nome').html();
            jQuery(jQuery('#topo-resultados-col1 li')[i]).attr('onclick', "parent.controleLocalizarMotoristas('finalizado','" + nome + "',true)");
            i++;
        }


    }
}

function enviarMotoristasSelecionados() {
    var lis = jQuery('#topo-resultados-col2 li');

    if (lis.size() > 0) {
        parent.removerValorInput('inptMotorista');
        var index = 0;
        while (lis[index]) {
            jQuery(lis[index]).find('.nome').find('img').remove();
            var nome = jQuery(lis[index]).find('.nome').html();
            var id = jQuery(lis[index]).find('input').val();
            parent.controleLocalizarMotoristas('finalizado', nome + '!@!' + id);
            index++;
        }
    } else {
        parent.controleLocalizarMotoristas('mensagem', 'Selecione ao menos um motorista.');
    }

    voltarTodosItens();
    limparMotoristas();
}

function popularListaMotoristas(motorista) {
    if (jQuery('#chkOpcoesAvancadas').prop('checked') == true) {
        jQuery('#topo-resultados-col1').append('<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="codigo">' + motorista.idmotorista + '</div><div class="nome">' + motorista.nome + '</div><div class="cpf">' + motorista.cpf + '</div><div class="veiculo">' + motorista.veiculo.placa + '</div><div class="veiculo">' + motorista.veiculo + '</div><div class="vencnh">' + motorista.vencimentocnh + '</div><input value="' + motorista.idmotorista + '" type="hidden" name="idmotorista"></li>');
        jQuery('.nome').css('text-decoration', 'none');
        jQuery('.nome').css('color', '#444');
    } else {
        jQuery('#topo-resultados-col1').append('<li class="ui-state-default" onclick="parent.controleLocalizarMotoristas(' + "'" + "finalizado" + "'" + ',popularOnClick(this),true);"><div class="codigo">' + motorista.idmotorista + '</div><div class="nome">' + motorista.nome + '</div><div class="cpf">' + motorista.cpf + '</div><div class="veiculo">' + motorista.veiculo + '</div><div class="vencnh">' + motorista.vencimentocnh + '</div><input value="' + motorista.idmotorista + '" type="hidden" name="idmotorista"></li>');
        jQuery('.nome').css('text-decoration', 'underline');
        jQuery('.nome').css('color', '#13385c');
    }
}

function popularListaMotoristasEscolhidos(motorista) {
    if (jQuery('#chkOpcoesAvancadas').prop('checked') == true) {
        jQuery('#topo-resultados-col2').append('<li class="ui-state-default" onclick="marcarItemAdicionar(this);"><div class="nome">' + motorista.split('#@#')[0] + '</div><input value="' + motorista.split('#@#')[1] + '" type="hidden" name="idmotorista"></li>');
        jQuery('.nome').css('text-decoration', 'none');
        jQuery('.nome').css('color', '#444');

    } else {
        jQuery('#topo-resultados-col2').append('<li class="ui-state-default" onclick="parent.controleLocalizarMotoristas(' + "'" + "finalizado" + "'" + ',popularOnClick(this),true);"><div class="nome">' + nome + '</div><input value="' + idmotorista + '" type="hidden" name="idmotorista"></li>');
        jQuery('.nome').css('text-decoration', 'underline');
        jQuery('.nome').css('color', '#13385c');
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
    return jQuery(element).find('.nome').html() + "!@!" + jQuery(element).find('input[name="idmotorista"]').val();
}



function proximaLocalizar() {
    var motoristas = jQuery('#inpt-filtrar-por').val();
    var campo = jQuery('#select-campo').val();
    var check = jQuery('#chkDiferenciar').prop('checked');
    var ckeckIgual = jQuery('#chkIgual').prop('checked');

    var paginaAtual = parseInt(jQuery('#paginaAtual').val()) + 1;
    var totalPaginas = parseInt(jQuery('#totalPaginas').val());

    limparMotoristasResultado();

    jQuery.ajax({
        url: 'MotoristaControlador?acao=localizar&campo=' + campo + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&motoristas=' + motoristas + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas,
        dataType: "text",
        method: "post",
        async: false,
        complete: function (jqXHR, textStatus) {
            var paginacao = jqXHR.responseText.split('!@!')[0];
            var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));
            popularPaginacao(paginacaoObj);
            //Comeca a pegar do 1 pois o 0 � a paginacao
            var motoristas = jqXHR.responseText.split('!@!');
            var i = 1;
            while (motoristas[i] !== undefined) {
                var motorista = jQuery.parseJSON(motoristas[i]);
                if (motorista.nome !== undefined) {
                    popularListaMotoristas(motorista);
                }
                i++;
            }
        }

    });
}

function anteriorLocalizar() {
    var motoristas = jQuery('#inpt-filtrar-por').val();
    var campo = jQuery('#select-campo').val();
    var check = jQuery('#chkDiferenciar').prop('checked');
    var ckeckIgual = jQuery('#chkIgual').prop('checked');

    var paginaAtual = parseInt(jQuery('#paginaAtual').val()) - 1;
    var totalPaginas = parseInt(jQuery('#totalPaginas').val());

    limparMotoristasResultado();

    jQuery.ajax({
        url: 'MotoristaControlador?acao=localizar&campo=' + campo + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&motoristas=' + motoristas + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas,
        dataType: "text",
        method: "post",
        async: false,
        complete: function (jqXHR, textStatus) {
            var paginacao = jqXHR.responseText.split('!@!')[0];
            var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));
            popularPaginacao(paginacaoObj);
            //Comeca a pegar do 1 pois o 0 � a paginacao
            var motoristas = jqXHR.responseText.split('!@!');
            var i = 1;
            while (motoristas[i] !== undefined) {
                var motorista = jQuery.parseJSON(motoristas[i]);
                if (motorista.nome !== undefined) {
                    popularListaMotoristas(motorista);
                }
                i++;
            }
        }

    });

}

function localizarMotoristas(motoristas, campo, check, ckeckIgual) {
    limparMotoristasResultado();
    jQuery.ajax({
        url: 'MotoristaControlador?acao=localizar&motoristas=' + motoristas + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&campo=' + campo,
        dataType: "text",
        method: "post",
        async: false,
        complete: function (jqXHR, textStatus) {
            var paginacao = jqXHR.responseText.split('!@!')[0];
            var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));
            popularPaginacao(paginacaoObj);
            //Comeca a pegar do 1 pois o 0 � a paginacao
            var motoristas = jqXHR.responseText.split('!@!');
            console.log(motoristas);
            //var placa = jQuery.parseJSON(motoristas.veiculo.replace('veiculo:','')).placa;
            //console.log(placa);
            var i = 1;
            while (motoristas[i] !== undefined) {
                var motorista = jQuery.parseJSON(motoristas[i]);
                if (motorista.nome !== undefined) {
                    popularListaMotoristas(motorista);
                }
                i++;
            }
        }

    });
}

function paginaEnter(evn, pagina) {
    if (evn.keyCode == 13) {
        var motoristas = jQuery('#inpt-filtrar-por').val();
        var campo = jQuery('#select-campo').val();
        var check = jQuery('#chkDiferenciar').prop('checked');
        var ckeckIgual = jQuery('#chkIgual').prop('checked');

        var paginaAtual = parseInt(jQuery('#pagina').val());
        var totalPaginas = parseInt(jQuery('#totalPaginas').val());

        limparMotoristasResultado();

        jQuery.ajax({
            url: 'MotoristaControlador?acao=localizar&campo=' + campo + '&isDiferencia=' + check + '&isIgual=' + ckeckIgual + '&motoristas=' + motoristas + '&paginaAtual=' + paginaAtual + '&totalPaginas=' + totalPaginas,
            dataType: "text",
            method: "post",
            async: false,
            complete: function (jqXHR, textStatus) {
                var paginacao = jqXHR.responseText.split('!@!')[0];
                var paginacaoObj = jQuery.parseJSON(jQuery.parseJSON(paginacao));
                popularPaginacao(paginacaoObj);
                //Comeca a pegar do 1 pois o 0 � a paginacao
                var motoristas = jqXHR.responseText.split('!@!');
                var i = 1;
                while (motoristas[i] !== undefined) {
                    var motorista = jQuery.parseJSON(motoristas[i]);
                    if (motorista.nome !== undefined) {
                        popularListaMotoristas(motorista);
                    }
                    i++;
                }
            }

        });
    }
}

//Validar o caractere de pagina
function verificaCaracterePagina(element, paginas) {
    element.value = element.value.replace(/[^0-9,]/g, "");

    if (element.value != null && element.value != "" && parseFloat(element.value) > parseFloat(paginas)) {
        element.value = "";
        return true;
    }

    //nao enviar pagina caso seja 0 - j� que 0 � menor
    // que a quantidade de paginas sempre e passa das validacoes acima
    if (element.value == "0" || element.value == 0) {
        element.value = "";
    }
}

function limparMotoristas() {
    jQuery('#topo-resultados-col1').html('');
    jQuery('#topo-resultados-col2').html('');
}

function limparMotoristasResultado() {
    jQuery('#topo-resultados-col1').html('');
}

function limparMotoristasEscolhidas() {
    jQuery('#topo-resultados-col2').html('');
}
function recarregarLocalizar() {
    window.location = 'MotoristaControlador?acao=iniciar_localizar';
}