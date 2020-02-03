let qtdDomCnpjAutorizadoCTe = 0;
let qtdDomCnpjAutorizadoMDFe = 0;

function localizarContaContabil(conta) {
    espereEnviar("", true);

    jQuery.ajax({
        url: "./PlanoContaControlador",
        dataType: "text",
        method: "post",
        async: false,
        data: {
            'acao': "localizarContaContabil",
            'conta': conta
        },
        success: function (data) {
            var conta = jQuery.parseJSON(data);

            espereEnviar("", false);

            if (conta === undefined || conta === null) {
                alert("Plano de contas não encontrado!");

                return false;
            } else if (conta === '' || conta.erro === 'true') {
                alert("Plano de contas não encontrado!");

                return false;
            } else {
                $('plano_contas_id').value = conta.id;
                $('cod_conta').value = conta.codigo;
                $('plano_conta_descricao').value = conta.descricao;

                return true;
            }
        }, error: function () {
            alert("Erro inesperado, favor refazer a operação.");
        }
    });
}

function limparContaContabil() {
    $('plano_conta_descricao').value = "";
    $('cod_conta').value = "";
    $('plano_contas_id').value = "0";
}

jQuery(document).ready(function aoCarregar() {
    jQuery('#btnAdicionarCnpjAutorizadoCTe').on('click', aoClicarAdicionarCnpjAutorizadoCTe);
    jQuery('#btnAdicionarCnpjAutorizadoMDFe').on('click', aoClicarAdicionarCnpjAutorizadoMDFe);

    jQuery('#bodyCnpjAutorizadoCTe').on('click', '.btnExcluirCnpjAutorizadoCTe', excluirCnpjAutorizadoCTe);
    jQuery('#bodyCnpjAutorizadoMDFe').on('click', '.btnExcluirCnpjAutorizadoMDFe', excluirCnpjAutorizadoMDFe);
});

function aoClicarAdicionarCnpjAutorizadoCTe(evento, id, cnpj) {
    const bodyCnpjAutorizadoCTe = jQuery('#bodyCnpjAutorizadoCTe');

    bodyCnpjAutorizadoCTe.append(criarTrCnpjAutorizado('CTe', ++qtdDomCnpjAutorizadoCTe, id, cnpj));

    $('qtdDomCnpjAutorizadoCTe').value = qtdDomCnpjAutorizadoCTe;
}

function aoClicarAdicionarCnpjAutorizadoMDFe(evento, id, cnpj) {
    const bodyCnpjAutorizadoMDFe = jQuery('#bodyCnpjAutorizadoMDFe');

    bodyCnpjAutorizadoMDFe.append(criarTrCnpjAutorizado('MDFe', ++qtdDomCnpjAutorizadoMDFe, id, cnpj));

    $('qtdDomCnpjAutorizadoMDFe').value = qtdDomCnpjAutorizadoMDFe;
}

function criarTrCnpjAutorizado(tipo, qtdDom, id, cnpj) {
    if (id === undefined) {
        id = 0;
    }

    if (cnpj === undefined) {
        cnpj = '00.000.000/0000-00';
    }

    return jQuery('<tr>', {'class': 'CelulaZebra2'})
        .append(jQuery('<td>', {'align': 'center'})
            .append(jQuery('<img>', {
                'src': `${homePath}/img/lixo.png`,
                'class': 'imagemLink btnExcluirCnpjAutorizado' + tipo
            })))
        .append(jQuery('<td>', {'align': 'center'})
            .append(jQuery('<input>', {
                'type': 'hidden',
                'id': 'idCnpjAutorizado' + tipo + '_' + qtdDom,
                'name': 'idCnpjAutorizado' + tipo + '_' + qtdDom,
                'value': id
            }))
            .append(jQuery('<input>', {
                'type': 'text',
                'value': cnpj,
                'class': 'inputtexto',
                'style': 'margin-left: 10px',
                'maxlength': '18',
                'id': 'cnpjAutorizado' + tipo + '_' + qtdDom,
                'name': 'cnpjAutorizado' + tipo + '_' + qtdDom
            }).mask('00.000.000/0000-00', {reverse: true})))
        .append(jQuery('<td>'))
}

function excluirCnpjAutorizadoCTe() {
    let tr = jQuery(this).parent().parent();
    let id = tr.find('input[name^="idCnpjAutorizadoCTe_"]').val();

    if (confirm('Deseja excluir o CNPJ?')) {
        if (confirm("Tem certeza?")) {
            tr.hide('slow', function aoExcluirTrCnpjAutorizadoCTe() {
                jQuery(this).remove();
                
                if (id !== '0') {
                    // Executar Ajax
                    jQuery.ajax({
                        type: 'POST',
                        url: `${homePath}/FilialControlador`,
                        data: {
                            'acao': 'excluirCnpjAutorizado',
                            'id': id
                        },
                        async: false
                    });
                }

                alert("CNPJ removido com sucesso!");
            });
        }
    }
}

function excluirCnpjAutorizadoMDFe() {
    let tr = jQuery(this).parent().parent();
    let id = tr.find('input[name^="idCnpjAutorizadoMDFe_"]').val();

    if (confirm('Deseja excluir o CNPJ?')) {
        if (confirm("Tem certeza?")) {
            tr.hide('slow', function aoExcluirTrCnpjAutorizadoMDFe() {
                jQuery(this).remove();

                if (id !== '0') {
                    // Executar Ajax
                    jQuery.ajax({
                        type: 'POST',
                        url: `${homePath}/FilialControlador`,
                        data: {
                            'acao': 'excluirCnpjAutorizado',
                            'id': id
                        },
                        async: false
                    });
                }

                alert("CNPJ removido com sucesso!");
            });
        }
    }
}