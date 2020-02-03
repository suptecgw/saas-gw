jQuery(document).ready(function () {
    jQuery('#selectBeneficiario').on('change', function () {
        if ($('selectBeneficiario').style.display === 'none') {
            $('idmotorista').value = '0';
            $('motor_nome').value = '';

            $('idFuncionario').value = '0';
            $('nomeFuncionario').value = '';

            $('idajudante').value = '0';
            $('nome').value = '';

            jQuery('#selectBeneficiario').val('0');
            jQuery('div[data-beneficiario]').hide();
        } else {
            if (jQuery('#selectBeneficiario').val() === '0' || jQuery('#selectBeneficiario').val() === 'm') {
                jQuery('#selectBeneficiario').val('m');
                $('idFuncionario').value = '0';
                $('nomeFuncionario').value = '';
                $('idajudante').value = '0';
                $('nome').value = '';
            }else if (jQuery('#selectBeneficiario').val() === 'f'){
                $('idajudante').value = '0';
                $('nome').value = '';
                $('idmotorista').value = '0';
                $('motor_nome').value = '';
            }else if (jQuery('#selectBeneficiario').val() === 'a'){
                $('idmotorista').value = '0';
                $('motor_nome').value = '';
                $('idFuncionario').value = '0';
                $('nomeFuncionario').value = '';
            }
            
            jQuery('div[data-beneficiario]').hide();
            jQuery('div[data-beneficiario="' + jQuery(this).val() + '"]').show();
        }
    }).trigger('change');

    jQuery('#localizarFuncionario').click(function () {
        launchPopupLocate(homePath + '/localiza?acao=consultar&idlista=21&paramaux2=1', 'Funcionario');
    });
    
    jQuery('#localiza_ajudante').click(function() {
        launchPopupLocate(homePath + '/localiza?acao=consultar&idlista=25', 'Ajudante');
    });
});

function aoClicarNoLocaliza(idjanela) {
    if (idjanela.indexOf('Fornecedor') > -1) {
        if ($('tipo_controle_conta_corrente').value == 's') {
            jQuery('.td_veiculo_prop').show();
        } else {
            jQuery('.td_veiculo_prop').hide();
        }
    } else if (idjanela === 'Funcionario') {
        $('idFuncionario').value = $('idfornecedor').value;
        $('nomeFuncionario').value = $('fornecedor').value;
    }
}