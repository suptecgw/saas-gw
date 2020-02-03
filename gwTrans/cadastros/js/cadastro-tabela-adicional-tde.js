$(document).ready(function () {
    $('.header-dom > img').click(function () {
        addDom();
    });
    
    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();
        $.ajax({
            url: 'TabelaAdicionalTdeControlador',
            async: true,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);
                if (obj.descricao) {
                    $('#descricao').val(obj.descricao);
                }

                $.each(obj.grupos, function (i, o) {
                    setTimeout(function () {
                        addDom(o);
                    }, 500);
                });

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['alteradoPor']['nome'], obj['alteradoEm']);

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }
});

var qtdDomTDe = 0;

function addDom(object) {
    var body = null;
    var count = ++qtdDomTDe;
    if ($('.container-dom').find('.body')[0]) {
        body = $('.container-dom').find('.body');
    } else {
        $('.container-dom').append($('<div class="body">'));
        body = $('.container-dom').find('.body');
    }
    var bodyDom = $('<div class="col-md-12 body-dom celula-zebra-2" style="padding-top:12px;">');
    $(body).append(bodyDom);
    $(bodyDom).load(homePath + '/gwTrans/cadastros/html-dom/tabela-tde.jsp?v=0.2&qtdDomTDe=' + count, function () {
        $('[data-dinheiro]').mask("#.##0,00", {reverse: true});
        $('[data-dinheiro]').focusout('focusout', function () {});
        if (object) {
            $('#formula' + count).val(object.formula);
            $('#valorTDE' + count).val(object.valorTde.toFixed(2));
            $('#selectTipoCalculo' + count + ' option[value=' + object.tipoCalculo + ']').prop('selected', true);
            $('#selectTipoCalculo' + count).selectmenu('refresh');

            if(object.grupoCLiente && object.grupoCLiente['id'] != '0'){
                $('input[type=radio][id=tipoGrupo' + count + '][value=cli]').click();
                addValorAlphaInput('grupo' + count, String(object.grupoCLiente.descricao), String(object.grupoCLiente.id));
            }else if(object.destinatario && object.destinatario['id'] != '0'){
                $('input[type=radio][id=tipoGrupo' + count + '][value=dest]').click();
                addValorAlphaInput('grupo' + count, String(object.destinatario.razaosocial), String(object.destinatario.id));
            }
        }
    });
}

function toLocalizar(input, s) {
    if (typeof input === 'object') {
        input = $(input).attr('id');
    }

    $('.cobre-tudo').show();

    if ($('#tipo' + s).val() == 'cli') {
        $('#localizarGrupoCliente').attr('input', input).css('display', '');
        $('#localizarCliente').css('display', 'none');
        controlador.acao('abrirLocalizar', 'localizarGrupoCliente');
    } else {
        $('#localizarCliente').attr('input', input).css('display', '');
        $('#localizarGrupoCliente').css('display', 'none');
        controlador.acao('abrirLocalizar', 'localizarCliente');
    }
}

function mostrarFormula(grupoId) {
    var formula = $('#formula');

    $('.cobre-tudo').show();

    formula.parent().show();
    formula.contents().find('#grupoID').val(grupoId);
    formula.contents().find('#text-formula').val($('input[name="formula' + grupoId + '"]').val());
}

function fecharFormula() {
    var formula = $('#formula');

    $('.cobre-tudo').hide();

    formula.parent().hide();
    formula.contents().find('#grupoID').val('');
    formula.contents().find('#text-formula').val('');
}

function popularFormula(grupoId, value) {
    $('input[name="formula' + grupoId + '"]').val(value);
    fecharFormula(grupoId);
}

function tipoGrupo(e, s) {
    $('#tipo' + s).val(e.value);
    removerValorInput('grupo' + s);
}

function tipoCalculo(e, s) {
    $('#tipoCalculo' + s).val(e.value);
}