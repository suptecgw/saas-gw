var qtdDomNFe = 0;
var objetosNota = [];
var atualizouDados = false;

jQuery(document).ready(function () {
    $('button[class="bt-salvar"]').on('click', function () {
        $('div[id*="obs"]').each(function () {
            var div = $(this);
            var id = div.attr('id');
            var text = div.text();
            $('input[name=' + id + ']').val(text);
        });
    });
    
    jQuery("#filial").selectmenu().selectmenu({
        change: function () {
            $('#id-filial').val(this.value);
        }
    }).selectmenu({width: '79px'}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui").addClass("select");

    jQuery("#select-layout").selectmenu({width: '79px'}).selectmenu("option", "position", {my: "top+15", at: "top center"}).selectmenu("menuWidget").addClass("selects-ui").addClass("select");

    jQuery("span[class*='-button'],.ativa-helper2,#descricao,#observacao,.radio-label,.js-labelFile").hover(
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

    jQuery("#apenas-ctes-areas-destino,#apenas-ctes-clientes,#apenas-ctes-destino,#apenas-ctes-remetente,#apenas-ultima-ocorrencia,#apenas-setor-entrega").parent().hover(
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

    var dataInicial;
    var horaInicial;
    var dataFinal;
    var horaFinal;

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();
        $('.topo-etiquetas,.container-dom-etiqueta').css("visibility", "visible");
        $.ajax({
            url: 'InventarioControlador',
            async: true,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                try {
                    var obj = JSON.parse(jqXHR.responseText);
                    $('#numero').val(obj.numero);
                    $('#filial option[value=' + obj.idFilial + ']').prop('selected', true);
                    $('#filial').selectmenu('refresh');
                    try{
                        dataInicial = addZeroData(obj.dthInicial);
                        $('#data-inicial').val(dataInicial);
                        $('#data-inicial').datebox('setValue',dataInicial);
                        horaInicial = addZeroHora(obj.dthInicial);
                        $('#hora-inicial').val(horaInicial);
                    }catch(ex){
                        var interval = setInterval(() => {
                            if ($('#data-inicial').datebox) {
                                dataInicial = addZeroData(obj.dthInicial);
                                $('#data-inicial').val(dataInicial);
                                $('#data-inicial').datebox('setValue',dataInicial);
                                horaInicial = addZeroHora(obj.dthInicial);
                                $('#hora-inicial').val(horaInicial);
                                clearInterval(interval);
                            };
                        },500);
                        
                    }

                    if (obj.dthFinal) {
                        dataFinal = addZeroData(obj.dthFinal);
                        $('#data-final').val(dataFinal);
                        horaFinal = addZeroHora(obj.dthFinal);
                        $('#hora-final').val(horaFinal);
                    } else {
                        // Limpar o campo de data e hora final
                        $('#data-final').val('');
                        $('#hora-final').val('');
                    }

                    $('#descricao').val(obj.descricao);
                    $('#observacao').val(obj.observacao);

                    timeoutNota(obj.listaCte.length > 50 ? 50 : obj.listaCte.length);
                    montarDOMObjetos(obj.listaCte);

                    timeoutEtiqueta(obj.listaEtiquetas.length);
                    $.each(obj.listaEtiquetas, function (i, e) {
                        var isLastElement = i == obj.listaEtiquetas.length - 1;
                        if (isLastElement) {
                            addDomEtiqueta(true, false, e.numero, e.status, true, e);
                        } else {
                            addDomEtiqueta(true, false, e.numero, e.status, false, e);
                        }
                    });

                    addDomArquivoEtiqueta(obj.listaArquivosEtiquetas);

                    criadoAlteradoAuditoria(obj['criadorPor']['nome'], obj['criadoEm'], obj['alteradoPor']['nome'], obj['alteradoEm']);
                } catch (exception) {
                    console.error(exception);
                    if (jqXHR.responseText.includes('ERROR:') || jqXHR.responseText.includes('A nome da coluna')) {
                        chamarAlert(jqXHR.responseText, function () {
                            window.location = 'ConsultaControlador?codTela=85';
                        });
                    } else {
                        chamarAlert(exception, function () {
                            window.location = 'ConsultaControlador?codTela=85';
                        });
                    }
                }
            }
        });
    }

    $('#hora-inicial,#hora-final').mask('00:00');
    $('.aba').click(function () {
        $('.conteudo-aba').hide();
        $('.aba-selecionada').removeClass('aba-selecionada');
        $(this).addClass('aba-selecionada');
        var left = '0px';
        if ($(this).hasClass('aba01')) {
            $('#conteudo-aba1').show(250);
            left = '270px';
        } else if ($(this).hasClass('aba02')) {
            $('#conteudo-aba2').show(250);
            left = '540px';
        } else if ($(this).hasClass('aba03')) {
            $('#conteudo-aba3').show(250);
            left = '890px';
        } else if ($(this).hasClass('aba04')) {
            $('#conteudo-aba4').show(250);
            left = '1200px';
        }
    });

    $('.bt-adicionar-filtros').on('click', function () {
        if (!$(this).attr('is-desativado')) {
            $('.cobre-tudo-1').show(250, function () {
                $('.model-filtros-ctes').show(250);
            });
        }
    });

    $('.bt-expandir').on('click', function(){

         var listaCte =  document.getElementById('lista-cte');
        // go full-screen
        if (listaCte.requestFullscreen) {
            listaCte.requestFullscreen();
        } else if (listaCte.webkitRequestFullscreen) {
            listaCte.webkitRequestFullscreen();
        } else if (listaCte.mozRequestFullScreen) {
            listaCte.mozRequestFullScreen();
        } else if (listaCte.msRequestFullscreen) {
            listaCte.msRequestFullscreen();
        }
        carregarFullScreen();
    });

    $('#img-fechar-filtros-ctes').on('click', function () {
        $('.cobre-tudo-1,.model-filtros-ctes').hide(250);
    });
    $('#apenas-ctes-clientes').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    $('#apenas-ctes-destino').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    $('#apenas-ctes-areas-destino').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    $('#apenas-ultima-ocorrencia').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    $('#apenas-ctes-remetente').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    $('#apenas-setor-entrega').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    $('[name="inp-cte-emitido-em"]').on('change', function () {
        if (this.value === 'data') {
            $('.cte-emitido-em').show();
            $('.model-filtros-ctes').css('height', '560px');
            $('.container-filtros').css('height', '420px');
        } else if (this.value === 'tudo') {
            $('.cte-emitido-em').hide();
            $('.model-filtros-ctes').css('height', '');
            $('.container-filtros').css('height', '');
        }
    });
    $('#img-fechar-justificativa-falta-cte').on('click', function () {
        $('.model-justificativa-falta-cte').hide();
        $('.cobre-tudo-1').hide();
    });
    $('.text-auto-ajuste').on('keyup keydown focusout', function () {
        this.style.cssText = 'height:auto; padding:0';
        // for box-sizing other than "content-box" use:
        // el.style.cssText = '-moz-box-sizing:content-box';
        this.style.cssText = 'height:' + this.scrollHeight + 'px';
    });
    $('.bt-pesquisar-cte').on('click', function (e) {
        var button = this;
        this.classList.add('loading');
        this.setAttribute('disabled', 'disabled');
        var obj_envio = {'acao': 'listarCtesInventario'};
        let radio_filial = $('[name="radio-filial-ctes"]:checked').val();
        Object.assign(obj_envio, {'radio-filial-ctes': radio_filial});
        Object.assign(obj_envio, {emitido_pela_filial: $('#filial').val()});
        Object.assign(obj_envio, {filial_responsavel: $('#filial').val()});

        let emitidoEm = $('[name="inp-cte-emitido-em"]:checked').val();
        if (emitidoEm !== 'tudo') {
            Object.assign(obj_envio, {data_de: $('#cte-de').datebox('getValue')});
            Object.assign(obj_envio, {data_ate: $('#cte-ate').datebox('getValue')});
        }

        // Cliente
        var clienteId = $('#apenas-ctes-clientes').val();
        if (clienteId && clienteId !== '') {
            clienteId = clienteId.split('!@!').map(function (elemento) {
                return elemento.split('#@#')[1]
            }).join(',');

            Object.assign(obj_envio, {clientes: clienteId});
            Object.assign(obj_envio, {'select-apenas-exceto-cliente': $('#select-apenas-exceto-cliente').val()});
        }

        // Cidade
        var cidadeId = $('#apenas-ctes-destino').val();
        if (cidadeId && cidadeId !== '') {
            cidadeId = cidadeId.split('!@!').map(function (elemento) {
                return elemento.split('#@#')[1]
            }).join(',');

            Object.assign(obj_envio, {destinos: cidadeId});
            Object.assign(obj_envio, {'select-apenas-exceto-destino': $('#select-apenas-exceto-destino').val()});
        }

        // Área
        var areaId = $('#apenas-ctes-areas-destino').val();
        if (areaId && areaId !== '') {
            areaId = areaId.split('!@!').map(function (elemento) {
                return elemento.split('#@#')[1]
            }).join(',');

            Object.assign(obj_envio, {areas: areaId});
            Object.assign(obj_envio, {'select-apenas-exceto-area-destino': $('#select-apenas-exceto-area-destino').val()});
        }
        // Ocorrencia
        var ocorrenciaId = $('#apenas-ultima-ocorrencia').val();
        if (ocorrenciaId && ocorrenciaId !== '') {
            ocorrenciaId = ocorrenciaId.split('!@!').map(function (elemento) {
                return elemento.split('#@#')[1]
            }).join(',');
            Object.assign(obj_envio, {ocorrencia: ocorrenciaId});
            Object.assign(obj_envio, {'select-apenas-exceto-ultima-ocorrencia': $('#select-apenas-exceto-ultima-ocorrencia').val()});
        }
        // Remetente
        var remetenteId = $('#apenas-ctes-remetente').val();
        if (remetenteId && remetenteId !== '') {
            remetenteId = remetenteId.split('!@!').map(function (elemento) {
                return elemento.split('#@#')[1]
            }).join(',');
            Object.assign(obj_envio, {remetente: remetenteId});
            Object.assign(obj_envio, {'select-apenas-exceto-remetente': $('#select-apenas-exceto-remetente').val()});
        }

        // Setor Entrega
        var setorEntregaId = $('#apenas-setor-entrega').val();
        if (setorEntregaId && setorEntregaId !== '') {
            setorEntregaId = setorEntregaId.split('!@!').map(function (elemento) {
                return elemento.split('#@#')[1]
            }).join(',');
            Object.assign(obj_envio, {setor_entrega: setorEntregaId});
            Object.assign(obj_envio, {'select-apenas-exceto-setor-entrega': $('#select-apenas-exceto-setor-entrega').val()});
        }

        $.ajax({
            url: 'InventarioControlador',
            async: true,
            data: obj_envio,
            complete: function (jqXHR, textStatus) {
                try {
                    montarDOMObjetos(JSON.parse(jqXHR.responseText));
                } finally {
                    setTimeout(function () {
                        $('.img-editar-cte').on('click', function () {
                            $('.model-justificativa-falta-cte').show();
                            $('.cobre-tudo-1').show();
                        });


                        button.classList.remove('loading');
                        button.removeAttribute('disabled');

                        $('#filial').selectmenu("disable");

                        if ($('.container-dom-cte').find('.container-item-dom-cte').length <= 0) {
                            chamarAlert('Nenhum resultado foi encontrado!');
                        } else {
                            if(qs['id'] != undefined && qs['id'] != '0'){
                                atualizouDados = true;
                            }
                            $('.model-filtros-ctes').hide();
                            $('.cobre-tudo-1').hide();
                        }
                    }, 1000);
                }
            }
        });
    });

    $('#bt-pesquisar-etiqueta').on('click', function () {
        $('.bt-adicionar-filtros').css('background-color', '#666');
        $('.bt-adicionar-filtros').attr('is-desativado', true);
        addDomEtiqueta(true, true, $('#input-etiqueta').val(), 'X', true);
        atualizarContadorQtd();
    });

    $('#input-etiqueta').on('keyup', function (e) {
        $('.bt-adicionar-filtros').css('background-color', '#666');
        $('.bt-adicionar-filtros').attr('is-desativado', true);
        if (e.which === 13) {
            addDomEtiqueta(true, true, $('#input-etiqueta').val(), 'X', true);
        }
    });

    $('#file').gwReadFile({
        destiny: function (text) {
            if (text === undefined) {
                chamarAlert('Não foi possivel importar o arquivo!');
                return;
            }

            $.each(text.split('\n'), function (i, e) {
                var isLastElement = i == text.split('\n').length - 1;
                if (isLastElement) {
                    addDomEtiqueta(true, true, e, 'X', true);
                } else {
                    addDomEtiqueta(true, true, e, 'X');
                }
            });
        },
        no_destiny_if_save_fail: true,
        save_file: {
            enable_save_file: true,
            controller: {
                url: homePath + '/InventarioControlador?acao=salvarArquivoEtiqueta&idInventario=' + qs['id'],
                data: {
                    extension: ['txt']
                }
            }
        },
        callback: function (arquivo) {
            adicionarNomeChaveAcesso(arquivo.name);
        }
    });

    $('.bt-justificar-falta-cte').on('click', function () {
        var idItem = sessionStorage.getItem('justificativa-falta');
        $('#' + idItem).val($('#justificativa-falta-etiqueta').val());
        $('.model-justificativa-falta-cte').hide();
        $('.cobre-tudo-1').hide();
    });

    jQuery('#data-inicial,#data-final,#cte-de,#cte-ate').gwDatebox({
        'icone_classe': 'combo-arrow-escuro-cte',
        'funcao_apos_criacao': function (elemento) {
            var id = elemento.attr('id');

            if (id === 'data-inicial') {
                elemento.datebox('setValue', dataInicial);
            } else if (id === 'data-final' && dataFinal) {
                elemento.datebox('setValue', dataFinal);
            }
            if (elemento.val() && elemento.val() !== '') {
                elemento.datebox('setValue', elemento.val());
            }

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
            elemento.parent().find('.textbox').css('height', '30px');
            elemento.parent().find('.textbox-text').css('width', '93%').css('height', '30px').css('font-size', '13px');

            if (elemento.attr('data-serialize-campo') !== undefined) {
                elemento.parent().find('.textbox-value').attr('data-serialize-campo', elemento.attr('data-serialize-campo'))
            }
        }
    });

    $('#hora-final').on('blur', function () {
        completarHora(this);
    });
    $('#hora-inicial').on('blur', function () {
        completarHora(this);
    });

    // Carregar mais ao scroll
    jQuery('#container-dom-cte').on('scroll', _.debounce(carregarMais, 500));
});

async function delay(ms) {
  return await new Promise(resolve => setTimeout(resolve, ms));
}

function addDomEtiqueta(limpar_input, salvar_etiqueta, numero, status, is_ativar_msg_ja_existe, json_etiqueta) {
    if (!numero || numero.trim() === '') {
        return;
    }
    if(atualizouDados){
        chamarAlert("ATENÇÃO! A lista de CTE's foi atualizada. Favor salvar o inventário antes de continuar com a Bipagem!");
        return false;
    }
    // Faz o trim da etiqueta
    numero = numero.trim();

    if ($('[data="numeroEtiqueta"]').filter(function () {
        return $(this).text() === numero
    }).size() > 0) {
        if (is_ativar_msg_ja_existe) {
            chamarAlert('Já existe uma etiqueta com o mesmo número bipada.', function () {
                setTimeout(function () {
                    jQuery('#input-etiqueta').focus();

                }, 500);
            });
        }

        // Limpa o input de etiqueta
        $('#input-etiqueta').val('');
        setInterval(function(){
            focarInput();
        },1000);
        return;
    }

    $('#bt-pesquisar-etiqueta,#input-etiqueta').prop('disabled', true);

    var existe = false;
    var idNotaFiscal = 0;
    var volumesNotaFiscal = 0;
    var ocorrenciaCod = '';
    var ocorrenciaDesc = '';
    var numeroNota = '';
    var numeroCTe = '';
    var setorEntrega = '';

    if (!salvar_etiqueta) {
        salvarEtiqueta(existe, status, idNotaFiscal, volumesNotaFiscal, limpar_input, numero, salvar_etiqueta, ocorrenciaCod, ocorrenciaDesc, numeroNota, numeroCTe, setorEntrega, json_etiqueta);
    } else {
        // Faz uma consulta ao controlador para saber se a etiqueta existe no inventário
        $.post(home_path + '/InventarioControlador', {
            'acao': 'biparEtiqueta',
            'etiqueta': numero,
            'id_inventario': qs['id']
        }, function (data) {
            if (data) {
                status = data['status'];
                existe = status == 'C';
                idNotaFiscal = data['idNotaFiscal'];
                volumesNotaFiscal = data['volumesNotaFiscal'];
                ocorrenciaCod = data['codigoOcorrencia'];
                ocorrenciaDesc = data['ocorrencia'];
                numeroNota = data['numeroNota'];
                numeroCTe = data['numeroCTe'];
                setorEntrega = data['setorEntrega'];

                salvarEtiqueta(existe, status, idNotaFiscal, volumesNotaFiscal, limpar_input, numero, salvar_etiqueta, ocorrenciaCod, ocorrenciaDesc, numeroNota, numeroCTe, setorEntrega);
                atualizarContadorQtd();
                $('#bt-pesquisar-etiqueta,#input-etiqueta').prop('disabled', false);
                focarInput();
            }
        }, 'json');
    }
}

function salvarEtiqueta(existe, status, idNotaFiscal, volumesNotaFiscal, limpar_input, numero, salvar_etiqueta, ocorrenciaCod, ocorrenciaDesc, numeroNota, numeroCTe, setorEntrega, json_etiqueta) {
    if (existe) {
        var objNota = objetosNota.find(nota => nota.idNota === idNotaFiscal);

        if (objNota) {
            objNota.bipadas++;
            objNota.volumeTotal = volumesNotaFiscal;
        }

        var item = $('input[id*=idNota][value="' + idNotaFiscal + '"]').parent().parent();

        if (item && item.length > 0) {
            var lbqtd = item.find('.lb-qtd-notas-bipadas');
            var lbQtdVolumes = item.find('.lb-qtd-volumes');

            lbqtd.text(parseInt(lbqtd.text()) + 1);
            lbQtdVolumes.text(volumesNotaFiscal);

            if (parseInt(lbqtd.text()) >= volumesNotaFiscal) {
                $(item).removeClass('item-incompleto').addClass('item-completo');
            } else {
                $(item).removeClass('item-completo').addClass('item-incompleto');
            }
        }
        atualizarContadorQtd();
    }

    if (salvar_etiqueta) {
        $('.cobre-etiqueta').show();
        atualizarContadorQtd();
    }

    if (limpar_input) {
        $('#input-etiqueta').val('');
    }

    var container = $('.container-dom-etiqueta .etiquetas');
    var div = $('<div class="container-item-dom-etiqueta">');
    $(container).prepend(div);

    var status_etiqueta = '';
    switch (status) {
        case 'X':
            status_etiqueta = 'Etiqueta não encontrada';
            break;
        case 'E':
            status = 'X';
            status_etiqueta = 'Atenção! A etiqueta ' + numero + ' não pertence ao inventário. CT-e ' + numeroCTe + ', NF ' + numeroNota + ', Ocorrência: ' + ocorrenciaCod + ' - ' + ocorrenciaDesc + '.' + ' Setor de entrega: ' + setorEntrega + '.';
            break;
        case 'C':
            status_etiqueta = 'Ok';
            break;
    }
    var user = json_etiqueta !== undefined  && json_etiqueta.nomeUsuarioBipado !== undefined ? json_etiqueta.nomeUsuarioBipado : nome_usuario; 
    $(div).load(home_path + '/gwTrans/cadastros/html-dom/dom-inventario-etiqueta.jsp?nomeUsuario=' + encodeURI(user) + '&etiqueta=' + encodeURI(numero) + '&status=' + encodeURI(status_etiqueta));    
    if (salvar_etiqueta) {
        $.ajax({
            'url': 'InventarioControlador',
            async: true,
            data: {
                acao: 'salvarEtiqueta',
                etiqueta: numero,
                id_inventario: qs['id'],
                status: status
            },
            complete: function (jqXHR, textStatus) {
                if (jqXHR.responseText !== 'true') {
                    chamarAlert(jqXHR.responseText,'focarInput');
                }
                setTimeout(function () {
                    $('.cobre-etiqueta').hide();
                    
                    jQuery('#input-etiqueta').focus();
                }, 500);
            }
        });
    } else {
        $('.cobre-etiqueta').hide();
        focarInput();
    }
}

function addDomArquivoEtiqueta(list) {
    var container = $('.container-dom-arquivos');
    $.each(list, function (i, e) {
        var div;
        var divG = $('<div>').addClass('item-lista-arquivos lista-arquivos-etiquetas');
        div = $('<div>').addClass('col-md-1');
        var i = $('<i>').addClass('icone-download icon fa fa-check').attr('onclick', 'downloadArquivoEtiqueta("' + e.idInventario + '")').hover(
                function () {
                    var elemento = $('#icone_download_arquivo');
                    $(".campo-helper h2").html(elemento.find('input[type=hidden]')[1].value);
                    $(".descri-helper h3").html(elemento.find('input[type=hidden]')[0].value);
                },
                function () {
                    $('.campo-helper h2').html('Ajuda');
                    $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                }
        );
        div.append(i);
        divG.append(div);
        div = $('<div>').addClass('col-md-3').text(e.descricaoArquivo).hover(
                function () {
                    var elemento = $('#nome_arquivo_importado');
                    $(".campo-helper h2").html(elemento.find('input[type=hidden]')[1].value);
                    $(".descri-helper h3").html(elemento.find('input[type=hidden]')[0].value);
                },
                function () {
                    $('.campo-helper h2').html('Ajuda');
                    $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                }
        );
        divG.append(div);
        div = $('<div>').addClass('col-md-3').text(e.nomeUsuarioInclusao);
        divG.append(div);
        div = $('<div>').addClass('col-md-3').text(addZeroData(e.dthInclusao));
        divG.append(div);
        div = $('<div>').addClass('col-md-2').text(addZeroHora(e.dthInclusao));
        divG.append(div);
        container.append(divG);
    });
}

function addDomNotas(e, apagarListaAtual) {
    if (apagarListaAtual === true) {
        qtdDomNFe = 0;
        $('.container-item-dom-cte').remove();
    }

    var container = $('#container-dom-cte');

    var div = $('<div class="container-item-dom-cte">');
    
    $(container).append(div);
    var dados = home_path
            + "/gwTrans/cadastros/html-dom/dom-inventario-ctes.jsp?numeroCte=" + e.numeroCte
            + "&id=" + e.id
            + "&idCte=" + e.idCte
            + "&idNota=" + e.idNota
            + "&destinatario=" + encodeURI(e.destinatario)
            + "&consignatario=" + encodeURI(e.consignatario)
            + "&numeroNota=" + e.numeroNota
            + "&volumeTotal=" + e.volumeTotal
            + "&etiquetas=" + e.listaEtiquetas[0]
            + "&isExcluido=" + e.excluido
            + "&motivoFalta=" + e.motivoFalta
            + "&qtdDomNFe=" + (++qtdDomNFe)
            + "&bipadas=" + e.bipadas
            + "&isCompleto=" + (e.volumeTotal > 0 && e.bipadas == e.volumeTotal);
    $(div).load(dados);
}

function addZeroData(dt) {
    var s = null;
    try {
        s = String(dt.date.day).padStart(2, '0') + "/" + String(dt.date.month).padStart(2, '0') + "/" + dt.date.year;
    } catch (exception) {
        s = '';
    }
    return s;
}

function addZeroHora(dt) {
    var s = null;
    try {
        s = String(dt.time.hour).padStart(2, '0') + ":" + String(dt.time.minute).padStart(2, '0');
    } catch (exception) {
        s = '';
    }
    return s;
}

function downloadArquivoEtiqueta(id_inventario) {
    $.ajax({
        url: 'InventarioControlador',
        data: {
            acao: 'carregarArquivoEtiqueta',
            id: id_inventario
        }, complete: function (jqXHR, textStatus) {
            try {
                var txt = atob(jqXHR.responseText);
                var blob = new Blob([txt], {type: "text/plain"});
                let link = document.createElement('a');
                link.href = window.URL.createObjectURL(blob);
                link.download = "arquivo";
                document.body.appendChild(link);
                link.dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true, view: window}));
                link.remove();
                window.URL.revokeObjectURL(link.href);
            } catch (exception) {
                chamarAlert(exception);
            }
        }
    });
}

