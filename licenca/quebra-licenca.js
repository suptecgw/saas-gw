jQuery(document).ready(function () {
    jQuery('.bt-conexao').click(function () {
        jQuery('[card-conexao]').addClass('loading');
        jQuery('.img-connection').attr('src', homePath + '/licenca/conection.gif');
        jQuery('.footer-card').hide(250);
        jQuery('.card-geral').css('height', '80%');
        tentarConexaoWebService();
    });

    jQuery('.abrir-impressao-boleto').click(function () {
        
        efetuarLogin();
        

    });
    jQuery('.fechar-iframe-boletos').click(function () {
        jQuery('.cobre-tudo').css('background', '');
        jQuery('.cobre-tudo').css('opacity', '');
        jQuery('.container-iframe-boletos').css('visibility', 'hidden');
        jQuery('.cobre-tudo').hide();
    });
});

var timeOutConexao = null;
function encerraTesteConexao() {
    timeOutConexao = setTimeout(function () {
        if (servidor_online) {
            jQuery('.img-connection').attr('src', homePath + '/licenca/yes_conection.png');
            jQuery('[card-conexao]').removeClass('loading');
            jQuery('.bt-conexao').hide();
            jQuery('.card-geral').css('height', '94%');
            jQuery('.span-aviso').show();
            jQuery('.footer-card').show(250);
        } else {
            jQuery('[card-conexao]').removeClass('loading');
            jQuery('.img-connection').attr('src', homePath + '/licenca/no_conection.png');

            jQuery('.card-geral').css('height', '94%');
            jQuery('.footer-card').show(250);
        }
    }, 3000);
}

function verificar() {
    window.location = 'home?acao=verify_payment';
}

function tentarConexaoWebService() {
    jQuery.ajax({
        url: "LicencaControlador",
        data: {
            acao: 'verificar_web_service',
            codigoCliente: codigo_cliente
        },
        success: function (data, textStatus, jqXHR) {
            servidor_online = data.trim() === 'true';
        },
        error: function (jqXHR, textStatus, errorThrown) {
            servidor_online = jqXHR.responseText.trim() === 'true';
        },
        complete: function (jqXHR, textStatus) {
            encerraTesteConexao();
        }
    });
}

function verificarConexaoWebService() {
    jQuery.ajax({
        url: "LicencaControlador",
        data: {
            acao: 'verificar_web_service',
            codigoCliente: codigo_cliente
        },
        success: function (data, textStatus, jqXHR) {
            servidor_online = data.trim() === 'true';
            if (!servidor_online) {
                jQuery('[card-conexao]').show();
                if (is_cloud) {
                    jQuery('[msg-bloqueio]').html('Identificamos um problema de conexão entre seu servidor e o servidor da GW Sistemas. Por favor entrar em contato no número : (81) 2125-3752.');
                } else {
                    jQuery('[msg-bloqueio]').html('Identificamos um problema de conexão entre seu servidor e o servidor da GW Sistemas. Por favor verifique sua conexão com a internet e seu firewall e pressione: <br> "Testar Conexão"');
                }
            }

        },
        error: function (jqXHR, textStatus, errorThrown) {
            servidor_online = jqXHR.responseText.trim() === 'true';
            if (!servidor_online) {
                jQuery('[card-conexao]').show();
                if (is_cloud) {
                    jQuery('[msg-bloqueio]').html('Identificamos um problema de conexão entre seu servidor e o servidor da GW Sistemas. Por favor entrar em contato no número : (81) 2125-3752.');
                } else {
                    jQuery('[msg-bloqueio]').html('Identificamos um problema de conexão entre seu servidor e o servidor da GW Sistemas. Por favor verifique sua conexão com a internet e seu firewall e pressione: <br> "Testar Conexão"');
                }
            }

        }
    });
}