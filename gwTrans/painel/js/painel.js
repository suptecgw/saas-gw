// função copiada do arquivo de funções. Mateus disse que seria melhor copiar a função do que importar tudo.
function colocarPonto(number) {
    number = number.replace(/\./, '');
    number = number.replace(/\,/, '.');
    return number;
}

//Variaveis
var graficos = {
    peso_total: 0,
    capacidade_total: 0,
    qtd_total_entregas: 0,
    qtd_total_entregas_realizadas: 0,
    peso_total_entregue: 0,
    peso_total_nao_entregue: 0,
    volume_total_entregue: 0,
    volume_total_nao_entregue: 0,
    valor_total_entregue: 0,
    valor_total_nao_entregue: 0,
    peso_cubado: 0,
    peso_cubado_veiculo_total: 0,
};

var intervalAtualizarPagina = null;

//mudar cor de variavel
//document.documentElement.style.setProperty('--bg-nav', 'red');;
$(function () {

    /*
     * Campos de exceto apenas
     */
    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-veiculo').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptVeiculo').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-motorista').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptMotorista').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-setor').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptSetorEntrega').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-uf-destino').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptUfDestino').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-cidades-destino').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptCidades').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#select-exceto-apenas-cliente').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptCliente').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    /*
     * Fim campos de exceto apenas
     */

    $(".sortable").sortable({
        handle: ".move"
    });

    $(".sortable").disableSelection();

    $('#select-atualizar-resultados').change(function () {
        clearInterval(intervalAtualizarPagina);
        if (document.getElementById('select-atualizar-resultados').value !== 0) {
            var atualizarPagina = {
                tempo: document.getElementById('select-atualizar-resultados').value,
                multiplo: 1000*60, // a tela é por minutos, então tem que ter o x60
                usuario: usuario
            };
            intervalAtualizarPagina = setInterval(function () {
                pesquisar(false);
            }, atualizarPagina.tempo * atualizarPagina.multiplo);
            localStorage.setItem('atualizarPagina', JSON.stringify(atualizarPagina));
        } else {
            var atualizarPagina = {
                tempo: document.getElementById('select-atualizar-resultados').value,
                multiplo: 1000*60, // a tela é por minutos, então tem que ter o x60
                usuario: usuario
            };
            localStorage.setItem('atualizarPagina', JSON.stringify(atualizarPagina));
        }
    });

    $('input[type=radio][name=estilo-layout]').change(function () {
        if (this.value == 'table') {
            $('.section-dados').show();
            $('.section-grafico').css('visibility', 'hidden');
            criarPopularTable();
        } else if (this.value == 'card') {
            $('.section-dados').show();
            $('.section-grafico').css('visibility', 'hidden');
            criarPupularCard();
        } else if (this.value == 'grafico') {
            $('.section-dados').hide();
            $('.section-grafico').css('visibility', 'visible');
        }
    });

    $('.li-nav-menu-lateral').click(function (e) {
        var container = null;
        if (e.target.id === 'filtros') {
            $('.title-filtros').html('<i class="fa fa-search" style="margin-right:8px;"></i><label class="margin-left:10px;">Filtros</label>');
            container = $('.container-filtros-filtros');
            $('.container-bt-consulta').show();
        } else {
            container = $('.container-filtros-ajustes');
            $('.title-filtros').html('<i class="fa fa-cogs" style="margin-right:8px;"></i><label class="margin-left:10px;">Ajustes</label>');
            $('.container-bt-consulta').hide();
        }

        $('.section-dados').css('width', 'calc(75% - 40px)');
        $('.section-grafico').css('width', 'calc(75% - 40px)');

        // $('.cobre-dados').css('width', 'calc(75% - 40px)');
        // $('.cobre-dados').css('left', '25%');


        $('.nav-menu-lateral').animate({
            'width': '25%'
        }, 250, function () {
            $('.li-nav-menu-lateral').hide();
            $('.fechar-menu-lateral').show();
            //ativando
            container.show();
            $('.title-filtros').show();
        });
    });

    $('.fechar-menu-lateral').click(function () {
//        $('.section-dica').css('width', 'calc(100% - 100px)');
        $('.section-dados').css('width', '');
        $('.section-grafico').css('width', '');
        // $('.cobre-dados').css('width', '');
        // $('.cobre-dados').css('left', '');

        $('.nav-menu-lateral').animate({
            'width': '55px'
        }, 250, function () {
            $('.li-nav-menu-lateral').show();
            $('.fechar-menu-lateral').hide();
        });

        $('.container-bt-consulta').hide();
        $('.container-filtros').hide();
        $('.title-filtros').hide();
    });