function toLocalizar(input) {
    if (input == 'localizarCliente') {
        // Troca o input do localizar para o remetente
        jQuery('#localizarCliente').attr('input', 'apenas-ctes-clientes');
        controlador.acao('abrirLocalizar', 'localizarCliente');
    } else if (input == 'localizarCidade') {
        controlador.acao('abrirLocalizar', 'localizarCidade');
    } else if (input == 'localizarArea') {
        controlador.acao('abrirLocalizar', 'localizarArea');
    } else if (input == 'localizarOcorrencia') {
        controlador.acao('abrirLocalizar', 'localizarOcorrencia');
    } else if (input == 'localizarRemetente') {
        // Troca o input do localizar para o remetente
        jQuery('#localizarCliente').attr('input', 'apenas-ctes-remetente');
        controlador.acao('abrirLocalizar', 'localizarCliente');
    } else if (input === 'localizarSetorEntrega') {
        controlador.acao('abrirLocalizar', 'localizarSetorEntrega');
    } else {
        chamarAlert('O localizar não foi configurado! ' + input);
    }
}

function completarHora(ob) {
    var vl_atual = ob.value;
    var vl_arr = vl_atual.split('');
    var vl_mod = '';
    var patt = new RegExp(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/);
    switch (vl_atual.length) {
        case 1:
            vl_mod = (String(vl_atual).padStart(2, '0')) + ':00';
            break;
        case 2:
            vl_mod = vl_atual + ':00';
            break;
        case 3:
            vl_mod = vl_atual + '00';
            break;
        case 4:
            vl_mod = vl_atual + '0';
            break;
        case 5:
            vl_mod = vl_atual;
            break;
        case 0:
            return;
            break;
    }
    if (patt.test(vl_mod)) {
        ob.value = vl_mod;
    } else {
        chamarAlert('A hora ' + vl_mod + ' é inválida.');
        ob.value = '';
    }
}

