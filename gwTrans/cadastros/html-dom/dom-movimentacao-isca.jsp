<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=ISO-8859-1" %>
<div data-movimentacao="${param['qtdDomMovimentacao']}" style="height: 40px;">
    <div class="col-md-11" style="padding-top: 6px;">
        <div style="margin-bottom: 0;width: 10%;display: inline-block;">
            <span class="container-input-form-gw input-width-100">
                <input class="input-form-gw input-width-100 ativa-helper input-readonly" data-campo="data_saida" readonly>
            </span>
        </div>
        <div style="margin-bottom: 0;width: 10%;display: inline-block;">
            <span class="container-input-form-gw input-width-100">
                <input class="input-form-gw input-width-100 ativa-helper input-readonly" data-campo="data_chegada" readonly>
            </span>
        </div>
        <div style="margin-bottom: 0;width: 15%;display: inline-block;">
            <span class="container-input-form-gw input-width-100">
                <input class="input-form-gw input-width-100 ativa-helper input-readonly" data-campo="filial" readonly>
            </span>
        </div>
        <div style="margin-top: 6px;width: 15%;display: inline-block;">
            <strong><label class="lb-link" data-campo="manifesto_romaneio" data-id="manifesto_romaneio"></label></strong>
        </div>
        <div style="margin-bottom: 0;width: 17%;display: inline-block;">
            <span class="container-input-form-gw input-width-100">
                <input class="input-form-gw input-width-100 ativa-helper input-readonly" data-campo="motorista" readonly>
            </span>
        </div>
        <div style="margin-bottom: 0;width: 15%;display: inline-block;">
            <span class="container-input-form-gw input-width-100">
                <input class="input-form-gw input-width-100 ativa-helper input-readonly" data-campo="cidade_destino" readonly>
            </span>
        </div>
        <div style="margin-bottom: 0;width: 15%;display: inline-block;">
            <span class="container-input-form-gw input-width-100">
                <input class="input-form-gw input-width-100 ativa-helper input-readonly" data-campo="veiculo" readonly>
            </span>
        </div>
    </div>
</div>
<script>
    let json = JSON.parse(decodeURIComponent('${param['movimentacao']}'));
    let divMovimentacao = jQuery('[data-movimentacao="${param['qtdDomMovimentacao']}"]');
    
    console.log(divMovimentacao);

    for (let key of Object.keys(json)) {
        divMovimentacao.find('[data-campo="' + key + '"]').val(json[key]).attr('title', json[key]);
    }
    
    let lblNumero = divMovimentacao.find('[data-campo="manifesto_romaneio"]');
    if (json['manifesto_id'] !== null) {
        if (json['filial_id'] === filial_id && !pode_ver_manifesto_propria_filial) {
            lblNumero.removeClass('lb-link').addClass('lb-no-link');
        } else if (json['filial_id'] !== filial_id && !pode_ver_manifesto_outra_filial) {
            lblNumero.removeClass('lb-link').addClass('lb-no-link');
        }

        lblNumero.text(json['manifesto_numero']).attr('data-id', json['manifesto_id']).attr('data-tipo', 'manifesto');
    } else if (json['romaneio_id'] !== null) {
        if (json['filial_id'] === filial_id && !pode_ver_romaneio_propria_filial) {
            lblNumero.removeClass('lb-link').addClass('lb-no-link');
        } else if (json['filial_id'] !== filial_id && !pode_ver_romaneio_outra_filial) {
            lblNumero.removeClass('lb-link').addClass('lb-no-link');
        }

        lblNumero.text(json['romaneio_numero']).attr('data-id', json['romaneio_id']).attr('data-tipo', 'romaneio');
    }
</script>