//    jQuery('#emitidoEm,#emitidoAte').gwDatebox({
    jQuery('#emitidoEm,#emitidoAte').gwDatebox({
        'icone_classe': 'combo-arrow-escuro-cte-auditoria',
        'funcao_apos_criacao': function (elemento) {
            elemento.parent().find('.datebox').css('width', '93%');
            elemento.parent().find('.textbox-text').css('width', '93%').css('font-size', '14px');
        }
    });

//    criarPupularCard();


//    $('.section-dados').hide();
//    $('.section-grafico').show();

    pesquisar(false);


    // $('.section-grafico').show();
    $('.section-dados').hide();

    setTimeout(function () {
        $($('.localiza')[0]).html('<iframe id="localizarFilial" input="inptFilial" name="localizarFilial" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilial&tema=" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
        $($('.localiza')[1]).html('<iframe id="localizarVeiculoGeral" input="inptVeiculo" name="localizarVeiculoGeral" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarVeiculoGeral&tema=" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
        $($('.localiza')[2]).html('<iframe id="localizarMotorista" input="inptMotorista" name="localizarMotorista" src="LocalizarControlador?acao=abrirLocalizar&tipoLocalizar=localizarMotorista&idLocalizar=localizarMotorista&tema=" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
        $($('.localiza')[3]).html('<iframe id="localizarSetorEntrega" input="inptSetorEntrega" name="localizarSetorEntrega" src="LocalizarControlador?acao=abrirLocalizar&tipoLocalizar=localizarSetorEntrega&idLocalizar=localizarSetorEntrega&tema=" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
        $($('.localiza')[5]).html('<iframe id="localizarCidade" input="inptCidades" name="localizarCidade" src="LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidade&tema=" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
        $($('.localiza')[6]).html('<iframe id="localizarCliente" input="inptCliente" name="localizarCliente" src="LocalizarControlador?acao=abrirLocalizar&tipoLocalizar=localizarCliente&idLocalizar=localizarCliente&tema=" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
    }, 1);

    verificarAtualizarPagina();

});

var card = null;

function pesquisar(nC) {
    $('.bloqueio-tela').show();
    $('.gif-bloq-tela').show();

    $.ajax({
        url: 'PainelControlador',
        method: 'POST',
        data: {
            codTela: 121,
            novaConsulta: nC,
            tipo: $('input[name=radio-mostrar]:checked').val(),
            emitidoEm: $('[name=emitidoEm]').val(),
            emitidoAte: $('[name=emitidoAte]').val(),
            filiais: $('#inptFilial').val(),
            veiculos: $('#inptVeiculo').val(),
            motoristas: $('#inptMotorista').val(),
            setores: $('#inptSetorEntrega').val(),
            cidades: $('#inptCidades').val(),
            clientes: $('#inptCliente').val()
        },
        complete: function (jqXHR, textStatus) {
            var json = jqXHR.responseText.split('@!@');
            if (!json[0]) {
                chamarAlert('Nenhum resultado foi encontrado.');
                $('.section-dados').html('');
                $('.section-grafico').css('visibility', 'hidden');
                $('.section-dados').show();
                $('.bloqueio-tela').hide();
                $('.gif-bloq-tela').hide();
            } else {
                card = JSON.parse(json[0]);
                criarPupularCard();
                cardGraficoInit();
                graficoPizzaInit();
                pesquisarGrafBarras();
            }

            try {
                var filtros = JSON.parse(json[1]);
                $.each(filtros, function (element, value) {
                    if (document.getElementById(element)) {
                        if (element.includes('emitido')) {
                            setTimeout(function () {
                                jQuery('#' + element).datebox('setValue', value[0]);
                            }, 1500);
                        } else {
                            document.getElementById(element).value = value;
                        }
                    } else {
                        if (element.includes('filiais')) {
                            addValorAlphaInput('inptFilial', value[0].split('#@#')[0], value[0].split('#@#')[1])
                        }
                        if (element.includes('veiculos')) {
                            addValorAlphaInput('inptVeiculo', value[0].split('#@#')[0], value[0].split('#@#')[1])
                        }
                        if (element.includes('motoristas')) {
                            addValorAlphaInput('inptMotorista', value[0].split('#@#')[0], value[0].split('#@#')[1])
                        }
                        if (element.includes('setores')) {
                            addValorAlphaInput('inptSetorEntrega', value[0].split('#@#')[0], value[0].split('#@#')[1])
                        }
                        if (element.includes('cidades')) {
                            addValorAlphaInput('inptCidades', value[0].split('#@#')[0], value[0].split('#@#')[1])
                        }
                        if (element.includes('clientes')) {
                            addValorAlphaInput('inptCliente', value[0].split('#@#')[0], value[0].split('#@#')[1])
                        }
                        if (element.includes('tipo')) {
                            $("input[name=radio-mostrar][value=" + value[0] + "]").prop('checked', true);
                        }

                    }
                });
            } catch (ex) {
                console.error(ex);
            }

//            graficoBarInit();
        }
    });
}
var obj1, obj2;

function pesquisarGrafBarras() {
    var idsrom = '';
    var idsman = '';
    $.each(card, function (index, obj) {
        if (obj.tipo === 'MAN') {
            idsman += obj.id + ',';
        } else if (obj.tipo === 'ROM') {
            idsrom += obj.id + ',';
        }
    });

    idsrom = idsrom.substring(0, idsrom.length - 1);
    idsman = idsman.substring(0, idsman.length - 1);
    if (!idsman || idsman == '') {
        idsman = '0';
    }
    if (!idsrom || idsrom == '') {
        idsrom = '0';
    }

    $.ajax({
        url: 'PainelControlador',
        method: 'GET',
        data: {
            acao: 'carregarGraficosBarras',
            idsmanifesto: idsman,
            idsromaneio: idsrom
        },
        complete: function (jqXHR, textStatus) {
            var json = jqXHR.responseText.split('#@#');
            var barras_cliente = JSON.parse(json[0]);
            var barras_cidade = JSON.parse(json[1]);

            var barras_vei = JSON.parse(json[2]);
            graficoBarInit(barras_cliente, barras_cidade, barras_vei);
        }
    });
}

function criarPopularTable() {
//    $('.section-dica').hide();
    var section = $('.section-dados').html('');
    var table = $('<table>').addClass('table-dados'), thead = $('<thead>'), tr = $('<tr>'), tbody = $('<tbody>');
    tr.append($('<th>').text('Número'));
    tr.append($('<th>').text('Emissão'));
    tr.append($('<th>').text('Tipo'));
    tr.append($('<th>').text('Filial'));
    tr.append($('<th>').text('Veículo'));
    tr.append($('<th>').text('Motorista'));
    tr.append($('<th>').text('Peso Carga'));
    tr.append($('<th>').text('QTD Entregas/Coletas'));
    tr.append($('<th>').text('QTD Realizadas'));
    tr.append($('<th>').text('% Performance'));
    tr.append($('<th>').text('Valor Carga'));
    tr.append($('<th>').text('Volumes Carga'));
    tr.append($('<th>').text('Cubagem Carga'));
    tr.append($('<th>').text('QTD Coletas'));
    tr.append($('<th>').text('QTD Entregas'));

    thead.append(tr);
    table.append(thead);
    section.append(table);

    $.each(card, function (index, obj) {
        tr = $('<tr>');
        tr.append($('<td>').text(obj.numero));
        tr.append($('<td>').text(obj.emissao_em));
        tr.append($('<td>').text(obj.tipo === 'MAN' ? 'Manifesto' : 'Romaneio'));
        tr.append($('<td>').text(obj.filial_abreviatura));
        tr.append($('<td>').text(obj.placa));
        tr.append($('<td>').text(obj.nome_motorista));
        tr.append($('<td>').text(obj.peso_carga));
        tr.append($('<td>').text(obj.qtd_entregas));
        tr.append($('<td>').text(obj.qtd_entregas_realizadas));
        tr.append($('<td>').text(obj.porcentagem_entregas_realizadas));
        tr.append($('<td>').text(obj.valor_entregue + obj.valor_nao_entregue));
        tr.append($('<td>').text(obj.volume_entregue + obj.volume_nao_entregue));
        tr.append($('<td>').text(obj.peso_cubado));
        tr.append($('<td>').text(obj.tipo === 'MAN' ? '' : obj.qtd_coletas));
        tr.append($('<td>').text(obj.qtd_entregas - obj.qtd_coletas));
        tbody.append(tr);
    });
    table.append(tbody);

    table.tabelaGwDraggable({
        redimensionavel: true
    });
}


function criarPupularCard() {
    graficos.qtd_total_entregas = 0;
    graficos.qtd_total_entregas_realizadas = 0;
    graficos.peso_total = 0;
    graficos.capacidade_total = 0;
    graficos.peso_total_entregue = 0;
    graficos.peso_total_nao_entregue = 0;
    graficos.volume_total_entregue = 0;
    graficos.volume_total_nao_entregue = 0;
    graficos.valor_total_entregue = 0;
    graficos.valor_total_nao_entregue = 0;

    var section = $('.section-dados').html(''), container = null, li = null, label = null, ul = null, i = null;
    $.each(card, function (index, obj) {
        graficos.qtd_total_entregas += obj.qtd_entregas;
        graficos.qtd_total_entregas_realizadas += obj.qtd_entregas_realizadas;
        graficos.peso_total_entregue += obj.peso_entregue;

        graficos.peso_total += obj.peso_entregue + obj.peso_nao_entregue;
        graficos.capacidade_total += obj.capacidade_veiculo;

        graficos.peso_total_nao_entregue += obj.peso_nao_entregue;

        graficos.volume_total_entregue += obj.volume_entregue;
        graficos.volume_total_nao_entregue += obj.volume_nao_entregue;

        graficos.valor_total_entregue += obj.valor_entregue;
        graficos.valor_total_nao_entregue += obj.valor_nao_entregue;

        graficos.peso_cubado += obj.peso_cubado;
        graficos.peso_cubado_veiculo_total += obj.capacidade_cubagem_veiculo;

        if (obj.emissao_em.indexOf('/') === -1) {
            var dt = obj.emissao_em.split('-');
            obj.emissao_em = dt[2] + '/' + dt[1] + '/' + dt[0];
        }
        obj.peso_carga = String(obj.peso_carga).replace('.',',');

        container = $('<div>').addClass('container-dados ui-state-default');
        container.load('gwTrans/painel/card-painel.jsp', {'card': obj});
        section.append(container);
    });
}

function cardGraficoInit() {
    if (graficos.qtd_total_entregas > 0) {
        drawDonutChart('#graf-card-performance', graficos.qtd_total_entregas_realizadas * 100 / graficos.qtd_total_entregas, 150, 150, ".35em", "Performance", '(' + graficos.qtd_total_entregas_realizadas + '/' + graficos.qtd_total_entregas + ')');
    }

    if (graficos.capacidade_total > 0) {
        drawDonutChart('#graf-card-ocupacao-peso', graficos.peso_total * 100 / graficos.capacidade_total, 150, 150, ".35em", "Ocupação por Peso");
    }

    if (graficos.peso_cubado > 0) {
        drawDonutChart('#graf-card-ocupacao-cubagem', graficos.peso_cubado_veiculo_total * 100 / graficos.peso_cubado, 150, 150, ".35em", "Ocupação por m³");
    }
}

function gerarExcelGraficoCard() {

    var arr_graf_1 = [['Número do romaneio/Manifesto', 'Número do CT-e/Coleta', 'Filial do CT-e/Coleta', 'Cliente do CT-e/Coleta',
            'Cidade de destino', 'Peso da carga', 'Volumes da carga', 'Valor da carga', 'Realizado (Sim/Não)']];

    var arr_graf_2 = [['Número do Romaneio/Manifesto', 'Data', 'Placa', 'Motorista', 'Capacidade de Peso do veículo',
            'Peso da carga', '% Ocupação Peso', 'Capacidade de Cubagem do veículo', 'Cubagem da carga', '% Ocupação Cubagem']];

    var arr_graf_3 = [['Número do Romaneio/Manifesto', 'Data', 'Placa', 'Motorista', 'Capacidade de Peso do veículo',
            'Peso da carga', '% Ocupação Peso', 'Capacidade de Cubagem do veículo', 'Cubagem da carga', '% Ocupação Cubagem']];

    $.each(card, (index, obj) => {
        let percentualCub = 0, percentualPeso = 0;
        if (obj.capacidade_cubagem_veiculo !== 0) {
            percentualCub = obj.peso_cubado * 100 / obj.capacidade_cubagem_veiculo;
        }
        if (obj.capacidade_veiculo !== 0) {
            percentualPeso = colocarPonto(obj.peso_carga) * 100 / obj.capacidade_veiculo;
        }

        arr_graf_1.push([obj.numero, obj.numeros_cte, obj.filiais_cte, obj.nomes_clientes, obj.cidade_destino, obj.peso_carga, obj.volume_carga, obj.valor_carga, obj.realizada]);
        arr_graf_2.push([obj.numero, obj.emissao_em, obj.placa, obj.nome_motorista, obj.capacidade_veiculo, obj.peso_carga, percentualPeso, obj.capacidade_cubagem_veiculo, obj.peso_cubado, percentualCub]);
        arr_graf_3.push([obj.numero, obj.emissao_em, obj.placa, obj.nome_motorista, obj.capacidade_veiculo, obj.peso_carga, percentualPeso, obj.capacidade_cubagem_veiculo, obj.peso_cubado, percentualCub]);
    });


    var opts = [{
            sheetid: 'Performance',
            headers: false
        }, {
            sheetid: 'Ocupação por Peso',
            headers: false
        }, {
            sheetid: 'Ocupação por m³',
            headers: false
        }];
    alasql('SELECT * INTO XLSX("arquivo.xlsx", ?) FROM ?', [opts, [arr_graf_1, arr_graf_2, arr_graf_3]]);
}


/*
 * ######################################
 * ####### GRAFICO PIZZA - INICIO #######
 * ######################################
 */
function graficoPizzaInit() {

    google.charts.load("current", {packages: ["corechart"]});
    google.charts.setOnLoadCallback(drawChart);

    function drawChart() {
        var data = null;

        var options = {
            titleTextStyle: {color: '#0c253e', fontName: 'sans-serif', fontSize: 18, bold: true},
            tooltip: {textStyle: {color: 'black', bold: true}, showColorCode: true},
            is3D: false,
//        is3D: true,
            fontSize: '16',
            fontName: 'sans-serif',
            legend: {position: 'top', textStyle: {color: 'black', fontSize: 14, bold: true}},
            slices: {0: {color: '#13385c', offset: 0.05}, 1: {color: '#4a0725'}}
//        slices: {0: {color: '#13385c'}, 1: {color: '#4a0725'}}
        };
        var chart = new google.visualization.PieChart(document.getElementById('graf-pizza-peso'));
        options.title = 'Performance ( Peso )';
        data = google.visualization.arrayToDataTable([
            ['Peso total', 'Kg'],
            ['Entregue', graficos.peso_total_entregue],
            ['Não entregue', graficos.peso_total_nao_entregue]
        ]);
        chart.draw(data, options);

        chart = new google.visualization.PieChart(document.getElementById('graf-pizza-volume'));
        options.title = 'Performance ( Volumes )';
        data = google.visualization.arrayToDataTable([
            ['Volume total', ''],
            ['Entregue', graficos.volume_total_entregue],
            ['Não entregue', graficos.volume_total_nao_entregue]
        ]);
        chart.draw(data, options);

        chart = new google.visualization.PieChart(document.getElementById('graf-pizza-vl-carga'));
        options.title = 'Performance ( Valor Carga )';
        data = google.visualization.arrayToDataTable([
            ['Valor Carga', ''],
            ['Entregue', graficos.valor_total_entregue],
            ['Não entregue', graficos.valor_total_nao_entregue]
        ]);
        chart.draw(data, options);
        //Setando cursor
        setTimeout(function () {
            $('[column-id="Não entregue"]').css('cursor', 'pointer');
            $('[column-id="Entregue"]').css('cursor', 'pointer');
        }, 1000);
    }
}
/*
 * ######################################
 * ####### GRAFICO PIZZA - FINAL ########
 * ######################################
 */

function gerarExcelGraficoPizza() {
    var arr_graf_1 = [['Número do romaneio/Manifesto', 'Número do CT-e/Coleta', 'Filial do CT-e/Coleta', 'Cliente do CT-e/Coleta',
            'Cidade de destino', 'Peso da carga', 'Volumes da carga', 'Valor da carga', 'Realizado (Sim/Não)']];

    $.each(card, (index, obj) => {
        arr_graf_1.push([obj.numero, obj.numeros_cte, obj.filiais_cte, '', obj.cidade_destino, obj.peso_carga, obj.volume_carga, obj.valor_carga, obj.realizada]);
    });

    var opts = [{
            sheetid: 'Performance',
            headers: false
        }];
    alasql('SELECT * INTO XLSX("arquivo.xlsx", ?) FROM ?', [opts, [arr_graf_1]]);
}


/*
 * ######################################
 * ####### GRAFICO BAR - INICIO ########
 * ######################################
 */
var graf_barras_cliente = null, graf_barras_cidade = null, graf_barras_vei = null;
function graficoBarInit(barras_cliente, barras_cidade, barras_vei) {
    google.charts.load('current', {'packages': ['bar']});
    google.charts.setOnLoadCallback(drawChart);
    graf_barras_cliente = barras_cliente;
    graf_barras_cidade = barras_cidade;
    graf_barras_vei = barras_vei;

    function drawChart() {
        var arr_cliente = [['Clientes', 'Realizadas', 'Não Realizadas']];
        var arr_cidade = [['Cidades', 'Realizadas', 'Não Realizadas']];
        var arr_vei = [['Veículos', 'Realizadas', 'Não Realizadas']];

        $.each(barras_cliente, function (index, obj) {
            arr_cliente.push([obj.nome, obj.qtd_nao_realizada, obj.qtd_realizada]);
        });

        $.each(barras_cidade, function (index, obj) {
            arr_cidade.push([obj.cidade, obj.qtd_nao_realizada, obj.qtd_realizada]);
        });

        $.each(barras_vei, function (index, obj) {
            arr_vei.push([obj.placa, obj.qtd_nao_realizada, obj.qtd_realizada]);
        });

        var options = {
            chart: {
                title: 'Entregas/Coletas realizadas e não realizadas',
            },
            titleTextStyle: {
                color: '#0c253e',
                fontName: 'sans-serif',
                fontSize: 18,
                bold: true
            },
            vAxis: {
                format: '',
            },
            colors: ['#13385c', '#4a0725'],
            chartArea: {
                width: '50%'
            },
        };

        var chart = null;
        var data = google.visualization.arrayToDataTable(arr_cliente);

        chart = new google.charts.Bar(document.getElementById('graf-barra-qtd-entregas-cliente'));
        options.chart.subtitle = 'Gráfico separado por cliente';
        pintarSubTitleCharts(chart, options);
        chart.draw(data, google.charts.Bar.convertOptions(options));

        data = google.visualization.arrayToDataTable(arr_cidade);

        chart = new google.charts.Bar(document.getElementById('graf-barra-qtd-entregas-destino'));
        options.chart.subtitle = 'Gráfico separado por cidade';
        pintarSubTitleCharts(chart, options);
        chart.draw(data, google.charts.Bar.convertOptions(options));

        data = google.visualization.arrayToDataTable(arr_vei);

        chart = new google.charts.Bar(document.getElementById('graf-barra-qtd-entregas-veiculo'));
        options.chart.subtitle = 'Gráfico separado por veículo';
        pintarSubTitleCharts(chart, options);
        chart.draw(data, google.charts.Bar.convertOptions(options));
    }
}
/*
 * ######################################
 * ####### GRAFICO BAR - FINAL ##########
 * ######################################
 */

function gerarExcelGraficoBar() {
    var arr_graf_1 = [['Cliente', 'Quantidade de Entregas/Coletas', 'Quantidade de Entregas/Coletas realizadas', 'Quantidade de Entregas/Coletas não realizadas', '% de Performance das entregas/coletas']];
    var arr_graf_2 = [['Cidade', 'Quantidade de Entregas/Coletas', 'Quantidade de Entregas/Coletas realizadas', 'Quantidade de Entregas/Coletas não realizadas', '% de Performance das entregas/coletas']];
    var arr_graf_3 = [['Veículo', 'Quantidade de Entregas/Coletas', 'Quantidade de Entregas/Coletas realizadas', 'Quantidade de Entregas/Coletas não realizadas', '% de Performance das entregas/coletas']];

    $.each(graf_barras_cliente, (index, obj) => {
        arr_graf_1.push([obj.nome, obj.qtd_nao_realizada, obj.qtd_realizada, '']);
    });
    $.each(graf_barras_cidade, (index, obj) => {
        arr_graf_2.push([obj.cidade, obj.qtd_nao_realizada, obj.qtd_realizada, '']);
    });
    $.each(graf_barras_vei, (index, obj) => {
        arr_graf_3.push([obj.placa, obj.qtd_nao_realizada, obj.qtd_realizada, '']);
    });

    var opts = [{
            sheetid: 'Clientes',
            headers: false
        },{
            sheetid: 'Cidades',
            headers: false
        },{
            sheetid: 'Veículos',
            headers: false
        }];
    alasql('SELECT * INTO XLSX("arquivo.xlsx", ?) FROM ?', [opts, [arr_graf_1, arr_graf_2, arr_graf_3]]);
}

var duration = 500, transition = 200;

drawDonutChart('#graf-card-performance', $('#graf-card-performance').data('donut'), 150, 150, ".35em", "Performance", "(000/000)");
drawDonutChart('#graf-card-ocupacao-peso', $('#graf-card-ocupacao-peso').data('donut'), 150, 150, ".35em", "Ocupação por Peso");
drawDonutChart('#graf-card-ocupacao-cubagem', $('#graf-card-ocupacao-cubagem').data('donut'), 150, 150, ".35em", "Ocupação por m³");

function drawDonutChart(element, percent, width, height, text_y, title, quantidade) {

    width = typeof width !== 'undefined' ? width : 290;
    height = typeof height !== 'undefined' ? height : 290;
    text_y = typeof text_y !== 'undefined' ? text_y : "-.10em";
    $(element).html('');
    var dataset =
            {
                lower: calcPercent(0),
                upper: calcPercent(percent)
            },
            radius = Math.min(width, height) / 2,
            pie = d3.layout.pie().sort(null),
            format = d3.format(".0%");

    var arc = d3.svg.arc().innerRadius(radius - 20).outerRadius(radius);

    var svg = d3.select(element).append("div").append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    var span = null;
    if (quantidade) {
        span = d3.select(element).append("div").text(quantidade);
        $(span[0]).addClass('graf-card-title');
    }

    span = d3.select(element).append("div").text(title);
    $(span[0]).addClass('graf-card-title');

    var path = svg.selectAll("path")
            .data(pie(dataset.lower))
            .enter().append("path")
            .attr("class", function (d, i) {
                return "color" + i
            })
            .attr("d", arc)
            .each(function (d) {
                this._current = d;
            });

    var text = svg.append("text")
            .attr("text-anchor", "middle")
            .attr("dy", text_y);

    if (typeof (percent) === "string") {
        text.text(percent);
    } else {
        var progress = 0;
        var timeout = setTimeout(function () {
            clearTimeout(timeout);
            path = path.data(pie(dataset.upper));
            path.transition().duration(duration).attrTween("d", function (a) {
                var i = d3.interpolate(this._current, a);
                var i2 = d3.interpolate(progress, percent);
                this._current = i(0);
                return function (t) {
                    text.text(format(i2(t) / 100));
                    return arc(i(t));
                };
            });
        }, 200);
    }
}
;

function calcPercent(percent) {
    return [percent, 100 - percent];
}
;


function pintarSubTitleCharts(chart, options) {
    google.visualization.events.addListener(chart, 'ready', function () {
        var labels = document.getElementsByTagName('text');

        for (var i = 0; i < labels.length; i++) {
            var txt = labels[i].innerHTML;
            if (txt === 'Gráfico separado por veículo' || txt === 'Gráfico separado por cidade' || txt === 'Gráfico separado por cliente') {
                $(labels[i]).css('fill', 'rgb(12, 37, 62)');
                $(labels[i]).css('font-family', 'sans-serif');
                $(labels[i]).css('font-weight', 'bold');
            }
        }

        setTimeout(function () {
            $('.section-grafico').css('visibility', 'hidden');
            $('.section-dados').show();
            $('.bloqueio-tela').hide();
            $('.gif-bloq-tela').hide();
        }, 1000);
    });
}

class filtro {
    constructor(tipoLocalizar) {
        this.tipoLocalizar = tipoLocalizar;
    }

    getTipo() {
        return this.tipoLocalizar;
    }

    setTipo(tipoLocalizar) {
        this.tipoLocalizar = tipoLocalizar;
    }

}

var tipo = new filtro('veiculo');

function alterarTipo(e) {
    tipo.setTipo(e);
}

function verificarAtualizarPagina() {
    var atualizarObj = localStorage.getItem('atualizarPagina');
    if (atualizarObj) {
        var obj = JSON.parse(atualizarObj);
        if (obj.usuario == usuario && obj.tempo != "0") {
            $('#select-atualizar-resultados').val(obj.tempo);
            intervalAtualizarPagina = setInterval(function () {
                pesquisar(false);
            }, obj.tempo * 60 * 1000);
        }
    }
}