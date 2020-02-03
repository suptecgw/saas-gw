let qtdDom = 0;
let qtdDomMovimentacao = 0;

jQuery(document).ready(function aoCarregarCorpo() {
    if (qs['modulo'] === 'editar') {
        jQuery('#cadastrarForm').remove();
        jQuery('#editarForm').show();

        jQuery('#id').val(qs["id"]);

        jQuery('.bloqueio-tela').show();
        jQuery('.gif-bloq-tela').show();

        jQuery.ajax({
            url: 'IscaControlador',
            async: true,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function aoCarregarPorAjax(jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);

                jQuery('#numero').val(obj['numeroIsca']);
                
                if (!obj['ativo']) {
                    jQuery('#statusDesativado').click();
                    jQuery('#motivo_desativacao').val(obj['motivoDesativacao']).selectmenu('refresh');
                }

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], obj['criadoEm'], obj['atualizadoPor']['nome'], obj['atualizadoEm']);

                setTimeout(function esconderBloqueioTela() {
                    jQuery('.bloqueio-tela').hide();
                    jQuery('.gif-bloq-tela').hide();
                }, 1000);
            }
        });

        jQuery("#motivo_desativacao").selectmenu().selectmenu("option", "position", {
            my: "top+15",
            at: "top center"
        }).selectmenu("menuWidget").addClass("selects-ui");

        jQuery('input[name="is_ativo"]').on('change', function aoMudarStatus() {
            if (this.id === 'statusAtivado') {
                jQuery('#divMotivo').hide();
                jQuery('#motivo_desativacao').val('selecione').selectmenu('refresh');
            } else {
                jQuery('#divMotivo').show();
            }
        });

        jQuery('#data-inicial,#data-final').gwDatebox({
            'icone_classe': 'combo-arrow-escuro-cte',
            'funcao_apos_criacao': function (elemento) {
                elemento.parent().find('.datebox').css('width', '93%');
                elemento.parent().find('.textbox-text').css('width', '93%').css('font-size', '14px');
            }
        });

        let movimentacoesBody = jQuery('#movimentacoesBody');

        jQuery('#btnVerMovimentacoes').on('click', function aoClicarBotaoVerMovimentacoes() {
            let dataInicial = jQuery('#data-inicial').datebox('getValue');
            let dataFinal = jQuery('#data-final').datebox('getValue');

            movimentacoesBody.empty();

            qtdDomMovimentacao = 0;

            jQuery.ajax({
                url: 'MovimentacaoIscasControlador',
                async: true,
                dataType: 'text',
                data: {
                    'acao': 'carregarMovimentacoes',
                    'iscaId': qs['id'],
                    'dataInicial': dataInicial,
                    'dataFinal': dataFinal,
                },
                complete: function aoCarregarPorAjax(jqXHR, textStatus) {
                    let obj = JSON.parse(jqXHR.responseText);

                    if (obj === null) {
                        chamarAlert('Não há movimentações para o período selecionado.');
                    } else {
                        jQuery.each(obj, function aoLoopArrayMovimentacoes(index, movimentacao) {
                            let bodyDom = jQuery('<div class="col-md-12 body-dom celula-zebra-2">');

                            movimentacoesBody.append(bodyDom);
                            bodyDom.load(homePath + '/gwTrans/cadastros/html-dom/dom-movimentacao-isca.jsp?qtdDomMovimentacao=' + (++qtdDomMovimentacao) + '&movimentacao=' + encodeURIComponent(JSON.stringify(movimentacao)));
                        });
                    }
                }
            });
        });

        movimentacoesBody.on('click', '[data-tipo]', function aoClicarVerDocumento() {
            let elemento = jQuery(this);
            let tipo = elemento.attr('data-tipo');
            let id = elemento.attr('data-id');
            
            if (elemento.hasClass('lb-link')) {
                if (tipo === 'manifesto') {
                    window.open(homePath + "/cadmanifesto?acao=editar&id=" + id, "", "width=1200,height=700");
                } else if (tipo === 'romaneio') {
                    window.open(homePath + "/cadromaneio?acao=editar&id=" + id, "", "width=1200,height=700");
                }
            }
            
        });
    } else {
        jQuery('#editarForm').remove();
        jQuery('#cadastrarForm').show();

        jQuery('#arquivo_planilha').gwReadFile({
            limit: 51200, // 50kib - 50kb
            destiny: lerPlanilhaExcel,
            save_file: {
                controller: {
                    data: {
                        extension: ['xsl', 'xlsx', 'csv'],
                        base64: true
                    }
                }
            }
        });

        jQuery('#tabela-gwsistemas').tabelaGwDraggable({
            redimensionavel: false,
            notResizableClass: 'nao'
        });

        jQuery('#adicionarIsca').on('click', function aoClicarAdicionarIsca() {
            adicionarIscaTabela('');
        });
    }

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
});

function lerPlanilhaExcel(base64) {
    let workbook = XLSX.read(base64.substring(base64.lastIndexOf(',') + 1), {type: 'base64'});
    let primeiraPlanilhaNome = workbook.SheetNames[0];
    let primeiraPlanilha = workbook.Sheets[primeiraPlanilhaNome];
    let numerosIscas = XLSX.utils.sheet_to_csv(primeiraPlanilha, {
        'RS': ',',
        'strip': true,
        'blankrows': false
    }).split(',').filter(Boolean);


    numerosIscas.forEach(isca => {
        adicionarIscaTabela(isca);
    });

    jQuery('#arquivo_planilha').val('');
}

function adicionarIscaTabela(isca) {
    qtdDom++;

    let tbody = jQuery('#tabela-gwsistemas').find('tbody');

    let tr = jQuery('<tr>').attr({
        'data-gw-grupo-serializado': 'isca_' + qtdDom,
        'data-gw-grupo-name': 'iscas'
    });

    tr.append(jQuery('<td>'));
    tr.append(jQuery('<td>').append(jQuery('<input>', {
        'type': 'text',
        'value': isca,
        'class': 'input-form-gw sombra',
        'placeholder': 'Número da Isca',
        'data-gw-campo-grupo-serializado': 'isca_' + qtdDom,
        'id': 'numero' + qtdDom,
        'name': 'numero' + qtdDom,
        'maxlength': '40',
        'data-ajuda': 'numero_isca_ajuda',
    })));
    tbody.append(tr);
}