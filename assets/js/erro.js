"use strict";

const mensagemErroDiv = $('.msg-erro');

$(document).ready(function () {
    if (temExcecao === 'true') {
        mensagemErroDiv.append($('<hr>'));
        mensagemErroDiv.append($('<label>', {
            'class': 'lb-link',
            'id': 'visualizarDetalhes',
            'data-micromodal-trigger': 'modal-erro'
        }).text('Informações Técnicas'));
    }

    MicroModal.init({
        awaitCloseAnimation: true,
        disableFocus: true,
        disableScroll: true
    });
    
    if (javax_servlet_error_message != null && javax_servlet_error_message != '') {
        jQuery(".msg-erro").text(javax_servlet_error_message);
    }
});

