jQuery(document).ready(function () {
    jQuery('#add_adiant').click(function () {
        var mensagem = '';

        switch ($('selectBeneficiario').value) {
            case 'm':
                mensagem = 'ADV MOT: ' + $('motor_nome').value + ' REF. VIAGEM ' + $('numviagem').value;
                break;
            case 'a':
                mensagem = 'ADV AJU: ' + $('nomeAjudante1').value + ' REF. VIAGEM ' + $('numviagem').value;
                break;
            case 'f':
                mensagem = 'ADV FUN: ' + $('nomeFuncionario').value + ' REF. VIAGEM ' + $('numviagem').value;
                break;
        }
        if($('selectBeneficiario').value == 'a' && $('idAjudante1').value ==0){
            alert("Para incluir adiantamento, o ajudante deverá ser preenchido.");
        }else if($('selectBeneficiario').value == 'f' && $('idFuncionario').value ==0){
            alert("Para incluir adiantamento, o funcionário deverá ser preenchido.");
        }else{
            addAdiantamento($('saidaem').value, '0.00', mensagem, '', 0, true, 0, false, $('saidaem').value, 0, 0, '', 0, '', 0, 0, 0, 0, 0, '', false, false); // 20 parametros
        }
    });

    jQuery('#selectBeneficiario').change(function () {
        switch (jQuery(this).val()) {
            case "m":
                visivel($('trMotorista'));
                visivel($('trAjudante1'));
                visivel($('trAjudante2'));
                invisivel($('trFuncionario'));
                break;
            case "a":
                visivel($('trMotorista'));
                visivel($('trAjudante1'));
                visivel($('trAjudante2'));
                invisivel($('trFuncionario'));
                break;
            case "f":
                invisivel($('trMotorista'));
                invisivel($('trAjudante1'));
                invisivel($('trAjudante2'));
                visivel($('trFuncionario'));
                break;
        }
    }).trigger('change');

    jQuery('#localizarFuncionario').click(function () {
        launchPopupLocate(homePath + '/localiza?acao=consultar&idlista=21&paramaux2=1', 'Funcionario');
    });

    jQuery('#verCadastroFuncionario').click(function () {
        window.open('./cadfornecedor?acao=editar&id=' + $('idFuncionario').value, 'Funcionario', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    });
});

function carregarSaldo(fornecedor) {
    var id = $("idmotorista").value;

    if (fornecedor == 1) {
        id = $('idAjudante1').value;
    } else if (fornecedor == 2) {
        id = $('idFuncionario').value;
    }

    var viagem = $('viagemId').value;
    var dataBase = $("saidaem").value;

    jQuery.get(homePath + '/ViagemControlador', {
        'acao': (fornecedor == 1 || fornecedor == 2 ? 'obterSaldoFornecedor' : 'obterSaldoMotorista'),
        'id': id,
        'viagemId': viagem,
        'dataBase': dataBase
    }, function (data) {
        if (data) {
            $("saldoMotorista").value = formatoMoeda(data['saldo']);
        }
    }, 'json');
}

function zeraSaldoAnterior() {
    $('saldoMotorista').value = '0.00';
    totalAdiantamento();
    totalDespesasAvista();
    totalAcerto();
}