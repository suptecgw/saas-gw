$(document).ready(function () {
    jQuery('#dataDeAuditoria,#dataAteAuditoria').gwDatebox({
        'icone_classe': 'combo-arrow-escuro-cte-auditoria',
        'funcao_apos_criacao': function (elemento) {
            elemento.parent().find('.datebox').css('width', '93%');
            elemento.parent().find('.textbox-text').css('width', '93%').css('font-size', '14px');
        }
    });

    var btnPesquisarAuditoria = $('button[name="btn-auditoria"]');
    var inputAuditoria = $('input[name="inp-auditoria"]');
    var isExclusao = inputAuditoria.attr('data-exclusao') === 'true';
    var rotinaAuditoria = inputAuditoria.attr('data-rotina-auditoria');
    var tabelaId = inputAuditoria.attr('data-auditoria-id');

    btnPesquisarAuditoria.on('click', function () {
        var btn = this;

        checkSession(function () {
            var dataDe = jQuery('#dataDeAuditoria').datebox('getValue');
            var dataAte = jQuery('#dataAteAuditoria').datebox('getValue');

            btn.classList.add('loading1');
            btn.setAttribute('disabled', 'disabled');

            acaoBtAuditoria(btn, rotinaAuditoria, isExclusao, tabelaId, dataDe, dataAte);
        });
    });
});

function acaoBtAuditoria(button, rotina, isExclusao, tabelaId, dataDe, dataAte) {
    $.ajax({
        url: 'AuditoriaControlador?dataDe=' + dataDe + '&dataAte=' + dataAte,
        data: {
            'acao': 'listarAuditoria',
            'rotina': rotina,
            'tabelaId': tabelaId,
            'exclusao': isExclusao
        },
        complete: function (jqXHR, textStatus) {
            try {
                var tbody = jQuery('.tb-auditoria > tbody');
                // Limpando o tbody
                tbody.html('');
                var logAcoes = JSON.parse(jqXHR.responseText)['list'][0]['logAcoesWebtrans'];
                var srcImg = homePath + '/assets/img/icones/visualizar_documentos.png';

                if (logAcoes && logAcoes.length > 0) {
                    $.each(logAcoes, function (i, e) {
                        addLogAction(tbody, srcImg, e);
                    });
                } else if (logAcoes) {
                    addLogAction(tbody, srcImg, logAcoes);
                }
            } catch (exception) {
                console.error(exception);
                chamarAlert('Nenhuma alteração foi encontrada');
            } finally {
                setTimeout(function () {
                    button.classList.remove('loading1');
                    button.removeAttribute('disabled');
                }, 1000);
            }
        }
    });
}

function addLogAction(tbody, src_img, e) {
    var tr = jQuery('<tr>');
    var td = jQuery('<td>').text(e.nomeUsuario);
    var inputHidden = jQuery('<input type="hidden">').val(JSON.stringify(e.logAcao.campos[0].campos));
    td.append(inputHidden);

    tr.append(td);
    tbody.append(tr);

    td = jQuery('<td>').text(e.dataAcao);
    tr.append(td);
    tbody.append(tr);

    switch (e.logAcao.action) {
        case 'I':
            td = jQuery('<td>').text('Incluiu');
            tr.append(td);
            tbody.append(tr);
            break;
        case 'U':
            td = jQuery('<td>').text('Atualizou');
            tr.append(td);
            tbody.append(tr);
            break;
        case 'D':
            td = jQuery('<td>').text('Excluiu');
            tr.append(td);
            tbody.append(tr);
            break;
    }

    td = jQuery('<td class="ip-cliente" title="'+e.logAcao.clientAddr+'">').text(e.logAcao.clientAddr);
    tr.append(td);
    tbody.append(tr);


    var img = jQuery('<img>').attr('src', src_img);
    td = jQuery('<td>').html(img);
    tr.append(td);
    tbody.append(tr);

    img.click(function () {
        detalhesAuditoria(this);
    });
}

function detalhesAuditoria(e) {
    var inputHidden = $(e).parents('tr').find('td:first-child').find('input[type="hidden"]');
    var arr = inputHidden.val();
    var tbody = jQuery('.tb-auditoria-detalhes > tbody');
    tbody.html('');
    $.each(JSON.parse(String(arr)), function (i, e) {
        var tr = jQuery('<tr>');
        var td = jQuery('<td>');
        td.text(e.descricao);
        tr.append(td);

        var td = jQuery('<td>');
        td.text(e.antes);
        tr.append(td);

        var td = jQuery('<td>');
        td.text(e.depois);
        tr.append(td);

        tbody.append(tr);

    });
    
    var tds = $(e).parents('tr').find('td');
    var usuarioTbody = $('.tb-auditoria-detalhes-usuario > tbody');
    usuarioTbody.html('');
    usuarioTbody.append(
        $('<tr>')
            .append($('<td>').text($(tds[0]).text()))
            .append($('<td>').text($(tds[1]).text()))
            .append($('<td>').text($(tds[2]).text()))
            .append($('<td>').text($(tds[3]).text()))
    );
    
    $('.cobre-tudo').show(100);
    $('.detalhes-auditoria').show(100);
}

function fecharAuditoria() {
    $('.cobre-tudo').hide(100);
    $('.detalhes-auditoria').hide(100);
}