function adicionarNomeChaveAcesso(fileName) {
    var elemento = jQuery('#file').parent().find('.js-labelFile');
    var label = elemento.find('.js-fileName');

    if (fileName == undefined) {
        elemento.removeClass('has-file');
        label.text('Importar Chave');
    } else {
        elemento.addClass('has-file');
        label.text(fileName);
    }
}

function atualizarContadorQtd() {
    var totalBipadas = objetosNota.filter(m => m.volumeTotal>0).map(e=>e.bipadas).reduce( (acumulador, valorAtual) => acumulador + valorAtual );
    var totalVolumes = objetosNota.filter(m => m.volumeTotal>0).map(e=>e.volumeTotal).reduce( (acumulador, valorAtual) => acumulador + valorAtual );
    $('#qtd_nfe').fadeOut(function () {
        $(this).text(objetosNota.length).fadeIn();
    });
    $('#qtd_vlmc').fadeOut(function () {
        $(this).text(totalBipadas).fadeIn();
    });
    $('#qtd_vlmr').fadeOut(function () {
        $(this).text(totalVolumes - totalBipadas).fadeIn();
    });
}

function carregarMais() {
    var OFFSET = 150;

    if (this.scrollTop + this.clientHeight + OFFSET >= this.scrollHeight) {
        if (qtdDomNFe < objetosNota.length) {
            // Carregar mais
            var notasMostrar = objetosNota.slice(qtdDomNFe, qtdDomNFe + 15);

            $.each(notasMostrar, function (index, elemento) {
                addDomNotas(elemento);
            });
        }
    }
}

