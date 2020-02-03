function alterarSenha() {
    jQuery(".div-tela-toda").css("display", "block");
    jQuery(".div-mudar-senha").css("display", "block");
    jQuery(".div-mudar-senha").animate({
        opacity: 1.0
    });
    jQuery(".div-tela-toda").animate({
        opacity: 0.6
    });
}

function fecharAlterarSenha() {
    jQuery(".div-mudar-senha").animate({
        opacity: 0.0
    }, function () {
        jQuery(".div-mudar-senha").css("display", "none");
    });
    jQuery(".div-tela-toda").animate({
        opacity: 0.0
    }, function () {
        jQuery(".div-tela-toda").css("display", "none");
    });

    jQuery("#senhaAtual").val('');
    jQuery("#senhaNova").val('');
    jQuery("#repetirSenha").val('');
}

jQuery(document).ready(function () {
    var deverarMostrarAlterarSenha = jQuery('#statusErro').val() === '004';

    if (deverarMostrarAlterarSenha) {
        alterarSenha();
    }else{
        fecharAlterarSenha();
    }
    
    jQuery('.img-senha-fechar,button[name="btnCancelar"]').on('click', function () {
        fecharAlterarSenha();
    });
    
    jQuery('button[name="btnSalvar"]').on('click', function (e) {
        e.preventDefault();

        if (jQuery("#senhaAtual").val() === '' || jQuery("#senhaNova").val() === '' || jQuery("#repetirSenha").val() === '') {
            chamarAlert("Preencha os campos corretamente!");
        } else if (jQuery("#senhaNova").val() !== jQuery("#repetirSenha").val()) {
                chamarAlert('Os campos "Nova senha" e "Repetir nova senha" devem ter valores iguais!');
        } else {
            var formulario = jQuery('#formSenha').gwFormToJson();

            $.post(homePath + '/UsuarioControlador', {
                'acao': 'renovarSenhaLogin',
                'form': formulario
            }, function (data) {
                if (data) {
                    if (data['erro']) {
                        chamarAlert(data['erro']);
                    } else {
                        chamarAlert('Senha atualizada com sucesso! Por favor, logue novamente', function () {
                            window.location = homePath;
                        });
                    }
                }
            }, 'json');
        }
    });
});