jQuery(document).ready(function () {
    jQuery('#btnBaixarXMLs').on('click', function () {
        var cteIds = jQuery('input[name^=ck]:checked').map(function() { return this.value } ).toArray().join(',');
        
        if (cteIds === '') {
            alert('Selecione no minimo 1 CT-e!');
            
            return;
        }

        var filialId = jQuery('#filial').val();

        var data = new Date();
        // A função "toPaddedString" vem do Prototype.JS.
        // A função getMonth() retorna um valor entre 0 a 1, então adicionar +1 para pegar um valor entre 1 a 12.
        window.location.href = homePath + '/CTe_XML_' + data.getDate().toPaddedString(2) + '_' + (data.getMonth() + 1).toPaddedString(2) + '_' + data.getFullYear() + '.zip?acao=CTe&tipo=ids&modelo=cte&idFilial=' + filialId + '&ids=' + cteIds;
    });
});

function efetuarLogOff() {
    location.replace("UsuarioControlador?acao=logoff");
}

function usuarioAceitouAtualizarCertificado() {
    $('.bloqueio-tela').show();
    $('.gif-bloq-tela').show();

    jQuery.post(`${homePath}/CertificadoDigitalMigracaoControlador`, {'acao': 'migrar'}, function retornoAjaxAtualizarCertificados(data) {
        $('.bloqueio-tela').hide();
        $('.gif-bloq-tela').hide();

        chamarAlert(data['mensagem'], function () {
            if (data['mensagem'].indexOf('Erro') === -1) {
                efetuarLogOff();
            }
        });
    }, 'json');
}

function usuarioNaoAceitouAtualizarCertificado() {
    chamarAlert('O envio dos documentos fiscais não irão funcionar até que essa atualização seja feita.');
}