function carregarFullScreen() {

        if (qtdDomNFe < objetosNota.length) {
            // Carregar mais
            $.each(objetosNota, function (index, elemento) {
                    // foi definido que ao maximizar será exibido mais 50 itens, a medida que o scroll for descendo irão aparecendo mais notas.
                    if(index < 50){
                        addDomNotas(elemento);
                    }
            });
        }

}

function focarInput(){
    $('#input-etiqueta').focus();
}
function montarDOMObjetos(listaCte) {
    $.each(listaCte, function (i, e) {
        if (!objetosNota.some(e1 => e1.idNota == e.idNota)) {
            objetosNota.push(e);

            if (i < 15 && !$('[id*=idNota][value="' + e.idNota + '"]')[0]) {
                // Só vai mostrar 50 na tela
                addDomNotas(e);
            }
        }
    });

    atualizarContadorQtd();
}

var finalizouNota = false;
function timeoutNota(tamanho) {
    setTimeout(function () {
        if ($('.container-lista').find('.container-item-dom-cte').find('[data="numeroCte"]').length < tamanho) {
            timeoutNota();
        } else {
            finalizouNota = true;
        }
    }, 500);
}

function timeoutEtiqueta(tamanho) {
    setTimeout(function () {
        if (!finalizouNota || $('.container-lista').find('.container-item-dom-etiqueta').find('[data="numeroEtiqueta"]').length < tamanho) {
            timeoutEtiqueta(tamanho);
        } else {
            $('#bt-pesquisar-etiqueta,#input-etiqueta').prop('disabled', false);
            setTimeout(function () {
                $('.bloqueio-tela').hide();
                $('.gif-bloq-tela').hide();
            }, 1000);
        }
    }, 500);
}
