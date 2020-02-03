var qtdDom = 0;
var contador = 0;
var dadosTabela = [];

jQuery(document).ready(function () {
    // Apaga a função toJSON do Prototype, ela está influenciando na conversão de array para JSON
    // O Prototype primeiro converte arrays para json, para depois colocar no JSON como uma string de json
    // https://stackoverflow.com/questions/29637962/json-stringify-turned-the-value-array-into-a-string
    delete Array.prototype.toJSON;

    var containerVeiculo = jQuery('.container-tabela-veiculo');

    jQuery('#visualizarTabelaCarreteiro').on('click', function () {
        jQuery(".gif-bloq-tela,.bloqueio-tela").css("display", "block");

        // Carregar os dados do controlador
        // http://localhost:8084/webtrans-custom-c11/TabelaPrecoControlador?acao=localizarTabelaPrecoVeiculo&cidadeOrigemId=2587&cidadeDestinoId=4993&clienteId=0

        jQuery('.container-tabela-veiculo').find('.container-nova-linha').remove();

        jQuery.get(homePath + '/TabelaPrecoControlador', {
            'acao': 'localizarTabelaPrecoVeiculo',
            'cidadeOrigemId': jQuery('#idcidadeorigem').val(),
            'cidadeDestinoId': jQuery('#idcidadedestino').val(),
            'clienteId': jQuery('#idremetente').val()
        }, function (data) {
            if (data) {
                qtdDom = 0;
                contador = 0;
                dadosTabela = [];

                jQuery.each(data, function (index, value) {
                    var json = {};

                    json['qtdDom'] = ++qtdDom;
                    json['tabelaRotaVeiculoId'] = value['id'];
                    json['tipoVeiculo'] = value['tipo_veiculo'];
                    json['cliente'] = value['cliente'];
                    json['tipoProduto'] = value['tipo_produto'];
                    json['tipoValor'] = value['tipo_valor'];
                    json['valorTabela'] = parseFloat(value['valor']).toFixed(2).replace('.', ',');
                    json['valorExcedenteKG'] = parseFloat(value['valor_peso_excedente']).toFixed(2).replace('.', ',');
                    json['valorSegundaViagem'] = parseFloat(value['valor_viagem_2']).toFixed(2).replace('.', ',');
                    json['valorPedagio'] = parseFloat(value['valor_pedagio']).toFixed(2).replace('.', ',');
                    json['valorTaxaEntrega'] = parseFloat(value['valor_entrega']).toFixed(2).replace('.', ',');
                    json['taxaEntregaPartirDe'] = value['qtd_entregas_apartir'];
                    json['valorDiaria'] = parseFloat(value['valor_diaria']).toFixed(2).replace('.', ',');
                    if (value['considerar_campo_cte'] !== null) {
                        json['considerarCampoCte'] = value['considerar_campo_cte'];
                    }
                    json['deduzirPedagioFrete'] = value['is_deduzir_pedagio'];
                    json['carregarValorPedagioCte'] = value['is_carregar_pedagio_ctes'];
                    json['valorTaxaFixa'] = parseFloat(value['valor_taxa_fixa']).toFixed(2).replace('.', ',');
                    json['valorMaximo'] = parseFloat(value['valor_maximo']).toFixed(2).replace('.', ',');
 
                    dadosTabela.push(json);

                    containerVeiculo.append(jQuery('<div>', {'class': 'container-nova-linha'})
                        .load(homePath + '/gwTrans/dom/tipo-veiculo-tabela-rota.html?v=' + (Math.floor(Math.random() * 999999999) + 1)));
                });

                jQuery('.container-cabecalho').show();
            } else {
                jQuery(".gif-bloq-tela,.bloqueio-tela").css("display", "none");
                chamarAlert('Não foram encontradas tabelas de carreteiro para essa origem, destino e cliente!');
            }
        });

        containerVeiculo.on('change', 'select[name="tipoValor"]', function () {
            var elemento = jQuery(this);
            var valor = elemento.val();
            var parente = elemento.parent().parent().parent();

            parente.find('[data-valor-tipo]').hide();
            parente.find('[data-valor-tipo="' + valor + '"]').show();

            if (valor === 'f') {
                var elementoValor = parente.find('input[name="valorTabela"]');
                var elementoValorMaximo = parente.find('input[name="valorMaximo"]');

                if (pontoParseFloat(elementoValor.val()) > pontoParseFloat(elementoValorMaximo.val())) {
                    elementoValorMaximo.val(elementoValor.val());
                }
            }
        });

        containerVeiculo.on('change', 'input[name="carregarValorPedagioCte"]', function () {
            var elemento = jQuery(this);
            var checked = elemento.is(':checked');
            var parente = elemento.parent().parent().parent().parent();
            var input = parente.find('input[name="valorPedagio"]');

            if (!checked) {
                input.removeClass('inputReadOnly8pt');
                input.prop('readonly', false);
            } else {
                input.addClass('inputReadOnly8pt');
                input.prop('readonly', true);
            }
        });

        containerVeiculo.on('change', 'input[name="valorTabela"],input[name="valorMaximo"]', function () {
            var elemento = jQuery(this);
            var parente = elemento.parent().parent().parent();
            var elementoValor = parente.find('input[name="valorTabela"]');
            var elementoValorMaximo = parente.find('input[name="valorMaximo"]');

            if (pontoParseFloat(elementoValor.val()) > pontoParseFloat(elementoValorMaximo.val())) {
                elementoValorMaximo.val(elementoValor.val());
            }
        });
    });
});